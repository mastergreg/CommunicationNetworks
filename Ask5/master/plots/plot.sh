#!/bin/bash

if [ 'x'$1 == 'x' ]
then
    echo No input
    exit 1
fi

if [ 'x'$2 == 'x' ]
then
    PLOT='plot "'$1'" with lines title "'${1/.tr/}'"'
else
    PLOT='plot "'$1'" with lines title "'${1/.tr/}'", "'$2'" with lines title "'${2/.tr/}'"'
fi

echo $PLOT
gnuplot << EOF

set terminal png size 1024,768
set output "${1/.tr/.png}"
$PLOT


EOF
