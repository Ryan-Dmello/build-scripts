#!/bin/bash
#-----------------------------------------------------------------------------
#
# package       : tophat 
# Version       : 2.1.1 
# Source repo   : http://ccb.jhu.edu/software/tophat/downloads/          
# Tested on     : rhel_7.3
# Script License: Apache License, Version 2 or later
# Maintainer    : Shane Barrantes <shane.barrantes@ibm.com>
#
# Disclaimer: This script has been tested in non-root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintaine" of this script.
#
# ---------------------------------------------------------------------------- 

# Update Source
sudo yum update -y

# gcc dev tools
sudo yum groupinstall 'Development Tools' -y
sudo yum install python -y

# install dependencies
sudo yum install zlib-1.2.7-17.el7.ppc64le -y
sudo yum install glibc-2.17-157.el7.ppc64le -y
sudo yum install libgcc-4.8.5-11.el7.ppc64le -y
sudo yum install boost* -y

# download and unpack
wget http://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.1.tar.gz
tar -xzvf tophat-2.1.1.tar.gz
cd tophat-2.1.1

# make
./configure --build=ppc64le
sudo make install
