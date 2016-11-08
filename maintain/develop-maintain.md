# 系统维护功能需求与设计实现文档
内容：

- 项目简介
- 功能需求
- 存在问题
- 项目进展
- 设计实现

## 项目简介
oto的系统开发与维护支持。

###　当前开发人员 (20160801-20161130)
陈渝 王建兴 韩辉

## 功能需求
1 提供基于docker开发环境
2 提供基于git的版本管理环境
3 定期维护，备份开发环境

## 存在问题

| 简述 | 类别 | 备注
|---|---|---|



## 项目进展
序号|名称 | 备注|时间阶段|说明
------------- | ------------- | ------------- |-------------| -------------
1| oto开发环境搭建| passed|201510-201511|本机完成，陈渝
2| oto开发环境搭建| passed|201512-201607|24服务器支持，肖络元
3| git/repo 管理| passed|201603-201607|本地和github，肖络元
4| git/repo 备份/整理| doing |201608-~|陈渝

## 设计实现
实时维护，定期升级


## 常见问题和解决方法

### 发现git pull or git clone 很慢
把ipv6给关闭了
比如
```
ifconfig eth0 del 33ffe:3240:800:1005::2/64

cat /proc/sys/net/ipv6/conf/all/disable_ipv6
显示0说明ipv6开启，1说明关闭

root@box.com:~# sysctl net.ipv6.conf.all.disable_ipv6
net.ipv6.conf.all.disable_ipv6 = 1
root@box.com:~# sysctl net.ipv6.conf.default.disable_ipv6
net.ipv6.conf.default.disable_ipv6 = 1
root@box.com:~# sysctl net.ipv6.conf.lo.disable_ipv6
net.ipv6.conf.lo.disable_ipv6 = 1
```
