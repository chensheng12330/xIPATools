# 0x01 xIPATools 
 #深蓝蕴车路宝IOS打包工具<br>
 #Author：Sherwin.Chen<br>
 #Date：2016.07.19
 
 <br>
 <br>
# 0x02 脚本使用说明 
 ***
 ./SLY_PackTool.sh  <app_data_xxx>  <app_name.ipa>
##### 使用示例:<br/>
 **SLY_PackTool.sh /ios/devlp/app_data_xxx myAppName.ipa**
 
##### 参数说明
 * [参数1]  app_data_xxx 【绝对路径地址】文件夹中需要提供如下文件, 生成的APK包将会放在此文件夹上. 
 
| 文件名称 | 文件说明 | 
| ------------ | ------------- | 
| icon@2x.png |  |
| icon@3x.png |  |
| Default-568h@2x.png |  |
| Default@2x.png |  |
| Default@3x.png |  |
| Default@4x.png |  |

 
 * 参数2  生成IPA包的名称 [myAppName],文件将会放到 app_data_xxx 目录中去.