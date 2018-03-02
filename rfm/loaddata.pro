pro loaddata, con, condc, unp, ma, mi, majjac, minjac
; LOADDATA.PRO takes the (a) atmospheric condition and
;   (b) altitude and extracts all the relevant data for all gases available.
;
; Inputs:
;   con - for con.altitude: tangent height
;   condc - to set condition.
;
; Outputs:
;   unp - unperturbed data. This and the two following structs contain the following:
;           (a) radiance data
;           (b) peak indices
;           (c) number of peaks counted
;           (d) files counted in the struct
;   ma - major isotopic data
;   mi - minor isotopic data

;#################################################################################################

altitude=con.altitude
atm=con.condition(where(con.condition eq condc))

; specify search directory to pass to filesearch script
libdir = '/home/ball4321/MPhysProject/rfm/' + atm + '/'
libdir = libdir + strtrim(altitude,2) + '/685en2/'

; call filesearch script, which splits the major and minor isotopes
@filesearch

unp=create_struct('f',main)
ma=create_struct('f',major)
majjac=create_struct('f',major)
mi=create_struct('f',minor)
minjac=create_struct('f',minor)
;#################################################################################################


;#################################################################################################
; Now read the data


; use rfmrd procedure to read the unperturbed spectrum
rfmrd,main,w,r

; store the result in unp struct
unp=create_struct(unp,'w',w,'r',r)

foreach a, ma.f do begin
;  rfmrd,major[a],w,k
  rfmrd, a, w, k
  
  ; divide by the unperturbed spectrum
  getname,a,temp
  ma=create_struct(ma,temp,k/(r+1))
  majjac=create_struct(majjac,temp,k)

endforeach

foreach a, mi.f do begin

  rfmrd, a, w, k
  
  ; divide by the unperturbed spectrum
  getname,a,temp
  mi=create_struct(mi,temp,k/(r+1))
  minjac=create_struct(minjac,temp,k)

endforeach
;#################################################################################################


;#################################################################################################
; finally, count the peaks using peakfinder.pro
foreach a, ma.f do begin
  
  ; find struct index for gas under question
  getname, a, name
  gettagname, ma, name, tag
  
  ; find peaks and enter into struct
  temp=peakfinder(ma.(tag),unp.w,npeaks=npeaks,/sort,/optimize,/silent)
  ma=create_struct(ma,name+'peak',temp,name+'no',npeaks)
  
  ; find peaks and enter into struct
  temp=peakfinder(majjac.(tag),unp.w,npeaks=npeaks,/sort,/optimize,/silent)
  majjac=create_struct(majjac,name+'peak',temp,name+'no',npeaks)
  
endforeach

foreach a, mi.f do begin
  
  ; find struct index for gas under question
  getname, a, name
  gettagname, mi, name, tag
  
  ; find peaks and enter into struct
  temp=peakfinder(mi.(tag),unp.w,npeaks=npeaks,/sort,/optimize,/silent)
  mi=create_struct(mi,name+'peak',temp,name+'no',npeaks)
  
  ; find peaks and enter into struct
  temp=peakfinder(minjac.(tag),unp.w,npeaks=npeaks,/sort,/optimize,/silent)
  minjac=create_struct(minjac,name+'peak',temp,name+'no',npeaks)
  
endforeach

; find peaks and enter into struct
rpeak=peakfinder(unp.r,unp.w,npeaks=npeaks,/sort,/optimize,/silent)
unp=create_struct(unp,'rpeak',rpeak,'rno',npeaks)

;#################################################################################################


end