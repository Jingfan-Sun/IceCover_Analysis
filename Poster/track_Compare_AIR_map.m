clc;clear;
close all;
%% Read data
D = importdata('unified-sea-ice-thickness-cdr-1947-2012/AIR-EM_summaries_2001_2009_v1.txt');
tmask_12 = GetNcVar('/mnt/storage0/xhu/CREG012-I/mask/CREG12_mask_v34.nc','tmask',[0 0 0 0],[1632 2400 1 1]);  % surface land mask
tmask_4 = GetNcVar('/mnt/storage0/xhu/CREG025-I/mesh_mask_creg025.nc','tmask',[0 0 0],[544 800 1]);  % surface land mask
[row, col] = size(D.data);

%% Find same campaign
campaign_Name = cell(1, col); % save different names in the data
campaign_Name{1} = D.textdata{2, 2};
campaign_Index = 1; % save the start index of different campaign in campaign_name variable
campaign_Year = D.data(1, 2); % save observtion year in each campaign
categary_Index = 1; % save the index of categaries, e.g. 1, 2, 3, 4, ...
for i = 3: (row + 1)
    if(~strcmp(campaign_Name{categary_Index}, D.textdata{i, 2}))
        categary_Index = categary_Index + 1;
        campaign_Name{categary_Index} = D.textdata{i, 2};
        campaign_Index = [campaign_Index, i - 1];
        campaign_Year = [campaign_Year, D.data(i-1, 2)];
    end
end
campaign_Index = [campaign_Index, row + 1];

% remove the empty cell in campaign_Name
id = cellfun('length', campaign_Name);
campaign_Name(id == 0) = [];

%% Extrct numerical data
lat = D.data(:, 7);
lon = D.data(:, 8);
Yday = D.data(:, 3);
Avg_ic_with_sn = D.data(:, 23);

%% Plot track
[~, length] = size(campaign_Index);
for i = 1: length-1
    tic;
    if(campaign_Year(i) < 2003 || campaign_Year(i) > 2008)
        continue;
    end
    
%     if(~strcmp(campaign_Name{i}, 'Ark19'))
%        continue; 
%     end
    
    if(~strcmp(campaign_Name{i}, 'GreenICE04'))
       continue; 
    end
    figure;
    % set(gcf, 'Position', [560 524 560 700]);
    % Extrct sub part of lat and lon
    lon_Temp = lon(campaign_Index(i): (campaign_Index(i + 1) - 1));
    lat_Temp = lat(campaign_Index(i): (campaign_Index(i + 1) - 1));
    % Calculate the distance of each separate part of the track
    distance_X_Separate = m_lldist(lon_Temp, lat_Temp);
    % Calculate the distance from the departure place
    distance_X = zeros(1, numel(lat_Temp));
    for j = 2: numel(lat_Temp)
       for k = 1: j-1
          distance_X(j) = distance_X(j) + distance_X_Separate(k); 
       end
    end
%     %% Line plot 
%     subplot(211);
    x = 1: (campaign_Index(i + 1) - campaign_Index(i));
    track_Num = numel(x); space = round(track_Num / 7); % I don't plot all points on map, wo I select some of them
%     track_Ice = Avg_ic_with_sn(campaign_Index(i) : (campaign_Index(i + 1) - 1)); % data from observation
%     p1 = plot(distance_X, track_Ice', '-', 'LineWidth', 2,'Color', [0 0 0] );
%     m_proj('stereographic','latitude',90,'radius',35,'rotangle',45);
%     %% ANHA4
%     % Read Lon and Lat
%     srcP = '/mnt/storage0/clark/ANHA4-E34REF/'; % 4th
%     ncfile = [srcP,'CREG025-E34REF_y2003m01d05_icemod.nc'];
%     lon_4=GetNcVar(ncfile,'nav_lon',[0 0],[544 800]);
%     lat_4=GetNcVar(ncfile,'nav_lat',[0 0],[544 800]);
%     track_ANHA4 = zeros(size(x)); % data from ANHA4
%     % draw range line
%     ANHA4_range_down = zeros(size(x));
%     ANHA4_range_up = zeros(size(x));
%     date_All = cell(1, (campaign_Index(i + 1) - campaign_Index(i)));
%     for j = 1: (campaign_Index(i + 1) - campaign_Index(i))
%         % Calculate the data
%         yearCounter = campaign_Year(i);
%         timeCounter = 5 * round(Yday(campaign_Index(i) + j - 1) / 5);
%         date = num2date(yearCounter, timeCounter);
%         date_All{1, j} = date;
%         % Read NC File
%         srcP = '/mnt/storage0/clark/ANHA4-E34REF/'; % 4th
%         ncfile=[srcP,'CREG025-E34REF_y',date,'_icemod.nc']; % 4th
%         NY=800; NX=544; % dimension of the whole model domain
%         subII = 1:544; subJJ = 1:800;
%         % Read ice Thickness
%         iceC=GetNcVar(ncfile,'iicethic',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
%         iceC(tmask_4 == 0) = NaN;
%         % Find neighbour grid points
%         [result,index]=sort((lat_4(:) - lat_Temp(j)).*(lat_4(:) - lat_Temp(j)) + (lon_4(:) - lon_Temp(j)).*(lon_4(:) - lon_Temp(j)));
%         inverseDistance = zeros(1,4);
%         for k = 1:4
%             if(~isnan(iceC(index(k))))
%                 inverseDistance(1,k) = 1 / sum((m_ll2xy(lon_Temp(j), lat_Temp(j)) - m_ll2xy(lon_4(index(k)), lat_4(index(k)))) .^ 2);
%             else
%                 inverseDistance(1,k) = 0;
%             end
%         end
%         sum_Distance = sum(inverseDistance);
%         ANHA4_range_down(j) = 0;
%         ANHA4_range_up(j) = 10;
%         for k = 1:4
%             if(inverseDistance(1,k) ~= 0)
%                 track_ANHA4(j) = track_ANHA4(j) + iceC(index(k)) * inverseDistance(1, k) / sum_Distance;
%             end
%             % Calculate the up and down range of the model output
%             if(iceC(index(k)) > ANHA4_range_down(j))
%                ANHA4_range_down(j) = iceC(index(k));
%             end
%             if(iceC(index(k)) < ANHA4_range_up(j))
%                ANHA4_range_up(j) = iceC(index(k));
%             end
%         end
%     end
%     hold on;
%     p2 = plot(distance_X, track_ANHA4, '-b', 'LineWidth', 2);
%     plot(distance_X, ANHA4_range_down, '--b', 'LineWidth', 0.5);
%     plot(distance_X, ANHA4_range_up, '--b', 'LineWidth', 0.5);
%     disp(['ANHA4 finished ', num2str(i)]);
%     %% ANHA12
%     % Read Lon and Lat
%     srcP='/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
%     ncfile=[srcP,'CREG012-EXH003_y2003m01d05_icemod.nc']; % 12th
%     lon_12=GetNcVar(ncfile,'nav_lon',[0 0],[1632 2400]);
%     lat_12=GetNcVar(ncfile,'nav_lat',[0 0],[1632 2400]);
%     track_ANHA12 = zeros(size(x)); % data from ANHA4
%     % draw range line
%     ANHA12_range_down = zeros(size(x));
%     ANHA12_range_up = zeros(size(x));
%     for j = 1: (campaign_Index(i + 1) - campaign_Index(i))
%         % Calculate the data
%         yearCounter = campaign_Year(i);
%         timeCounter = 5 * round(Yday(campaign_Index(i) + j - 1) / 5);
%         date = num2date(yearCounter, timeCounter);
%         % Read NC File
%         srcP='/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
%         ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc']; % 12th
%         NY=2400; NX=1632; % dimension of the whole model domain
%         subII=1:1632; subJJ=1:2400;
%         % Read ice Thickness
%         iceC=GetNcVar(ncfile,'iicethic',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
%         iceC(tmask_12 == 0) = NaN;
%         % Find neighbour grid points
%         [result,index]=sort((lat_12(:) - lat_Temp(j)).*(lat_12(:) - lat_Temp(j)) + (lon_12(:) - lon_Temp(j)).*(lon_12(:) - lon_Temp(j)));
%         inverseDistance = zeros(1,9);
%         for k = 1:9
%             if(~isnan(iceC(index(k))))
%                 inverseDistance(1,k) = 1 / sum((m_ll2xy(lon_Temp(j), lat_Temp(j)) - m_ll2xy(lon_12(index(k)), lat_12(index(k)))) .^ 2);
%             else
%                 inverseDistance(1,k) = 0;
%             end
%         end
%         sum_Distance = sum(inverseDistance);
%         ANHA12_range_down(j) = 0;
%         ANHA12_range_up(j) = 10;
%         for k = 1:9
%             if(inverseDistance(1,k) ~= 0)
%                 track_ANHA12(j) = track_ANHA12(j) + iceC(index(k)) * inverseDistance(1, k) / sum_Distance;
%             end
%             % Calculate the up and down range of the model output
%             if(iceC(index(k)) > ANHA12_range_down(j))
%                ANHA12_range_down(j) = iceC(index(k));
%             end
%             if(iceC(index(k)) < ANHA12_range_up(j))
%                ANHA12_range_up(j) = iceC(index(k));
%             end
%         end
%     end
%     hold on;
%     p3 = plot(distance_X, track_ANHA12, '-r', 'LineWidth', 2);
%     plot(distance_X, ANHA12_range_down, '--r', 'LineWidth', 0.5);
%     plot(distance_X, ANHA12_range_up, '--r', 'LineWidth', 0.5);
%     grid on;
%     set(gca,'fontweight','bold','fontsize',7,'fontname','Nimbus Sans L');
%     clear title xlabel ylabel;
%     xlabel('Distance /km');
%     ylabel('Thickness /m');
%     % title
%     title = title(['FILE: AIR-EM_summaries_2001_2009_v1 TRACK: ', campaign_Name{i}, ' ', num2str(campaign_Year(i))], 'fontweight','bold','fontsize', 12,'fontname','Nimbus Sans L');
%     set(title,'Interpreter','none');
    xLimit = get(gca, 'XLim');
    xLimit_up = round(xLimit(2) / 3.5);
%     set(gca, 'XLim', [0, xLimit(2) + xLimit_up]);
%     legend([p1 p2 p3], 'Observation', 'ANHA4', 'ANHA12', 'Location', 'NorthEast');
%     % Calculate the position of each points in global coordinate
%     x1 = zeros(1, xLimit(2) + xLimit_up);
%     y1 = zeros(1, xLimit(2) + xLimit_up);
%     YLim_plot = get(gca, 'YLim');
%     jj = 1;
%     for j = 1: (campaign_Index(i + 1) - campaign_Index(i))
%         if(j == 1 || j == (campaign_Index(i + 1) - campaign_Index(i)))
%             x1(jj) = j / (xLimit(2) + xLimit_up);
%             y1(jj) = 0.58 + (track_Ice(j, 1) - YLim_plot(1)) / (YLim_plot(2) - YLim_plot(1)) * 0.42;
%             jj = jj + 1;
%         end
%         if(rem(j, space) == 0)
%             x1(jj) = j / (xLimit(2) + xLimit_up);
%             y1(jj) = 0.58 + (track_Ice(j, 1) - YLim_plot(1)) / (YLim_plot(2) - YLim_plot(1)) * 0.42;
%             jj = jj + 1;
%         end
%     end
%     disp(['ANHA12 finished ', num2str(i)]);
    %% Map plot
    % Mean track data index
    mean_Index = round((campaign_Index(i + 1) - campaign_Index(i)) / 2);
    min_Lon = find(lon_Temp == min(lon_Temp));
    min_Lat = find(lat_Temp == min(lat_Temp));
    max_Lon = find(lon_Temp == max(lon_Temp));
    max_Lat = find(lat_Temp == max(lat_Temp));
    if(max(lon_Temp) - min(lon_Temp) > 100 || max(lat_Temp) - min(lat_Temp) > 100)
        radius = 30;
    elseif(max(lon_Temp) - min(lon_Temp) < 13 && max(lat_Temp) - min(lat_Temp) < 13)
        radius = 15;
    else
        radius = max(max(lon_Temp) - min(lon_Temp), max(lat_Temp) - min(lat_Temp)) / 3;
    end
    % m_proj('albers equal-area','longitudes',[lon_Temp(min_Lon) - 10, lon_Temp(max_Lon) + 10], ...
    %    'latitudes',[lat_Temp(min_Lat) - 5, lat_Temp(max_Lat) + 5],'rect','on');
    m_proj('lambert','latitude', [lat_Temp(min_Lat) - 3, lat_Temp(max_Lat) + 3],...
        'longtitude', [lon_Temp(min_Lon) - 5, lon_Temp(max_Lon) + 5], 'rect', 'on');
    m_grid;
    disp(['grid finish ', num2str(i)]);
    m_gshhs_i('patch',[0 0 0],'linestyle','none');% plot map grid
    m_nolakes;
    disp(['gshhs finish ', num2str(i)]);
    color_Temp = rand(1,3);
%     if(radius == 10)
%         for j = 1: (campaign_Index(i + 1) - campaign_Index(i))
%             m_line(lon_Temp(j), lat_Temp(j), 'Color', 'g', 'LineStyle', '*', 'LineWidth', 5);
%         end
%     else
        m_line(lon_Temp, lat_Temp, 'linewi',4, 'Color', 'g');
%     end
    %% Mark number at the side of each selected point and calculate the
    %% position in global coordinate of each point
    room = 0.8 / (campaign_Index(i + 1) - campaign_Index(i));
    Xlim_map = get(gca,'Xlim');
    Ylim_map = get(gca,'Ylim');
    x2 = zeros(1, xLimit(2) + xLimit_up);
    y2 = zeros(1, xLimit(2) + xLimit_up);
    jj = 1;
    for j = 1: (campaign_Index(i + 1) - campaign_Index(i))
        if(j == 1 || j == (campaign_Index(i + 1) - campaign_Index(i)))
            [x, y] = m_ll2xy(lon_Temp(j), lat_Temp(j));
            text(x, y, num2str(j), 'Color', 'r', 'FontSize', 7, 'fontweight','bold', 'fontname','Nimbus Sans L');
            x2(jj) = 0.5 + (x / (Xlim_map(2) - Xlim_map(1)) * 0.55);
            y2(jj) = 0.21 + (y / (Ylim_map(2) - Ylim_map(1)) * 0.42);
            jj = jj + 1;
        end
        if(rem(j, space) == 0)
            [x, y] = m_ll2xy(lon_Temp(j), lat_Temp(j));
            text(x, y, num2str(j), 'Color', 'r', 'FontSize', 7, 'fontweight','bold', 'fontname','Nimbus Sans L');
            x2(jj) = 0.5 + (x / (Xlim_map(2) - Xlim_map(1)) * 0.47);
            y2(jj) = 0 + ((y - Ylim_map(1)) / (Ylim_map(2) - Ylim_map(1)) * 0.42);
            jj = jj + 1;
        end
%         hleg1 = text(0.13,(0.14 - room*j), [num2str(j), ' (Lat: ', num2str(lat_Temp(j)), ', Lon: ', num2str(lon_Temp(j)), ') ', date_All{1, j}]...
%             , 'Color', 'k', 'FontSize', 4, 'fontweight','bold', 'fontname','Nimbus Sans L');
    end
    set(gca,'fontweight','b','fontsize',8,'fontname','Nimbus Sans L');
    %% Change the font and size of the label in maps
    hxlabel=findobj(gca,'tag','m_grid_xticklabel');  set(hxlabel,'fontweight','b','fontsize',8,'fontname','Nimbus Sans L');
    hylabel=findobj(gca,'tag','m_grid_yticklabels'); 
    % Delete lontitude line according to the number of the lontitude
    % available
    set(hylabel,'fontweight','b','fontsize',8,'fontname','Nimbus Sans L','rotation',0');
    delete(hylabel(1: numel(hylabel)));
    delete(hxlabel(1: numel(hxlabel)));
    %    text_Num = round((campaign_Index(i + 1) - campaign_Index(i)) / 2);
    %    [x, y] = m_ll2xy(lon_Temp(text_Num), lat_Temp(text_Num));
    %    text(x, y, num2str(i), 'Color', 'r', 'FontSize', 6, 'fontweight','bold', 'fontname','Nimbus Sans L');
    %     hleg1 = text(0.7,(0.6 - room*i), [num2str(i), ' ', campaign_Name{i}, ' ', num2str(campaign_Year(i))], 'Color', color_Temp, 'FontSize', 8, 'fontweight','bold', 'fontname','Nimbus Sans L');
    %     set(hleg1,'Interpreter','none');
    %    legend = m_legend('a');
    %    set(legend, 'AmbientLightColor', 'b');
    
%     %% Draw a transparent coordinate to write text exactly
%     hold on;
%     hax = axes();
%     set(hax, 'Color', 'none');
%     axis off;
%     set(gca,'Xlim',[0 1]);
%     set(gca,'Ylim',[0 1]);
%     set(gcf, 'currentAxes', hax);
%     %% Draw lines between plot and map
% %     jj = 1;
% %     for j = 1: (campaign_Index(i + 1) - campaign_Index(i))
% %         if(j == 1 || j == (campaign_Index(i + 1) - campaign_Index(i)))
% %             line([x1(jj) x2(jj)], [y1(jj) y2(jj)],'Marker','.','LineStyle','--', 'color', [0.3 0.3 0.3]);
% %             jj = jj + 1;
% %         end
% %         if(rem(j, space) == 0)
% %             line([x1(jj) x2(jj)], [y1(jj) y2(jj)],'Marker','.','LineStyle','--', 'color', [0.3 0.3 0.3]);
% %             jj = jj + 1;
% %         end
% % %         hleg1 = text(0.13,(0.14 - room*j), [num2str(j), ' (Lat: ', num2str(lat_Temp(j)), ', Lon: ', num2str(lon_Temp(j)), ') ', date_All{1, j}]...
% % %             , 'Color', 'k', 'FontSize', 4, 'fontweight','bold', 'fontname','Nimbus Sans L');
% %     end
%     %% Annotation at the side of the map
%     for j = 1: (campaign_Index(i + 1) - campaign_Index(i))
%         if(rem(j, 2) == 0)
%            text(-0.08,(0.4 - room*(j/2)), [num2str(j), ' (Lat: ', num2str(lat_Temp(j)), ', Lon: ', num2str(lon_Temp(j)), ') ', date_All{1, j}]...
%              , 'Color', 'k', 'FontSize', 5, 'fontweight','bold', 'fontname','Nimbus Sans L');
%         else
%            text(0.85,(0.4 - room*(round(j/2))), [num2str(j), ' (Lat: ', num2str(lat_Temp(j)), ', Lon: ', num2str(lon_Temp(j)), ') ', date_All{1, j}]...
%              , 'Color', 'k', 'FontSize', 5, 'fontweight','bold', 'fontname','Nimbus Sans L');
%         end
%     end
    toc;
    % set(gcf,'paperPositionMode','auto'); % print the figure with the same size in matlab
    print(gcf, '-dpng' ,'-r300',['AIR-EM_summaries_2001_2009_v1_', campaign_Name{i}, '_map.png']);
end

% for i = 1:length-1
%     lon_Temp = lon(campaign_Index(i): (campaign_Index(i + 1) - 1));
%     lat_Temp = lat(campaign_Index(i): (campaign_Index(i + 1) - 1));
%     text_Num = round((campaign_Index(i + 1) - campaign_Index(i)) / 2);
%     [x, y] = m_ll2xy(lon_Temp(text_Num), lat_Temp(text_Num));
%     text(x, y, num2str(i), 'Color', 'r', 'FontSize', 6, 'fontweight','bold', 'fontname','Nimbus Sans L');
% end


