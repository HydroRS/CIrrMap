% ####################Performance Evaluation################
clc
clear;
year_map=2000;

land_loc='F:\Data_ZL\IrrMap\';
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';


% read province data as the baseline map
% read province data
[data_crop, Ref] = geotiffread([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);

% read province crop Id
province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

% read county data
[county_area, infor]=xlsread([Cesus_IrrArea_data_local,num2str(year_map),'\County_area_merge.xlsx']);
zhu_county_area_all=xlsread([Cesus_IrrArea_data_local,num2str(year_map),'\County_area_original.xlsx']);
zhu_county_area=zhu_county_area_all(:,5);

% read irrigaiton census data (province)
[Cesus_IrrArea_data, province]=xlsread([Cesus_IrrArea_data_local,'2001-2019年水利统计年鉴.xlsx'], [num2str(year_map),'年']);
province_code=sortrows(Cesus_IrrArea_data(2:end,[1,2,5]),2);

CIrrMap= geotiffread([land_loc,num2str(year_map),'\county_level\test08\2000_Irr_map_county_China_final_post2.tif']);

basin= geotiffread([land_loc,num2str(year_map),'\county_level\test08\liuyu_grid250.tif']);
%%

% sum Irr and NoneIrr area for each province
Irr_NonIrr_Area=[];
Irr_NonIrr_Area{1,1}='省ID';
Irr_NonIrr_Area{1,2}='灌溉面积';
Irr_NonIrr_Area{1,3}='非灌溉面积';
Irr_NonIrr_Area{1,4}='灌溉比例';


for ii=1:31
    ii
    
    current_province_crop_id=province_crop_id_2000{ii};
    idx = sub2ind(size(data_crop),current_province_crop_id(:,1),current_province_crop_id(:,2)); % row/con to index
    Irr_nonIrr_province=CIrrMap(idx);
    crop_proportion=data_crop(idx);
    
    Irr_area=sum(Irr_nonIrr_province(Irr_nonIrr_province>0)).*250.*250/1e7;  % m2->1000ha
    
    Non_Irr_area=sum(crop_proportion(Irr_nonIrr_province==0)).*250.*250/1e7;  % m2->1000ha
    
    Irr_NonIrr_Area{ii+1,1}=ii;
    Irr_NonIrr_Area{ii+1,2}=Irr_area;
    Irr_NonIrr_Area{ii+1,3}=Non_Irr_area;
    Irr_NonIrr_Area{ii+1,4}=Irr_area/(Irr_area+Non_Irr_area);
    
    
end

% save results
 xlswrite([land_loc,num2str(year_map),'\county_level\test08\Irr_NonIrr_Area',num2str(year_map),'.xlsx'],Irr_NonIrr_Area, 'Province');
%%

% sum Irr and NoneIrr area for each basin
Irr_NonIrr_Area=[];
Irr_NonIrr_Area{1,1}='流域ID';
Irr_NonIrr_Area{1,2}='灌溉面积';
Irr_NonIrr_Area{1,3}='非灌溉面积';
Irr_NonIrr_Area{1,4}='灌溉比例';

for ii=1:9
    ii
    
    current_province_crop_id=find(basin==ii);
    idx=current_province_crop_id;
%     idx = sub2ind(size(data_crop),current_province_crop_id(:,1),current_province_crop_id(:,2)); % row/con to index
    Irr_nonIrr_province=CIrrMap(idx);
    crop_proportion=data_crop(idx);
    
    Irr_area=sum(Irr_nonIrr_province(Irr_nonIrr_province>0)).*250.*250/1e7;  % m2->1000ha
    
    Non_Irr_area=sum(crop_proportion(Irr_nonIrr_province==0)).*250.*250/1e7;  % m2->1000ha
    
    Irr_NonIrr_Area{ii+1,1}=ii;
    Irr_NonIrr_Area{ii+1,2}=Irr_area;
    Irr_NonIrr_Area{ii+1,3}=Non_Irr_area;
    Irr_NonIrr_Area{ii+1,4}=Irr_area/(Irr_area+Non_Irr_area);
    
    
end


% save results
 xlswrite([land_loc,num2str(year_map),'\county_level\test08\Irr_NonIrr_Area',num2str(year_map),'.xlsx'],Irr_NonIrr_Area, 'Basin');
