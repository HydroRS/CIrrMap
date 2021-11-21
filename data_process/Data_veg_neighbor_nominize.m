

clc, clear

year_map=2000;
modis_data_local='F:\Data_ZL\MODIS\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';
land_loc='F:\Data_ZL\IrrMap\';

humin_region_veg_used=load([modis_data_local,num2str(year_map),'\humin_region_veg_used.mat'], 'humin_region_veg_used');
humin_region_veg_used=humin_region_veg_used.humin_region_veg_used;

%%
% China_county_crop_aridity=geotiffread([land_loc,num2str(year_map),'\China_county_crop_aridity.tif']);
data_lucc = geotiffread([land_loc,'\',num2str(year_map),'\',num2str(year_map),'new1.tif']);

province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

humin_region_veg_used_nominize=cell(1,31);

%
humin_region_veg_used_map01=ones(size(data_lucc))*nan;
% humin_region_veg_used_map02=ones(size(data_lucc))*nan;
% humin_region_veg_used_map03=ones(size(data_lucc))*nan;
% humin_region_veg_used_map04=ones(size(data_lucc))*nan;
% humin_region_veg_used_map05=ones(size(data_lucc))*nan;


neighbor_size=10000; % 50 km2
neighbor_temp=floor (sqrt(neighbor_size)/2); % Êµ¼Ê=29*29*0.25*0.25=52 km2
cols=(neighbor_temp*2+1)^2;
[m, n]=size(data_lucc);
    divide=10000;
%%  [NGI_range_A, NGI_range_G, NGI_max_A, NGI_max_G, NAGI_A]
% 
for ff=3:5
%     
    for hh=1:31
        hh
        
        province_crop_id=province_crop_id_2000{hh};
        idx = sub2ind(size(data_lucc),province_crop_id(:,1),province_crop_id(:,2)); % row/con to index
        humin_region_veg_used_map01(idx)=humin_region_veg_used{hh}(:,ff);
%             humin_region_veg_used_map02(idx)=humin_region_veg_used{hh}(:,2);
%             humin_region_veg_used_map03(idx)=humin_region_veg_used{hh}(:,3);
%             humin_region_veg_used_map04(idx)=humin_region_veg_used{hh}(:,4);
%             humin_region_veg_used_map05(idx)=humin_region_veg_used{hh}(:,5);
%         
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
                 humin_region_veg_used_all01=zeros(length(range_current),cols);
%                  humin_region_veg_used_all02=zeros(length(range_current),cols);
%                  humin_region_veg_used_all03=zeros(length(range_current),cols);
%                  humin_region_veg_used_all04=zeros(length(range_current),cols);
%                  humin_region_veg_used_all05=zeros(length(range_current),cols);
               
                 
                  range(ii)
%                   tic
            for jj=1:length(range_current);
               
                row_around=(current_province(range_current(jj),1)-neighbor_temp):(current_province(range_current(jj),1)+neighbor_temp);
                col_around=current_province(range_current(jj),2)-neighbor_temp:current_province(range_current(jj),2)+neighbor_temp;
                
                row_around=min(row_around,m);
                row_around=max(row_around,1);
                
                col_around=min(col_around,n);
                col_around=max(col_around,1);
                
                humin_region_veg_used_around01= humin_region_veg_used_map01(row_around,col_around) ;
%                 humin_region_veg_used_around02= humin_region_veg_used_map02(row_around,col_around) ;
%                 humin_region_veg_used_around03= humin_region_veg_used_map03(row_around,col_around) ;
%                 humin_region_veg_used_around04= humin_region_veg_used_map04(row_around,col_around) ;
%                 humin_region_veg_used_around05= humin_region_veg_used_map05(row_around,col_around) ;
                
                humin_region_veg_used_all01(jj,:)=humin_region_veg_used_around01(:) ;
%                 humin_region_veg_used_all02(jj,:)=humin_region_veg_used_around02(:) ;
%                    humin_region_veg_used_all03(jj,:)=humin_region_veg_used_around03(:) ;
%                       humin_region_veg_used_all04(jj,:)=humin_region_veg_used_around04(:) ;
%                          humin_region_veg_used_all05(jj,:)=humin_region_veg_used_around05(:) ;
            end
          humin_region_veg_used_nominize{kk}(range_current,ff)=humin_region_veg_used{kk}(range_current,ff)./nanmedian(humin_region_veg_used_all01,2); 
%           humin_region_veg_used_nominize{kk}(range_current,2)=nanmedian(humin_region_veg_used_all02,2); 
%           humin_region_veg_used_nominize{kk}(range_current,3)=nanmedian(humin_region_veg_used_all03,2); 
%           humin_region_veg_used_nominize{kk}(range_current,4)=nanmedian(humin_region_veg_used_all04,2); 
%           humin_region_veg_used_nominize{kk}(range_current,5)=nanmedian(humin_region_veg_used_all05,2); 
%                toc
            
        end
          
    end
    
 end
%%
output_fold='F:\Data_ZL\MODIS\';
humin_region_veg_used_nominize02=humin_region_veg_used_nominize;
save ([output_fold,num2str(year_map),'\humin_region_veg_used_nominize02.mat'], 'humin_region_veg_used_nominize02','-v7.3');

