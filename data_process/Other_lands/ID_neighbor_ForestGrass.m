

clc, clear

year_map=2000;
modis_data_local='F:\Data_ZL\MODIS\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
land_loc='F:\Data_ZL\IrrMap\';

% China_county_crop_aridity=geotiffread([land_loc,num2str(year_map),'\China_county_crop_aridity.tif']);
[data_lucc, Ref] = geotiffread([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor_base=geotiffinfo([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);

data_ForestGrass=geotiffread([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new2_ForestGrass.tif']);

province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

cop_nominize=cell(1,31);

%
ForestGrass_map=zeros(size(data_lucc));


neighbor_size=10000; % 50 km2
neighbor_temp=floor (sqrt(neighbor_size)/2); % Êµ¼Ê=29*29*0.25*0.25=52 km2
[m, n]=size(data_lucc);
   
    
%%
    for kk=1:31
        
        kk
        
        current_province=province_crop_id_2000{kk};
        
        
        for ii=1:length(current_province(:,1))
            
            if rem(ii,100000)==1
                ii
            end
            
            row_around=(current_province(ii,1)-neighbor_temp):(current_province(ii,1)+neighbor_temp);
            col_around=(current_province(ii,2)-neighbor_temp):(current_province(ii,2)+neighbor_temp);
            
            row_around=min(row_around,m);
            row_around=max(row_around,1);
            
            col_around=min(col_around,n);
            col_around=max(col_around,1);
            
            ForestGrass_map(row_around,col_around)=1;
            
        end
        
        
    end
    
ForestGrass_map(data_lucc>0)=0;
ForestGrass_map(data_ForestGrass==0)=0;
%%
output_local='F:\Data_ZL\IrrMap\';
geotiffwrite([output_local,num2str(year_map),'\2000new1_ForestGrass.tif'],ForestGrass_map,Ref, 'GeoKeyDirectoryTag', data_GeoInfor_base.GeoTIFFTags.GeoKeyDirectoryTag);

