pro collate, collated, peakno, index, peakindex, data, w, n

; column 1: indices of peaks, column 2: corresponding wavenumbers, column 3: corresponding peak (radiance) values
collated=make_array(3,peakno(index))
collated[0,*]=peakindex[index,0:peakno(index)-1]
collated[1,*]=w(collated[0,*])
collated[2,*]=data(index,collated[0,*])

collated=collated[*,REVERSE(SORT(collated[2,*]))] ; sort according to radiance

collated=collated[*,0:n-1] ; only take top n peaks

end