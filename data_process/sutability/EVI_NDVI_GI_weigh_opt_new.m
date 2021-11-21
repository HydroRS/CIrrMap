% Codes used to obtain training samples
clc;clear

% data location
modis_data_local='F:\Data_ZL\MODIS\';
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
land_loc='F:\Data_ZL\IrrMap\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
% year for the land use map
year_map=2000;

%% read data

data_dem= geotiffread([land_loc,'\Envrioment\dem_class_map_new.tif']);

data_waterdist= geotiffread([land_loc,'\Envrioment\waterdist_class_map_new.tif']);
data_slope= geotiffread([land_loc,'\Envrioment\slope_class_map_new.tif']);
data_aridity= geotiffread([land_loc,'\Envrioment\aridity_class_map_new.tif']);

[data_crop, Ref] = geotiffread([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);

% read weights
EVI_2000_weight_all=load([modis_data_local,num2str(year_map),'\EVI_2000_weight_all.mat'], 'EVI_2000_weight_all');
EVI_2000_weight_all=EVI_2000_weight_all.EVI_2000_weight_all;

GI_2000_weight_all=load([modis_data_local,num2str(year_map),'\GI_2000_weight_all.mat'], 'GI_2000_weight_all');
GI_2000_weight_all=GI_2000_weight_all.GI_2000_weight_all;

NDVI_2000_weight_all=load([modis_data_local,num2str(year_map),'\NDVI_2000_weight_all.mat'], 'NDVI_2000_weight_all');
NDVI_2000_weight_all=NDVI_2000_weight_all.NDVI_2000_weight_all;

province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;


%%
weight_all=[];
for i=1:500
    rng(i);
    x=rand(1,4);
    y=sum(x);
    r=x/y;
    weight_all=[weight_all;r];
end

%%
sutability_map=zeros(size(data_crop));
weight_opt_used=[];
mannual_weight_province=[7,9,13,17,22,26];
mannual_weight_id=[499, 409,442,367,217,98];
for kk=1:31
    kk
    % province & county
    province_crop_id=province_crop_id_2000{kk};
  
    idx = sub2ind(size(data_crop),province_crop_id(:,1),province_crop_id(:,2)); % row/con to index
    data_dem_province=data_dem(idx);
    data_waterdist_province=data_waterdist(idx);
    data_slope_province=data_slope(idx);
    data_aridity_province=data_aridity(idx);
  
    %% weigh settings
    weight_province=EVI_2000_weight_all{kk}+NDVI_2000_weight_all{kk}+GI_2000_weight_all{kk};
    
%          [temp,index]=sort(weight_province(:,2));
%             max2min_oder=flipud([temp,index]);
%              weigth_opt1=weight_all(max2min_oder(1:40,2),:);
%           [xx, id]= intersect(weight_all,weigth_opt1(7,:),'rows');
         
         
if ismember(kk,mannual_weight_province)==1
    best_one_id=mannual_weight_id(ismember(mannual_weight_province,kk)==1);
else
    
    best_one_id= find(weight_province(:,2)==max(max(weight_province(:,2))));
    
    if length(best_one_id)>1
        weigth_opt_temp=weight_all(best_one_id,:);
        std_temp=std(weigth_opt_temp,0,2);
        best_one_id_temp=best_one_id(std_temp==min(std_temp));
        best_one_id=best_one_id_temp;
    end
end


    weigth_opt=weight_all(best_one_id(1),:);
    sutability= data_dem_province/4*weigth_opt(1)...
        +data_waterdist_province/4*weigth_opt(2)...
        +data_slope_province/4*weigth_opt(3)...
        +data_aridity_province/10*weigth_opt(4);
    
   weight_opt_used=[weight_opt_used;weigth_opt];
   sutability_map(idx)=sutability;
    
end

%%
output_local='F:\Data_ZL\IrrMap\';
geotiffwrite([output_local,num2str(year_map),'\county_level\test08\sutability_map_V3.tif'],sutability_map,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
xlswrite([output_local,num2str(year_map),'\county_level\test08\weight_opt_used_V3.xlsx'],weight_opt_used);
