#!/bin/sh
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

# make sure the output directory exists
if [ ! -d "$UNIVERSAL_OUTPUTFOLDER" ]; then
  mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"
fi

# passed parameter is the name of target
PROJECT_NAME="$1"

# Step 1. Build Device and Simulator versions
xcodebuild BITCODE_GENERATION_MODE=bitcode -target "${PROJECT_NAME}" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build

xcodebuild -target "${PROJECT_NAME}" -configuration ${CONFIGURATION} -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" EXCLUDED_ARCHS=arm64 clean build

# Step 2. Copy the framework structure (from iphoneos build) to the universal folder
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}/${PROJECT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 3. Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
SIMULATOR_SWIFT_MODULES_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/."

if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"
fi

# Step 4. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework/${PROJECT_NAME}"

# Step 5. Convenience step to copy the framework to the project's directory
EXECUTABLES_DIR="${PROJECT_DIR}/Executables"
if [ ! -d "$EXECUTABLES_DIR" ]; then
  mkdir -p "${EXECUTABLES_DIR}"
fi

# Step 6. Copy everything to Executables
cp -R "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework" "${EXECUTABLES_DIR}"
