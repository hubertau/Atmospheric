pro peakcount, input, peakindices, peakno, peakindex, threshold
; PEAKCOUNT.PRO: script to count number of peaks in sets of data, by assuming a baseline of 0
;   (which is reasonable for the jacobians) and then recording start and end points of peaks above
;   a certain threshold (percentage between 0 and max of the data) with a minimum number of points.
;   
;   Inputs:
;     input - the input data. This will be majoryr or minoryr
;     threshold - matrix of thresholds for each jacobian/spectrum to use.
;   
;   Outputs:
;     peakindex - the most important output. This contains the indices of the peak itself, not a 
;       range of values
;     peakno - the number of peaks counted.
;     peakindices - the ranges of values for each peak, counted as the peak rises above the
;       threshold and then falls back down again. 


;#################################################################################################
; Initialise output arrays.

c=n_elements(input[*,0])
r=n_elements(input[0,*])

; create peakno with the number of columns equal to the number of major/minor isotopes being
; examined.
peakno=make_array(c,1)

; create peakindices with the same number of columns as peakno, but with an extra dimension of
; size 2 to store start and finish values for peaks.
peakindices=make_array(c,r,2,/double)

; create peakindex to with the same number of columns as peakno, but without the extra dimension
; of peakindices because it will just store the peaks.
peakindex=make_array(c,r)
;#################################################################################################


;#################################################################################################
; count along number of files to sweep through
for a=0, (c-1) do begin
  
  ; first obtain the maximum value of the dataset being worked with, i.e. the specific column in
  ; input.
  maxy=max(input[a,*])
  
  ; initialise peakcounter at 0. This will be off (0) whenever a peak is not being counted, and
  ; on (1) whenever a peak IS being counted.
  peakcounter=0
  
  ; count along number of points within each file to sweep through, i.e. the number of rows.
  for b=0, (r-1) do begin
    
    ; first, if the point is above the threshold, and no peak is currently being counted, then
    ; begin counting and store value. The first conditional is only satisfied if a peak is not
    ; already being counted, and a point is above the threshold.
    if (input[a,b] ge threshold[a]*maxy) and (peakcounter eq 0) then begin
      
      ; turn on peakcounting variable
      peakcounter=1
      
      ; store the START value of the range in which the peak will reside
      peakindices[a,peakno[a],0]=b
      
    endif else begin
      
      ; cease peak counting if points drop below threshold and the peakcounting variable is on
      if (input[a,b] lt threshold[a]*maxy) and (peakcounter eq 1) then begin
        
        ; store the END value of the range in which the peak will reside
        peakindices[a,peakno[a],1]=b
        
        ; use a dummy variable to obtain the max value witin the range stored. max(...,I) gives
        ; I as the index of where the max value is.
        dummy=max(input(a,peakindices[a,peakno[a],0]:peakindices[a,peakno[a],1]),I)
        
        ; However, the index I given is within the range specified as input to the max function.
        ; Therefore, add on the index value of the start peak value. A quick conceptual check:
        ; if I is 0, i.e. the peak consists just of one point, then nothing will be added to
        ; the peakindex. That is correct.
        peakindex[a,peakno[a]]=I+peakindices[a,peakno[a],0]
        
        ; Now that the processing is complete for this particular peak, turn off peak counting
        ; variable.
        peakcounter=0
        
        ; Finally, add one to the number of peaks counted.
        peakno[a]=peakno[a]+1
        
      endif
    endelse
  endfor
endfor
;#################################################################################################




end