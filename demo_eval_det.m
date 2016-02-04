function demo_eval_det(resdir, testset, datadir, runparallel, verbose)
% This code shows how to evalaute the detection results.
%   resdir: the directory which stores the results
%   testset: the name of the set for test.
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
    verbose = false;
end

VOCopts = VOCinit(datadir, resdir, testset);

classes = VOCopts.classes;
num_classes = length(classes);
aps = zeros(1, num_classes);
recs = cell(1, num_classes);
precs = cell(1, num_classes);
if runparallel
    parfor c = 1:num_classes
        cls = classes{c};
        fprintf('Processing %s...\n', cls);
        [recs{c}, precs{c}, aps(c)] = VOCevaldet(VOCopts, 'comp4', cls, verbose);
        fprintf('%s: %f\n', cls, aps(c));
    end
else
    for c = 1:num_classes
        cls = classes{c};
        fprintf('Processing %s...\n', cls);
        [recs{c}, precs{c}, aps(c)] = VOCevaldet(VOCopts, 'comp4', cls, verbose);
        fprintf('%s: %f\n', cls, aps(c));
    end
end
fprintf('mAP: %f\n', mean(aps));
for c = 1:num_classes
    clf; plot(recs{c}, precs{c});
    pause;
end