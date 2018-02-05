; use script to generate apodisable real data

length=96401
apodise=make_array(3,length)
apodise(0,*)=indgen(length,/double)*0.025

for i=0,n_elements(wnospc)-1 do begin
  x=where(abs(apodise(0,*)-wnospc(i)) lt 0.001)
  apodise(1,x)=wnospc(i)
  apodise(2,x)=avgreal(i)
endfor

newapodise=make_array(2,length)
newapodise(0,*)=apodise(0,*)
newapodise(1,*)=apodise(2,*)

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

end