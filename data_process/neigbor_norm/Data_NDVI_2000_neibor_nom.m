
clc, clear

year_map=2000;
modis_data_local='F:\Data_ZL\MODIS\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
land_loc='F:\Data_ZL\IrrMap\';

NDVI_2000_intep=load([modis_data_local,num2str(year_map),'\NDVI_2000_intep.mat'], 'NDVI_2000_intep');
NDVI_2000_intep=NDVI_2000_intep.NDVI_2000_intep;

NDVI_2000_ForestGrass=load([modis_data_local,num2str(year_map),'\NDVI_2000_ForestGrass.mat'], 'NDVI_2000_ForestGrass');
NDVI_2000_ForestGrass=NDVI_2000_ForestGrass.NDVI_2000_ForestGrass;

%%
% China_county_crop_aridity=geotiffread([land_loc,num2str(year_map),'\China_county_crop_aridity.tif']);
[data_lucc, Ref] = geotiffread([land_loc,num2str(year_map),'\',num2str(year_map),'new1.tif']);
data_GeoInfor=geotiffinfo([land_loc,num2str(year_map),'\',num2str(year_map),'new1.tif']);

province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;
province_ForestGrass_id_2000=load([ID_loc, num2str(year_map),'\province_ForestGrass_id_2000.mat'], 'province_ForestGrass_id_2000');
province_ForestGrass_id_2000=province_ForestGrass_id_2000.province_ForestGrass_id_2000;

NDVI_2000_intep_nominize=cell(1,31);

%
NDVI_2000_intep_map01=ones(size(data_lucc))*nan;

% NDVI_2000_intep_map_nominize=zeros(size(data_lucc));

neighbor_size=10000; % 50 km2
neighbor_temp=floor (sqrt(neighbor_size)/2); % Êµ¼Ê=29*29*0.25*0.25=52 km2
cols=(neighbor_temp*2+1)^2;
[m, n]=size(data_lucc);
    divide=10000;
%%  
% 
for ff=1
%     
    for hh=1:31
        hh
        
        % crop
        province_crop_id=province_crop_id_2000{hh};
        idx = sub2ind(size(data_lucc),province_crop_id(:,1),province_crop_id(:,2)); % row/con to index
        NDVI_2000_intep_map01(idx)=NDVI_2000_intep{hh}(:,ff);
        
        % Forest and grass
         province_FG_id=province_ForestGrass_id_2000{hh};
         idx = sub2ind(size(data_lucc),province_FG_id(:,1),province_FG_id(:,2)); % row/con to index
         NDVI_2000_intep_map01(idx)=NDVI_2000_ForestGrass{hh}(:,ff);
    end
    
%%
    for kk=1:31
        
        kk
        
        current_province=province_crop_id_2000{kk};
        range=1:divide:length(current_province(:,1));
        
       
        for ii=1:length(range)
             
               if ii==length(range)
                   range_current=range(ii):length(current_province(:,1));
               else
               range_current=range(ii):range(ii+1)-1;
               end
                 NDVI_2000_intep_all01=zeros(length(range_current),cols);
%                  NDVI_2000_intep_all02=zeros(length(range_current),cols);
%                  NDVI_2000_intep_all03=zeros(length(range_current),cols);
%                  NDVI_2000_intep_all04=zeros(length(range_current),cols);
%                  NDVI_2000_intep_all05=zeros(length(range_current),cols);
               
                 
                  range(ii)
%                   tic
            for jj=1:length(range_current);
               
                row_around=(current_province(range_current(jj),1)-neighbor_temp):(current_province(range_current(jj),1)+neighbor_temp);
                col_around=current_province(range_current(jj),2)-neighbor_temp:current_province(range_current(jj),2)+neighbor_temp;
                
                row_around=min(row_around,m);
                row_around=max(row_around,1);
                
                col_around=min(col_around,n);
                col_around=max(col_around,1);
                
                NDVI_2000_intep_around01= NDVI_2000_intep_map01(row_around,col_around) ;
%                 NDVI_2000_intep_around02= NDVI_2000_intep_map02(row_around,col_around) ;
%                 NDVI_2000_intep_around03= NDVI_2000_intep_map03(row_around,col_around) ;
%                 NDVI_2000_intep_around04= NDVI_2000_intep_map04(row_around,col_around) ;
%                 NDVI_2000_intep_around05= NDVI_2000_intep_map05(row_around,col_around) ;
                
                NDVI_2000_intep_all01(jj,:)=NDVI_2000_intep_around01(:) ;
%                 NDVI_2000_intep_all02(jj,:)=NDVI_2000_intep_around02(:) ;
%                    NDVI_2000_intep_all03(jj,:)=NDVI_2000_intep_around03(:) ;
%                       NDVI_2000_intep_all04(jj,:)=NDVI_2000_intep_around04(:) ;
%                          NDVI_2000_intep_all05(jj,:)=NDVI_2000_intep_around05(:) ;
            end
          
         NDVI_2000_intep_nominize{kk}(range_current,ff)=NDVI_2000_intep{kk}(range_current,ff)./nanmedian(NDVI_2000_intep_all01,2);

%           NDVI_2000_intep_nominize{kk}(range_current,ff)=NDVI_2000_intep{kk}(range_current,ff)./prctile(NDVI_2000_intep_all01,85,2); 
  
%           NDVI_2000_intep_nominize{kk}(range_current,2)=nanmedian(NDVI_2000_intep_all02,2); 
%           NDVI_2000_intep_nominize{kk}(range_current,3)=nanmedian(NDVI_2000_intep_all03,2); 
%           NDVI_2000_intep_nominize{kk}(range_current,4)=nanmedian(NDVI_2000_intep_all04,2); 
%           NDVI_2000_intep_nominize{kk}(range_current,5)=nanmedian(NDVI_2000_intep_all05,2); 
%                toc
            
        end
        
%         if ff==1
%             idx = sub2ind(size(data_lucc),current_province(:,1),current_province(:,2)); % row/con to index
%              NDVI_2000_intep_map_nominize(idx)=NDVI_2000_intep_nominize{kk}(:,ff);
%         end
          
    end
    
 end
%%
output_fold='F:\Data_ZL\MODIS\';
save ([output_fold,num2str(year_map),'\NDVI_2000_intep_nominize.mat'], 'NDVI_2000_intep_nominize','-v7.3');
% 
%  output_local='F:\Data_ZL\IrrMap\';
% 
% geotiffwrite([output_local,num2str(year_map),'\county_level\test04\NDVI_2000_intep_map_nominize.tif'],NDVI_2000_intep_map_nominize,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
% geotiffwrite([output_local,num2str(year_map),'\county_level\test03\NDVI_2000_intep_map_orgin_FG_crop.tif'],NDVI_2000_intep_map01,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);

