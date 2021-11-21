% https://www.hydroshare.org/resource/9f981ae4e68b4f529cdd7a5c9013e27e/
clc;clear

% data location£¬
land_loc='F:\Data_ZL\MODIS\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
SM_loc='F:\Data_ZL\IrrMap\Envrioment\';
% year for the land use map
year_map=2000;


%% load crop location data
province_crop_id_2000=load([ID_loc,num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

SM_crop_id=cell(1,31);
for kk=1:31
    
    kk
    current_province_id=province_crop_id_2000{kk};
    if kk==1
        data=imread([SM_loc,'predicted_sm_global_15km_2000.tif']);
        data_GeoInfor=geotiffinfo([SM_loc,'predicted_sm_global_15km_2000.tif']);
        
        [row, col]=find(zeros(size(data))<10e8);
        [x,y] = pix2latlon(data_GeoInfor.RefMatrix, row, col);
        SM_location=[x,y] ;
        
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
    current_SM_location=find(SM_location(:,1)>=min_lat&SM_location(:,1)<=max_lat&SM_location(:,2)>=min_lon&SM_location(:,2)<=max_lon);
    current_SM_row_col=[current_SM_location, SM_location(current_SM_location,:)];
    
    % find the crop location in extracted moidis polygon
    Nereast_crop_in_SM= knnsearch(current_SM_row_col(:,2:3),current_province_id(:,3:4));
    
    % find the crop location in original moidis polygon
    current_province_SM=current_SM_row_col(Nereast_crop_in_SM(:,1));
    
    SM_crop_id{kk}=current_province_SM;
    
end

%%
save([ID_loc,num2str(year_map),'\SM_crop_id.mat'],'SM_crop_id','-v7.3');
