#!/bin/bash

cd $1 || exit 1
mkdir Temp
mv INCAR KPOINTS POTCAR POSCAR qsub.parallel Temp/
rm * 2>/dev/null
mv Temp/* .
rm -r Temp
