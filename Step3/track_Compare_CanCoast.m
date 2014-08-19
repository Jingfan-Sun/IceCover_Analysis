% Individual observation sites
clc;clear;
close all;
%% Read data
D = importdata('unified-sea-ice-thickness-cdr-1947-2012/CanCoast_summaries_1947_2010_v1.txt');
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

%% Plot track
[~, length] = size(campaign_Index);
for i = 1: length - 1
    data_Position = zeros(1, numel(campaign_Year{1, i}));
    jj = 1;
    for k = 1: numel(campaign_Year{1, i})
        tic;
        if(campaign_Year{1, i}(k) < 2003 || campaign_Year{1, i}(k) > 2010)
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
    subplot(211);
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
    % draw range line
    ANHA4_range_down = zeros(size(x));
    ANHA4_range_up = zeros(size(x));
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
        ANHA4_range_down(j) = 0;
        ANHA4_range_up(j) = 10;
        for k = 1:kk-1
            track_ANHA4(less_2008) = track_ANHA4(less_2008) + iceC(valid_Index(k)) * inverseDistance(1, k) / sum_Distance;
            % Calculate the up and down range of the model output
            if(iceC(valid_Index(k)) > ANHA4_range_down(j))
               ANHA4_range_down(j) = iceC(valid_Index(k));
            end
            if(iceC(valid_Index(k)) < ANHA4_range_up(j))
               ANHA4_range_up(j) = iceC(valid_Index(k));
            end
        end
    end
    track_ANHA4 = track_ANHA4(1, 1: less_2008);
    ANHA4_range_down = ANHA4_range_down(1, 1: less_2008);
    ANHA4_range_up = ANHA4_range_up(1, 1: less_2008);
    date_X_less_2008 = date_X(1, 1: less_2008);
    hold on;
    xx = 1: less_2008;
    p2 = plot(date_X_less_2008, track_ANHA4, '-b', 'LineWidth', 2);
    plot(date_X_less_2008, ANHA4_range_down, '--b', 'LineWidth', 0.5);
    plot(date_X_less_2008, ANHA4_range_up, '--b', 'LineWidth', 0.5);
    disp(['ANHA4 finished ', num2str(i)]);
    %% ANHA12
    % Read Lon and Lat
    srcP='/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
    ncfile=[srcP,'CREG012-EXH003_y2003m01d05_icemod.nc']; % 12th
    lon_12=GetNcVar(ncfile,'nav_lon',[0 0],[1632 2400]);
    lat_12=GetNcVar(ncfile,'nav_lat',[0 0],[1632 2400]);
    track_ANHA12 = zeros(size(x)); % data from ANHA4
    % draw range line
    ANHA12_range_down = zeros(size(x));
    ANHA12_range_up = zeros(size(x));
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
        ANHA12_range_down(j) = 0;
        ANHA12_range_up(j) = 10;
        for k = 1:kk-1
            track_ANHA12(j) = track_ANHA12(j) + iceC(valid_Index(k)) * inverseDistance(1, k) / sum_Distance;
            % Calculate the up and down range of the model output
            if(iceC(valid_Index(k)) > ANHA12_range_down(j))
               ANHA12_range_down(j) = iceC(valid_Index(k));
            end
            if(iceC(valid_Index(k)) < ANHA12_range_up(j))
               ANHA12_range_up(j) = iceC(valid_Index(k));
            end
        end
    end
    hold on;
    p3 = plot(date_X, track_ANHA12, '-r', 'LineWidth', 2);
    plot(date_X, ANHA12_range_down, '--r', 'LineWidth', 0.5);
    plot(date_X, ANHA12_range_up, '--r', 'LineWidth', 0.5);
    grid on;
    set(gca,'fontweight','bold','fontsize',7,'fontname','Nimbus Sans L');
    %% Calculate and change the x and y labels and ticks
    clear title xlabel ylabel;
    xlabel('Date');
    ylabel('Thickness /m');
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
    %% Map plot
    subplot(212);
    m_proj('stereographic','latitude',70,'lon',-90, 'radius',20);
    m_grid;
    disp(['grid finish ', num2str(i)]);
    m_gshhs_i('patch',[0 0 0],'linestyle','none');% plot map grid
    m_nolakes;
    disp(['gshhs finish ', num2str(i)]);
    m_line(lon(campaign_Index(i)), lat(campaign_Index(i)), 'Color', 'g', 'LineStyle', '*', 'LineWidth', 3);
    
    set(gca,'fontweight','b','fontsize',8,'fontname','Nimbus Sans L');
    %% Change the font and size of the label in maps
    hxlabel=findobj(gca,'tag','m_grid_xticklabel');  set(hxlabel,'fontweight','b','fontsize',8,'fontname','Nimbus Sans L');
    hylabel=findobj(gca,'tag','m_grid_yticklabels'); 
    % Delete lontitude line according to the number of the lontitude
    % available
    delete(hxlabel);
    set(hylabel,'fontweight','b','fontsize',8,'fontname','Nimbus Sans L','rotation',0');
    delete(hylabel([1 numel(hylabel)]));
    %    text_Num = round((campaign_Index(i + 1) - campaign_Index(i)) / 2);
    %    [x, y] = m_ll2xy(lon_Temp(text_Num), lat_Temp(text_Num));
    %    text(x, y, num2str(i), 'Color', 'r', 'FontSize', 6, 'fontweight','bold', 'fontname','Nimbus Sans L');
    %     hleg1 = text(0.7,(0.6 - room*i), [num2str(i), ' ', campaign_Name{i}, ' ', num2str(campaign_Year(i))], 'Color', color_Temp, 'FontSize', 8, 'fontweight','bold', 'fontname','Nimbus Sans L');
    %     set(hleg1,'Interpreter','none');
    %    legend = m_legend('a');
    %    set(legend, 'AmbientLightColor', 'b');
    hold on;
    hax = axes();
    set(hax, 'Color', 'none');
    axis off;
    set(gca,'Xlim',[0 1]);
    set(gca,'Ylim',[0 1]);
    set(gcf, 'currentAxes', hax);
    %% Annotation at the side of the map
    room = 0.8 / numel(x);
    for j = 1: numel(x)
        if(j < numel(x)/2)
            text(0.05,(0.4 - room*(j)), [num2str(j), ': ', date_All{1, j}]...
                , 'Color', 'k', 'FontSize', 5, 'fontweight','bold', 'fontname','Nimbus Sans L');
        else
            text(0.85,(0.4 - room*(round(j - numel(x) / 2))), [num2str(j), ': ', date_All{1, j}]...
                , 'Color', 'k', 'FontSize', 5, 'fontweight','bold', 'fontname','Nimbus Sans L');
        end
    end
    toc;
    % set(gcf,'paperPositionMode','auto'); % print the figure with the same size in matlab
    print(gcf, '-dpng' ,'-r300',['CanCoast_summaries_1947_2010_v1_', campaign_Name{i}, '.png']);
end

% for i = 1:length-1
%     lon_Temp = lon(campaign_Index(i): (campaign_Index(i + 1) - 1));
%     lat_Temp = lat(campaign_Index(i): (campaign_Index(i + 1) - 1));
%     text_Num = round((campaign_Index(i + 1) - campaign_Index(i)) / 2);
%     [x, y] = m_ll2xy(lon_Temp(text_Num), lat_Temp(text_Num));
%     text(x, y, num2str(i), 'Color', 'r', 'FontSize', 6, 'fontweight','bold', 'fontname','Nimbus Sans L');
% end


