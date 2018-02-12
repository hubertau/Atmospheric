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
; simulated errors

; number of spectral lines averaged over
specnum=n_elements(data(*,0))

; calculate relative error for unperturbed ratio
unptotalerr=sqrt((stdsim[*,*,0]/unpratio)^2 $ 
  +unprdmerr[*,*,0]^2/specnum)

; calculate relative error for the perturbed ratio
ptotalerr=sqrt((stdsim[*,*,1]/pratio)^2 $
  +prdmerr[*,*,0]^2/specnum)

;#################################################################################################


;#################################################################################################
; measured data errors

; set variable 'number' to divide the standard deviation through by.
number=n_elements(data(*,0))

; run apodisation script. This is smoothing of the data
@apodise.pro

; create arrays to contain necessary data
realratio=make_array(n,n)
totalrealerr=make_array(n,n)

; fill the arrays
for z=0, n-1 do begin
  for y=0, n-1 do begin
    realratio[z,y]=newapodise(1,mincoll[0,y]+27400)/newapodise(1,majcoll[0,z]+27400)
    totalrealerr[z,y]=sqrt((stdreal1(mincoll[0,y])/(newapodise(1,mincoll[0,y]+27400)*sqrt(number)))^2 $
      +(stdreal1(majcoll[0,z])/(newapodise(1,majcoll[0,z]+27400)*sqrt(number)))^2)
  endfor
endfor

;#################################################################################################


;#################################################################################################
; calcalate estimate for delta

delta=20*(realratio-unpratio)/(pratio-unpratio)

; calculate error for delta estimate
; get absolute errors
abs1=sqrt((realratio*totalrealerr)^2+(unpratio*unptotalerr)^2)
abs2=sqrt((pratio*ptotalerr)^2+(unpratio*unptotalerr)^2)

; to then relative errors to propagate through
rel1=abs1/(realratio-unpratio)
rel2=abs2/(pratio-unpratio)

; then propagate
deltaerr=sqrt(rel1^2+rel2^2)

;#################################################################################################

delvar, y, z

end
