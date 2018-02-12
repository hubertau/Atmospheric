; Initial. 
; 
; Last edit 06/02/18
; 
; This is the script to run for SIMULATED Data. As of writing, 5 atmospheric conditions were taken, and are listed in 'condition'.
; Altitude specifies the altitude at which the data is simulated.
; The wavenumber range in which this is all conducted is 685-970cm^-1 - this is the MIPAS A band
; loaddata.pro loads the data using the rfmrd procedure, giving outputs of unperturbed spectra, the peak indices of
;   the peaks sensitive to the major isotope changes and the minor isotope changes.
; collate.pro then takes the processed output from loaddata.pro to produce 'mincoll' and 'majcoll', which collects
;   indices of the top 10 peaks sensitive to major and minor isotope changes, and the wavenumbers corresponding, and the majoryr/minoryr values
; unpratio are the unperturbed ratios: the ratios between the identified peaks (major to minor) in the unperturbed spectrum
; pratio are are the perturbed ratios: the ratios between the identified peaks (major to minor) in the perturbed spectrum
; unprdmerr and rdmerr are the random errors (assuming an error of 30), with only 1 real spectrum averaged.

;#################################################################################################
; change to correct directory and set up relevant atmospheric conditions and gas choice.

CD, '/home/ball4321/MPhysProject/rfm'

condition=['day','ngt','sum', 'win', 'equ']
c=0
atm=condition[c]      ; specify the atmospheric conditions of the data
altitude=30000        ; specify the altitude at which to consider data
savename=altitude     ; useful later if saving is enabled

p=0 ; p is the index number for MINOR
q=0 ; q is the index number for MAJOR

;#################################################################################################


;#################################################################################################
; First task: load in data using the conditions specified above. This is done by calling loaddata,
; and setting n conditionally on the number of peaks found.

; load data in from rfm outputs
loaddata, atm, altitude, w, r, majoryr, minoryr, majpeakindices, minpeakindices, majpeakno, minpeakno, majpeakindex, minpeakindex, major, minor

; set n: if n is less than nmax take n, otherwise take nmax.
nmax=10
if (minpeakno(p) lt majpeakno(q)) eq 1 then begin
  if (minpeakno(p) lt nmax) then begin
    n=minpeakno(p) ; the number of peaks to take
  endif else begin
    n=nmax
  endelse
endif else begin
  if (majpeakno(q) lt nmax) then begin
    n=majpeakno(q) ; the number of peaks to take
  endif else begin
    n=nmax
  endelse
endelse

; collate will collect the top n peaks sensitive to minor and major 
collate, mincoll, minpeakno, p, minpeakindex, minoryr, w, n
collate, majcoll, majpeakno, q, majpeakindex, majoryr, w, n

;#################################################################################################


;#################################################################################################
; Next: calculate the relevant ratios and their relative errors. This is the ratios between lines
; sensitive to minor isotopic change to major isotopic change, for both unperturbed and perturbed cases.
; One more call is made to loaddata using default settings to ensure passing the right arrays to saving

;base30=make_array(n,n)
;for a=0, n-1 do begin
;  for b=0, n-1 do begin
;    base30[a,b]=mincoll[2,b]/majcoll[2,a]
;  endfor
;endfor

unpratio=make_array(n,n,n_elements(condition))   ; unperturbed ratios
pratio=make_array(n,n,n_elements(condition))     ; perturbed ratios
unprdmerr=make_array(n,n,n_elements(condition))  ; unperturbed random errors
prdmerr=make_array(n,n,n_elements(condition))    ; perturbed random errors

avgsim=make_array(n,n,2) ; this will contain the ratios, averaged over atmospheric conditions
stdsim=make_array(n,n,2) ; the standard deviation of the ratios, over different atmospheric conditions
varsim=make_array(n,n,2) ; the variance of the ratios, over different atmospheric conditions


; fill.pro will fill in the ratios for different atmospheric conditions
; unprdmerr and prdmerr are output as RELATIVE errors
fill, savename, p, q, n, w, r, minoryr, majoryr, mincoll, majcoll, contrast, condition, unpratio, pratio, pr

; rerun of loaddata with day conditions to pass on to save.
loaddata, atm, altitude, w, r, majoryr, minoryr, majpeakindices, minpeakindices, majpeakno, minpeakno, majpeakindex, minpeakindex, major, minor

; calculate average ratios and standard deviations for these ratios over different atmospheric conditions.
ratiostat, unpratio, pratio, avgsim, stdsim, varsim, cov

;row=0 ; which ratio?
;column=0
;specnum=indgen(100000,start=1,/float) ; to generate the x-axis for plot - we want to plot against number of real spectra to be averaged over
;; work out percentage change and error in perentage change. Divide by two to get percentage change per 1% isotopic concentration change.
;pchange=50*(pratio[*,*,0]-unpratio[*,*,0])/(unpratio[*,*,0])
;
;; these are generally expressed in delta values in the literature:
;delta=10*pchange
;
;; calculate error for unperturbed ratio
;unptotalerr=sqrt(stdsim[column,row,0]^2+unprdmerr[column,row,0]^2/specnum)
;;unptotalerr=stdsim[column,row,0]^2+unprdmerr[column,row,0]^2/specnum
;
;; calculate error for the perturbed ratio
;ptotalerr=sqrt(stdsim[column,row,1]^2+prdmerr[column,row,0]^2/specnum)
;;ptotalerr=stdsim[column,row,1]^2+prdmerr[column,row,0]^2/specnum
;
;; propagating the error through the percentage change calculation:
;totalerr=sqrt(unptotalerr^2+ptotalerr^2)
;
;; plot,specnum, 1/(totalerr),xtitle='number of real spectra averaged', ytitle='signal-to-noise ratio'

;#################################################################################################


name='ratioday30km'
save, filename=name, n, mincoll, majcoll, minoryr, majoryr, w, r, pratio, unpratio, avgsim, stdsim, pr, varsim, cov

delvar, a, b

end