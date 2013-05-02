
for beta in 0.1  ;
do


for alpha in 0.5 ;
do

for nnPU in 10 ;

do

for seed in 1  ; 
do

	
	file="map_"$seed"_"$nnPU".txt"
	../../../ns pu_special.tcl $seed $alpha $beta $nnPU > $file


done

done

done

done
