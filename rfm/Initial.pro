; Initial. 
; 
; Last edit 30/01/18
; 
; This is the script to run for SIMULATED Data. As of writing, 5 atmospheric conditions were taken, and are listed in 'condition'.
; Altitude specifies the altitude at which the data is simulated.
; The wavenumber range in which this is all conducted is 700-800cm^-1
; loaddata.pro loads the data using the rfmrd procedure, giving outputs of unperturbed spectra, the peak indices of
;   the peaks sensitive to the major isotope changes and the minor isotope changes.
; collate.pro then takes the processed output from loaddata.pro to produce 'mincoll' and 'majcoll', which collects
;   indices of the top 10 peaks sensitive to major and minor isotope changes, and the wavenumbers corresponding, and the majoryr/minoryr values
; unpratio are the unperturbed ratios: the ratios between the identified peaks (major to minor) in the unperturbed spectrum
; pratio are are the perturbed ratios: the ratios between the identified peaks (major to minor) in the perturbed spectrum
; unprdmerr and rdmerr are the random errors (assuming an error of 30), with only 1 real spectrum averaged.
; pchange is the percentage change, PER PERCENTAGE CHANGE OF ISOTOPIC RATIO.
; finally, totalerr is the total error of a specified percentage change.

CD, '/home/ball4321/MPhysProject/rfm'

condition=['day','ngt','sum', 'win', 'equ']
c=0
atm=condition[c]           ; specify the atmospheric conditions of the data
altitude=30000        ; specify the altitude at which to consider data
savename=altitude     ; useful later if saving is enabled

p=8 ; p is the index number for MINOR
q=1 ; q is the index number for MAJOR

loaddata, atm, altitude, w, r, majoryr, minoryr, majpeakindices, minpeakindices, majpeakno, minpeakno, majpeakindex, minpeakindex, major, minor

; set n: if n is less than 10 take n, otherwise take 10.
if (minpeakno(p) lt majpeakno(q)) eq 1 then begin
  if (minpeakno(p) lt 10) then begin
    n=minpeakno(p) ; the number of peaks to take
  endif else begin
    n=10
  endelse
endif else begin
  if (majpeakno(q) lt 10) then begin
    n=majpeakno(q) ; the number of peaks to take
  endif else begin
    n=10
  endelse
endelse

collate, mincoll, minpeakno, p, minpeakindex, minoryr, w, n
collate, majcoll, majpeakno, q, majpeakindex, majoryr, w, n

base30=make_array(n,n)
for a=0, n-1 do begin
  for b=0, n-1 do begin
    base30[a,b]=mincoll[2,b]/majcoll[2,a]
  endfor
endfor

; ratios (10x10), gas (p), gas (q), atm, altitude
contrast=make_array(n,n,n_elements(condition))


unpratio=make_array(n,n,n_elements(condition))   ; unperturbed ratios
pratio=make_array(n,n,n_elements(condition))     ; perturbed ratios
unprdmerr=make_array(n,n,n_elements(condition))  ; unperturbed random errors
prdmerr=make_array(n,n,n_elements(condition))    ; perturbed random errors

avgsim=make_array(n,n,2) ; this will contain the ratios, averaged
stdsim=make_array(n,n,2) ; the standard deviation of the ratios, over different atmospheric conditions

fill, savename, p, q, n, w, r, minoryr, majoryr, mincoll, majcoll, contrast, condition, unpratio, pratio, unprdmerr, prdmerr

ratiostat, unpratio, pratio, avgsim, stdsim

row=0 ; which ratio?
column=0
specnum=indgen(100000,start=1,/float) ; to generate the x-axis for plot - we want to plot against number of real spectra to be averaged over


; work out percentage change and error in perentage change. Divide by two to get percentage change per 1% isotopic concentration change.
pchange=100*(pratio[*,*,0]-unpratio[*,*,0])/(unpratio[*,*,0])/2

; these are generally expressed in delta values in the literature:
delta=10*pchange

; calculate error for unperturbed ratio
unptotalerr=sqrt(stdsim[column,row,0]^2+unprdmerr[column,row,0]^2/specnum)
;unptotalerr=stdsim[column,row,0]^2+unprdmerr[column,row,0]^2/specnum

; calculate error for the perturbed ratio
ptotalerr=sqrt(stdsim[column,row,1]^2+prdmerr[column,row,0]^2/specnum)
;ptotalerr=stdsim[column,row,1]^2+prdmerr[column,row,0]^2/specnum

; propagating the error through the percentage change calculation:
totalerr=sqrt(unptotalerr^2+ptotalerr^2)

; plot,specnum, 1/(totalerr),xtitle='number of real spectra averaged', ytitle='signal-to-noise ratio'

name='ratioday30km'
save, filename=name, n, mincoll, majcoll, w, r, pratio, unpratio, pchange, delta, avgsim, stdsim, prdmerr, unprdmerr

delvar, a, b

end