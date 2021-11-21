
% Pairwise_comparison_matrix =[1, 1/3, 4, 5;3,1,5,6;1/4,1/5,1,2;1/5,1/6,1/2,1];
% weight=AHP(Pairwise_comparison_matrix);
clc
clear
% data location
modis_data_local='F:\Data_ZL\MODIS\';
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
land_loc='F:\Data_ZL\IrrMap\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
% year for the land use map
year_map=2000;

%%  impact factors

% read aridity
data_aridity= geotiffread([land_loc,num2str(year_map),'\China_crop_aridity.tif']);
data_aridity(data_aridity==0)=nan;

%  read dem and slope, distance to water body
data_waterdist=double(imread([land_loc,'Envrioment\waterdist250f.tif'])); %单位m
data_waterdist(data_waterdist==-32768)=nan;

data_dem=double(imread([land_loc,'Envrioment\dem250.tif']));
data_dem(data_dem==-32768)=nan;

data_slope=double(imread([land_loc,'Envrioment\slope250.tif'])); %单位 %
data_slope(data_slope<0)=nan; %单位 %

%%
% read county data
county_area=xlsread([Cesus_IrrArea_data_local,num2str(year_map),'\County_area_merge.xlsx']);

% read province crop Id
province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

% read province data
% read land data
[data_crop, Ref] = geotiffread([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);

County_crop_id_2000=load([ID_loc,num2str(year_map),'\County_crop_id_2000.mat'], 'County_crop_id_2000');
County_crop_id_2000=County_crop_id_2000.County_crop_id_2000;

% read irrigaiton census data (province)
[Cesus_IrrArea_data, province]=xlsread([Cesus_IrrArea_data_local,'2001-2019年水利统计年鉴.xlsx'], [num2str(year_map),'年']);
province_code=sortrows(Cesus_IrrArea_data(2:end,[1,2,5]),2);

dem_class_map=zeros(size(data_crop));
slope_class_map=zeros(size(data_crop));
aridity_class_map=zeros(size(data_crop));
waterdist_class_map=zeros(size(data_crop));

%%
NCP=[1,2,10,12,15,23];
for kk=1:31
    kk
    % province & county
    province_crop_id=province_crop_id_2000{kk};
    province_current=province_code(kk,1);
    current_provinc_county_Irr=county_area(county_area(:,1)==province_current,end);
    
    idx = sub2ind(size(data_crop),province_crop_id(:,1),province_crop_id(:,2)); % row/con to index
    
    dem_province=data_dem(idx);
    slope_province=data_slope(idx);
    aridity_province=data_aridity(idx);
    waterdist_province=data_waterdist(idx);
    
    
    
    for jj=1:length(current_provinc_county_Irr);
        jj
        
        county_in_province=County_crop_id_2000{jj,kk};
        idx = sub2ind(size(data_crop),province_crop_id(county_in_province,1),province_crop_id(county_in_province,2)); % row/con to index
        
        if length(county_in_province)<50 %如果县区crop个数小于50，假设它们具有的低灌溉潜力
             dem_class_map(idx)=1;
              slope_class_map(idx)=1;
              aridity_class_map(idx)=1;
              waterdist_class_map(idx)=1;
            continue
        else
            %% dem
            dem_county=dem_province(county_in_province);
%             divide=[100,300, 500];
           min_value=min(dem_county);
            temp=dem_county;
%             divide=quantile(temp, 7);         %分为8类
              divide=min_value+[100,300, 500];  %分为4类
            for hh=1:4
                if hh==1
                    temp(dem_county<=divide(hh))=5-hh; % 值越小，灌溉潜力越大
                elseif hh==4
                    temp(dem_county>divide(hh-1))=5-hh;
                else
                    temp(dem_county>divide(hh-1)&dem_county<=divide(hh))=5-hh;
                end
            end
            dem_class_map(idx)=temp;
           
            %% slope
            slope_county=slope_province(county_in_province);
            temp=slope_county;
%             divide=quantile(temp, 7);         %分为8类   
            divide=[2,4,8];
            for hh=1:4
                if hh==1
                    temp(slope_county<=divide(hh))=5-hh; % 值越小，灌溉潜力越大
                elseif hh==4
                    temp(slope_county>divide(hh-1))=5-hh;
                else
                    temp(slope_county>divide(hh-1)&slope_county<=divide(hh))=5-hh;
                end
            end
            slope_class_map(idx)=temp;
            
            %% aridity
            aridity_county=aridity_province(county_in_province);
            delta_dem=prctile(dem_county,95)-prctile(dem_county,5);
            if  delta_dem<=100&&ismember(kk,NCP)==1
                 aridity_class_map(idx)=10; % 平原县假设aridity不影响灌溉潜力
            else
                temp=aridity_county;
                divide=0.1:0.1:0.9;         %分为10类
                for hh=1:10
                    if hh==1
                        temp(aridity_county<=divide(hh))=11-hh; % 值越小，灌溉潜力越大
                    elseif hh==10
                        temp(aridity_county>divide(hh-1))=11-hh;
                    else
                        temp(aridity_county>divide(hh-1)&aridity_county<=divide(hh))=11-hh;
                    end
                    
                    aridity_class_map(idx)=temp;
                end            
            end
            %% waterdist
            waterdist_county=waterdist_province(county_in_province);
            min_value=min(waterdist_county);
            delta_dem=prctile(dem_county,95)-prctile(dem_county,5);
             if  delta_dem<=100&&ismember(kk,NCP)==1
                  waterdist_class_map(idx)=4; % 如果平原县（dem变化<100），假设到河道距离不影像灌溉潜力
             else
                temp=waterdist_county;
                divide=min_value+[1000,  10000, 20000];  %分为6类
                for hh=1:4
                    if hh==1
                        temp(waterdist_county<=divide(hh))=5-hh; % 值越小，灌溉潜力越大
                    elseif hh==4
                        temp(waterdist_county>divide(hh-1))=5-hh;
                    else
                        temp(waterdist_county>divide(hh-1)&waterdist_county<=divide(hh))=5-hh;
                    end
                end
                waterdist_class_map(idx)=temp;
               
            end
        
    end
    end
end


%% test 01-arid
% Pairwise_comparison_matrix =[1, 1/4, 1/2, 1/3;....
%                                                4,1,4,2;...
%                                                2,1/4,1,1/4;...
%                                                3,1/2,4,1];
% weight=AHP(Pairwise_comparison_matrix);
% 
% % test 02-humid
% Pairwise_comparison_matrix =[1, 1/3, 4, 1;....
%                                                3,1,7,2;...
%                                                1/4,1/7,1,1/9;...
%                                                1,1/2,9,1];
% weight=AHP(Pairwise_comparison_matrix);


% weight=[0.25, 0.25, 0.25, 0.25];
% %%
% Irr_sutability_value=dem_class_map/4*weight(1)+waterdist_class_map/4*weight(2)+slope_class_map/4*weight(3)+aridity_class_map/10*weight(4);
% % Irr_sutability_value=data_dem/16*weight(1)+data_waterdist/16*weight(2)+data_slope/16*weight(3)+data_aridity/16*weight(4);
% output_local='F:\Data_ZL\IrrMap\';
% geotiffwrite([output_local,'\Envrioment\Irr_sutability_value_test.tif'],Irr_sutability_value,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);

%%
output_local='F:\Data_ZL\IrrMap\';
geotiffwrite([output_local,'\Envrioment\dem_class_map_new.tif'],dem_class_map,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite([output_local,'\Envrioment\slope_class_map_new.tif'],slope_class_map,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite([output_local,'\Envrioment\aridity_class_map_new.tif'],aridity_class_map,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite([output_local,'\Envrioment\waterdist_class_map_new.tif'],waterdist_class_map,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
