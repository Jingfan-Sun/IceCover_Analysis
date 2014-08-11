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
if nargin==0
   flname='icesat_icethk_on07_filled.dat';
end

%% loading the data
fid=fopen(flname,'r');
nLine=str2double(fgetl(fid));
myIceData=fscanf(fid,'%f%f%f%f%f',[5 nLine]);
fclose(fid);
myIceData=myIceData';  % --> unit: cm

% file = csvread(flname,1,0);
% nLine = file(1);
% file(1) = [];
% file(19601) = [];
% file = reshape(file,  5, 19600/5);
% myIceData = file';

%% extract coordinate information
isProj=1;
yy=myIceData(:,4);
NX=length(find(yy==yy(1)));
NY=nLine/NX;
if isProj==1
   lat=reshape(squeeze(myIceData(:,1)),NX,NY);
   lon=reshape(squeeze(myIceData(:,2)),NX,NY);
else
   xx=reshape(squeeze(myIceData(:,3)),NX,NY);
   yy=reshape(yy,NX,NY);
end

myIceH=reshape(myIceData(:,5),NX,NY);
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

%% plotting
if isProj==1
   % using m_map toolbox
   % m_proj('stereographic','lat',90,'long',0,'radius',30);
   m_proj('stereographic','latitude',90,'radius',55,'rotangle',45);
   hp=m_pcolor(lon,lat,myIceH);set(hp,'linestyle','none');
   m_grid;
   m_gshhs_i('patch',[1.0 0.8 0.7],'linestyle','none');
   colorbar;
   set(gca, 'CLim', [0, 5.5]);
   figurenicer;
else
   hp=pcolor(xx,yy,myIceH);set(hp,'linestyle','none');
   hcbar=colorbar;
   caxis([0 6])
   figurenicer;
   axis equal; axis tight;
end
