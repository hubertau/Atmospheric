pro loaddata, atm, altitude, w, r, majoryr, minoryr, majpeakindices, minpeakindices, majpeakno, minpeakno, majpeakindex, minpeakindex, major, minor
; LOADDATA.PRO takes the (a) atmospheric condition and
;   (b) altitude and extracts all the relevant data for all gases available.
;
; Inputs:
;   atm - which atmospheric condition to run the script with. Default set to day.
;   altitude - altitude the read data is to be at. Default set to 30km.
;
; Outputs:
;   w - wavenumbers
;   r - unperturbed spectrum
;   major - string column vector containing the major isotopes found.
;   minor - string column vector containing the minor isotopes found.
;   majoryr - matrix containing columns, corresponding to major isotopes, of jacobians/r
;   minoryr - matrix containing columns, corresponding to minor isotopes, of jacobians/r
;   majpeakindices - matrix containing the start and end indices of peaks found for all  major
;    isotopes
;   minpeakindices - matrix containing the start and end indices of peaks found for all minor
;    isotopes
;   majpeakno - contains the number of peaks found for each major isotope 
;   minpeakno - contains the number of peaks found for each minor isotope
;   majpeakindex - contains the index of the peaks themselves for the major isotopes
;   minpeakindex - contains the index of the peaks themselves for the minor isotopes


;#################################################################################################
; specify search directory to pass to filesearch script
libdir = '/home/ball4321/MPhysProject/rfm/' + atm + '/'
libdir = libdir + strtrim(altitude,2) + '/685end/'

; call filesearch script, which splits the major and minor isotopes
@filesearch
;#################################################################################################


;#################################################################################################
; Now read the data


; use rfmrd procedure to read the unperturbed spectrum
rfmrd,main,w,r

; create an array to store the results of the reads (major isotopologues)
majoryr=make_array(n_elements(major),n_elements(r),/double)

for a=0,(n_elements(major)-1) do begin
  rfmrd,major[a],w,k
  
  ; divide by the unpertubed spectrum
  majoryr[a,*]=k/r
endfor



; create an array to store the results of the reads (minor isotopologues)
minoryr=make_array(n_elements(minor),n_elements(r),/double)

for a=0,(n_elements(minor)-1) do begin
  rfmrd,minor[a],w,k
  
  ; divide by the unpertubed spectrum
  minoryr[a,*]=k/r
endfor
;#################################################################################################


;#################################################################################################
; finally, count the peaks using peakcount.pro

threshold=[0.1,0.1,0.1,0.1]
peakcount, majoryr, majpeakindices, majpeakno, majpeakindex, threshold

threshold=[0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1]
peakcount, minoryr, minpeakindices, minpeakno, minpeakindex, threshold
;#################################################################################################


end