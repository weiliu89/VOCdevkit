function VOCopts = VOCinit(datadir, dataset, resdir, testset, trainset)
% This function initialize the VOCdevkit.
%   datadir: the root directory which contains the VOCcode and VOC2***.
%   dataset: the name of the dataset. "VOC2012" or "VOC2007".
%   resdir: the directory which contains the results.
%   testset: the name of the test set. "test" or "val".
%   trainset: the name of the train set. "train" or "trainval".

% get devkit directory with forward slashes
devkitroot=strrep(fileparts(fileparts(mfilename('fullpath'))),'\','/');

if nargin < 1
    datadir = [devkitroot '/'];
else
    datadir = [datadir '/'];
end
if nargin < 2
    dataset = 'VOC2012';
end
if nargin < 3
    resdir = [devkitroot '/results/' dataset '/'];
else
    resdir = [resdir '/'];
end
if nargin < 4
    testset = 'val';
end
if nargin < 5
    trainset = 'train';
end
clear VOCopts

% dataset
%
% Note for experienced users: the VOC2008-11 test sets are subsets
% of the VOC2012 test set. You don't need to do anything special
% to submit results for VOC2008-11.

VOCopts.dataset=dataset;

% change this path to point to your copy of the PASCAL VOC data
VOCopts.datadir=datadir;

% change this path to a writable directory for your results
VOCopts.resdir=resdir;

% change this path to a writable local directory for the example code
VOCopts.localdir=[devkitroot '/local/' VOCopts.dataset '/'];
if ~exist(VOCopts.localdir, 'dir')
    mkdir(VOCopts.localdir);
end

% initialize the training set

VOCopts.trainset=trainset; % use train for development
% VOCopts.trainset='trainval'; % use train+val for final challenge

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
VOCopts.layout.respath=[VOCopts.resdir 'Layout/%s_layout_' VOCopts.testset '.xml'];

% initialize action task paths

VOCopts.action.imgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Action/%s.txt'];
VOCopts.action.clsimgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Action/%s_%s.txt'];
VOCopts.action.respath=[VOCopts.resdir 'Action/%s_action_' VOCopts.testset '_%s.txt'];

% initialize the VOC challenge options

% classes

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

VOCopts.nclasses=length(VOCopts.classes);	

% poses

VOCopts.poses={...
    'Unspecified'
    'Left'
    'Right'
    'Frontal'
    'Rear'};

VOCopts.nposes=length(VOCopts.poses);

% layout parts

VOCopts.parts={...
    'head'
    'hand'
    'foot'};    

VOCopts.nparts=length(VOCopts.parts);

VOCopts.maxparts=[1 2 2];   % max of each of above parts

% actions

VOCopts.actions={...    
    'other'             % skip this when training classifiers
    'jumping'
    'phoning'
    'playinginstrument'
    'reading'
    'ridingbike'
    'ridinghorse'
    'running'
    'takingphoto'
    'usingcomputer'
    'walking'};

VOCopts.nactions=length(VOCopts.actions);

% overlap threshold

VOCopts.minoverlap=0.5;

% annotation cache for evaluation

VOCopts.annocachepath=[VOCopts.localdir '%s_anno.mat'];

% options for example implementations

VOCopts.exfdpath=[VOCopts.localdir '%s_fd.mat'];

assignin('caller', 'VOCopts', VOCopts);