library uefimain;

uses uefi,tydqfs;

function efi_main(ImageHandle:efi_handle;systemtable:Pefi_system_table):efi_status;cdecl;[public,alias:'_DLLMainCRTStartup'];
var mystr,writestr,partstr:PWideChar;
    status:efi_status;
    edl,eedl:efi_disk_list;
    i,realsize,tydqfscount,procnum:natuint;
    biop:Pefi_block_io_protocol;
    myfsh:tydqfs_header;
    fsflist:tydqfs_file_list;
    mybool:boolean;
    fsa:tydqfs_attribute_bool;
    fsh:tydqfs_header;
    tfsd:tydqfs_data;
begin
 efi_console_set_global_colour(Systemtable,efi_bck_black,efi_lightgrey);
 efi_console_clear_screen(systemtable);
 efi_console_get_max_row_and_max_column(systemtable,true);
 efi_console_enable_mouse(systemtable);
 efi_console_enable_mouse_blink(systemtable,true,500);
 efi_console_output_string(systemtable,'Welcome to TYDQ System!'+#13#10);
 eedl:=efi_disk_empty_list(systemtable); edl:=efi_disk_tydq_get_fs_list(systemtable);
 if(eedl.disk_count>0) and (edl.disk_count=0) then
  begin
   efi_console_output_string(systemtable,'Now you must format the empty disks to TYDQ File System formatted disks.'#13#10);
   efi_console_output_string(systemtable,'Empty disks without any File System in them:'#13#10); 
   for i:=1 to eedl.disk_count do
    begin
     efi_console_output_string(systemtable,'Empty disk ');
     efi_console_output_string(systemtable,UIntToPWChar(i));
     efi_console_output_string(systemtable,' - ');
     biop:=(eedl.disk_block_content+i-1)^; realsize:=(biop^.Media^.LastBlock+1)*(biop^.Media^.BlockSize);
     efi_console_output_string(systemtable,'Size:');
     efi_console_output_string(systemtable,UIntToPWChar(realsize));
     efi_console_output_string(systemtable,'Bytes'#13#10);
    end;
   efi_console_output_string(systemtable,'Type the count of empty disks you want to format:'); 
   efi_console_read_string(systemtable,mystr);
   procnum:=PWCharToUint(mystr);
   while(procnum=0) or (procnum>eedl.disk_count) do
    begin
     efi_console_output_string(systemtable,'Error:The count of empty disks you want to format is invaild.'#13#10); 
     efi_console_output_string(systemtable,'Type the count of empty disks you want to format:'); 
     efi_console_read_string(systemtable,mystr);
     procnum:=PWCharToUint(mystr);
    end;
   tydqfscount:=procnum;
   while(tydqfscount>0) do
    begin
     efi_console_output_string(systemtable,'Select the Disk to format it to TYDQ File System:');
     efi_console_read_string(systemtable,mystr);
     procnum:=PWCharToUint(mystr);
     while(procnum=0) or (procnum>eedl.disk_count) or (tydq_fs_disk_is_formatted(eedl,procnum)=true) do
      begin
       if(procnum=0) or (procnum>eedl.disk_count) then
        begin
         efi_console_output_string(systemtable,'Error:typed disk index is invaild.'#13#10);
        end
       else if(tydq_fs_disk_is_formatted(eedl,procnum)=true) then
        begin
         efi_console_output_string(systemtable,'Error:disk is already formatted.'#13#10);
        end;
       efi_console_output_string(systemtable,'Select the Disk to format it to TYDQ File System:');
       efi_console_read_string(systemtable,mystr);
       procnum:=PWCharToUint(mystr);
      end;
     efi_console_output_string(systemtable,'Type the Disk'#39's Name:');
     efi_console_read_string(systemtable,mystr);
     while(tydq_fs_disk_exists(eedl,mystr)=true) do
      begin
       efi_console_output_string(systemtable,'Error:root name already exists.'#13#10);
       efi_console_output_string(systemtable,'Type the Disk'#39's Name:');
       efi_console_read_string(systemtable,mystr);
      end;
     tydq_fs_initialize(eedl,procnum,mystr);
     dec(tydqfscount);
    end;
  end;
 Wstrfree(mystr);
 if(tydq_fs_systeminfo_read(systemtable,edl).header.tydqsyslang=0) then
  begin
   efi_console_output_string(systemtable,'All available TYDQ file systems to be specified to system disk:'#13#10);
   for i:=1 to edl.disk_count do
    begin
     efi_console_output_string(systemtable,'Disk ');
     partstr:=UintToPWchar(i);
     efi_console_output_string(systemtable,partstr);
     Wstrfree(partstr);
     efi_console_output_string(systemtable,'-');
     fsh:=tydq_fs_read_header(edl,i);
     efi_console_output_string(systemtable,@fsh.RootName);
     efi_console_output_string(systemtable,#13#10);
    end;
   if(edl.disk_count=1) then procnum:=1 else
    begin
     efi_console_output_string(systemtable,'Enter the index of disk to specify the system disk:');
     efi_console_read_string(systemtable,mystr);
     procnum:=PWcharToUint(mystr);
     while(procnum=0) or (procnum>edl.disk_count) do
      begin
       efi_console_output_string(systemtable,'Error:disk index is invaild for specify the system disk.'#10);
       efi_console_output_string(systemtable,'Enter the index of disk to specify the system disk:');
       efi_console_read_string(systemtable,mystr);
       procnum:=PWcharToUint(mystr);
      end;
    end;
   tydq_fs_create_systeminfo_file(systemtable,edl,procnum);
  end;
 freemem(eedl.disk_content); freemem(eedl.disk_block_content); eedl.disk_count:=0;
 freemem(edl.disk_content); freemem(edl.disk_block_content); edl.disk_count:=0;
 Wstrfree(mystr);
 edl:=efi_disk_tydq_get_fs_list(systemtable);
 efi_console_output_string(systemtable,'All available TYDQ file systems:'#13#10);
 for i:=1 to edl.disk_count do
  begin
   efi_console_output_string(systemtable,'TYDQ File System ');
   efi_console_output_string(systemtable,UintToPWChar(i));
   efi_console_output_string(systemtable,':'#13#10);
   myfsh:=tydq_fs_read_header(edl,i);
   efi_console_output_string(systemtable,'File System Name:');
   efi_console_output_string(systemtable,@myfsh.RootName);
   efi_console_output_string(systemtable,#13#10);
   efi_console_output_string(systemtable,'File System Size:');
   efi_console_output_string(systemtable,UintToPWChar(myfsh.maxsize));
   efi_console_output_string(systemtable,#13#10);
   efi_console_output_string(systemtable,'File System Used Size:');
   efi_console_output_string(systemtable,UintToPWChar(myfsh.usedsize));
   efi_console_output_string(systemtable,#13#10);
  end;
 efi_console_output_string(systemtable,'Type the commands to operate the TYDQ System(-h or --help for help!)'#13#10);
 tydq_fs_create_file(systemtable,edl,1,'/System/Password.dqi',tydqfs_normal_file,userlevel_system);
 mybool:=tydq_fs_file_exists(edl,1,'/System/Password.dqi');
 efi_console_output_string(systemtable,UintTOPWChar(tydq_fs_file_position(edl,1,'/System/Password.dqi')));
 efi_console_output_string(systemtable,#13#10);
 efi_console_output_string(systemtable,'Program Terminated......'#13#10);
 while(True) do;
 efi_main:=efi_success;
end;

end.
