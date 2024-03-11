#!/bin/sh
#
#  Install R packages from the command line
#
CRAN_URL=http://cran.ma.imperial.ac.uk/

packages=`echo $* | sed 's/\([^ ]*\)/"\1",/g;s/,$//g'`

echo "install.packages(c($packages), repo=\"$CRAN_URL\")" | R --no-save
