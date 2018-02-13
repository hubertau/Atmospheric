; compare real and simulated data

;#################################################################################################
; set the directory and load in simulated and real data

cd, '/home/ball4321/MPhysProject'

restore, 'rfm/ratioday30km' ; simulated data
restore, 'jan04averaged'    ; measured data

pratio=pratio[*,*,0]
unpratio=unpratio[*,*,0]

;pratio=mean(pratio,dimension=3)
;unpratio=mean(unpratio,dimension=3)

;#################################################################################################


;#################################################################################################
; measured data errors

; set variable 'number' to divide the standard deviation through by.
number=n_elements(data(*,0))

; run apodisation script. This is smoothing of the data
@apodise.pro

; create arrays to contain necessary data
realratio=make_array(n,n)
realvar=make_array(n,n)

; fill the arrays
for z=0, n-1 do begin
  for y=0, n-1 do begin
    realratio[z,y]=newapodise(1,mincoll[0,y])/newapodise(1,majcoll[0,z])
    realvar[z,y]=newapodise(2,mincoll[0,y])/number+newapodise(2,majcoll[0,z])/number
;    totalrealerr[z,y]=sqrt((stdreal1(mincoll[0,y])/(newapodise(1,mincoll[0,y]+27400)*sqrt(number)))^2 + (stdreal1(majcoll[0,z])/(newapodise(1,majcoll[0,z]+27400)*sqrt(number)))^2)
  endfor
endfor

;#################################################################################################


;#################################################################################################
; prepare derivatives for the delta variance calculation.

; derivative for measured ratios
dm=20/(realratio-unpratio)

; derivative for unperturbed ratios
d0=20*(realratio-pratio)/((pratio-unpratio)^2)

; derivative for perturbed ratios
dp=20*(unpratio-realratio)/((pratio-unpratio)^2)

;#################################################################################################


;#################################################################################################
; prepare terms for final addition

; term for measured variance
err1=dm^2*realvar

; term for unperturbed variance
err2=d0^2*varsim[*,*,0]

; term for perturbed variance
err3=dp^2*varsim[*,*,1]

; term for perturbed-unperturbed covariance
err4=2*dp*d0*cov

;#################################################################################################


;#################################################################################################
; calcalate estimate for delta, and its error

delta=20*(realratio-unpratio)/(pratio-unpratio)

deltavar=err1+err2+err3+err4

;#################################################################################################


;#################################################################################################
; display results

deltastd=sqrt(deltavar)
x=deltastd/delta
width=n_elements(x(*,0))
print, 'delta:'
print, delta
print, 'deltastd/delta:'
print, x
print, 'minimum relative error:'
print, min(abs(x),I), '    indices:', I mod width +1, ' (column)', floor(I/width)+1, ' (row)'

;#################################################################################################

delvar, y, z

end
