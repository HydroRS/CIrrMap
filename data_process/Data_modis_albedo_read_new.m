% Codes used to extract the location of crops in Land use data
clc;clear

% data location，
land_loc='F:\Data_ZL\MODIS\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';

% year for the land use map
year_map=2000;

if year_map==2000
else
    start_day=1;
end



%% quality look-up table (albdeo)
%   0 = processed, good quality (full BRDF inversions)
%   1 = processed, see other QA (magnitude BRDF inversions)
value_good_qualtiy_albedo=[0;1]; 


%% load albedo location in modis data, which is same to albedo
modis_refct04_crop_id=load([ID_loc,num2str(year_map),'\modis_refct04_crop_id.mat'], 'modis_refct04_crop_id');
modis_refct04_crop_id=modis_refct04_crop_id.modis_refct04_crop_id;

 start_day=60; % 55-59,nodata for the entire spatial domain

dayofyear=start_day:5:yeardays(year_map);

Albedo_data_all=[];

for ii=1:length(dayofyear)
    
    day_samlength=num2str(dayofyear(ii),'%03d');
    
['MCD43A3.006_Albedo_WSA_shortwave_doy', num2str(year_map),day_samlength,'_aid0001.tif']
        
    
    %% ====Albedo data======
    data_albedo= imread([land_loc,num2str(year_map),'\Albedo\',['MCD43A3.006_Albedo_WSA_shortwave_doy', num2str(year_map),day_samlength,'_aid0001.tif']]);

    %      int16-> double
    data_albedo=double(data_albedo);
        % valid ranges
    data_albedo(data_albedo<0 | data_albedo>32766)=NaN;
    %     real value=data*scale factor
    data_albedo=data_albedo.*0.001;
    
    % all data is zero, means no valid data at all
    if max(max(data_albedo))==0
        data_albedo(:,:)=NaN;
    end

        %% ====Albedo quality flag======
    vi_quality_albedo= imread([land_loc,num2str(year_map),'\Albedo\',['MCD43A3.006_BRDF_Albedo_Band_Mandatory_Quality_shortwave_doy', num2str(year_map),day_samlength,'_aid0001.tif']]); 
    
    %% current province
    
    for jj=1:31
       % jj

         Albedo_data_all{jj}(:,ii)=data_albedo(modis_refct04_crop_id{jj});
   
    end
  
end
clear vi_quality_albedo
clear modis_refct04_crop_id
clear data_albedo

%% 2D interpolation
for uu=1:31
    uu
    
    % 用divide是因为数据太大，二维插值内存不够。我们就拆为几部分
%     temp_data_province=Albedo_data_all{uu};
    %     Albedo_data_all_new{uu}=[];
    %     data_divde=[1:10000:length(temp_data_province)];
    %
    %
    %     for hh=1:length(data_divde)
    %         hh
    %         if hh==length(data_divde)
    %          temp_divide=temp_data_province(data_divde(hh):length(temp_data_province),:);
    %         else
    %         temp_divide=temp_data_province(data_divde(hh):(data_divde(hh+1)-1),:);
    %         end
    %         [cc, dd]=find(isnan(temp_divide)==0);
    %         kk=find(isnan(temp_divide)==0);
    %         [ee,ff]=find(zeros(size(temp_divide))<100);
    %         Albedo_data_all_new{uu}(data_divde(hh):(data_divde(hh+1)-1),:)=reshape(griddata(cc,dd,temp_divide(kk),ee,ff, 'nearest'),size(temp_divide));
    %
    %     end
    
    
  albedo=Albedo_data_all{uu};
    for hh=1:length(albedo)
        
         if rem(hh,100000)==0
          hh
         end
   
        current_point=albedo(hh,:);
        invalid_id=find(isnan(current_point)==1);
        valid_id=find(isnan(current_point)==0);
        
        % 至少有5个有效值
        if length(valid_id)<6;
            albedo(hh,:)=albedo(hh-1,:);
            continue
        end
        
%         current_point_interp=current_point;
        current_point(invalid_id)=interp1(valid_id,current_point(valid_id),invalid_id,'linear','extrap');
       albedo(hh,:)=current_point;
    end
    
    save ([land_loc,num2str(year_map),'\Albedo\',num2str(uu),'albedo.mat'], 'albedo','-v7.3');
%     Albedo_data_all_new{uu}=data_intep_all;
end

%% save result
%  output_fold='F:\Data_ZL\MODIS\';
%  save ([output_fold,num2str(year_map),'\Albedo_data_all_new.mat'], 'Albedo_data_all_new','-v7.3');