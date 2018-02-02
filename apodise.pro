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


end