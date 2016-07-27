#!/bin/bash

#第一步   将 app_pkg.sh 放入 /usr/local/bin
#第二步   chmode 777 /usr/local/bin  app_pkg.sh
#第三步   打包： app_pkg.sh /Users/sherwin/Library/Developer/Xcode/Archives/2016-07-05/xcar\ 16-7-5\ 17.46.xcarchive/Products/Applications/xcar.app


# 深蓝蕴车路宝IOS打包工具
# Author：Sherwin.Chen
# Date：2016.07.19

#脚本使用说明  app_pkg.sh [APP_Payload_PATH]
#-------------------------
#参数1  APP_Payload_PATH 【绝对路径地址】Xcode Archive后，会生成一个APP目录，该参数为此目录绝对值

#示例：app_pkg.sh /Users/sherwin/Library/Developer/Xcode/Archives/2016-07-05/xcar\ 16-7-5\ 17.46.xcarchive/Products/Applications/xcar.app
############################################
echo "-->正在打包生成IPA..."

#xcrun 开始打包
TEMP_ID=`date +%Y%m%d%H%M%S`
APP_Payload_PATH="$1"
IPA_PATH=$(cd ~; pwd)

IPA_PATH="${IPA_PATH}/${TEMP_ID}_APP.ipa"

/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP_Payload_PATH}"  -o "${IPA_PATH}"

#查询打包是否成功
if [ ! -f "${IPA_PATH}" ]; then
  echo "----------------------------------------------------"
	echo "--> ERROR-错误501：找不到签名生成的IPA包, SO? 打包APP失败."
	exit 1
else
	echo " 打包APP完成! √ "
  echo ""
fi

echo '----------------------------------------------------'
echo "安装包--->  ${IPA_PATH}"
echo '----------------------------------------------------'
