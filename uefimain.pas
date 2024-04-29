unit uefimain;
interface

uses uefi;

function efi_main(ImageHandle:efi_handle;systemtable:Pefi_system_table):efi_status;cdecl;

implementation

function efi_main(ImageHandle:efi_handle;systemtable:Pefi_system_table):efi_status;cdecl;[public,alias:'efi_main'];
var mystr:PWideChar;
    i,realsize:natuint;
    status:efi_status;
    efi_interface_list:efi_disk_interface_list;
    efi_block_list:efi_block_interface_list;
    myhandle:efi_handle;
    gpe:efi_gpt_partition_array;
    mbrhead:master_boot_record;
    gptheader:efi_gpt_header;
    gptarray:efi_gpt_entry_array;
    efsl:efi_file_system_list;
    efp:Pefi_file_protocol;
    efsi:efi_file_system_info;
begin
 gpe.array_content:=allocmem(4*sizeof(efi_gpt_partition_array_content));
 gpe.array_count:=2;
 efi_console_set_global_colour(Systemtable,efi_bck_black,efi_lightgrey);
 efi_console_clear_screen(systemtable);
 efi_console_get_max_row_and_max_column(systemtable,true);
 efi_console_enable_mouse(systemtable);
 efi_console_enable_mouse_blink(systemtable,true,500);
 efi_interface_list:=efi_detect_disk(systemtable);
 efi_block_list:=efi_detect_block(systemtable);
 for i:=1 to efi_block_list.block_count do
  begin
   efi_console_output_string(systemtable,UintToPWChar(((efi_block_list.block_interface+i-1)^)^.Media^.MediaId));
   efi_console_output_string(systemtable,#13#10); 
   efi_console_output_string(systemtable,UintToPWChar(efi_get_disk_size(efi_block_list,i)));
   efi_console_output_string(systemtable,#13#10); 
  end;
  gpe.array_content^.startlba:=0;
  gpe.array_content^.endlba:=256*1024*2-1;
  (gpe.array_content+1)^.startlba:=256*1024*2;
  (gpe.array_content+1)^.endlba:=((efi_block_list.block_interface)^)^.Media^.LastBlock-gpe.array_count;
  //efi_clear_disk(efi_interface_list,efi_block_list,1);
  efi_zone_disk(efi_interface_list,efi_block_list,1,gpe);
  mbrhead:=efi_read_disk_format_mbr(efi_interface_list,efi_block_list,1);
  efi_console_output_string(systemtable,'MBR Head:'+#13#10);
  efi_console_output_string(systemtable,DataToHex(Pointer(@mbrhead),sizeof(master_boot_record)));
  efi_console_output_string(systemtable,#13#10); 
  gptheader:=efi_read_disk_format_gpt(efi_interface_list,efi_block_list,1);
  efi_console_output_string(systemtable,'GPT Header:'+#13#10);
  efi_console_output_string(systemtable,DataToHex(Pointer(@gptheader),sizeof(efi_gpt_header)));
  efi_console_output_string(systemtable,#13#10); 
  gptarray:=efi_read_disk_gpt_entry_array(efi_interface_list,efi_block_list,1);
  efi_console_output_string(systemtable,'GPT Entries Number:');
  efi_console_output_string(systemtable,UintToPWChar(gptarray.entry_count));
  efi_console_output_string(systemtable,#13#10); 
  if(gptarray.entry_count>0) then efi_console_output_string(systemtable,'GPT Entries:'+#13#10);
  for i:=1 to gptarray.entry_count do
   begin
    efi_console_output_string(systemtable,DataToHex(gptarray.entry_content+i-1,sizeof(efi_partition_entry)));
    efi_console_output_string(systemtable,#13#10); 
   end;
 efsl:=efi_list_all_file_system(systemtable);
 efi_console_output_string(systemtable,UintToPWChar(efsl.file_system_count));
 efi_console_output_string(systemtable,#13#10);
 for i:=1 to efsl.file_system_count do
  begin
   realsize:=sizeof(efi_file_system_info);
   efi_console_output_string(systemtable,UintToPWChar(Qword(realsize)));
   efi_console_output_string(systemtable,#13#10);
   status:=((efsl.file_system_content+i-1)^)^.OpenVolume((efsl.file_system_content+i-1)^,efp);
   if(status<>efi_success) then
    begin 
     efi_console_output_string(systemtable,'ERROR1!'+#13#10);
     break;
    end;
   status:=efp^.GetInfo(efp,@efi_file_system_info_id,realsize,efsi);
   if(status<>efi_success) then
    begin 
     efi_console_output_string(systemtable,'ERROR2!'+#13#10);
     break;
    end;
   efi_console_output_string(systemtable,UintToPWChar(efsi.size));
   efi_console_output_string(systemtable,' ');
   efi_console_output_string(systemtable,UintToPWChar(efsi.volumesize));
   efi_console_output_string(systemtable,' ');
   efi_console_output_string(systemtable,UintToPWChar(efsi.FreeSpace));
   efi_console_output_string(systemtable,' ');
   efi_console_output_string(systemtable,UintToPWChar(efsi.BlockSize));
   efi_console_output_string(systemtable,' ');
   efi_console_output_string(systemtable,@efsi.VolumeLabel);
   efi_console_output_string(systemtable,' ');
   efi_console_output_string(systemtable,#13#10);
   efp^.Close(efp);
  end;
 efi_console_output_string(systemtable,'Hello UEFI!'+#13#10);
 efi_console_read_string(systemtable,mystr);
 efi_console_output_string(systemtable,mystr);
 efi_install_cdrom_to_disk(systemtable,1,1);
 while(True) do;
 efi_main:=efi_success;
end;

end.
