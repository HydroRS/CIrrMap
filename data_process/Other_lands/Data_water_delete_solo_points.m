% Codes used to extract the location of crops in Land use data
clc;clear

% data location£¬2000.tif:30m, 2000new.tif:30m
land_loc='F:\Data_ZL\IrrMap\Envrioment\';

% year for the land use map
year_map=2000;
[water_data, Ref] =geotiffread([land_loc,'\water_rec1.tif']);
data_GeoInfor_base=geotiffinfo([land_loc,'\water_rec1.tif']);
[IRR_row,IRR_colunm]=find(water_data==1); 
water_data_new=water_data;
[m,n]=size(water_data);

%% read 250m crop Id
   for kk=1:length(IRR_row)
      if rem(kk,1000000)==0
          kk
      end
          current_id_lat=IRR_row(kk);
          current_id_lon=IRR_colunm(kk);
          
       
          lat_around=current_id_lat-10:current_id_lat+10;
          lat_around(lat_around>m)=m;
           lat_around(lat_around<1)=1;
          
          lon_around=current_id_lon-10:current_id_lon+10;
           lon_around(lon_around>n)=n;
           lon_around(lon_around<1)=1;
          
          data_point=water_data(lat_around,lon_around);
           
        if sum(sum(data_point))<10
            water_data_new(lat_around,lon_around)=0;
        end  
   end

%%
geotiffwrite([land_loc,'\water_data_new.tif'],water_data_new,Ref, 'GeoKeyDirectoryTag', data_GeoInfor_base.GeoTIFFTags.GeoKeyDirectoryTag);
