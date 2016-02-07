function displayImages(datadir, dataset, testset)

devkitroot=strrep(fileparts(fileparts(mfilename('fullpath'))),'\','/');

if nargin < 1
    datadir = [devkitroot '/'];
end
if nargin < 2
    dataset = 'VOC2007';
end
if nargin < 3
    testset = 'test';
end

VOCopts = VOCinit(datadir, dataset, '', testset);

fid=fopen(sprintf(VOCopts.imgsetpath,VOCopts.testset),'r');
if fid==-1
    fprintf('%s: error: cannot open file\n',cls);
    return;
end
C=textscan(fid,'%s %d');
gtids=C{1};
clear C
fclose(fid);

for i = 1:length(gtids)
    img=imread(sprintf(VOCopts.imgpath,gtids{i}));
    imshow(img);
    % get the figure and axes handles
    hFig = gcf;
    hAx  = gca;
    % set the figure to full screen
    set(hFig,'units','normalized','outerposition',[0 0 1 1]);
    % set the axes to full screen
    set(hAx,'Unit','normalized','Position',[0 0 1 1]);
    % hide the toolbar
    set(hFig,'menubar','none')
    % to hide the title
    set(hFig,'NumberTitle','off');
    pause;
end