% Codes used to extract the location of ForestGrasss in Land use data
clc;clear

% data location£¬
land_loc='F:\Data_ZL\MODIS\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
% year for the land use map
year_map=2000;


%% load ForestGrass location data
province_ForestGrass_id_2000=load([ID_loc,num2str(year_map),'\province_ForestGrass_id_2000.mat'], 'province_ForestGrass_id_2000');
province_ForestGrass_id_2000=province_ForestGrass_id_2000.province_ForestGrass_id_2000;

modis_evi_ndiv_ForestGrass_id=cell(1,31);
for kk=1:31
    
    kk
    current_province_id=province_ForestGrass_id_2000{kk};
    if kk==1
        data=imread([land_loc,num2str(year_map),'\',['MOD13Q1.006__250m_16_days_EVI_doy', num2str(year_map),'049','_aid0001.tif']]);
        data_GeoInfor=geotiffinfo([land_loc,num2str(year_map),'\',['MOD13Q1.006__250m_16_days_EVI_doy', num2str(year_map),'049','_aid0001.tif']]);
        
%            data=imread([land_loc,num2str(year_map),'\',['MOD09Q1.006_sur_refl_b02_doy', num2str(year_map),'049','_aid0001.tif']]);
%         data_GeoInfor=geotiffinfo([land_loc,num2str(year_map),'\',['MOD09Q1.006_sur_refl_b02_doy', num2str(year_map),'049','_aid0001.tif']]);
        
        [row, col]=find(zeros(size(data))<10e8);
        [x,y] = pix2latlon(data_GeoInfor.RefMatrix, row, col);
        modis_location=[x,y] ;
        
        clear x;
        clear y;
        clear row;
        clear col;
        clear data;
    end

    % polygon of current province
    min_lat=min(current_province_id(:,3));
    max_lat=max(current_province_id(:,3));
    min_lon=min(current_province_id(:,4));
    max_lon=max(current_province_id(:,4));
    
    % find the polygon close to current province
    current_modis_location=find(modis_location(:,1)>=min_lat&modis_location(:,1)<=max_lat&modis_location(:,2)>=min_lon&modis_location(:,2)<=max_lon);
    current_modis_row_col=[current_modis_location, modis_location(current_modis_location,:)];
    
    % find the ForestGrass location in extracted moidis polygon
    Nereast_ForestGrass_in_modis= knnsearch(current_modis_row_col(:,2:3),current_province_id(:,3:4));
    
    % find the ForestGrass location in original moidis polygon
    current_province_modis=current_modis_row_col(Nereast_ForestGrass_in_modis(:,1));
    
    modis_evi_ndiv_ForestGrass_id{kk}=current_province_modis;
    
end

%%
save([ID_loc,num2str(year_map),'\modis_evi_ndiv_ForestGrass_id.mat'],'modis_evi_ndiv_ForestGrass_id','-v7.3');
