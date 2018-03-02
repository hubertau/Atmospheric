pro Fill, n, unp, con, ma, mi, rat
; FILL.PRO runs through the different atmospheric conditions specified in the matrix 'condition',
;   filling in the ratios for the different conditions. This requires nesting loaddata within.
;   
;   Inputs:
;     n - take nxn ratios
;     unp - for majcoll and mincoll
;     con - to feed into loaddata
;     ma, mi - to feed into loaddata
;     
;   Outputs:
;     rat - struct to contain unperturbed and perturbed ratios

;#################################################################################################
; fill in the elements of unpratio and pratio using a for loop.

foreach a, con.condition, index do begin
  
  ; Run loaddata to give different atmospheric condition data
  loaddata, con, a, unp, ma, mi, majjac, minjac
  
  ; fill in unpratio. Each element will be minor isotope/major isotope
  for z=0, n-1 do begin
    for y=0, n-1 do begin
      rat.unp[z,y,index]=unp.r(rat.mincoll[0,y])/unp.r(rat.majcoll[0,z])
    endfor
  endfor
  
  ; perturb spectrum r to take perturbed ratios
  getname, ma.f(con.q), name
  gettagname, ma, name, majtag
  getname, mi.f(con.p), name
  gettagname, mi, name, mintag
  pr=unp.r-ma.(majtag)*unp.r+mi.(mintag)*unp.r
  
  ; fill in pratio. Each element will be minor isotope/major isotope
  for z=0, n-1 do begin
    for y=0, n-1 do begin
      rat.p[z,y,index]=pr(rat.mincoll[0,y])/pr(rat.majcoll[0,z])
    endfor
  endfor
  
endforeach
;#################################################################################################

end