; This script is intended to collect rfm output from the specified requirements in rfm.drv
; The script first collects and sorts the .asc files into major and minor isotopologues. Then it
; applies rfmrd (read procedure for .asc files)

; set up colour for plots
device,decomposed = 0
loadct, 39
;!p.background=CGCOLOR('white')
;!p.color=CGCOLOR('black')

condition=['day','ngt','sum', 'win', 'equ']
c=1
atm=condition[c]           ; specify the atmospheric conditions of the data
altitude=30000        ; specify the altitude at which to consider data
savename=altitude     ; useful later if saving is enabled

p=0 ; p is the index number for MINOR
q=0 ; q is the index number for MAJOR

; specify search directory to pass to filesearch script
libdir = '/home/ball4321/rfm/' + atm + '/'
libdir = libdir + strtrim(altitude,2) + '/'

; call filesearch script, which splits the major and minor isotopes
@filesearch

; use rfmrd procedure to read the unperturbed spectrum
rfmrd,main,w,r

; create an array to store the results of the reads (major isotopologues)
majory=make_array(n_elements(major),n_elements(r),/double)  ; the y-values (radiance) of the jacobian
majoryr=make_array(n_elements(major),n_elements(r),/double) ; divided by r


for a=0,(n_elements(major)-1) do begin
  rfmrd,major[a],w,k
  majory[a,*]=k
  majoryr[a,*]=k/r ; divided by the unpertubed spectrum
endfor

; create an array to store the results of the reads (minor isotopologues)
minory=make_array(n_elements(minor),n_elements(r),/double)
minoryr=make_array(n_elements(minor),n_elements(r),/double) ; divided by r


for a=0,(n_elements(minor)-1) do begin
  rfmrd,minor[a],w,k
  minory[a,*]=k
  minoryr[a,*]=k/r ; divided by the unpertubed spectrum
endfor

; counting peaks
threshold=[0.2,0.2,0.2,0.2]
peakcount, majoryr, majpeakindices, majpeakno, majpeakindex, threshold

threshold=[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2]
peakcount, minoryr, minpeakindices, minpeakno, minpeakindex, threshold

if (atm eq 'day') and (savename eq 25000) then begin
  
  collate, mincoll, minpeakno, p, minpeakindex, minoryr, w
  collate, majcoll, majpeakno, q, majpeakindex, majoryr, w
  
  ratio1=make_array(10,10)
  for a=0, 9 do begin
    for b=0, 9 do begin
      ratio1[a,b]=mincoll[2,b]/majcoll[2,a]
    endfor
  endfor

  name='ratioday' + strtrim(savename/1000,2) + 'km'
  
  save, filename=name, ratio1, mincoll, majcoll

endif else begin
  
  restore, 'ratioday30km'
  minpeaks=minoryr(p,mincoll[0,*])
  majpeaks=majoryr(q,majcoll[0,*])
  
  ratio=make_array(10,10)
  for a=0, 9 do begin
    for b=0, 9 do begin
      ratio[a,b]=minpeaks[b]/majpeaks[a]
    endfor
  endfor
  
  contrast=make_array(10,10,n_elements(condition))
  contrast[0,0,0]=ratio/base30
  print, 'ratio/base30:'
  print, contrast[*,*,0]
  
endelse

print, 'minor[',strtrim(p,2),'] (rows): ', minor[p]
print, 'major[',strtrim(q,2),'] (columns): ', major[q]


end