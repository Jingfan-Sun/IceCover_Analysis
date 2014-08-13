%% This script costs much memory
%% Show difference between iceProduction and Thickness diff between two concontifuous day
clc;
clear;
close all;
%% Read data from ANHA4
yearCounter = 2003;
timeCounter = 10: 5: 365;

m_proj('stereographic','lat',90,'long',-60,'radius',35,'rect','off');

for i = timeCounter
    %% ANHA4
    date_latter = num2date(yearCounter, i);
    date_former = num2date(yearCounter, i - 5);
    srcP = '/mnt/storage0/clark/ANHA4-E34REF/'; % 4th
    ncfile_latter = [srcP,'CREG025-E34REF_y',date_latter,'_icemod.nc']; % 4th
    ncfile_former = [srcP,'CREG025-E34REF_y',date_former,'_icemod.nc']; % 4th
    NY = 800; NX = 544; % dimension of the whole model domain
    subII = 1:544; subJJ = 1:800;
    
    iceH_latter = GetNcVar(ncfile_latter,'iicethic',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
    iceH_former = GetNcVar(ncfile_former,'iicethic',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
    iceP = GetNcVar(ncfile_former,'iiceprod',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
    
    
    %% Plot
    figure(1);
    subplot(121);
    title(['Ice Thickness&Production Diff on ', date_latter],'fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');

    myxtick=[-150:60:180];
    myytick=[45:5:85];
    
    % plot ice concentration
    navLon=GetNcVar(ncfile_latter,'nav_lon',[subII(1)-1 subJJ(1)-1],[numel(subII) numel(subJJ)]);
    navLat=GetNcVar(ncfile_latter,'nav_lat',[subII(1)-1 subJJ(1)-1],[numel(subII) numel(subJJ)]);
    hp=m_pcolor(navLon,navLat,iceH_latter - iceH_former - iceP .* 400);set(hp,'linestyle','none');
    
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
    hbar=colorbar('location','southoutside');
    set(hbar,'tag','cbar','fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
    % colorbar('location','southoutside')
    set(gcf,'paperPositionmode','auto')
    set(gca, 'CLim', [-0.5, 0.5]); % ice thickness 0-5.0 \\\ ice concentrstion -0.35-0.35
    
    xlabel(['Ice Thickness&Production Diff on ANHA4 ', date_latter],'fontweight','bold','fontsize',7,'fontname','Nimbus Sans L');
    
    %% Plot
    subplot(122);
    
    myxtick=[-150:60:180];
    myytick=[45:5:85];
    
    % plot ice concentration
    navLon=GetNcVar(ncfile_latter,'nav_lon',[subII(1)-1 subJJ(1)-1],[numel(subII) numel(subJJ)]);
    navLat=GetNcVar(ncfile_latter,'nav_lat',[subII(1)-1 subJJ(1)-1],[numel(subII) numel(subJJ)]);
    hp=m_pcolor(navLon, navLat, iceP .* 400);set(hp,'linestyle','none');
    
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

    hbar=colorbar;
    if exist('myCAXIS','var'), caxis(myCAXIS), end  
    hbar = colorbar('location','southoutside');
    set(hbar,'tag','cbar','fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
    % colorbar('location','southoutside')
    set(gcf,'paperPositionmode','auto')
    set(gca, 'CLim', [-0.25, 0.25]); % ice thickness 0-5.0 \\\ ice concentrstion -0.35-0.35
    % set(gca, 'CLimMode', 'auto');
    
    set(gcf, 'visible', 'off');
    xlabel(['Ice Production on ANHA4 ', date_latter],'fontweight','bold','fontsize',7,'fontname','Nimbus Sans L');
    print(gcf, '-dpng', '-r300' ,['Ice_ANHA4Diff_with_Production', date_latter,'.png']);
    
    disp([num2str(i / numel(timeCounter) * 100 / 5), '%']);
    close;
end