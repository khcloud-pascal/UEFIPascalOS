unit tydqfs;

interface

{$POINTERMATH ON}

uses uefi;
type tydqfs_time=packed record
                 year:word;
                 month:byte;
                 day:byte;
                 hour:byte;
                 minute:byte;
                 second:byte;
                 millisecond:word;
                 end;
     tydqfs_file=packed record
                 fparentpos:qword;
                 fattribute:byte;
                 fName:array[1..256] of WideChar;
                 fcreatetime:tydqfs_time;
                 flastedittime:tydqfs_time;
                 fcontentCount:qword;
                 end;
     tydqfs_header=packed record
                   signature:qword;
                   maxsize:qword;
                   usedsize:qword;
                   RootName:array[1..256] of WideChar;
                   RootCount:qword;
                   end;
     tydqfs_filename=array[1..256] of WideChar;
     tydqfs_file_list=record
                      files_basepath:^PWideChar;
                      files_content:^PWideChar;
                      files_count:natuint;
                      end;
     tydqfs_file_total_list=record
                            files_fullpath:^PWideChar;
                            files_position:^natuint;
                            files_count:natuint;
                            end;
     tydqfs_attribute_bool=array[1..8] of boolean;
     tydqfs_data=record
                 fsdata:PByte;
                 fssize:natuint;
                 end;
     tydqfs_system_header=packed record 
                        tydqgraphics:boolean;
                        tydqnetwork:boolean;
                        tydqsyslang:word;
                        tydqusercount:natuint;
                        end;
     tydqfs_user_info=packed record
                      username:PWideChar;
                      userpasswd:PWideChar;
                      end; 
     tydqfs_system_info=packed record
                        header:tydqfs_system_header;
                        userinfolist:^tydqfs_user_info;
                        end;

const tydqfs_signature:qword=$5D47291AD7E3F2B1;
      tydqfs_folder:byte=$01;
      tydqfs_normal_file:byte=$02;
      tydqfs_system_file:byte=$04;
      tydqfs_hidden_file:byte=$08;
      tydqfs_link_file:byte=$10;
      tydqfs_text_file:byte=$20;
      tydqfs_binary_file:byte=$40;
      tydqfs_executable_file:byte=$80;
      tydqfilemode_create:byte=$01;
      tydqfilemode_write:byte=$02;
      tydqfilemode_read:byte=$04;
      tydqfilemode_delete:byte=$08;
      tydqfs_search_start:natuint=0;
      userlevel_system:byte=$00;
      userlevel_user:byte=$01;
      userlevel_application:byte=$02;
      
function tydq_fs_byte_to_attribute_bool(attr:byte):tydqfs_attribute_bool;cdecl;      
function tydq_combine_path_and_filename(path:PWideChar;filename:PWideChar):PWideChar;cdecl;
function tydq_fs_filelist_combine(filelist1,filelist2:tydqfs_file_list):tydqfs_file_list;cdecl;
procedure tydq_fs_initialize(edl:efi_disk_list;diskindex:natuint;RootName:PWideChar);cdecl;
function tydq_fs_read_header(edl:efi_disk_list;diskindex:natuint):tydqfs_header;cdecl;
procedure tydq_fs_write_header(edl:efi_disk_list;diskindex:natuint;fsh:tydqfs_header);cdecl;
function tydq_fs_disk_exists(edl:efi_disk_list;diskname:PWideChar):boolean;cdecl;
function tydq_fs_disk_is_formatted(edl:efi_disk_list;diskindex:natuint):boolean;cdecl;
function tydq_fs_file_exists(edl:efi_disk_list;diskindex:natuint;filename:PWideChar):boolean;cdecl;
function tydq_fs_file_position(edl:efi_disk_list;diskindex:natuint;filename:PWideChar):natuint;cdecl;
procedure tydq_fs_create_file(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;attr:byte;userlevel:byte);cdecl;
function tydq_fs_list_file(edl:efi_disk_list;diskindex:natuint;path:PWideChar;detecthidden:boolean):tydqfs_file_list;cdecl;
function tydq_fs_delete_file(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte):byte;cdecl;
function tydq_fs_file_read(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;position,readlength:natuint;userlevel:byte):tydqfs_data;cdecl;
function tydq_fs_file_info(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte):tydqfs_file;cdecl;
procedure tydq_fs_file_write(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;offset:natuint;writedata:Pointer;writesize:natuint;userlevel:byte);cdecl;
procedure tydq_fs_file_rewrite(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;writedata:Pointer;writesize:natuint;userlevel:byte);cdecl;
function tydq_fs_systeminfo_init:tydqfs_system_info;cdecl;
procedure tydq_fs_create_systeminfo_file(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint);cdecl;
function tydq_fs_systeminfo_read(systemtable:Pefi_system_table;edl:efi_disk_list):tydqfs_system_info;cdecl;
procedure tydq_fs_systeminfo_write(systemtable:Pefi_system_table;edl:efi_disk_list;writeinfo:tydqfs_system_info);cdecl;

var tydqcurrentdiskindex:Natuint;
    tydqcurrentdiskname:PWideChar;
    tydqcurrentpath:PWideChar;
    tydqcurrentpos:Natuint;

implementation

function efi_time_to_tydq_fs_time(etime:efi_time):tydqfs_time;cdecl;[public,alias:'EFI_TIME_TO_TYDQ_FS_TIME'];
var fs_time:tydqfs_time;
begin
 fs_time.year:=etime.year;
 fs_time.month:=etime.month;
 fs_time.day:=etime.day;
 fs_time.hour:=etime.hour;
 fs_time.minute:=etime.minute;
 fs_time.second:=etime.second;
 fs_time.millisecond:=etime.nanosecond div 1000000;
end;
function PWChar_to_tydq_filename(str:PWideChar):tydqfs_filename;cdecl;[public,alias:'PWChar_to_tydq_filename'];
var i:natuint;
    fsfn:tydqfs_filename;
begin
 i:=0;
 while((str+i)^<>#0) do
  begin
   fsfn[i+1]:=(str+i)^;
   inc(i);
  end;
 fsfn[i+1]:=#0;
 PWChar_to_tydq_filename:=fsfn;
end;
function tydq_combine_path_and_filename(path:PWideChar;filename:PWideChar):PWideChar;cdecl;[public,alias:'TYDQ_COMBINE_PATH_AND_FILENAME'];
var totalpath:PWideChar;
begin
 if(WstrCmp(path,'/')=0) and (Wstrlen(path)=1) then
  begin
   Wstrinit(totalpath,Wstrlen(path)+Wstrlen(filename));
   Wstrset(totalpath,path);
   WstrCat(totalpath,filename);
  end
 else if(Wstrposinverse(path,filename,1)<Wstrlen(path)-Wstrlen(filename)+1) then
  begin
   Wstrinit(totalpath,Wstrlen(path)+1+Wstrlen(filename));
   Wstrset(totalpath,path);
   WstrCat(totalpath,'/');
   WstrCat(totalpath,filename);
  end
 else
  begin
   Wstrinit(totalpath,Wstrlen(path));
   Wstrset(totalpath,path);
  end;
 tydq_combine_path_and_filename:=totalpath;
end;
function tydq_fs_byte_to_attribute_bool(attr:byte):tydqfs_attribute_bool;cdecl;[public,alias:'TYDQ_FS_BYTE_TO_ATTRIBUTE_BOOL'];
var mybool:tydqfs_attribute_bool;
    myattr:byte;
    i:natuint;
begin
 myattr:=attr;
 for i:=8 downto 1 do
  begin
   if(myattr mod 2=1) then mybool[i]:=true else mybool[i]:=false;
   myattr:=myattr div 2;
  end;
 tydq_fs_byte_to_attribute_bool:=mybool;
end;
function tydq_fs_filelist_combine(filelist1,filelist2:tydqfs_file_list):tydqfs_file_list;cdecl;[public,alias:'TYDQ_FS_FILELIST_COMBINE'];
var reslist:tydqfs_file_list;
    i:natuint;
begin
 reslist.files_basepath:=allocmem(sizeof(PWideChar)*(filelist1.files_count+filelist2.files_count));
 reslist.files_content:=allocmem(sizeof(PWideChar)*(filelist1.files_count+filelist2.files_count));
 reslist.files_count:=filelist1.files_count+filelist2.files_count;
 for i:=1 to filelist1.files_count do
  begin
   (reslist.files_basepath+i-1)^:=(filelist1.files_basepath+i-1)^;
   (reslist.files_content+i-1)^:=(filelist1.files_content+i-1)^;
  end;
 for i:=1 to filelist2.files_count do
  begin
   (reslist.files_basepath+filelist1.files_count+i-1)^:=(filelist2.files_basepath+i-1)^;
   (reslist.files_content+filelist1.files_count+i-1)^:=(filelist2.files_content+i-1)^;
  end;
 tydq_fs_filelist_combine:=reslist;
end;
procedure tydq_fs_initialize(edl:efi_disk_list;diskindex:natuint;RootName:PWideChar);cdecl;[public,alias:'TYDQ_FS_INITIALIZE'];
var tydqdp:Pefi_disk_io_protocol;
    tydqbp:Pefi_block_io_protocol;
    tydqfsh:tydqfs_header;
begin
 tydqdp:=(edl.disk_content+diskindex-1)^; tydqbp:=(edl.disk_block_content+diskindex-1)^;
 tydqfsh.signature:=$5D47291AD7E3F2B1;
 tydqfsh.maxsize:=(tydqbp^.Media^.LastBlock+1)*tydqbp^.Media^.BlockSize;
 tydqfsh.usedsize:=sizeof(tydqfs_header);
 tydqfsh.RootName:=PWChar_to_tydq_filename(RootName);
 tydqfsh.RootCount:=0;
 tydqdp^.WriteDisk(tydqdp,tydqbp^.Media^.MediaId,0,sizeof(tydqfs_header),@tydqfsh);
end;
function tydq_file_initialize(fattribute:byte;fparentpos:qword;filetime:efi_time;filename:PWideChar):tydqfs_file;cdecl;[public,alias:'TYDQ_FILE_INITIALIZE'];
var tydqfile:tydqfs_file;
begin
 tydqfile.fparentpos:=fparentpos;
 tydqfile.fattribute:=fattribute;
 tydqfile.fcreatetime:=efi_time_to_tydq_fs_time(filetime);
 tydqfile.flastedittime:=efi_time_to_tydq_fs_time(filetime);
 tydqfile.fname:=PWChar_to_tydq_filename(filename);
 tydqfile.fcontentCount:=0;
 tydq_file_initialize:=tydqfile;
end;
function tydq_fs_read_header(edl:efi_disk_list;diskindex:natuint):tydqfs_header;cdecl;[public,alias:'TYDQ_FS_READ_HEADER'];
var tydqdp:Pefi_disk_io_protocol;
    tydqbp:Pefi_block_io_protocol;
    res:tydqfs_header;
begin
 tydqdp:=(edl.disk_content+diskindex-1)^;
 tydqbp:=(edl.disk_block_content+diskindex-1)^;
 tydqdp^.ReadDisk(tydqdp,tydqbp^.Media^.MediaId,0,sizeof(tydqfs_header),res);
 tydq_fs_read_header:=res;
end;
procedure tydq_fs_write_header(edl:efi_disk_list;diskindex:natuint;fsh:tydqfs_header);cdecl;[public,alias:'TYDQ_FS_WRITE_HEADER'];
var tydqdp:Pefi_disk_io_protocol;
    tydqbp:Pefi_block_io_protocol;
begin
 tydqdp:=(edl.disk_content+diskindex-1)^;
 tydqbp:=(edl.disk_block_content+diskindex-1)^;
 tydqdp^.WriteDisk(tydqdp,tydqbp^.Media^.MediaId,0,sizeof(tydqfs_header),@fsh);
end;
procedure tydq_fs_disk_move_left(edl:efi_disk_list;diskindex,movestart,moveend,movelength:natuint);cdecl;[public,alias:'TYDQ_FS_FILE_MOVE_LEFT'];
var procbyte,zero:byte;
    dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    i,readpos:natuint;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^;
 for i:=movestart to moveend do
  begin
   dp^.ReadDisk(dp,bp^.Media^.MediaId,i,1,procbyte);
   dp^.WriteDisk(dp,bp^.Media^.MediaId,i-movelength,1,@procbyte);
  end;
end;
procedure tydq_fs_disk_move_right(edl:efi_disk_list;diskindex,movestart,moveend,movelength:natuint);cdecl;[public,alias:'TYDQ_FS_FILE_MOVE_RIGHT'];
var procbyte:byte;
    dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    i,readpos:natuint;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^;
 for i:=moveend downto movestart do
  begin
   dp^.ReadDisk(dp,bp^.Media^.MediaId,i,1,procbyte);
   dp^.WriteDisk(dp,bp^.Media^.MediaId,i+movelength,1,@procbyte);
  end;
end;
function tydq_fs_disk_is_formatted(edl:efi_disk_list;diskindex:natuint):boolean;cdecl;[public,alias:'TYDQ_FS_DISK_IS_FORMATTED'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    fsh:tydqfs_header;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,0,sizeof(tydqfs_header),fsh);
 if(fsh.signature=$5D47291AD7E3F2B1) and (fsh.maxsize=(bp^.Media^.LastBlock+1)*bp^.Media^.BlockSize) and (fsh.usedsize>=sizeof(tydqfs_header)) then
 tydq_fs_disk_is_formatted:=true else tydq_fs_disk_is_formatted:=false;
end;
function tydq_fs_disk_exists(edl:efi_disk_list;diskname:PWideChar):boolean;cdecl;[public,alias:'TYDQ_FS_DISK_EXISTS'];
var i:natuint;
    fsh:tydqfs_header;
begin
 for i:=1 to edl.disk_count do
  begin
   fsh:=tydq_fs_read_header(edl,i);
   if(WstrCmp(diskname,@fsh.RootName)=0) then break;
  end;
 if(i>edl.disk_count) then tydq_fs_disk_exists:=false else tydq_fs_disk_exists:=true;
end;
function tydq_fs_file_exists(edl:efi_disk_list;diskindex:natuint;filename:PWideChar):boolean;cdecl;[public,alias:'TYDQ_FS_FILE_EXISTS'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    i,pos1,pos2,dpos,rpos:natuint;
    fsh:tydqfs_header;
    fsf,rfsf:tydqfs_file;
    partstr:PWideChar;
    bool:boolean;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^; fsh:=tydq_fs_read_header(edl,diskindex);
 pos1:=1; pos2:=2; bool:=true;
 if(WstrCmp(filename,'/')=0) and (Wstrlen(filename)=1) then exit(bool);
 while(pos2>0) do
  begin
   pos2:=Wstrpos(filename,'/',pos1+1);
   if(pos2>0) then partstr:=Wstrcutout(filename,pos1+1,pos2-1) else partstr:=Wstrcutout(filename,pos1+1,Wstrlen(filename));
   if(pos1=1) then
    begin
     i:=1;
     while(i<=fsh.RootCount div sizeof(natuint)) do
      begin
       dp^.ReadDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(i-1)*sizeof(natuint),sizeof(natuint),dpos);
       dp^.ReadDisk(dp,bp^.Media^.MediaId,dpos,sizeof(tydqfs_file),fsf);
       if(Wstrcmp(@fsf.fname,partstr)=0) then 
        begin
         rpos:=dpos; bool:=true; break;
        end;
       inc(i);
      end;
     if(i>fsh.RootCount div sizeof(natuint)) then 
      begin
       Wstrfree(partstr); bool:=false; break;
      end;
    end
   else if(pos1>1) then
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,rpos,sizeof(tydqfs_file),fsf);
     if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) and (fsf.fContentCount>0) then
      begin
       i:=1;
       while(i<=fsf.fContentCount div sizeof(natuint)) do
        begin
         dp^.ReadDisk(dp,bp^.Media^.MediaId,rpos+sizeof(tydqfs_file)+(i-1)*sizeof(natuint),sizeof(natuint),dpos);
         dp^.ReadDisk(dp,bp^.Media^.MediaId,dpos,sizeof(tydqfs_file),rfsf);
         if(Wstrcmp(@rfsf.fname,partstr)=0) then 
          begin
           rpos:=dpos; bool:=true; break;
          end;
         inc(i);
        end;
       if(i>fsf.fContentCount div sizeof(natuint)) then 
        begin
         Wstrfree(partstr); bool:=false; break;
        end;
      end
     else 
      begin
       if(WstrCmp(@fsf.fname,partstr)<>0) then bool:=false else bool:=true;
       Wstrfree(partstr); break;
      end;
    end;
   Wstrfree(partstr);
   pos1:=pos2;
  end;
 tydq_fs_file_exists:=bool;
end;
function tydq_fs_file_position(edl:efi_disk_list;diskindex:natuint;filename:PWideChar):natuint;cdecl;[public,alias:'TYDQ_FS_FILE_POSITION'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    fsh:tydqfs_header;
    fsf,rfsf:tydqfs_file;
    i,pos1,pos2,cpos,res:natuint;
    partstr:PWideChar;
begin 
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^; fsh:=tydq_fs_read_header(edl,diskindex);
 pos1:=1; pos2:=2; res:=0; 
 if(WstrCmp(filename,'/')=0) and (Wstrlen(filename)=1) then exit(res);
 while(pos2>0) do
  begin
   pos2:=Wstrpos(filename,'/',pos1+1);
   if(pos2>0) then partstr:=Wstrcutout(filename,pos1+1,pos2-1) else partstr:=Wstrcutout(filename,pos1+1,Wstrlen(filename));
   if(pos1=1) then
    begin
     i:=1;
     while(i<=fsh.RootCount div sizeof(natuint)) do
      begin
       dp^.ReadDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(i-1)*sizeof(natuint),sizeof(natuint),cpos);
       dp^.ReadDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),fsf);
       if(WstrCmp(@fsf.fname,partstr)=0) then 
        begin
         res:=cpos; break;
        end;
       inc(i);
      end;
     if(i>fsh.RootCount div sizeof(natuint)) then 
      begin
       Wstrfree(partstr);
       res:=0; break;
      end;
    end
   else if(pos1>1) then
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,res,sizeof(tydqfs_file),fsf);
     if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) and (fsf.fContentCount>0) then
      begin
       i:=1;
       while(i<=fsf.fContentCount div sizeof(natuint)) do
        begin
         dp^.ReadDisk(dp,bp^.Media^.MediaId,res+sizeof(tydqfs_file)+(i-1)*sizeof(natuint),sizeof(natuint),cpos);
         dp^.ReadDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),rfsf);
         if(WstrCmp(@rfsf.fname,partstr)=0) then 
          begin
           res:=cpos; break;
          end;
         inc(i);
        end;
       if(i>fsf.fContentCount div sizeof(natuint)) then 
        begin
         Wstrfree(partstr);
         res:=0; break;
        end;
      end
     else
      begin
       if(WstrCmp(@fsf.fname,partstr)<>0) then res:=0;
       Wstrfree(partstr); break;
      end;
    end;
   Wstrfree(partstr);
   pos1:=pos2;
  end;
 tydq_fs_file_position:=res;
end;
procedure tydq_fs_create_file(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;attr:byte;userlevel:byte);cdecl;[public,alias:'TYDQ_FS_CREATE_FILE'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    fsh:tydqfs_header;
    fsf,rfsf,pfsf:tydqfs_file;
    partstr:PWideChar;
    i,j,pos1,pos2,mpos,cpos,rpos:natuint;
    gtime:efi_time;
    ctime:efi_time_capabilities;
    bool:boolean;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^;
 fsh:=tydq_fs_read_header(edl,diskindex);
 if(fsh.usedsize+sizeof(natuint)+sizeof(tydqfs_file)>fsh.maxsize) then exit;
 if(tydq_fs_byte_to_attribute_bool(attr)[6]=true) and (userlevel<>userlevel_system) then exit;
 if(tydq_fs_byte_to_attribute_bool(attr)[6]=true) and (tydq_fs_byte_to_attribute_bool(attr)[7]=true) then exit;
 if(tydq_fs_file_exists(edl,diskindex,filename)=false) then
  begin
   pos1:=1; pos2:=2; mpos:=0; 
   while(pos2>0) do
    begin
     pos2:=Wstrpos(filename,'/',pos1+1);
     if(pos2>0) then
      begin
       bool:=tydq_fs_file_exists(edl,diskindex,Wstrcutout(filename,1,pos2-1));
       partstr:=Wstrcutout(filename,pos1+1,pos2-1);
       systemtable^.RuntimeServices^.GetTime(gtime,ctime);
       fsf:=tydq_file_initialize(tydqfs_folder,mpos,gtime,partstr);
       if(bool=false) then
        begin
         cpos:=fsh.usedsize+sizeof(natuint);
         if(mpos=0) then 
          begin
           i:=sizeof(tydqfs_header)+fsh.RootCount;
          end
         else if(mpos>0) then 
          begin
           dp^.ReadDisk(dp,bp^.Media^.Mediaid,mpos,sizeof(tydqfs_file),pfsf);
           i:=mpos+sizeof(tydqfs_file)+pfsf.fContentCount;
          end;
         while(i<fsh.usedsize) do
          begin
           dp^.ReadDisk(dp,bp^.Media^.MediaId,i,sizeof(tydqfs_header),rfsf);
           if(mpos=0) then
            begin
             if(rfsf.fparentpos>sizeof(tydqfs_header)+fsh.RootCount) then rfsf.fparentpos:=rfsf.fparentpos+sizeof(natuint);
            end
           else if(mpos>0) then
            begin
             if(rfsf.fparentpos>mpos+sizeof(tydqfs_file)+pfsf.fContentCount) then rfsf.fparentpos:=rfsf.fparentpos+sizeof(natuint);
            end;
           if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) and (rfsf.fContentCount>0) then
            begin
             for j:=1 to rfsf.fcontentCount div sizeof(natuint) do
              begin
               dp^.ReadDisk(dp,bp^.Media^.MediaId,i+sizeof(tydqfs_file)+(j-1)*sizeof(natuint),sizeof(natuint),rpos);
               rpos:=rpos+sizeof(natuint);
               dp^.WriteDisk(dp,bp^.Media^.MediaId,i+sizeof(tydqfs_file)+(j-1)*sizeof(natuint),sizeof(natuint),@rpos);
              end;
            end;
           dp^.WriteDisk(dp,bp^.Media^.MediaId,i,sizeof(tydqfs_file),@rfsf);
           inc(i,sizeof(tydqfs_file)+rfsf.fContentCount);
          end;
         if(mpos=0) then
          begin
           tydq_fs_disk_move_right(edl,diskindex,sizeof(tydqfs_header)+fsh.RootCount,fsh.usedsize-1,sizeof(natuint));
           dp^.WriteDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+fsh.RootCount,sizeof(natuint),@cpos);
           dp^.WriteDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),@fsf);
          end
         else if(mpos>0) then
          begin
           tydq_fs_disk_move_right(edl,diskindex,mpos+sizeof(tydqfs_file)+fsf.fContentCount,fsh.usedsize-1,sizeof(natuint));
           dp^.WriteDisk(dp,bp^.Media^.MediaId,mpos+sizeof(tydqfs_file)+fsf.fContentCount,sizeof(natuint),@cpos);
           dp^.WriteDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),@fsf);
          end;
         fsh.usedsize:=fsh.usedsize+sizeof(natuint)+sizeof(tydqfs_file);
         if(pos1=1) then fsh.RootCount:=fsh.RootCount+sizeof(natuint) else
          begin 
           pfsf.fContentCount:=pfsf.fcontentCount+sizeof(natuint);
           dp^.WriteDisk(dp,bp^.Media^.MediaId,mpos,sizeof(tydqfs_file),@pfsf);
          end;
        end
       else if(bool=true) then
        begin
         partstr:=Wstrcutout(filename,pos1+1,pos2-1);
         if(mpos=0) then
          begin
           for i:=1 to fsh.RootCount div sizeof(natuint) do
            begin
             dp^.ReadDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(i-1)*sizeof(natuint),sizeof(natuint),cpos);
             dp^.ReadDisk(dp,bp^.Media^.MediaId,cpos,sizeof(natuint),fsf);
             if(Wstrcmp(partstr,@fsf.fname)=0) then break;
            end;
          end
         else if(mpos>0) then
          begin
           dp^.ReadDisk(dp,bp^.Media^.MediaId,mpos,sizeof(tydqfs_file),rfsf);
           for i:=1 to fsh.RootCount div sizeof(natuint) do
            begin
             dp^.ReadDisk(dp,bp^.Media^.MediaId,mpos+sizeof(tydqfs_file)+(i-1)*sizeof(natuint),sizeof(natuint),cpos);
             dp^.ReadDisk(dp,bp^.Media^.MediaId,cpos,sizeof(natuint),fsf);
             if(Wstrcmp(partstr,@fsf.fname)=0) then break;
            end;
          end;
        end;
       mpos:=cpos;
       pos1:=pos2;
       Wstrfree(partstr);
      end
     else if(pos2=0) then
      begin
       partstr:=Wstrcutout(filename,pos1+1,Wstrlen(filename));
       systemtable^.RuntimeServices^.GetTime(gtime,ctime);
       fsf:=tydq_file_initialize(attr,mpos,gtime,partstr);
       cpos:=fsh.usedsize+sizeof(natuint);
       if(mpos=0) then
        begin
         tydq_fs_disk_move_right(edl,diskindex,sizeof(tydqfs_header)+fsh.RootCount,fsh.usedsize-1,sizeof(natuint));
         dp^.WriteDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+fsh.RootCount,sizeof(natuint),@cpos);
         dp^.WriteDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),@fsf);
        end
       else if(mpos>0) then
        begin
         tydq_fs_disk_move_right(edl,diskindex,mpos+sizeof(tydqfs_file)+fsf.fContentCount,fsh.usedsize-1,sizeof(natuint));
         dp^.WriteDisk(dp,bp^.Media^.MediaId,mpos+sizeof(tydqfs_file)+fsf.fContentCount,sizeof(natuint),@cpos);
         dp^.WriteDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),@fsf);
        end;
       fsh.usedsize:=fsh.usedsize+sizeof(natuint)+sizeof(tydqfs_file);
       if(pos1=1) then fsh.RootCount:=fsh.RootCount+sizeof(natuint)
       else
        begin
         dp^.ReadDisk(dp,bp^.Media^.MediaId,mpos,sizeof(tydqfs_file),rfsf);
         rfsf.fContentCount:=rfsf.fContentCount+sizeof(natuint);
         dp^.WriteDisk(dp,bp^.Media^.MediaId,mpos,sizeof(tydqfs_file),@rfsf);
        end;
       mpos:=cpos;
       Wstrfree(partstr);
      end;
    end;
   tydq_fs_write_header(edl,diskindex,fsh);
  end;
end;
function tydq_fs_list_file(edl:efi_disk_list;diskindex:natuint;path:PWideChar;detecthidden:boolean):tydqfs_file_list;cdecl;[public,alias:'TYDQ_FS_LIST_FILE'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    fsh:tydqfs_header;
    fsf,rfsf:tydqfs_file;
    i,pos1,pos2,mpos,cpos,rpos,mysize1,mysize2:natuint;
    partstr:PWideChar;
    res:tydqfs_file_list;
    canaddtolist,canaddtolist2:boolean;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^; fsh:=tydq_fs_read_header(edl,diskindex); 
 res.files_basepath:=nil; res.files_content:=nil; res.files_count:=0;
 if(tydq_fs_file_exists(edl,diskindex,path)=true) then
  begin
   pos1:=1; pos2:=2; mpos:=0;
   if(Wstrlen(path)=1) and (WstrCmp(path,'/')=0) then pos2:=0;
   while(pos2>0) do
    begin 
     pos2:=Wstrpos(path,'/',pos1+1);
     if(pos2>0) then partstr:=Wstrcutout(path,pos1+1,pos2-1) else partstr:=Wstrcutout(path,pos1+1,Wstrlen(path));
     if(pos1=1) then
      begin
       for i:=1 to fsh.RootCount div sizeof(natuint) do
        begin
         dp^.ReadDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(i-1)*sizeof(natuint),sizeof(natuint),cpos);
         dp^.ReadDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),rfsf);
         if(WstrCmp(partstr,@rfsf.fname)=0) then
          begin
           mpos:=cpos; break;
          end;
        end;
      end
     else if(pos1>1) then
      begin
       dp^.ReadDisk(dp,bp^.Media^.MediaId,mpos,sizeof(tydqfs_file),fsf);
       if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) and (fsf.fContentCount>0) then
        begin
         for i:=1 to fsf.fContentCount div sizeof(natuint) do
          begin
           dp^.ReadDisk(dp,bp^.Media^.MediaId,mpos+sizeof(tydqfs_file)+(i-1)*sizeof(natuint),sizeof(natuint),cpos);
           dp^.ReadDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),rfsf);
           if(WstrCmp(partstr,@rfsf.fname)=0) then
            begin
             mpos:=cpos; break;
            end;
          end;
        end;
      end;
     pos1:=pos2;
     Wstrfree(partstr);
    end;
   res.files_basepath:=allocmem(sizeof(PWideChar));
   res.files_content:=allocmem(sizeof(PWideChar));
   res.files_count:=0;
   if(mpos=0) then
    begin
     for i:=1 to fsh.RootCount div sizeof(natuint) do
      begin
       dp^.ReadDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(i-1)*sizeof(natuint),sizeof(natuint),rpos);
       dp^.ReadDisk(dp,bp^.Media^.MediaId,rpos,sizeof(tydqfs_file),fsf);
       inc(res.files_count);
       mysize1:=getmemsize(res.files_basepath);
       res.files_content:=res.files_content-mysize1;
       ReallocMem(res.files_basepath,sizeof(PWideChar)*res.files_count);
       mysize2:=getmemsize(res.files_content);
       res.files_basepath:=res.files_basepath-mysize2;
       ReallocMem(res.files_content,sizeof(PWideChar)*res.files_count);
       if(res.files_count>=2) then
        begin
         (res.files_basepath+res.files_count-2)^:=(res.files_basepath+res.files_count-2)^-mysize1-mysize2;
         (res.files_content+res.files_count-2)^:=(res.files_content+res.files_count-2)^-mysize1-mysize2;
        end;
       Wstrinit((res.files_basepath+res.files_count-1)^,Wstrlen(path));
       Wstrset((res.files_basepath+res.files_count-1)^,path);
       Wstrinit((res.files_content+res.files_count-1)^,Wstrlen(@fsf.fname));
       Wstrset((res.files_content+res.files_count-1)^,@fsf.fname);
       if(detecthidden=true) then canaddtolist:=true 
       else if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[5]=true) then canaddtolist:=false
       else canaddtolist:=true;
       if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) and (canaddtolist=true) and (fsf.fContentCount>0) then
        begin
         if(Wstrcmp(path,'/')=0) and (Wstrlen(path)=1) then
          begin
           Wstrinit(partstr,Wstrlen((res.files_content+res.files_count-1)^)+1);
           WstrSet(partstr,'/'); WstrCat(partstr,@fsf.fname);
          end
         else
          begin
           Wstrinit(partstr,Wstrlen((res.files_basepath+res.files_count-1)^)+Wstrlen((res.files_content+res.files_count-1)^)+1);
           Wstrset(partstr,path); WstrCat(partstr,'/'); WstrCat(partstr,@fsf.fname);
          end;
         res:=tydq_fs_filelist_combine(res,tydq_fs_list_file(edl,diskindex,partstr,detecthidden));
         Wstrfree(partstr);
        end;
      end;
    end
   else if(mpos>0) then
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,mpos,sizeof(tydqfs_file),rfsf);
     if(detecthidden=true) then canaddtolist:=true
     else if(tydq_fs_byte_to_attribute_bool(rfsf.fattribute)[5]=true) then canaddtolist:=false
     else canaddtolist:=true;
     if(tydq_fs_byte_to_attribute_bool(rfsf.fattribute)[8]=true) and (canaddtolist=true) then
      begin
       for i:=1 to rfsf.fContentCount div sizeof(natuint) do
        begin
         dp^.ReadDisk(dp,bp^.Media^.MediaId,mpos+sizeof(tydqfs_file)+(i-1)*sizeof(natuint),sizeof(natuint),rpos);
         dp^.ReadDisk(dp,bp^.Media^.MediaId,rpos,sizeof(tydqfs_file),fsf);
         inc(res.files_count);
         mysize1:=getmemsize(res.files_basepath);
         res.files_content:=res.files_content-mysize1;
         ReallocMem(res.files_basepath,sizeof(PWideChar)*res.files_count);
         mysize2:=getmemsize(res.files_content);
         res.files_basepath:=res.files_basepath-mysize2;
         ReallocMem(res.files_content,sizeof(PWideChar)*res.files_count);
         if(res.files_count>=2) then
          begin
           (res.files_basepath+res.files_count-2)^:=(res.files_basepath+res.files_count-2)^-mysize1-mysize2;
           (res.files_content+res.files_count-2)^:=(res.files_content+res.files_count-2)^-mysize1-mysize2;
          end;
         Wstrinit((res.files_basepath+res.files_count-1)^,Wstrlen(path));
         Wstrset((res.files_basepath+res.files_count-1)^,path);
         Wstrinit((res.files_content+res.files_count-1)^,Wstrlen(@fsf.fname));
         Wstrset((res.files_content+res.files_count-1)^,@fsf.fname);
         if(detecthidden=true) then canaddtolist2:=true
         else if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[5]=true) then canaddtolist2:=false
         else canaddtolist2:=true;
         if(tydq_fs_byte_to_attribute_bool(rfsf.fattribute)[5]=canaddtolist) and (canaddtolist2=true) and (fsf.fContentCount>0) then
          begin 
           if(Wstrcmp(path,'/')=0) and (WStrlen(path)=1) then
            begin
             Wstrinit(partstr,Wstrlen((res.files_content+res.files_count-1)^)+1);
             WstrSet(partstr,'/'); WstrCat(partstr,@fsf.fname);
            end
          else
           begin
            Wstrinit(partstr,Wstrlen((res.files_basepath+res.files_count-1)^)+Wstrlen((res.files_content+res.files_count-1)^)+1);
            Wstrset(partstr,path); WstrCat(partstr,'/'); WstrCat(partstr,@fsf.fname);
           end;
          res:=tydq_fs_filelist_combine(res,tydq_fs_list_file(edl,diskindex,partstr,detecthidden));
          Wstrfree(partstr);
         end;
        end;
       end
      else if(canaddtolist=true) then
       begin
        res.files_count:=1;
        Wstrinit((res.files_basepath+res.files_count-1)^,Wstrlen(path));
        Wstrset((res.files_basepath+res.files_count-1)^,path);
        Wstrinit((res.files_content+res.files_count-1)^,Wstrlen(@rfsf.fname));
        Wstrset((res.files_content+res.files_count-1)^,@rfsf.fname);
       end;
    end;
  end;
 tydq_fs_list_file:=res;
end;
function tydq_fs_delete_file(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte):byte;cdecl;[public,alias:'TYDQ_FS_DELETE_FILE'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    fsl:tydqfs_file_list;
    fstl:tydqfs_file_total_list;
    i,j,k,zero:natuint;
    procstr:PWideChar;
    procnum:natuint;
    fsf,rfsf,pfsf:tydqfs_file;
    fsh:tydqfs_header;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^; fsh:=tydq_fs_read_header(edl,diskindex); zero:=0;
 if(Wstrcmp(filename,'/')=0) and (Wstrlen(filename)=1) then exit(1);
 if(tydq_fs_file_exists(edl,diskindex,filename)=false) then exit(2);
 fsl:=tydq_fs_list_file(edl,diskindex,filename,true);
 fstl.files_fullpath:=allocmem(sizeof(PWideChar)*fsl.files_count);
 fstl.files_position:=allocmem(sizeof(natuint)*fsl.files_count);
 fstl.files_count:=fsl.files_count;
 for i:=1 to fstl.files_count do 
  begin
   (fstl.files_fullpath+i-1)^:=tydq_combine_path_and_filename((fsl.files_basepath+i-1)^,(fsl.files_content+i-1)^);
   (fstl.files_position+i-1)^:=tydq_fs_file_position(edl,diskindex,(fstl.files_fullpath+i-1)^);
   Wstrfree((fsl.files_basepath+i-1)^); Wstrfree((fsl.files_content+i-1)^);
  end;
 freemem(fsl.files_basepath); freemem(fsl.files_content); fsl.files_count:=0;
 for i:=1 to fstl.files_count-1 do
  for j:=i+1 to fstl.files_count do
   begin
    if((fstl.files_position+i-1)^>(fstl.files_position+j-1)^) then
     begin
      procstr:=(fstl.files_fullpath+i-1)^;
      (fstl.files_fullpath+i-1)^:=(fstl.files_fullpath+j-1)^;
      (fstl.files_fullpath+j-1)^:=procstr;
      procnum:=(fstl.files_position+i-1)^;
      (fstl.files_position+i-1)^:=(fstl.files_position+j-1)^;
      (fstl.files_position+j-1)^:=procnum;
     end;
   end;
 procstr:=nil; procnum:=0;
 for i:=fstl.files_count downto 1 do
  begin
   dp^.ReadDisk(dp,bp^.Media^.MediaId,(fstl.files_position+i-1)^,sizeof(tydqfs_file),fsf);
   if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) and (userlevel<>userlevel_system) then 
    begin
     for j:=fstl.files_count downto 1 do Wstrfree((fstl.files_fullpath+j-1)^); 
     freemem(fstl.files_fullpath); freemem(fstl.files_position); fstl.files_count:=0;
     exit(3);
    end;
  end;
 for i:=fstl.files_count downto 1 do
  begin 
   if((fstl.files_position+i-1)^=0) then continue;
   dp^.ReadDisk(dp,bp^.Media^.MediaId,(fstl.files_position+i-1)^,sizeof(tydqfs_file),fsf);
   if(fsf.fparentpos=0) then j:=sizeof(tydqfs_header)+fsh.RootCount
   else if(fsf.fparentpos>0) then j:=(fstl.files_position+i-1)^+sizeof(tydqfs_file)+fsf.fContentCount;
   while(j<fsh.usedsize) do
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,j,sizeof(tydqfs_file),pfsf);
     if(fsf.fparentpos=0) then
      begin
       if(pfsf.fparentpos>sizeof(tydqfs_header)+fsh.RootCount) then 
       pfsf.fparentpos:=pfsf.fparentpos-sizeof(natuint)-sizeof(tydqfs_file)-fsf.fContentCount;
      end
     else if(fsf.fparentpos>0) then
      begin
       if(pfsf.fparentpos>(fstl.files_position+i-1)^+sizeof(tydqfs_file)+fsf.fContentCount) then 
       pfsf.fparentpos:=pfsf.fparentpos-sizeof(natuint)-sizeof(tydqfs_file)-fsf.fContentCount;
      end;
     if(tydq_fs_byte_to_attribute_bool(pfsf.fattribute)[8]=true) and (pfsf.fContentCount>0) then
      begin
       for k:=1 to pfsf.fContentCount div sizeof(natuint) do
        begin
         dp^.ReadDisk(dp,bp^.Media^.MediaId,j+sizeof(tydqfs_file)+(k-1)*sizeof(natuint),sizeof(natuint),procnum);
         procnum:=procnum-sizeof(natuint)-sizeof(tydqfs_file)-fsf.fContentCount;
         dp^.WriteDisk(dp,bp^.Media^.MediaId,j+sizeof(tydqfs_file)+(k-1)*sizeof(natuint),sizeof(natuint),@procnum);
        end;
      end;
     dp^.WriteDisk(dp,bp^.Media^.MediaId,j,sizeof(tydqfs_file),@pfsf);
     inc(j,sizeof(tydqfs_file)+pfsf.fContentCount);
    end;
   if(fsf.fparentpos=0) then
    begin
     dp^.WriteDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+fsh.RootCount-sizeof(natuint),sizeof(natuint),@zero);
     tydq_fs_disk_move_left(edl,diskindex,(fstl.files_position+i-1)^+sizeof(tydqfs_file)+fsf.fContentCount,fsh.usedsize-1,sizeof(natuint)+sizeof(tydqfs_file)
     +fsf.fContentCount);
     if(fsh.RootCount>=sizeof(natuint)) then fsh.RootCount:=fsh.RootCount-sizeof(natuint);
    end
   else if(fsf.fparentpos>0) then
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,fsf.fparentpos,sizeof(tydqfs_file),rfsf);
     dp^.WriteDisk(dp,bp^.Media^.MediaId,fsf.fparentpos+sizeof(tydqfs_file)+rfsf.fContentCount-sizeof(natuint),sizeof(natuint),@zero);
     tydq_fs_disk_move_left(edl,diskindex,(fstl.files_position+i-1)^+sizeof(tydqfs_file)+fsf.fContentCount,fsh.usedsize-1,sizeof(natuint)+sizeof(tydqfs_file)
     +fsf.fContentCount);
     if(rfsf.fContentCount>=sizeof(natuint)) then rfsf.fContentCount:=rfsf.fContentCount-sizeof(natuint);
     dp^.WriteDisk(dp,bp^.Media^.MediaId,fsf.fparentpos,sizeof(tydqfs_file),@rfsf);
    end;
   fsh.usedsize:=fsh.usedsize-sizeof(natuint)-sizeof(tydqfs_file)-fsf.fContentCount;
  end;
 for i:=fstl.files_count downto 1 do Wstrfree((fstl.files_fullpath+i-1)^); 
 freemem(fstl.files_fullpath); freemem(fstl.files_position);
 tydq_fs_write_header(edl,diskindex,fsh);
 tydq_fs_delete_file:=0;
end;
function tydq_fs_file_read(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;position,readlength:natuint;userlevel:byte):tydqfs_data;cdecl;[public,alias:'TYDQ_FS_FILE_READ'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    i,fpos:natuint;
    fsd:tydqfs_data;
    fsf:tydqfs_file;
    rbyte:byte;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^; 
 fsd.fsdata:=nil; fsd.fssize:=0;
 if(tydq_fs_file_exists(edl,diskindex,filename)=false) then exit(fsd);
 fpos:=tydq_fs_file_position(edl,diskindex,filename);
 dp^.ReadDisk(dp,bp^.Media^.MediaId,fpos,sizeof(tydqfs_file),fsf);
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) then exit(fsd);
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) and (userlevel<>userlevel_system) then exit(fsd);
 if(position>fsf.fContentCount) then exit(fsd);
 fsd.fsdata:=allocmem(1);
 for i:=1 to readlength do
  begin
   inc(fsd.fssize);
   ReallocMem(fsd.fsdata,fsd.fssize);
   dp^.ReadDisk(dp,bp^.Media^.MediaId,fpos+sizeof(tydqfs_file)+position-1+i-1,1,(fsd.fsdata+fsd.fssize-1)^);
   if(position+i-1>fsf.fContentCount) then break;
  end;
 tydq_fs_file_read:=fsd;
end;
function tydq_fs_file_info(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte):tydqfs_file;cdecl;[public,alias:'TYDQ_FS_FILE_INFO'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    fpos:natuint;
    fsf:tydqfs_file;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^;
 fpos:=tydq_fs_file_position(edl,diskindex,filename);
 fsf.fparentpos:=0; fsf.fattribute:=0; fsf.fName[1]:=#0; fsf.fcontentCount:=0;
 if(fpos=0) then exit(fsf);
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) and (userlevel<>userlevel_system) then exit(fsf);
 dp^.ReadDisk(dp,bp^.Media^.MediaId,fpos,sizeof(tydqfs_file),fsf);
 tydq_fs_file_info:=fsf;
end;
procedure tydq_fs_file_write(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;offset:natuint;writedata:Pointer;writesize:natuint;userlevel:byte);cdecl;[public,alias:'TYDQ_FS_FILE_WRITE'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    i,j,fpos,dpos,rpos,len:natuint;
    fsh:tydqfs_header;
    fsf,rfsf,pfsf:tydqfs_file;
    status:boolean;
    gtime:efi_time;
    ctime:efi_time_capabilities;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^; fsh:=tydq_fs_read_header(edl,diskindex);
 fpos:=tydq_fs_file_position(edl,diskindex,filename);
 if(fpos=0) then exit;
 if(fpos+sizeof(fsf)+offset+writesize>=fsh.maxsize) then exit;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,fpos,sizeof(tydqfs_file),fsf);
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) then exit;
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) and (userlevel<>userlevel_system) then exit;
 if(offset+writesize>fsf.fContentCount) then status:=true else status:=false;
 if(status) then
  begin
   len:=offset+writesize-fsf.fContentCount;
   if(fsf.fparentpos=0) then 
    begin
     for i:=1 to fsh.RootCount div sizeof(natuint) do
      begin
       dp^.ReadDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(i-1)*sizeof(natuint),sizeof(natuint),rpos);
       if(rpos>=fpos+sizeof(tydqfs_file)+fsf.fContentCount) then rpos:=rpos+len;
       dp^.WriteDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(i-1)*sizeof(natuint),sizeof(natuint),@rpos);
      end;
    end
   else if(fsf.fparentpos>0) then 
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,fsf.fparentpos,sizeof(tydqfs_file),pfsf);
     for i:=1 to pfsf.fContentCount div sizeof(natuint) do
      begin
       dp^.ReadDisk(dp,bp^.Media^.MediaId,fsf.fparentpos+sizeof(tydqfs_file)+(i-1)*sizeof(natuint),sizeof(natuint),rpos);
       if(rpos>=fpos+sizeof(tydqfs_file)+fsf.fContentCount) then rpos:=rpos+len;
       dp^.WriteDisk(dp,bp^.Media^.MediaId,fsf.fparentpos+sizeof(tydqfs_file)+(i-1)*sizeof(natuint),sizeof(natuint),@rpos);
      end;
    end;
   i:=fpos+sizeof(tydqfs_file)+fsf.fContentCount;
   while(i<fsh.usedsize) do
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,i,sizeof(tydqfs_file),rfsf);
     if(fsf.fparentpos=0) then
      begin
       if(rfsf.fparentpos>sizeof(tydqfs_header)+fsh.RootCount) then
       rfsf.fparentpos:=rfsf.fparentpos+len;
      end
     else if(fsf.fparentpos>0) then
      begin
       if(rfsf.fparentpos>fpos+sizeof(tydqfs_file)+fsf.fContentCount) then
       rfsf.fparentpos:=rfsf.fparentpos+len;
      end;
     if(tydq_fs_byte_to_attribute_bool(rfsf.fattribute)[8]=true) and (rfsf.fContentCount>0) then
      begin
       for j:=1 to rfsf.fContentCount div sizeof(natuint) do
        begin
         dp^.ReadDisk(dp,bp^.Media^.MediaId,i+sizeof(tydqfs_file)+(j-1)*sizeof(natuint),sizeof(natuint),dpos);
         dpos:=dpos+len;
         dp^.WriteDisk(dp,bp^.Media^.MediaId,i+sizeof(tydqfs_file)+(j-1)*sizeof(natuint),sizeof(natuint),@dpos);
        end;
      end;
     inc(i,sizeof(tydqfs_file)+rfsf.fContentCount);
    end;
   fsf.fContentCount:=offset+writesize;
   tydq_fs_disk_move_right(edl,diskindex,fpos+sizeof(tydqfs_file)+fsf.fContentCount-len,fsh.usedsize-1,len);
   dp^.WriteDisk(dp,bp^.Media^.MediaId,fpos+sizeof(tydqfs_file)+offset,writesize,writedata);
   fsh.usedsize:=fsh.usedsize+len;
  end
 else dp^.WriteDisk(dp,bp^.Media^.MediaId,fpos+sizeof(tydqfs_file)+offset,writesize,writedata);
 systemtable^.RuntimeServices^.GetTime(gtime,ctime);
 fsf.flastedittime:=efi_time_to_tydq_fs_time(gtime);
 dp^.WriteDisk(dp,bp^.Media^.MediaId,fpos,sizeof(tydqfs_file),@fsf);
 tydq_fs_write_header(edl,diskindex,fsh);
end;
procedure tydq_fs_file_rewrite(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;writedata:Pointer;writesize:natuint;userlevel:byte);cdecl;[public,alias:'TYDQ_FS_FILE_REWRITE'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    i,j,fpos,rpos:natuint;
    fsh:tydqfs_header;
    fsf,rfsf:tydqfs_file;
    toffset:natint;
    gtime:efi_time;
    ctime:efi_time_capabilities;
    status:efi_status;
begin 
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^; fsh:=tydq_fs_read_header(edl,diskindex);
 fpos:=tydq_fs_file_position(edl,diskindex,filename);
 if(fpos=0) then exit;
 if(fpos+sizeof(fsf)+writesize>=fsh.maxsize) then exit;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,fpos,sizeof(tydqfs_file),fsf);
 toffset:=fsf.fContentCount-writesize;
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) then exit;
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) and (userlevel<>userlevel_system) then exit;
 if(fsf.fparentpos=0) then
  begin
   for i:=1 to fsh.RootCount div sizeof(natuint) do
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(i-1)*sizeof(natuint),sizeof(natuint),rpos);
     if(rpos>=fpos+sizeof(tydqfs_file)+fsf.fContentCount) then rpos:=rpos-toffset;
     dp^.WriteDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(i-1)*sizeof(natuint),sizeof(natuint),@rpos);
    end;
  end
 else if(fsf.fparentpos>0) then
  begin
   dp^.ReadDisk(dp,bp^.Media^.MediaId,fsf.fparentpos,sizeof(tydqfs_file),rfsf);
   for i:=1 to rfsf.fContentCount div sizeof(natuint) do
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,fsf.fparentpos+sizeof(tydqfs_file)+(i-1)*sizeof(natuint),sizeof(natuint),rpos);
     if(rpos>=fpos+sizeof(tydqfs_file)+fsf.fContentCount) then rpos:=rpos-toffset;
     dp^.WriteDisk(dp,bp^.Media^.MediaId,fsf.fparentpos+sizeof(tydqfs_file)+(i-1)*sizeof(natuint),sizeof(natuint),@rpos);
    end;
  end;
 i:=fpos+sizeof(tydqfs_file)+fsf.fContentCount;
 while(i<fsh.usedsize) do
  begin
   dp^.ReadDisk(dp,bp^.Media^.MediaId,i,sizeof(tydqfs_file),rfsf);
   if(fsf.fparentpos=0) then
    begin
     if(rfsf.fparentpos>sizeof(tydqfs_header)+fsh.RootCount) then rfsf.fparentpos:=rfsf.fparentpos-toffset;
    end
   else if(fsf.fparentpos>0) then
    begin
     if(rfsf.fparentpos>fpos+sizeof(tydqfs_file)+fsf.fContentCount) then rfsf.fparentpos:=rfsf.fparentpos-toffset;
    end;
   if(tydq_fs_byte_to_attribute_bool(rfsf.fattribute)[8]=true) and (rfsf.fContentCount>0) then 
    begin
     for j:=1 to rfsf.fContentCount div sizeof(natuint) do
      begin
       dp^.ReadDisk(dp,bp^.Media^.MediaId,i+sizeof(tydqfs_file)+(j-1)*sizeof(natuint),sizeof(natuint),rpos);
       rpos:=rpos-toffset;
       dp^.WriteDisk(dp,bp^.Media^.MediaId,i+sizeof(tydqfs_file)+(j-1)*sizeof(natuint),sizeof(natuint),@rpos); 
      end;
    end;
   inc(i,sizeof(tydqfs_file)+rfsf.fContentCount);
  end;
 if(toffset>0) then
  begin
   tydq_fs_disk_move_left(edl,diskindex,fpos+sizeof(tydqfs_file)+fsf.fContentCount,fsh.usedsize-1,toffset);
   dp^.WriteDisk(dp,bp^.Media^.MediaId,fpos+sizeof(tydqfs_file),writesize,writedata);
  end
 else if(toffset<0) then
  begin
   tydq_fs_disk_move_right(edl,diskindex,fpos+sizeof(tydqfs_file)+fsf.fContentCount,fsh.usedsize-1,-toffset);
   dp^.WriteDisk(dp,bp^.Media^.MediaId,fpos+sizeof(tydqfs_file),writesize,writedata);
  end
 else if(toffset=0) then
  begin 
   dp^.WriteDisk(dp,bp^.Media^.MediaId,fpos+sizeof(tydqfs_file),writesize,writedata);
  end;
 fsf.fContentCount:=writesize; 
 systemtable^.RuntimeServices^.GetTime(gtime,ctime);
 fsf.flastedittime:=efi_time_to_tydq_fs_time(gtime);
 dp^.WriteDisk(dp,bp^.Media^.MediaId,fpos,sizeof(tydqfs_file),@fsf);
 fsh.usedsize:=fsh.usedsize-toffset;
 tydq_fs_write_header(edl,diskindex,fsh);
end;
function tydq_fs_systeminfo_init:tydqfs_system_info;cdecl;[public,alias:'TYDQ_FS_SYSTEMINFO_INIT'];
var tydqsysteminfo:tydqfs_system_info;
begin
 tydqsysteminfo.header.tydqgraphics:=false;
 tydqsysteminfo.header.tydqnetwork:=false;
 tydqsysteminfo.header.tydqsyslang:=0;
 tydqsysteminfo.header.tydqusercount:=0;
 tydqsysteminfo.userinfolist:=nil;
end;
procedure tydq_fs_create_systeminfo_file(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint);cdecl;[public,alias:'TYDQ_FS_CREATE_SYSTEMINFO_FILE'];
var total_info_str:PChar;
    encrypted_info_str:PChar;
begin
 if(tydq_fs_disk_is_formatted(edl,diskindex)=false) then exit;
 if(diskindex>edl.disk_count) then exit;
 strinit(total_info_str,1024*128);
 strset(total_info_str,'[Systeminfo]'#10);
 strCat(total_info_str,'Graphics=False'#10);
 strCat(total_info_str,'EnableNetwork=False'#10);
 strCat(total_info_str,'Language=English'#10);
 strCat(total_info_str,'UserCount=0');
 encrypted_info_str:=PChar_encrypt_to_passwd(total_info_str);
 strfree(total_info_str);
 tydq_fs_create_file(systemtable,edl,diskindex,'/SystemInfo.dqi',tydqfs_hidden_file or tydqfs_system_file,userlevel_system);
 tydq_fs_file_rewrite(systemtable,edl,diskindex,'/SystemInfo.dqi',encrypted_info_str,sizeof(Char)*(strlen(encrypted_info_str)+1),userlevel_system);
end;
function tydq_fs_systeminfo_read(systemtable:Pefi_system_table;edl:efi_disk_list):tydqfs_system_info;cdecl;[public,alias:'TYDQ_FS_SYSTEMINFO_READ'];
var readfsdata:tydqfs_data;
    res:tydqfs_system_info;
    i,j,index,linecount,position,optionpos,optionnum,usercount,mysize1,mysize2,mysize3:natuint;
    passwd,orgstr,optionstr,valuestr,partstr:Pchar;
    partstr2:PwideChar;
    fsf:tydqfs_file;
    dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    issysteminfo:boolean;
begin
 index:=1; issysteminfo:=false;
 while(index<=edl.disk_count) do
  begin
   fsf:=tydq_fs_file_info(edl,index,'/SystemInfo.dqi',userlevel_system);
   if(tydq_fs_file_exists(edl,index,'/SystemInfo.dqi')) and (fsf.fattribute=tydqfs_system_file or tydqfs_hidden_file) then break;
   inc(index);
  end;
 if(index>edl.disk_count) then exit(tydq_fs_systeminfo_init);
 dp:=(edl.disk_content+index-1)^; bp:=(edl.disk_block_content+index-1)^;
 position:=tydq_fs_file_position(edl,index,'/SystemInfo.dqi');
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position,sizeof(tydqfs_file),fsf);
 readfsdata:=tydq_fs_file_read(edl,index,'/SystemInfo.dqi',1,fsf.fContentCount,userlevel_system);
 passwd:=PChar(readfsdata.fsdata); orgstr:=Passwd_decrypt_to_PChar(passwd); strfree(passwd);
 i:=1; optionnum:=0; usercount:=0; res.userinfolist:=allocmem(sizeof(tydqfs_user_info));
 while(i<=readfsdata.fssize-1) do
  begin
   inc(optionnum);
   if(optionnum>=6) and (usercount<(optionnum-5) div 2) then
    begin
     freemem(res.userinfolist); break;
    end
   else if(optionnum=6) then
    begin
     res.userinfolist:=allocmem(sizeof(tydqfs_user_info)*usercount);
    end;
   j:=strpos(orgstr,#10,i);
   if(j>0) then partstr:=strcutout(orgstr,i,j) else partstr:=strcutout(orgstr,i,readfsdata.fssize-1);
   if(optionnum>1) then
    begin
     optionpos:=strpos(partstr,'=',1);
     optionstr:=strcutout(partstr,1,optionpos-1);
     valuestr:=strcutout(partstr,optionpos+1,strlen(partstr));
    end;
   if(optionnum=1) and (strcmp(partstr,'[SystemInfo]')<>0) then
    begin
     res:=tydq_fs_systeminfo_init; break;
    end
   else if(optionnum=1) then issysteminfo:=true;
   if(optionnum=2) and (strcmp(optionstr,'Graphics')<>0) then
    begin
     res:=tydq_fs_systeminfo_init; break;
    end
   else if(optionnum=2) then
    begin
     if(strcmp(valuestr,'True')=0) then res.header.tydqgraphics:=true else res.header.tydqgraphics:=false;
    end;
   if(optionnum=3) and (strcmp(optionstr,'EnableNetwork')<>0) then
    begin
     res:=tydq_fs_systeminfo_init; break;
    end
   else if(optionnum=3) then
    begin
     if(strcmp(valuestr,'True')=0) then res.header.tydqnetwork:=true else res.header.tydqnetwork:=false;
    end;
   if(optionnum=4) and (strcmp(optionstr,'Language')<>0) then
    begin
     res:=tydq_fs_systeminfo_init; break;
    end
   else if(optionnum=4) then
    begin
     if(strcmp(valuestr,'English')=0) then res.header.tydqsyslang:=1 else res.header.tydqsyslang:=2;
    end;
   if(optionnum=5) and (strcmp(optionstr,'UserCount')<>0) then
    begin
     res:=tydq_fs_systeminfo_init; break;
    end
   else if(optionnum=5) then
    begin
     usercount:=PCharToUint(valuestr);
    end;
   if(optionnum>=6) and ((optionnum-5) mod 2=1) and (strcmp(optionstr,'UserName')<>0) then
    begin
     res:=tydq_fs_systeminfo_init; break;
    end
   else if(optionnum>=6) and ((optionnum-5) mod 2=1) then
    begin
      partstr2:=PCharToPWChar(valuestr);
      Wstrinit((res.userinfolist+(optionnum-5) div 2)^.username,strlen(valuestr));
      Wstrset((res.userinfolist+(optionnum-5) div 2)^.username,partstr2);
      freemem(partstr2);
    end;
   if(optionnum>=6) and ((optionnum-5) mod 2=0) and (strcmp(optionstr,'UserPasswd')<>0) then
    begin
     res:=tydq_fs_systeminfo_init; break;
    end
   else if(optionnum>=6) and ((optionnum-5) mod 2=0) then
    begin
      partstr2:=PCharToPWChar(valuestr);
      Wstrinit((res.userinfolist+(optionnum-5) div 2)^.userpasswd,strlen(valuestr));
      Wstrset((res.userinfolist+(optionnum-5) div 2)^.userpasswd,partstr2);
      freemem(partstr2);
    end;
   if(j>0) then i:=j+1 else i:=readfsdata.fssize;
   if(optionnum=6) then
    begin
     if(Natuint(res.userinfolist)>Natuint(optionstr)) then mysize1:=getmemsize(optionstr) else mysize1:=0;
     if(Natuint(res.userinfolist)>Natuint(partstr)) then mysize2:=getmemsize(partstr) else mysize2:=0;
     if(Natuint(res.userinfolist)>Natuint(valuestr)) then mysize3:=getmemsize(partstr) else mysize3:=0;
     res.userinfolist:=res.userinfolist-mysize1-mysize2-mysize3;
    end;
   if(optionnum>1) then strfree(optionstr); strfree(partstr); strfree(valuestr);
  end;
 strfree(orgstr);
 tydq_fs_systeminfo_read:=res;
end;
procedure tydq_fs_systeminfo_write(systemtable:Pefi_system_table;edl:efi_disk_list;writeinfo:tydqfs_system_info);cdecl;[public,alias:'TYDQ_FS_SYSTEMINFO_WRITE'];
var position,index:natuint;
    dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    orgstr,passwdstr,partstr:PChar;
    fsf:tydqfs_file;
    i,j:natuint;
begin
  index:=1;
  while(index<=edl.disk_count) do
   begin
     fsf:=tydq_fs_file_info(edl,index,'/SystemInfo.dqi',userlevel_system);
     if(tydq_fs_file_exists(edl,index,'/SystemInfo.dqi')) and (fsf.fattribute=tydqfs_system_file or tydqfs_hidden_file) then break;
     inc(index);
   end;
  if(index>edl.disk_count) then exit;
  Strinit(orgstr,1024*128);
  Strset(orgstr,'[SystemInfo]'#10);
  if(writeinfo.header.tydqgraphics=true) then
   begin
    strcat(orgstr,'Graphics=True'#10);
   end
  else if(writeinfo.header.tydqgraphics=false) then
   begin
    strcat(orgstr,'Graphics=False'#10);
   end;
  if(writeinfo.header.tydqnetwork=true) then
   begin
    strcat(orgstr,'EnableNetwork=True'#10);
   end
  else if(writeinfo.header.tydqnetwork=false) then
   begin
    strcat(orgstr,'EnableNetwork=False'#10);
   end;
  if(writeinfo.header.tydqsyslang=1) then
   begin
    strcat(orgstr,'Language=English'#10);
   end
  else if(writeinfo.header.tydqsyslang=2) then
   begin
    strcat(orgstr,'Language=Chinese'#10);
   end;
  strcat(orgstr,'UserCount=');
  partstr:=UintToPChar(writeinfo.header.tydqusercount);
  strcat(orgstr,partstr);
  strcat(orgstr,#10);
  strfree(partstr);
  for i:=1 to writeinfo.header.tydqusercount do
   begin
     strcat(orgstr,'UserName=');
     strcat(orgstr,PWCharToPChar((writeinfo.userinfolist+i-1)^.username));
     strcat(orgstr,#10);
     strcat(orgstr,'UserPasswd=');
     strcat(orgstr,PWCharToPChar((writeinfo.userinfolist+i-1)^.userpasswd));
     if(i<writeinfo.header.tydqusercount) then strcat(orgstr,#10);
   end;
  passwdstr:=PChar_encrypt_to_passwd(orgstr);
  tydq_fs_file_rewrite(systemtable,edl,index,'/SystemInfo.dqi',passwdstr,sizeof(char)*(strlen(passwdstr)+1),userlevel_system);
  strfree(passwdstr);
  strfree(orgstr);
end;
begin
 Wstrinit(tydqcurrentpath,16384);
end.
