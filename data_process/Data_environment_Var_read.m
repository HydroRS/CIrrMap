% Codes used to obtain training samples
clc;clear

% data location
modis_data_local='F:\Data_ZL\MODIS\';
land_loc='F:\Data_ZL\IrrMap\';
land_Env_loc='F:\Data_ZL\IrrMap\Envrioment\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';

% year for the land use map
year_map=2000;

%%  Data read
% read province crop Id
province_crop_id_2000=load([ID_loc,num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;
[data_province, Ref] = geotiffread([land_loc,num2str(year_map),'\province_',num2str(year_map),'.tif']);

% SM_crop_id.mat
SM_crop_id=load([ID_loc,num2str(year_map),'\SM_crop_id.mat'], 'SM_crop_id');
SM_crop_id=SM_crop_id.SM_crop_id;
data_SM=imread([land_Env_loc,'predicted_sm_global_15km_2000.tif']);
%% read envrionment variables
crop_intensity = geotiffread([land_Env_loc,'crop_intensity.tif']);
dem250= geotiffread([land_Env_loc,'dem250.tif']);
distrance_to_river= geotiffread([land_Env_loc,'waterdist250f.tif']);
% distance_to_Irrdistrict= geotiffread([land_Env_loc,'Distance_to_resevors_lakes.tif']);
slope250= geotiffread([land_Env_loc,'slope250.tif']);
soil_type= geotiffread([land_Env_loc,'soil_type.tif']);
soil_moisture=geotiffread([land_Env_loc,'predicted_sm_global_15km_2000.tif']);
IrrSutability=geotiffread([land_Env_loc,'sutability_map_V3.tif']);
env_variables=cell(31,1);
for kk=1:31
    kk
    ID=province_crop_id_2000{kk};
    ID_SM=SM_crop_id{kk};
    env_variables{kk}(:,1)=province_crop_id_2000{kk}(:,3); % lat
    env_variables{kk}(:,2)=province_crop_id_2000{kk}(:,4); % lon
    env_variables{kk}(:,3)=crop_intensity(sub2ind(size(data_province),ID(:,1),ID(:,2)) );
    env_variables{kk}(:,4)=dem250(sub2ind(size(data_province),ID(:,1),ID(:,2)) );
    env_variables{kk}(:,5)=distrance_to_river(sub2ind(size(data_province),ID(:,1),ID(:,2)) );
    env_variables{kk}(:,6)=IrrSutability(sub2ind(size(data_province),ID(:,1),ID(:,2)));
    env_variables{kk}(:,7)=slope250(sub2ind(size(data_province),ID(:,1),ID(:,2)) );
    env_variables{kk}(:,8)=soil_type(sub2ind(size(data_province),ID(:,1),ID(:,2)) );
    env_variables{kk}(:,9)=soil_moisture(ID_SM);
 
    
end

%%
output_fold='F:\Data_ZL\MODIS\';
 save ([output_fold,num2str(year_map),'\env_variables.mat'], 'env_variables','-v7.3');




