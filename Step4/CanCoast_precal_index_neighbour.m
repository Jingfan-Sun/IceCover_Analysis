% Individual observation sites
clc;clear;
close all;
%% Read data
D = importdata('/home/jingfan/Step3/unified-sea-ice-thickness-cdr-1947-2012/CanCoast_summaries_1947_2010_v1.txt');
tmask_12 = GetNcVar('/mnt/storage0/xhu/CREG012-I/mask/CREG12_mask_v34.nc','tmask',[0 0 0 0],[1632 2400 1 1]);  % surface land mask
tmask_4 = GetNcVar('/mnt/storage0/xhu/CREG025-I/mesh_mask_creg025.nc','tmask',[0 0 0],[544 800 1]);  % surface land mask
m_proj('stereographic','latitude',70,'lon',-90, 'radius',20);
[row, col] = size(D.data);

%% Find same campaign
campaign_Name = cell(1, col); % save different names in the data
campaign_Name{1} = D.textdata{2, 2};
campaign_Index = 1; % save the start index of different campaign in campaign_name variable
campaign_Year = cell(1, 100);
campaign_Year{1,1} = D.data(1, 2);
categary_Index = 1; % save the index of categaries, e.g. 1, 2, 3, 4, ...
for i = 3: (row + 1)
    if(~strcmp(campaign_Name{categary_Index}, D.textdata{i, 2}))
        categary_Index = categary_Index + 1;
        campaign_Name{categary_Index} = D.textdata{i, 2};
        campaign_Index = [campaign_Index, i - 1];
    end
    campaign_Year{1, categary_Index} = [campaign_Year{1, categary_Index}, D.data(i-1, 2)];
end
campaign_Index = [campaign_Index, row + 1];

% remove the empty cell in campaign_Name
id = cellfun('length', campaign_Name);
campaign_Name(id == 0) = [];

%% Extrct numerical data
lat = D.data(:, 7);
lon = D.data(:, 8);
Yday = D.data(:, 3);
Avg_ic = D.data(:, 23);

%% Initialization
[~, length] = size(campaign_Index);
IceH_all = zeros(8, 365/5*9);
IceP_all = zeros(8, 365/5*9);
% record the neighbour index of each point on the track
neighbour_Index_12 = zeros(8, 9);
inverseDistance_all = zeros(8, 9);
ii = 1;

for i = 1: length - 1
    %% save the index of data 2003-2010
    data_Position = zeros(1, numel(campaign_Year{1, i}));
    jj = 1;
    for k = 1: numel(campaign_Year{1, i})
        tic;
        if(campaign_Year{1, i}(k) < 2002 || campaign_Year{1, i}(k) > 2010)
            continue;
        end
        data_Position(jj) = k;
        jj = jj + 1;
    end
    if(jj == 1)
        continue;
    end
    % Delete the extra 0s in the end of the array
    data_Position(data_Position == 0) = [];
    %% save neighbour and inversedistance in ANHA12
    % Read Lon and Lat
    srcP='/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
    ncfile=[srcP,'CREG012-EXH003_y2003m01d05_icemod.nc']; % 12th
    NY=2400; NX=1632; % dimension of the whole model domain
    subII=1:1632; subJJ=1:2400;
    lon_12=GetNcVar(ncfile,'nav_lon',[0 0],[1632 2400]);
    lat_12=GetNcVar(ncfile,'nav_lat',[0 0],[1632 2400]);
    % Read ice Thickness
    iceC=GetNcVar(ncfile,'iicethic',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
    iceC(tmask_12 == 0) = NaN;
    %% Interpolation information calculation
    % Find neighbour grid points
    [result,index]=sort((lat_12(:) - lat(campaign_Index(i))).*(lat_12(:) - lat(campaign_Index(i))) + (lon_12(:) - lon(campaign_Index(i))).*(lon_12(:) - lon(campaign_Index(i))));
    for k = 1:9
        if(~isnan(iceC(index(k))))
            neighbour_Index_12(ii, k) = index(k);
            inverseDistance_all(ii, k) = 1 / sum((m_ll2xy(lon(campaign_Index(i)), lat(campaign_Index(i))) - m_ll2xy(lon_12(index(k)), lat_12(index(k)))) .^ 2);
        else
            inverseDistance_all(ii, k) = 0;
        end
    end
    if(sum(inverseDistance_all(ii, :)) == 0)
        while(isnan(iceC(index(k))))
            k = k + 1;
        end
        neighbour_Index_12(ii, 9) = index(k);
        inverseDistance_all(ii, 9) = 1 / sum((m_ll2xy(lon(campaign_Index(i)), lat(campaign_Index(i))) - m_ll2xy(lon_12(index(k)), lat_12(index(k)))) .^ 2);
    end
    ii = ii + 1;
    disp(campaign_Name{i});
end
date = num2date(2002, 5);
ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc']; % 12th
iceC_first=GetNcVar(ncfile,'iicethic',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
for yearCounter = 2002: 2010
    tic;
    for timeCounter = 5: 5: 365
        date = num2date(yearCounter, timeCounter);
        ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc']; % 12th
        iceC=GetNcVar(ncfile,'iicethic',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]) - iceC_first;
        iceP = GetNcVar(ncfile,'iiceprod',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]) .* 2400;
        iceC(tmask_12 == 0) = NaN;
        iceP(tmask_12 == 0) = NaN;
        for jj = 1: 8
            point_iceC = 0;
            point_iceP = 0;
            sum_Distance = sum(inverseDistance_all(jj, :));
            for kk = 1: 9
                if(inverseDistance_all(jj, kk) ~= 0)
                    point_iceC = point_iceC + iceC(neighbour_Index_12(jj, kk)) * inverseDistance_all(jj, kk) / sum_Distance;
                    point_iceP = point_iceP + iceP(neighbour_Index_12(jj, kk)) * inverseDistance_all(jj, kk) / sum_Distance;
                end
            end
            IceH_all(jj, (timeCounter / 5 + (yearCounter - 2002) * 365/5)) = point_iceC;
            IceP_all(jj, (timeCounter / 5 + (yearCounter - 2002) * 365/5)) = point_iceP;
        end
        timeCounter
    end
    toc;
end
IceP_all_Year = IceP_all;
IceH_all_Day = IceH_all;
IceH_all_Year = IceH_all;
for i = 1: 9
    for j = ((73*(i-1)) + 2): (73*i)
        IceP_all_Year(:, j) = IceP_all_Year(:, j) + IceP_all_Year(:, j - 1);
    end   
end
for i = linspace(365/5*9, 2, 365/5*9-1)
   IceH_all_Day(:, i) = IceH_all_Day(:, i) - IceH_all_Day(:, i - 1); 
end
for i = 2: 9
    for j = ((73*(i-1)) + 2): (73*i)
        IceH_all_Year(:, j) = IceH_all_Year(:, j) - IceH_all_Year(:, ((73*(i-1)) + 1));
    end   
    IceH_all_Year(:, ((73*(i-1)) + 1)) = zeros(8, 1);
end
clear IceH_all;
save('IceH_all_Year', 'IceH_all_Year');
save('IceH_all_Day', 'IceH_all_Day');
save('IceP_all_Year', 'IceP_all_Year');
save('IceP_all', 'IceP_all');
