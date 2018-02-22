;pro loaddata, atm, altitude, w, r, majoryr, minoryr, majpeakindices, minpeakindices, majpeakno, minpeakno, majpeakindex, minpeakindex, major, minor
pro loaddata, atm, altitude, unp, maj, min


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
libdir = libdir + strtrim(altitude,2) + '/685en2/'

; call filesearch script, which splits the major and minor isotopes
@filesearch

unp=create_struct('f',main)
maj=create_struct('f',major)
min=create_struct('f',minor)
;#################################################################################################


;#################################################################################################
; Now read the data


; use rfmrd procedure to read the unperturbed spectrum
rfmrd,main,w,r

unp=create_struct(unp,'w',w)

foreach a, maj.f do begin
;  rfmrd,major[a],w,k
  rfmrd, a, w, k
  
  ; divide by the unperturbed spectrum
;  majoryr[a,*]=k/r
  getname,a,temp
  maj=create_struct(maj,temp,k/r)

endforeach



; create an array to store the results of the reads (minor isotopologues)
minoryr=make_array(n_elements(minor),n_elements(r),/double)

foreach a, min.f do begin

  rfmrd, a, w, k
  
  ; divide by the unperturbed spectrum
  getname,a,temp
  min=create_struct(min,temp,k/r)

endforeach
;#################################################################################################


;#################################################################################################
; finally, count the peaks using peakcount.pro

;threshold=0.1*make_array(n_elements(majoryr[*,0]),1,/INTEGER,VALUE = 1)
;peakcount, majoryr, majpeakindices, majpeakno, majpeakindex, threshold
threshold=0.1
peakcount, maj, threshold

;threshold=0.1*make_array(n_elements(minoryr[*,0]),1,/INTEGER,VALUE = 1)
threshold=0.1
peakcount, min, threshold
;#################################################################################################


end