% Codes used to extract the location of crops in Land use data
clc;clear

% data location，
Location_Yangkun='F:\Data_ZL\国家青藏高原数据中心\中国区域高时空分辨率地面气象要素驱动数据集\Data_forcing_01dy_010deg\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';

% year for the land use map
year_map=2000;


%% load crop location data
province_crop_id_2000=load([ID_loc,num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

%% load Yangkun data
% rad_Yangkun=ncread([Location_Yangkun,'srad_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year_map),'01-',num2str(year_map),'12.nc'],'srad',[1 1,jj],[700,400,1]); % unit:w/m2
% Temp_Yangkun=ncread([Location_Yangkun,'temp_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year),'01-',num2str(year),'12.nc'],'temp',[1 1,jj],[700,400,1])-273.15; % unit:k->摄氏度
% Prec_Yangkun=ncread([Location_Yangkun,'prec_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year),'01-',num2str(year),'12.nc'],'prec',[1 1,jj],[700,400,1])*24; % unit:mm/hour-->mm/day

% lon_Yangkun=ncread([Location_Yangkun,'srad_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year_map),'01-',num2str(year_map),'12.nc'],'lon');
% lat_Yangkun=ncread([Location_Yangkun,'srad_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year_map),'01-',num2str(year_map),'12.nc'],'lat');

%%
Yangkun_climate_2000_id=cell(1,31);
for kk=1:31
    
    kk
    current_province_id=province_crop_id_2000{kk};
    if kk==1
        x=ncread([Location_Yangkun,'srad_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year_map),'01-',num2str(year_map),'12.nc'],'lon');
        y=ncread([Location_Yangkun,'srad_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year_map),'01-',num2str(year_map),'12.nc'],'lat');
        
        climate_data=ncread([Location_Yangkun,'srad_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year_map),'01-',num2str(year_map),'12.nc'],'srad',[1 1,yeardays(year_map)],[700,400,1]);
%         [row_data, col_data]=size(climate_data);
%         temp_data=zeros(row_data, col_data);
        [row, col]=find(zeros(size(climate_data))<10e8);
        climate_location= [y(col), x(row)]; % lat, lon
        
    end

    
    % polygon of current province
    min_lat=min(current_province_id(:,3));
    max_lat=max(current_province_id(:,3));
    min_lon=min(current_province_id(:,4));
    max_lon=max(current_province_id(:,4));
    
    % find the polygon close to current province
    current_climate_location=find(climate_location(:,1)>=min_lat&climate_location(:,1)<=max_lat&climate_location(:,2)>=min_lon&climate_location(:,2)<=max_lon);
    current_climate_row_col=[current_climate_location, climate_location(current_climate_location,:)];
    
    % find the crop location in extracted moidis polygon
    Nereast_crop_in_climate= knnsearch(current_climate_row_col(:,2:3),current_province_id(:,3:4));
    
    % find the crop location in original moidis polygon
    current_province_climate=current_climate_row_col(Nereast_crop_in_climate(:,1));
    
    Yangkun_climate_2000_id{kk}=current_province_climate;
    
end

%%
save([ID_loc,num2str(year_map),'\Yangkun_climate_2000_id.mat'],'Yangkun_climate_2000_id','-v7.3');