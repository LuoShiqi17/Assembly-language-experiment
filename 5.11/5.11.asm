.386
.model   flat,stdcall
option   casemap:none

WinMain  proto :DWORD,:DWORD,:DWORD,:DWORD
WndProc  proto :DWORD,:DWORD,:DWORD,:DWORD ;主窗口的消息处理程序
Display  proto :DWORD
calculate proto 
convertstring proto: word
arrangement proto: dword

include      menuID.INC

include      windows.inc
include      user32.inc
include      kernel32.inc
include      gdi32.inc
include      shell32.inc

includelib   user32.lib
includelib   kernel32.lib
includelib   gdi32.lib
includelib   shell32.lib

profits macro v1,v2,v3
    push ax
    mov ax,v1
    sub ax,v2
    mov si,100
    imul si
    idiv v2
    mov v3,ax
    pop ax
    endm

.data
GOODS  struct
 goods_name  db 10 dup(' ')  ;名称
 purchase_price   dw  0  ;进货价
 sale_price  dw  0   ;销售价
 purchased_quantity     dw  0    ;进货数量
 sold_quantity    dw  0  ;已售数量
 profit_rate       dw  0 ;利润率（尚未计算）
GOODS ends
APPNAME		DB  'GOODS Infortion Management System Window',0
SHOPNAME		DB  'SHOP',0
MenuName    DB  'MyMenu',0
DlgName	    DB  'MyDialog',0
INFORMATION		DB  'CS1901 LIUZIXUAN',0	;本人信息
cost dw 0
sales dw 0
profit dw 0
num dw 0

data_string DB 5 dup(0)

hInstance    dd       0
CommandLine  dd       0
N    EQU   5
GA1		GOODS  <'PEN',15,20,70,25,>
GA2		GOODS  <'PENCIL',2,3,100,50,>
GA3		GOODS  <'BOOK',30,40,25,5,>
GA4		GOODS  <'RULER',3,4,200,150,>
GA5		GOODS  <'GLUE',8,12,50,10,>
GAN		GOODS 5 dup(<>)
GOOD  DD  N DUP(0)
INFORMATION1 DB 'GOODSNAME',0
INFORMATION2 DB 'BUYPRICE',0
INFORMATION3 DB 'SELLPRICE',0
INFORMATION4 DB 'BUYNUM',0
INFORMATION5 DB 'SELLNUM',0
INFORMATION6 DB 'RATE',0

.code
Start:	     invoke GetModuleHandle,NULL
	     mov    hInstance,eax
	     invoke GetCommandLine
	     mov    CommandLine,eax
	     invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	     invoke ExitProcess,eax
	     ;;
WinMain      proc   hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
	     LOCAL  wc:WNDCLASSEX
	     LOCAL  msg:MSG
	     LOCAL  hWnd:HWND
             invoke RtlZeroMemory,addr wc,sizeof wc
	     mov    wc.cbSize,SIZEOF WNDCLASSEX
	     mov    wc.style, CS_HREDRAW or CS_VREDRAW
	     mov    wc.lpfnWndProc, offset WndProc
	     mov    wc.cbClsExtra,NULL
	     mov    wc.cbWndExtra,NULL
	     push   hInst
	     pop    wc.hInstance
	     mov    wc.hbrBackground,COLOR_WINDOW+1
	     mov    wc.lpszMenuName, offset MenuName
	     mov    wc.lpszClassName,offset SHOPNAME
	     invoke LoadIcon,NULL,IDI_APPLICATION
	     mov    wc.hIcon,eax
	     mov    wc.hIconSm,0
	     invoke LoadCursor,NULL,IDC_ARROW
	     mov    wc.hCursor,eax
	     invoke RegisterClassEx, addr wc
	     INVOKE CreateWindowEx,NULL,addr SHOPNAME,addr APPNAME,\
                    WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
                    CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
                    hInst,NULL
	     mov    hWnd,eax
	     INVOKE ShowWindow,hWnd,SW_SHOWNORMAL
	     INVOKE UpdateWindow,hWnd
	     ;;
MsgLoop:     INVOKE GetMessage,addr msg,NULL,0,0
             cmp    EAX,0
             je     ExitLoop
             INVOKE TranslateMessage,addr msg
             INVOKE DispatchMessage,addr msg
	     jmp    MsgLoop 
ExitLoop:    mov    eax,msg.wParam
	     ret
WinMain      endp

WndProc      proc   hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	     LOCAL  hdc:HDC
     .IF     uMsg == WM_DESTROY
	     invoke PostQuitMessage,NULL
     .ELSEIF uMsg == WM_KEYDOWN
	    .IF     wParam == VK_F1
             ;;your code
	    .ENDIF
     .ELSEIF uMsg == WM_COMMAND
	    .IF     wParam == IDM_FILE_EXIT
		    invoke SendMessage,hWnd,WM_CLOSE,0,0
        .ELSEIF wParam == ID_ACTION_COMPUTERATE
            invoke calculate
	    .ELSEIF wParam == ID_ACTION_LIST
		    invoke Display,hWnd
	    .ELSEIF wParam == IDM_HELP_ABOUT
            invoke MessageBox,hWnd,addr INFORMATION,addr APPNAME,0
            
	    .ENDIF
   ;  .ELSEIF uMsg == WM_PAINT
	     ;;redraw window again
     .ELSE
             invoke DefWindowProc,hWnd,uMsg,wParam,lParam
             ret
     .ENDIF
  	     xor    eax,eax
	     ret
WndProc      endp

Display      proc   hWnd:DWORD
             XX     equ  10
             YY     equ  10
	     XX_GAP equ  100
	     YY_GAP equ  30
             LOCAL  hdc:HDC
             invoke GetDC,hWnd
             mov    hdc,eax
             invoke arrangement,offset GOOD
             invoke TextOut,hdc,XX+0*XX_GAP,YY+0*YY_GAP,offset INFORMATION1,9
             invoke TextOut,hdc,XX+1*XX_GAP,YY+0*YY_GAP,offset INFORMATION2,8
             invoke TextOut,hdc,XX+2*XX_GAP,YY+0*YY_GAP,offset INFORMATION3,9
             invoke TextOut,hdc,XX+3*XX_GAP,YY+0*YY_GAP,offset INFORMATION4,6
             invoke TextOut,hdc,XX+4*XX_GAP,YY+0*YY_GAP,offset INFORMATION5,7
             invoke TextOut,hdc,XX+5*XX_GAP,YY+0*YY_GAP,offset INFORMATION6,4    
show:
             mov ebx,offset GOOD
             mov edi,[ebx]
             sub edi,18
             invoke TextOut,hdc,XX+0*XX_GAP,YY+1*YY_GAP,edi,10
             add edi,10
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+1*XX_GAP,YY+1*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+2*XX_GAP,YY+1*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+3*XX_GAP,YY+1*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+4*XX_GAP,YY+1*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+5*XX_GAP,YY+1*YY_GAP,offset data_string,5
             ;;
             add ebx,4
             mov edi,[ebx]
             sub edi,18
             invoke TextOut,hdc,XX+0*XX_GAP,YY+2*YY_GAP,edi,10
             add edi,10
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+1*XX_GAP,YY+2*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+2*XX_GAP,YY+2*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+3*XX_GAP,YY+2*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+4*XX_GAP,YY+2*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+5*XX_GAP,YY+2*YY_GAP,offset data_string,5
             ;;
             add ebx,4
             mov edi,[ebx]
             sub edi,18
             invoke TextOut,hdc,XX+0*XX_GAP,YY+3*YY_GAP,edi,10
             add edi,10
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+1*XX_GAP,YY+3*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+2*XX_GAP,YY+3*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+3*XX_GAP,YY+3*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+4*XX_GAP,YY+3*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+5*XX_GAP,YY+3*YY_GAP,offset data_string,5
             ;;
             add ebx,4
             mov edi,[ebx]
             sub edi,18
             invoke TextOut,hdc,XX+0*XX_GAP,YY+4*YY_GAP,edi,10
             add edi,10
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+1*XX_GAP,YY+4*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+2*XX_GAP,YY+4*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+3*XX_GAP,YY+4*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+4*XX_GAP,YY+4*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+5*XX_GAP,YY+4*YY_GAP,offset data_string,5
             ;;
             add ebx,4
             mov edi,[ebx]
             sub edi,18
             invoke TextOut,hdc,XX+0*XX_GAP,YY+5*YY_GAP,edi,10
             add edi,10
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+1*XX_GAP,YY+5*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+2*XX_GAP,YY+5*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+3*XX_GAP,YY+5*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+4*XX_GAP,YY+5*YY_GAP,offset data_string,5
             add edi,2
             invoke convertstring,[edi]
             invoke TextOut,hdc,XX+5*XX_GAP,YY+5*YY_GAP,offset data_string,5
			      
             ret
Display      endp

calculate    proc
    mov ebx,offset GA1.purchase_price
    mov num,0
cal:
    mov si,[ebx]    ;进货价
    add ebx,2
    mov di,[ebx]    ;销售价
    add ebx,2
    mov ax,[ebx]    ;进货数量
    imul si         ;成本
    mov cost,ax
    add ebx,2
    mov ax,[ebx]    ;已售数量
    imul di         ;销售额
    mov sales,ax
    profits sales,cost,profit
    add ebx,2
    mov ax,profit
    mov [ebx],ax
    add ebx,12
    inc num
    cmp num,N
    jne cal
    ret

calculate endp

convertstring proc number:word
    pusha
    mov ax,number
    mov esi,offset data_string
    mov ebx,0
clear_string:
    mov byte ptr[esi+ebx],' '
    inc ebx
    cmp ebx,5
    jne clear_string
    mov bx,10
    mov cx,0
    cmp ax,0
    jge convert
    neg ax
    mov byte ptr[esi],'-'
    inc esi
convert:
    mov dx,0
    div bx
    add dl,'0'
    push dx
    inc cx
    cmp ax,0
    jne convert
save:
    pop dx
    mov byte ptr[esi],dl
    inc esi
    dec cx
    cmp cx,0
    jne save
    popa
    ret
convertstring endp


arrangement proc good_address:dword
    mov esi,offset GA1
    mov edi,good_address
    mov num,0
    add esi,18
address:
    mov [edi],esi
    add esi,20
    add edi,4
    inc num
    cmp num,N
    jne address
    mov ax,0
    mov edi,good_address
arrange:
    inc ax
    cmp ax,num
    je arrange1
    mov ebx,[edi]
    mov edx,[edi+4]
    mov cx,[ebx]
    add edi,4
    cmp cx,[edx]
    jg arrange
change:
    mov [edi-4],edx
    mov [edi],ebx
    jmp arrange
arrange1:
    dec num 
    cmp num,1
    je  arrange_true
    mov ax,0
    mov edi,good_address
    jmp arrange
arrange_true:
    ret
arrangement endp

             end  Start
