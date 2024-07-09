unit system;
{$MODE FPC}

interface

{$IFDEF CPU32}
const maxheap=16777216*12;
      maxsection=16384*64;
{$ELSE CPU32}
const maxheap=67108864*12;
      maxsection=65536*64;
{$ENDIF CPU32}
const exe_heap_content_max_volume=1048576*512;
      exe_heap_section_max_volume=65536*16;
type
  hresult = LongInt;
  Char = #0..#255;
  DWord = LongWord;
  Cardinal = LongWord;
  {$IFDEF CPU16}
  Integer = SmallInt;
  {$ELSE CPU16}
  Integer = Longint;
  {$ENDIF CPU16}
  UInt64 = QWord;
  Pbyte=^byte;
  Pchar=^char;
  PWideChar=^WideChar;
  PPWideChar=^PWideChar;
  PWChar=^WideChar;
  PPWChar=^PWChar;
  Pword=^word;
  Pdword=^dword;
  Pqword=^qword;
  PPointer=^Pointer;
  Pboolean=^boolean;
  Pint64=^int64;
  Puint64=^uint64;
  {$IFDEF CPU32}
  NatUint=dword;
  PNatUint=^dword;
  Natint=integer;
  PNatint=^integer;
  Uint128=record
          Dwords:array[1..4] of dword;
          end;
  Int128=record
         Highdword:Integer;
         Lowdwords:array[1..3] of dword;
         end;
  {$ELSE CPU32}
  NatUint=qword;
  PNatUint=^qword;
  Natint=int64;
  PNatint=^int64;
  Uint128=record
          High,Low:qword;
          end;
  Int128=record
         High:Int64;
         Low:qword;
         end;
  {$ENDIF CPU32}
  TTypeKind = (tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkSet,
    tkMethod, tkSString, tkLString, tkAString, tkWString, tkVariant, tkArray,
    tkRecord, tkInterface, tkClass, tkObject, tkWChar, tkBool, tkInt64, tkQWord,
    tkDynArray, tkInterfaceRaw, tkProcVar, tkUString, tkUChar, tkHelper, tkFile,
    tkClassRef, tkPointer);
  PTypeKind=^TTypekind;
  jmp_buf = packed record
    rbx, rbp, r12, r13, r14, r15, rsp, rip: QWord;
    {$IFDEF CPU64}
    rsi, rdi: QWord;
    xmm6, xmm7, xmm8, xmm9, xmm10, xmm11, xmm12, xmm13, xmm14, xmm15: record 
      m1, m2: QWord;
    end;
    mxcsr: LongWord;
    fpucw: word;
    padding: word;
    {$ENDIF CPU64}
  end;
  Pjmp_buf = ^jmp_buf;
  PExceptAddr = ^TExceptAddr;
  TExceptAddr = record 
    buf: Pjmp_buf;
    next: PExceptAddr;
    {$IFDEF CPU16}
    frametype: SmallInt;
    {$ELSE CPU16}
    frametype: LongInt;
    {$ENDIF CPU16}
  end;
  PGuid = ^TGuid;
  TGuid = packed record
    case Integer of
    1:
     (Data1: DWord;
      Data2: word;
      Data3: word;
      Data4: array [0 .. 7] of byte;
    );
    2:
     (D1: DWord;
      D2: word;
      D3: word;
      D4: array [0 .. 7] of byte;
    );
    3:
    ( { uuid fields according to RFC4122 }
      time_low: DWord; // The low field of the timestamp
      time_mid: word; // The middle field of the timestamp
      time_hi_and_version: word;
      // The high field of the timestamp multiplexed with the version number
      clock_seq_hi_and_reserved: byte;
      // The high field of the clock sequence multiplexed with the variant
      clock_seq_low: byte; // The low field of the clock sequence
      node: array [0 .. 5] of byte; // The spatially unique node identifier
    );
  end;
  systemheap=packed record
	     heapcontent:array[1..maxheap] of byte;
	     heapsection:array[1..maxsection,1..2] of natuint;
	     heapcount,heaprest:natuint;
             end;
  neighborline=packed record
               lineslen:array[1..3] of natuint;
               linepos:array[1..3] of natuint;
               linelen:byte;
               linestatus:byte;
               end;
  linelist=packed record
           lineleft:^natuint;
           lineright:^natuint;
           linecount:natuint;
           end;
  maskwildcard=packed record
               liststr:^PChar;
               listpos:^natuint;
               listlen:^natuint;
               listcount:natuint;
               end;
  Wmaskwildcard=packed record
                liststr:^PWideChar;
                listpos:^natuint;
                listlen:^natuint;
                listcount:natuint;
                end; 
  executable_heap=packed record
                  heap_content:array[1..exe_heap_content_max_volume] of word;
                  heap_section:array[1..exe_heap_section_max_volume,1..2] of natuint;
                  heap_count,heap_rest_volume:natuint;
                  end; 
const mypwd:PChar='PHjueigbEYywLCQiCYRQGleDMUjOceLMBFDMJHEMUzgCleRgkKEnAuVLtSAEFSFhevpEKomPHIbaqxLLGJVMRmZUDFKnvHGfvTwYEOqVaBxEGXMXXuITZixUcMbdTCfWIwysKPSciOnUHgmePRWEWWcNMuePEbGOvNgNbqdMMRlzbocTikuCuQuISgQTWFtVSLUmAObgipXAnNEdUNXKVFBiNTIOornretCNOaEwhQTdIRlYaldWzFiummYKKJJcnDRJovDJTFXpQczJQBDnATyvopuBakmGKXTDsIhKfKNITJlsDkLTlKRKfObLvwpIgXvqmBmiWLKQlhqMyAcUoFxkFNPYeGFCduhGJTNtSMfvbGuupWzugWNrwwZKkwjfIqIdjXMAiVONPcMebzSCvUGtVblwohLzOhlnPKIQBTxpBYufIJesKHeZPUHiYaofkTEDcpRapVwluKFARevxkgjxuEFHgVEuQtAUFMMTszCgrqcuKFnJiZtmDBmYsatb';
mypwdoffset:array[1..24] of shortint=(-1,-3,-6,-8,-7,-4,-5,-2,0,8,9,10,12,2,3,4,1,9,-9,3,-11,-12,10,-7);
pi:extended=3.1415926;
procedure fpc_specific_handler;compilerproc;
procedure fpc_handleerror;compilerproc;
procedure fpc_lib_exit;compilerproc;
procedure fpc_libinitializeunits;compilerproc;
procedure fpc_initializeunits;compilerproc;
procedure fpc_finalizeunits;compilerproc;
procedure fpc_do_exit;compilerproc;
procedure fpc_div_by_zero;compilerproc;
function fpc_qword_to_double(q:qword):double;compilerproc;
function fpc_int64_to_double(i:int64):double;compilerproc;
function fpc_getmem(size:natuint):Pointer;compilerproc;
procedure fpc_freemem(var p:pointer);compilerproc;
function fpc_allocmem(size:natuint):Pointer;compilerproc;
procedure fpc_reallocmem(var p:Pointer;size:natuint);compilerproc;
procedure fpc_move(const source;var dest;count:natuint);compilerproc;
function getmem(size:natuint):Pointer;
procedure freemem(var p:pointer);
function allocmem(size:natuint):Pointer;
function getmemsize(p:Pointer):natuint;
procedure reallocmem(var p:Pointer;size:natuint);
procedure move(const source;var dest;count:natuint);
procedure sysheap_clear_all;
function exe_heap_getmem(size:natuint):Pointer;
function exe_heap_allocmem(size:natuint):Pointer;
procedure exe_heap_freemem(var p:Pointer);
function exe_heap_getmemsize(p:Pointer):natuint;
procedure exe_heap_reallocmem(var p:Pointer;size:natuint);
procedure exe_heap_move(var dest;const source;size:natuint);
procedure exe_heap_clear_all;
function frac(x:extended):extended;
function optimize_integer_divide(a,b:natuint):natuint;
function optimize_integer_modulo(a,b:natuint):natuint;
function strlen(str:Pchar):natuint;
function wstrlen(str:PWideChar):natuint;
procedure strinit(var str:PChar;size:natuint);
procedure wstrinit(var str:PWideChar;Size:natuint);
procedure strrealloc(var str:PChar;size:natuint);
procedure Wstrrealloc(var str:PwideChar;size:natuint);
procedure strset(var str:PChar;val:Pchar);
procedure wstrset(var str:PWideChar;val:Pwidechar);
function strcmp(str1,str2:Pchar):natint;
function Wstrcmp(str1,str2:PwideChar):natint;
function strpartcmp(str1:PChar;position,length:natuint;str2:PChar):natint;
function Wstrpartcmp(str1:PWideChar;position,length:natuint;str2:PWideChar):natint; 
function strcmpL(str1,str2:Pchar):natint;
function WstrcmpL(str1,str2:PwideChar):natint;
function strpartcmpL(str1:PChar;position,length:natuint;str2:PChar):natint;
function WstrpartcmpL(str1:PWideChar;position,length:natuint;str2:PWideChar):natint; 
procedure strcat(var dest:PChar;src:PChar);
procedure Wstrcat(var dest:PWideChar;src:PWideChar);
procedure strfree(var str:PChar);
procedure Wstrfree(var str:PWideChar);
procedure strUpperCase(var str:PChar);
procedure strLowerCase(var str:PChar);
procedure WstrUpperCase(var str:PWideChar);
procedure WstrLowerCase(var str:PWideChar);
function strcopy(str:PChar;index,count:Natuint):Pchar;
function Wstrcopy(str:PWideChar;index,count:Natuint):PWideChar;
function strcutout(str:PChar;left,right:Natuint):PChar;
function Wstrcutout(str:PWideChar;left,right:Natuint):PWideChar;
procedure strdelete(var str:PChar;index,count:Natuint);
procedure Wstrdelete(var str:PWideChar;index,count:Natuint);
procedure strdeleteinrange(var str:PChar;left,right:Natuint);
procedure WStrdeleteinrange(var str:PWideChar;left,right:Natuint);
procedure strinsert(var str:PChar;insertstr:PChar;index:natuint);
procedure Wstrinsert(var str:PWideChar;insertstr:PWideChar;index:natuint);
function strpos(str,substr:PChar;start:Natuint):Natuint;
function Wstrpos(str,substr:PWideChar;start:natuint):natuint;
function strposdir(str,substr:PChar;start:natuint;direction:shortint):natuint;
function Wstrposdir(str,substr:PWideChar;start:natuint;direction:shortint):natuint;
function strposorder(str,substr:PChar;start,order:natuint):natuint;
function Wstrposorder(str,substr:PWideChar;start,order:natuint):natuint;
function strposdirorder(str,substr:PChar;start,order:natuint;direction:shortint):natuint;
function Wstrposdirorder(str,substr:PWideChar;start,order:natuint;direction:shortint):natuint;
function strcount(str,substr:PChar;start:Natuint):natuint;
function Wstrcount(str,substr:PWideChar;start:Natuint):natuint;
function strposinverse(str,substr:PChar;start:Natuint):Natuint;
function Wstrposinverse(str,substr:PWideChar;start:natuint):natuint;
function UIntToPChar(UInt:natuint):Pchar;
function UIntToPWChar(UInt:natuint):PWideChar;
function PCharToUint(str:PChar):natuint;
function PWCharToUint(str:PWideChar):natuint;
function IntToPChar(Int:natint):Pchar;
function IntToPWChar(Int:natint):PWideChar;
function PCharToInt(str:PChar):natint;
function PWCharToInt(str:PWideChar):natint;
function ExtendedToPChar(num:Extended;Reserveddecimal:byte):PChar;
function ExtendedToPWChar(num:Extended;Reserveddecimal:byte):PWideChar;
function PCharToExtended(str:PChar):extended;
function PWCharToExtended(str:PWideChar):extended;
function IntPower(a:natint;b:natuint):natint;
function UIntPower(a,b:natuint):natuint;
function ExtendedPower(a:extended;b:natuint):extended;
function UintToHex(inputint:natuint):Pchar;
function UintToWhex(inputint:natuint):PWideChar;
function HexToUint(inputhex:PChar):natuint;
function WHexToUint(inputhex:PWideChar):natuint;
function PChar_encrypt_to_passwd(oristr:PChar):PChar;
function PWChar_encrypt_to_passwd(oristr:PWideChar):PChar;
function Passwd_decrypt_to_PChar(passwdstr:PChar):PChar;
function Passwd_decrypt_to_PWChar(passwdstr:PChar):PWideChar;
function PCharToPWChar(orgstr:PChar):PWideChar;
function PWCharToPChar(orgstr:PWideChar):PChar;
function PCharIsInt(str:PChar):boolean;
function PWCharIsInt(str:PWideChar):boolean;
function PCharMatchMask(orgstr,maskstr:PChar):boolean;
function PWCharMatchMask(orgstr,maskstr:PWideChar):boolean;
function PCharGetWildcard(orgstr,maskstr:PChar):maskwildcard;
function PWCharGetWildcard(orgstr,maskstr:PWideChar):Wmaskwildcard;
function Neighborlinegenerate(originalstr,linestr:PWideChar;row:natuint;mcolumn:natuint):neighborline;
function TotalLineList(originalstr,linefeed:PWideChar;mcolumn:natuint):linelist;

var compheap,sysheap:systemheap;
    exe_heap:executable_heap;
    
implementation

procedure fpc_specific_handler;compilerproc;[public,alias:'__FPC_specific_handler'];
begin
end;
procedure fpc_handleerror;compilerproc;[public,alias:'FPC_HANDLEERROR'];
begin
end;
procedure fpc_lib_exit;compilerproc;[public,alias:'FPC_LIB_EXIT'];
begin
end;
procedure fpc_libinitializeunits;compilerproc;[public,alias:'FPC_LIBINITIALIZEUNITS'];
begin
end;
procedure fpc_initializeunits;compilerproc;[public,alias:'FPC_INITIALIZEUNITS'];
begin
end;
procedure fpc_finalizeunits;compilerproc;[public,alias:'FPC_FINALIZEUNITS'];
begin
end;
procedure fpc_do_exit;compilerproc;[public,alias:'FPC_DI_EXIT'];
begin
end;
procedure fpc_div_by_zero;compilerproc;[public,alias:'FPC_DIVBYZERO'];
begin
end;
function fpc_qword_to_double(q:qword):double;compilerproc;[public,alias:'FPC_QWORD_TO_DOUBLE'];
begin
 fpc_qword_to_double:=dword(q and $ffffffff)+dword(q shr 32)*double(4294967296.0);
end;
function fpc_int64_to_double(i:int64):double;compilerproc;[public,alias:'FPC_INT64_TO_DOUBLE'];
begin
 fpc_int64_to_double:=dword(i and $ffffffff)+longint(i shr 32)*double(4294967296.0);
end;
procedure compheap_delete_item(p:pointer);
var i,j,k,len:natuint;
begin
 i:=1;
 while(i<=compheap.heapcount) do
  begin
   if(natuint(p)>=compheap.heapsection[i,1]) and (natuint(p)<=compheap.heapsection[i,2]) then break;
   inc(i);
  end;
 if(i>compheap.heapcount) then exit;
 len:=compheap.heapsection[i,2]-compheap.heapsection[i,1]+1;
 for j:=i+1 to compheap.heapcount do
  begin
   for k:=compheap.heapsection[j,1] to compheap.heapsection[j,2] do
    begin
     compheap.heapcontent[k-len-Qword(@compheap.heapcontent)+1]:=compheap.heapcontent[k-Qword(@compheap.heapcontent)+1];
     compheap.heapcontent[k-Qword(@compheap.heapcontent)+1]:=0;
    end;
   compheap.heapsection[j-1,1]:=compheap.heapsection[j,1]-len;
   compheap.heapsection[j-1,2]:=compheap.heapsection[j,2]-len;
  end;
 compheap.heapsection[compheap.heapcount,1]:=0;
 compheap.heapsection[compheap.heapcount,2]:=0; 
 dec(compheap.heapcount); inc(compheap.heaprest,len);
end;
function fpc_getmem(size:natuint):Pointer;compilerproc;[public,alias:'FPC_GETMEM'];
var i,istart,cstart:natuint;
begin
 if(compheap.heapcount>=maxsection) then exit(nil);
 if(compheap.heaprest<size) then exit(nil);
 if(size=0) then exit(nil);
 if(compheap.heapcount>0) then istart:=compheap.heapsection[compheap.heapcount,2]+1 else istart:=Natuint(@compheap.heapcontent);
 cstart:=istart-Natuint(@compheap.heapcontent)+1;
 inc(compheap.heapcount);
 compheap.heapsection[compheap.heapcount,1]:=istart;
 compheap.heapsection[compheap.heapcount,2]:=istart+size-1;
 for i:=1 to size do
  begin
   compheap.heapcontent[cstart+i-1]:=0;
  end;
 dec(compheap.heaprest,size);
 fpc_getmem:=Pointer(compheap.heapsection[compheap.heapcount,1]);
end;
procedure fpc_freemem(var p:pointer);compilerproc;[public,alias:'FPC_FREEMEM'];
begin
 if(p<>nil) then 
  begin
   compheap_delete_item(p); p:=nil;
  end
 else p:=nil;
end;
function fpc_allocmem(size:natuint):Pointer;compilerproc;[public,alias:'FPC_ALLOCMEM'];
var i,istart,cstart:natuint;
begin
 if(compheap.heapcount>=maxsection) then exit(nil);
 if(compheap.heaprest<size) then exit(nil);
 if(size=0) then exit(nil);
 if(compheap.heapcount>0) then istart:=compheap.heapsection[compheap.heapcount,2]+1 else istart:=NatUint(@compheap.heapcontent);
 cstart:=istart-Natuint(@compheap.heapcontent)+1;
 inc(compheap.heapcount);
 compheap.heapsection[compheap.heapcount,1]:=istart;
 compheap.heapsection[compheap.heapcount,2]:=istart+size-1;
 for i:=1 to size do
  begin
   compheap.heapcontent[cstart+i-1]:=0;
  end;
 dec(compheap.heaprest,size);
 fpc_allocmem:=Pointer(compheap.heapsection[compheap.heapcount,1]);
end;
procedure fpc_reallocmem(var p:Pointer;size:natuint);compilerproc;[public,alias:'FPC_REALLOCMEM'];
var i,istart,cstart,len,orgsize:Natuint;
    newp:Pointer;
    p1,p2:Pbyte;
begin
 if(compheap.heapcount>=maxsection) then exit;
 if(compheap.heaprest<size) then exit;
 if(size=0) then exit;
 if(compheap.heapcount>0) then istart:=compheap.heapsection[compheap.heapcount,2]+1 else istart:=Natuint(@compheap.heapcontent);
 cstart:=istart-Natuint(@compheap.heapcontent)+1;
 inc(compheap.heapcount);
 compheap.heapsection[compheap.heapcount,1]:=istart;
 compheap.heapsection[compheap.heapcount,2]:=istart+size-1;
 for i:=1 to size do
  begin
   compheap.heapcontent[cstart+i-1]:=0;
  end;
 dec(compheap.heaprest,size);
 newp:=Pointer(compheap.heapsection[compheap.heapcount,1]);
 if(p=nil) then
  begin
   newp:=p; exit;
  end;
 i:=1;
 while(i<=compheap.heapcount)do
  begin
   if(NatUint(p)>=compheap.heapsection[i,1]) and (NatUint(p)<=compheap.heapsection[i,2]) then break;
  end;
 if(i>compheap.heapcount) then exit;
 len:=NatUint(p)-compheap.heapsection[i,1]; 
 orgsize:=compheap.heapsection[i,2]-compheap.heapsection[i,1]+1;
 p1:=Pbyte(compheap.heapsection[i,1]); p2:=@newp^; 
 if(compheap.heapsection[compheap.heapcount,2]-compheap.heapsection[compheap.heapcount,1]+1>=orgsize) then
  begin
   for i:=1 to orgsize do (p2+i-1)^:=(p1+i-1)^;
  end
 else 
  begin
   for i:=1 to compheap.heapsection[compheap.heapcount,2]-compheap.heapsection[compheap.heapcount,1]+1 do (p2+i-1)^:=(p1+i-1)^;
  end;
 compheap_delete_item(p); p:=newp+len-orgsize;
end;
procedure fpc_move(const source;var dest;count:natuint);compilerproc;[public,alias:'FPC_MOVE'];
var p1,p2:Pchar;
    i:natuint;
begin
 p1:=@source; p2:=@dest;
 for i:=1 to count do (p2+i-1)^:=(p1+i-1)^;
end;
procedure sysheap_delete_item(p:pointer);
var i,j,k,len:natuint;
begin
 i:=1;
 while(i<=sysheap.heapcount) do
  begin
   if(natuint(p)>=sysheap.heapsection[i,1]) and (natuint(p)<=sysheap.heapsection[i,2]) then break;
   inc(i);
  end;
 if(i>sysheap.heapcount) then exit;
 len:=sysheap.heapsection[i,2]-sysheap.heapsection[i,1]+1;
 for j:=i+1 to sysheap.heapcount do
  begin
   for k:=sysheap.heapsection[j,1] to sysheap.heapsection[j,2] do
    begin
     sysheap.heapcontent[k-len-Qword(@sysheap.heapcontent)+1]:=sysheap.heapcontent[k-Qword(@sysheap.heapcontent)+1];
    end;
   sysheap.heapsection[j-1,1]:=sysheap.heapsection[j,1]-len;
   sysheap.heapsection[j-1,2]:=sysheap.heapsection[j,2]-len;
  end;
 sysheap.heapsection[sysheap.heapcount,1]:=0;
 sysheap.heapsection[sysheap.heapcount,2]:=0; 
 dec(sysheap.heapcount); inc(sysheap.heaprest,len);
end;
function getmem(size:natuint):Pointer;[public,alias:'getmem'];
var i,istart,cstart:natuint;
begin
 if(sysheap.heapcount>=maxsection) then exit(nil);
 if(sysheap.heaprest<size) then exit(nil);
 if(size=0) then exit(nil);
 if(sysheap.heapcount>0) then istart:=sysheap.heapsection[sysheap.heapcount,2]+1 else istart:=Natuint(@sysheap.heapcontent);
 cstart:=istart-Natuint(@sysheap.heapcontent)+1;
 inc(sysheap.heapcount);
 sysheap.heapsection[sysheap.heapcount,1]:=istart;
 sysheap.heapsection[sysheap.heapcount,2]:=istart+size-1;
 for i:=1 to size do
  begin
   sysheap.heapcontent[cstart+i-1]:=0;
  end;
 dec(sysheap.heaprest,size);
 getmem:=Pointer(sysheap.heapsection[sysheap.heapcount,1]);
end;
procedure freemem(var p:pointer);[public,alias:'freemem'];
begin
 if(p<>nil) then 
  begin
   sysheap_delete_item(p); p:=nil;
  end;
end;
function allocmem(size:natuint):Pointer;[public,alias:'allocmem'];
var i,istart,cstart:natuint;
begin
 if(sysheap.heapcount>=maxsection) then exit(nil);
 if(sysheap.heaprest<size) then exit(nil);
 if(size=0) then exit(nil);
 if(sysheap.heapcount>0) then istart:=sysheap.heapsection[sysheap.heapcount,2]+1 else istart:=NatUint(@sysheap.heapcontent);
 cstart:=istart-Natuint(@sysheap.heapcontent)+1;
 inc(sysheap.heapcount);
 sysheap.heapsection[sysheap.heapcount,1]:=istart;
 sysheap.heapsection[sysheap.heapcount,2]:=istart+size-1;
 for i:=1 to size do
  begin
   sysheap.heapcontent[cstart+i-1]:=0;
  end;
 dec(sysheap.heaprest,size);
 allocmem:=Pointer(sysheap.heapsection[sysheap.heapcount,1]);
end;
function getmemsize(p:Pointer):natuint;[public,alias:'getmemsize'];
var i:natuint;
begin
 i:=1;
 if(p=nil) then exit(0);
 while(i<=sysheap.heapcount) do
  begin
   if(NatUint(p)>=sysheap.heapsection[i,1]) and (NatUint(p)<=sysheap.heapsection[i,2]) then break;
   inc(i);
  end;
 if(i>sysheap.heapcount) then exit(0);
 getmemsize:=sysheap.heapsection[i,2]-sysheap.heapsection[i,1]+1;
end;
procedure reallocmem(var p:Pointer;size:natuint);[public,alias:'reallocmem'];
var i,len,orgsize:Natuint;
    newp:Pointer;
    po1,po2:Pbyte;
begin
 newp:=getmem(size);
 if(p=nil) then
  begin 
   p:=newp; exit;
  end;
 i:=1;
 while(i<=sysheap.heapcount-1) do
  begin
   if(NatUint(p)>=sysheap.heapsection[i,1]) and (NatUint(p)<=sysheap.heapsection[i,2]) then break;
   inc(i);
  end;
 if(i>=sysheap.heapcount) then 
  begin
   p:=newp; exit;
  end;
 len:=NatUint(p)-sysheap.heapsection[i,1];
 orgsize:=sysheap.heapsection[i,2]-sysheap.heapsection[i,1]+1;
 po1:=Pbyte(sysheap.heapsection[i,1]); po2:=newp;
 if(sysheap.heapsection[sysheap.heapcount,2]-sysheap.heapsection[sysheap.heapcount,1]+1>=orgsize) then
  begin
   for i:=1 to orgsize do (po2+i-1)^:=(po1+i-1)^;
  end
 else 
  begin
   for i:=1 to sysheap.heapsection[sysheap.heapcount,2]-sysheap.heapsection[sysheap.heapcount,1]+1 do (po2+i-1)^:=(po1+i-1)^;
  end;
 sysheap_delete_item(p); p:=newp+len-orgsize;
end;
procedure move(const source;var dest;count:natuint);[public,alias:'move'];
var p1,p2:Pchar;
    i:natuint;
begin
 p1:=@source; p2:=@dest;
 for i:=1 to count do (p2+i-1)^:=(p1+i-1)^;
end;
procedure sysheap_clear_all;[public,alias:'sysheap_clear_all'];
begin
 sysheap.heapcount:=0; sysheap.heaprest:=maxheap;
end;
procedure exe_heap_delete_item(p:Pointer);
var index,i,j,size:natuint;
    p1,p2:Pbyte;
begin
 index:=1;
 while(index<=exe_heap.heap_count) do
  begin
   if(natuint(p)>=exe_heap.heap_section[index,1]) and
   (natuint(p)<=exe_heap.heap_section[index,2]) then break;
   inc(i,1);
  end;
 if(index>exe_heap.heap_count) then exit;
 size:=exe_heap.heap_section[index,2]-exe_heap.heap_section[index,1]+1;
 for i:=index+1 to exe_heap.heap_count do
  begin
   for j:=exe_heap.heap_section[i,1]-natuint(@exe_heap.heap_content)
   to exe_heap.heap_section[i,2]-natuint(@exe_heap.heap_content) do
    begin
     p1:=(@exe_heap.heap_content+j-size-1); p2:=(@exe_heap.heap_content+j-1);
     p1^:=p2^; p2^:=0;
    end;
   exe_heap.heap_section[i-1,1]:=exe_heap.heap_section[i,1]-size;
   exe_heap.heap_section[i-1,2]:=exe_heap.heap_section[i,2]-size;
  end;
 inc(exe_heap.heap_rest_volume,size);
 dec(exe_heap.heap_count);
end;
function exe_heap_getmem(size:natuint):Pointer;[public,alias:'exe_heap_getmem'];
var i:natuint;
    p:PByte;
begin
 if(exe_heap.heap_count>=exe_heap_section_max_volume) then exit(nil);
 if(exe_heap.heap_rest_volume<size) then exit(nil);
 if(size=0) then exit(nil);
 inc(exe_heap.heap_count);
 if(exe_heap.heap_count>1) then
  begin
   exe_heap.heap_section[exe_heap.heap_count,1]:=exe_heap.heap_section[exe_heap.heap_count-1,2]+1;
   exe_heap.heap_section[exe_heap.heap_count,2]:=exe_heap.heap_section[exe_heap.heap_count,1]+size;
  end
 else if(exe_heap.heap_count=1) then
  begin
   exe_heap.heap_section[exe_heap.heap_count,1]:=natuint(@exe_heap.heap_content);
   exe_heap.heap_section[exe_heap.heap_count,2]:=exe_heap.heap_section[exe_heap.heap_count,1]+size;
  end;
 for i:=exe_heap.heap_section[exe_heap.heap_count,1]-natuint(@exe_heap.heap_section)
 to exe_heap.heap_section[exe_heap.heap_count,2]-natuint(@exe_heap.heap_section) do
  begin
   p:=(@exe_heap.heap_section+i-1); p^:=0;
  end;
 dec(exe_heap.heap_rest_volume,size);
 exe_heap_getmem:=Pointer(exe_heap.heap_section[exe_heap.heap_count,1]);
end;
function exe_heap_allocmem(size:natuint):Pointer;[public,alias:'exe_heap_allocmem'];
var i:natuint;
    p:PByte;
begin
 if(exe_heap.heap_count>=exe_heap_section_max_volume) then exit(nil);
 if(exe_heap.heap_rest_volume<size) then exit(nil);
 if(size=0) then exit(nil);
 inc(exe_heap.heap_count);
 if(exe_heap.heap_count>1) then
  begin
   exe_heap.heap_section[exe_heap.heap_count,1]:=exe_heap.heap_section[exe_heap.heap_count-1,2]+1;
   exe_heap.heap_section[exe_heap.heap_count,2]:=exe_heap.heap_section[exe_heap.heap_count,1]+size-1;
  end
 else if(exe_heap.heap_count=1) then
  begin
   exe_heap.heap_section[exe_heap.heap_count,1]:=natuint(@exe_heap.heap_content);
   exe_heap.heap_section[exe_heap.heap_count,2]:=exe_heap.heap_section[exe_heap.heap_count,1]+size-1;
  end;
 for i:=exe_heap.heap_section[exe_heap.heap_count,1]-natuint(@exe_heap.heap_section)
 to exe_heap.heap_section[exe_heap.heap_count,2]-natuint(@exe_heap.heap_section) do
  begin
   p:=(@exe_heap.heap_section+i-1); p^:=0;
  end;
 dec(exe_heap.heap_rest_volume,size);
 exe_heap_allocmem:=Pointer(exe_heap.heap_section[exe_heap.heap_count,1]);
end;
procedure exe_heap_freemem(var p:Pointer);[public,alias:'exe_heap_freemem'];
begin
 if(p<>nil) then
  begin
   exe_heap_delete_item(p); p:=nil;
  end;
end;
function exe_heap_getmemsize(p:Pointer):natuint;[public,alias:'exe_heap_getmemsize'];
var index:natuint;
begin
 index:=1;
 while(index<=exe_heap.heap_count) do
  begin
   if(natuint(p)>=exe_heap.heap_section[index,1]) and (natuint(p)<=exe_heap.heap_section[index,2])
   then break;
   inc(index);
  end;
 if(index>exe_heap.heap_count) then exit(0)
 else exe_heap_getmemsize:=exe_heap.heap_section[index,2]-exe_heap.heap_section[index,1]+1;
end;
procedure exe_heap_reallocmem(var p:Pointer;size:natuint);[public,alias:'exe_heap_reallocmem'];
var p1,p2:PByte;
    i,index,orgsize,offset:natuint;
begin
 p2:=exe_heap_allocmem(size);
 if(p=nil) then
  begin
   p:=p2; exit;
  end;
 index:=1;
 while(index<=exe_heap.heap_count-1) do
  begin
   if(natuint(p)>=exe_heap.heap_section[index,1]) and (natuint(p)<=exe_heap.heap_section[index,2]) then break;
   inc(index);
  end;
 if(index>=exe_heap.heap_count) then
  begin
   p:=p2; exit;
  end;
 orgsize:=exe_heap.heap_section[index,2]-exe_heap.heap_section[index,1]+1;
 p1:=PByte(exe_heap.heap_section[index,1]); offset:=natuint(p)-natuint(p1);
 if(size>orgsize) then
  begin
   for i:=1 to orgsize do
    begin
     (p2+i-1)^:=(p1+i-1)^;
    end;
  end
 else if(size<=orgsize) then
  begin
   for i:=1 to size do
    begin
     (p2+i-1)^:=(p1+i-1)^;
    end;
  end;
 exe_heap_freemem(p1);
 p:=p2-orgsize+offset;
end;
procedure exe_heap_move(var dest;const source;size:natuint);[public,alias:'exe_heap_move'];
var p1,p2:Pbyte;
    i:natuint;
begin
 p1:=@source; p2:=@dest;
 for i:=1 to size do
  begin
   (p2+i-1)^:=(p1+i-1)^;
  end;
end;                  
procedure exe_heap_clear_all;[public,alias:'exe_heap_clear_all'];
begin
 exe_heap.heap_count:=0; exe_heap.heap_rest_volume:=exe_heap_content_max_volume*sizeof(word);
end;
function frac(x:extended):extended;[public,alias:'frac'];
var j:natuint;
    num,procnum:extended;
begin
 if(x>0) then num:=x else num:=-x;
 procnum:=1;
 while(procnum<=num/10) do
  begin
   procnum:=procnum*10;
  end;
 while(num>=1) do
  begin
   j:=0;
   while(j<=9) do
    begin
     if(num>=j*procnum) and (num<(j+1)*procnum) then break;
     j:=j+1;
    end;
   if(j>=10) then break;
   num:=num-j*procnum;
   if(procnum>1) then procnum:=procnum/10;
  end;
 frac:=num;
end;
function optimize_integer_divide(a,b:natuint):natuint;[public,alias:'optimize_integer_divide'];
var procnum1,procnum2,degree,res:natuint;
begin
 procnum1:=a; procnum2:=b; degree:=1; res:=0;
 while(procnum2<=procnum1 shr 1) do
  begin
   procnum2:=procnum2 shl 1;
   degree:=degree shl 1;
  end;
 while(procnum1>=b) do
  begin
   if(procnum1>=procnum2) then
    begin
     procnum1:=procnum1-procnum2;
     res:=res+degree;
    end;
   degree:=degree shr 1;
   procnum2:=procnum2 shr 1;
  end;
 optimize_integer_divide:=res;
end;
function optimize_integer_modulo(a,b:natuint):natuint;[public,alias:'optimize_integer_modulo'];
var res,procnum:natuint;
begin
 res:=a; procnum:=b;
 while(procnum<res shr 1) do
  begin
   procnum:=procnum shl 1;
  end;
 while(res>=b) do
  begin
   if(res>=procnum) then res:=res-procnum;
   procnum:=procnum shr 1;
  end;
 optimize_integer_modulo:=res;
end; 
function strlen(str:Pchar):natuint;[public,alias:'strlen'];
var res:natuint;
begin
 res:=0;
 if(str=nil) then exit(0);
 while((str+res)^<>#0) do inc(res);
 strlen:=res;
end;
function wstrlen(str:PWideChar):natuint;[public,alias:'Wstrlen'];
var res:natuint;
begin
 res:=0;
 if(str=nil) then exit(0);
 while((str+res)^<>#0) do inc(res);
 wstrlen:=res;
end;
function strcmp(str1,str2:Pchar):natint;[public,alias:'strcmp'];
var i:natint;
begin
 i:=0;
 if(str1=nil) then exit(-1) else if(str2=nil) then exit(1);
 while((str1+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0) do inc(i);
 if((str1+i)^>(str2+i)^) then strcmp:=1
 else if((str1+i)^<(str2+i)^) then strcmp:=-1
 else strcmp:=0;
end;
function Wstrcmp(str1,str2:PwideChar):natint;[public,alias:'Wstrcmp'];
var i:natint;
begin
 i:=0;
 if(str1=nil) then exit(-1) else if(str2=nil) then exit(1);
 while((str1+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0) do inc(i);
 if((str1+i)^>(str2+i)^) then Wstrcmp:=1
 else if((str1+i)^<(str2+i)^) then Wstrcmp:=-1
 else Wstrcmp:=0;
end;
function strpartcmp(str1:PChar;position,length:natuint;str2:PChar):natint;[public,alias:'strpartcmp'];
var i,len:natuint;
begin
 i:=0; len:=strlen(str1);
 if(str1=nil) then exit(-1) else if(str2=nil) then exit(1);
 if(position+length-1>len) then
  begin
   while((str1+position+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0)
   and (i<len-position+1) do inc(i);
   if(i>=len-position+1) then strpartcmp:=0
   else if((str1+position+i)^<(str2+i)^) then strpartcmp:=-1
   else if((str1+position+i)^>(str2+i)^) then strpartcmp:=1
   else strpartcmp:=0;
  end
 else
  begin
   while((str1+position+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0)
   and (i<length) do inc(i);
   if(i>=length) then strpartcmp:=0
   else if((str1+position+i)^<(str2+i)^) then strpartcmp:=-1
   else if((str1+position+i)^>(str2+i)^) then strpartcmp:=1
   else strpartcmp:=0;
  end;
end;
function Wstrpartcmp(str1:PWideChar;position,length:natuint;str2:PWideChar):natint;[public,alias:'Wstrpartcmp'];
var i,len:natuint;
begin
 i:=0; len:=Wstrlen(str1);
 if(str1=nil) then exit(-1) else if(str2=nil) then exit(1);
 if(position+length-1>len) then
  begin
   while((str1+position+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0)
   and (i<len-position+1) do inc(i);
   if(i>=len-position+1) then Wstrpartcmp:=0
   else if((str1+position+i)^<(str2+i)^) then Wstrpartcmp:=-1
   else if((str1+position+i)^>(str2+i)^) then Wstrpartcmp:=1
   else Wstrpartcmp:=0;
  end
 else
  begin
   while((str1+position+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0)
   and (i<length) do inc(i);
   if(i>=length) then Wstrpartcmp:=0
   else if((str1+position+i)^<(str2+i)^) then Wstrpartcmp:=-1
   else if((str1+position+i)^>(str2+i)^) then Wstrpartcmp:=1
   else Wstrpartcmp:=0;
  end;
end;  
function strcmpL(str1,str2:Pchar):natint;[public,alias:'strcmpL'];
var i,len1,len2:natint;
begin
 i:=0; len1:=strlen(str1); len2:=strlen(str2);
 if(len1>len2) then exit(1) else if(len1<len2) then exit(-1);
 if(str1=nil) then exit(-1) else if(str2=nil) then exit(1);
 while((str1+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0) do inc(i);
 if((str1+i)^>(str2+i)^) then strcmpL:=1
 else if((str1+i)^<(str2+i)^) then strcmpL:=-1
 else strcmpL:=0;
end;
function WstrcmpL(str1,str2:PwideChar):natint;[public,alias:'WstrcmpL'];
var i,len1,len2:natint;
begin
 i:=0; len1:=Wstrlen(str1); len2:=Wstrlen(str2);
 if(len1>len2) then exit(1) else if(len1<len2) then exit(-1);
 if(str1=nil) then exit(-1) else if(str2=nil) then exit(1);
 while((str1+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0) do inc(i);
 if((str1+i)^>(str2+i)^) then WstrcmpL:=1
 else if((str1+i)^<(str2+i)^) then WstrcmpL:=-1
 else WstrcmpL:=0;
end;
function strpartcmpL(str1:PChar;position,length:natuint;str2:PChar):natint;[public,alias:'strpartcmpL'];
var i,len,sublen:natuint;
begin
 i:=0; len:=strlen(str1); sublen:=strlen(str2);
 if(str1=nil) then exit(-1) else if(str2=nil) then exit(1);
 if(position+length-1>len) then
  begin
   if(len-position+1>sublen) then exit(1) else if(len-position+1<sublen) then exit(-1);
   while((str1+position+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0)
   and (i<len-position+1) do inc(i);
   if(i>=len-position+1) then strpartcmpL:=0
   else if((str1+position+i)^<(str2+i)^) then strpartcmpL:=-1
   else if((str1+position+i)^>(str2+i)^) then strpartcmpL:=1
   else strpartcmpL:=0;
  end
 else
  begin
   if(length>sublen) then exit(1) else if(length<sublen) then exit(-1);
   while((str1+position+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0)
   and (i<length) do inc(i);
   if(i>=length) then strpartcmpL:=0
   else if((str1+position+i)^<(str2+i)^) then strpartcmpL:=-1
   else if((str1+position+i)^>(str2+i)^) then strpartcmpL:=1
   else strpartcmpL:=0;
  end;
end;
function WstrpartcmpL(str1:PWideChar;position,length:natuint;str2:PWideChar):natint;[public,alias:'WstrpartcmpL'];
var i,len,sublen:natuint;
begin
 i:=0; len:=Wstrlen(str1); sublen:=Wstrlen(str2);
 if(str1=nil) then exit(-1) else if(str2=nil) then exit(1);
 if(position+length-1>len) then
  begin
   if(len-position+1>sublen) then exit(1) else if(len-position+1<sublen) then exit(-1);
   while((str1+position+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0)
   and (i<len-position+1) do inc(i);
   if(i>=len-position+1) then WstrpartcmpL:=0
   else if((str1+position+i)^<(str2+i)^) then WstrpartcmpL:=-1
   else if((str1+position+i)^>(str2+i)^) then WstrpartcmpL:=1
   else WstrpartcmpL:=0;
  end
 else
  begin
   if(length>sublen) then exit(1) else if(length<sublen) then exit(-1);
   while((str1+position+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0)
   and (i<length) do inc(i);
   if(i>=length) then WstrpartcmpL:=0
   else if((str1+position+i)^<(str2+i)^) then WstrpartcmpL:=-1
   else if((str1+position+i)^>(str2+i)^) then WstrpartcmpL:=1
   else WstrpartcmpL:=0;
  end;
end;
procedure strinit(var str:PChar;size:natuint);[public,alias:'strinit'];
begin
 str:=allocmem(sizeof(char)*(size+1));
end;
procedure wstrinit(var str:PWideChar;Size:natuint);[public,alias:'wstrinit'];
begin
 str:=allocmem(sizeof(WideChar)*(size+1));
end;
procedure strrealloc(var str:PChar;size:natuint);[public,alias:'strrealloc'];
begin
 ReallocMem(str,sizeof(char)*(size+1));
 (str+size)^:=#0;
end;
procedure Wstrrealloc(var str:PwideChar;size:natuint);[public,alias:'Wstrrealloc'];
begin
 ReallocMem(str,sizeof(WideChar)*(size+1));
 (str+size)^:=#0;
end;
procedure strset(var str:PChar;val:Pchar);[public,alias:'strset'];
var i:natuint;
begin
 i:=0;
 while((val+i)^<>#0) do
  begin
   (str+i)^:=(val+i)^; inc(i);
  end;
 (str+i)^:=#0;
end;
procedure wstrset(var str:PWideChar;val:Pwidechar);[public,alias:'Wstrset'];
var i:natuint;
begin
 i:=0;
 while((val+i)^<>#0) do
  begin
   (str+i)^:=(val+i)^; inc(i);
  end;
 (str+i)^:=#0;
end;
procedure strcat(var dest:PChar;src:PChar);[public,alias:'strcat'];
var i,len:natuint;
begin
 len:=strlen(dest);
 for i:=1 to strlen(src) do
  begin
   (dest+len+i-1)^:=(src+i-1)^;
  end;
 (dest+len+strlen(src))^:=#0;
end;
procedure Wstrcat(var dest:PWideChar;src:PWideChar);[public,alias:'Wstrcat'];
var i,len:natuint;
begin
 len:=Wstrlen(dest);
 for i:=1 to Wstrlen(src) do
  begin
   (dest+len+i-1)^:=(src+i-1)^;
  end;
 (dest+len+Wstrlen(src))^:=#0;
end;
procedure strfree(var str:PChar);[public,alias:'strfree'];
begin
 freemem(str); if(str<>nil) then str:=nil;
end;
procedure Wstrfree(var str:PWideChar);[public,alias:'Wstrfree'];
begin
 freemem(str); if(str<>nil) then str:=nil;
end;
procedure strUpperCase(var str:PChar);[public,alias:'strUpperCase'];
var i,len:natuint;
begin
 len:=strlen(str);
 for i:=1 to len do
  begin
   if(str^>='a') and (str^<='z') then str^:=Char(Byte(str^)-32);
  end;
end;
procedure strLowerCase(var str:PChar);[public,alias:'strLowerCase'];
var i,len:natuint;
begin
 len:=strlen(str);
 for i:=1 to len do
  begin
   if(str^>='A') and (str^<='Z') then str^:=Char(Byte(str^)+32);
  end;
end;
procedure WstrUpperCase(var str:PWideChar);[public,alias:'WstrUpperCase'];
var i,len:natuint;
begin
 len:=Wstrlen(str);
 for i:=1 to len do
  begin
   if(str^>='a') and (str^<='z') then str^:=WideChar(Word(str^)-32);
  end;
end;
procedure WstrLowerCase(var str:PWideChar);[public,alias:'WstrLowerCase'];
var i,len:natuint;
begin
 len:=Wstrlen(str);
 for i:=1 to len do
  begin
   if(str^>='A') and (str^<='Z') then str^:=WideChar(Word(str^)+32);
  end;
end;  
function strcopy(str:PChar;index,count:Natuint):Pchar;[public,alias:'strcopy'];
var newstr:PChar;
    i,len:natuint;
begin
 len:=strlen(str);
 if(index>len) then exit(nil);
 if(index+count-1>len) then
  begin
   strinit(newstr,len-index+1);
   for i:=1 to len-index+1 do
    begin
     (newstr+i-1)^:=(str+index-1+i-1)^;
    end;
   (newstr+len-index+1)^:=#0;
  end
 else
  begin
   strinit(newstr,count);
   for i:=1 to count do
    begin
     (newstr+i-1)^:=(str+index-1+i-1)^;
    end;
   (newstr+count)^:=#0;
  end;
 strcopy:=newstr;
end;
function Wstrcopy(str:PWideChar;index,count:Natuint):PWideChar;[public,alias:'Wstrcopy'];
var newstr:PWideChar;
    i,len:natuint;
begin
 len:=Wstrlen(str);
 if(index>len) then exit(nil);
 if(index+count-1>len) then
  begin
   Wstrinit(newstr,len-index+1);
   for i:=1 to len-index+1 do
    begin
     (newstr+i-1)^:=(str+index-1+i-1)^;
    end;
   (newstr+len-index+1)^:=#0;
  end
 else
  begin
   Wstrinit(newstr,count);
   for i:=1 to count do
    begin
     (newstr+i-1)^:=(str+index-1+i-1)^;
    end;
   (newstr+count)^:=#0;
  end;
 Wstrcopy:=newstr;
end;
function strcutout(str:PChar;left,right:Natuint):PChar;[public,alias:'strcutout'];
var newstr:Pchar;
    i,len:natuint;
begin
 len:=strlen(str); 
 if(left>len) or (left>right) then exit(nil);
 if(right<=len) then
  begin
   strinit(newstr,right-left+1);
   for i:=left to right do
    begin
     (newstr+i-left)^:=(str+i-1)^;
    end;
   (newstr+right-left+1)^:=#0;
  end
 else if(right>len) then
  begin
   strinit(newstr,len-left+1);
   for i:=left to len do
    begin
     (newstr+i-1)^:=(str+i-1)^;
    end;
   (newstr+len-left+1)^:=#0;
  end;
 strcutout:=newstr;
end;
function Wstrcutout(str:PWideChar;left,right:Natuint):PWideChar;[public,alias:'Wstrcutout'];
var newstr:PWidechar;
    i,len:natuint;
begin
 len:=Wstrlen(str); 
 if(left>len) or (left>right) then exit(nil);
 if(right<=len) then
  begin
   Wstrinit(newstr,right-left+1);
   for i:=left to right do
    begin
     (newstr+i-left)^:=(str+i-1)^;
    end;
   (newstr+right-left+1)^:=#0;
  end
 else if(right>len) then
  begin
   Wstrinit(newstr,len-left+1);
   for i:=left to len do
    begin
     (newstr+i-1)^:=(str+i-1)^;
    end;
   (newstr+len-left+1)^:=#0;
  end;
 Wstrcutout:=newstr;
end;
procedure strdelete(var str:PChar;index,count:Natuint);[public,alias:'strdelete'];
var i,len:natuint;
begin
 len:=strlen(str);
 for i:=index+count to len do
  begin
   (str+i-1-count)^:=(str+i-1)^;
   (str+i-1)^:=#0;
  end;
 (str+len-count)^:=#0;
end;
procedure Wstrdelete(var str:PWideChar;index,count:Natuint);[public,alias:'Wstrdelete'];
var i,len:natuint;
begin
 len:=Wstrlen(str);
 for i:=index+count to len do
  begin
   (str+i-1-count)^:=(str+i-1)^;
   (str+i-1)^:=#0;
  end;
 (str+len-count)^:=#0;
end;
procedure strdeleteinrange(var str:PChar;left,right:Natuint);[public,alias:'strdeleteinrange'];
var i,len,distance:natuint;
begin
 len:=strlen(str); distance:=right-left+1;
 for i:=right+1 to len do
  begin
   (str+i-1-distance)^:=(str+i-1)^;
   (str+i-1)^:=#0;
  end;
 (str+len-distance)^:=#0;
end;
procedure WStrdeleteinrange(var str:PWideChar;left,right:Natuint);[public,alias:'Wstrdeleteinrange'];
var i,len,distance:natuint;
begin
 len:=Wstrlen(str); distance:=right-left+1;
 for i:=right+1 to len do
  begin
   (str+i-1-distance)^:=(str+i-1)^;
   (str+i-1)^:=#0;
  end;
 (str+len-distance)^:=#0;
end;
procedure strinsert(var str:PChar;insertstr:PChar;index:natuint);[public,alias:'strinsert'];
var strlength,partlength,i:natuint;
begin
 strlength:=strlen(str);
 partlength:=strlen(insertstr);
 for i:=strlength downto index do
  begin
   (str+i-1+partlength)^:=(str+i-1)^;
  end;
 for i:=1 to partlength do
  begin
   (str+index-1+i-1)^:=(insertstr+i-1)^;
  end;
 (str+strlength+partlength)^:=#0;
end;
procedure Wstrinsert(var str:PWideChar;insertstr:PWideChar;index:natuint);[public,alias:'Wstrinsert'];
var strlength,partlength,i:natuint;
begin
 strlength:=Wstrlen(str);
 partlength:=Wstrlen(insertstr);
 for i:=strlength downto index do
  begin
   (str+i-1+partlength)^:=(str+i-1)^;
  end;
 for i:=1 to partlength do
  begin
   (str+index-1+i-1)^:=(insertstr+i-1)^;
  end;
 (str+strlength+partlength)^:=#0;
end;
function strpos(str,substr:PChar;start:Natuint):Natuint;[public,alias:'strpos'];
var i,mylen,mysublen:natuint;
    partstr:PChar;
begin
 mylen:=strlen(str)-strlen(substr)+1; mysublen:=strlen(substr);
 if(start>=mylen) then exit(0);
 i:=start;
 while(i<=mylen) do
  begin
   partstr:=strcopy(str,i,mysublen);
   if(strcmp(substr,partstr)=0) then 
    begin
     strfree(partstr); break;
    end;
   strfree(partstr);
   inc(i);
  end;
 if(i>mylen) then strpos:=0 else strpos:=i;
end;
function Wstrpos(str,substr:PWideChar;start:natuint):natuint;[public,alias:'Wstrpos'];
var i,mylen,mysublen:natuint;
    partstr:PWideChar;
begin
 mylen:=Wstrlen(str)-Wstrlen(substr)+1; mysublen:=Wstrlen(substr);
 if(start>mylen) then exit(0);
 i:=start;
 while(i<=mylen) do
  begin
   partstr:=Wstrcopy(str,i,mysublen);
   if(Wstrcmp(substr,partstr)=0) then 
    begin
     Wstrfree(partstr);
     break;
    end;
   Wstrfree(partstr);
   inc(i);
  end;
 if(i>mylen) then Wstrpos:=0 else Wstrpos:=i;
end;
function strposdir(str,substr:PChar;start:natuint;direction:shortint):natuint;[public,alias:'strposdir'];
var i,mylen,mysublen:natuint;
    partstr:PChar;
begin
 mylen:=strlen(str)-strlen(substr)+1; mysublen:=strlen(substr);
 if(start>mylen) and (direction=1) then exit(0);
 if(start<1) and (direction=-1) then exit(0);
 if(direction=1) then
  begin
   i:=start;
   while(i<=mylen) do 
    begin
     partstr:=strcopy(str,i,mysublen);
     if(strcmp(substr,partstr)=0) then 
      begin
       strfree(partstr);
       break;
      end;
     strfree(partstr);
     inc(i);
    end;
   if(i>mylen) then strposdir:=0 else strposdir:=i;
  end
 else if(direction=-1) then
  begin
   i:=start;
   while(i>=1) do
    begin
     partstr:=strcopy(str,i,mysublen);
     if(strcmp(substr,partstr)=0) then 
      begin
       strfree(partstr);
       break;
      end;
     strfree(partstr);
     dec(i);
    end;
   if(i=0) then strposdir:=0 else strposdir:=i;
  end
 else if(direction=0) then strposdir:=0;
end;
function Wstrposdir(str,substr:PWideChar;start:natuint;direction:shortint):natuint;[public,alias:'Wstrposdir'];
var i,mylen,mysublen:natuint;
    partstr:PWideChar;
begin
 mylen:=Wstrlen(str)-Wstrlen(substr)+1; mysublen:=Wstrlen(substr);
 if(start>mylen) and (direction=1) then exit(0);
 if(start<1) and (direction=-1) then exit(0);
 if(direction=1) then
  begin
   i:=start;
   while(i<=mylen) do 
    begin
     partstr:=Wstrcopy(str,i,mysublen);
     if(Wstrcmp(substr,partstr)=0) then 
      begin
       Wstrfree(partstr);
       break;
      end;
     Wstrfree(partstr);
     inc(i);
    end;
   if(i>mylen) then Wstrposdir:=0 else Wstrposdir:=i;
  end
 else if(direction=-1) then
  begin
   i:=start;
   while(i>=1) do
    begin
     partstr:=Wstrcopy(str,i,mysublen);
     if(Wstrcmp(substr,partstr)=0) then 
      begin
       Wstrfree(partstr);
       break;
      end;
     Wstrfree(partstr);
     dec(i);
    end;
   if(i=0) then Wstrposdir:=0 else Wstrposdir:=i;
  end
 else if(direction=0) then Wstrposdir:=0;
end;
function strposorder(str,substr:PChar;start,order:natuint):natuint;[public,alias:'strposorder'];
var i,forder,mylen,mysublen:natuint;
    partstr:Pchar;
begin
 mylen:=strlen(str)-strlen(substr)+1; mysublen:=strlen(substr);
 if(start>mylen) then exit(0);
 if(order=0) then exit(0);
 i:=start; forder:=0;
 while(i<=mylen) do
  begin 
   partstr:=strcopy(str,i,mysublen);
   if(strcmp(substr,partstr)=0) then
    begin
     inc(forder);
     strfree(partstr);
     if(forder>=order) then break else inc(i,mysublen);
    end
   else 
    begin
     strfree(partstr);
     inc(i);
    end;
  end;
 if(i>mylen) then strposorder:=0 else strposorder:=i;
end;
function Wstrposorder(str,substr:PWideChar;start,order:natuint):natuint;[public,alias:'Wstrposorder'];
var i,forder,mylen,mysublen:natuint;
    partstr:PWideChar;
begin
 mylen:=Wstrlen(str)-Wstrlen(substr)+1; mysublen:=Wstrlen(substr);
 if(start>mylen) then exit(0);
 if(order=0) then exit(0);
 i:=start; forder:=0;
 while(i<=mylen) do
  begin 
   partstr:=Wstrcopy(str,i,mysublen);
   if(Wstrcmp(substr,partstr)=0) then
    begin
     inc(forder);
     Wstrfree(partstr);
     if(forder>=order) then break else inc(i,mysublen);
    end
   else 
    begin
     Wstrfree(partstr);
     inc(i);
    end;
  end;
 if(i>mylen) then Wstrposorder:=0 else Wstrposorder:=i;
end;
function strposdirorder(str,substr:PChar;start,order:natuint;direction:shortint):natuint;[public,alias:'strposdirorder'];
var i,forder,mylen,mysublen:natuint;
    partstr:PChar;
begin
 mylen:=strlen(str)-strlen(substr)+1; mysublen:=strlen(substr);
 if(start>mylen) and (direction=1) then exit(0);
 if(start<1) and (direction=-1) then exit(0);
 if(direction=0) then exit(0);
 if(order=0) then exit(0);
 i:=start; forder:=0;
 if(direction=1) then
  begin
   while(i<=mylen) do
    begin
     partstr:=strcopy(str,i,mysublen);
     if(strcmp(substr,partstr)=0) then
      begin
       inc(forder);
       strfree(partstr);
       if(forder>=order) then break else inc(i,mysublen);
      end
     else 
      begin
       strfree(partstr);
       inc(i);
      end;
    end;
   if(i>mylen) then strposdirorder:=0 else strposdirorder:=i;
  end
 else if(direction=-1) then
  begin
   while(i>=1) do
    begin
     partstr:=strcopy(str,i,mysublen);
     if(strcmp(substr,partstr)=0) then
      begin
       inc(forder);
       strfree(partstr);
       if(forder>=order) then break else dec(i,mysublen);
      end
     else 
      begin
       strfree(partstr);
       dec(i);
      end;
    end;
   if(i=0) then strposdirorder:=0 else strposdirorder:=i;
  end;
end;
function Wstrposdirorder(str,substr:PWideChar;start,order:natuint;direction:shortint):natuint;[public,alias:'Wstrposdirorder'];
var i,forder,mylen,mysublen:natuint;
    partstr:PWideChar;
begin
 mylen:=Wstrlen(str)-Wstrlen(substr)+1; mysublen:=Wstrlen(substr);
 if(start>mylen) and (direction=1) then exit(0);
 if(start<1) and (direction=-1) then exit(0);
 if(direction=0) then exit(0);
 if(order=0) then exit(0);
 i:=start; forder:=0;
 if(direction=1) then
  begin
   while(i<=mylen) do
    begin
     partstr:=Wstrcopy(str,i,mysublen);
     if(Wstrcmp(substr,partstr)=0) then
      begin
       inc(forder);
       Wstrfree(partstr);
       if(forder>=order) then break else inc(i,mysublen);
      end
     else 
      begin
       Wstrfree(partstr);
       inc(i);
      end;
    end;
   if(i>mylen) then Wstrposdirorder:=0 else Wstrposdirorder:=i;
  end
 else if(direction=-1) then
  begin
   while(i>=1) do
    begin
     partstr:=Wstrcopy(str,i,mysublen);
     if(Wstrcmp(substr,partstr)=0) then
      begin
       inc(forder);
       Wstrfree(partstr);
       if(forder>=order) then break else dec(i,mysublen);
      end
     else 
      begin
       Wstrfree(partstr);
       dec(i);
      end;
    end;
   if(i=0) then Wstrposdirorder:=0 else Wstrposdirorder:=i;
  end;
end;
function strcount(str,substr:PChar;start:Natuint):natuint;[public,alias:'strcount'];
var i,len1,len2,res:natuint;
    partstr:PChar;
begin
 len1:=strlen(str); len2:=strlen(substr);
 if(len1=0) or (len2=0) then res:=0
 else if(len2>len1) then
  begin
   res:=0;
  end
 else if(len2=len1) then
  begin
   if(start>1) then res:=0
   else 
    begin
     if(StrCmp(str,substr)=0) then res:=1 else res:=0;
    end;
  end
 else
  begin
   res:=0; i:=start;
   while(i<=len1-len2+1) do
    begin
     partstr:=strcopy(str,i,len2);
     if(StrCmp(substr,partstr)=0) then 
      begin
       strfree(partstr); inc(i,len2); inc(res);
      end
     else 
      begin
       strfree(partstr); inc(i);
      end;
    end;
  end;
 strcount:=res;
end;
function Wstrcount(str,substr:PWideChar;start:Natuint):natuint;[public,alias:'Wstrcount'];
var i,len1,len2,res:natuint;
    partstr:PWideChar;
begin
 len1:=Wstrlen(str); len2:=Wstrlen(substr);
 if(len1=0) or (len2=0) then res:=0
 else if(len2>len1) then
  begin
   res:=0;
  end
 else if(len2=len1) then
  begin
   if(start>1) then res:=0
   else 
    begin
     if(WStrCmp(str,substr)=0) then res:=1 else res:=0;
    end;
  end
 else
  begin
   res:=0; i:=start;
   while(i<=len1-len2+1) do
    begin
     partstr:=Wstrcopy(str,i,len2);
     if(WStrCmp(substr,partstr)=0) then 
      begin
       Wstrfree(partstr); inc(i,len2); inc(res);
      end
     else 
      begin
       Wstrfree(partstr); inc(i);
      end;
    end;
  end;
 Wstrcount:=res;
end;
function strposinverse(str,substr:PChar;start:Natuint):Natuint;[public,alias:'strposinverse'];
var i,mylen,mysublen:natuint;
    partstr:Pchar;
begin
 mylen:=strlen(str)-strlen(substr)+1; i:=mylen; mysublen:=strlen(substr);
 while(i>=start) do
  begin
   partstr:=strcopy(str,i,mysublen);
   if(strcmp(substr,partstr)=0) then 
    begin
     strfree(partstr);
     break;
    end;
   strfree(partstr);
   dec(i);
  end;
 if(i<start) then strposinverse:=0 else strposinverse:=i;
end;
function Wstrposinverse(str,substr:PWideChar;start:natuint):natuint;[public,alias:'Wstrposinverse'];
var i,mylen,mysublen:natuint;
    partstr:PWideChar;
begin
 mylen:=Wstrlen(str)-Wstrlen(substr)+1; i:=mylen; mysublen:=Wstrlen(substr);
 while(i>=start) do
  begin
   partstr:=Wstrcopy(str,i,mysublen);
   if(Wstrcmp(substr,partstr)=0) then 
    begin
     Wstrfree(partstr);
     break;
    end;
   Wstrfree(partstr);
   dec(i);
  end;
 if(i<start) then Wstrposinverse:=0 else Wstrposinverse:=i;
end;
function UIntToPChar(UInt:natuint):Pchar;[public,alias:'uinttochar'];
const numchar:PChar='0123456789';
var i:byte;
    myint:natuint;
    mychar:PChar;
begin
 mychar:=allocmem(sizeof(Char)*31);
 i:=20; myint:=uint; (mychar+30)^:=#0;
 repeat
  begin
   (mychar+i-1)^:=(numchar+myint mod 10)^;
   myint:=myint div 10;
   dec(i);
  end;
 until (myint=0);
 UIntToPChar:=mychar+i;
end;
function UIntToPWChar(UInt:natuint):PWideChar;[public,alias:'uinttopwchar'];
const numchar:PWideChar='0123456789';
var i:byte;
    myint:natuint;
    mychar:PWideChar;
begin
 mychar:=allocmem(sizeof(WideChar)*31);
 i:=20; myint:=uint; (mychar+30)^:=#0;
 repeat
  begin
   (mychar+i-1)^:=(numchar+myint mod 10)^;
   myint:=myint div 10;
   dec(i);
  end;
 until (myint=0);
 UIntToPWChar:=mychar+i;
end;
function PCharToUint(str:PChar):natuint;[public,alias:'PCharToUint'];
const numchar:Pchar='0123456789';
var i,j,res:natuint;
begin
 res:=0; i:=0;
 if(str=nil) then exit(0);
 while ((str+i)^<>#0) do
  begin
   for j:=0 to 9 do 
    if((str+i)^=(numchar+j)^) then 
     begin
      res:=res*10+j;
      break;
     end;
   inc(i);
  end;
 PCharToUint:=res;
end;
function PWCharToUint(str:PWidechar):natuint;[public,alias:'PWCharToUint'];
const numchar:PWidechar='0123456789';
var i,j,res:natuint;
begin
 res:=0; i:=0;
 if(str=nil) then exit(0);
 while ((str+i)^<>#0) do
  begin
   for j:=0 to 9 do 
    if((str+i)^=(numchar+j)^) then 
     begin
      res:=res*10+j;
      break;
     end;
   inc(i);
  end;
 PWCharToUint:=res;
end;
function IntToPChar(int:natint):PChar;[public,alias:'IntToPChar'];
const numchar:Pchar='0123456789';
var negative:boolean=false;
    procnum:natint;
    mystr:Pchar;
    myrightnum:natint=30;
begin
 procnum:=int; strinit(mystr,30);
 if(int<0) then
  begin
   procnum:=-int;
   negative:=true;
  end;
 repeat 
  begin
   (mystr+myrightnum-1)^:=(numchar+procnum mod 10)^;
   dec(myrightnum);
   procnum:=procnum div 10;
  end;
 until (procnum=0);
 if(negative=true)then 
  begin
   (mystr+myrightnum-1)^:='-';
   IntToPChar:=mystr+myrightnum-1;
  end
 else
  begin
   IntToPChar:=mystr+myrightnum;
  end;
end;
function IntToPWChar(int:natint):PWideChar;[public,alias:'IntToPWChar'];
const numchar:PWidechar='0123456789';
var negative:boolean=false;
    procnum:natint;
    mystr:PWidechar;
    myrightnum:natint=30;
begin
 procnum:=int; Wstrinit(mystr,30);
 if(int<0) then
  begin
   procnum:=-int;
   negative:=true;
  end;
 repeat 
  begin
   (mystr+myrightnum-1)^:=(numchar+procnum mod 10)^;
   dec(myrightnum);
   procnum:=procnum div 10;
  end;
 until (procnum=0);
 if(negative=true)then 
  begin
   (mystr+myrightnum-1)^:='-';
   IntToPWChar:=mystr+myrightnum-1;
  end
 else
  begin
   IntToPWChar:=mystr+myrightnum;
  end;
end;
function PCharToInt(str:PChar):natint;[public,alias:'PCharToInt'];
const numchar:PChar='0123456789';
var i,j:natuint;
    res,start:natint;
    negative:boolean;
begin
 res:=0; start:=1;
 if(str=nil) then exit(0);
 if(str^='-') then 
  begin
   start:=2;
   negative:=true;
  end;
 for i:=start to strlen(str) do
  begin
   for j:=0 to 9 do 
    if((str+i-1)^=(numchar+j)^) then 
     begin
      res:=res*10+j;
      break;
     end; 
  end;
 if(negative=true) then PCharToInt:=-res else PCharToInt:=res;
end;
function PWCharToInt(str:PWideChar):natint;[public,alias:'PWCharToInt'];
const numchar:PWideChar='0123456789';
var i,j:natuint;
    res,start:natint;
    negative:boolean;
begin
 res:=0; start:=1;
 if(str=nil) then exit(0);
 if(str^='-') then 
  begin
   start:=2;
   negative:=true;
  end;
 for i:=start to Wstrlen(str) do
  begin
   for j:=0 to 9 do 
    if((str+i-1)^=(numchar+j)^) then 
     begin
      res:=res*10+j;
      break;
     end; 
  end;
 if(negative=true) then PWCharToInt:=-res else PWCharToInt:=res;
end;
function ExtendedToPChar(num:Extended;Reserveddecimal:byte):PChar;[public,alias:'ExtendedToPChar'];
const numchar:PChar='0123456789';
var orgnum,intpart,decpart,procnum:extended;
    partstr1,partstr2,res:PChar;
    isnegative,havedecimal:boolean;
    len1,len2,i,size:natuint;
begin
 if(num>0) then
  begin
   orgnum:=num; isnegative:=false;
  end
 else
  begin
   orgnum:=-num; isnegative:=true;
  end;
 intpart:=orgnum-frac(orgnum); decpart:=frac(orgnum)*ExtendedPower(10,Reserveddecimal);
 partstr1:=nil; partstr2:=nil;
 len1:=0; len2:=0;
 if(decpart=0) then havedecimal:=false else havedecimal:=true;
 procnum:=1;
 while(procnum<=intpart) do
  begin
   procnum:=procnum*10;
  end;
 while(intpart>0) do
  begin
   inc(len1);
   if(procnum>1) then procnum:=procnum/10;
   i:=0;
   while(i<=9) do
    begin
     if(intpart>=procnum*i) and (intpart<procnum*(i+1)) then break;
     inc(i);
    end;
   intpart:=intpart-procnum*i;
   strrealloc(partstr1,len1);
   (partstr1+len1-1)^:=(numchar+i)^;
   if(i>=10) or (procnum<=1) then break;
  end;
 procnum:=1;
 while(procnum<=decpart) do
  begin
   procnum:=procnum*10;
  end;
 while(decpart>0) do
  begin
   inc(len2);
   if(procnum>1) then procnum:=procnum/10;
   i:=0;
   while(i<=9) do
    begin
     if(decpart>=procnum*i) and (decpart<procnum*(i+1)) then break;
     inc(i);
    end;
   decpart:=decpart-procnum*i;
   strrealloc(partstr2,len2);
   (partstr2+len2-1)^:=(numchar+i)^;
   if(i>=10) or (procnum<=1) then break;
  end;
 if(len2>0) then size:=len1+len2+2 else size:=len1+1;
 if(isnegative) then
  begin
   if(havedecimal) then
    begin
     strinit(res,1+len1+1+reserveddecimal);
     strset(res,'-');
     strcat(res,partstr1);
     strcat(res,'.');
     for i:=1 to reserveddecimal-len2 do strcat(res,'0');
     strcat(res,partstr2);
    end
   else
    begin
     strinit(res,1+len1);
     strset(res,'-');
     strcat(res,partstr1);
    end;
  end
 else
  begin
   if(havedecimal) then
    begin
     strinit(res,len1+1+reserveddecimal);
     strset(res,partstr1);
     strcat(res,'.');
     for i:=1 to reserveddecimal-len2 do strcat(res,'0');
     strcat(res,partstr2);
    end
   else
    begin
     strinit(res,len1);
     strset(res,partstr1);
    end;
  end;
 if(havedecimal) then strfree(partstr2);
 strfree(partstr1);
 res:=res-size;
 ExtendedToPChar:=res;
end; 
function ExtendedToPWChar(num:Extended;Reserveddecimal:byte):PWideChar;[public,alias:'ExtendedToPWChar'];
const numchar:PWideChar='0123456789';
var orgnum,intpart,decpart,procnum:extended;
    partstr1,partstr2,res:PWideChar;
    isnegative,havedecimal:boolean;
    len1,len2,i,size:natuint;
begin
 if(num>0) then
  begin
   orgnum:=num; isnegative:=false;
  end
 else
  begin
   orgnum:=-num; isnegative:=true;
  end;
 intpart:=orgnum-frac(orgnum); decpart:=frac(orgnum)*ExtendedPower(10,Reserveddecimal);
 partstr1:=nil; partstr2:=nil;
 len1:=0; len2:=0;
 if(decpart=0) then havedecimal:=false else havedecimal:=true;
 procnum:=1;
 while(procnum<=intpart) do
  begin
   procnum:=procnum*10;
  end;
 while(intpart>0) do
  begin
   inc(len1);
   if(procnum>1) then procnum:=procnum/10;
   i:=0;
   while(i<=9) do
    begin
     if(intpart>=procnum*i) and (intpart<procnum*(i+1)) then break;
     inc(i);
    end;
   intpart:=intpart-procnum*i;
   Wstrrealloc(partstr1,len1);
   (partstr1+len1-1)^:=(numchar+i)^;
   if(i>=10) or (procnum<=1) then break;
  end;
 procnum:=1;
 while(procnum<=decpart) do
  begin
   procnum:=procnum*10;
  end;
 while(decpart>0) do
  begin
   inc(len2);
   if(procnum>1) then procnum:=procnum/10;
   i:=0;
   while(i<=9) do
    begin
     if(decpart>=procnum*i) and (decpart<procnum*(i+1)) then break;
     inc(i);
    end;
   decpart:=decpart-procnum*i;
   Wstrrealloc(partstr2,len2);
   (partstr2+len2-1)^:=(numchar+i)^;
   if(i>=10) or (procnum<=1) then break;
  end;
 if(len2>0) then size:=len1+len2+2 else size:=len1+1;
 if(isnegative) then
  begin
   if(havedecimal) then
    begin
     Wstrinit(res,1+len1+1+reserveddecimal);
     Wstrset(res,'-');
     Wstrcat(res,partstr1);
     Wstrcat(res,'.');
     for i:=1 to reserveddecimal-len2 do Wstrcat(res,'0');
     Wstrcat(res,partstr2);
    end
   else
    begin
     Wstrinit(res,1+len1);
     Wstrset(res,'-');
     Wstrcat(res,partstr1);
    end;
  end
 else
  begin
   if(havedecimal) then
    begin
     Wstrinit(res,len1+1+reserveddecimal);
     Wstrset(res,partstr1);
     Wstrcat(res,'.');
     for i:=1 to reserveddecimal-len2 do Wstrcat(res,'0');
     Wstrcat(res,partstr2);
    end
   else
    begin
     Wstrinit(res,len1);
     Wstrset(res,partstr1);
    end;
  end;
 if(havedecimal) then Wstrfree(partstr2);
 Wstrfree(partstr1);
 res:=res-size;
 ExtendedToPWChar:=res;
end;  
function PCharToExtended(str:PChar):extended;[public,alias:'PCharToExtended'];
const numchar:PChar='0123456789';
var intpart,decpart:extended;
    position,startx,i,j,len:natuint;
begin
 position:=strpos(str,'.',1);
 if(str^='-') then startx:=2 else startx:=1;
 len:=Strlen(str); intpart:=0; decpart:=0;
 if(position>0) then
  begin
   for i:=startx to position-1 do
    begin
     j:=0;
     while(j<=9) do if((str+i-1)^=(numchar+j)^) then break;
     intpart:=intpart*10+j;
    end;
   for i:=position+1 to len do
    begin
     j:=0;
     while(j<=9) do if((str+i-1)^=(numchar+j)^) then break;
     decpart:=decpart*10+j;
    end;
  end
 else
  begin
   for i:=startx to len do
    begin
     j:=0;
     while(j<=9) do if((str+i-1)^=(numchar+j)^) then break;
     intpart:=intpart*10+j;
    end;
  end;
 if(startx=2) then
  begin
   PCharToExtended:=intpart+decpart/ExtendedPower(10,len-position);
  end
 else if(startx=1) then
  begin
   PCharToExtended:=intpart+decpart/ExtendedPower(10,len-position);
  end;
end; 
function PWCharToExtended(str:PWideChar):extended;[public,alias:'PWCharToExtended'];
const numchar:PWideChar='0123456789';
var intpart,decpart:extended;
    position,startx,i,j,len:natuint;
begin
 position:=Wstrpos(str,'.',1);
 if(str^='-') then startx:=2 else startx:=1;
 len:=WStrlen(str); intpart:=0; decpart:=0;
 if(position>0) then
  begin
   for i:=startx to position-1 do
    begin
     j:=0;
     while(j<=9) do if((str+i-1)^=(numchar+j)^) then break;
     intpart:=intpart*10+j;
    end;
   for i:=position+1 to len do
    begin
     j:=0;
     while(j<=9) do if((str+i-1)^=(numchar+j)^) then break;
     decpart:=decpart*10+j;
    end;
  end
 else
  begin
   for i:=startx to len do
    begin
     j:=0;
     while(j<=9) do if((str+i-1)^=(numchar+j)^) then break;
     intpart:=intpart*10+j;
    end;
  end;
 if(startx=2) then
  begin
   PWCharToExtended:=intpart+decpart/ExtendedPower(10,len-position);
  end
 else if(startx=1) then
  begin
   PWCharToExtended:=intpart+decpart/ExtendedPower(10,len-position);
  end;
end; 
function IntPower(a:natint;b:natuint):natint;[public,alias:'IntPower'];
var i:natuint;
    res:natint;
begin
 res:=1;
 for i:=1 to b do
  begin
   res:=res*a;
  end;
 intPower:=res;
end;
function UIntPower(a,b:natuint):natuint;[public,alias:'UintPower'];
var res,i:natuint;
begin
 res:=1;
 for i:=1 to b do
  begin
   res:=res*a;
  end;
 UintPower:=res;
end;
function ExtendedPower(a:extended;b:natuint):extended;[public,alias:'ExtendedPower'];
var res:extended;
    i:natuint;
begin
 res:=1;
 for i:=1 to b do
  begin
   res:=res*a;
  end;
 ExtendedPower:=res;
end;
function UintToHex(inputint:natuint):Pchar;[public,alias:'UintToHex'];
const hexcode:PChar='0123456789ABCDEF';
var i,j,k,procint,procnum:natuint;
    str:PChar;
begin
 i:=0; procint:=inputint; procnum:=1;
 while(optimize_integer_divide(procint,procnum)>=16) do 
  begin
   procnum:=procnum*16;
   inc(i);
  end;
 strinit(str,i+1);
 for j:=i+1 downto 1 do
  begin 
   (str+j-1)^:=(hexcode+procint mod 16)^;
   procint:=procint div 16;
  end;
 (str+i+1)^:=#0;
 UintToHex:=str;
end;
function UintToWhex(inputint:natuint):PWideChar;[public,alias:'UintToWHex'];
const hexcode:PWideChar='0123456789ABCDEF';
var i,j,k,procint,procnum:natuint;
    str:PWideChar;
begin
 i:=0; procint:=inputint; procnum:=1;
 while(optimize_integer_divide(procint,procnum)>=16) do 
  begin
   procnum:=procnum*16;
   inc(i);
  end;
 Wstrinit(str,i+1);
 for j:=i+1 downto 1 do
  begin 
   (str+j-1)^:=(hexcode+procint mod 16)^;
   procint:=procint div 16;
  end;
 (str+i+1)^:=#0;
 UintToWHex:=str;
end;
function HexToUint(inputhex:PChar):natuint;[public,alias:'HexToUint'];
const hexcode1:PChar='0123456789ABCDEF';
      hexcode2:PChar='0123456789abcdef';
var res,i,j:natuint;
begin
 i:=1; res:=0;
 while((inputhex+i-1)^<>#0) do
  begin
   j:=0;
   while(j<=15) and ((inputhex+i-1)^<>(hexcode1+j)^) and ((inputhex+i-1)^<>(hexcode2+j)^) do inc(j);
   res:=res*16+j;
  end;
 HexToUint:=res;
end;
function WHexToUint(inputhex:PWideChar):natuint;[public,alias:'WHexToUint'];
const hexcode1:PWideChar='0123456789ABCDEF';
      hexcode2:PWideChar='0123456789abcdef';
var res,i,j:natuint;
begin
 i:=1; res:=0;
 while((inputhex+i-1)^<>#0) do
  begin
   j:=0;
   while(j<=15) and ((inputhex+i-1)^<>(hexcode1+j)^) and ((inputhex+i-1)^<>(hexcode2+j)^) do inc(j);
   res:=res*16+j;
  end;
 WHexToUint:=res;
end;
function PChar_encrypt_to_passwd(oristr:PChar):PChar;[public,alias:'PChar_encrypt_to_passwd'];
var i,index,len:natuint;
    res:PChar;
begin
 i:=0; len:=strlen(oristr);
 strinit(res,len*2);
 while(i<len) do
  begin 
   inc(i);
   index:=(Byte((oristr+i-1)^)+mypwdoffset[i mod 24+1]+256) mod 256;
   (res+i*2-2)^:=Char(Byte((mypwd+index*2)^)+128);
   (res+i*2-1)^:=Char(Byte((mypwd+index*2+1)^)+128);
  end;
 (res+len*2)^:=#0;
 PChar_encrypt_to_passwd:=res;
end;
function PWChar_encrypt_to_passwd(oristr:PWideChar):PChar;[public,alias:'PWChar_encrypt_to_passwd'];
var i,index,len:natuint;
    res:PChar;
begin
 i:=0; len:=Wstrlen(oristr);
 strinit(res,len*4);
 while(i<len) do
  begin 
   inc(i);
   index:=(Word((oristr+i-1)^)+mypwdoffset[i mod 24+1]+65536) mod 65536;
   (res+i*4-4)^:=Char(Byte((mypwd+index div 256*2)^)+128);
   (res+i*4-3)^:=Char(Byte((mypwd+index div 256*2+1)^)+128);
   (res+i*4-2)^:=Char(Byte((mypwd+index mod 256*2)^)+128);
   (res+i*4-1)^:=Char(Byte((mypwd+index mod 256*2+1)^)+128);
  end;
 (res+len*4)^:=#0;
 PWChar_encrypt_to_passwd:=res;
end;
function Passwd_decrypt_to_PChar(passwdstr:PChar):PChar;[public,alias:'Passwd_decrypt_to_PChar'];
var i,j,index,len:natuint;
    res,partstr,partstr2:PChar;
begin
 i:=0; len:=strlen(passwdstr) div 2;
 strinit(res,len);
 while(i<len) do
  begin
   inc(i);
   partstr:=StrCopy(passwdstr,i*2-1,2);
   j:=1;
   while(j<=256) do
    begin
     partstr2:=StrCopy(mypwd,j*2-1,2);
     partstr2^:=Char(Byte(partstr2^)-128);
     (partstr2+1)^:=Char(Byte((partstr2+1)^)-128);
     if(StrCmp(partstr,partstr2)=0) then break;
     Strfree(partstr2);
     inc(j,1);
    end;
   if(j>256) then break;
   if(partstr2<>nil) then Strfree(partstr2);
   (res+i-1)^:=Char((j-1-mypwdoffset[i mod 24+1]+256) mod 256);
   Strfree(partstr);
  end;
 (res+len)^:=#0;
 Passwd_decrypt_to_PChar:=res;
end;
function Passwd_decrypt_to_PWChar(passwdstr:PChar):PWideChar;[public,alias:'Passwd_decrypt_to_PWChar'];
var i,j,k,index,len:natuint;
    res:PWideChar;
    partstr,partstr2:PChar;
begin
 i:=0; len:=strlen(passwdstr) div 4;
 Wstrinit(res,len);
 while(i<len) do
  begin
   inc(i);
   partstr:=StrCopy(passwdstr,i*4-3,4);
   j:=1;
   while(j<=256) do
    begin
     partstr2:=StrCopy(mypwd,j*2-1,2);
     partstr2^:=Char(Byte(partstr2^)-128);
     (partstr2+1)^:=Char(Byte((partstr2+1)^)-128);
     if(StrCmp(StrCopy(partstr,1,2),partstr2)=0) then break;
     Strfree(partstr2);
     inc(j,1);
    end;
   if(j>256) then break;
   if(partstr2<>nil) then Strfree(partstr2);
   k:=1;
   while(k<=256) do
    begin
     partstr2:=StrCopy(mypwd,k*2-1,2);
     partstr2^:=Char(Byte(partstr2^)-128);
     (partstr2+1)^:=Char(Byte((partstr2+1)^)-128);
     if(StrCmp(StrCopy(partstr,3,2),partstr2)=0) then break;
     Strfree(partstr2);
     inc(k,1);
    end;
   if(k>256) then break;
   if(partstr2<>nil) then Strfree(partstr2);
   (res+i-1)^:=WideChar(((j-1)*256+k-1-mypwdoffset[i mod 24+1]+65536) mod 65536);
   Strfree(partstr);
  end;
 (res+len)^:=#0;
 Passwd_decrypt_to_PWChar:=res;
end;
function PCharToPWChar(orgstr:PChar):PWideChar;[public,alias:'PCharToPWChar'];
var res:PWideChar;
    len,i:natuint;
begin
  len:=strlen(orgstr); i:=1;
  Wstrinit(res,len);
  while(i<=len+1) do
   begin
    (res+i-1)^:=WideChar(Word((orgstr+i-1)^)); inc(i);
   end;
  PCharToPWChar:=res;
end;
function PWCharToPChar(orgstr:PWideChar):PChar;[public,alias:'PWCharToPChar'];
var res:PChar;
    len,i:natuint;
begin
  len:=Wstrlen(orgstr); i:=1;
  strinit(res,len);
  while(i<=len+1) do
   begin
    (res+i-1)^:=Char(Byte((orgstr+i-1)^)); inc(i);
   end;
  PWCharToPChar:=res;
end;
function PCharIsInt(str:PChar):boolean;[public,alias:'PCharIsInt'];
const numchar:PChar='0123456789';
var i,j,len:natuint;
begin
 len:=strlen(str);
 for i:=1 to len do
  begin
   j:=0;
   while(j<=9) do if((str+i-1)^=(numchar+j)^) then break else inc(j);
   if(j>9) then break;
  end;
 if(j>9) then PCharIsInt:=false else PCharIsInt:=true;
end;
function PWCharIsInt(str:PWideChar):boolean;[public,alias:'PWCharIsInt'];
const numchar:PWideChar='0123456789';
var i,j,len:natuint;
begin
 len:=Wstrlen(str);
 for i:=1 to len do
  begin
   j:=0;
   while(j<=9) do if((str+i-1)^=(numchar+j)^) then break else inc(j);
   if(j>9) then break;
  end;
 if(j>9) then PWCharIsInt:=false else PWCharIsInt:=true;
end;
function PCharMatchMask(orgstr,maskstr:PChar):boolean;[public,alias:'PCharMatchMask'];
var i,j,k,len1,len2:natuint;
begin
 len1:=strlen(orgstr); len2:=strlen(maskstr); i:=1; j:=1;
 while(i<=len1) and (j<=len2) do
  begin
   if((maskstr+j-1)^='*') then
    begin
     if((maskstr+j)^='*') then
      begin
       inc(j); inc(i);
      end
     else
      begin
       k:=i+1;
       while(k<=len1) do
        begin
         if((maskstr+j)^=(orgstr+k-1)^) then break;
         inc(k);
        end;
       if(k>len1) then break else
        begin
         i:=k; inc(j);
        end;
      end;
    end
   else if((maskstr+j-1)^='?') then
    begin
     inc(j); inc(i);
    end
   else if((maskstr+j-1)^=(orgstr+i-1)^) then
    begin
     inc(j); inc(i);
    end
   else break;
  end;
 if(i<=len1) and (j<=len2) then PCharMatchMask:=false else PCharMatchMask:=true;
end;
function PWCharMatchMask(orgstr,maskstr:PWideChar):boolean;[public,alias:'PWCharMatchMask'];
var i,j,k,len1,len2:natuint;
begin
 len1:=Wstrlen(orgstr); len2:=Wstrlen(maskstr); i:=1; j:=1;
 while(i<=len1) and (j<=len2) do
  begin
   if((maskstr+j-1)^='*') then
    begin
     if((maskstr+j)^='*') then
      begin
       inc(j); inc(i);
      end
     else
      begin
       k:=i+1;
       while(k<=len1) do
        begin
         if((maskstr+j)^=(orgstr+k-1)^) then break;
         inc(k);
        end;
       if(k>len1) then break else
        begin
         i:=k; inc(j);
        end;
      end;
    end
   else if((maskstr+j-1)^='?') then
    begin
     inc(j); inc(i);
    end
   else if((maskstr+j-1)^=(orgstr+i-1)^) then
    begin
     inc(j); inc(i);
    end
   else break;
  end;
 if(i<=len1) and (j<=len2) then PWCharMatchMask:=false else PWCharMatchMask:=true;
end;
function PCharGetWildcard(orgstr,maskstr:PChar):maskwildcard;[public,alias:'PCharGetWildcard'];
var res:maskwildcard;
    i,j,k,m,len1,len2,spos,slen,size:natuint;
begin
 res.liststr:=nil; res.listcount:=0;
 len1:=strlen(orgstr); len2:=strlen(maskstr); i:=1; j:=1;
 while(i<=len1) and (j<=len2) do
  begin
   if((maskstr+j-1)^='*') then
    begin
     inc(res.listcount);
     size:=getmemsize(res.liststr);
     ReallocMem(res.liststr,sizeof(PChar)*res.listcount);
     res.listlen:=Pointer(Pointer(res.listlen)-size);
     size:=size+getmemsize(res.listlen);
     ReallocMem(res.listlen,sizeof(natuint)*res.listcount);
     res.listpos:=Pointer(Pointer(res.listpos)-size);
     size:=size+getmemsize(res.listpos);
     ReallocMem(res.listpos,sizeof(natuint)*res.listcount);
     for m:=1 to res.listcount-1 do (res.liststr+m-1)^:=PChar(Pointer((res.liststr+m-1)^)-size);
     k:=j+1; spos:=i; slen:=0;
     while((maskstr+k-1)^='*') do inc(k);
     while((orgstr+spos+slen-1)^<>(maskstr+k-1)^) and (spos+slen<=len1) do inc(slen);
     if(k>len1) then
      begin
       dec(res.listcount);
       size:=getmemsize(res.liststr);
       ReallocMem(res.liststr,sizeof(PChar)*res.listcount);
       for m:=1 to res.listcount do (res.liststr+m-1)^:=PChar(Pointer((res.liststr+m-1)^)-size);
       break;
      end;
     (res.liststr+res.listcount-1)^:=strcopy(orgstr,spos,slen);
     (res.listlen+res.listcount-1)^:=spos;
     (res.listpos+res.listcount-1)^:=k-j;
     i:=spos+slen; j:=k;
    end
   else if((maskstr+j-1)^='?') then
    begin
     inc(res.listcount);
     size:=getmemsize(res.liststr);
     ReallocMem(res.liststr,sizeof(PChar)*res.listcount);
     res.listlen:=Pointer(Pointer(res.listlen)-size);
     size:=size+getmemsize(res.listlen);
     ReallocMem(res.listlen,sizeof(natuint)*res.listcount);
     res.listpos:=Pointer(Pointer(res.listpos)-size);
     size:=size+getmemsize(res.listpos);
     ReallocMem(res.listpos,sizeof(natuint)*res.listcount);
     for m:=1 to res.listcount-1 do (res.liststr+m-1)^:=PChar(Pointer((res.liststr+m-1)^)-size);
     k:=j+1; spos:=i; slen:=1;
     while((maskstr+k+slen-1)^='?') do inc(slen);
     (res.liststr+res.listcount-1)^:=strcopy(orgstr,spos,slen);
     (res.listlen+res.listcount-1)^:=spos;
     (res.listpos+res.listcount-1)^:=slen;
     i:=spos+slen; j:=k;
    end
   else if((maskstr+j-1)^=(orgstr+i-1)^) then
    begin
     inc(i); inc(j);
    end
   else break;
  end;
 if(i<=len1) and (j<=len2) then
  begin
   res.liststr:=nil; res.listcount:=0;
  end;
 PCharGetWildCard:=res;
end;
function PWCharGetWildcard(orgstr,maskstr:PWideChar):Wmaskwildcard;[public,alias:'PWCharGetWildcard'];
var res:Wmaskwildcard;
    i,j,k,m,len1,len2,spos,slen,size,size2:natuint;
begin
 res.liststr:=nil; res.listcount:=0;
 len1:=Wstrlen(orgstr); len2:=Wstrlen(maskstr); i:=1; j:=1;
 while(i<=len1) and (j<=len2) do
  begin
   if((maskstr+j-1)^='*') then
    begin
     inc(res.listcount);
     size:=getmemsize(res.liststr);
     ReallocMem(res.liststr,sizeof(PWideChar)*res.listcount);
     res.listlen:=Pointer(Pointer(res.listlen)-size);
     size:=size+getmemsize(res.listlen);
     ReallocMem(res.listlen,sizeof(natuint)*res.listcount);
     res.listpos:=Pointer(Pointer(res.listpos)-size);
     size:=size+getmemsize(res.listpos);
     ReallocMem(res.listpos,sizeof(natuint)*res.listcount);
     for m:=1 to res.listcount-1 do (res.liststr+m-1)^:=PWideChar(Pointer((res.liststr+m-1)^)-size);
     k:=j+1; spos:=i; slen:=0;
     while((maskstr+k-1)^='*') do inc(k);
     while((orgstr+spos+slen-1)^<>(maskstr+k-1)^) and (spos+slen<=len1) do inc(slen);
     if(k>len1) then
      begin
       dec(res.listcount);
       size:=getmemsize(res.liststr);
       ReallocMem(res.liststr,sizeof(PWideChar)*res.listcount);
       for m:=1 to res.listcount do (res.liststr+m-1)^:=PWideChar(Pointer((res.liststr+m-1)^)-size);
       break;
      end;
     (res.liststr+res.listcount-1)^:=Wstrcopy(orgstr,spos,slen);
     (res.listlen+res.listcount-1)^:=spos;
     (res.listpos+res.listcount-1)^:=k-j;
     i:=spos+slen; j:=k;
    end
   else if((maskstr+j-1)^='?') then
    begin
     inc(res.listcount);
     size:=getmemsize(res.liststr);
     ReallocMem(res.liststr,sizeof(PWideChar)*res.listcount);
     res.listlen:=Pointer(Pointer(res.listlen)-size);
     size:=size+getmemsize(res.listlen);
     ReallocMem(res.listlen,sizeof(natuint)*res.listcount);
     res.listpos:=Pointer(Pointer(res.listpos)-size);
     size:=size+getmemsize(res.listpos);
     ReallocMem(res.listpos,sizeof(natuint)*res.listcount);
     for m:=1 to res.listcount-1 do (res.liststr+m-1)^:=PWideChar(Pointer((res.liststr+m-1)^)-size);
     k:=j+1; spos:=i; slen:=1;
     while((maskstr+k+slen-1)^='?') do inc(slen);
     (res.liststr+res.listcount-1)^:=Wstrcopy(orgstr,spos,slen);
     (res.listlen+res.listcount-1)^:=spos;
     (res.listpos+res.listcount-1)^:=slen;
     i:=spos+slen; j:=k;
    end
   else if((maskstr+j-1)^=(orgstr+i-1)^) then
    begin
     inc(i); inc(j);
    end
   else break;
  end;
 if(i<=len1) and (j<=len2) then
  begin
   res.liststr:=nil; res.listcount:=0;
  end;
 PWCharGetWildCard:=res;
end; 
function Neighborlinegenerate(originalstr,linestr:PWideChar;row:natuint;mcolumn:natuint):neighborline;[public,alias:'Neighborlinegenerate'];
var res:neighborline;
    mypos,mylen:^natuint;
    mycount,istart,iend,i,j:natuint;
    pos1,pos2,pos3,mylen1,mylen2,mysize1,mysize2:natuint;
begin
 mylen1:=Wstrlen(originalstr); mylen2:=Wstrlen(linestr);
 if(mylen1=0) or (mylen2=0) then pos2:=0 else pos2:=1; pos1:=1;
 if(pos2=0) then exit;
 mypos:=allocmem(sizeof(natuint)); mylen:=allocmem(sizeof(natuint)); mycount:=0;
 while(pos2>0) do
  begin
   pos2:=Wstrpos(originalstr,linestr,pos1);
   if(pos2=0) then pos3:=mylen1+1 else pos3:=pos2;
   if(pos3-pos1>mcolumn) then
    begin
     j:=pos1;
     while(j<pos3) do
      begin
       inc(mycount);
       mysize1:=getmemsize(mypos);
       mylen:=mylen-mysize1 div sizeof(natuint);
       ReallocMem(mypos,sizeof(natuint)*mycount); 
       mysize2:=getmemsize(mylen);
       mypos:=mypos-mysize2 div sizeof(natuint);
       ReallocMem(mylen,sizeof(natuint)*mycount);
       (mypos+mycount-1)^:=j; (mypos+mycount-1)^:=j+mcolumn-1;
       if(j+mcolumn-1>=pos3-1) then (mypos+mycount-1)^:=pos3-1;
       inc(j,mcolumn);
      end;
    end
   else 
    begin
     inc(mycount);
     mysize1:=getmemsize(mypos);
     mylen:=mylen-mysize1 div sizeof(natuint);
     ReallocMem(mypos,sizeof(natuint)*mycount); 
     mysize2:=getmemsize(mylen);
     mypos:=mypos-mysize2 div sizeof(natuint);
     ReallocMem(mylen,sizeof(natuint)*mycount);
     (mypos+mycount-1)^:=pos1; (mylen+mycount-1)^:=pos3-pos1;
    end;
   if(pos2>0) then pos1:=pos2+mylen2 else break;
  end;
 if(row=1) then
  begin
   istart:=1; 
   if(mycount>2) then iend:=2 else iend:=mycount;
   res.linestatus:=0;
  end
 else if(row=mycount) then
  begin
   if(mycount>2) then istart:=mycount-1 else istart:=1; 
   iend:=mycount;
   res.linestatus:=1;
  end
 else
  begin
   istart:=row-1;
   iend:=row+1;
   res.linestatus:=2;
  end;
 res.linelen:=iend-istart+1;
 for i:=istart to iend do
  begin
   j:=i-istart+1;
   res.lineslen[j]:=(mylen+i-1)^;
   res.linepos[j]:=(mypos+i-1)^;
  end;
 freemem(mylen); freemem(mypos); 
 Neighborlinegenerate:=res;
end;
function TotalLineList(originalstr,linefeed:PWideChar;mcolumn:natuint):linelist;[public,alias:'TotalLineList'];
var pos1,pos2,pos3,mylen1,mylen2,i,mysize:natuint;
    res:linelist;
begin
 pos1:=1; pos2:=2; pos3:=pos2; res.linecount:=0; res.lineleft:=allocmem(sizeof(natuint)); res.lineright:=allocmem(sizeof(natuint));
 mylen1:=Wstrlen(originalstr); mylen2:=Wstrlen(linefeed);
 while(pos2>0) do
  begin
   pos2:=Wstrpos(originalstr,linefeed,pos1);
   if(pos2=0) then pos3:=mylen1+1 else pos3:=pos2;
   if(pos3-pos1>mcolumn) then
    begin
     i:=pos1;
     while(i<pos3) do
      begin
       inc(res.linecount);
       mysize:=getmemsize(res.lineleft);
       res.lineright:=res.lineright-mysize div sizeof(natuint);
       ReallocMem(res.lineleft,res.linecount*sizeof(natuint)); 
       mysize:=getmemsize(res.lineright);
       res.lineleft:=res.lineleft-mysize div sizeof(natuint);
       ReallocMem(res.lineright,res.linecount*sizeof(natuint));
       if(i+mcolumn-1<pos3) then
        begin
         (res.lineleft+res.linecount-1)^:=i; (res.lineright+res.linecount-1)^:=i+mcolumn-1;
        end
       else 
        begin
         (res.lineleft+res.linecount-1)^:=i; (res.lineright+res.linecount-1)^:=pos3-1;
        end;
       inc(i,mcolumn);
      end;
    end
   else 
    begin
     inc(res.linecount);
     mysize:=getmemsize(res.lineleft);
     res.lineright:=res.lineright-mysize div sizeof(natuint);
     ReallocMem(res.lineleft,res.linecount*sizeof(natuint)); 
     mysize:=getmemsize(res.lineright);
     res.lineleft:=res.lineleft-mysize div sizeof(natuint);
     ReallocMem(res.lineright,res.linecount*sizeof(natuint));
     (res.lineleft+res.linecount-1)^:=pos1; (res.lineright+res.linecount-1)^:=pos3-1;
    end;
   if(pos2>0) then pos1:=pos2+mylen2 else break;
  end;
 TotalLineList:=res;
end;

end.
