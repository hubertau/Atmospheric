function name2iso, gas

dict=dictionary('CO2I1',626,$
  'CO2I2',636,$
  'CO2I3',628,$
  'CO2I4',627,$
  'CO2I5',638,$
  'H2OI1',161,$
  'H2OI4',162,$
  'O3I1',666,$
  'O3I2',668,$
  'O3I3',686,$
  'N2OI1',446,$
  'N2OI2',456,$
  'N2OI3',546,$
  'CH4I1',211,$
  'CH4I2',311,$
  'CH4I3',212,$
  'HNO3I1',146,$
  'HNO3I2',156,$
  'COI1',26,$
  'COI2',36,$
  'COI3',28)
  
r=strupcase(gas.remove(-2)) + '(' + strtrim(string(dict[gas]),2) + ')'

return, r

end