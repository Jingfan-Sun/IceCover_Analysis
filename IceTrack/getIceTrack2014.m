function getIceTrack2014(secName)
% compute ice fields along a track from the ANHA12 output
% usage:
%       getIceTrack2014(secName)
% e.g.,
%       getIceTrack2014('BaffinNaresArctic')

if nargin==0
   disp('usage: getIceTrack2014(secName)')
   return
end

% create the name used for save the files 
YS=2003; YE=2008; MS=1; ME=12;
secInfo.name=secName;
caseTag='CREG012-EXH003';
dataRoot='/mnt/storage0/xhu/CREG012-EXH003';
saveP='./matfile/';

if ~exist(saveP,'dir')
  mkdir(saveP)
end

%% create the initial section index
if ~exist(['secIndex/',secInfo.name,'Index.mat'],'file')
   error(['Please check drawLonLatSection.m to create the ',secInfo.name,'Index.mat'])
else
   eval(['load secIndex/',secInfo.name,'Index.mat']); 
end

%% smooth the section if needed (to avoid jagged signals)
if ~isfield(secInfo,'isSmooth')
   % smooth the curve
   % secInfo.mylon is the longtitude of the points you choose
    myLon=secInfo.myLon; myLat=secInfo.myLat;
    % project on the center of the chosen points
    m_proj('stereographic','lat',mean(myLat),'long',mean(myLon),'radius',15)
    % change the longtitude and latitude of the points selected to the xy
    % scale
    [tmpx,tmpy]=m_ll2xy(myLon,myLat);
    % then smooth the selected points and return the points on the smooth
    % curve
    [xx02,yy02]=smoothDist(tmpx,tmpy,'cubic',2);
    [xx,yy]=smoothDist(xx02,yy02,'cubic',5);
    [myLon,myLat]=m_xy2ll(xx,yy);
    
    % show curve
    m_plot(secInfo.myLon,secInfo.myLat,'b'); hold on
    hl=m_plot(myLon,myLat,'r');set(hl,'linewidth',2);
    % Add a coastline to a given map using the 'intermediate' resolution of
    % the Global Self-consistant Hierarchical High-resolution Shorelines.
    m_gshhs_i('color','k');m_grid;
    
    secInfo.myLon=myLon;
    secInfo.myLat=myLat;
    secInfo.isSmooth=1;
    clearvars -global
    % update the data in the secInfo
    eval(['save secIndex/',secInfo.name,'Index.mat secInfo']); 
end
% add more variables to the file
if ~isfield(secInfo,'ncmaskfile'),  secInfo.ncmaskfile='mask.nc'; end
if ~isfield(secInfo,'ncmaskfilez'), secInfo.ncmaskfilez='mesh_zgr.nc'; end
if ~isfield(secInfo,'ncmaskfileh'), secInfo.ncmaskfileh='mesh_hgr.nc'; end
if ~isfield(secInfo,'anglefile'),   secInfo.anglefile='RotatedAngle_ANHA12.nc'; end

caseTagStr=strrep(caseTag,'-','_'); % change '-' to '_'
% create the name used for the wight file
iisubstr=['ii',num2str(secInfo.IIsub(1)),'_',num2str(secInfo.IIsub(2))];
jjsubstr=['jj',num2str(secInfo.JJsub(1)),'_',num2str(secInfo.JJsub(2))];
NPT=numel(secInfo.myLon);
wgtfile=['secIndex/wgt_',secInfo.name,'_',iisubstr,'_',jjsubstr,'_npt',num2str(NPT),'.mat'];
if ~exist(wgtfile,'file')
    % 'ii0' is the start index, NX is the length of the area
   ii0=secInfo.IIsub(1)-1; NX=secInfo.IIsub(2)-secInfo.IIsub(1)+1;
   jj0=secInfo.JJsub(1)-1; NY=secInfo.JJsub(2)-secInfo.JJsub(1)+1;
   NZ=GetNcDimLen(secInfo.ncmaskfilez,'z');% get the Z dimention of the file 
   avgN=4;

   srcLon=GetNcVar(secInfo.ncmaskfileh,'glamt',[ii0 jj0 0 ],[NX NY 1]);  % longitude of t-points
   srcLat=GetNcVar(secInfo.ncmaskfileh,'gphit',[ii0 jj0 0 ],[NX NY 1]);  % longitude of t-points
   e1t=GetNcVar(secInfo.ncmaskfileh,'e1t',[ii0 jj0 0],[NX NY 1]);
   e2t=GetNcVar(secInfo.ncmaskfileh,'e2t',[ii0 jj0 0],[NX NY 1]);
   % calclate the maxmum distance of the selected area
   maxGridDist=max(sqrt(e1t(:).*e1t(:)+e2t(:).*e2t(:)))/1000*1.25;  % km
   srcMask=GetNcVar(secInfo.ncmaskfile,'tmask',[ii0 jj0 0 0],[NX NY NZ 1]);
   clear e1t e2t 
   % calculate the distances of the target points
   [wgt,avgIndex,wgtTS]=getInverseDistanceWGT(secInfo.myLon,secInfo.myLat,srcLon,srcLat,avgN,maxGridDist,srcMask);
   eval(['save ',wgtfile,' wgt avgIndex wgtTS'])
   clear srcLon srcLat srcMask
   secInfo.wgt=wgt;
   secInfo.avgIndex=avgIndex;
   secInfo.wgtTS=wgtTS;
   eval(['save secIndex/',secInfo.name,'Index.mat secInfo']); 
else
   eval(['load ',wgtfile])
   secInfo.wgt=wgt;
   secInfo.avgIndex=avgIndex;
   secInfo.wgtTS=wgtTS;
end
clear wgt wgtTS avgIndex

if ~isfield(secInfo,'etopo')
   isETopo=0;
else
   isETopo=1;
end

for ny=YS:YE
    % create the name used for the data, e.g. y2003m01d05
    if ny==YS
       m0=MS; 
    else
       m0=1;           
    end
    if ny==YE
       m1=ME;
    else
       m1=12;
    end
    yystr=num2str(ny,'%04d'); % get the name of year string
    for nmon=m0:m1
        [mmstr,ddstr]=getyymmdd(nmon); % get the day of the data source accoding to the month
        if ~isempty(mmstr)
           for nd=1:size(mmstr,1)
               timeTag=['y',yystr,'m',mmstr(nd,:),'d',ddstr(nd,:)];
               % compute section
               for nv=1:2
                    if nv==1
                       ncvar.name='iicethic';
                       ncvar.maskLand=1; % because land values are filled already
                       ncvar.isZLev=0;
                       ncfile=[dataRoot,'/',caseTag,'_',timeTag,'_icemod.nc'];
                       secResult=[caseTagStr,'_mysection_IceH_',secInfo.name,'_',timeTag]; 
                    elseif nv==2
                       ncvar.name='ileadfra';
                       ncvar.maskLand=1; % because land values are filled already
                       ncvar.isZLev=0;
                       ncfile=[dataRoot,'/',caseTag,'_',timeTag,'_icemod.nc'];
                       secResult=[caseTagStr,'_mysection_IceC_',secInfo.name,'_',timeTag]; 
                    else
                        error('not code yet: more variables')
                    end
                    eval([secResult,'=getSection(ncfile,ncvar,secInfo);']);

                    if isETopo==0
                       if isfield(secInfo,'is180')
                          secInfo.etopo=reshape(abs(getTopoTrack(secInfo.myLon,secInfo.myLat,secInfo.is180)),1,[]);
                       else
                          secInfo.etopo=reshape(abs(getTopoTrack(secInfo.myLon,secInfo.myLat,0)),1,[]);
                       end
                       eval(['save secIndex/',secInfo.name,'Index.mat secInfo']); 
                       isETopo=1;
                    end
                    eval(['save ',saveP,secResult,'.mat ',secResult]);
               end                
           end
        end
    end
end
