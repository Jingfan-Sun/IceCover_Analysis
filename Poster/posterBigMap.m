%% Show big map at the middle of the poster
clear;
clc;
close all;

%% Draw map
% m_proj('stereographic','lat',90,'long',-60,'radius',35,'rect','off');
m_proj('lambert','long',[-149 40],'lat',[55 90]);
myxtick=[-150:60:180];
myytick=[45:5:85];

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
delete(hylabel([2 4 5 6]));
[xxtmp,yytmp]=m_ll2xy((85:-5:45)*0-15,85:-5:45);

movePostion(hylabel(1),-0.055,'y');
movePostion(hylabel(3),-0.055,'y');
movePostion(hylabel(7),-0.055,'y');
%    for np=1:2:9
%        movePosition(hylabel(np),xxtmp(np),yytmp(np));
%    end
%    movePostion(hylabel(1),[-0.01 0.06],'xy'); %85
%    movePostion(hylabel(3),0.025,'y'); %75
%    movePostion(hylabel(5),0.03,'y'); %65
%    movePostion(hylabel(7),[0.01 0.03],'xy'); %55
%    movePostion(hylabel(9),[0.2 0.03],'xy'); %45

set(gcf, 'visible', 'on');
print(gcf, '-dpng', '-r300' ,['posterMap.png']);