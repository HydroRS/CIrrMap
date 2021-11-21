clc, clear

%%
year_map=2000;
modis_data_local='F:\Data_ZL\MODIS\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
land_loc='F:\Data_ZL\IrrMap\';

EVI_2000_intep_nominize=load([modis_data_local,num2str(year_map),'\EVI_2000_intep_nominize.mat'], 'EVI_2000_intep_nominize');
EVI_2000_intep_nominize=EVI_2000_intep_nominize.EVI_2000_intep_nominize;

weight_all=[];
for i=1:500
    rng(i);
    x=rand(1,4);
    y=sum(x);
    r=x/y;
    weight_all=[weight_all;r];
end

% read weights
EVI_2000_weight_all=load([modis_data_local,num2str(year_map),'\EVI_2000_weight_all.mat'], 'EVI_2000_weight_all');
EVI_2000_weight_all=EVI_2000_weight_all.EVI_2000_weight_all;

[data_crop, Ref] = geotiffread([land_loc,num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor=geotiffinfo([land_loc,num2str(year_map),'\',num2str(year_map),'new1.tif']);


province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;


% County_crop_id_2000=load([ID_loc,num2str(year_map),'\County_crop_id_2000.mat'], 'County_crop_id_2000');
% County_crop_id_2000=County_crop_id_2000.County_crop_id_2000;

% read spatial aridity data
% China_county_crop_aridity=geotiffread([land_loc,num2str(year_map),'\China_county_crop_aridity.tif']);

%% Sutability factors
data_dem= geotiffread([land_loc,'\Envrioment\dem_class_map_new.tif']);
data_waterdist= geotiffread([land_loc,'\Envrioment\waterdist_class_map_new.tif']);
data_slope= geotiffread([land_loc,'\Envrioment\slope_class_map_new.tif']);
data_aridity= geotiffread([land_loc,'\Envrioment\aridity_class_map_new.tif']);

%% 林草和耕地混合像元
data_UWU=imread([land_loc,num2str(year_map),'\',num2str(year_map),'new2_UWU.tif']);
data_FG=imread([land_loc,num2str(year_map),'\',num2str(year_map),'new3_ForestGrass.tif']);
id_invalid_FG=cell(31,1);
for hh=1:31
    hh
     province_crop_id=province_crop_id_2000{hh};
        idx = sub2ind(size(data_crop),province_crop_id(:,1),province_crop_id(:,2)); % row/con to index
        current_province_crop=data_crop(idx);
        current_province_UWU=data_UWU(idx);
        current_province_FG=data_FG(idx);
             
        id_invalid_FG{hh}=find(current_province_crop>0&current_province_crop<0.90&current_province_UWU<=current_province_FG);
end

%% 1-5列共五个变量（max, min, range, median, std)
EVI_2000_intep_nominize_ajusted=cell(1,31);

for mm=1%:5 仅取max变量
     mm
    
    for kk=1:31
        kk
        province_crop_id=province_crop_id_2000{kk};
        idx = sub2ind(size(data_crop),province_crop_id(:,1),province_crop_id(:,2)); % row/con to index
        EVI_province=EVI_2000_intep_nominize{kk}(:,mm);
        
         data_dem_province=data_dem(idx);
    data_waterdist_province=data_waterdist(idx);
    data_slope_province=data_slope(idx);
    data_aridity_province=data_aridity(idx);
    
        proportion_province=data_crop(idx);
    
      % 林草混合的点，调整EVI=EVI*耕地比例
      id_invalid_FG_province=id_invalid_FG{kk};
      temp=ones(size(EVI_province));
      temp(id_invalid_FG_province)=proportion_province(id_invalid_FG_province); 
      
      EVI_province_ajusted=temp.*EVI_province;
 
%       %% weigh settings
%     weight_province=EVI_2000_weight_all{kk};
%     best_one_id= find(weight_province(:,2)==max(max(weight_province(:,2))));
%     weigth_opt=weight_all(best_one_id(1),:);
%     sutability= data_dem_province/4*weigth_opt(1)...
%         +data_waterdist_province/4*weigth_opt(2)...
%         +data_slope_province/4*weigth_opt(3)...
%         +data_aridity_province/10*weigth_opt(4);
    
     EVI_2000_intep_nominize_ajusted{kk}(:,mm)=EVI_province_ajusted;
    end
end
%%
output_fold='F:\Data_ZL\MODIS\';
save ([output_fold,num2str(year_map),'\EVI_2000_intep_nominize_ajusted.mat'], 'EVI_2000_intep_nominize_ajusted','-v7.3');