# seafile环境搭建
源码及文档:  
下载地址:https://github.com/haiwen  
安装server文档:https://manual.seafile.com/
## 安装过程
一键安装脚本,只适合空白机器上安装,对于dev.openthos.org不能使用这种方式安装,请按照手册逐步安装;
https://github.com/haiwen/seafile-server-installer
```
chmod +x seafile-server-installer/seafile_ubuntu
sudo ./seafile_ubuntu 6.0.1
```
### 我的修改:  
1.手动安装这些依赖工具,不然每次都报错  
2.手动执行,因为脚本不知道数据库的密码  
setup-seafile-mysql.sh -u seafile -w $(pwgen)
```
diff --git a/seafile_ubuntu b/seafile_ubuntu
-apt-get update
+#apt-get update
 apt-get install -y python2.7 sudo python-pip python-setuptools python-imaging python-mysqldb python-ldap python-urllib3 \
 openjdk-8-jre memcached python-memcache pwgen curl openssl poppler-utils libpython2.7 libreoffice \
 libreoffice-script-provider-python ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy nginx
@@ -390,7 +390,7 @@ mkdir -p ${DEFAULT_CONF_DIR}
 # Create ccnet, seafile, seahub conf using setup script
 # -------------------------------------------

-./setup-seafile-mysql.sh auto -u seafile -w ${SQLSEAFILEPW} -r ${SQLROOTPW}
+#./setup-seafile-mysql.sh auto -u seafile -w ${SQLSEAFILEPW} -r ${SQLROOTPW}

 # -------------------------------------------
 # Configure Seafile WebDAV Server(SeafDAV)
```
### 手动执行setup-seafile-mysql.sh -u seafile -w $(pwgen)中的选项:
```
root@linux-S6:/opt/seafile/seafile-server-6.0.1# python setup-seafile-mysql.py -u seafile -w Ae2xeega -r
-----------------------------------------------------------------
This script will guide you to setup your seafile server using MySQL.
Make sure you have read seafile server manual at

        https://github.com/haiwen/seafile/wiki

Press ENTER to continue
-----------------------------------------------------------------

What is the name of the server? It will be displayed on the client.
3 - 15 letters or digits
[ server name ] seafile

What is the ip or domain of the server?
For example: www.mycompany.com, 192.168.1.101
[ This server's ip or domain ] 192.168.0.125

Where do you want to put your seafile data?
Please use a volume with enough free space
[ default "/opt/seafile/seafile-data" ]

Which port do you want to use for the seafile fileserver?
[ default "8082" ]

-------------------------------------------------------
Please choose a way to initialize seafile databases:
-------------------------------------------------------

[1] Create new ccnet/seafile/seahub databases
[2] Use existing ccnet/seafile/seahub databases

[ 1 or 2 ] 1

What is the host of mysql server?
[ default "localhost" ]

What is the port of mysql server?
[ default "3306" ]

What is the password of the mysql root user?
[ root password ]

verifying password of user root ...  done

Enter the name for mysql user of seafile. It would be created if not exists.
[ default "root" ] seafile

Enter the password for mysql user "seafile":
[ password for seafile ]

Enter the database name for ccnet-server:
[ default "ccnet-db" ]

Enter the database name for seafile-server:
[ default "seafile-db" ]

Enter the database name for seahub:
[ default "seahub-db" ]

---------------------------------
This is your configuration
---------------------------------

    server name:            seafile
    server ip/domain:       192.168.0.125

    seafile data dir:       /opt/seafile/seafile-data
    fileserver port:        8082

    database:               create new
    ccnet database:         ccnet-db
    seafile database:       seafile-db
    seahub database:        seahub-db
    database user:          seafile



---------------------------------
Press ENTER to continue, or Ctrl-C to abort
---------------------------------

Generating ccnet configuration ...

done
Successly create configuration dir /opt/seafile/ccnet.
Generating seafile configuration ...


  Your Seafile server is installed
  -----------------------------------------------------------------

  Server Name:         linux-S6
  Server Address:      http://127.0.1.1

  Seafile Admin:       admin@seafile.local
  Admin Password:      Ruteing9

  Seafile Data Dir:    /opt/seafile/seafile-data

  Seafile DB Credentials:  Check /opt/seafile/.my.cnf
  Root DB Credentials:     Check /root/.my.cnf

  This report is also saved to /opt/seafile/aio_seafile-server.log

  Next you should manually complete the following steps
  -----------------------------------------------------------------

  1) Run seafile-server-change-address to add your Seafile servers DNS name

  2) If this server is behind a firewall, you need to ensure that
     tcp port 80 is open.

  3) Seahub tries to send emails via the local server. Install and
     configure Postfix for this to work.

  Optional steps
  -----------------------------------------------------------------

  1) Check seahub_settings.py and customize it to fit your needs. Consult
     http://manual.seafile.com/config/seahub_settings_py.html for possible switches.

  2) Setup NGINX with official SSL certificate.

  3) Secure server with iptables based firewall. For instance: UFW or shorewall

  4) Harden system with port knocking, fail2ban, etc.

  5) Enable unattended installation of security updates. Check
     https://wiki.Ubuntu.org/UnattendedUpgrades for details.

  6) Implement a backup routine for your Seafile server.

  7) Update NGINX worker processes to reflect the number of CPU cores.
```
### 如何添加数据库密码:
seafile自动安装mariadb(是mysql的开源版本),里面会有mysql数据库,mysql中包含一张user的table
可以使用:
```
sudo mysql -u root mysql
>use mysql;
>show tables;
```
更新密码:  
update user set password="openthos" where host="localhost";
### 手动配置postfix
自查


# dev.openthos.org上环境配置解析:
对外使用了apache2的Web服务器,然后根据/etc/apache2/sites-avaiable/下的conf文件可以看到它现在支持的
web服务:
```
https://dev.openthos.org/zentao 禅道
https://dev.openthos.org seahub
http://dev.openthos.org/ drupal(openthos的注册网站)
https://dev.openthos.org/appstore 暂时无法使用
https://dev.openthos.org/opengrok 暂时无法使用
http://www.openthos.org openthos介绍的网站
https://www.openthos.org openthos介绍的网站
http://bugs.openthos.org bug
http://wiki.openthos.org wiki
```
## drupal中访问数据库的配置文件:
```
/var/www/sites/default/settings.php
```
需要修改用户名和密码;
## 数据库密码相关
```
user:root password:openthos
user:seafile password:openthos
```
## seahub
```
adminname:seafile@openthos.org
password:openthos
登陆seahub:
https://dev.openthos.org
```
# 剩余任务
drupal和seahub共用一个密码
