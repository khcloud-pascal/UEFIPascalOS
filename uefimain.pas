unit uefimain;
interface

uses uefi;

function efi_main(ImageHandle:efi_handle;systemtable:Pefi_system_table):efi_status;cdecl;

implementation

function efi_main(ImageHandle:efi_handle;systemtable:Pefi_system_table):efi_status;cdecl;[public,alias:'efi_main'];
var mystr:PWideChar;
    status:efi_status;
    edl:efi_disk_list;
begin
 efi_console_set_global_colour(Systemtable,efi_bck_black,efi_lightgrey);
 efi_console_clear_screen(systemtable);
 efi_console_get_max_row_and_max_column(systemtable,true);
 efi_console_enable_mouse(systemtable);
 efi_console_enable_mouse_blink(systemtable,true,500);
 efi_console_output_string(systemtable,'Welcome to TYDQ System!'+#13#10);
 efi_console_output_string(systemtable,'Hello UEFI!'+#13#10);
 efi_console_read_string(systemtable,mystr);
 efi_console_output_string(systemtable,mystr);
 while(True) do;
 efi_main:=efi_success;
end;

end.
