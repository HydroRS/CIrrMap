%% functions
function [RH]=SH2RH(SH, T, Pa)
% note:
%
% input: SH : Specific humidiy, 1 or kg/kg
%            T: air temperature, ℃
%              Pa: air pressure, Pa, surface pressure
T=T+273.15; % ℃--->K
RH=0.263.*Pa.*SH.*(exp(17.67.*(T-273.16)./(T-29.65))).^(-1);  % 单位：%
% RH=6.112.*exp(17.67.*(T-273.16)./(T-29.65)).*(0.378.*SH+0.622)./Pa./SH.*100; % 单位：%

end
