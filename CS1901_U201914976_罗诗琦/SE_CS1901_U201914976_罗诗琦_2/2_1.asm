.386     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess �� kernel32.lib��ʵ��
 includelib  ucrt.lib ;�����������C������ʵ��
 printf          PROTO C :DWORD,:VARARG
 scanf           PROTO C :DWORD,:VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib

 timeGetTime proto stdcall
 includelib  Winmm.lib

.DATA
GOODS struct
    GOODSNAME  db  10 DUP(0)
    BUYPRICE  dw  0
    SELLPRICE  dw  0
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
BPASS DB   'U201914976',0
GOOD   DB  10 DUP(0) ;���ڴ�Ż�������
SNUM   DD  0 ;���ڷ���������
ANUM   DD  0 ;���ڷŲ�������
N EQU 30   ;��30��������N
GA1 GOODS <'CHIPS', 15, 20, 70, 25, >
GA2 GOODS <'COOCKIE', 2, 3, 100, 50, >
GA3 GOODS <'COKE',30, 40, 25, 5, >
GA4 GOODS <'MILK', 3, 4, 200, 150, >
;GAN   DB N-4 DUP( 'TempValue��',0,15,0,20,0,30,0,2,0,?,?) ;����4���Ѿ����嶨���˵���Ʒ��Ϣ���⣬������Ʒ��Ϣ��ʱ�ٶ�Ϊһ���ġ�
GAN GOODS N-4 DUP(<'TempValue',15,20,30,2,>)
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

__t1		dd	?
__t2		dd	?
__fmtTime	db	0ah,0dh,"Time elapsed is %ld ms",2 dup(0ah,0dh),0

.STACK 2000000

.CODE
winTimer	proc stdcall, flag:DWORD
		jmp	__L1
__L1:		call	timeGetTime
		cmp	flag, 0
		jnz	__L2
		mov	__t1, eax
		ret	4
__L2:		mov	__t2, eax
		sub	eax, __t1
		invoke	printf,offset __fmtTime,eax
		ret	4
winTimer	endp
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
    cld ;ʹDFΪ0
    repe cmpsb ;�Ƚ�si��di���ַ���
    jz JUDGEPASS ;�������
    jnz NEQUAL ;�����
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
J1:
    lea esi,GOOD
    mov ebx,0
    mov edi,offset GA1
    F1:
        mov ecx,10
        mov eax,edi
        cld
        repe cmpsb
        jnz J2
        mov edi,eax
        F1J1:
            cmp SNUM,0
            jz F1J2
                movzx eax,word ptr GA1[ebx].SELLNUM ;�޷�����չ
                cmp SNUM,eax
                jng F0
                mov ax,word ptr SNUM
                mov word ptr GA1[ebx].SELLNUM,ax
                jmp F1J3
        F1J2:
            cmp ANUM,0
            jz F1J3
                mov ax,word ptr GA1[ebx].BUYNUM
                add ax,word ptr ANUM
                mov word ptr GA1[ebx].BUYNUM,ax
                jmp F1J3
        F1J3:
            invoke printf,offset lpFmt1,edi,word ptr GA1[ebx].BUYPRICE,word ptr GA1[ebx].SELLPRICE,word ptr GA1[ebx].BUYNUM,word ptr GA1[ebx].SELLNUM
            jmp EQUAL1
    J2:
        lea esi,GOOD
        mov edi,eax
        add ebx,20
        add edi,20
        cmp ebx,80
        jz F0
        jmp F1
    F0:
        invoke printf,offset lpFmt,offset buf7
        jmp EQUAL1
L2:
    invoke printf,offset lpFmt,offset buf8
    invoke scanf,offset format,offset GOOD
    invoke scanf,offset format1,offset SNUM
    jmp J1
L3:
    invoke printf,offset lpFmt,offset buf9
    invoke scanf,offset format,offset GOOD
    invoke scanf,offset format1,offset ANUM
    jmp J1
L4:
    mov tt,0
    invoke winTimer,0 ;��ʼ��ʱ
TIN:
    mov yy,0
    mov x,0
    cmp tt,1000
    jz TOUT ;��������
    inc tt
    mov edi,offset GA1
LL:
    mov eax,0
    mov ebx,0
    mov ecx,0
    mov edx,0
    mov ax,word ptr [edi].GOODS.SELLPRICE
    movzx eax,ax
    mov bx,word ptr [edi].GOODS.SELLNUM
    movzx ebx,bx
    imul ebx,eax ;���������ۼ�
    mov cx,word ptr [edi].GOODS.BUYPRICE
    movzx ecx,cx
    mov dx,word ptr [edi].GOODS.BUYNUM
    movzx edx,dx
    imul ecx,edx ;������������
    mov TPRO,ecx
    sub ebx,ecx ;ebx=ebx-ecx ;�����ܼ�-�����ܼ�=������
    mov eax,ebx
    imul eax,100
    cdq
    idiv TPRO
    mov TPRO,eax
    mov ax,sword ptr TPRO
    mov PROFIT,ax
    mov [edi].GOODS.RATE,ax
    ;invoke printf,offset lpFmt,edi
    ;invoke printf,offset lpFmt2,[edi].GOODS.RATE
    mov si,word ptr x
    movzx esi,si
    mov dword ptr ADRE[esi*4],edi ;ADRE����ŵ���GA1��2��3��4�ĵ�ַ
    add edi,20
    inc x
    cmp x,30
    jnz LL
L5:
    ;ADRE�������δ���GA1��2��3��4��δ�����
    mov x,0
    mov edi,0
    mov esi,0
    cmp yy,29
    jz TIN
    inc yy
L5L1:
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
    jnl L5L2
    mov edx,dword ptr ADRE[esi*4]
    mov TAD,edx
    mov edx,dword ptr ADRE[esi*4-4]
    mov dword ptr ADRE[esi*4],edx
    mov edx,TAD
    mov dword ptr ADRE[esi*4-4],edx
    cmp x,29
    jnz L5L1
    jmp L5
L5L2:
    cmp x,29
    jz L5
    jmp L5L1
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
    jmp EQUAL1
L:
    invoke printf,offset lpFmt,offset buf7
    jmp EQUAL1
L0:
    invoke ExitProcess, 0
main endp
END
