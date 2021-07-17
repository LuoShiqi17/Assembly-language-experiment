.386     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 VirtualProtect proto:dword,:dword,:dword,:dword
 includelib  kernel32.lib  ; ExitProcess �� kernel32.lib��ʵ��
 includelib  ucrt.lib ;�����������C������ʵ��
 printf          PROTO C :DWORD,:VARARG
 scanf           PROTO C :DWORD,:VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib
 stringcmp     proto 
 include winTimer.asm
 ;timeGetTime proto stdcall
 ;includelib  Winmm.lib

 mycalculate macro a,b,c,d,TP
    movzx eax,a
    movzx ebx,b
    movzx ecx,c
    movzx edx,d
    imul ebx,eax
    imul ecx,edx
    mov TP,ecx
    sub ebx,ecx
    mov eax,ebx
    imul eax,100
    endm

 .DATA
GOODS struct
    GOODSNAME  db  10 DUP(0)
    BUYPRICE  dw  0 ;���۱�����
    SELLPRICE  dw  0 ;�ۼ۱�����  ;����ֵ������Ա�����ֵ���б任
    BUYNUM  dw  0
    SELLNUM  dw  0
    RATE  sword  0
GOODS ENDS
lpFmt	db	"%s",0ah, 0dh, 0 ;����printf��ʽ�����
lpFmt1	db	"%s  %d  %d  %d  %d",0ah, 0dh, 0 ;����printf��ʽ�����
lpFmt2	db	"%d",0ah, 0dh, 0 ;����printf��ʽ�����
format  db  "%s",0 ;����scanf��ʽ������
format1  db  "%d",0 ;����scanf��ʽ������
choice  dd  0
XNAME  DB  24 DUP(0) ;���ڴ������
XPASS  DB  11 DUP(0) ;���ڴ������
BNAME DB   'LUOSHIQI', 16 DUP(0)
;BPASS DB   'U201914976',0
;BPASS DB  'U' xor '6','2' xor '7','0' xor '9','1' xor '4','9' xor '1','1' xor '9','4' xor '1','9' xor '0','7' xor '2','6' xor 'U',0
BPASS DB ('U'-30h)*4,('2'-30h)*4,('0'-30h)*4,('1'-30h)*4,('9'-30h)*4,('1'-30h)*4,('4'-30h)*4,('9'-30h)*4,('7'-30h)*4,('6'-30h)*4,0
GOOD   DB  10 DUP(0) ;���ڴ�Ż�������
SNUM   DD  0 ;���ڷ���������
ANUM   DD  0 ;���ڷŲ�������
N EQU 30   ;��30��������N
GA1 GOODS <'CHIPS', 15 xor 'a', 20 xor 'a', 70, 25, >
GA2 GOODS <'COOCKIE', 2 xor 'a', 3 xor 'a', 100, 50, >
GA3 GOODS <'COKE',30 xor 'a', 40 xor 'a', 25, 5, >
GA4 GOODS <'MILK', 3 xor 'a', 4 xor 'a', 200, 150, >
GAN GOODS N-4 DUP(<'TempValue',15,20,30,2,>)
len=$-GA1
oldprotect dd ?
PROFIT sword 0 ;���ڴ������
TPRO   sdword 0
x word 0 ;���������ʵļ���
tt dd 0 ;���ڼ�ʱ����
yy db 0 ;���ڵ�������
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
msg6  db   '5.Display product information according to profit margin from high to low', 0
msg7  db   '6.Exit', 0
ADRE  dd   30 DUP(0) ;�Ƚ������ʴ�С���ŵ�ַ
TAD   dd   0
FIR  dw  0
timesearch dd 0

.STACK 2000000

.CODE
;--------------------------------------------------------------------
;�ַ����Ƚ��ӳ���
stringcmp proc
    push ebp
    mov ebp,esp
    mov edi,[ebp+8] ;��XNAME�ĵ�ַ��edi
    mov esi,[ebp+12] ;��BNAME�ĵ�ַ��esi
    mov eax,0
    mov edx,0
strcmp_start:
    mov dl,[edi]
    cmp dl,[esi]
    jnz str_nequal
    cmp dl,0
    jz str_equal
    inc edi
    inc esi
    jmp strcmp_start
str_nequal:
    mov eax,1 ;�ַ��������eax����1
    jmp str_exit
str_equal:
    mov eax,0 ;�ַ������eax����0
str_exit:
    pop ebp
    ret
stringcmp endp
;--------------------------------------------------------------------
;��ʾ��Ʒ��Ϣ
displaygoods proc NAMEADDR:dword,GOODNAME:dword
    local ct:byte ;���ڼ���
    push ebp
    mov ebp,esp
    push eax
    push ebx
    push ecx
    push edx
    ;mov ecx,10
    ;mov eax,[ebp+20]
    mov edi,NAMEADDR+8
    ;mov esi,[ebp+20]
    mov esi,GOODNAME+8
    mov ct,0
    mov ebx,0
    mov edx,0
J1:
    push esi
    mov ecx,edi
    push edi
    call stringcmp
    add esp,8
    mov edi,ecx
    cmp eax,0
    jnz A1
    F1:
        cmp SNUM,0
        jz F2
        movzx eax,word ptr GA1[ebx].SELLNUM ;�޷�����չ
        cmp SNUM,eax
        jng F0
        mov ax,word ptr SNUM
        mov word ptr GA1[ebx].SELLNUM,ax
    F2:
        cmp ANUM,0
        jz F3
        mov ax,word ptr GA1[ebx].BUYNUM
        add ax,word ptr ANUM
        mov word ptr GA1[ebx].BUYNUM,ax
    F3:
        ;sub edi,10
        invoke printf,offset lpFmt1,edi,word ptr GA1[ebx].BUYPRICE,word ptr GA1[ebx].SELLPRICE,word ptr GA1[ebx].BUYNUM,word ptr GA1[ebx].SELLNUM
        jmp F01
A1:
    add ebx,20
    mov esi,GOODNAME+8
    add esi,ebx
    mov ecx,10
    add ct,20
    cmp ct,80
    jz F0
    jmp J1
F0:
    invoke printf,offset lpFmt,offset buf7
F01:
    pop edx
    pop ecx
    pop ebx
    pop eax
    mov esp,ebp
    pop ebp
    ret
displaygoods endp
;--------------------------------------------------------------------
;�����������ӳ���
calculaterate proc
    push ebp
    mov ebp,esp
    mov edi,[ebp+8]
LL:
    mov eax,0
    mov ebx,0
    mov ecx,0
    mov edx,0
    xor [edi].GOODS.SELLPRICE,'a'
    xor [edi].GOODS.BUYPRICE,'a'
    mycalculate word ptr [edi].GOODS.SELLPRICE,word ptr [edi].GOODS.SELLNUM,word ptr [edi].GOODS.BUYPRICE,word ptr [edi].GOODS.BUYNUM,TPRO
    cdq
    idiv TPRO
    mov TPRO,eax
    mov ax,sword ptr TPRO
    mov PROFIT,ax
    mov [edi].GOODS.RATE,ax
    ;invoke printf,offset lpFmt,edi
    ;invoke printf,offset lpFmt2,[edi].GOODS.RATE
    xor [edi].GOODS.SELLPRICE,'a'
    xor [edi].GOODS.BUYPRICE,'a'
    mov si,word ptr x
    movzx esi,si
    mov dword ptr ADRE[esi*4],edi ;ADRE����ŵ���GA1��2��3��4�ĵ�ַ
    add edi,20
    inc x
    cmp x,30
    jnz LL
    mov esp,ebp
    pop ebp
    ret
calculaterate endp
;--------------------------------------------------------------------
;��������
rankrate proc
    push ebp
    mov ebp,esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
rank_start:
    mov x,0
    mov edi,0
    mov esi,0
    cmp yy,29
    jz rank_exit
    inc yy
rank_body:
    mov si,word ptr x
    movzx esi,si
    mov edi,dword ptr ADRE[esi*4]
    mov dx,[edi].GOODS.RATE
    mov FIR,dx
    inc x
    mov si,word ptr x
    movzx esi,si
    mov edi,dword ptr ADRE[esi*4]
    mov dx,[edi].GOODS.RATE
    cmp FIR,dx ;���С�ڣ������ǰ��������λ�ã����ڵ�������ת��������λ�ã�
    jnl rank_body2
    mov edx,dword ptr ADRE[esi*4]
    mov TAD,edx
    mov edx,dword ptr ADRE[esi*4-4]
    mov dword ptr ADRE[esi*4],edx
    mov edx,TAD
    mov dword ptr ADRE[esi*4-4],edx
    cmp x,29
    jnz rank_body
    jmp rank_start
rank_body2:
    cmp x,29
    jz rank_start
    jmp rank_body
rank_exit:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    mov esp,ebp
    pop ebp
    ret
rankrate endp
;--------------------------------------------------------------------
main proc c
    mov eax,len
    mov ebx,40h
    lea ecx,copyhere
    invoke VirtualProtect,ecx,eax,ebx,offset oldprotect ;��̬�޸�ִ�д���
    invoke printf,offset lpFmt,offset buf2
    invoke scanf,offset format,offset XNAME
    invoke printf,offset lpFmt,offset buf3
    invoke scanf,offset format,offset XPASS
    ;invoke printf,offset format2,offset XNAME
    ;invoke printf,offset format3,offset XPASS
    invoke printf,offset lpFmt,offset buf1
just:
    xor bx,bx
    mov ax,bx
    mov cx,word ptr XNAME
    push offset XNAME
    push offset XPASS
    call stringcmp
    add esp,8 ;������޹ش���
    jz L0

    push offset BNAME
    push offset XNAME
    call stringcmp
    add esp,8
    cmp eax,0
    jnz NEQUAL ;�����
    mov edi,0
    mov ecx,10
    ;�������������ܱȽ�
na: mov al,XPASS[edi]
    sub al,30h
    mov ah,0
    imul ax,4
    mov byte ptr XPASS[edi],al
    dec ecx
    inc edi
    cmp ecx,0
    jnz na
    push offset BPASS
    push offset XPASS
    call stringcmp ;Ĭ����near���͵�
    ;call far ptr stringcmp
    add esp,8
    cmp eax,0
    jnz NEQUAL ;�����
    jz EQUAL ;���ֺ����붼ƥ��
NEQUAL:
    invoke printf,offset lpFmt,offset buf4
    jmp L0
EQUAL:
    ;��ʱ
    ;call	timeGetTime
    ;mov timesearch,eax

    mov SNUM,0

    ;��ʱ
    ;call	timeGetTime
    ;cmp eax,timesearch
    ;jnz L0

    mov ANUM,0
    mov edi,offset GOOD
    mov ecx,0
    T:
        mov al,0 ;ʹ�ַ���GOODΪ��
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
    invoke printf,offset lpFmt,offset msg7
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
    jz L5
    cmp choice,6
    jz L0
    cmp choice,0
    jae L
L1:
    invoke printf,offset lpFmt,offset buf6
    invoke scanf,offset format,offset GOOD
    mov ebx,0
    invoke displaygoods,offset GOOD,offset GA1
    add esp,8
    jmp EQUAL
L2:
    invoke printf,offset lpFmt,offset buf8
    invoke scanf,offset format,offset GOOD
    invoke scanf,offset format1,offset SNUM
    invoke displaygoods,offset GOOD,offset GA1
    add esp,8
    jmp EQUAL
L3:
    invoke printf,offset lpFmt,offset buf9
    invoke scanf,offset format,offset GOOD
    invoke scanf,offset format1,offset ANUM
    invoke displaygoods,offset GOOD,offset GA1
    add esp,8
    jmp EQUAL
L4:
    mov tt,0
    invoke winTimer,0 ;��ʼ��ʱ
TIN:
    mov yy,0
    mov x,0
    cmp tt,1000000
    jz TOUT
    inc tt
    push offset GA1
    call calculaterate
    add esp,4
L5:
    ;ADRE�������δ���GA1��2��3��4��δ�����
    call rankrate
    jmp TIN
TOUT:
    mov esi,0
TTOUT:
    invoke printf,offset lpFmt1,offset GA1,GA1[esi].BUYPRICE,GA1[esi].SELLPRICE,GA1[esi].BUYNUM,GA1[esi].SELLNUM
    invoke printf,offset lpFmt2,GA1[esi].RATE
    add esi,20
    cmp esi,600
    jnz TTOUT
    mov esi,0
TTOUT2:
    mov edi,dword ptr ADRE[esi]
    invoke printf,offset lpFmt1,edi,[edi].GOODS.BUYPRICE,[edi].GOODS.SELLPRICE,[edi].GOODS.BUYNUM,[edi].GOODS.SELLNUM
    invoke printf,offset lpFmt2,[edi].GOODS.RATE
    add esi,4
    cmp esi,120
    jnz TTOUT2
    invoke winTimer,1
    jmp EQUAL
L:
    invoke printf,offset lpFmt,offset buf7
    jmp EQUAL
copyhere:
    db len dup(0)
L0:
    invoke ExitProcess, 0
main endp

END