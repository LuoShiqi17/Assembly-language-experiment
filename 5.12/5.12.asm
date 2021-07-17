.386
.model   flat,stdcall
option   casemap:none

WinMain  proto :DWORD,:DWORD,:DWORD,:DWORD
WndProc  proto :DWORD,:DWORD,:DWORD,:DWORD ;主窗口的消息处理程序
calculaterate proto
rankrate proto
displaygoods proto:dword
changeABC proto:word

include      menuID.INC

include      windows.inc
include      user32.inc
include      kernel32.inc
include      gdi32.inc
include      shell32.inc

include resource.inc

includelib   user32.lib
includelib   kernel32.lib
includelib   gdi32.lib
includelib   shell32.lib

mycalculate macro a,b,c,d,TP ;实验3.1中用到的宏指令
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

.data
hInstance    dd       0
CommandLine  dd       0
GOODS struct
    GOODSNAME  db  10 DUP(' ')
    BUYPRICE  dw  0
    SELLPRICE  dw  0
    BUYNUM  dw  0
    SELLNUM  dw  0
    RATE  sword  0
GOODS ENDS
szClassName db "GoodsDisplay",0
titlename db 'Goods Displaying System Window',0
szMessageBoxTitle db 'About',0
menuname    DB  'MyMenu',0
DlgName	    DB  'MyDialog',0
INFORMATION		DB  'CS1901 LUOSHIQI',0	
GA1 GOODS <'CHIPS', 15, 20, 70, 25, >
GA2 GOODS <'COOCKIE', 2, 3, 100, 50, >
GA3 GOODS <'COKE',30, 40, 25, 5, >
GA4 GOODS <'MILK', 3, 4, 200, 150, >
GA5 GOODS <'SALAD', 15, 20, 30, 2, >
lpFmt1	db	"%s  %d  %d  %d  %d",0ah, 0dh, 0 ;用于printf格式化输出
lpFmt2	db	"%d",0ah, 0dh, 0 ;用于printf格式化输出
PROFIT sword 0 ;用于存放利润
TPRO   sdword 0
x word 0 ;用于利润率的计数
tt dd 0 ;用于计时计数
yy db 0 ;用于调换计数
ADRE  dd   5 DUP(0) ;比较利润率大小后存放地址
TAD   dd   0
FIR  dw  0
xaddr dd 10
yaddr dd 10
num_string db 10 dup(' ') ;用来存放数字转换成的ASCII码
neg_mark db '-'
zero_num db '0'

.code
start:
    invoke GetModuleHandle,NULL
    mov hInstance,eax
	invoke GetCommandLine
	mov CommandLine,eax
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke ExitProcess,eax

;------------------------窗口主程序 WinMain----------------------
WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
    LOCAL hMenu:HMENU
    invoke RtlZeroMemory,addr wc,sizeof wc
    mov wc.cbSize,SIZEOF WNDCLASSEX
	mov wc.style, CS_HREDRAW or CS_VREDRAW
	mov wc.lpfnWndProc, offset WndProc
    push hInst
	pop wc.hInstance
	mov wc.hbrBackground,COLOR_WINDOW+1

    mov    wc.lpszMenuName, offset menuname   ;;不加这个语句就没有菜单栏

	mov wc.lpszClassName,offset szClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov wc.hIcon,eax
    invoke LoadCursor,NULL,IDC_ARROW
	mov wc.hCursor,eax
	invoke RegisterClassEx,addr wc
    invoke LoadMenu,hInst,IDM_MYMENU ;装载菜单
	mov hMenu,eax ;在创建窗口时带上菜单
    invoke CreateWindowEx,NULL,addr szClassName,addr titlename,\
		   WS_OVERLAPPEDWINDOW,\
		   CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,\
		   NULL,hMenu,hInst,NULL
	mov hwnd,eax
	invoke ShowWindow,hwnd,SW_SHOWNORMAL
	invoke UpdateWindow,hwnd
StartLoop:
	invoke GetMessage,addr msg,NULL,0,0
	cmp eax,0
	je ExitLoop
	invoke TranslateMessage,addr msg
	invoke DispatchMessage,addr msg
	jmp StartLoop
ExitLoop:
	mov eax,msg.wParam
	ret
WinMain ENDP

;-------------------------主窗口消息处理程序 WndProc----------------------------
WndProc proc hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	LOCAL hdc:HDC
.IF uMsg==WM_COMMAND ;菜单上的消息
	.IF wParam==IDM_FILE_EXIT
		invoke DestroyWindow,hWnd
		invoke PostQuitMessage,NULL
	.ELSEIF wParam==ID_ACTION_COMPUTERATE
		invoke calculaterate ;计算利润率
    .ELSEIF wParam==ID_ACTION_LIST
        invoke rankrate ;排序
        invoke displaygoods,hWnd ;显示
	.ELSEIF wParam==IDM_HELP_ABOUT
		invoke MessageBox,hWnd,addr INFORMATION,addr szMessageBoxTitle,MB_OK          ;0
	.ENDIF ;菜单消息处理结束
.ELSEIF uMsg==WM_CLOSE ;关闭窗口消息
		invoke PostQuitMessage,NULL
.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
.ENDIF
 xor eax,eax
 ret
WndProc endp

;-------------------计算利润率--------------------
calculaterate proc
    push ebp
    mov ebp,esp
    mov edi,offset GA1
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
    cmp x,5
    jnz LL
    mov esp,ebp
    pop ebp
    ret
calculaterate endp

;------------------------利润排序------------------------
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
    cmp yy,4
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
    cmp x,4
    jnz rank_body
    jmp rank_start
rank_body2:
    cmp x,4
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

;----------------------显示商品信息-----------------------
displaygoods proc hwnd:DWORD
    local ct:byte ;用于计数
    local  hdc:HDC
    mov edi,dword ptr ADRE
    mov TAD,edi
    mov ct,0
    invoke GetDC,hwnd
    mov hdc,eax
J1:
    invoke TextOut,hdc,xaddr,yaddr,TAD,10
    add xaddr,50
    add edi,10
    mov bx,word ptr [edi]
    invoke changeABC,bx
    invoke TextOut,hdc,xaddr,yaddr,offset num_string,10
    add xaddr,50
    add edi,2
    mov bx,word ptr [edi]
    invoke changeABC,bx
    invoke TextOut,hdc,xaddr,yaddr,offset num_string,10
    add xaddr,50
    add edi,2
    mov bx,word ptr [edi]
    invoke changeABC,bx
    invoke TextOut,hdc,xaddr,yaddr,offset num_string,10
    add xaddr,50
    add edi,2
    mov bx,word ptr [edi]
    invoke changeABC,bx
    invoke TextOut,hdc,xaddr,yaddr,offset num_string,10
    add xaddr,50
    add edi,2
    mov bx,word ptr [edi]
    cmp bx,0
    jg pos
    je zero
    imul bx,-1
    invoke TextOut,hdc,xaddr,yaddr,offset neg_mark,1
    add xaddr,5
    jmp pos
zero:
    add xaddr,9
    invoke TextOut,hdc,xaddr,yaddr,offset zero_num,1
    invoke TextOut,hdc,xaddr,yaddr,offset zero_num,1
    jmp next
pos:
    invoke changeABC,bx
    invoke TextOut,hdc,xaddr,yaddr,offset num_string,10
    invoke TextOut,hdc,xaddr,yaddr,offset num_string,10
next:
    inc ct
    movzx edx,ct
    imul edx,4
    mov edi,dword ptr ADRE[edx]
    mov TAD,edi
    add yaddr,50
    mov xaddr,10
    cmp ct,5
    je F01
    jmp J1
F01:
    ret
displaygoods endp

;------------------------------------------------------
;将字母、数字转换成ASCII码输出到屏幕
changeABC proc num:word
    pusha
    mov ecx,0
count_start:
    mov num_string[ecx],' '
    inc ecx
    cmp ecx,9
    jnz count_start
    mov ecx,8
change_start:
    mov eax,0
    mov ax,num
    mov bh,10
    ;mov bl,0
    div bh
    cmp al,0
    jz change_exit
here:
    add ah,30H
    mov num_string[ecx],ah
    mov ah,0
    ;mov al,0
    mov num,ax
    dec ecx
    jmp change_start
change_exit:
    cmp ah,0
    jnz here
    popa
    ret
changeABC endp
end start