function mytopo=getTopoTrack(lon,lat,is180,metStr)
% get the topography data along a track
% usage:
%        mytopo=getTopoTrack(lon,lat,is180)
%           lon: -180 ~ 180
%           lat:  -90 ~  90
%         is180: 
%                1: do the interpolation with two steps, lon>=90 & lon <90
%                   because in the original topography array: left (-180) to right (180)
%                0: in one step
etopoFile='/mnt/storage0/xhu/DATA/etopo1_Ice_gridN.nc';

if ~exist(etopoFile,'file')
  disp('Please check getTopoTrack.m for the location of etopo file')
  mytopo=nan;
  return
end
if nargin==2
   is180=0;
   metStr='linear';
elseif nargin==3
   metStr='linear';
elseif nargin~=4
   help getTopoTrack
   return
end

mytopo=zeros(size(lon));
lon=fixLonRange(lon);

if is180==0
   if ~isempty(find(lon<0, 1)) && ~isempty(find(lon>90, 1))
      disp(['I would like to recommend the option: is180=1'])
   end
end
if is180==1
   % do the interpolation with two steps
   indEast=find(lon>90);
   indWest=find(lon<=90);
   if ~isempty(indEast)
     mytopo(indEast)=getTopoTrack(lon(indEast),lat(indEast),0,metStr);
   end
   if ~isempty(indWest)
     mytopo(indWest)=getTopoTrack(lon(indWest),lat(indWest),0,metStr);
   end
   return
end

etopoLon=GetNcVar(etopoFile,'lon');
etopoLat=GetNcVar(etopoFile,'lat');
z=GetNcVar(etopoFile,'z');
% data -180 to 180
N1=find(etopoLon<min(lon)-2); if isempty(N1), N1=1; end
N2=find(etopoLon<=max(lon)+1);if isempty(N2), N2=numel(etopoLon); end
Lon=etopoLon(N1(end)+1:N2(end));
L1=find(etopoLat<min(lat)-2); if isempty(L1), L1=1; end
L2=find(etopoLat<max(lat)+1); if isempty(L2), L2=numel(etopoLat); end

Lat=etopoLat(L1(end):L2(end));
z=z(L1(end):L2(end),N1(end)+1:N2(end));
clear N1 N2 L1 etopoLon etopoLat

% interpolation
mytopo=interp2(Lon,Lat,z,lon,lat,metStr);

function lon=fixLonRange(lon)
ind180Up=find(lon>180);
while ~isempty(ind180Up)
   lon(ind180Up)=lon(ind180Up)-360;
   ind180Up=find(lon>=180);
end

ind180NLow=find(lon<=-180);
while ~isempty(ind180NLow)
   lon(ind180NLow)=lon(ind180NLow)+360;
   ind180NLow=find(lon<-180);
end
