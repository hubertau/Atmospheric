pro ratiostat, n, unpratio, pratio, avg, std, var, cov

avg[*,*,0]=mean(unpratio,dimension=3)
avg[*,*,1]=mean(pratio,dimension=3)

std[*,*,0]=stddev(unpratio,dimension=3)
std[*,*,1]=stddev(pratio,dimension=3)

var[*,*,0]=variance(unpratio,dimension=3)
var[*,*,1]=variance(pratio,dimension=3)

; now calculate correlation

temp1=make_array(n,n,5)
temp2=make_array(n,n,5)

for i=0,4 do begin
  temp1[*,*,i]=pratio[*,*,i]-avg[*,*,1]
  temp2[*,*,i]=unpratio[*,*,i]-avg[*,*,0]
endfor

cov=total(temp1*temp2,3)/4

end