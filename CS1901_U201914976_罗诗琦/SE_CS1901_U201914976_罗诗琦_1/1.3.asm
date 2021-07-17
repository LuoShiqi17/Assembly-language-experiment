.386     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
 includelib  ucrt.lib ;这个库里面有C函数的实现
 printf          PROTO C :DWORD,:VARARG
 scanf           PROTO C :DWORD,:VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib

.DATA
lpFmt	db	"%s",0ah, 0dh, 0 ;用于printf格式化输出
lpFmt1	db	"%s  %d  %d  %d  %d",0ah, 0dh, 0 ;用于printf格式化输出
lpFmt2	db	"%hd",0ah, 0dh, 0 ;用于printf格式化输出
format  db  "%s",0 ;用于scanf格式化输入
format1  db  "%d",0 ;用于scanf格式化输入
choice  dd  0
XNAME  DB  24 DUP(0) ;用于存放名字
XPASS  DB  11 DUP(0) ;用于存放密码
BNAME DB   'LUOSHIQI', 16 DUP(0)
;LEN1  EQU  $-BNAME
BPASS DB   'U201914976',0
;LEN2  EQU  $-BPASS
GOOD   DB  10 DUP(0) ;用于存放货物名称
SNUM   DD  0 ;用于放销售数量
ANUM   DD  0 ;用于放补货数量
N EQU 30   ;将30赋给常数N
GA1   DB   'CHIPS',5 DUP(0);商品1：薯条
      DW   15, 20, 70, 25, ? ;进货价、销售价、进货数量、已售数量、利润率（尚未计算）
GA2   DB   'COOCKIE', 3 DUP(0) ;商品2：曲奇
      DW   2, 3, 100, 50, ?
GA3   DB   'COKE', 6 DUP(0) ;商品3：可乐
      DW   30, 40, 25, 5, ?
GA4   DB   'MILK', 6 DUP(0)  ;商品4：牛奶
      DW   3, 4, 200, 150, ?
GAN   DB N-4 DUP( 'TempValue’',0,15,0,20,0,30,0,2,0,?,?) ;除了4个已经具体定义了的商品信息以外，其他商品信息暂时假定为一样的。
PROFIT sword 0 ;用于存放利润
TPRO   sdword 0
PP    DW   0
RR    DD   0
AA    sdword 0
buf1  db   '**********************************************', 0
buf2  db   'Please enter your name:', 0
buf3  db   'Please enter your password:', 0
buf4  db   'Your name or password does not match', 0
buf5  db   'Please enter your choice:', 0
buf6  db   'Please enter the name of the good:', 0
buf7  db   'Good not found or invalid data', 0
buf8  db   'Please enter the name of the good and the sales volumes:', 0
buf9  db   'Please enter tne name of the good and number of replenishments', 0
format2  db   'name:%s', 0ah, 0dh, 0
format3  db   'password:%s', 0ah, 0dh, 0
msg1  db   'menu', 0
msg2  db   '1.Find goods and display information', 0
msg3  db   '2.Sales volumes', 0
msg4  db   '3.Replenishment', 0
msg5  db   '4.Calculate the profit margin of goods', 0
msg6  db   '5.Exit', 0

.STACK 2000000

.CODE
main proc c
    invoke printf,offset lpFmt,offset buf2
    invoke scanf,offset format,offset XNAME
    invoke printf,offset lpFmt,offset buf3
    invoke scanf,offset format,offset XPASS
    invoke printf,offset format2,offset XNAME
    invoke printf,offset format3,offset XPASS
    invoke printf,offset lpFmt,offset buf1
    mov ecx,24
    lea esi,BNAME
    mov edi,offset XNAME
    cld ;使DF为0
    repe cmpsb ;比较si和di的字符串
    jz JUDGEPASS ;名字相等
    jnz NEQUAL ;不相等
JUDGEPASS:
    mov ecx,11
    lea esi,BPASS
    mov edi,offset XPASS
    cld
    repe cmpsb
    jz EQUAL1
    jnz NEQUAL
NEQUAL:
    invoke printf,offset lpFmt,offset buf4
    lea esi,offset XNAME
    jmp L0
EQUAL1:
    mov SNUM,0
    mov ANUM,0
    mov edi,offset GOOD
    mov ecx,0
    T:
        mov al,0
        mov byte ptr [edi],al
        add edi,1
        add ecx,1
        cmp ecx,10
        jnz T
    invoke printf,offset lpFmt,offset msg1
    invoke printf,offset lpFmt,offset buf1
    invoke printf,offset lpFmt,offset msg2
    invoke printf,offset lpFmt,offset msg3
    invoke printf,offset lpFmt,offset msg4
    invoke printf,offset lpFmt,offset msg5
    invoke printf,offset lpFmt,offset msg6
    invoke printf,offset lpFmt,offset buf1
    invoke printf,offset lpFmt,offset buf5
    invoke scanf,offset format1,offset choice
    cmp choice,1
    jz L1
    cmp choice,2
    jz L2
    cmp choice,3
    jz L3
    cmp choice,4
    jz L4
    cmp choice,5
    jz L0
    cmp choice,0
    jae L
L1:
    invoke printf,offset lpFmt,offset buf6
    invoke scanf,offset format,offset GOOD
    lea esi,GOOD
    F1:
        mov ecx,10
        mov edi,offset GA1
        cld
        repe cmpsb
        jnz F2
        F1J1:
            cmp SNUM,0
            jz F1J2
                mov ax,word ptr[GA1+16]
                movzx eax,ax ;无符号扩展
                cmp SNUM,eax
                jng F0
                mov ax,word ptr SNUM
                mov word ptr [GA1+16],ax
                jmp F1J3
        F1J2:
            cmp ANUM,0
            jz F1J3
                mov ax,word ptr [GA1+14]
                cmp ANUM,0
                jng F0
                add ax,word ptr ANUM
                mov word ptr [GA1+14],ax
                jmp F1J3
        F1J3:
            mov ax,word ptr [GA1+10]
            mov bx,word ptr [GA1+12]
            mov cx,word ptr [GA1+14]
            mov dx,word ptr [GA1+16]
            invoke printf,offset lpFmt1,offset GA1,ax,bx,cx,dx
            jmp EQUAL1
    F2:
        lea esi,GOOD
        mov ecx,10
        mov edi,offset GA2
        cld
        repe cmpsb
        jnz F3
        F2J1:
            cmp SNUM,0
            jz F2J2
                mov ax,word ptr [GA2+16]
                movzx eax,ax
                cmp SNUM,eax
                jng F0
                mov ax,word ptr SNUM
                mov word ptr [GA2+16],ax
                jmp F2J3
        F2J2:
            cmp ANUM,0
            jz F2J3
                mov ax,word ptr [GA2+14]
                cmp ANUM,0
                jng F0
                add ax,word ptr ANUM
                mov word ptr [GA2+14],ax
                jmp F2J3
        F2J3:
            mov ax,word ptr [GA2+10]
            mov bx,word ptr [GA2+12]
            mov cx,word ptr [GA2+14]
            mov dx,word ptr [GA2+16]
            invoke printf,offset lpFmt1,offset GA2,ax,bx,cx,dx
        jmp EQUAL1
    F3:
        lea esi,GOOD
        mov ecx,10
        mov edi,offset GA3
        cld
        repe cmpsb
        jnz F4
        F3J1:
            cmp SNUM,0
            jz F3J2
                mov ax,word ptr [GA3+16]
                movzx eax,ax
                cmp SNUM,eax
                jng F0
                mov ax,word ptr SNUM
                mov word ptr [GA3+16],ax
                jmp F3J3
        F3J2:
            cmp ANUM,0
            jz F3J3
                mov ax,word ptr [GA3+14]
                cmp ANUM,0
                jng F0
                add ax,word ptr ANUM
                mov word ptr [GA3+14],ax
                jmp F3J3
        F3J3:
            mov ax,word ptr [GA3+10]
            mov bx,word ptr [GA3+12]
            mov cx,word ptr [GA3+14]
            mov dx,word ptr [GA3+16]
            invoke printf,offset lpFmt1,offset GA3,ax,bx,cx,dx
        jmp EQUAL1
    F4:
        lea esi,GOOD
        mov ecx,10
        mov edi,offset GA4
        cld
        repe cmpsb
        jnz F0
        F4J1:
            cmp SNUM,0
            jz F4J2
                mov ax,word ptr [GA4+16]
                movzx eax,ax
                cmp SNUM,eax
                jng F0
                mov ax,word ptr SNUM
                mov word ptr [GA4+16],ax
                jmp F4J3
        F4J2:
            cmp ANUM,0
            jz F4J3
                mov ax,word ptr [GA4+14]
                cmp ANUM,0
                jng F0
                add ax,word ptr ANUM
                mov word ptr [GA4+14],ax
                jmp F4J3
        F4J3:
            mov ax,word ptr [GA4+10]
            mov bx,word ptr [GA4+12]
            mov cx,word ptr [GA4+14]
            mov dx,word ptr [GA4+16]
            invoke printf,offset lpFmt1,offset GA4,ax,bx,cx,dx
        jmp EQUAL1
    F0:
        invoke printf,offset lpFmt,offset buf7
        jmp EQUAL1
L2:
    invoke printf,offset lpFmt,offset buf8
    invoke scanf,offset format,offset GOOD
    invoke scanf,offset format1,offset SNUM
    lea esi,GOOD
    jmp F1
L3:
    invoke printf,offset lpFmt,offset buf9
    invoke scanf,offset format,offset GOOD
    invoke scanf,offset format1,offset ANUM
    lea esi,GOOD
    jmp F1
L4:
    mov eax,0
    mov ebx,0
    mov ecx,0
    mov edx,0
    mov ax,word ptr [GA1+12]
    movzx eax,ax
    mov bx,word ptr [GA1+16]
    movzx ebx,bx
    imul ebx,eax ;销售量×售价
    mov cx,word ptr [GA1+10]
    movzx ecx,cx
    mov dx,word ptr [GA1+14]
    movzx edx,dx
    imul ecx,edx ;进货量×进价
    mov TPRO,ecx
    sub ecx,ebx ;ecx=ebx-ecx ;销售总价-进货总价=总利润
    mov eax,ecx
    imul eax,100
    cdq
    idiv TPRO
    mov TPRO,eax
    mov ax,sword ptr TPRO
    mov PROFIT,ax
    invoke printf,offset lpFmt,offset GA1
    invoke printf,offset lpFmt2,PROFIT
    mov eax,0
    mov ebx,0
    mov ecx,0
    mov edx,0
    mov ax,word ptr [GA2+12]
    mov bx,word ptr [GA2+16]
    imul ebx,eax
    mov cx,word ptr [GA2+10]
    mov dx,word ptr [GA2+14]
    imul ecx,edx
    mov TPRO,ecx
    sub ecx,ebx
    mov eax,ecx
    imul eax,100
    cdq
    idiv TPRO
    mov TPRO,eax
    mov ax,sword ptr TPRO
    mov PROFIT,ax
    invoke printf,offset lpFmt,offset GA2
    invoke printf,offset lpFmt2,PROFIT
    mov eax,0
    mov ebx,0
    mov ecx,0
    mov edx,0
    mov ax,word ptr [GA3+12]
    mov bx,word ptr [GA3+16]
    imul ebx,eax
    mov cx,word ptr [GA3+10]
    mov dx,word ptr [GA3+14]
    imul ecx,edx
    mov TPRO,ecx
    sub ecx,ebx
    mov eax,ecx
    imul eax,100
    cdq
    idiv TPRO
    mov TPRO,eax
    mov ax,sword ptr TPRO
    mov PROFIT,ax
    invoke printf,offset lpFmt,offset GA3
    invoke printf,offset lpFmt2,PROFIT
    mov eax,0
    mov ebx,0
    mov ecx,0
    mov edx,0
    mov ax,word ptr [GA4+12]
    mov bx,word ptr [GA4+16]
    imul ebx,eax
    mov cx,word ptr [GA4+10]
    mov dx,word ptr [GA4+14]
    imul ecx,edx
    mov PROFIT,cx
    sub ecx,ebx
    mov eax,ecx
    imul eax,100
    cdq
    idiv TPRO
    mov TPRO,eax
    mov ax,sword ptr TPRO
    mov PROFIT,ax
    invoke printf,offset lpFmt,offset GA4
    invoke printf,offset lpFmt2,PROFIT
    jmp EQUAL1
L:
    invoke printf,offset lpFmt,offset buf7
    jmp EQUAL1
L0:
    invoke ExitProcess, 0
main endp
END
