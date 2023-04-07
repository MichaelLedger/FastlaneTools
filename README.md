# Fastools

#### 介绍
Fastools 的目的是 利用 Fastlane 和 Ruby 对 iOS 工程 进行快速管理，包含iOS证书管理、iOS私有Pods的发布、iOS多个平台的发布（AppCenter，Fir，Pgyer，Testflight），等多项快速能力

#### 软件架构
工具而已，没有架构


#### 安装教程

1.  安装 bunlder 
2.  安装 fastools
3.  配置 env
* 在fastlane文件下，建立环境文件，比如`.env.appstore`
> 环境文件模版
```
#---------- Xcode Select ----------------
XCODE_SELECT = "/Applications/Xcode.app"

#----------- Apple Developer Variables --------------

ITC_TEAM_ID = "<ITC_TEAM_ID>" # App Store Connect Team ID for itunes connect account

TEAM_ID = "<TEAM_ID>" # Developer Portal Team ID for apple developer account

BUNDLE_IDENTIFIER = "<BUNDLE_IDENTIFIER>" # Your container app bundle-id

EXTENSION_BUNDLE_INDENTIFIERS = "<EXTENSION_BUNDLE_INDENTIFIERS1,EXTENSION_BUNDLE_INDENTIFIERS2,EXTENSION_BUNDLE_INDENTIFIERS3,...>" # Your extensions' bundle-id, seperated by `,`

CERTS_GIT_URL = "<CERTS_GIT_URL>" # Your git repository to store your apple developer certificats and profiles

FASTLANE_USER = "<FASTLANE_USER>" # Your developer apple id

FASTLANE_PASSWORD = "<FASTLANE_PASSWORD>" # Your password of developer apple id

DEVICES_PATH = "./fastlane/devices.txt" # The file path which store the uuid of your registered development devices

IS_ENTERPRISE = false # Is your apple developer account is an enterprise account or an app-store account

#----------- App Center         --------------

APPCENTER_API_TOKEN = "<APPCENTER_API_TOKEN>" # Your AppCenter API token

APPCENTER_OWNER_NAME = "<APPCENTER_OWNER_NAME>" # Your AppCenter user email

#----------- FIR                --------------
FIR_API_TOKEN = "<FIR_API_TOKEN>" # Your Fir API token

#----------- PGYER              --------------
PGYER_API_KEY = "<PGYER_API_KEY>" # Your Pgyer API token

PGYER_USER_KEY = "<PGYER_USER_KEY>" # Your Pgyer user key
#----------- BUGLY              --------------

BUGLY_APP_ID = "<BUGLY_APP_ID>" # Your Bugly App ID

BUGLY_APP_KEY = "<BUGLY_APP_KEY>" # Your Bugly App Key
#----------- Common Environment --------------

MATCH_PASSWORD = "<MATCH_PASSWORD>" # Your password for fastlane match

APP_SCHEME = "<APP_SCHEME>" # Your App Scheme

WORKSPACE = "<WORKSPACE.xcworkspace>" # Your project workspace

APP_NAME = "<APP_NAME>" # Your App Name

FASTLANE_DONT_STORE_PASSWORD = "1" # Do you want fastlane to store the password

BUILD_OUTPUT_DIRECTORY = "<BUILD_OUTPUT_DIRECTORY>" # Output directory for building ipa

DYSM_OUTPUT_DIRECTORY = "<DYSM_OUTPUT_DIRECTORY>" # Output directory for building dysm files
  
```


#### 使用说明
1.  Apple Developer Account 操作
* Register Devices
```
Usage:

    $ bundle exec fastlane ios add_devices --env <env-file>

      register devices   
```

* Create a new app
```
Usage:

    $ bundle exec fastlane ios create_app --env <env-file>

      Create an app on Apple Developer and App Connect   
```

* Create one or more new app extensions
```
Usage:

    $ bundle exec fastlane ios create_app_extensions --env <env-file>

      Create one or more app extension on Apple Developer 
```

* Create a new app and its extensions
```
Usage:

    $ bundle exec fastlane ios create_app_and_extensions --env <env-file>

      Create an app and extension on Apple Developer and App Connect
```

2.  Match
* match 对应证书
```
Usage:

    $ bundle exec fastlane ios match_lane --env <env-file>

      match apple certifications

Parameters:
    + type           development
                     adhoc
                     appstore
                     enterprise
                     
    + readonly       默认为false
                     false 不重写对应的profiles
                     true  会重写对应的profiles
                     
    + force_for_new_devices  默认为false
                     false 不强制更新注册的devices到profiles中
                     true  会强制更新注册的devices到profiles中     
```


* match development 证书
```
Usage:

    $ bundle exec fastlane ios match_development --env <env-file>

      match apple development certifications

Parameters:

    + readonly       默认为false
                     false 不重写对应的profiles
                     true  会重写对应的profiles
```

* match adhoc 证书
```
Usage:

    $ bundle exec fastlane ios match_adhoc --env <env-file>

      match apple ad-hoc certifications

Parameters:

    + readonly       默认为false
                     false 不重写对应的profiles
                     true  会重写对应的profiles
```

* match app-store 证书
```
Usage:

    $ bundle exec fastlane ios match_appstore --env <env-file>

      match apple app-store certifications

Parameters:

    + readonly       默认为false
                     false 不重写对应的profiles
                     true  会重写对应的profiles
```
* match enterprise 证书
```
Usage:

    $ bundle exec fastlane ios match_enterprise --env <env-file>

      match apple enterprise certifications

Parameters:

    + readonly       默认为false
                     false 不重写对应的profiles
                     true  会重写对应的profiles
```
* match 所有证书
```
Usage:

    $ bundle exec fastlane ios match_all --env <env-file>

      match apple all certifications
```
3.  xxxx
4.  xxxx
5.  发布App
> 发布App之前，请先进行`pod install`
```
bundle exec pod update --no-repo-update --verbose
```
> Fastools目前可提供在`AppCenter`, `Fir`, `Pgyer`, `Testflight`4个不同的平台发布App，如下
* 在`App Center`上发布
```
Usage:
    $ bundle exec fastlane ios appcenter_lane --env <env-file>

      Build and push a new build to Appcenter

Parameters:

    + configuration       Staging        编译选项为`Staging`
                          Preproduction  编译选项为`Preproduction`
                          Release        编译选项为`Release`
    + export_method       enterprise
                          ad-hoc
```

* 在`Fir`上发布
```
Usage:
    $ bundle exec fastlane ios fir_lane --env <env-file>

      Build and push a new build to Fir

Parameters:

    + configuration       Staging        编译选项为`Staging`
                          Preproduction  编译选项为`Preproduction`
                          Release        编译选项为`Release`
    + export_method       enterprise
                          ad-hoc
```

* 在`Pgyer`上发布
```
Usage:
    $ bundle exec fastlane ios pgyer_lane --env <env-file>

      Build and push a new build to Pgyer

Parameters:

    + configuration       Staging        编译选项为`Staging`
                          Preproduction  编译选项为`Preproduction`
                          Release        编译选项为`Release`
    + export_method       enterprise
                          ad-hoc
```

* 在`Testflight`上发布
```
Usage:
    $ bundle exec fastlane ios beta --env <env-file>

      Build and push a new build to TestFlight

Parameters:

    + configuration       Staging        编译选项为`Staging`
                          Preproduction  编译选项为`Preproduction`
                          Release        编译选项为`Release`
    + skip_waiting        默认为false
                          true           等待完成处理
                          false          不等待完成处理
```

#### 参与贡献

1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request