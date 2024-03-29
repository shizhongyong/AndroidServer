#!/usr/local/opt/bash/bin/bash
# mac系统bash版本太低，使用新版本bash

if [[ ${FLAVOR^^} == 'ALL' ]]; then
	CMD='assembleRelease'
else
	CMD="assemble${FLAVOR^}Release"
fi

./gradlew clean $CMD -PenableAbiSplit

# $?: 上个命令的退出状态，或函数的返回值
ret=$?

if [ $ret -eq 0 ];then
        echo 打包成功
else
        echo 打包失败
        exit $ret
fi

APK_ROOT=app/build/outputs/apk
MAPPING_ROOT=app/build/outputs/mapping
RELEASE_ROOT=/Users/jingxin/Android/server/release

for flavorPath in $APK_ROOT/*; do
	if [[ ! -d $flavorPath ]]; then
		continue
	fi

	CHANNEL=$(basename $flavorPath)
	APK_FILE=$(find $flavorPath -name "*.apk" -type f | head -n 1)
	MAPPING_FILE=$(find $MAPPING_ROOT/$CHANNEL -name "mapping.txt" -type f | head -n 1)
	
	if [[ ! $APK_FILE ]]; then
		continue
	fi

	if [[ ! $MAPPING_FILE ]]; then
		#从build tools 3.6.0开始，mapping目录有变化。例如：mapping/officialRelease
	    MAPPING_FILE=$(find $MAPPING_ROOT/${CHANNEL}Release -name "mapping.txt" -type f | head -n 1)
	fi

	APP_ID=$(apkanalyzer manifest application-id $APK_FILE)
	RELEASE_PATH=$RELEASE_ROOT/$APP_ID/$CHANNEL

	if [[ ! -d $RELEASE_PATH ]]; then
		mkdir -p $RELEASE_PATH
	fi
	
	find $flavorPath -name "*.apk" -type f -print | xargs -I {} cp -f {} $RELEASE_PATH

	if [[ $MAPPING_FILE ]]; then
		APK_NAME=$(basename $APK_FILE)
		MAPPING_NAME_PREFIX=${APK_NAME%${CHANNEL}*}
		cp -f $MAPPING_FILE $RELEASE_PATH/${MAPPING_NAME_PREFIX}${CHANNEL}-mapping.txt
	fi
done