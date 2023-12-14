#!/bin/bash

#ESPlus Installer script

ESPlusDirectory=/var
esPlusDirectoryPath=/var/ESPlus
xdgFolder=/etc/xdg
desktopDirectoryPath=/etc/xdg/autostart
serviceDirectoryPath=/etc/systemd/system
logFile=$esPlusDirectoryPath/ESPlusDeploymentLog.txt
tarFileName=ESPlus.tar
AppPatchLogFile=/var/ESPlus/AppPatchLog.txt

#zip file contents 
ESPlusScriptFile1=ESPlusSessionSwitchModule.sh
ESPlusScriptFile2=ESPlusHeartBeatModule.sh
ESPlusScriptFile3=ESPlusUpdateApp.sh
ESPlusScriptFile4=ESPlusUpdatePatch.sh
ESPlusScriptFile5=HeartBeatDataUpload.sh
ESPlusScriptFile6=UserDataUpload.sh

ESPlusSessionSwitchModuleReloadScript=ESPlusSessionSwitchModuleReload.sh
ESPlusSessionSwitchModuleReloadInvoker=ESPlusSessionSwitchModuleReloadInvoker.desktop
ESPLusService=ESPlusHeartBeatInvoker.service
ESPlusLogin=ESPlusSessionSwitchInvoker.desktop
ESPLusPatchAppService=ESPlusUpdateAppService.service
ESPLusDataSendService=ESPlusUploadData.service

now=$(date +"%m-%d-%Y %H:%M:%S")

SetUpService()
{
	#Argument 1 is path where service currently is
	#Argument 2 is service name
	

	sudo cp $esPlusDirectoryPath/$1/$2 $serviceDirectoryPath
	if [ "$?" -eq 0 ]
	then
		echo "Successfully copied $2 to $serviceDirectoryPath $now" >> $logFile
	else
		echo "Failed to copy $2 service file to $serviceDirectoryPath exiting script $now" >> $logFile
		exit 1
	fi
	#Enabling service
	sudo systemctl daemon-reload
	if [ "$?" -eq 0 ]
	then
		echo "Daemon realod successfully done $now" >> $logFile
		sudo systemctl enable $2
		if [ "$?" -eq 0 ]
		then
			echo "$2 Service successfully enabled $now" >> $logFile
			sudo systemctl start $2
		else
			echo "Failed  to enable $2 service $now" >> $logFile
		fi
	else
		echo "Failed to reload the daemon" >> $logFile
	fi
}

CopyFilesToDesiredDirectory()
{
	#Argument 1 Path where file is present
	#Argument 2 File name
	#Argument 3 Destination path
	sudo cp $esPlusDirectoryPath/$1/$2 $3
		if [ "$?" -eq 0 ]
		then
			echo "$2 file moved to $3 | $now"  >> $logFile
		else
			echo "Falied to copy $2 file to $3 | $now" >> $logFile
			exit 1
		fi
}

#Updating system
sudo apt-get update -y
sudo apt-get upgrade -y

if ! command -v curl > /dev/null
then
	sudo apt-get install curl -y
fi

if ! command -v xmessage > /dev/null
then
	sudo apt-get install x11-utils -y
fi

#CMD=`exec sudo cat /etc/sudoers | grep "ALL ALL=(ALL) NOPASSWD: /var/ESPlus/ESPlusSessionSwitchModule.sh" | wc -l`
#if [ "$CMD" -eq 0 ]
#then
#	sudo echo "ALL ALL=(ALL) NOPASSWD: /var/ESPlus/ESPlusSessionSwitchModule.sh" >> /etc/sudoers
#fi

#Checking if /var/ESPlus directory exists
#If directory is not present then creating directory
if [ -d "$esPlusDirectoryPath" ]
then
	echo "ESPlus directory exists deleting already existing directory $now" >> ./ESPlusDeployment.txt
	sudo rm -r $esPlusDirectoryPath

fi

#Downloading ESPlus tar file
curl --connect-timeout 5 https://esplus-macunix.cybage.com/ESPlusUnixWebService/Patches/ESPlus.tar --output ESPlus.tar

#Extracting files dowloaded
sudo tar -xf $tarFileName -C $ESPlusDirectory
if [ "$?" -eq 0 ] 
then
	echo "Files extracted successfully $now" >> $logFile
	sudo chmod 777 $esPlusDirectoryPath
	
	sudo mkdir $esPlusDirectoryPath/RecordedLogs
	sudo chmod 777 $esPlusDirectoryPath/RecordedLogs
	
	sudo mkdir $esPlusDirectoryPath/UpdateLogs
	sudo chmod 777 $esPlusDirectoryPath/UpdateLogs
	
	echo "ESPlus directory created $now" >> $logFile
else
	echo "Failed to extract ESPlus files. $now" >> ./ESPlusDeployment.txt
	exit 1
fi	

	
	#Moving script files from App to esPlusDirectoryPath
	CopyFilesToDesiredDirectory App $ESPlusScriptFile1 $esPlusDirectoryPath
	CopyFilesToDesiredDirectory App $ESPlusScriptFile2 $esPlusDirectoryPath
	CopyFilesToDesiredDirectory App $ESPlusScriptFile4 $esPlusDirectoryPath
	CopyFilesToDesiredDirectory App $ESPlusScriptFile5 $esPlusDirectoryPath
	CopyFilesToDesiredDirectory App $ESPlusScriptFile6 $esPlusDirectoryPath
	
	#Copying Patch scripts to ESPlusDirectory
	CopyFilesToDesiredDirectory Patch $ESPlusScriptFile3 $esPlusDirectoryPath
	CopyFilesToDesiredDirectory Patch $ESPlusSessionSwitchModuleReloadScript $esPlusDirectoryPath
	
	#Changing permissions of scripts
	sudo chmod +x $esPlusDirectoryPath/$ESPlusScriptFile1 $esPlusDirectoryPath/$ESPlusScriptFile2 $esPlusDirectoryPath/$ESPlusScriptFile3 $esPlusDirectoryPath/$ESPlusScriptFile4 $esPlusDirectoryPath/$ESPlusSessionSwitchModuleReloadScript $esPlusDirectoryPath/$ESPlusScriptFile5 $esPlusDirectoryPath/$ESPlusScriptFile6
	if [ "$?" -eq 0 ]
	then
		echo "Permissions for scripts changed $now" >> $logFile
	else
		echo "Falied to change permissions of scrits exiting script $now" >> $logFile
		exit 1
	fi
	
	#Setting up ESPLusService
	SetUpService App $ESPLusService
	
	#Setting up ESPLusPatchAppService
	SetUpService Patch $ESPLusPatchAppService
	
	#Setting up ESPlusDataSendService
	SetUpService App ESPlusUploadData.service
	
	#Setting up .desktop files 
	#Checking if xdg directory exists
	if [ -d "$xdgFolder" ]
	then
		echo "$xdgFolder directory exists $now" >> $logFile
		#Copying ESPlusSessionSwitchInvoker.desktop 
		CopyFilesToDesiredDirectory App $ESPlusLogin $desktopDirectoryPath
				
		echo "Rebooting system $now" >> $logFile
		sudo reboot
	else
		echo "$xdgFolder is not directory existing script $now" >> $logFile
		exit 1
	fi

