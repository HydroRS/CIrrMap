% Codes used to obtain training samples
clc;clear

% data location
modis_data_local='F:\Data_ZL\MODIS\';
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
land_loc='F:\Data_ZL\IrrMap\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
% year for the land use map
year_map=2000;

%%  Data read
% read veg_used

EVI_threshod_IrrArea= geotiffread([land_loc,num2str(year_map),'\county_level\test08\EVI_sutability_threshold_IrrArea_opt.tif']);
NDVI_threshod_IrrArea= geotiffread([land_loc,num2str(year_map),'\county_level\test08\NDVI_sutability_threshold_IrrArea_opt.tif']);
GI_threshod_IrrArea= geotiffread([land_loc,num2str(year_map),'\county_level\test08\GI_sutability_threshold_IrrArea_opt.tif']);
%%
% read province crop Id
province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

% read province data
[data_crop, Ref] = geotiffread([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);

% read county data
county_area=xlsread([Cesus_IrrArea_data_local,num2str(year_map),'\County_area_merge.xlsx']);

County_crop_id_2000=load([ID_loc,num2str(year_map),'\County_crop_id_2000.mat'], 'County_crop_id_2000');
County_crop_id_2000=County_crop_id_2000.County_crop_id_2000;

% read spatial aridity data
China_county_crop_aridity=geotiffread([land_loc,num2str(year_map),'\China_county_crop_aridity.tif']);

% read irrigaiton census data (province)
[Cesus_IrrArea_data, province]=xlsread([Cesus_IrrArea_data_local,'2001-2019年水利统计年鉴.xlsx'], [num2str(year_map),'年']);
province_code=sortrows(Cesus_IrrArea_data(2:end,[1,2,5]),2);

%% initaite viarbles
% Veg_top1_IrrArea=ones(size(data_crop)).*255;

Veg_intersect_IrrArea=zeros(size(data_crop));
% Veg_IrrArea_county=[];

% Exact potential irrigaiton samples
for kk=1:31
    kk
    % province & county
    province_crop_id=province_crop_id_2000{kk};
    province_current=province_code(kk,1);
    current_provinc_county_Irr=county_area(county_area(:,1)==province_current,end);
    current_provinc_county_code=county_area(county_area(:,1)==province_current,end-1);
    
  
    for jj=1:length(current_provinc_county_Irr);
        jj
        
        county_in_province=County_crop_id_2000{jj,kk};
        idx = sub2ind(size(data_crop),province_crop_id(county_in_province,1),province_crop_id(county_in_province,2)); % row/con to index
        
         EVI_IrrArea_county=EVI_threshod_IrrArea(idx);
         NDVI_IrrArea_county=NDVI_threshod_IrrArea(idx);
         GI_IrrArea_county=GI_threshod_IrrArea(idx);
        
        %% ===================3  Veg indices============================
        
           EVI_Irr_id_all=county_in_province(EVI_IrrArea_county>0);
           EVI_NoneIrr_id_all=county_in_province(EVI_IrrArea_county==0);
           
             NDVI_Irr_id_all=county_in_province(NDVI_IrrArea_county>0);
          NDVI_NoneIrr_id_all=county_in_province(NDVI_IrrArea_county==0);
 
             GI_Irr_id_all=county_in_province(GI_IrrArea_county>0);
          GI_NoneIrr_id_all=county_in_province(GI_IrrArea_county==0);
        
        Veg_Irr_id_intersect = mintersect(EVI_Irr_id_all,NDVI_Irr_id_all,GI_Irr_id_all);
        Veg_NoneIrr_id_intersect = mintersect( EVI_NoneIrr_id_all,NDVI_NoneIrr_id_all,GI_NoneIrr_id_all);

%         Veg_IrrArea_county{jj,kk}=Veg_Irr_id_intersect;
%         Veg_IrrArea_county{jj+length(current_provinc_county_Irr),kk}=Veg_NoneIrr_id_intersect;
        
        idx = sub2ind(size(data_crop),province_crop_id(Veg_Irr_id_intersect,1),province_crop_id(Veg_Irr_id_intersect,2)); % row/con to index
        idx_none_irr = sub2ind(size(data_crop),province_crop_id(Veg_NoneIrr_id_intersect,1),province_crop_id(Veg_NoneIrr_id_intersect,2)); % row/con to index
        Veg_intersect_IrrArea(idx)=1;
        Veg_intersect_IrrArea(idx_none_irr)=2;
        
    end
end

%% save result
output_local='F:\Data_ZL\IrrMap\';
geotiffwrite([output_local,num2str(year_map),'\county_level\test08\Veg_intersect_IrrArea.tif'],Veg_intersect_IrrArea,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);

