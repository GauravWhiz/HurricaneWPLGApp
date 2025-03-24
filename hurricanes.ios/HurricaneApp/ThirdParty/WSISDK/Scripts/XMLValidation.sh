#!/bin/sh

# IBM Confidential
# Copyright IBM Corp. 2016, 2020. Copyright WSI Corporation 1998, 2015

# XML-Validation.sh
#
# Script for validating xml files via Xcode.
#
# Edit the "Add paths / files..." section below to add / remove paths or files
# that should be verified.
#
# Note that our xsd files are often in a different folder than the xml files so
# we look for matching xsd files in a number of places:
#
#	+ in the same folder as the xml file (explicit files only)
#
# Additional Notes
#
# The project sources root directory is accessible via ${SRCROOT}
# The target name is accessible via ${REAL_TARGET_NAME}
#

# Set to 1 to enable debug information.
DEBUG_MODE=0

echo "Validating xml for build target!"

if [ $DEBUG_MODE -eq 1 ] ; then
	echo "SRCROOT="${SRCROOT}
fi

XML_DIR_COUNT=0
XML_FILE_COUNT=0

##########################################################################
# Add paths / files to validate here.

function addFileEntry()
{
    XML_FILE_LIST[${XML_FILE_COUNT}]=$1
    ((XML_FILE_COUNT++))
}

function addDirectoryEntry()
{
    XML_DIR_LIST[${XML_DIR_COUNT}]=$1
    ((XML_DIR_COUNT++))
}

# always verify the main configuration files
addFileEntry "${SRCROOT}/Configuration/legends_config.xml"
addFileEntry "${SRCROOT}/Configuration/maplayers_config.xml"
addFileEntry "${SRCROOT}/Configuration/map_alert_styles.xml"
addFileEntry "${SRCROOT}/Configuration/map_local_radars.xml"
addFileEntry "${SRCROOT}/Configuration/master_config_map.xml"
addFileEntry "${SRCROOT}/Configuration/master_config_ordering.xml"

#addDirectoryEntry "${SRCROOT}/TargetResources/${REAL_TARGET_NAME}"

##########################################################################

#debug stuff
if [ $DEBUG_MODE -eq 1 ] ; then
	echo "Directories ("${XML_DIR_COUNT}"):"
	index=0
	while [ $index -lt "${XML_DIR_COUNT}" ] ; do
		echo "  " $index: ${XML_DIR_LIST[$index]}
		((index++))
	done
	echo "Files ("${XML_FILE_COUNT}"):"
	index=0
	while [ $index -lt "${XML_FILE_COUNT}" ] ; do
		echo "  " $index: ${XML_FILE_LIST[$index]}
		((index++))
	done
fi

# This will be set to 1 if any validation fails:
EXIT_CODE=0

# validate explicit xml files
if [ $DEBUG_MODE -eq 1 ] ; then
echo "Processing specific xml files..."
fi

# empty output file
echo "" > "${TMPDIR}\xmllint.txt"

ii=0
while [ $ii -lt "${XML_FILE_COUNT}" ] ; do
	XML_FILE_NAME=${XML_FILE_LIST[$ii]}
	FILE_SCHEMA_FILE_NAME=`basename "${XML_FILE_NAME}" | sed -e "s/xml/xsd/"`
	FILE_SCHEMA_DIR_NAME=$(dirname ${XML_FILE_NAME})

	# try to find the .xsd in any of several paths
	SCHEMA_FILE_PATH_COUNT=0

	SCHEMA_FILE_PATH[((SCHEMA_FILE_PATH_COUNT++))]="${FILE_SCHEMA_DIR_NAME}/${FILE_SCHEMA_FILE_NAME}"

	jj=0
	while [ $jj -lt "${SCHEMA_FILE_PATH_COUNT}" ] ; do
		if [ -f "${SCHEMA_FILE_PATH[$jj]}" ] ; then
			xmllint --noout --schema "${SCHEMA_FILE_PATH[$jj]}" "${XML_FILE_NAME}" >> "${TMPDIR}\xmllint.txt" 2>&1
			if [ $? -ne 0 ] ; then
                echo "Error: validation failed for '${XML_FILE_NAME}'!"
                more "${TMPDIR}\xmllint.txt"
				EXIT_CODE=1
			fi
			break
		fi

		# if doesn't find .xsd schema by any of paths complain about this
		if [ "$jj" == "$[${SCHEMA_FILE_PATH_COUNT}-1]" ] ; then
			echo "Error: No XML schema found for ${XML_FILE_NAME}!"
			EXIT_CODE=1
		fi

		((jj++))
	done

	((ii++))
done

if [ ${EXIT_CODE} -eq 0 ] ; then
	if [ $DEBUG_MODE -eq 1 ] ; then
    	echo "XML validation completed"
	fi
else
    echo "XML validation failed!"
fi
exit ${EXIT_CODE}
