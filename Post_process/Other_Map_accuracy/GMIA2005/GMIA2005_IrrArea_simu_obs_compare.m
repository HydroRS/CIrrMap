% ####################Performance Evaluation################
clc
clear;
year_map=2000;

land_loc='F:\Data_ZL\IrrMap\';
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';

% mapping_result_V3=load([land_loc,num2str(year_map),'\county_level\test07\mapping_result_V3.mat'], 'mapping_result_V3');
% mapping_result=mapping_result_V3.mapping_result_V3;

% read province data as the baseline map
% read province data
[data_crop, Ref] = geotiffread([land_loc,num2str(year_map),'\county_level\Other_IrrMap\gmia_china2005.tif']);
data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);

% read province crop Id
province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

% read county id in each province
County_crop_id_2000=load([ID_loc,num2str(year_map),'\County_crop_id_2000.mat'], 'County_crop_id_2000');
County_crop_id_2000=County_crop_id_2000.County_crop_id_2000;

% read province crop proportion
% proportion_province=load([land_loc, num2str(year_map),'\proportion_province.mat'], 'proportion_province');
% proportion_province=proportion_province.proportion_province;

% read county data
[county_area, infor]=xlsread([Cesus_IrrArea_data_local,num2str(year_map),'\County_area_merge.xlsx']);
zhu_county_area_all=xlsread([Cesus_IrrArea_data_local,num2str(year_map),'\County_area_original.xlsx']);
zhu_county_area=zhu_county_area_all(:,5);

% read irrigaiton census data (province)
[Cesus_IrrArea_data, province]=xlsread([Cesus_IrrArea_data_local,'2001-2019年水利统计年鉴.xlsx'], [num2str(year_map),'年']);
province_code=sortrows(Cesus_IrrArea_data(2:end,[1,2,5]),2); 

CIrrMap= geotiffread([land_loc,num2str(year_map),'\county_level\Other_IrrMap\gmia_china2005.tif']);


%% 

% sum Irr and NoneIrr area for each province
Irr_NonIrr_Area=[];
begin_time=1;
Irr_NonIrr_Area{1,1}='省ID';
Irr_NonIrr_Area{1,2}='省';
Irr_NonIrr_Area{1,3}='市';
Irr_NonIrr_Area{1,4}='区县';
Irr_NonIrr_Area{1,5}='区县ID';
Irr_NonIrr_Area{1,6}='统计灌溉面积';
Irr_NonIrr_Area{1,7}='模拟灌溉面积';
Irr_NonIrr_Area{1,8}='Zhu模拟非灌溉面积';
 
% mapping_result_class=cell(size(mapping_result));
Irr_map_China=double(zeros(size(data_crop)));

for ii=1:31
    ii
    
     province_current=province_code(ii,1);
     
    current_provinc_county_Irr=county_area(county_area(:,1)==province_current,end);
    
    county_number_current=county_area(county_area(:,1)==province_current,end-1);
    
    county_number_infor=infor(county_area(:,1)==province_current,:);
    
    county_number=length(current_provinc_county_Irr);
    
    current_province_crop_id=province_crop_id_2000{ii};
    
%     current_province_crop_proportion=proportion_province{ii};
      
    for kk=1:county_number
        kk
         
          zhu_county_area_current=sum(zhu_county_area(zhu_county_area_all(:,7)==county_number_current(kk)));
          
          crop_current_county=County_crop_id_2000{kk,ii};
           idx = sub2ind(size(data_crop),current_province_crop_id(crop_current_county,1),current_province_crop_id(crop_current_county,2)); % row/con to index
           
%             temp_province=mapping_result{kk,ii};
            temp_province=CIrrMap(idx);
            if isempty(temp_province)
                Irr_NonIrr_Area{kk+begin_time,1}=province_current;
                Irr_NonIrr_Area{kk+begin_time,2}=county_number_infor{kk,1};
                Irr_NonIrr_Area{kk+begin_time,3}=county_number_infor{kk,2};
                Irr_NonIrr_Area{kk+begin_time,4}=county_number_infor{kk,3};
                 Irr_NonIrr_Area{kk+begin_time,5}=county_number_current(kk);
                Irr_NonIrr_Area{kk+begin_time,6}=current_provinc_county_Irr(kk);
                Irr_NonIrr_Area{kk+begin_time,7}=0;
                Irr_NonIrr_Area{kk+begin_time,8}=zhu_county_area_current;  
              continue
            end
            temp_province(temp_province>0.5)=1;
            temp_province(temp_province<=0.5)=0;
       
%             mapping_result_class{kk,ii}=bb;
%             crop_current_county=County_crop_id_2000{kk,ii};
%            idx = sub2ind(size(data_crop),current_province_crop_id(crop_current_county,1),current_province_crop_id(crop_current_county,2)); % row/con to index
           crop_proportion_current_county=data_crop(idx);
           
             Irr_nonIrr_county=double(temp_province).*(crop_proportion_current_county/100); % 没有比例
             
%             idx = sub2ind(size(data_crop),current_province_crop_id(crop_current_county,1),current_province_crop_id(crop_current_county,2)); % row/con to index
            Irr_map_China(idx)=Irr_nonIrr_county;
            
            
             Irr_area=sum(Irr_nonIrr_county(Irr_nonIrr_county>0)).*250.*250/1e7;  % m2->1000ha
            if isempty(Irr_area)
                Irr_area=0;
            end
            
            Non_Irr_area=sum(crop_proportion_current_county(Irr_nonIrr_county==0)).*250.*250/1e7;  % m2->1000ha
                if isempty(Non_Irr_area)
                Non_Irr_area=0;
                end
            
                  Irr_NonIrr_Area{kk+begin_time,1}=province_current;
                Irr_NonIrr_Area{kk+begin_time,2}=county_number_infor{kk,1};
                Irr_NonIrr_Area{kk+begin_time,3}=county_number_infor{kk,2};
                Irr_NonIrr_Area{kk+begin_time,4}=county_number_infor{kk,3};
                 Irr_NonIrr_Area{kk+begin_time,5}=county_number_current(kk);
                Irr_NonIrr_Area{kk+begin_time,6}=current_provinc_county_Irr(kk);
                Irr_NonIrr_Area{kk+begin_time,7}=Irr_area;
                Irr_NonIrr_Area{kk+begin_time,8}=zhu_county_area_current;
                
    end
    begin_time=begin_time+county_number;
end

%% save results
xlswrite([land_loc,num2str(year_map),'\county_level\Other_IrrMap\GMIA2005_area_sim_obs_county_',num2str(year_map),'.xlsx'],Irr_NonIrr_Area(:,1:end-1));

%  geotiffwrite([land_loc,num2str(year_map),'\county_level\tes08\',num2str(year_map),'_Irr_map_county_China_final.tif'],Irr_map_China,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
