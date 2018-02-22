pro ratiostat, n, rat
; RATIOSTAT.PRO is a short script to calculate the variance and covariance of the unperturbed
;   and perturbed ratios.
; 
;   Inputs:
;     n - indicates how many ratios
;     unpratio - unperturbed ratios, over different atmospheric conditions
;     pratio - perturbed ratios, over different atmospheric conditions
;     
;   Outputs:
;     avg - matrix to contain the averaged ratios, over the atmospheric conditions
;     std - standard deviation of that average
;     var - variance of that average
;     cov - covariance between perturbed and unperturbed ratios
;

;#################################################################################################
; fill in avg, std, and var
rat.avg[*,*,0]=mean(rat.unp,dimension=3)
rat.avg[*,*,1]=mean(rat.p,dimension=3)

rat.var[*,*,0]=variance(rat.unp,dimension=3)
rat.var[*,*,1]=variance(rat.p,dimension=3)
;#################################################################################################


;#################################################################################################
; now calculate covariance
temp1=make_array(n,n,5)
temp2=make_array(n,n,5)

for i=0,4 do begin
  temp1[*,*,i]=rat.p[*,*,i]-rat.avg[*,*,1]
  temp2[*,*,i]=rat.unp[*,*,i]-rat.avg[*,*,0]
endfor

; divide by n-1 atmospheric conditions for SAMPLE variance.
rat=create_struct(rat,'cov',total(temp1*temp2,3)/4)
;#################################################################################################


end