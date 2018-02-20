pro convert, num, delta, result
; CONVERT.PRO is a script to change the long one-dimensional index of a matrix into column and
;   row.
; 
;   Inputs:
;     num - a COLUMN vector of indices to be converted
;     delta - the delta estimate matrix, used to obtain desired dimensions.
;   
;   Outputs:
;     result - 2 column * n matrix, whose rows are pairs of (major, minor) isotope indices for
;               delta
;

;#################################################################################################
k=size(num)

; if the first element of size(num) is zero, then it's a single number (1x1) matrix.
if k(0) eq 0 then begin
  result=num
endif else begin
  ; otherwise, make an array with two columns and k(2) rows. That's the element of size(num)
  ; that gives its row number.
  result=make_array(2,k(2))
endelse

; width will tell us how much we need to divide by
width=n_elements(delta(*,0))
result(0,*)=num mod width
result(1,*)=floor(num/width)
;#################################################################################################


end