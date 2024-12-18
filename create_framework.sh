#!/bin/bash

SCHEME="ElasticApmWrapper"
BUILD_DIR="$(pwd)/DerivedData"
ARCHIVE_PATH_BASE="$(pwd)/archives"
XCFRAMEWORK_OUTPUT="$(pwd)/xcframeworks/${SCHEME}.xcframework"
CONFIGURATION="Release"

# Функция для архивирования
archive_framework() {
    local destination=$1
    local archive_path=$2

    xcodebuild archive \
        -scheme "$SCHEME" \
        -destination "$destination" \
        -archivePath "$archive_path" \
        -derivedDataPath "$BUILD_DIR" \
        -configuration "$CONFIGURATION" \
        SKIP_INSTALL=NO \
        INSTALL_PATH=/Library/Frameworks || {
        echo "Ошибка архивирования для $destination" >&2
        exit 1
    }
}

# Функция для сборки и копирования модулей
build_and_copy_modules() {
    local destination=$1
    local framework_dir=$2
    local swiftmodule_dir=$3
    local modulemap_path=$4

    xcodebuild build \
        -scheme "$SCHEME" \
        -destination "$destination" \
        -configuration "$CONFIGURATION" \
        -derivedDataPath "$BUILD_DIR" || {
        echo "Ошибка сборки для $destination" >&2
        exit 1
    }

    mkdir -p "$framework_dir/Modules/${SCHEME}.swiftmodule"
    cp -pv "$swiftmodule_dir"/* "$framework_dir/Modules/${SCHEME}.swiftmodule/"
    cp -pv "$modulemap_path" "$framework_dir/Modules/module.modulemap"
}

xcodebuild -resolvePackageDependencies \
    -scheme "$SCHEME" \
    -derivedDataPath "$BUILD_DIR"

# Архивирование и сборка для симулятора
archive_framework "generic/platform=iOS Simulator" "$ARCHIVE_PATH_BASE/${SCHEME}-Simulator.xcarchive"
build_and_copy_modules \
    "generic/platform=iOS Simulator" \
    "$ARCHIVE_PATH_BASE/${SCHEME}-Simulator.xcarchive/Products/Library/Frameworks/${SCHEME}.framework" \
    "$BUILD_DIR/Build/Products/${CONFIGURATION}-iphonesimulator/${SCHEME}.swiftmodule" \
    "$BUILD_DIR/Build/Intermediates.noindex/${SCHEME}.build/${CONFIGURATION}-iphonesimulator/${SCHEME}.build/${SCHEME}.modulemap"

# Архивирование и сборка для устройства
archive_framework "generic/platform=iOS" "$ARCHIVE_PATH_BASE/${SCHEME}-Device.xcarchive"
build_and_copy_modules \
    "generic/platform=iOS" \
    "$ARCHIVE_PATH_BASE/${SCHEME}-Device.xcarchive/Products/Library/Frameworks/${SCHEME}.framework" \
    "$BUILD_DIR/Build/Products/${CONFIGURATION}-iphoneos/${SCHEME}.swiftmodule" \
    "$BUILD_DIR/Build/Intermediates.noindex/${SCHEME}.build/${CONFIGURATION}-iphoneos/${SCHEME}.build/${SCHEME}.modulemap"

# Создание XCFramework
xcodebuild -create-xcframework \
    -allow-internal-distribution \
    -framework "$ARCHIVE_PATH_BASE/${SCHEME}-Simulator.xcarchive/Products/Library/Frameworks/${SCHEME}.framework" \
    -framework "$ARCHIVE_PATH_BASE/${SCHEME}-Device.xcarchive/Products/Library/Frameworks/${SCHEME}.framework" \
    -output "$XCFRAMEWORK_OUTPUT" || {
    echo "Ошибка создания XCFramework" >&2
    exit 1
}

echo "XCFramework создан: $XCFRAMEWORK_OUTPUT"
