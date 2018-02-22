pro loaddata, con, condc, unp, maj, min
; LOADDATA.PRO takes the (a) atmospheric condition and
;   (b) altitude and extracts all the relevant data for all gases available.
;
; Inputs:
;   atm - which atmospheric condition to run the script with. Default set to day.
;   altitude - altitude the read data is to be at. Default set to 30km.
;
; Outputs:
;   unp - unperturbed data. This and the two following structs contain the following:
;           (a) radiance data
;           (b) peak indices
;           (c) number of peaks counted
;           (d) files counted in the struct
;   maj - major isotopic data
;   min - minor isotopic data

;#################################################################################################

altitude=con.altitude
atm=con.condition(where(con.condition eq condc))

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

; store the result in unp struct
unp=create_struct(unp,'w',w,'r',r)

foreach a, maj.f do begin
;  rfmrd,major[a],w,k
  rfmrd, a, w, k
  
  ; divide by the unperturbed spectrum
  getname,a,temp
  maj=create_struct(maj,temp,k/r)

endforeach

foreach a, min.f do begin

  rfmrd, a, w, k
  
  ; divide by the unperturbed spectrum
  getname,a,temp
  min=create_struct(min,temp,k/r)

endforeach
;#################################################################################################


;#################################################################################################
; finally, count the peaks using peakcount.pro

threshold=0.05
peakcount, maj, threshold

threshold=0.05
peakcount, min, threshold
;#################################################################################################


end