; script to count number of peaks in sets of data, by assuming a baseline of 0 (which is reasonable for the jacobians)
; and then recording start and end points of peaks above a certain threshold (percentage between 0 and max of the data)
; with a minimum number of points
pro peakcount, input, peakindices, peakno, peakindex, threshold

peakno=make_array(n_elements(input[*,0]),1)
peakindices=make_array(n_elements(input[*,0]),n_elements(input[0,*]),2,/double)
peakindex=make_array(n_elements(input[*,0]),n_elements(input[0,*]))

; count along number of files to sweep through
for a=0, (n_elements(input[*,0])-1) do begin
  maxy=max(input[a,*])
  peakcounter=0
  ; count along number of points within each file to sweep through
  for b=0, (n_elements(input[0,*])-1) do begin
    ; first, if the point is above the threshold, and no peak is currently being counted, then begin counting and store value
    if (input[a,b] ge threshold[a]*maxy) and (peakcounter eq 0) then begin
      peakcounter=1
      peakindices[a,peakno[a],0]=b
    endif else begin
      ; cease peak counting if points drop below threshold and the peakcounter is going
      if (input[a,b] lt threshold[a]*maxy) and (peakcounter eq 1) then begin
        peakindices[a,peakno[a],1]=b
        dummy=max(input(a,peakindices[a,peakno[a],0]:peakindices[a,peakno[a],1]),I)
        peakindex[a,peakno[a]]=I+peakindices[a,peakno[a],0]
        peakcounter=0
        peakno[a]=peakno[a]+1
      endif
    endelse
  endfor
endfor



end