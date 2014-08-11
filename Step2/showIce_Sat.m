%% Change from March to September
% timeCounter, day_Num, Loop-in Reintialize, Output
clear;clc;

%% Read file
icesat_icethk_fm04_filled = csvread('icesat_icethk_fm04_filled.dat');
icesat_icethk_fm04_filled(1) = [];
icesat_icethk_fm04_filled(19601) = [];

icesat_icethk_fm04_filled = reshape(icesat_icethk_fm04_filled, 5, 19600/5);

iceC = icesat_icethk_fm04_filled(5,:);
navLat = icesat_icethk_fm04_filled(1,:);
navLon = icesat_icethk_fm04_filled(2,:);

m_proj('stereographic','latitude',90,'radius',55,'rotangle',45);
[MAPX,dm]=m_ll2xy([360-103.761 360-4.441],[65.661 73.257],'clip','off');
[dm,MAPY]=m_ll2xy([103.366 360-4.441],[68.091 73.257],'clip','off');