#!/bin/bash

function getcell {
f=$1
row=$(( $2 + 3  ))
sed -n "${row},${row}p" $f | cut -f 3
}
function getcell2 {
f=$1
#row=$(( $2 + 26  ))
row=$(( $2 + 25  ))
sed -n "${row},${row}p" $f | cut -f 3
}

exp=$1
y1=$2
y2=$3
echo -n "|" exp_y1_y2 "|"
f=Global_Mean_Table_${exp}_${y1}_${y2}.txt

echo " TOAnet SW | TOAnet LW | Net TOA | Sfc Net SW | Sfc Net LW | SH Fl. | LH Fl. | SWCF | LWCF | NetSfc* | TOA-SFC | t2m | TCC | LCC | MCC | HCC | TP | P-E |"

echo -n "|" ${exp}_${y1}_${y2} "| "
for row in 1 2 3 4 5 6 7 8 9 11 13
do
echo -n $(getcell $f $row )  "| "
done

for row in 1 3 4 5 6 7 11
do
echo -n $(getcell2 $f $row )  "| "
done
echo


