% Codes used to extract the location of crops in Land use data
clc;clear

% data location
IrrDistrict_local='F:\Data_ZL\IrrMap\IrrDistrict';
land_loc='F:\Data_ZL\IrrMap';

% year for the land use map
year_map=2000;

%%  read land data
district_ID = geotiffread([IrrDistrict_local,'\China_IrrDis250.tif']);

% find pixel id in districts
[IRR_row,IRR_colunm]=find(district_ID==1); 

% release memo
clear district_ID

%% read province data (same extent and spatial resolution as land data)
% read land data
[data_province, Ref] = geotiffread([land_loc,'\',num2str(year_map),'\province_',num2str(year_map),'.tif']);

province_IrrDistrict_id=cell(1,31);
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
data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new.tif']);

% obtaining coordinates of the projected system （pix2map)
[x,y] = pix2map(data_GeoInfor.RefMatrix, crop_current_province(:,1), crop_current_province(:,2));

% obtaining coordinates of the geographical system
[lat,lon] = projinv(data_GeoInfor ,x, y);  %将投影坐标转换为地理坐标

province_IrrDistrict_id{kk}=[crop_current_province,lat, lon];

end

%% save result
 save 'province_IrrDistrict_id.mat', 'province_IrrDistrict_id';
