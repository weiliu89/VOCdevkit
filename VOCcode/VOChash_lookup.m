function ind = VOChash_lookup(hash,s,dataset)

if nargin < 2
    dataset = 'VOC2012';
end

hsize=numel(hash.key);
if strcmp(dataset, 'VOC2012')
    h=mod(str2double(s([3:4 6:11 13:end])),hsize)+1;
else
    h=mod(str2double(s),hsize)+1;
end
ind=hash.val{h}(strmatch(s,hash.key{h},'exact'));
