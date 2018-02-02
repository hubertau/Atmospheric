pro ratiostat, unpratio, pratio, avg, std

avg[*,*,0]=mean(unpratio,dimension=3)
avg[*,*,1]=mean(pratio,dimension=3)

std[*,*,0]=stddev(unpratio,dimension=3)
std[*,*,1]=stddev(pratio,dimension=3)

end