; script to compare ratios between specific lines in unperturbed, rfm without a specific isotpe, and
; averaged MPIAS data.

cd, '/home/ball4321/MPhysProject/rfm'
restore,'../comres'
restore,'ratioday30km' ; get back mincoll and majcoll before apodisation changed indices


pratio=pratio[*,*,0]
unpratio=unpratio[*,*,0]

name=strupcase(strmid(strtrim(major(q)),27,3))+'(-'+strmid(strtrim(minor(p)),31,1)+')'
name='mod/'+name+'/rad_30000.asc'

rfmrd,name,w,rtemp

mratio=make_array(n,n)

for z=0, n-1 do begin
  for y=0, n-1 do begin
    mratio[z,y]=rtemp(mincoll[0,y])/rtemp(majcoll[0,z])
  endfor
endfor

; plot the ratios

temp=make_array(3,n_elements(result[0,*]))
temp[0,*]=unpratio(result[0,*],result[1,*])
temp[1,*]=mratio(result[0,*],result[1,*])
temp[2,*]=realratio(result[0,*],result[1,*])

maji=w(majcoll[0,result[0,*]])
mini=w(mincoll[0,result[1,*]])

;plot1=scatterplot3d(mini,maji,temp(0,*), name='unperturbed ratios')
;plot2=scatterplot3d(mini,maji,temp(1,*),/overplot, symbol='x', name='rfm without CO2(636)')
;plot3=scatterplot3d(mini,maji,temp(2,*),symbol='plus',/overplot,$
;  name='averaged MIPAS data at 30km', $
;  xtitle='minor isotope line', $
;  ytitle='major isotope line', $
;  ztitle='ratio', $
;  title='ratios between major lines and minor lines for ' + strmid(strtrim(major(q)),27,5) + ' and ' + strmid(strtrim(minor(p)),27,5))
;
;leg=LEGEND(TARGET=[plot1,plot2,plot3], POSITION=[1800,1800,5.7], $
;    /DATA, /AUTO_TEXT_COLOR)


;#########
dirty=make_array(1,9)
dirty=mini(where(result[0,*] eq 14))
tempd=make_array(3,9)
tempd=temp(*,where(result[0,*] eq 14))
  plot1=scatterplot(dirty,tempd(0,*), name='unperturbed ratios')
  plot2=scatterplot(dirty,tempd(1,*),/overplot, symbol='x', name='rfm without CO2(636)')
  plot3=scatterplot(dirty,tempd(2,*),symbol='plus',/overplot,$
    name='averaged MIPAS data at 30km', $
    xtitle='minor isotope line/cm$^{-1}$', $
    ytitle='ratio', $
    title='ratios (taken in the night) between major line at 1926.325cm$^{-1}$ and minor lines for ' + strmid(strtrim(major(q)),27,5) + ' and ' + strmid(strtrim(minor(p)),27,5))

  leg=LEGEND(TARGET=[plot1,plot2,plot3], POSITION=[1880,5.5],/DATA, /AUTO_TEXT_COLOR, sample_width=0)


 
end