pro peakcount, input, threshold
; PEAKCOUNT.PRO: script to count number of peaks in sets of data, by assuming a baseline of 0
;   (which is reasonable for the jacobians) and then recording start and end points of peaks above
;   a certain threshold (percentage between 0 and max of the data) with a minimum number of points.
;   
;   Inputs:
;     input - the input data. This will be a STRUCTURE containing the data.
;     threshold - matrix of thresholds for each jacobian/spectrum to use.
;   
;   Outputs:
;     input.(various) - the output will be numbers of peaks counted, indices of these peaks, and
;                       final index of the points.

;#################################################################################################

foreach a, input.f do begin
  
  ; getname is the script that extracts the isotope name from the path name
  getname, a, name
  
  ; gettagname then takes in a string in 'name' to find the tag index 'tindex' to be able to
  ; variable reference it in the following code. 
  gettagname, input, name, tindex
  
  ; first obtain the maximum value of the dataset being worked with
  maxy=max(input.(tindex))
  
  ; create the peakindices matrix to contain the start and end points of each peak range
  ; detected. This will be overwritten each time ,which is why its creation is WITHIN
  ; the foreach loop that goes along all the isotopic files.
  peakindices=make_array(2,n_elements(input.(tindex)))
  
  ; create peakindex
  peakindex=make_array(n_elements(input.(tindex)))
  
  ; create the relevant tags in the struct. Each gas has two extra tags, along with the data:
  ; (a) peak indices, in e.g. 'CO2I1IDX' and
  ; (b) the number of peaks, in e.g. 'CO2I1NO'
  input=create_struct(input,$
    name+'no',0)
  
  ; initialise peakcounter at 0. This will be off (0) whenever a peak is not being counted, and
  ; on (1) whenever a peak IS being counted.
  peakcounter=0
  
  foreach b, input.(tindex), index do begin

    ; first, if the point is above the threshold, and no peak is currently being counted, then
    ; begin counting and store value. The first conditional is only satisfied if a peak is not
    ; already being counted, and a point is above the threshold.
    if (b ge threshold*maxy) and (peakcounter eq 0) then begin

      ; turn on peakcounting variable
      peakcounter=1

      ; store the START value of the range in which the peak will reside
      gettagname, input, name+'no', no
      peakindices[0,input.(no)]=index

    endif else begin

      ; cease peak counting if points drop below threshold and the peakcounting variable is on
      if (b lt threshold*maxy) and (peakcounter eq 1) then begin

        ; store the END value of the range in which the peak will reside
        peakindices[1,input.(no)]=index

        ; use a dummy variable to obtain the max value witin the range stored. max(...,I) gives
        ; I as the index of where the max value is.
        dummy=max(input.(tindex)(peakindices[0,input.(no)]:peakindices[1,input.(no)]),I)

        ; However, the index I given is within the range specified as input to the max function.
        ; Therefore, add on the index value of the start peak value. A quick conceptual check:
        ; if I is 0, i.e. the peak consists just of one point, then nothing will be added to
        ; the peakindex matrix entry in the struct. That is correct.
        peakindex(input.(no))=I+peakindices[0,input.(no)]

        ; Now that the processing is complete for this particular peak, turn off peak counting
        ; variable.
        peakcounter=0

        ; Finally, add one to the number of peaks counted.
        input.(no)=input.(no)+1

      endif
    endelse
  endforeach
  input=create_struct(input, name+'IDX',peakindex(0:input.(no)-1))
endforeach
;#################################################################################################

end