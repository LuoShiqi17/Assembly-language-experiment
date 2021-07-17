.386     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
 includelib  ucrt.lib ;这个库里面有C函数的实现
 printf          PROTO C :DWORD,:VARARG
 scanf           PROTO C :DWORD,:VARARG
 m_main  proto
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib
 include winTimer2.asm

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
    BUYPRICE  dw  0 ;unsigned short
    SELLPRICE  dw  0 ;unsigned short
    BUYNUM  dw  0 ;unsigned short
    SELLNUM  dw  0 ;unsigned short
    RATE  sword  0 ;short
GOODS ENDS
lpFmt	db	"%s",0ah, 0dh, 0 ;用于printf格式化输出
lpFmt1	db	"%s  %d  %d  %d  %d",0ah, 0dh, 0 ;用于printf格式化输出
lpFmt2	db	"%d",0ah, 0dh, 0 ;用于printf格式化输出
format  db  "%s",0 ;用于scanf格式化输入
format1  db  "%d",0 ;用于scanf格式化输入
choice  dd  0
XNAME  DB  24 DUP(0) ;用于存放名字
XPASS  DB  11 DUP(0) ;用于存放密码
BNAME DB   'LUOSHIQI', 16 DUP(0)
BPASS DB   'U201914976',0
GOOD   DB  10 DUP(0) ;用于存放货物名称
public GOOD
SNUM   DD  0 ;用于放销售数量
public SNUM
ANUM   DD  0 ;用于放补货数量
public ANUM
N EQU 30   ;将30赋给常数N
GA1 GOODS <'CHIPS', 15, 20, 70, 25, >
GA2 GOODS <'COOCKIE', 2, 3, 100, 50, >
GA3 GOODS <'COKE',30, 40, 25, 5, >
GA4 GOODS <'MILK', 3, 4, 200, 150, >
GAN GOODS N-4 DUP(<'TempValue',15,20,30,2,>)
new_good GOODS 30 DUP(<'0',0,0,0,0,0>)
public GA1
public GA2
public GA3
public GA4
public GAN
public new_good
PROFIT sword 0 ;用于存放利润
TPRO   sdword 0
x word 0 ;用于利润率的计数
public x
tt dd 0 ;用于计时计数
public tt
yy db 0 ;用于调换计数
public yy
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
ADRE  dd   60 DUP(0) ;比较利润率大小后存放地址
public ADRE
TAD   dd   0
FIR  dw  0
goods_num dd 30
public goods_num

.STACK 2000000

.CODE
;--------------------------------------------------------------------
;字符串比较子程序
stringcmp proc
    push ebp
    mov ebp,esp
    mov edi,[ebp+8] ;将XNAME的地址给edi
    mov esi,[ebp+12] ;将BNAME的地址给esi
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
    mov eax,1 ;字符串不相等eax返回1
    jmp str_exit
str_equal:
    mov eax,0 ;字符串相等eax返回0
str_exit:
    pop ebp
    ret
stringcmp endp
;--------------------------------------------------------------------
;显示商品信息
displaygoods proc NAMEADDR:dword,GOODNAME:dword
    local ct:dword ;用于计数
    push ebp
    mov ebp,esp
    push eax
    push ebx
    push ecx
    push edx
    mov edi,NAMEADDR+8
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
        movzx eax,word ptr GA1[ebx].SELLNUM ;无符号扩展
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
    inc ct
    mov eax,goods_num
    cmp ct,eax
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
;计算利润率子程序
calculaterate proc
    push ebp
    mov ebp,esp
    mov edi,[ebp+8]
LL:
    mov eax,0
    mov ebx,0
    mov ecx,0
    mov edx,0
    mycalculate word ptr [edi].GOODS.SELLPRICE,word ptr [edi].GOODS.SELLNUM,word ptr [edi].GOODS.BUYPRICE,word ptr [edi].GOODS.BUYNUM,TPRO
    cdq
    idiv TPRO
    mov TPRO,eax
    mov ax,sword ptr TPRO
    mov PROFIT,ax
    mov [edi].GOODS.RATE,ax
    mov si,word ptr x
    movzx esi,si
    mov dword ptr ADRE[esi*4],edi ;ADRE里面放的是GA1、2、3、4的地址
    add edi,20
    inc x
    mov eax,goods_num
    cmp x,ax
    ;cmp x,30
    jnz LL
    mov esp,ebp
    pop ebp
    ret
calculaterate endp
;--------------------------------------------------------------------
;利润排序
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
    cmp FIR,dx ;如果小于，则调换前后两个的位置，大于等于则跳转（不调换位置）
    jnl rank_body2
    mov edx,dword ptr ADRE[esi*4]
    mov TAD,edx
    mov edx,dword ptr ADRE[esi*4-4]
    mov dword ptr ADRE[esi*4],edx
    mov edx,TAD
    mov dword ptr ADRE[esi*4-4],edx
    mov eax,goods_num
    dec eax
    cmp x,ax
    ;cmp x,29
    jnz rank_body
    jmp rank_start
rank_body2:
mov eax,goods_num
    dec eax
    cmp x,ax
    ;cmp x,29
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

END