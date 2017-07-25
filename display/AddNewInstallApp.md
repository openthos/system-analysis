# How to Add a new install app
**If you have app source,please upload it other than upload `apk` file.**
## 1.Get the apk's package name
First you need to get package name,you can choose both methods.
### 1.1 Get it after Installtion
For Example:
```
adb connect $IP
adb install test.apk
```
then you can get its pakcage name under `/data/app/`,the Directory is pakcage name.

**Sometimes Android change `org.openthos.test` to `org.openthos.test-1`,please ignore its `-number`.**

### 1.2 Get it via apktool
Install apktool

Reference:https://ibotpeaches.github.io/Apktool/install/
```
apktool d test.apk
```
You will find `AndroidManifest.xml` in `test` directory,then find head line like `package="org.openthos.test"`,that's it.
## 2.Put apk into package name directory
Then you just need to `mkdir org.openthos.test` and `mv test.apk org.openthos.test/org.openthos.test.apk`

Later maybe you need not follow the rule,just put apk here.
