#!/bin/sh

if [[ ! $(id -u) = 0 ]] 
    then echo "This script should run as root" && exit 1 
fi

function installfile() {
    fname=$1
    dname=$(echo $fname | sed -e 's_\(^.*\/\).*_\1_')
    sfile="files/$( echo $fname | sed -e 's_^/__' )"
    if [[ "$fname" =~ ^\/.* ]] 
        then 
            if [[ -f $sfile ]] 
                then echo "Installing: [ $sfile ] to [ $fname ]"
                mkdir -p $dname
                cp "$sfile"  "$fname"
            else 
                echo "Source file does not exist [ $sfile ]" && exit 1
            fi
    else 
        echo "Bad filename match [ $fname ] , name must start with / "    
    fi
}

[[ -f /usr/bin/pip-python ]] && pip-python install ansible
[[ -f /usr/bin/pip ]] && pip-python install ansible


#install all files in 'files' sub-directory, with the exception of swp files and cruft.
find files -type f  -a \( -not -regex ".*\.swp" \)     | sed -e 's/files//' | while read i 
do installfile $i 
done
