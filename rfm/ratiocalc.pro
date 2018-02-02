pro ratiocalc, p,q, minoryr, majoryr, majpeakno, minpeakno, majpeakindex, minpeakindex, ratio

temp=minpeakindex[p,where(minpeakindex[p,*] ne 0)]
minmax=minoryr[p,temp]

temp=majpeakindex[q,where(majpeakindex[q,*] ne 0)]
majmax=majoryr[q,temp]

ratio=make_array(n_elements(majmax),n_elements(minmax))
for a=0, n_elements(majmax)-1 do begin
  for b=0, n_elements(minmax)-1 do begin
    ratio[a,b]=minmax[b]/majmax[a]
  endfor
endfor

end