#!/bin/bash

BASE_DIR=$PWD
cd electronic 2>/dev/null
if [ $1 == scrun ]; then
    cd $BASE_DIR
    mkdir electronic && cd electronic
    cp -r ../INPUT .
#    sed -i "/ISMEAR/c ISMEAR = 1" INPUT/INCAR
    sed -i "/NSW/c NSW = 0" INPUT/INCAR
    sed -i "/LCHARG/c LCHARG = .TRUE." INPUT/INCAR
    sed -i "/LMAXMIX/c LMAXMIX = 4" INPUT/INCAR
    sed -i "/PREC/c PREC = Accurate" INPUT/INCAR
    Fast-prep.sh scrun
    cd scrun
    qsub qsub.parallel

elif [ $1 == dosrun ]; then
    Fast-prep.sh dosrun
    cd dosrun
    cp -l ../scrun/CHGCAR .
    sed -i "/ISMEAR/c ISMEAR = -5" INCAR
    sed -i "/NEDOS/c NEDOS = 2101" INCAR
    sed -i "/ICHARG/c ICHARG = 11" INCAR
    if [[ $2 == rwigs ]]; then
        rwigs=$(cd ../scrun; Cellinfo.sh rwigs |awk '{print $4}')
        sed -i "/RWIGS/c RWIGS = ${rwigs//,/ }" INCAR
        sed -i "/NPAR/c NPAR = 1" INCAR
        sed -i "/LORBIT/c LORBIT = 5"  INCAR
    else
        sed -i "/LORBIT/c LORBIT = 11"  INCAR
    fi

    sed -i '4c 21 21 21' KPOINTS
    qsub qsub.parallel

elif [ $1 == bsrun ]; then
    Fast-prep.sh bsrun
    cd bsrun
    cp -l ../scrun/CHGCAR .
    sed -i "/ICHARG/c ICHARG = 11" INCAR
    sed -i "/LORBIT/c LORBIT = 11" INCAR
    if [ -f KPOINTS-bs ]; then
        mv KPOINTS-bs KPOINTS
    else
        echo "You must manually change the KPOINTS file before submitting job!"
        exit 1
    fi
    qsub qsub.parallel

elif [ $1 == lobster-pre ]; then
    Fast-prep.sh lobster-pre qlobster.pre.serial
    cd lobster-pre
    sed -i "/ISYM/c ISYM = 0" INCAR
    sed -i "/LSORBIT/c LSORBIT = .TRUE." INCAR
    sed -i "/ISMEAR/c ISMEAR = -5" INCAR
#    sed -i '4c 17 17 17' KPOINTS
    qsub qlobster.pre.serial

elif [ $1 == lobster ]; then
    Fast-prep.sh lobster qlobster.serial
    cd lobster
    cp -l ../scrun/CHGCAR .
    cp ../lobster-pre/IBZKPT KPOINTS
    sed -i "/ISMEAR/c ISMEAR = -5" INCAR
    if [[ -n $2 ]]; then
        sed -i "/NBANDS/c NBANDS = $2" INCAR
    fi
    sed -i "/LWAVE/c LWAVE = .TRUE." INCAR
    sed -i "/ICHARG/c ICHARG = 11" INCAR
    sed -i "/LORBIT/c LORBIT = 11"  INCAR
    sed -i "/NEDOS/c NEDOS = 2101" INCAR
    sed -i "/NPAR/c NPAR = 8"  INCAR
    sed -i "/#PBS -l walltime/c #PBS -l walltime=04:00:00" qsub.parallel
    sed -i "/#PBS -l nodes/c #PBS -l nodes=2:ppn=8" qsub.parallel
    qsub qsub.parallel

elif [ $1 == lobster-post ]; then
    cd lobster
    qsub qlobster.serial

elif [ $1 == plot-ldos ]; then
    cd dosrun
    _Plot-ldos.py $2 $3

elif [ $1 == plot-tdos ]; then
    cd dosrun
    _Plot-tdos.py $2

elif [ $1 == bs ]; then
    cd bsrun
    _Plot-bs.py $2
fi