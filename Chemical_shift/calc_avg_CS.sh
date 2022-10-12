#!/bin/csh

### Combined chemical shift perturbation of 1H & 15N/13C (for the time being, its only for REC3) ###

echo -n  "1st Atom: H \n"
set n1 = "H"

echo -n  "2nd Atom (N/C/CA/CB): "
set n2 = $<
#echo $n2


set x =  `ls frame*.pdb.cs | wc -l`
@ v = $x - 1
set j = 0
while ( $j <= $v )
  sed -e 's/,/ /g' frame$j\.pdb.cs > frame$j\_new.pdb.cs
  sed -i '1d' frame$j\_new.pdb.cs
  awk -v v1=$n1 '{if (($1>493) && ($1<710) && ($3==v1)) print $0 }' frame$j\_new.pdb.cs > frame$j\_REC3_$n1\.pdb.cs
  awk -v v2=$n2 '{if (($1>493) && ($1<710) && ($3==v2)) print $0 }' frame$j\_new.pdb.cs > frame$j\_REC3_$n2\.pdb.cs


  @ j++

end


#####---- Avg combined perturbation----- ###################
if ($n2 == "N") then
	paste -d ' ' frame0_REC3_H.pdb.cs frame0_REC3_N.pdb.cs | awk '{print sqrt(0.5*(($4^2)+(0.04*($8^2))))}' > temp1.cs
else
	paste -d ' ' frame0_REC3_H.pdb.cs frame0_REC3_$n2\.pdb.cs | awk '{print sqrt(0.5*(($4^2)+(0.25*($8^2))))}' > temp1.cs
endif
cp temp1.cs temp3.cs

awk '{print $4}' frame0_REC3_H.pdb.cs > temp3_H.cs ## for H Average
awk '{print $4}' frame0_REC3_$n2\.pdb.cs > temp3_$n2\.cs # for 2nd atom average


set j = 1
while ( $j <= $v )
  if ($n2 == "N") then
	  paste -d ' ' frame$j\_REC3_H.pdb.cs frame$j\_REC3_N.pdb.cs | awk '{print sqrt(0.5*(($4^2)+(0.04*($8^2))))}' > temp1.cs
  else
         paste -d ' ' frame0_REC3_H.pdb.cs frame0_REC3_$n2\.pdb.cs | awk '{print sqrt(0.5*(($4^2)+(0.25*($8^2))))}' > temp1.cs 
  endif
  paste -d ' ' temp1.cs temp3.cs | awk '{print $1+$2} ' > temp2.cs  ## combined perturbation 
  paste -d ' ' frame$j\_REC3_H.pdb.cs temp3_H.cs | awk '{print $4+$5} ' > temp2_H.cs  ## for H
  paste -d ' ' frame$j\_REC3_$n2\.pdb.cs temp3_$n2\.cs | awk '{print $4+$5} ' > temp2_$n2\.cs  ## for 2nd Atom

  cp temp2.cs temp3.cs
  cp temp2_H.cs temp3_H.cs
  cp temp2_$n2\.cs temp3_$n2\.cs
  @ j++

end

awk -v var=$v '{print $1/var}' temp3.cs > average_H_$n2\.cs # combined perturbation
awk -v var=$v '{print $1/var}' temp3_H.cs > average_H.cs  ## for H
awk -v var=$v '{print $1/var}' temp3_$n2\.cs > average_$n2\.cs ## for 2nd atom
####------------------------------##############################

#####---- stdev ----- ###################

if ($n2 == "N") then
        paste -d ' ' frame0_REC3_H.pdb.cs frame0_REC3_N.pdb.cs | awk '{print sqrt(0.5*(($4^2)+(0.04*($8^2))))}' > temp1.cs
else
        paste -d ' ' frame0_REC3_H.pdb.cs frame0_REC3_$n2\.pdb.cs | awk '{print sqrt(0.5*(($4^2)+(0.25*($8^2))))}' > temp1.cs
endif
paste -d ' ' temp1.cs average_H_$n2\.cs | awk '{print ($1-$2)^2} ' > temp2.cs
paste -d ' ' frame0_REC3_H.pdb.cs average_H.cs | awk '{print ($4-$5)^2} ' > temp2_H.cs
paste -d ' ' frame0_REC3_$n2\.pdb.cs average_$n2\.cs | awk '{print ($4-$5)^2} ' > temp2_$n2\.cs

cp temp2.cs temp_run.cs
cp temp2_H.cs temp_run_H.cs
cp temp2_$n2\.cs temp_run_$n2\.cs

set j = 1
while ( $j <= $v )
  if ($n2 == "N") then
          paste -d ' ' frame$j\_REC3_H.pdb.cs frame$j\_REC3_N.pdb.cs | awk '{print sqrt(0.5*(($4^2)+(0.04*($8^2))))}' > temp1.cs
  else
         paste -d ' ' frame0_REC3_H.pdb.cs frame0_REC3_$n2\.pdb.cs | awk '{print sqrt(0.5*(($4^2)+(0.25*($8^2))))}' > temp1.cs
  endif
  paste -d ' ' temp1.cs average_H_$n2\.cs | awk '{print ($1-$2)^2} ' > temp2.cs
  paste -d ' ' frame$j\_REC3_H.pdb.cs average_H.cs | awk '{print ($4-$5)^2} ' > temp2_H.cs
  paste -d ' ' frame$j\_REC3_$n2\.pdb.cs average_$n2\.cs | awk '{print ($4-$5)^2} ' > temp2_$n2\.cs

  paste -d ' ' temp2.cs temp_run.cs | awk '{print $1+$2} ' > temp3.cs  
  paste -d ' ' temp2_H.cs temp_run_H.cs | awk '{print $1+$2} ' > temp3_H.cs  
  paste -d ' ' temp2_$n2\.cs temp_run_$n2\.cs | awk '{print $1+$2} ' > temp3_$n2\.cs  

  cp temp3.cs temp_run.cs
  cp temp3_H.cs temp_run_H.cs
  cp temp3_$n2.cs temp_run_$n2.cs
  @ j++

end


awk -v var=$v '{print sqrt($1/var)}' temp_run.cs > stdev_H_$n2\.cs # combined perturbation
awk -v var=$v '{print sqrt($1/var)}' temp_run_H.cs > stdev_H.cs  ## for H
awk -v var=$v '{print sqrt($1/var)}' temp_run_$n2\.cs > stdev_$n2\.cs ## for 2nd atom

#################-----------------------------------------------####################
echo "Resid   Avergae   Stdev" > avg_stdev_H_$n2\.cs
paste -d ' ' average_H_$n2\.cs stdev_H_$n2\.cs frame1_REC3_$n2\.pdb.cs | awk '{print $3+3," ", $1," ", $2}' >> avg_stdev_H_$n2\.cs

echo "Resid   Avergae   Stdev" > avg_stdev_H.cs
paste -d ' ' average_H.cs stdev_H.cs frame1_REC3_H.pdb.cs | awk '{print $3+3," ", $1," ", $2}' >> avg_stdev_H.cs

echo "Resid   Avergae   Stdev" > avg_stdev_$n2\.cs
paste -d ' ' average_$n2\.cs stdev_$n2\.cs frame1_REC3_$n2\.pdb.cs | awk '{print $3+3," ", $1," ", $2}' >> avg_stdev_$n2\.cs


rm -f temp*.cs
rm -f frame*_new.pdb.cs
rm -f frame*_REC3_*.pdb.cs
rm -f average_H_$n2\.cs stdev_H_$n2\.cs average_H.cs stdev_H.cs average_$n2\.cs stdev_$n2\.cs
