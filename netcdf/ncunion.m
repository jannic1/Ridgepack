function [outset]=ncunion(firstset,secondset)

% NCUNION - Generates a cell array as the difference between two cell arrays
%
% function [outset]=ncunion(firstset,secondset)
%
% This function generates the union of two sets presented as 1D
% cell arrays.  This is similar to the matlab function union, except the 
% output is not sorted and occurs in the same order as elements in 
% firstset.  Also, elements are not repeated.
%
% Input:
% firstset   - cell array with elements that you want to test for commonality
% secondeset - comparing cell array
%
% Output:
% outset - cell array containing elements that are common between first set
%          and the second set
%
% Example:
% firstset={'x','y','z','a'}
% secondset={'a','z'}
% outset={'z','a'}
% 
% In this example, the standard matlab union would provide
% outset={'a','z'}
%
% Written by Andrew Roberts 2012
% Department of Oceanography, Naval Postgraduate School
%
% $Id$

global debug;
if debug; disp(['Entering ',mfilename,'...']); end

if ~iscell(firstset)
	error('firstset is not a cell array');
elseif ~iscell(secondset)
	error('secondset is not a cell array');
end

outset=firstset;
for j=1:length(secondset)
 if ~any(strcmp(char(secondset{j}),firstset))
   outset{end+1}=secondset{j};
 end
end

if debug; disp(['...Leaving ',mfilename]); end
