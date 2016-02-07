function demo_eval_det(datadir, dataset, resdir, testset, evaldet, runparallel, verbose, draw)
% This code shows how to evalaute the detection results.
%   datadir: the root directory which contains the VOCcode and VOC2***.
%   dataset: the name of the dataset. "VOC2012" or "VOC2007".
%   resdir: the directory which contains the results.
%   testset: the name of the test set. "test" or "val".
%   evaldet: if true, only test on images with detection results.
%   runparallel: if true, run evaluation in parallel.
%   verbose: if true, display progress.
%   draw: if true, draw the precision recall curve.
%
% Example: demo_eval_det('/path/to/data', 'VOC2007', '/path/to/results', 'test', true)
%

% get devkit directory with forward slashes
devkitroot=strrep(fileparts(fileparts(mfilename('fullpath'))),'\','/');

if nargin < 1
    datadir = [devkitroot '/'];
end
if nargin < 2
    dataset = 'VOC2007';
end
if nargin < 3
    resdir = [devkitroot '/results/' dataset '/'];
end
if nargin < 4
    testset = 'test';
end
if nargin < 5
    evaldet = false;
end
if nargin < 6
    runparallel = false;
end
if nargin < 7
    verbose = false;
end
if nargin < 8
    draw = false;
end

VOCopts = VOCinit(datadir, dataset, resdir, testset);

classes = VOCopts.classes;
num_classes = length(classes);
aps = zeros(1, num_classes);
recs = cell(1, num_classes);
precs = cell(1, num_classes);
if runparallel
    num_cores = feature('numcores');
    if isempty(gcp('nocreate'))
        parpool(num_cores);
    end
    parfor c = 1:num_classes
        cls = classes{c};
        [recs{c}, precs{c}, aps(c)] = ...
            VOCevaldet(VOCopts, 'comp4', cls, evaldet, verbose);
        fprintf('%s: ap: %f\n', cls, aps(c));
    end
else
    for c = 1:num_classes
        cls = classes{c};
        [recs{c}, precs{c}, aps(c)] = ...
            VOCevaldet(VOCopts, 'comp4', cls, evaldet, verbose);
        fprintf('%s: ap: %f\n', cls, aps(c));
    end
end
fprintf('mAP: %f\n', mean(aps));

resfile = sprintf('%s/results.mat', resdir);
save(resfile, 'aps', 'recs', 'precs');

if draw
    for c = 1:num_classes
        cls = classes{c};
        clf; plot(recs{c},precs{c},'-');
        grid;
        xlabel 'recall'
        ylabel 'precision'
        title(sprintf('class: %s, subset: %s, AP = %.3f',cls,VOCopts.testset,aps(c)));
        pause;
    end
end