#!/bin/bash

dirname_path=$(cd `dirname $0`; pwd)
usr_psw="user:password"
#git config --global credential.helper cache
android_x86="/opt/git/lollipop-x86"

#####

new_repo="kernel bootable/newinstaller device/generic/common packages/apps/Settings packages/apps/Mms" #manifest.xml $path

#####

cd $android_x86
#ls -d *.git
#new_repo="BasicSmsReceiver.git Bluetooth.git Browser.git Calculator.git Calendar.git Camera2.git Camera.git CellBroadcastReceiver.git CertInstaller.git CMFileManager.git ContactsCommon.git Contacts.git DeskClock.git Dialer.git Email.git Exchange.git FMRadio.git Gallery2.git Gallery.git HTMLViewer.git InCallUI.git KeyChain.git Launcher2.git Launcher3.git LegacyCamera.git ManagedProvisioning.git Mms.git MusicFX.git Music.git OneTimeInitializer.git PackageInstaller.git PhoneCommon.git Phone.git Protips.git Provision.git QuickSearchBox.git SoundRecorder.git SpareParts.git SpeechRecorder.git Stk.git Terminal.git TSCalibration2.git TvSettings.git UnifiedEmail.git VoiceDialer.git"

for repo_ in $new_repo
do
repo_git="${repo_}.git"

pre_repo=$( echo $repo_ | cut -c 1-6 )
if [ "$pre_repo"x = "kernel"x ]; then
pre_path=""
repo_git="kernel/common.git"

elif [ "$pre_repo"x = "device"x ]; then
pre_path=""
else
pre_path="platform"
fi

cd $android_x86/$pre_path/$repo_git
if [ $? -ne 0 ]; then
echo -e "\033[31mCD to $repo_ ERROR!\033[0m"
continue
fi

repo_name="openthos_$(echo $repo_ |sed "s/\//_/g")"
echo -e "\033[32m$repo_name\033[0m"

pwd
continue

##### create github repos
sleep 2
curl -u $usr_psw -d "{\"name\":\"$repo_name\"}" https://api.github.com/orgs/openthos/repos | grep "github.com/openthos/$repo_name" > /dev/null 2>&1

if [ $? -ne 0 ]; then
echo -e "\033[31mCreate $repo_name ERROR!\033[0m"
continue
fi
#####

sudo git remote add github  https://github.com/openthos/$repo_name

git log -1 lollipop-x86 > /dev/null 2>&1
if [ $? -ne 0 ]; then
echo -e "\033[1maosp:refs/tags/android-5.1.1_r30\033[0m"
sudo git push -u github refs/tags/android-5.1.1_r30:lollipop-x86

else
echo -e "\033[1mx86:lollipop-x86\033[0m"
sudo git push -u github lollipop-x86:lollipop-x86
fi

sudo git push -u github multiwindow
if [ $? -ne 0 ]; then
echo -e "\033[31mPush $repo_name ERROR!\033[0m"
fi

sudo git push -u github singlewindow

#sudo git remote add github  https://github.com/openthos/openthos_frameworks_native.git
#sudo git push -u github lollipop-x86 multiwindow singlewindow  

done

