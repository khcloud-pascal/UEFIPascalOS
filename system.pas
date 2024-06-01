unit system;
{$MODE FPC}

{$POINTERMATH ON}
interface

{$IFDEF CPU32}
const maxheap=16777216*8;
      maxsection=16384*64;
{$ELSE CPU32}
const maxheap=67108864*8;
      maxsection=65536*64;
{$ENDIF CPU32}
type
  hresult = LongInt;
  Char = #0..#255;
  DWord = LongWord;
  Cardinal = LongWord;
  Integer = SmallInt;
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
  {$IFDEF CPU32}
  NatUint=dword;
  PNatUint=^dword;
  Natint=integer;
  PNatint=^integer;
  {$ELSE CPU32}
  NatUint=qword;
  PNatUint=^qword;
  Natint=int64;
  PNatint=^int64;
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
  systemheap=record
	   heapcontent:array[1..maxheap] of byte;
	   heapsection:array[1..maxsection,1..2] of natuint;
	   heapcount,heaprest:natuint;
           end;
  neighborline=record
               lineslen:array[1..3] of natuint;
               linepos:array[1..3] of natuint;
               linelen:byte;
               linestatus:byte;
               end;
  linelist=record
           lineleft:^natuint;
           lineright:^natuint;
           linecount:natuint;
           end;
const mypwd:PChar='PHjueigbEYywLCQiCYRQGleDMUjOceLMBFDMJHEMUzgCleRgkKEnAuVLtSAEFSFhevpEKomPHIbaqxLLGJVMRmZUDFKnvHGfvTwYEOqVaBxEGXMXXuITZixUcMbdTCfWIwysKPSciOnUHgmePRWEWWcNMuePEbGOvNgNbqdMMRlzbocTikuCuQuISgQTWFtVSLUmAObgipXAnNEdUNXKVFBiNTIOornretCNOaEwhQTdIRlYaldWzFiummYKKJJcnDRJovDJTFXpQczJQBDnATyvopuBakmGKXTDsIhKfKNITJlsDkLTlKRKfObLvwpIgXvqmBmiWLKQlhqMyAcUoFxkFNPYeGFCduhGJTNtSMfvbGuupWzugWNrwwZKkwjfIqIdjXMAiVONPcMebzSCvUGtVblwohLzOhlnPKIQBTxpBYufIJesKHeZPUHiYaofkTEDcpRapVwluKFARevxkgjxuEFHgVEuQtAUFMMTszCgrqcuKFnJiZtmDBmYsatb';
mypwdoffset:array[1..24] of shortint=(-1,-3,-6,-8,-7,-4,-5,-2,0,8,9,10,12,2,3,4,1,9,-9,3,-11,-12,10,-7);
procedure fpc_handleerror;compilerproc;
procedure fpc_lib_exit;compilerproc;
procedure fpc_libinitializeunits;compilerproc;
procedure fpc_initializeunits;compilerproc;
procedure fpc_finalizeunits;compilerproc;
procedure fpc_do_exit;compilerproc;
function sys_getmem(size:natuint):Pointer;compilerproc;
procedure sys_freemem(var p:pointer);compilerproc;
function sys_allocmem(size:natuint):Pointer;compilerproc;
procedure sys_reallocmem(var p:Pointer;size:natuint);compilerproc;
procedure sys_move(const source;var dest;count:natuint);compilerproc;
function getmem(size:natuint):Pointer;
procedure freemem(var p:pointer);
function allocmem(size:natuint):Pointer;
function getmemsize(p:Pointer):natuint;
procedure reallocmem(var p:Pointer;size:natuint);
procedure move(const source;var dest;count:natuint);
procedure sysheap_clear_all;
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
procedure strcat(var dest:PChar;src:PChar);
procedure Wstrcat(var dest:PWideChar;src:PWideChar);
procedure strfree(var str:PChar);
procedure Wstrfree(var str:PWideChar);
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
function DataToHex(Data:Pointer;Size:Natuint):PWideChar;
function UIntPower(a,b:natuint):natuint;
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
function Neighborlinegenerate(originalstr,linestr:PWideChar;row:natuint;mcolumn:natuint):neighborline;
function TotalLineList(originalstr,linefeed:PWideChar;mcolumn:natuint):linelist;

var compheap,sysheap:systemheap;
implementation
procedure fpc_handleerror;compilerproc;[public,alias:'FPC_HANDLEERROR'];
begin
 while (True) do;
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
function sys_getmem(size:natuint):Pointer;compilerproc;[public,alias:'FPC_GETMEM'];
var i,istart,cstart:natuint;
begin
 if(compheap.heapcount>=maxsection) then sys_getmem:=nil;
 if(compheap.heaprest<size) then sys_getmem:=nil;
 if(size=0) then sys_getmem:=nil;
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
 sys_getmem:=Pointer(compheap.heapsection[compheap.heapcount,1]);
end;
procedure sys_freemem(var p:pointer);compilerproc;[public,alias:'FPC_FREEMEM'];
begin
 compheap_delete_item(p); p:=nil;
end;
function sys_allocmem(size:natuint):Pointer;compilerproc;[public,alias:'FPC_ALLOCMEM'];
var i,istart,cstart:natuint;
begin
 if(compheap.heapcount>=maxsection) then sys_allocmem:=nil;
 if(compheap.heaprest<size) then sys_allocmem:=nil;
 if(size=0) then sys_allocmem:=nil;
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
 sys_allocmem:=Pointer(compheap.heapsection[compheap.heapcount,1]);
end;
procedure sys_reallocmem(var p:Pointer;size:natuint);compilerproc;[public,alias:'FPC_REALLOCMEM'];
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
procedure sys_move(const source;var dest;count:natuint);compilerproc;[public,alias:'FPC_MOVE'];
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
 if(sysheap.heapcount>=maxsection) then getmem:=nil;
 if(sysheap.heaprest<size) then getmem:=nil;
 if(size=0) then getmem:=nil;
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
 sysheap_delete_item(p); p:=nil;
end;
function allocmem(size:natuint):Pointer;[public,alias:'allocmem'];
var i,istart,cstart:natuint;
begin
 if(sysheap.heapcount>=maxsection) then allocmem:=nil;
 if(sysheap.heaprest<size) then allocmem:=nil;
 if(size=0) then allocmem:=nil;
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
 if(p=nil) then
  begin
   p:=allocmem(size); exit;
  end;
 newp:=getmem(size);
 i:=1;
 while(i<=sysheap.heapcount) do
  begin
   if(NatUint(p)>=sysheap.heapsection[i,1]) and (NatUint(p)<=sysheap.heapsection[i,2]) then break;
   inc(i);
  end;
 if(i>sysheap.heapcount) then 
  begin
   p:=allocmem(size); exit;
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
function strcopy(str:PChar;index,count:Natuint):Pchar;[public,alias:'strcopy'];
var newstr:PChar;
    i:natuint;
begin
 if(index+count-1>strlen(str)) then exit(nil);
 strinit(newstr,count);
 for i:=1 to count do
  begin
   (newstr+i-1)^:=(str+index-1+i-1)^;
  end;
 (newstr+count)^:=#0;
 strcopy:=newstr;
end;
function Wstrcopy(str:PWideChar;index,count:Natuint):PWideChar;[public,alias:'Wstrcopy'];
var newstr:PWideChar;
    i:natuint;
begin
 if(index+count-1>Wstrlen(str)) then exit(nil);
 Wstrinit(newstr,count);
 for i:=1 to count do
  begin
   (newstr+i-1)^:=(str+index-1+i-1)^;
  end;
 (newstr+count)^:=#0;
 Wstrcopy:=newstr;
end;
function strcutout(str:PChar;left,right:Natuint):PChar;[public,alias:'strcutout'];
var newstr:Pchar;
    i,len:natuint;
begin
 len:=strlen(str); 
 if(left>len) or (right>len) or (left>right) then exit(nil);
 strinit(newstr,right-left+1);
 for i:=left to right do
  begin
   (newstr+i-left)^:=(str+i-1)^;
  end;
 (newstr+right-left+1)^:=#0;
 strcutout:=newstr;
end;
function Wstrcutout(str:PWideChar;left,right:Natuint):PWideChar;[public,alias:'Wstrcutout'];
var newstr:PWidechar;
    i,len:natuint;
begin
 len:=Wstrlen(str); 
 if(left>len) or (right>len) or (left>right) then exit(nil);
 Wstrinit(newstr,right-left+1);
 for i:=left to right do
  begin
   (newstr+i-left)^:=(str+i-1)^;
  end;
 (newstr+right-left+1)^:=#0;
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
var i,mylen:natuint;
begin
 mylen:=strlen(str)-strlen(substr)+1;
 if(start>=mylen) then exit(0);
 i:=start;
 while(i<=mylen) do
  begin
   if(strcmp(substr,strcopy(str,i,strlen(substr)))=0) then break;
   inc(i);
  end;
 if(i>mylen) then strpos:=0 else strpos:=i;
end;
function Wstrpos(str,substr:PWideChar;start:natuint):natuint;[public,alias:'Wstrpos'];
var i,mylen:natuint;
begin
 mylen:=Wstrlen(str)-Wstrlen(substr)+1;
 if(start>mylen) then exit(0);
 i:=start;
 while(i<=mylen) do
  begin
   if(Wstrcmp(substr,Wstrcopy(str,i,Wstrlen(substr)))=0) then break;
   inc(i);
  end;
 if(i>mylen) then Wstrpos:=0 else Wstrpos:=i;
end;
function strposdir(str,substr:PChar;start:natuint;direction:shortint):natuint;[public,alias:'strposdir'];
var i,mylen:natuint;
begin
 mylen:=strlen(str)-strlen(substr)+1;
 if(start>mylen) and (direction=1) then exit(0);
 if(start<1) and (direction=-1) then exit(0);
 if(direction=1) then
  begin
   i:=start;
   while(i<=mylen) do 
    begin
     if(strcmp(substr,strcopy(str,i,strlen(substr)))=0) then break;
     inc(i);
    end;
   if(i>mylen) then strposdir:=0 else strposdir:=i;
  end
 else if(direction=-1) then
  begin
   i:=start;
   while(i>=1) do
    begin
     if(strcmp(substr,strcopy(str,i,strlen(substr)))=0) then break;
     dec(i);
    end;
   if(i=0) then strposdir:=0 else strposdir:=i;
  end
 else if(direction=0) then strposdir:=0;
end;
function Wstrposdir(str,substr:PWideChar;start:natuint;direction:shortint):natuint;[public,alias:'Wstrposdir'];
var i,mylen:natuint;
begin
 mylen:=Wstrlen(str)-Wstrlen(substr)+1;
 if(start>mylen) and (direction=1) then exit(0);
 if(start<1) and (direction=-1) then exit(0);
 if(direction=1) then
  begin
   i:=start;
   while(i<=mylen) do 
    begin
     if(Wstrcmp(substr,Wstrcopy(str,i,Wstrlen(substr)))=0) then break;
     inc(i);
    end;
   if(i>mylen) then Wstrposdir:=0 else Wstrposdir:=i;
  end
 else if(direction=-1) then
  begin
   i:=start;
   while(i>=1) do
    begin
     if(Wstrcmp(substr,Wstrcopy(str,i,Wstrlen(substr)))=0) then break;
     dec(i);
    end;
   if(i=0) then Wstrposdir:=0 else Wstrposdir:=i;
  end
 else if(direction=0) then Wstrposdir:=0;
end;
function strposorder(str,substr:PChar;start,order:natuint):natuint;[public,alias:'strposorder'];
var i,forder,mylen:natuint;
begin
 mylen:=strlen(str)-strlen(substr)+1;
 if(start>mylen) then exit(0);
 if(order=0) then exit(0);
 i:=start; forder:=0;
 while(i<=mylen) do
  begin 
   if(strcmp(substr,strcopy(str,i,strlen(substr)))=0) then
    begin
     inc(forder);
     if(forder>=order) then break else inc(i,strlen(substr));
    end
   else inc(i);
  end;
 if(i>mylen) then strposorder:=0 else strposorder:=i;
end;
function Wstrposorder(str,substr:PWideChar;start,order:natuint):natuint;[public,alias:'Wstrposorder'];
var i,forder,mylen:natuint;
begin
 mylen:=Wstrlen(str)-Wstrlen(substr)+1;
 if(start>mylen) then exit(0);
 if(order=0) then exit(0);
 i:=start; forder:=0;
 while(i<=mylen) do
  begin 
   if(Wstrcmp(substr,Wstrcopy(str,i,Wstrlen(substr)))=0) then
    begin
     inc(forder);
     if(forder>=order) then break else inc(i,Wstrlen(substr));
    end
   else inc(i);
  end;
 if(i>mylen) then Wstrposorder:=0 else Wstrposorder:=i;
end;
function strposdirorder(str,substr:PChar;start,order:natuint;direction:shortint):natuint;[public,alias:'strposdirorder'];
var i,forder,mylen:natuint;
begin
 mylen:=strlen(str)-strlen(substr)+1;
 if(start>mylen) and (direction=1) then exit(0);
 if(start<1) and (direction=-1) then exit(0);
 if(direction=0) then exit(0);
 if(order=0) then exit(0);
 i:=start; forder:=0;
 if(direction=1) then
  begin
   while(i<=mylen) do
    begin
     if(strcmp(substr,strcopy(str,i,strlen(substr)))=0) then
      begin
       inc(forder);
       if(forder>=order) then break else inc(i,strlen(substr));
      end
     else inc(i);
    end;
   if(i>mylen) then strposdirorder:=0 else strposdirorder:=i;
  end
 else if(direction=-1) then
  begin
   while(i>=1) do
    begin
     if(strcmp(substr,strcopy(str,i,strlen(substr)))=0) then
      begin
       inc(forder);
       if(forder>=order) then break else dec(i,strlen(substr));
      end
     else dec(i);
    end;
   if(i=0) then strposdirorder:=0 else strposdirorder:=i;
  end;
end;
function Wstrposdirorder(str,substr:PWideChar;start,order:natuint;direction:shortint):natuint;[public,alias:'Wstrposdirorder'];
var i,forder,mylen:natuint;
begin
 mylen:=Wstrlen(str)-Wstrlen(substr)+1;
 if(start>mylen) and (direction=1) then exit(0);
 if(start<1) and (direction=-1) then exit(0);
 if(direction=0) then exit(0);
 if(order=0) then exit(0);
 i:=start; forder:=0;
 if(direction=1) then
  begin
   while(i<=mylen) do
    begin
     if(Wstrcmp(substr,Wstrcopy(str,i,Wstrlen(substr)))=0) then
      begin
       inc(forder);
       if(forder>=order) then break else inc(i,Wstrlen(substr));
      end
     else inc(i);
    end;
   if(i>mylen) then Wstrposdirorder:=0 else Wstrposdirorder:=i;
  end
 else if(direction=-1) then
  begin
   while(i>=1) do
    begin
     if(Wstrcmp(substr,Wstrcopy(str,i,Wstrlen(substr)))=0) then
      begin
       inc(forder);
       if(forder>=order) then break else dec(i,Wstrlen(substr));
      end
     else dec(i);
    end;
   if(i=0) then Wstrposdirorder:=0 else Wstrposdirorder:=i;
  end;
end;
function strcount(str,substr:PChar;start:Natuint):natuint;[public,alias:'strcount'];
var i,len1,len2,res:natuint;
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
   while(i<len1-len2+1) do
    begin
     if(StrCmp(Strcopy(str,i,len2),substr)=0) then 
      begin
       inc(i,len2); inc(res);
      end
     else inc(i);
    end;
  end;
 strcount:=res;
end;
function Wstrcount(str,substr:PWideChar;start:Natuint):natuint;[public,alias:'Wstrcount'];
var i,len1,len2,res:natuint;
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
     if(WStrCmp(WStrcopy(str,i,len2),substr)=0) then 
      begin
       inc(i,len2); inc(res);
      end
     else inc(i);
    end;
  end;
 Wstrcount:=res;
end;
function strposinverse(str,substr:PChar;start:Natuint):Natuint;[public,alias:'strposinverse'];
var i,mylen:natuint;
begin
 mylen:=strlen(str)-strlen(substr)+1; i:=mylen;
 while(i>=start) do
  begin
   if(strcmp(substr,strcopy(str,i,strlen(substr)))=0) then break;
   dec(i);
  end;
 if(i<start) then strposinverse:=0 else strposinverse:=i;
end;
function Wstrposinverse(str,substr:PWideChar;start:natuint):natuint;[public,alias:'Wstrposinverse'];
var i,mylen:natuint;
begin
 mylen:=Wstrlen(str)-Wstrlen(substr)+1; i:=mylen;
 while(i>=start) do
  begin
   if(Wstrcmp(substr,Wstrcopy(str,i,Wstrlen(substr)))=0) then break;
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
 res:=0;
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
 res:=0;
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
function DataToHex(Data:Pointer;Size:Natuint):PWideChar;[public,alias:'DataToHex'];
const hexcode:PWideChar='0123456789ABCDEF';
var highbit,lowbit:byte;
    i:natuint;
    mystr:PWideChar;
begin
 mystr:=allocmem((Size*2+1)*Sizeof(WideChar));
 for i:=1 to Size do
  begin
   highbit:=Byte((Data+i-1)^) div 16;
   lowbit:=Byte((Data+i-1)^) mod 16;
   (mystr+i*2-2)^:=(hexcode+highbit)^;
   (mystr+i*2-1)^:=(hexcode+lowbit)^;
  end;
 DataToHex:=mystr;
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
function UintToHex(inputint:natuint):Pchar;[public,alias:'UintToHex'];
const hexcode:PChar='0123456789ABCDEF';
var i,j,k,procint:natuint;
    str:PChar;
begin
 i:=0; procint:=inputint;
 while(inputint div UintPower(16,i)>=16) do inc(i);
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
var i,j,k,procint:natuint;
    str:PWideChar;
begin
 i:=0; procint:=inputint;
 while(inputint div UintPower(16,i)>=16) do inc(i);
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
begin
 compheap.heapcount:=0; compheap.heaprest:=maxheap;
 sysheap.heapcount:=0; sysheap.heaprest:=maxheap;
end.
