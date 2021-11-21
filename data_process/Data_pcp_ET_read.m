% Codes used to obtain training samples
clc;clear

% data location
modis_data_local='F:\Data_ZL\MODIS\';
land_loc='F:\Data_ZL\IrrMap\';
ET_loc='F:\Data_ZL\IrrMap\Envrioment\';
ID_loc='D:\Work_2021\Irr_Map_China\ID\';

% year for the land use map
year_map=2000;

%%  Data read
% read province crop Id
province_crop_id_2000=load([ID_loc,num2str(year_map),'\province_crop_id_2000.mat'], 'province_crop_id_2000');
province_crop_id_2000=province_crop_id_2000.province_crop_id_2000;

% read climate
Yangkun_climate_2000_mean=load([modis_data_local,num2str(year_map),...
    '\Yangkun_climate_2000_mean.mat'], 'Yangkun_climate_2000_mean');
Yangkun_climate_2000_mean=Yangkun_climate_2000_mean.Yangkun_climate_2000_mean;

% ET_id.mat
ET_id=load([ID_loc,num2str(year_map),'\ET_id.mat'], 'ET_id');
ET_id=ET_id.ET_id;

%% read envrionment variables

delta_pcp_ET=cell(31,1);
for kk=1:31
    kk
    ID=province_crop_id_2000{kk};
    ID_SM=ET_id{kk};

	ETm_current_province=0;
	
	for mm=4:10 % growth period,3月没有数据
	ETm=load([ET_loc,num2str(year_map),'\ETm',num2str(year_map),num2str(mm,'%02d'),'.mat']);
    ETm=ETm.ETm;
	 ETm=single(ETm); % transfer from int16 to single
     ETm(ETm==0)=NaN;  % remove ocean and water body values which is given a value of 0
     ETm= ETm/10; % transfer to unit of mm
	ETm_current_province=ETm_current_province+ETm(ET_id{kk});
	end
	 invalid_data_id=find(isnan(ETm_current_province)==1);
    if length(invalid_data_id)>=1
        valid_data_id=find(isnan(ETm_current_province)==0);
        ETm_current_province(invalid_data_id)=interp1(valid_data_id,ETm_current_province(valid_data_id),invalid_data_id,'neareast','extrap') ;
    end
	
    delta_pcp_ET{kk}(:,1)=ETm_current_province;
    delta_pcp_ET{kk}(:,2)=Yangkun_climate_2000_mean{kk}(:,1)-ETm_current_province; %pcp-ET
	delta_pcp_ET{kk}(:,3)=Yangkun_climate_2000_mean{kk}(:,1)./ETm_current_province; % aridity
	
    
end
%%
output_fold='F:\Data_ZL\MODIS\';
 save ([output_fold,num2str(year_map),'\delta_pcp_ET.mat'], 'delta_pcp_ET','-v7.3');




