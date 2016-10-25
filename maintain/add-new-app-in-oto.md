# add new app git repo in oto
## detail process
```
# server
// add bare git repo in oto git repos
cd /opt/git/lollipop-x86/platform/packages/apps/
sudo git init --bare OtoFileManager.git
sudo chown -R gitdaemon.nogroup OtoFileManager.git/

//update manifest
cd manifest/
git status //in multiwin branch
vim default.xml  //add a item for new apps
git commit -am"add OtoFileMnanger app"
git pull
git push

#client 
// go to TOP dir of OTO
repo init -u git://192.168.0.185/lollipop-x86/manifest -b multiwindow
repo sync
```
