% ####################Performance Evaluation################
clc
clear;
year_map=2000;

modis_data_local='F:\Data_ZL\MODIS\';
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
land_loc='F:\Data_ZL\IrrMap\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
% year for the land use map
year_map=2000;
NCP=[1,2,10,12,15,23];
%%  read dem and slope, distance to water body
data_waterdist=double(imread([land_loc,'Envrioment\waterdist250f.tif'])); %单位m
data_waterdist(data_waterdist==-32768)=nan;

data_dem=double(imread([land_loc,'Envrioment\dem250.tif']));
data_dem(data_dem==-32768)=nan;

data_slope=double(imread([land_loc,'Envrioment\slope250.tif'])); %单位 %
data_slope(data_slope<0)=nan; %单位 %

[data_province, Ref] = geotiffread([land_loc,'\',num2str(year_map),'\province_',num2str(year_map),'.tif']);


%% read Irr maps
file_names={'2000_Irr_map_county_China_final_post2','EVI-Map.tif','NDVI-Map.tif','GI-Map.tif','zhu_map2000.tif','gima2000.tif', 'Meier2005.tif'};
dem_proportion_all=zeros(7,4);
slope_proportion_all=zeros(7,4);
watedist_proportion_all=zeros(7,4);
for jj=1:7
    
     file_names{jj}
     
    if jj==1
        CIrrMap = geotiffread([land_loc,num2str(year_map),'\county_level\test08\2000_Irr_map_county_China_final_post2.tif']);
    else
        CIrrMap= geotiffread(['F:\Data_ZL\IrrMap\2000\county_level\Other_IrrMap\', file_names{jj}]);
    end
    
    %F:\Data_ZL\IrrMap\2000\county_level\Other_IrrMap
    %% Zhang-map
    China_Irr_dem=[];
    China_Irr_slope=[];
    China_Irr_watedist=[];
    for kk=1:31
        kk
        if ismember(NCP,kk)==1
            continue
        else
            id01=find(data_province==kk);
            province_Irr=CIrrMap(id01);
            province_dem=data_dem(id01);
            province_slope=data_slope(id01);
            province_watedist=data_waterdist(id01);
            
            if jj==5
                 id02=find(province_Irr>5);
            else
                 id02=find(province_Irr>0);
            end
            
            province_Irr_dem=province_dem(id02);
            China_Irr_dem=[China_Irr_dem;province_Irr_dem];
            China_Irr_slope=[China_Irr_slope;province_slope(id02)];
            China_Irr_watedist=[China_Irr_watedist;province_watedist(id02)];
        end
    end
    
    % dem
    divide=[100,500,900];
    dem_proportion=zeros(1,4);
    for kk=1:4
        if kk==1
            temp=length(find(China_Irr_dem<=divide(kk)))/length(China_Irr_dem);
            dem_proportion(kk)=temp;
        elseif kk==4
            temp=length(find(China_Irr_dem>divide(kk-1)))/length(China_Irr_dem);
            dem_proportion(kk)=temp;
        else
            temp=length(find(China_Irr_dem>divide(kk-1)&China_Irr_dem<=divide(kk)))/length(China_Irr_dem);
            dem_proportion(kk)=temp;
        end
    end
    dem_proportion_all(jj,:)=dem_proportion;
    
    % slope
    divide=[1,4,6];
    slope_proportion=zeros(1,4);
    for kk=1:4
        if kk==1
            temp=length(find(China_Irr_slope<=divide(kk)))/length(China_Irr_slope);
            slope_proportion(kk)=temp;
        elseif kk==4
            temp=length(find(China_Irr_slope>divide(kk-1)))/length(China_Irr_slope);
            slope_proportion(kk)=temp;
        else
            temp=length(find(China_Irr_slope>divide(kk-1)&China_Irr_slope<=divide(kk)))/length(China_Irr_slope);
            slope_proportion(kk)=temp;
        end
    end
    slope_proportion_all(jj,:)=slope_proportion;
    
    % waterdist
    divide=[1000,3000,5000];
    waterdist_proportion=zeros(1,4);
    for kk=1:4
        if kk==1
            temp=length(find(China_Irr_watedist<=divide(kk)))/length(China_Irr_watedist);
            waterdist_proportion(kk)=temp;
        elseif kk==4
            temp=length(find(China_Irr_watedist>divide(kk-1)))/length(China_Irr_watedist);
            waterdist_proportion(kk)=temp;
        else
            temp=length(find(China_Irr_watedist>divide(kk-1)&China_Irr_watedist<=divide(kk)))/length(China_Irr_watedist);
            waterdist_proportion(kk)=temp;
        end
    end
    watedist_proportion_all(jj,:)=waterdist_proportion;
    
end
%
xlswrite('F:\Data_ZL\IrrMap\2000\county_level\Other_IrrMap\dem_slope_water_Irr_prortion.xlsx',dem_proportion_all,'dem_proportion_all');
xlswrite('F:\Data_ZL\IrrMap\2000\county_level\Other_IrrMap\dem_slope_water_Irr_prortion.xlsx',slope_proportion_all,'slope_proportion_all');
xlswrite('F:\Data_ZL\IrrMap\2000\county_level\Other_IrrMap\dem_slope_water_Irr_prortion.xlsx',watedist_proportion_all,'watedist_proportion_all');
