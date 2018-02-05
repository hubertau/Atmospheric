; compare real and simulated data

cd, '/home/ball4321/MPhysProject'

restore, 'rfm/ratioday30km'
restore, 'jan04averaged'

;specnum=n_elements(flist)
specnum=indices[0,n_elements(indices[0,*])-1]

; calculate error for unperturbed ratio
unptotalerr=sqrt(stdsim[*,*,0]^2+unprdmerr[*,*,0]^2/specnum)
;unptotalerr=stdsim[column,row,0]^2+unprdmerr[column,row,0]^2/specnum

; calculate error for the perturbed ratio
ptotalerr=sqrt(stdsim[*,*,1]^2+prdmerr[*,*,0]^2/specnum)
;ptotalerr=stdsim[column,row,1]^2+prdmerr[column,row,0]^2/specnum

; propagating the error through the percentage change calculation:
totalsimerr=sqrt(unptotalerr^2+ptotalerr^2)

number=n_elements(flist)

; real
realratio=make_array(10,10)
totalrealerr=make_array(10,10)
for z=0, n-1 do begin
  for y=0, n-1 do begin
    realratio[z,y]=avgreal1(mincoll[0,y])/avgreal1(majcoll[0,z])
    totalrealerr[z,y]=sqrt((stdreal1(mincoll[0,y])/(avgreal1(mincoll[0,y])*sqrt(number)))^2+(stdreal1(majcoll[0,z])/(avgreal1(mincoll[0,y])*sqrt(n)))^2)
  endfor
endfor
; add in sqrt(n)
; ACE-FTS, MIPAS, google isotopic
; journals: ACP JGR AMT
; make wavenumber axis starting at 0 going in 0.025
; look at D2O

deltareal=1000*(realratio-unpratio[*,*,0])/(unpratio[*,*,0])

delvar, y, z

end
