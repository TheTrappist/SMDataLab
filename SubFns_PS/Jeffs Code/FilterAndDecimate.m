function [x] = FilterAndDecimate(xd, num);

x = filter(ones(1, num), num, xd);


ind = num:num:length(xd);

x = x(ind); 
