#!/bin/bash
# 深蓝蕴车路宝IOS打包工具
# Author：Sherwin.Chen
# Date：2016.07.19

#脚本使用说明  SLY_PackTool.sh app_data_xxx myAppName
#参数1  app_data_xxx 【绝对路径地址】文件夹中需要提供如下文件, 生成的APK包将会放在此文件夹上.
#ic_launcher-web.png, ic_launcher_144.png, ic_launcher_48.png,
#ic_launcher_72.png, ic_launcher_96.png, package_configure.xml,
#start_page_bg.png

#参数2  生成IPA包的名称 [myAppName]

BUNDLEIDENTIFIER=com.temobi.xin
APPLICATIONIDENTIFIER=TEAMID.${BUNDLEIDENTIFIER}
WECHATFILEPATH=$(pwd)/apps/WeChat
LIBNAME=PQWXHook.dylib
TEMPDIR=$(mktemp -d)
ORIGINDIR=$(pwd)

# 0.get argv

if [ x$1 != x ]
then
BUNDLEIDENTIFIER=$1
fi

# 1.unzip ipa

if [ $arch == "arm64" ]
then
unzip -qo ${WECHATFILEPATH}/WeChat.ipa -d $TEMPDIR
else
unzip -qo ${WECHATFILEPATH}/WeChat-dump-armv7.ipa -d $TEMPDIR
fi

# 2.copy files
cp ${WECHATFILEPATH}/embedded.mobileprovision $TEMPDIR/
cp ${WECHATFILEPATH}/entitlements.plist $TEMPDIR/
cp ${BUILD_DIR}/Debug-iphoneos/${LIBNAME} $TEMPDIR/

# 3.resign
cd $TEMPDIR
plutil -replace application-identifier -string ${APPLICATIONIDENTIFIER} entitlements.plist
plutil -replace CFBundleIdentifier -string ${BUNDLEIDENTIFIER} Payload/WeChat.app/Info.plist

mv ${LIBNAME} Payload/WeChat.app/
insert_dylib --all-yes @executable_path/${LIBNAME} Payload/WeChat.app/WeChat
mv Payload/WeChat.app/WeChat_patched Payload/WeChat.app/WeChat
chmod +x Payload/WeChat.app/WeChat

rm -rf Payload/WeChat.app/_CodeSignature
rm -rf Payload/WeChat.app/PlugIns
rm -rf Payload/WeChat.app/Watch
cp embedded.mobileprovision Payload/WeChat.app/
codesign -fs "iPhone Distribution: Shanghai Jinqiao Export Processing Zone Development Co.,LTD" --no-strict --entitlements=entitlements.plist Payload/WeChat.app/${LIBNAME}
codesign -fs "iPhone Distribution: Shanghai Jinqiao Export Processing Zone Development Co.,LTD" --no-strict --entitlements=entitlements.plist Payload/WeChat.app

# 4.end

cp -rf Payload/WeChat.app ${BUILD_DIR}/Debug-iphoneos/
rm -rf ${TEMPDIR}
