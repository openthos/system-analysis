# 本流程目的
目前我们的repo系统中，尚不支持pull requests这样的团队协作功能，对已有代码的任意修改提交，
有可能造成仓库中代码污染，导致某些系统功能能的失效，严重者导致无法编译整个系统。  

特此，针对dm-verity相关的代码提交制定本流程。  

# 补丁流程  
1. 相关开发人员创建本地的测试分支，在本地分支上进行相关测试
2. 本人测试通过后，使用git diff 功能生成patch档
3. 发送邮件到给测试组zhanglinping@openthos.org，系统组chenwei01@thtfpc.com，并抄送bigandroid@googlegroups.com
4. 测试组收到邮件后，在本地仓库是创建一个临时分支，打上patch后进行复验。 系统组收邮件后，根据patch所在模块将邮件转发到相关组进行代码人工审核。
5. 审核通过后，审核人员回复邮件，开发人员进行代码的push推送。 如审核未通过，亦回复邮件说明原因。
6. 补丁成功提交后，发邮件到bigandroid@googlegroups.com

# 补丁规范

**编码风格 ：** 沿用各个补丁所在模块的编码风格，对于同当前环境下的编码风格不抵触的地方，可沿用自己的偏好和习惯。  
**补丁说明 ：** 沿用英文的格式风格，例如:标题部分要有补丁所在位置的说明，用": "进行间隔，开始字母大写，标题尽量没有标点，
两个段落间有单独的空行，每段起始部分从第一列开始，每个标点后面有一个空格等。  
**邮件告知 ：** 提交成功的补丁需要发送邮件给bigandroid@googlegroups.com，需要用git来从命令行发送，
由此保证其格式为纯文本。对于如何发送请参见下文。  

# 提交补丁说明
**相关分支 ：** 必须有multiwindow分支，是远程对应的x86/multiwindow，可通过git branch -a查看，
git checkout -b multiwindow x86/multiwindow来创建此分支到本地。  
**创建devorg：** 先用git remote -v查看，默认有x86，在其路径后面加".git"作为新路径创建，
例如frameworks/base是git://192.168.0.185/lollipop-x86/platform/frameworks/base  
**创建命令：**git remote add devorg git://192.168.0.185/lollipop-x86/platform/frameworks/base.git $@  
**提交命令：** git push devorg multiwindow:refs/heads/multiwindow，有时候可能需要先同步远程，然后再打补丁提交。
相关的同步命令是git pull devorg multiwindow:refs/heads/multiwindow

# 发送邮件（以Ubuntu系统为开发系统为例）
**环境配置 ：** 在OPENTHOS中安装Ubuntu，在chroot Ubuntu中，apt-get install git git-mail.  
**邮箱配置 ：** 编辑/root/.gitconfig，增加[sendmail]根栏目，不同的邮件服务器配置稍有不同，
例如，from = chengang@emindsoft.com.cn, envelopesender = chengang@emindsoft.com.cn, 
smtpencryption = None, smtpserver = smtp.emindsoft.com.cn, smtpuser =chengang@emindsoft.com.cnsmtpserverport = 587 ，
每项占一行，并用一个tab进行缩进。  
**发送邮件 ：** 下载补丁到当前目录，假设补丁文件名是000开头，发送命令是:git send-email --smtp-debug --no-validate --To 
bigandroid@googlegroups.com 000*，然后按照提示进行相关的输入即可，例如期间需要确认，需要输入密码等。  
也可以客户端来发送邮件，但需要注意，以纯文本的形式发出。  
