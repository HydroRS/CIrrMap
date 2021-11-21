% Codes used to extract the location of crops in Land use data
clc;clear

% data location£¬2000.tif:30m, 2000new.tif:30m
land_loc='F:\Data_ZL\IrrMap\2000\county_level\test08\';
crop_loc='F:\Data_ZL\IrrMap\2000\';

% year for the land use map
year_map=2000;
[IrrMap_data, Ref] =geotiffread([land_loc,'\2000_Irr_map_county_China_final.tif']);
CropMap_data =geotiffread([crop_loc,'\2000new1.tif']);
data_GeoInfor_base=geotiffinfo([land_loc,'\2000_Irr_map_county_China_final.tif']);
[IRR_row,IRR_colunm]=find(IrrMap_data>0); 
IrrMap_data_new=IrrMap_data;
[m,n]=size(IrrMap_data);

%% read 250m crop Id
   for kk=1:length(IRR_row)
      if rem(kk,1000000)==0
          kk
      end
          current_id_lat=IRR_row(kk);
          current_id_lon=IRR_colunm(kk);
          
       % 5¡Á5´°¿Ú
          lat_around=current_id_lat-3:current_id_lat+3;
          lat_around(lat_around>m)=m;
           lat_around(lat_around<1)=1;
          
          lon_around=current_id_lon-3:current_id_lon+3;
           lon_around(lon_around>n)=n;
           lon_around(lon_around<1)=1;
          
          data_point=IrrMap_data(lat_around,lon_around);
          data_point(data_point>0)=1;
           
        if sum(sum(data_point))<=2
            IrrMap_data_new(current_id_lat,current_id_lon)=0;
        end 
        if sum(sum(data_point))>=47
            IrrMap_data_new(lat_around,lon_around)=CropMap_data(lat_around,lon_around);
        end  
        
   end



%%
geotiffwrite([land_loc,'\2000_Irr_map_county_China_final_post2.tif'],IrrMap_data_new,Ref, 'GeoKeyDirectoryTag', data_GeoInfor_base.GeoTIFFTags.GeoKeyDirectoryTag);
