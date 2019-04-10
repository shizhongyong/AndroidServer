#!/bin/bash

./gradlew clean assembleRelease

APK_FILE=$(find app/build/outputs/apk/ -name "*.apk" -type f | head -n 1)
APK_NAME=$(basename $APK_FILE .apk)
MAPPING_FILE=$(find app/build/outputs/mapping/ -name "mapping.txt" -type f | head -n 1)
RELEASE_PATH=/Users/jingxin/Android/server/release

cp -f $APK_FILE $RELEASE_PATH
cp -f $MAPPING_FILE $RELEASE_PATH/${APK_NAME}-mapping.txt