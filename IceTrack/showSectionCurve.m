function showSectionCurve(secName,varargin)
% show the geographic location of a section
% usage:
%      showSectionCurve(secName,varargin)
% e.g.,
%      showSectionCurve(secName,varargin)

if nargin==0
   help showSectionCurve
   return
end
  
myR=15; nNode=0; latName='myLat'; lonName='myLon';
isOV=0;
isSmooth=1;
while(size(varargin,2)>0)
   switch lower(varargin{1})
     case {'r','radius','rad','myr'}
          myR=varargin{2};
          varargin(1:2)=[];
     case {'nnode','nd','nskip'}
          nNode=varargin{2};
          varargin(1:2)=[];
     case {'lon','long','longname','longitude'}
          lonName=varargin{2};
          varargin(1:2)=[];
     case {'lat','latname','latitude'}
          latName=varargin{2};
          varargin(1:2)=[];
     case {'nofig','ov'}
          isOV=1;
          varargin(1)=[];
     case {'nosmooth','orinode','original'}
          isSmooth=0;
          varargin(1)=[];
     case {'flux'}
          lonName='fluxLon'; latName='fluxLat';
          varargin(1)=[];
     otherwise
         if isnumeric(varargin(1))
            myR=arargin(1);
         else
            disp(['Unknow option: ',varargin{1}])
         end
         varargin(1)=[];
   end
end

secIndexFile=['secIndex/',secName,'Index.mat'];
if ~exist(secIndexFile,'file')
   error([secName,' index file does not exist'])
end
eval(['load ',secIndexFile]); 

eval(['myLon=secInfo.',lonName,';']);
eval(['myLat=secInfo.',latName,';']);
if isOV==0
   figure;
   m_proj('stereographic','lat',mean(myLat),'long',mean(myLon),'radius',myR)
   m_gshhs_i('color','k');m_grid;
end
if ~ishold, hold on; end
m_plot(myLon,myLat,'b');
m_plot(myLon(1),myLat(1),'marker','o','markerfacecolor','w');
if nNode>0
   hpn=m_plot(myLon(nNode:nNode:end),myLat(nNode:nNode:end),'.');
   set(hpn,'marker','s','markerfacecolor','r', ...
          'markersize',8,'markeredgecolor','w','linewidth',2);
end

if isSmooth==1
   %% smooth the section if needed (to avoid jagged signals)
   if ~isfield(secInfo,'isSmoothed')
      % smooth the curve
      [tmpx,tmpy]=m_ll2xy(myLon,myLat);
      [xx02,yy02]=smoothDist(tmpx,tmpy,'cubic',0.2);
      [xx,yy]=smoothDist(xx02,yy02,'cubic',5);
      [myLon,myLat]=m_xy2ll(xx,yy);
      hl=m_plot(myLon,myLat,'r');set(hl,'linewidth',2);
   end
end
set(gcf,'color','w')
