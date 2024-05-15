unit uefiinstaller;
interface

uses uefi,tydqfs;

function efi_main(ImageHandle:efi_handle;systemtable:Pefi_system_table):efi_status;cdecl;

implementation

function efi_main(ImageHandle:efi_handle;systemtable:Pefi_system_table):efi_status;cdecl;[public,alias:'efi_main'];
var mystr:PWideChar;
    cdindex,hdindex,emptyindex,emptynum:natuint;
    verifydata:qword;
    i,realsize:natuint;
    status:efi_status;
    efsl:efi_file_system_list;
    efslext:efi_file_system_list_ext;
    efp:Pefi_file_protocol;
    efsi:efi_file_system_info;
    edl,edl2,edl3:efi_disk_list;
    mybool:boolean;
begin
 efi_console_set_global_colour(Systemtable,efi_bck_black,efi_lightgrey);
 efi_console_clear_screen(systemtable);
 efi_console_get_max_row_and_max_column(systemtable,false);
 efi_console_enable_mouse(systemtable);
 efi_console_enable_mouse_blink(systemtable,true,500);
 efslext:=efi_list_all_file_system_ext(systemtable);
 efi_system_restart_information_off(systemtable,mybool);
 if(efslext.fsrwcount=0) and (mybool=false) then
 begin
  efsl:=efi_list_all_file_system(systemtable,1);
  efi_console_output_string(systemtable,'Welcome to tydq system installer to install tydq system to hard disk!'+#13#10);
  efi_console_output_string(systemtable,'This is installtion stage 1.'+#13#10);
  efi_console_output_string(systemtable,'Now you can install the tydq system by using tydq installer!'+#13#10);
  efi_console_output_string(systemtable,'The Cdrom which have install ability to install to hard disk:'+#13#10);
  efi_console_output_string(systemtable,'Total Cdrom Number:');
  efi_console_output_string(systemtable,UintToPWChar(efsl.file_system_count));
  efi_console_output_string(systemtable,#13#10);
  efi_console_output_string(systemtable,'Cdrom information:');
  efi_console_output_string(systemtable,#13#10);
  for i:=1 to efsl.file_system_count do
   begin
    realsize:=sizeof(efi_file_system_info);
    ((efsl.file_system_content+i-1)^)^.OpenVolume((efsl.file_system_content+i-1)^,efp);
    efp^.GetInfo(efp,@efi_file_system_info_id,realsize,efsi);
    efi_console_output_string(systemtable,'Cdrom');
    efi_console_output_string(systemtable,UintToPWChar(i));
    efi_console_output_string(systemtable,' Size:');
    efi_console_output_string(systemtable,UintToPWChar(efsi.VolumeSize));
    efi_console_output_string(systemtable,#13#10);
    efp^.Close(efp);
   end;
  edl:=efi_detect_disk_write_ability(systemTable);
  efi_console_output_string(systemtable,'Available disk number:');
  efi_console_output_string(systemtable,UintToPWchar(edl.disk_count));
  efi_console_output_string(systemtable,#13#10);
  efi_console_output_string(systemtable,'Available disk to be installed to:');
  efi_console_output_string(systemtable,#13#10);
  for i:=1 to edl.disk_count do
   begin 
    efi_console_output_string(systemtable,UintToPWChar(i));
    efi_console_output_string(systemtable,'-');
    realsize:=((edl.disk_block_content+i-1)^)^.Media^.BlockSize*(((edl.disk_block_content+i-1)^)^.Media^.LastBlock+1);
    efi_console_output_string(systemtable,UintToPWChar(realsize));
    efi_console_output_string(systemtable,#13#10);
   end;
  efi_console_output_string(systemtable,'Do you want to install the cdrom to the hard disk(Y or y is yes,other is no)?'#13#10);
  efi_console_output_string(systemtable,'Your answer:');
  efi_console_read_string(systemtable,mystr);
  while(WstrCmp(mystr,'Y')<>0) and (WstrCmp(mystr,'y')<>0) do
   begin
    if(WstrCmp(mystr,'Y')<>0) and (WstrCmp(mystr,'y')<>0) then
     begin
      efi_console_output_string(systemtable,'Do you want to exit the installer(Y or y is yes,other is no)?'#13#10);
      efi_console_output_string(systemtable,'Your answer:');
      efi_console_read_string(systemtable,mystr);
      if(WstrCmp(mystr,'Y')=0) or (WstrCmp(mystr,'y')=0) then
       begin
        SystemTable^.RuntimeServices^.ResetSystem(EfiResetShutdown,efi_success,0,nil);
       end;
     end;
    efi_console_output_string(systemtable,'Do you want to install the cdrom to the hard disk(Y or y is yes,other is no)?'#13#10);
    efi_console_output_string(systemtable,'Your answer:');
    efi_console_read_string(systemtable,mystr);
   end;
  if(edl.disk_count=0) then
   begin
    efi_console_output_string(systemtable,'ERROR:No available disk found,installer terminated.'#13#10);
    while(True) do;
   end;
  cdindex:=1; hdindex:=1;
  if(efsl.file_system_count>1) then
   begin
    cdindex:=efsl.file_system_count+1;
    while (cdindex<efsl.file_system_count+1) do
     begin
      efi_console_output_string(systemtable,'Select the cdrom to install:');
      efi_console_read_string(systemtable,mystr);
      cdindex:=PWCharToUint(mystr);
      if(cdindex>=efsl.file_system_count+1) then efi_console_output_string(systemtable,'Error:Invaild Cdrom.'+#13#10);
     end;
   end;
  if(edl.disk_count>1) then
   begin
    hdindex:=edl.disk_count+1;
    while (cdindex<edl.disk_count+1) do
     begin
      efi_console_output_string(systemtable,'Select the hard disk to be installed:');
      efi_console_read_string(systemtable,mystr);
      hdindex:=PWCharToUint(mystr);
      if(hdindex>=edl.disk_count+1) then efi_console_output_string(systemtable,'Error:Invaild Hard Disk.'+#13#10);
     end;
   end;
  efi_install_cdrom_to_hard_disk(systemtable,efsl,edl,cdindex,hdindex);
  efi_console_output_string(systemtable,'Stage 1 Install done!Now you can reboot the installer to enter stage 2!'+#13#10);
  SystemTable^.RuntimeServices^.ResetSystem(EfiResetWarm,efi_success,0,nil);
 end
 else if(mybool=true) then
  begin 
   efi_console_output_string(systemtable,'This is install stage 2,Following the instruction to completely install the system on the machine!'#13#10);
   if(efslext.fsrcount>0) then efi_console_output_string(systemtable,'Your Cdrom is:'+#13#10);
   for i:=1 to efslext.fsrcount do
    begin
     ((efslext.fsrcontent+i-1)^)^.OpenVolume((efslext.fsrcontent+i-1)^,efp);
     realsize:=sizeof(efi_file_system_info);
     efp^.GetInfo(efp,@efi_file_system_info_id,realsize,efsi);
     efi_console_output_string(systemtable,'Cdrom ');
     efi_console_output_string(systemtable,UintToPWChar(i));
     efi_console_output_string(systemtable,' - ');
     efi_console_output_string(systemtable,UintToPWChar(efsi.VolumeSize));
     efi_console_output_string(systemtable,#13#10);
    end;
   if(efslext.fsrwcount>0) then efi_console_output_string(systemtable,'Your EFI System Partition is:'+#13#10);
   for i:=1 to efslext.fsrwcount do
    begin
     ((efslext.fsrwcontent+i-1)^)^.OpenVolume((efslext.fsrwcontent+i-1)^,efp);
     realsize:=sizeof(efi_file_system_info);
     efp^.GetInfo(efp,@efi_file_system_info_id,realsize,efsi);
     efi_console_output_string(systemtable,'EFI System Partition ');
     efi_console_output_string(systemtable,UintToPWChar(i));
     efi_console_output_string(systemtable,' - ');
     efi_console_output_string(systemtable,UintToPWChar(efsi.VolumeSize));
     efi_console_output_string(systemtable,#13#10);
    end;
   cdindex:=1; hdindex:=1;
   if(efslext.fsrcount>1) then
    begin
     cdindex:=efslext.fsrcount+1;
     while (cdindex>efslext.fsrcount) or (cdindex=0) do
      begin
       efi_console_output_string(systemtable,'Select the cdrom to install:');
       efi_console_read_string(systemtable,mystr);
       cdindex:=PWCharToUint(mystr);
       if(cdindex>efslext.fsrcount) or (cdindex=0) then efi_console_output_string(systemtable,'Error:Invaild Cdrom.'+#13#10);
      end;
    end;
   if(efslext.fsrwcount>1) then
    begin
     hdindex:=efslext.fsrwcount+1;
     while (hdindex>efslext.fsrwcount) or (hdindex=0) do
      begin
       efi_console_output_string(systemtable,'Select the EFI System Partition to install:');
       efi_console_read_string(systemtable,mystr);
       hdindex:=PWCharToUint(mystr);
       if(hdindex>efslext.fsrwcount) or (hdindex=0) then efi_console_output_string(systemtable,'Error:Invaild EFI System Partition.'+#13#10);
      end;
    end;
   efi_install_cdrom_to_hard_disk_stage2(systemtable,efslext,cdindex,hdindex,true);
   edl2:=efi_disk_empty_list(systemtable);
   if(edl2.disk_count>0) then
    begin
     efi_console_output_string(systemtable,'The empty disks are:'#13#10);
     for i:=1 to edl2.disk_count do
      begin
       efi_console_output_string(systemtable,'Disk ');
       efi_console_output_string(systemtable,UintToPWChar(i));
       efi_console_output_string(systemtable,' - ');
       realsize:=((edl2.disk_block_content+i-1)^)^.Media^.BlockSize*(((edl2.disk_block_content+i-1)^)^.Media^.LastBlock+1);
       efi_console_output_string(systemtable,UintToPWChar(realsize));
       efi_console_output_string(systemtable,#13#10);
      end;
     efi_console_output_string(systemtable,'Do you want to format the empty disk to TYDQ File System(Y or y is yes,other is no)?'#13#10);
     efi_console_output_string(systemtable,'Your answer:');
     efi_console_read_string(systemtable,mystr);
     if(WStrCmp(mystr,'Y')=0) or (WStrCmp(mystr,'y')=0) then
      begin
       efi_console_output_string(systemtable,'Please input the empty disks'#39' Total Number to format them to TYDQ File System:');
       efi_console_read_string(systemtable,mystr);
       emptynum:=PWCharToUint(mystr);
       if(emptynum<=edl2.disk_count) then
        begin
         i:=0;
         while(i<emptynum) do
          begin
           inc(i);
           efi_console_output_string(systemtable,'The Empty Disk index');
           efi_console_output_string(systemtable,UintToPWChar(i));
           efi_console_output_string(systemtable,' is:');
           efi_console_read_String(systemtable,mystr);
           emptyindex:=PWcharToUint(mystr);
           ((edl2.disk_content+emptyindex-1)^)^.ReadDisk((edl2.disk_content+emptyindex-1)^,
           ((edl2.disk_block_content+emptyindex-1)^)^.Media^.MediaId,0,8,verifydata);
           if(emptyindex>edl2.disk_count) or (emptyindex=0) then
            begin
             efi_console_output_string(systemtable,'Error:Invaild Disk.'+#13#10);
             dec(i);
            end
           else if(verifydata=$5D47291AD7E3F2B1) then
            begin
             efi_console_output_string(systemtable,'Error:Disk is formatted.'+#13#10);
             dec(i);
            end
           else
            begin
             efi_console_output_string(systemtable,'The Disk Name is(Name length DO NOT exceeds to 256):');
             efi_console_read_string(systemtable,mystr);
             efi_disk_tydq_set_fs(systemtable,emptyindex);
             tydq_fs_initialize(edl2,emptyindex,mystr);
            end;
          end;
        end;
      end;
    end
   else
    begin
     efi_console_output_string(systemtable,'No disk available for TYDQ system install,installer terminated.');
     while True do;
    end;
   efi_console_output_string(systemtable,'Stage 2 Install done!Now you can restart your installer to enter the system!'#13#10);
   SystemTable^.RuntimeServices^.ResetSystem(EfiResetWarm,efi_success,0,nil);
  end
 else
  begin
   efi_console_output_string(systemtable,'EFI System Partition detected,set the installer stage to the stage 2!'#13#10);
   efi_console_output_string(systemtable,'This is install stage 2,Following the instruction to completely install the system on the machine!'#13#10);
   if(efslext.fsrcount>0) then efi_console_output_string(systemtable,'Your Cdrom is:'+#13#10);
   for i:=1 to efslext.fsrcount do
    begin
     ((efslext.fsrcontent+i-1)^)^.OpenVolume((efslext.fsrcontent+i-1)^,efp);
     realsize:=sizeof(efi_file_system_info);
     efp^.GetInfo(efp,@efi_file_system_info_id,realsize,efsi);
     efi_console_output_string(systemtable,'Cdrom ');
     efi_console_output_string(systemtable,UintToPWChar(i));
     efi_console_output_string(systemtable,' - ');
     efi_console_output_string(systemtable,UintToPWChar(efsi.VolumeSize));
     efi_console_output_string(systemtable,#13#10);
    end;
   if(efslext.fsrwcount>0) then efi_console_output_string(systemtable,'Your EFI System Partition is:'+#13#10);
   for i:=1 to efslext.fsrwcount do
    begin
     ((efslext.fsrwcontent+i-1)^)^.OpenVolume((efslext.fsrwcontent+i-1)^,efp);
     realsize:=sizeof(efi_file_system_info);
     efp^.GetInfo(efp,@efi_file_system_info_id,realsize,efsi);
     efi_console_output_string(systemtable,'EFI System Partition ');
     efi_console_output_string(systemtable,UintToPWChar(i));
     efi_console_output_string(systemtable,' - ');
     efi_console_output_string(systemtable,UintToPWChar(efsi.VolumeSize));
     efi_console_output_string(systemtable,#13#10);
    end;
   cdindex:=1; hdindex:=1;
   if(efslext.fsrcount>1) then
    begin
     cdindex:=efslext.fsrcount+1;
     while (cdindex>efslext.fsrcount) or (cdindex=0) do
      begin
       efi_console_output_string(systemtable,'Select the cdrom to install:');
       efi_console_read_string(systemtable,mystr);
       cdindex:=PWCharToUint(mystr);
       if(cdindex>efslext.fsrcount) or (cdindex=0) then efi_console_output_string(systemtable,'Error:Invaild Cdrom.'+#13#10);
      end;
    end;
   if(efslext.fsrwcount>1) then
    begin
     hdindex:=efslext.fsrwcount+1;
     while (hdindex>efslext.fsrwcount) or (hdindex=0) do
      begin
       efi_console_output_string(systemtable,'Select the EFI System Partition to install:');
       efi_console_read_string(systemtable,mystr);
       hdindex:=PWCharToUint(mystr);
       if(hdindex>efslext.fsrwcount) or (hdindex=0) then efi_console_output_string(systemtable,'Error:Invaild EFI System Partition.'+#13#10);
      end;
    end;
   efi_install_cdrom_to_hard_disk_stage2(systemtable,efslext,cdindex,hdindex,false);
   edl2:=efi_disk_empty_list(systemtable);
   if(edl2.disk_count>0) then
    begin
     efi_console_output_string(systemtable,'The empty disks are:'#13#10);
     for i:=1 to edl2.disk_count do
      begin
       efi_console_output_string(systemtable,'Disk ');
       efi_console_output_string(systemtable,UintToPWChar(i));
       efi_console_output_string(systemtable,' - ');
       realsize:=((edl2.disk_block_content+i-1)^)^.Media^.BlockSize*(((edl2.disk_block_content+i-1)^)^.Media^.LastBlock+1);
       efi_console_output_string(systemtable,UintToPWChar(realsize));
       efi_console_output_string(systemtable,#13#10);
      end;
     efi_console_output_string(systemtable,'Do you want to format the empty disk to TYDQ File System(Y or y is yes,other is no)?'#13#10);
     efi_console_output_string(systemtable,'Your answer:');
     efi_console_read_string(systemtable,mystr);
     if(WStrCmp(mystr,'Y')=0) or (WStrCmp(mystr,'y')=0) then
      begin
       efi_console_output_string(systemtable,'Please input the empty disks'#39' Total Number to format them to TYDQ File System:');
       efi_console_read_string(systemtable,mystr);
       emptynum:=PWCharToUint(mystr);
       if(emptynum<=edl2.disk_count) then
        begin
         i:=0;
         while(i<emptynum) do
          begin
           inc(i);
           efi_console_output_string(systemtable,'The Empty Disk index');
           efi_console_output_string(systemtable,UintToPWChar(i));
           efi_console_output_string(systemtable,' is:');
           efi_console_read_String(systemtable,mystr);
           emptyindex:=PWcharToUint(mystr);
           ((edl2.disk_content+emptyindex-1)^)^.ReadDisk((edl2.disk_content+emptyindex-1)^,
           ((edl2.disk_block_content+emptyindex-1)^)^.Media^.MediaId,0,8,verifydata);
           if(emptyindex>edl2.disk_count) or (emptyindex=0) then
            begin
             efi_console_output_string(systemtable,'Error:Invaild Disk.'+#13#10);
             dec(i);
            end
           else if(verifydata=$5D47291AD7E3F2B1) then
            begin
             efi_console_output_string(systemtable,'Error:Disk is formatted.'+#13#10);
             dec(i);
            end
           else
            begin
             efi_console_output_string(systemtable,'The Disk Name is(Name length DO NOT exceeds to 256):');
             efi_console_read_string(systemtable,mystr);
             efi_disk_tydq_set_fs(systemtable,emptyindex);
             tydq_fs_initialize(edl2,emptyindex,mystr);
            end;
          end;
        end;
      end;
    end
   else
    begin
     efi_console_output_string(systemtable,'No disk available for TYDQ system install,installer terminated.');
     while True do;
    end;
   efi_console_output_string(systemtable,'Stage 2 Install done!Now you can restart your installer to enter the system!'#13#10);
   SystemTable^.RuntimeServices^.ResetSystem(EfiResetWarm,efi_success,0,nil);
  end;
 efi_main:=efi_success;
end;

end.
