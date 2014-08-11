meshhgr='/mnt/storage0/xhu/CREG012-I/mask/CREG12_mesh_hgr.nc'; % horizontal mesh file
meshzgr='/mnt/storage0/xhu/CREG012-I/mask/CREG12_mesh_zgr.nc'; % vertical mesh file
maskfile='/mnt/storage0/xhu/CREG012-I/mask/CREG12_mask_v34.nc'; % mask file

srcP='/mnt/storage0/xhu/CREG012-EXH003/';

yearCounter = 2003;
timeCounter = 5;
data_Type = 'nav_lat';

date = num2date(yearCounter, timeCounter);

ncfile=[srcP,'CREG012-EXH003_y',date,'_icemod.nc'];

% read the longitude and latitude informations
NY=2400; NX=1632; % dimension of the whole model domain
% read sub-domain only (to save memory)
subII=60:1600; subJJ=400:2400;  % for pan-Arctic region
%subII=70:900; subJJ=1200:2150; % for the Canadian Arctic Archipelago (CAA) region

lat = GetNcVar(ncfile,data_Type,[0 0], [1632 2400]);
tmask=GetNcVar(maskfile,'tmask',[0 0 0 0],[1632 2400 1 1]);
lat(tmask==0)=NaN;

flag = 0;

for i = 1:2400
   for j = 1:1632
   
       if(lat(i, j) > 55)
           flag = 1;
           break;
       end
       
   end
   if(flag == 1)
      break; 
   end
end

i
j

% read ice concentration
% iceC=GetNcVar(ncfile,data_Type,[subII(1)-1 subJJ(1)-1 0],[numel(subII) numel(subJJ) 1]);
% tmask=GetNcVar(maskfile,'tmask',[subII(1)-1 subJJ(1)-1 0 0],[numel(subII) numel(subJJ) 1 1]);  % surface land mask
% iceC(tmask==0)=NaN; % set the values on land to be NaNs
