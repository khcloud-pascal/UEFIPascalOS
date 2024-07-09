unit tydqfs;

interface

{$MODE FPC}

uses uefi;

const kernel_number_of_directory_entries=16;
     {Define files in TYDQ File System}
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
                 fparentpos:natuint;
                 fattribute:byte;
                 fbelonguserindex:natuint;
                 fName:array[1..256] of WideChar;
                 fcreatetime:tydqfs_time;
                 flastedittime:tydqfs_time;
                 fcontentCount:natuint;
                 end;
     tydqfs_header=packed record
                   signature:natuint;
                   maxsize:natuint;
                   usedsize:natuint;
                   RootName:array[1..256] of WideChar;
                   RootCount:natuint;
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
     {Define system info file in TYDQ System}
     tydqfs_system_header=packed record 
                        tydqgraphics:boolean;
                        tydqnetwork:boolean;
                        tydqautodetectkernel:boolean;
                        tydqsyslang:word;
                        tydqusercount:natuint;
                        end;
     tydqfs_user_info=packed record
                      username:PWideChar;
                      userpasswd:PWideChar;
                      usermanager:boolean;
                      end; 
     tydqfs_system_info=packed record
                        header:tydqfs_system_header;
                        userinfolist:^tydqfs_user_info;
                        end;
     {Define executable files in TYDQ System}
     tydqfs_file_executable_relocation=packed record
                                       relocation_number:natuint;
                                       relocation_offset:^natuint;
                                       end;
     tydqfs_file_executable_string_table=packed record
                                         string_table_size:natuint;
                                         string_table_content:^byte;
                                         end;
     tydqfs_file_executable_symbol_table=packed record
                                         symbol_table_number:natuint;
                                         symbol_table_type:^byte;
                                         symbol_table_address:^natuint;
                                         end;
     tydqfs_file_executable_hash_table=packed record
                                       hash_table_number:natuint;
                                       hash_table_address:^natuint;
                                       end;
     tydqfs_file_executable_section=packed record     
                                    section_name_index:natuint;
                                    section_type:byte;
                                    section_segment_size:natuint;
                                    section_content:^Byte;
                                    end;
     tydqfs_file_executable=packed record
                            exe_signature:natuint;
                            exe_type:byte;
                            exe_arch:byte;
                            exe_version:array[1..4] of byte;
                            exe_relocation_offset:natuint;
                            exe_relocation_segment:tydqfs_file_executable_relocation;
                            exe_string_table_offset:natuint;
                            exe_string_table_segment:tydqfs_file_executable_string_table;
                            exe_symbol_table_offset:natuint;
                            exe_symbol_table_segment:tydqfs_file_executable_symbol_table;
                            exe_hash_table_offset:natuint;
                            exe_hash_table_segment:tydqfs_file_executable_hash_table;
                            exe_section_start_offset:natuint;
                            exe_section_number:natuint;
                            exe_section_segments:^tydqfs_file_executable_section;
                            end;
     tydqfs_file_executable_parameter=packed record
                                      parameter:PWideChar;
                                      parameternum:natuint;
                                      end;
     tydqfs_program_code=natint;
     tydqfs_program_entry=function(param:tydqfs_file_executable_parameter):natuint;
     {Define TYDQ UEFI kernel(PE32+format) file}
     tydqfs_kernel_msdos_header=packed record
                                kernel_magic:word;
                                kernel_bytes_on_last_page_of_file:word;
                                kernel_pages_in_file:word;
                                kernel_relocations:word;
                                kernel_size_of_header_in_paragraphs:word;
                                kernel_minimum_allocation:word;
                                kernel_maximum_allocation:word;
                                kernel_initial_ss_register:word;
                                kernel_initial_sp_register:word;
                                kernel_check_sum:word;
                                kernel_initial_ip_register:word;
                                kernel_initial_cs_register:word;
                                kernel_file_address_of_relocation_table:word;
                                kernel_overlay_number:word;
                                kernel_reserved:array[1..4] of word;
                                kernel_oem_id:word;
                                kernel_oem_info:word;
                                kernel_reserved2:array[1..10] of word;
                                kernel_file_address_of_new_exe_header:dword;
                                end;
     tydqfs_kernel_data_directory=packed record
                                  virtual_address:dword;
                                  size:dword;
                                  end;
     tydqfs_kernel_pecoff_header=packed record
                                 kernel_pecoff_signature:dword;
                                 kernel_pecoff_machine:word;
                                 kernel_pecoff_number_of_sections:word;
                                 kernel_pecoff_time_date_stamp:dword;
                                 kernel_pecoff_pointer_to_symbol_table:dword;
                                 kernel_pecoff_number_of_symbols:dword;
                                 kernel_pecoff_size_of_optional_header:word;
                                 kernel_pecoff_characteristics:word;
                                 kernel_pecoff_optional_magic:word;
                                 kernel_pecoff_optional_major_linker_version:byte;
                                 kernel_pecoff_optional_minor_linker_version:byte;
                                 kernel_pecoff_optional_size_of_code:dword;
                                 kernel_pecoff_optional_size_of_initialized_data:dword;
                                 kernel_pecoff_optional_size_of_uninitialized_data:dword;
                                 kernel_pecoff_optional_address_of_entry_point:dword;
                                 kernel_pecoff_optional_base_of_code:dword;
                                 kernel_pecoff_optional_image_base:natuint;
                                 kernel_pecoff_optional_section_alignment:dword;
                                 kernel_pecoff_optional_file_alignment:dword;
                                 kernel_pecoff_optional_major_operating_system_version:word;
                                 kernel_pecoff_optional_minor_operating_system_version:word;
                                 kernel_pecoff_optional_major_image_version:word;
                                 kernel_pecoff_optional_minor_image_version:word;
                                 kernel_pecoff_optional_major_subsystem_version:word;
                                 kernel_pecoff_optional_minor_subsystem_version:word;
                                 kernel_pecoff_optional_win32_version_value:dword;
                                 kernel_pecoff_optional_size_of_image:dword;
                                 kernel_pecoff_optional_size_of_header:dword;
                                 kernel_pecoff_optional_check_sum:dword;
                                 kernel_pecoff_optional_subsystem:word;
                                 kernel_pecoff_optional_dll_characteristics:word;
                                 kernel_pecoff_optional_size_of_stack_reserve:natuint;
                                 kernel_pecoff_optional_size_of_stack_commit:natuint;
                                 kernel_pecoff_optional_size_of_heap_reserve:natuint;
                                 kernel_pecoff_optional_size_of_heap_commit:natuint;
                                 kernel_pecoff_optional_loader_flags:dword;
                                 kernel_pecoff_optional_number_of_rva_and_sizes:dword;
                                 kernel_pecoff_optional_data_directory:array[1..kernel_number_of_directory_entries] of tydqfs_kernel_data_directory;
                                 end;
    
const tydqfs_signature:natuint=$5D47291AD7E3F2B1;
      tydqfs_folder:byte=$01;
      tydqfs_normal_file:byte=$02;
      tydqfs_system_file:byte=$04;
      tydqfs_hidden_file:byte=$08;
      tydqfs_link_file:byte=$10;
      tydqfs_text_file:byte=$20;
      tydqfs_binary_file:byte=$40;
      tydqfs_executable_file:byte=$80;
      userlevel_system:byte=$00;
      userlevel_user:byte=$01;
      userlevel_application:byte=$02;
      tydqfs_executable_signature:natuint=$DD23F9E3F3C1ABEF;
      tydqfs_executable_executable:byte=$00;
      tydqfs_executable_relocatable:byte=$01;
      tydqfs_executable_object:byte=$02;
      tydqfs_executable_staticlib:byte=$03;
      tydqfs_executable_dynamiclib:byte=$04;
      tydqfs_executable_symbol_table_link_none:byte=$00;
      tydqfs_executable_symbol_table_link_static:byte=$01;
      tydqfs_executable_symbol_table_link_dynamic:byte=$02;
      tydqfs_executable_symbol_table_link_smart:byte=$03;
      tydqfs_executable_section_code:byte=$00;
      tydqfs_executable_section_initialized_data:byte=$01;
      tydqfs_executable_section_read_only_data:byte=$02;
      tydqfs_executable_section_uninitialized_data:byte=$03;
      tydqfs_executable_section_debug_info:byte=$04;
      tydqfs_executable_section_compiler_info:byte=$05;
      tydqfs_x64:byte=$00;
      tydqfs_aarch64:byte=$01;
      tydqfs_loongarch64:byte=$02;
      tydqfs_riscv64:byte=$03;
      tydqfs_riscv128:byte=$04;
      
function tydq_fs_byte_to_attribute_bool(attr:byte):tydqfs_attribute_bool;      
function tydq_combine_path_and_filename(path:PWideChar;filename:PWideChar):PWideChar;
procedure tydq_diskname_and_path_initialize;
function tydq_time_to_string(orgtime:tydqfs_time):PWideChar;
function tydq_fs_locate_diskindex(edl:efi_disk_list;path:PWideChar):natuint;
function tydq_fs_locate_fullpath(edl:efi_disk_list;path:PWideChar):PWideChar;
function tydq_fs_filelist_combine(filelist1,filelist2:tydqfs_file_list):tydqfs_file_list;
procedure tydq_fs_initialize(edl:efi_disk_list;diskindex:natuint;RootName:PWideChar);
function tydq_fs_read_header(edl:efi_disk_list;diskindex:natuint):tydqfs_header;
procedure tydq_fs_write_header(edl:efi_disk_list;diskindex:natuint;fsh:tydqfs_header);
function tydq_fs_disk_exists(edl:efi_disk_list;diskname:PWideChar):boolean;
function tydq_fs_disk_index(edl:efi_disk_list;diskname:PWideChar):natuint;
function tydq_fs_disk_name(edl:efi_disk_list;index:natuint):PWideChar;
function tydq_fs_disk_is_formatted(edl:efi_disk_list;diskindex:natuint):boolean;
function tydq_fs_file_exists(edl:efi_disk_list;diskindex:natuint;filename:PWideChar):boolean;
function tydq_fs_file_position(edl:efi_disk_list;diskindex:natuint;filename:PWideChar):natuint;
procedure tydq_fs_create_file(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;attr:byte;userlevel:byte;belonguserindex:natuint);
function tydq_fs_list_file(edl:efi_disk_list;diskindex:natuint;path:PWideChar;expanded:boolean;detecthidden:boolean;belonguserindex:natuint):tydqfs_file_list;
function tydq_fs_delete_file(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;belonguserindex:natuint):byte;
function tydq_fs_file_read(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;position,readlength:natuint;userlevel:byte;belonguserindex:natuint):tydqfs_data;
function tydq_fs_file_info(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;belonguserindex:natuint):tydqfs_file;
procedure tydq_fs_file_write(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;offset:natuint;writedata:Pointer;writesize:natuint;userlevel:byte;belonguserindex:natuint);
procedure tydq_fs_file_rewrite(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;writedata:Pointer;writesize:natuint;userlevel:byte;belonguserindex:natuint);
function tydq_fs_systeminfo_init(lanindex:word):tydqfs_system_info;
procedure tydq_fs_create_systeminfo_file(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint);
function tydq_fs_systeminfo_read(systemtable:Pefi_system_table;edl:efi_disk_list):tydqfs_system_info;
procedure tydq_fs_systeminfo_write(systemtable:Pefi_system_table;edl:efi_disk_list;writeinfo:tydqfs_system_info);
function tydq_fs_systeminfo_disk_index(systemtable:Pefi_system_table;edl:efi_disk_list):natuint;
procedure tydq_fs_systeminfo_add_user(var sysinfo:tydqfs_system_info;newusername,newuserpasswd:PWideChar;Manager:boolean);
procedure tydq_fs_systeminfo_delete_user(var sysinfo:tydqfs_system_info;username:PWideChar);
function tydq_fs_systeminfo_get_passwd(sysinfo:tydqfs_system_info;username:PWideChar):PWideChar;
function tydq_fs_systeminfo_get_index(sysinfo:tydqfs_system_info;username:PWideChar):natuint;
function tydq_fs_systeminfo_get_manager_index(sysinfo:tydqfs_system_info):natuint;
function tydq_fs_systeminfo_username_count(sysinfo:tydqfs_system_info;username:PWideChar):natuint;
procedure tydq_fs_systeminfo_free(var sysinfo:tydqfs_system_info);
function tydq_fs_read_executable(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;belonguserindex:natuint):tydqfs_file_executable;
function tydq_fs_execute_executable(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;param:tydqfs_file_executable_parameter;userlevel:byte;belonguserindex:natuint):boolean;
procedure tydq_fs_free_executable(var fse:tydqfs_file_executable);
function tydq_fs_detect_kernel(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;belonguserindex:byte):boolean;
function tydq_fs_change_kernel(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;belonguserindex:byte):boolean;
function tydq_fs_legal_filename(filename:PWideChar):boolean;
function tydq_fs_legal_length_filename(filename:PWideChar):boolean;

var tydqcurrentdiskname:PWideChar;
    tydqcurrentpath:PWideChar;

implementation

function efi_time_to_tydq_fs_time(etime:efi_time):tydqfs_time;[public,alias:'EFI_TIME_TO_TYDQ_FS_TIME'];
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
function PWChar_to_tydq_filename(str:PWideChar):tydqfs_filename;[public,alias:'PWChar_to_tydq_filename'];
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
function tydq_combine_path_and_filename(path:PWideChar;filename:PWideChar):PWideChar;[public,alias:'TYDQ_COMBINE_PATH_AND_FILENAME'];
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
function tydq_time_to_string(orgtime:tydqfs_time):PWideChar;[public,alias:'TYDQ_TIME_TO_STRING'];
var res,partstr,partstr2:PWideChar;
begin
 Wstrinit(res,256);
 partstr:=UintToPWChar(orgtime.year);
 Wstrset(res,partstr);
 Wstrcat(res,'/');
 Wstrfree(partstr);
 partstr:=UintToPWchar(orgtime.month);
 if(Wstrlen(partstr)=1) then Wstrcat(res,'0');
 Wstrcat(res,partstr);
 Wstrcat(res,'/');
 Wstrfree(partstr);
 partstr:=UintToPWChar(orgtime.day);
 if(Wstrlen(partstr)=1) then Wstrcat(res,'0');
 Wstrcat(res,partstr);
 Wstrfree(partstr);
 Wstrcat(res,' ');
 partstr:=UintToPWChar(orgtime.hour);
 if(Wstrlen(partstr)=1) then Wstrcat(res,'0');
 Wstrcat(res,partstr);
 Wstrfree(partstr);
 Wstrcat(res,':');
 partstr:=UintToPWChar(orgtime.minute);
 if(Wstrlen(partstr)=1) then Wstrcat(res,'0');
 Wstrcat(res,partstr);
 Wstrfree(partstr);
 Wstrcat(res,':');
 partstr:=UintToPWChar(orgtime.second);
 if(Wstrlen(partstr)=1) then Wstrcat(res,'0');
 Wstrcat(res,partstr);
 Wstrfree(partstr);
 tydq_time_to_string:=res;
end;
procedure tydq_diskname_and_path_initialize;[public,alias:'TYDQ_DISKNAME_AND_PATH_INITIALIZE'];
begin
 Wstrinit(tydqcurrentdiskname,256);
 Wstrinit(tydqcurrentpath,16384);
end;
function tydq_fs_locate_diskindex(edl:efi_disk_list;path:PWideChar):natuint;[public,alias:'TYDQ_FS_LOCATE_DISKINDEX'];
var pos,res:natuint;
    partstr:PWideChar;
begin
 if(path<>nil) then
  begin
   pos:=Wstrpos(path,'/',1);
   partstr:=Wstrcutout(path,1,pos-1);
   res:=tydq_fs_disk_index(edl,partstr);
  end
 else res:=0;
 if(res=0) then tydq_fs_locate_diskindex:=tydq_fs_disk_index(edl,tydqcurrentdiskname) else tydq_fs_locate_diskindex:=res;
end;
function tydq_fs_locate_fullpath(edl:efi_disk_list;path:PWideChar):PWideChar;[public,alias:'TYDQ_FS_LOCATE_FULLPATH'];
var pos,procnum:natuint;
    res,partstr,partstr2:PWideChar;
begin
 if(path<>nil) then
  begin
   pos:=Wstrpos(path,'/',1); 
   partstr2:=Wstrcutout(path,1,pos-1);
   procnum:=tydq_fs_disk_index(edl,partstr2);
   Wstrfree(partstr2);
  end
 else pos:=0;
 if(pos=1) then res:=Wstrcutout(path,pos,Wstrlen(path)) 
 else if(pos>0) then
  begin
   if(procnum=0) then
    begin
     Wstrinit(partstr,16384);
     Wstrset(partstr,tydqcurrentpath);
     Wstrcat(partstr,'/');
     Wstrcat(partstr,path);
    end
   else if(procnum>0) then
    begin
     partstr:=Wstrcutout(path,pos,Wstrlen(path));
    end;
   res:=partstr;
  end
 else if(pos=0) then
  begin
   Wstrinit(partstr,16384);
   Wstrset(partstr,tydqcurrentpath);
   res:=partstr;
  end;
 tydq_fs_locate_fullpath:=res;
end;
function tydq_fs_byte_to_attribute_bool(attr:byte):tydqfs_attribute_bool;[public,alias:'TYDQ_FS_BYTE_TO_ATTRIBUTE_BOOL'];
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
function tydq_fs_filelist_combine(filelist1,filelist2:tydqfs_file_list):tydqfs_file_list;[public,alias:'TYDQ_FS_FILELIST_COMBINE'];
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
procedure tydq_fs_initialize(edl:efi_disk_list;diskindex:natuint;RootName:PWideChar);[public,alias:'TYDQ_FS_INITIALIZE'];
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
function tydq_file_initialize(fattribute:byte;fparentpos:natuint;filetime:efi_time;filename:PWideChar;fuserindex:byte):tydqfs_file;[public,alias:'TYDQ_FILE_INITIALIZE'];
var tydqfile:tydqfs_file;
begin
 tydqfile.fparentpos:=fparentpos;
 tydqfile.fattribute:=fattribute;
 tydqfile.fbelonguserindex:=fuserindex;
 tydqfile.fcreatetime:=efi_time_to_tydq_fs_time(filetime);
 tydqfile.flastedittime:=efi_time_to_tydq_fs_time(filetime);
 tydqfile.fname:=PWChar_to_tydq_filename(filename);
 tydqfile.fcontentCount:=0;
 tydq_file_initialize:=tydqfile;
end;
function tydq_fs_read_header(edl:efi_disk_list;diskindex:natuint):tydqfs_header;[public,alias:'TYDQ_FS_READ_HEADER'];
var tydqdp:Pefi_disk_io_protocol;
    tydqbp:Pefi_block_io_protocol;
    res:tydqfs_header;
begin
 if(diskindex=0) then exit;
 tydqdp:=(edl.disk_content+diskindex-1)^;
 tydqbp:=(edl.disk_block_content+diskindex-1)^;
 tydqdp^.ReadDisk(tydqdp,tydqbp^.Media^.MediaId,0,sizeof(tydqfs_header),res);
 tydq_fs_read_header:=res;
end;
procedure tydq_fs_write_header(edl:efi_disk_list;diskindex:natuint;fsh:tydqfs_header);[public,alias:'TYDQ_FS_WRITE_HEADER'];
var tydqdp:Pefi_disk_io_protocol;
    tydqbp:Pefi_block_io_protocol;
begin
 tydqdp:=(edl.disk_content+diskindex-1)^;
 tydqbp:=(edl.disk_block_content+diskindex-1)^;
 tydqdp^.WriteDisk(tydqdp,tydqbp^.Media^.MediaId,0,sizeof(tydqfs_header),@fsh);
end;
procedure tydq_fs_disk_move_left(edl:efi_disk_list;diskindex,movestart,moveend,movelength:natuint);[public,alias:'TYDQ_FS_FILE_MOVE_LEFT'];
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
procedure tydq_fs_disk_move_right(edl:efi_disk_list;diskindex,movestart,moveend,movelength:natuint);[public,alias:'TYDQ_FS_FILE_MOVE_RIGHT'];
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
function tydq_fs_disk_is_formatted(edl:efi_disk_list;diskindex:natuint):boolean;[public,alias:'TYDQ_FS_DISK_IS_FORMATTED'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    fsh:tydqfs_header;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,0,sizeof(tydqfs_header),fsh);
 if(fsh.signature=$5D47291AD7E3F2B1) and (fsh.maxsize=(bp^.Media^.LastBlock+1)*bp^.Media^.BlockSize) and (fsh.usedsize>=sizeof(tydqfs_header)) then
 tydq_fs_disk_is_formatted:=true else tydq_fs_disk_is_formatted:=false;
end;
function tydq_fs_disk_exists(edl:efi_disk_list;diskname:PWideChar):boolean;[public,alias:'TYDQ_FS_DISK_EXISTS'];
var i:natuint;
    fsh:tydqfs_header;
begin
 i:=1;
 while(i<=edl.disk_count) do
  begin
   fsh:=tydq_fs_read_header(edl,i);
   if(WstrCmp(diskname,@fsh.RootName)=0) and (Wstrlen(diskname)=Wstrlen(@fsh.RootName)) then break;
   inc(i);
  end;
 if(i>edl.disk_count) then tydq_fs_disk_exists:=false else tydq_fs_disk_exists:=true;
end;
function tydq_fs_disk_index(edl:efi_disk_list;diskname:PWideChar):natuint;[public,alias:'TYDQ_FS_DISK_INDEX'];
var i:natuint;
    fsh:tydqfs_header;
begin
 i:=1;
 while(i<=edl.disk_count) do
  begin
   fsh:=tydq_fs_read_header(edl,i);
   if(WstrCmp(diskname,@fsh.RootName)=0) and (Wstrlen(diskname)=Wstrlen(@fsh.RootName)) then break;
   inc(i);
  end;
 if(i>edl.disk_count) then tydq_fs_disk_index:=0 else tydq_fs_disk_index:=i+1;
end;
function tydq_fs_disk_name(edl:efi_disk_list;index:natuint):PWideChar;[public,alias:'TYDQ_FS_DISK_NAME'];
var fsh:tydqfs_header;
    res:PWideChar;
begin
 Wstrinit(res,256);
 fsh:=tydq_fs_read_header(edl,index);
 Wstrset(res,@fsh.RootName);
 tydq_fs_disk_name:=res;
end;
function tydq_fs_file_exists(edl:efi_disk_list;diskindex:natuint;filename:PWideChar):boolean;[public,alias:'TYDQ_FS_FILE_EXISTS'];
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
function tydq_fs_file_position(edl:efi_disk_list;diskindex:natuint;filename:PWideChar):natuint;[public,alias:'TYDQ_FS_FILE_POSITION'];
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
procedure tydq_fs_create_file(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;attr:byte;userlevel:byte;belonguserindex:natuint);[public,alias:'TYDQ_FS_CREATE_FILE'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    fsh:tydqfs_header;
    fsf,rfsf,pfsf:tydqfs_file;
    partstr,partstr2:PWideChar;
    i,j,pos1,pos2,mpos,cpos,rpos,ppos,procnum:natuint;
    gtime:efi_time;
    ctime:efi_time_capabilities;
    bool:boolean;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^;
 fsh:=tydq_fs_read_header(edl,diskindex);
 if(fsh.usedsize+sizeof(natuint)+sizeof(tydqfs_file)>fsh.maxsize) then exit;
 if(tydq_fs_byte_to_attribute_bool(attr)[6]=true) and (userlevel<>userlevel_system) then exit;
 if(tydq_fs_byte_to_attribute_bool(attr)[6]=true) and (tydq_fs_byte_to_attribute_bool(attr)[7]=true) then exit;
 if(tydq_fs_byte_to_attribute_bool(attr)[6]=false) and (tydq_fs_byte_to_attribute_bool(attr)[7]=false) then exit;
 if(tydq_fs_file_exists(edl,diskindex,filename)=false) then
  begin
   pos1:=1; pos2:=2; mpos:=0; 
   while(pos2>0) do
    begin
     pos2:=Wstrpos(filename,'/',pos1+1);
     if(pos2>0) then
      begin
       partstr2:=Wstrcutout(filename,1,pos2-1);
       bool:=tydq_fs_file_exists(edl,diskindex,partstr2);
       Wstrfree(partstr2);
       partstr:=Wstrcutout(filename,pos1+1,pos2-1);
       systemtable^.RuntimeServices^.GetTime(gtime,ctime);
       if(userlevel=userlevel_system) then fsf:=tydq_file_initialize(tydqfs_folder or tydqfs_system_file,mpos,gtime,partstr,belonguserindex)
       else fsf:=tydq_file_initialize(tydqfs_folder or tydqfs_normal_file,mpos,gtime,partstr,belonguserindex);
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
           dp^.ReadDisk(dp,bp^.Media^.MediaId,i,sizeof(tydqfs_file),rfsf);
           if(mpos=0) then
            begin
             if(rfsf.fparentpos>=sizeof(tydqfs_header)+fsh.RootCount) then rfsf.fparentpos:=rfsf.fparentpos+sizeof(natuint);
            end
           else if(mpos>0) then
            begin
             if(rfsf.fparentpos>=mpos+sizeof(tydqfs_file)+pfsf.fContentCount) then rfsf.fparentpos:=rfsf.fparentpos+sizeof(natuint);
            end;
           if(tydq_fs_byte_to_attribute_bool(rfsf.fattribute)[8]=true) and (rfsf.fContentCount>0) then
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
           for j:=1 to fsh.RootCount div sizeof(natuint) do
            begin
             dp^.ReadDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(j-1)*sizeof(natuint),sizeof(natuint),procnum);
             procnum:=procnum+sizeof(natuint);
             dp^.WriteDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(j-1)*sizeof(natuint),sizeof(natuint),@procnum);
            end;
           dp^.WriteDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),@fsf);
          end
         else if(mpos>0) then
          begin
           tydq_fs_disk_move_right(edl,diskindex,mpos+sizeof(tydqfs_file)+pfsf.fContentCount,fsh.usedsize-1,sizeof(natuint));
           dp^.WriteDisk(dp,bp^.Media^.MediaId,mpos+sizeof(tydqfs_file)+pfsf.fContentCount,sizeof(natuint),@cpos);
           for j:=1 to pfsf.fContentCount div sizeof(natuint) do
            begin
             dp^.ReadDisk(dp,bp^.Media^.MediaId,mpos+sizeof(tydqfs_file)+(j-1)*sizeof(natuint),sizeof(natuint),procnum);
             procnum:=procnum+sizeof(natuint);
             dp^.WriteDisk(dp,bp^.Media^.MediaId,mpos+sizeof(tydqfs_file)+(j-1)*sizeof(natuint),sizeof(natuint),@procnum);
            end;
           dp^.WriteDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),@fsf);
          end;
         fsh.usedsize:=fsh.usedsize+sizeof(natuint)+sizeof(tydqfs_file);
         if(pos1=1) then 
          begin
           fsh.RootCount:=fsh.RootCount+sizeof(natuint);
          end
         else
          begin 
           pfsf.fContentCount:=pfsf.fcontentCount+sizeof(natuint);
           dp^.WriteDisk(dp,bp^.Media^.MediaId,mpos,sizeof(tydqfs_file),@pfsf);
          end;
        end
       else if(bool=true) then
        begin
         partstr:=Wstrcutout(filename,pos1+1,pos2-1);
         partstr2:=Wstrcutout(filename,1,pos2-1);
         ppos:=tydq_fs_file_position(edl,diskindex,partstr2);
         Wstrfree(partstr2);
         dp^.ReadDisk(dp,bp^.Media^.MediaId,ppos,sizeof(tydqfs_file),fsf);
         if(fsf.fbelonguserindex<>belonguserindex) and (belonguserindex>=2) then
          begin
           Wstrfree(partstr); exit;
          end;
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
           for i:=1 to rfsf.fContentCount div sizeof(natuint) do
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
       fsf:=tydq_file_initialize(attr,mpos,gtime,partstr,belonguserindex);
       cpos:=fsh.usedsize+sizeof(natuint);
       if(mpos=0) then
        begin
         tydq_fs_disk_move_right(edl,diskindex,sizeof(tydqfs_header)+fsh.RootCount,fsh.usedsize-1,sizeof(natuint));
         dp^.WriteDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+fsh.RootCount,sizeof(natuint),@cpos);
         dp^.WriteDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),@fsf);
        end
       else if(mpos>0) then
        begin
         dp^.ReadDisk(dp,bp^.Media^.MediaId,mpos,sizeof(tydqfs_file),rfsf);
         tydq_fs_disk_move_right(edl,diskindex,mpos+sizeof(tydqfs_file)+rfsf.fContentCount,fsh.usedsize-1,sizeof(natuint));
         dp^.WriteDisk(dp,bp^.Media^.MediaId,mpos+sizeof(tydqfs_file)+rfsf.fContentCount,sizeof(natuint),@cpos);
         dp^.WriteDisk(dp,bp^.Media^.MediaId,cpos,sizeof(tydqfs_file),@fsf);
        end;
       fsh.usedsize:=fsh.usedsize+sizeof(natuint)+sizeof(tydqfs_file);
       if(pos1=1) then 
        begin
         fsh.RootCount:=fsh.RootCount+sizeof(natuint);
        end
       else
        begin
         rfsf.fContentCount:=rfsf.fContentCount+sizeof(natuint);
         dp^.WriteDisk(dp,bp^.Media^.MediaId,mpos,sizeof(tydqfs_file),@rfsf);
        end;
       mpos:=cpos;
       Wstrfree(partstr);
       break;
      end;
    end;
   tydq_fs_write_header(edl,diskindex,fsh);
  end;
end;
function tydq_fs_list_file(edl:efi_disk_list;diskindex:natuint;path:PWideChar;expanded:boolean;detecthidden:boolean;belonguserindex:natuint):tydqfs_file_list;[public,alias:'TYDQ_FS_LIST_FILE'];
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
       if(detecthidden=true) and ((fsf.fbelonguserindex=belonguserindex) or (fsf.fbelonguserindex=0)) then canaddtolist:=true 
       else if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[5]=true) or 
       ((fsf.fbelonguserindex<>belonguserindex) and (fsf.fbelonguserindex>=2)) then canaddtolist:=false
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
         if(expanded) then res:=tydq_fs_filelist_combine(res,tydq_fs_list_file(edl,diskindex,partstr,expanded,detecthidden,belonguserindex));
         Wstrfree(partstr);
        end;
      end;
    end
   else if(mpos>0) then
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,mpos,sizeof(tydqfs_file),rfsf);
     if(detecthidden=true) and ((rfsf.fbelonguserindex=belonguserindex) or (rfsf.fbelonguserindex=0)) then canaddtolist:=true
     else if(tydq_fs_byte_to_attribute_bool(rfsf.fattribute)[5]=true) or 
     ((rfsf.fbelonguserindex<>belonguserindex) and (rfsf.fbelonguserindex>=2)) then canaddtolist:=false
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
         if(detecthidden=true) and ((fsf.fbelonguserindex=belonguserindex) or (fsf.fbelonguserindex=0)) then canaddtolist2:=true
         else if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[5]=true) or 
         ((fsf.fbelonguserindex<>belonguserindex) and (fsf.fbelonguserindex>=2)) then canaddtolist2:=false
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
          if(expanded) then res:=tydq_fs_filelist_combine(res,tydq_fs_list_file(edl,diskindex,partstr,expanded,detecthidden,belonguserindex));
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
function tydq_fs_delete_file(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;belonguserindex:natuint):byte;[public,alias:'TYDQ_FS_DELETE_FILE'];
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
 fsl:=tydq_fs_list_file(edl,diskindex,filename,true,true,belonguserindex);
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
   if((tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) and (userlevel<>userlevel_system)) or (fsf.fbelonguserindex<>belonguserindex) then 
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
   if(Wstrcmp('SystemInfo.dqi',@fsf.fName)=0) and (Wstrlen(@fsf.fName)=Wstrlen('SystemInfo.dqi')) and (fsf.fparentpos=0) then continue;
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
     if(fsh.RootCount>0) then
      begin
       for j:=1 to fsh.RootCount div sizeof(natuint) do
        begin
         dp^.ReadDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(i-1)*sizeof(natuint),sizeof(natuint),procnum);
         procnum:=procnum-sizeof(natuint);
         dp^.WriteDisk(dp,bp^.Media^.MediaId,sizeof(tydqfs_header)+(i-1)*sizeof(natuint),sizeof(natuint),@procnum);
        end;
      end;
    end
   else if(fsf.fparentpos>0) then
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,fsf.fparentpos,sizeof(tydqfs_file),rfsf);
     dp^.WriteDisk(dp,bp^.Media^.MediaId,fsf.fparentpos+sizeof(tydqfs_file)+rfsf.fContentCount-sizeof(natuint),sizeof(natuint),@zero);
     tydq_fs_disk_move_left(edl,diskindex,(fstl.files_position+i-1)^+sizeof(tydqfs_file)+fsf.fContentCount,fsh.usedsize-1,sizeof(natuint)+sizeof(tydqfs_file)
     +fsf.fContentCount);
     if(rfsf.fContentCount>=sizeof(natuint)) then rfsf.fContentCount:=rfsf.fContentCount-sizeof(natuint);
     if(tydq_fs_byte_to_attribute_bool(rfsf.fattribute)[8]=true) and (rfsf.fContentCount>0) then
      begin
       for j:=1 to rfsf.fContentCount div sizeof(natuint) do
        begin
         dp^.ReadDisk(dp,bp^.Media^.MediaId,fsf.fparentpos+sizeof(tydqfs_file)+(i-1)*sizeof(natuint),sizeof(natuint),procnum);
         procnum:=procnum-sizeof(natuint);
         dp^.WriteDisk(dp,bp^.Media^.MediaId,fsf.fparentpos+sizeof(tydqfs_file)+(i-1)*sizeof(natuint),sizeof(natuint),@procnum);
        end;
      end;
     dp^.WriteDisk(dp,bp^.Media^.MediaId,fsf.fparentpos,sizeof(tydqfs_file),@rfsf);
    end;
   fsh.usedsize:=fsh.usedsize-sizeof(natuint)-sizeof(tydqfs_file)-fsf.fContentCount;
  end;
 for i:=fstl.files_count downto 1 do Wstrfree((fstl.files_fullpath+i-1)^); 
 freemem(fstl.files_fullpath); freemem(fstl.files_position);
 tydq_fs_write_header(edl,diskindex,fsh);
 tydq_fs_delete_file:=0;
end;
function tydq_fs_file_read(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;position,readlength:natuint;userlevel:byte;belonguserindex:natuint):tydqfs_data;[public,alias:'TYDQ_FS_FILE_READ'];
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
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) and (userlevel<>userlevel_system) and (fsf.fbelonguserindex>0) then exit(fsd);
 if(position-1>fsf.fContentCount) then exit(fsd);
 if(fsf.fbelonguserindex<>belonguserindex) and (belonguserindex>=2) then exit(fsd);
 fsd.fsdata:=nil;
 for i:=1 to readlength do
  begin
   inc(fsd.fssize);
   ReallocMem(fsd.fsdata,fsd.fssize);
   dp^.ReadDisk(dp,bp^.Media^.MediaId,fpos+sizeof(tydqfs_file)+position-1+i-1,1,(fsd.fsdata+fsd.fssize-1)^);
   if(position-1+i-1>fsf.fContentCount) then break;
  end;
 tydq_fs_file_read:=fsd;
end;
function tydq_fs_file_info(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;belonguserindex:natuint):tydqfs_file;[public,alias:'TYDQ_FS_FILE_INFO'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    fpos:natuint;
    fsf:tydqfs_file;
begin
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^;
 fpos:=tydq_fs_file_position(edl,diskindex,filename);
 fsf.fparentpos:=0; fsf.fattribute:=0; fsf.fName[1]:=#0; fsf.fcontentCount:=0;
 if(fpos=0) then exit(fsf);
 dp^.ReadDisk(dp,bp^.Media^.MediaId,fpos,sizeof(tydqfs_file),fsf);
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) and (userlevel<>userlevel_system) and (fsf.fbelonguserindex>=2) then 
  begin
   fsf.fparentpos:=0; fsf.fattribute:=0; fsf.fName[1]:=#0; fsf.fcontentCount:=0; exit(fsf);
  end;
 if(fsf.fbelonguserindex<>belonguserindex) and (belonguserindex>=2) then 
  begin
   fsf.fparentpos:=0; fsf.fattribute:=0; fsf.fName[1]:=#0; fsf.fcontentCount:=0; exit(fsf);
  end;
 tydq_fs_file_info:=fsf;
end;
procedure tydq_fs_file_write(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;offset:natuint;writedata:Pointer;writesize:natuint;userlevel:byte;belonguserindex:natuint);[public,alias:'TYDQ_FS_FILE_WRITE'];
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
 if(fpos+sizeof(tydqfs_file)+offset+writesize>=fsh.maxsize) then exit;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,fpos,sizeof(tydqfs_file),fsf);
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) then exit;
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) and (userlevel<>userlevel_system) and (fsf.fbelonguserindex>0) then exit;
 if(fsf.fbelonguserindex<>belonguserindex) and (belonguserindex>=2) then exit;
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
procedure tydq_fs_file_rewrite(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;writedata:Pointer;writesize:natuint;userlevel:byte;belonguserindex:natuint);[public,alias:'TYDQ_FS_FILE_REWRITE'];
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
 if(fpos+sizeof(tydqfs_file)+writesize>=fsh.maxsize) then exit;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,fpos,sizeof(tydqfs_file),fsf);
 toffset:=fsf.fContentCount-writesize;
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[8]=true) then exit;
 if(tydq_fs_byte_to_attribute_bool(fsf.fattribute)[6]=true) and (userlevel<>userlevel_system) and (fsf.fbelonguserindex>0) then exit;
 if(fsf.fbelonguserindex<>belonguserindex) and (belonguserindex>=2) then exit;
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
function tydq_fs_systeminfo_init(lanindex:word):tydqfs_system_info;[public,alias:'TYDQ_FS_SYSTEMINFO_INIT'];
var tydqsysteminfo:tydqfs_system_info;
begin
 tydqsysteminfo.header.tydqgraphics:=false;
 tydqsysteminfo.header.tydqnetwork:=false;
 tydqsysteminfo.header.tydqautodetectkernel:=false;
 tydqsysteminfo.header.tydqsyslang:=lanindex;
 tydqsysteminfo.header.tydqusercount:=0;
 tydqsysteminfo.userinfolist:=nil;
 tydq_fs_systeminfo_init:=tydqsysteminfo;
end;
procedure tydq_fs_create_systeminfo_file(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint);[public,alias:'TYDQ_FS_CREATE_SYSTEMINFO_FILE'];
var total_info_str:PChar;
    encrypted_info_str:PChar;
begin
 if(tydq_fs_disk_is_formatted(edl,diskindex)=false) then exit;
 if(diskindex>edl.disk_count) then exit;
 strinit(total_info_str,1024*1024);
 strset(total_info_str,'[SystemInfo]'#10);
 strCat(total_info_str,'Graphics=False'#10);
 strCat(total_info_str,'EnableNetwork=False'#10);
 StrCat(total_info_str,'tydqautodetectkernel=False'#10);
 strCat(total_info_str,'Language=English'#10);
 strCat(total_info_str,'UserCount=0');
 encrypted_info_str:=PChar_encrypt_to_passwd(total_info_str);
 tydq_fs_create_file(systemtable,edl,diskindex,'/SystemInfo.dqi',tydqfs_system_file or tydqfs_hidden_file or tydqfs_binary_file,userlevel_system,1);
 tydq_fs_file_rewrite(systemtable,edl,diskindex,'/SystemInfo.dqi',encrypted_info_str,sizeof(Char)*(strlen(encrypted_info_str)+1),userlevel_system,1);
 strfree(encrypted_info_str);
 strfree(total_info_str);
end;
function tydq_fs_systeminfo_read(systemtable:Pefi_system_table;edl:efi_disk_list):tydqfs_system_info;[public,alias:'TYDQ_FS_SYSTEMINFO_READ'];
const userstartindex:byte=7;
var readfsdata:tydqfs_data;
    res:tydqfs_system_info;
    i,j,index,linecount,position,optionpos,optionnum,usercount,len,mysize:natuint;
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
   fsf:=tydq_fs_file_info(edl,index,'/SystemInfo.dqi',userlevel_system,1);
   if(tydq_fs_file_exists(edl,index,'/SystemInfo.dqi')) and (fsf.fattribute=tydqfs_system_file or tydqfs_hidden_file or tydqfs_binary_file) then break;
   inc(index);
  end;
 if(index>edl.disk_count) then exit(tydq_fs_systeminfo_init(0));
 dp:=(edl.disk_content+index-1)^; bp:=(edl.disk_block_content+index-1)^;
 position:=tydq_fs_file_position(edl,index,'/SystemInfo.dqi');
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position,sizeof(tydqfs_file),fsf);
 readfsdata:=tydq_fs_file_read(edl,index,'/SystemInfo.dqi',1,fsf.fContentCount,userlevel_system,1);
 passwd:=PChar(readfsdata.fsdata); orgstr:=Passwd_decrypt_to_PChar(passwd); 
 i:=1; optionnum:=0; usercount:=0; res.header.tydqusercount:=0; res.userinfolist:=nil; len:=strlen(orgstr);
 while(i<=len) do
  begin
   inc(optionnum);
   if(optionnum>=userstartindex) and (usercount<(optionnum-userstartindex-1) div 3) then
    begin
     freemem(res.userinfolist); break;
    end
   else if(optionnum=userstartindex) and (usercount>0) then
    begin
     res.userinfolist:=allocmem(sizeof(tydqfs_user_info)*usercount);
    end;
   j:=strpos(orgstr,#10,i);
   if(j>0) then partstr:=strcutout(orgstr,i,j-1) else partstr:=strcutout(orgstr,i,len);
   if(optionnum>1) then
    begin
     optionpos:=strpos(partstr,'=',1);
     optionstr:=strcutout(partstr,1,optionpos-1);
     valuestr:=strcutout(partstr,optionpos+1,strlen(partstr));
    end;
   if(optionnum=1) and (strcmp(partstr,'[SystemInfo]')<>0) then
    begin
     res:=tydq_fs_systeminfo_init(0); break;
    end
   else if(optionnum=1) then issysteminfo:=true;
   if(optionnum=2) and (strcmp(optionstr,'Graphics')<>0) then
    begin
     res:=tydq_fs_systeminfo_init(0); break;
    end
   else if(optionnum=2) then
    begin
     if(strcmp(valuestr,'True')=0) and (strlen(valuestr)=4) then res.header.tydqgraphics:=true else res.header.tydqgraphics:=false;
    end;
   if(optionnum=3) and (strcmp(optionstr,'EnableNetwork')<>0) then
    begin
     res:=tydq_fs_systeminfo_init(0); break;
    end
   else if(optionnum=3) then
    begin
     if(strcmp(valuestr,'True')=0) and (strlen(valuestr)=4) then res.header.tydqnetwork:=true else res.header.tydqnetwork:=false;
    end;
   if(optionnum=4) and (strcmp(optionstr,'AutoDetectKernel')<>0) then
    begin
     res:=tydq_fs_systeminfo_init(0); break;
    end
   else if(optionnum=4) then
    begin
     if(strcmp(valuestr,'True')=0) and (strlen(valuestr)=4) then res.header.tydqautodetectkernel:=true else res.header.tydqautodetectkernel:=false;
    end;
   if(optionnum=5) and (strcmp(optionstr,'Language')<>0) then
    begin
     res:=tydq_fs_systeminfo_init(0); break;
    end
   else if(optionnum=5) then
    begin
     if(strcmp(valuestr,'English')=0) and (strlen(valuestr)=7) then res.header.tydqsyslang:=1 else res.header.tydqsyslang:=2;
    end;
   if(optionnum=6) and (strcmp(optionstr,'UserCount')<>0) then
    begin
     res:=tydq_fs_systeminfo_init(0); break;
    end
   else if(optionnum=6) then
    begin
     usercount:=PCharToUint(valuestr);
     res.header.tydqusercount:=usercount;
    end;
   if(optionnum>=userstartindex) and ((optionnum-userstartindex+1) mod 3=1) and (strcmp(optionstr,'UserName')<>0) then
    begin
     res:=tydq_fs_systeminfo_init(0); break;
    end
   else if(optionnum>=userstartindex) and ((optionnum-userstartindex+1) mod 3=1) then
    begin
      partstr2:=PCharToPWChar(valuestr);
      mysize:=getmemsize(partstr2);
      Wstrinit((res.userinfolist+(optionnum-userstartindex+1) div 3)^.username,strlen(valuestr));
      Wstrset((res.userinfolist+(optionnum-userstartindex+1) div 3)^.username,partstr2);
      freemem(partstr2);
      (res.userinfolist+(optionnum-userstartindex+1) div 3)^.username:=PWideChar(Pointer((res.userinfolist+(optionnum-5) div 3)^.username)-mysize);
    end;
   if(optionnum>=userstartindex) and ((optionnum-userstartindex+1) mod 3=2) and (strcmp(optionstr,'UserPasswd')<>0) then
    begin
     res:=tydq_fs_systeminfo_init(0); break;
    end
   else if(optionnum>=userstartindex) and ((optionnum-userstartindex+1) mod 3=2) then
    begin
      partstr2:=PCharToPWChar(valuestr);
      mysize:=getmemsize(partstr2);
      Wstrinit((res.userinfolist+(optionnum-userstartindex+1) div 3)^.userpasswd,strlen(valuestr));
      Wstrset((res.userinfolist+(optionnum-userstartindex+1) div 3)^.userpasswd,partstr2);
      freemem(partstr2);
      (res.userinfolist+(optionnum-userstartindex+1) div 3)^.userpasswd:=PWideChar(Pointer((res.userinfolist+(optionnum-5) div 3)^.userpasswd)-mysize);
    end;
   if(optionnum>=userstartindex) and ((optionnum-userstartindex+1) mod 3=0) and (strcmp(optionstr,'UserManager')<>0) then
    begin 
     res:=tydq_fs_systeminfo_init(0); break;
    end
   else if(optionnum>=userstartindex) and ((optionnum-userstartindex+1) mod 3=0) then
    begin
     if(strcmp(valuestr,'True')=0) then 
     (res.userinfolist+(optionnum-userstartindex+1) div 3-1)^.usermanager:=true
     else
     (res.userinfolist+(optionnum-userstartindex+1) div 3-1)^.usermanager:=false;
    end;
   if(optionnum>1) then
    begin
     mysize:=getmemsize(partstr)+getmemsize(optionstr)+getmemsize(valuestr);
     strfree(valuestr); strfree(optionstr);
    end;
   strfree(partstr);
   if(optionnum>=userstartindex) and ((optionnum-userstartindex+1) mod 3=1) then
    begin
     (res.userinfolist+(optionnum-userstartindex+1) div 3)^.username:=
     PWideChar(Pointer((res.userinfolist+(optionnum-userstartindex+1) div 3)^.username)-mysize);
    end
   else if(optionnum>=userstartindex) and ((optionnum-userstartindex+1) mod 3=2) then
    begin
     (res.userinfolist+(optionnum-userstartindex+1) div 3)^.userpasswd:=
     PWideChar(Pointer((res.userinfolist+(optionnum-userstartindex+1) div 3)^.userpasswd)-mysize);
    end;
   if(j>0) then i:=j+1 else break; 
  end;
 mysize:=getmemsize(orgstr)+getmemsize(passwd);
 strfree(orgstr); strfree(passwd); readfsdata.fssize:=0;
 res.userinfolist:=Pointer(Pointer(res.userinfolist)-mysize);
 for i:=1 to usercount do
  begin
   (res.userinfolist+i-1)^.username:=PWideChar(Pointer((res.userinfolist+i-1)^.username)-mysize);
   (res.userinfolist+i-1)^.userpasswd:=PWideChar(Pointer((res.userinfolist+i-1)^.userpasswd)-mysize);
  end;
 tydq_fs_systeminfo_read:=res;
end;
procedure tydq_fs_systeminfo_write(systemtable:Pefi_system_table;edl:efi_disk_list;writeinfo:tydqfs_system_info);[public,alias:'TYDQ_FS_SYSTEMINFO_WRITE'];
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
    fsf:=tydq_fs_file_info(edl,index,'/SystemInfo.dqi',userlevel_system,1);
    if(tydq_fs_file_exists(edl,index,'/SystemInfo.dqi')) and (fsf.fattribute=tydqfs_system_file or tydqfs_hidden_file or tydqfs_binary_file) then break;
    inc(index);
   end;
  if(index>edl.disk_count) then exit;
  Strinit(orgstr,1024*1024);
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
  if(writeinfo.header.tydqautodetectkernel=true) then
   begin
    strcat(orgstr,'AutoDetectKernel=True'#10);
   end
  else if(writeinfo.header.tydqautodetectkernel=false) then
   begin
    strcat(orgstr,'AutoDetectKernel=False'#10);
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
  if(writeinfo.header.tydqusercount>0) then strcat(orgstr,#10);
  strfree(partstr);
  for i:=1 to writeinfo.header.tydqusercount do
   begin
     strcat(orgstr,'UserName=');
     partstr:=PWCharToPChar((writeinfo.userinfolist+i-1)^.username);
     strcat(orgstr,partstr);
     strfree(partstr);
     strcat(orgstr,#10);
     strcat(orgstr,'UserPasswd=');
     partstr:=PWCharToPChar((writeinfo.userinfolist+i-1)^.userpasswd);
     strcat(orgstr,partstr);
     strfree(partstr);
     strcat(orgstr,#10);
     if((writeinfo.userinfolist+i-1)^.usermanager) then strcat(orgstr,'UserManager=True') else strcat(orgstr,'UserManager=False');
     if(i<writeinfo.header.tydqusercount) then strcat(orgstr,#10);
   end;
  passwdstr:=PChar_encrypt_to_passwd(orgstr);
  tydq_fs_file_rewrite(systemtable,edl,index,'/SystemInfo.dqi',passwdstr,sizeof(char)*(strlen(passwdstr)+1),userlevel_system,1);
  strfree(passwdstr);
  strfree(orgstr);
end;
function tydq_fs_systeminfo_disk_index(systemtable:Pefi_system_table;edl:efi_disk_list):natuint;[public,alias:'TYDQ_FS_SYSTEMINFO_DISK_INDEX'];
var index:natuint;
    fsf:tydqfs_file;
begin
 index:=1;
 while(index<=edl.disk_count) do
  begin
   fsf:=tydq_fs_file_info(edl,index,'/SystemInfo.dqi',userlevel_system,1);
   if(tydq_fs_file_exists(edl,index,'/SystemInfo.dqi')) and (fsf.fattribute=tydqfs_system_file or tydqfs_hidden_file or tydqfs_binary_file) then break;
   inc(index);
  end;
 if(index>edl.disk_count) then exit(0) else exit(index);
end;
procedure tydq_fs_systeminfo_add_user(var sysinfo:tydqfs_system_info;newusername,newuserpasswd:PWideChar;Manager:boolean);[public,alias:'TYDQ_FS_SYSTEMINFO_ADD_USER'];
var i,size:natuint;
begin
 for i:=1 to sysinfo.header.tydqusercount do
  begin
   if(Wstrcmp((sysinfo.userinfolist+i-1)^.username,newusername)=0) and (Wstrlen((sysinfo.userinfolist+i-1)^.username)=Wstrlen(newusername)) then exit;
  end;
 inc(sysinfo.header.tydqusercount);
 size:=getmemsize(sysinfo.userinfolist);
 ReallocMem(sysinfo.userinfolist,sizeof(tydqfs_user_info)*sysinfo.header.tydqusercount);
 i:=sysinfo.header.tydqusercount-1;
 if(i>0) then
  begin
   (sysinfo.userinfolist+i-1)^.username:=PWideChar(Pointer((sysinfo.userinfolist+i-1)^.username)-size);
   (sysinfo.userinfolist+i-1)^.userpasswd:=PWideChar(Pointer((sysinfo.userinfolist+i-1)^.userpasswd)-size);
  end;
 Wstrinit((sysinfo.userinfolist+sysinfo.header.tydqusercount-1)^.username,Wstrlen(newusername));
 Wstrset((sysinfo.userinfolist+sysinfo.header.tydqusercount-1)^.username,newusername);
 Wstrinit((sysinfo.userinfolist+sysinfo.header.tydqusercount-1)^.userpasswd,Wstrlen(newuserpasswd));
 Wstrset((sysinfo.userinfolist+sysinfo.header.tydqusercount-1)^.userpasswd,newuserpasswd);
 (sysinfo.userinfolist+sysinfo.header.tydqusercount-1)^.usermanager:=Manager;
end;
procedure tydq_fs_systeminfo_delete_user(var sysinfo:tydqfs_system_info;username:PWideChar);[public,alias:'TYDQ_FS_SYSTEMINFO_DELETE_USER'];
var i,j,size1,size2:natuint;
begin
 i:=1;
 while(i<=sysinfo.header.tydqusercount) do
  begin 
   if(Wstrcmp((sysinfo.userinfolist+i-1)^.username,username)=0) and (Wstrlen((sysinfo.userinfolist+i-1)^.username)=Wstrlen(username)) then break;
   inc(i);
  end;
 if(i>sysinfo.header.tydqusercount) then exit else 
  begin
   size1:=getmemsize(sysinfo.userinfolist);
   size2:=getmemsize((sysinfo.userinfolist+i-1)^.username)+getmemsize((sysinfo.userinfolist+i-1)^.userpasswd);
   Wstrfree((sysinfo.userinfolist+i-1)^.userpasswd); Wstrfree((sysinfo.userinfolist+i-1)^.username);
   ReallocMem(sysinfo.userinfolist,sizeof(tydqfs_user_info)*(sysinfo.header.tydqusercount-1));
   if(sysinfo.header.tydqusercount>1) then
    begin
     sysinfo.userinfolist:=Pointer(Pointer(sysinfo.userinfolist)-size2);
     for j:=i to sysinfo.header.tydqusercount-1 do
      begin
       (sysinfo.userinfolist+j-1)^.userpasswd:=Pointer(Pointer((sysinfo.userinfolist+j)^.userpasswd)-size1-size2);
       (sysinfo.userinfolist+j-1)^.username:=Pointer(Pointer((sysinfo.userinfolist+j)^.username)-size1-size2);
      end;
     ReallocMem(sysinfo.userinfolist,sizeof(tydqfs_user_info)*(sysinfo.header.tydqusercount-1));
    end
   else 
    begin
     freemem(sysinfo.userinfolist); sysinfo.userinfolist:=nil;
    end;
  end;
 if(sysinfo.header.tydqusercount>0) then dec(sysinfo.header.tydqusercount);
end;
function tydq_fs_systeminfo_get_passwd(sysinfo:tydqfs_system_info;username:PWideChar):PWideChar;[public,alias:'TYDQ_FS_SYSTEMINFO_GET_PASSWD'];
var i:natuint;
    res:PWidechar;
begin
 i:=1;
 while(i<=sysinfo.header.tydqusercount) do
  begin
   if(Wstrcmp((sysinfo.userinfolist+i-1)^.username,username)=0) and (Wstrlen((sysinfo.userinfolist+i-1)^.username)=Wstrlen(username)) then break;
   inc(i);
  end;
 if(i>sysinfo.header.tydqusercount) then exit(nil) 
 else 
  begin
   Wstrinit(res,Wstrlen((sysinfo.userinfolist+i-1)^.userpasswd));
   Wstrset(res,(sysinfo.userinfolist+i-1)^.userpasswd);
   exit(res);
  end;
end;
function tydq_fs_systeminfo_get_index(sysinfo:tydqfs_system_info;username:PWideChar):natuint;[public,alias:'TYDQ_FS_SYSTEMINFO_GET_INDEX'];
var i:natuint;
begin
 i:=1;
 while(i<=sysinfo.header.tydqusercount) do
  begin
   if(Wstrcmp((sysinfo.userinfolist+i-1)^.username,username)=0) and (Wstrlen((sysinfo.userinfolist+i-1)^.username)=Wstrlen(username)) then break;
   inc(i);
  end;
 if(i>sysinfo.header.tydqusercount) then exit(0) else exit(i+1);
end;
function tydq_fs_systeminfo_get_manager_index(sysinfo:tydqfs_system_info):natuint;[public,alias:'TYDQ_FS_SYSTEMINFO_GET_MANAGER_INDEX'];
var i:natuint;
begin
 i:=1;
 while(i<=sysinfo.header.tydqusercount) do
  begin
   if((sysinfo.userinfolist+i-1)^.usermanager) then break;
   inc(i);
  end;
 if(i>sysinfo.header.tydqusercount) then exit(0) else exit(i+1);
end;
function tydq_fs_systeminfo_username_count(sysinfo:tydqfs_system_info;username:PWideChar):natuint;[public,alias:'TYDQ_FS_SYSTEMINFO_USERNAME_COUNT'];
var i,res:natuint;
begin
 i:=1; res:=0;
 while(i<=sysinfo.header.tydqusercount) do
  begin
   if(Wstrcmp((sysinfo.userinfolist+i-1)^.username,username)=0) and (Wstrlen(username)=Wstrlen((sysinfo.userinfolist+i-1)^.username)) then inc(res);
   inc(i);
  end;
 tydq_fs_systeminfo_username_count:=res;
end;
procedure tydq_fs_systeminfo_free(var sysinfo:tydqfs_system_info);[public,alias:'TYDQ_FS_SYSTEMINFO_FREE'];
var i,size:natuint;
begin 
 if(sysinfo.header.tydqusercount>0) then 
  begin
   Wstrfree((sysinfo.userinfolist+sysinfo.header.tydqusercount-1)^.userpasswd);   
   Wstrfree((sysinfo.userinfolist+sysinfo.header.tydqusercount-1)^.username); 
  end;
 size:=0;
 if(sysinfo.header.tydqusercount>1) then
  begin
   for i:=sysinfo.header.tydqusercount-1 downto 1 do
    begin
     size:=size+getmemsize((sysinfo.userinfolist+i-1)^.userpasswd)+getmemsize((sysinfo.userinfolist+i-1)^.username);
     Wstrfree((sysinfo.userinfolist+i-1)^.userpasswd); Wstrfree((sysinfo.userinfolist+i-1)^.username);
    end;
  end;
 if(sysinfo.userinfolist<>nil) then sysinfo.userinfolist:=Pointer(Pointer(sysinfo.userinfolist)-size);
 freemem(sysinfo.userinfolist);
 sysinfo.header.tydqusercount:=0; sysinfo.header.tydqsyslang:=0; sysinfo.header.tydqnetwork:=false; sysinfo.header.tydqgraphics:=false;
end;
function tydq_fs_read_executable(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;belonguserindex:natuint):tydqfs_file_executable;[public,alias:'TYDQ_FS_READ_EXECUTABLE'];
var position:natuint;
    fsf:tydqfs_file;
    dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    res:tydqfs_file_executable;
    i,j,offset,offset2:natuint;
begin
 fsf:=tydq_fs_file_info(edl,diskindex,filename,userlevel,belonguserindex);
 position:=tydq_fs_file_position(edl,diskindex,filename)+sizeof(tydqfs_file);
 if(position=sizeof(tydqfs_file)) then 
  begin
   res.exe_signature:=0;
   exit(res);
  end;
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position,sizeof(natuint),res.exe_signature);
 res.exe_version[1]:=0; res.exe_version[2]:=0; res.exe_version[3]:=0; res.exe_version[4]:=0;
 res.exe_relocation_offset:=0; res.exe_string_table_offset:=0; res.exe_symbol_table_offset:=0; 
 res.exe_hash_table_offset:=0; res.exe_section_start_offset:=0; res.exe_section_number:=0;
 fsf:=tydq_fs_file_info(edl,diskindex,filename,userlevel,belonguserindex);
 if(fsf.fattribute=0) then 
  begin
   res.exe_signature:=0;
   exit(res);
  end;
 if(res.exe_signature<>tydqfs_executable_signature) then 
  begin
   res.exe_signature:=0;
   exit(res);
  end;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+sizeof(natuint),sizeof(byte),res.exe_type);
 if(res.exe_type>$04) then 
  begin
   res.exe_signature:=0;
   exit(res);
  end;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+sizeof(natuint)+sizeof(byte),sizeof(byte),res.exe_arch);
 if(res.exe_type>$05) then 
  begin
   res.exe_signature:=0;
   exit(res);
  end;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+sizeof(natuint)+sizeof(byte)*2,sizeof(byte)*4,res.exe_version);
 {Load the relocation segment}
 offset:=sizeof(natuint)+sizeof(byte)*2+sizeof(byte)*4;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+offset,sizeof(natuint),res.exe_relocation_offset);
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+res.exe_relocation_offset,
 sizeof(tydqfs_file_executable_relocation)-sizeof(natuint),res.exe_relocation_segment);
 res.exe_relocation_segment.relocation_offset:=exe_heap_allocmem(res.exe_relocation_segment.relocation_number*sizeof(natuint));
 for i:=1 to res.exe_relocation_segment.relocation_number do
  begin
   dp^.ReadDisk(dp,bp^.Media^.MediaId,res.exe_relocation_offset+sizeof(natuint)+sizeof(natuint)*(i-1),sizeof(natuint),
   (res.exe_relocation_segment.relocation_offset+i-1)^);
  end;
 {Load the string table segment}
 offset:=sizeof(natuint)+sizeof(byte)*2+sizeof(byte)*4+sizeof(natuint);
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+offset,sizeof(natuint),res.exe_string_table_offset);
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+res.exe_string_table_offset,
 sizeof(tydqfs_file_executable_string_table)-sizeof(natuint),res.exe_string_table_segment);
 res.exe_string_table_segment.string_table_content:=exe_heap_allocmem(res.exe_string_table_segment.string_table_size);
 for i:=1 to res.exe_string_table_segment.string_table_size do
  begin
   dp^.ReadDisk(dp,bp^.Media^.MediaId,res.exe_string_table_offset+sizeof(natuint)+sizeof(byte)*(i-1),sizeof(byte),
   (res.exe_string_table_segment.string_table_content+i-1)^);
  end;
 {Load the symbol table segment}
 offset:=sizeof(natuint)+sizeof(byte)*2+sizeof(byte)*4+sizeof(natuint)*2;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+offset,sizeof(natuint),res.exe_symbol_table_offset);
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+res.exe_symbol_table_offset,
 sizeof(tydqfs_file_executable_symbol_table)-sizeof(natuint)-sizeof(natuint),res.exe_symbol_table_segment);
 res.exe_symbol_table_segment.symbol_table_type:=exe_heap_allocmem(res.exe_symbol_table_segment.symbol_table_number*sizeof(byte));
 for i:=1 to res.exe_symbol_table_segment.symbol_table_number do
  begin
   dp^.ReadDisk(dp,bp^.Media^.MediaId,res.exe_symbol_table_offset+sizeof(natuint)+sizeof(byte)*(i-1),sizeof(byte),
   (res.exe_symbol_table_segment.symbol_table_type+i-1)^);
  end;
 res.exe_symbol_table_segment.symbol_table_address:=exe_heap_allocmem(res.exe_symbol_table_segment.symbol_table_number*sizeof(natuint));
 for i:=1 to res.exe_symbol_table_segment.symbol_table_number do
  begin
   dp^.ReadDisk(dp,bp^.Media^.MediaId,res.exe_symbol_table_offset+sizeof(natuint)+sizeof(natuint)*(i-1),sizeof(natuint),
   (res.exe_symbol_table_segment.symbol_table_address+i-1)^);
  end;
 {Load the hash table segment}
 offset:=sizeof(natuint)+sizeof(byte)*2+sizeof(byte)*4+sizeof(natuint)*3;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+offset,sizeof(natuint),res.exe_hash_table_offset);
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+res.exe_symbol_table_offset,
 sizeof(tydqfs_file_executable_hash_table)-sizeof(natuint),res.exe_hash_table_segment);
 res.exe_hash_table_segment.hash_table_address:=exe_heap_allocmem(res.exe_hash_table_segment.hash_table_number*sizeof(natuint));
 for i:=1 to res.exe_hash_table_segment.hash_table_number do
  begin
   dp^.ReadDisk(dp,bp^.Media^.MediaId,res.exe_hash_table_offset+sizeof(natuint)+sizeof(natuint)*(i-1),sizeof(natuint),
   (res.exe_hash_table_segment.hash_table_address+i-1)^);
  end;
 {Load the section}
 offset:=sizeof(natuint)+sizeof(byte)*2+sizeof(byte)*4+sizeof(natuint)*4;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+offset,sizeof(natuint),res.exe_section_start_offset);
 offset:=sizeof(natuint)+sizeof(byte)*2+sizeof(byte)*4+sizeof(natuint)*5;
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+offset,sizeof(natuint),res.exe_section_number);
 res.exe_section_segments:=exe_heap_allocmem(sizeof(tydqfs_file_executable_section)*res.exe_section_number);
 offset:=0; 
 for i:=1 to res.exe_section_number do
  begin
   dp^.ReadDisk(dp,bp^.Media^.MediaId,position+res.exe_section_start_offset+offset,sizeof(tydqfs_file_executable_section)-sizeof(natuint),
   (res.exe_section_segments+i-1)^);
   (res.exe_section_segments+i-1)^.section_content:=exe_heap_allocmem(sizeof(byte)*((res.exe_section_segments+i-1)^.section_segment_size));
   offset2:=offset+sizeof(tydqfs_file_executable_section)-sizeof(natuint);
   offset:=offset+sizeof(tydqfs_file_executable_section)-sizeof(natuint)+sizeof(sizeof(byte)*((res.exe_section_segments+i-1)^.section_segment_size));
   for j:=1 to (res.exe_section_segments+i-1)^.section_segment_size do
    begin
     dp^.ReadDisk(dp,bp^.Media^.MediaId,position+offset2,sizeof(byte),((res.exe_section_segments+i-1)^.section_content+j-1)^);
    end;
  end;
end;
function tydq_fs_execute_executable(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;param:tydqfs_file_executable_parameter;userlevel:byte;belonguserindex:natuint):boolean;[public,alias:'TYDQ_FS_EXECUTE_EXECUTABLE'];
var dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    exefile:tydqfs_file_executable;
    exedata:tydqfs_data;
    fsf:tydqfs_file;
    i:natuint;
    exitcode:tydqfs_program_code;
    exitprogram:tydqfs_program_entry;
begin
 fsf:=tydq_fs_file_info(edl,diskindex,filename,userlevel_user,belonguserindex);
 if(fsf.fattribute=0) then exit(false);
 exefile:=tydq_fs_read_executable(edl,diskindex,filename,userlevel,belonguserindex);
 if(exefile.exe_signature<>tydqfs_executable_signature) then exit(false);
 i:=1;
 while (i<=exefile.exe_section_number) do
  begin
   if((exefile.exe_section_segments+i-1)^.section_type=tydqfs_executable_section_code) then break;
   inc(i,1);
  end;
 if(i>exefile.exe_section_number) then exit(false);
 exitprogram:=tydqfs_program_entry((exefile.exe_section_segments+i-1)^.section_content);
 exitcode:=exitprogram(param);
 tydq_fs_free_executable(exefile);
 if(exitcode<>0) then tydq_fs_execute_executable:=false else tydq_fs_execute_executable:=true;
end;
procedure tydq_fs_free_executable(var fse:tydqfs_file_executable);[public,alias:'TYDQ_FS_FREE_EXECUTABLE'];
var i:natuint;
begin
 {Free the section code}
 for i:=fse.exe_section_number downto 1 do
  begin
   exe_heap_freemem((fse.exe_section_segments+i-1)^.section_content);
  end;
 exe_heap_freemem(fse.exe_section_segments);
 fse.exe_section_start_offset:=0; fse.exe_section_number:=0;
 {Free the hash table}
 exe_heap_freemem(fse.exe_hash_table_segment.hash_table_address);
 fse.exe_hash_table_segment.hash_table_number:=0;
 {Free the symbol table}
 exe_heap_freemem(fse.exe_symbol_table_segment.symbol_table_type);
 exe_heap_freemem(fse.exe_symbol_table_segment.symbol_table_address);
 fse.exe_symbol_table_segment.symbol_table_number:=0;
 {Free the string table}
 exe_heap_freemem(fse.exe_string_table_segment.string_table_content);
 fse.exe_string_table_segment.string_table_size:=0;
 {Free the relocation table}
 exe_heap_freemem(fse.exe_relocation_segment.relocation_offset);
 fse.exe_relocation_segment.relocation_number:=0;
 {Free the rest part of the executable variables}
 fse.exe_signature:=0; fse.exe_type:=$FF; fse.exe_arch:=$FF;
 fse.exe_version[1]:=0; fse.exe_version[2]:=0; fse.exe_version[3]:=0; fse.exe_version[4]:=0;
 fse.exe_relocation_offset:=0; fse.exe_string_table_offset:=0; fse.exe_symbol_table_offset:=0; 
 fse.exe_hash_table_offset:=0; fse.exe_section_start_offset:=0; fse.exe_section_number:=0;
end;
function tydq_fs_detect_kernel(edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;belonguserindex:byte):boolean;[public,alias:'TYDQ_FS_DETECT_KERNEL'];
var msdosheader:tydqfs_kernel_msdos_header;
    pecoffheader:tydqfs_kernel_pecoff_header;
    dp:Pefi_disk_io_protocol;
    bp:Pefi_block_io_protocol;
    position:natuint;
    fsf:tydqfs_file;
begin
 fsf:=tydq_fs_file_info(edl,diskindex,filename,userlevel,belonguserindex);
 if(fsf.fattribute=0) then exit(false);
 dp:=(edl.disk_content+diskindex-1)^; bp:=(edl.disk_block_content+diskindex-1)^;
 position:=tydq_fs_file_position(edl,diskindex,filename)+sizeof(tydqfs_file);
 if(fsf.fContentCount>sizeof(tydqfs_kernel_msdos_header)) then 
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position,sizeof(tydqfs_kernel_msdos_header),msdosheader) else exit(false);
 if(msdosheader.kernel_magic<>$5A4D) then exit(false);
 if(msdosheader.kernel_file_address_of_new_exe_header>fsf.fContentCount) then
 dp^.ReadDisk(dp,bp^.Media^.MediaId,position+msdosheader.kernel_file_address_of_new_exe_header,sizeof(tydqfs_kernel_pecoff_header),pecoffheader)
 else exit(false);
 if(pecoffheader.kernel_pecoff_signature<>$50450000) then exit(false);
 if(pecoffheader.kernel_pecoff_machine<>$8664) and (efi_get_platform=0) then exit(false)
 else if(pecoffheader.kernel_pecoff_machine<>$AA64) and (efi_get_platform=1) then exit(false)
 else if(pecoffheader.kernel_pecoff_machine<>$6264) and (efi_get_platform=2) then exit(false)
 else if(pecoffheader.kernel_pecoff_machine<>$5064) and (efi_get_platform=3) then exit(false)
 else if(pecoffheader.kernel_pecoff_machine<>$5128) and (efi_get_platform=4) then exit(false);
 if(pecoffheader.kernel_pecoff_optional_magic<>$20B) then exit(false);
 if(pecoffheader.kernel_pecoff_optional_subsystem<10) or (pecoffheader.kernel_pecoff_optional_subsystem>13) then exit(false);
 tydq_fs_detect_kernel:=true;
end;
function tydq_fs_change_kernel(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;belonguserindex:byte):boolean;[public,alias:'TYDQ_FS_CHANGE_KERNEL'];
var fsf:tydqfs_file;
    efsle:efi_file_system_list_ext;
    efifs:Pefi_simple_file_system_protocol;
    efif:Pefi_file_protocol;
    status1,status2:efi_status;
    data:tydqfs_data;
    i:natuint;
begin
 if(tydq_fs_detect_kernel(edl,diskindex,filename,userlevel,belonguserindex)=false) then exit(false);
 fsf:=tydq_fs_file_info(edl,diskindex,filename,userlevel,belonguserindex);
 data:=tydq_fs_file_read(edl,diskindex,filename,1,fsf.fContentCount,userlevel,belonguserindex);
 for i:=1 to efsle.fsrwcount do
  begin
   efifs:=(efsle.fsrwcontent+i-1)^;
   efifs^.OpenVolume(efifs,efif);
   status1:=efif^.Open(efif,efif,'\EFI\BOOT',efi_file_mode_read,efi_file_system);
   status2:=efif^.Open(efif,efif,'\EFI\TYDQOS',efi_file_mode_read,efi_file_system);
   if(status2=0) then
    begin
     if(efi_get_platform=0) then
      begin
       efif^.Open(efif,efif,'\EFI\TYDQOS\bootx64.efi',efi_file_mode_read or efi_file_mode_write or efi_file_mode_create,efi_file_system);
       efif^.SetPosition(efif,0);
       efif^.efiWrite(efif,data.fssize,data.fsdata); break;
      end
     else if(efi_get_platform=1) then
      begin
       efif^.Open(efif,efif,'\EFI\TYDQOS\bootaa64.efi',efi_file_mode_read or efi_file_mode_write or efi_file_mode_create,efi_file_system);
       efif^.SetPosition(efif,0);
       efif^.efiWrite(efif,data.fssize,data.fsdata); break;
      end
     else if(efi_get_platform=2) then
      begin
       efif^.Open(efif,efif,'\EFI\TYDQOS\bootloongarch64.efi',efi_file_mode_read or efi_file_mode_write or efi_file_mode_create,efi_file_system);
       efif^.SetPosition(efif,0);
       efif^.efiWrite(efif,data.fssize,data.fsdata); break;
      end
     else if(efi_get_platform=3) then
      begin
       efif^.Open(efif,efif,'\EFI\TYDQOS\bootriscv64.efi',efi_file_mode_read or efi_file_mode_write or efi_file_mode_create,efi_file_system);
       efif^.SetPosition(efif,0);
       efif^.efiWrite(efif,data.fssize,data.fsdata); break;
      end
     else if(efi_get_platform=4) then
      begin
       efif^.Open(efif,efif,'\EFI\TYDQOS\bootriscv128.efi',efi_file_mode_read or efi_file_mode_write or efi_file_mode_create,efi_file_system);
       efif^.SetPosition(efif,0);
       efif^.efiWrite(efif,data.fssize,data.fsdata); break;
      end;
    end
   else if(status1=0) then
    begin
     if(efi_get_platform=0) then
      begin
       efif^.Open(efif,efif,'\EFI\BOOT\bootx64.efi',efi_file_mode_read or efi_file_mode_write or efi_file_mode_create,efi_file_system);
       efif^.SetPosition(efif,0);
       efif^.efiWrite(efif,data.fssize,data.fsdata); break;
      end
     else if(efi_get_platform=1) then
      begin
       efif^.Open(efif,efif,'\EFI\BOOT\bootaa64.efi',efi_file_mode_read or efi_file_mode_write or efi_file_mode_create,efi_file_system);
       efif^.SetPosition(efif,0);
       efif^.efiWrite(efif,data.fssize,data.fsdata); break;
      end
     else if(efi_get_platform=2) then
      begin
       efif^.Open(efif,efif,'\EFI\BOOT\bootloongarch64.efi',efi_file_mode_read or efi_file_mode_write or efi_file_mode_create,efi_file_system);
       efif^.SetPosition(efif,0);
       efif^.efiWrite(efif,data.fssize,data.fsdata); break;
      end
     else if(efi_get_platform=3) then
      begin
       efif^.Open(efif,efif,'\EFI\BOOT\bootriscv64.efi',efi_file_mode_read or efi_file_mode_write or efi_file_mode_create,efi_file_system);
       efif^.SetPosition(efif,0);
       efif^.efiWrite(efif,data.fssize,data.fsdata); break;
      end
     else if(efi_get_platform=4) then
      begin
       efif^.Open(efif,efif,'\EFI\BOOT\bootriscv128.efi',efi_file_mode_read or efi_file_mode_write or efi_file_mode_create,efi_file_system);
       efif^.SetPosition(efif,0);
       efif^.efiWrite(efif,data.fssize,data.fsdata); break;
      end;
    end;
  end;
 efif^.Close(efif);
 freemem(data.fsdata); data.fssize:=0; freemem(efsle.fsrwcontent); freemem(efsle.fsrcontent); efsle.fsrwcount:=0; efsle.fsrcount:=0;
 tydq_fs_change_kernel:=true;
end;
function tydq_fs_legal_filename(filename:PWideChar):boolean;[public,alias:'TYDQ_FS_LEGAL_FILENAME'];
const illegalchar:PWideChar='?*${}[]()@#^%';
var i,j,len,len2:natuint;
begin
 len:=Wstrlen(filename); len2:=Wstrlen(illegalchar);
 for i:=1 to len do
  begin
   for j:=1 to len2 do
    begin
     if((filename+i-1)^=(illegalchar+j-1)^) then exit(false);
    end;
  end;
 tydq_fs_legal_filename:=true;
end;
function tydq_fs_legal_length_filename(filename:PWideChar):boolean;[public,alias:'TYDQ_FS_LEGAL_LENGTH_FILENAME'];
var i1,i2:natuint;
begin
 i1:=1; i2:=2;
 while(i2>0) do
  begin
   i2:=Wstrpos(filename,'/',i1+1);
   if(i2-1-i1<=255) or (i2-1-i1>0) then exit(false);
   i1:=i2;
  end;
 tydq_fs_legal_length_filename:=true;
end;

end.
