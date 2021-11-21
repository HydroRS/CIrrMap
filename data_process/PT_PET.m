function [ PET ] = PT_PET( alfa, delta,gamma, Rn, G, lamda)

% PET, Kg/s/m2
% alfa, PT coefficient,1
% delta, slope of the saturated vapor pressure curve(kPa °„C-1)
% gamma, psychrometric constant, kPa °„C-1
% Rn, net radiation for the canopy (W °§ m/2)
% G,  soil heat flux (W °§ m/2)
% lamda, latent heat of vaporization (J kg-1)

PET=max(alfa.*delta./(delta+gamma).*(Rn-G)./lamda,0);


end

