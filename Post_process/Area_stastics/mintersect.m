function [runIntersect, varargout] = mintersect(varargin)
%MINTERSECT Multiple set intersection.
% MINTERSECT(A,B,C,...) when A,B,C... are vectors returns the values
% common to all A,B,C... The result will be sorted. A,B,C... can be cell
% arrays of strings.
%
% MINTERSECT repeatedly evaluates INTERSECT on successive pairs of sets,
% which may not be very efficient. For a large number of sets, this should
% probably be reimplemented using some kind of tree algorithm.
%
% MINTERSECT(A,B,'rows') when A,B,C... are matrices with the same
% number of columns returns the rows common to all A,B,C...
%
% [C,IA,IB,IC,...] = MINTERSECT(...) returns required number of indices, similar to INTERSECT
%
% See also INTERSECT

flag = 0;
if isempty(varargin),
error('No inputs specified.')
else
if isequal(varargin{end},'rows'),
flag = 'rows';
setArray = varargin(1:end-1);
else
setArray = varargin;
end
end

nout = min(length(setArray),max(nargout,1)-1);
varargout = cell(nout, 1);
for k = 1:nout
varargout(k) = {(1:length(setArray{k}))'};
end

runIntersect = setArray{1};
for i = 2:length(setArray),

if isequal(flag,'rows'),
[runIntersect, i1, i2] = intersect(runIntersect,setArray{i},'rows');
elseif flag == 0,
[runIntersect, i1, i2] = intersect(runIntersect,setArray{i});
else
error('Flag not set.')
end
for k = 2:min(i,nout+1)
varargout(k-1) = {varargout{k-1}(i1)};
end
if k <= nout
varargout(k) = {i2};
end

if isempty(runIntersect)
for k = 1:nout
varargout(k) = {};
end
return
end

end