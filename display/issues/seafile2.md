调查seafile的数据库:

root@dev:/opt/seafile# sqlite3 ccnet/PeerMgr/usermgr.db 
sqlite> .table
Binding    EmailUser  LDAPUsers  UserRole 
sqlite> select * from EmailUser


1.使用apache2作为服务器的框架
2.

FastCGIExternalServer /var/www/seahub.fcgi -host 127.0.0.1:8000
FastCGIExternalServer 告诉Apache如何找到FastCGI服务器。 
按照FastCGIExternalServer 文档（ http://www.djangoproject.com/r/mod_fastcgi/FastCGIExternalServer/ ），你可以指明 socket 或者 host 。以下是两个例子：
	
# Connect to FastCGI via a socket/named pipe:
FastCGIExternalServer /home/user/public_html/mysite.fcgi -socket /home/user/mysite.sock
 
# Connect to FastCGI via a TCP host/port:
FastCGIExternalServer /home/user/public_html/mysite.fcgi -host 127.0.0.1:3033

在这两个例子中， /home/user/public_html/ 目录必须存在，而 /home/user/public_html/mysite.fcgi 文件不一定存在。 它仅仅是一个Web服务器内部使用的接口，这个URL决定了对于哪些URL的请求会被FastCGI处理（下一部分详细讨论）。


user:root password:openthos
user:seafile password:openthos

What is the email for the admin account?
[ admin email ] seafile@openthos.org

What is the password for the admin account?
[ admin password ] openthos

Enter the password again:
[ admin password again ] openthos


添加:
/etc/apache2/sites-available/000-default-le-ssl.conf
SSLEngine       On

drupal中访问数据的配置:
/var/www/sites/default/settings.php

访问
https://dev.openthos.org
/opt/seafile/seafile-server-latest/seahub/seahub/templates/registration/login.html
