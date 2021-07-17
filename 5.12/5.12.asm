.386
.model   flat,stdcall
option   casemap:none

WinMain  proto :DWORD,:DWORD,:DWORD,:DWORD
WndProc  proto :DWORD,:DWORD,:DWORD,:DWORD ;�����ڵ���Ϣ�������
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

mycalculate macro a,b,c,d,TP ;ʵ��3.1���õ��ĺ�ָ��
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
lpFmt1	db	"%s  %d  %d  %d  %d",0ah, 0dh, 0 ;����printf��ʽ�����
lpFmt2	db	"%d",0ah, 0dh, 0 ;����printf��ʽ�����
PROFIT sword 0 ;���ڴ������
TPRO   sdword 0
x word 0 ;���������ʵļ���
tt dd 0 ;���ڼ�ʱ����
yy db 0 ;���ڵ�������
ADRE  dd   5 DUP(0) ;�Ƚ������ʴ�С���ŵ�ַ
TAD   dd   0
FIR  dw  0
xaddr dd 10
yaddr dd 10
num_string db 10 dup(' ') ;�����������ת���ɵ�ASCII��
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

;------------------------���������� WinMain----------------------
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

    mov    wc.lpszMenuName, offset menuname   ;;�����������û�в˵���

	mov wc.lpszClassName,offset szClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov wc.hIcon,eax
    invoke LoadCursor,NULL,IDC_ARROW
	mov wc.hCursor,eax
	invoke RegisterClassEx,addr wc
    invoke LoadMenu,hInst,IDM_MYMENU ;װ�ز˵�
	mov hMenu,eax ;�ڴ�������ʱ���ϲ˵�
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

;-------------------------��������Ϣ������� WndProc----------------------------
WndProc proc hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	LOCAL hdc:HDC
.IF uMsg==WM_COMMAND ;�˵��ϵ���Ϣ
	.IF wParam==IDM_FILE_EXIT
		invoke DestroyWindow,hWnd
		invoke PostQuitMessage,NULL
	.ELSEIF wParam==ID_ACTION_COMPUTERATE
		invoke calculaterate ;����������
    .ELSEIF wParam==ID_ACTION_LIST
        invoke rankrate ;����
        invoke displaygoods,hWnd ;��ʾ
	.ELSEIF wParam==IDM_HELP_ABOUT
		invoke MessageBox,hWnd,addr INFORMATION,addr szMessageBoxTitle,MB_OK          ;0
	.ENDIF ;�˵���Ϣ�������
.ELSEIF uMsg==WM_CLOSE ;�رմ�����Ϣ
		invoke PostQuitMessage,NULL
.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
.ENDIF
 xor eax,eax
 ret
WndProc endp

;-------------------����������--------------------
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
    mov dword ptr ADRE[esi*4],edi ;ADRE����ŵ���GA1��2��3��4�ĵ�ַ
    add edi,20
    inc x
    cmp x,5
    jnz LL
    mov esp,ebp
    pop ebp
    ret
calculaterate endp

;------------------------��������------------------------
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
    cmp FIR,dx ;���С�ڣ������ǰ��������λ�ã����ڵ�������ת��������λ�ã�
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

;----------------------��ʾ��Ʒ��Ϣ-----------------------
displaygoods proc hwnd:DWORD
    local ct:byte ;���ڼ���
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
;����ĸ������ת����ASCII���������Ļ
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