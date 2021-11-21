% =============================================
%  this code is to get random samples of irr and non-irr areas in each
%    subregions of China
%   Dr. Ling Zhang, zhanglingky@lzb.ac.cn, CAS
% =============================================
clc,clear
%% paramters & data loading
year_map=2000;
num_training_times=10;

%  read data loaction
land_loc='F:\Data_ZL\IrrMap\';
Predictors_loc='F:\Data_ZL\MODIS\';
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';

% read potential Irr and NonIrr pixes for each county of each province
Veg_intersect_IrrArea=geotiffread([land_loc,num2str(year_map),'\county_level\test08\Veg_intersect_IrrArea.tif']);

[data_crop, Ref] = geotiffread([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor=geotiffinfo([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);
%%


EVI_2000_intep_ajusted=load([Predictors_loc,num2str(year_map),...
    '\EVI_2000_intep_ajusted.mat'], 'EVI_2000_intep_ajusted');
EVI_2000=EVI_2000_intep_ajusted.EVI_2000_intep_ajusted;

EVI_2000_intep_nominize_ajusted=load([Predictors_loc,num2str(year_map),...
    '\EVI_2000_intep_nominize_ajusted.mat'], 'EVI_2000_intep_nominize_ajusted');
NEVI_2000=EVI_2000_intep_nominize_ajusted.EVI_2000_intep_nominize_ajusted;

NDVI_2000_intep_ajusted=load([Predictors_loc,num2str(year_map),...
    '\NDVI_2000_intep_ajusted.mat'], 'NDVI_2000_intep_ajusted');
NDVI_2000=NDVI_2000_intep_ajusted.NDVI_2000_intep_ajusted;

NDVI_2000_intep_nominize_ajusted=load([Predictors_loc,num2str(year_map),...
    '\NDVI_2000_intep_nominize_ajusted.mat'], 'NDVI_2000_intep_nominize_ajusted');
NNDVI_2000=NDVI_2000_intep_nominize_ajusted.NDVI_2000_intep_nominize_ajusted;

GI_2000_intep_ajusted=load([Predictors_loc,num2str(year_map),...
    '\GI_2000_intep_ajusted.mat'], 'GI_2000_intep_ajusted');
GI_2000=GI_2000_intep_ajusted.GI_2000_intep_ajusted;

GI_2000_intep_nominize_ajusted=load([Predictors_loc,num2str(year_map),...
    '\GI_2000_intep_nominize_ajusted.mat'], 'GI_2000_intep_nominize_ajusted');
NGI_2000=GI_2000_intep_nominize_ajusted.GI_2000_intep_nominize_ajusted;

%%
env_variables=load([Predictors_loc,num2str(year_map),...
    '\env_variables.mat'], 'env_variables');
env_variables=env_variables.env_variables;

Yangkun_climate_2000_mean=load([Predictors_loc,num2str(year_map),...
    '\Yangkun_climate_2000_mean.mat'], 'Yangkun_climate_2000_mean');
Yangkun_climate_2000_mean=Yangkun_climate_2000_mean.Yangkun_climate_2000_mean;

%%
EVI_2000_intep=load([Predictors_loc,num2str(year_map),...
    '\EVI_2000_intep.mat'], 'EVI_2000_intep');
EVI_2000_intep=EVI_2000_intep.EVI_2000_intep;

NDVI_2000_intep=load([Predictors_loc,num2str(year_map),...
    '\NDVI_2000_intep.mat'], 'NDVI_2000_intep');
NDVI_2000_intep=NDVI_2000_intep.NDVI_2000_intep;


GI_2000_intep=load([Predictors_loc,num2str(year_map),...
    '\GI_2000_intep.mat'], 'GI_2000_intep');
GI_2000_intep=GI_2000_intep.GI_2000_intep;


NDWI_2000_intep=load([Predictors_loc,num2str(year_map),...
    '\NDWI_2000_intep.mat'], 'NDWI_2000_intep');
NDWI_2000_intep=NDWI_2000_intep.NDWI_2000_intep;

%%
% read county data
county_area=xlsread([Cesus_IrrArea_data_local,num2str(year_map),'\County_area_merge.xlsx']);

% read irrigaiton census data (province)
[Cesus_IrrArea_data, province]=xlsread([Cesus_IrrArea_data_local,'2001-2019年水利统计年鉴.xlsx'], [num2str(year_map),'年']);
province_code=sortrows(Cesus_IrrArea_data(2:end,[1,2,5]),2);

County_crop_id_2000=load([ID_loc,num2str(year_map),'\County_crop_id_2000.mat'], 'County_crop_id_2000');
County_crop_id_2000=County_crop_id_2000.County_crop_id_2000;

province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

% read sample id
validation_sample_id=load([ID_loc,num2str(year_map),'\validation_sample_id.mat'], 'validation_sample_id');
validation_sample_id=validation_sample_id.validation_sample_id;

%% random samples

% train_data_subset=cell(10,31);
% predictor_data_all=cell(size(County_crop_id_2000));
% train_data_subset=cell(size(County_crop_id_2000));
city_province=[18,30,8,20,11,22];
% for ii=1:num_training_times
% ii
%
paroptions = Parellel_set();

leaf=10;
ntrees=100;
fboot=1;
surrogate='off';

weight_all=[];
mapping_result=cell(size(County_crop_id_2000));
Irr_map_China=double(zeros(size(data_crop)));


for jj=1:31
    jj
    province_crop_id=province_crop_id_2000{jj};
    
    if find(city_province==jj)>0
        total_num_sample_county=5000;
    else
        total_num_sample_county=400;
    end
    province_current=province_code(jj,1);
    current_provinc_county_Irr=county_area(county_area(:,1)==province_current,end);
    county_number=length(current_provinc_county_Irr);
    
    AGI=GI_2000_intep{jj}(:,1).*NDWI_2000_intep{jj}(:,1);
%     veg=[EVI_2000{jj}(:,1),NEVI_2000{jj}, EVI_2000_intep{jj}, NDVI_2000{jj}(:,1),NNDVI_2000{jj},NDVI_2000_intep{jj},GI_2000{jj}(:,1),NGI_2000{jj},GI_2000_intep{jj}, NDWI_2000_intep{jj},AGI];
    
     veg=[EVI_2000{jj}(:,1),NEVI_2000{jj},NDVI_2000{jj}(:,1),NNDVI_2000{jj},GI_2000{jj}(:,1),NGI_2000{jj}, NDWI_2000_intep{jj}(:,1),AGI];
   
    Env=env_variables{jj};
    climate=Yangkun_climate_2000_mean{jj};
    %     ET_pcp=delta_pcp_ET{jj}(:,1);
    
    
    for kk=1:county_number
        kk
        county_in_province=County_crop_id_2000{kk,jj};
        idx = sub2ind(size(data_crop),province_crop_id(county_in_province,1),province_crop_id(county_in_province,2)); % row/con to index
        
        Veg_IrrArea_county=Veg_intersect_IrrArea(idx);
        
        Irr_sample_ID=county_in_province(Veg_IrrArea_county==1);
        NoneIrr_sample_ID=county_in_province(Veg_IrrArea_county==2);
        
        if isempty(Irr_sample_ID) && isempty(NoneIrr_sample_ID)
            continue
            
        end
        
        num_sample_irr=length(Irr_sample_ID);
        num_sample_Noneirr=length(NoneIrr_sample_ID);
        
        % ensure sample not greater than total potential numbers
        if num_sample_irr>total_num_sample_county/2
            num_sample_irr=total_num_sample_county/2;
        end
        
        if num_sample_Noneirr>total_num_sample_county/2
            num_sample_Noneirr=total_num_sample_county/2;
        end
        
        %        density_diff_all=[];
        %        for mm=1:50
        %            mm
        %            rng(mm);
        %            Irr_sample=datasample(Irr_sample_ID,num_sample_irr,'Replace',false);
        %            rng(mm);
        %
        %            None_Irr_sample=datasample(NoneIrr_sample_ID,num_sample_Noneirr,'Replace',false);
        %
        %            density_diff = createFit(EVI_2000{jj}(Irr_sample), EVI_2000{jj}(None_Irr_sample), 0, '');
        %            density_diff_all=[density_diff_all;density_diff];
        %        end
        %        max_diff=find(density_diff_all==max(density_diff_all));
         mapping_result{kk,jj}=0;
        for uu=1
            
            rng(8);
            Irr_sample=datasample(Irr_sample_ID,num_sample_irr,'Replace',false);
            rng(8);
            None_Irr_sample=datasample(NoneIrr_sample_ID,num_sample_Noneirr,'Replace',false);
            
            
            all_sample=[Irr_sample;None_Irr_sample];
            label=[ones(size(Irr_sample));zeros(size(None_Irr_sample))];
            
%             train_data_subset{kk,jj}=[veg(all_sample,:),Env(all_sample,:),label];
%             predictor_data_all{kk,jj}=[veg(county_in_province,:),Env(county_in_province,:)];
            
            temp_in=[veg(all_sample,:), Env(all_sample,:), climate(all_sample,:)];
            if isempty(temp_in)
                continue
            end
            temp_out=label;
            predict_temp=[veg(county_in_province,:),Env(county_in_province,:),climate(county_in_province,:)];
            
            
            RF_model= TreeBagger(ntrees,temp_in,temp_out,'Method','classification','oobvarimp','on','surrogate',...
                surrogate,'minleaf',leaf,'FBoot',fboot, 'Options',paroptions);
            
            
            [ y, prob]=predict(RF_model,predict_temp );
            weight=RF_model.OOBPermutedVarDeltaError;
            %第一列是0的概率，第二列是1的概率
            % 如果只有一列则表示样本都属于一类。
            % 两种情况：（1） crop面积小于统计面积；（2）统计面积太小或者等于0
            
            %如果样本仅有一个类型，则prob为一列，且为1
            if length(prob(1,:))==1
                prob=temp_out(1)*ones(length(predict_temp(:,1)),1);
                mapping_result{kk,jj}= mapping_result{kk,jj}+prob(:,end);
            else
                % feture improtance仅给有效的训练样本进行计算
                %            temp=[province_current,current_provinc_county_code(kk),weight];
                %            weight_all=[weight_all;temp];
                mapping_result{kk,jj}=mapping_result{kk,jj}+ prob(:,end);
            end
        end
       
        
        temp_province=mapping_result{kk,jj}/uu;
        temp_province(temp_province>0.5)=1;
        temp_province(temp_province<=0.5)=0;
        
        %             mapping_result_class{kk,ii}=bb;
%         crop_current_county=County_crop_id_2000{kk,jj};
%         idx = sub2ind(size(data_crop),current_province_crop_id(crop_current_county,1),current_province_crop_id(crop_current_county,2)); % row/con to index
        Irr_nonIrr_county=temp_province.*data_crop(idx);
        Irr_map_China(idx)=Irr_nonIrr_county;
        
    end
    
end



%% ##################### accuracy ################

accuarcy_Province={'OA', 'kappa','PIrr','PnonIrr'};
% aridty=[];
for kk=1:31
    kk
    sutability_factor=[];
    current_province_id=province_crop_id_2000{kk};
    id=validation_sample_id{kk};
    idx_map = sub2ind(size(data_crop),current_province_id(:,1),current_province_id(:,2)); % row/con to index
    
    sutability_province=Irr_map_China(idx_map);
    Irr_sutability=sutability_province(id(:,end),:);
    
    sutability_factor=[id,Irr_sutability];
    sutability_factor(sutability_factor>0)=1;
    
    obs=sutability_factor(:,4);
    simu=sutability_factor(:,1+5);
    [over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
    accuarcy_Province{kk+1,1}=over_accuracy;
    accuarcy_Province{kk+1,2}=kappa;
    accuarcy_Province{kk+1,3}=Irr_Pa;
    accuarcy_Province{kk+1,4}=NonIrr_Pa;
    
end

%% China, arid, humid assessment
China_county_crop_aridity=geotiffread([land_loc,num2str(year_map),'\China_county_crop_aridity.tif']);
sutability_factor=[];
aridty=[];
for kk=1:31
    kk
    current_province_id=province_crop_id_2000{kk};
    id=validation_sample_id{kk};
    idx_map = sub2ind(size(Irr_map_China),current_province_id(:,1),current_province_id(:,2)); % row/con to index
    
    sutability_province=Irr_map_China(idx_map);
    Irr_sutability=sutability_province(id(:,end),:);
    
    sutability_factor=[sutability_factor;[id,Irr_sutability]];
    
    temp_data=zeros(length(id(:,1)),1);
    for jj=1:length(id(:,1))
        province_id=id(:,end);
        temp_row_col=[current_province_id(province_id(jj),1),current_province_id(province_id(jj),2)];
        temp_data(jj)=China_county_crop_aridity(temp_row_col(1),temp_row_col(2));
    end
    aridty=[aridty;temp_data];
end

sutability_factor(sutability_factor>0)=1;

acccuracy_China={'OA', 'kappa','PIrr','PnonIrr'};

sutability_factor=[];
aridty=[];
for kk=1:31
    kk
    current_province_id=province_crop_id_2000{kk};
    id=validation_sample_id{kk};
    idx_map = sub2ind(size(Irr_map_China),current_province_id(:,1),current_province_id(:,2)); % row/con to index
    
    sutability_province=Irr_map_China(idx_map);
    Irr_sutability=sutability_province(id(:,end),:);
    
    sutability_factor=[sutability_factor;[id,Irr_sutability]];
    
    temp_data=zeros(length(id(:,1)),1);
    for jj=1:length(id(:,1))
        province_id=id(:,end);
        temp_row_col=[current_province_id(province_id(jj),1),current_province_id(province_id(jj),2)];
        temp_data(jj)=China_county_crop_aridity(temp_row_col(1),temp_row_col(2));
    end
    aridty=[aridty;temp_data];
end

sutability_factor(sutability_factor>0)=1;

% ####### China ##########
obs=sutability_factor(:,4);
simu=sutability_factor(:,1+5);
[over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
acccuracy_China{2,1}=over_accuracy;
acccuracy_China{2,2}=kappa;
acccuracy_China{2,3}=Irr_Pa;
acccuracy_China{2,4}=NonIrr_Pa;

% ####### arid region ##########
obs=sutability_factor(aridty<=0.500,4);
simu=sutability_factor(aridty<=0.500,1+5);
[over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
acccuracy_China{3,1}=over_accuracy;
acccuracy_China{3,2}=kappa;
acccuracy_China{3,3}=Irr_Pa;
acccuracy_China{3,4}=NonIrr_Pa;

% ########## humid region ##########
obs=sutability_factor(aridty>0.500,4);
simu=sutability_factor(aridty>0.500,1+5);
[over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu );
acccuracy_China{4,1}=over_accuracy;
acccuracy_China{4,2}=kappa;
acccuracy_China{4,3}=Irr_Pa;
acccuracy_China{4,4}=NonIrr_Pa;

%%
output_local='F:\Data_ZL\IrrMap\';
xlswrite([output_local,num2str(year_map),'\county_level\test08\IrrArea_map_point_accuracy_final.xlsx'],acccuracy_China,'acccuracy_China');
xlswrite([output_local,num2str(year_map),'\county_level\test08\IrrArea_map_point_accuracy_final.xlsx'],accuarcy_Province,'accuarcy_Province');

mapping_result_final=mapping_result;
save ([land_loc,num2str(year_map),'\county_level\test08\mapping_result_final.mat'], 'mapping_result_final','-v7.3');
geotiffwrite([land_loc,num2str(year_map),'\county_level\test08\',num2str(year_map),'_Irr_map_county_China_final.tif'],Irr_map_China,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
