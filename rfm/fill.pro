pro Fill, savename, p, q, n, w, r, minoryr, majoryr, mincoll, majcoll, condition, unpratio, pratio, pr
; FILL.PRO runs through the different atmospheric conditions specified in the matrix 'condition',
;   filling in the ratios for the different conditions. This requires nesting loaddata within.
;   
;   Inputs:
;     savename - altitude. Default set to 30km
;     p - index indicating which minor isotope
;     q - index indicating which major isotope
;     n - nxn will indicate the number of ratios to take
;     w - wavenumbers
;     r - unperturbed spectrum
;     minoryr - matrix of minor jacobians/r
;     majoryr - matrix of major jacobians/r
;     mincoll - top n peaks of minoryr for specified isotope
;     majcoll - top n peaks of majoryr for specified isotope
;     condition - contains the different atmospheric conditions
;     
;   Outputs:
;     unpratio - ratios in the unperturbed regime
;     pratio - ratios in the perturbed regime
;     pr - 20 ppt perturbed r. Increased minor and decreased major.
;

;#################################################################################################
; fill in the elements of unpratio and pratio using a for loop.

for a=0, n_elements(condition)-1 do begin
  
  ; Run loaddata to give different atmospheric condition data
  loaddata, $
    condition[a], $
    savename, $
    w, $
    r, $
    majoryr, $
    minoryr, $
    majpeakindices, $
    minpeakindices, $
    majpeakno, $
    minpeakno, $
    majpeakindex, $
    minpeakindex, $
    major, $
    minor
  
  ; fill in unpratio. Each element will be minor isotope/major isotope
  for z=0, n-1 do begin
    for y=0, n-1 do begin
      unpratio[z,y,a]=r(mincoll[0,y])/r(majcoll[0,z])
    endfor
  endfor
  
  ; perturb spectrum r to take perturbed ratios
  pr=r-majoryr[q,*]*r+minoryr[p,*]*r
  
  ; fill in pratio. Each element will be minor isotope/major isotope
  for z=0, n-1 do begin
    for y=0, n-1 do begin
      pratio[z,y,a]=pr(mincoll[0,y])/pr(majcoll[0,z])
    endfor
  endfor
  
endfor
;#################################################################################################

end