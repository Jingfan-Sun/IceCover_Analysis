% Individual observation sites
clc;clear;
close all;
%% Read data
D = importdata('/home/jingfan/Step3/unified-sea-ice-thickness-cdr-1947-2012/CanCoast_summaries_1947_2010_v1.txt');
tmask_12 = GetNcVar('/mnt/storage0/xhu/CREG012-I/mask/CREG12_mask_v34.nc','tmask',[0 0 0 0],[1632 2400 1 1]);  % surface land mask
tmask_4 = GetNcVar('/mnt/storage0/xhu/CREG025-I/mesh_mask_creg025.nc','tmask',[0 0 0],[544 800 1]);  % surface land mask
srcP='/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
    NY = 2400; NX = 1632; % dimension of the whole model domain
    subII = 1:NX; subJJ = 1:NY;
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
IceH_all = zeros(8, 365/5*8);
IceP_all = zeros(8, 365/5*8);
% record the neighbour index of each point on the track
neighbour_Index_12 = zeros(8, 9);
inverseDistance_all = zeros(8, 9);
ii = 1;

date = num2date(2003, 5);
ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc']; % 12th
iceP = 0;
for yearCounter = 2003: 2008
    tic;
    for timeCounter = 5: 5:365
        date = num2date(yearCounter, timeCounter);
        ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc']; % 12th
        iceP = iceP + GetNcVar(ncfile,'iiceprod',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]) .* 2400;
        timeCounter
    end
    
end
% for yearCounter = 2005
%     tic;
%     for timeCounter = 5: 5:245
%         date = num2date(yearCounter, timeCounter);
%         ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc']; % 12th
%         iceP = iceP + GetNcVar(ncfile,'iiceprod',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]) .* 2400;
%         timeCounter
%     end
%     
% end
toc;
m_proj('stereographic','lat',90,'long',-60,'radius',35,'rect','off');
myxtick=[-150:60:180];
    myytick=[45:5:85];
    
    % plot ice concentration
    navLon=GetNcVar(ncfile,'nav_lon',[subII(1)-1 subJJ(1)-1],[numel(subII) numel(subJJ)]);
    navLat=GetNcVar(ncfile,'nav_lat',[subII(1)-1 subJJ(1)-1],[numel(subII) numel(subJJ)]);
    hp=m_pcolor(navLon,navLat,iceP);set(hp,'linestyle','none');
    
    if ~ishold, hold off; end
    
    % fill the land
    %m_gshhs_i('patch',[1 .85 .7]); set(findobj('tag','m_gshhs_i'),'linestyle','none');
    m_coast('patch',[0 0 0]); set(findobj('tag','m_coast'),'linestyle','none'); % low resolution coastlines
    m_nolakes;
    
    % plot map grid
    m_grid('tickdir','in','bac','none','xtick',myxtick,'ytick',myytick,'linestyle','-','linewidth',1,'tickdir','out','fontsize',18)
    set(findobj('tag','m_grid_ygrid'),'color',[0.5 0.5 0.5],'linestyle','-')
    set(findobj('tag','m_grid_xgrid'),'color',[0.5 0.5 0.5],'linestyle','-')
    
    % refine the map grid
    delete(findobj('tag','m_grid_xticks-lower'));
    delete(findobj('tag','m_grid_xticks-upper'));
    delete(findobj('tag','m_grid_yticks-left'));
    delete(findobj('tag','m_grid_yticks-right'));
    hxlabel=findobj(gca,'tag','m_grid_xticklabel');  set(hxlabel,'fontweight','b','fontsize',8,'fontname','Nimbus Sans L');
    hylabel=findobj(gca,'tag','m_grid_yticklabels'); set(hylabel,'fontweight','b','fontsize',8,'fontname','Nimbus Sans L','rotation',0');
    delete(hylabel([2 4]));
    [xxtmp,yytmp]=m_ll2xy((85:-5:45)*0-15,85:-5:45);
    
    movePostion(hylabel(1),0.055,'y');
    movePostion(hylabel(6),-0.035,'y');
    movePostion(hylabel(6),-0.03,'x');
    
    load nclcolormap
    colormap(nclcolormap.temp_diff_18lev)
    hbar=colorbar;
    if exist('myCAXIS','var'), caxis(myCAXIS), end
    
    set(hbar,'tag','cbar','fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
    % colorbar('location','southoutside')
    set(gcf,'paperPositionmode','auto')
    set(gca, 'CLim', [-3 3]); % ice thickness 0-5.0 \\\ ice concentrstion -0.35-0.35
    colorbar('location','southoutside');
    xlabel(date);
    print(gcf, '-dpng' ,'-r300',['From 2003m01d05_to_', date, '.png']);
    
