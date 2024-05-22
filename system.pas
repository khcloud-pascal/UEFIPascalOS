unit system;
{$MODE FPC}

{$POINTERMATH ON}
interface
{$IFDEF CPU32}
const maxheap=16777216*8;
      maxsection=16384*16;
{$ELSE CPU32}
const maxheap=67108864*8;
      maxsection=65536*16;
{$ENDIF CPU32}
type
  hresult = LongInt;
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
procedure fpc_initialize(data,info:Pointer);compilerproc;
procedure fpc_finalize(data,Info:Pointer);compilerproc;       
procedure fpc_specific_handler;compilerproc;
function sys_getmem(size:natuint):Pointer;compilerproc;
procedure sys_freemem(var p:pointer);compilerproc;
function sys_allocmem(size:natuint):Pointer;compilerproc;
procedure sys_reallocmem(var p:Pointer;size:natuint);compilerproc;
procedure sys_move(const source;var dest;count:natuint);compilerproc;
function getmem(size:natuint):Pointer;
procedure freemem(var p:pointer);
function allocmem(size:natuint):Pointer;
procedure reallocmem(var p:Pointer;size:natuint);
procedure move(const source;var dest;count:natuint);
function strlen(str:Pchar):natuint;
function wstrlen(str:PWideChar):natuint;
procedure strinit(var str:PChar;size:natuint);
procedure wstrinit(var str:PWideChar;Size:natuint);
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
var compheap,sysheap:systemheap;
implementation
procedure fpc_initialize(Data,Info:Pointer);compilerproc;[public,alias:'FPC_INITIALIZE'];
begin
end;
procedure fpc_finalize(Data,Info:Pointer);compilerproc;[public,alias:'FPC_FINALIZE'];
begin
end;
procedure fpc_specific_handler;compilerproc;[public,alias:'__FPC_specific_handler'];
begin
end;
procedure compheap_delete_item(p:pointer);
var i,j,len:natuint;
begin
 for i:=1 to compheap.heapcount do
  begin
   if(natuint(p)>=compheap.heapsection[i,1]) and (natuint(p)<=compheap.heapsection[i,2]) then break;
  end;
 if(i>compheap.heapcount) then exit;
 len:=compheap.heapsection[i,2]-compheap.heapsection[i,1]+1;
 for j:=i+1 to compheap.heapcount do
  begin
   compheap.heapsection[j-1,1]:=compheap.heapsection[j,1]-len;
   compheap.heapsection[j-1,2]:=compheap.heapsection[j,2]-len;
  end;
 compheap.heapsection[compheap.heapcount,1]:=0;
 compheap.heapsection[compheap.heapcount,2]:=0; 
 dec(compheap.heapcount); inc(compheap.heaprest,len);
end;
function sys_getmem(size:natuint):Pointer;compilerproc;[public,alias:'FPC_GETMEM'];
var i,istart:natuint;
begin
 if(compheap.heapcount>=maxsection) then sys_getmem:=nil;
 if(compheap.heaprest<size) then sys_getmem:=nil;
 if(size=0) then sys_getmem:=nil;
 if(compheap.heapcount>0) then istart:=compheap.heapsection[compheap.heapcount,2]+1 else istart:=Natuint(@compheap.heapcontent);
 inc(compheap.heapcount);
 compheap.heapsection[compheap.heapcount,1]:=istart;
 compheap.heapsection[compheap.heapcount,2]:=istart+size-1;
 for i:=1 to size do
  begin
   compheap.heapcontent[istart+i-1]:=0;
  end;
 dec(compheap.heaprest,size);
 sys_getmem:=Pointer(compheap.heapsection[compheap.heapcount,1]);
end;
procedure sys_freemem(var p:pointer);compilerproc;[public,alias:'FPC_FREEMEM'];
begin
 compheap_delete_item(p); p:=nil;
end;
function sys_allocmem(size:natuint):Pointer;compilerproc;[public,alias:'FPC_ALLOCMEM'];
var i,istart:natuint;
begin
 if(compheap.heapcount>=maxsection) then sys_allocmem:=nil;
 if(compheap.heaprest<size) then sys_allocmem:=nil;
 if(size=0) then sys_allocmem:=nil;
 if(compheap.heapcount>0) then istart:=compheap.heapsection[compheap.heapcount,2]+1 else istart:=NatUint(@compheap.heapcontent);
 inc(compheap.heapcount);
 compheap.heapsection[compheap.heapcount,1]:=istart;
 compheap.heapsection[compheap.heapcount,2]:=istart+size-1;
 for i:=1 to size do
  begin
   compheap.heapcontent[istart+i-1]:=0;
  end;
 dec(compheap.heaprest,size);
 sys_allocmem:=Pointer(compheap.heapsection[compheap.heapcount,1]);
end;
procedure sys_reallocmem(var p:Pointer;size:natuint);compilerproc;[public,alias:'FPC_REALLOCMEM'];
var i,istart,len:Natuint;
    newp:Pointer;
    p1,p2:Pchar;
begin
 if(compheap.heapcount>=maxsection) then exit;
 if(compheap.heaprest<size) then exit;
 if(size=0) then exit;
 if(compheap.heapcount>0) then istart:=compheap.heapsection[compheap.heapcount,2]+1 else istart:=Natuint(@compheap.heapcontent);
 inc(compheap.heapcount);
 compheap.heapsection[compheap.heapcount,1]:=istart;
 compheap.heapsection[compheap.heapcount,2]:=istart+size-1;
 for i:=1 to size do
  begin
   compheap.heapcontent[istart+i-1]:=0;
  end;
 dec(compheap.heaprest,size);
 newp:=Pointer(compheap.heapsection[compheap.heapcount,1]);
 for i:=1 to compheap.heapcount do
  begin
   if(NatUint(p)>=compheap.heapsection[i,1]) and (NatUint(p)<=compheap.heapsection[i,2]) then break;
  end;
 len:=NatUint(p)-compheap.heapsection[i,1];
 p1:=@p^; p2:=@newp^; 
 if(compheap.heapsection[compheap.heapcount,2]-compheap.heapsection[compheap.heapcount,1]+1>=compheap.heapsection[i,2]-compheap.heapsection[i,1]+1) then
  begin
   for i:=1 to compheap.heapsection[i,2]-compheap.heapsection[i,1]+1 do (p2+i-1)^:=(p1+i-1)^;
  end
 else 
  begin
   for i:=1 to compheap.heapsection[compheap.heapcount,2]-compheap.heapsection[compheap.heapcount,1]+1 do (p2+i-1)^:=(p1+i-1)^;
  end;
 compheap_delete_item(p); p:=newp+len;
end;
procedure sys_move(const source;var dest;count:natuint);compilerproc;[public,alias:'FPC_MOVE'];
var p1,p2:Pchar;
    i:natuint;
begin
 p1:=@source; p2:=@dest;
 for i:=1 to count do (p2+i-1)^:=(p1+i-1)^;
end;
function fpc_copy_proc(src,dest,typeinfo:Pointer):natint;compilerproc;[public,alias:'FPC_COPY_PROC'];
var address1,address2:Pbyte;
    i:natuint;
begin
 address1:=src; address2:=dest;
 for i:=1 to sizeof(src^) do
  begin
   (address2+i-1)^:=(address1+i-1)^;
  end; 
end;
procedure sysheap_delete_item(p:pointer);
var i,j,len:natuint;
begin
 for i:=1 to sysheap.heapcount do
  begin
   if(natuint(p)>=sysheap.heapsection[i,1]) and (natuint(p)<=sysheap.heapsection[i,2]) then break;
  end;
 if(i>sysheap.heapcount) then exit;
 len:=sysheap.heapsection[i,2]-sysheap.heapsection[i,1]+1;
 for j:=i+1 to sysheap.heapcount do
  begin
    sysheap.heapsection[j-1,1]:= sysheap.heapsection[j,1]-len;
    sysheap.heapsection[j-1,2]:= sysheap.heapsection[j,2]-len;
  end;
  sysheap.heapsection[sysheap.heapcount,1]:=0;
  sysheap.heapsection[sysheap.heapcount,2]:=0; 
 dec(sysheap.heapcount); inc(sysheap.heaprest,len);
end;
function getmem(size:natuint):Pointer;[public,alias:'getmem'];
var i,istart:natuint;
begin
 if(sysheap.heapcount>=maxsection) then getmem:=nil;
 if(sysheap.heaprest<size) then getmem:=nil;
 if(size=0) then getmem:=nil;
 if(sysheap.heapcount>0) then istart:=sysheap.heapsection[sysheap.heapcount,2]+1 else istart:=Natuint(@sysheap.heapcontent);
 inc(sysheap.heapcount);
 sysheap.heapsection[sysheap.heapcount,1]:=istart;
 sysheap.heapsection[sysheap.heapcount,2]:=istart+size-1;
 for i:=1 to size do
  begin
   sysheap.heapcontent[istart+i-1]:=0;
  end;
 dec(sysheap.heaprest,size);
 getmem:=Pointer(sysheap.heapsection[sysheap.heapcount,1]);
end;
procedure freemem(var p:pointer);[public,alias:'freemem'];
begin
 sysheap_delete_item(p); p:=nil;
end;
function allocmem(size:natuint):Pointer;[public,alias:'allocmem'];
var i,istart:natuint;
begin
 if(sysheap.heapcount>=maxsection) then allocmem:=nil;
 if(sysheap.heaprest<size) then allocmem:=nil;
 if(size=0) then allocmem:=nil;
 if(sysheap.heapcount>0) then istart:=sysheap.heapsection[sysheap.heapcount,2]+1 else istart:=NatUint(@sysheap.heapcontent);
 inc(sysheap.heapcount);
 sysheap.heapsection[sysheap.heapcount,1]:=istart;
 sysheap.heapsection[sysheap.heapcount,2]:=istart+size-1;
 for i:=1 to size do
  begin
   sysheap.heapcontent[istart+i-1]:=0;
  end;
 dec(sysheap.heaprest,size);
 allocmem:=Pointer(sysheap.heapsection[sysheap.heapcount,1]);
end;
procedure reallocmem(var p:Pointer;size:natuint);[public,alias:'reallocmem'];
var i,len:Natuint;
    newp:Pointer;
    po1,po2:Pbyte;
begin
 newp:=getmem(size);
 for i:=1 to sysheap.heapcount do
  begin
   if(NatUint(p)>=sysheap.heapsection[i,1]) and (NatUint(p)<=sysheap.heapsection[i,2]) then break;
  end;
 len:=NatUint(p)-sysheap.heapsection[i,1];
 po1:=p; po2:=newp;
 if(sysheap.heapsection[sysheap.heapcount,2]-sysheap.heapsection[sysheap.heapcount,1]+1>=sysheap.heapsection[i,2]-sysheap.heapsection[i,1]+1) then
  begin
   for i:=1 to sysheap.heapsection[i,2]-sysheap.heapsection[i,1]+1 do (po2+i-1)^:=(po1+i-1)^;
  end
 else 
  begin 
   for i:=1 to sysheap.heapsection[sysheap.heapcount,2]-sysheap.heapsection[sysheap.heapcount,1]+1 do (po2+i-1)^:=(po1+i-1)^;
  end;
 sysheap_delete_item(p); p:=newp+len;
end;
procedure move(const source;var dest;count:natuint);[public,alias:'move'];
var p1,p2:Pchar;
    i:natuint;
begin
 p1:=@source; p2:=@dest;
 for i:=1 to count do (p2+i-1)^:=(p1+i-1)^;
end;
function strlen(str:Pchar):natuint;[public,alias:'strlen'];
var res:natuint;
begin
 res:=0;
 while((str+res)^<>#0) do inc(res);
 strlen:=res;
end;
function wstrlen(str:PWideChar):natuint;[public,alias:'Wstrlen'];
var res:natuint;
begin
 res:=0;
 while((str+res)^<>#0) do inc(res);
 wstrlen:=res;
end;
function strcmp(str1,str2:Pchar):natint;[public,alias:'strcmp'];
var i:natint;
begin
 i:=0;
 while((str1+i)^=(str2+i)^) and ((str1+i)^<>#0) and ((str2+i)^<>#0) do inc(i);
 if((str1+i)^>(str2+i)^) then strcmp:=1
 else if((str1+i)^<(str2+i)^) then strcmp:=-1
 else strcmp:=0;
end;
function Wstrcmp(str1,str2:PwideChar):natint;[public,alias:'Wstrcmp'];
var i:natint;
begin
 i:=0;
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
procedure strset(var str:PChar;val:Pchar);[public,alias:'strset'];
var i:natuint;
begin
 i:=0;
 while((val+i)^<>#0) do
  begin
   (str+i)^:=(val+i)^; inc(i);
  end;
end;
procedure wstrset(var str:PWideChar;val:Pwidechar);[public,alias:'wstrset'];
var i:natuint;
begin
 i:=0;
 while((val+i)^<>#0) do
  begin
   (str+i)^:=(val+i)^; inc(i);
  end;
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
var i:natuint;
begin
 for i:=1 to count do
  begin
   (str+index-1+i-1)^:=(str+index-1+count+i-1)^;
   (str+index-1+count+i-1)^:=#0;
  end;
 (str+index+i-1)^:=#0;
end;
procedure Wstrdelete(var str:PWideChar;index,count:Natuint);[public,alias:'Wstrdelete'];
var i:natuint;
begin
 for i:=1 to count do
  begin
   (str+index-1+i-1)^:=(str+index-1+count+i-1)^;
   (str+index-1+count+i-1)^:=#0;
  end;
 (str+index-1+i-1)^:=#0;
end;
procedure strdeleteinrange(var str:PChar;left,right:Natuint);[public,alias:'strdeleteinrange'];
var i:natuint;
begin
 for i:=left to right do
  begin
   (str+i-1)^:=(str+i-1+right-left+1)^;
   (str+i-1+right-left+1)^:=#0;
  end;
 (str+i-1)^:=#0;
end;
procedure WStrdeleteinrange(var str:PWideChar;left,right:Natuint);[public,alias:'Wstrdeleteinrange'];
var i:natuint;
begin
 for i:=left to right do
  begin
   (str+i-1)^:=(str+i-1+right-left+1)^;
   (str+i-1+right-left+1)^:=#0;
  end;
 (str+i-1)^:=#0;
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
function strcount(str,substr:PChar;start:Natuint):natuint;[public,alias:'strcount'];
var i,len1,len2,res:natuint;
begin
 len1:=strlen(str); len2:=strlen(substr);
 if(len2>len1) then
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
 if(len2>len1) then
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
 mylen:=strlen(str)-strlen(substr)+1;
 for i:=mylen downto start do
  begin
   if(strcmp(substr,strcopy(str,i,strlen(substr)))=0) then break;
  end;
 if(i<start) then strposinverse:=0 else strposinverse:=i;
end;
function Wstrposinverse(str,substr:PWideChar;start:natuint):natuint;[public,alias:'Wstrposinverse'];
var i,mylen:natuint;
begin
 mylen:=Wstrlen(str)-Wstrlen(substr)+1;
 for i:=mylen downto start do
  begin
   if(Wstrcmp(substr,Wstrcopy(str,i,Wstrlen(substr)))=0) then break;
  end;
 if(i<start) then Wstrposinverse:=0 else Wstrposinverse:=i;
end;
function UIntToPChar(UInt:natuint):Pchar;[public,alias:'uinttochar'];
const numchar:PChar='0123456789';
var i:byte;
    myint:natuint;
    mychar:PChar;
begin
 mychar:=allocmem(sizeof(Char)*21);
 i:=20; myint:=uint; (mychar+20)^:=#0;
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
 mychar:=allocmem(sizeof(WideChar)*21);
 i:=20; myint:=uint; (mychar+20)^:=#0;
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
    myrightnum:natint=20;
begin
 procnum:=int; strinit(mystr,20);
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
    myrightnum:natint=20;
begin
 procnum:=int; Wstrinit(mystr,20);
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
var i:dword;
begin
 compheap.heapcount:=0; compheap.heaprest:=maxheap;
 sysheap.heapcount:=0; sysheap.heaprest:=maxheap;
end.
