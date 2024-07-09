unit console;

interface

{$MODE FPC}

uses tydqfs,uefi,shell;

type cmdpartstr=record
                partstrnum:natuint;
                partstrlist:^PWideChar;
                end;
     cmdshellline=record
                   shellline:^PWideChar;
                   shelllinecount:natuint;
                   end;  
procedure console_main(systemtable:Pefi_system_table;var sysinfo:tydqfs_system_info;var sysindex:natuint);
procedure console_command_parser(systemtable:Pefi_system_table;var sysinfo:tydqfs_system_info;var sysindex:natuint;cmdstr:PWideChar);
procedure console_initialize(systemtable:Pefi_system_table;sysinfo:tydqfs_system_info;sysindex:natuint);

implementation

procedure console_main(systemtable:Pefi_system_table;var sysinfo:tydqfs_system_info;var sysindex:natuint);[public,alias:'console_main'];
var cmdstr,partstr,partstr2,partstr3:PWideChar;
    edl:efi_disk_list;
    fsh:tydqfs_header;
    procnum:natuint;
begin
 console_initialize(systemtable,sysinfo,sysindex);
 while(True) do
  begin
   efi_console_output_string(systemtable,(sysinfo.userinfolist+sysindex-2)^.username);
   efi_console_output_string(systemtable,'@');
   efi_console_output_string(systemtable,'TYDQSystem:');
   edl:=efi_disk_tydq_get_fs_list(systemtable);
   procnum:=tydq_fs_systeminfo_disk_index(systemtable,edl);
   fsh:=tydq_fs_read_header(edl,procnum);
   if(Wstrcmp(@fsh.RootName,tydqcurrentdiskname)<>0) or (Wstrlen(@fsh.RootName)<>Wstrlen(tydqcurrentdiskname)) then   
    begin
     efi_console_output_string(systemtable,tydqcurrentdiskname);
    end;
   Wstrinit(partstr,256); Wstrset(partstr,'/usrsp/'); Wstrcat(partstr,(sysinfo.userinfolist+sysindex-2)^.username);
   if(Wstrlen(partstr)<=Wstrlen(tydqcurrentpath)) then partstr3:=Wstrcutout(tydqcurrentpath,1,Wstrlen(partstr)) else partstr3:=tydqcurrentpath;
   if(Wstrcmp(partstr,partstr3)=0) and (Wstrlen(partstr)<=Wstrlen(tydqcurrentpath)) then
    begin
     partstr2:=Wstrcutout(tydqcurrentpath,Wstrlen(partstr)+2,Wstrlen(tydqcurrentpath));
     efi_console_output_string(systemtable,'~');
     procnum:=Wstrpos(partstr2,'/',1);
     if(procnum>0) then
      begin
       efi_console_output_string(systemtable,'/');
      end;
     efi_console_output_string(systemtable,partstr2);
     Wstrfree(partstr2);
    end
   else
    begin
     efi_console_output_string(systemtable,tydqcurrentpath);
    end;
   Wstrfree(partstr3);
   Wstrfree(partstr);
   efi_console_output_string(systemtable,'$');
   efi_console_read_string(systemtable,cmdstr);
   console_command_parser(systemtable,sysinfo,sysindex,cmdstr);
   freemem(cmdstr); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
  end;
end;
procedure console_command_parser(systemtable:Pefi_system_table;var sysinfo:tydqfs_system_info;var sysindex:natuint;cmdstr:PWideChar);[public,alias:'console_command_parser'];
var cpstr:cmdpartstr;
    procnum,procnum2,procnum3,procnum4,procnum5,procnum6:natuint;
    attributes:byte;
    i,j,partstart,partlen,len,size:natuint;
    partstr,partstr2,partstr3,partstr4,partstr5,partstr6,partstr7:PWideChar;
    inputstr1,inputstr2,inputstr3:PWideChar;
    ismanager,isstring,haveextraparam,shared,fileexists,detecthidden,judgehidden:boolean;
    {for executable operation only}
    relocationshow,stringtableshow,symboltableshow,hashtableshow,sectionshowall:boolean;
    sectionshow:^natuint;
    sectionshownum:natuint;
    {executable operation ended}
    edl:efi_disk_list;
    fsh:tydqfs_header;
    fsf:tydqfs_file;
    fsfl:tydqfs_file_list;
    data:tydqfs_data;
    fse:tydqfs_file_executable;
    {for executable parameter only}
    param:tydqfs_file_executable_parameter;
    isexecuted,bool:boolean;
    {parameter ended}
begin
 len:=Wstrlen(cmdstr); cpstr.partstrnum:=0; partstart:=0; partlen:=0; isstring:=false;
 for i:=1 to len do
  begin
   if(partlen=0) and ((cmdstr+i-1)^=#39) then isstring:=true
   else if(partlen=0) and ((cmdstr+i-1)^='"') then isstring:=true
   else if(partlen>0) and ((cmdstr+i-1)^=#39) then isstring:=false
   else if(partlen>0) and ((cmdstr+i-1)^='"') then isstring:=false;
   if(i=len) and (isstring=true) then isstring:=false;
   if(partlen=0) and ((cmdstr+i-1)^<>' ') and (partstart=0) then
    begin
     partstart:=i; inc(partlen);
    end
   else if((partlen>0) and ((cmdstr+i-1)^=' ') and (isstring=false)) or (i=len) then
    begin
     if(i=len) and ((cmdstr+i-1)^<>' ') then inc(partlen);
     inc(cpstr.partstrnum);
     size:=getmemsize(cpstr.partstrlist);
     ReallocMem(cpstr.partstrlist,sizeof(PWideChar)*cpstr.partstrnum);
     if(cpstr.partstrnum>1) then
     (cpstr.partstrlist+cpstr.partstrnum-2)^:=PWideChar(Pointer((cpstr.partstrlist+cpstr.partstrnum-2)^)-size);
     if((cmdstr+i-1)^='"') or ((cmdstr+i-1)^=#39) then
      begin
       Wstrinit((cpstr.partstrlist+cpstr.partstrnum-1)^,partlen-2);
       partstr:=Wstrcopy(cmdstr,partstart+1,partlen-2);
       Wstrset((cpstr.partstrlist+cpstr.partstrnum-1)^,partstr);
      end
     else
      begin
       Wstrinit((cpstr.partstrlist+cpstr.partstrnum-1)^,partlen);
       partstr:=Wstrcopy(cmdstr,partstart,partlen);
       Wstrset((cpstr.partstrlist+cpstr.partstrnum-1)^,partstr);
      end;
     freemem(partstr);
     partstart:=0;
     partlen:=0;
    end
   else if(partstart>0) or (isstring=true) then
    begin
     inc(partlen);
    end;
  end; 
 if(cpstr.partstrnum=0) or (len=0) then
  begin
   efi_console_output_string(systemtable,'Please enter the command to operate the system!'#10);
   exit;
  end;
 ismanager:=sysindex=tydq_fs_systeminfo_get_manager_index(sysinfo);
 if(Wstrcmp(cpstr.partstrlist^,'sp')=0) and (Wstrlen(cpstr.partstrlist^)=2) and (ismanager=true) then
  begin
   if(cpstr.partstrnum<=1) then
    begin
     efi_console_output_string(systemtable,'sp must have one vaild command!'#10);
     for i:=cpstr.partstrnum downto 1 do
      begin
       Wstrfree((cpstr.partstrlist+i-1)^);
      end;
     freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
     exit;
    end;
   if(Wstrcmp((cpstr.partstrlist+1)^,'reboot')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
    begin
     if(cpstr.partstrnum=2) then
      begin
       efi_console_output_string(systemtable,'The system will reboot in 20 seconds!'#10);
       Wstrfree(tydqcurrentpath); Wstrfree(tydqcurrentdiskname);
       SystemTable^.BootServices^.Stall(20000);
       SystemTable^.RuntimeServices^.ResetSystem(EfiResetWarm,efi_success,0,nil);
      end
     else if(cpstr.partstrnum>2) then
      begin
       efi_console_output_string(systemtable,'reboot doesn'#39't need any parameters!'#10);
      end;
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'shutdown')=0) and (Wstrlen((cpstr.partstrlist+1)^)=8) then
    begin
     if(cpstr.partstrnum=2) then
      begin
       efi_console_output_string(systemtable,'The system will shut down in 20 seconds!'#10);
       Wstrfree(tydqcurrentpath); Wstrfree(tydqcurrentdiskname);
       SystemTable^.BootServices^.Stall(20000);
       SystemTable^.RuntimeServices^.ResetSystem(EfiResetShutDown,efi_success,0,nil);
      end
     else if(cpstr.partstrnum>2) then
      begin
       efi_console_output_string(systemtable,'shutdown doesn'#39't need any parameter!'#10);
      end;
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'echo')=0) and (Wstrlen((cpstr.partstrlist+1)^)=4) then
    begin
     if(cpstr.partstrnum=3) then
      begin
       partstr:=Wstrcutout((cpstr.partstrlist+2)^,1,Wstrlen((cpstr.partstrlist+2)^));
       efi_console_output_string(systemtable,partstr);
       Wstrfree(partstr);
       efi_console_output_string(systemtable,#10);
      end
     else
      begin
       efi_console_output_string(systemtable,'echo doesn'#39't need two or more parameters or no parameter!'#10);
      end;
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'delay')=0) and (Wstrlen((cpstr.partstrlist+1)^)=5) then
    begin
     if(cpstr.partstrnum<>3) then
      begin
       efi_console_output_string(systemtable,'delay must have one parameter!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     partstr:=Wstrcutout((cpstr.partstrlist+2)^,1,Wstrlen((cpstr.partstrlist+2)^)-1);
     partstr2:=Wstrcopy((cpstr.partstrlist+2)^,Wstrlen((cpstr.partstrlist+2)^),1);
     if(Wstrlen(partstr2)>1) then
      begin
       efi_console_output_string(systemtable,'The specified time unit must be h(hour) or m(minute) or s(second),not other units!'#10);
       Wstrfree(partstr2); Wstrfree(partstr); 
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end
     else if(PWCharIsInt(partstr)=false) then 
      begin
       efi_console_output_string(systemtable,'The specified time value must to be decimal number!'#10);
       Wstrfree(partstr2); Wstrfree(partstr);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     if(partstr2^='h') then
      begin
       procnum:=PWCharToUint(partstr)*3600;
      end
     else if(partstr2^='m') then
      begin
       procnum:=PWCharToUint(partstr)*60;
      end
     else if(partstr2^='s') then
      begin
       procnum:=PWCharToUint(partstr);
      end
     else
      begin
       efi_console_output_string(systemtable,'The specified time unit must be h(hour) or m(minute) or s(second),not other units!'#10);
       Wstrfree(partstr2);
       Wstrfree(partstr);
       exit;
      end;
     SystemTable^.BootServices^.Stall(procnum*1000);
     Wstrfree(partstr2);
     Wstrfree(partstr);
    end
   else if(WStrcmp((cpstr.partstrlist+1)^,'file')=0) and (Wstrlen((cpstr.partstrlist+1)^)=4) then
    begin
     if(cpstr.partstrnum<=3) then
      begin
       efi_console_output_string(systemtable,'file must have one vaild command!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     if(Wstrcmp((cpstr.partstrlist+2)^,'create')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
      begin
       if(cpstr.partstrnum>4) then
        begin
         efi_console_output_string(systemtable,'file create must have one path and at least one type!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       if(tydq_fs_legal_filename(partstr5)) and (tydq_fs_legal_length_filename(partstr5)) then
        begin
         attributes:=0; shared:=false; Wstrfree(partstr5);
         for j:=5 to cpstr.partstrnum do
          begin
           if(Wstrcmp((cpstr.partstrlist+j-1)^,'folder')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_folder; 
            end
           else if(Wstrcmp((cpstr.partstrlist+j-1)^,'normal')=0) and (WStrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_normal_file; 
            end
           else if(WStrcmp((cpstr.partstrlist+j-1)^,'system')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_system_file; 
            end
           else if(WStrcmp((cpstr.partstrlist+j-1)^,'hidden')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_hidden_file; 
            end
           else if(WStrcmp((cpstr.partstrlist+j-1)^,'link')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=4) then
            begin
             attributes:=attributes or tydqfs_link_file; 
            end
           else if(Wstrcmp((cpstr.partstrlist+j-1)^,'text')=0) and (WStrlen((cpstr.partstrlist+j-1)^)=4) then
            begin
             attributes:=attributes or tydqfs_text_file; 
            end
           else if(Wstrcmp((cpstr.partstrlist+j-1)^,'binary')=0) and (WStrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_binary_file; 
            end
           else if(Wstrcmp((cpstr.partstrlist+j-1)^,'shared')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             shared:=true;
            end;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=true) then
          begin
           efi_console_output_string(systemtable,'Error:A file could not to be both normal file and system file.'#10);
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=false) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=false) then
          begin
           efi_console_output_string(systemtable,'Error:A file must be a normal file or system file.'#10);
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         procnum:=0;
         if(tydq_fs_byte_to_attribute_bool(attributes)[8]=true) then procnum:=1;
         for j:=4 downto 1 do if(tydq_fs_byte_to_attribute_bool(attributes)[j]=true) then inc(procnum);
         if(procnum>1) and (procnum=0) then
          begin
           efi_console_output_string(systemtable,'Error:A file could not be two or more main type or no type.'#10);
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         tydq_fs_create_file(systemtable,edl,procnum,partstr,attributes,userlevel_system,1);
         if(tydq_fs_byte_to_attribute_bool(attributes)[4]=true) then 
          begin
           efi_console_output_string(systemtable,'Type the path you want to link to:');
           efi_console_read_string(systemtable,partstr2);
           partstr6:=tydq_fs_locate_fullpath(edl,partstr2);
           procnum2:=tydq_fs_locate_diskindex(edl,partstr2);
           while(tydq_fs_file_exists(edl,procnum,partstr6)=false) do
            begin
             efi_console_output_string(systemtable,'Error:file linked does not exist.'#10);
             efi_console_output_string(systemtable,'Type the path you want to link to:');
             efi_console_read_string(systemtable,partstr2);
             partstr6:=tydq_fs_locate_fullpath(edl,partstr2);
             procnum2:=tydq_fs_locate_diskindex(edl,partstr2);
            end;
           fsh:=tydq_fs_read_header(edl,procnum2);
           Wstrinit(partstr,16640); Wstrset(partstr,@fsh.RootName); Wstrcat(partstr,'/'); Wstrcat(partstr,partstr6);
           if(shared) then tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr)+1)*2,userlevel_system,1)
           else tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr)+1)*2,userlevel_system,0);
           Wstrfree(partstr6);
          end;
         Wstrfree(partstr5);
         freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
        end
       else
        begin
         if(tydq_fs_legal_filename(partstr5)=false) then
         efi_console_output_string(systemtable,'Error:file name is illegal(?,*,$,{,},(,),@,#,^ or % are illegal).'#10)
         else if(tydq_fs_legal_length_filename(partstr5)=false) then
         efi_console_output_string(systemtable,'Error:file name length is illegal(length must not exceed 255 and lower to 0).'#10);
         Wstrfree(partstr5);
         freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'list')=0) and (WStrlen((cpstr.partstrlist+2)^)=4) then
      begin
       if(cpstr.partstrnum<>3) and (cpstr.partstrnum<>4) and (cpstr.partstrnum<>5) then
        begin
         efi_console_output_string(systemtable,'file list must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       haveextraparam:=false; 
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       if(cpstr.partstrnum=5) then 
        begin
         partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
         procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
         if(Wstrcmp((cpstr.partstrlist+4)^,'detecthidden')=0) and (Wstrlen((cpstr.partstrlist+4)^)=12) then
          begin
           haveextraparam:=true;
          end;
        end
       else if(cpstr.partstrnum=4) then
        begin
         if(Wstrcmp((cpstr.partstrlist+3)^,'detecthidden')=0) and (Wstrlen((cpstr.partstrlist+3)^)=12) then
          begin
           haveextraparam:=true;
          end
         else
          begin
           partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
           procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
          end;
        end
       else if(cpstr.partstrnum=3) then
        begin
         partstr5:=tydq_fs_locate_fullpath(edl,nil);
         procnum:=tydq_fs_locate_diskindex(edl,nil);
        end;
       fsfl:=tydq_fs_list_file(edl,procnum,partstr5,false,haveextraparam,1);
       for i:=1 to fsfl.files_count do 
        begin
         partstr4:=tydq_combine_path_and_filename((fsfl.files_basepath+i-1)^,(fsfl.files_content+i-1)^);
         efi_console_output_string(systemtable,partstr4);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr4);
        end;
      size:=0;
       for i:=fsfl.files_count downto 1 do
        begin
         if(i<fsfl.files_count) then size:=size+getmemsize((fsfl.files_content+i-1)^)+getmemsize((fsfl.files_basepath+i-1)^);
         Wstrfree((fsfl.files_content+i-1)^); Wstrfree((fsfl.files_basepath+i-1)^);
        end;
       fsfl.files_content:=fsfl.files_content-size; fsfl.files_basepath:=fsfl.files_content-size;
       freemem(fsfl.files_content); freemem(fsfl.files_basepath); fsfl.files_count:=0;
       Wstrfree(partstr3); Wstrfree(partstr2); Wstrfree(partstr); Wstrfree(partstr5);
       freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'tree')=0) and (WStrlen((cpstr.partstrlist+2)^)=4) then
      begin
       if(cpstr.partstrnum<>3) and (cpstr.partstrnum<>4) and (cpstr.partstrnum<>5) then
        begin
         efi_console_output_string(systemtable,'file tree must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       haveextraparam:=false; 
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       if(cpstr.partstrnum=5) then 
        begin
         partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
         procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
         if(Wstrcmp((cpstr.partstrlist+4)^,'detecthidden')=0) and (Wstrlen((cpstr.partstrlist+4)^)=12) then
          begin
           haveextraparam:=true;
          end;
        end
       else if(cpstr.partstrnum=4) then
        begin
         if(Wstrcmp((cpstr.partstrlist+3)^,'detecthidden')=0) and (Wstrlen((cpstr.partstrlist+3)^)=12) then
          begin
           haveextraparam:=true;
          end
         else
          begin
           partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
           procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
          end;
        end
       else if(cpstr.partstrnum=3) then
        begin
         partstr5:=tydq_fs_locate_fullpath(edl,nil);
         procnum:=tydq_fs_locate_diskindex(edl,nil);
        end;
       if(Wstrcmp((cpstr.partstrlist+4)^,'detecthidden')=0) and (Wstrlen((cpstr.partstrlist+3)^)=12) then
        begin
         haveextraparam:=true;
        end;
       fsfl:=tydq_fs_list_file(edl,procnum,partstr5,true,haveextraparam,1);
       for i:=1 to fsfl.files_count do 
        begin
         partstr4:=tydq_combine_path_and_filename((fsfl.files_basepath+i-1)^,(fsfl.files_content+i-1)^);
         efi_console_output_string(systemtable,partstr4);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr4);
        end;
       size:=0;
       for i:=fsfl.files_count downto 1 do
        begin
         if(i<fsfl.files_count) then size:=size+getmemsize((fsfl.files_content+i-1)^)+getmemsize((fsfl.files_basepath+i-1)^);
         Wstrfree((fsfl.files_content+i-1)^); Wstrfree((fsfl.files_basepath+i-1)^);
        end;
       fsfl.files_content:=fsfl.files_content-size; fsfl.files_basepath:=fsfl.files_content-size;
       freemem(fsfl.files_content); freemem(fsfl.files_basepath); fsfl.files_count:=0;
       Wstrfree(partstr3); Wstrfree(partstr2); Wstrfree(partstr); Wstrfree(partstr5);
       freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'info')=0) and (Wstrlen((cpstr.partstrlist+2)^)=4) then
      begin
       if(cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file info must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_disk_index(edl,(cpstr.partstrlist+3)^);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_system,1);
       if(tydq_fs_file_exists(edl,procnum,(cpstr.partstrlist+3)^)=false) then
        begin
         efi_console_output_string(systemtable,'Error:File does not exist.'#10);
        end
       else if(fsf.fattribute=0) then
        begin
         efi_console_output_string(systemtable,'Error:File could not be accessed.'#10);
        end
       else 
        begin
         efi_console_output_string(systemtable,'File ');
         efi_console_output_string(systemtable,@fsf.fName);
         efi_console_output_string(systemtable,':'#10);
         efi_console_output_string(systemtable,'Attribute:');
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) then
          begin
           efi_console_output_string(systemtable,'Folder ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[7]=true) then
          begin
           efi_console_output_string(systemtable,'Normal ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) then
          begin
           efi_console_output_string(systemtable,'System ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[5]=true) then
          begin
           efi_console_output_string(systemtable,'Hidden ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[4]=true) then
          begin
           efi_console_output_string(systemtable,'Link ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[3]=true) then
          begin
           efi_console_output_string(systemtable,'Text ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[2]=true) then
          begin
           efi_console_output_string(systemtable,'Binary ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[1]=true) then
          begin
           efi_console_output_string(systemtable,'Executable ');
          end;
         efi_console_output_string(systemtable,#10);
         efi_console_output_string(systemtable,'The file belongs to:');
         if(fsf.fbelonguserindex=0) then
          begin
           efi_console_output_string(systemtable,'Shared'#10);
          end
         else if(fsf.fbelonguserindex=1) then
          begin
           efi_console_output_string(systemtable,'System'#10);
          end
         else if(fsf.fbelonguserindex=2) then
          begin
           efi_console_output_string(systemtable,(sysinfo.userinfolist+fsf.fbelonguserindex-2)^.username);
           efi_console_output_string(systemtable,#10);
          end;
         efi_console_output_string(systemtable,'Created Time:');
         partstr:=tydq_time_to_string(fsf.fcreatetime);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr);
         efi_console_output_string(systemtable,'Last Edit Time:');
         partstr:=tydq_time_to_string(fsf.flastedittime);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr);
        end;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'copy')=0) and (Wstrlen((cpstr.partstrlist+2)^)=4) then
      begin
       if(cpstr.partstrnum<>5) then
        begin
         efi_console_output_string(systemtable,'file copy must have only two paths!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       partstr7:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+4)^);
       procnum5:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+4)^);
       procnum3:=Wstrpos(partstr5,'*',1); procnum4:=Wstrpos(partstr5,'?',1);
       if(procnum4>0) and (procnum3>procnum4) then procnum2:=Wstrposdir(partstr5,'/',procnum4,-1)
       else if(procnum3>0) and (procnum4>procnum3) then procnum2:=Wstrposdir(partstr5,'/',procnum3,-1)
       else if(procnum4>0) and (procnum3=0) then procnum2:=Wstrposdir(partstr5,'/',procnum4,-1)
       else if(procnum3>0) and (procnum4=0) then procnum2:=Wstrposdir(partstr5,'/',procnum3,-1)
       else procnum2:=Wstrposdir(partstr5,'/',Wstrlen(partstr5),-1);
       if(procnum2=1) then partstr6:=Wstrcutout(partstr5,1,1) else partstr6:=Wstrcutout(partstr5,1,procnum2-1);
       if(Wstrcmp((cpstr.partstrlist+4)^,'judgehidden')=0) and (Wstrlen((cpstr.partstrlist+4)^)=11) then judgehidden:=true else judgehidden:=false;
       fsfl:=tydq_fs_list_file(edl,procnum,partstr6,false,judgehidden,1);
       for i:=1 to fsfl.files_count do 
        begin
         partstr4:=tydq_combine_path_and_filename((fsfl.files_basepath+i-1)^,(fsfl.files_content+i-1)^);
         if(PWCharMatchMask(partstr4,partstr5)) then 
          begin
           fsf:=tydq_fs_file_info(edl,procnum,partstr4,userlevel_system,1);
           Wstrinit(partstr,16384);
           procnum6:=Wstrposdir(partstr4,'/',Wstrlen(partstr4),-1);
           partstr2:=Wstrcutout(partstr4,procnum6+1,Wstrlen(partstr4));
           Wstrset(partstr,partstr7); Wstrcat(partstr,partstr2);
           if(fsf.fbelonguserindex=0) then
           tydq_fs_create_file(systemtable,edl,procnum5,partstr,fsf.fattribute,userlevel_system,0)
           else if(fsf.fbelonguserindex=1) then
           tydq_fs_create_file(systemtable,edl,procnum5,partstr,fsf.fattribute,userlevel_system,1)
           else if(fsf.fbelonguserindex=sysindex) then
           tydq_fs_create_file(systemtable,edl,procnum5,partstr,fsf.fattribute,userlevel_system,fsf.fbelonguserindex);
           data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_system,1);
           tydq_fs_file_rewrite(systemtable,edl,procnum5,partstr,data.fsdata,data.fssize,userlevel_system,1);
           freemem(data.fsdata); data.fssize:=0; Wstrfree(partstr2); Wstrfree(partstr);
          end;
         Wstrfree(partstr4);
        end;
       size:=0;
       for i:=fsfl.files_count downto 1 do
        begin
         if(i<fsfl.files_count) then size:=size+getmemsize((fsfl.files_content+i-1)^)+getmemsize((fsfl.files_basepath+i-1)^);
         Wstrfree((fsfl.files_content+i-1)^); Wstrfree((fsfl.files_basepath+i-1)^);
        end;
       fsfl.files_content:=fsfl.files_content-size; fsfl.files_basepath:=fsfl.files_content-size;
       freemem(fsfl.files_content); freemem(fsfl.files_basepath); fsfl.files_count:=0;
       Wstrfree(partstr6); Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'delete')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
      begin
       if(cpstr.partstrnum<>4) and (cpstr.partstrnum<>5) then
        begin
         efi_console_output_string(systemtable,'file delete must have only one path or one path and one switch!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       procnum3:=Wstrpos(partstr5,'*',1); procnum4:=Wstrpos(partstr5,'?',1);
       if(procnum4>0) and (procnum3>procnum4) then procnum2:=Wstrposdir(partstr5,'/',procnum4,-1)
       else if(procnum3>0) and (procnum4>procnum3) then procnum2:=Wstrposdir(partstr5,'/',procnum3,-1)
       else if(procnum4>0) and (procnum3=0) then procnum2:=Wstrposdir(partstr5,'/',procnum4,-1)
       else if(procnum3>0) and (procnum4=0) then procnum2:=Wstrposdir(partstr5,'/',procnum3,-1)
       else procnum2:=Wstrposdir(partstr5,'/',Wstrlen(partstr5),-1);
       if(procnum2=1) then partstr6:=Wstrcutout(partstr5,1,1) else partstr6:=Wstrcutout(partstr5,1,procnum2-1);
       if(Wstrcmp((cpstr.partstrlist+4)^,'judgehidden')=0) and (Wstrlen((cpstr.partstrlist+4)^)=11) then judgehidden:=true else judgehidden:=false;
       fsfl:=tydq_fs_list_file(edl,procnum,partstr6,false,judgehidden,1);
       for i:=1 to fsfl.files_count do 
        begin
         partstr4:=tydq_combine_path_and_filename((fsfl.files_basepath+i-1)^,(fsfl.files_content+i-1)^);
         if(PWCharMatchMask(partstr4,partstr5)) then tydq_fs_delete_file(edl,procnum,partstr4,userlevel_system,1);
         Wstrfree(partstr4);
        end;
       size:=0;
       for i:=fsfl.files_count downto 1 do
        begin
         if(i<fsfl.files_count) then size:=size+getmemsize((fsfl.files_content+i-1)^)+getmemsize((fsfl.files_basepath+i-1)^);
         Wstrfree((fsfl.files_content+i-1)^); Wstrfree((fsfl.files_basepath+i-1)^);
        end;
       fsfl.files_content:=fsfl.files_content-size; fsfl.files_basepath:=fsfl.files_content-size;
       freemem(fsfl.files_content); freemem(fsfl.files_basepath); fsfl.files_count:=0;
       Wstrfree(partstr6); Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'exist')=0) and (Wstrlen((cpstr.partstrlist+2)^)=5) then
      begin
       if(cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file exist must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       fileexists:=tydq_fs_file_exists(edl,procnum,partstr5);
       if(fileexists) then efi_console_output_string(systemtable,'File exists!'#10) else efi_console_output_string(systemtable,'File does not exist!'#10);
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'edit')=0) and (Wstrlen((cpstr.partstrlist+2)^)=4) then
      begin
       if(cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file edit must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       if(tydq_fs_file_exists(edl,procnum,partstr5)) then
        begin
         partstr:=nil;
         Wstrinit(partstr2,16640); 
         partstr3:=tydq_fs_disk_name(edl,procnum);
         Wstrset(partstr2,partstr3);
         Wstrcat(partstr2,partstr5);
         fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_system,sysindex);
         data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_system,1);
         partstr:=PWideChar(data.fsdata);
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[3]=true) then
          begin
           efi_console_edit_text_file_content_string(systemtable,partstr,partstr2);
           tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr)+1)*2,userlevel_system,1);
          end;
         Wstrfree(partstr); data.fssize:=0; Wstrfree(partstr3); Wstrfree(partstr2); 
        end
       else
        begin
         efi_console_output_string(systemtable,'File does not exist,so cannot edit the content of the file!'#10);
        end;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WstrCmp((cpstr.partstrlist+2)^,'edithex')=0) and (Wstrlen((cpstr.partstrlist+2)^)=7) then
      begin
       if(cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file edithex must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       data.fsdata:=nil; data.fssize:=0;
       if(tydq_fs_file_exists(edl,procnum,partstr5)) then
        begin
         Wstrinit(partstr2,16640); 
         partstr3:=tydq_fs_disk_name(edl,procnum);
         Wstrset(partstr2,partstr3);
         Wstrcat(partstr2,partstr5);
         fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_system,sysindex);
         data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_system,1);
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[2]=true) then
          begin
           efi_console_edit_hex_content_string(systemtable,data.fsdata,data.fssize,partstr2);
           tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,data.fsdata,data.fssize,userlevel_system,1);
          end;
         freemem(data.fsdata); data.fssize:=0; Wstrfree(partstr3); Wstrfree(partstr2);
        end
       else
        begin
         efi_console_output_string(systemtable,'File does not exist,so cannot edit the hex in the file!'#10);
        end;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'createandedit')=0) and (WStrlen((cpstr.partstrlist+2)^)=13) then
      begin
       if(cpstr.partstrnum>=4) and (cpstr.partstrnum<=7) then
        begin
         efi_console_output_string(systemtable,'file createandedit must have only one path or one path and maximum three types!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       if(tydq_fs_legal_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name is illegal(?,*,$,{,},(,),@,#,^ or % are illegal).'#10)
       else if(tydq_fs_legal_length_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name length is illegal(length must not exceed 255 and lower to 0).'#10);
       if(tydq_fs_legal_filename(partstr5)=false) or (tydq_fs_legal_length_filename(partstr5)=false) then
        begin
         Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       if(tydq_fs_file_exists(edl,procnum,partstr5)=false) then
        begin
         attributes:=tydqfs_text_file; shared:=false;
         for i:=5 to cpstr.partstrnum do
          begin
           if(WStrcmp((cpstr.partstrlist+i-1)^,'normal')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_normal_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'system')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_system_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'hidden')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_hidden_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'shared')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             shared:=true;
            end;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=true) then
          begin
           efi_console_output_string(systemtable,'file created must not to be both normal and system file!'#10);
           Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=false) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=false) then
          begin
           efi_console_output_string(systemtable,'file created must be normal or system file!'#10);
           Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(shared=true) then tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_system,0)
         else tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_system,1);
        end;
       partstr:=nil;
       Wstrinit(partstr2,16640); 
       partstr3:=tydq_fs_disk_name(edl,procnum);
       Wstrset(partstr2,partstr3);
       Wstrcat(partstr2,partstr5);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_system,sysindex);
       data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_system,1);
       partstr:=PWideChar(data.fsdata);
       efi_console_edit_text_file_content_string(systemtable,partstr,partstr2);
       tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr)+1)*2,userlevel_system,1);
       Wstrfree(partstr); data.fssize:=0; Wstrfree(partstr3); Wstrfree(partstr2); 
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'createandedithex')=0) and (WStrlen((cpstr.partstrlist+2)^)=16) then
      begin
       if(cpstr.partstrnum>=4) and (cpstr.partstrnum<=7) then
        begin
         efi_console_output_string(systemtable,'file createandedithex must have only one path or one path and maximum two types!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       if(tydq_fs_legal_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name is illegal(?,*,$,{,},(,),@,#,^ or % are illegal).'#10)
       else if(tydq_fs_legal_length_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name length is illegal(length must not exceed 255 and lower to 0).'#10);
       if(tydq_fs_legal_filename(partstr5)=false) or (tydq_fs_legal_length_filename(partstr5)=false) then
        begin
         Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       if(tydq_fs_file_exists(edl,procnum,partstr5)=false) then
        begin
         attributes:=tydqfs_binary_file; shared:=false;
         for i:=5 to cpstr.partstrnum do
          begin
           if(WStrcmp((cpstr.partstrlist+i-1)^,'normal')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_normal_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'system')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_system_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'hidden')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_hidden_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'shared')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             shared:=true;
            end;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=true) then
          begin
           efi_console_output_string(systemtable,'file created must not to be both normal and system file!'#10);
           Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=false) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=false) then
          begin
           efi_console_output_string(systemtable,'file created must be normal or system file!'#10);
           Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(shared=true) then tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_system,0)
         else tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_system,1);
        end;
       data.fsdata:=nil; data.fssize:=0;
       Wstrinit(partstr2,16640); 
       partstr3:=tydq_fs_disk_name(edl,procnum);
       Wstrset(partstr2,partstr3);
       Wstrcat(partstr2,partstr5);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_system,sysindex);
       data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_system,1);
       efi_console_edit_hex_content_string(systemtable,data.fsdata,data.fssize,partstr2);
       tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,data.fsdata,data.fssize,userlevel_system,1);
       freemem(data.fsdata); data.fssize:=0; Wstrfree(partstr3); Wstrfree(partstr2);
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'showtext')=0) and (Wstrlen((cpstr.partstrlist+2)^)=8) then
      begin
       if(cpstr.partstrnum<=3) then
        begin
         efi_console_output_string(systemtable,'file showtext must have a file path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_system,1);
       if(tydq_fs_file_exists(edl,procnum,partstr5)=false) and (tydq_fs_byte_to_attribute_bool(fsf.fattribute)[3]=false) then
        begin
         if(tydq_fs_file_exists(edl,procnum,partstr5)=false) then efi_console_output_string(systemtable,'file showtext must have a vaild file path!'#10)
         else if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[3]=false) then efi_console_output_string(systemtable,'file is not text file!'#10);
         Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       data.fsdata:=nil; data.fssize:=0;
       data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_system,1);
       partstr2:=PWideChar(data.fsdata);
       procnum2:=1; procnum3:=Wstrcount(partstr,#10,1)+1;
       for i:=5 to cpstr.partstrnum do 
        begin
         if(Wstrcmp('startline',(cpstr.partstrlist+i-1)^)=0) and (Wstrlen((cpstr.partstrlist+i-1)^)>9) then
          begin
           partstr:=Wstrcutout((cpstr.partstrlist+i-1)^,10,Wstrlen((cpstr.partstrlist+i-1)^));
           procnum2:=PWCharToUint(partstr);
           Wstrfree(partstr);
          end
         else if(Wstrcmp('endline',(cpstr.partstrlist+i-1)^)=0) and (Wstrlen((cpstr.partstrlist+i-1)^)>7) then
          begin
           partstr:=Wstrcutout((cpstr.partstrlist+i-1)^,8,Wstrlen((cpstr.partstrlist+i-1)^));
           procnum3:=PWCharToUint(partstr);
           Wstrfree(partstr);
          end;
        end;
       procnum4:=Wstrposorder(partstr2,#10,1,procnum2-1)+1;
       procnum6:=Wstrposorder(partstr2,#10,1,procnum3-1)-1;
       i:=procnum4;
       while(i<=procnum6) do
        begin
         j:=Wstrpos(partstr2,#10,procnum4);
         partstr3:=Wstrcutout(partstr2,i,j-1);
         efi_console_output_string(systemtable,partstr3);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr3);
         if(j>procnum6) then break;
         i:=j+1;
        end;
       freemem(data.fsdata); data.fssize:=0;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'showhex')=0) and (Wstrlen((cpstr.partstrlist+2)^)=7) then
      begin
       if(cpstr.partstrnum<=3) then
        begin
         efi_console_output_string(systemtable,'file showhex must have a file path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_system,1);
       if(tydq_fs_file_exists(edl,procnum,partstr5)=false) then
        begin
         efi_console_output_string(systemtable,'file showhex must have a vaild file path!'#10);
         Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
       data.fsdata:=nil; data.fssize:=0;
       data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_system,1);
       partstr2:=PWideChar(data.fsdata);
       procnum2:=1; procnum3:=data.fssize;
       for i:=5 to cpstr.partstrnum do 
        begin
         if(Wstrcmp('startoffset',(cpstr.partstrlist+i-1)^)=0) and (Wstrlen((cpstr.partstrlist+i-1)^)>9) then
          begin
           partstr:=Wstrcutout((cpstr.partstrlist+i-1)^,10,Wstrlen((cpstr.partstrlist+i-1)^));
           procnum2:=PWCharToUint(partstr);
           Wstrfree(partstr);
          end
         else if(Wstrcmp('endoffset',(cpstr.partstrlist+i-1)^)=0) and (Wstrlen((cpstr.partstrlist+i-1)^)>7) then
          begin
           partstr:=Wstrcutout((cpstr.partstrlist+i-1)^,8,Wstrlen((cpstr.partstrlist+i-1)^));
           procnum3:=PWCharToUint(partstr);
           Wstrfree(partstr);
          end;
        end;
       i:=procnum2; j:=1;
       for i:=procnum2 to procnum3 do
        begin
         j:=i-procnum2+1;
         partstr3:=UintToWHex((data.fsdata+i-1)^);
         if(Wstrlen(partstr3)=1) then
          begin
           efi_console_output_string(systemtable,'0');
           efi_console_output_string(systemtable,partstr3);
          end
         else if(Wstrlen(partstr3)=2) then
          begin
           efi_console_output_string(systemtable,partstr3);
          end;
         efi_console_output_string(systemtable,' ');
         if(j mod (maxcolumn div 3)=0) then efi_console_output_string(systemtable,#10);
        end;
       freemem(data.fsdata); data.fssize:=0;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrCmp((cpstr.partstrlist+2)^,'createlink')=0) and (Wstrlen((cpstr.partstrlist+2)^)=10) then
      begin
       if(cpstr.partstrnum<5) then
        begin
         efi_console_output_string(systemtable,'file createlink must have only two paths!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       if(tydq_fs_legal_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name is illegal(?,*,$,{,},(,),@,#,^ or % are illegal).'#10)
       else if(tydq_fs_legal_length_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name length is illegal(length must not exceed 255 and lower to 0).'#10);
       if(tydq_fs_legal_filename(partstr5)=false) or (tydq_fs_legal_length_filename(partstr5)=false) then
        begin
         Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       partstr6:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+4)^);
       procnum2:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+4)^);
       attributes:=tydqfs_link_file; shared:=false;
       for j:=6 to cpstr.partstrnum do
        begin
         if(Wstrcmp((cpstr.partstrlist+j-1)^,'normal')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then 
          begin
           attributes:=attributes or tydqfs_normal_file;
          end;
         if(Wstrcmp((cpstr.partstrlist+j-1)^,'system')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then 
          begin
           attributes:=attributes or tydqfs_system_file;
          end;
         if(Wstrcmp((cpstr.partstrlist+j-1)^,'hidden')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then 
          begin
           attributes:=attributes or tydqfs_hidden_file;
          end;
         if(Wstrcmp((cpstr.partstrlist+j-1)^,'shared')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then shared:=true;
        end;
       if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=true) then
        begin
         efi_console_output_string(systemtable,'Error:The link file could not to be both system and normal type!'#10);
         Wstrfree(partstr6); Wstrfree(partstr5); 
         freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; exit;
        end;
       if(shared) then tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_system,1)
       else tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_system,0);
       fsh:=tydq_fs_read_header(edl,procnum2);
       Wstrinit(partstr,16640); Wstrset(partstr,@fsh.RootName); Wstrcat(partstr,'/'); Wstrcat(partstr,partstr6);
       tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr)+1)*2,userlevel_system,1);
       Wstrfree(partstr); Wstrfree(partstr6); Wstrfree(partstr5); 
       freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
      end
     else if(WStrCmp((cpstr.partstrlist+2)^,'openlink')=0) and (Wstrlen((cpstr.partstrlist+2)^)=8) then
      begin
       if(cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file openlink must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_system,1);
       data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_system,1);
       if(tydq_fs_file_exists(edl,procnum,PWideChar(data.fsdata))=false) then
        begin
         efi_console_output_string(systemtable,'It is a best choice to delete the invaild link.'#10);
         efi_console_output_string(systemtable,'Do you agree to delete(Y or y is yes,other is no?'#10);
         efi_console_read_string(systemtable,partstr);
         if((Wstrcmp(partstr,'Y')=0) or (Wstrcmp(partstr,'y')=0)) and (Wstrlen(partstr)=1) then
          begin
           tydq_fs_delete_file(edl,procnum,partstr5,userlevel_system,1);
          end;
        end
       else
        begin
         partstr6:=tydq_fs_locate_fullpath(edl,PWideChar(data.fsdata));
         procnum2:=tydq_fs_locate_diskindex(edl,PWideChar(data.fsdata));
         fsh:=tydq_fs_read_header(edl,procnum2);
         Wstrset(tydqcurrentdiskname,@fsh.RootName);
         Wstrset(tydqcurrentpath,partstr6);
        end;
       Wstrfree(partstr6); Wstrfree(partstr5); 
       freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'resetlink')=0) and (Wstrlen((cpstr.partstrlist+2)^)=9) then
      begin
       if(cpstr.partstrnum<>5) then
        begin
         efi_console_output_string(systemtable,'file resetlink must have only two paths!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       partstr6:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+4)^);
       procnum2:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+4)^);
       fsh:=tydq_fs_read_header(edl,procnum2);
       Wstrinit(partstr,16640); Wstrset(partstr,@fsh.RootName); Wstrcat(partstr,partstr6);
       tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr)+1)*2,userlevel_system,1);
       Wstrfree(partstr); Wstrfree(partstr6); Wstrfree(partstr5); 
       freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
      end
     else
      begin
       efi_console_output_string(systemtable,'Command ');
       efi_console_output_string(systemtable,(cpstr.partstrlist+2)^);
       efi_console_output_string(systemtable,' after the command file unrecognized.'#10);
       efi_console_output_string(systemtable,'Vaild commands can be searched in help manual.'#10);
      end;
    end
   else if(WStrCmpL((cpstr.partstrlist+1)^,'shell')=0) then
    begin
     if(cpstr.partstrnum<3) then 
      begin
       efi_console_output_string(systemtable,'shell must have at least one path!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     edl:=efi_disk_tydq_get_fs_list(systemtable);
     for i:=3 to cpstr.partstrnum do
      begin
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+i-1)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+i-1)^);
       shell_execute_code(systemtable,edl,procnum,partstr5,userlevel_system,sysinfo,sysindex);
       Wstrfree(partstr5);
      end;
     freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
    end
   else if(WstrcmpL((cpstr.partstrlist+1)^,'readexe')=0) then
    begin
     if(cpstr.partstrnum<3) then 
      begin
       efi_console_output_string(systemtable,'readexe must have one path!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     edl:=efi_disk_tydq_get_fs_list(systemtable);
     partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
     procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
     fse:=tydq_fs_read_executable(edl,procnum,partstr5,userlevel_system,1);
     relocationshow:=false; stringtableshow:=false; symboltableshow:=false; hashtableshow:=false; sectionshowall:=false;
     sectionshow:=nil; sectionshownum:=0;
     for i:=4 to cpstr.partstrnum do
      begin
       if(WstrcmpL((cpstr.partstrlist+i-1)^,'relocation')=0) then relocationshow:=true
       else if(WstrcmpL((cpstr.partstrlist+i-1)^,'stringtable')=0) then stringtableshow:=true
       else if(WstrcmpL((cpstr.partstrlist+i-1)^,'symboltable')=0) then symboltableshow:=true
       else if(WstrcmpL((cpstr.partstrlist+i-1)^,'hashtable')=0) then hashtableshow:=true
       else if(WStrcmp((cpstr.partstrlist+i-1)^,'section')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=7) then sectionshowall:=true
       else if(WstrcmpL((cpstr.partstrlist+i-1)^,'section')=0) then
        begin
         procnum2:=Wstrlen((cpstr.partstrlist+i-1)^)-7;
         partstr:=Wstrcopy((cpstr.partstrlist+i-1)^,8,procnum2);
         for j:=1 to fse.exe_section_number do
          begin
           partstr2:=PCharToPWChar(PChar(fse.exe_string_table_segment.string_table_content+(fse.exe_section_segments+j-1)^.section_name_index-1));
           if(WstrcmpL(partstr,partstr2)=0) then 
            begin
             inc(sectionshownum);
             ReallocMem(sectionshow,sectionshownum*sizeof(natuint));
             (sectionshow+sectionshownum-1)^:=j;
             size:=getmemsize(partstr2);
             sectionshow:=Pointer(Pointer(sectionshow)-size);
             Wstrfree(partstr2);
             break;
            end;
           Wstrfree(partstr2);
          end;
         size:=getmemsize(partstr);
         sectionshow:=Pointer(Pointer(sectionshow)-size);
         Wstrfree(partstr);
        end;
      end;
     if(fse.exe_signature=tydqfs_executable_signature) and (fse.exe_string_table_offset>0) then
      begin
       {Output the executable type}
       efi_console_output_string(systemtable,'Executable Type:');
       if(fse.exe_type=tydqfs_executable_executable) then efi_console_output_string(systemtable,'Executable')
       else if(fse.exe_type=tydqfs_executable_relocatable) then efi_console_output_string(systemtable,'Relocatable')
       else if(fse.exe_type=tydqfs_executable_object) then efi_console_output_string(systemtable,'Object')
       else if(fse.exe_type=tydqfs_executable_staticlib) then efi_console_output_string(systemtable,'Static library')
       else if(fse.exe_type=tydqfs_executable_dynamiclib) then efi_console_output_string(systemtable,'Dynamic library');
       efi_console_output_string(systemtable,#10);
       {Output the executable architecture}
       efi_console_output_string(systemtable,'Executable Architecture:');
       if(fse.exe_type=tydqfs_x64) then efi_console_output_string(systemtable,'X64')
       else if(fse.exe_type=tydqfs_aarch64) then efi_console_output_string(systemtable,'AArch64')
       else if(fse.exe_type=tydqfs_loongarch64) then efi_console_output_string(systemtable,'LoongArch64')
       else if(fse.exe_type=tydqfs_riscv64) then efi_console_output_string(systemtable,'Risc-V64')
       else if(fse.exe_type=tydqfs_riscv128) then efi_console_output_string(systemtable,'Risc-V128');
       efi_console_output_string(systemtable,#10);
       {Output the executable version}
       efi_console_output_string(systemtable,'Executable Version:');
       partstr:=UintToPWChar(fse.exe_version[1]);
       efi_console_output_string(systemtable,partstr);
       efi_console_output_string(systemtable,'.');
       Wstrfree(partstr);
       partstr:=UintToPWChar(fse.exe_version[2]);
       efi_console_output_string(systemtable,partstr);
       efi_console_output_string(systemtable,'.');
       Wstrfree(partstr);
       partstr:=UintToPWChar(fse.exe_version[3]);
       efi_console_output_string(systemtable,partstr);
       efi_console_output_string(systemtable,'.');
       Wstrfree(partstr);
       partstr:=UintToPWChar(fse.exe_version[4]);
       efi_console_output_string(systemtable,partstr);
       Wstrfree(partstr);
       efi_console_output_string(systemtable,#10);
       {If needed,output the relocation part}
       if(relocationshow=true) and (fse.exe_relocation_offset>0) then 
        begin
         efi_console_output_string(systemtable,'Relocation part vaild,now show the relocation part infomation:'#10);
         efi_console_output_string(systemtable,'Relocation part total number:');
         partstr:=UintToPWChar(fse.exe_relocation_segment.relocation_number);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         for i:=1 to fse.exe_relocation_segment.relocation_number do
          begin
           partstr2:=UintToPWChar(i);
           efi_console_output_string(systemtable,'Relocation part ');
           efi_console_output_string(systemtable,partstr2);
           efi_console_output_string(systemtable,':'#10);
           Wstrfree(partstr2);
           partstr2:=PCharToPWChar(PChar(fse.exe_string_table_segment.string_table_content+(fse.exe_section_segments+i-1)^.section_name_index));
           efi_console_output_string(systemtable,'Part Name:');
           efi_console_output_string(systemtable,partstr2);
           Wstrfree(partstr2);
           efi_console_output_string(systemtable,' Relocation Offset:');
           partstr2:=UintToWHex((fse.exe_relocation_segment.relocation_offset+i-1)^);
           efi_console_output_string(systemtable,partstr2);
           efi_console_output_string(systemtable,#10);
           Wstrfree(partstr2);
          end;
         Wstrfree(partstr);
        end
       else
        begin
         efi_console_output_string(systemtable,'Error:Invaild relocation part!'#10);
        end;
       {If needed,Output the string table part}
       if(stringtableshow=true) then
        begin
         efi_console_output_string(systemtable,'String Table Size:');
         partstr:=UintToPWChar(fse.exe_string_table_segment.string_table_size);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr);
         procnum2:=1; procnum3:=0; i:=0;
         while(procnum2<=fse.exe_string_table_segment.string_table_size) do
          begin
           inc(i,1);
           partstr:=UintToPWChar(i);
           efi_console_output_string(systemtable,'Section ');
           efi_console_output_string(systemtable,partstr);
           efi_console_output_string(systemtable,' Name:');
           Wstrfree(partstr);
           partstr:=PCharToPWChar(PChar(fse.exe_string_table_segment.string_table_content+procnum2-1));
           procnum3:=strlen(PChar(fse.exe_string_table_segment.string_table_content+procnum2-1));
           efi_console_output_string(systemtable,partstr);
           efi_console_output_string(systemtable,#10);
           Wstrfree(partstr);
           inc(procnum2,procnum3+1);
          end;
        end;
       {If needed,Output the symbol table part}
       if(symboltableshow=true) and (fse.exe_symbol_table_offset>0) then
        begin
         efi_console_output_string(Systemtable,'Symbol Table part vaild,now show the symbol table information:'#10);
         efi_console_output_string(Systemtable,'Symbol total number in symbol table:');
         partstr:=UintToPWChar(fse.exe_symbol_table_segment.symbol_table_number);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr);
         for i:=1 to fse.exe_symbol_table_segment.symbol_table_number do
          begin
           partstr:=UintToPWChar(i);
           efi_console_output_string(systemtable,'Symbol Address ');
           efi_console_output_string(systemtable,partstr);
           Wstrfree(partstr);
           partstr:=UintToWhex((fse.exe_symbol_table_segment.symbol_table_address+i-1)^);
           efi_console_output_string(systemtable,':');
           efi_console_output_string(systemtable,partstr);
           Wstrfree(partstr);
           if((fse.exe_symbol_table_segment.symbol_table_type+i-1)^=$00) then
            begin
             efi_console_output_string(systemtable,' Link type:None');
            end
           else if((fse.exe_symbol_table_segment.symbol_table_type+i-1)^=$01) then
            begin
             efi_console_output_string(systemtable,' Link type:Static');
            end
           else if((fse.exe_symbol_table_segment.symbol_table_type+i-1)^=$02) then
            begin
             efi_console_output_string(systemtable,' Link type:Dynamic');
            end
           else if((fse.exe_symbol_table_segment.symbol_table_type+i-1)^=$03) then
            begin
             efi_console_output_string(systemtable,' Link type:Smartlink');
            end;
           efi_console_output_string(systemtable,#10);
          end;       
        end;
       {If needed,Output the hash table part}
       if(hashtableshow=true) and (fse.exe_hash_table_offset>0) then
        begin
         efi_console_output_string(Systemtable,'Hash Table part vaild,now show the hash table information:'#10);
         efi_console_output_string(Systemtable,'Hash total number in symbol table:');
         partstr:=UintToPWChar(fse.exe_hash_table_segment.hash_table_number);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr);
         for i:=1 to fse.exe_hash_table_segment.hash_table_number do
          begin
           partstr:=UintToPWChar(i);
           efi_console_output_string(systemtable,'Hash Address ');
           efi_console_output_string(systemtable,partstr);
           Wstrfree(partstr);
           partstr:=UintToWhex((fse.exe_hash_table_segment.hash_table_address+i-1)^);
           efi_console_output_string(systemtable,':');
           efi_console_output_string(systemtable,partstr);
           Wstrfree(partstr);
           efi_console_output_string(systemtable,#10);
          end;       
        end;
       {If needed,Output the section part}
       if(fse.exe_section_start_offset>0) then
        begin
         efi_console_output_string(systemtable,'Section part vaild,now show all section information:'#10);
         efi_console_output_string(systemtable,'Section total number in symbol table:');
         partstr:=UintToPWChar(fse.exe_section_number);
         efi_console_output_string(systemtable,partstr);
         Wstrfree(partstr);
         if(sectionshowall=false) then
          begin
           for i:=1 to sectionshownum do
            begin
             efi_console_output_string(systemtable,'Section ');
             partstr:=UintToPWChar(i);
             efi_console_output_string(systemtable,partstr);
             efi_console_output_string(systemtable,':'#10);
             Wstrfree(partstr);
             j:=(sectionshow+i-1)^;
             if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_code) then
              begin
               efi_console_output_string(systemtable,'Section Type:Code'#10);
              end
             else if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_initialized_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Initialized Data'#10);
              end
             else if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_read_only_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Read Only data'#10);
              end
             else if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_uninitialized_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Uninitialized Data'#10);
              end
             else if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_debug_info) then
              begin
               efi_console_output_string(systemtable,'Section Type:Debug info'#10);
              end
             else if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_compiler_info) then
              begin
               efi_console_output_string(systemtable,'Section Type:Compiler info'#10);
              end;
             partstr:=UintToPWChar((fse.exe_section_segments+j-1)^.section_segment_size);
             efi_console_output_string(systemtable,'Section Size:');
             efi_console_output_string(systemtable,partstr);
             efi_console_output_string(systemtable,#10);
             Wstrfree(partstr);
            end;
          end
         else if(sectionshowall=true) then
          begin
           for i:=1 to sectionshownum do
            begin
             efi_console_output_string(systemtable,'Section ');
             partstr:=UintToPWChar(i);
             efi_console_output_string(systemtable,partstr);
             efi_console_output_string(systemtable,':'#10);
             Wstrfree(partstr);
             if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_code) then
              begin
               efi_console_output_string(systemtable,'Section Type:Code'#10);
              end
             else if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_initialized_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Initialized Data'#10);
              end
             else if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_read_only_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Read Only data'#10);
              end
             else if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_uninitialized_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Uninitialized Data'#10);
              end
             else if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_debug_info) then
              begin
               efi_console_output_string(systemtable,'Section Type:Debug info'#10);
              end
             else if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_compiler_info) then
              begin
               efi_console_output_string(systemtable,'Section Type:Compiler info'#10);
              end;
             partstr:=UintToPWChar((fse.exe_section_segments+i-1)^.section_segment_size);
             efi_console_output_string(systemtable,'Section Size:');
             efi_console_output_string(systemtable,partstr);
             efi_console_output_string(systemtable,#10);
             Wstrfree(partstr);
            end;
          end;
        end;
      end
     else
      begin
       if(fse.exe_string_table_offset>0) then efi_console_output_string(systemtable,'Error:Invaild executable due to string table invaild!'#10)
       else efi_console_output_string(systemtable,'Error:Invaild executable and this executable file unrecognized!'#10);
      end;
     tydq_fs_free_executable(fse);
     Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
    end
   else if(WstrcmpL((cpstr.partstrlist+1)^,'execute')=0) then
    begin
     if(cpstr.partstrnum<3) then
      begin
       efi_console_output_string(systemtable,'execute must have at least one path!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     edl:=efi_disk_tydq_get_fs_list(systemtable);
     partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
     procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
     param.parameter:=nil; param.parameternum:=0; procnum2:=0;
     for i:=4 to cpstr.partstrnum do
      begin
       procnum3:=WStrlen((cpstr.partstrlist+i-1)^);
       procnum2:=procnum2+procnum3+1;
       ReallocMem(param.parameter,sizeof(WideChar)*procnum2);
       partstr:=Wstrcopy((cpstr.partstrlist+i-1)^,1,procnum3);
       partstr2:=param.parameter+procnum2;
       Wstrset(partstr2,partstr);
       Wstrfree(partstr);
      end;
     isexecuted:=tydq_fs_execute_executable(edl,procnum,partstr5,param,userlevel_system,1);
     if(isexecuted=false) then 
      begin 
       efi_console_output_string(systemtable,'the file ');
       efi_console_output_string(systemtable,partstr5);
       efi_console_output_string(systemtable,' executed returns error,please check this executable file to detect problems.'#10);
      end;
     Wstrfree(param.parameter); param.parameternum:=0;
     Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'passwd')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
    begin
     efi_console_output_string(systemtable,'Enter your original password:');
     efi_console_read_password_string(systemtable,inputstr1);
     while(Wstrcmp(inputstr1,tydq_fs_systeminfo_get_passwd(sysinfo,(sysinfo.userinfolist+sysindex-2)^.username))<>0)
     or (Wstrlen(inputstr1)<>Wstrlen(tydq_fs_systeminfo_get_passwd(sysinfo,(sysinfo.userinfolist+sysindex-2)^.username))) do
      begin
       efi_console_output_string(systemtable,'Error:typed password incorrect.'#10);
       efi_console_output_string(systemtable,'Enter your original password:');
       efi_console_read_password_string(systemtable,inputstr1);
      end;
     efi_console_output_string(systemtable,'Input your new password:');
     efi_console_read_password_string(systemtable,inputstr2);
     size:=getmemsize((sysinfo.userinfolist+sysindex-2)^.userpasswd);
     Wstrrealloc((sysinfo.userinfolist+sysindex-2)^.userpasswd,Wstrlen(inputstr2));
     Wstrset((sysinfo.userinfolist+sysindex-2)^.userpasswd,inputstr2);
     for j:=sysindex-1 to sysinfo.header.tydqusercount do
      begin
       (sysinfo.userinfolist+j)^.username:=PWideChar(Pointer((sysinfo.userinfolist+j)^.username)-size);
       (sysinfo.userinfolist+j)^.userpasswd:=PWideChar(Pointer((sysinfo.userinfolist+j)^.userpasswd)-size);
      end;
     efi_console_output_string(systemtable,'You successfully changed your password!'#10);
     freemem(inputstr2); freemem(inputstr1);
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'usrname')=0) and (Wstrlen((cpstr.partstrlist+1)^)=7) then
    begin
     efi_console_output_string(systemtable,'Input your new user name:');
     efi_console_read_string(systemtable,inputstr1);
     while(tydq_fs_systeminfo_username_count(sysinfo,inputstr1)>=1) do
      begin
       efi_console_output_string(systemtable,'Error:User name already exists.'#10);
       efi_console_output_string(systemtable,'Input your new user name:');
       efi_console_read_string(systemtable,inputstr1);
      end;
     size:=getmemsize((sysinfo.userinfolist+sysindex-2)^.username);
     Wstrrealloc((sysinfo.userinfolist+sysindex-2)^.username,Wstrlen(inputstr1));
     Wstrset((sysinfo.userinfolist+sysindex-2)^.username,inputstr1);
     for j:=sysindex-1 to sysinfo.header.tydqusercount do
      begin
       (sysinfo.userinfolist+j)^.username:=PWideChar(Pointer((sysinfo.userinfolist+j)^.username)-size);
       (sysinfo.userinfolist+j)^.userpasswd:=PWideChar(Pointer((sysinfo.userinfolist+j)^.userpasswd)-size);
      end;
     efi_console_output_string(systemtable,'You successfully changed your user name!'#10);
     freemem(inputstr1);
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'path')=0) and (Wstrlen((cpstr.partstrlist+1)^)=4) then
    begin
     if(cpstr.partstrnum<=2) then
      begin
       efi_console_output_string(systemtable,'path must have one path,.. or . .'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     if(WStrcmp((cpstr.partstrlist+2)^,'..')=0) and (Wstrlen((cpstr.partstrlist+2)^)=2) then
      begin
       procnum:=Wstrposdir(tydqcurrentpath,'/',Wstrlen(tydqcurrentpath),-1);
       if(procnum>1) then partstr:=Wstrcutout(tydqcurrentpath,1,procnum-1) else partstr:=Wstrcopy(tydqcurrentpath,1,1);
       Wstrset(tydqcurrentpath,partstr);
       Wstrfree(partstr);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'.')=0) and (Wstrlen((cpstr.partstrlist+2)^)=1) then
      begin
      end
     else
      begin
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       fsh:=tydq_fs_read_header(edl,procnum);
       Wstrset(tydqcurrentdiskname,@fsh.RootName);
       Wstrset(tydqcurrentpath,partstr5);
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
      end;
    end
   else if(WStrcmp((cpstr.partstrlist+1)^,'addusr')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
    begin
     efi_console_output_string(systemtable,'Type your new user name(name length must be in 1-128):');
     efi_console_read_string(systemtable,inputstr1);
     while(Wstrlen(inputstr1)=0) or (Wstrlen(inputstr1)>128) or (tydq_fs_systeminfo_get_index(sysinfo,inputstr1)>=2) do
      begin
       if(Wstrlen(inputstr1)=0) or (Wstrlen(inputstr1)>128) then
       efi_console_output_string(systemtable,'Error:Account name length overflows.'#10)
       else
       efi_console_output_string(systemtable,'Error:The new name is already used.'#10);
       efi_console_output_string(systemtable,'Type your new user name:');
       efi_console_read_string(systemtable,inputstr1);
      end;
     efi_console_output_string(systemtable,'Type your new user'#39's password:');
     efi_console_read_password_string(systemtable,inputstr2);
     efi_console_output_string(systemtable,'Verify your password:');
     efi_console_read_password_string(systemtable,inputstr3);
     while(Wstrcmp(inputstr2,inputstr3)<>0) or (Wstrlen(inputstr2)<>Wstrlen(inputstr3)) do
      begin
       efi_console_output_string(systemtable,'Error:The typed password does not correspond to former password.'#10);
       efi_console_output_string(systemtable,'Verify your password:');
       efi_console_read_password_string(systemtable,inputstr3);
      end;
     tydq_fs_systeminfo_add_user(sysinfo,inputstr1,inputstr2,false);
     edl:=efi_disk_tydq_get_fs_list(systemtable);
     tydq_fs_systeminfo_write(systemtable,edl,sysinfo);
     Freemem(edl.disk_block_content); Freemem(edl.disk_content); edl.disk_count:=0;
     efi_console_output_string(systemtable,'You successfully add a new user!'#10);
     Wstrfree(inputstr3); Wstrfree(inputstr2); Wstrfree(inputstr1);
    end
   else if(WStrcmp((cpstr.partstrlist+1)^,'delusr')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
    begin
     efi_console_output_string(systemtable,'Type the user name you want to delete:');
     efi_console_read_string(systemtable,inputstr1);
     while(tydq_fs_systeminfo_get_index(sysinfo,inputstr1)=0) or 
     (Wstrcmp((sysinfo.userinfolist+sysindex-2)^.username,inputstr1)=0) or 
     (Wstrlen((sysinfo.userinfolist+sysindex-2)^.username)=Wstrlen(inputstr1)) do
      begin
       if(tydq_fs_systeminfo_get_index(sysinfo,inputstr1)=0) then
        begin
         efi_console_output_string(systemtable,'Error:the specified user name does not exist.'#10);
        end
       else if(Wstrcmp((sysinfo.userinfolist+sysindex-2)^.username,inputstr1)=0) or (Wstrlen((sysinfo.userinfolist+sysindex-2)^.username)=Wstrlen(inputstr1)) then
        begin
         efi_console_output_string(systemtable,'Error:the user name must not to be your current account'#39's user name.'#10);
        end;
       efi_console_output_string(systemtable,'Type the user name you want to delete:');
       efi_console_read_string(systemtable,inputstr1);
      end;
     tydq_fs_systeminfo_delete_user(sysinfo,inputstr1);
     edl:=efi_disk_tydq_get_fs_list(systemtable);
     tydq_fs_systeminfo_write(systemtable,edl,sysinfo);
     Freemem(edl.disk_block_content); Freemem(edl.disk_content); edl.disk_count:=0;
     efi_console_output_string(systemtable,'You successfully delete a exist user!'#10);
     Wstrfree(inputstr1);
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'lsuser')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
    begin
     efi_console_output_string(systemtable,'Existing user account infomation:'#10);
     for j:=1 to sysinfo.header.tydqusercount do
      begin
       partstr:=UintToPWChar(j);
       efi_console_output_string(systemtable,'User ');
       efi_console_output_string(systemtable,partstr);
       efi_console_output_string(systemtable,' Account Name:');
       efi_console_output_string(systemtable,(sysinfo.userinfolist+j-1)^.username);
       efi_console_output_string(systemtable,#10);
       FreeMem(partstr);
      end;
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'lsdisk')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
    begin
     edl:=efi_disk_tydq_get_fs_list(systemtable);
     efi_console_output_string(systemtable,'Formatted TYDQ System Disk:'#10);
     for j:=1 to edl.disk_count do
      begin
       fsh:=tydq_fs_read_header(edl,j);
       partstr:=UintToPWChar(j);
       efi_console_output_string(systemtable,'Disk ');
       efi_console_output_string(systemtable,partstr);
       Wstrfree(partstr);
       efi_console_output_string(systemtable,' information:'#10);
       efi_console_output_string(systemtable,'Name:');
       efi_console_output_string(systemtable,@fsh.RootName);
       efi_console_output_string(systemtable,#10);
       efi_console_output_string(systemtable,'Maximum Size:');
       if(fsh.maxsize>=1024*1024*1024*1024) then
        begin
         partstr:=ExtendedToPWChar(fsh.maxsize/(1024*1024*1024*1024),2);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,'TiB'#10);
        end
       else if(fsh.maxsize>=1024*1024*1024) then
        begin
         partstr:=ExtendedToPWChar(fsh.maxsize/(1024*1024*1024),2);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,'GiB'#10);
        end
       else if(fsh.maxsize>=1024*1024) then
        begin
         partstr:=ExtendedToPWChar(fsh.maxsize/(1024*1024),2);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,'MiB'#10);
        end
       else if(fsh.maxsize>=1024) then
        begin
         partstr:=ExtendedToPWChar(fsh.maxsize/1024,2);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,'KiB'#10);
        end
       else if(fsh.maxsize>=0) then
        begin
         partstr:=ExtendedToPWChar(fsh.maxsize,2);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,'B'#10);
        end;
       Wstrfree(partstr);
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
       else if(fsh.usedsize>0) then
        begin
         partstr:=ExtendedToPWChar(fsh.usedsize,2);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,'B'#10);
        end;
       Wstrfree(partstr);
      end;
     freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'logout')=0) and (WStrlen((cpstr.partstrlist+1)^)=6) then
    begin
     efi_console_clear_screen(systemtable);
     efi_console_output_string(systemtable,'Type the user name you want to login:');
     efi_console_read_string(systemtable,partstr);
     while(tydq_fs_systeminfo_get_index(sysinfo,partstr)=0) do
      begin
       efi_console_output_string(systemtable,'Error:typed user name does not exist.'#10);
       efi_console_output_string(systemtable,'Type the user name you want to login:');
       efi_console_read_string(systemtable,partstr);
      end;
     partstr2:=tydq_fs_systeminfo_get_passwd(sysinfo,(sysinfo.userinfolist+sysindex-2)^.username);
     efi_console_output_string(systemtable,'Type ');
     efi_console_output_string(systemtable,(sysinfo.userinfolist+sysindex-2)^.username);
     efi_console_output_string(systemtable,#39's password:');
     efi_console_read_password_string(systemtable,partstr3);
     while(Wstrcmp(partstr2,partstr3)=0) or (Wstrlen(partstr2)<>Wstrlen(partstr3)) do
      begin
       efi_console_output_string(systemtable,'Error:input password incorrect.');
       efi_console_output_string(systemtable,'Type ');
       efi_console_output_string(systemtable,(sysinfo.userinfolist+sysindex-2)^.username);
       efi_console_output_string(systemtable,#39's password:');
       efi_console_read_password_string(systemtable,partstr3);
      end;
     efi_console_output_string(systemtable,'Successfully login!'#10);
     tydq_fs_systeminfo_write(systemtable,edl,sysinfo);
    end
   else if(WstrcmpL((cpstr.partstrlist+1)^,'kerneldetect')=0) then
    begin
     if(cpstr.partstrnum<3) then
      begin
       efi_console_output_string(systemtable,'kerneldetect must have one path to detect!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     edl:=efi_disk_tydq_get_fs_list(systemtable);
     partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
     procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
     bool:=tydq_fs_detect_kernel(edl,procnum,partstr5,userlevel_system,1);
     if(bool) then efi_console_output_string(systemtable,'Typed file is a kernel file!'#10)
     else efi_console_output_string(systemtable,'Typed file is not a kernel file!'#10);
     Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
    end
   else if(WstrcmpL((cpstr.partstrlist+1)^,'kernelinstall')=0) then
    begin
     if(cpstr.partstrnum<3) then
      begin
       efi_console_output_string(systemtable,'kernelinstall must have one path to install from!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     edl:=efi_disk_tydq_get_fs_list(systemtable);
     partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
     procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
     bool:=tydq_fs_change_kernel(systemtable,edl,procnum,partstr5,userlevel_system,1);
     if(bool) then efi_console_output_string(systemtable,'Vaild kernel installed!'#10)
     else efi_console_output_string(systemtable,'Kernel invaild!'#10);
     Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'clearscreen')=0) and (Wstrlen((cpstr.partstrlist+1)^)=11) then
    begin
     efi_console_clear_screen(systemtable);
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'sysver')=0) and (WStrlen((cpstr.partstrlist+1)^)=6) then
    begin
     efi_console_output_string(systemtable,'System Version:0.0.4'#10);
    end
   else if(WStrcmp((cpstr.partstrlist+1)^,'sysname')=0) and (Wstrlen((cpstr.partstrlist+1)^)=7) then
    begin
     efi_console_output_string(systemtable,'System Name:TYDQ System'#10);
    end
   else if(WStrcmp((cpstr.partstrlist+1)^,'sysarch')=0) and (Wstrlen((cpstr.partstrlist+1)^)=7) then
    begin
     procnum:=efi_get_platform;
     if(procnum=0) then efi_console_output_string(systemtable,'System Architecture:x64'#10)
     else if(procnum=1) then efi_console_output_string(systemtable,'System Architecture:aarch64'#10)
     else if(procnum=2) then efi_console_output_string(systemtable,'System Architecture:loongarch64'#10);
    end
   else if(WStrcmp((cpstr.partstrlist+1)^,'sysinfo')=0) and (Wstrlen((cpstr.partstrlist+1)^)=7) then
    begin
     efi_console_output_string(systemtable,'System Name:TYDQ System'#10);
     efi_console_output_string(systemtable,'System Version:0.0.4'#10);
     procnum:=efi_get_platform;
     if(procnum=0) then efi_console_output_string(systemtable,'System Architecture:x64'#10)
     else if(procnum=1) then efi_console_output_string(systemtable,'System Architecture:aarch64'#10)
     else if(procnum=2) then efi_console_output_string(systemtable,'System Architecture:loongarch64'#10);
    end
   else if(WstrCmp((cpstr.partstrlist+1)^,'sysctl')=0) and (WStrlen((cpstr.partstrlist+1)^)=6) then
    begin
     if(cpstr.partstrnum<4) then
      begin
       efi_console_output_string(systemtable,'sysctl must have an option name and option value(disabled or enabled).'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     if(Wstrcmp((cpstr.partstrlist+2)^,'graphics')=0) and (Wstrlen((cpstr.partstrlist+2)^)=8) then
      begin
       if(Wstrcmp((cpstr.partstrlist+3)^,'disabled')=0) and (Wstrlen((cpstr.partstrlist+3)^)=8) then
        begin
         sysinfo.header.tydqgraphics:=false;
         efi_console_output_string(systemtable,'Please reboot the system to take effect this system option.'#10);
        end
       else if(Wstrcmp((cpstr.partstrlist+3)^,'enabled')=0) and (Wstrlen((cpstr.partstrlist+3)^)=7) then
        begin
         sysinfo.header.tydqgraphics:=true;
         efi_console_output_string(systemtable,'Please reboot the system to take effect this system option.'#10);
        end  
       else
        begin
         efi_console_output_string(systemtable,'Option Value ');
         efi_console_output_string(systemtable,(cpstr.partstrlist+3)^);
         efi_console_output_string(systemtable,' is invaild,vaild option value:disabled/enabled.'#10);
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       tydq_fs_systeminfo_write(systemtable,edl,sysinfo);
       Freemem(edl.disk_block_content); Freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'network')=0) and (Wstrlen((cpstr.partstrlist+2)^)=7) then
      begin
       if(Wstrcmp((cpstr.partstrlist+3)^,'disabled')=0) and (Wstrlen((cpstr.partstrlist+3)^)=8) then
        begin
         sysinfo.header.tydqnetwork:=false;
         efi_console_output_string(systemtable,'Please reboot the system to take effect this system option.'#10);
        end
       else if(Wstrcmp((cpstr.partstrlist+3)^,'enabled')=0) and (Wstrlen((cpstr.partstrlist+3)^)=7) then
        begin
         sysinfo.header.tydqnetwork:=true;
         efi_console_output_string(systemtable,'Please reboot the system to take effect this system option.'#10);
        end
       else
        begin
         efi_console_output_string(systemtable,'Option Value ');
         efi_console_output_string(systemtable,(cpstr.partstrlist+3)^);
         efi_console_output_string(systemtable,' is invaild,vaild option value:disabled/enabled.'#10);
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       tydq_fs_systeminfo_write(systemtable,edl,sysinfo);
       Freemem(edl.disk_block_content); Freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'autodetectkernel')=0) and (Wstrlen((cpstr.partstrlist+2)^)=7) then
      begin
       if(Wstrcmp((cpstr.partstrlist+3)^,'disabled')=0) and (Wstrlen((cpstr.partstrlist+3)^)=8) then
        begin
         sysinfo.header.tydqautodetectkernel:=false;
         efi_console_output_string(systemtable,'Please reboot the system to take effect this system option.'#10);
        end
       else if(Wstrcmp((cpstr.partstrlist+3)^,'enabled')=0) and (Wstrlen((cpstr.partstrlist+3)^)=7) then
        begin
         sysinfo.header.tydqautodetectkernel:=true;
         efi_console_output_string(systemtable,'Please reboot the system to take effect this system option.'#10);
        end
       else
        begin
         efi_console_output_string(systemtable,'Option Value ');
         efi_console_output_string(systemtable,(cpstr.partstrlist+3)^);
         efi_console_output_string(systemtable,' is invaild,vaild option value:disabled/enabled.'#10);
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       tydq_fs_systeminfo_write(systemtable,edl,sysinfo);
       Freemem(edl.disk_block_content); Freemem(edl.disk_content); edl.disk_count:=0;
      end
     else 
      begin
       efi_console_output_string(systemtable,'This option ');
       efi_console_output_string(systemtable,(cpstr.partstrlist+2)^);
       efi_console_output_string(systemtable,' is invaild,please try option graphics/network.'#10);
      end;
    end
   else if(Wstrcmp((cpstr.partstrlist+1)^,'help')=0) and (WStrlen((cpstr.partstrlist+1)^)=4) then
    begin
     if(cpstr.partstrnum<=2) then
      begin
       efi_console_output_string(systemtable,'You need to type a command to show the help manual of it.'#10);
       efi_console_output_string(systemtable,'Vaild commands:sp reboot shutdown echo delay file passwd usrname path'#10);
       efi_console_output_string(systemtable,'addusr delusr lsuser lsdisk kerneldetect kernelinstall logout help sysver sysname sysarch sysinfo sysctl'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'sp')=0) and (WStrlen((cpstr.partstrlist+2)^)=2) then
      begin
       efi_console_output_string(systemtable,'Improve your user level in one command and with this user level execute the command.'#10);
       efi_console_output_string(systemtable,'Usage:sp <command>'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'reboot')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
      begin
       efi_console_output_string(systemtable,'Restart the whole operating system.'#10);
       efi_console_output_string(systemtable,'Usage:reboot'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'shutdown')=0) and (WStrlen((cpstr.partstrlist+2)^)=8) then
      begin
       efi_console_output_string(systemtable,'Close the whole operating system.'#10);
       efi_console_output_string(systemtable,'Usage:shutdown'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'echo')=0) and (Wstrlen((cpstr.partstrlist+2)^)=4) then
      begin
       efi_console_output_string(systemtable,'Output the string in the screen.'#10);
       efi_console_output_string(systemtable,'Usage:echo <string>'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'delay')=0) and (Wstrlen((cpstr.partstrlist+2)^)=5) then
      begin
       efi_console_output_string(systemtable,'Delay in specified time after execute the command.'#10);
       efi_console_output_string(systemtable,'Usage:echo <string>'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'file')=0) and (WStrlen((cpstr.partstrlist+2)^)=4) then
      begin
       if(cpstr.partstrnum<=3) then
        begin
         efi_console_output_string(systemtable,'Please type the vaild command after the command file:'#10);
         efi_console_output_string(systemtable,'create list tree info copy delete exist edit edithex'#10);
         efi_console_output_string(systemtable,'createandedit createandedithex showtext showhex createlink'#10);
         efi_console_output_string(systemtable,'openlink resetlink'#10);
         efi_console_output_string(systemtable,'Usage:file <command> <parameters>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+3)^,'create')=0) and (Wstrlen((cpstr.partstrlist+3)^)=6) then
        begin
         efi_console_output_string(systemtable,'Create a specified file in specified path.'#10);
         efi_console_output_string(systemtable,'Usage:file create <path><folder/link/text/binary>'#10);
         efi_console_output_string(systemtable,'<normal/system><hidden><shared>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+3)^,'list')=0) and (Wstrlen((cpstr.partstrlist+3)^)=4) then
        begin
         efi_console_output_string(systemtable,'List all specified files in the specified path.'#10);
         efi_console_output_string(systemtable,'You can add command detecthidden to detect hidden files.'#10);
         efi_console_output_string(systemtable,'Usage:file list <path><detecthidden(optional)>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+3)^,'tree')=0) and (Wstrlen((cpstr.partstrlist+3)^)=4) then
        begin
         efi_console_output_string(systemtable,'List all specified files in the specified path(the file in folder will also be listed.'#10);
         efi_console_output_string(systemtable,'You can add command detecthidden to detect hidden files.'#10);
         efi_console_output_string(systemtable,'Usage:file tree <path><detecthidden(optional)>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+3)^,'info')=0) and (Wstrlen((cpstr.partstrlist+3)^)=4) then
        begin
         efi_console_output_string(systemtable,'Get the file information from the specified file.'#10);
         efi_console_output_string(systemtable,'Usage:file info <path>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+3)^,'copy')=0) and (Wstrlen((cpstr.partstrlist+3)^)=4) then
        begin
         efi_console_output_string(systemtable,'Copy the specified file or specified files to other path.'#10);
         efi_console_output_string(systemtable,'You can add judgehidden command to specified hidden files.'#10);
         efi_console_output_string(systemtable,'Usage:file copy <pathfrom><pathto><judgehidden(optional)>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+3)^,'delete')=0) and (Wstrlen((cpstr.partstrlist+3)^)=6) then
        begin
         efi_console_output_string(systemtable,'Delete the specified file or specified files(including files in folders).'#10);
         efi_console_output_string(systemtable,'You can add judgehidden command to specified hidden files.'#10);
         efi_console_output_string(systemtable,'Usage:file delete <path><judgehidden(optional)>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+3)^,'exist')=0) and (Wstrlen((cpstr.partstrlist+3)^)=5) then
        begin
         efi_console_output_string(systemtable,'Test whether the file exist or not.'#10);
         efi_console_output_string(systemtable,'Usage:file exist <path>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+3)^,'edit')=0) and (WStrlen((cpstr.partstrlist+3)^)=4) then
        begin
         efi_console_output_string(systemtable,'Edit the specified text file.'#10);
         efi_console_output_string(systemtable,'Usage:file edit <path>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+3)^,'edithex')=0) and (WStrlen((cpstr.partstrlist+3)^)=7) then
        begin
         efi_console_output_string(systemtable,'Edit the specified file in hex edit mode.'#10);
         efi_console_output_string(systemtable,'Usage:file edithex <path>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+3)^,'createandedit')=0) and (WStrlen((cpstr.partstrlist+3)^)=13) then
        begin
         efi_console_output_string(systemtable,'Create the specified text file in path and then edit the content.'#10);
         efi_console_output_string(systemtable,'Usage:file createandedit <path><normal/system><hidden><shared>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+3)^,'createandedithex')=0) and (WStrlen((cpstr.partstrlist+3)^)=16) then
        begin
         efi_console_output_string(systemtable,'Create the specified binary file in path and then edit the hex.'#10);
         efi_console_output_string(systemtable,'Usage:file createandedithex <path><normal/system><hidden><shared>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+3)^,'showtext')=0) and (WStrlen((cpstr.partstrlist+3)^)=8) then
        begin
         efi_console_output_string(systemtable,'Show the text content in the text file with specified range.'#10);
         efi_console_output_string(systemtable,'You can set the startline to set the start line to show,'#10);
         efi_console_output_string(systemtable,'set the endline to set the end line to show.'#10);
         efi_console_output_string(systemtable,'Usage:file showtext <path><startline+number><endline+number>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+3)^,'showhex')=0) and (WStrlen((cpstr.partstrlist+3)^)=7) then
        begin
         efi_console_output_string(systemtable,'Show the hex content in the file with specified range.'#10);
         efi_console_output_string(systemtable,'You can set the startoffset to set the start offset to show,'#10);
         efi_console_output_string(systemtable,'set the endoffset to set the end offset to show.'#10);
         efi_console_output_string(systemtable,'Usage:file showhex <path><startoffset+number><endoffset+number>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+3)^,'createlink')=0) and (WStrlen((cpstr.partstrlist+3)^)=10) then
        begin
         efi_console_output_string(systemtable,'Create a specified link file which point to specified path.'#10);
         efi_console_output_string(systemtable,'Usage:file createlink <path><pathto><normal/system><hidden><shared>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+3)^,'openlink')=0) and (WStrlen((cpstr.partstrlist+3)^)=8) then
        begin
         efi_console_output_string(systemtable,'Open link to jump to the path which link specified in the file.'#10);
         efi_console_output_string(systemtable,'Usage:file openlink <path>'#10);
        end 
       else if(Wstrcmp((cpstr.partstrlist+3)^,'resetlink')=0) and (Wstrlen((cpstr.partstrlist+3)^)=9) then
        begin
         efi_console_output_string(systemtable,'Reset a specified link file'#39's link to specified path.'#10);
         efi_console_output_string(systemtable,'Usage:file resetlink <path><pathto>'#10);
        end
       else
        begin
         efi_console_output_string(systemtable,'Command ');
         efi_console_output_string(systemtable,(cpstr.partstrlist+3)^);
         efi_console_output_string(systemtable,' after the command file unrecognized,'#10);
         efi_console_output_string(systemtable,'Please type the vaild command after the command file:'#10);
         efi_console_output_string(systemtable,'create list tree info copy delete exist edit edithex'#10);
         efi_console_output_string(systemtable,'createandedit createandedithex showtext showhex createlink'#10);
         efi_console_output_string(systemtable,'openlink resetlink'#10);
        end;
      end
     else if(WStrCmpL((cpstr.partstrlist+2)^,'shell')=0) then
      begin
       efi_console_output_string(systemtable,'Execute the shell code file'#39's information'#10);
       efi_console_output_string(systemtable,'Usage:shell <path1..n>(n>=1)'#10);
       efi_console_output_string(systemtable,'shell code tips:'#10);
       efi_console_output_string(systemtable,'if(statement){expression}'#10'variable-name =/+=/-=/*=//=/%= variable-value'#10);
       efi_console_output_string(systemtable,'for(variable-name = initial value:final value){expression}'#10);
       efi_console_output_string(systemtable,'while(statement){expression}'#10);
       efi_console_output_string(systemtable,'do{expression}while(statement)'#10);
       efi_console_output_string(systemtable,'switch(variable){case 0:{expression}break;...}'#10);
      end
     else if(WStrCmpL((cpstr.partstrlist+2)^,'readexe')=0) then
      begin
       efi_console_output_string(systemtable,'Read the executable file'#39's information'#10);
       efi_console_output_string(systemtable,'Usage:readexe <path> <relocation/stringtable/symboltable/hashtable/section<section name>>'#10);
      end
     else if(WStrCmpL((cpstr.partstrlist+2)^,'execute')=0) then
      begin
       efi_console_output_string(systemtable,'Execute the executable file.'#10);
       efi_console_output_string(systemtable,'Usage:execute <path> <parameters to executable file>'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'passwd')=0) and (WStrlen((cpstr.partstrlist+2)^)=6) then
      begin
       efi_console_output_string(systemtable,'Reset your current account'#39's password.'#10);
       efi_console_output_string(systemtable,'Usage:passwd'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'usrname')=0) and (Wstrlen((cpstr.partstrlist+2)^)=7) then
      begin
       efi_console_output_string(systemtable,'Reset your current account'#39's user name.'#10);
       efi_console_output_string(systemtable,'Usage:usrname'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'path')=0) and (WStrlen((cpstr.partstrlist+2)^)=4) then
      begin
       efi_console_output_string(systemtable,'Change your relative path.'#10);
       efi_console_output_string(systemtable,'. means your current path,.. means your previous level path,'#10);
       efi_console_output_string(systemtable,'other means your new path based on your relative path.'#10);
       efi_console_output_string(systemtable,'Usage:path <./../new path>'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'addusr')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use addusr when you are user manager.'#10);
       efi_console_output_string(systemtable,'Add a specified user to the TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sp addusr'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'delusr')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use delusr when you are user manager.'#10);
       efi_console_output_string(systemtable,'Delete a specified user to the TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sp delusr'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'lsuser')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use lsuser when you are user manager.'#10);
       efi_console_output_string(systemtable,'List all users of the TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sp lsuser'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'lsdisk')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use addusr when you are user manager.'#10);
       efi_console_output_string(systemtable,'List all available disks of the TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sp lsdisk'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'kerneldetect')=0) and (Wstrlen((cpstr.partstrlist+2)^)=12) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use kerneldetect when you are user manager.'#10);
       efi_console_output_string(systemtable,'Detect the kernel is vaild or invaild.'#10);
       efi_console_output_string(systemtable,'Usage:sp kerneldetect <path>'#10);
      end 
     else if(WStrcmp((cpstr.partstrlist+2)^,'kernelinstall')=0) and (Wstrlen((cpstr.partstrlist+2)^)=13) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use kernelinstall when you are user manager.'#10);
       efi_console_output_string(systemtable,'Install the vaild kernel to your computer and reboot after you do this.'#10);
       efi_console_output_string(systemtable,'Usage:sp kernelinstall <path>'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'logout')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
      begin
       efi_console_output_string(systemtable,'Log out your current account and then change to account you want to login.'#10);
       efi_console_output_string(systemtable,'Usage:logout'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'clearscreen')=0) and (Wstrlen((cpstr.partstrlist+2)^)=11) then
      begin
       efi_console_output_string(systemtable,'Clear the whole screen in console.'#10);
       efi_console_output_string(systemtable,'Usage:clearscreen'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'sysver')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
      begin
       efi_console_output_string(systemtable,'Show the system version of TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sysver'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'sysname')=0) and (Wstrlen((cpstr.partstrlist+2)^)=7) then
      begin
       efi_console_output_string(systemtable,'Show the system name of TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sysname'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'sysarch')=0) and (Wstrlen((cpstr.partstrlist+2)^)=7) then
      begin
       efi_console_output_string(systemtable,'Show the system CPU architecture of TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sysarch'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+2)^,'sysinfo')=0) and (Wstrlen((cpstr.partstrlist+2)^)=7) then
      begin
       efi_console_output_string(systemtable,'Show all system information of TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sysinfo'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'sysctl')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use sysctl when you are user manager.'#10);
       efi_console_output_string(systemtable,'Change the system option value to enable the function or disable it.'#10);
       efi_console_output_string(systemtable,'Usage:sp sysctl graphics/network/autodetectkernel disabled/enabled'#10);
      end 
     else
      begin
       efi_console_output_string(systemtable,'Command ');
       efi_console_output_string(systemtable,(cpstr.partstrlist+2)^);
       efi_console_output_string(systemtable,' unrecognized,'#10);
       efi_console_output_string(systemtable,'So please type vaild command to show help manual!'#10);
       efi_console_output_string(systemtable,'Vaild commands:sp reboot shutdown echo delay file shell readexe execute passwd usrname path'#10);
       efi_console_output_string(systemtable,'addusr delusr lsuser lsdisk kerneldetect kernelinstall logout help sysver sysname sysarch sysinfo sysctl'#10);
      end;
    end
   else if(cpstr.partstrnum>=2) then
    begin
     efi_console_output_string(systemtable,'Command ');
     efi_console_output_string(systemtable,(cpstr.partstrlist+1)^);
     efi_console_output_string(systemtable,' unrecognized!'#10);
    end
   else if(cpstr.partstrnum=1) then
    begin
     efi_console_output_string(systemtable,'sp must have one command after it to work!'#10);
    end;
  end
 else if(Wstrcmp(cpstr.partstrlist^,'sp')=0) and (Wstrlen(cpstr.partstrlist^)=2) then
  begin
   efi_console_output_string(systemtable,'User ');
   efi_console_output_string(systemtable,(sysinfo.userinfolist+sysindex-2)^.username);
   efi_console_output_string(systemtable,' is not user manager,so it is no use of command sp.'#10);
  end
 else
  begin
   if(Wstrcmp(cpstr.partstrlist^,'reboot')=0) and (Wstrlen(cpstr.partstrlist^)=6) then
    begin
     if(cpstr.partstrnum=1) then
      begin
       efi_console_output_string(systemtable,'The system will reboot in 20 seconds!'#10);
       Wstrfree(tydqcurrentpath); Wstrfree(tydqcurrentdiskname);
       SystemTable^.BootServices^.Stall(20000);
       SystemTable^.RuntimeServices^.ResetSystem(EfiResetWarm,efi_success,0,nil);
      end
     else if(cpstr.partstrnum>1) then
      begin
       efi_console_output_string(systemtable,'reboot doesn'#39't need any parameters!'#10);
      end;
    end
   else if(Wstrcmp(cpstr.partstrlist^,'shutdown')=0) and (Wstrlen(cpstr.partstrlist^)=8) then
    begin
     if(cpstr.partstrnum=1) then
      begin
       efi_console_output_string(systemtable,'The system will shut down in 20 seconds!'#10);
       Wstrfree(tydqcurrentpath); Wstrfree(tydqcurrentdiskname);
       SystemTable^.BootServices^.Stall(20000);
       SystemTable^.RuntimeServices^.ResetSystem(EfiResetShutDown,efi_success,0,nil);
      end
     else if(cpstr.partstrnum>1) then
      begin
       efi_console_output_string(systemtable,'shutdown doesn'#39't need any parameter!'#10);
      end;
    end
   else if(Wstrcmp(cpstr.partstrlist^,'echo')=0) and (Wstrlen(cpstr.partstrlist^)=4) then
    begin
     if(cpstr.partstrnum=2) then
      begin
       partstr:=Wstrcutout((cpstr.partstrlist+1)^,1,Wstrlen((cpstr.partstrlist+1)^));
       efi_console_output_string(systemtable,partstr);
       Wstrfree(partstr);
       efi_console_output_string(systemtable,#10);
      end
     else
      begin
       efi_console_output_string(systemtable,'echo doesn'#39't need two or more parameters or no parameter!'#10);
      end;
    end
   else if(Wstrcmp(cpstr.partstrlist^,'delay')=0) and (Wstrlen(cpstr.partstrlist^)=5) then
    begin
     if(cpstr.partstrnum<>2) then
      begin
       efi_console_output_string(systemtable,'delay must have only one parameter!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     partstr:=Wstrcutout((cpstr.partstrlist+1)^,sysindex,Wstrlen((cpstr.partstrlist+1)^)-1);
     partstr2:=Wstrcopy((cpstr.partstrlist+1)^,Wstrlen((cpstr.partstrlist+1)^),1);
     if(Wstrlen(partstr2)>1) then
      begin
       efi_console_output_string(systemtable,'The specified time unit must be h(hour) or m(minute) or s(second),not other units!'#10);
       Wstrfree(partstr2); Wstrfree(partstr); 
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end
     else if(PWCharIsInt(partstr)=false) then 
      begin
       efi_console_output_string(systemtable,'The specified time value must to be decimal number!'#10);
       Wstrfree(partstr2); Wstrfree(partstr);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     if(partstr2^='h') then
      begin
       procnum:=PWCharToUint(partstr)*3600;
      end
     else if(partstr2^='m') then
      begin
       procnum:=PWCharToUint(partstr)*60;
      end
     else if(partstr2^='s') then
      begin
       procnum:=PWCharToUint(partstr);
      end
     else
      begin
       efi_console_output_string(systemtable,'The specified time unit must be h(hour) or m(minute) or s(second),not other units!'#10);
       Wstrfree(partstr2);
       Wstrfree(partstr);
       exit;
      end;
     SystemTable^.BootServices^.Stall(procnum*1000);
     Wstrfree(partstr2);
     Wstrfree(partstr);
    end
   else if(WStrcmp(cpstr.partstrlist^,'file')=0) and (Wstrlen(cpstr.partstrlist^)=4) then
    begin
     if(cpstr.partstrnum<=2) then
      begin
       efi_console_output_string(systemtable,'file must have one vaild command!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     if(Wstrcmp((cpstr.partstrlist+1)^,'create')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
      begin
       if(cpstr.partstrnum>4) then
        begin
         efi_console_output_string(systemtable,'file create must have one path and at least one type!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       if(tydq_fs_legal_filename(partstr5)) and (tydq_fs_legal_length_filename(partstr5)) then
        begin
         attributes:=0; shared:=false; Wstrfree(partstr5);
         for j:=4 to cpstr.partstrnum do
          begin
           if(Wstrcmp((cpstr.partstrlist+j-1)^,'folder')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_folder; 
            end
           else if(Wstrcmp((cpstr.partstrlist+j-1)^,'normal')=0) and (WStrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_normal_file; 
            end
           else if(WStrcmp((cpstr.partstrlist+j-1)^,'system')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_system_file; 
            end
           else if(WStrcmp((cpstr.partstrlist+j-1)^,'hidden')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_hidden_file; 
            end
           else if(WStrcmp((cpstr.partstrlist+j-1)^,'link')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=4) then
            begin
             attributes:=attributes or tydqfs_link_file; 
            end
           else if(Wstrcmp((cpstr.partstrlist+j-1)^,'text')=0) and (WStrlen((cpstr.partstrlist+j-1)^)=4) then
            begin
             attributes:=attributes or tydqfs_text_file; 
            end
           else if(Wstrcmp((cpstr.partstrlist+j-1)^,'binary')=0) and (WStrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_binary_file; 
            end
           else if(Wstrcmp((cpstr.partstrlist+j-1)^,'shared')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then
            begin
             shared:=true;
            end;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=true) then
          begin
           efi_console_output_string(systemtable,'Error:A file could not to be both normal file and system file.'#10);
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=false) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=false) then
          begin
           efi_console_output_string(systemtable,'Error:A file must be a normal file or system file.'#10);
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) then
          begin
           efi_console_output_string(systemtable,'Error:A file cannot be system file in normal mode.'#10);
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         procnum:=0;
         if(tydq_fs_byte_to_attribute_bool(attributes)[8]=true) then procnum:=1;
         for j:=4 downto 1 do if(tydq_fs_byte_to_attribute_bool(attributes)[j]=true) then inc(procnum);
         if(procnum>1) and (procnum=0) then
          begin
           efi_console_output_string(systemtable,'Error:A file could not be two or more main type or no type.'#10);
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         tydq_fs_create_file(systemtable,edl,procnum,partstr,attributes,userlevel_user,sysindex);
         if(tydq_fs_byte_to_attribute_bool(attributes)[4]=true) then 
          begin
           efi_console_output_string(systemtable,'Type the path you want to link to:');
           efi_console_read_string(systemtable,partstr2);
           partstr6:=tydq_fs_locate_fullpath(edl,partstr2);
           procnum2:=tydq_fs_locate_diskindex(edl,partstr2);
           while(tydq_fs_file_exists(edl,procnum,partstr6)=false) do
            begin
             efi_console_output_string(systemtable,'Error:file linked does not exist.'#10);
             efi_console_output_string(systemtable,'Type the path you want to link to:');
             efi_console_read_string(systemtable,partstr2);
             partstr6:=tydq_fs_locate_fullpath(edl,partstr2);
             procnum2:=tydq_fs_locate_diskindex(edl,partstr2);
            end;
           fsh:=tydq_fs_read_header(edl,procnum2);
           Wstrinit(partstr,16640); Wstrset(partstr,@fsh.RootName); Wstrcat(partstr,'/'); Wstrcat(partstr,partstr6);
           if(shared) then tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr))*2,userlevel_user,sysindex)
           else tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr))*2,userlevel_user,0);
           Wstrfree(partstr6);
          end;
         Wstrfree(partstr5);
         freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
        end
       else
        begin
         if(tydq_fs_legal_filename(partstr5)=false) then
         efi_console_output_string(systemtable,'Error:file name is illegal(?,*,$,{,},(,),@,#,^ or % are illegal)..'#10)
         else if(tydq_fs_legal_length_filename(partstr5)=false) then
         efi_console_output_string(systemtable,'Error:file name length is illegal(length must not exceed 255 and lower to 0).'#10);
         Wstrfree(partstr5);
         freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'list')=0) and (WStrlen((cpstr.partstrlist+1)^)=4) then
      begin
       if(cpstr.partstrnum<>2) and (cpstr.partstrnum<>3) and (cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file list must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       haveextraparam:=false;
       if(cpstr.partstrnum=4) then
        begin
         partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
         procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
         if(Wstrcmp((cpstr.partstrlist+3)^,'detecthidden')=0) and (Wstrlen((cpstr.partstrlist+3)^)=12) then
          begin
           haveextraparam:=true;
          end;
        end
       else if(cpstr.partstrnum=3) then
        begin
         if(Wstrcmp((cpstr.partstrlist+2)^,'detecthidden')=0) and (Wstrlen((cpstr.partstrlist+2)^)=12) then
          begin
           haveextraparam:=true;
          end
         else
          begin
           partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
           procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
          end;
        end
       else if(cpstr.partstrnum=2) then
        begin
         partstr5:=tydq_fs_locate_fullpath(edl,nil);
         procnum:=tydq_fs_locate_diskindex(edl,nil);
        end;
       fsfl:=tydq_fs_list_file(edl,procnum,partstr5,false,haveextraparam,sysindex);
       for i:=1 to fsfl.files_count do 
        begin
         partstr4:=tydq_combine_path_and_filename((fsfl.files_basepath+i-1)^,(fsfl.files_content+i-1)^);
         efi_console_output_string(systemtable,partstr4);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr4);
        end;
      size:=0;
       for i:=fsfl.files_count downto 1 do
        begin
         if(i<fsfl.files_count) then size:=size+getmemsize((fsfl.files_content+i-1)^)+getmemsize((fsfl.files_basepath+i-1)^);
         Wstrfree((fsfl.files_content+i-1)^); Wstrfree((fsfl.files_basepath+i-1)^);
        end;
       fsfl.files_content:=fsfl.files_content-size; fsfl.files_basepath:=fsfl.files_content-size;
       freemem(fsfl.files_content); freemem(fsfl.files_basepath); fsfl.files_count:=0;
       Wstrfree(partstr3); Wstrfree(partstr2); Wstrfree(partstr); Wstrfree(partstr5);
       freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'tree')=0) and (WStrlen((cpstr.partstrlist+1)^)=4) then
      begin
       if(cpstr.partstrnum<>2) and (cpstr.partstrnum<>3) and (cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file list must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       haveextraparam:=false;
       if(cpstr.partstrnum=4) then
        begin
         partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
         procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
         if(Wstrcmp((cpstr.partstrlist+3)^,'detecthidden')=0) and (Wstrlen((cpstr.partstrlist+3)^)=12) then
          begin
           haveextraparam:=true;
          end;
        end
       else if(cpstr.partstrnum=3) then
        begin
         if(Wstrcmp((cpstr.partstrlist+2)^,'detecthidden')=0) and (Wstrlen((cpstr.partstrlist+2)^)=12) then
          begin
           haveextraparam:=true;
          end
         else
          begin
           partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
           procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
          end;
        end
       else if(cpstr.partstrnum=2) then
        begin
         partstr5:=tydq_fs_locate_fullpath(edl,nil);
         procnum:=tydq_fs_locate_diskindex(edl,nil);
        end;
       fsfl:=tydq_fs_list_file(edl,procnum,partstr5,true,haveextraparam,sysindex);
       for i:=1 to fsfl.files_count do 
        begin
         partstr4:=tydq_combine_path_and_filename((fsfl.files_basepath+i-1)^,(fsfl.files_content+i-1)^);
         efi_console_output_string(systemtable,partstr4);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr4);
        end;
       size:=0;
       for i:=fsfl.files_count downto 1 do
        begin
         if(i<fsfl.files_count) then size:=size+getmemsize((fsfl.files_content+i-1)^)+getmemsize((fsfl.files_basepath+i-1)^);
         Wstrfree((fsfl.files_content+i-1)^); Wstrfree((fsfl.files_basepath+i-1)^);
        end;
       fsfl.files_content:=fsfl.files_content-size; fsfl.files_basepath:=fsfl.files_content-size;
       freemem(fsfl.files_content); freemem(fsfl.files_basepath); fsfl.files_count:=0;
       Wstrfree(partstr3); Wstrfree(partstr2); Wstrfree(partstr); Wstrfree(partstr5);
       freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'info')=0) and (Wstrlen((cpstr.partstrlist+1)^)=4) then
      begin
       if(cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file info must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_disk_index(edl,(cpstr.partstrlist+2)^);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_user,sysindex);
       if(tydq_fs_file_exists(edl,procnum,(cpstr.partstrlist+2)^)=false) then
        begin
         efi_console_output_string(systemtable,'Error:File does not exist.'#10);
        end
       else if(fsf.fattribute=0) then
        begin
         efi_console_output_string(systemtable,'Error:File could not be accessed.'#10);
        end
       else 
        begin
         efi_console_output_string(systemtable,'File ');
         efi_console_output_string(systemtable,@fsf.fName);
         efi_console_output_string(systemtable,':'#10);
         efi_console_output_string(systemtable,'Attribute:');
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) then
          begin
           efi_console_output_string(systemtable,'Folder ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[7]=true) then
          begin
           efi_console_output_string(systemtable,'Normal ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) then
          begin
           efi_console_output_string(systemtable,'System ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[5]=true) then
          begin
           efi_console_output_string(systemtable,'Hidden ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[4]=true) then
          begin
           efi_console_output_string(systemtable,'Link ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[3]=true) then
          begin
           efi_console_output_string(systemtable,'Text ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[2]=true) then
          begin
           efi_console_output_string(systemtable,'Binary ');
          end;
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[1]=true) then
          begin
           efi_console_output_string(systemtable,'Executable ');
          end;
         efi_console_output_string(systemtable,#10);
         efi_console_output_string(systemtable,'The file belongs to:');
         if(fsf.fbelonguserindex=0) then
          begin
           efi_console_output_string(systemtable,'Shared'#10);
          end
         else if(fsf.fbelonguserindex=1) then
          begin
           efi_console_output_string(systemtable,'System'#10);
          end
         else if(fsf.fbelonguserindex=2) then
          begin
           efi_console_output_string(systemtable,(sysinfo.userinfolist+fsf.fbelonguserindex-2)^.username);
           efi_console_output_string(systemtable,#10);
          end;
         efi_console_output_string(systemtable,'Created Time:');
         partstr:=tydq_time_to_string(fsf.fcreatetime);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr);
         efi_console_output_string(systemtable,'Last Edit Time:');
         partstr:=tydq_time_to_string(fsf.flastedittime);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr);
        end;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'copy')=0) and (Wstrlen((cpstr.partstrlist+1)^)=4) then
      begin
       if(cpstr.partstrnum<>5) then
        begin
         efi_console_output_string(systemtable,'file copy must have only two paths!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       partstr7:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum5:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       procnum3:=Wstrpos(partstr5,'*',sysindex); procnum4:=Wstrpos(partstr5,'?',sysindex);
       if(procnum4>0) and (procnum3>procnum4) then procnum2:=Wstrposdir(partstr5,'/',procnum4,-1)
       else if(procnum3>0) and (procnum4>procnum3) then procnum2:=Wstrposdir(partstr5,'/',procnum3,-1)
       else if(procnum4>0) and (procnum3=0) then procnum2:=Wstrposdir(partstr5,'/',procnum4,-1)
       else if(procnum3>0) and (procnum4=0) then procnum2:=Wstrposdir(partstr5,'/',procnum3,-1)
       else procnum2:=Wstrposdir(partstr5,'/',Wstrlen(partstr5),-1);
       if(procnum2=1) then partstr6:=Wstrcutout(partstr5,sysindex,sysindex) else partstr6:=Wstrcutout(partstr5,sysindex,procnum2-1);
       if(Wstrcmp((cpstr.partstrlist+3)^,'judgehidden')=0) and (Wstrlen((cpstr.partstrlist+3)^)=11) then judgehidden:=true else judgehidden:=false;
       fsfl:=tydq_fs_list_file(edl,procnum,partstr6,false,judgehidden,sysindex);
       for i:=1 to fsfl.files_count do 
        begin
         partstr4:=tydq_combine_path_and_filename((fsfl.files_basepath+i-1)^,(fsfl.files_content+i-1)^);
         if(PWCharMatchMask(partstr4,partstr5)) then 
          begin
           fsf:=tydq_fs_file_info(edl,procnum,partstr4,userlevel_user,sysindex);
           Wstrinit(partstr,16384);
           procnum6:=Wstrposdir(partstr4,'/',Wstrlen(partstr4),-1);
           partstr2:=Wstrcutout(partstr4,procnum6,Wstrlen(partstr4));
           Wstrset(partstr,partstr7); Wstrcat(partstr,partstr2);
           if(fsf.fbelonguserindex=0) then
           tydq_fs_create_file(systemtable,edl,procnum5,partstr,fsf.fattribute,userlevel_user,0)
           else if(fsf.fbelonguserindex=1) then
           tydq_fs_create_file(systemtable,edl,procnum5,partstr,fsf.fattribute,userlevel_user,sysindex)
           else if(fsf.fbelonguserindex=sysindex) then
           tydq_fs_create_file(systemtable,edl,procnum5,partstr,fsf.fattribute,userlevel_user,fsf.fbelonguserindex);
           data:=tydq_fs_file_read(edl,procnum,partstr5,sysindex,fsf.fContentCount,userlevel_user,sysindex);
           tydq_fs_file_rewrite(systemtable,edl,procnum5,partstr,data.fsdata,data.fssize,userlevel_user,sysindex);
           freemem(data.fsdata); data.fssize:=0; Wstrfree(partstr2); Wstrfree(partstr);
          end;
         Wstrfree(partstr4);
        end;
       size:=0;
       for i:=fsfl.files_count downto 1 do
        begin
         if(i<fsfl.files_count) then size:=size+getmemsize((fsfl.files_content+i-1)^)+getmemsize((fsfl.files_basepath+i-1)^);
         Wstrfree((fsfl.files_content+i-1)^); Wstrfree((fsfl.files_basepath+i-1)^);
        end;
       fsfl.files_content:=fsfl.files_content-size; fsfl.files_basepath:=fsfl.files_content-size;
       freemem(fsfl.files_content); freemem(fsfl.files_basepath); fsfl.files_count:=0;
       Wstrfree(partstr6); Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'delete')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
      begin
       if(cpstr.partstrnum<>4) and (cpstr.partstrnum<>5) then
        begin
         efi_console_output_string(systemtable,'file delete must have only one path or one path and one switch!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       procnum3:=Wstrpos(partstr5,'*',sysindex); procnum4:=Wstrpos(partstr5,'?',sysindex);
       if(procnum4>0) and (procnum3>procnum4) then procnum2:=Wstrposdir(partstr5,'/',procnum4,-1)
       else if(procnum3>0) and (procnum4>procnum3) then procnum2:=Wstrposdir(partstr5,'/',procnum3,-1)
       else if(procnum4>0) and (procnum3=0) then procnum2:=Wstrposdir(partstr5,'/',procnum4,-1)
       else if(procnum3>0) and (procnum4=0) then procnum2:=Wstrposdir(partstr5,'/',procnum3,-1)
       else procnum2:=Wstrposdir(partstr5,'/',Wstrlen(partstr5),-1);
       if(procnum2=1) then partstr6:=Wstrcutout(partstr5,sysindex,sysindex) else partstr6:=Wstrcutout(partstr5,sysindex,procnum2-1);
       if(Wstrcmp((cpstr.partstrlist+3)^,'judgehidden')=0) and (Wstrlen((cpstr.partstrlist+3)^)=11) then judgehidden:=true else judgehidden:=false;
       fsfl:=tydq_fs_list_file(edl,procnum,partstr6,false,judgehidden,sysindex);
       for i:=1 to fsfl.files_count do 
        begin
         partstr4:=tydq_combine_path_and_filename((fsfl.files_basepath+i-1)^,(fsfl.files_content+i-1)^);
         if(PWCharMatchMask(partstr4,partstr5)) then tydq_fs_delete_file(edl,procnum,partstr4,userlevel_user,sysindex);
         Wstrfree(partstr4);
        end;
       size:=0;
       for i:=fsfl.files_count downto 1 do
        begin
         if(i<fsfl.files_count) then size:=size+getmemsize((fsfl.files_content+i-1)^)+getmemsize((fsfl.files_basepath+i-1)^);
         Wstrfree((fsfl.files_content+i-1)^); Wstrfree((fsfl.files_basepath+i-1)^);
        end;
       fsfl.files_content:=fsfl.files_content-size; fsfl.files_basepath:=fsfl.files_content-size;
       freemem(fsfl.files_content); freemem(fsfl.files_basepath); fsfl.files_count:=0;
       Wstrfree(partstr6); Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'exist')=0) and (Wstrlen((cpstr.partstrlist+1)^)=5) then
      begin
       if(cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file exist must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       fileexists:=tydq_fs_file_exists(edl,procnum,partstr5);
       if(fileexists) then efi_console_output_string(systemtable,'File exists!'#10) else efi_console_output_string(systemtable,'File does not exist!'#10);
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'edit')=0) and (Wstrlen((cpstr.partstrlist+1)^)=4) then
      begin
       if(cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file edit must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       if(tydq_fs_file_exists(edl,procnum,partstr5)) then
        begin
         partstr:=nil;
         Wstrinit(partstr2,16640); 
         partstr3:=tydq_fs_disk_name(edl,procnum);
         Wstrset(partstr2,partstr3);
         Wstrcat(partstr2,partstr5);
         fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_user,sysindex);
         data:=tydq_fs_file_read(edl,procnum,partstr5,sysindex,fsf.fContentCount,userlevel_user,sysindex);
         partstr:=PWideChar(data.fsdata);
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[3]=true) and (tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=false) then
          begin
           efi_console_edit_text_file_content_string(systemtable,partstr,partstr2);
           tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr))*2,userlevel_user,sysindex);
          end
         else
          begin
           if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) then
           efi_console_output_string(systemtable,'File cannot to be accessed,permission denied.'#10)
           else if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[3]=false) then
           efi_console_output_string(systemtable,'File is not text file,it cannot be edited.'#10)
          end;
         Wstrfree(partstr); data.fssize:=0; Wstrfree(partstr3); Wstrfree(partstr2); 
        end
       else
        begin
         efi_console_output_string(systemtable,'File does not exist,so cannot edit the content of the file!'#10);
        end;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WstrCmp((cpstr.partstrlist+1)^,'edithex')=0) and (Wstrlen((cpstr.partstrlist+1)^)=7) then
      begin
       if(cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file edithex must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       data.fsdata:=nil; data.fssize:=0;
       if(tydq_fs_file_exists(edl,procnum,partstr5)) then
        begin
         Wstrinit(partstr2,16640); 
         partstr3:=tydq_fs_disk_name(edl,procnum);
         Wstrset(partstr2,partstr3);
         Wstrcat(partstr2,partstr5);
         fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_user,sysindex);
         data:=tydq_fs_file_read(edl,procnum,partstr5,sysindex,fsf.fContentCount,userlevel_user,sysindex);
         if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[2]=true) and (tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=false) then
          begin
           efi_console_edit_hex_content_string(systemtable,data.fsdata,data.fssize,partstr2);
           tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,data.fsdata,data.fssize,userlevel_user,sysindex);
          end
         else
          begin
           if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) then
           efi_console_output_string(systemtable,'File cannot to be accessed,permission denied.'#10)
           else if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[3]=false) then
           efi_console_output_string(systemtable,'File is not binary file,it cannot be edited.'#10)
          end;
         freemem(data.fsdata); data.fssize:=0; Wstrfree(partstr3); Wstrfree(partstr2);
        end
       else
        begin
         efi_console_output_string(systemtable,'File does not exist,so cannot edit the hex in the file!'#10);
        end;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'createandedit')=0) and (WStrlen((cpstr.partstrlist+1)^)=13) then
      begin
       if(cpstr.partstrnum>=3) and (cpstr.partstrnum<=5) then
        begin
         efi_console_output_string(systemtable,'file createandedit must have only one path or one path and maximum two types!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       if(tydq_fs_legal_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name is illegal(?,*,$,{,},(,),@,#,^ or % are illegal).'#10)
       else if(tydq_fs_legal_length_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name length is illegal(length must not exceed 255 and lower to 0).'#10);
       if(tydq_fs_legal_filename(partstr5)=false) or (tydq_fs_legal_length_filename(partstr5)=false) then
        begin
         Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       if(tydq_fs_file_exists(edl,procnum,partstr5)=false) then
        begin
         attributes:=tydqfs_text_file; shared:=false;
         for i:=4 to cpstr.partstrnum do
          begin
           if(WStrcmp((cpstr.partstrlist+i-1)^,'normal')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_normal_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'system')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_system_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'hidden')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_hidden_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'shared')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             shared:=true;
            end;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=true) then
          begin
           efi_console_output_string(systemtable,'file created must not to be both normal and system file!'#10);
           Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=false) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=false) then
          begin
           efi_console_output_string(systemtable,'file created must be normal or system file!'#10);
           Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) then
          begin
           efi_console_output_string(systemtable,'You cannot create system file,permission denied.'#10);
           Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(shared) then tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_user,0)
         else tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_user,sysindex);
        end;
       partstr:=nil;
       Wstrinit(partstr2,16640); 
       partstr3:=tydq_fs_disk_name(edl,procnum);
       Wstrset(partstr2,partstr3);
       Wstrcat(partstr2,partstr5);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_user,sysindex);
       data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_user,sysindex);
       partstr:=PWideChar(data.fsdata);
       efi_console_edit_text_file_content_string(systemtable,partstr,partstr2);
       tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr)+1)*2,userlevel_user,sysindex);
       Wstrfree(partstr); data.fssize:=0; Wstrfree(partstr3); Wstrfree(partstr2); 
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'createandedithex')=0) and (WStrlen((cpstr.partstrlist+1)^)=16) then
      begin
       if(cpstr.partstrnum>=3) and (cpstr.partstrnum<=5) then
        begin
         efi_console_output_string(systemtable,'file createandedithex must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       if(tydq_fs_legal_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name is illegal(?,*,$,{,},(,),@,#,^ or % are illegal).'#10)
       else if(tydq_fs_legal_length_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name length is illegal(length must not exceed 255 and lower to 0).'#10);
       if(tydq_fs_legal_filename(partstr5)=false) or (tydq_fs_legal_length_filename(partstr5)=false) then
        begin
         Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       if(tydq_fs_file_exists(edl,procnum,partstr5)=false) then
        begin
         attributes:=tydqfs_binary_file; shared:=false;
         for i:=4 to cpstr.partstrnum do
          begin
           if(WStrcmp((cpstr.partstrlist+i-1)^,'normal')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_normal_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'system')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_system_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'hidden')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             attributes:=attributes or tydqfs_hidden_file;
            end
           else if(WStrcmp((cpstr.partstrlist+i-1)^,'shared')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=6) then
            begin
             shared:=true;
            end;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=true) then
          begin
           efi_console_output_string(systemtable,'file created must not to be both normal and system file!'#10);
           Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=false) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=false) then
          begin
           efi_console_output_string(systemtable,'file created must be normal or system file!'#10);
           Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) then
          begin
           efi_console_output_string(systemtable,'You cannot create system file,permission denied.'#10);
           Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
           for i:=cpstr.partstrnum downto 1 do
            begin
             Wstrfree((cpstr.partstrlist+i-1)^);
            end;
           freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
           exit;
          end;
         if(shared) then tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_user,0)
         else tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_user,sysindex);
        end;
       data.fsdata:=nil; data.fssize:=0;
       Wstrinit(partstr2,16640); 
       partstr3:=tydq_fs_disk_name(edl,procnum);
       Wstrset(partstr2,partstr3);
       Wstrcat(partstr2,partstr5);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_system,sysindex);
       data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_user,sysindex);
       efi_console_edit_hex_content_string(systemtable,data.fsdata,data.fssize,partstr2);
       tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,data.fsdata,data.fssize,userlevel_user,sysindex);
       freemem(data.fsdata); data.fssize:=0; Wstrfree(partstr3); Wstrfree(partstr2);
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'showtext')=0) and (Wstrlen((cpstr.partstrlist+1)^)=8) then
      begin
       if(cpstr.partstrnum<=2) then
        begin
         efi_console_output_string(systemtable,'file showtext must have a file path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_user,sysindex);
       if(tydq_fs_file_exists(edl,procnum,partstr5)=false) or (tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=false) or 
       (tydq_fs_byte_to_attribute_bool(fsf.fattribute)[3]=false) then
        begin
         if(tydq_fs_file_exists(edl,procnum,partstr5)=false) then efi_console_output_string(systemtable,'file showtext must have a vaild file path!'#10)
         else if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=false) then efi_console_output_string(systemtable,'file is system file,permission denied!'#10)
         else if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[3]=false) then efi_console_output_string(systemtable,'file is not text file!'#10);
         Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       data.fsdata:=nil; data.fssize:=0;
       data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_user,sysindex);
       partstr2:=PWideChar(data.fsdata);
       procnum2:=1; procnum3:=Wstrcount(partstr,#10,1)+1;
       for i:=4 to cpstr.partstrnum do 
        begin
         if(Wstrcmp('startline',(cpstr.partstrlist+i-1)^)=0) and (Wstrlen((cpstr.partstrlist+i-1)^)>9) then
          begin
           partstr:=Wstrcutout((cpstr.partstrlist+i-1)^,10,Wstrlen((cpstr.partstrlist+i-1)^));
           procnum2:=PWCharToUint(partstr);
           Wstrfree(partstr);
          end
         else if(Wstrcmp('endline',(cpstr.partstrlist+i-1)^)=0) and (Wstrlen((cpstr.partstrlist+i-1)^)>7) then
          begin
           partstr:=Wstrcutout((cpstr.partstrlist+i-1)^,8,Wstrlen((cpstr.partstrlist+i-1)^));
           procnum3:=PWCharToUint(partstr);
           Wstrfree(partstr);
          end;
        end;
       procnum4:=Wstrposorder(partstr2,#10,1,procnum2-1)+1;
       procnum6:=Wstrposorder(partstr2,#10,1,procnum3-1)-1;
       i:=procnum4;
       while(i<=procnum6) do
        begin
         j:=Wstrpos(partstr2,#10,procnum4);
         partstr3:=Wstrcutout(partstr2,i,j-1);
         efi_console_output_string(systemtable,partstr3);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr3);
         if(j>procnum6) then break;
         i:=j+1;
        end;
       freemem(data.fsdata); data.fssize:=0;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'showhex')=0) and (Wstrlen((cpstr.partstrlist+1)^)=7) then
      begin
       if(cpstr.partstrnum<=2) then
        begin
         efi_console_output_string(systemtable,'file showhex must have a file path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_user,sysindex);
       if(tydq_fs_file_exists(edl,procnum,partstr5)=false) or (tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=false) then
        begin
         if(tydq_fs_file_exists(edl,procnum,partstr5)=false) then efi_console_output_string(systemtable,'file showhex must have a vaild file path!'#10)
         else if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=false) then efi_console_output_string(systemtable,'file is system file,permission denied!'#10);
         Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
       data.fsdata:=nil; data.fssize:=0;
       data:=tydq_fs_file_read(edl,procnum,partstr5,1,fsf.fContentCount,userlevel_user,sysindex);
       partstr2:=PWideChar(data.fsdata);
       procnum2:=1; procnum3:=data.fssize;
       for i:=4 to cpstr.partstrnum do 
        begin
         if(Wstrcmp('startoffset',(cpstr.partstrlist+i-1)^)=0) and (Wstrlen((cpstr.partstrlist+i-1)^)>9) then
          begin
           partstr:=Wstrcutout((cpstr.partstrlist+i-1)^,10,Wstrlen((cpstr.partstrlist+i-1)^));
           procnum2:=PWCharToUint(partstr);
           Wstrfree(partstr);
          end
         else if(Wstrcmp('endoffset',(cpstr.partstrlist+i-1)^)=0) and (Wstrlen((cpstr.partstrlist+i-1)^)>7) then
          begin
           partstr:=Wstrcutout((cpstr.partstrlist+i-1)^,8,Wstrlen((cpstr.partstrlist+i-1)^));
           procnum3:=PWCharToUint(partstr);
           Wstrfree(partstr);
          end;
        end;
       i:=procnum2; j:=1;
       for i:=procnum2 to procnum3 do
        begin
         j:=i-procnum2+1;
         partstr3:=UintToWHex((data.fsdata+i-1)^);
         if(Wstrlen(partstr3)=1) then
          begin
           efi_console_output_string(systemtable,'0');
           efi_console_output_string(systemtable,partstr3);
          end
         else if(Wstrlen(partstr3)=2) then
          begin
           efi_console_output_string(systemtable,partstr3);
          end;
         efi_console_output_string(systemtable,' ');
         if(j mod (maxcolumn div 3)=0) then efi_console_output_string(systemtable,#10);
        end;
       freemem(data.fsdata); data.fssize:=0;
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
      end
     else if(WStrCmp((cpstr.partstrlist+1)^,'createlink')=0) and (Wstrlen((cpstr.partstrlist+1)^)=10) then
      begin
       if(cpstr.partstrnum<>5) then
        begin
         efi_console_output_string(systemtable,'file createlink must have only two paths!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       if(tydq_fs_legal_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name is illegal(?,*,$,{,},(,),@,#,^ or % are illegal).'#10)
       else if(tydq_fs_legal_length_filename(partstr5)=false) then
       efi_console_output_string(systemtable,'Error:file name length is illegal(length must not exceed 255 and lower to 0).'#10);
       if(tydq_fs_legal_filename(partstr5)=false) or (tydq_fs_legal_length_filename(partstr5)=false) then
        begin
         Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       partstr6:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum2:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       attributes:=tydqfs_link_file; shared:=false;
       for j:=6 to cpstr.partstrnum do
        begin
         if(Wstrcmp((cpstr.partstrlist+j-1)^,'normal')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then 
          begin
           attributes:=attributes or tydqfs_normal_file;
          end;
         if(Wstrcmp((cpstr.partstrlist+j-1)^,'system')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then 
          begin
           attributes:=attributes or tydqfs_system_file;
          end;
         if(Wstrcmp((cpstr.partstrlist+j-1)^,'hidden')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then 
          begin
           attributes:=attributes or tydqfs_hidden_file;
          end;
         if(Wstrcmp((cpstr.partstrlist+j-1)^,'shared')=0) and (Wstrlen((cpstr.partstrlist+j-1)^)=6) then shared:=true;
        end;
       if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) and (tydq_fs_byte_to_attribute_bool(attributes)[7]=true) then
        begin
         efi_console_output_string(systemtable,'Error:The link file could not to be both system and normal type!'#10);
         Wstrfree(partstr6); Wstrfree(partstr5); 
         freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       if(tydq_fs_byte_to_attribute_bool(attributes)[6]=true) then
        begin
         efi_console_output_string(systemtable,'Error:normal user cannot create a system link file!'#10);
         Wstrfree(partstr6); Wstrfree(partstr5); 
         freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       if(shared) then tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_user,sysindex)
       else tydq_fs_create_file(systemtable,edl,procnum,partstr5,attributes,userlevel_user,0);
       fsh:=tydq_fs_read_header(edl,procnum2);
       Wstrinit(partstr,16640); Wstrset(partstr,@fsh.RootName); Wstrcat(partstr,'/'); Wstrcat(partstr,partstr6);
       tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr))*2,userlevel_user,sysindex);
       Wstrfree(partstr); Wstrfree(partstr6); Wstrfree(partstr5); 
       freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
      end
     else if(WStrCmp((cpstr.partstrlist+1)^,'openlink')=0) and (Wstrlen((cpstr.partstrlist+1)^)=8) then
      begin
       if(cpstr.partstrnum<>5) then
        begin
         efi_console_output_string(systemtable,'file openlink must have only one path!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_user,sysindex);
       if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) then
        begin
         efi_console_output_string(systemtable,'Error:normal user cannot access to,permission denied!'#10);
         Wstrfree(partstr6); Wstrfree(partstr5); 
         freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       data:=tydq_fs_file_read(edl,procnum,partstr5,sysindex,fsf.fContentCount,userlevel_user,sysindex);
       if(tydq_fs_file_exists(edl,procnum,PWideChar(data.fsdata))=false) then
        begin
         efi_console_output_string(systemtable,'It is a best choice to delete the invaild link.'#10);
         efi_console_output_string(systemtable,'Do you agree to delete(Y or y is yes,other is no?'#10);
         efi_console_read_string(systemtable,partstr);
         if((Wstrcmp(partstr,'Y')=0) or (Wstrcmp(partstr,'y')=0)) and (Wstrlen(partstr)=1) then
          begin
           tydq_fs_delete_file(edl,procnum,partstr5,userlevel_user,sysindex);
          end;
        end
       else
        begin
         partstr6:=tydq_fs_locate_fullpath(edl,PWideChar(data.fsdata));
         procnum2:=tydq_fs_locate_diskindex(edl,PWideChar(data.fsdata));
         fsh:=tydq_fs_read_header(edl,procnum2);
         Wstrset(tydqcurrentdiskname,@fsh.RootName);
         Wstrset(tydqcurrentpath,partstr6);
        end;
       Wstrfree(partstr6); Wstrfree(partstr5); 
       freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'resetlink')=0) and (Wstrlen((cpstr.partstrlist+1)^)=9) then
      begin
       if(cpstr.partstrnum<>4) then
        begin
         efi_console_output_string(systemtable,'file resetlink must have only two paths!'#10);
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
       partstr6:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+3)^);
       procnum2:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+3)^);
       fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_user,sysindex);
       if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) then
        begin
         efi_console_output_string(systemtable,'Error:normal user cannot access to,permission denied!'#10);
         Wstrfree(partstr6); Wstrfree(partstr5); 
         freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
         for i:=cpstr.partstrnum downto 1 do
          begin
           Wstrfree((cpstr.partstrlist+i-1)^);
          end;
         freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
         exit;
        end;
       fsh:=tydq_fs_read_header(edl,procnum2);
       Wstrinit(partstr,16640); Wstrset(partstr,@fsh.RootName); Wstrcat(partstr,partstr6);
       tydq_fs_file_rewrite(systemtable,edl,procnum,partstr5,partstr,(Wstrlen(partstr))*2,userlevel_user,sysindex);
       Wstrfree(partstr); Wstrfree(partstr6); Wstrfree(partstr5); 
       freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
      end
     else
      begin
       efi_console_output_string(systemtable,'Command ');
       efi_console_output_string(systemtable,(cpstr.partstrlist+1)^);
       efi_console_output_string(systemtable,' after the command file unrecognized.'#10);
       efi_console_output_string(systemtable,'Vaild commands can be searched in help manual.'#10);
      end;
    end
   else if(WStrCmpL((cpstr.partstrlist+1)^,'shell')=0) then
    begin
     if(cpstr.partstrnum<2) then 
      begin
       efi_console_output_string(systemtable,'shell must have at least one path!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     edl:=efi_disk_tydq_get_fs_list(systemtable);
     for i:=2 to cpstr.partstrnum do
      begin
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+i-1)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+i-1)^);
       shell_execute_code(systemtable,edl,procnum,partstr5,userlevel_system,sysinfo,sysindex);
       Wstrfree(partstr5);
      end;
     freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
    end
   else if(WstrcmpL(cpstr.partstrlist^,'readexe')=0) then
    begin
     if(cpstr.partstrnum<2) then 
      begin
       efi_console_output_string(systemtable,'readexe must have one path!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     edl:=efi_disk_tydq_get_fs_list(systemtable);
     partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
     procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
     fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_user,sysindex);
     if(fsf.fattribute=0) then
      begin
       efi_console_output_string(systemtable,'readexe failed,permission denied.'#10);
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     fse:=tydq_fs_read_executable(edl,procnum,partstr5,userlevel_user,sysindex);
     relocationshow:=false; stringtableshow:=false; symboltableshow:=false; hashtableshow:=false; sectionshowall:=false;
     sectionshow:=nil; sectionshownum:=0;
     for i:=3 to cpstr.partstrnum do
      begin
       if(WstrcmpL((cpstr.partstrlist+i-1)^,'relocation')=0) then relocationshow:=true
       else if(WstrcmpL((cpstr.partstrlist+i-1)^,'stringtable')=0) then stringtableshow:=true
       else if(WstrcmpL((cpstr.partstrlist+i-1)^,'symboltable')=0) then symboltableshow:=true
       else if(WstrcmpL((cpstr.partstrlist+i-1)^,'hashtable')=0) then hashtableshow:=true
       else if(WStrcmp((cpstr.partstrlist+i-1)^,'section')=0) and (Wstrlen((cpstr.partstrlist+i-1)^)=7) then sectionshowall:=true
       else if(WstrcmpL((cpstr.partstrlist+i-1)^,'section')=0) then
        begin
         procnum2:=Wstrlen((cpstr.partstrlist+i-1)^)-7;
         partstr:=Wstrcopy((cpstr.partstrlist+i-1)^,8,procnum2);
         for j:=1 to fse.exe_section_number do
          begin
           partstr2:=PCharToPWChar(PChar(fse.exe_string_table_segment.string_table_content+(fse.exe_section_segments+j-1)^.section_name_index-1));
           if(WstrcmpL(partstr,partstr2)=0) then 
            begin
             inc(sectionshownum);
             ReallocMem(sectionshow,sectionshownum*sizeof(natuint));
             (sectionshow+sectionshownum-1)^:=j;
             size:=getmemsize(partstr2);
             sectionshow:=Pointer(Pointer(sectionshow)-size);
             Wstrfree(partstr2);
             break;
            end;
           Wstrfree(partstr2);
          end;
         size:=getmemsize(partstr);
         sectionshow:=Pointer(Pointer(sectionshow)-size);
         Wstrfree(partstr);
        end;
      end;
     if(fse.exe_signature=tydqfs_executable_signature) and (fse.exe_string_table_offset>0) then
      begin
       {Output the executable type}
       efi_console_output_string(systemtable,'Executable Type:');
       if(fse.exe_type=tydqfs_executable_executable) then efi_console_output_string(systemtable,'Executable')
       else if(fse.exe_type=tydqfs_executable_relocatable) then efi_console_output_string(systemtable,'Relocatable')
       else if(fse.exe_type=tydqfs_executable_object) then efi_console_output_string(systemtable,'Object')
       else if(fse.exe_type=tydqfs_executable_staticlib) then efi_console_output_string(systemtable,'Static library')
       else if(fse.exe_type=tydqfs_executable_dynamiclib) then efi_console_output_string(systemtable,'Dynamic library');
       efi_console_output_string(systemtable,#10);
       {Output the executable architecture}
       efi_console_output_string(systemtable,'Executable Architecture:');
       if(fse.exe_type=tydqfs_x64) then efi_console_output_string(systemtable,'X64')
       else if(fse.exe_type=tydqfs_aarch64) then efi_console_output_string(systemtable,'AArch64')
       else if(fse.exe_type=tydqfs_loongarch64) then efi_console_output_string(systemtable,'LoongArch64')
       else if(fse.exe_type=tydqfs_riscv64) then efi_console_output_string(systemtable,'Risc-V64')
       else if(fse.exe_type=tydqfs_riscv128) then efi_console_output_string(systemtable,'Risc-V128');
       efi_console_output_string(systemtable,#10);
       {Output the executable version}
       efi_console_output_string(systemtable,'Executable Version:');
       partstr:=UintToPWChar(fse.exe_version[1]);
       efi_console_output_string(systemtable,partstr);
       efi_console_output_string(systemtable,'.');
       Wstrfree(partstr);
       partstr:=UintToPWChar(fse.exe_version[2]);
       efi_console_output_string(systemtable,partstr);
       efi_console_output_string(systemtable,'.');
       Wstrfree(partstr);
       partstr:=UintToPWChar(fse.exe_version[3]);
       efi_console_output_string(systemtable,partstr);
       efi_console_output_string(systemtable,'.');
       Wstrfree(partstr);
       partstr:=UintToPWChar(fse.exe_version[4]);
       efi_console_output_string(systemtable,partstr);
       Wstrfree(partstr);
       efi_console_output_string(systemtable,#10);
       {If needed,output the relocation part}
       if(relocationshow=true) and (fse.exe_relocation_offset>0) then 
        begin
         efi_console_output_string(systemtable,'Relocation part vaild,now show the relocation part infomation:'#10);
         efi_console_output_string(systemtable,'Relocation part total number:');
         partstr:=UintToPWChar(fse.exe_relocation_segment.relocation_number);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         for i:=1 to fse.exe_relocation_segment.relocation_number do
          begin
           partstr2:=UintToPWChar(i);
           efi_console_output_string(systemtable,'Relocation part ');
           efi_console_output_string(systemtable,partstr2);
           efi_console_output_string(systemtable,':'#10);
           Wstrfree(partstr2);
           partstr2:=PCharToPWChar(PChar(fse.exe_string_table_segment.string_table_content+(fse.exe_section_segments+i-1)^.section_name_index));
           efi_console_output_string(systemtable,'Part Name:');
           efi_console_output_string(systemtable,partstr2);
           Wstrfree(partstr2);
           efi_console_output_string(systemtable,' Relocation Offset:');
           partstr2:=UintToWHex((fse.exe_relocation_segment.relocation_offset+i-1)^);
           efi_console_output_string(systemtable,partstr2);
           efi_console_output_string(systemtable,#10);
           Wstrfree(partstr2);
          end;
         Wstrfree(partstr);
        end
       else
        begin
         efi_console_output_string(systemtable,'Error:Invaild relocation part!'#10);
        end;
       {If needed,Output the string table part}
       if(stringtableshow=true) then
        begin
         efi_console_output_string(systemtable,'String Table Size:');
         partstr:=UintToPWChar(fse.exe_string_table_segment.string_table_size);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr);
         procnum2:=1; procnum3:=0; i:=0;
         while(procnum2<=fse.exe_string_table_segment.string_table_size) do
          begin
           inc(i,1);
           partstr:=UintToPWChar(i);
           efi_console_output_string(systemtable,'Section ');
           efi_console_output_string(systemtable,partstr);
           efi_console_output_string(systemtable,' Name:');
           Wstrfree(partstr);
           partstr:=PCharToPWChar(PChar(fse.exe_string_table_segment.string_table_content+procnum2-1));
           procnum3:=strlen(PChar(fse.exe_string_table_segment.string_table_content+procnum2-1));
           efi_console_output_string(systemtable,partstr);
           efi_console_output_string(systemtable,#10);
           Wstrfree(partstr);
           inc(procnum2,procnum3+1);
          end;
        end;
       {If needed,Output the symbol table part}
       if(symboltableshow=true) and (fse.exe_symbol_table_offset>0) then
        begin
         efi_console_output_string(Systemtable,'Symbol Table part vaild,now show the symbol table information:'#10);
         efi_console_output_string(Systemtable,'Symbol total number in symbol table:');
         partstr:=UintToPWChar(fse.exe_symbol_table_segment.symbol_table_number);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr);
         for i:=1 to fse.exe_symbol_table_segment.symbol_table_number do
          begin
           partstr:=UintToPWChar(i);
           efi_console_output_string(systemtable,'Symbol Address ');
           efi_console_output_string(systemtable,partstr);
           Wstrfree(partstr);
           partstr:=UintToWhex((fse.exe_symbol_table_segment.symbol_table_address+i-1)^);
           efi_console_output_string(systemtable,':');
           efi_console_output_string(systemtable,partstr);
           Wstrfree(partstr);
           if((fse.exe_symbol_table_segment.symbol_table_type+i-1)^=$00) then
            begin
             efi_console_output_string(systemtable,' Link type:None');
            end
           else if((fse.exe_symbol_table_segment.symbol_table_type+i-1)^=$01) then
            begin
             efi_console_output_string(systemtable,' Link type:Static');
            end
           else if((fse.exe_symbol_table_segment.symbol_table_type+i-1)^=$02) then
            begin
             efi_console_output_string(systemtable,' Link type:Dynamic');
            end
           else if((fse.exe_symbol_table_segment.symbol_table_type+i-1)^=$03) then
            begin
             efi_console_output_string(systemtable,' Link type:Smartlink');
            end;
           efi_console_output_string(systemtable,#10);
          end;       
        end;
       {If needed,Output the hash table part}
       if(hashtableshow=true) and (fse.exe_hash_table_offset>0) then
        begin
         efi_console_output_string(Systemtable,'Hash Table part vaild,now show the hash table information:'#10);
         efi_console_output_string(Systemtable,'Hash total number in symbol table:');
         partstr:=UintToPWChar(fse.exe_hash_table_segment.hash_table_number);
         efi_console_output_string(systemtable,partstr);
         efi_console_output_string(systemtable,#10);
         Wstrfree(partstr);
         for i:=1 to fse.exe_hash_table_segment.hash_table_number do
          begin
           partstr:=UintToPWChar(i);
           efi_console_output_string(systemtable,'Hash Address ');
           efi_console_output_string(systemtable,partstr);
           Wstrfree(partstr);
           partstr:=UintToWhex((fse.exe_hash_table_segment.hash_table_address+i-1)^);
           efi_console_output_string(systemtable,':');
           efi_console_output_string(systemtable,partstr);
           Wstrfree(partstr);
           efi_console_output_string(systemtable,#10);
          end;       
        end;
       {If needed,Output the section part}
       if(fse.exe_section_start_offset>0) then
        begin
         efi_console_output_string(systemtable,'Section part vaild,now show all section information:'#10);
         efi_console_output_string(systemtable,'Section total number in symbol table:');
         partstr:=UintToPWChar(fse.exe_section_number);
         efi_console_output_string(systemtable,partstr);
         Wstrfree(partstr);
         if(sectionshowall=false) then
          begin
           for i:=1 to sectionshownum do
            begin
             efi_console_output_string(systemtable,'Section ');
             partstr:=UintToPWChar(i);
             efi_console_output_string(systemtable,partstr);
             efi_console_output_string(systemtable,':'#10);
             Wstrfree(partstr);
             j:=(sectionshow+i-1)^;
             if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_code) then
              begin
               efi_console_output_string(systemtable,'Section Type:Code'#10);
              end
             else if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_initialized_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Initialized Data'#10);
              end
             else if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_read_only_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Read Only data'#10);
              end
             else if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_uninitialized_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Uninitialized Data'#10);
              end
             else if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_debug_info) then
              begin
               efi_console_output_string(systemtable,'Section Type:Debug info'#10);
              end
             else if((fse.exe_section_segments+j-1)^.section_type=tydqfs_executable_section_compiler_info) then
              begin
               efi_console_output_string(systemtable,'Section Type:Compiler info'#10);
              end;
             partstr:=UintToPWChar((fse.exe_section_segments+j-1)^.section_segment_size);
             efi_console_output_string(systemtable,'Section Size:');
             efi_console_output_string(systemtable,partstr);
             efi_console_output_string(systemtable,#10);
             Wstrfree(partstr);
            end;
          end
         else if(sectionshowall=true) then
          begin
           for i:=1 to sectionshownum do
            begin
             efi_console_output_string(systemtable,'Section ');
             partstr:=UintToPWChar(i);
             efi_console_output_string(systemtable,partstr);
             efi_console_output_string(systemtable,':'#10);
             Wstrfree(partstr);
             if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_code) then
              begin
               efi_console_output_string(systemtable,'Section Type:Code'#10);
              end
             else if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_initialized_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Initialized Data'#10);
              end
             else if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_read_only_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Read Only data'#10);
              end
             else if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_uninitialized_data) then
              begin
               efi_console_output_string(systemtable,'Section Type:Uninitialized Data'#10);
              end
             else if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_debug_info) then
              begin
               efi_console_output_string(systemtable,'Section Type:Debug info'#10);
              end
             else if((fse.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_compiler_info) then
              begin
               efi_console_output_string(systemtable,'Section Type:Compiler info'#10);
              end;
             partstr:=UintToPWChar((fse.exe_section_segments+i-1)^.section_segment_size);
             efi_console_output_string(systemtable,'Section Size:');
             efi_console_output_string(systemtable,partstr);
             efi_console_output_string(systemtable,#10);
             Wstrfree(partstr);
            end;
          end;
        end;
      end
     else
      begin
       if(fse.exe_string_table_offset>0) then efi_console_output_string(systemtable,'Error:Invaild executable due to string table invaild!'#10)
       else efi_console_output_string(systemtable,'Error:Invaild executable and this executable file unrecognized!'#10);
      end;
     tydq_fs_free_executable(fse);
     Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
    end
   else if(WstrcmpL(cpstr.partstrlist^,'execute')=0) then
    begin
     if(cpstr.partstrnum<2) then
      begin
       efi_console_output_string(systemtable,'execute must have at least one path!'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     edl:=efi_disk_tydq_get_fs_list(systemtable);
     partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+2)^);
     procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+2)^);
     fsf:=tydq_fs_file_info(edl,procnum,partstr5,userlevel_user,sysindex);
     if(fsf.fattribute=0) then
      begin
       efi_console_output_string(systemtable,'readexe failed,permission denied.'#10);
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     param.parameter:=nil; param.parameternum:=0; procnum2:=0;
     for i:=4 to cpstr.partstrnum do
      begin
       procnum3:=WStrlen((cpstr.partstrlist+i-1)^);
       procnum2:=procnum2+procnum3+1;
       ReallocMem(param.parameter,sizeof(WideChar)*procnum2);
       partstr:=Wstrcopy((cpstr.partstrlist+i-1)^,1,procnum3);
       partstr2:=param.parameter+procnum2;
       Wstrset(partstr2,partstr);
       Wstrfree(partstr);
      end;
     isexecuted:=tydq_fs_execute_executable(edl,procnum,partstr5,param,userlevel_system,1);
     if(isexecuted=false) then 
      begin 
       efi_console_output_string(systemtable,'the file ');
       efi_console_output_string(systemtable,partstr5);
       efi_console_output_string(systemtable,' executed returns error,please check this executable file to detect problems.'#10);
      end;
     Wstrfree(param.parameter); param.parameternum:=0;
     Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
    end
   else if(Wstrcmp(cpstr.partstrlist^,'passwd')=0) and (Wstrlen(cpstr.partstrlist^)=6) then
    begin
     efi_console_output_string(systemtable,'Enter your original password:');
     efi_console_read_password_string(systemtable,inputstr1);
     while(Wstrcmp(inputstr1,tydq_fs_systeminfo_get_passwd(sysinfo,(sysinfo.userinfolist+sysindex-2)^.username))<>0)
     or (Wstrlen(inputstr1)<>Wstrlen(tydq_fs_systeminfo_get_passwd(sysinfo,(sysinfo.userinfolist+sysindex-2)^.username))) do
      begin
       efi_console_output_string(systemtable,'Error:typed password incorrect.'#10);
       efi_console_output_string(systemtable,'Enter your original password:');
       efi_console_read_password_string(systemtable,inputstr1);
      end;
     efi_console_output_string(systemtable,'Input your new password:');
     efi_console_read_password_string(systemtable,inputstr2);
     size:=getmemsize((sysinfo.userinfolist+sysindex-2)^.userpasswd);
     Wstrrealloc((sysinfo.userinfolist+sysindex-2)^.userpasswd,Wstrlen(inputstr2));
     Wstrset((sysinfo.userinfolist+sysindex-2)^.userpasswd,inputstr2);
     for j:=sysindex-1 to sysinfo.header.tydqusercount do
      begin
       (sysinfo.userinfolist+j)^.username:=PWideChar(Pointer((sysinfo.userinfolist+j)^.username)-size);
       (sysinfo.userinfolist+j)^.userpasswd:=PWideChar(Pointer((sysinfo.userinfolist+j)^.userpasswd)-size);
      end;
     efi_console_output_string(systemtable,'You successfully changed your password!'#10);
     freemem(inputstr2); freemem(inputstr1);
    end
   else if(Wstrcmp(cpstr.partstrlist^,'usrname')=0) and (Wstrlen(cpstr.partstrlist^)=7) then
    begin
     efi_console_output_string(systemtable,'Input your new user name:');
     efi_console_read_string(systemtable,inputstr1);
     while(tydq_fs_systeminfo_username_count(sysinfo,inputstr1)>=1) do
      begin
       efi_console_output_string(systemtable,'Error:User name already exists.'#10);
       efi_console_output_string(systemtable,'Input your new user name:');
       efi_console_read_string(systemtable,inputstr1);
      end;
     size:=getmemsize((sysinfo.userinfolist+sysindex-2)^.username);
     Wstrrealloc((sysinfo.userinfolist+sysindex-2)^.username,Wstrlen(inputstr1));
     Wstrset((sysinfo.userinfolist+sysindex-2)^.username,inputstr1);
     for j:=sysindex-1 to sysinfo.header.tydqusercount do
      begin
       (sysinfo.userinfolist+j)^.username:=PWideChar(Pointer((sysinfo.userinfolist+j)^.username)-size);
       (sysinfo.userinfolist+j)^.userpasswd:=PWideChar(Pointer((sysinfo.userinfolist+j)^.userpasswd)-size);
      end;
     efi_console_output_string(systemtable,'You successfully changed your user name!'#10);
     freemem(inputstr1);
    end
   else if(Wstrcmp(cpstr.partstrlist^,'path')=0) and (Wstrlen(cpstr.partstrlist^)=4) then
    begin
     if(cpstr.partstrnum<=1) then
      begin
       efi_console_output_string(systemtable,'path must have one path,.. or . .'#10);
       for i:=cpstr.partstrnum downto 1 do
        begin
         Wstrfree((cpstr.partstrlist+i-1)^);
        end;
       freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
       exit;
      end;
     if(WStrcmp((cpstr.partstrlist+1)^,'..')=0) and (Wstrlen((cpstr.partstrlist+1)^)=2) then
      begin
       procnum:=Wstrposdir(tydqcurrentpath,'/',Wstrlen(tydqcurrentpath),-1);
       if(procnum>1) then partstr:=Wstrcutout(tydqcurrentpath,1,procnum-1) else partstr:=Wstrcopy(tydqcurrentpath,1,1);
       Wstrset(tydqcurrentpath,partstr);
       Wstrfree(partstr);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'.')=0) and (Wstrlen((cpstr.partstrlist+1)^)=1) then
      begin
      end
     else
      begin
       edl:=efi_disk_tydq_get_fs_list(systemtable);
       partstr5:=tydq_fs_locate_fullpath(edl,(cpstr.partstrlist+1)^);
       procnum:=tydq_fs_locate_diskindex(edl,(cpstr.partstrlist+1)^);
       fsh:=tydq_fs_read_header(edl,procnum);
       Wstrset(tydqcurrentdiskname,@fsh.RootName);
       Wstrset(tydqcurrentpath,partstr5);
       Wstrfree(partstr5); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0; 
      end;
    end
   else if(Wstrcmp(cpstr.partstrlist^,'logout')=0) and (WStrlen(cpstr.partstrlist^)=6) then
    begin
     efi_console_clear_screen(systemtable);
     efi_console_output_string(systemtable,'Type the user name you want to login:');
     efi_console_read_string(systemtable,partstr);
     while(tydq_fs_systeminfo_get_index(sysinfo,partstr)=0) do
      begin
       efi_console_output_string(systemtable,'Error:typed user name does not exist.'#10);
       efi_console_output_string(systemtable,'Type the user name you want to login:');
       efi_console_read_string(systemtable,partstr);
      end;
     partstr2:=tydq_fs_systeminfo_get_passwd(sysinfo,(sysinfo.userinfolist+sysindex-2)^.username);
     efi_console_output_string(systemtable,'Type ');
     efi_console_output_string(systemtable,(sysinfo.userinfolist+sysindex-2)^.username);
     efi_console_output_string(systemtable,#39's password:');
     efi_console_read_password_string(systemtable,partstr3);
     while(Wstrcmp(partstr2,partstr3)=0) or (Wstrlen(partstr2)<>Wstrlen(partstr3)) do
      begin
       efi_console_output_string(systemtable,'Error:input password incorrect.');
       efi_console_output_string(systemtable,'Type ');
       efi_console_output_string(systemtable,(sysinfo.userinfolist+sysindex-2)^.username);
       efi_console_output_string(systemtable,#39's password:');
       efi_console_read_password_string(systemtable,partstr3);
      end;
     tydq_fs_systeminfo_write(systemtable,edl,sysinfo);
     efi_console_output_string(systemtable,'Successfully login!'#10);
    end
   else if(Wstrcmp(cpstr.partstrlist^,'clearscreen')=0) and (Wstrlen(cpstr.partstrlist^)=11) then
    begin
     efi_console_clear_screen(systemtable);
    end
   else if(Wstrcmp(cpstr.partstrlist^,'sysver')=0) and (WStrlen(cpstr.partstrlist^)=6) then
    begin
     efi_console_output_string(systemtable,'System Version:0.0.4'#10);
    end
   else if(WStrcmp(cpstr.partstrlist^,'sysname')=0) and (Wstrlen(cpstr.partstrlist^)=7) then
    begin
     efi_console_output_string(systemtable,'System Name:TYDQ System'#10);
    end
   else if(WStrcmp(cpstr.partstrlist^,'sysarch')=0) and (WStrlen(cpstr.partstrlist^)=7) then
    begin
     procnum:=efi_get_platform;
     if(procnum=0) then efi_console_output_string(systemtable,'System Architecture:x64'#10)
     else if(procnum=1) then efi_console_output_string(systemtable,'System Architecture:aarch64'#10)
     else if(procnum=2) then efi_console_output_string(systemtable,'System Architecture:loongarch64'#10);
    end
   else if(WStrcmp(cpstr.partstrlist^,'sysinfo')=0) and (Wstrlen(cpstr.partstrlist^)=7) then
    begin
     efi_console_output_string(systemtable,'System Name:TYDQ System'#10);
     efi_console_output_string(systemtable,'System Version:0.0.4'#10);
     procnum:=efi_get_platform;
     if(procnum=0) then efi_console_output_string(systemtable,'System Architecture:x64'#10)
     else if(procnum=1) then efi_console_output_string(systemtable,'System Architecture:aarch64'#10)
     else if(procnum=2) then efi_console_output_string(systemtable,'System Architecture:loongarch64'#10);
    end
   else if(Wstrcmp(cpstr.partstrlist^,'help')=0) and (WStrlen(cpstr.partstrlist^)=4) then
    begin
      if(cpstr.partstrnum<=1) then
      begin
       efi_console_output_string(systemtable,'You need to type a command to show the help manual of it.'#10);
       efi_console_output_string(systemtable,'Vaild commands:sp reboot shutdown echo delay file readexe execute passwd usrname path'#10);
       efi_console_output_string(systemtable,'addusr delusr lsuser lsdisk kerneldetect kernelinstall logout help sysver sysname sysarch sysinfo sysctl'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'sp')=0) and (WStrlen((cpstr.partstrlist+1)^)=2) then
      begin
       efi_console_output_string(systemtable,'Improve your user level in one command and with this user level execute the command.'#10);
       efi_console_output_string(systemtable,'Usage:sp <command>'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'reboot')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
      begin
       efi_console_output_string(systemtable,'Restart the whole operating system.'#10);
       efi_console_output_string(systemtable,'Usage:reboot'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'shutdown')=0) and (WStrlen((cpstr.partstrlist+1)^)=8) then
      begin
       efi_console_output_string(systemtable,'Close the whole operating system.'#10);
       efi_console_output_string(systemtable,'Usage:shutdown'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'echo')=0) and (Wstrlen((cpstr.partstrlist+1)^)=4) then
      begin
       efi_console_output_string(systemtable,'Output the string in the screen.'#10);
       efi_console_output_string(systemtable,'Usage:echo <string>'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'delay')=0) and (Wstrlen((cpstr.partstrlist+1)^)=5) then
      begin
       efi_console_output_string(systemtable,'Delay in specified time after execute the command.'#10);
       efi_console_output_string(systemtable,'Usage:echo <string>'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'file')=0) and (WStrlen((cpstr.partstrlist+1)^)=4) then
      begin
       if(cpstr.partstrnum<=2) then
        begin
         efi_console_output_string(systemtable,'Please type the vaild command after the command file:'#10);
         efi_console_output_string(systemtable,'create list tree info copy delete exist edit edithex'#10);
         efi_console_output_string(systemtable,'createandedit createandedithex showtext showhex createlink'#10);
         efi_console_output_string(systemtable,'openlink resetlink'#10);
         efi_console_output_string(systemtable,'Usage:file <command> <parameters>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+2)^,'create')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
        begin
         efi_console_output_string(systemtable,'Create a specified file in specified path.'#10);
         efi_console_output_string(systemtable,'Usage:file create <path><folder/link/text/binary>'#10);
         efi_console_output_string(systemtable,'<normal/system><hidden><shared>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+2)^,'list')=0) and (Wstrlen((cpstr.partstrlist+2)^)=4) then
        begin
         efi_console_output_string(systemtable,'List all specified files in the specified path.'#10);
         efi_console_output_string(systemtable,'You can add command detecthidden to detect hidden files.'#10);
         efi_console_output_string(systemtable,'Usage:file list <path><detecthidden(optional)>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+2)^,'tree')=0) and (Wstrlen((cpstr.partstrlist+2)^)=4) then
        begin
         efi_console_output_string(systemtable,'List all specified files in the specified path(the file in folder will also be listed.'#10);
         efi_console_output_string(systemtable,'You can add command detecthidden to detect hidden files.'#10);
         efi_console_output_string(systemtable,'Usage:file tree <path><detecthidden(optional)>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+2)^,'info')=0) and (Wstrlen((cpstr.partstrlist+2)^)=4) then
        begin
         efi_console_output_string(systemtable,'Get the file information from the specified file.'#10);
         efi_console_output_string(systemtable,'Usage:file info <path>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+2)^,'copy')=0) and (Wstrlen((cpstr.partstrlist+2)^)=4) then
        begin
         efi_console_output_string(systemtable,'Copy the specified file or specified files to other path.'#10);
         efi_console_output_string(systemtable,'You can add judgehidden command to specified hidden files.'#10);
         efi_console_output_string(systemtable,'Usage:file copy <pathfrom><pathto><judgehidden(optional)>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+2)^,'delete')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
        begin
         efi_console_output_string(systemtable,'Delete the specified file or specified files(including files in folders).'#10);
         efi_console_output_string(systemtable,'You can add judgehidden command to specified hidden files.'#10);
         efi_console_output_string(systemtable,'Usage:file delete <path><judgehidden(optional)>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+2)^,'exist')=0) and (Wstrlen((cpstr.partstrlist+2)^)=5) then
        begin
         efi_console_output_string(systemtable,'Test whether the file exist or not.'#10);
         efi_console_output_string(systemtable,'Usage:file exist <path>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+2)^,'edit')=0) and (WStrlen((cpstr.partstrlist+2)^)=4) then
        begin
         efi_console_output_string(systemtable,'Edit the specified text file.'#10);
         efi_console_output_string(systemtable,'Usage:file edit <path>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+2)^,'edithex')=0) and (WStrlen((cpstr.partstrlist+2)^)=7) then
        begin
         efi_console_output_string(systemtable,'Edit the specified file in hex edit mode.'#10);
         efi_console_output_string(systemtable,'Usage:file edithex <path>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+2)^,'createandedit')=0) and (WStrlen((cpstr.partstrlist+2)^)=12) then
        begin
         efi_console_output_string(systemtable,'Create the specified text file in path and then edit the content.'#10);
         efi_console_output_string(systemtable,'Usage:file createandedit <path><normal/system><hidden><shared>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+2)^,'createandedithex')=0) and (WStrlen((cpstr.partstrlist+2)^)=16) then
        begin
         efi_console_output_string(systemtable,'Create the specified binary file in path and then edit the hex.'#10);
         efi_console_output_string(systemtable,'Usage:file createandedithex <path><normal/system><hidden><shared>'#10);
        end
       else if(WStrcmp((cpstr.partstrlist+2)^,'showtext')=0) and (WStrlen((cpstr.partstrlist+2)^)=8) then
        begin
         efi_console_output_string(systemtable,'Show the text content in the text file with specified range.'#10);
         efi_console_output_string(systemtable,'You can set the startline to set the start line to show,'#10);
         efi_console_output_string(systemtable,'set the endline to set the end line to show.'#10);
         efi_console_output_string(systemtable,'Usage:file showtext <path><startline+number><endline+number>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+2)^,'showhex')=0) and (WStrlen((cpstr.partstrlist+2)^)=7) then
        begin
         efi_console_output_string(systemtable,'Show the hex content in the file with specified range.'#10);
         efi_console_output_string(systemtable,'You can set the startoffset to set the start offset to show,'#10);
         efi_console_output_string(systemtable,'set the endoffset to set the end offset to show.'#10);
         efi_console_output_string(systemtable,'Usage:file showhex <path><startoffset+number><endoffset+number>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+2)^,'createlink')=0) and (WStrlen((cpstr.partstrlist+2)^)=10) then
        begin
         efi_console_output_string(systemtable,'Create a specified link file which point to specified path.'#10);
         efi_console_output_string(systemtable,'Usage:file createlink <path><pathto><normal/system><hidden><shared>'#10);
        end 
       else if(WStrcmp((cpstr.partstrlist+2)^,'openlink')=0) and (WStrlen((cpstr.partstrlist+2)^)=8) then
        begin
         efi_console_output_string(systemtable,'Open link to jump to the path which link specified in the file.'#10);
         efi_console_output_string(systemtable,'Usage:file openlink <path>'#10);
        end 
       else if(Wstrcmp((cpstr.partstrlist+2)^,'resetlink')=0) and (Wstrlen((cpstr.partstrlist+2)^)=9) then
        begin
         efi_console_output_string(systemtable,'Reset a specified link file'#29's link to specified path.'#10);
         efi_console_output_string(systemtable,'Usage:file resetlink <path><pathto>'#10);
        end
       else
        begin
         efi_console_output_string(systemtable,'Command ');
         efi_console_output_string(systemtable,(cpstr.partstrlist+2)^);
         efi_console_output_string(systemtable,' after the command file unrecognized,'#10);
         efi_console_output_string(systemtable,'Please type the vaild command after the command file:'#10);
         efi_console_output_string(systemtable,'create list tree info copy delete exist edit edithex'#10);
         efi_console_output_string(systemtable,'createandedit createandedithex showtext showhex createlink'#10);
         efi_console_output_string(systemtable,'openlink resetlink'#10);
        end;
      end
     else if(WStrCmpL((cpstr.partstrlist+1)^,'shell')=0) then
      begin
       efi_console_output_string(systemtable,'Execute the shell code file'#39's information'#10);
       efi_console_output_string(systemtable,'Usage:shell <path1..n>(n>=1)'#10);
       efi_console_output_string(systemtable,'shell code tips:'#10);
       efi_console_output_string(systemtable,'if(statement){expression}'#10'variable-name =/+=/-=/*=//=/%= variable-value'#10);
       efi_console_output_string(systemtable,'for(variable-name = initial value:final value){expression}'#10);
       efi_console_output_string(systemtable,'while(statement){expression}'#10);
       efi_console_output_string(systemtable,'do{expression}while(statement)'#10);
       efi_console_output_string(systemtable,'switch(variable){case 0:{expression}break;...}'#10);
      end
     else if(WStrCmpL((cpstr.partstrlist+1)^,'readexe')=0) then
      begin
       efi_console_output_string(systemtable,'Read the executable file'#39's information'#10);
       efi_console_output_string(systemtable,'Usage:readexe <path> <relocation/stringtable/symboltable/hashtable/section<section name>>'#10);
      end
     else if(WStrCmpL((cpstr.partstrlist+1)^,'execute')=0) then
      begin
       efi_console_output_string(systemtable,'Execute the executable file.'#10);
       efi_console_output_string(systemtable,'Usage:execute <path> <parameters to executable file>'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'passwd')=0) and (WStrlen((cpstr.partstrlist+1)^)=6) then
      begin
       efi_console_output_string(systemtable,'Reset your current account'#29's password.'#10);
       efi_console_output_string(systemtable,'Usage:passwd'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'usrname')=0) and (Wstrlen((cpstr.partstrlist+1)^)=7) then
      begin
       efi_console_output_string(systemtable,'Reset your current account'#29's user name.'#10);
       efi_console_output_string(systemtable,'Usage:usrname'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'path')=0) and (WStrlen((cpstr.partstrlist+1)^)=4) then
      begin
       efi_console_output_string(systemtable,'Change your relative path.'#10);
       efi_console_output_string(systemtable,'. means your current path,.. means your previous level path,'#10);
       efi_console_output_string(systemtable,'other means your new path based on your relative path.'#10);
       efi_console_output_string(systemtable,'Usage:path <./../new path>'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'addusr')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use addusr when you are user manager.'#10);
       efi_console_output_string(systemtable,'Add a specified user to the TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sp addusr'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'delusr')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use delusr when you are user manager.'#10);
       efi_console_output_string(systemtable,'Delete a specified user to the TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sp delusr'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'lsuser')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use lsuser when you are user manager.'#10);
       efi_console_output_string(systemtable,'List all users of the TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sp lsuser'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'lsdisk')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use addusr when you are user manager.'#10);
       efi_console_output_string(systemtable,'List all available disks of the TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sp lsdisk'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'kerneldetect')=0) and (Wstrlen((cpstr.partstrlist+1)^)=12) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use kerneldetect when you are user manager.'#10);
       efi_console_output_string(systemtable,'Detect the kernel is vaild or invaild.'#10);
       efi_console_output_string(systemtable,'Usage:sp kerneldetect <path>'#10);
      end 
     else if(WStrcmp((cpstr.partstrlist+1)^,'kernelinstall')=0) and (Wstrlen((cpstr.partstrlist+1)^)=13) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use kernelinstall when you are user manager.'#10);
       efi_console_output_string(systemtable,'Install the vaild kernel to your computer and reboot after you do this.'#10);
       efi_console_output_string(systemtable,'Usage:sp kernelinstall <path>'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'logout')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
      begin
       efi_console_output_string(systemtable,'Log out your current account and then change to account you want to login.'#10);
       efi_console_output_string(systemtable,'Usage:logout'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+1)^,'clearscreen')=0) and (Wstrlen((cpstr.partstrlist+1)^)=11) then
      begin
       efi_console_output_string(systemtable,'Clear the whole screen in console.'#10);
       efi_console_output_string(systemtable,'Usage:clearscreen'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'sysver')=0) and (Wstrlen((cpstr.partstrlist+1)^)=6) then
      begin
       efi_console_output_string(systemtable,'Show the system version of TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sysver'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'sysname')=0) and (Wstrlen((cpstr.partstrlist+1)^)=7) then
      begin
       efi_console_output_string(systemtable,'Show the system name of TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sysname'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'sysarch')=0) and (Wstrlen((cpstr.partstrlist+1)^)=7) then
      begin
       efi_console_output_string(systemtable,'Show the system CPU architecture of TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sysarch'#10);
      end
     else if(Wstrcmp((cpstr.partstrlist+1)^,'sysinfo')=0) and (Wstrlen((cpstr.partstrlist+1)^)=7) then
      begin
       efi_console_output_string(systemtable,'Show all system information of TYDQ System.'#10);
       efi_console_output_string(systemtable,'Usage:sysinfo'#10);
      end
     else if(WStrcmp((cpstr.partstrlist+2)^,'sysctl')=0) and (Wstrlen((cpstr.partstrlist+2)^)=6) then
      begin
       efi_console_output_string(systemtable,'Tips:you must use the sp command to use sysctl when you are user manager.'#10);
       efi_console_output_string(systemtable,'Change the system option value to enable the function or disable it.'#10);
       efi_console_output_string(systemtable,'Usage:sp sysctl graphics/network/autodetectkernel disabled/enabled'#10);
      end 
     else
      begin
       efi_console_output_string(systemtable,'Command ');
       efi_console_output_string(systemtable,(cpstr.partstrlist+1)^);
       efi_console_output_string(systemtable,' unrecognized,'#10);
       efi_console_output_string(systemtable,'So please type vaild command to show help manual!'#10);
       efi_console_output_string(systemtable,'Vaild commands:sp reboot shutdown echo delay file shell readexe execute passwd usrname path'#10);
       efi_console_output_string(systemtable,'addusr delusr lsuser lsdisk kerneldetect kernelinstall logout help sysver sysname sysarch sysinfo sysctl'#10);
      end;
    end
   else if(cpstr.partstrnum>=1) then
    begin
     efi_console_output_string(systemtable,'Command ');
     efi_console_output_string(systemtable,cpstr.partstrlist^);
     efi_console_output_string(systemtable,' unrecognized!'#10);
    end
   else
    begin
     efi_console_output_string(systemtable,'Please type your command to operate the system!'#10);
    end;
  end;
 for i:=cpstr.partstrnum downto 1 do
  begin
   Wstrfree((cpstr.partstrlist+i-1)^);
  end;
 freemem(cpstr.partstrlist); cpstr.partstrnum:=0;
end;
procedure console_initialize(systemtable:Pefi_system_table;sysinfo:tydqfs_system_info;sysindex:natuint);[public,alias:'console_initialize'];
var edl:efi_disk_list;
    fsh:tydqfs_header;
    diskindex:natuint;
    mypath:PWideChar;
begin
 edl:=efi_disk_tydq_get_fs_list(systemtable);
 Wstrinit(mypath,1024); Wstrset(mypath,'/usrsp');
 Wstrcat(mypath,'/'); WstrCat(mypath,(sysinfo.userinfolist+sysindex-2)^.username);
 diskindex:=tydq_fs_systeminfo_disk_index(systemtable,edl);
 tydq_fs_create_file(systemtable,edl,diskindex,mypath,tydqfs_folder or tydqfs_system_file,userlevel_system,1);
 fsh:=tydq_fs_read_header(edl,diskindex); Wstrset(tydqcurrentdiskname,@fsh.RootName); Wstrset(tydqcurrentpath,mypath);
 freemem(mypath); freemem(edl.disk_block_content); freemem(edl.disk_content); edl.disk_count:=0;
end;

end.
