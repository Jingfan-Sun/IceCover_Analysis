%% Change from March to September
% timeCounter, day_Num, Loop-in Reintialize, Output
clear;clc;

%% Initialization
maskfile='/mnt/storage0/myers/NEMO/ORCA025-GLORYS2V3/GLORYS2V3_mesh_mask.nc'; % mask file
data_Type = 'iicethic'; % ice thickness 'iicethic' \\\\ ice concentration 'ileadfra'
configuration = '4th';

ice_Sum = 0; % Total ice among certain periad
month_Num = {'03', '09'}; % Sept 6, March 7

%% Calculate
for yearCounter = 2002: 2010
    
    for i = 1: 2

        srcP = '/mnt/storage0/myers/NEMO/ORCA025-GLORYS2V3/'; % 4th
        ncfile=[srcP,'GLORYS2V3_ORCA025_',num2str(yearCounter),month_Num{i},'15_R20130808_icemod.nc']; % 4th
        NY=1438; NX=1020; % dimension of the whole model domain
        subII = 1:NY; subJJ = 1:NX;
        
        % read ice concentration
        iceC=GetNcVar(ncfile,data_Type,[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
        tmask=GetNcVar(maskfile,'tmask',[subII(1)-1 subJJ(1)-1 0 0],[numel(subII) numel(subJJ) 1 1]);  % surface land mask
        iceC(tmask==0)=NaN; % set the values on land to be NaNs
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
            hp=m_pcolor(navLon,navLat,iceC);set(hp,'linestyle','none');
            
            if ~ishold, hold off; end
            
            % fill the land
%             m_gshhs_i('patch',[0 0 0]); set(findobj('tag','m_gshhs_i'),'linestyle','none');
            m_coast('patch',[0 0 0]); 
            set(findobj('tag','m_coast'),'linestyle','none'); % low resolution coastlines
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
            
            load mycolormap
            colormap(mycolormap.icecmap)
            hbar=colorbar;
            if exist('myCAXIS','var'), caxis(myCAXIS), end
            set(hbar,'tag','cbar','fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
            % colorbar('location','southoutside')
            set(gcf,'paperPositionmode','auto')
            set(gca, 'CLim', [0, 4.0]); % ice thickness 0-4.0 \\\ ice concentrstion 0-1.0
            set(hbar,'position',[0.9 0.1055 0.02 0.8203]);
            
            set(gcf, 'visible', 'on');
            xlabel(['Ice Thickness on month ', month_Num{i}, ' ', num2str(yearCounter), ' GLORYS2V3'],'fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
            print(gcf, '-dpng', '-r300' ,['Ice_Thickness_month_', month_Num{i}, '_', num2str(yearCounter), '_GLORYS2V3','.png']);
            
            % disp('To save the figure, please run')
            disp(num2str(i));
        end
    end
    timeCounter = 245;
    disp(yearCounter);
end


