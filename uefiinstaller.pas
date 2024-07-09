library uefiinstaller;

{$MODE FPC}

uses uefi,tydqfs;

function efi_main(ImageHandle:efi_handle;systemtable:Pefi_system_table):efi_status;cdecl;[public,alias:'_DLLMainCRTStartup'];
var mystr,mystr2,mystr3,partstr:PWideChar;
    cdindex,hdindex,emptyindex,emptynum,procnum:natuint;
    verifydata:qword;
    i,j,realsize:natuint;
    status:efi_status;
    efsl:efi_file_system_list;
    efslext:efi_file_system_list_ext;
    efp:Pefi_file_protocol;
    efsi:efi_file_system_info;
    edl,edl2,edl3:efi_disk_list;
    fsh:tydqfs_header;
    mybool,havesysinfo:boolean;
    fsi:tydqfs_system_info;
begin
 {Initialize the system heap and executable heap}
 compheap.heapcount:=0; compheap.heaprest:=maxheap;
 sysheap.heapcount:=0; sysheap.heaprest:=maxheap;
 {Initiailize ended}
 efi_console_set_global_colour(Systemtable,efi_bck_black,efi_lightgrey);
 efi_console_clear_screen(systemtable);
 efi_console_get_max_row_and_max_column(systemtable,false);
 efi_console_enable_mouse(systemtable);
 efi_console_enable_mouse_blink(systemtable,true,500);
 efi_set_watchdog_timer_to_null(systemtable);
 efslext:=efi_list_all_file_system_ext(systemtable);
 efi_system_restart_information_off(systemtable,mybool); 
 havesysinfo:=false; 
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
    efi_console_output_string(systemtable,ExtendedToPWChar(efsi.VolumeSize/(1024*1024),2));
    efi_console_output_string(systemtable,'MiB');
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
    efi_console_output_string(systemtable,ExtendedToPWChar(realsize/(1024*1024*1024),2));
    efi_console_output_string(systemtable,'GiB');
    efi_console_output_string(systemtable,#13#10);
   end;
  efi_console_output_string(systemtable,'Do you want to install the cdrom to the hard disk(Y or y is yes,other is no)?'#13#10);
  efi_console_output_string(systemtable,'Your answer:');
  efi_console_read_string(systemtable,mystr);
  while((WstrCmp(mystr,'Y')<>0) and (WstrCmp(mystr,'y')<>0)) or (Wstrlen(mystr)=0)  do
   begin
    if((WstrCmp(mystr,'Y')<>0) and (WstrCmp(mystr,'y')<>0)) or (Wstrlen(mystr)=0) then
     begin
      efi_console_output_string(systemtable,'Do you want to exit the installer(Y or y is yes,other is no)?'#13#10);
      efi_console_output_string(systemtable,'Your answer:');
      efi_console_read_string(systemtable,mystr);
      if((WstrCmp(mystr,'Y')=0) or (WstrCmp(mystr,'y')=0)) and (Wstrlen(mystr)>0) then
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
    efi_console_output_string(systemtable,'Error:No available disk found,installer terminated.'#13#10);
    while(True) do;
   end;
  cdindex:=1; hdindex:=1;
  if(efsl.file_system_count>1) then
   begin
    cdindex:=efsl.file_system_count+1;
    while (cdindex=0) or (cdindex>=efsl.file_system_count+1) do
     begin
      efi_console_output_string(systemtable,'Select the cdrom to install:');
      efi_console_read_string(systemtable,mystr);
      cdindex:=PWCharToUint(mystr);
      Wstrfree(mystr);
      if(cdindex>=efsl.file_system_count+1) or (cdindex=0) then efi_console_output_string(systemtable,'Error:Invaild Cdrom.'+#13#10);
     end;
   end;
  if(edl.disk_count>1) then
   begin
    hdindex:=edl.disk_count+1;
    while (hdindex=0) or (hdindex>=edl.disk_count+1) do
     begin
      efi_console_output_string(systemtable,'Select the hard disk to be installed:');
      efi_console_read_string(systemtable,mystr);
      hdindex:=PWCharToUint(mystr);
      Wstrfree(mystr);
      if(hdindex>=edl.disk_count+1) or (hdindex=0) then efi_console_output_string(systemtable,'Error:Invaild Hard Disk.'+#13#10);
     end;
   end;
  efi_install_cdrom_to_hard_disk(systemtable,edl,cdindex,hdindex);
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
     efi_console_output_string(systemtable,ExtendedToPWChar(efsi.VolumeSize/(1024*1024),2));
     efi_console_output_string(systemtable,'MiB');
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
     efi_console_output_string(systemtable,ExtendedToPWChar(efsi.VolumeSize/(1024*1024),2));
     efi_console_output_string(systemtable,'MiB');
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
       efi_console_output_string(systemtable,ExtendedToPWChar(realsize/(1024*1024*1024),2));
       efi_console_output_string(systemtable,'GiB');
       efi_console_output_string(systemtable,#13#10);
      end;
      efi_console_output_string(systemtable,'Do you want to format the empty disk to TYDQ File System(Y or y is yes,other is no)?'#13#10);
      efi_console_output_string(systemtable,'Your answer:');
      efi_console_read_string(systemtable,mystr);
      if((WStrCmp(mystr,'Y')=0) or (WStrCmp(mystr,'y')=0)) and (WStrlen(mystr)=1) then
       begin
        efi_console_output_string(systemtable,'Please input the empty disks'#39' Total Number to format them to TYDQ File System:');
        efi_console_read_string(systemtable,mystr);
        emptynum:=PWCharToUint(mystr);
        while(emptynum>edl2.disk_count) and (emptynum=0) do
         begin
          if(emptynum>edl2.disk_count) then
           begin
            efi_console_output_string(systemtable,'Error:Total Number is too large that exceed the empty disk total number.');
           end
          else if(emptynum=0) then
           begin
            efi_console_output_string(systemtable,'Error:Total Number must be larger than 0.');
           end;
         efi_console_output_string(systemtable,'Please input the empty disks'#39' Total Number to format them to TYDQ File System:');
         efi_console_read_string(systemtable,mystr);
         emptynum:=PWCharToUint(mystr);
        end;
       if(emptynum<=edl2.disk_count) then
        begin
         i:=0;
         while(i<emptynum) do
          begin
           inc(i);
           efi_console_output_string(systemtable,'The Empty Disk index ');
           efi_console_output_string(systemtable,UintToPWChar(i));
           efi_console_output_string(systemtable,' is:');
           efi_console_read_String(systemtable,mystr);
           emptyindex:=PWcharToUint(mystr);
           if(emptyindex<=edl2.disk_count) and (emptyindex>=1) then
            begin
             ((edl2.disk_content+emptyindex-1)^)^.ReadDisk((edl2.disk_content+emptyindex-1)^,
             ((edl2.disk_block_content+emptyindex-1)^)^.Media^.MediaId,0,8,verifydata);
            end
           else verifydata:=$0000000000000000;
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
             edl3:=efi_disk_tydq_get_fs_list(systemtable);
             efi_console_output_string(systemtable,'Type the disk ');
             efi_console_output_string(systemtable,UintToPWChar(i));
             efi_console_output_string(systemtable,#39's name(Name length DO NOT exceeds to 255):');
             efi_console_read_string(systemtable,mystr);
             while(Wstrlen(mystr)>255) or (Wstrlen(mystr)=0) or (tydq_fs_disk_exists(edl3,mystr)=true) or (tydq_fs_legal_filename(mystr)=false) do 
              begin
               if(Wstrlen(mystr)>255) or (Wstrlen(mystr)=0) then efi_console_output_string(systemtable,'Error:Disk name exceeds 255.'#13#10)
               else if(tydq_fs_disk_exists(edl3,mystr)=true) then efi_console_output_string(systemtable,'Error:Disk name exists.'#13#10)
               else if(tydq_fs_legal_filename(mystr)=false) then 
               efi_console_output_string(systemtable,'Error:Disk name illegal,please modify the new disk name(space,* or ? are illegal).'#10);
               efi_console_output_string(systemtable,'Type the disk ');
               efi_console_output_string(systemtable,UintToPWChar(i));
               efi_console_output_string(systemtable,#39's name(Name length DO NOT exceeds to 255):');
               efi_console_read_string(systemtable,mystr);
              end;
             efi_disk_tydq_set_fs(edl2,emptyindex);
             tydq_fs_initialize(edl2,emptyindex,mystr);
             Wstrfree(mystr); freemem(edl3.disk_block_content); freemem(edl3.disk_content); edl3.disk_count:=0;
             edl3:=efi_disk_tydq_get_fs_list(systemtable);
             if(edl3.disk_count>0) and (havesysinfo=false) then 
              begin
               efi_console_output_string(systemtable,'Do you want to specify this disk as system disk?'#10);
               efi_console_output_string(systemtable,'Your answer:');
               efi_console_read_string(systemtable,mystr);
               if((WStrcmp(mystr,'Y')=0) or (WStrcmp(mystr,'y')=0)) and (Wstrlen(mystr)=1) then 
                begin
                 tydq_fs_create_systeminfo_file(systemtable,edl2,emptyindex); havesysinfo:=true;
                 fsi:=tydq_fs_systeminfo_init(1);
                 if(fsi.header.tydqusercount=0) then
                  begin
                   efi_console_output_string(systemtable,'You need a user account to enter the installed system,So you need to create a account.'#10);
      		   efi_console_output_string(systemtable,'Do you want to create the account immediately or create it later(Y or y is yes,other is no)?'#10);
      		   efi_console_output_string(systemtable,'The first account will be automatically set to be user manager.'#10);
                   efi_console_output_string(systemtable,'Your answer:');
                   efi_console_read_string(systemtable,mystr);
                   if((WstrCmp(mystr,'Y')=0) or (WstrCmp(mystr,'y')=0)) and (Wstrlen(mystr)=1) then
                    begin
                     efi_console_output_string(systemtable,'Set your account name(Name length must be in 1-128):');
                     efi_console_read_string(systemtable,mystr);
                     while(Wstrlen(mystr)=0) or (Wstrlen(mystr)>128) or (tydq_fs_legal_filename(mystr)=false) do
                      begin
                       if(tydq_fs_legal_filename(mystr)=false) then
                       efi_console_output_string(systemtable,'Error:Account name is illegal(space,* or ? is illegal character).'#10)
                       else efi_console_output_string(systemtable,'Error:Account Name is invaild.'#10);
                       efi_console_output_string(systemtable,'Set your account name:');
                       efi_console_read_string(systemtable,mystr);
                      end;
                     efi_console_output_string(systemtable,'Set your account password(Password length must be in 1-128):');
                     efi_console_read_password_string(systemtable,mystr2);
                     while(Wstrlen(mystr2)=0) or (Wstrlen(mystr2)>128) do
                      begin
                       efi_console_output_string(systemtable,'Error:Account password is invaild.'#10);
                       efi_console_output_string(systemtable,'Set your account name:');
                       efi_console_read_string(systemtable,mystr);
                      end;
                     efi_console_output_string(systemtable,'Verify your account password:');
                     efi_console_read_password_string(systemtable,mystr3);
                     while(Wstrcmp(mystr2,mystr3)<>0) or (WStrlen(mystr2)<>Wstrlen(mystr3)) do
                      begin
                       efi_console_output_string(systemtable,'Error:Typed password does not match your password.'#10);
                       efi_console_output_string(systemtable,'Verify your account password:');
                       efi_console_read_password_string(systemtable,mystr3);
                      end;
                     tydq_fs_systeminfo_add_user(fsi,mystr,mystr2,true);
                     tydq_fs_systeminfo_write(systemtable,edl3,fsi);
                     Wstrfree(mystr3); Wstrfree(mystr2);
                    end;
                   Wstrfree(mystr);
                  end
                 else
                  begin
                   efi_console_output_string(systemtable,'You will create the account later when entering the system.'#10);
                  end;
                end
               else
                begin
                 if(i=emptynum) then efi_console_output_string(systemtable,'You will specify the system disk later in system.'#10)
                 else efi_console_output_string(systemtable,'You can specify an another disk to system disk.'#10);
                end;
              end;
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
   freemem(edl3.disk_block_content); freemem(edl3.disk_content); edl3.disk_count:=0;
   freemem(edl2.disk_block_content); freemem(edl2.disk_content); edl2.disk_count:=0;
   freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
   Wstrfree(mystr3); Wstrfree(mystr2); Wstrfree(mystr); sysheap_clear_all;
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
     efi_console_output_string(systemtable,ExtendedToPWChar(efsi.VolumeSize/(1024*1024),2));
     efi_console_output_string(systemtable,'MiB');
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
     efi_console_output_string(systemtable,ExtendedToPWChar(efsi.VolumeSize/(1024*1024),2));
     efi_console_output_string(systemtable,'MiB');
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
       efi_console_output_string(systemtable,ExtendedToPWChar(realsize/(1024*1024*1024),2));
       efi_console_output_string(systemtable,'GiB');
       efi_console_output_string(systemtable,#13#10);
      end;
     efi_console_output_string(systemtable,'Do you want to format the empty disk to TYDQ File System(Y or y is yes,other is no)?'#13#10);
     efi_console_output_string(systemtable,'Your answer:');
     efi_console_read_string(systemtable,mystr);
     if((WStrCmp(mystr,'Y')=0) or (WStrCmp(mystr,'y')=0)) and (Wstrlen(mystr)>0) then
      begin
        efi_console_output_string(systemtable,'Please input the empty disks'#39' Total Number to format them to TYDQ File System:');
        efi_console_read_string(systemtable,mystr);
        emptynum:=PWCharToUint(mystr);
        while(emptynum>edl2.disk_count) do
         begin
          if(emptynum>edl2.disk_count) then
           begin
            efi_console_output_string(systemtable,'Error:Total Number is too large that exceed the empty disk total number.');
           end
          else if(emptynum=0) then
           begin
            efi_console_output_string(systemtable,'Error:Total Number must be larger than 0.');
           end;
          efi_console_output_string(systemtable,'Please input the empty disks'#39' Total Number to format them to TYDQ File System:');
          efi_console_read_string(systemtable,mystr);
          emptynum:=PWCharToUint(mystr);
          Wstrfree(mystr);
         end;
       if(emptynum<=edl2.disk_count) then
        begin
         i:=0;
         while(i<emptynum) do
          begin
           inc(i);
           efi_console_output_string(systemtable,'The Empty Disk index ');
           efi_console_output_string(systemtable,UintToPWChar(i));
           efi_console_output_string(systemtable,' is:');
           efi_console_read_String(systemtable,mystr);
           emptyindex:=PWcharToUint(mystr);
           Wstrfree(mystr);
           if(emptyindex<=edl2.disk_count) and (emptyindex>=1) then
            begin
             ((edl2.disk_content+emptyindex-1)^)^.ReadDisk((edl2.disk_content+emptyindex-1)^,
             ((edl2.disk_block_content+emptyindex-1)^)^.Media^.MediaId,0,8,verifydata);
            end
           else verifydata:=$0000000000000000;
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
             edl3:=efi_disk_tydq_get_fs_list(systemtable);
             efi_console_output_string(systemtable,'Type the disk');
             efi_console_output_string(systemtable,UintToPWChar(i));
             efi_console_output_string(systemtable,#39's name(Name length DO NOT exceeds to 255):');
             efi_console_read_string(systemtable,mystr);
             while(Wstrlen(mystr)>255) or (Wstrlen(mystr)=0) or (tydq_fs_disk_exists(edl3,mystr)=true) or (tydq_fs_legal_filename(mystr)=false) do 
              begin
               if(Wstrlen(mystr)>255) or (Wstrlen(mystr)=0) then efi_console_output_string(systemtable,'Error:Disk name exceeds 255.'#13#10)
               else if(tydq_fs_disk_exists(edl3,mystr)=true) then efi_console_output_string(systemtable,'Error:Disk name exists.'#13#10)
               else if(tydq_fs_legal_filename(mystr)=false) then 
               efi_console_output_string(systemtable,'Error:Disk name illegal,please modify the new disk name(space,* or ? are illegal).'#10);
               efi_console_output_string(systemtable,'Type the disk');
               efi_console_output_string(systemtable,UintToPWChar(i));
               efi_console_output_string(systemtable,#39's name(Name length DO NOT exceeds to 255):');
               efi_console_read_string(systemtable,mystr);
              end;
             efi_disk_tydq_set_fs(edl2,emptyindex);
             tydq_fs_initialize(edl2,emptyindex,mystr);
             Wstrfree(mystr); freemem(edl3.disk_block_content); freemem(edl3.disk_content); edl3.disk_count:=0;
             edl3:=efi_disk_tydq_get_fs_list(systemtable);
             if(edl3.disk_count>0) and (havesysinfo=false) then 
              begin
               efi_console_output_string(systemtable,'Do you want to specify this disk as system disk?'#10);
               efi_console_output_string(systemtable,'Your answer:');
               efi_console_read_string(systemtable,mystr);
               if((WStrcmp(mystr,'Y')=0) or (WStrcmp(mystr,'y')=0)) and (Wstrlen(mystr)=1) then 
                begin
                 tydq_fs_create_systeminfo_file(systemtable,edl2,emptyindex); havesysinfo:=true;
                 fsi:=tydq_fs_systeminfo_init(1);
                 if(fsi.header.tydqusercount=0) then
                  begin
                   efi_console_output_string(systemtable,'You need a user account to enter the installed system,So you need to create a account.'#10);
      		   efi_console_output_string(systemtable,'Do you want to create the account immediately or create it later(Y or y is yes,other is no)?'#10);
      		   efi_console_output_string(systemtable,'The first account will be automatically set to be user manager.'#10);
                   efi_console_output_string(systemtable,'Your answer:');
                   efi_console_read_string(systemtable,mystr);
                   if((WstrCmp(mystr,'Y')=0) or (WstrCmp(mystr,'y')=0)) and (Wstrlen(mystr)=1) then
                    begin
                     efi_console_output_string(systemtable,'Set your account name(Name length must be in 1-128):');
                     efi_console_read_string(systemtable,mystr);
                     while(Wstrlen(mystr)=0) or (Wstrlen(mystr)>128) or (tydq_fs_legal_filename(mystr)=false) do
                      begin
                       if(tydq_fs_legal_filename(mystr)=false) then
                       efi_console_output_string(systemtable,'Error:Account name is illegal(space,* or ? is illegal character).'#10)
                       else efi_console_output_string(systemtable,'Error:Account Name is invaild.'#10);
                       efi_console_output_string(systemtable,'Set your account name:');
                       efi_console_read_string(systemtable,mystr);
                      end;
                     efi_console_output_string(systemtable,'Set your account password(Password length must be in 1-128):');
                     efi_console_read_password_string(systemtable,mystr2);
                     while(Wstrlen(mystr2)=0) or (Wstrlen(mystr2)>128) do
                      begin
                       efi_console_output_string(systemtable,'Error:Account password is invaild.'#10);
                       efi_console_output_string(systemtable,'Set your account name:');
                       efi_console_read_string(systemtable,mystr);
                      end;
                     efi_console_output_string(systemtable,'Verify your account password:');
                     efi_console_read_password_string(systemtable,mystr3);
                     while(Wstrcmp(mystr2,mystr3)<>0) or (WStrlen(mystr2)<>Wstrlen(mystr3)) do
                      begin
                       efi_console_output_string(systemtable,'Error:Typed password does not match your password.'#10);
                       efi_console_output_string(systemtable,'Verify your account password:');
                       efi_console_read_password_string(systemtable,mystr3);
                      end;
                     tydq_fs_systeminfo_add_user(fsi,mystr,mystr2,true);
                     tydq_fs_systeminfo_write(systemtable,edl2,fsi);
                     Wstrfree(mystr3); Wstrfree(mystr2);
                    end;
                   Wstrfree(mystr);
                  end
                 else
                  begin
                   efi_console_output_string(systemtable,'You will create the account later when entering the system.'#10);
                  end;
                end
               else
                begin
                 if(i=emptynum) then efi_console_output_string(systemtable,'You will specify the system disk later in system.'#10)
                 else efi_console_output_string(systemtable,'You can specify an another disk to system disk.'#10);
                end;
              end;
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
    freemem(edl3.disk_block_content); freemem(edl3.disk_content); edl3.disk_count:=0;
    freemem(edl2.disk_block_content); freemem(edl2.disk_content); edl2.disk_count:=0;
    freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
    freemem(mystr3); freemem(mystr2); freemem(mystr); sysheap_clear_all;
   efi_console_output_string(systemtable,'Stage 2 Install done!Now you can restart your installer to enter the system!'#13#10);
   SystemTable^.RuntimeServices^.ResetSystem(EfiResetWarm,efi_success,0,nil);
  end;
 efi_main:=efi_success;
end;

end.
