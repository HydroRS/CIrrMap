% Codes used to obtain training samples
clc;clear

% data location
modis_data_local='F:\Data_ZL\MODIS\';
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
land_loc='F:\Data_ZL\IrrMap\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
% year for the land use map
year_map=2000;

% read province data
% read land data
[data_crop, Ref] = geotiffread([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);

%##################
%   EVI_interp_and_sutability= geotiffread([land_loc,num2str(year_map),'\county_level\test05\EVI_interp_and_sutability.tif']);
% EVI_2000_intep_county_norm=load([modis_data_local,num2str(year_map),'\EVI_2000_intep_county_norm.mat'], 'EVI_2000_intep_county_norm');
% EVI_interp_and_sutability=EVI_2000_intep_county_norm.EVI_2000_intep_county_norm;

EVI_2000_intep_nominize=load([modis_data_local,num2str(year_map),'\EVI_2000_intep_nominize.mat'], 'EVI_2000_intep_nominize');
EVI_interp_and_sutability=EVI_2000_intep_nominize.EVI_2000_intep_nominize;

% EVI_2000_intep_county_norm_test=load([modis_data_local,num2str(year_map),'\EVI_2000_intep_county_norm_test'], 'EVI_2000_intep_county_norm_test');
% EVI_interp_and_sutability=EVI_2000_intep_county_norm_test.EVI_2000_intep_county_norm_test;

% EVI_2000=load([modis_data_local,num2str(year_map),'\EVI_2000.mat'], 'EVI_2000');
% EVI_interp_and_sutability=EVI_2000.EVI_2000;
 
%##################

% read county data
county_area=xlsread([Cesus_IrrArea_data_local,num2str(year_map),'\County_area_merge.xlsx']);

County_crop_id_2000=load([ID_loc,num2str(year_map),'\County_crop_id_2000.mat'], 'County_crop_id_2000');
County_crop_id_2000=County_crop_id_2000.County_crop_id_2000;

% read irrigaiton census data (province)
[Cesus_IrrArea_data, province]=xlsread([Cesus_IrrArea_data_local,'2001-2019年水利统计年鉴.xlsx'], [num2str(year_map),'年']);
province_code=sortrows(Cesus_IrrArea_data(2:end,[1,2,5]),2); 

% read sample id
validation_sample_id=load([ID_loc,num2str(year_map),'\validation_sample_id.mat'], 'validation_sample_id');
validation_sample_id=validation_sample_id.validation_sample_id;
% validation_sample_id_origin=load([ID_loc,num2str(year_map),'\validation_sample_id_origin.mat'], 'validation_sample_id_origin');
% validation_sample_id=validation_sample_id_origin.validation_sample_id_origin;

China_county_crop_aridity=geotiffread([land_loc,num2str(year_map),'\China_county_crop_aridity.tif']);
province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;
%
%% initaite viarbles
sutability_threshod_IrrArea=zeros(size(data_crop));

% Exact potential irrigaiton samples
for kk=1:31
    kk
    % province & county
    province_crop_id=province_crop_id_2000{kk};
    province_current=province_code(kk,1);
    current_provinc_county_Irr=county_area(county_area(:,1)==province_current,end);
    current_provinc_county_code=county_area(county_area(:,1)==province_current,end-1);

%       idx = sub2ind(size(data_crop),province_crop_id(:,1),province_crop_id(:,2)); % row/con to index

      sutability_province=EVI_interp_and_sutability{kk}(:,1); % EVI_max_aj
    
       
    for jj=1:length(current_provinc_county_Irr);
        jj
        
        Cecsus_IrrArea=current_provinc_county_Irr(jj)*1e7;   % 1000 hm2 to m2
        county_in_province=County_crop_id_2000{jj,kk};
         idx = sub2ind(size(data_crop),province_crop_id(county_in_province,1),province_crop_id(county_in_province,2)); % row/con to index
        proportion_county=data_crop(idx);
     % proportion_county=sum(length(county_in_province),1);
         
           % sutability
        max_sutability=sutability_province(county_in_province); 
        [temp,index]=sort(max_sutability);
        max2min_oder=flipud([temp,index]);
      
        % threshods
        proportion_county_temp=proportion_county(max2min_oder(:,2)).*250*250; % area of each grid
        summax=cumsum(proportion_county_temp);
        if isempty(summax) % empty value
            continue
        elseif summax(end)<Cecsus_IrrArea;
                disp(['warning!!! ', num2str(current_provinc_county_code(jj)), ' IrrArea>CropArea']);
                id_threshod=length(proportion_county_temp); % thresholds
        else 
              id_threshod=find(summax>Cecsus_IrrArea); % thresholds
        end

        sutability_threshold_IrrArea=max2min_oder(1:id_threshod(1)-1,:);
        sutability_threshold_NoneIrrArea=max2min_oder(id_threshod(1):end,:); % find
        sutability_Irr_id=county_in_province(sutability_threshold_IrrArea(:,2));
        sutability_NoneIrr_id=county_in_province(sutability_threshold_NoneIrrArea(:,2));
        
        %Locate sutability dected Irr and none-irr to the grid province map
        sutability_idx = sub2ind(size(data_crop),province_crop_id(sutability_Irr_id,1),province_crop_id(sutability_Irr_id,2)); % row/con to index
        sutability_idx_none_irr = sub2ind(size(data_crop),province_crop_id(sutability_NoneIrr_id,1),province_crop_id(sutability_NoneIrr_id,2)); % row/con to index
        sutability_threshod_IrrArea(sutability_idx)=data_crop(sutability_idx);
        sutability_threshod_IrrArea(sutability_idx_none_irr)=0;
 
    end
end

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
    
%% save result
% xlswrite('EVI_threshod_IrrArea_map_accuracy.xlsx', histogram_match_all);
% 
% output_local='F:\Data_ZL\IrrMap\';
% geotiffwrite([output_local,num2str(year_map),'\county_level\test05\EVI_sutability_threshold_IrrArea1.tif'],sutability_threshod_IrrArea,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
