#证书名称
DEVELOPER_SIGN="iPhone Distribution: Shanghai Jinqiao Export Processing Zone Development Co.,LTD"
#团队ID,证书内称为用户ID
TEAM_ID="9482W8V8YZ"
#-------------------------#-------------------------#-------------------------
#脚本工作目录
ShellPath=$(cd "$(dirname "$0")"; pwd)
#cd "${ShellPath}"

#解压后 .app 绝对路径[../Payload/package.app]
APP_Payload_PATH="$1"
cd "$1"
APP_DIR=$(cd ..; pwd)

APPName=$(basename ${APP_Payload_PATH} .app)
APPLICATIONIDENTIFIER="${TEAM_ID}.$2"

#0x01 证书
cp -rf "${ShellPath}/embedded.mobileprovision" "${APP_Payload_PATH}/embedded.mobileprovision"

echo "(0x01) 证书替换完成. √  "
echo ""

#0x02 替换App idet
cp -rf "${ShellPath}/entitlements.plist" "${APP_Payload_PATH}/"

ENTITL_PLIST="${APP_Payload_PATH}/entitlements.plist"
plutil -replace application-identifier -string ${APPLICATIONIDENTIFIER} "${ENTITL_PLIST}"

IPA_PLIST_PATH="${APP_Payload_PATH}/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $2" "${IPA_PLIST_PATH}"

echo "(0x02) 替换 entitlements for application-identifier 完成 √  "
echo ""

#0x03 删除已有签名
rm -rf "${APP_Payload_PATH}/_CodeSignature"

echo "(0x03) 删除已有签名完成. √  "
echo ""

#0x04 重新签名
echo "(0x04)-->正在重新签名..."
codesign -fs "${DEVELOPER_SIGN}" --no-strict --entitlements="${APP_Payload_PATH}/entitlements.plist" "${APP_Payload_PATH}"

echo "(0x04) 正在重新签名完成. √  "
echo ""

echo "(0x05)-->正在打包生成IPA..."
#xcrun 开始打包
IPA_PATH="${APP_DIR}/${APPName}.ipa"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP_Payload_PATH}"  -o "${IPA_PATH}"

#查询打包是否成功
if [ ! -f "${IPA_PATH}" ]; then
  echo "----------------------------------------------------"
	echo "--> ERROR-错误501：找不到签名生成的IPA包, SO? 打包APP失败."
	exit 1
else
	echo "(0x06) 打包APP完成! √ "
  echo ""
fi
