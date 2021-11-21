% Codes used to extract the location of crops in Land use data
clc;clear

% data location，2000.tif:30m, 2000new.tif:30m
land_loc='F:\Data_ZL\IrrMap\Census\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
crop_250='F:\Data_ZL\IrrMap\2000\bak\';

% year for the land use map
year_map=2000;


%% read 250m crop Id
[crop_data, Ref] =geotiffread([crop_250,'\2000new.tif']);
data_GeoInfor_base=geotiffinfo([crop_250,'\2000new.tif']);
[IRR_row,IRR_colunm]=find(abs(crop_data)<255); 

% obtaining coordinates of the projected system （pix2map)
[x,y] = pix2map(data_GeoInfor_base.RefMatrix,IRR_row, IRR_colunm);

% obtaining coordinates of the geographical system
[lat,lon] = projinv(data_GeoInfor_base ,x, y);  %将投影坐标转换为地理坐标


%% read 30m crop 
data=imread([crop_250,'2000ge.tif']);
data_GeoInfor=geotiffinfo([crop_250,'2000ge.tif']);

[m,n]=size(data);
% lat，x1; lon，y2
[x1,y1]= pix2latlon(data_GeoInfor.RefMatrix, (1:m)',ones(m,1)); % 行
[x2,y2]= pix2latlon(data_GeoInfor.RefMatrix, ones(n,1),(1:n)'); % 列

% 对250m crop的每个点，估算其含有的30m crop面积
   Nereast_Irr30_in_Irr250m_lat= knnsearch(x1,lat);
    Nereast_Irr30_in_Irr250m_lon= knnsearch(y2,lon);

%% 
result=zeros(length(Nereast_Irr30_in_Irr250m_lat),1);
   for kk=1:length(Nereast_Irr30_in_Irr250m_lat)
      if rem(kk,1000000)==0
          kk
      end
        current_id_lat=Nereast_Irr30_in_Irr250m_lat(kk);
          current_id_lon=Nereast_Irr30_in_Irr250m_lon(kk);
          
          % 30 m for each grid
          lat_around=current_id_lat-4:current_id_lat+4;
          lon_around=current_id_lon-4:current_id_lon+4;
          
          data_point=data(lat_around,lon_around);
          data_point([1,2,8,9,10,18,64,72,73,74,80,81])=0;
           
         result(kk)=min(length(data_point(data_point>20&data_point<40))/69,1);
         
   end
   
%% 保存所有被草地和林地覆盖的网格
output_local='F:\Data_ZL\IrrMap\';
simu_250m=zeros(size(crop_data));
idx = sub2ind(size(crop_data),IRR_row,IRR_colunm); % row/con to index
simu_250m(idx)=result;
geotiffwrite([output_local,num2str(year_map),'\2000new3_ForestGrass.tif'],simu_250m,Ref, 'GeoKeyDirectoryTag', data_GeoInfor_base.GeoTIFFTags.GeoKeyDirectoryTag);
%% 仅保存完全被草地和林地覆盖的网格
% simu_250m=zeros(size(crop_data));
% result(result<1)=0; 
% simu_250m(idx)=result;
% geotiffwrite([output_local,num2str(year_map),'\2000new2_ForestGrass.tif'],simu_250m,Ref, 'GeoKeyDirectoryTag', data_GeoInfor_base.GeoTIFFTags.GeoKeyDirectoryTag);
