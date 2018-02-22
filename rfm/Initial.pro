; Initial. 
; 
; Last edit 22/02/18
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
;  and 'majcoll', which collects indices of the top n peaks sensitive to major and minor
;  isotope changes, and the wavenumbers corresponding, and the majoryr/minoryr values
;  
; unpratio are the unperturbed ratios: the ratios between the identified peaks
;  (major to minor) in the unperturbed spectrum
; pratio are are the perturbed ratios: the ratios between the identified peaks
;  (major to minor) in the perturbed spectrum
; 
; All outputs are stored in relevant structures.
;

;#################################################################################################
; change to correct directory and set up relevant atmospheric conditions and gas choice.

CD, '/home/ball4321/MPhysProject/rfm'

condition=['day','ngt','sum', 'win', 'equ']
c=0
atm=condition[c]      ; specify the atmospheric conditions of the data
altitude=30000        ; specify the altitude at which to consider data

p=2 ; p is the index number for MINOR
q=1 ; q is the index number for MAJOR

con=create_struct('p',p,'q',q,'condition',condition,'atm',condition(c),'altitude',altitude)

;#################################################################################################


;#################################################################################################
; First task: load in data using the conditions specified above. This is done by calling loaddata,
; and setting n conditionally on the number of peaks found.

; load data in from rfm outputs
;loaddata, $
;  atm, $
;  altitude, $
;  w, $
;  r, $
;  majoryr, $
;  minoryr, $
;  majpeakindices, $
;  minpeakindices, $
;  majpeakno, $
;  minpeakno, $
;  majpeakindex, $
;  minpeakindex, $
;  major, $
;  minor
loaddata, con, atm, unp, maj, min

; set n: if n is less than nmax take n, otherwise take nmax.
; Second argument of setn is nmax.
setn, n, 15, min, maj, p, q

; add result to con structure
con=create_struct(con,'n',n)

; collate will collect the top n peaks sensitive to minor and major 
collate, mincoll, min, p, unp, n
collate, majcoll, maj, q, unp, n

;#################################################################################################


;#################################################################################################
; Next: calculate the relevant ratios. This is the ratios between lines sensitive to minor
; isotopic change to major isotopic change, for both unperturbed and perturbed cases.
; One more call is made to loaddata using default settings to ensure passing the right arrays
; to saving

rat=create_struct('unp',make_array(n,n,n_elements(condition)),$
  'p',make_array(n,n,n_elements(condition)),$
  'avg',make_array(n,n,2),$
  'var',make_array(n,n,2),$
  'mincoll',mincoll,$
  'majcoll',majcoll)

; fill.pro will fill in the ratios for different atmospheric conditions
fill, n, unp, con, maj, min, rat

; rerun of loaddata with day conditions to pass on to save.
loaddata, con, atm, unp, maj, min

; calculate average ratios and standard deviations for these ratios over different atmospheric
; conditions.
ratiostat, n, rat

;#################################################################################################

;#################################################################################################
; save the outputs

; rename stuctures
set=['con','unp','maj','min','rat']
temp=strtrim(string(c),2)
foreach a, set do void=execute(a+temp+'='+a)

name='ratio30km' + con.atm

void=execute('save,filename=name,con'+temp+',unp'+temp+',maj'+temp+',min'+temp+',rat'+temp)
;#################################################################################################

delvar, a, b, altitude, atm, c, condition, majcoll, mincoll, n, p, q, name, set, temp, void,$
  con, unp, maj, min, rat

end