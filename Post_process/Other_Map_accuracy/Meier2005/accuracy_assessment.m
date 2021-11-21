function [over_accuracy, kappa, Irr_Pa, NonIrr_Pa] = accuracy_assessment( obs,simu )

  % »ìÏý¾ØÕó
   %             simu01   simu 02
   % ¹Û²â01       x            x
   % ¹Û²â02       x            x
    [mat,order] = confusionmat(obs,simu);
    
    if length(mat)==1
        over_accuracy=1;
        kappa=1;
        Irr_Pa=1;
        NonIrr_Pa=1;
    else
    
    over_accuracy=(mat(1,1)+mat(2,2))/sum(sum(mat));
    pe=sum(mat)*sum(mat,2)/power(sum(sum(mat)),2);
    kappa=(over_accuracy-pe)/(1-pe);
    Irr_Pa=mat(2,2)/sum(mat(2,:));
    NonIrr_Pa=mat(1,1)/sum(mat(1,:));
    end

end

