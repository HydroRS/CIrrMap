% Codes used to extract the location of crops in Land use data
clc;clear

% data location，
land_loc='F:\Data_ZL\MODIS\';
Location_Yangkun='F:\Data_ZL\国家青藏高原数据中心\中国区域高时空分辨率地面气象要素驱动数据集\Data_forcing_01dy_010deg\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
% year for the land use map
year_map=2000;

if year_map==2000
    start_day=60;
else
    start_day=1;
end



%% load albedo data
% Albedo_data_all_new=load([land_loc,num2str(year_map),'\Albedo_data_all_new.mat'], 'Albedo_data_all_new');
% Albedo_data_all_new=Albedo_data_all_new.Albedo_data_all_new;
% current_province_id_modis=modis_evi_ndiv_crop_id{1};
Albedo_data_all_new=[];
for kk=1:31
    kk
         albedo=load([land_loc,num2str(year_map),'\Albedo\',num2str(kk),'albedo.mat'], 'albedo');
        Albedo_data_all_new{kk}=albedo.albedo;
end
%% load cliamte location data
Yangkun_climate_2000_id=load([ID_loc,num2str(year_map),'\Yangkun_climate_2000_id.mat'], 'Yangkun_climate_2000_id');
Yangkun_climate_2000_id=Yangkun_climate_2000_id.Yangkun_climate_2000_id;


%% load Yangkun data
Yangkun_climate_privince_data=cell(31,1);

% !!!仅统计生长季节的结果，定义为3-10月
time_span=start_day:yeardays(year_map)-60;

albedo_time_span=start_day:5:yeardays(year_map);
T_last_min=cell(31,1);
T_last_max=cell(31,1);
for jj=1:length(time_span);
    jj
   
    rad_Yangkun=ncread([Location_Yangkun,'srad_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year_map),'01-',num2str(year_map),'12.nc'],'srad',[1 1,time_span(jj)],[700,400,1]); % unit:w/m2
    Temp_Yangkun=ncread([Location_Yangkun,'temp_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year_map),'01-',num2str(year_map),'12.nc'],'temp',[1 1,time_span(jj)],[700,400,1])-273.15; % unit:k->摄氏度
    Prec_Yangkun=ncread([Location_Yangkun,'prec_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year_map),'01-',num2str(year_map),'12.nc'],'prec',[1 1,time_span(jj)],[700,400,1])*24; % unit:mm/hour-->mm/day
    Shum_Yangkun=ncread([Location_Yangkun,'Shum_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year_map),'01-',num2str(year_map),'12.nc'],'shum',[1 1,time_span(jj)],[700,400,1]); % unit:Kg/kg, 比湿
    Pres_Yangkun=ncread([Location_Yangkun,'pres_ITPCAS-CMFD_V0106_B-01_01dy_010deg_',num2str(year_map),'01-',num2str(year_map),'12.nc'],'pres',[1 1,time_span(jj)],[700,400,1]); % unit:pa

    for ii=1:31 % provinces
        PCP=Prec_Yangkun(Yangkun_climate_2000_id{ii});
        T=Temp_Yangkun(Yangkun_climate_2000_id{ii});
        Rad=rad_Yangkun(Yangkun_climate_2000_id{ii});
        Hum=Shum_Yangkun(Yangkun_climate_2000_id{ii});
        Pres=Pres_Yangkun(Yangkun_climate_2000_id{ii});
        

        %=== PET estimtimation using Priestely and Taylor method====
        
        % alfa = 1.26; % 1.26 Priestley&Taylor,1972
        % alfa, PT coefficient,1
        % delta, slope of the saturated vapor pressure curve(kPa °C-1)
        % gamma, psychrometric constant, kPa °C-1
        % Rn, net radiation for the canopy (W · m/2)
        % G,  soil heat flux (W · m/2)
        % lamda, latent heat of vaporization (J kg-1)
        %T, air temperature, ℃
        gamma=0.066;
        RH=SH2RH(Hum, T, Pres);
        alfa=-0.014.*RH+2.33; 
        G=0;
        es   = 0.6108 .* exp(17.27 .* T ./ (T + 237.3)); % saturation vapor pressure, kPa
        delta = 4098 .* es ./ (T + 237.3) .^ 2;
        lamda=2.501e6-2361.*T;
        nerest_albedo=knnsearch(albedo_time_span', jj); % albedo is exatracted per five day
        Rn = Rn_calculation( Albedo_data_all_new{ii}(:,nerest_albedo), Rad,  T);
        PET=PT_PET( alfa, delta,gamma, Rn, G, lamda).*24.*3600; % kg/s/m2->mm/day
        %=== =========================================
        
        if jj==1
            T_last_min{ii}=T;
            T_last_max{ii}=T;
            Yangkun_climate_privince_data{ii}=zeros(length(Yangkun_climate_2000_id{ii}),6); % 6 climate variables
        end
        
          % max and min Temperature
        T_max=max(T,  T_last_max{ii});
        T_min=min(T, T_last_min{ii});
        
        % Accumulated sum of climate variables
        Yangkun_climate_privince_data{ii}(:,1:6)=Yangkun_climate_privince_data{ii}(:,1:6)+ [PCP, T, Rad, Hum, Pres, PET];
        
        % save current max and min Temp value
        T_last_max{ii}=T_max;
        T_last_min{ii}=T_min;
        
        % 8 climate variables now 
        Yangkun_climate_privince_data{ii}(:,7:8)=[T_max,T_min];
   
    end
    
end

%% extract mean values of climate varibles
Yangkun_climate_2000_mean=cell(31,1);
for jj=1:31
    jj
    Yangkun_climate_2000_mean{jj}=Yangkun_climate_privince_data{jj};
    
    % T, Rad, Hum, Press is the mean value， while p and PET is the
    % accumulated value 
    Yangkun_climate_2000_mean{jj}(:,2:5)=Yangkun_climate_privince_data{jj}(:,2:5)./length(time_span); 
    
    % aridity, P/PET
    % PCP, T, Rad, Hum, Pres, PET,T_max,T_min, aridity
    Yangkun_climate_2000_mean{jj}(:,9)=Yangkun_climate_privince_data{jj}(:,1)./Yangkun_climate_privince_data{jj}(:,6);
end


%% save result
 output_fold='F:\Data_ZL\MODIS\';
save ([output_fold,num2str(year_map),'\Yangkun_climate_2000_mean.mat'], 'Yangkun_climate_2000_mean','-v7.3');
