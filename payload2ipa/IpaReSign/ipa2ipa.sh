#!/bin/bash

# 盒子支付 移动支付部门 IOS重签名工具
# Author：Sherwin.Chen
# Mail: chensheng12330@gmail.com
# GitHub: chensheng12330
# Date：2016.12.15

#脚本使用说明  ipa2ipa.sh ipa_data_xxx
#需要在 ipa_data_xxx 文件夹中，提供
#--> entitlements.plist   签名时所需的环境配置文件,可参考模板里的 entitlements.plist-->[9482W8V8YZ.com.temobi.vcar] 进行设置.[TeamID + APPID]组合
#--> Info.plist           APP的相关信息配置,方便打包时引用.
#--> mdm.mobileprovision  签名所需要的新证书文件.
#--> src.ipa   						被签名的源ipa包,执行脚本前需要把此名字设置好，默认为 "src.ipa"
#

#证书名称【替换成自己需要打包的证书名称】
IBP_AdHoc="iPhone Distribution: decai LI (DJYRL6FJ8P)"
IBP_Dis="iPhone Distribution: decai LI (DJYRL6FJ8P)"
IBP_Debug="iPhone Distribution: decai LI (DJYRL6FJ8P)"
TMB_AdHoc="iPhone Distribution: Shanghai Jinqiao Export Processing Zone Development Co.,LTD"

IBP_TID="DJYRL6FJ8P"
TMB_TID="9482W8V8YZ"


DEVELOPER_SIGN=${IBP_AdHoc}

#团队ID,证书内称为用户ID /PS: entitlements.plist文件内需要改成一致,如:9482W8V8YZ.com.ucweb.iphone.lowversion
TEAM_ID=${IBP_TID}

#Plist配置文件名 [ipa_data_xxx文件夹内]
MDM_PLIST="Info.plist"

#被签名的源ipa包包
SRC_IPA="src.ipa"

SH_LOG="-------------------盒子支付-------------------"
#-------------------------#-------------------------#-------------------------


#脚本工作目录
ShellPath=$(cd "$(dirname "$0")"; pwd)

#进入脚本当前工作环境下面，方便使用相对路径.
cd "${ShellPath}"

#需要重新签名的资源文件夹绝对路径 [/root/home/shewin/ibox/]
INPUT_PATH="${ShellPath}/$1"

#需要检测文件夹以及所需要的文件是否存在，
#step 0x01 检查参数
#检测参数1
echo "(0x00)-->校验打包资源文件夹是否存在..."
if [ ! -d "${INPUT_PATH}" ]; then
	echo "打包资源文件夹不存在，请检察脚本参数1.请提供如下文件："
echo "--> entitlements.plist"
echo "--> Info.plist"
echo "--> mdm.mobileprovision"
exit 1
else
	echo ""
fi
#-------------------------#---------------------

# 读取Plist内容(其余配置信息后续加)
APP_Identify=$(/usr/libexec/PlistBuddy -c "Print:CFBundleIdentifier" "${INPUT_PATH}/${MDM_PLIST}")
APP_DisplayName=$(/usr/libexec/PlistBuddy -c "Print:CFBundleDisplayName" "${INPUT_PATH}/${MDM_PLIST}")
APP_Version=$(/usr/libexec/PlistBuddy -c "Print:CFBundleShortVersionString" "${INPUT_PATH}/${MDM_PLIST}")

APPLICATIONIDENTIFIER="${TEAM_ID}.${APP_Identify}"

#解包APK副本路径 ${APP_Identify}
IPACopy="${INPUT_PATH}/${SRC_IPA}"

#检测IPA文件是否存在
if [ ! -f "${IPACopy}" ]; then
	echo "--> ERROR-错误501：找不到封IPA原始包:[${SRC_IPA}], 请复制对应的IPA包到 /${INPUT_PATH}/ 目录中."
	exit 1
else
  echo "(0x00) √  "
  echo $SH_LOG
  echo ""
fi

#工作副本目录,  可更新路径，绝对路径，脚本内自定义
Workspace="workspace"


#step 0x01  将副本IPA拷贝至工作区，若工作区已存在，则删除；
echo "(0x01)-->正在解压IPA副本到临时工作目录..."
PayloadDIR="Payload"
TEMP_ID=`date +%Y%m%d%H%M%S`
TEMP_F="temp${TEMP_ID}"

#临时工作目录，完成操作后，删除此临时工作目录
Project_TEMP="${Workspace}/${TEMP_F}"
mkdir -p "${Project_TEMP}"

DUP_APK_PATH="${Project_TEMP}"
unzip -qo "${IPACopy}" -d "$DUP_APK_PATH"

echo "(0x01) √  "
echo $SH_LOG
echo " "

############################################
#step 0x02 替换证书&环境文件

#应用程序图标
#AppIcon60x60@2x.png	AppIcon60x60@3x.png

#启动图片
#LaunchImage-568h@2x.png		LaunchImage-700@2x.png		LaunchImage@2x.png
#LaunchImage-700-568h@2x.png	LaunchImage-800-667h@2x.png
echo "(0x02)-->替换证书&环境文件..."
DUP_APP=$(ls "${DUP_APK_PATH}/Payload/")

APP_Payload_PATH="${DUP_APK_PATH}/Payload/${DUP_APP}"

#证书
cp -rf "${INPUT_PATH}/mdm.mobileprovision" "${APP_Payload_PATH}/embedded.mobileprovision"
cp -rf "${INPUT_PATH}/entitlements.plist" "${APP_Payload_PATH}/"

#替换App idet
ENTITL_PLIST="${ShellPath}/${APP_Payload_PATH}/entitlements.plist"
echo $ENTITL_PLIST

plutil -replace application-identifier -string ${APPLICATIONIDENTIFIER} "${ENTITL_PLIST}"

echo "(0x02)  √  "
echo $SH_LOG
echo ""

############################################
echo "(0x03)-->修改APP工程中info.plist信息..."

IPA_PLIST_PATH="${APP_Payload_PATH}/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_DisplayName" "${IPA_PLIST_PATH}"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $APP_Identify" "${IPA_PLIST_PATH}"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_Version"  "${IPA_PLIST_PATH}"

#cp -rf "${INPUT_PATH}/${MDM_PLIST}" "${APP_Payload_PATH}/${MDM_PLIST}"

rm -rf "${APP_Payload_PATH}/_CodeSignature"

echo "(0x03)  √  "
echo $SH_LOG
echo ""

############################################
echo "(0x04)-->正在重新签名..."

codesign -fs "${DEVELOPER_SIGN}" --no-strict --entitlements="${ShellPath}/${APP_Payload_PATH}/entitlements.plist" "${ShellPath}/${APP_Payload_PATH}"

echo "(0x04)  √  "
echo $SH_LOG
echo ""

############################################
echo "(0x05)-->正在打包生成IPA,耗时操作,请稍等,如需中断请按 [Conrtol+C]..."
#xcrun 开始打包

IPA_APP_DIR="${INPUT_PATH}/${APP_DisplayName}_${APP_Version}_${TEMP_ID}"
IPA_PATH="${IPA_APP_DIR}.ipa"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${ShellPath}/${APP_Payload_PATH}"  -o "${IPA_PATH}"

#查询打包是否成功
if [ ! -f "${IPA_PATH}" ]; then
  echo "-X----------------------------------------------------"
	echo "--> ERROR-错误501：找不到签名生成的IPA包, SO? 打包APP失败."
	exit 1
else
  echo ""
	echo "(0x05) 打包APP完成! √ "
  echo $SH_LOG
  echo ""
fi

#清理资源
rm -r ${Project_TEMP}

echo '----------------------------------------------------'
echo "安装包--->  ${INPUT_PATH}"
open ${INPUT_PATH}
echo '----------------------------------------------------'
