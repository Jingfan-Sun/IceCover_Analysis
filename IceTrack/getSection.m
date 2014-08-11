function mysection=getSection(ncfile,ncvar,secInfo)
% extract the scalar variable along a section from grided model output
% usage:
%        getSection(ncfile,ncvar,secInfo)
%             ncvar.name    : variable name
%                  .origrid : grid-point type
%           secInfo.name    : name of this section
%                  .IIsub   : i-index of sub-domain
%                  .JJsub   : j-index of sub-domain
%                  .Lon     : longitude of each node
%                  .Lat     : latitude of each node
%  return:
%          mysection.name
clc;
if nargin~=3
   help getSection
   return
end
if ~exist(ncfile,'file')
   disp([ncfile,' does not exist!']); 
   return;
end

if ~isfield(secInfo,'ncmaskfile')
   secInfo.ncmaskfile='mask.nc';
end

myLon=secInfo.myLon;
myLat=secInfo.myLat;
avgIndex=secInfo.avgIndex;

if ~isstruct(ncvar)
   varname=ncvar;      clear ncvar
   ncvar.name=varname; clear varname
end

switch lower(ncvar.name)
  case {'votemper','vosaline','sossheig','iicethic','ileadfra','somxl010','vosigmai'}
       ncvar.maskLand=1; % land-value not used for interpolation
  otherwise
        error(['not coded for ', ncvar.name,' yet'])
end

if ~isfield(secInfo,'ncmaskfileh')
   secInfo.ncmaskfileh=secInfo.ncmaskfile;
end
if ~isfield(secInfo,'ncmaskfilez')
   secInfo.ncmaskfilez=secInfo.ncmaskfile;
end

NPT=length(myLon);
% get variable   
if ~isfield(ncvar,'isZLev')
   switch lower(ncvar.name)
      case {'votemper','vosaline','vosigmai'}
        isZLev=1;
      case {'sossheig','iicethic','ileadfra','somxl010'}
        isZLev=1;
      otherwise
        error('need a field: isZLev in ncvar to tell whether it is a 3D field')
   end
else
   isZLev=ncvar.isZLev;
end

%
ii0=secInfo.IIsub(1)-1; NX=secInfo.IIsub(2)-secInfo.IIsub(1)+1;
jj0=secInfo.JJsub(1)-1; NY=secInfo.JJsub(2)-secInfo.JJsub(1)+1;
NZ=GetNcDimLen(secInfo.ncmaskfilez,'z');
if ncvar.maskLand==1
   wgt=secInfo.wgtTS;
else
   wgt=secInfo.wgt;
end

if isZLev==1
   mymask=GetNcVar(secInfo.ncmaskfile,'tmask',[ii0 jj0 0 0],[NX NY NZ 1]);
   myvar0=squeeze(GetNcVar(ncfile,ncvar.name,[ii0 jj0 0 0],[NX NY NZ 1]));
   myvar0(mymask==0)=nan;

   % layer-depth, same for tsuv
   if isfield(secInfo,'e3t0varname')
      cdep=secInfo.e3t0varname;
   else
      cdep='e3t_0'; 
   end
   if isfield(secInfo,'e3tpsvarname')
      ce3=secInfo.e3tpsvarname;
   else
      ce3='e3t_ps';
   end
  
   [~,e3DimLen]=GetNcVarDims(secInfo.ncmaskfilez,cdep);
   if sum(e3DimLen>1)>1
      is3dE3t=1;
   else
      is3dE3t=0;
   end

   if is3dE3t==1
      % assuming NXglo~=NYglo~=NZglo
      NZglo=GetNcDimLen(secInfo.ncmaskfilez,'z');
      NYglo=GetNcDimLen(secInfo.ncmaskfilez,'y');
      NXglo=GetNcDimLen(secInfo.ncmaskfilez,'x');
      startInd=e3DimLen*0;
      cntInd=startInd+1;
      startInd(e3DimLen==NXglo)=secInfo.IIsub(1)-1;
      startInd(e3DimLen==NYglo)=secInfo.JJsub(1)-1;
      cntInd(e3DimLen==NXglo)=secInfo.IIsub(2)-secInfo.IIsub(1)+1;
      cntInd(e3DimLen==NYglo)=secInfo.JJsub(2)-secInfo.JJsub(1)+1;
      cntInd(e3DimLen==NZglo)=NZglo;
      % load 3D e3t with consideration of e3t_ps
      e3t0=squeeze(GetNcVar(secInfo.ncmaskfilez,cdep,startInd,cntInd));
   else
      e3t0=GetNcVar(secInfo.ncmaskfilez,cdep);       % NZx1
      e3tps=GetNcVar(secInfo.ncmaskfilez,ce3,[ii0 jj0 0],[NX NY 1]);
      mbathy=GetNcVar(secInfo.ncmaskfilez,'mbathy',[ii0 jj0 0],[NX NY 1]);
   end

   % load depth of t-point
   gdeptVar='gdept_0';
   if isNcVar(secInfo.ncmaskfilez,gdeptVar)==0
      gdeptVar='gdept';
   end
   if isNcVar(secInfo.ncmaskfilez,gdeptVar)==0
      error(['Either gdept_0 or gdept is found in ',secInfo.ncmaskfilez])
   end
   gdept=GetNcVar(secInfo.ncmaskfilez,gdeptVar); % NZx1

   mysection.var=zeros(NZ,NPT);
   mysection.dep=zeros(NZ,NPT);
   mysection.dep2=zeros(NZ,NPT);
   sumWGT=squeeze(nansum(wgt,1));
   varSecLev=zeros(1,NPT);
   depSecLev=zeros(1,NPT);
   depSecLev2=zeros(1,NPT);
   TempH=zeros(NY,NX);
   TempH_up=TempH;
   dept=TempH;

   for NLev=1:NZ
       masktmp=squeeze(mymask(NLev,:,:));
       if is3dE3t==0
          TempH(:)=e3t0(NLev);
          TempH(mbathy==NLev)=e3tps(mbathy==NLev);
       else
          TempH(:,:)=squeeze(e3t0(NLev,:,:));
       end
       TempH(masktmp==0)=nan;
       if (NLev==1)
          dept(:,:)=TempH*0.5;
       else
         if is3dE3t==0
            TempH_up(:,:)=e3t0(NLev-1);
            TempH_up(mbathy==NLev-1)=e3tps(mbathy==NLev-1);
         else
            TempH_up(:,:)=squeeze(e3t0(NLev-1,:,:));
         end
         dept(:,:)=dept(:,:)+(TempH_up+TempH)*0.5;
       end
       tm=squeeze(myvar0(NLev,:,:)); tm(isnan(tm))=0;
       if sum(sum(mymask(NLev,:,:)))>0
          for np=1:NPT
              if ncvar.maskLand==1
                  tmpWGTSum=sumWGT(np,NLev);
              else
                  tmpWGTSum=sumWGT(np);
              end
              if (tmpWGTSum==0)
                 varSecLev(np)=nan;  % not available in model domain
                 depSecLev(np)=nan;
                 depSecLev2(np)=nansum(dept(avgIndex(:,np)).*secInfo.wgt(:,np));
                 % if NLev>1
                 %    depSecLev2(np)=  mysection.dep2(NLev-1,np);
                 % else
                 %    depSecLev2(np)=gdept(NLev);    
                 % end
              else
                 varSecLev(np)=nansum(tm(avgIndex(:,np)).*wgt(:,np,NLev));
                 depSecLev(np)=nansum(dept(avgIndex(:,np)).*wgt(:,np,NLev));
                 depSecLev2(np)=nansum(dept(avgIndex(:,np)).*secInfo.wgt(:,np));
              end
          end
          %if NLev==1
          %   indNaN=find(isnan(varSecLev));
          %   indValid=find(~isnan(varSecLev));
          %   varSecLev(indNaN)=interp1(indValid,varSecLev(indValid),indNaN,'nearest');
          %end
          mysection.var(NLev,:)=varSecLev; % No data in this level
          mysection.dep(NLev,:)=depSecLev; % No data in this level
          mysection.dep2(NLev,:)=depSecLev2; % No data in this level
       else
          mysection.var(NLev,:)=nan; % No data in this level
          mysection.dep(NLev,:)=gdept(NLev); % No data in this level
       end
   end
else
   myvar0=squeeze(GetNcVar(ncfile,ncvar.name,[ii0 jj0 0],[NX NY 1]));
   wgt=squeeze(wgt(:,:,1));
   sumWGT=nansum(wgt);
   varSecLev=zeros(1,NPT);
   mysection.var=zeros(1,NPT);
   for np=1:NPT
      if (sumWGT(np)==0)
         varSecLev(np)=nan;  % not available in model domain
      else
         varSecLev(np)=nansum(myvar0(avgIndex(:,np)).*wgt(:,np));
      end
   end
   %   indNaN=find(isnan(varSecLev));
   %   indValid=find(~isnan(varSecLev));
   %   varSecLev(indNaN)=interp1(indValid,varSecLev(indValid),indNaN,'nearest');
   mysection.var=varSecLev;
end
mysection.lon=myLon;
mysection.lat=myLat;
mysection.xx=[0 (cumsum(m_lldist(myLon,myLat)))'];
if isZLev==1, mysection.depOri=repmat(reshape(gdept,[],1),1,NPT); end
