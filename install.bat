VboxManage unregistervm porteus_browser_appliance --delete
VboxManage createvm --name porteus_browser_appliance --register
VboxManage modifyvm porteus_browser_appliance --ostype Linux --memory 1024 --vram 128 --cpus 2 --ioapic on --nic1 nat --audio dsound --clipboard bidirectional --draganddrop hosttoguest
VboxManage storagectl porteus_browser_appliance --name porteus_live_cd --add ide --bootable on
VboxManage storageattach porteus_browser_appliance --storagectl porteus_live_cd --type dvddrive --port 1 --device 0 --medium "%~dp0output.iso" --tempeject on
VboxManage sharedfolder add porteus_browser_appliance --name "share" --hostpath "%~dp0boot" --readonly
VboxManage sharedfolder add porteus_browser_appliance --name "storage" --hostpath "%~dp0storage"
