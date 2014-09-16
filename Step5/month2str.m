function [ output ] = month2str( input )
%MONTH2STR Summary of this function goes here
%   Detailed explanation goes here
if input < 10
    output = ['0', num2str(input)];
else
    output = num2str(input);
end
end

