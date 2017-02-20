# System Group目前的工作范围和当前遗留任务
## 对openthos其他开发的支持
filemanager:压缩，解压缩，云服务  
测试组：安装，升级，启动和其他未明确分类的问题  
第一次启动:第一次注册服务
appStore服务
### 潜在问题
server端对多个账号的统一响应  
seafile运行长时间会stop
## 开发环境维护
180,185,github开发环境维护  
代码升级维护  
### 潜在问题：
现在提交的源从185变成了两个:185服务器和github，同步可能会频繁出现冲突；  
最好能够提交到一个server，其他mirror从一个server同步　　
## 系统性问题第一次分析
### 稳定性:
PC的突然重启(刘明明的T45睡眠唤醒后重启问题)  
我们需要一种手段来支持取core dump以此来应对系统软件重启问题
### 性能:

## 系统组技能提高
### Android Debug
logcat使用[总结]  
dumpsys使用[总结]  
### 其他技能提升
kernel的掌握  
Android HAL层　
