pro Fill, savename, p, q, n, w, r, minoryr, majoryr, mincoll, majcoll, contrast, condition, unpratio, pratio, pr

for a=0, n_elements(condition)-1 do begin
  ; Need LoadData to give different atmospheric condition data
  LoadData, condition[a], savename, w, r, majoryr, minoryr, majpeakindices, minpeakindices, majpeakno, minpeakno, majpeakindex, minpeakindex, major, minor
  minpeaks=minoryr(p,mincoll[0,*])
  majpeaks=majoryr(q,majcoll[0,*])
  
;  for z=0, n-1 do begin
;    for y=0, n-1 do begin
;      contrast[z,y,a]=minpeaks[y]/majpeaks[z]
;    endfor
;  endfor
  
  for z=0, n-1 do begin
    for y=0, n-1 do begin
      unpratio[z,y,a]=r(mincoll[0,y])/r(majcoll[0,z])
;      unprdmerr[z,y,a]=sqrt((30/r(mincoll[0,y]))^2+(30/r(majcoll[0,z]))^2)
    endfor
  endfor
  
  pr=r-majoryr[q,*]*r+minoryr[p,*]*r
  
  for z=0, n-1 do begin
    for y=0, n-1 do begin
      pratio[z,y,a]=pr(mincoll[0,y])/pr(majcoll[0,z])
;      prdmerr[z,y,a]=sqrt((30/pr(mincoll[0,y]))^2+(30/pr(majcoll[0,z]))^2)
    endfor
  endfor
  
endfor

end