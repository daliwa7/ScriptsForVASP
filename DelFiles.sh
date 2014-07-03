#!/usr/bin/env bash

directory_name="$1"

while getopts ":twc" opt; do
    case $opt in
    t)
        contcar=true
        echo "-t also removes CONTCAR."
        ;;
    w)
        wavecar=true
        echo "-w also removes WAVECAR."
        ;;
    c)
        chgcar=true
        echo "-c also removes CHGCAR."
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
  esac
done

if [[ -d "$directory_name" && $(ls -A "$directory_name") ]]; then
    cd "$directory_name"
else
    echo "The directory $directory_name does not exist!"
    exit 1
fi

rm XDATCAR PCDAT CHG EIGENVAL PROCAR vasprun.xml OUTCAR OSZICAR DOSCAR *.o*
[[ $contcar ]] && rm CONTCAR
[[ $wavecat ]] && rm WAVECAR
[[ $chgcar ]] && rm CHGCAR