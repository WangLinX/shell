#!/bin/bash

procdir=$HOME/trio

cd
path=(`find $procdir -name '[Ll]og' -type d`)

mkdir $HOME/logcollect
cd $HOME/logcollect
rm -f *


for i in ${path[@]}
do
   dirlink=`echo ${i##$procdir/}`
    dirlink=${dirlink//\//.}
    ln -s $i dir.$dirlink
    for j in `find $i -name '*.log' `
    do
        filelink=`echo ${j##$procdir/}`
        filelink=${filelink//\//.}
        ln -s $j $filelink
    done
    for z in `find $i -name '*INFO' `
    do
        infofilelink=`echo ${z##$procdir/}`
        infofilelink=${infofilelink//\//.}
        ln -s $z $infofilelink
    done
done

