unit uefiinstaller;
interface

uses uefi;

function efi_main(ImageHandle:efi_handle;systemtable:Pefi_system_table):efi_status;cdecl;

implementation

function efi_main(ImageHandle:efi_handle;systemtable:Pefi_system_table):efi_status;cdecl;[public,alias:'efi_main'];
var mystr:PWideChar;
    cdindex,hdindex:natuint;
    i,realsize:natuint;
    status:efi_status;
    efsl:efi_file_system_list;
    efslext:efi_file_system_list_ext;
    efp:Pefi_file_protocol;
    efsi:efi_file_system_info;
    edl:efi_disk_list;
begin
 efi_console_set_global_colour(Systemtable,efi_bck_black,efi_lightgrey);
 efi_console_clear_screen(systemtable);
 efi_console_get_max_row_and_max_column(systemtable,false);
 efi_console_enable_mouse(systemtable);
 efi_console_enable_mouse_blink(systemtable,true,500);
 efslext:=efi_list_all_file_system_ext(systemtable);
 if(efslext.fsrwcount=0) then
 begin
  efsl:=efi_list_all_file_system(systemtable);
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
    efi_console_output_string(systemtable,UintToPWChar(efsi.VolumeSize+efsi.FreeSpace));
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
  efi_console_output_string(systemtable,'Stage 1 Install done!Now you can restart your installer to enter stage 2!'+#13#10);
  SystemTable^.RuntimeServices^.ResetSystem(EfiResetWarm,efi_success,0,nil);
 end
 else
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
     efi_console_output_string(systemtable,UintToPWChar(efsi.FreeSpace));
     efi_console_output_string(systemtable,#13#10);
    end;
   if(efslext.fsrwcount>0) then efi_console_output_string(systemtable,'Your HardDisk is:'+#13#10);
   for i:=1 to efslext.fsrwcount do
    begin
     ((efslext.fsrwcontent+i-1)^)^.OpenVolume((efslext.fsrwcontent+i-1)^,efp);
     realsize:=sizeof(efi_file_system_info);
     efp^.GetInfo(efp,@efi_file_system_info_id,realsize,efsi);
     efi_console_output_string(systemtable,'HardDisk ');
     efi_console_output_string(systemtable,UintToPWChar(i));
     efi_console_output_string(systemtable,' - ');
     efi_console_output_string(systemtable,UintToPWChar(efsi.FreeSpace));
     efi_console_output_string(systemtable,#13#10);
    end;
   cdindex:=1; hdindex:=1;
   if(efslext.fsrcount>1) then
    begin
     cdindex:=efslext.fsrcount+1;
     while (cdindex<efsl.file_system_count+1) do
      begin
       efi_console_output_string(systemtable,'Select the cdrom to install:');
       efi_console_read_string(systemtable,mystr);
       cdindex:=PWCharToUint(mystr);
       if(cdindex>=efslext.fsrcount) then efi_console_output_string(systemtable,'Error:Invaild Cdrom.'+#13#10);
      end;
    end;
   efi_install_cdrom_to_hard_disk_stage2(systemtable,efslext,cdindex,hdindex);
   efi_console_output_string(systemtable,'Stage 2 Install done!Now you can restart your installer to enter the system!'+#13#10);
   SystemTable^.RuntimeServices^.ResetSystem(EfiResetWarm,efi_success,0,nil);
  end;
 efi_main:=efi_success;
end;

end.
