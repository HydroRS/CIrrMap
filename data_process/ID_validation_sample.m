clc, clear

year_map=2000;

ID_loc='D:\Work_2021\Irr_Map_China\ID\';
land_loc='F:\Data_ZL\IrrMap\Census\';


% read EVI, NDVI, and GI
province_crop_id_2000=load([ID_loc,num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

 
point_Irr_NoneIrr_data=xlsread([land_loc,'point_Irr_NoneIrr_data_used.xlsx']);
validation_sample_id=[];
for kk=1:31
    kk
     current_point=point_Irr_NoneIrr_data(point_Irr_NoneIrr_data(:,3)==kk,1:4);
     Nereast_crop= knnsearch(province_crop_id_2000{kk}(:,3:4),current_point(:,1:2));
    validation_sample_id{kk}=[current_point,Nereast_crop];
end

save([ID_loc,num2str(year_map),'\validation_sample_id.mat'],'validation_sample_id','-v7.3');

 %% orgin ID (not used)
% % read pont scale validation data
% point_Irr_NoneIrr_data=xlsread([land_loc,'point_Irr_NoneIrr_data.xlsx']);
% validation_sample_id=[];
% for kk=1:31
%     kk
%      current_point=point_Irr_NoneIrr_data(point_Irr_NoneIrr_data(:,3)==kk,1:4);
%      Nereast_crop= knnsearch(province_crop_id_2000{kk}(:,3:4),current_point(:,1:2));
%     validation_sample_id{kk}=[current_point,Nereast_crop];
% end
% %
% validation_sample_id_origin=validation_sample_id;
% save([ID_loc,num2str(year_map),'\validation_sample_id_origin.mat'],'validation_sample_id_origin','-v7.3');