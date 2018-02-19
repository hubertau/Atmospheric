pro ratiostat, n, unpratio, pratio, avg, std, var, cov
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
avg[*,*,0]=mean(unpratio,dimension=3)
avg[*,*,1]=mean(pratio,dimension=3)

std[*,*,0]=stddev(unpratio,dimension=3)
std[*,*,1]=stddev(pratio,dimension=3)

var[*,*,0]=variance(unpratio,dimension=3)
var[*,*,1]=variance(pratio,dimension=3)
;#################################################################################################


;#################################################################################################
; now calculate covariance
temp1=make_array(n,n,5)
temp2=make_array(n,n,5)

for i=0,4 do begin
  temp1[*,*,i]=pratio[*,*,i]-avg[*,*,1]
  temp2[*,*,i]=unpratio[*,*,i]-avg[*,*,0]
endfor

; divide by n-1 atmospheric conditions for SAMPLE variance.
cov=total(temp1*temp2,3)/4
;#################################################################################################


end