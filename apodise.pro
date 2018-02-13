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