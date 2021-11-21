function density_diff = createFit(EVI_max_IRR, EVI_max_NonIRR, option, var_name)


% Force all inputs to be column vectors
EVI_max_IRR = EVI_max_IRR(:);
EVI_max_NonIRR=EVI_max_NonIRR(:);

XLim=[min([EVI_max_IRR;EVI_max_NonIRR]),max([EVI_max_IRR;EVI_max_NonIRR])];
XLim = XLim + [-1 1] * 0.01 * diff(XLim);
XGrid = linspace(XLim(1),XLim(2),10000);

% --- Create fit "fit 4"
pd1 = fitdist(EVI_max_IRR,'kernel','kernel','normal','support','unbounded');
YPlot01 = pdf(pd1,XGrid);
pd2 = fitdist(EVI_max_NonIRR,'kernel','kernel','normal','support','unbounded');
YPlot02 = pdf(pd2,XGrid);

% --Estimate Overlap
% y_d = [YPlot02(YPlot02<YPlot01) YPlot01(YPlot01<YPlot02)]; 
y_d = min([YPlot01; YPlot02], [], 1);
area_y1=trapz(XGrid,YPlot01);
area_y2=trapz(XGrid,YPlot02);
 area_int  = trapz(XGrid,y_d);
 non_overlap_area=1-area_int/(area_y1+area_y2-area_int);

 % estimate realative value diff of max density
 median_diff=abs(XGrid(YPlot02==max(YPlot02))-XGrid(YPlot01==max(YPlot01)));
 relative_median_diff=median_diff/(max(XGrid)-min(XGrid));
% relative_median_diff=0;
 % estimate overall overlap
 density_diff=non_overlap_area+relative_median_diff; % range [0,2]
 
 
% --PLot

if option==1
    
hLine = plot(XGrid,YPlot01,'Color',[1 0 0],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
legend('IRR_points');
hold on;
hLine= plot(XGrid,YPlot02,'Color',[0 0 1],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
legend('IRR-points','NoneIRR-points');
temp=strsplit(var_name,'_');
if length(temp)==1
    title(temp{1});
else
title([temp{1},' ', temp{2}]);
end
hold off;

% LegHandles(end+1) = hLine;
% LegText{end+1} = var_name;
%  
% % Create legend from accumulated handles and labels
% hLegend = legend(LegHandles,LegText,'Orientation', 'vertical', 'Location', 'NorthEast');
% set(hLegend,'Interpreter','none');

end



%%
% fiteype= fittype('1/(w*sqrt(pi/2))*exp(-power(x-u,2)/(2*power(w,2)))', 'independent', 'x', 'dependent', 'y');
% hist(EVI_max_IRR,range_IRR);
% h=findobj(gca,'Type','patch');
% set(h,'facecolor','r');%改变柱状图颜色'
% hold on;
% [fitobject,gof]  = fit(range_IRR',counts1','gauss1');
% plot(fitobject,'r')
% hold off;

% p = polyfit(range_IRR,counts1/sum(counts1),2);
% yfit=polyval(p,range_IRR);
% plot(range_IRR',yfit, 'r')

% 


% figure
% hist(EVI_max_NonIRR,range_NonIRR);
% h=findobj(gca,'Type','patch');
% set(h,'facecolor','b');%改变柱状图颜色'
% [fitobject,gof]  = fit(range_NonIRR',counts2','gauss1');
% hold on;
% plot(fitobject,'b')
% hold off;
