% Codes used to extract the location of crops in Land use data
clc;clear

% data location，2000.tif:30m, 2000new.tif:250m
land_loc='F:\Data_ZL\IrrMap';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';

% year for the land use map
year_map=2000;

%%  read land data
data_lucc = geotiffread([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1_ForestGrass.tif']);
data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1_ForestGrass.tif']);


% find crop id
% [IRR_row,IRR_colunm]=find(data_lucc==11|data_lucc==12); % !!! this may differ
[IRR_row,IRR_colunm]=find(data_lucc>0); % !!! this may differ

% release memo
clear data_lucc

%% read province data (same extent and spatial resolution as land data)
% read land data
[data_province, Ref] = geotiffread([land_loc,'\',num2str(year_map),'\province_',num2str(year_map),'.tif']);
% data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\province_',num2str(year_map),'.tif']);

province_ForestGrass_id_2000=cell(1,31);
for kk=1:31
    
    kk
% find crop id
[IRR_row_province,IRR_colunm_province]=find(data_province==kk); % calculation for each province

% release memo
% clear data_province

%% find the intercetion of cropand and province
crop_current_province=intersect([IRR_row,IRR_colunm],[IRR_row_province,IRR_colunm_province],'rows');

%% temp test: Check the extraction results
% idx = sub2ind(size(data_province),crop_current_province(:,1),crop_current_province(:,2)); % row/con to index
% data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\province_',num2str(year_map),'.tif']);
% temp_test=data_province;
% temp_test(idx)=ones(size(idx)).*199;
%   geotiffwrite('temp_test.tif',temp_test,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);

%% Read row, column, lat, lon of the crop grids

% obtaining coordinates of the projected system （pix2map)
[x,y] = pix2map(data_GeoInfor.RefMatrix, crop_current_province(:,1), crop_current_province(:,2));

% obtaining coordinates of the geographical system
[lat,lon] = projinv(data_GeoInfor ,x, y);  %将投影坐标转换为地理坐标

province_ForestGrass_id_2000{kk}=[crop_current_province,lat,lon];

end

%% save result
%  save 'province_ForestGrass_id_2000.mat', 'province_ForestGrass_id_2000';
save([ID_loc,num2str(year_map),'\province_ForestGrass_id_2000.mat'],'province_ForestGrass_id_2000','-v7.3');