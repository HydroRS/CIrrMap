% Codes used to extract the location of crops in Land use data
clc;clear

% data location，2000.tif:30m, 2000new.tif:250m
land_loc='F:\Data_ZL\IrrMap\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';

% year for the land use map
year_map=2000;


%% read 1km baseline
[data_base, Ref] =geotiffread([land_loc,num2str(year_map),'\county_level\test08\base_map_1km1.tif']);
data_GeoInfor_base=geotiffinfo([land_loc,num2str(year_map),'\county_level\test08\base_map_1km1.tif']);
[IRR_row,IRR_colunm]=find(data_base>=0); % calculation for each province

% obtaining coordinates of the projected system （pix2map)
[x,y] = pix2map(data_GeoInfor_base.RefMatrix,IRR_row, IRR_colunm);

% obtaining coordinates of the geographical system
[lat,lon] = projinv(data_GeoInfor_base ,x, y);  %将投影坐标转换为地理坐标
%% read 250m results
data=imread([land_loc,num2str(year_map),'\county_level\test08\CIrrMap250ge.tif']);
data_GeoInfor=geotiffinfo([land_loc,num2str(year_map),'\county_level\test08\CIrrMap250ge.tif']);

[m,n]=size(data);
% lat，x1; lon，y2
[x1,y1]= pix2latlon(data_GeoInfor.RefMatrix, (1:m)',ones(m,1)); % 行
[x2,y2]= pix2latlon(data_GeoInfor.RefMatrix, ones(n,1),(1:n)'); % 列

   Nereast_Irr250_in_Irr1km_lat= knnsearch(x1,lat);
    Nereast_Irr250_in_Irr1km_lon= knnsearch(y2,lon);

%% 
result=zeros(length(Nereast_Irr250_in_Irr1km_lat),1);
simu_1km=zeros(size(data_base));
   for kk=1:length(Nereast_Irr250_in_Irr1km_lat)
      if rem(kk,5000)==0
          kk
      end
        current_id_lat=Nereast_Irr250_in_Irr1km_lat(kk);
          current_id_lon=Nereast_Irr250_in_Irr1km_lon(kk);
           lat_around=current_id_lat-2:current_id_lat+2;
          lon_around=current_id_lon-2:current_id_lon+2;
          data_point=data(lat_around,lon_around);
          
          center_lat=x1(current_id_lat);
          center_lat_lon=y2(current_id_lon);
          
          origin_center_lat=lat(kk);
          origin_center_lon=lon(kk);
          
          %右上角
          if origin_center_lat>=center_lat&&origin_center_lon>=center_lat_lon
          data_point_nereast=data_point(1:end-1,2:end);
          % 右下角
          elseif origin_center_lat>=center_lat&&origin_center_lon<=center_lat_lon
              data_point_nereast=data_point(2:end,2:end);
              %左上角
          elseif origin_center_lat<center_lat&&origin_center_lon>=center_lat_lon
              data_point_nereast=data_point(1:end-1,1:end-1);
                %左下角
          else
               data_point_nereast=data_point(2:end,1:end-1);
          end
          
          result(kk)=sum(sum(data_point_nereast))*0.25*0.25; %unit km2
   end

   %%
   idx = sub2ind(size(data_base),IRR_row,IRR_colunm); % row/con to index
simu_1km(idx)=result;
output_local='F:\Data_ZL\IrrMap\';
geotiffwrite([output_local,num2str(year_map),'\county_level\test08\2000_Irr_map_county_China_final_post2_1km.tif'],simu_1km,Ref, 'GeoKeyDirectoryTag', data_GeoInfor_base.GeoTIFFTags.GeoKeyDirectoryTag);


