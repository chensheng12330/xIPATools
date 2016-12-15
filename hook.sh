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
MDM_PLIST="Info.plist"
# 读取Plist内容(其余配置信息后续加)
APP_Identify=$(/usr/libexec/PlistBuddy -c "Print:CFBundleIdentifier" "${INPUT_PATH}/${MDM_PLIST}")
APP_DisplayName=$(/usr/libexec/PlistBuddy -c "Print:CFBundleDisplayName" "${INPUT_PATH}/${MDM_PLIST}")
APP_Version=$(/usr/libexec/PlistBuddy -c "Print:CFBundleShortVersionString" "${INPUT_PATH}/${MDM_PLIST}")
APP_needSIP=$(/usr/libexec/PlistBuddy -c "Print:needSIP" "${INPUT_PATH}/${MDM_PLIST}")

APPLICATIONIDENTIFIER="${TEAM_ID}.${APP_Identify}"
#解包APK副本路径 ${APP_Identify}
IPACopy="${ShellPath}/src_ipa/${APP_Identify}.ipa"

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
	echo "--> ERROR-错误501：找不到封IPA原始包:[${APP_Identify}.ipa], 请复制对应的IPA包到 /src_ipa/ 目录中."
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
echo " "

############################################
#step 0x03 替换图片资源

#应用程序图标
#AppIcon60x60@2x.png	AppIcon60x60@3x.png

#启动图片
#LaunchImage-568h@2x.png		LaunchImage-700@2x.png		LaunchImage@2x.png
#LaunchImage-700-568h@2x.png	LaunchImage-800-667h@2x.png
echo "(0x04)-->替换图片资源..."
DUP_APP=$(ls "${DUP_APK_PATH}/Payload/")

#${ShellPath}
APP_Payload_PATH="${DUP_APK_PATH}/Payload/${DUP_APP}"
echo $APP_Payload_PATH

#AppIcon60x60@2x.png	AppIcon60x60@3x.png
#ICONS
cp -rf "${INPUT_PATH}/icon@2x.png" "${APP_Payload_PATH}/AppIcon60x60@2x.png"
cp -rf "${INPUT_PATH}/icon@3x.png" "${APP_Payload_PATH}/AppIcon60x60@3x.png"

#Default-568h@2x.png  LaunchImage-700@2x.png 640*1136
cp -rf "${INPUT_PATH}/Default-568h@2x.png" "${APP_Payload_PATH}/LaunchImage-568h@2x.png"
cp -rf "${INPUT_PATH}/Default-568h@2x.png" "${APP_Payload_PATH}/LaunchImage-700@2x.png"

#LaunchImage@2x.png  LaunchImage-700-568h@2x.png
cp -rf "${INPUT_PATH}/Default@2x.png" "${APP_Payload_PATH}/LaunchImage@2x.png"
cp -rf "${INPUT_PATH}/Default@2x.png" "${APP_Payload_PATH}/LaunchImage-700-568h@2x.png"

#Default@3x.png
cp -rf "${INPUT_PATH}/Default@3x.png" "${APP_Payload_PATH}/LaunchImage-800-667h@2x.png"

#Default@4x.png
cp -rf "${INPUT_PATH}/Default@4x.png" "${APP_Payload_PATH}/LaunchImage-800-Portrait-736h@3x.png"

#证书
cp -rf "${INPUT_PATH}/mdm.mobileprovision" "${APP_Payload_PATH}/embedded.mobileprovision"
cp -rf "${INPUT_PATH}/entitlements.plist" "${APP_Payload_PATH}/"

#替换App idet
ENTITL_PLIST="${ShellPath}/${APP_Payload_PATH}/entitlements.plist"
echo $ENTITL_PLIST

plutil -replace application-identifier -string ${APPLICATIONIDENTIFIER} "${ENTITL_PLIST}"

echo "(0x04)  √  "
echo ""

############################################
echo "(0x05)-->正在修改APP工程中plist信息..."

IPA_PLIST_PATH="${APP_Payload_PATH}/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_DisplayName" "${IPA_PLIST_PATH}"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $APP_Identify" "${IPA_PLIST_PATH}"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_Version"  "${IPA_PLIST_PATH}"
/usr/libexec/PlistBuddy -c "Set :needSIP $APP_needSIP" "${IPA_PLIST_PATH}"

#cp -rf "${INPUT_PATH}/${MDM_PLIST}" "${APP_Payload_PATH}/${MDM_PLIST}"


rm -rf "${APP_Payload_PATH}/_CodeSignature"

echo "(0x05)  √  "
echo ""

############################################
echo "(0x06)-->正在重新签名..."

codesign -fs "${DEVELOPER_SIGN}" --no-strict --entitlements="${ShellPath}/${APP_Payload_PATH}/entitlements.plist" "${ShellPath}/${APP_Payload_PATH}"

echo $APP_Payload_PATH
echo "(0x06)  √  "
echo ""

############################################
echo "(0x06)-->正在打包生成IPA..."
#xcrun 开始打包
IPA_PATH="${INPUT_PATH}/$2"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${ShellPath}/${APP_Payload_PATH}"  -o "${IPA_PATH}"

#查询打包是否成功
if [ ! -f "${IPA_PATH}" ]; then
  echo "----------------------------------------------------"
	echo "--> ERROR-错误501：找不到签名生成的IPA包, SO? 打包APP失败."
	exit 1
else
	echo "(0x06) 打包APP完成! √ "
  echo ""
fi

#清理资源
#rm -rf ${DUP_APK_PATH}

echo '----------------------------------------------------'
echo "安装包--->  ${INPUT_PATH}"
echo '----------------------------------------------------'
