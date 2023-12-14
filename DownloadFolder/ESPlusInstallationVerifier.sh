#!/bin/bash

ESPlusUnixInstalltionGuideLink="https://esplusapps.cybage.com/esplusworkstatus/installation/ESPlus_Linux_Installation_Guide.pdf";
ESPlusQuries="https://esplusapps.cybage.com/esplusworkstatus/#/home";
ESPlusAdmin="esplusadmin@cybage.com";
bIsESPlusInstalled=0;
bIsESPlusRunning=0;

CheckIfESPlusIsInstalled(){
        if [ -d "/var/ESPlus" ]
	then
		bIsESPlusInstalled=1;
	fi
}

CheckIfESPlusIsRunningCorectly(){
        bIsESPlusHeartBeatModuleRunning=`exec ps -aux  | grep  ESPlusHeartBeatModule.sh | wc -l`;
        if [ $bIsESPlusHeartBeatModuleRunning -ge 1 ]
	then
		bIsESPlusRunning=1;
	fi
}

CheckIfESPlusIsInstalled
CheckIfESPlusIsRunningCorectly
if [ $bIsESPlusInstalled -eq 1 ]
then
        if [ $bIsESPlusRunning -eq 1 ]
        then
                printf "Hello "$USER" ESPlus is successfully installed and running correctly on your machine.";
                printf "\n  Support section for Unix users is available on ES+ Dashboard as ES+ Dashboard-> Support-> Linux.";
                printf "\n  ESPlus dashboard link : "$ESPlusQuries+"\n";
        else
                printf "Hello "$USER" ESPlus is installed on your machine. But its not running correctly.";
                printf "\n  Please drop a mail to "$ESPlusAdmin" they will do the needfull.\n";
        fi
else
        printf "Hello "$USER" ESPlus is not installed on your machine.";
        printf "\n  ESPlus unix installtion guid is availble on  link :  "$ESPlusUnixInstalltionGuideLink;
        printf "\n  Support section for Unix users is available on ES+ Dashboard as ES+ Dashboard-> Support-> Linux."; 
        printf "\n  ESPlus dashboard link : "$ESPlusQuries+"\n"; 
fi
