%    county data包含中国每个县的空间分布。
%    因为部分县的数据没有，需要将这些县进行合并。
%    该程序提取中国各省、各市、以及县（综合后）的位置。
%--------------------------------------------------------------
clc; clear

% data location
Cesus_IrrArea_data_local='F:\Data_ZL\IrrMap\Census\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';

% year for the land use map
year_map=2000;

% read irrigaiton census data (province)
[Cesus_IrrArea_data, province]=xlsread([Cesus_IrrArea_data_local,'2001-2019年水利统计年鉴.xlsx'], [num2str(year_map),'年']);
province_code=sortrows(Cesus_IrrArea_data(2:end,[1,2,5]),2); 

%  read county id data
[County_ID,Ref] = geotiffread([Cesus_IrrArea_data_local,num2str(year_map),'\County_china_250.tif']);
County_ID_new=ones(size(County_ID))*(-9999);
City_ID_new=ones(size(County_ID))*(-9999);

data_GeoInfor=geotiffinfo([Cesus_IrrArea_data_local,num2str(year_map),'\County_china_250.tif']);

% read irrigaiton census data (county)
county_area_new=load([Cesus_IrrArea_data_local, num2str(year_map),'\county_area_new.mat'], 'county_area_new');
county_area_new=county_area_new.county_area_new;


% read province crop Id
province_crop_id_2000=load([ID_loc, num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;


%% 
County_crop_id_2000=[];
City_crop_id_2000=[];
County_Irr_area_all_province=[];
begin_time=0;
begin_time_01=0;
begin_time_02=0;
county_area_merge=[];
 Irr_Area_city=[];
for kk=27
   kk
    current_province_crop_id=province_crop_id_2000{kk};
    
     [County_IrrArea,infor_county]=xlsread([Cesus_IrrArea_data_local,num2str(year_map),'\Zhu_county_area.xlsx'], num2str(province_code(kk,1)));
     
    id_temp=find( strcmp(county_area_new(1,:),num2str(province_code(kk,1)))==1);

      temp02=infor_county(:,end);
   [i,j] = unique(temp02,'first');
   city_all=temp02(sort(j));
   
   Irr_Area_county=county_area_new{2,id_temp};
   
   for hh=1:length(Irr_Area_county)
       County_Irr_area_all_province{hh+begin_time,1}=County_IrrArea(hh,1);
          County_Irr_area_all_province{hh+begin_time,2}=infor_county{hh,1};
          County_Irr_area_all_province{hh+begin_time,3}=infor_county{hh,2};
          County_Irr_area_all_province{hh+begin_time,4}=infor_county{hh,3};
          County_Irr_area_all_province{hh+begin_time,5}=County_IrrArea(hh,5);
          County_Irr_area_all_province{hh+begin_time,6}=County_IrrArea(hh,6);
           County_Irr_area_all_province{hh+begin_time,7}=County_IrrArea(hh,7);
          County_Irr_area_all_province{hh+begin_time,8}=Irr_Area_county(hh,1);
   end
   
    start_county=0;
    Irr_Area_county_merge_final=[];
 
   for jj=1:length(city_all)
       jj
       ID_city=find(strcmp(infor_county(:,end),city_all{jj})==1);
       temp_county=County_IrrArea(ID_city,[1,7]);
       
        ia_city=[];
        
      temp01=temp_county(:,2);
%       Irr_city=Irr_Area_county(ID_city,1);
      
     [i,j] = unique(temp01,'first');
     county_has_data= temp01(sort(j));
     
       Irr_Area_county_merge=[];
        
       for ii=1:length(county_has_data)
           ii
           ID=find(County_IrrArea(:,7)==county_has_data(ii));
           IRR_row=[];
           IRR_colunm=[];
            temp_irr_area=0;

           for mm=1:length(ID)
               [IRR_row_county,IRR_colunm_county]=find(County_ID==County_IrrArea(ID(mm),1));
               IRR_row=[IRR_row;IRR_row_county];
               IRR_colunm=[IRR_colunm;IRR_colunm_county];
               temp_irr_area=temp_irr_area+Irr_Area_county(ID(mm));
               
           end
           
            idx = sub2ind(size(County_ID_new),IRR_row,IRR_colunm); % row/con to index
           
           County_ID_new(idx)=int32(county_has_data(ii));
           
              temp=num2str(county_has_data(ii));
           temp_city=str2num([temp(1:4),'00']);
           City_ID_new(idx)=int32(temp_city);
           
           [crop_current_county,ia]=intersect([current_province_crop_id(:,1),current_province_crop_id(:,2)],[IRR_row,IRR_colunm],'rows');
           County_crop_id_2000{start_county+ii,kk}=ia;
           ia_city=[ia_city;ia];
           
        Irr_Area_county_merge=[Irr_Area_county_merge;[county_has_data(ii),temp_irr_area]];
          
       end
       
       Irr_Area_city{jj+begin_time_02,1}=province_code(kk,1);
       Irr_Area_city{jj+begin_time_02,2}=infor_county{1,2};
      Irr_Area_city{jj+begin_time_02,3}=city_all{jj};
       Irr_Area_city{jj+begin_time_02,4}=temp_city;
       Irr_Area_city{jj+begin_time_02,5}=sum(Irr_Area_county_merge(:,2));
           
        City_crop_id_2000{jj,kk}=ia_city;
       start_county=start_county+length(county_has_data);
       Irr_Area_county_merge_final=[Irr_Area_county_merge_final;Irr_Area_county_merge];

   end
%    county_area_merge{1,kk}=num2str(province_code(kk,1));
%     county_area_merge{2,kk}=Irr_Area_county_merge_final;
%     county_area_merge=[county_area_merge;Irr_Area_county_merge_final];
    
    for uu=1:length(Irr_Area_county_merge_final)
        id_temp=find(County_IrrArea(:,1)==Irr_Area_county_merge_final(uu,1));
        county_area_merge{uu+begin_time_01,1}=province_code(kk,1);
        county_area_merge{uu+begin_time_01,2}=infor_county{id_temp,2};
        county_area_merge{uu+begin_time_01,3}=infor_county{id_temp,3};
        county_area_merge{uu+begin_time_01,4}=infor_county{id_temp,1};
        county_area_merge{uu+begin_time_01,5}=Irr_Area_county_merge_final(uu,1);
        county_area_merge{uu+begin_time_01,6}=Irr_Area_county_merge_final(uu,2);
    end
    

    
    begin_time=begin_time+length(Irr_Area_county);
    begin_time_01=begin_time_01+length(Irr_Area_county_merge_final);
    begin_time_02=begin_time_02+length(city_all);
     
end

%%
xlswrite([Cesus_IrrArea_data_local,num2str(year_map),'\County_area_original.xlsx'],County_Irr_area_all_province);
xlswrite([Cesus_IrrArea_data_local,num2str(year_map),'\County_area_merge.xlsx'],county_area_merge);
xlswrite([Cesus_IrrArea_data_local,num2str(year_map),'\City_area_merge.xlsx'],Irr_Area_city);

% save ([ID_loc,num2str(year_map),'\county_area_merge.mat'], 'county_area_merge','-v7.3');
save ([ID_loc,num2str(year_map),'\City_crop_id_2000.mat'], 'City_crop_id_2000','-v7.3');
save ([ID_loc,num2str(year_map),'\County_crop_id_2000.mat'], 'County_crop_id_2000','-v7.3');

geotiffwrite([Cesus_IrrArea_data_local,num2str(year_map),'\City_ID_new_250.tif'],City_ID_new,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite([Cesus_IrrArea_data_local,num2str(year_map),'\County_ID_new_250.tif'],County_ID_new,Ref, 'GeoKeyDirectoryTag', data_GeoInfor.GeoTIFFTags.GeoKeyDirectoryTag);


