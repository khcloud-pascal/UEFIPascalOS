unit shell;

interface

uses tydqfs,uefi;
const shell_string:byte=$00;
      shell_int:byte=$01;
type shell_error_item=record
                      errorrow:natuint;
                      errorcolumn:natuint;
                      errortype:byte;
                      end;
     shell_error_list=record
                      errorindex:^shell_error_item;
                      errorcount:natuint;
                      end;
     shell_error_partstr=record
                         errorpos:^natuint;
                         errorlen:^natuint;
                         errorcount:natuint;
                         end;
     shell_string_index=record
                        position:natuint;
                        length:natuint;
                        end;
     shell_ifstatement=packed record
                       condition:shell_string_index;
                       startline,endline:natuint;
                       havetop,havebuttom:boolean;
                       end;
     shell_switchstatement=packed record
                           condition:shell_string_index;
                           startline,endline:natuint;
                           end;
     shell_switchitemstatement=packed record
                               itemvalue:shell_string_index;
                               startline,endline:natuint;
                               end;
     shell_loopstatement=packed record
                         condition:shell_string_index;
                         startline,endline:natuint;
                         state:boolean;
                         end;
     shell_expression=packed record
                      content:shell_string_index;
                      end;
     shell_tree=packed record
                parent:^shell_tree;
                treetype:byte;
                content:Pointer;
                child:^shell_tree;
                childcount:natuint;
                end;
     shell_temporary_stack=packed record
                           stackleft:array[1..65535] of natuint;
                           stackright:array[1..65535] of natuint;
                           isfunc:array[1..65535] of boolean;
                           stacksize:byte;
                           end;
     shell_temporary_calculate=packed record
                               sign:^byte;
                               number:^natint;
                               count:word;
                               end;
     shell_temporary_condition=packed record
                               sign:^byte;
                               condition:^boolean;
                               count:word;
                               end;
     shell_variable_list_item=packed record
                              varname:array[1..128] of WideChar;
                              vartype:byte;
                              varvalue:Pointer;
                              end;
     shell_variable_list=packed record
                         itemlist:^shell_variable_list_item;
                         itemcount:qword;
                         end;
     variable_name=array[1..128] of WideChar;
     Pshell_ifstatement=^shell_ifstatement;
     Pshell_switchitemstatement=^shell_switchitemstatement;
     Pshell_switchstatement=^shell_switchstatement;
     Pshell_loopstatement=^shell_loopstatement;
     Pshell_expression=^shell_expression;

procedure shell_execute_code(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;var sysinfo:tydqfs_system_info;var sysindex:natuint);
implementation
uses console;
function shell_natuint_minimum(data:array of natuint):natuint;
var res,i:natuint;
begin
 res:=$FFFFFFFF;
 for i:=0 to High(data) do if(data[i]<res) then res:=data[i];
 shell_natuint_minimum:=res;
end;
function shell_is_function_name(fstr:PwideChar):boolean;
var i,len:natuint;
begin
 len:=Wstrlen(fstr);
 if(not (((fstr^>='a') and (fstr^<='z')) or ((fstr^>='A')
 and (fstr^<='Z')) or (fstr^='_'))) then exit(false);
 for i:=1 to len-1 do
  begin
   if(not ((((fstr+i)^>='a') and ((fstr+i)^<='z')) or (((fstr+i)^>='A')
   and ((fstr+i)^<='Z')) or
   (((fstr+i)^>='0') and ((fstr+i)^<='9')) or ((fstr+i)^='_'))) then exit(false);
  end;
 shell_is_function_name:=true;
end;
function shell_PwideCharToVarName(mystr:PWideChar):variable_name;
var i:byte;
    res:variable_name;
begin
 i:=0;
 while((mystr+i)^<>#0) do
  begin
   res[i+1]:=(mystr+i)^; inc(i);
  end;
 shell_PwideCharToVarName:=res;
end;
procedure shell_handle_code_str(var totalstr:PWideChar);
var i,j,k,len,procnum:natuint;
    status:byte;
    partstr1,partstr2:PWideChar;
    isbracket:boolean;
begin
 partstr1:=nil; partstr2:=nil;
 i:=1; len:=WStrlen(totalstr); isbracket:=false;
 while(i<=len) do
  begin
   if((totalstr+i-1)^=#0) then break;
   if((totalstr+i-1)^='"') then
    begin
     procnum:=Wstrpos(totalstr,'"',i+1);
     if(procnum=0) then i:=len+1 else i:=procnum+1;
    end;
   if((totalstr+i-1)^=#39) then
    begin
     procnum:=Wstrpos(totalstr,#39,i+1);
     if(procnum=0) then i:=len+1 else i:=procnum+1;
    end;
   if((totalstr+i-1)^='(') and (isbracket=false) then
    begin
     inc(i,1); isbracket:=true;
    end;
   if((totalstr+i-1)^=')') and (isbracket=true) then
    begin
     inc(i,1); isbracket:=false;
    end;
   if((totalstr+i-1)^='\') then
    begin
     procnum:=Wstrpos(totalstr,#10,i+1);
     if(procnum=0) then
      begin
       Wstrdelete(totalstr,i,len-i+1); dec(len,len-i+1);
      end
     else
      begin
       Wstrdelete(totalstr,i,procnum-i+1); dec(len,procnum-i+1);
      end;
    end;
   if((totalstr+i-1)^<>' ') then
    begin
     if((totalstr+i-1)^=#10) and (isbracket=true) then
      begin
       Wstrdelete(totalstr,i,1); dec(len); continue;
      end;
     partstr1:=Wstrcutout(totalstr,i,i+1);
     partstr2:=Wstrcutout(totalstr,i,i+2);
     if((totalstr+i-1)^='#') then
      begin
       if(WstrcmpL(partstr2,'###')=0) then
        begin
         status:=1; procnum:=Wstrpos(totalstr,'###',i+3);
        end
       else
        begin
         status:=0; procnum:=Wstrpos(totalstr,#10,i+1);
        end;
       if(status=1) then
        begin
         if(procnum>0) then
          begin
           Wstrdelete(totalstr,i,procnum+2-i+1); dec(len,procnum+2-i+1);
          end
         else
          begin
           Wstrdelete(totalstr,i,len-i+1); dec(len,len-i+2);
          end;
        end
       else if(status=0) then
        begin
         if(procnum>0) then
          begin
           Wstrdelete(totalstr,i,procnum-i+1); dec(len,procnum-i+1);
          end
         else
          begin
           Wstrdelete(totalstr,i,len-i+1); dec(len,len-i+2);
          end;
        end;
      end
     else if(WstrcmpL(partstr1,'//')=0)then
      begin
       procnum:=Wstrpos(totalstr,#10,i+2);
       if(procnum>0) then
        begin
         Wstrdelete(totalstr,i,procnum-i+1); dec(len,procnum-i+1);
        end
       else
        begin
         Wstrdelete(totalstr,i,len-i+1); dec(len,len-i+2);
        end;
      end
     else if(WStrcmpL(partstr1,'/*')=0) then
      begin
       procnum:=Wstrpos(totalstr,'*/',i+2);
       if(procnum>0) then
        begin
         Wstrdelete(totalstr,i,procnum+1-i+1); dec(len,procnum+1-i+1);
        end
       else
        begin
         Wstrdelete(totalstr,i,len-i+1); dec(len,len-i+2);
        end;
      end;
     Wstrfree(partstr2);
     Wstrfree(partstr1);
     inc(i,1); continue;
    end
   else
    begin
     if(i<len) then
      begin
       if((totalstr+i)^='(') or ((totalstr+i)^=')') or ((totalstr+i)^='[')
       or((totalstr+i)^=']') or ((totalstr+i)^='{') or ((totalstr+i)^='}')
       or((totalstr+i)^='+') or ((totalstr+i)^='=') or ((totalstr+i)^='*')
       or((totalstr+i)^='/') or ((totalstr+i)^='!')
       or((totalstr+i)^=':') or ((totalstr+i)^=' ') or ((totalstr+i)^='%')
       or((totalstr+i)^='^') then
        begin
         Wstrdelete(totalstr,i,1); dec(len); continue;
        end;
      end;
     if(i>1) then
      begin
       if((totalstr+i-2)^='(') or ((totalstr+i-2)^=')') or ((totalstr+i-2)^='[')
       or((totalstr+i-2)^=']') or ((totalstr+i-2)^='{') or ((totalstr+i-2)^='}')
       or((totalstr+i-2)^='+') or ((totalstr+i-2)^='=') or ((totalstr+i-2)^='*')
       or((totalstr+i-2)^='/') or ((totalstr+i-2)^='!')
       or((totalstr+i-2)^=':') or ((totalstr+i-2)^=' ') or ((totalstr+i-2)^='%')
       or((totalstr+i-2)^='^') then
        begin
         Wstrdelete(totalstr,i,1); dec(len); continue;
        end;
      end;
     if(i=len) or (i=1) then
      begin
       Wstrdelete(totalstr,i,1); dec(len); continue;
      end;
     if(i>1) and ((totalstr+i-2)^=#10) then
      begin
       Wstrdelete(totalstr,i,1); dec(len); continue;
      end
     else if(i<len) and ((totalstr+i)^=#10) then
      begin
       Wstrdelete(totalstr,i,1); dec(len); continue;
      end;
     inc(i,1);
    end;
  end;
 i:=1;
 while(i<=len) do
  begin
   j:=Wstrpos(totalstr,'{',i);
   k:=Wstrpos(totalstr,'}',i);
   if(j>=k) then
    begin
     status:=0;
     if(k>2) and ((totalstr+k-2)^<>#10) then
      begin
       Wstrinsert(totalstr,#10,k); status:=status+1; inc(len);
      end;
     if(k<len) and ((totalstr+k)^<>#10) then
      begin
       Wstrinsert(totalstr,#10,k+1); status:=status+1; inc(len);
      end;
     i:=k+1+status;
     if(k=0) then i:=len+1;
    end
   else if(j<k) then
    begin
     if(j>2) and ((totalstr+j-2)^<>#10) then
      begin
       Wstrinsert(totalstr,#10,j); status:=status+1; inc(len);
      end;
     if(j<len) and ((totalstr+j)^<>#10) then
      begin
       Wstrinsert(totalstr,#10,j+1); status:=status+1; inc(len);
      end;
     i:=j+1+status;
     if(j=0) then i:=len+1;
    end;
  end;
 i:=2;
 while(i<=len) do
  begin
   if((totalstr+i-2)^=#10) and ((totalstr+i-1)^=#10) then
    begin
     Wstrdelete(totalstr,i-1,1); dec(len);
    end
   else if((totalstr+i-2)^=#10) and (i=2) then
    begin
     Wstrdelete(totalstr,i-1,1); dec(len);
    end
   else if((totalstr+i-1)^=#10) and (i=len) then
    begin
     Wstrdelete(totalstr,i,1); dec(len);
    end
   else inc(i,1);
  end;
end;
function shell_check_code_str(totalstr:PWideChar):shell_error_list;
var i,j,k,len,procnum,subpos,sublen,size,m1,m2:natuint;
    res:shell_error_list;
    stack:shell_temporary_stack;
    partstr,mycondstr,partstr2,partstr3:PWideChar;
    mypartlist:shell_error_partstr;
    bool:boolean;
begin
 res.errorcount:=0; stack.stacksize:=0; len:=Wstrlen(totalstr);
 mypartlist.errorcount:=0; mypartlist.errorpos:=nil; mypartlist.errorlen:=nil;
 for i:=1 to len do
  begin
   if((totalstr+i-1)^='(') or ((totalstr+i-1)^='{') then
    begin
     inc(stack.stacksize);
     stack.stackleft[stack.stacksize]:=i;
     stack.stackright[stack.stacksize]:=0;
    end
   else if((totalstr+i-1)^=')') or ((totalstr+i-1)^='}')then
    begin
     j:=stack.stacksize;
     while(j>0) and (stack.stackright[j]<>0) do dec(j);
     if(j>0) then stack.stackright[j]:=i else
      begin
       inc(res.errorcount);
       ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
       partstr:=Wstrcopy(totalstr,1,i);
       (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
       (res.errorindex+res.errorcount-1)^.errorcolumn:=
       i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
       (res.errorindex+res.errorcount-1)^.errortype:=0;
       Wstrfree(partstr);
      end;
    end;
  end;
 for i:=1 to stack.stacksize do
  begin
   if(stack.stackright[i]=0) then
    begin
     inc(res.errorcount);
     ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
     partstr:=Wstrcopy(totalstr,1,stack.stackleft[i]);
     (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
     (res.errorindex+res.errorcount-1)^.errorcolumn:=
     i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
     (res.errorindex+res.errorcount-1)^.errortype:=0;
     Wstrfree(partstr);
    end
   else if((totalstr+stack.stackleft[i]-1)^='(') and ((totalstr+stack.stackright[i]-1)^='}') then
    begin
     inc(res.errorcount);
     ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
     partstr:=Wstrcopy(totalstr,1,stack.stackleft[i]);
     (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
     (res.errorindex+res.errorcount-1)^.errorcolumn:=
     i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
     (res.errorindex+res.errorcount-1)^.errortype:=1;
     Wstrfree(partstr);
    end
   else if((totalstr+stack.stackleft[i]-1)^='{') and ((totalstr+stack.stackright[i]-1)^=')') then
    begin
     inc(res.errorcount);
     ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
     partstr:=Wstrcopy(totalstr,1,stack.stackleft[i]);
     (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
     (res.errorindex+res.errorcount-1)^.errorcolumn:=
     i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
     (res.errorindex+res.errorcount-1)^.errortype:=1;
     Wstrfree(partstr);
    end;
  end;
 i:=0; subpos:=0; sublen:=0;
 while(i<len) do
  begin
   inc(i,1);
   if((totalstr+i-1)^='{') or ((totalstr+i-1)^='}') or
   ((totalstr+i-1)^='(') or ((totalstr+i-1)^=')') or ((totalstr+i-1)^=#10) then
    begin
     if(sublen>0) then
      begin
       inc(mypartlist.errorcount);
       size:=exe_heap_getmemsize(mypartlist.errorpos);
       exe_heap_reallocmem(mypartlist.errorpos,sizeof(natuint)*2*mypartlist.errorcount);
       mypartlist.errorlen:=Pointer(mypartlist.errorlen)-size;
       size:=exe_heap_getmemsize(mypartlist.errorlen);
       exe_heap_reallocmem(mypartlist.errorlen,sizeof(natuint)*2*mypartlist.errorcount);
       mypartlist.errorpos:=Pointer(mypartlist.errorpos)-size;
       (mypartlist.errorpos+mypartlist.errorcount-1)^:=subpos;
       (mypartlist.errorlen+mypartlist.errorcount-1)^:=sublen;
       subpos:=0; sublen:=0;
      end;
     inc(mypartlist.errorcount);
     size:=exe_heap_getmemsize(mypartlist.errorpos);
     exe_heap_reallocmem(mypartlist.errorpos,sizeof(natuint)*mypartlist.errorcount);
     mypartlist.errorlen:=Pointer(Pointer(mypartlist.errorlen)-size);
     size:=exe_heap_getmemsize(mypartlist.errorlen);
     exe_heap_reallocmem(mypartlist.errorlen,sizeof(natuint)*mypartlist.errorcount);
     mypartlist.errorpos:=Pointer(Pointer(mypartlist.errorpos)-size);
     (mypartlist.errorpos+mypartlist.errorcount-1)^:=i;
     (mypartlist.errorlen+mypartlist.errorcount-1)^:=1;
    end
   else if((totalstr+i-1)^=' ') then
    begin
     if(sublen>0) then
      begin
       inc(mypartlist.errorcount);
       size:=exe_heap_getmemsize(mypartlist.errorpos);
       exe_heap_reallocmem(mypartlist.errorpos,sizeof(natuint)*(mypartlist.errorcount+1));
       mypartlist.errorlen:=Pointer(Pointer(mypartlist.errorlen)-size);
       size:=exe_heap_getmemsize(mypartlist.errorlen);
       exe_heap_reallocmem(mypartlist.errorlen,sizeof(natuint)*(mypartlist.errorcount+1));
       mypartlist.errorpos:=Pointer(Pointer(mypartlist.errorpos)-size);
       (mypartlist.errorpos+mypartlist.errorcount-1)^:=subpos;
       (mypartlist.errorlen+mypartlist.errorcount-1)^:=sublen;
       subpos:=0; sublen:=0;
      end;
    end
   else if((totalstr+i-1)^<>' ') then
    begin
     if(subpos=0) then subpos:=i;
     if(subpos>0) then inc(sublen,1);
    end;
  end;
 while(i<=mypartlist.errorcount)do
  begin
   if(WstrpartcmpL(totalstr,(mypartlist.errorpos+i-1)^,
   (mypartlist.errorlen+i-1)^,'if')=0) then
    begin
     for j:=i+1 to mypartlist.errorcount do
      begin
       if(WstrpartcmpL(totalstr,(mypartlist.errorpos+j-1)^,
       (mypartlist.errorlen+j-1)^,#10)=0) then break;
      end;
     Wstrinit(mycondstr,65535);
     for k:=i+1 to j-1 do
      begin
       partstr:=Wstrcopy(totalstr,(mypartlist.errorpos+i-1)^,(mypartlist.errorlen+i-1)^);
       Wstrcat(mycondstr,partstr);
       Wstrfree(partstr);
      end;
     m1:=1; m2:=1;
     while(m2>0) do
      begin
       if(Wstrpos(mycondstr,'||',m1)<Wstrpos(mycondstr,'&&',m1)) then
       m2:=Wstrpos(mycondstr,'||',m1) else m2:=Wstrpos(mycondstr,'&&',m1);
       partstr:=Wstrcopy(mycondstr,m1,m2-m1);
       if(Wstrcount(partstr,'==',1)>1) or (Wstrcount(partstr,'!=',1)>1) or (Wstrcount(partstr,'<',1)>1)
       or (Wstrcount(partstr,'>',1)>1) or (Wstrcount(partstr,'==',1)+Wstrcount(partstr,'!=',1)+
       Wstrcount(partstr,'<',1)+Wstrcount(partstr,'>',1)>1) then
        begin
         Wstrfree(partstr);
         partstr:=Wstrcopy(totalstr,1,(mypartlist.errorpos+i-1)^);
         inc(res.errorcount);
         size:=getmemsize(partstr);
         ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
         (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
         (res.errorindex+res.errorcount-1)^.errorcolumn:=
         i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
         (res.errorindex+res.errorcount-1)^.errortype:=2;
         Wstrfree(partstr);
         res.errorindex:=Pointer(Pointer(res.errorindex)-size);
        end;
       if(partstr<>nil) then Wstrfree(partstr);
       m1:=m2+2;
      end;
     size:=getmemsize(mycondstr);
     Wstrfree(mycondstr);
     res.errorindex:=Pointer(Pointer(res.errorindex)-size);
     i:=j+1;
    end
   else if(WstrpartcmpL(totalstr,(mypartlist.errorpos+i-1)^,
   (mypartlist.errorlen+i-1)^,'elseif')=0) then
    begin
     for j:=i+1 to mypartlist.errorcount do
      begin
       if(WstrpartcmpL(totalstr,(mypartlist.errorpos+j-1)^,
       (mypartlist.errorlen+j-1)^,#10)=0) then break;
      end;
     Wstrinit(mycondstr,65535);
     for k:=i+1 to j-1 do
      begin
       partstr:=Wstrcopy(totalstr,(mypartlist.errorpos+i-1)^,(mypartlist.errorlen+i-1)^);
       Wstrcat(mycondstr,partstr);
       Wstrfree(partstr);
      end;
     m1:=1; m2:=1;
     while(m2>0) do
      begin
       if(Wstrpos(mycondstr,'||',m1)<Wstrpos(mycondstr,'&&',m1)) then
       m2:=Wstrpos(mycondstr,'||',m1) else m2:=Wstrpos(mycondstr,'&&',m1);
       partstr:=Wstrcopy(mycondstr,m1,m2-m1);
       if(Wstrcount(partstr,'==',1)>1) or (Wstrcount(partstr,'!=',1)>1) or (Wstrcount(partstr,'<',1)>1)
       or (Wstrcount(partstr,'>',1)>1) or (Wstrcount(partstr,'==',1)+Wstrcount(partstr,'!=',1)+
       Wstrcount(partstr,'<',1)+Wstrcount(partstr,'>',1)>1) then
        begin
         Wstrfree(partstr);
         partstr:=Wstrcopy(totalstr,1,(mypartlist.errorpos+i-1)^);
         inc(res.errorcount);
         size:=getmemsize(partstr);
         ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
         (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
         (res.errorindex+res.errorcount-1)^.errorcolumn:=
         i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
         (res.errorindex+res.errorcount-1)^.errortype:=2;
         Wstrfree(partstr);
         res.errorindex:=Pointer(Pointer(res.errorindex)-size);
        end;
       if(partstr<>nil) then Wstrfree(partstr);
       m1:=m2+2;
      end;
     size:=getmemsize(mycondstr);
     Wstrfree(mycondstr);
     res.errorindex:=Pointer(Pointer(res.errorindex)-size);
     i:=j+1;
    end
   else if(WstrpartcmpL(totalstr,(mypartlist.errorpos+i-1)^,
   (mypartlist.errorlen+i-1)^,'switch')=0) then
    begin
     if(WstrpartcmpL(totalstr,(mypartlist.errorpos+i)^,(mypartlist.errorlen+i)^,'(')=0) then
      begin
       Wstrinit(mycondstr,65535);
       for k:=i+2 to j-2 do
        begin
         partstr:=Wstrcopy(totalstr,(mypartlist.errorpos+i-1)^,(mypartlist.errorlen+i-1)^);
         Wstrcat(mycondstr,partstr);
         Wstrfree(partstr);
        end;
       bool:=shell_is_function_name(mycondstr);
       Wstrfree(mycondstr);
       if(bool=false) then
        begin
         partstr:=Wstrcopy(totalstr,1,(mypartlist.errorpos+i-1)^);
         inc(res.errorcount);
         ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
         (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
         (res.errorindex+res.errorcount-1)^.errorcolumn:=
         i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
         (res.errorindex+res.errorcount-1)^.errortype:=3;
         Wstrfree(partstr);
         res.errorindex:=Pointer(Pointer(res.errorindex)-size);
        end;
      end
     else
      begin
       Wstrinit(mycondstr,65535);
       for k:=i+1 to j-1 do
        begin
         partstr:=Wstrcopy(totalstr,(mypartlist.errorpos+i-1)^,(mypartlist.errorlen+i-1)^);
         Wstrcat(mycondstr,partstr);
         Wstrfree(partstr);
        end;
       bool:=shell_is_function_name(mycondstr);
       Wstrfree(mycondstr);
       if(bool=false) then
        begin
         partstr:=Wstrcopy(totalstr,1,(mypartlist.errorpos+i-1)^);
         inc(res.errorcount);
         ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
         (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
         (res.errorindex+res.errorcount-1)^.errorcolumn:=
         i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
         (res.errorindex+res.errorcount-1)^.errortype:=4;
         Wstrfree(partstr);
         res.errorindex:=Pointer(Pointer(res.errorindex)-size);
        end;
      end;
    end
   else if(WstrpartcmpL(totalstr,(mypartlist.errorpos+i-1)^,
   (mypartlist.errorlen+i-1)^,'while')=0) then
    begin
     for j:=i+1 to mypartlist.errorcount do
      begin
       if(WstrpartcmpL(totalstr,(mypartlist.errorpos+j-1)^,
       (mypartlist.errorlen+j-1)^,#10)=0) then break;
      end;
     Wstrinit(mycondstr,65535);
     for k:=i+1 to j-1 do
      begin
       partstr:=Wstrcopy(totalstr,(mypartlist.errorpos+i-1)^,(mypartlist.errorlen+i-1)^);
       Wstrcat(mycondstr,partstr);
       Wstrfree(partstr);
      end;
     m1:=1; m2:=1;
     while(m2>0) do
      begin
       if(Wstrpos(mycondstr,'||',m1)<Wstrpos(mycondstr,'&&',m1)) then
       m2:=Wstrpos(mycondstr,'||',m1) else m2:=Wstrpos(mycondstr,'&&',m1);
       partstr:=Wstrcopy(mycondstr,m1,m2-m1);
       if(Wstrcount(partstr,'==',1)>1) or (Wstrcount(partstr,'!=',1)>1) or (Wstrcount(partstr,'<',1)>1)
       or (Wstrcount(partstr,'>',1)>1) or (Wstrcount(partstr,'==',1)+Wstrcount(partstr,'!=',1)+
       Wstrcount(partstr,'<',1)+Wstrcount(partstr,'>',1)>1) then
        begin
         Wstrfree(partstr);
         partstr:=Wstrcopy(totalstr,1,(mypartlist.errorpos+i-1)^);
         inc(res.errorcount);
         size:=getmemsize(partstr);
         ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
         (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
         (res.errorindex+res.errorcount-1)^.errorcolumn:=
         i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
         (res.errorindex+res.errorcount-1)^.errortype:=5;
         Wstrfree(partstr);
         res.errorindex:=Pointer(Pointer(res.errorindex)-size);
        end;
       if(partstr<>nil) then Wstrfree(partstr);
       m1:=m2+2;
      end;
     size:=getmemsize(mycondstr);
     Wstrfree(mycondstr);
     res.errorindex:=Pointer(Pointer(res.errorindex)-size);
     i:=j+1;
    end
   else if(WstrpartcmpL(totalstr,(mypartlist.errorpos+i-1)^,
   (mypartlist.errorlen+i-1)^,'for')=0) then
    begin
     for j:=i+1 to mypartlist.errorcount do
      begin
       if(WstrpartcmpL(totalstr,(mypartlist.errorpos+j-1)^,
       (mypartlist.errorlen+j-1)^,#10)=0) then break;
      end;
     Wstrinit(mycondstr,65535);
     for k:=i+1 to j-1 do
      begin
       partstr:=Wstrcopy(totalstr,(mypartlist.errorpos+i-1)^,(mypartlist.errorlen+i-1)^);
       Wstrcat(mycondstr,partstr);
       Wstrfree(partstr);
      end;
     m1:=1; m2:=1;
     if(Wstrpos(mycondstr,':',1)=0) then partstr2:=nil
     else partstr2:=Wstrcopy(mycondstr,1,Wstrpos(mycondstr,':',1)-1);
     partstr3:=Wstrcopy(mycondstr,Wstrpos(mycondstr,':',1)+1,
     Wstrlen(mycondstr)-Wstrpos(mycondstr,':',1));
     if(Wstrpos(mycondstr,':',1)=0) or (partstr2=nil) then
      begin
       inc(res.errorcount);
       partstr:=Wstrcopy(totalstr,1,(mypartlist.errorpos+i-1)^);
       size:=getmemsize(partstr)+getmemsize(partstr2)+getmemsize(partstr3);
       ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
       (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
       (res.errorindex+res.errorcount-1)^.errorcolumn:=
       i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
       (res.errorindex+res.errorcount-1)^.errortype:=6;
       Wstrfree(partstr);
       Wstrfree(partstr3);
       Wstrfree(partstr2);
       res.errorindex:=Pointer(Pointer(res.errorindex)-size);
      end
     else if(partstr3=nil) then
      begin
       inc(res.errorcount);
       partstr:=Wstrcopy(totalstr,1,(mypartlist.errorpos+i-1)^);
       size:=getmemsize(partstr)+getmemsize(partstr2)+getmemsize(partstr3);
       ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
       (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
       (res.errorindex+res.errorcount-1)^.errorcolumn:=
       i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
       (res.errorindex+res.errorcount-1)^.errortype:=7;
       Wstrfree(partstr);
       Wstrfree(partstr3);
       Wstrfree(partstr2);
       res.errorindex:=Pointer(Pointer(res.errorindex)-size);
      end;
     size:=getmemsize(mycondstr);
     Wstrfree(mycondstr);
     res.errorindex:=Pointer(Pointer(res.errorindex)-size);
    end
   else if(WstrpartcmpL(totalstr,(mypartlist.errorpos+i-1)^,
   (mypartlist.errorlen+i-1)^,'case')=0) then
    begin
     if(WstrpartcmpL(totalstr,(mypartlist.errorpos+i+1)^,
     (mypartlist.errorlen+i+1)^,'case')=0) then
      begin
       inc(i,2);
       inc(res.errorcount);
       ReallocMem(res.errorindex,sizeof(shell_error_item)*res.errorcount);
       partstr:=Wstrcopy(totalstr,1,(mypartlist.errorpos+mypartlist.errorcount+1)^);
       (res.errorindex+res.errorcount-1)^.errorrow:=Wstrcount(partstr,#10,1)+1;
       (res.errorindex+res.errorcount-1)^.errorcolumn:=
       i-Wstrposorder(partstr,#10,1,Wstrcount(partstr,#10,1));
       (res.errorindex+res.errorcount-1)^.errortype:=8;
       Wstrfree(partstr);
      end;
    end
   else
    begin
     inc(i,1);
    end;
  end;
 shell_check_code_str:=res;
end;
procedure shell_create_tree(var tree:shell_tree;totalstr:PWideChar;startindex,endindex:natuint);
var mystack:shell_temporary_stack;
    i,j,k,m,len,lineindex,baseindex,stackindex,childnumber,index,totalline:natuint;
    procnum1,procnum2,procnum3,procnum4,procnum5,procnum6:natuint;
    line:PWideChar;
begin
 i:=startindex; len:=endindex;
 lineindex:=0; baseindex:=1; mystack.stacksize:=0;
 while(i<=len) do
  begin
   inc(lineindex);
   j:=Wstrpos(totalstr,#10,i);
   line:=Wstrcutout(totalstr,i,j-1);
   if(WstrcmpL(line,'{')=0) then
    begin
     inc(mystack.stacksize);
     mystack.stackleft[mystack.stacksize]:=lineindex;
     mystack.stackright[mystack.stacksize]:=0;
    end
   else if(WstrcmpL(line,'}')=0) then
    begin
     k:=mystack.stacksize;
     while(k>0) and (mystack.stackright[k]=0) do dec(k);
     if(k=baseindex) then
      begin
       for m:=baseindex+1 to mystack.stacksize do
        begin
         if(mystack.stackleft[baseindex]<mystack.stackleft[m]) and
         (mystack.stackright[baseindex]>mystack.stackright[m]) then
           begin
            mystack.stackleft[m]:=0;
            mystack.stackright[m]:=0;
           end;
        end;
       mystack.stacksize:=baseindex;
       inc(baseindex);
      end
     else if(k>baseindex) then
      begin
       mystack.stackright[k]:=i;
      end;
    end;
   Wstrfree(line);
   if(j=0) then i:=len+1 else i:=j+1;
  end;
 i:=0; childnumber:=0; stackindex:=1;
 while(i<lineindex) do
  begin
   inc(i,1);
   if(i=mystack.stackleft[stackindex]-1) and (stackindex<=mystack.stacksize) then
    begin
     i:=mystack.stackright[stackindex]+1;
     inc(childnumber,1);
     inc(stackindex,1);
    end;
   inc(childnumber,1);
  end;
 totalline:=i;
 i:=0; index:=0; stackindex:=1;
 tree.childcount:=childnumber;
 tree.child:=allocmem(sizeof(shell_tree)*tree.childcount);
 while(index<childnumber) do
  begin
   inc(i,1); inc(index,1);
   if(i=mystack.stackleft[stackindex]-1) and (mystack.stacksize>=stackindex) then
    begin
     procnum1:=Wstrposorder(totalstr,#10,startindex,i-1);
     if(i-1=0) then procnum1:=0;
     procnum2:=Wstrposorder(totalstr,#10,startindex,i);
     procnum5:=i;
     if(stackindex>mystack.stacksize) then i:=totalline else i:=mystack.stackright[stackindex]+1;
     procnum3:=Wstrposorder(totalstr,#10,startindex,i-1);
     procnum4:=Wstrposorder(totalstr,#10,startindex,i);
     if(procnum4=0) then procnum4:=endindex;
     procnum6:=i;
     inc(stackindex,1);
     if(Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'if ')=0) or
     (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'if(')=0) or
     (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif ')=0) or
     (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif(')=0) or
     (WstrpartcmpL(totalstr,procnum1+1,procnum2-procnum1-1,'else ')=0) then
      begin
       (tree.child+index-1)^.parent:=@tree;
       (tree.child+index-1)^.treetype:=2;
       (tree.child+index-1)^.content:=allocmem(sizeof(shell_ifstatement));
       Pshell_ifstatement((tree.child+index-1)^.content)^.condition.position:=procnum1+1;
       Pshell_ifstatement((tree.child+index-1)^.content)^.condition.length:=procnum2-procnum1-1;
       Pshell_ifstatement((tree.child+index-1)^.content)^.startline:=procnum5+2;
       Pshell_ifstatement((tree.child+index-1)^.content)^.endline:=procnum6-2;
       if(mystack.stacksize>1) then
        begin
         if(Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'if ')=0) or
         (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'if(')=0) or
         (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif ')=0) or
         (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif(')=0) then
          begin
           Pshell_ifstatement((tree.child+index-1)^.content)^.havetop:=true;
          end
         else
          begin
           Pshell_ifstatement((tree.child+index-1)^.content)^.havetop:=false;
          end
        end;
       if(procnum6-1<totalline) then
        begin
         if(Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif ')=0) or
         (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif(')=0) or
         (WstrpartcmpL(totalstr,procnum1+1,procnum2-procnum1-1,'else')=0) then
          begin
           Pshell_ifstatement((tree.child+index-1)^.content)^.havebuttom:=true;
          end
         else
          begin
           Pshell_ifstatement((tree.child+index-1)^.content)^.havebuttom:=false;
          end;
        end;
       shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
      end
     else if(WstrpartcmpL(totalstr,procnum1+1,procnum2-procnum1-1,'switch ')=0) or
     (WstrpartcmpL(totalstr,procnum1+1,procnum2-procnum1-1,'switch(')=0) then
      begin
       (tree.child+index-1)^.parent:=@tree;
       (tree.child+index-1)^.treetype:=3;
       (tree.child+index-1)^.content:=allocmem(sizeof(shell_switchstatement));
       Pshell_switchstatement((tree.child+index-1)^.content)^.condition.position:=procnum1+1;
       Pshell_switchstatement((tree.child+index-1)^.content)^.condition.length:=procnum2-procnum1-1;
       Pshell_switchstatement((tree.child+index-1)^.content)^.startline:=procnum5+2;
       Pshell_switchstatement((tree.child+index-1)^.content)^.endline:=procnum6-2;
       shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
      end
     else if(Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'for ')=0) or
     (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'for(')=0) then
      begin
       (tree.child+index-1)^.parent:=@tree;
       (tree.child+index-1)^.treetype:=4;
       (tree.child+index-1)^.content:=allocmem(sizeof(shell_loopstatement));
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.position:=procnum1+1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.length:=procnum2-procnum1-1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.state:=false;
       Pshell_loopstatement((tree.child+index-1)^.content)^.startline:=procnum5+2;
       Pshell_loopstatement((tree.child+index-1)^.content)^.endline:=procnum6-2;
       shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
      end
     else if(Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'while ')=0) or
     (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'while(')=0) then
      begin
       (tree.child+index-1)^.parent:=@tree;
       (tree.child+index-1)^.treetype:=5;
       (tree.child+index-1)^.content:=allocmem(sizeof(shell_loopstatement));
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.position:=procnum1+1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.length:=procnum2-procnum1-1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.state:=false;
       Pshell_loopstatement((tree.child+index-1)^.content)^.startline:=procnum5+2;
       Pshell_loopstatement((tree.child+index-1)^.content)^.endline:=procnum6-2;
       shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
      end
     else if(WstrpartcmpL(totalstr,procnum1+1,procnum2-procnum1-1,'do')=0) and
     ((Wstrpartcmp(totalstr,procnum3+1,procnum4-procnum3-1,'while ')=0) or
     (Wstrpartcmp(totalstr,procnum3+1,procnum4-procnum3-1,'while(')=0))then
      begin
       (tree.child+index-1)^.parent:=@tree;
       (tree.child+index-1)^.treetype:=6;
       (tree.child+index-1)^.content:=allocmem(sizeof(shell_loopstatement));
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.position:=procnum3+1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.length:=procnum4-procnum3-1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.state:=true;
       Pshell_loopstatement((tree.child+index-1)^.content)^.startline:=procnum5+2;
       Pshell_loopstatement((tree.child+index-1)^.content)^.endline:=procnum6-2;
       shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
      end
     else if(Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'case ')=0) then
      begin
       if(tree.parent^.treetype=3) then
        begin
         (tree.child+index-1)^.parent:=@tree;
         (tree.child+index-1)^.treetype:=7;
         (tree.child+index-1)^.content:=allocmem(sizeof(shell_switchitemstatement));
         Pshell_switchitemstatement((tree.child+index-1)^.content)^.itemvalue.position:=procnum1+1;
         Pshell_switchitemstatement((tree.child+index-1)^.content)^.itemvalue.length:=procnum2-procnum1-1;
         Pshell_switchitemstatement((tree.child+index-1)^.content)^.startline:=procnum5+2;
         Pshell_switchitemstatement((tree.child+index-1)^.content)^.endline:=procnum6-2;
         shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
        end
       else
        begin
         (tree.child+index-1)^.parent:=@tree;
         (tree.child+index-1)^.treetype:=0;
         (tree.child+index-1)^.content:=nil;
         shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
        end;
      end
     else
      begin
       (tree.child+index-1)^.parent:=@tree;
       (tree.child+index-1)^.treetype:=0;
       (tree.child+index-1)^.content:=nil;
       shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
      end;
    end
   else
    begin
     procnum1:=Wstrposorder(totalstr,#10,startindex,i-1);
     if(i-1=0) then procnum1:=0;
     procnum2:=Wstrposorder(totalstr,#10,startindex,i);
     procnum5:=i-1;
     i:=i+2;
     procnum3:=Wstrposorder(totalstr,#10,startindex,i-1);
     procnum4:=Wstrposorder(totalstr,#10,startindex,i);
     if(procnum4=0) then procnum4:=endindex;
     procnum6:=i+1;
     inc(stackindex,1);
     if(Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'if ')=0) or
     (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'if(')=0) or
     (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif ')=0) or
     (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif(')=0) or
     (WstrpartcmpL(totalstr,procnum1+1,procnum2-procnum1-1,'else ')=0) then
      begin
       (tree.child+index-1)^.parent:=@tree;
       (tree.child+index-1)^.treetype:=2;
       (tree.child+index-1)^.content:=allocmem(sizeof(shell_ifstatement));
       Pshell_ifstatement((tree.child+index-1)^.content)^.condition.position:=procnum1+1;
       Pshell_ifstatement((tree.child+index-1)^.content)^.condition.length:=procnum2-procnum1-1;
       Pshell_ifstatement((tree.child+index-1)^.content)^.startline:=procnum5+2;
       Pshell_ifstatement((tree.child+index-1)^.content)^.endline:=procnum6-2;
       if(mystack.stacksize>1) then
        begin
         if(Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'if ')=0) or
         (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'if(')=0) or
         (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif ')=0) or
         (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif(')=0) then
          begin
           Pshell_ifstatement((tree.child+index-1)^.content)^.havetop:=true;
          end
         else
          begin
           Pshell_ifstatement((tree.child+index-1)^.content)^.havetop:=false;
          end
        end;
       if(procnum6-1<totalline) then
        begin
         if(Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif ')=0) or
         (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'elseif(')=0) or
         (WstrpartcmpL(totalstr,procnum1+1,procnum2-procnum1-1,'else')=0) then
          begin
           Pshell_ifstatement((tree.child+index-1)^.content)^.havebuttom:=true;
          end
         else
          begin
           Pshell_ifstatement((tree.child+index-1)^.content)^.havebuttom:=false;
          end;
        end;
       shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
      end
     else if(Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'for ')=0) or
     (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'for(')=0) then
      begin
       (tree.child+index-1)^.parent:=@tree;
       (tree.child+index-1)^.treetype:=4;
       (tree.child+index-1)^.content:=allocmem(sizeof(shell_loopstatement));
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.position:=procnum1+1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.length:=procnum2-procnum1-1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.state:=false;
       Pshell_loopstatement((tree.child+index-1)^.content)^.startline:=procnum5+2;
       Pshell_loopstatement((tree.child+index-1)^.content)^.endline:=procnum6-2;
       shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
      end
     else if(Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'while ')=0) or
     (Wstrpartcmp(totalstr,procnum1+1,procnum2-procnum1-1,'while(')=0) then
      begin
       (tree.child+index-1)^.parent:=@tree;
       (tree.child+index-1)^.treetype:=5;
       (tree.child+index-1)^.content:=allocmem(sizeof(shell_loopstatement));
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.position:=procnum1+1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.length:=procnum2-procnum1-1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.state:=false;
       Pshell_loopstatement((tree.child+index-1)^.content)^.startline:=procnum5+2;
       Pshell_loopstatement((tree.child+index-1)^.content)^.endline:=procnum6-2;
       shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
      end
     else if(WstrpartcmpL(totalstr,procnum1+1,procnum2-procnum1-1,'do')=0) and
     ((Wstrpartcmp(totalstr,procnum3+1,procnum4-procnum3-1,'while ')=0) or
     (Wstrpartcmp(totalstr,procnum3+1,procnum4-procnum3-1,'while(')=0)) then
      begin
       (tree.child+index-1)^.parent:=@tree;
       (tree.child+index-1)^.treetype:=6;
       (tree.child+index-1)^.content:=allocmem(sizeof(shell_loopstatement));
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.position:=procnum3+1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.condition.length:=procnum4-procnum3-1;
       Pshell_loopstatement((tree.child+index-1)^.content)^.state:=true;
       Pshell_loopstatement((tree.child+index-1)^.content)^.startline:=procnum5+2;
       Pshell_loopstatement((tree.child+index-1)^.content)^.endline:=procnum6-2;
       shell_create_tree((tree.child+index-1)^,totalstr,procnum2+3,procnum3-3);
      end
     else
      begin
       (tree.child+index-1)^.parent:=@tree;
       (tree.child+index-1)^.treetype:=1;
       (tree.child+index-1)^.content:=allocmem(sizeof(shell_expression));
       Pshell_expression((tree.child+index-1)^.content)^.content.position:=procnum1+1;
       Pshell_expression((tree.child+index-1)^.content)^.content.length:=procnum2-procnum1-1;
      end;
    end;
  end;
end;
procedure shell_variable_list_item_add(var varlist:shell_variable_list;varname:PWideChar;
vartype:byte;varvalue:Pointer);
begin
 inc(varlist.itemcount);
 ReallocMem(varlist.itemlist,sizeof(shell_variable_list_item)*varlist.itemcount);
 (varlist.itemlist+varlist.itemcount-1)^.varname:=shell_PwideCharToVarName(varname);
 (varlist.itemlist+varlist.itemcount-1)^.vartype:=vartype;
 if(vartype=shell_string) then
  begin
   (varlist.itemlist+varlist.itemcount-1)^.varvalue:=exe_heap_allocmem(sizeof(WideChar));
   PwideChar((varlist.itemlist+varlist.itemcount-1)^.varvalue)^:=#0;
  end
 else if(vartype=shell_int) then
  begin
   (varlist.itemlist+varlist.itemcount-1)^.varvalue:=exe_heap_allocmem(sizeof(natint));
   Pnatint((varlist.itemlist+varlist.itemcount-1)^.varvalue)^:=0;
  end;
end;
procedure shell_variable_list_item_change(var varlist:shell_variable_list;varname:PWideChar;varvalue:Pointer);
var i,itype,size,index:natuint;
begin
 i:=1;
 while(i<=varlist.itemcount) do
  begin
   if(WstrcmpL(@(varlist.itemlist+i-1)^.varname,varname)=0) then break;
   inc(i);
  end;
 itype:=(varlist.itemlist+i-1)^.vartype;
 if(i>varlist.itemcount) then exit;
 index:=i;
 if(itype=shell_string) then
  begin
   i:=0;
   size:=exe_heap_getmemsize((varlist.itemlist+i-1)^.varvalue);
   while(PWideChar(varvalue+i)^<>#0) do inc(i,2);
   exe_heap_reallocmem((varlist.itemlist+i-1)^.varvalue,sizeof(WideChar)*(i div 2)+1);
   i:=0;
   while(PWideChar(varvalue+i)^<>#0) do
    begin
     PWideChar((varlist.itemlist+i-1)^.varvalue+i)^:=PWideChar(varvalue+i)^;
     inc(i,2);
    end;
   for i:=1 to varlist.itemcount do
    begin
     if(i<>index) then
     (varlist.itemlist+i-1)^.varvalue:=Pointer(Pointer((varlist.itemlist+i-1)^.varvalue)-size);
    end;
  end
 else if(itype=shell_int) then
  begin
   Pnatint((varlist.itemlist+i-1)^.varvalue)^:=Pnatint(varvalue)^;
  end;
end;
function shell_variable_list_exist(varlist:shell_variable_list;varname:PWideChar):boolean;
var i:natuint;
begin
 i:=1;
 while(i<=varlist.itemcount) do
  begin
   if(WstrcmpL(@(varlist.itemlist+i-1)^.varname,varname)=0) then break;
   inc(i);
  end;
 if(i>varlist.itemcount) then exit(false) else exit(true);
end;
function shell_variable_list_index(varlist:shell_variable_list;varname:PWideChar):natuint;
var i:natuint;
begin
 i:=1;
 while(i<=varlist.itemcount) do
  begin
   if(WstrcmpL(@(varlist.itemlist+i-1)^.varname,varname)=0) then break;
   inc(i);
  end;
 if(i>varlist.itemcount) then exit(0) else exit(i);
end;
function shell_variable_list_item_compare(varlist:shell_variable_list;varname:PWidechar;comparevalue:Pointer):boolean;
var i:natuint;
begin
 i:=1;
 while(i<=varlist.itemcount) do
  begin
   if(WstrcmpL(@(varlist.itemlist+i-1)^.varname,varname)=0) then break;
   inc(i);
  end;
 if(i>varlist.itemcount) then exit(false);
 if((varlist.itemlist+i-1)^.vartype=shell_string) then
  begin
   if(WStrCmp(PWideChar(Comparevalue),PWideChar((varlist.itemlist+i-1)^.varvalue))=0) then exit(true)
   else exit(false);
  end
 else if((varlist.itemlist+i-1)^.vartype=shell_int) then
  begin
   if(Pnatint(comparevalue)^=Pnatint((varlist.itemlist+i-1)^.varvalue)^) then exit(true)
   else exit(false);
  end;
end;
procedure shell_variable_list_item_free(var varlist:shell_variable_list);
var i:natuint;
begin
 for i:=varlist.itemcount downto 1 do exe_heap_freemem((varlist.itemlist+i-1)^.varvalue);
 freemem(varlist.itemlist); varlist.itemcount:=0;
end;
function shell_expression_calculate(orgstr:PwideChar;varlist:shell_variable_list):natint;
var stack:shell_temporary_stack;
    calc:shell_temporary_calculate;
    expstr,partstr,partstr2:PWideChar;
    i,j,k,len,procnum:natuint;
    res:natint;
begin
 Wstrinit(expstr,65535);
 Wstrset(expstr,orgstr);
 stack.stacksize:=0; res:=0; len:=Wstrlen(expstr);
 for i:=1 to varlist.itemcount do
  begin
   if((varlist.itemlist+i-1)^.vartype<>shell_int) then continue;
   len:=Wstrlen(@(varlist.itemlist+i-1)^.varname);
   procnum:=Wstrpos(expstr,@(varlist.itemlist+i-1)^.varname,1);
   if(procnum=0) then continue;
   Wstrdelete(expstr,procnum,len);
   partstr:=IntToPWChar(Pnatint((varlist.itemlist+i-1)^.varvalue)^);
   Wstrinsert(expstr,partstr,procnum);
   Wstrfree(partstr);
  end;
 for i:=1 to len do
  begin
   if((expstr+i-1)^='(') then
    begin
     inc(stack.stacksize);
     stack.stackleft[stack.stacksize]:=i;
     stack.stackright[stack.stacksize]:=0;
    end
   else if((expstr+i-1)^=')') then
    begin
     j:=stack.stacksize;
     while(j>0) and (stack.stackright[j]<>0) do dec(j);
     if(j>0) then stack.stackright[j]:=i;
    end;
  end;
 if(stack.stacksize=0) then
  begin
   calc.count:=Wstrcount(expstr,'+',1)+Wstrcount(expstr,'-',1)+Wstrcount(expstr,'*',1)+
   Wstrcount(expstr,'/',1)+Wstrcount(expstr,'^',1);
   calc.number:=allocmem(sizeof(qword)*(calc.count+1));
   calc.sign:=allocmem(sizeof(byte)*calc.count);
   i:=1; k:=1; j:=0;
   while(k>0) do
    begin
     inc(j,1);
     k:=shell_natuint_minimum([Wstrpos(expstr,'+',i),Wstrpos(expstr,'-',i),Wstrpos(expstr,'*',i),Wstrpos(expstr,'/',i),Wstrpos(expstr,'^',i)]);
     if(k=$FFFFFFFF) then k:=len+1;
     partstr:=Wstrcopy(expstr,i,k-1);
     (calc.number+j-1)^:=PWCharToInt(partstr);
     Wstrfree(partstr);
     partstr:=Wstrcopy(expstr,i,k-1);
     (calc.number+j-1)^:=PWCharToInt(partstr);
     Wstrfree(partstr);
     if(k=len+1) then break;
     if((expstr+k-1)^='+') then (calc.sign+j-1)^:=0
     else if((expstr+k-1)^='-') then (calc.sign+j-1)^:=1
     else if((expstr+k-1)^='*') then (calc.sign+j-1)^:=2
     else if((expstr+k-1)^='/') then (calc.sign+j-1)^:=3
     else if((expstr+k-1)^='^') then (calc.sign+j-1)^:=4
     else if((expstr+k-1)^='%') then (calc.sign+j-1)^:=5;
     Wstrfree(partstr);
     i:=k+1;
    end;
   i:=0;
   while(i<j-1) do
    begin
     inc(i,1);
     if((calc.sign+i-1)^=4) then
      begin
       (calc.number+i)^:=IntPower((calc.number+i-1)^,(calc.number+i)^);
       (calc.sign+i-1)^:=0;
      end
     else if((calc.sign+i-1)^=2) then
      begin
       (calc.number+i)^:=(calc.number+i-1)^*(calc.number+i)^;
       (calc.sign+i-1)^:=0;
      end
     else if((calc.sign+i-1)^=3) then
      begin
       (calc.number+i)^:=optimize_integer_divide((calc.number+i-1)^,(calc.number+i)^);
       (calc.sign+i-1)^:=0;
      end
     else if((calc.sign+i-1)^=5) then
      begin
       (calc.number+i)^:=optimize_integer_modulo((calc.number+i-1)^,(calc.number+i)^);
       (calc.sign+i-1)^:=0;
      end;
    end;
   i:=0;
   while(i<j-1) do
    begin
     inc(i,1);
     if((calc.sign+i-1)^=0) then
      begin
       (calc.number+i)^:=(calc.number+i-1)^+(calc.number+i)^;
       (calc.number+i-1)^:=0;
      end
     else if((calc.sign+i-1)^=1) then
      begin
       (calc.number+i)^:=(calc.number+i-1)^-(calc.number+i)^;
       (calc.number+i-1)^:=0;
      end;
    end;
   res:=(calc.number+i)^;
   freemem(calc.number);
   freemem(calc.sign);
   calc.count:=0;
  end
 else if(stack.stacksize>0) then
  begin
   partstr:=Wstrcutout(expstr,stack.stackleft[1]+1,stack.stackright[1]-1);
   res:=shell_expression_calculate(partstr,varlist);
   partstr2:=IntToPWChar(res);
   Wstrdelete(expstr,stack.stackleft[1],stack.stackright[1]);
   Wstrinsert(expstr,partstr2,stack.stackleft[1]);
   Wstrfree(partstr2);
   Wstrfree(partstr);
  end;
 Wstrfree(expstr);
 shell_expression_calculate:=res;
end;
function shell_expression_calculate_string(orgstr:PWideChar;varlist:shell_variable_list):PWideChar;
var expstr,partstr,partstr2:PWideChar;
    i,len,procnum:natuint;
    res:PWideChar;
begin
 Wstrinit(expstr,65535);
 Wstrset(expstr,orgstr);
 res:=nil; len:=Wstrlen(expstr);
 for i:=1 to varlist.itemcount do
  begin;
   if((varlist.itemlist+i-1)^.vartype=shell_string) then
    begin
     Wstrinit(partstr,Wstrlen(@(varlist.itemlist+i-1)^.varname)+3);
     Wstrset(partstr,'$(');
     Wstrcat(partstr,@(varlist.itemlist+i-1)^.varname);
     Wstrcat(partstr,')');
     len:=Wstrlen(partstr);
     procnum:=Wstrpos(expstr,partstr,1);
     if(procnum=0) then continue;
     Wstrdelete(expstr,procnum,len);
     Wstrfree(partstr);
     len:=Wstrlen(PwideChar((varlist.itemlist+i-1)^.varvalue));
     partstr:=Wstrcopy(PwideChar((varlist.itemlist+i-1)^.varvalue),1,len);
    end
   else
    begin
     len:=Wstrlen(@(varlist.itemlist+i-1)^.varname);
     procnum:=Wstrpos(expstr,@(varlist.itemlist+i-1)^.varname,1);
     if(procnum=0) then continue;
     Wstrdelete(expstr,procnum,len);
     partstr:=IntToPWChar(Pnatint((varlist.itemlist+i-1)^.varvalue)^);
    end;
   Wstrinsert(expstr,partstr,procnum);
   Wstrfree(partstr);
  end;
 shell_expression_calculate_string:=expstr;
end;
function shell_condition_calculate(conditionstr:PWideChar;varlist:shell_variable_list):boolean;
var condstr,partstr,partstr1,partstr2,partstr3:PWideChar;
    procnum1,procnum2,procnum3,procnum4:natuint;
    status,ftype:byte;
    stack:shell_temporary_stack;
    condlist:shell_temporary_condition;
    resstr:PWideChar;
    inverse,res:boolean;
    i,j,k,m,n,len,len2,procnum,baseindex,baselen:natuint;
begin
 Wstrinit(condstr,65535);
 Wstrset(condstr,conditionstr);
 res:=false; len:=Wstrlen(condstr); stack.stacksize:=0;
 for i:=1 to varlist.itemcount do
  begin;
   if((varlist.itemlist+i-1)^.vartype=shell_string) then
    begin
     Wstrinit(partstr,Wstrlen(@(varlist.itemlist+i-1)^.varname)+3);
     Wstrset(partstr,'$(');
     Wstrcat(partstr,@(varlist.itemlist+i-1)^.varname);
     Wstrcat(partstr,')');
     len:=Wstrlen(partstr);
     procnum:=Wstrpos(condstr,partstr,1);
     if(procnum=0) then continue;
     Wstrdelete(condstr,procnum,len);
     Wstrfree(partstr);
     len:=Wstrlen(PwideChar((varlist.itemlist+i-1)^.varvalue));
     partstr:=Wstrcopy(PwideChar((varlist.itemlist+i-1)^.varvalue),1,len);
    end
   else
    begin
     len:=Wstrlen(@(varlist.itemlist+i-1)^.varname);
     procnum:=Wstrpos(condstr,@(varlist.itemlist+i-1)^.varname,1);
     if(procnum=0) then continue;
     Wstrdelete(condstr,procnum,len);
     partstr:=IntToPWChar(Pnatint((varlist.itemlist+i-1)^.varvalue)^);
    end;
   Wstrinsert(condstr,partstr,procnum);
   Wstrfree(partstr);
  end;
 for i:=1 to len do
  begin
   if((condstr+i-1)^='(') then
    begin
     inc(stack.stacksize);
     stack.stackleft[stack.stacksize]:=i;
     stack.stackright[stack.stacksize]:=0;
     if(i>1) then
      begin
       j:=i-1;
       while((((condstr+j-1)^>='a') and ((condstr+j-1)^<='z')) or (((condstr+j-1)^>='A')
       and ((condstr+j-1)^<='Z')) or
       (((condstr+j-1)^>='0') and ((condstr+j-1)^<='9')) or ((condstr+j-1)^='_')) do
        begin
         dec(j);
        end;
       partstr:=WStrcutout(condstr,j+1,i-1);
       stack.isfunc[stack.stacksize]:=shell_is_function_name(partstr);
      end;
    end
   else if((condstr+i-1)^=')') then
    begin
     j:=stack.stacksize;
     while(j>0) and (stack.stackright[j]<>0) do dec(j);
     if(j>0) then stack.stackright[j]:=i;
    end;
  end;
 if(stack.stacksize=0) then
  begin
   i:=0; condlist.count:=0;
   while(i<=len) do
    begin
     inc(i,1);
     if((condstr+i-1)^='&') then
      begin
       if(i<len) and ((condstr+i)^='&') then
        begin
         inc(i,2); inc(condlist.count);
        end
       else
        begin
         inc(condlist.count);
        end;
      end
     else if((condstr+i-1)^='|') then
      begin
       if(i<len) and ((condstr+i)^='|') then
        begin
         inc(i,2); inc(condlist.count);
        end
       else
        begin
         inc(condlist.count);
        end;
      end
    end;
   condlist.condition:=allocmem(condlist.count);
   condlist.sign:=allocmem(condlist.count);
   i:=0; j:=0; baseindex:=0; baselen:=0;
   while(i<=len) do
    begin
     inc(i,1);
     if((condstr+i-1)^='&') then
      begin
       inc(j,1);
       if(baseindex>0) then
        begin
         if((condstr+baseindex-1)^='!') then
          begin
           inverse:=true;
           partstr:=Wstrcopy(condstr,baseindex+1,baselen);
           len2:=Wstrlen(partstr);
          end
         else
          begin
           inverse:=false;
           partstr:=Wstrcopy(condstr,baseindex,baselen);
           len2:=Wstrlen(partstr);
          end;
         j:=1; k:=1;
         if(partstr^='-') and ((partstr+1)^>='0') and ((partstr+1)^<='9') then
          begin
           ftype:=shell_int;
          end
         else if(partstr^>='0') and (partstr^<='9') then
          begin
           ftype:=shell_int;
          end
         else
          begin
           ftype:=shell_string;
          end;
         procnum1:=Wstrpos(condstr,'==',j);
         procnum2:=Wstrpos(condstr,'!=',j);
         procnum3:=Wstrpos(condstr,'>',j);
         procnum4:=Wstrpos(condstr,'<',j);
         k:=shell_natuint_minimum([procnum1,procnum2,procnum3,procnum4]); status:=0;
         if(k=procnum1) or (k=procnum2) then
          begin
           if(k=procnum1) then status:=1 else status:=0;
           n:=k-1; m:=k+2;
          end;
         if(k=procnum3) or (k=procnum4) then
          begin
           if((partstr1+k)^='=') then
            begin
             n:=k-1; m:=k+2; if(k=procnum3) then status:=5 else status:=4;
            end
           else
            begin
             n:=k-1; m:=k+1; if(k=procnum3) then status:=3 else status:=2;
            end;
          end;
         partstr2:=Wstrcopy(partstr1,1,n);
         partstr3:=Wstrcopy(partstr2,m,len2-m+1);
         if(status=0) then
          begin
           (condlist.condition+j-1)^:=WstrcmpL(partstr2,partstr3)=0;
          end
         else if(status=1) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)<>0;
          end
         else if(status=2) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)>0;
          end
         else if(status=3) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)<0;
          end
         else if(status=4) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)>=0;
          end
         else if(status=5) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)<=0;
          end;
         if(inverse=true) then (condlist.condition+j-1)^:=not (condlist.condition+j-1)^;
         Wstrfree(partstr3);
         Wstrfree(partstr2);
         Wstrfree(partstr);
         baseindex:=0; baselen:=0;
        end;
       if(i<len) and ((condstr+i)^='&') then
        begin
         inc(i,2); (condlist.sign+j-1)^:=0;
        end;
      end
     else if((condstr+i-1)^='|') then
      begin
       inc(j,1);
       if(baseindex>0) then
        begin
         if((condstr+baseindex-1)^='!') then
          begin
           inverse:=true;
           partstr:=Wstrcopy(condstr,baseindex+1,baselen);
           len2:=Wstrlen(partstr);
          end
         else
          begin
           inverse:=false;
           partstr:=Wstrcopy(condstr,baseindex,baselen);
           len2:=Wstrlen(partstr);
          end;
         j:=1; k:=1;
         procnum1:=Wstrpos(condstr,'==',j);
         procnum2:=Wstrpos(condstr,'!=',j);
         procnum3:=Wstrpos(condstr,'>',j);
         procnum4:=Wstrpos(condstr,'<',j);
         k:=shell_natuint_minimum([procnum1,procnum2,procnum3,procnum4]); status:=0;
         if(k=procnum1) or (k=procnum2) then
          begin
           if(k=procnum1) then status:=1 else status:=0;
           n:=k-1; m:=k+2;
          end;
         if(k=procnum3) or (k=procnum4) then
          begin
           if((partstr1+k)^='=') then
            begin
             n:=k-1; m:=k+2; if(k=procnum3) then status:=5 else status:=4;
            end
           else
            begin
             n:=k-1; m:=k+1; if(k=procnum3) then status:=3 else status:=2;
            end;
          end;
         partstr2:=Wstrcopy(partstr1,1,n);
         partstr3:=Wstrcopy(partstr2,m,len2-m+1);
         if(status=0) then
          begin
           (condlist.condition+j-1)^:=WstrcmpL(partstr2,partstr3)=0;
          end
         else if(status=1) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)<>0;
          end
         else if(status=2) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)>0;
          end
         else if(status=3) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)<0;
          end
         else if(status=4) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)>=0;
          end
         else if(status=5) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)<=0;
          end;
         if(inverse=true) then (condlist.condition+j-1)^:=not (condlist.condition+j-1)^;
         Wstrfree(partstr3);
         Wstrfree(partstr2);
         Wstrfree(partstr);
         baseindex:=0; baselen:=0;
        end;
       if(i<len) and ((condstr+i)^='|') then
        begin
         inc(i,2); (condlist.sign+j-1)^:=1;
        end;
      end
     else if(i=len) then
      begin
       if(baseindex>0) then
        begin
         if((condstr+baseindex-1)^='!') then
          begin
           inverse:=true;
           partstr:=Wstrcopy(condstr,baseindex+1,baselen);
           len2:=Wstrlen(partstr);
          end
         else
          begin
           inverse:=false;
           partstr:=Wstrcopy(condstr,baseindex,baselen);
           len2:=Wstrlen(partstr);
          end;
         j:=1; k:=1;
         procnum1:=Wstrpos(condstr,'==',j);
         procnum2:=Wstrpos(condstr,'!=',j);
         procnum3:=Wstrpos(condstr,'>',j);
         procnum4:=Wstrpos(condstr,'<',j);
         k:=shell_natuint_minimum([procnum1,procnum2,procnum3,procnum4]); status:=0;
         if(k=procnum1) or (k=procnum2) then
          begin
           if(k=procnum1) then status:=1 else status:=0;
           n:=k-1; m:=k+2;
          end;
         if(k=procnum3) or (k=procnum4) then
          begin
           if((partstr1+k)^='=') then
            begin
             n:=k-1; m:=k+2; if(k=procnum3) then status:=5 else status:=4;
            end
           else
            begin
             n:=k-1; m:=k+1; if(k=procnum3) then status:=3 else status:=2;
            end;
          end;
         if(k<>procnum1) and (k<>procnum2) and (k<>procnum3) and (k<>procnum4) then
          begin
           status:=6; n:=len;
          end;
         partstr2:=Wstrcopy(partstr1,1,n);
         if(n<len) then partstr3:=Wstrcopy(partstr2,m,len2-m+1) else partstr3:=nil;
         if(status=0) then
          begin
           (condlist.condition+j-1)^:=WstrcmpL(partstr2,partstr3)=0;
          end
         else if(status=1) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)<>0;
          end
         else if(status=2) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)>0;
          end
         else if(status=3) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)<0;
          end
         else if(status=4) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)>=0;
          end
         else if(status=5) then
          begin
           (condlist.condition+j-1)^:=WStrcmpL(partstr2,partstr3)<=0;
          end
         else if(status=6) then
          begin
           if(WstrcmpL(partstr2,'\T\')=0) then (condlist.condition+j-1)^:=true
           else (condlist.condition+j-1)^:=false;
          end;
         if(inverse=true) then (condlist.condition+j-1)^:=not (condlist.condition+j-1)^;
         Wstrfree(partstr3);
         Wstrfree(partstr2);
         Wstrfree(partstr);
         baseindex:=0; baselen:=0;
        end;
      end
     else
      begin
       if(baseindex=0) then baseindex:=i;
       if(baseindex>0) then inc(baselen);
      end;
    end;
   i:=1; res:=condlist.condition^;
   while(i<condlist.count) do
    begin
     if((condlist.sign+i-1)^=0) then
      begin
       res:=res and (condlist.condition+i)^;
      end
     else if((condlist.sign+i-1)^=1) then
      begin
       res:=res or (condlist.condition+i)^;
      end;
    end;
   shell_condition_calculate:=res;
  end
 else if(stack.stacksize>0) then
  begin
   partstr:=Wstrcutout(condstr,stack.stackleft[1]+1,stack.stackright[1]-1);
   if(stack.stackleft[1]>1) then
    begin
     j:=stack.stackleft[1]-1;
     while((((condstr+j-1)^>='a') and ((condstr+j-1)^<='z')) or (((condstr+j-1)^>='A')
     and ((condstr+j-1)^<='Z')) or
     (((condstr+j-1)^>='0') and ((condstr+j-1)^<='9')) or ((condstr+j-1)^='_')) do
      begin
       dec(j);
      end;
     partstr2:=WStrcutout(condstr,j+1,i-1);
     stack.isfunc[1]:=shell_is_function_name(partstr);
     if(stack.isfunc[1]) then
      begin
       if(WstrcmpL(partstr2,'fileexists')=0) then
        begin
         resstr:=shell_expression_calculate_string(partstr,varlist);
         res:=false;
         Wstrfree(resstr);
        end
       else if(WstrcmpL(partstr2,'isint')=0) then
        begin
         procnum:=shell_variable_list_index(varlist,partstr);
         if((varlist.itemlist+procnum-1)^.vartype=shell_int) then res:=true else res:=false;
        end
       else if(WstrcmpL(partstr2,'isstring')=0) then
        begin
         procnum:=shell_variable_list_index(varlist,partstr);
         if((varlist.itemlist+procnum-1)^.vartype=shell_string) then res:=true else res:=false;
        end;
      end
     else
      begin
       res:=shell_condition_calculate(partstr,varlist);
      end;
    end
   else
    begin
     res:=shell_condition_calculate(partstr,varlist);
    end;
   Wstrinit(partstr2,3);
   if(res=true) then Wstrset(partstr2,'\T\') else Wstrset(partstr2,'\F\');
   Wstrdelete(condstr,stack.stackleft[1],stack.stackright[1]);
   Wstrinsert(condstr,partstr2,stack.stackleft[1]);
   Wstrfree(partstr2);
   Wstrfree(partstr);
  end;
 Wstrfree(condstr);
end;
procedure shell_execute_tree(systemtable:Pefi_system_table;tree:shell_tree;totalstr:PWideChar;var varlist:shell_variable_list;var sysinfo:tydqfs_system_info;var sysindex:natuint);
var i,j,len:natuint;
    procnum,procnum1,procnum2,procnum3:natint;
    partstr1:PWideChar=nil;
    partstr2:PWideChar=nil;
    partstr3:PWideChar=nil;
    partstr4:PWideChar=nil;
    partstr5:PWideChar=nil;
    partstr6:PWideChar=nil;
    partstr7:PWideChar=nil;
    res:natint;
    resbool:boolean;
    resstr:PwideChar=nil;
    parentitem:shell_tree;
begin
 i:=1;
 if(tree.treetype=0) then
  begin
   for i:=1 to tree.childcount do
    begin
     shell_execute_tree(systemtable,tree,totalstr,varlist,sysinfo,sysindex);
    end;
  end
 else if(tree.treetype=1) then
  begin
   partstr1:=Wstrcopy(totalstr,Pshell_expression(tree.content)^.content.position,
   Pshell_expression(tree.content)^.content.length);
   procnum:=Wstrpos(partstr1,'=',1);
   if(procnum=0) then
    begin
     partstr2:=shell_expression_calculate_string(partstr1,varlist);
     console_command_parser(systemtable,sysinfo,sysindex,partstr2);
     Wstrfree(partstr2);
     Wstrfree(partstr1);
     exit;
    end;
   len:=Wstrlen(partstr1);
   partstr2:=Wstrcutout(partstr1,procnum+1,len);
   if((partstr1+procnum-2)^='+') then
    begin
     partstr3:=Wstrcopy(partstr1,1,procnum-2);
     if(shell_variable_list_exist(varlist,partstr3)) then
      begin
       res:=PWCharToUint(partstr1)+shell_expression_calculate(partstr2,varlist);
       shell_variable_list_item_change(varlist,partstr3,@res);
      end;
     Wstrfree(partstr3);
    end
   else if((partstr1+procnum-2)^='-') then
    begin
     partstr3:=Wstrcopy(partstr1,1,procnum-2);
     if(shell_variable_list_exist(varlist,partstr3)) then
      begin
       res:=PWCharToUint(partstr1)-shell_expression_calculate(partstr2,varlist);
       shell_variable_list_item_change(varlist,partstr3,@res);
      end;
     Wstrfree(partstr3);
    end
   else if((partstr1+procnum-2)^='*') then
    begin
     partstr3:=Wstrcopy(partstr1,1,procnum-2);
     if(shell_variable_list_exist(varlist,partstr3)) then
      begin
       res:=PWCharToUint(partstr1)*shell_expression_calculate(partstr2,varlist);
       shell_variable_list_item_change(varlist,partstr3,@res);
      end;
     Wstrfree(partstr3);
    end
   else if((partstr1+procnum-2)^='/') then
    begin
     partstr3:=Wstrcopy(partstr1,1,procnum-2);
     if(shell_variable_list_exist(varlist,partstr3)) then
      begin
       res:=optimize_integer_divide(PWCharToint(partstr1),shell_expression_calculate(partstr2,varlist));
       shell_variable_list_item_change(varlist,partstr3,@res);
      end;
     Wstrfree(partstr3);
    end
   else if((partstr1+procnum-2)^='%') then
    begin
     partstr3:=Wstrcopy(partstr1,1,procnum-2);
     if(shell_variable_list_exist(varlist,partstr3)) then
      begin
       res:=optimize_integer_modulo(PWCharToint(partstr1),shell_expression_calculate(partstr2,varlist));
       shell_variable_list_item_change(varlist,partstr3,@res);
      end;
     Wstrfree(partstr3);
    end
   else
    begin
     partstr3:=Wstrcopy(partstr1,1,procnum-1);
     res:=shell_expression_calculate(partstr3,varlist);
     if(procnum+1=len) and
     ((partstr1+procnum)^='-') and ((partstr1+procnum+1)^>='0') and ((partstr1+procnum+1)^<='9') then
      begin
       resstr:=shell_expression_calculate_string(partstr2,varlist);
       shell_variable_list_item_add(varlist,partstr3,shell_string,resstr);
       Wstrfree(resstr);
      end
     else if((partstr1+procnum)^>='0') and ((partstr1+procnum)^<='9') then
      begin
       res:=shell_expression_calculate(partstr2,varlist);
       partstr4:=IntToPWChar(res);
       shell_variable_list_item_add(varlist,partstr3,shell_int,partstr4);
       Wstrfree(partstr4);
      end;
     Wstrfree(partstr3);
    end;
   Wstrfree(partstr2);
   Wstrfree(partstr1);
  end
 else if(tree.treetype=2) then
  begin
   if(Wstrpartcmp(totalstr,Pshell_ifstatement(tree.content)^.condition.position,
   Pshell_ifstatement(tree.content)^.condition.length,'if ')=0) or
   (Wstrpartcmp(totalstr,Pshell_ifstatement(tree.content)^.condition.position,
    Pshell_ifstatement(tree.content)^.condition.length,'if(')=0) then
    begin
     if((totalstr+Pshell_ifstatement(tree.content)^.condition.position+2)^='(') then
      begin
       partstr3:=Wstrcopy(totalstr,Pshell_ifstatement(tree.content)^.condition.position+3,
       Pshell_ifstatement(tree.content)^.condition.length-3);
      end
     else
      begin
       partstr3:=Wstrcopy(totalstr,Pshell_ifstatement(tree.content)^.condition.position+3,
       Pshell_ifstatement(tree.content)^.condition.length-2);
      end;
     resbool:=shell_condition_calculate(partstr3,varlist);
     if(resbool=true) then
      begin
       for i:=1 to tree.childcount do
        begin
         shell_execute_tree(systemtable,tree,totalstr,varlist,sysinfo,sysindex);
        end;
      end;
     Wstrfree(partstr3);
    end
   else if(Wstrpartcmp(totalstr,Pshell_ifstatement(tree.content)^.condition.position,
   Pshell_ifstatement(tree.content)^.condition.length,'elseif ')=0) or
   (Wstrpartcmp(totalstr,Pshell_ifstatement(tree.content)^.condition.position,
    Pshell_ifstatement(tree.content)^.condition.length,'elseif(')=0) then
    begin
     if((totalstr+Pshell_ifstatement(tree.content)^.condition.position+2)^='(') then
      begin
       partstr3:=Wstrcopy(totalstr,Pshell_ifstatement(tree.content)^.condition.position+7,
       Pshell_ifstatement(tree.content)^.condition.length-7);
      end
     else
      begin
       partstr3:=Wstrcopy(totalstr,Pshell_ifstatement(tree.content)^.condition.position+7,
       Pshell_ifstatement(tree.content)^.condition.length-6);
      end;
     resbool:=shell_condition_calculate(partstr3,varlist);
     if(resbool=true) then
      begin
       for i:=1 to tree.childcount do
        begin
         shell_execute_tree(systemtable,tree,totalstr,varlist,sysinfo,sysindex);
        end;
      end;
     Wstrfree(partstr3);
    end
   else if(Wstrpartcmp(totalstr,Pshell_ifstatement(tree.content)^.condition.position,
   Pshell_ifstatement(tree.content)^.condition.length,'else')=0) then
    begin
     for i:=1 to tree.childcount do
      begin
       shell_execute_tree(systemtable,tree,totalstr,varlist,sysinfo,sysindex);
      end;
    end
  end
 else if(tree.treetype=3) then
  begin
   for i:=1 to tree.childcount do
    begin
     shell_execute_tree(systemtable,tree,totalstr,varlist,sysinfo,sysindex);
    end;
  end
 else if(tree.treetype=4) then
  begin
   if((Wstrpartcmp(totalstr,Pshell_loopstatement(tree.content)^.condition.position,
   Pshell_loopstatement(tree.content)^.condition.length,'for ')=0) or
   (Wstrpartcmp(totalstr,Pshell_loopstatement(tree.content)^.condition.position,
    Pshell_loopstatement(tree.content)^.condition.length,'for(')=0))
   and (Pshell_loopstatement(tree.content)^.state=false) then
    begin
     if((totalstr+Pshell_loopstatement(tree.content)^.condition.position+3)^='(') then
      begin
       partstr3:=Wstrcopy(totalstr,Pshell_loopstatement(tree.content)^.condition.position+4,
       Pshell_loopstatement(tree.content)^.condition.length-4);
      end
     else
      begin
       partstr3:=Wstrcopy(totalstr,Pshell_loopstatement(tree.content)^.condition.position+4,
       Pshell_loopstatement(tree.content)^.condition.length-3);
      end;
     len:=Wstrlen(partstr3); procnum:=Wstrpos(partstr3,':',1);
     partstr4:=Wstrcopy(partstr3,1,procnum-1);
     partstr5:=Wstrcutout(partstr3,procnum+1,len);
     partstr6:=Wstrcutout(partstr4,Wstrpos(partstr4,'=',1)+1,Wstrlen(partstr4));
     res:=shell_expression_calculate(partstr6,varlist);
     partstr7:=IntToPWChar(res); procnum3:=PWCharToInt(partstr5);
     shell_variable_list_item_add(varlist,partstr3,shell_int,@res);
     if(res>=procnum3) then
      begin
       for j:=res downto procnum3 do
        begin
         for i:=1 to tree.childcount do
          begin
           shell_execute_tree(systemtable,tree,totalstr,varlist,sysinfo,sysindex);
          end;
        end;
      end
     else if(res<procnum3) then
      begin
       for j:=res to procnum3 do
        begin
         for i:=1 to tree.childcount do
          begin
           shell_execute_tree(systemtable,tree,totalstr,varlist,sysinfo,sysindex);
          end;
        end;
      end;
     Wstrfree(partstr7);
     Wstrfree(partstr6);
     Wstrfree(partstr5);
     Wstrfree(partstr4);
    end;
  end
 else if(tree.treetype=5) then
  begin
   if((Wstrpartcmp(totalstr,Pshell_loopstatement(tree.content)^.condition.position,
   Pshell_loopstatement(tree.content)^.condition.length,'while ')=0) or
   (Wstrpartcmp(totalstr,Pshell_loopstatement(tree.content)^.condition.position,
    Pshell_loopstatement(tree.content)^.condition.length,'while(')=0))
   and (Pshell_loopstatement(tree.content)^.state=false) then
    begin
     if((totalstr+Pshell_loopstatement(tree.content)^.condition.position+2)^='(') then
      begin
       partstr3:=Wstrcopy(totalstr,Pshell_loopstatement(tree.content)^.condition.position+6,
       Pshell_loopstatement(tree.content)^.condition.length-6);
      end
     else
      begin
       partstr3:=Wstrcopy(totalstr,Pshell_loopstatement(tree.content)^.condition.position+6,
       Pshell_loopstatement(tree.content)^.condition.length-5);
      end;
     resbool:=shell_condition_calculate(partstr3,varlist);
     while(resbool=true) do
      begin
       resbool:=shell_condition_calculate(partstr3,varlist);
       for i:=1 to tree.childcount do
        begin
         shell_execute_tree(systemtable,tree,totalstr,varlist,sysinfo,sysindex);
        end;
      end;
     Wstrfree(partstr3);
    end
  end
 else if(tree.treetype=6) then
  begin
   if((Wstrpartcmp(totalstr,Pshell_loopstatement(tree.content)^.condition.position,
   Pshell_loopstatement(tree.content)^.condition.length,'while ')=0) or
   (Wstrpartcmp(totalstr,Pshell_loopstatement(tree.content)^.condition.position,
    Pshell_loopstatement(tree.content)^.condition.length,'while(')=0))
   and (Pshell_loopstatement(tree.content)^.state=true) then
    begin
     if((totalstr+Pshell_loopstatement(tree.content)^.condition.position+2)^='(') then
      begin
       partstr3:=Wstrcopy(totalstr,Pshell_loopstatement(tree.content)^.condition.position+6,
       Pshell_loopstatement(tree.content)^.condition.length-6);
      end
     else
      begin
       partstr3:=Wstrcopy(totalstr,Pshell_loopstatement(tree.content)^.condition.position+6,
       Pshell_loopstatement(tree.content)^.condition.length-5);
      end;
     resbool:=shell_condition_calculate(partstr3,varlist);
     repeat
      begin
       for i:=1 to tree.childcount do
        begin
         shell_execute_tree(systemtable,tree,totalstr,varlist,sysinfo,sysindex);
        end;
      end;
     until(resbool=false);
     Wstrfree(partstr3);
    end
  end
 else if(tree.treetype=7) then
  begin
   parentitem:=tree.parent^;
   if(parentitem.treetype=3) then
    begin
     partstr1:=Wstrcopy(totalstr,Pshell_switchstatement(parentitem.content)^.condition.position,
     Pshell_switchstatement(parentitem.content)^.condition.length);
     len:=Wstrlen(partstr1);
     if((partstr1+6)^='(') then
      begin
       partstr2:=Wstrcopy(partstr1,7,len-7);
      end
     else
      begin
       partstr2:=Wstrcopy(partstr1,7,len-6);
      end;
     partstr3:=Wstrcopy(totalstr,Pshell_switchitemstatement(tree.content)^.itemvalue.position+5,
     Pshell_switchitemstatement(tree.content)^.itemvalue.length-5);
     procnum:=shell_variable_list_index(varlist,partstr1);
     if((varlist.itemlist+procnum-1)^.vartype=shell_string) then
      begin
       if(shell_variable_list_item_compare(varlist,partstr1,partstr3)=true) then
        begin
         for i:=1 to tree.childcount do
          begin
           shell_execute_tree(systemtable,tree,totalstr,varlist,sysinfo,sysindex);
          end;
        end;
      end
     else if((varlist.itemlist+procnum-1)^.vartype=shell_int) then
      begin
       procnum:=PWCharToInt(partstr3);
       if(shell_variable_list_item_compare(varlist,partstr1,@procnum)=true) then
        begin
         for i:=1 to tree.childcount do
          begin
           shell_execute_tree(systemtable,tree,totalstr,varlist,sysinfo,sysindex);
          end;
        end;
      end;
    end;
  end;
end;
procedure shell_destroy_tree(tree:shell_tree);
var i:natuint;
begin
 if(tree.child=nil) then
  begin
   freemem(tree.content);
  end
 else
  begin
   for i:=tree.childcount downto 1 do
    begin
     shell_destroy_tree((tree.child+i-1)^);
    end;
   freemem(tree.child);
   freemem(tree.content);
   tree.childcount:=0;
  end;
end;  
procedure shell_execute_code(systemtable:Pefi_system_table;edl:efi_disk_list;diskindex:natuint;filename:PWideChar;userlevel:byte;var sysinfo:tydqfs_system_info;var sysindex:natuint);[public,alias:'shell_execute_code'];
var syntax_tree:shell_tree;
    i,fsp:natuint;
    fsf:tydqfs_file;
    fsd:tydqfs_data;
    content,partstr:PWideChar;
    error_list:shell_error_list;
    variable_list:shell_variable_list;
begin
 if(userlevel=userlevel_system) then fsf:=tydq_fs_file_info(edl,diskindex,filename,userlevel,1)
 else fsf:=tydq_fs_file_info(edl,diskindex,filename,userlevel,sysindex);
 fsp:=tydq_fs_file_position(edl,diskindex,filename);
 if(fsf.fattribute=0) then
  begin
   if(fsp>0) then efi_console_output_string(systemtable,'Shell code cannot be executed,permission denied.'#10)
   else efi_console_output_string(systemtable,'Shell code cannot be executed,file does not exist.'#10);
   exit;
  end;
 fsd:=tydq_fs_file_read(edl,diskindex,filename,1,fsf.fContentCount,userlevel,sysindex);
 error_list:=shell_check_code_str(PWideChar(fsd.fsdata));
 if(error_list.errorcount>0) then
  begin 
   for i:=1 to diskindex do
    begin
     efi_console_output_string(systemtable,filename);
     efi_console_output_string(systemtable,'(');
     partstr:=UintToPWChar((error_list.errorindex+i-1)^.errorrow);
     efi_console_output_string(systemtable,partstr);
     Wstrfree(partstr);
     efi_console_output_string(systemtable,',');
     partstr:=UintToPWChar((error_list.errorindex+i-1)^.errorcolumn);
     efi_console_output_string(systemtable,partstr);
     Wstrfree(partstr);
     efi_console_output_string(systemtable,'):');
     if((error_list.errorindex+i-1)^.errortype=0) then
      begin
       efi_console_output_string(systemtable,'Left brackets too many to match the right brackets.'#10);
      end
     else if((error_list.errorindex+i-1)^.errortype=1) then
      begin
       efi_console_output_string(systemtable,'The left bracket does not correspond to corresponding right bracket.'#10);
      end
     else if((error_list.errorindex+i-1)^.errortype=2) then
      begin
       efi_console_output_string(systemtable,'Two or more comparison sign is prohibited in one comparison statement.'#10);
      end
     else if((error_list.errorindex+i-1)^.errortype=3) then
      begin
       efi_console_output_string(systemtable,'The switch statement cannot undergo a expression but variable.'#10);
      end
     else if((error_list.errorindex+i-1)^.errortype=4) then
      begin
       efi_console_output_string(systemtable,'The switch statement cannot undergo a non-variable but variable.'#10);
      end
     else if((error_list.errorindex+i-1)^.errortype=5) then
      begin
       efi_console_output_string(systemtable,'Two or more comparison sign is prohibited in one loop comparison statement.'#10);
      end
     else if((error_list.errorindex+i-1)^.errortype=6) then
      begin
       efi_console_output_string(systemtable,'For statement lacks initial value of the variable.'#10);
      end
     else if((error_list.errorindex+i-1)^.errortype=7) then
      begin
       efi_console_output_string(systemtable,'For statement lakcs final value of the variable.'#10);
      end
     else if((error_list.errorindex+i-1)^.errortype=8) then
      begin
       efi_console_output_string(systemtable,'Cases not allowed to combined to one situation.'#10);
      end;
    end;
  end;
 freemem(error_list.errorindex);
 if(error_list.errorcount>0) then
  begin
   efi_console_output_string(systemtable,'Error occured so the shell code cannot be executed.'#10);
   freemem(fsd.fsdata); 
   exit;
  end;
 syntax_tree.parent:=nil; syntax_tree.content:=nil; syntax_tree.treetype:=0;
 variable_list.itemlist:=nil; variable_list.itemcount:=0;
 Wstrinit(content,4*1024*1024);
 Wstrset(content,PWideChar(fsd.fsdata));
 shell_create_tree(syntax_tree,content,1,Wstrlen(content));
 shell_execute_tree(systemtable,syntax_tree,content,variable_list,sysinfo,sysindex);
 shell_variable_list_item_free(variable_list);
 shell_destroy_tree(syntax_tree);
 Wstrfree(content);
 freemem(fsd.fsdata); fsd.fssize:=0;
end;

end.
