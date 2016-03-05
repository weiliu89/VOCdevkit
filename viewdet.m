function viewdet(cls, id, onlytp, onlyfp, resdir, testset, datadir)
% This code displays the detection results for cls.
%   cls: the name of the class whose results are displayed. Required!
%   id: the competition id, e.g. 'comp3' or 'comp4'.
%   onlytp: if true, only show the true positive.
%   onlyfp: if true, only show the false positive.
%   resdir: the directory which stores the results
%   testset: the name of the set for test.
%   datadir: the directory which contains all the data/code.
%
% Example: viewdet('aeroplane', 'comp4', true, false, '/path/to/results',
%                  'test', '/path/to/data')
%

% change this path if you install the VOC code elsewhere
addpath([cd '/VOCcode']);

cwd=cd;
cwd(cwd=='\')='/';

if nargin < 1
    error('usage: viewdet(cls, id, onlytp, onlyfp, resdir, testset, datadir)');
end
if nargin < 2
    id = 'comp3';
end
if nargin < 3
    onlytp = false;
end
if nargin < 4
    onlyfp = false;
end
if nargin < 5
    resdir = [cwd '/results/VOC2007/'];
end
if nargin < 6
    testset = 'test';
end
if nargin < 7
    datadir = [cwd '/'];
end

% initialize VOC options
VOCopts = VOCinit(datadir, resdir, testset);

% load test set ground truth
cp=sprintf(VOCopts.exannocachepath,VOCopts.testset);
if exist(cp,'file')
    fprintf('%s: pr: loading ground truth\n',cls);
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

% extract ground truth objects
npos=0;
gt(length(gtids))=struct('BB',[],'diff',[],'det',[]);
for i=1:length(gtids)
    % extract objects of class
    clsinds=strcmp(cls,{recs(i).objects(:).class});
    gt(i).BB=cat(1,recs(i).objects(clsinds).bbox)';
    gt(i).diff=[recs(i).objects(clsinds).difficult];
    gt(i).det=false(length(clsinds),1);
    npos=npos+sum(~gt(i).diff);
end

% load results
[ids,confidence,b1,b2,b3,b4]=textread(sprintf(VOCopts.detrespath,id,cls),'%s %f %f %f %f %f');
BB=[b1 b2 b3 b4]';

% sort detections by decreasing confidence
[sc,si]=sort(-confidence);
ids=ids(si);
BB=BB(:,si);

% view detections
nd=length(confidence);
tic;
for d=1:nd
    % display progress
    if onlytp && toc>1
        fprintf('%s: viewdet: find true pos: %d/%d\n',cls,i,length(gtids));
        drawnow;
        tic;
    end
    
    % find ground truth image
    i=strmatch(ids{d},gtids,'exact');
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
    tp=0;
    fp=0;
    if ovmax>=VOCopts.minoverlap
        if ~gt(i).diff(jmax)
            if ~gt(i).det(jmax)
                tp=1;            % true positive
                gt(i).det(jmax)=true;
            else
                fp=1;            % false positive (multiple detection)
            end
        end
    else
        fp=1;                    % false positive
    end
    
    % skip false positives
    if onlytp && fp
        continue
    end
    if onlyfp && tp
        continue
    end
    
    % read image
    I=imread(sprintf(VOCopts.imgpath,gtids{i}));
    
    % draw detection bounding box and ground truth bounding box (if any)
    imagesc(I);
    hold on;
    for j = 1:size(gt(i).BB, 2)
        bbgt=gt(i).BB(:,j);
        plot(bbgt([1 3 3 1 1]),bbgt([2 2 4 4 2]),'y-','linewidth',2);
    end
    if ovmax>=VOCopts.minoverlap
        bbgt=gt(i).BB(:,jmax);
        plot(bbgt([1 3 3 1 1]),bbgt([2 2 4 4 2]),'g-','linewidth',2);
        plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),'g:','linewidth',2);
    else
        plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),'r-','linewidth',2);
    end
    text(bb(1), bb(2), sprintf('%.2f',ovmax), 'BackgroundColor', 'w');
    hold off;
    axis image;
    axis off;
    title(sprintf('det %d/%d: image: "%s" (green=true pos,red=false pos,yellow=ground truth',...
        d,nd,gtids{i}));
    
    fprintf('press any key to continue with next image\n');
    pause;
end
