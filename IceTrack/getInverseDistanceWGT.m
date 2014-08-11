function [wgt,avgIndex,wgtTS]=getInverseDistanceWGT(tLon,tLat,srcLon,srcLat,avgN,maxGridDist,srcMask)
% calculate the index of neighbour points, weight, weight-with-consideration-of-mask
% usage:
%      [wgt,avgIndex,wgtTS]=getInverseDistanceWGT(tLon,tLat,srcLon,srcLat,avgN,maxGridDist,srcMask)
%                tLon,tLat : long/latitude of target points (a vector with a length of NPT)
%            srcLon,srcLat : long/latitude of source data points (NY x NX maxtrix or a vector with a length of NX*NY)
%                     avgN : number of most closest points used for averaging
%              maxGridDist : max searching distance
%                  srcMask : land-sea mask (NZ x NX*NY or NZ x NY x NX), 1 for ocean, 0 for land
%
%                      wgt : the weight matrix (avgN x NPT), sum is 1 if any neighbouring point is found, and 0 if out of source domain
%                 avgIndex : index of neighbouring points in source data (avgIndex x NPT)
%                    wgtTS : the weight matrix (avgN x NPT x NZ ) with consideration of land-sea mask. Land points are excluded for weight calculation
%                            sum(:,np,nz) is 1 if any neighbouring point is found, and 0 if out of source domain or surrounded by land points
% method description:
%                   https://www.ems-i.com/smshelp/Data_Module/Interpolation/Inverse_Distance_Weighted.htm
% history:
%     Mar 3, 2014   Xianmin (xianmin@ualberta.ca)

if nargin==6
   isWGTmask=0;
elseif nargin==7
   isWGTmask=1;
else
   help getInverseDistanceWGT
   return
end

NPT=numel(tLon);
NPTSrc=numel(srcLon);
if isWGTmask==1
   if numel(srcMask)==NPTSrc
      NZ=1;
      srcMask=squeeze(srcMask);
   else
      NZ=size(srcMask,1);
   end
   wgtTS=zeros(avgN,NPT,NZ);
end
wgt=zeros(avgN,NPT);
avgIndex=zeros(avgN,NPT);

for np=1:NPT
    ppdist=myll2dist2(tLon(np),tLat(np),srcLon(:),srcLat(:));
    [distSort,indexSort]=sort(ppdist);
    if (distSort(1)>maxGridDist )
       %out of model domain, no need to check the index (0 by defaut)
       wgt(:,np)=0;
       if isWGTmask==1, wgtTS(:,np,:)=0; end
    else
       tmpdistVect=distSort(1:avgN);
       tmpdistVect(tmpdistVect>maxGridDist)=nan;
       Rmax=nanmax(tmpdistVect);
       myTotal=nansum(((Rmax-tmpdistVect)./(Rmax*tmpdistVect)).^2);
       wgt(:,np)=((Rmax-tmpdistVect)./(Rmax*tmpdistVect)).^2/myTotal;
       avgIndex(:,np)=indexSort(1:avgN);
       if isWGTmask==1
          if NZ==1 
             % only one layer
             tmpdistVect(srcMask(indexSort(1:avgN))==0)=nan;
             RmaxC=nanmax(tmpdistVect);
             myTotalC=nansum(((RmaxC-tmpdistVect)./(RmaxC*tmpdistVect)).^2);
             wgtTS(:,np,1)=((RmaxC-tmpdistVect)./(RmaxC*tmpdistVect)).^2/myTotalC;
          else
             for nz=1:NZ
                 maskLev=squeeze(srcMask(nz,:));
                 tmpdistVectC=tmpdistVect;
                 tmpdistVectC(maskLev(indexSort(1:avgN))==0)=nan;
                 RmaxC=nanmax(tmpdistVectC);
                 myTotalC=nansum(((RmaxC-tmpdistVectC)./(RmaxC*tmpdistVectC)).^2);
                 wgtTS(:,np,nz)=((RmaxC-tmpdistVectC)./(RmaxC*tmpdistVectC)).^2/myTotalC;
             end
          end
       end
    end
end
if isWGTmask==0 && nargout==3
   wgtTS=wgt;
end
   
function dist=myll2dist2(lon0,lat0,lon1,lat1)
% lon0, lat0: start point(s)
% lon1, lat1:   end point(s)
  % Earth radius
  zr=(6378.137+6356.7523)/2.0; % km
  pi180=pi/180;

  % compute these term only if they differ from previous call
  np0=numel(lon0);
  np=numel(lon1);
  lat0=reshape(lat0,np0,1)*pi180;
  lon0=reshape(lon0,np0,1)*pi180;
  if np0>1
     zux=cos(lon0).*cos(lat0);
     zuy=sin(lon0).*cos(lat0);
     zuz=sin(lat0);
  else
     zux=cos(lon0)*cos(lat0);
     zuy=sin(lon0)*cos(lat0);
     zuz=sin(lat0);
  end

  lon1=reshape(lon1,1,np)*pi180;
  lat1=reshape(lat1,1,np)*pi180;
  if np>1
     zvx=cos(lon1).*cos(lat1);
     zvy=sin(lon1).*cos(lat1);
     zvz=sin(lat1);
  else
     zvx=cos(lon1)*cos(lat1);
     zvy=sin(lon1)*cos(lat1);
     zvz=sin(lat1);
  end
  zux=repmat(zux,1,np); zuy=repmat(zuy,1,np); zuz=repmat(zuz,1,np); 
  zvx=repmat(zvx,np0,1); zvy=repmat(zvy,np0,1); zvz=repmat(zvz,np0,1); 
  
  if np>1 || np0>1
    zdps=zux.*zvx+zuy.*zvy+zuz.*zvz;
    zdps(zdps>=1.0)=0;
    dist=zdps.*acos(zdps)*zr;
  else
    zdps=zux*zvx+zuy*zvy+zuz*zvz;
    if zdps>=1.0
       dist=0;
    else
       dist=zdps*acos(zdps)*zr;
    end
  end

function dist=myll2dist(lon0,lat0,lon,lat)
% origins from m_lldist (m_map package)
% compute the distance from (lon0,lat0)
% lon0, lat0: start point(s)
% lon, lat:   end point(s)
pi180=pi/180;
earth_radius=6378.137;
lat0=lat0*pi180;
lat=lat*pi180;
if numel(lon0)~=1
   np0=numel(lon0);
   np=numel(lon);
   lon0=repmat(lon0(:),1,np);
   lat0=repmat(lat0(:),1,np);
   lon=repmat(lon(:)',np0,1);
   lat=repmat(lat(:)',np0,1);
end
dlon =(lon-lon0)*pi180;
dlat = lat-lat0;
a = (sin(dlat/2)).^2 + cos(lat0)* cos(lat) .* (sin(dlon/2)).^2;
angles = 2 * atan2( sqrt(a), sqrt(1-a) );
dist = earth_radius * angles;
