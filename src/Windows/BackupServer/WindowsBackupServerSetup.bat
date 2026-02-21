@echo off
REM -------------------------------
REM Windows Server VirtualBox Installatie
REM -------------------------------

REM Stel het VirtualBox-pad in
cd /d "C:\Program Files\Oracle\VirtualBox\"

REM Vraag gebruikersinvoer op
SET /p VM_NAME= VM-naam:
SET /p ISO_PATH= Pad naar ISO: 
SET /p SHARED_FOLDER_PATH= Pad naar gedeelde map (GitHub-klone):
SET /p ADMIN_PASSWORD= Admin wachtwoord:

SET DOMAIN_NAME=g07-syndus.internal
SET PRODUCT_KEY=N69G4-B89J2-4G8F4-WWYCC-J464C
SET VM_MEMORY=2048
SET VM_CPUS=1

REM -------------------------------
REM Maak een nieuwe VM aan
@echo Begin met het aanmaken van de VM
VBoxManage createvm --name "%VM_NAME%" --ostype "Windows2019_64" --register
@echo VM aanmaken voltooid

REM -------------------------------
REM Stel de basisconfiguratie van de VM in
@echo Basisconfiguratie starten
VBoxManage modifyvm "%VM_NAME%" --memory %VM_MEMORY% --vram 128 --cpus %VM_CPUS% --ioapic on --clipboard-mode bidirectional --draganddrop bidirectional
@echo Basisconfiguratie voltooid

REM -------------------------------
REM Maak en koppel de virtuele harde schijf
@echo Harde schijfconfiguratie starten
VBoxManage createhd --filename "%USERPROFILE%\VirtualBox VMs\%VM_NAME%\%VM_NAME%.vdi" --size 51200 --format VDI
VBoxManage storagectl "%VM_NAME%" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "%VM_NAME%" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "%USERPROFILE%\VirtualBox VMs\%VM_NAME%\%VM_NAME%.vdi"
@echo Harde schijfconfiguratie voltooid

@REM REM -------------------------------
@REM REM Configure Bridged Network Adapter
@REM @echo Netwerkconfiguratie starten (Bridged Mode)
@REM VBoxManage modifyvm "%VM_NAME%" --nic1 bridged --bridgeadapter1 "Cisco AnyConnect Secure Mobility Client Virtual Miniport Adapter for Windows x64"
@REM @echo Netwerkconfiguratie voltooid

REM -----------------------------------------
REM Voeg de GitHub-klone toe als gedeelde map
@echo Configuratie van gedeelde map starten
VBoxManage sharedfolder add "%VM_NAME%" --name "GitHubRepo" --hostpath "%SHARED_FOLDER_PATH%" --automount
@echo Configuratie van gedeelde map voltooid

REM -------------------------------
REM Unattended installatie (Automatische Windows installatie met productcode)
@echo Unattended Windows-installatie starten
VBoxManage unattended install "%VM_NAME%" ^
    --iso="%ISO_PATH%" ^
    --user="Administrator" ^
    --password="%ADMIN_PASSWORD%" ^
    --full-user-name="Admin" ^
    --install-additions ^
    --time-zone="W. Europe Standard Time" ^
    --locale=en_US ^
    --country=BE ^
    --hostname="%DOMAIN_NAME%" ^
    --image-index=1 ^
    --key="%PRODUCT_KEY%" ^
    --start-vm=headless
    --post-install-template= shutdown
@echo Unattended installatie voltooid


REM -------------------------------
@echo VM-installatie succesvol voltooid!
@echo Je gedeelde map (GitHub-klone) "%SHARED_FOLDER_PATH%" is nu beschikbaar als "GitHubRepo" in de VM.

