cd, '/home/ball4321/MPhysProject/rfm'

majchange=make_array(n_elements(majcoll[0,*]))
minchange=make_array(n_elements(majcoll[0,*]))

f='ngt'
f1=f+'/30000/685en2/rad_30000.asc'

rfmrd,f1,w,rad1
;
;majchange=newapodise(1,newmajcoll[0,*])/rad1(majcoll[0,*])
;minchange=newapodise(1,newmincoll[0,*])/rad1(mincoll[0,*])
;
;plot1=scatterplot(newmincoll[1,*],minchange, name='minor isotopic lines', sym_color='b')
;plot2=scatterplot(newmajcoll[1,*],majchange,/overplot,symbol='x', $
;  sym_color='r', $
;  name='major isotopic lines', $
;  xtitle='wavenumbers of isotopic lines/cm$^{-1}$', $
;  ytitle='ratio: MIPAS data/expected rfm values', $
;  title='Comparison between MIPAS and rfm line strength for isotopic lines (' + f + ')')
;  
;leg=LEGEND(TARGET=[plot1,plot2], POSITION=[2400,20],/DATA, /AUTO_TEXT_COLOR,SAMPLE_WIDTH=0)


;see HT18 6th week wednesday diary - 3 overplots to compare 1800-2400 region

rfmrd, 'mod/CO2only/rad_30000.asc',w, rad2

sta=1904
fin=1910
staMIP=where(abs(newapodise[0,*]-sta) lt 0.001)
finMIP=where(abs(newapodise[0,*]-fin) lt 0.001)
staRFM=where(abs(w-sta) lt 0.001)
finRFM=where(abs(w-fin) lt 0.001)
staMAJ=(majcoll[1,*] gt sta)
finMAJ=(majcoll[1,*] lt fin)
list=staMaj eq finMAJ
list=where(list eq 1, /null)


;staRFM=where(abs(w
plota=plot(newapodise[0,staMIP:finMIP],newapodise[1,staMIP:finMIP], $
  color='r', $
  name='MIPAS (averaged and apodised) data')
plotb=plot(newapodise[0,staMIP:finMIP],rad1[staRFM:finRFM], $
  color='b', $
  /overplot, $
  name='rfm with full gas profile')
plotc=plot(newapodise[0,staMIP:finMIP],rad2[staRFM:finRFM], $
  color='green', $
  /overplot, $
  yrange=plota.yrange, $
  name='rfm with just CO2', $
  title='Comparison between (a) MIPAS data, (b) rfm data for all gases, (c)rfm of just CO2', $
  xtitle='wavenumbers of isotopic lines/cm$^{-1}$', $
  ytitle='radiance/ nW/(cm$^{2} sr cm$^{-1}$)')


;foreach element, majcoll[1,list], index do plotd=polyline([element,element],plota.yrange,/data,target=plota,linestyle='dash',name='major isotope lines')
foreach element, majcoll[1,list], index do plotd=plot([element,element],plota.yrange,linestyle='dash',name='major isotope lines',/overplot)


leg=LEGEND(Target=[plota,plotb,plotc,plotd], position=[0.5,0.9],/relative)

; put into matrix for easy comparison
;vis=make_array(3,finMIP-staMIP+1)
;vis[0,*]=newapodise[0,staMIP:finMIP]
;vis[1,*]=newapodise[1,staMIP:finMIP]
;vis[2,*]=rad1[staRFM:finRFM]
;vis[3,*]=rad2[staRFM:finRFM]


;plote=plot(newapodise[0,staMIP:finMIP],rad2[staRFM:finRFM]-rad1[staRFM:finRFM])

end