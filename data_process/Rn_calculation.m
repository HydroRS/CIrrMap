function [ Rnet ] = Rn_calculation( albedo, Rad,  T )
%UNTITLED5 此处显示有关此函数的摘要
%   albdelo 反照率
% Rad, shortwave radiation (W/m2)
% SB, the Stefan‐Boltzmann constant (i.e., 5.6704 × 10?8, W · m ?2· K?4, or 4.903× 10?9, MJ · m ?2· K?4 day-1)
 % T is the air temperature (℃)
 SB=5.6704e-8;
 Ea=1-0.26.*exp(-7.77e-4.*(power(T,2))); % atmospheric emissivity, 0-1
 Es=0.97;  % surface emissivity, 0-1
 
Rnet=(1-albedo).*Rad+(Ea-Es).*SB.*power((273.15+T),4);
end

