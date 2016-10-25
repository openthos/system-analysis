## detail process
```
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
```
