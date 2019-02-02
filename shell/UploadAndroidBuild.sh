#!/bin/bash

APK_PATH=$(find app/build/outputs/apk/ -name "*.apk" -type f)
MAPPING_PATH=$(find app/build/outputs/mapping/ -name "mapping.txt" -type f)
APP_ID=$(apkanalyzer manifest application-id $APK_PATH)
VERSION_NAME=$(apkanalyzer manifest version-name $APK_PATH)
VERSION_CODE=$(apkanalyzer manifest version-code $APK_PATH)
COMMIT_ID=$(git rev-parse --short HEAD)

echo $APK_PATH
echo $MAPPING_PATH
echo $APP_ID
echo $VERSION_NAME
echo $VERSION_CODE
echo $COMMIT_ID
echo $APP_ICON

DEST_DIR=~/Android/server/build/${APP_ID}
echo $DEST_DIR

mkdir -p $DEST_DIR

cp -f ${APK_PATH} ${DEST_DIR}/app.apk
cp -f ${MAPPING_PATH} ${DEST_DIR}/mapping-${COMMIT_ID}.txt
cp -f ${APP_ICON} ${DEST_DIR}/icon.png

echo "{\"name\":\"${APP_NAME}\", \"versionCode\":\"${VERSION_CODE}\", \"versionName\":\"${VERSION_NAME}\", \"packageName\":\"${APP_ID}\"}" > ${DEST_DIR}/app.json


# FIR网站token, 通过token获取上传证书
API_TOKEN=d98b00bb26bdd6a65ba0054ca7cccd9a
curl -X "POST" "http://api.fir.im/apps" \
-H "Content-Type: application/json" \
-d "{\"type\":\"android\", \"bundle_id\":\"${APP_ID}\", \"api_token\":\"${API_TOKEN}\"}" > fir.json

# 上传APK到FIR
apkKey=$(jq -r .cert.binary.key fir.json)
apkToken=$(jq -r .cert.binary.token fir.json)
apkUrl=$(jq -r .cert.binary.upload_url fir.json)

echo apk
echo $apkKey
echo $apkUrl

curl   -F "key=${apkKey}"              \
-F "token=${apkToken}"          \
-F "file=@${APK_PATH}"             \
-F "x:name=${APP_NAME}"            \
-F "x:version=${VERSION_NAME}"     \
-F "x:build=${VERSION_CODE}"       \
${apkUrl}


# 上传ICON到FIR
iconKey=$(jq -r .cert.icon.key fir.json)
iconToken=$(jq -r .cert.icon.token fir.json)
iconUrl=$(jq -r .cert.icon.upload_url fir.json)

curl   -F "key=${iconKey}"              \
-F "token=${iconToken}"          \
-F "file=@${APP_ICON}"          \
${iconUrl}

rm -f fir.json



