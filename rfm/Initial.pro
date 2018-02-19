; Initial. 
; 
; Last edit 19/02/18
; 
; This is the script to run for SIMULATED Data. As of writing, 5 atmospheric conditions were
;  taken, and are listed in 'condition'.
;  
; Altitude specifies the altitude at which the data is simulated.
; 
; The wavenumber range in which this is all conducted is 685-2410cm^-1 - this is the overall
;  range of the MIPAS instrument. The script collate.pro checks for peaks identified outside
;  the MIPAS bands.
; 
; loaddata.pro loads the data using the rfmrd procedure, giving outputs of unperturbed
;   spectra, the peak indices of the peaks sensitive to the major isotope changes and the
;   minor isotope changes.
;   
; collate.pro then takes the processed output from loaddata.pro to produce 'mincoll'
;  and 'majcoll', which collects indices of the top 10 peaks sensitive to major and minor
;  isotope changes, and the wavenumbers corresponding, and the majoryr/minoryr values
;  
; unpratio are the unperturbed ratios: the ratios between the identified peaks
;  (major to minor) in the unperturbed spectrum
; pratio are are the perturbed ratios: the ratios between the identified peaks
;  (major to minor) in the perturbed spectrum

;#################################################################################################
; change to correct directory and set up relevant atmospheric conditions and gas choice.

CD, '/home/ball4321/MPhysProject/rfm'

condition=['day','ngt','sum', 'win', 'equ']
c=0
atm=condition[c]      ; specify the atmospheric conditions of the data
altitude=30000        ; specify the altitude at which to consider data
savename=altitude     ; useful later if saving is enabled

p=8 ; p is the index number for MINOR
q=1 ; q is the index number for MAJOR

;#################################################################################################


;#################################################################################################
; First task: load in data using the conditions specified above. This is done by calling loaddata,
; and setting n conditionally on the number of peaks found.

; load data in from rfm outputs
loaddata, $
  atm, $
  altitude, $
  w, $
  r, $
  majoryr, $
  minoryr, $
  majpeakindices, $
  minpeakindices, $
  majpeakno, $
  minpeakno, $
  majpeakindex, $
  minpeakindex, $
  major, $
  minor

; set n: if n is less than nmax take n, otherwise take nmax.
; Second argument of setn is nmax.
setn, n, 15, minpeakno, majpeakno, p, q

; collate will collect the top n peaks sensitive to minor and major 
collate, mincoll, minpeakno, p, minpeakindex, minoryr, w, n
collate, majcoll, majpeakno, q, majpeakindex, majoryr, w, n

;#################################################################################################


;#################################################################################################
; Next: calculate the relevant ratios. This is the ratios between lines sensitive to minor
; isotopic change to major isotopic change, for both unperturbed and perturbed cases.
; One more call is made to loaddata using default settings to ensure passing the right arrays
; to saving

; unperturbed ratios
unpratio=make_array(n,n,n_elements(condition))

; perturbed ratios
pratio=make_array(n,n,n_elements(condition))

; this will contain the ratios, averaged over atmospheric conditions
avgsim=make_array(n,n,2)

; the standard deviation of the ratios, over different atmospheric conditions
stdsim=make_array(n,n,2)

; the variance of the ratios, over different atmospheric conditions 
varsim=make_array(n,n,2)


; fill.pro will fill in the ratios for different atmospheric conditions
fill, $
  savename, $
  p, $
  q, $
  n, $
  w, $
  r, $
  minoryr, $
  majoryr, $
  mincoll, $
  majcoll, $
  condition, $
  unpratio, $
  pratio, $
  pr

; rerun of loaddata with day conditions to pass on to save.
loaddata, $
  atm, $
  altitude, $
  w, $
  r, $
  majoryr, $
  minoryr, $
  majpeakindices, $
  minpeakindices, $
  majpeakno, $
  minpeakno, $
  majpeakindex, $
  minpeakindex, $
  major, $
  minor

; calculate average ratios and standard deviations for these ratios over different atmospheric
; conditions.
ratiostat, n, unpratio, pratio, avgsim, stdsim, varsim, cov

;#################################################################################################

;#################################################################################################
; save the outputs

name='ratioday30km'
save, filename=name, $
  n, $
  mincoll, $
  majcoll, $
  minoryr, $
  majoryr, $
  w, $
  r, $
  pratio, $
  unpratio, $
  avgsim, $
  stdsim, $
  pr, $
  varsim, $
  cov
;#################################################################################################

delvar, a, b

end