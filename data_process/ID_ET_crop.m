% https://www.hydroshare.org/resource/9f981ae4e68b4f529cdd7a5c9013e27e/
clc;clear

% data location£¬
land_loc='F:\Data_ZL\MODIS\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
ET_loc='F:\Data_ZL\IrrMap\Envrioment\';
% year for the land use map
year_map=2000;


%% load crop location data
province_crop_id_2000=load([ID_loc,num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

Latitude=load([ET_loc,num2str(year_map),'\Latitude.mat'], 'Latitude');
Latitude=Latitude.Latitude;

Longitude=load([ET_loc,num2str(year_map),'\Longitude.mat'], 'Longitude');
Longitude=Longitude.Longitude;

ET_location=[Latitude(:),Longitude(:)];

%%
ET_id=cell(1,31);
for kk=1:31
    
    kk
    current_province_id=province_crop_id_2000{kk};
  

    % polygon of current province
    min_lat=min(current_province_id(:,3));
    max_lat=max(current_province_id(:,3));
    min_lon=min(current_province_id(:,4));
    max_lon=max(current_province_id(:,4));
    
    % find the polygon close to current province
    current_ET_location=find(ET_location(:,1)>=min_lat&ET_location(:,1)<=max_lat&ET_location(:,2)>=min_lon&ET_location(:,2)<=max_lon);
    current_ET_row_col=[current_ET_location, ET_location(current_ET_location,:)];
    
    % find the crop location in extracted moidis polygon
    Nereast_crop_in_ET= knnsearch(current_ET_row_col(:,2:3),current_province_id(:,3:4));
    
    % find the crop location in original moidis polygon
    current_province_ET=current_ET_row_col(Nereast_crop_in_ET(:,1));
    
    ET_id{kk}=current_province_ET;
    
end

%%
save([ID_loc,num2str(year_map),'\ET_id.mat'],'ET_id','-v7.3');
