clc, clear

year_map=2000;
modis_data_local='F:\Data_ZL\MODIS\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
land_loc='F:\Data_ZL\IrrMap\';

province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

County_crop_id_2000=load([ID_loc,num2str(year_map),'\County_crop_id_2000.mat'], 'County_crop_id_2000');
County_crop_id_2000=County_crop_id_2000.County_crop_id_2000;


[data_crop, Ref] = geotiffread([land_loc,num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor=geotiffinfo([land_loc,num2str(year_map),'\',num2str(year_map),'new1.tif']);

county_mean_aridity=data_crop;

% read aridity
Yangkun_climate_2000_mean=load([modis_data_local,num2str(year_map),'\Yangkun_climate_2000_mean.mat'], 'Yangkun_climate_2000_mean');
Yangkun_climate_2000_mean=Yangkun_climate_2000_mean.Yangkun_climate_2000_mean;
%%

for kk=1:31
    kk
    province_crop_id=province_crop_id_2000{kk};
    
        aridty_province=Yangkun_climate_2000_mean{kk}(:,end);
        aridty_province(aridty_province>5)=nan;
       invalid_data_id=find(isnan(aridty_province)==1);
    if length(invalid_data_id)>=1
        valid_data_id=find(isnan(aridty_province)==0);
        aridty_province(invalid_data_id)=interp1(valid_data_id,aridty_province(valid_data_id),invalid_data_id,'neareast','extrap') ;
    end
    
%     [IRR_row_province,IRR_colunm_province]=find(data_province==kk); % calculation for each province
    
%     aridty_mean=mean(aridty_province);


    idx = sub2ind(size(data_crop),province_crop_id(:,1),province_crop_id(:,2)); % row/con to index
       data_crop(idx)=aridty_province;
       
      
       for jj =1:length(County_crop_id_2000)
         county_id=County_crop_id_2000{jj, kk};
         if isempty(county_id)
             continue
         else
             county_temp=mean(aridty_province(county_id));
                 idx_county = sub2ind(size(county_mean_aridity),province_crop_id(county_id,1),province_crop_id(county_id,2)); % row/con to index
              county_mean_aridity(idx_county)=county_temp;
             
         end
   
       end
end

geotiffwrite([land_loc,num2str(year_map),'\China_crop_aridity.tif'],data_crop,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite([land_loc,num2str(year_map),'\China_county_crop_aridity.tif'],county_mean_aridity,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
