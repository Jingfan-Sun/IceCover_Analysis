clc;clear;
close(gcf);
%% Read data
D = importdata('unified-sea-ice-thickness-cdr-1947-2012/AWI-GS_summaries_1991_2002_v1.txt');
[row, col] = size(D.data);

%% Find same campaign
campaign_Name = cell(1, col); % save different names in the data
campaign_Name{1} = D.textdata{2, 2};
campaign_Index = 1; % save the start index of different campaign in campaign_name variable
campaign_Year = D.data(1, 2);
categary_Index = 1;
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

%% Extrct lat and lon
lat = D.data(:, 7);
lon = D.data(:, 8);

%% Plot track
m_proj('stereographic','latitude',90,'radius',35,'rotangle',45);
m_grid;
disp('grid finish');
m_gshhs_i('patch',[0 0 0],'linestyle','none');
disp('gshhs finish');
[~, length] = size(campaign_Index);
room = 1.2 / length;
for i = 1:length-1
   lon_Temp = lon(campaign_Index(i): (campaign_Index(i + 1) - 1));
   lat_Temp = lat(campaign_Index(i): (campaign_Index(i + 1) - 1));
   color_Temp = rand(1,3);
   [x, y] = m_ll2xy(lon_Temp(1), lat_Temp(1));
   % m_plot(x, y, 'o', 'Color', color_Temp)
   m_line(lon_Temp(1), lat_Temp(1), 'Color', color_Temp, 'LineStyle', '.', 'LineWidth', 4);
   hleg1 = text(0.7,(0.6 - room*i), [num2str(i), ' ', campaign_Name{i}, ' ', num2str(campaign_Year(i))], 'Color', color_Temp, 'FontSize', 8, 'fontweight','bold', 'fontname','Nimbus Sans L');
   set(hleg1,'Interpreter','none');
%    legend = m_legend('a');
%    set(legend, 'AmbientLightColor', 'b');
end
% 
% for i = 1:length-1
%    lon_Temp = lon(campaign_Index(i): (campaign_Index(i + 1) - 1));
%    lat_Temp = lat(campaign_Index(i): (campaign_Index(i + 1) - 1));
%    [x, y] = m_ll2xy(lon_Temp(1), lat_Temp(1));
%    text(x, y, num2str(i), 'Color', 'r', 'FontSize', 3, 'fontname','Nimbus Sans L');
% end

title = title('AWI-GS_summaries_1991_2002_v1', 'fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
set(title,'Interpreter','none');

print(gcf, '-dpng', '-r300' ,'AWI-GS_summaries_1991_2002_v1.png');
