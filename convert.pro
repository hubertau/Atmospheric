pro convert, num, delta, result
; num must be a column vector

k=size(num)
if k(0) eq 0 then begin
  result=num
endif else begin
  result=make_array(2,k(2))
endelse


width=n_elements(delta(*,0))
result(0,*)=num mod width
result(1,*)=floor(num/width)


end