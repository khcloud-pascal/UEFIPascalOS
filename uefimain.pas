library uefimain;

{$MODE FPC}

uses uefi,tydqfs,console;

function efi_main(ImageHandle:efi_handle;systemtable:Pefi_system_table):efi_status;cdecl;[public,alias:'_DLLMainCRTStartup'];
var mystr,mystr2,mystr3,mystr4,writestr,partstr:PWideChar;
    status:efi_status;
    edl,eedl:efi_disk_list;
    i,realsize,mysize,tydqfscount,procnum:natuint;
    biop:Pefi_block_io_protocol;
    fsflist:tydqfs_file_list;
    mybool:boolean;
    fsa:tydqfs_attribute_bool;
    fsh:tydqfs_header;
    tfsd:tydqfs_data;
    fsi:tydqfs_system_info;
    fsiindex:natuint;
begin
 ParentImageHandle:=ImageHandle;
 efi_console_set_global_colour(Systemtable,efi_bck_black,efi_lightgrey);
 efi_console_clear_screen(systemtable);
 efi_console_get_max_row_and_max_column(systemtable,true);
 efi_console_enable_mouse(systemtable);
 efi_console_enable_mouse_blink(systemtable,true,500);
 efi_set_watchdog_timer_to_null(systemtable);
 efi_console_output_string(systemtable,'Welcome to TYDQ System!'#10);
 eedl:=efi_disk_empty_list(systemtable); 
 edl:=efi_disk_tydq_get_fs_list(systemtable);
 if(eedl.disk_count>0) and (edl.disk_count=0) then
  begin
   efi_console_output_string(systemtable,'Now you must format the empty disks to TYDQ File System formatted disks.'#10);
   efi_console_output_string(systemtable,'Empty disks without any File System in them:'#10); 
   for i:=1 to eedl.disk_count do
    begin
     efi_console_output_string(systemtable,'Empty disk ');
     partstr:=UintToPWChar(i);
     efi_console_output_string(systemtable,partstr);
     Wstrfree(partstr);
     efi_console_output_string(systemtable,' - ');
     biop:=(eedl.disk_block_content+i-1)^; realsize:=(biop^.Media^.LastBlock+1)*(biop^.Media^.BlockSize);
     efi_console_output_string(systemtable,'Size:');
     partstr:=ExtendedToPWChar(realsize/(1024*1024*1024),2);
     efi_console_output_string(systemtable,partstr);
     Wstrfree(partstr);
     efi_console_output_string(systemtable,'GiB'#10);
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
 freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
 freemem(eedl.disk_block_content); freemem(eedl.disk_content); eedl.disk_count:=0;
 edl:=efi_disk_tydq_get_fs_list(systemtable);
 fsi:=tydq_fs_systeminfo_read(systemtable,edl);
 if(fsi.header.tydqsyslang=0) then
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
     Wstrfree(mystr);
     while(procnum=0) or (procnum>edl.disk_count) do
      begin
       efi_console_output_string(systemtable,'Error:disk index is invaild for specify the system disk.'#10);
       efi_console_output_string(systemtable,'Enter the index of disk to specify the system disk:');
       efi_console_read_string(systemtable,mystr);
       procnum:=PWcharToUint(mystr);
       Wstrfree(mystr);
      end;
    end;
   tydq_fs_create_systeminfo_file(systemtable,edl,procnum);
  end;
 tydq_fs_systeminfo_free(fsi);
 freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
 edl:=efi_disk_tydq_get_fs_list(systemtable);
 efi_console_output_string(systemtable,'All available TYDQ file systems:'#13#10);
 for i:=1 to edl.disk_count do
  begin
   efi_console_output_string(systemtable,'TYDQ File System ');
   partstr:=UintToPWChar(i);
   efi_console_output_string(systemtable,UintToPWChar(i));
   Wstrfree(partstr);
   efi_console_output_string(systemtable,':'#13#10);
   fsh:=tydq_fs_read_header(edl,i);
   efi_console_output_string(systemtable,'File System Name:');
   efi_console_output_string(systemtable,@fsh.RootName);
   efi_console_output_string(systemtable,#13#10);
   efi_console_output_string(systemtable,'File System Size:');
   if(fsh.maxsize>=1024*1024*1024*1024) then
    begin
     partstr:=ExtendedToPWChar(fsh.maxsize/(1024*1024*1024*1024),2);
     efi_console_output_string(systemtable,partstr);
     efi_console_output_string(systemtable,'TiB'#10);
    end
   else 
    begin
     partstr:=ExtendedToPWChar(fsh.maxsize/(1024*1024*1024),2);
     efi_console_output_string(systemtable,partstr);
     efi_console_output_string(systemtable,'GiB'#10);
    end;
   Wstrfree(partstr);
   efi_console_output_string(systemtable,'File System Used Size:');
   if(fsh.usedsize>=1024*1024*1024*1024) then
    begin
     partstr:=ExtendedToPWChar(fsh.usedsize/(1024*1024*1024*1024),2);
     efi_console_output_string(systemtable,partstr);
     efi_console_output_string(systemtable,'TiB'#10);
    end
   else if(fsh.usedsize>=1024*1024*1024) then
    begin
     partstr:=ExtendedToPWChar(fsh.usedsize/(1024*1024*1024),2);
     efi_console_output_string(systemtable,partstr);
     efi_console_output_string(systemtable,'GiB'#10);
    end
   else if(fsh.usedsize>=1024*1024) then
    begin
     partstr:=ExtendedToPWChar(fsh.usedsize/(1024*1024),2);
     efi_console_output_string(systemtable,partstr);
     efi_console_output_string(systemtable,'MiB'#10);
    end
   else if(fsh.usedsize>=1024) then
    begin
     partstr:=ExtendedToPWChar(fsh.usedsize/1024,2);
     efi_console_output_string(systemtable,partstr);
     efi_console_output_string(systemtable,'KiB'#10);
    end
   else if(fsh.usedsize>=0) then
    begin
     partstr:=ExtendedToPWChar(fsh.usedsize,2);
     efi_console_output_string(systemtable,partstr);
     efi_console_output_string(systemtable,'B'#10);
    end;
   Wstrfree(partstr);
  end;
 fsi:=tydq_fs_systeminfo_read(systemtable,edl);
 if(fsi.header.tydqusercount>1) then
  begin
   efi_console_output_string(systemtable,'Accounts exist,Do you want to login(Y or y is yes,other is no)?'#10);
   efi_console_output_string(systemtable,'Your answer:');
   efi_console_read_string(systemtable,mystr);
   if((Wstrcmp(mystr,'Y')=0) or (WStrcmp(mystr,'y')=0)) and (WStrlen(mystr)=1) then
    begin
     efi_console_output_string(systemtable,'Enter your account name:');
     efi_console_read_string(systemtable,mystr);
     while(tydq_fs_systeminfo_get_index(fsi,mystr)<=1) do
      begin
       efi_console_output_string(systemtable,'Error:Typed user name does not exist.'#10);
       efi_console_output_string(systemtable,'Enter your account name:');
       efi_console_read_string(systemtable,mystr);
      end;
     mystr2:=tydq_fs_systeminfo_get_passwd(fsi,mystr);
     efi_console_output_string(systemtable,'Enter your account');
     efi_console_output_string(systemtable,mystr);
     efi_console_output_string(systemtable,#39's password:');
     efi_console_read_password_string(systemtable,mystr3);
     while(Wstrcmp(mystr2,mystr3)<>0) or (Wstrlen(mystr2)<>Wstrlen(mystr3)) do 
      begin
       efi_console_output_string(systemtable,'Error:Typed password is inaccurate.'#10);
       efi_console_output_string(systemtable,'Enter your account:');
       efi_console_output_string(systemtable,mystr);
       efi_console_output_string(systemtable,#39's password:');
       efi_console_read_password_string(systemtable,mystr3);
      end;
     efi_console_output_string(systemtable,'You successfully enter the TYDQ System!'#10);
     fsiindex:=tydq_fs_systeminfo_get_index(fsi,mystr);
     FreeMem(mystr3); FreeMem(mystr2); Freemem(mystr);
    end
   else
    begin
     efi_console_output_string(systemtable,'Now you can create a new account to enter TYDQ System.'#10);
     efi_console_output_string(systemtable,'Set your account name(Account name length must be 1-128):');
     efi_console_read_string(systemtable,mystr);
     while(Wstrlen(mystr)=0) or (Wstrlen(mystr)>128) or (tydq_fs_systeminfo_get_index(fsi,mystr)<>0) or (tydq_fs_legal_filename(mystr)=false) do
      begin
       if(Wstrlen(mystr)=0) or (Wstrlen(mystr)>128) then efi_console_output_string(systemtable,'Error:Account Name is invaild.'#10)
       else if(tydq_fs_systeminfo_get_index(fsi,mystr)<>0) then efi_console_output_string(systemtable,'Error:Account Name already exists.'#10)
       else if(tydq_fs_legal_filename(mystr)=false) then 
       efi_console_output_string(systemtable,'Error:Account name is illegal(space,* or ? is illegal character).'#10);
       efi_console_output_string(systemtable,'Set your account name(Account name length must be 1-128):');
       efi_console_read_string(systemtable,mystr);
      end;
     efi_console_output_string(systemtable,'Set your account password(Password length must be in 1-128):');
     efi_console_read_password_string(systemtable,mystr2);
     while(Wstrlen(mystr2)=0) or (Wstrlen(mystr2)>128) do
      begin
       efi_console_output_string(systemtable,'Error:Account password is invaild.'#10);
       efi_console_output_string(systemtable,'Set your account password(Password length must be in 1-128):');
       efi_console_read_password_string(systemtable,mystr2);
      end;
     efi_console_output_string(systemtable,'Verify your account password:');
     efi_console_read_password_string(systemtable,mystr3);
     while(Wstrcmp(mystr2,mystr3)<>0) or (WStrlen(mystr2)<>Wstrlen(mystr3)) do
      begin
       efi_console_output_string(systemtable,'Error:Typed password does not match your password.'#10);
       efi_console_output_string(systemtable,'Verify your account password:');
       efi_console_read_password_string(systemtable,mystr3);
      end;
     efi_console_output_string(systemtable,'The account you created will be normal user automatically.'#10);
     efi_console_output_string(systemtable,'Must have only one user manager in the system.');
     tydq_fs_systeminfo_add_user(fsi,mystr,mystr2,false);
     mysize:=getmemsize(mystr3)+getmemsize(mystr2)+getmemsize(mystr);
     tydq_fs_systeminfo_write(systemtable,edl,fsi);
     fsiindex:=tydq_fs_systeminfo_get_index(fsi,mystr);
     Wstrfree(mystr3); Wstrfree(mystr2); Wstrfree(mystr);
     fsi.userinfolist:=Pointer(Pointer(fsi.userinfolist)-mysize); 
     (fsi.userinfolist+fsi.header.tydqusercount-1)^.userpasswd:=Pointer(Pointer((fsi.userinfolist+fsi.header.tydqusercount-1)^.userpasswd)-mysize);
     (fsi.userinfolist+fsi.header.tydqusercount-1)^.username:=Pointer(Pointer((fsi.userinfolist+fsi.header.tydqusercount-1)^.username)-mysize);
     efi_console_output_string(systemtable,'Automatically enter the TYDQ System!'#10);
    end;
  end
 else if(fsi.header.tydqusercount>0) then 
  begin
   efi_console_output_string(systemtable,'Account exists,Do you want to login(Y or y is yes,other is no)?'#10);
   efi_console_output_string(systemtable,'Your answer:');
   efi_console_read_string(systemtable,mystr);
   if((Wstrcmp(mystr,'Y')=0) or (WStrcmp(mystr,'y')=0)) and (WStrlen(mystr)=1) then
    begin
     efi_console_output_string(systemtable,'Enter your account name:');
     efi_console_read_string(systemtable,mystr);
     while(tydq_fs_systeminfo_get_index(fsi,mystr)<=1) do
      begin
       efi_console_output_string(systemtable,'Error:Typed user name does not exist.'#10);
       efi_console_output_string(systemtable,'Enter your account name:');
       efi_console_read_string(systemtable,mystr);
      end;
     mystr2:=tydq_fs_systeminfo_get_passwd(fsi,mystr);
     efi_console_output_string(systemtable,'Enter your account ');
     efi_console_output_string(systemtable,mystr);
     efi_console_output_string(systemtable,#39's password:');
     efi_console_read_password_string(systemtable,mystr3);
     while(Wstrcmp(mystr2,mystr3)<>0) or (Wstrlen(mystr2)<>Wstrlen(mystr3)) do 
      begin
       efi_console_output_string(systemtable,'Error:Typed password is inaccurate.'#10);
       efi_console_output_string(systemtable,'Enter your account');
       efi_console_output_string(systemtable,mystr);
       efi_console_output_string(systemtable,#39's password:');
       efi_console_read_password_string(systemtable,mystr3);
      end;
     efi_console_output_string(systemtable,'You successfully enter the TYDQ System!'#10);
     fsiindex:=tydq_fs_systeminfo_get_index(fsi,mystr);
     FreeMem(mystr3); FreeMem(mystr2); Freemem(mystr);
    end
   else
    begin
     efi_console_output_string(systemtable,'Now you can create a new account to enter TYDQ System.'#10);
     efi_console_output_string(systemtable,'Set your account name(Account name length must be 1-128):');
     efi_console_read_string(systemtable,mystr);
     while(Wstrlen(mystr)=0) or (Wstrlen(mystr)>128) or (tydq_fs_systeminfo_get_index(fsi,mystr)<>0) or (tydq_fs_legal_filename(mystr)=false) do
      begin
       if(Wstrlen(mystr)=0) or (Wstrlen(mystr)>128) then efi_console_output_string(systemtable,'Error:Account Name is invaild.'#10)
       else if(tydq_fs_systeminfo_get_index(fsi,mystr)<>0) then efi_console_output_string(systemtable,'Error:Account Name already exists.'#10)
       else if(tydq_fs_legal_filename(mystr)=false) then 
       efi_console_output_string(systemtable,'Error:Account name is illegal(space,* or ? is illegal character).'#10);
       efi_console_output_string(systemtable,'Set your account name(Account name length must be 1-128):');
       efi_console_read_string(systemtable,mystr);
      end;
     efi_console_output_string(systemtable,'Set your account password(Password length must be in 1-128):');
     efi_console_read_password_string(systemtable,mystr2);
     while(Wstrlen(mystr2)=0) or (Wstrlen(mystr2)>128) do
      begin
       efi_console_output_string(systemtable,'Error:Account password is invaild.'#10);
       efi_console_output_string(systemtable,'Set your account password(Password length must be in 1-128):');
       efi_console_read_password_string(systemtable,mystr2);
      end;
     efi_console_output_string(systemtable,'Verify your account password:');
     efi_console_read_password_string(systemtable,mystr3);
     while(Wstrcmp(mystr2,mystr3)<>0) or (WStrlen(mystr2)<>Wstrlen(mystr3)) do
      begin
       efi_console_output_string(systemtable,'Error:Typed password does not match your password.'#10);
       efi_console_output_string(systemtable,'Verify your account password:');
       efi_console_read_password_string(systemtable,mystr3);
      end;
     efi_console_output_string(systemtable,'The account you created will be normal user automatically.'#10);
     efi_console_output_string(systemtable,'Must have only one user manager in the system.');
     tydq_fs_systeminfo_add_user(fsi,mystr,mystr2,false);
     mysize:=getmemsize(mystr3)+getmemsize(mystr2)+getmemsize(mystr);
     tydq_fs_systeminfo_write(systemtable,edl,fsi);
     fsiindex:=tydq_fs_systeminfo_get_index(fsi,mystr);
     Wstrfree(mystr3); Wstrfree(mystr2); Wstrfree(mystr);
     fsi.userinfolist:=Pointer(Pointer(fsi.userinfolist)-mysize);
     (fsi.userinfolist+fsi.header.tydqusercount-1)^.userpasswd:=Pointer(Pointer((fsi.userinfolist+fsi.header.tydqusercount-1)^.userpasswd)-mysize);
     (fsi.userinfolist+fsi.header.tydqusercount-1)^.username:=Pointer(Pointer((fsi.userinfolist+fsi.header.tydqusercount-1)^.username)-mysize);
     efi_console_output_string(systemtable,'Automatically enter the TYDQ System!'#10);
    end;
  end
 else if(fsi.header.tydqusercount=0) then
  begin
   efi_console_output_string(systemtable,'Account does not exist,you must create an account for you to enter the system.'#10);
   efi_console_output_string(systemtable,'Set your account name(Account name length must be 1-128):');
   efi_console_read_string(systemtable,mystr);
   while(Wstrlen(mystr)=0) or (Wstrlen(mystr)>128) or (tydq_fs_systeminfo_get_index(fsi,mystr)<>0) or (tydq_fs_legal_filename(mystr)=false) do
    begin
     if(Wstrlen(mystr)=0) or (Wstrlen(mystr)>128) then efi_console_output_string(systemtable,'Error:Account Name is invaild.'#10)
     else if(tydq_fs_systeminfo_get_index(fsi,mystr)<>0) then efi_console_output_string(systemtable,'Error:Account Name already exists.'#10)
     else if(tydq_fs_legal_filename(mystr)=false) then efi_console_output_string(systemtable,'Error:Account name is illegal(space,* or ? is illegal character).'#10);
     efi_console_output_string(systemtable,'Set your account name(Account name length must be 1-128):');
     efi_console_read_string(systemtable,mystr);
    end;
   efi_console_output_string(systemtable,'Set your account password(Password length must be in 1-128):');
   efi_console_read_password_string(systemtable,mystr2);
   while(Wstrlen(mystr2)=0) or (Wstrlen(mystr2)>128) do
    begin
     efi_console_output_string(systemtable,'Error:Account password is invaild.'#10);
     efi_console_output_string(systemtable,'Set your account password:');
     efi_console_read_password_string(systemtable,mystr2);
    end;
   efi_console_output_string(systemtable,'Verify your account password:');
   efi_console_read_password_string(systemtable,mystr3);
   while(Wstrcmp(mystr2,mystr3)<>0) or (WStrlen(mystr2)<>Wstrlen(mystr3)) do
    begin
     efi_console_output_string(systemtable,'Error:Typed password does not match your password.'#10);
     efi_console_output_string(systemtable,'Verify your account password:');
     efi_console_read_password_string(systemtable,mystr3);
    end;
   efi_console_output_string(systemtable,'The account you created will be user manager automatically.'#10);
   tydq_fs_systeminfo_add_user(fsi,mystr,mystr2,true);
   mysize:=getmemsize(mystr3)+getmemsize(mystr2)+getmemsize(mystr);
   tydq_fs_systeminfo_write(systemtable,edl,fsi);
   fsiindex:=tydq_fs_systeminfo_get_index(fsi,mystr);
   Wstrfree(mystr3); Wstrfree(mystr2); Wstrfree(mystr);
   fsi.userinfolist:=Pointer(Pointer(fsi.userinfolist)-mysize); 
   (fsi.userinfolist+fsi.header.tydqusercount-1)^.userpasswd:=Pointer(Pointer((fsi.userinfolist+fsi.header.tydqusercount-1)^.userpasswd)-mysize);
   (fsi.userinfolist+fsi.header.tydqusercount-1)^.username:=Pointer(Pointer((fsi.userinfolist+fsi.header.tydqusercount-1)^.username)-mysize);
   efi_console_output_string(systemtable,'Automatically enter the TYDQ System!'#10);
  end;
 procnum:=tydq_fs_systeminfo_disk_index(systemtable,edl);
 fsh:=tydq_fs_read_header(edl,procnum);
 fsiindex:=2;
 tydq_diskname_and_path_initialize;
 Wstrset(tydqcurrentdiskname,@fsh.RootName);
 Wstrset(tydqcurrentpath,'/');
 efi_console_output_string(systemtable,'Wait for 10 seconds to enter TYDQ system!'#10);
 SystemTable^.BootServices^.Stall(10000);
 efi_console_clear_screen(systemtable);
 efi_console_output_string(systemtable,'Type the commands to operate the TYDQ System(type help <command> for help!)'#10);
 efi_console_output_string(systemtable,'Warning:every commands need to have a space to deliter(However you can use " or '#39' to avoid this)!'#10);
 if(fsi.header.tydqgraphics=false) then console_main(systemtable,fsi,fsiindex);
 freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
 SystemTable^.RuntimeServices^.ResetSystem(EfiResetShutDown,efi_success,0,nil);
 efi_main:=efi_success;
end;

end.
