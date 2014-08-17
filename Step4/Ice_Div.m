%% Claculate the shear deformation of the ice
% Method:
% u: iicevelu;  v: iicevelv;
% du/dx = (u(i + 1, j) - u(i - 1, j)) / (2 * e1t(i, j))
% dv/dy = (v(i, j + 1) - v(i, j - 1)) / (2 * e2t(i, j))
% shear deformation = sqrt((du / dx - dv / dy) ^ 2) + (du / dy + dv / dx) ^ 2));

clc;
clear;
close all;

%% Initialization
NY = 2400; NX = 1632;
configuration = '12th';
% mesh file that includes the length of each grid
meshhgr = '/mnt/storage0/xhu/CREG012-I/mask/CREG12_mesh_hgr.nc'; % horizontal mesh file

%% Read data
e1t = GetNcVar(meshhgr,'e1t',[0 0 0],[NX NY 1]);
e2t = GetNcVar(meshhgr,'e2t',[0 0 0],[NX NY 1]);
srcP = '/mnt/storage0/xhu/CREG012-EXH003/'; % 12th
ncfile = [srcP,'CREG012-EXH003_y2003m01d05_icemod.nc']; % 12th
lon_12 = GetNcVar(ncfile,'nav_lon',[0 0],[NX, NY]);
lat_12 = GetNcVar(ncfile,'nav_lat',[0 0],[NX, NY]);
lon_12 = lon_12(2: NY - 1, 2: NX - 1);
lat_12 = lat_12(2: NY - 1, 2: NX - 1);
timeCounter = 5: 5: 365;
for yearCounter = 2003: 2008
    for i = timeCounter
        date = num2date(yearCounter, i);
        ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc']; % 12th
        subII=1:1632; subJJ=1:2400;
        u = GetNcVar(ncfile,'iicevelu',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
        v = GetNcVar(ncfile,'iicevelv',[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
        u(u == 0) = NaN;
        v(v == 0) = NaN;
        du = zeros(NY, NX - 2);
        u_x = zeros(NY, NX - 2);
        dv = zeros(NY - 2, NX);
        v_y = zeros(NY - 2, NX);
        for j = 1: NX - 2
            du(:, j) = u(:, j + 2) - u(:, j);
            u_x(:, j) = du(:, j) ./ e1t(:, j + 1) ./ 2;
        end
        for j = 1: NY - 2
            dv(j, :) = v(j + 2, :) - v(j, :);
            v_y(j, :) = dv(j, :) ./ e2t(j + 1, :) ./ 2;
        end
        du = du(2: NY - 1, :);
        u_x = u_x(2: NY - 1, :);
        dv = dv(:, 2: NX - 1);
        v_y = v_y(:, 2: NX - 1);
        
        div = u_x + v_y;
        
        %% Map Plot
        m_proj('stereographic','lat',90,'long',-60,'radius',35,'rect','off');
        myxtick=[-150:60:180];
        myytick=[45:5:85];
        % plot ice concentration
        hp=m_pcolor(lon_12, lat_12, div);set(hp,'linestyle','none');
        
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
        
        load mycolormap
        colormap(mycolormap.icecmap)
        hbar=colorbar;
        if exist('myCAXIS','var'), caxis(myCAXIS), end
        set(hbar,'tag','cbar','fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
        % colorbar('location','southoutside')
        set(gcf,'paperPositionmode','auto')
        set(gca, 'CLim', [0 1e-7]); % ice thickness 0-5.0 \\\ ice concentrstion -0.35-0.35
        % set(gca, 'CLimMode', 'auto');
        set(hbar,'position',[0.9 0.1055 0.02 0.8203]);
        
        set(gcf, 'visible', 'off');
        xlabel(['Ice Div on ', date, ' ', configuration, ' Degree'],'fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
        print(gcf, '-dpng', '-r300' ,['Ice_Div_', date, '_', configuration,'_Degree','.png']);
        
        disp(['Finish: ', num2str(i / 3.65)]);
    end
    disp(num2str(yearCounter));
end