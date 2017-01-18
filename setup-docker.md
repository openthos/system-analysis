
## setup ubuntu 17.04
```
apt-get install docker.io
service docker stop
edit your /etc/default/docker file with the -g option: DOCKER_OPTS="-dns 8.8.8.8 -dns 8.8.4.4 -g /chydata/thedatqa/dockers"
service docker start
servicd docker status
```
## pull image

https://github.com/kylemanna/docker-aosp

```
docker search aosp
docker pull kylemanna/docker-aosp #Minimal Android AOSP build environment with handy automation wrapper scripts

```
