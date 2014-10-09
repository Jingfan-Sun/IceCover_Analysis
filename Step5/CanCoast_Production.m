% Individual observation sites
clc;clear;
close all;
%% Read data
D = importdata('/home/jingfan/Step3/unified-sea-ice-thickness-cdr-1947-2012/CanCoast_summaries_1947_2010_v1.txt');
tmask_12 = GetNcVar('/mnt/storage0/xhu/CREG012-I/mask/CREG12_mask_v34.nc','tmask',[0 0 0 0],[1632 2400 1 1]);  % surface land mask
tmask_4 = GetNcVar('/mnt/storage0/xhu/CREG025-I/mesh_mask_creg025.nc','tmask',[0 0 0],[544 800 1]);  % surface land mask
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
% record the neighbour index of each point on the track
neighbour_Index_12 = zeros(8, 9);
inverseDistance_all = zeros(8, 9);
ii = 1;
load IceH_all_Year;
load IceP_all;
load IceP_all_Year;
load IceH_all_Day;
valid_plotIndex = 1; % used for plotting production plots
%% Calculate track data for later plot
for i = 1: length - 1
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
    figure;
    set(gcf, 'Position', [560 524 560 700]);
    %% Line plot
    subplot(311);
    x = 1: numel(data_Position);
    % Date used for the X-Axis
    date_X = zeros(1, numel(x));
    yearCounter_1 = campaign_Year{1, i}(data_Position(1));
    timeCounter_1 = 5 * round(Yday(campaign_Index(i) + data_Position(1) - 1) / 5);
    for j = 2: numel(x)
        yearCounter = campaign_Year{1, i}(data_Position(j));
        timeCounter = 5 * round(Yday(campaign_Index(i) + data_Position(j) - 1) / 5);
        date_X(j) = 365*(yearCounter - yearCounter_1) + timeCounter - timeCounter_1;
    end
    track_Ice = Avg_ic((campaign_Index(i) + min(data_Position) - 1) : (campaign_Index(i) + max(data_Position)) - 1); % data from observation
    p1 = plot(date_X, track_Ice', '-', 'LineWidth', 2,'Color', [0 0 0] );
    %% ANHA4
    % Read Lon and Lat
    m_proj('stereographic','latitude',70,'lon',-90, 'radius',20);
    srcP = '/mnt/storage0/clark/ANHA4-E34REF/'; % 4th
    ncfile = [srcP,'CREG025-E34REF_y2003m01d05_icemod.nc'];
    lon_4=GetNcVar(ncfile,'nav_lon',[0 0],[544 800]);
    lat_4=GetNcVar(ncfile,'nav_lat',[0 0],[544 800]);
    track_ANHA4 = zeros(size(x)); % data from ANHA4
    % Record the data of each point
    date_All = cell(1, (campaign_Index(i + 1) - campaign_Index(i)));
    less_2008 = 0;
    for j = 1: numel(x)
        if(campaign_Year{1, i}(data_Position(j)) > 2008)
            continue;
        end
        if(campaign_Year{1, i}(data_Position(j)) == 2008 && Yday(campaign_Index(i) + data_Position(j) - 1) > 310)
            continue;
        end
        less_2008 = less_2008 + 1;
        % Calculate the data
        yearCounter = campaign_Year{1, i}(data_Position(j));
        timeCounter = 5 * round(Yday(campaign_Index(i) + data_Position(j) - 1) / 5);
        date = num2date(yearCounter, timeCounter);
        % Read NC File
        srcP = '/mnt/storage0/clark/ANHA4-E34REF/'; % 4th
        ncfile=[srcP,'CREG025-E34REF_y',date,'_icemod.nc']; % 4th
        NY=800; NX=544; % dimension of the whole model domain
        subII = 1:544; subJJ = 1:800;
        % Read ice Thickness
        iceC=GetNcVar(ncfile,'iicethic',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
        iceC(tmask_4 == 0) = NaN;
        % Find neighbour grid points
        [result,index]=sort((lat_4(:) - lat(campaign_Index(i))).*(lat_4(:) - lat(campaign_Index(i))) + (lon_4(:) - lon(campaign_Index(i))).*(lon_4(:) - lon(campaign_Index(i))));
        inverseDistance = zeros(1,4);
        kk = 1; % Number of valid neighbour points
        k = 1; % Number of index
        valid_Index = zeros(1, 4);
        while kk <= 4
            if(~isnan(iceC(index(k))))
                inverseDistance(1,kk) = 1 / sum((m_ll2xy(lon(campaign_Index(i)), lat(campaign_Index(i))) - m_ll2xy(lon_4(index(k)), lat_4(index(k)))) .^ 2);
                valid_Index(1, kk) = index(k);
                kk = kk + 1;
            end
            % Break active situations:
            % 1. search more than 4 neighbours until there is 1 non-zero
            % 2. search less than 4 neighbours with at least 1 non-zero
            if(k > 4 && kk > 1)
                break; 
            elseif(k > 4 && kk == 0)
                inverseDistance(1,kk) = 0;
                kk = kk + 1;
                break;
            end
            k = k + 1;
        end
        sum_Distance = sum(inverseDistance);
        for k = 1:kk-1
            track_ANHA4(less_2008) = track_ANHA4(less_2008) + iceC(valid_Index(k)) * inverseDistance(1, k) / sum_Distance;
        end
    end
    track_ANHA4 = track_ANHA4(1, 1: less_2008);
    date_X_less_2008 = date_X(1, 1: less_2008);
    hold on;
    xx = 1: less_2008;
    p2 = plot(date_X_less_2008, track_ANHA4, '-b', 'LineWidth', 2);
    disp(['ANHA4 finished ', num2str(i)]);
    %% ANHA12
    % Read Lon and Lat
    srcP='/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
    ncfile=[srcP,'CREG012-EXH003_y2003m01d05_icemod.nc']; % 12th
    lon_12=GetNcVar(ncfile,'nav_lon',[0 0],[1632 2400]);
    lat_12=GetNcVar(ncfile,'nav_lat',[0 0],[1632 2400]);
    track_ANHA12 = zeros(size(x)); % data from ANHA4
    for j = 1: numel(x)
        % Calculate the data
        yearCounter = campaign_Year{1, i}(data_Position(j));
        % Find the nearst date in 5-day-long
        timeCounter = 5 * round(Yday(campaign_Index(i) + data_Position(j) - 1) / 5);
        date = num2date(yearCounter, timeCounter);
        date_All{1, j} = date;
        % Read NC File
        srcP='/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
        ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc']; % 12th
        NY=2400; NX=1632; % dimension of the whole model domain
        subII=1:1632; subJJ=1:2400;
        % Read ice Thickness
        iceC=GetNcVar(ncfile,'iicethic',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
        iceC(tmask_12 == 0) = NaN;
        % Find neighbour grid points
        [result,index]=sort((lat_12(:) - lat(campaign_Index(i))).*(lat_12(:) - lat(campaign_Index(i))) + (lon_12(:) - lon(campaign_Index(i))).*(lon_12(:) - lon(campaign_Index(i))));
        inverseDistance = zeros(1,4);
        kk = 1; % Number of valid neighbour points
        k = 1; % Number of index
        valid_Index = zeros(1, 4);
        while kk <= 4
            if(~isnan(iceC(index(k))))
                inverseDistance(1,kk) = 1 / sum((m_ll2xy(lon(campaign_Index(i)), lat(campaign_Index(i))) - m_ll2xy(lon_12(index(k)), lat_12(index(k)))) .^ 2);
                valid_Index(1, kk) = index(k);
                kk = kk + 1;
            end
            % Break active situations:
            % 1. search more than 9 neighbours until there is 1 non-zero
            % 2. search less than 9 neighbours with at least 1 non-zero
            if(k > 9 && kk > 1) 
                break;
            elseif(k > 9 && kk == 0)
                inverseDistance(1,kk) = 0;
                kk = kk + 1;
                break;
            end
            k = k + 1;
        end
        sum_Distance = sum(inverseDistance);
        for k = 1:kk-1
            track_ANHA12(j) = track_ANHA12(j) + iceC(valid_Index(k)) * inverseDistance(1, k) / sum_Distance;
        end
    end
    hold on;
    p3 = plot(date_X, track_ANHA12, '-r', 'LineWidth', 2);
    grid on;
    set(gca,'fontweight','bold','fontsize',5,'fontname','Nimbus Sans L');
    
    %% Calculate and change the x and y labels and ticks
    clear title xlabel ylabel;
    xlabel('Date', 'fontweight','bold','fontsize', 10,'fontname','Nimbus Sans L');
    ylabel('Thickness /m', 'fontweight','bold','fontsize', 10,'fontname','Nimbus Sans L');
    % title
    title = title(['FILE: CanCoast_summaries_1947_2010_v1 TRACK: ', campaign_Name{i}], 'fontweight','bold','fontsize', 12,'fontname','Nimbus Sans L');
    set(title,'Interpreter','none');
    xLimit = get(gca, 'XLim');
    xLimit_up = round(xLimit(2) / 3.5);
    set(gca, 'XLim', [0, xLimit(2) + xLimit_up]);
    xtick = get(gca, 'xTick');
    xtick_Char = cell(1, numel(xtick));
    xtick_Char{1} = num2date(yearCounter_1, timeCounter_1);
    for j = 2: numel(xtick)
        yearCounter = round(xtick(j) / 365) + yearCounter_1;
        timeCounter = rem(xtick(j), 365);
        xtick_Char{j} = num2date(yearCounter, timeCounter);
    end
    set(gca,'xTicklabel', xtick_Char);
    legend([p1 p2 p3], 'Observation', 'ANHA4','ANHA12','Location', 'NorthEast');
    % Calculate the position of each points in global coordinate
    x1 = zeros(1, xLimit(2) + xLimit_up);
    y1 = zeros(1, xLimit(2) + xLimit_up);
    YLim_plot = get(gca, 'YLim');
    disp(['ANHA12 finished ', num2str(i)]);
    %% Production plot 1
    subplot(312);
    p4 = plot(1: 365/5*9, IceH_all_Day(valid_plotIndex, :), '-g', 'LineWidth', 1.5);
    hold on;
    p5 = plot(1: 365/5*9, IceP_all(valid_plotIndex, :), '-m', 'LineWidth', 1.5);
    grid on;
    xLimit = get(gca, 'XLim');
    xLimit_up = round(xLimit(2) / 3.5);
    set(gca, 'XLim', [0, xLimit(2) + xLimit_up]);
    xtick_Char_P = cell(1, 9);
    xtick_Char_P{1} = num2date(2002, 5);
    for j = 2:9
        xtick_Char_P{j} = num2date(((j-1)*500-rem((j-1)*500, 365))/365+2002, rem((j-1)*500, 365));
    end
    set(gca,'xTicklabel', xtick_Char_P);
    legend([p4 p5], 'Thickness','Production','Location', 'NorthEast');
    xlabel('Date', 'fontweight','bold','fontsize', 10,'fontname','Nimbus Sans L');
    ylabel('Thickness /m', 'fontweight','bold','fontsize', 10,'fontname','Nimbus Sans L');
    set(gca,'fontweight','bold','fontsize',5,'fontname','Nimbus Sans L');
    
    %% Production plot 2
    subplot(313);
    p6 = plot(1: 365/5*9, IceH_all_Year(valid_plotIndex, :), '-g', 'LineWidth', 2);
    hold on;
    p7 = plot(1: 365/5*9, IceP_all_Year(valid_plotIndex, :), '-m', 'LineWidth', 2);
    grid on;
    xLimit = get(gca, 'XLim');
    xLimit_up = round(xLimit(2) / 3.5);
    set(gca, 'XLim', [0, xLimit(2) + xLimit_up]);
    xtick_Char_P = cell(1, 9);
    xtick_Char_P{1} = num2date(2002, 5);
    for j = 2:9
        xtick_Char_P{j} = num2date(((j-1)*500-rem((j-1)*500, 365))/365+2002, rem((j-1)*500, 365));
    end
    set(gca,'xTicklabel', xtick_Char_P);
    legend([p6 p7], 'Thickness','Production','Location', 'NorthEast');
    xlabel('Date', 'fontweight','bold','fontsize', 10,'fontname','Nimbus Sans L');
    ylabel('Thickness /m', 'fontweight','bold','fontsize', 10,'fontname','Nimbus Sans L');
    set(gca,'fontweight','bold','fontsize',5,'fontname','Nimbus Sans L');
    
    toc;
    valid_plotIndex = valid_plotIndex + 1;
    % set(gcf,'paperPositionMode','auto'); % print the figure with the same size in matlab
    set(gcf, 'paperPosition', [0.25 2.5 5.6 7]);
    print(gcf, '-dpng' ,'-r300',['CanCoast_summaries_1947_2010_v1_', campaign_Name{i}, '_withProduction.png']);
end
