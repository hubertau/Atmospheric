pro loaddata, atm, altitude, w, r, majoryr, minoryr, majpeakindices, minpeakindices, majpeakno, minpeakno, majpeakindex, minpeakindex, major, minor

;LoadData takes the (a) atmospheric condition and (b) altitude and extracts all the relevant data for all gases available.

; specify search directory to pass to filesearch script
libdir = '/home/ball4321/MPhysProject/rfm/' + atm + '/'
libdir = libdir + strtrim(altitude,2) + '/685end/'

; call filesearch script, which splits the major and minor isotopes
@filesearch

; use rfmrd procedure to read the unperturbed spectrum
rfmrd,main,w,r


; create an array to store the results of the reads (major isotopologues)
majoryr=make_array(n_elements(major),n_elements(r),/double) ; divided by r

for a=0,(n_elements(major)-1) do begin
  rfmrd,major[a],w,k
  majoryr[a,*]=k/r ; divided by the unpertubed spectrum
endfor



; create an array to store the results of the reads (minor isotopologues)
minoryr=make_array(n_elements(minor),n_elements(r),/double) ; divided by r

for a=0,(n_elements(minor)-1) do begin
  rfmrd,minor[a],w,k
  minoryr[a,*]=k/r ; divided by the unpertubed spectrum
endfor



; counting peaks
threshold=[0.1,0.1,0.1,0.1]
peakcount, majoryr, majpeakindices, majpeakno, majpeakindex, threshold

threshold=[0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1]
peakcount, minoryr, minpeakindices, minpeakno, minpeakindex, threshold


end