#!/bin/bash
# 深蓝蕴车路宝打包工具
# Author：黄盼青
# Date：2016.03.11
# Update: 2015.03.14

#脚本使用说明  SLY_PackTool.sh app_data_xxx 0  请将xcocebuild 工具升级xcode7以上才能支持新语法.
#参数1  app_data_xxx 文件夹中需要提供如下文件
#参数2  是否需要copy原副本
##  icon@2x.png   SIZE: 120*120
##  icon@3x.png   SIZE: 180*180
##  Default-568h@2x.png   SIZE:640*1136
##  Default@2x.png        SIZE:640*960
##  Default@3x.png        SIZE:750*1334
##  Default@3x.png        SIZE:1242*2208
##  mdm.plist     KEYS:  CFBundleDisplayName(名称)   CFBundleIdentifier(bundle ID)  CFBundleVersion(APP版本)  app_agent_id（车路宝商户ID）  app_company_info(APP公司名)  app_version_code(APP内部版本号)  app_baidumap_key(百度地图APP KEY)


ShellPath=$(cd "$(dirname "$0")"; pwd)

#工作副本目录,  可更新路径
WorkPath="${ShellPath}/../xcar/"

#编译模式  Debug & Release
Configuration="Release"

#Plist配置文件名
MDM_PLIST="info.plist"

echo '----------------------------------------------------'
echo '   深蓝蕴车路宝打包工具 v1.0 20160311 by 黄盼青/Sherwin'
echo '----------------------------------------------------'

# 判断脚本用法是否正确
if [ $# -le 0 ]; then
  echo "用法错误！示例:SLY_PackTool.sh [打包APP文件目录名] "
  exit 1
fi

INPUT_PATH="${ShellPath}/$1"

# 校验工程副本是否存在
echo "(0x01)-->校验工程副本文件..."
if [ ! -d "${WorkPath}" ]; then
	echo "错误：找不到工程副本，请在脚本中修改工程副本(WorkPath参数)位置"
	exit 1
else
	echo "(0x01) √  "
fi

# 校验配置文件
cd "${INPUT_PATH}"
echo "(0x02)-->校验Plist配置文件..."

if [ ! -f "${MDM_PLIST}" ]; then
	echo "错误：找不到MDM打包配置文件!"
	exit 1
else
	checkResut=`Plutil -lint "${INPUT_PATH}/${MDM_PLIST}"`
	okStr="${INPUT_PATH}/${MDM_PLIST}: OK"
	if [ ! "${checkResut}" == "${okStr}" ]; then
		echo "Plist配置文件错误!请检查配置文件是格式否正确！"
		exit 1
	else
		echo "(0x02) √  "
	fi
fi


# 拷贝项目代码到工作目录
cd "${ShellPath}"
TEMP_F="temp"

if [ "$2" == "0" ]; then
  echo "(0x03)-->使用已存的副本，不进行项目工程的Copy..."

else
  echo "(0x03)-->正在拷贝项目副本到临时文件..."
  rm -rf  "${TEMP_F}"
  mkdir -p  "${TEMP_F}"
  cp -rf "${WorkPath}" "${ShellPath}/${TEMP_F}/"
fi

echo "(0x03) √  "
echo ""

###工程配置文件路径
echo "(0x04)-->配置工程文件路径..."

cd "${TEMP_F}"
project_path=$(pwd)
project_name=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')
target_name="${project_name}"
#创建保存打包结果的目录
CU_DATA=`date +%Y-%m-%d_%H_%M`
result_path="${project_path}/build_release_${CU_DATA}"
mkdir -p "${result_path}"

if [ "${project_name}" -z ]; then
  echo "--> ERROR-错误401：找不到需要编译的工程,SO? 编译APP中断."
  exit 401
fi

echo "(0x04)  √   "
echo ""


##!!! 需要检测图片资源是否都存在
# 替换图片资源文件
echo "(0x05)-->正在替换图片资源..."
echo ""

#替换 App Icon
APP_ICONS_PATH="${project_path}/${project_name}/Assets.xcassets/AppIcon.appiconset/"
APP_LaunchS_PATH="${project_path}/${project_name}/Assets.xcassets/LaunchImage.launchimage/"

#ICONS
cp -rf "${INPUT_PATH}/icon@2x.png" "${APP_ICONS_PATH}"
cp -rf "${INPUT_PATH}/icon@3x.png" "${APP_ICONS_PATH}"

##替换启动图片
#Default-568h@2x.png
cp -rf "${INPUT_PATH}/Default-568h@2x.png" "${APP_LaunchS_PATH}"
cp -rf "${INPUT_PATH}/Default-568h@2x.png" "${APP_LaunchS_PATH}/Default-568h@2x-1.png"

#Default@2x.png
cp -rf "${INPUT_PATH}/Default@2x.png" "${APP_LaunchS_PATH}"
cp -rf "${INPUT_PATH}/Default@2x.png" "${APP_LaunchS_PATH}/Default@2x-1.png"

#Default@3x.png
cp -rf "${INPUT_PATH}/Default@3x.png" "${APP_LaunchS_PATH}"

#Default@4x.png
cp -rf "${INPUT_PATH}/Default@4x.png" "${APP_LaunchS_PATH}"

echo "(0x05)  √  "
echo ""

# 更改info.plist内容

echo "(0x06)-->正在修改APP工程中plist信息..."

#//////////////////////////////////////////
#copy plist配置到副本工程中去.
APP_Info_Plist_PATH="${project_path}/${project_name}/"
cp -rf "${INPUT_PATH}/${MDM_PLIST}" "${APP_Info_Plist_PATH}"


# 读取Plist内容(其余配置信息后续加)
#APP_Identify=$(/usr/libexec/PlistBuddy -c "Print:CFBundleIdentifier" "${INPUT_PATH}/${MDM_PLIST}")
APP_DisplayName=$(/usr/libexec/PlistBuddy -c "Print:CFBundleDisplayName" "${INPUT_PATH}/${MDM_PLIST}")
APP_Version=$(/usr/libexec/PlistBuddy -c "Print:CFBundleShortVersionString" "${INPUT_PATH}/${MDM_PLIST}")
#MDM_AgentID=$(/usr/libexec/PlistBuddy -c "Print:app_agent_id" "${INPUT_PATH}/${MDM_PLIST}")
#MDM_CompanyInfo=$(/usr/libexec/PlistBuddy -c "Print:app_company_info" "${INPUT_PATH}/${MDM_PLIST}")
#MDM_VersionCode=$(/usr/libexec/PlistBuddy -c "Print:app_version_code" "${INPUT_PATH}/${MDM_PLIST}")
#MDM_BaiduMapKey=$(/usr/libexec/PlistBuddy -c "Print:app_baidumap_key" "${INPUT_PATH}/${MDM_PLIST}")
#MDM_app_server_host=$(/usr/libexec/PlistBuddy -c "Print:app_server_host" "${INPUT_PATH}/${MDM_PLIST}")
#//////////////////////////////////////////

#INFO_PLIST="${project_path}/${project_name}/Info.plist"
#/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_DisplayName" "${INFO_PLIST}"
#/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $APP_Identify" "${INFO_PLIST}"
#/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $APP_Version" "${INFO_PLIST}"
#/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_Version" "${INFO_PLIST}"
#/usr/libexec/PlistBuddy -c "Set :app_agent_id $MDM_AgentID" "${INFO_PLIST}"
#/usr/libexec/PlistBuddy -c "Set :app_company_info $MDM_CompanyInfo" "${INFO_PLIST}"
#/usr/libexec/PlistBuddy -c "Set :app_version_code $MDM_VersionCode" "${INFO_PLIST}"
#/usr/libexec/PlistBuddy -c "Set :app_baidumap_key $MDM_BaiduMapKey" "${INFO_PLIST}"
#/usr/libexec/PlistBuddy -c "Set :app_server_host $MDM_app_server_host" "${INFO_PLIST}"

echo "(0x06)  √  "
echo ""

# 编译打包


#打包完的程序目录
appDir="${result_path}/${target_name}.app"
#dSYM的路径
dsymDir="${result_path}/${target_name}.app.dSYM"

#xcode_build=""

#编译工程
echo "(0x08)-->开始编译，耗时操作,请稍等..."
echo ""
#"${xcode_build}" clean / -arch arm64 ONLY_ACTIVE_ARCH=NO
xcodebuild -configuration Release -workspace "${ShellPath}/${TEMP_F}/${project_name}".xcworkspace -scheme "${project_name}" ONLY_ACTIVE_ARCH=NO TARGETED_DEVICE_FAMILY=1 DEPLOYMENT_LOCATION=YES CONFIGURATION_BUILD_DIR="${result_path}" clean build

#查询编译APP是否成功
if [ ! -d "${appDir}" ]; then
	echo "--> ERROR-错误501：找不到编译生成的APP,SO? 编译APP失败."
	exit 1
else
	echo "(0x08) 编译APP完成! √ "
fi

echo ""
echo "(0x09)-->开始打包请稍等..."
echo ""
#cd "${result_path}"

#创建打包生成目录
#cd "${ShellPath}"

IPA_APP_DIR="${ShellPath}/${APP_DisplayName}_${APP_Version}_${CU_DATA}"
mkdir "${IPA_APP_DIR}"

IPA_PATH="${IPA_APP_DIR}/${APP_DisplayName}_${APP_Version}.ipa"
APP_PATH="${IPA_APP_DIR}/${APP_DisplayName}_${APP_Version}.app"
SYM_PATH="${APP_PATH}.dSYM"

#复制编译好的APP到 目标文件夹里，注：编译出来的目录，有可能是软连接.
cp -r "${appDir}" "${APP_PATH}"

#xcrun 开始打包
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP_PATH}"  -o "${IPA_PATH}"

#查询打包是否成功
if [ ! -f "${IPA_PATH}" ]; then
  echo "----------------------------------------------------"
	echo "--> ERROR-错误501：找不到签名生成的IPA包, SO? 打包APP失败."
	exit 1
else
	echo "(0x09) 打包APP完成! √ "
  echo ""
fi

#拷贝过来.app.dSYM到输出目录
mv "${dsymDir}" "${SYM_PATH}"

rm -rf "${result_path}"

#cd "${ShellPath}"

echo "(0x0A)-->Nice Worker! -->打包成功!  GET √ "

echo '----------------------------------------------------'
echo "安装包--->  ${IPA_APP_DIR}"
echo '----------------------------------------------------'

open "${IPA_APP_DIR}"

exit 0
