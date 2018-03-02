pro setn, n, nmax, mi, ma, p, q
; SETN.PRO is a short script to return the value of n to be used to set up ratio calculations
; 
; Inputs:
;   nmax - maximum size to return
;   mi - min struct
;   ma - maj struct
;   p - minor isotopic index
;   q - major isotopic index
;
; Output:
;   n - size of matrix to contain ratio calculations

;#################################################################################################
; set up correct tags to pass to next section
getname, ma.f(q), majgas
gettagname, ma, majgas+'no', majtag


getname, mi.f(p), mingas
gettagname, mi, mingas+'no', mintag
;#################################################################################################


;#################################################################################################
; A simple set of conditionals

; if the number of minor isotope peaks is less than the number of major isotope peaks, continue
if (mi.(mintag) lt ma.(majtag)) eq 1 then begin

  ; now if the number of peaks of the minor isotope is less than nmax, use that. Otherwise,
  ; use nmax.
  if (mi.(mintag) lt nmax) then begin
    n=mi.(mintag)
  endif else begin
    n=nmax
  endelse

  ; now if the number of major peaks is <= number of minor peaks, examine that in relation to nmax.
  ; If it's < nmax, use that. Otherwise, use nmax.
endif else begin
  if (ma.(majtag) lt nmax) then begin
    n=ma.(majtag)
  endif else begin
    n=nmax
  endelse
endelse
;#################################################################################################

;;#################################################################################################
;; A simple set of conditionals
;
;; if the number of minor isotope peaks is less than the number of major isotope peaks, continue
;if (minpeakno(p) lt majpeakno(q)) eq 1 then begin
;  
;  ; now if the number of peaks of the minor isotope is less than nmax, use that. Otherwise,
;  ; use nmax.
;  if (minpeakno(p) lt nmax) then begin
;    n=minpeakno(p)
;  endif else begin
;    n=nmax
;  endelse
;  
;; now if the number of major peaks is <= number of minor peaks, examine that in relation to nmax.
;; If it's < nmax, use that. Otherwise, use nmax.
;endif else begin
;  if (majpeakno(q) lt nmax) then begin
;    n=majpeakno(q)
;  endif else begin
;    n=nmax
;  endelse
;endelse
;;#################################################################################################

end