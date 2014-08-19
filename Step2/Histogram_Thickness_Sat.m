clc;
clear;

% variables
name_Array = {'fm04', 'fm05', 'fm06', 'fm08', 'ma07', 'on03', 'on04', 'on05', 'on06', 'on07'};
bins = 0:0.2:8; % in 0.2 thick bins
total_Area_Sum = zeros(1, numel(bins) - 1); % Total ice among certain periad
isProj = 1;

for i = 1:4

    flname=['icesat_icethk_', name_Array{i}, '_filled.dat'];

    
    %% loading the data
    fid=fopen(flname,'r');
    nLine=str2double(fgetl(fid));
    myIceData=fscanf(fid,'%f%f%f%f%f',[5 nLine]);
    fclose(fid);
    myIceData=myIceData';  % --> unit: cm
    
    yy=myIceData(:,4);
    sat_SizeX=length(find(yy==yy(1)));
    sat_SizeY=nLine/sat_SizeX;
    if isProj==1
        sat_Lat=reshape(squeeze(myIceData(:,1)),sat_SizeX,sat_SizeY);
        sat_Lon=reshape(squeeze(myIceData(:,2)),sat_SizeX,sat_SizeY);
    else
        xx=reshape(squeeze(myIceData(:,3)),sat_SizeX,sat_SizeY);
        yy=reshape(yy,sat_SizeX,sat_SizeY);
    end
    
    myIceH=reshape(myIceData(:,5),sat_SizeX,sat_SizeY);
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
    
    total_Area = zeros(1, numel(bins) - 1);
    for ii = 1:(numel(bins) - 1)
        % extract target data
        temp1 = find(myIceH > bins(ii));
        temp2 = find(myIceH <= bins(ii + 1));
        
        % find the same number in these temps
        target = temp1(ismember(temp1, temp2));
        % calculate the total area
        total_Area(ii) = numel(target) * 25 * 25;
    end
    disp(['total area finished: ',num2str(i)]);
    total_Area_Sum = total_Area_Sum + total_Area;
end

total_Area_Mean = total_Area_Sum / 4 ;

%% Do plotting
% b = bar(0:0.2:7.8,total_Area);
% set(b,'BarWidth',1);
% create the data used for histogram plotting
plotting = [];
for i = 1: numel(total_Area_Mean)
   temp_plot = (ones(1, round(total_Area_Mean(i)))*2*i - 1) / 10;
   plotting = [plotting, temp_plot];
end
disp('plotting calculate finished');
hist(plotting, 0.1:0.2:7.9);
set(get(gca,'child'),'FaceColor','black','EdgeColor','w');
set(gca, 'fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
grid on;

%% Output
set(gcf, 'visible', 'on');
title(['Sat Distribution Febuary and March over 04, 05, 06, 08'],'fontweight','bold','fontsize',12,'fontname','Nimbus Sans L');
xlabel('Ice Thickness \m');
xlabh = get(gca,'XLabel');
set(xlabh,'Position',get(xlabh,'Position') + [0 30000 0]);
ylabel('Area \km^2');
set(gca, 'Position', [0.13 0.085 0.775 0.815]);
title=get(gca, 'Title');
set(title, 'Position', get(title, 'Position') + [0 40000 0]);
print(gcf, '-dpng', '-r300' ,['Ice_Thickness_Sat_Distribution_FM_04050608.png']);


