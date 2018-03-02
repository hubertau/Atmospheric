function collate, input, input2, index, unp, n, iso
; COLLATE.PRO is to collect the peakfinding data into easy, visible matrices that
;   display the top n peaks that will be used to calculate ratios
; 
;   Inputs:
;     input - input major/minor struct
;     input2 - input major/minor JACOBIAN struct
;     index - which isotope?
;     unp - for the wavenumber data
;     n - size of ratio matrix to be taken.
;     iso - string of either 'major' or 'minor' to indicate type
;
;   Output:
;     collated - a 3xn matrix containing a column of indices, a column of wavenumbers
;                 and a column of spectral values.

;#################################################################################################
;prepare data from structures

; rpeak will contian the peakfinder data for RFM peaks
rpeak=unp.rpeak

; get data from k/(r+1) spectrum
getname, input.f(index), tag
gettagname, input, tag+'peak', tag1
pkr=input.(tag1)
pkr=pkr[*,sort(pkr[1,*])]

; get data from k spectrum. Further distill these by discarding any peak with relative
; weight less than 0.1.
getname, input2.f(index), tag
gettagname, input2, tag+'peak', tag2
pk=input2.(tag2)
weights=abs(pk[4,*]-0.1)
!null=min(weights,cutpk)

; now to check for whether each peak within pk has a corresponding peak in pkr, and in rpeak
; peakfinder.pro returns, in the 5th column, the WIDTH of the peak. Set all of these to -1
; by default so that if anywhere x or y are 0 it doens't mess with where(x).
x=make_array(n_elements(pk[1,0:cutpk]))-1
y=make_array(n_elements(pk[1,0:cutpk]))-1


foreach a, pk[1,0:cutpk], i do begin
  
  ;create the set that will contain the integers to be checked against pkr
  set=(a-0.025*0.5*pk[5,i])+indgen(pk[5,i]+1)*0.025
  
  ;check for intersection using Coyote's cgsetintersection, extracting indices from pkr and rpeak
  !null=cgsetintersection(round(set*1000),round(pkr[1,*]*1000),indices_b=indices_pkr,success=success)
  !null=cgsetintersection(round(set*1000),round(rpeak[1,*]*1000),indices_b=indices_rpeak,success=successr)
  
  ; now if both intersections are found, then 
  if (successr and success) eq 1 then begin
    
    ; now if there is more than one intersection, take the highest pkr value around.
    if n_elements(indices_pkr) gt 1 then begin
      !null=max(pkr[2,indices_pkr],pkrmax)
      x(i)=indices_pkr[pkrmax]
    endif else begin
      x(i)=indices_pkr
    endelse
    
    ; if there is more than one intersection, take the RFM peak closest to the pk peak.
    if n_elements(indices_rpeak) gt 1 then begin
      !null=min(abs(rpeak[1,indices_rpeak]-a),temp)
      y(i)=indices_rpeak[temp] ;index to feed into rpeak
    endif else begin
      y(i)=indices_rpeak
    endelse
    
  endif
  
endforeach

; collect results into peakindex. Set its size to x, which is the size of all the peaks
; to scan through. NOT equal to size of pk because we've specified weight boundary.
peakindex=make_array(3,n_elements(where(x ne -1)))

; if it's a minor isotope we're examining then just take the pk lines. If major, shift to RFM
; lines.
if iso eq 'minor' then begin
  
  ; the indices of elements in X that aren't -1 are the indices that indicate which pk line
  ; to take. This is because x was designed to be the size of pk, so any modified changes
  ; from -1 values are peaks to take.
  peakindex[0:1,*]=pk[0:1,where(x ne -1)]
  
endif else begin
  
  ; the elements in y are the indices to feed into rpeak to get the RFM lines. To know which
  ; these are, of course, check which ones aren't -1: use the where function. Then feed the
  ; resulting array into y to get the indices for rpeak.
  peakindex[0:1,*]=rpeak[0:1,y(where(y ne -1))]
  
endelse

; enter pkr values for the peaks found. This is necessary to find the most sensitive lines.
peakindex[2,*]=pkr[2,x(where(x ne -1))]

;#################################################################################################
; First, use the data in peakno to determine the size of the collated array.
; Then, take the appropriate column of peakindex to get the wavenumber indices
; Which we can then use to get the actual wavenumber values
; and also the minoryr/majoryr values for the data. This is useful for visual verifiation the
;   sorting has worked
; column 1: indices of peaks, 
; column 2: corresponding wavenumbers,
; column 3: corresponding peak (radiance) values

collated=peakindex[0:2,*]
;#################################################################################################


;#################################################################################################
; However, the peakfinding algorithm may have collected peaks that are not within the MIPAS bands!
; Therefore, the following code is to weed these out and delete them BEFORE the sorting.
; The MIPAS Bands are:
;   A: 685-970cm^-1
;   AB: 1020-1170cm^-1
;   B: 1215-1500cm^-1
;   C: 1570-1750cm^-1
;   D: 1820-2410cm^-1

; create array to store these band values:
b=[[685,970],$
  [1020,1170],$
  [1215,1500],$
  [1570,1750],$
  [1820,2410]]

; Check bands using a for-loop:
for a=0,3 do begin
  
  ; first create logical array indicating where wavenumbers are >= upper bound
  ; of one band
  t1=(collated[1,*] ge b[1,a])
  
  ; then create logical array indicating where wavenumbers are <= lower bound
  ; of next band
  t2=(collated[1,*] le b[0,a+1])
  
  ; then create logical array indicating where these agree
  t3=t1 eq t2
  
  ; next, obtain indices of where these agree. /null allows for !NULL output
  ; if the where function finds nothing, which then has no effect when passed
  ; into an array as an index (i.e. the next line)
  t=where(t3 eq 1, /null)
  
  ; finally, set the ones found to be outside the particular MIPAS band scanned
  ; in this iteration of the for loop to -10. This is an arbitrary number, and
  ; just needs to be small enough that it won't appear in the top n peaks
  ; selected in the next part.
  collated[2,t]=-10

endfor
;#################################################################################################


;#################################################################################################
; finally sort the data so it only takes the top 10 peaks, THAT ARE WITHIN THE MIPAS BANDS

; sort(A) where A is an array gives an array with indices of elements of A in ascending order.
; Of course, we want them in DESCENDING order, so reserve(sort(A)) will return the right indices.
; Finally, using these indices as inputsto the collated array to sort it. 
collated=collated[*,REVERSE(SORT(collated[2,*]))]

; glean the top n peaks as end of processing, remembering IDL indexes from 0, so 0:n-1 is required
; instead of 1:n.
collated=collated[*,0:n-1]
;#################################################################################################

return, collated

end