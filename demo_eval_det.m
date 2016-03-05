function demo_eval_det(resdir, testset, datadir, runparallel, evaldet, verbose, draw)
% This code shows how to evalaute the detection results.
%   resdir: the directory which stores the results
%   testset: the name of the set for test.
%   datadir: the directory which contains all the data/code.
%   runparallel: if true, run evaluation in parallel.
%   evaldet: if true, only test on images with detection results.
%   verbose: if true, display progress.
%   draw: if true, draw the precision recall curve at the end.
%
% Example:
% demo_eval_det('/path/to/results/VOC2007/SSD_300x300', 'test',
% '/path/to/data/VOCdevkit', true, false, false)
%

addpath('VOCcode');

cwd=cd;
cwd(cwd=='\')='/';

if nargin < 1
    resdir = [cwd '/results/VOC2007/'];
end
if nargin < 2
    testset = 'test';
end
if nargin < 3
    datadir = [cwd '/'];
end
if nargin < 4
    runparallel = false;
end
if nargin < 5
    evaldet = false;
end
if nargin < 6
    verbose = false;
end
if nargin < 7
    draw = false;
end

VOCopts = VOCinit(datadir, resdir, testset);

classes = VOCopts.classes;
num_classes = length(classes);
aps = zeros(1, num_classes);
recs = cell(1, num_classes);
precs = cell(1, num_classes);
if runparallel
    % num_cores = feature('numcores');
    if isempty(gcp('nocreate'))
        parpool(num_classes);
    end
    parfor c = 1:num_classes
        cls = classes{c};
        [recs{c}, precs{c}, aps(c)] = ...
            VOCevaldet(VOCopts, 'comp4', cls, evaldet, verbose);
    end
    for c = 1:num_classes
        fprintf('%s: ap: %f\n', classes{c}, aps(c));
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
