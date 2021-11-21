% Codes used to obtain training samples
clc;clear

% data location
modis_data_local='F:\Data_ZL\MODIS\';
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
land_loc='F:\Data_ZL\IrrMap\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
% year for the land use map
year_map=2000;
% read pont scale validation data
point_Irr_NoneIrr_data=xlsread([Cesus_IrrArea_data_local,'point_Irr_NoneIrr_data_used.xlsx']);

%%
China_county_crop_aridity=geotiffread([land_loc,num2str(year_map),'\China_county_crop_aridity.tif']);

% read sample id
validation_sample_id=load([ID_loc,num2str(year_map),'\validation_sample_id.mat'], 'validation_sample_id');
validation_sample_id=validation_sample_id.validation_sample_id;

province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

%% read 1km baseline
[data_base, Ref] =geotiffread([land_loc,num2str(year_map),'\county_level\test08\base_map_1km1.tif']);
data_GeoInfor_base=geotiffinfo([land_loc,num2str(year_map),'\county_level\test08\base_map_1km1.tif']);
[IRR_row,IRR_colunm]=find(data_base>=0); % calculation for each province

[CIrrMap1km, Ref] =geotiffread([land_loc,num2str(year_map),'\county_level\Other_IrrMap\zhu_map_1km.tif']);

% obtaining coordinates of the projected system （pix2map)
[x,y] = pix2map(data_GeoInfor_base.RefMatrix,IRR_row, IRR_colunm);

% obtaining coordinates of the geographical system
[lat,lon] = projinv(data_GeoInfor_base ,x, y);  %将投影坐标转换为地理坐标

nereast_grid=knnsearch([lat,lon],[point_Irr_NoneIrr_data(:,1),point_Irr_NoneIrr_data(:,2)]);
row_col=[IRR_row(nereast_grid),IRR_colunm(nereast_grid)];

%%
sutability_factor=[];
for kk=1:length(nereast_grid)
point_in_map_value=CIrrMap1km(row_col(kk,1), row_col(kk,2));
sutability_factor=[sutability_factor;[point_Irr_NoneIrr_data(kk,:),point_in_map_value]];
end
       
%% aridity

aridty=[];
for kk=1:31
    kk
    current_province_id=province_crop_id_2000{kk};
    id=validation_sample_id{kk};
   
      temp_data=zeros(length(id(:,1)),1);
      for jj=1:length(id(:,1))
          province_id=id(:,end);
      temp_row_col=[current_province_id(province_id(jj),1),current_province_id(province_id(jj),2)];
      temp_data(jj)=China_county_crop_aridity(temp_row_col(1),temp_row_col(2));
      end
     temp_data =[id,temp_data];
       aridty=[aridty;temp_data];
end

[intersect_point,ia,ib]=intersect(sutability_factor(:,1:2),aridty(:,1:2),'rows');
sutability_factor(ia,6)=aridty(ib,6);
aridty=sutability_factor(:,6);
%%
acccuracy_China={'OA', 'kappa','PIrr','PnonIrr'};
sutability_factor(:,5)=sutability_factor(:,5)/100; % unit: 1-100
sutability_factor(sutability_factor>0.05)=1;
sutability_factor(sutability_factor<=0.05)=0;
% ####### China ##########
   obs=sutability_factor(:,4);
   simu=sutability_factor(:,5);
    [over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
    acccuracy_China{2,1}=over_accuracy;
   acccuracy_China{2,2}=kappa;
    acccuracy_China{2,3}=Irr_Pa;
    acccuracy_China{2,4}=NonIrr_Pa;

% ####### arid region ##########
    obs=sutability_factor(aridty<=0.500,4);
   simu=sutability_factor(aridty<=0.500,5);
   [over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
    acccuracy_China{3,1}=over_accuracy;
   acccuracy_China{3,2}=kappa;
    acccuracy_China{3,3}=Irr_Pa;
    acccuracy_China{3,4}=NonIrr_Pa;

% ########## humid region ##########
    obs=sutability_factor(aridty>0.500,4);
   simu=sutability_factor(aridty>0.500,5);
   [over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
    acccuracy_China{4,1}=over_accuracy;
   acccuracy_China{4,2}=kappa;
    acccuracy_China{4,3}=Irr_Pa;
    acccuracy_China{4,4}=NonIrr_Pa;

    %%
 output_local='F:\Data_ZL\IrrMap\';
xlswrite([output_local,num2str(year_map),'\county_level\Other_IrrMap\Zhu_map_1km_Point_accuracy_post.xlsx'],acccuracy_China, 'acccuracy_China');
