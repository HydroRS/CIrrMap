% Codes used to extract the location of crops in Land use data
clc;clear

% data location，
land_loc='F:\Data_ZL\MODIS\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';

% year for the land use map
year_map=2000;


if year_map==2000
    start_day=49;
else
    start_day=1;
end

%% load crop location data
% province_crop_id_2000=load('province_crop_id_2000.mat', 'province_crop_id_2000');
% province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;
% current_province_id=province_crop_id_2000{1};

%% read qualliy  look-up table
[value, quality_info]=xlsread([land_loc,num2str(year_map),'\MOD13Q1-006-250m-16-days-VI-Quality-lookup.csv']);
id_good_quality01=ismember(quality_info(2:end,2),{'VI produced with good quality', 'VI produced, but check other QA','Pixel produced, but most probably cloudy'});
id_good_quality02=ismember(quality_info(2:end,3),{'Highest quality', 'Decreasing quality','Lower quality'});
id_good_quality03=strcmp(quality_info(2:end,5),'No');
id_good_quality04=strcmp(quality_info(2:end,6),'No');
id_good_quality05=strcmp(quality_info(2:end,7),'No');
id_good_quality06=strcmp(quality_info(2:end,9),'No');
id_good_quality07=strcmp(quality_info(2:end,10),'No');
id_all_quality=find(id_good_quality01==1&id_good_quality02==1&id_good_quality03==1&...
    id_good_quality04==1&id_good_quality05==1&id_good_quality06==1&...
    id_good_quality07==1);

%  id_all_quality=find(id_good_quality02==1);

value_good_qualtiy=value(id_all_quality);
%% load crop location in modis data
modis_evi_ndiv_crop_id=load([ID_loc,num2str(year_map),'\modis_evi_ndiv_crop_id.mat'], 'modis_evi_ndiv_crop_id');
modis_evi_ndiv_crop_id=modis_evi_ndiv_crop_id.modis_evi_ndiv_crop_id;
% current_province_id_modis=modis_evi_ndiv_crop_id{1};

province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;
%%  read EVI data

dayofyear=start_day:16:353;
valid_percent_all=zeros(length(dayofyear),1);

EVI_data_all=cell(31,1);
NDVI_data_all=cell(31,1);

for ii=1:length(start_day:16:353)
    
    day_samlength=num2str(dayofyear(ii),'%03d');
    
    ['MOD13Q1.006__250m_16_days_doy', num2str(year_map),day_samlength,'_aid0001.tif']
    
    
    %% ====EVI data======
    data= imread([land_loc,num2str(year_map),'\',['MOD13Q1.006__250m_16_days_EVI_doy', num2str(year_map),day_samlength,'_aid0001.tif']]);
    
        %      int16-> double
    data=double(data);
    
    % valid ranges
    data(data<-2000 | data>10000)=NaN;

    %     real value=data*scale factor
    data=data.*0.0001;
    
    
    %% ====NDVI data======
    data_NDVI= imread([land_loc,num2str(year_map),'\',['MOD13Q1.006__250m_16_days_NDVI_doy', num2str(year_map),day_samlength,'_aid0001.tif']]);
    
      %      int16-> double
    data_NDVI=double(data_NDVI);
    
    % valid ranges
    data_NDVI(data_NDVI<-2000 | data_NDVI>10000)=NaN;

    %     real value=data*scale factor
    data_NDVI=data_NDVI.*0.0001;
    
    
    %% ====quality flag======
    vi_quality= imread([land_loc,num2str(year_map),'\',['MOD13Q1.006__250m_16_days_VI_Quality_doy', num2str(year_map),day_samlength,'_aid0001.tif']]);
    
    %% current province
    
    for jj=1:31
       % jj
       
        province_crop_id=province_crop_id_2000{jj};
        
        current_province_id_modis=modis_evi_ndiv_crop_id{jj};
        
        EVI_province_data=data(current_province_id_modis);
        NDVI_province_data=data_NDVI(current_province_id_modis);
        province_quality=double(vi_quality(current_province_id_modis));
        
        %% valid data
        modis_quality=ismember(province_quality, value_good_qualtiy);
%         valid_percent=length(find(modis_quality==1))/length(modis_quality);
%         valid_percent_all(ii,jj)=valid_percent;
        
        %% invalid data intepolation
 
        invalid_data_id=find(modis_quality==0|isnan(EVI_province_data)==1);
        valid_data_id=find(modis_quality==1&isnan(EVI_province_data)==0);
        
         invalid_data_id_NDVI=find(modis_quality==0|isnan(NDVI_province_data)==1);
        valid_data_id_NDVI=find(modis_quality==1&isnan(NDVI_province_data)==0);
        
        EVI_province_data_intep=EVI_province_data;
        NDVI_province_data_intep=NDVI_province_data;
        
         EVI_province_data_valid=EVI_province_data(valid_data_id);
          id_valid_neareast=knnsearch([province_crop_id(valid_data_id,3),province_crop_id(valid_data_id,4)],...
            [province_crop_id(invalid_data_id,3),province_crop_id(invalid_data_id,4)]); %最邻近插值
        EVI_province_data_intep(valid_data_id(id_valid_neareast))=EVI_province_data_valid(id_valid_neareast);

          NDVI_province_data_valid=NDVI_province_data(valid_data_id_NDVI);
          id_valid_neareast=knnsearch([province_crop_id(valid_data_id_NDVI,3),province_crop_id(valid_data_id_NDVI,4)],...
            [province_crop_id(invalid_data_id_NDVI,3),province_crop_id(invalid_data_id_NDVI,4)]); %最邻近插值
        NDVI_province_data_intep(valid_data_id_NDVI(id_valid_neareast))=NDVI_province_data_valid(id_valid_neareast);
        
        
        EVI_data_all{jj}(:,ii)=EVI_province_data_intep;
        NDVI_data_all{jj}(:,ii)=NDVI_province_data_intep;
   
            %% invalid data intepolation
%         invalid_data_id=find(modis_quality==0|isnan(EVI_province_data)==1);
%         valid_data_id=find(modis_quality==1&isnan(EVI_province_data)==0);
%         
%          invalid_data_id_NDVI=find(modis_quality==0|isnan(NDVI_province_data)==1);
%         valid_data_id_NDVI=find(modis_quality==1&isnan(NDVI_province_data)==0);
%         
%         EVI_province_data_intep=EVI_province_data;
%         NDVI_province_data_intep=NDVI_province_data;
%         
%         EVI_province_data_intep(invalid_data_id)=interp1(valid_data_id,EVI_province_data(valid_data_id),invalid_data_id,'nereast','extrap') ;
%         NDVI_province_data_intep(invalid_data_id_NDVI)=interp1(valid_data_id_NDVI,NDVI_province_data(valid_data_id_NDVI),invalid_data_id_NDVI,'nereast','extrap');
%         
%         EVI_data_all{jj}(:,ii)=EVI_province_data_intep;
%         NDVI_data_all{jj}(:,ii)=NDVI_province_data_intep;
        
    end
end

%% save result
%  save ('NDVI_data_all.mat', 'NDVI_data_all','-v7.3');
%   save ('EVI_data_all.mat', 'EVI_data_all','-v7.3');

output_fold='F:\Data_ZL\MODIS\';
 save ([output_fold,num2str(year_map),'\NDVI_data_all.mat'], 'NDVI_data_all','-v7.3');
  save ([output_fold,num2str(year_map),'\EVI_data_all.mat'], 'EVI_data_all','-v7.3');