% Codes used to extract the location of crops in Land use data
clc;clear

% data location��
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
province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

%%  qualliy  look-up table (reflectance 02)
[value, quality_info]=xlsread([land_loc,num2str(year_map),'\MOD09Q1-006-sur-refl-qc-250m-lookup.csv']);
id_good_quality01=ismember(quality_info(2:end,2),{'Corrected product produced at ideal quality all bands','Corrected product produced at less than ideal quality some or all bands'});
id_good_quality03=ismember(quality_info(2:end,4),{'highest quality'});

 id_all_quality=find(id_good_quality01==1&id_good_quality03==1);
value_good_qualtiy=value(id_all_quality);
%% quality look-up table (reflectance 04)
[value_reflect04, quality_info_reflect04]=xlsread([land_loc,num2str(year_map),'\MOD09A1-006-sur-refl-qc-500m-lookup.csv']);
id_good_quality01_reflect04=ismember(quality_info_reflect04(2:end,2),{ 'Corrected product produced at ideal quality -- all bands','Corrected product produced at less than ideal quality -- some or all bands'});
id_good_quality05_reflect04=ismember(quality_info_reflect04(2:end,6),{'highest quality'});

 id_all_quality_reflect04=find(id_good_quality01_reflect04==1&id_good_quality05_reflect04==1);
value_good_qualtiy_reflect04=value_reflect04(id_all_quality_reflect04);

%% load reflectance 02 location in modis data
modis_evi_ndiv_crop_id=load([ID_loc,num2str(year_map),'\modis_evi_ndiv_crop_id.mat'], 'modis_evi_ndiv_crop_id');
modis_evi_ndiv_crop_id=modis_evi_ndiv_crop_id.modis_evi_ndiv_crop_id;
% current_province_id_modis=modis_evi_ndiv_crop_id{1};

%% load reflectance 04 location in modis data
modis_refct04_crop_id=load([ID_loc,num2str(year_map),'\modis_refct04_crop_id.mat'], 'modis_refct04_crop_id');
modis_refct04_crop_id=modis_refct04_crop_id.modis_refct04_crop_id;

%%  green index estiamte

dayofyear=start_day:8:361;

GI_data_all=cell(31,1);

for ii=1:length(dayofyear)
   

    day_samlength=num2str(dayofyear(ii),'%03d');
    
  ['MOD09Q1.006_sur_refl_b02_doy', num2str(year_map),day_samlength,'_aid0001.tif']
    
    
    %% ====Reflectance 02 data======
    data= imread([land_loc,num2str(year_map),'\',['MOD09Q1.006_sur_refl_b02_doy', num2str(year_map),day_samlength,'_aid0001.tif']]);

    %      int16-> double
    data=double(data);
    
        % valid ranges
    data(data<-100 | data>16000)=NaN;
    
    %     real value=data*scale factor
    data=data.*0.0001;

    %% ====Reflectance 02 quality flag======
    vi_quality= imread([land_loc,num2str(year_map),'\',['MOD09Q1.006_sur_refl_qc_250m_doy', num2str(year_map),day_samlength,'_aid0001.tif']]); 
    
    %% ====Reflectance 04 data======
    data_reflect04= imread([land_loc,num2str(year_map),'\',['MOD09A1.006_sur_refl_b04_doy', num2str(year_map),day_samlength,'_aid0001.tif']]);
  
   %      int16-> double
    data_reflect04=double(data_reflect04);
    
      % valid ranges
       data_reflect04(data_reflect04<-100 | data_reflect04>16000)=NaN;
 
    %   real value=data*scale factor
    data_reflect04=data_reflect04.*0.0001;
    


        %% ====Reflectance 02 quality flag======
    vi_quality_reflect04= imread([land_loc,num2str(year_map),'\',['MOD09A1.006_sur_refl_qc_500m_doy', num2str(year_map),day_samlength,'_aid0001.tif']]); 
    
    %% current province
    
    for jj=1:31
        %jj
       
              province_crop_id=province_crop_id_2000{jj};
        current_province_id_reflect02=modis_evi_ndiv_crop_id{jj};
        current_province_id_reflect04=modis_refct04_crop_id{jj};
        reflet02_province_data=data(current_province_id_reflect02);
        reflet04_province_data=data_reflect04(current_province_id_reflect04);
        province_quality=double(vi_quality(current_province_id_reflect02));
         province_quality_reflect04=double(vi_quality_reflect04(current_province_id_reflect04));
        
        %% valid data
        modis_quality=ismember(province_quality, value_good_qualtiy);
%        valid_percent=length(find(modis_quality==1))/length(modis_quality);
%        valid_percent_all(ii,jj)=valid_percent;
%             aa=tabulate(province_quality);
%             bb=aa(aa(:,3)>0,:);
%             mm=sortrows(bb,-3);

        modis_quality_reflect04=ismember(province_quality_reflect04, value_good_qualtiy_reflect04);
%        valid_percent_reflectance04=length(find(modis_quality_reflect04==1))/length(modis_quality_reflect04);
%        valid_percent_all_reflect04(ii,jj)=valid_percent_reflectance04;
%               aa=tabulate(province_quality_reflect04);
%             bb=aa(aa(:,3)>0,:);
%             mm=sortrows(bb,-3);

 %% invalid data intepolation new
       %  reflect02
        invalid_data_id=find(modis_quality==0|isnan(reflet02_province_data)==1);
        valid_data_id=find(modis_quality==1&isnan(reflet02_province_data)==0);
        reflect02_province_data_intep=reflet02_province_data;
        
        reflect02_province_data_valid=reflet02_province_data(valid_data_id);
          id_valid_neareast=knnsearch([province_crop_id(valid_data_id,3),province_crop_id(valid_data_id,4)],...
            [province_crop_id(invalid_data_id,3),province_crop_id(invalid_data_id,4)]); %���ڽ���ֵ
        reflect02_province_data_intep(valid_data_id(id_valid_neareast))=reflect02_province_data_valid(id_valid_neareast);
        
        %  reflect04
         invalid_data_id=find(modis_quality_reflect04==0|isnan(reflet04_province_data)==1);
        valid_data_id=find(modis_quality_reflect04==1&isnan(reflet04_province_data)==0);
        reflect04_province_data_intep=reflet04_province_data;
   
         reflect04_province_data_valid=reflet04_province_data(valid_data_id);
          id_valid_neareast=knnsearch([province_crop_id(valid_data_id,3),province_crop_id(valid_data_id,4)],...
            [province_crop_id(invalid_data_id,3),province_crop_id(invalid_data_id,4)]); %���ڽ���ֵ
        reflect04_province_data_intep(valid_data_id(id_valid_neareast))=reflect04_province_data_valid(id_valid_neareast);
        
        %% invalid data intepolation
%         invalid_data_id=find(modis_quality==0|isnan(reflet02_province_data)==1);
%         valid_data_id=find(modis_quality==1&isnan(reflet02_province_data)==0);
%         reflect02_province_data_intep=reflet02_province_data;
%         reflect02_province_data_intep(invalid_data_id)=interp1(valid_data_id,reflet02_province_data(valid_data_id),invalid_data_id,'nereast','extrap') ;
%      
%         
%          invalid_data_id_reflect04=find(modis_quality_reflect04==0|isnan(reflet04_province_data)==1);
%         valid_data_id_reflect04=find(modis_quality_reflect04==1&isnan(reflet04_province_data)==0);
%         reflect04_province_data_intep=reflet04_province_data;
%         reflect04_province_data_intep(invalid_data_id_reflect04)=interp1(valid_data_id_reflect04,reflet04_province_data(valid_data_id_reflect04),invalid_data_id_reflect04,'nereast','extrap');
        
        %% delete and interp value higher than 15 new
         GI_data=reflect02_province_data_intep./reflect04_province_data_intep;
         invalid_data_id=find(GI_data>15);
        valid_data_id=find(GI_data<=15);
         GI_data_intep=GI_data;    
         
         GI_data_valid=GI_data(valid_data_id);
          id_valid_neareast=knnsearch([province_crop_id(valid_data_id,3),province_crop_id(valid_data_id,4)],...
            [province_crop_id(invalid_data_id,3),province_crop_id(invalid_data_id,4)]); %���ڽ���ֵ
         GI_data_intep(valid_data_id(id_valid_neareast))=GI_data_valid(id_valid_neareast);
         GI_data_all{jj}(:,ii)=GI_data_intep;
             %% delete and interp value higher than 15
%          GI_data=reflect02_province_data_intep./reflect04_province_data_intep;
%          invalid_GI_id=find(GI_data>15);
%         valid_GI_id=find(GI_data<=15);
%          GI_data_intep=GI_data;       
%         GI_data_intep(invalid_GI_id)=interp1(valid_GI_id,GI_data(valid_GI_id),invalid_GI_id,'nereast','extrap');      
%         GI_data_all{jj}(:,ii)=GI_data_intep;
    end
end

%% save result
output_fold='F:\Data_ZL\MODIS\';
 save ([output_fold,num2str(year_map),'\GI_data_all.mat'], 'GI_data_all','-v7.3');