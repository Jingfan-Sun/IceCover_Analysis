%% Change from March to September
% timeCounter, day_Num, Loop-in Reintialize, Output
clear;clc;

%% Initialization
timeCounter = 60; % March 60 September 245

meshhgr='/mnt/storage0/xhu/CREG012-I/mask/CREG12_mesh_hgr.nc'; % horizontal mesh file
meshzgr='/mnt/storage0/xhu/CREG012-I/mask/CREG12_mesh_zgr.nc'; % vertical mesh file
maskfile='/mnt/storage0/xhu/CREG012-I/mask/CREG12_mask_v34.nc'; % mask file
data_Type = 'ileadfra'; % ice thickness 'iicethic' \\\\ ice concentration 'ileadfra'
configuration = '12th';

ice_Sum = 0; % Total ice among certain periad
day_Num = 7; % Sept 6, March 7

%% Calculate
for yearCounter = 2003:2008
    
    for i = 1:day_Num
        
        date = num2date(yearCounter, timeCounter);
        
        srcP='/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
        ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc']; % 12th
        NY=2400; NX=1632; % dimension of the whole model domain
        subII=1:1632; subJJ=1:2400;
        
        % read ice concentration
        iceC=GetNcVar(ncfile,data_Type,[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
        tmask=GetNcVar(maskfile,'tmask',[subII(1)-1 subJJ(1)-1 0 0],[numel(subII) numel(subJJ) 1 1]);  % surface land mask
        iceC(tmask==0)=NaN; % set the values on land to be NaNs
        
        ice_Sum = ice_Sum + iceC;
        
        timeCounter = timeCounter + 5;
        
    end
    timeCounter = 60;
    disp(yearCounter);
    
end

ice_Mean_12 = ice_Sum / day_Num / 8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization

ice_Sum = 0; % Total ice among certain periad

%% Calculate
for yearCounter = 2003:2008
    
    for i = 1:day_Num
        
        date = num2date(yearCounter, timeCounter);
        
        srcP = '/mnt/storage0/clark/ANHA4-E34REF/'; % 4th
        ncfile=[srcP,'CREG025-E34REF_y',date,'_icemod.nc']; % 4th
        NY=800; NX=544; % dimension of the whole model domain
        subII = 1:544; subJJ = 1:800;
        
        % read ice concentration
        iceC=GetNcVar(ncfile,data_Type,[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
        
        ice_Sum = ice_Sum + iceC;
        
        timeCounter = timeCounter + 5;
        
    end
    timeCounter = 60;
    disp(yearCounter);
    
end

ice_Mean_4 = ice_Sum / day_Num / 8;

%% Do Plotting
% make a simple plot
isProj=1; % with map projection or not

% subplot(3,4,i)

if isProj==0
    mypcolor(subII,subJJ,iceC);
    axis equal; axis tight
    set(gca,'linewidth',1,'xminortick','on','yminortick','on','tickdir','out','FontWeight','bold','fontname','Nimbus Sans L','fontsize',14)
    caxis([0 1])
    hbar=colorbar; set(hbar,'linewidth',1,'FontWeight','bold','fontname','Nimbus Sans L','fontsize',10);
    set(gcf,'color','w');
else
    
    navLon=GetNcVar(ncfile,'nav_lon',[subII(1)-1 subJJ(1)-1],[numel(subII) numel(subJJ)]);
    navLat=GetNcVar(ncfile,'nav_lat',[subII(1)-1 subJJ(1)-1],[numel(subII) numel(subJJ)]);
    
    % declare the map projection, pan-Arctic region
    m_proj('stereographic','lat',90,'long',-60,'radius',35,'rect','off');
    myxtick=[-150:60:180];
    myytick=[45:5:85];
    
    % plot ice concentration
    hp=m_pcolor(navLon,navLat,ice_Mean_12(1:3:2398, 1:3:1630) - ice_Mean_4);set(hp,'linestyle','none');
    
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
    %    for np=1:2:9
    %        movePosition(hylabel(np),xxtmp(np),yytmp(np));
    %    end
    %    movePostion(hylabel(1),[-0.01 0.06],'xy'); %85
    %    movePostion(hylabel(3),0.025,'y'); %75
    %    movePostion(hylabel(5),0.03,'y'); %65
    %    movePostion(hylabel(7),[0.01 0.03],'xy'); %55
    %    movePostion(hylabel(9),[0.2 0.03],'xy'); %45
    
    load nclcolormap
    colormap(nclcolormap.temp_diff_18lev)
    hbar=colorbar;
    if exist('myCAXIS','var'), caxis(myCAXIS), end
    set(hbar,'tag','cbar','fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
    % colorbar('location','southoutside')
    set(gcf,'paperPositionmode','auto')
    set(gca, 'CLim', [-0.3, 0.3]); % ice thickness -0.5-0.5 \\\ ice concentrstion -0.3-0.3
    set(hbar,'position',[0.9 0.1055 0.02 0.8203]);
    
    set(gcf, 'visible', 'on');
    xlabel(['Ice Concentration Mean Diff on 2003-2008',' March '],'fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
    print(gcf, '-dpng', '-r300' ,['Ice_Concentration_mean_Diff_2003-2008_','March.png']);
    
    % disp('To save the figure, please run')
    
end


