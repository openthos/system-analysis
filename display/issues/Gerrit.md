# 为Openthos配置Gerrit服务
## Background
现在openthos有两个仓库:  
第一个是在oslab内部使用的仓库镜像,主要是为了方便实验室内部开发同步代码  
第二是放在了github上<https://github.com/openthos/openthos/wiki/Download_Build_Run_OTO>,主要是为了openthos爱好者和不在实验室内部的开发;  
现在两个仓库都可以提交代码,而且需要及时同步;但总会出现conflict的情况,需要开发来手动解决conflict;  
所以,我打算更改mirror的架构:  
在dev.openthos.org上架设gerrit服务,所有开发的代码全都是提交到这里;  
然后周期性同步到实验室内部和github;  

## 配置gerrit
### 1.下载gerrit的jar包
link <http://download.csdn.net/download/stwstw0123/9044005>
### 2.提前安装一些工具:mysql,apache2-utils,nginx
gerrit将用户信息保存到数据库中,所以需要选择一个数据库,这里暂且使用mysql;
并且需要提前新建数据库  
```
sudo apt-get install mysql-server
mysql -u root -p
>create database reviewdb;
>set global explicit_defaults_for_timestamp=1;   fix issue[http://www.jianshu.com/p/154960f71d11]
```
添加用户名和密码时需要使用如下的操作:
```
htpasswd /home/gerrit/gerrit/etc/htpasswd.conf admin
```
### 3.安装gerrit:
具体的选项可以看一下网上的,可以参考一下这个<http://blog.csdn.net/stwstw0123/article/details/47259425>;  
最后生成的配置文件请看:
```
linux@linux-T:~/mount$ java -jar ../Downloads/gerrit-2.11.3.war  init -d ./review-site

cat ./review-site/etc/gerrit.config
Configure file:
[gerrit]
        basePath = git
        canonicalWebUrl = http://localhost:8081
[database]
        type = mysql
        hostname = localhost
        database = reviewdb
        username = root
[index]
        type = LUCENE
[auth]
        type = HTTP
[sendemail]
        enable = true
        smtpServer = smtp.163.com
        smtpServerPort = 25
        smtpEncryption =
        smtpUser = wangjianxing5210@163.com
        smtpPass = xxxx
        from = wangjianxing5210@163.com
[container]
        user = linux
        javaHome = /usr/lib/jvm/java-8-openjdk-amd64/jre
[sshd]
        listenAddress = *:29418
[httpd]
        listenUrl = proxy-http://*:8081
[cache]
        directory = cache
[gitweb]
        cgi = /usr/lib/cgi-bin/gitweb.cgi
```
### 4.配置nginx的反向代理
```
sudo vim /etc/nginx/sites-available/mydefault.vhost
server {
  listen *:80;
  server_name localhost;
  allow   all;
  deny    all;
  auth_basic "ZJC INC. Review System Login";
  auth_basic_user_file /home/linux/mount/review-site/etc/htpasswd.conf;

  location / {
    proxy_pass  http://localhost:8081;
  }
}
```
重新启动nginx和gerrit服务应该都会好用了
```
review-site/bin/gerrit.sh start
service nginx restart
```
http://localhost
# Gerrit管理repo
## 1.添加仓库到gerrit中
从上面的配置就可以看出,路径是git,即review-site/git/目录下,所有理论上我们就只需要将库拷贝到
review-site/git/
这里我们可以重新init和sync
```
repo init -u git://xxxx -b branch --mirror  必须要是使用mirror方式
repo sync
```
重启gerrit我们就可以登陆gerrit看到  
*Projects->List*
## 2.配置仓库的manifest
原来我们没有使用gerrit服务,所以现在需要指定提交的地址,如下所示:
```
   <remote  name="aosp"
-           fetch="git://192.168.0.185/lollipop-x86/" />
+           fetch="git://192.168.0.185/lollipop-x86/"
+          review="http://localhost" />
   <remote  name="x86"
-           fetch="." />
+           fetch="."
+          review="http://localhost" />
```
## 开发需要的配置
### 1.配置~/.gitconfig
```
[review "http://localhost"]
    username = MYNAME
```
### 2.新的上传操作
拷贝~/.ssh/id_rsa.pub到gerrit上  
1.repo start(if you still use `git checkout -b branchname`,you will see 'no branches ready for upload' when `repo upload .`)  
2.git add;git commit  
3.repo upload .  
# 遇到的错误
## 1.反向代理的认证问题
![image](./images/gerrit-error.png)
nginx/apache2的反向代理配置有问题,重新配置反向代理
```
/etc/nginx/sites-available/mydefault.vhost
server {
  listen *:80;
  server_name localhost;
  allow   all;
  deny    all;
  auth_basic "ZJC INC. Review System Login";
  auth_basic_user_file /home/linux/mount/review-site/etc/htpasswd.conf;  (htpasswd /home/gerrit/gerrit/etc/htpasswd.conf admin)

  location / {
    proxy_pass  http://localhost:8081;
  }
}
```
review-site/etc/gerrit.config
```
[gerrit]
        basePath = git
        canonicalWebUrl = http://localhost:8081
[sshd]
        listenAddress = *:29418
[httpd]
        listenUrl = proxy-http://*:8081
[cache]
        directory = cache
[gitweb]
        cgi = /usr/lib/cgi-bin/gitweb.cgi
```
You Can access http://localhost,and jump to http://localhost:8081
## repo upload 失败
```
linux@linux-T:~/mount/mul/build$ repo upload .
Upload project build/ to remote branch refs/heads/multiwindow:
  branch 123 ( 1 commit, Wed Feb 8 19:26:03 2017 +0800):
         dfc4275f test
to http://localhost (y/N)? y
Unauthorized
User: linux     
Password:
Unable to negotiate with 127.0.0.1 port 29418: no matching key exchange method found. Their offer: diffie-hellman-group1-sha1
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.

----------------------------------------------------------------------
[FAILED] build/          123             (Upload failed)
```
### 1.ask you to input 'user' and 'password'
需要你输入用户名和密码(没有解决呢)
### 2.upload failed
```
Unable to negotiate with 127.0.0.1 port 29418: no matching key exchange method found. Their offer: diffie-hellman-group1-sha1
fatal: Could not read from remote repository.
vi ~/.ssh/config
Host localhost(这是服务器地址)
    KexAlgorithms +diffie-hellman-group1-sha1
```
错误提示改变为:
```
linux@linux-T:~/mount/mul/build$ repo upload .
Upload project build/ to remote branch refs/heads/multiwindow:
  branch 123 ( 1 commit, Wed Feb 8 19:26:03 2017 +0800):
         dfc4275f test
to http://localhost (y/N)? y
Unauthorized
User: linux
Password:
sign_and_send_pubkey: signing failed: agent refused operation
Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.

----------------------------------------------------------------------
[FAILED] build/          123             (Upload failed)

linux@linux-T:~/mount/mul/build$ eval "$(ssh-agent -s)"
Agent pid 2433
linux@linux-T:~/mount/mul/build$ ssh-add
Identity added: /home/linux/.ssh/id_rsa (/home/linux/.ssh/id_rsa)
```
然后就修复好了
```
linux@linux-T:~/mount/mul/build$ cat ~/.gitconfig
[user]
	email = wangjianxing5210@163.com
	name = linux
[color]
	ui = auto
[review "http://localhost"]
	username = linux
```
