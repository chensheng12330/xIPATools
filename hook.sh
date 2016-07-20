#!/bin/bash

# 深蓝蕴车路宝IOS打包工具
# Author：Sherwin.Chen
# Date：2016.07.19

#脚本使用说明  SLY_PackTool.sh app_data_xxx myAppName
#-------------------------
#参数1  app_data_xxx 【绝对路径地址】文件夹中需要提供如下文件, 生成的APK包将会放在此文件夹上.
#ic_launcher-web.png, ic_launcher_144.png, ic_launcher_48.png,
#ic_launcher_72.png, ic_launcher_96.png, package_configure.xml,
#start_page_bg.png
#-------------------------
#参数2  生成IPA包的名称 [myAppName],文件将会放到 app_data_xxx 目录中去.
#-------------------------

#####
#打包证书信息定义

#证书名称
DEVELOPER_SIGN="iPhone Distribution: Shanghai Jinqiao Export Processing Zone Development Co.,LTD"
#团队ID,证书内称为用户ID
TEAM_ID="9482W8V8YZ"
#-------------------------#-------------------------#-------------------------

#脚本工作目录
ShellPath=$(cd "$(dirname "$0")"; pwd)

cd "${ShellPath}"

#打包资源文件夹绝对路径
INPUT_PATH="$1"

#Plist配置文件名
MDM_PLIST="mdm.plist"
# 读取Plist内容(其余配置信息后续加)
APP_Identify=$(/usr/libexec/PlistBuddy -c "Print:CFBundleIdentifier" "${INPUT_PATH}/${MDM_PLIST}")
APP_DisplayName=$(/usr/libexec/PlistBuddy -c "Print:CFBundleDisplayName" "${INPUT_PATH}/${MDM_PLIST}")

#解包APK副本路径 ${APP_Identify}
IPACopy="${ShellPath}/src_ipa/vcar.ipa"

#工作副本目录,  可更新路径，绝对路径，脚本内自定义
Workspace="workspace"


#step 0x01 检查参数
#检测参数1
echo "(0x00)-->校验打包资源文件夹是否存在..."
if [ ! -d "${INPUT_PATH}" ]; then
	echo "打包资源文件夹不存在，请检察脚本参数1."
	exit 1
else
	echo "--参数1正确 √ "
fi

#检测参数2
if [ ! -n "$2" ] ;then
	echo "需要生成IPA包名不存在，请检察脚本参数2."
	exit 1
else
	echo "--参数2正确 √ "
fi

#检测IPA文件是否存在
if [ ! -f "${IPACopy}" ]; then
	echo "--> ERROR-错误501：找不到封IPA原始包:[${APP_Identify}.apk], 请复制对应的IPA包到 /src_ipa/ 目录中."
	exit 1
else
  echo "(0x00) √  "
  echo ""
fi

############################################


#step 0x02  将副本IPA拷贝至工作区，若工作区已存在，则删除；
echo "(0x02)-->正在解压IPA副本到临时工作目录..."
PayloadDIR="Payload"
TEMP_ID=`date +%Y%m%d%H%M%S`
TEMP_F="temp${TEMP_ID}"

#临时工作目录，完成操作后，删除此临时工作目录
Project_TEMP="${Workspace}/${TEMP_F}"
mkdir -p "${Project_TEMP}"

DUP_APK_PATH="${Project_TEMP}"
unzip -qo "${IPACopy}" -d "$DUP_APK_PATH"

echo "(0x02) √  "

#step 0x03 替换图片资源

#ICON

#启动图片
#LaunchImage-568h@2x.png		LaunchImage-700@2x.png		LaunchImage@2x.png
#LaunchImage-700-568h@2x.png	LaunchImage-800-667h@2x.png
echo "(0x04)-->替换图片资源..."

APP_Payload_NAME=$(ls)




BUNDLEIDENTIFIER="com.temobi.xin"
IPA_NAME="WeChat.ipa"
APP_NAME="xin.app"
EXE_NAME="xin"
DISPLAYNAME="懒人辅助"
LIBNAME="PerfectWX.dylib"
BUNDLEFILE="PerfectWXRes.bundle"
IMG_PATH="$(pwd)/img/*.png"
AlwaysUsageDescription="抢红包"


PACKAGEPATH="$(pwd)/package/"
APPLICATIONIDENTIFIER="${TEAM_ID}.${BUNDLEIDENTIFIER}"

TEMPDIR=$(mktemp -d)
ORIGINDIR=$(pwd)


# 1.解压IPA包
unzip -qo ${PACKAGEPATH}/${IPA_NAME} -d $TEMPDIR

# 2.拷贝资源文件到临时目录
cp ${PACKAGEPATH}/embedded.mobileprovision $TEMPDIR/
cp ${PACKAGEPATH}/entitlements.plist $TEMPDIR/
cp ${PACKAGEPATH}/libReveal.dylib $TEMPDIR/

# 3.修改Plist文件
cd $TEMPDIR

plutil -replace application-identifier -string ${APPLICATIONIDENTIFIER} entitlements.plist

INFO_PLIST_CHS=Payload/${APP_NAME}/zh_CN.lproj/InfoPlist.strings
INFO_PLIST=Payload/${APP_NAME}/Info.plist


/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $DISPLAYNAME" "${INFO_PLIST_CHS}"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLEIDENTIFIER" "${INFO_PLIST}"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $DISPLAYNAME" "${INFO_PLIST}"
/usr/libexec/PlistBuddy -c "Set :NSLocationAlwaysUsageDescription $AlwaysUsageDescription" "${INFO_PLIST}"
/usr/libexec/PlistBuddy -c "Add :UIBackgroundModes:array string 'location'" "${INFO_PLIST}"

NSLocationAlwaysUsageDescription

# 4.动态库注入

cp ${BUILD_DIR}/${CONFIGURATION}-iphoneos/${LIBNAME} Payload/${APP_NAME}/
cp -r ${BUILD_DIR}/${CONFIGURATION}-iphoneos/${BUNDLEFILE} Payload/${APP_NAME}/
mv libReveal.dylib Payload/${APP_NAME}/
insert_dylib --all-yes @executable_path/${LIBNAME} Payload/${APP_NAME}/${EXE_NAME}
mv Payload/${APP_NAME}/${EXE_NAME}_patched Payload/${APP_NAME}/${EXE_NAME}
insert_dylib --all-yes @executable_path/libReveal.dylib Payload/${APP_NAME}/${EXE_NAME}
mv Payload/${APP_NAME}/${EXE_NAME}_patched Payload/${APP_NAME}/${EXE_NAME}
chmod +x Payload/${APP_NAME}/${EXE_NAME}

# 5.删除多余的Target和签名
rm -rf Payload/${APP_NAME}/_CodeSignature
rm -rf Payload/${APP_NAME}/PlugIns
rm -rf Payload/${APP_NAME}/Watch

# 6.替换图片资源
cp -rf ${IMG_PATH} Payload/${APP_NAME}

# 6.重新签名
cp embedded.mobileprovision Payload/${APP_NAME}/
codesign -fs "${DEVELOPER_SIGN}" --no-strict --entitlements=entitlements.plist Payload/${APP_NAME}/libReveal.dylib
codesign -fs "${DEVELOPER_SIGN}" --no-strict --entitlements=entitlements.plist Payload/${APP_NAME}/${LIBNAME}
codesign -fs "${DEVELOPER_SIGN}" --no-strict --entitlements=entitlements.plist Payload/${APP_NAME}

# 7.拷贝.app替换假Target生成的.app
cp -rf Payload/${APP_NAME} ${BUILD_DIR}/${CONFIGURATION}-iphoneos/

# 8.清理工作
rm -rf ${TEMPDIR}
