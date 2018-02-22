pro Fill, n, unp, con, maj, min, rat
; FILL.PRO runs through the different atmospheric conditions specified in the matrix 'condition',
;   filling in the ratios for the different conditions. This requires nesting loaddata within.
;   
;   Inputs:
;     
;   Outputs:
;     unpratio - ratios in the unperturbed regime
;     pratio - ratios in the perturbed regime
;     pr - 20 ppt perturbed r. Increased minor and decreased major.
;

;#################################################################################################
; fill in the elements of unpratio and pratio using a for loop.

foreach a, con.condition, index do begin
  
  ; Run loaddata to give different atmospheric condition data
  loaddata, con, a, unp, maj, min
  
  ; fill in unpratio. Each element will be minor isotope/major isotope
  for z=0, n-1 do begin
    for y=0, n-1 do begin
      rat.unp[z,y,index]=unp.r(rat.mincoll[0,y])/unp.r(rat.majcoll[0,z])
    endfor
  endfor
  
  ; perturb spectrum r to take perturbed ratios
  getname, maj.f(con.q), name
  gettagname, maj, name, majtag
  getname, min.f(con.p), name
  gettagname, min, name, mintag
  pr=unp.r-maj.(majtag)*unp.r+min.(mintag)*unp.r
  
  ; fill in pratio. Each element will be minor isotope/major isotope
  for z=0, n-1 do begin
    for y=0, n-1 do begin
      rat.p[z,y,index]=pr(rat.mincoll[0,y])/pr(rat.majcoll[0,z])
    endfor
  endfor
  
endforeach
;#################################################################################################

end