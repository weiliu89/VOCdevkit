function [rec,prec,ap] = VOCevaldet(VOCopts,id,cls,evaldet,verbose,draw)

if nargin < 4
    evaldet = false;
end
if nargin < 5
    verbose = true;
end
if nargin < 6
    draw = false;
end

% load test set

cp=sprintf(VOCopts.annocachepath,VOCopts.testset);
if exist(cp,'file')
    if verbose
        fprintf('%s: pr: loading ground truth\n',cls);
    end
    load(cp,'gtids','recs');
else
    fid=fopen(sprintf(VOCopts.imgsetpath,VOCopts.testset),'r');
    if fid==-1
        fprintf('%s: error: cannot open file\n',cls);
        return;
    end
    C=textscan(fid,'%s %d');
    gtids=C{1};
    clear C
    fclose(fid);
    tic;
    for i=1:length(gtids)
        % display progress
        if toc>1
            fprintf('%s: pr: load: %d/%d\n',cls,i,length(gtids));
            drawnow;
            tic;
        end
        
        % read annotation
        recs(i)=PASreadrecord(sprintf(VOCopts.annopath,gtids{i}));
    end
    save(cp,'gtids','recs');
end

if verbose
    fprintf('%s: pr: evaluating detections\n',cls);
end

% hash image ids
hash=VOChash_init(gtids, VOCopts.dataset);

% load results
fid=fopen(sprintf(VOCopts.detrespath,id,cls),'r');
if fid==-1
    fprintf('%s: error: cannot open file\n',cls);
    return;
end
C=textscan(fid,'%s %f %f %f %f %f');
ids=C{1};
confidence=C{2};
BB=cat(2, C{3:end})';
clear C
fclose(fid);

% extract ground truth objects
npos=0;
if evaldet
    detids = unique(ids);
    gt(length(detids))=struct('BB',[],'diff',[],'det',[]);
    for d=1:length(detids)
        % find ground truth image
        i=VOChash_lookup(hash,detids{d},VOCopts.dataset);
        if isempty(i)
            error('unrecognized image "%s"',detids{d});
        elseif length(i)>1
            error('multiple image "%s"',detids{d});
        end
        % extract objects of class
        clsinds=strcmp(cls,{recs(i).objects(:).class});
        gt(i).BB=cat(1,recs(i).objects(clsinds).bbox)';
        gt(i).diff=[recs(i).objects(clsinds).difficult];
        gt(i).det=false(length(clsinds),1);
        npos=npos+sum(~gt(i).diff);
    end
else
    gt(length(gtids))=struct('BB',[],'diff',[],'det',[]);
    for i=1:length(gtids)
        % extract objects of class
        clsinds=strcmp(cls,{recs(i).objects(:).class});
        gt(i).BB=cat(1,recs(i).objects(clsinds).bbox)';
        gt(i).diff=[recs(i).objects(clsinds).difficult];
        gt(i).det=false(length(clsinds),1);
        npos=npos+sum(~gt(i).diff);
    end
end

% sort detections by decreasing confidence
[~,si]=sort(-confidence);
ids=ids(si);
BB=BB(:,si);

% assign detections to ground truth objects
nd=length(confidence);
tp=zeros(nd,1);
fp=zeros(nd,1);
tic;
for d=1:nd
    % display progress
    if toc>1
        if verbose
            fprintf('%s: pr: compute: %d/%d\n',cls,d,nd);
            drawnow;
        end
        tic;
    end
    
    % find ground truth image
    i=VOChash_lookup(hash,ids{d},VOCopts.dataset);
    if isempty(i)
        error('unrecognized image "%s"',ids{d});
    elseif length(i)>1
        error('multiple image "%s"',ids{d});
    end
    
    % assign detection to ground truth object if any
    bb=BB(:,d);
    ovmax=-inf;
    for j=1:size(gt(i).BB,2)
        bbgt=gt(i).BB(:,j);
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 && ih>0
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
                (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
                iw*ih;
            ov=iw*ih/ua;
            if ov>ovmax
                ovmax=ov;
                jmax=j;
            end
        end
    end
    % assign detection as true positive/don't care/false positive
    if ovmax>=VOCopts.minoverlap
        if ~gt(i).diff(jmax)
            if ~gt(i).det(jmax)
                tp(d)=1;            % true positive
                gt(i).det(jmax)=true;
            else
                fp(d)=1;            % false positive (multiple detection)
            end
        end
    else
        fp(d)=1;                    % false positive
    end
end

% compute precision/recall
fp=cumsum(fp);
tp=cumsum(tp);
rec=tp/npos;
prec=tp./(fp+tp);

ap=VOCap(rec,prec);

if draw
    % plot precision/recall
    plot(rec,prec,'-');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('class: %s, subset: %s, AP = %.3f',cls,VOCopts.testset,ap));
end
