mratio=make_array(15,15)

for z=0, n-1 do begin
  for y=0, n-1 do begin
    mratio[z,y]=rtemp(mincoll[0,y])/rtemp(majcoll[0,z])
  endfor
endfor

end

plot1=scatterplot(w(mincoll(0,*)),temp(0,*), name='unperturbed ratios')
plot2=scatterplot(w(mincoll(0,*)),temp(1,*),/overplot, symbol='x', name='rfm without CO2(636)')
plot3=scatterplot(w(mincoll(0,*)),temp(2,*),symbol='plus',/overplot,$
  name='averaged MIPAS data at 30km', $
  xtitle='minor isotope line', $
  ytitle='ratio', $
  title='ratios between major line 15 (1926.325 cm^-1) and minor lines for CO2 isotopes 626 and 636')

leg=LEGEND(TARGET=[plot1,plot2,plot3], POSITION=[1800,5.7], $
    /DATA, /AUTO_TEXT_COLOR)