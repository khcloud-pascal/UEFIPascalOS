unit console;

interface

uses
    tydqfs,
    uefi;

implementation

function console_main();cdecl;[public,alias:'console_main'];
begin
end;
function console_command_parser(cmdstr:PWideChar);cdecl;[public,alias:'console_command_parser'];
begin
end;

end.
