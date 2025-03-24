#!/bin/sh

# IBM Confidential
# Copyright IBM Corp. 2016, 2020. Copyright WSI Corporation 1998, 2015

#
# This script will process *all* frameworks in the app bundle's Frameworks
# folder and (optionally):
#
#   + strip any bitcode from the framework and dSYM binaries
#   + strip any simulator code from the framework and dSYM binaries
#   + code sign the framework
#
# Note that released apps that are uploaded to the App Store can't contain
# simulator code (e.g. x86_64) or they will be rejected on upload.
#
# Also, your app can't use bitcode unless *all* frameworks and libraries
# used by the app themselves contain bitcode.
#
# Most apps will have a script like this one to process any 3rd party
# frameworks and/or libraries that the app uses although in some cases,
# it might be preferable to remove bitcode and/or unused architectures
# once in the source binaries rather than each time the app is built.
#
# You can either add this one to your own apps (e.g. as a post-build step) or
# merge any/all of the code below into an existing script.
#
# Note: In general, you only *really* need to strip architectures when doing a
# release build for the app store.
#
# This script will process the frameworks for any build configuration other
# than "Debug" - you can change this if desired (e.g. so stripping isn't done
# when doing "Devel" builds for AppCenter etc.).

# set to 1 if you want to codesign the frameworks (not generally needed) NOT TESTED YET
shouldCodeSign=0

# set to 1 if you want to strip ununsed code slices (architectures) from the frameworks
shouldStripBinary=1

# set to 1 if you want to remove bitcode from the frameworks NOT TESTED YET
shouldStripBitCode=0

function vLog()
{
    echo "[PF]: $1"
}


#
# Strips 32-bit and simulator architectures from the given binary.
#
function stripfile()
{
    targetPathName=$1
    targetName=$2
    
    input_archs=`lipo -archs "$targetPathName"`

    strip_params=""
    if [[ ${input_archs} == *"i386"* ]]; then
        strip_params="-remove i386"
    fi
    if [[ ${input_archs} == *"x86_64"* ]]; then
        strip_params="${strip_params} -remove x86_64"
    fi
    if [[ ${input_archs} == *"armv7"* ]]; then
        strip_params="${strip_params} -remove armv7"
    fi
    if [[ ${input_archs} == *"armv7s"* ]]; then
        strip_params="${strip_params} -remove armv7s"
    fi
    if [[ ${input_archs} == *"arm64e"* ]]; then
        strip_params="${strip_params} -remove arm64e"
    fi

    if [ "$strip_params" != "" ]; then
        lipo "$targetPathName" ${strip_params} -output "$targetPathName"
        output_archs=`lipo -archs "$targetPathName"`
        printf "%-35s: %s --> %s\n" "${targetName}" "$input_archs" "$output_archs"
    else
        printf "%-35s: %s (already stripped)\n" "${targetName}" "$input_archs"
    fi
}


function stripframework()
{
    targetDir=$1
    targetName=${targetDir%.framework}
    targetName=${targetName##*/}
    stripfile "$targetDir/$targetName" $targetName

    # also strip dSYM if it's beside xxx.framework as xxx.framework.dSYM?
    if [ "1" == "1" ]; then
        dSYMDir=$targetDir.dSYM
        if [ -d $dSYMDir ]; then
                dSYMBinary=$dSYMDir/Contents/Resources/DWARF/$targetName
                if [ -f $dSYMBinary ]; then
                    stripfile "$dSYMBinary" "${targetName} (dsym)"
                else
                    echo "${targetName} [Error]: missing DWARF in dSYM!"
                    EXIT_CODE=1
                fi
        fi
    fi
}


function striplibrary()
{
    targetPathName=$1
    targetName=${targetPathName%.a}
    targetName=${targetName##*/}
    stripfile "$targetPathName" "${targetName}"
}

# bail if we're doing a "Debug" build (generally no need to strip anything)
if [ "${CONFIGURATION}" == "Debug" ]; then
    exit 0
fi

EXIT_CODE=0

#env

FRAMEWORKS_DIR="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Frameworks"
#FRAMEWORKS_DIR="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
#SRC_DIR="./Embedded"

echo "Processing frameworks in '$FRAMEWORKS_DIR'"

frameworkPaths=( $(find ${FRAMEWORKS_DIR} -name '*.framework' -type directory) )
numFrameworks=${#frameworkPaths[@]}
if [ "$numFrameworks" != "0" ]; then
    for frameworkPath in "${frameworkPaths[@]}" ; do
        frameworkName=$(basename "$frameworkPath")
        frameworkName=${frameworkName/".framework"/""}
        frameworkDSYM="${frameworkPath}.dSYM"

        #vLog "Found '${frameworkName}"
        
        shouldProcess=1

        # Note: you could look for specific frameworks here and choose to
        # skip over those if you want by setting shouldProcess to 0.

        if [ "$shouldProcess" == "1" ]; then
            #destinationFramework="${FRAMEWORKS_DIR}/${frameworkName}.framework"
            #if [ -d "$destinationFramework" ]; then
            #    rm -fR "$destinationFramework"
            #fi

            # make sure the target directory exists
            #if [ ! -d "${FRAMEWORKS_DIR}" ]; then
            #    mkdir "${FRAMEWORKS_DIR}"
            #fi

            #echo "    copying '$frameworkPath'..."
            #cp -R "$frameworkPath" "${FRAMEWORKS_DIR}"
            #if [ $? -ne 0 ] ; then
            #    echo "    Error: copy failed for '$frameworkName'!"
            #    EXIT_CODE=1
            #fi

            #if [ -d ${frameworkDSYM} ]; then
            #    echo "    copying dSYM: '$frameworkDSYM' into ${BUILT_PRODUCTS_DIR}..."
            #    cp -Rf ${frameworkDSYM} "${BUILT_PRODUCTS_DIR}"
            #    if [ $? -ne 0 ] ; then
            #        echo "    Error: copy failed for ${frameworkDSYM}!"
            #        EXIT_CODE=1
            #    fi
            #fi

            if [ "$shouldStripBinary" == "1" ]; then
                stripframework ${frameworkPath}
            fi

            if [ "$shouldStripBitCode" == "1" ]; then
                libraryName=${destinationFramework}/${frameworkName}
                echo "    stripping bitcode from '${libraryName}'..."
                ${DT_TOOLCHAIN_DIR}/usr/bin/bitcode_strip "${libraryName}" -r -o "${libraryName}"
                if [ $? -ne 0 ] ; then
                    echo "    Error: bitcode_strip failed for '$frameworkName'!"
                    EXIT_CODE=1
                fi
            fi

            if [ "$shouldCodeSign" == "1" ]; then
                echo "    code signing '$frameworkPath' using '${EXPANDED_CODE_SIGN_IDENTITY}'..."
                /usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements,flags --timestamp=none "$destinationFramework" &> /dev/null
                if [ $? -ne 0 ] ; then
                    echo "    Error: codesigning failed for '$frameworkName'!"
                    EXIT_CODE=1
                fi
            fi
        fi
    done
else
    EXIT_CODE=1
fi

exit $EXIT_CODE
