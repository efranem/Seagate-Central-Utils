#!/bin/bash
source ../common/build-common
source ../common/build-functions
check_source_dir "gnutls"
change_into_obj_directory

# gnutls doesn't like the following .la file
# temporarily rename it.
#
mv $BUILDHOST_DEST/$PREFIX/lib/libidn2.la $BUILDHOST_DEST/$PREFIX/lib/libidn2.la.orig

# Configure options:
#
# without-tpm : TPM is support for the Trusted Platform
# Module, a hardware module not included in the Seagate
# Central.
#

configure_it --prefix=$PREFIX \
	     --bindir=$EXEC_PREFIX/bin \
	     --sbindir=$EXEC_PREFIX/sbin \
	     --host=$ARCH \
	     --enable-static \
	     --enable-shared \
	     --without-tpm \
	     --enable-openssl-compatibility

# Tried to get rid of the thousands
# of warning messages during build saying
# 
# "warning: 'ASN1_TYPE' macro is deprecated, use 'asn1_node' instead."
#
# I expected the following to work but it didn't.
# export CPPFLAGS="$CPPFLAGS -Wno-cpp"

make_it
install_it
finish_it

