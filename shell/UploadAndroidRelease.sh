#!/usr/local/opt/bash/bin/bash
# mac系统bash版本太低，使用新版本bash

if [[ ${FLAVOR^^} == 'ALL' ]]; then
	CMD='assembleRelease'
else
	CMD="assemble${FLAVOR^}Release"
fi

./gradlew clean $CMD

APK_ROOT=app/build/outputs/apk
MAPPING_ROOT=app/build/outputs/mapping
RELEASE_ROOT=/Users/jingxin/Android/server/release

for file in $APK_ROOT/*; do
	if [[ ! -d $file ]]; then
		continue
	fi

	CHANNEL=$(basename $file)
	APK_FILE=$(find $file -name "*.apk" -type f | head -n 1)
	MAPPING_FILE=$(find $MAPPING_ROOT/$CHANNEL -name "mapping.txt" -type f | head -n 1)
	
	if [[ ! $APK_FILE ]]; then
		continue
	fi

	APP_ID=$(apkanalyzer manifest application-id $APK_FILE)
	RELEASE_PATH=$RELEASE_ROOT/$APP_ID/$CHANNEL

	if [[ ! -d $RELEASE_PATH ]]; then
		mkdir -p $RELEASE_PATH
	fi
	
	cp -f $APK_FILE $RELEASE_PATH

	if [[ $MAPPING_FILE ]]; then
		APK_NAME=$(basename $APK_FILE .apk)
		cp -f $MAPPING_FILE $RELEASE_PATH/${APK_NAME}-mapping.txt
	fi
done