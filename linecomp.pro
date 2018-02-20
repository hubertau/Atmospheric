majchange=make_array(n_elements(majcoll[0,*]))
minchange=make_array(n_elements(majcoll[0,*]))

f='day'
f1=f+'/30000/685en2/rad_30000.asc'

rfmrd,f1,w,rngt

majchange=newapodise(1,newmajcoll[0,*])/rngt(majcoll[0,*])
minchange=newapodise(1,newmincoll[0,*])/rngt(mincoll[0,*])

plot1=scatterplot(newmincoll[1,*],minchange, name='minor isotopic lines')
plot2=scatterplot(newmajcoll[1,*],majchange,/overplot,symbol='x', $
  name='major isotopic lines', $
  xtitle='wavenumbers of isotopic lines/cm$^{-1}$', $
  ytitle='ratio: MIPAS data/expected rfm values', $
  title='Comparison between MIPAS and rfm line strength for isotopic lines (' + f + ')')
  
leg=LEGEND(TARGET=[plot1,plot2], POSITION=[2400,20],/DATA, /AUTO_TEXT_COLOR)

end