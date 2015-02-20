#!/bin/bash
# Creates Open vSwitch RPM files in CentOS 6 and RHEL6

DL_URL="http://openvswitch.org/releases/"
DL_VER="openvswitch-2.3.1.tar.gz"
EXTRACTED_TAR_DIR=$(echo $DL_VER | sed -r 's/\.[[:alnum:]]+\.[[:alnum:]]+$//')

declare -a dependencies=("gcc" \
                         "make" \
                         "python-devel" \
                         "openssl-devel" \
                         "kernel-devel" \
                         "graphviz" \
                         "kernel-debug-devel" \
                         "autoconf" \
                         "automake" \
                         "rpm-build" \
                         "redhat-rpm-config" \
                         "libtool" \
                         "wget")

# Install Dependencies if necessary
for package in "${dependencies[@]}"
do
  rpm -qa | grep $package 2>&1 > /dev/null
  isinstalled=$?
  if [[ $isinstalled != 0 ]]; then
    yum install -y $package
  else
    echo "Dependency $package is already fulfilled."
  fi
done

#Prepare for RPM creation
mkdir -p /root/rpmbuild/SOURCES && cd /root/rpmbuild/SOURCES
wget $DL_URL$DL_VER
tar -xvf $DL_VER
cd $EXTRACTED_TAR_DIR

# Build RPMs
rpmbuild -bb rhel/openvswitch.spec

# Prepare to build kernel module RPMs
cp /root/rpmbuild/SOURCES/$EXTRACTED_TAR_DIR/rhel/openvswitch-kmod.files /root/rpmbuild/SOURCES/

# Build kernel module RPMs
rpmbuild -bb rhel/openvswitch-kmod-rhel6.spec

# Echo location of RPMs
echo "Finished. All of the following RPMs are now located at /root/rpmbuild/RPMS/"
ls -lah /root/rpmbuild/RPMS/*
