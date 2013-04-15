#!/bin/bash

# parameters
DEST_PATH=tarballs

##########################################################################

UPVERSION=$1
if [ -z "${UPVERSION}" ]; then
    UPVERSION=$(cat ASTERISK-VERSION)
fi

FILENAME="asterisk_${UPVERSION}+dfsg.orig.tar.gz"

mkdir -p "${DEST_PATH}"
if [ -e "${DEST_PATH}/${FILENAME}" ]; then
	echo "A tarball already exist for this version ; remove it if you want to regenerate."
	exit 0
fi

UPFILENAME="asterisk_${UPVERSION}.orig.tar.gz"
URL="http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${UPVERSION}.tar.gz"

echo "Downloading ${UPFILENAME} from ${URL}"
wget -nv -T10 -t3 -O ${DEST_PATH}/${UPFILENAME} ${URL}
if [ $? != 0 ]; then
	rm -f ${DEST_PATH}/${UPFILENAME}
	echo "Could not find tarball."
	exit 2
fi

echo "Repacking as DFSG-free..."
mkdir -p ${DEST_PATH}/asterisk-${UPVERSION}.tmp/
cd ${DEST_PATH}/asterisk-${UPVERSION}.tmp
tar xfz ../${UPFILENAME}
if [ -e "asterisk-${UPVERSION}" ]; then
	(
	cd asterisk-${UPVERSION}
	# remove some large files we don't need in the tarball
	rm -f sounds/asterisk-moh*
	)
	tar cfz ../${FILENAME} asterisk-${UPVERSION}
else
	echo "Source tarball layout changed. Check by yourself in '${DEST_PATH}/asterisk-${UPVERSION}.tmp/'."
	exit 2
fi

echo "Cleaning up..."
cd - >/dev/null
rm -rf ${DEST_PATH}/${UPFILENAME} ${DEST_PATH}/asterisk-${UPVERSION}.tmp/

