function CMU = mocHuman
% Load human label file for segmentation. Meanwhile, obtain the list of all the motion capture file.
%
% Output
%   CMU     -  a container
%     nm    -  sequence name
%       seg
%       cnames
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 06-24-2014

prIn('mocHuman');

% all subject
CMU = getAllNames;

prOut;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [seg, cnames] = cmuOne(fid)
% Parse one mocap's label.
%
% Input
%   fid     -  file handler
%
% Output
%   seg     -  segmentation parameter
%   cnames  -  class names, 1 x k (cell)

% initialize
maxk = 20; maxm = 100;
k = 0; m = 0;
cnames = cell(1, maxk);
L = zeros(1, maxm);
s = ones(1, maxm + 1);

while ~feof(fid)
    line = fgetl(fid);
    parts = tokenise(line, ' ');

    % finish one mocap
    if isempty(parts)
        break;
    end

    m = m + 1;

    % label
    cname = parts{1};
    c = strloc(cname, cnames);
    if c == 0 % new class?
        k = k + 1;
        cnames{k} = cname;
        c = k;
    end
    L(m) = c;

    % boundary
    p2 = floor(str2double(parts{3}));
    s(m + 1) = p2 + 1;
end

% remove no-used fields
cnames(k + 1 : end) = [];
s(m + 2 : end) = [];
L(m + 1 : end) = [];

seg = newSeg('s', s, 'G', L2G(L, k));

%%%%%%%%%%%%%%%%%%%%%%%%%%
function CMU = getAllNames
% Obtain all names under the folder data/cmu.
%
% Output
%   CMU  
%     name  
%       seg
%       cnames

% specified in addPath.m
global footpath; 

% path
foldpath = sprintf('%s/data/cmu', footpath);

% person numbers
pnos = dir(foldpath);
for i = 1 : length(pnos)
    pno = pnos(i).name;
    pos = regexp(pno, '^\d', 'once');
    if ~isempty(pos)
        pnopath = sprintf('%s/%s', foldpath, pno);

        % motion trials
        trials = dir(pnopath);
        for j = 1 : length(trials)
            trial = trials(j).name;
            trialL = lower(trial);
            pos = regexp(trialL, '^[\w\d_]+\.amc$', 'once');
            if ~isempty(pos)
                name = sprintf('S%s', trialL(1 : end - 4));
                CMU.(name).seg = [];
                CMU.(name).cnames = [];
            end
        end
    end
end
