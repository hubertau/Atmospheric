; compare real and simulated data

;#################################################################################################
; set the directory and load in simulated and real data

!PATH = Expand_Path('/home/ball4321/MPhysProject/coyote') + ':' + !PATH
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
; use script to generate apodisable real data

length=96401
;apodise columns:
; 0-new spectrum wavenumbers
; 1-old spectrum wavenumbers
; 2-old spectrum radiances
; 3-old spectrum radiance variances 
apodise=make_array(4,length)
apodise(0,*)=indgen(length,/double)*0.025

for i=0,n_elements(wnospc)-1 do begin
  x=where(abs(apodise(0,*)-wnospc(i)) lt 0.001)
  apodise(1,x)=wnospc(i)
  apodise(2,x)=avgreal(i)
  apodise(3,x)=varreal(i)
endfor

;remap mincoll and majcoll
for i=0,n_elements(mincoll(0,*))-1 do begin
  x=where(abs(apodise(0,*)-mincoll(1,i)) lt 0.001)
  mincoll(0,i)=x
endfor
for i=0,n_elements(majcoll(0,*))-1 do begin
  x=where(abs(apodise(0,*)-majcoll(1,i)) lt 0.001)
  majcoll(0,i)=x
endfor

newapodise=make_array(3,length)
newapodise(0,*)=apodise(0,*)  ;wavenumbers
newapodise(1,*)=apodise(2,*)  ;radiances
newapodise(2,*)=apodise(3,*)  ;variances

; now do apodisation
; a(-2)=0.0098, a(-1)=0.2385,0.5034,0.2385,0.0098
; functional form (U is original spectrum): A(i)=a(-2)*U(i-2)+a(-1)*U(i-1)+...+a(2)*U(i+2)

for i=2, n_elements(apodise(2,*))-3 do begin
  newapodise(1, i)=0.0098*apodise(2,i-2) $
    + 0.2385*apodise(2,i-1) $
    + 0.5034*apodise(2,i) $
    + 0.2385*apodise(2,i+1) $
    + 0.0098*apodise(2,i+2)
endfor
;#################################################################################################


;#################################################################################################
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


;#################################################################################################
; plotting delta against the errors

x1=reform(deltavar,1,n_elements(deltavar))
x2=reform(err1,1,n_elements(err1))
x3=reform(realvar,1,n_elements(realvar))
y1=reform(delta,1,n_elements(delta))

s1=sort(x1)
s2=sort(x2)
s3=sort(x3)

; scatter plot lowest 50 elements:

;cgscatter2d, x1(s1(0:50)), y1(s1(0:50)), $
;  xtitle='$\sigma$$\downtotal$', $
;  ytitle='delta estimate', $
;  title='50 points with lowest std deviations', $
;  fit=0, $
;  /window
;
;
;cgscatter2d, x2(s2(0:50)), y1(s2(0:50)), $
;  xtitle='$\sigma$$\downrm$', $
;  ytitle='delta estimate', $
;  title='50 points with lowest std deviations', $
;  fit=0, $
;  /window
;  
r1=0
r2=50

a=scatterplot(x1(s1(r1:r2)), y1(s1(r1:r2)), $
  xtitle='$\sigma^{2}_{total}$', $
  ytitle='delta estimate', $
  title='50 points with lowest std deviations',$ 
  layout=[1,3,1])
  
b=scatterplot(x2(s2(r1:r2)), y1(s2(r1:r2)), $
  xtitle='$err1$', $
  ytitle='delta estimate', $
  title='50 points with lowest std deviations',$
  /current, layout=[1,3,2])

c=scatterplot(x3(s3(r1:r2)), y1(s3(r1:r2)), $
  xtitle='$\sigma^{2}_{r_{m}}$', $
  ytitle='delta estimate', $
  title='50 points with lowest std deviations',$
  /current, layout=[1,3,3])

;convert changes the indices back into column/row to access the major and minor isotope lines used
convert, transpose(s1(0:6)), delta, result

;result(0,*) holds the major isotope number
;result(1,*) holds the minor isotope number
;#################################################################################################


delvar, y, z

end
