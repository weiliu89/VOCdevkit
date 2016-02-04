function demo_eval_det(resdir, testset, datadir)
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
if nargin < 3
    testset = 'test';
end
if nargin < 3
    datadir = [cwd '/'];
end

VOCinit(datadir, resdir, testset);

classes = VOCopts.classes;
num_classes = length(classes);
aps = zeros(1, num_classes);
recs = cell(1, num_classes);
precs = cell(1, num_classes);
for c = 1:num_classes
    [recs{c}, precs{c}, aps(c)] = VOCevaldet(VOCopts, 'comp4', classes{c});
end
disp(aps');
fprintf('mAP: %f\n', mean(aps));
for c = 1:num_classes
    clf; plot(recs{c}, precs{c});
    pause;
end