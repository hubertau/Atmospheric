pro setn, n, nmax, min, maj, p, q
; SETN.PRO is a short script to return the value of n to be used to set up ratio calculations
; 
; Inputs:
;   nmax - maximum size to return
;   mininput - array for minor isotope under consideration
;   majinput - array for major isotope 
;
; Output:
;   n - size of matrix to contain ratio calculations

getname, maj.f(q), majgas
gettagname, maj, majgas+'no', majtag


getname, min.f(p), mingas
gettagname, min, mingas+'no', mintag


;#################################################################################################
; A simple set of conditionals

; if the number of minor isotope peaks is less than the number of major isotope peaks, continue
if (min.(mintag) lt maj.(majtag)) eq 1 then begin

  ; now if the number of peaks of the minor isotope is less than nmax, use that. Otherwise,
  ; use nmax.
  if (min.(mintag) lt nmax) then begin
    n=min.(mintag)
  endif else begin
    n=nmax
  endelse

  ; now if the number of major peaks is <= number of minor peaks, examine that in relation to nmax.
  ; If it's < nmax, use that. Otherwise, use nmax.
endif else begin
  if (maj.(majtag) lt nmax) then begin
    n=maj.(majtag)
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