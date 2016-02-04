function VOCopts = VOCinit(datadir, resdir, testset, VOC2006)
% This function initialize the VOCdevkit.
%   datadir: the root directory which contains the VOCcode and VOC2***.
%   resdir: the directory which contains the results.
%   testset: the name of the test set. "test" or "val".
%   VOC2006: if true, use VOC2006 dataset; otherwise, use VOC2007.

% get current directory with forward slashes

cwd=cd;
cwd(cwd=='\')='/';

if nargin < 1
    datadir = cwd;
end
if nargin < 3
    testset = 'test';
end
if nargin < 4
    VOC2006 = false;
end
clear VOCopts

% dataset

if VOC2006
    VOCopts.dataset='VOC2006';
else
    VOCopts.dataset='VOC2007';
end

if nargin < 2
    resdir = [cwd '/results/' VOCopts.dataset];
end

datadir = [datadir '/'];
resdir = [resdir '/'];

% change this path to point to your copy of the PASCAL VOC data
VOCopts.datadir=datadir;

% change this path to a writable directory for your results
VOCopts.resdir=resdir;

% change this path to a writable local directory for the example code
VOCopts.localdir=[cwd '/local/' VOCopts.dataset '/'];
VOCopts.gtcachedir=[VOCopts.localdir 'cache'];
VOCopts.gtcachepath=[VOCopts.gtcachedir '/%s_gt.mat'];

% initialize the test set

VOCopts.testset=testset; % use validation data for development test set
% VOCopts.testset='test'; % use test set for final challenge

% initialize main challenge paths

VOCopts.annopath=[VOCopts.datadir VOCopts.dataset '/Annotations/%s.xml'];
VOCopts.imgpath=[VOCopts.datadir VOCopts.dataset '/JPEGImages/%s.jpg'];
VOCopts.imgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Main/%s.txt'];
VOCopts.clsimgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Main/%s_%s.txt'];
VOCopts.clsrespath=[VOCopts.resdir 'Main/%s_cls_' VOCopts.testset '_%s.txt'];
VOCopts.detrespath=[VOCopts.resdir 'Main/%s_det_' VOCopts.testset '_%s.txt'];

% initialize segmentation task paths

VOCopts.seg.clsimgpath=[VOCopts.datadir VOCopts.dataset '/SegmentationClass/%s.png'];
VOCopts.seg.instimgpath=[VOCopts.datadir VOCopts.dataset '/SegmentationObject/%s.png'];

VOCopts.seg.imgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Segmentation/%s.txt'];

VOCopts.seg.clsresdir=[VOCopts.resdir 'Segmentation/%s_%s_cls'];
VOCopts.seg.instresdir=[VOCopts.resdir 'Segmentation/%s_%s_inst'];
VOCopts.seg.clsrespath=[VOCopts.seg.clsresdir '/%s.png'];
VOCopts.seg.instrespath=[VOCopts.seg.instresdir '/%s.png'];

% initialize layout task paths

VOCopts.layout.imgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Layout/%s.txt'];
VOCopts.layout.respath=[VOCopts.resdir 'Layout/%s_layout_' VOCopts.testset '_%s.xml'];

% initialize the VOC challenge options

if VOC2006
    
    % VOC2006 classes
    
    VOCopts.classes={...
        'bicycle'
        'bus'
        'car'
        'cat'
        'cow'
        'dog'
        'horse'
        'motorbike'
        'person'
        'sheep'};
else

    % VOC2007 classes
    
    VOCopts.classes={...
        'aeroplane'
        'bicycle'
        'bird'
        'boat'
        'bottle'
        'bus'
        'car'
        'cat'
        'chair'
        'cow'
        'diningtable'
        'dog'
        'horse'
        'motorbike'
        'person'
        'pottedplant'
        'sheep'
        'sofa'
        'train'
        'tvmonitor'};
end

VOCopts.nclasses=length(VOCopts.classes);	

VOCopts.poses={...
    'Unspecified'
    'SideFaceLeft'
    'SideFaceRight'
    'Frontal'
    'Rear'};

VOCopts.nposes=length(VOCopts.poses);

VOCopts.parts={...
    'head'
    'hand'
    'foot'};    

VOCopts.maxparts=[1 2 2];   % max of each of above parts

VOCopts.nparts=length(VOCopts.parts);

VOCopts.minoverlap=0.5;

% initialize example options

VOCopts.exannocachepath=[VOCopts.localdir '%s_anno.mat'];

VOCopts.exfdpath=[VOCopts.localdir '%s_fd.mat'];

assignin('caller', 'VOCopts', VOCopts);