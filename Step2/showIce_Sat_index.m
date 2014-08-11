function showICESat(flname)
% show the ICESat Ice thickness data
% data description:
%      http://icdc.zmaw.de/seaicethickness_satobs_arc.html?&L=1
%      and http://rkwok.jpl.nasa.gov/icesat/download.html
% mesh grid:
%      http://nsidc.org/data/polar_stereo/ps_grids.html
% matlab script:
%      xianmin@ualberta.ca

clc;
clear;

%% Initialization
% calculation automation
control_Array = [2004 2005 2006 2008 2007 2003 2004 2005 2006 2007;
    35 35 35 35 60 275 275 275 275 275;
    12 12 12 12 7 12 12 12 12 12];
% name automation
name_Array = {'fm04', 'fm05', 'fm06', 'fm08', 'ma07', 'on03', 'on04', 'on05', 'on06', 'on07'};
% mesh file that includes the length of each grid
meshhgr='/mnt/storage0/xhu/CREG012-I/mask/CREG12_mesh_hgr.nc'; % horizontal mesh file


%% extract coordinate information
isProj=1;

%% Read from model data
% yearCounter = 2003;
% timeCounter = 60;
data_Type = 'iicethic';
% date = num2date(yearCounter, timeCounter);

for control_Index = 1:10
    
    if nargin==0
        flname=['icesat_icethk_', name_Array{control_Index}, '_filled.dat'];
    end
    
    %% loading the data
    fid=fopen(flname,'r');
    nLine=str2double(fgetl(fid));
    myIceData=fscanf(fid,'%f%f%f%f%f',[5 nLine]);
    fclose(fid);
    myIceData=myIceData';  % --> unit: cm
    
    yy=myIceData(:,4);
    sat_SizeX=length(find(yy==yy(1)));
    sat_SizeY=nLine/sat_SizeX;
    if isProj==1
        sat_Lat=reshape(squeeze(myIceData(:,1)),sat_SizeX,sat_SizeY);
        sat_Lon=reshape(squeeze(myIceData(:,2)),sat_SizeX,sat_SizeY);
    else
        xx=reshape(squeeze(myIceData(:,3)),sat_SizeX,sat_SizeY);
        yy=reshape(yy,sat_SizeX,sat_SizeY);
    end
    
    myIceH=reshape(myIceData(:,5),sat_SizeX,sat_SizeY);
    % temp = zeros(1,NX);
    % for i = NX
    %    temp(i) = nan;
    % end
    % for i = 1:10
    %    myIceH(i,:) = temp;
    % end
    myIceH(myIceH==9999)=nan; % land
    myIceH(myIceH==-1.0)=0;   % water
    myIceH=myIceH/100;        % convert into meter
    
    %% Calculate the data from model
    yearCounter = control_Array(1, control_Index);
    timeCounter = control_Array(2, control_Index);
    day_Num = control_Array(3, control_Index);
    ice_Sum_12 = 0;
    ice_Sum_4 = 0;
    
    %     for i = 1:day_Num
    %
    %         date = num2date(yearCounter, timeCounter);
    %
    %         srcP='/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
    %         ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc']; % 12th
    %         NY=2400; NX=1632; % dimension of the whole model domain
    %         subII=1:1632; subJJ=1:2400;
    %
    %         % read ice concentration
    %         iceC=GetNcVar(ncfile,data_Type,[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
    %
    %         ice_Sum_12 = ice_Sum_12 + iceC;
    %
    %         srcP = '/mnt/storage0/clark/ANHA4-E34REF/'; % 4th
    %         ncfile=[srcP,'CREG025-E34REF_y',date,'_icemod.nc']; % 4th
    %         NY=800; NX=544; % dimension of the whole model domain
    %         subII = 1:544; subJJ = 1:800;
    %
    %         % read ice concentration
    %         iceC=GetNcVar(ncfile,data_Type,[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
    %
    %         ice_Sum_4 = ice_Sum_4 + iceC;
    %
    %         timeCounter = timeCounter + 5;
    %
    %         disp(['mean counter: ', num2str(i)]);
    %
    %     end
    %
    %     NY=2400; NX=1632;
    %     lat_12 = GetNcVar(meshhgr,'nav_lat',[0 0],[NX,NY]);
    %     lon_12 = GetNcVar(meshhgr,'nav_lon',[0 0],[NX,NY]);
    %     NY=800; NX=544;
    %     subII = 1:544; subJJ = 1:800;
    %     lon_4=GetNcVar(ncfile,'nav_lon',[subII(1)-1 subJJ(1)-1],[numel(subII) numel(subJJ)]);
    %     lat_4=GetNcVar(ncfile,'nav_lat',[subII(1)-1 subJJ(1)-1],[numel(subII) numel(subJJ)]);
    %% Find neighbour points
    %     flag = 0;
    %     model_Compare = zeros(sat_SizeX, sat_SizeY);
    %     m_proj('stereographic','latitude',90,'radius',55,'rotangle',45);
    %     neighbour_Index = cell(sat_SizeX, sat_SizeY);
    %     for i = 1:sat_SizeX
    %         for j = 1:sat_SizeY
    %             if(isnan(myIceH(i, j)))
    %                 model_Compare(i, j) = nan;
    %                 neighbour_Index{i, j} = nan;
    %             elseif(myIceH(i, j) == 0)
    %                 model_Compare(i, j) = 0;
    %                 neighbour_Index{i, j} = 0;
    %             else
    %                 tic;
    %                 index = zeros(1,4);
    %                 temp_Lat = sat_Lat(i, j);
    %                 temp_Lon = sat_Lon(i, j);
    %                 %0  [~,I] = min(abs(lat(:) - temp_Lat).*abs(lat(:) - temp_Lat) + abs(lon(:) - temp_Lon).*abs(lon(:) - temp_Lon));
    %                 [result,index]=sort((lat_12(:) - sat_Lat(i, j)).*(lat_12(:) - sat_Lat(i, j)) + (lon_12(:) - sat_Lon(i, j)).*(lon_12(:) - sat_Lon(i, j)));
    %                 % [result,index]=sort(abs(lat_12(:) - temp_Lat) + abs(lon_12(:) - temp_Lon));
    %                 % calculate distance of 4 neighbour points
    %                 neighbour_Index{i, j} = index(1:4, 1);
    %                 distance = zeros(1,4);
    %                 for k = 1:4
    %                     distance(1,k) = sum((m_ll2xy(sat_Lon(i, j), sat_Lat(i, j)) - m_ll2xy(lon_12(index(k)), lat_12(index(k)))) .^ 2);
    %                 end
    %                 sum_Distance = sum(distance);
    %                 for k = 1:4
    %                     model_Compare(i, j) = model_Compare(i, j) + ice_Mean_12(index(k)) * distance(1, k) / sum_Distance;
    %                 end
    %                 flag = flag + 1;
    %                 disp(['Valid',num2str(flag),': ',num2str(model_Compare(i, j))]);
    % %                 if(flag == 50)
    % %                     break;
    % %                 end
    %                 toc;
    %             end
    %         end
    % %         if(flag == 50)
    % %             break;
    % %         end
    %     end
    %
    %     save(['icesat_icethk_', num2str(control_Index), '_12th_index'], 'neighbour_Index');
    %     save(['icesat_icethk_', num2str(control_Index), '_12th_data'], 'model_Compare');
    
    %% plotting
    if isProj==1
        disp('plotting start');
        % using m_map toolbox
        % m_proj('stereographic','lat',90,'long',0,'radius',30);
        m_proj('stereographic','latitude',90,'radius',35,'rotangle',45);
        tic;
        subplot(131);
        hp=m_pcolor(sat_Lon,sat_Lat,myIceH);set(hp,'linestyle','none');
        m_grid;
        m_gshhs_i('patch',[0 0 0],'linestyle','none');
        load mycolormap
        colormap(mycolormap.icecmap)
        hbar=colorbar;
        if exist('myCAXIS','var'), caxis(myCAXIS), end
        hxlabel=findobj(gca,'tag','m_grid_xticklabel');  set(hxlabel,'fontweight','b','fontsize',6,'fontname','Nimbus Sans L');
        hylabel=findobj(gca,'tag','m_grid_yticklabels'); set(hylabel,'fontweight','b','fontsize',6,'fontname','Nimbus Sans L','rotation',0');
        delete(hylabel([2 4]));
        colorbar('location','southoutside')
        set(gcf,'paperPositionmode','auto')
        set(gca, 'CLim', [0, 5.0]);
        % figurenicer;
        disp('figure 1 complete');
        title([name_Array{control_Index},' Satellite']);
        plot_title=get(gca, 'Title');
        set(plot_title, 'Position', get(plot_title, 'Position') + [0 0.2 0]);
        toc;
        tic;
        subplot(132);
        eval(['load ', 'icesat_icethk_', num2str(control_Index), '_4th_data.mat']);
        model_Compare_4 = model_Compare;
        hp=m_pcolor(sat_Lon,sat_Lat,model_Compare_4);set(hp,'linestyle','none');
        m_grid;
        m_gshhs_i('patch',[0 0 0],'linestyle','none');
        colormap(mycolormap.icecmap)
        hbar=colorbar;
        if exist('myCAXIS','var'), caxis(myCAXIS), end
        hxlabel=findobj(gca,'tag','m_grid_xticklabel');  set(hxlabel,'fontweight','b','fontsize',6,'fontname','Nimbus Sans L');
        hylabel=findobj(gca,'tag','m_grid_yticklabels'); set(hylabel,'fontweight','b','fontsize',6,'fontname','Nimbus Sans L','rotation',0');
        delete(hylabel([2 4]));
        colorbar('location','southoutside')
        set(gcf,'paperPositionmode','auto')
        set(gca, 'CLim', [0, 5.0]);
        % figurenicer;
        disp('figure 2 complete');
        title([name_Array{control_Index}, ' 1/4']);
        plot_title=get(gca, 'Title');
        set(plot_title, 'Position', get(plot_title, 'Position') + [0 0.2 0]);
        toc;
        tic;
        subplot(133);
        eval(['load ', 'icesat_icethk_', num2str(control_Index), '_12th_data.mat']);
        model_Compare_12 = model_Compare;
        hp=m_pcolor(sat_Lon,sat_Lat,model_Compare_12);set(hp,'linestyle','none');
        m_grid;
        m_gshhs_i('patch',[0 0 0],'linestyle','none');
        colormap(mycolormap.icecmap)
        hbar=colorbar;
        if exist('myCAXIS','var'), caxis(myCAXIS), end
        hxlabel=findobj(gca,'tag','m_grid_xticklabel');  set(hxlabel,'fontweight','b','fontsize',6,'fontname','Nimbus Sans L');
        hylabel=findobj(gca,'tag','m_grid_yticklabels'); set(hylabel,'fontweight','b','fontsize',6,'fontname','Nimbus Sans L','rotation',0');
        delete(hylabel([2 4]));
        colorbar('location','southoutside')
        set(gcf,'paperPositionmode','auto')
        set(gca, 'CLim', [0, 5.0]);
        % figurenicer;
        disp('figure 3 complete');
        title([name_Array{control_Index}, ' 1/12']);
        plot_title=get(gca, 'Title');
        set(plot_title, 'Position', get(plot_title, 'Position') + [0 0.2 0]);
        hxlabel=findobj(gca,'tag','m_grid_xticklabel');  set(hxlabel,'fontweight','b','fontsize',6,'fontname','Nimbus Sans L');
        hylabel=findobj(gca,'tag','m_grid_yticklabels'); set(hylabel,'fontweight','b','fontsize',6,'fontname','Nimbus Sans L','rotation',0');
        toc;
    else
        hp=pcolor(xx,yy,myIceH);set(hp,'linestyle','none');
        hcbar=colorbar;
        caxis([0 6])
        figurenicer;
        axis equal; axis tight;
    end
    
    set(gcf, 'visible', 'on');
    
    print(gcf, '-dpng', '-r300' ,['Ice_Thickness_', name_Array{control_Index}, '.png']);
    
end
