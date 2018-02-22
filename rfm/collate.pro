pro collate, collated, input, index, unp, n
; COLLATE.PRO is to collect the peakfinding data into easy, visible matrices that
;   display the top n peaks that will be used to calculate ratios
; 
;   Inputs:
;     input - input struct
;     index - which isotope?
;     unp - for the wavenumber data
;     n - size of ratio matrix to be taken.
;
;   Output:
;     collated - a 3xn matrix containing a column of indices, a column of wavenumbers
;                 and a column of spectral values.

;#################################################################################################
;prepare data from structures

getname, input.f(index), tag
gettagname, input, tag+'IDX', tag1

peakindex=input.(tag1)

;#################################################################################################
; First, use the data in peakno to determine the size of the collated array.
; Then, take the appropriate column of peakindex to get the wavenumber indices
; Which we can then use to get the actual wavenumber values
; and also the minoryr/majoryr values for the data. This is useful for visual verifiation the
;   sorting has worked
; column 1: indices of peaks, column 2: corresponding wavenumbers, column 3: corresponding peak (radiance) values
collated=make_array(3,n_elements(peakindex))
collated[0,*]=peakindex
collated[1,*]=unp.w(collated[0,*])

getname, input.f(index), tag
gettagname, input, tag, tag1
collated[2,*]=input.(tag1)(collated[0,*])
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

end