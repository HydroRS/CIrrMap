% Codes used to obtain training samples
clc;clear

% data location
modis_data_local='F:\Data_ZL\MODIS\';
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
land_loc='F:\Data_ZL\IrrMap\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
% year for the land use map
year_map=2000;

%% read data

data_dem= geotiffread([land_loc,'\Envrioment\dem_class_map_new.tif']);
data_waterdist= geotiffread([land_loc,'\Envrioment\waterdist_class_map_new.tif']);
data_slope= geotiffread([land_loc,'\Envrioment\slope_class_map_new.tif']);
data_aridity= geotiffread([land_loc,'\Envrioment\aridity_class_map_new.tif']);
data_dem_origin=double(imread([land_loc,'Envrioment\dem250.tif']));

% data_dem=dem_class_map;
% data_waterdist=waterdist_class_map;
% data_slope= slope_class_map;
% data_aridity= aridity_class_map;


GI_2000_intep=load([modis_data_local,num2str(year_map),'\GI_2000_intep.mat'], 'GI_2000_intep');
GI_2000_intep=GI_2000_intep.GI_2000_intep;

GI_2000_intep_nominize=load([modis_data_local,num2str(year_map),'\GI_2000_intep_nominize.mat'], 'GI_2000_intep_nominize');
GI_2000_intep_nominize=GI_2000_intep_nominize.GI_2000_intep_nominize;

[data_crop, Ref] = geotiffread([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);


% read county data
county_area=xlsread([Cesus_IrrArea_data_local,num2str(year_map),'\County_area_merge.xlsx']);

County_crop_id_2000=load([ID_loc,num2str(year_map),'\County_crop_id_2000.mat'], 'County_crop_id_2000');
County_crop_id_2000=County_crop_id_2000.County_crop_id_2000;

% read irrigaiton census data (province)
[Cesus_IrrArea_data, province]=xlsread([Cesus_IrrArea_data_local,'2001-2019年水利统计年鉴.xlsx'], [num2str(year_map),'年']);
province_code=sortrows(Cesus_IrrArea_data(2:end,[1,2,5]),2);

% read sample id
validation_sample_id=load([ID_loc,num2str(year_map),'\validation_sample_id.mat'], 'validation_sample_id');
validation_sample_id=validation_sample_id.validation_sample_id;

province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

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

%%
weight_all=[];
for i=1:500
    rng(i);
    x=rand(1,4);
    y=sum(x);
    r=x/y;
    weight_all=[weight_all;r];
end
sutability_threshod_IrrArea=zeros(size(data_crop));

%%
% read weights
% GI_2000_weight_all=load([modis_data_local,num2str(year_map),'\GI_2000_weight_all.mat'], 'GI_2000_weight_all');
% weight_opt_all=GI_2000_weight_all.GI_2000_weight_all;
 weight_opt_all=cell(1,31);
NCP=[1,2,10,12,15,23];
for kk=1:31
    kk
    % province & county
    province_crop_id=province_crop_id_2000{kk};
    province_current=province_code(kk,1);
    current_provinc_county_Irr=county_area(county_area(:,1)==province_current,end);
    current_provinc_county_code=county_area(county_area(:,1)==province_current,end-1);
    
   GI_province=GI_2000_intep{kk}(:,1);
     GI_province_neighbor=GI_2000_intep_nominize{kk}(:,1);
      
    idx = sub2ind(size(data_crop),province_crop_id(:,1),province_crop_id(:,2)); % row/con to index
    data_dem_province=data_dem(idx);
    data_waterdist_province=data_waterdist(idx);
    data_slope_province=data_slope(idx);
    data_aridity_province=data_aridity(idx);
    proportion_province=data_crop(idx);
    
     data_dem_province_origin=data_dem_origin(idx);

    

      % 林草混合的点，调整GI=GI*耕地比例
      id_invalid_FG_province=id_invalid_FG{kk};
      temp=ones(size(GI_province));
      temp(id_invalid_FG_province)=proportion_province(id_invalid_FG_province); 
     GI_province_ajusted=temp.*GI_province;
      GI_province_neighbor_ajusted=temp.*GI_province_neighbor;
            
    weight_opt_results=zeros(length(weight_all(:,1)),4);
    %% weigh settings
    tic
    for hh=1:length(weight_all(:,1))
        hh
        sutability= data_dem_province/4*weight_all(hh,1)...
            +data_waterdist_province/4*weight_all(hh,2)...
            +data_slope_province/4*weight_all(hh,3)...
            +data_aridity_province/10*weight_all(hh,4);
       
%            sutability= data_dem_province/4*0.25...
%             +data_waterdist_province/4*0.25...
%             +data_slope_province/4*0.25...
%             +data_aridity_province/10*0.25;
        
        %% threshold area
        
        for jj=1:length(current_provinc_county_Irr);
            
            Cecsus_IrrArea=current_provinc_county_Irr(jj)*1e7;   % 1000 hm2 to m2
            county_in_province=County_crop_id_2000{jj,kk};
            idx_county= sub2ind(size(data_crop),province_crop_id(county_in_province,1),province_crop_id(county_in_province,2)); % row/con to index
            proportion_county=data_crop(idx_county);
            
             dem_county=data_dem_province_origin(county_in_province);
              delta_dem=prctile(dem_county,95)-prctile(dem_county,5);
                       % sutability
            if  delta_dem<=100&&ismember(kk,NCP)==1 %华北平原平原县
                max_sutability=GI_province_neighbor_ajusted(county_in_province);
            else
                county_temp_sutability=sutability(county_in_province);
                county_temp_GI=GI_province_ajusted(county_in_province);
                max_sutability=county_temp_sutability.*county_temp_GI;
            end
            
            % sutability
%             county_temp_sutability=sutability(county_in_province);
%             county_temp_GI=GI_province_ajusted(county_in_province);         
%             max_sutability=county_temp_sutability.*county_temp_GI;

            [temp,index]=sort(max_sutability);
            max2min_oder=flipud([temp,index]);
            
            % threshods
            proportion_county_temp=proportion_county(max2min_oder(:,2)).*250*250; % area of each grid
            summax=cumsum(proportion_county_temp);
            if isempty(summax) % empty value
                continue
            elseif summax(end)<Cecsus_IrrArea;
%                 disp(['warning!!! ', num2str(current_provinc_county_code(jj)), ' IrrArea>CropArea']);
                id_threshod=length(proportion_county_temp); % thresholds
            else
                id_threshod=find(summax>Cecsus_IrrArea); % thresholds
            end
            
            sutability_threshold_IrrArea=max2min_oder(1:id_threshod(1)-1,:);
            sutability_threshold_NoneIrrArea=max2min_oder(id_threshod(1):end,:); % find
            sutability_Irr_id=county_in_province(sutability_threshold_IrrArea(:,2));
            sutability_NoneIrr_id=county_in_province(sutability_threshold_NoneIrrArea(:,2));
            
            %Locate sutability dected Irr and none-irr to the grid province map
            sutability_idx = sub2ind(size(data_crop),province_crop_id(sutability_Irr_id,1),province_crop_id(sutability_Irr_id,2)); % row/con to index
            sutability_idx_none_irr = sub2ind(size(data_crop),province_crop_id(sutability_NoneIrr_id,1),province_crop_id(sutability_NoneIrr_id,2)); % row/con to index
            sutability_threshod_IrrArea(sutability_idx)=data_crop(sutability_idx);
            sutability_threshod_IrrArea(sutability_idx_none_irr)=0;
            
        end
        
        %% accuracy assessment
        
        id=validation_sample_id{kk};
        sutability_province=sutability_threshod_IrrArea(idx);
        Irr_sutability=sutability_province(id(:,end),:);
        
        sutability_factor=[id,Irr_sutability];
        sutability_factor(sutability_factor>0)=1;
        
        obs=sutability_factor(:,4);
        simu=sutability_factor(:,1+5);
   [over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
        weight_opt_results(hh,:)=[over_accuracy, kappa, Irr_Pa, NonIrr_Pa] ;
    end
    toc
    weight_opt_all{kk}=weight_opt_results;
   best_one= find(weight_opt_results(:,2)==max(max(weight_opt_results(:,2))));
end

%%
output_fold='F:\Data_ZL\MODIS\';
GI_2000_weight_all=weight_opt_all;
save ([output_fold,num2str(year_map),'\GI_2000_weight_all.mat'], 'GI_2000_weight_all','-v7.3');

% output_local='F:\Data_ZL\IrrMap\';
% geotiffwrite([output_local,num2str(year_map),'\county_level\test06\GI_sutability_threshold_IrrArea_opt918_V9.tif'],sutability_threshod_IrrArea,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);

