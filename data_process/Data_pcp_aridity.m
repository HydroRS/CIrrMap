
clc, clear
year_map=2000;
modis_data_local='F:\Data_ZL\MODIS\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
land_loc='F:\Data_ZL\IrrMap\';


%%
% China_county_crop_aridity=geotiffread([land_loc,num2str(year_map),'\China_county_crop_aridity.tif']);
[data_lucc, Ref] = geotiffread([land_loc,num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor=geotiffinfo([land_loc,num2str(year_map),'\',num2str(year_map),'new1.tif']);

Yangkun_climate_2000_mean=load([modis_data_local,num2str(year_map),...
    '\Yangkun_climate_2000_mean.mat'], 'Yangkun_climate_2000_mean');
Yangkun_climate_2000_mean=Yangkun_climate_2000_mean.Yangkun_climate_2000_mean;

delta_pcp_ET=load([modis_data_local,num2str(year_map),...
    '\delta_pcp_ET.mat'], 'delta_pcp_ET');
delta_pcp_ET=delta_pcp_ET.delta_pcp_ET;

province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;
%%
pcp_map=zeros(size(data_lucc));
ET_map=zeros(size(data_lucc));
aridity_map=zeros(size(data_lucc));

    
    for hh=1:31
        hh
        
        province_crop_id=province_crop_id_2000{hh};
        idx = sub2ind(size(data_lucc),province_crop_id(:,1),province_crop_id(:,2)); % row/con to index
        pcp_map(idx)=Yangkun_climate_2000_mean{hh}(:,1);
        ET_map(idx)=delta_pcp_ET{hh}(:,1);
        aridity_map(idx)=Yangkun_climate_2000_mean{hh}(:,end);
        
    end
    
%%
output_local='F:\Data_ZL\IrrMap\';
 geotiffwrite([output_local,num2str(year_map),'\county_level\test03\pcp_map.tif'],pcp_map,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
 geotiffwrite([output_local,num2str(year_map),'\county_level\test03\ET_map.tif'],ET_map,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
  geotiffwrite([output_local,num2str(year_map),'\county_level\test03\aridity_map.tif'],aridity_map,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);