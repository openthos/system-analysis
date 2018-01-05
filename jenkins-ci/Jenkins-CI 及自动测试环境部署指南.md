# Jenkins-CI 及自动测试环境部署指南
本文主要介绍如何使用docker搭建jenkins-master服务器，使用docker或物理计算机搭建用于build,validate的jenkins-slave节点，通过合理的架构设计，以实现多台jenkins-slave同jenkins-master协作，实现build,validate任务的自动分配，以提高团队工作效率。
## 安装Docker
为便于开发环境的迁移，jenkins-master服务器将部署在docker容器内。
以下安装过程在Ubuntu 16.04.3下经过确认。
1. 确保旧版本docker已经移除
```
sudo apt-get remove docker docker-engine docker.io
```
2. 添加docker官方GPG密钥
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
3. 添加docker的apt仓库
```
sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable"
```
4. 使用apt安装docker-ce
```
sudo apt-get update
```
```
sudo apt-get install docker-ce
```
## 在docker内部署jenkins-master
虽然jenkins官方提供了docker镜像，但是基于ubuntu 16.04定制的docker镜像更利于使用apt快速的增加编译的工具链。
创建工作目录，在目录内创建Dockerfile文件，内容如下：
```
FROM ubuntu:16.04

MAINTAINER Shanmin Zhang <zhangshanmin@mail.tsinghua.edu.cn>

RUN sed -i 's#http://archive.ubuntu.com/ubuntu/#http://mirrors.tuna.tsinghua.edu.cn/ubuntu/#g;s#http://security.ubuntu.com/ubuntu/#http://mirrors.tuna.tsinghua.edu.cn/ubuntu/#g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y wget \
    && wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add - \
    && sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' \
    && apt-get update \
    && apt-get install -y \
    bc \
    bison \
    build-essential \
    ccache \
    cpio \
    curl \
    flex \
    gcc-multilib \
    genisoimage \
    gettext \
    git-core \
    g++-multilib \
    gnupg \
    gperf \
    jenkins \
    lib32ncurses5-dev \
    lib32z-dev \
    libc6-dev-i386 \
    libelf-dev \
    libgl1-mesa-dev \
    libssl-dev \
    libx11-dev \
    libxml2-utils \
    openjdk-8-jdk \
    python-mako \
    unzip \
    x11proto-core-dev \
    xsltproc \
    zip \
    zlib1g-dev \
    && apt-get clean

CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]
EXPOSE 8080 50000
```
使用jenkins build创建docker镜像
```
docker build -t jenkins-master .
```
运行docker
```
docker run -u root -d -p 8080:8080 -p 50000:50000 -v jenkins-data:/root/.jenkins -v /var/run/docker.sock:/var/run/docker.sock jenkins-master
```
命令解释：
1. -u root 以root用户运行
2. -d 以daemon方式运行
3. -p 8080:8080 -p 50000:50000 容器与host端口映射，8080用于jenkins web界面，50000用于预留master-slave通信。
4. -v jenkins-data:/root/.jenkins apt仓库版本的jenkins可能不同于jenkins网站直接下载的deb版本jenkins，当前版本的JENKINS_HOME定义为/root/.jenkins，docker容器在关闭后将丢弃全部数据，为了保存容器内jenkins数据，创建一个docker volume，并映射至docker容器，docker容器关闭后，数据将在宿主机/var/lib/docker/volumes/jenkins-data目录下长期保存。
### jenkins-ci初始化后的首次配置
1. 浏览器打开127.0.0.1:8080，获取initialAdminPassword，填入页面。
查看容器ID
```
docker ps | grep jenkins-master | awk '{print $1}'
```
```
docker exec  CONTAINER_ID cat /root/.jenkins/secrets/initialAdminPassword
```
2. 添加jenkins插件
```
SSH Agent Plugin
REPO plugin
Publish Over SSH
SSH plugin
```
3. 创建管理员账户
4. 完成首次配置
## 在docker内部署jenkins-slave
1.jenkins-master与jenkins-slave通过ssh协议进行通讯，jenkins-slave需要内置openssh-server并设置22端口的映射。ssh通过rsa publickey进行认证，需要创建key：
```
ssh-keygen -t rsa
```
创建Dockerfile文件：
```
ssh-keygen -t rsa

Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:NJtfdwHATjO98fwiOxk0e/UWq5hHIG+BpKqUmzf6ln0 root@oto-H170-PRO
The key's randomart image is:
+---[RSA 2048]----+
|          ..o.   |
|         . = o.  |
|        = + o =. |
|       o * +o. +o|
|    . . S o.+o..*|
|   o .   . ++ooo+|
|  . + o   o +*.o |
|   + = . E o+o   |
|   .=.. .   ..   |
+----[SHA256]-----+
```
重命名id_rsa.pub为authorized_keys，因为需要内置于docker镜像，所以要将authorized_keys文件复制到docker build的工作目录。
```
mv .ssh/id_rsa.pub authorized_keys
```
在docker build的工作目录中创建Dockerfile
```
FROM ubuntu:16.04

MAINTAINER Shanmin Zhang <zhangshanmin@mail.tsinghua.edu.cn>

RUN sed -i 's#http://archive.ubuntu.com/ubuntu/#http://mirrors.tuna.tsinghua.edu.cn/ubuntu/#g;s#http://security.ubuntu.com/ubuntu/#http://mirrors.tuna.tsinghua.edu.cn/ubuntu/#g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y cpio genisoimage gettext openjdk-8-jdk bc libssl-dev openssh-server git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip python-mako libelf-dev \
    && apt-get clean

RUN mkdir -p /var/run/sshd

COPY ["authorized_keys","/root/.ssh/authorized_keys"]

CMD ["/usr/sbin/sshd", "-D"]

ENV USER root

EXPOSE 22
```
运行docker build，生成jenkins-slave镜像
```
docker build -t jenkins-slave .
```
运行docker
```
sudo docker run -u root -d -p 2222:22 -v jenkins-slave-data:/root/jenkins -v /var/run/docker.sock:/var/run/docker.sock jenkins-slave
```
命令解释：
1. -u root 以root用户运行
2. -d 以daemon方式运行
3. -p 2222:22 容器与host端口映射，22用于与jenkins-master通信。
4. -v jenkins-slave-data:/root/jenkins docker容器在关闭后将丢弃全部数据，为了保存容器内jenkins-slave数据，创建一个docker volume，并映射至docker容器，docker容器关闭后，数据将在宿主机/var/lib/docker/volumes/jenkins-slave-data目录下长期保存。
## 在物理计算机内部署jenkins-slave
部分依赖具体计算机物理部件的build,validate任务需要以物理计算机作为jenkins-slave。
1. 新建jenkins用户，并指定/home/jenkins作为用户目录。
```
sudo useradd jenkins -m
```
2. 安装用于ssh访问的publickey
```
sudo -u jenkins mv id_rsa.pub /home/jenkins/.ssh/authorized_keys
```
## 在jenkins-master中添加jenkins-slave
打开jenkins web页面。配置页面路径：系统管理 | 管理节点 | 新建节点。输入节点名称，并选中“固定代理”。
类似方法分别新建3个项目
```
slave-build-01 # 用于编译的jenkins-slave
slave-validate-kafl-01 #　用于kAFL测试的jenkins-slave
slave-validate-qemu-01 # 用于qemu测试的jenkins-slave
```
进入jenkins工作目录（docker位于/var/lib/docker/volumes/jenkins-data/_data）
修改nodes/slave-build-01/config.xml
```
<?xml version='1.0' encoding='UTF-8'?>
<slave>
  <name>slave-build-01</name>
  <description></description>
  <remoteFS>/root/jenkins</remoteFS>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.24">
    <host>192.168.0.87</host>
    <port>2222</port>
    <credentialsId>92382c61-6627-45c6-82db-cc71b0292f35</credentialsId>
    <javaPath>/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java</javaPath>
    <maxNumRetries>0</maxNumRetries>
    <retryWaitTime>0</retryWaitTime>
    <sshHostKeyVerificationStrategy class="hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy"/>
  </launcher>
  <label>linux amd64</label>
  <nodeProperties/>
</slave>
```
修改nodes/slave-validate-qemu-01/config.xml
```
<?xml version='1.0' encoding='UTF-8'?>
<slave>
  <name>slave-validate-qemu-01</name>
  <description></description>
  <remoteFS>/home/jenkins/</remoteFS>
  <numExecutors>1</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.24">
    <host>192.168.0.87</host>
    <port>22</port>
    <credentialsId>a188cc44-2402-471e-8b2c-899a0b7a194a</credentialsId>
    <javaPath>/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java</javaPath>
    <maxNumRetries>0</maxNumRetries>
    <retryWaitTime>0</retryWaitTime>
    <sshHostKeyVerificationStrategy class="hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy"/>
  </launcher>
  <label>validate qemu</label>
  <nodeProperties/>
</slave>
```
修改nodes/slave-validate-kafl-01/config.xml
```
<?xml version='1.0' encoding='UTF-8'?>
<slave>
  <name>slave-validate-kafl-01</name>
  <description></description>
  <remoteFS>/home/oto/jenkins/</remoteFS>
  <numExecutors>1</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.24">
    <host>192.168.0.77</host>
    <port>22</port>
    <credentialsId>a7fb5418-c04b-4692-92a8-c2b62442bdb2</credentialsId>
    <javaPath>/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java</javaPath>
    <maxNumRetries>0</maxNumRetries>
    <retryWaitTime>0</retryWaitTime>
    <sshHostKeyVerificationStrategy class="hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy"/>
  </launcher>
  <label>validate kafl</label>
  <nodeProperties/>
</slave>
```
根据实际配置，修改host、port属性。

### 新建build项目
1.   在jenkins web页面中选择“新建”，输入一个任务名称，类型选择为“构建一个自由风格的软件项目”。依次新建3个项目
```
linux-stable # 编译linux kernel的项目
validate-kernel-kafl # 使用kAFL进行测试的项目
validate-kernel-qemu # 使用qemu进行测试的项目
```
2. 依次修改项目配置文件
```
jobs/linux-stable/config.xml
jobs/validate-kernel-qemu/config.xml
jobs/validate-kernel-kafl/config.xml
```
```
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.plugins.git.GitSCM" plugin="git@3.7.0">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>git://192.168.0.87/pub/scm/linux/kernel/git/stable/linux-stable.git</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/master</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <submoduleCfg class="list"/>
    <extensions>
      <hudson.plugins.git.extensions.impl.CloneOption>
        <shallow>true</shallow>
        <noTags>false</noTags>
        <reference></reference>
        <depth>1</depth>
        <honorRefspec>false</honorRefspec>
      </hudson.plugins.git.extensions.impl.CloneOption>
    </extensions>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>make x86_64_defconfig &amp;&amp; make
test -e initrd-root || git clone git://192.168.0.87/initrd-root.git --depth=1
rm -rf initrd-root/lib/modules/
make INSTALL_MOD_PATH=initrd-root modules_install
cd initrd-root &amp;&amp; find . | grep -v .git | cpio -o -H newc | gzip &gt; ../initrd.gz
echo &apos;JOB_URL&apos;=$JOB_URL
</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers>
    <hudson.tasks.BuildTrigger>
      <childProjects>validate-kernel-qemu</childProjects>
      <threshold>
        <name>SUCCESS</name>
        <ordinal>0</ordinal>
        <color>BLUE</color>
        <completeBuild>true</completeBuild>
      </threshold>
    </hudson.tasks.BuildTrigger>
  </publishers>
  <buildWrappers/>
</project>
```
```
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <assignedNode>validate &amp;&amp; qemu</assignedNode>
  <canRoam>false</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>curl --user &apos;admin:66693470309e6a94e73106d47ab56661&apos; $JENKINS_URL/job/linux-stable/ws/arch/x86_64/boot/bzImage &gt; bzImage
curl --user &apos;admin:66693470309e6a94e73106d47ab56661&apos; $JENKINS_URL/job/linux-stable/ws/initrd.gz &gt; initrd.gz
qemu-system-x86_64 \
-kernel bzImage \
-initrd initrd.gz \
-m 512 \
-nographic \
-append &quot;console=ttyS0&quot;</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
```
```
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <assignedNode>validate&amp;&amp;kafl</assignedNode>
  <canRoam>false</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>/home/oto/jenkins/run_kAFL.sh vmlinuz-4.8.0-58 5218ea</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
```
配置完成后，重启docker容器。全部配置完成。在jenkins中添加相应的ssh凭证后，Jenkins-CI 及自动测试环境可正常运行。
