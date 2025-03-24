#!/bin/sh

# IBM Confidential
# Copyright IBM Corp. 2016, 2020. Copyright WSI Corporation 1998, 2015

#
# Additional pre-link scripts can be called from here, rather than adding
# those to the build phase for multiple targets.
#

# uncomment this to dump entire bash environment
#env

################################################################################
# SETUP
################################################################################

echo " "
echo "##########################################################################"
echo "Running '$0'..."

echo " "
echo "##########################################################################"
./Scripts/ProcessFrameworks.sh
if [ $? -ne 0 ] ; then
    echo "Error: ProcessFrameworks.sh failed!"
    exit 1
fi

exit 0
