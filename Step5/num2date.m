function date = num2date(yearCounter, timeCounter)
% change numbers into date(normal year)
% usage:
%       num2date(year, the number of days in the year)
%       e.g. num2date(2013, 150)
% output:
%       date
% July 2014,   sunjfsjfan@gmail.com

days = [31 59 90 120 151 181 212 243 273 304 334 365];


timeM = numel(days(days < timeCounter)) + 1;
if(timeM == 1)
    timeD = timeCounter;
else
    timeD = timeCounter - days(timeM - 1);
end

if(timeM < 10 && timeM > 0)
    timeM = ['0',num2str(timeM)];
else
    timeM = num2str(timeM);
end
if(timeD < 10 && timeD > 0)
    timeD = ['0',num2str(timeD)];
else
    timeD = num2str(timeD);
end

date=[num2str(yearCounter),'m',timeM,'d',timeD];

end