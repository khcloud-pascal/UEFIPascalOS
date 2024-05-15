unit tydqfs;

interface
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
                      fcontentstart,fcontentend:qword;
                      end;
     tydqfs_header=packed record
                   signature:qword;
                   maxsize:qword;
                   RootName:array[1..256] of WideChar;
                   RootTreeStart,RootTreeEnd:qword;
                   end;
     tydqfs_filename=array[1..256] of WideChar;

const tydqfs_signature:qword=$5D47291AD7E3F2B1;
      tydqfs_none:byte=$00;
      tydqfs_folder:byte=$01;
      tydqfs_normal_file:byte=$02;
      tydqfs_system_file:byte=$04;
      tydqfs_link_file:byte=$08;
      tydqfilemode_create:byte=$01;
      tydqfilemode_write:byte=$02;
      tydqfilemode_read:byte=$04;
      tydqfilemode_delete:byte=$08;

procedure tydq_fs_initialize(edl:efi_disk_list;disknum:natuint;RootName:PWideChar);cdecl;
procedure tydq_fs_read_header(edl:efi_disk_list;disknum:natuint);cdecl;
procedure tydq_fs_write_header(edl:efi_disk_list;disknum:natuint);cdecl;

var tydqfsh:tydqfs_header;
    tydqcurrentpath:PWideChar;

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
procedure tydq_fs_initialize(edl:efi_disk_list;disknum:natuint;RootName:PWideChar);cdecl;[public,alias:'TYDQ_FS_INITIALIZE'];
var tydqdp:Pefi_disk_io_protocol;
    tydqbp:Pefi_block_io_protocol;
begin
 tydqdp:=(edl.disk_content+disknum-1)^; tydqbp:=(edl.disk_block_content+disknum-1)^;
 tydqfsh.signature:=tydqfs_signature;
 tydqfsh.maxsize:=(tydqbp^.Media^.LastBlock+1)*tydqbp^.Media^.BlockSize;
 tydqfsh.RootName:=PWChar_to_tydq_filename(RootName);
 tydqfsh.RootTreeStart:=0; tydqfsh.RootTreeEnd:=0;
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
 tydqfile.fcontentstart:=0;
 tydqfile.fcontentend:=0;
 tydq_file_initialize:=tydqfile;
end;
procedure tydq_fs_read_header(edl:efi_disk_list;disknum:natuint);cdecl;[public,alias:'TYDQ_FS_READ_HEADER'];
var tydqdp:Pefi_disk_io_protocol;
    tydqbp:Pefi_block_io_protocol;
begin
 tydqdp:=(edl.disk_content+disknum-1)^;
 tydqbp:=(edl.disk_block_content+disknum-1)^;
 tydqdp^.ReadDisk(tydqdp,tydqbp^.Media^.MediaId,0,sizeof(tydqfs_header),tydqfsh);
end;
procedure tydq_fs_write_header(edl:efi_disk_list;disknum:natuint);cdecl;[public,alias:'TYDQ_FS_WRITE_HEADER'];
var tydqdp:Pefi_disk_io_protocol;
    tydqbp:Pefi_block_io_protocol;
begin
 tydqdp:=(edl.disk_content+disknum-1)^;
 tydqbp:=(edl.disk_block_content+disknum-1)^;
 tydqdp^.WriteDisk(tydqdp,tydqbp^.Media^.MediaId,0,sizeof(tydqfs_header),@tydqfsh);
end;
procedure tydq_fs_file_content_move
procedure tydq_fs_file_create(systemtable:Pefi_system_table;relativefilename:PWideChar;fileattribute:byte);cdecl;[public,alias:'TYDQ_FS_FILE_CREATE'];
var partstr:PWideChar;
    signpos1,signpos2:qword;
begin
 signpos1:=1; signpos2:=Wstrpos(relativefilename,'/',1);
 if(signpos2=0) then
  begin
   partstr:=relativefilename;
  end
 else if(signpos2>0) then
  begin
  end;
end;
procedure tydq_fs_file_exist(systemtable:Pefi_system_table;relativefilename:PWideChar);cdecl;[public,alias:'TYDQ_FS_FILE_EXIST'];
begin
 
end;
procedure tydq_fs_file_read(systemtable:Pefi_system_table;relativefilename:PWideChar;var readdata:PByte;var readlength:qword;Offset:qword);cdecl;[public,alias:'TYDQ_FS_FILE_READ'];
begin
 
end;
procedure tydq_fs_file_write(systemtable:Pefi_system_table;relativefilename:PWideChar;writedata:PByte;writelength:qword;Offset:qword);cdecl;[public,alias:'TYDQ_FS_FILE_WRITE'];
begin
 
end;
procedure tydq_fs_file_clear(systemtable:Pefi_system_table;relativefilename:PWideChar);cdecl;[public,alias:'TYDQ_FS_FILE_CLEAR_CONTENT'];
begin
end;
procedure tydq_fs_file_delete(systemtable:Pefi_system_table;relativefilename:PWideChar);cdecl;[public,alias:'TYDQ_FS_FILE_DELETE'];
begin
end;
begin
 Wstrinit(tydqcurrentpath,32768);
end.
