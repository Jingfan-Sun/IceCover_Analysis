function drawIceTrackProj
% get the longitude and latitude of a section interactively by drawing it
% save the track informaiton to a mat file used for later interpolation
% usage:
%       drawIceTrackProj
% how-to:
%        1: change the setting for map projection, 
%           add the locations of observational section (could be down after step 2, simply using m_plot)
%        2: run the script
%        3: zoom into your interested area
%        4: click the "data cursor" button (DIFFERENT from mkSectionWithDistFromCoast_CDFTOOLS) 
%        5: select the observation sites
%        6: close the window, and copy the section information from command window
%        7: for section fluxes calculation, check the cdftools command: cdftransportizFinalSP
% July 2014,   xianmin@ualberta.ca

clc;

% global variables
global navLon navLat lonLog latLog NX NY secName

secName='CAANorthTest';
maskfile='mask.nc';

lonLog=[]; latLog=[];
navLon=GetNcVar(maskfile,'nav_lon');
navLat=GetNcVar(maskfile,'nav_lat');
[NY,NX]=size(navLon);

% load surface mask file
tmask=squeeze(GetNcVar(maskfile,'tmask',[0 0 0 0],[NX NY 1 1]));

figure;
set(gcf,'render','zbuffer','color','w','CloseRequestFcn',@clearMyGlobal,'Pointer','cross');
m_proj('stereographic','lat',65,'long',-60,'radius',45,'rect','on');
[cc,hh]=m_contour(navLon,navLat,tmask,[0.5 0.5],'k-');
m_etopo2('pcolorocean'); caxis([-4000 0]); colorbar;
m_grid; hold on;
% datacursor
mycobj=datacursormode(gcf);
datacursormode on;
set(mycobj,'UpdateFcn',@myupdatefcn,'SnapToDataVertex','off','Enable','on','DisplayStyle','window');
title(secName,'fontweight','bold')
disp('add observation locations using m_plot if there is any')
end

%---------------------------------------------------------------
function clearMyGlobal(varargin)
 % save some variables
 global lonLog latLog NX NY secName navLon navLat
 [lonLog,latLog]=myUnique(lonLog,latLog);
 NPT=numel(lonLog);
 indmin=zeros(1,NPT);
 for np=1:NPT
     [~,indmin(np)]=min((navLon(:)-lonLog(np)).^2 + (navLat(:)-latLog(np)).^2); % '~' means no concerned input
 end
 [~,iidx,~]=unique(indmin);
 indmin=indmin(sort(iidx));
 [jLogOri,iLogOri]=ind2sub([NY NX],indmin); % return the index

 %% secInfo
 secInfo.name=secName;
 secInfo.IIsub=[max(1,min(iLogOri)-4) min(NX,max(iLogOri)+4)];
 secInfo.JJsub=[max(1,min(jLogOri)-4) min(NY,max(jLogOri)+4)];
 indLonLat=sub2ind([NY NX],jLogOri,iLogOri);
 secInfo.myLon=navLon(indLonLat);
 secInfo.myLat=navLat(indLonLat);
 secInfo.iLogOri=iLogOri;
 secInfo.jLogOri=jLogOri;
 if ~exist('secIndex','dir')
    mkdir('secIndex');
 end
 eval(['save secIndex/',secName,'Index.mat secInfo'])
 % clear global variables when close the window
 clearvars -global *
 delete(gcf);
end

function output_txt = myupdatefcn(~,~)
% output_txt   Data cursor text string (string or cell array of strings).

 global preXX preYY lonLog latLog
 pos = get(gca,'CurrentPoint');     
 [clon,clat]=m_xy2ll(pos(1,1),pos(1,2));
 if ~ishold, hold on; end
 plot(pos(1,1),pos(1,2),'ko');  % label the previous selections
 lonLog=[lonLog clon];
 latLog=[latLog clat];

 if ~isempty(preXX)
    plot([preXX pos(1,1)],[preYY pos(1,2)])
 end
% update previous location
 preXX=pos(1,1); preYY=pos(1,2);
 output_txt = {['Lon: ',num2str(clon,4)],[' Lat: ',num2str(clat,4)]};
end
