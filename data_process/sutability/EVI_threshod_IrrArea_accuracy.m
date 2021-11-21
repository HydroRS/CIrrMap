% Codes used to obtain training samples
clc;clear

% data location
modis_data_local='F:\Data_ZL\MODIS\';
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
land_loc='F:\Data_ZL\IrrMap\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
% year for the land use map
year_map=2000;

sutability_threshod_IrrArea= geotiffread([land_loc,num2str(year_map),'\county_level\test08\EVI_sutability_threshold_IrrArea_opt.tif']);

China_county_crop_aridity=geotiffread([land_loc,num2str(year_map),'\China_county_crop_aridity.tif']);

% read sample id
validation_sample_id=load([ID_loc,num2str(year_map),'\validation_sample_id.mat'], 'validation_sample_id');
validation_sample_id=validation_sample_id.validation_sample_id;


province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;


%% province assessment
accuarcy_Province={'OA', 'kappa','PIrr','PnonIrr'};
% aridty=[];
for kk=1:31
    kk
    sutability_factor=[];
    current_province_id=province_crop_id_2000{kk};
    id=validation_sample_id{kk};
    idx_map = sub2ind(size(China_county_crop_aridity),current_province_id(:,1),current_province_id(:,2)); % row/con to index
     
     sutability_province=sutability_threshod_IrrArea(idx_map);
       Irr_sutability=sutability_province(id(:,end),:);
    
      sutability_factor=[id,Irr_sutability];
      sutability_factor(sutability_factor>0)=1;
      
      obs=sutability_factor(:,4);
   simu=sutability_factor(:,1+5);
    [over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
    accuarcy_Province{kk+1,1}=over_accuracy;
   accuarcy_Province{kk+1,2}=kappa;
    accuarcy_Province{kk+1,3}=Irr_Pa;
    accuarcy_Province{kk+1,4}=NonIrr_Pa;
    
end

%% China, arid, humid assessment
sutability_factor=[];
aridty=[];
for kk=1:31
    kk
    current_province_id=province_crop_id_2000{kk};
    id=validation_sample_id{kk};
    idx_map = sub2ind(size(sutability_threshod_IrrArea),current_province_id(:,1),current_province_id(:,2)); % row/con to index
     
     sutability_province=sutability_threshod_IrrArea(idx_map);
       Irr_sutability=sutability_province(id(:,end),:);
    
      sutability_factor=[sutability_factor;[id,Irr_sutability]];
      
      temp_data=zeros(length(id(:,1)),1);
      for jj=1:length(id(:,1))
          province_id=id(:,end);
      temp_row_col=[current_province_id(province_id(jj),1),current_province_id(province_id(jj),2)];
      temp_data(jj)=China_county_crop_aridity(temp_row_col(1),temp_row_col(2));
      end
       aridty=[aridty;temp_data];
end

sutability_factor(sutability_factor>0)=1;

acccuracy_China={'OA', 'kappa','PIrr','PnonIrr'};

sutability_factor=[];
aridty=[];
for kk=1:31
    kk
    current_province_id=province_crop_id_2000{kk};
    id=validation_sample_id{kk};
    idx_map = sub2ind(size(sutability_threshod_IrrArea),current_province_id(:,1),current_province_id(:,2)); % row/con to index
     
     sutability_province=sutability_threshod_IrrArea(idx_map);
       Irr_sutability=sutability_province(id(:,end),:);
    
      sutability_factor=[sutability_factor;[id,Irr_sutability]];
      
      temp_data=zeros(length(id(:,1)),1);
      for jj=1:length(id(:,1))
          province_id=id(:,end);
      temp_row_col=[current_province_id(province_id(jj),1),current_province_id(province_id(jj),2)];
      temp_data(jj)=China_county_crop_aridity(temp_row_col(1),temp_row_col(2));
      end
       aridty=[aridty;temp_data];
end

sutability_factor(sutability_factor>0)=1;

% ####### China ##########
   obs=sutability_factor(:,4);
   simu=sutability_factor(:,1+5);
    [over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
    acccuracy_China{2,1}=over_accuracy;
   acccuracy_China{2,2}=kappa;
    acccuracy_China{2,3}=Irr_Pa;
    acccuracy_China{2,4}=NonIrr_Pa;

% ####### arid region ##########
    obs=sutability_factor(aridty<=0.500,4);
   simu=sutability_factor(aridty<=0.500,1+5);
   [over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
    acccuracy_China{3,1}=over_accuracy;
   acccuracy_China{3,2}=kappa;
    acccuracy_China{3,3}=Irr_Pa;
    acccuracy_China{3,4}=NonIrr_Pa;

% ########## humid region ##########
    obs=sutability_factor(aridty>0.500,4);
   simu=sutability_factor(aridty>0.500,1+5);
   [over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
    acccuracy_China{4,1}=over_accuracy;
   acccuracy_China{4,2}=kappa;
    acccuracy_China{4,3}=Irr_Pa;
    acccuracy_China{4,4}=NonIrr_Pa;

    %%
 output_local='F:\Data_ZL\IrrMap\';
xlswrite([output_local,num2str(year_map),'\county_level\test09\EVI_Point_accuracy.xlsx'],acccuracy_China, 'acccuracy_China');
xlswrite([output_local,num2str(year_map),'\county_level\test09\EVI_Point_accuracy.xlsx'],accuarcy_Province, 'accuarcy_Province');
geotiffwrite([output_local,num2str(year_map),'\county_level\test09\EVI-Map.tif'],sutability_threshod_IrrArea,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);

