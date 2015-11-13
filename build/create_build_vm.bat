for /f "delims=" %%i in ('where VBoxManage.exe') do set RESULT=%%i
set iso=%RESULT:~0,-14%VBoxGuestAdditions.iso

set vm=porteus_build_vm
VboxManage unregistervm %vm% --delete
VboxManage createvm --name %vm% --register
VboxManage modifyvm %vm% --ostype Linux --memory 1024 --nic1 nat --usb on
VboxManage storagectl %vm% --name porteus_live_cd --add ide --bootable on
VboxManage storageattach %vm% --storagectl porteus_live_cd --type dvddrive --port 1 --device 0 --medium "%~dp0%1" --tempeject on
VboxManage storageattach %vm% --storagectl porteus_live_cd --type dvddrive --port 1 --device 1 --medium "%iso%" --tempeject on
VBoxManage usbfilter add 1 --target %vm% --name any
VBoxManage startvm %vm%