%% Change from March to September
% timeCounter, day_Num, Loop-in Reintialize, Output
clear;clc;

%% Initialization
timeCounter = 245; % March 60 September 245
data_Type = 'iicethic';
bins = 0:0.2:8; % in 0.2 thick bins
total_Area_Sum = zeros(1, numel(bins) - 1); % Total ice among certain periad
day_Num = 6; % Sept 6, March 7
NY=800; NX=544;
configuration = '4th';

% mesh file that includes the length of each grid
meshhgr='/mnt/storage0/xhu/CREG025-I/CREG025_coordinates.nc'; % horizontal mesh file

%% Extrct data whose latitude is norther than 55 degree
lat = GetNcVar(meshhgr,'nav_lat',[0 0],[NX,NY]);
e1t=GetNcVar(meshhgr,'e1t',[0 0],[NX NY]);
e2t=GetNcVar(meshhgr,'e2t',[0 0],[NX NY]);
e1t = e1t(lat > 55);
e2t = e2t(lat > 55);

%% Calculate the area
area = zeros(size(e1t));
[a,b] = size(e1t);
for i = 1:a
    for j = 1:b
        area(i,j) = e1t(i,j) * e1t(i,j);
    end
end

%% Read files and calculate the mean over 2003-2010
for yearCounter = 2003:2008
    for i = 1:day_Num
        date = num2date(yearCounter, timeCounter);
        
        srcP = '/mnt/storage0/clark/ANHA4-E34REF/'; % 4th
        ncfile=[srcP,'CREG025-E34REF_y',date,'_icemod.nc']; % 4th
        NY=800; NX=544; % dimension of the whole model domain
        subII = 1:544; subJJ = 1:800;
        iceC=GetNcVar(ncfile,data_Type,[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
        iceC = iceC(lat > 55);
        
        %% Calculate total area of each ice thickness domin
        total_Area = zeros(1, numel(bins) - 1);
        for ii = 1:(numel(bins) - 1)
            % extract target data
            temp1 = find(iceC > bins(ii));
            temp2 = find(iceC <= bins(ii + 1));
            
            % find the same number in these temps
            target = temp1(ismember(temp1, temp2));
            % calculate the total area
            total_Area(ii) = sum(area(target));
        end
        disp(['total area finished: ',num2str(i)]);
        total_Area_Sum = total_Area_Sum + total_Area;
        
        timeCounter = timeCounter + 5;
    end
    timeCounter = 245; % don't forget to change
    disp(yearCounter);
end

total_Area_Sum = total_Area_Sum / 1e6; % change the unit from m^2 to km^2
total_Area_Mean = total_Area_Sum / day_Num / 6;

%% Do plotting
% b = bar(0:0.2:7.8,total_Area);
% set(b,'BarWidth',1);
% create the data used for histogram plotting
b = bar(0.1:0.2:7.9, total_Area_Mean);
set(b,'BarWidth',1);
set(get(gca,'child'),'FaceColor','black','EdgeColor','w');
set(gca, 'fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
grid on;

%% Output
set(gcf, 'visible', 'on');
title(['Ice Thickness Distribution over 2003-2008',' September ',configuration, ' Degree'],'fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
xlabel('Ice Thickness \m');
xlabh = get(gca,'XLabel');
set(xlabh,'Position',get(xlabh,'Position') + [0 17000 0]);
ylabel('Area \km^2');
set(gca, 'Position', [0.13 0.085 0.775 0.815]);
title=get(gca, 'Title');
set(title, 'Position', get(title, 'Position') + [0 20000 0]);
print(gcf, '-dpng', '-r300' ,['Ice_Thickness_Distribution_2003-2008_','September_',configuration,'_Degree','.png']);

