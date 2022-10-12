#!/bin/csh
echo 0 | gmx trjconv -f HypaCas_R1-4_stride10000_prot.trr -s SYS_prot.pdb -sep -o frame.pdb

set v =  `ls frame*.pdb | wc -l`

set j = 0
while ( $j <= $v )
  sed -i 's/HIE/HIS/g' frame$j\.pdb
  @ j++
end
