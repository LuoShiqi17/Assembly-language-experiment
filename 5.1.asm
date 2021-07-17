;�˵�����
;-------------------------------------------
;#include "resource.h"
;IDM_MYMENU MENU
;begin
;	popup "File"
;	begin
;		menuitem "Exit",id_op_exit
;	end
;	popup "Action"
;	begin
;		menuitem "Compute Rate",id_
;		menuitem "List Sort",id_
;	end
;	popup "Help"
;	begin
;		menuitem "About",id_help_author
;	end
;end

;�Ի�����
;-------------------------------------------------
;IDD_MY_DIALOG DIALOGEX 0,0,186,82
;STYLE DS_SETFONT|DS_MODALFRAME|DS_FIXEDSYS|WS_POPUP|WS_CAPTION|WS_SYSMENU
;CAPTION "List Sort"
;FONT 8,"MS Shell Dlg",400,0,0XL
;BEGIN
;	DEFPUSHBUTTON "Yes",IDOK,105,53,50,14
;	PUSHBUTTON "No",IDCANCEL,34,53,50,14
;	LTEXT "List Sort",IDC_STATIC,66,16,87,11,WS_BORDER
;END

;-------------------------������-----------------------------
.686P
.model flat,stdcall
OPTION CASEMAP:NONE
WinMain proto:dword
WndProc proto:dword,:dword,:dword,:dword      ;�����ڵ���Ϣ�������
DialogProc proto:dword,:dword,:dword,:dword   ;�Ի��򴰿ڵ���Ϣ�������
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include resoure.inc
.data
szClassName db "GoodsDisplay",0
szTitle db"Goods Display Window",0
hInstance dd 0
szMessageBoxTitle db "Message Box Title",0
szMessageConfirm db "Are you sure to close the window ?",0
szAuthorInfo db "User : LUOSHIQI",0
szInputText db 100 dup(0)
dwInputLength dd 0
szCancelPress db "Cancel Button is pressed ",0
dwCancelPressLength = $-szCancelPress-1
szClosePress db "Close Window is pressed ",0
dwClosePressLength = $-szClosePress-1
szClearText db 100 dup(' ')
.code
start:
	invoke GetModuleHandle,NULL
	mov hInstance,eax
	invoke WinMain,hInstance
	invoke ExitProcess,eax

;---------------------���������� WinMain------------------------
WinMain proc hInst:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	LOCAL hMenu:HMENU
	invoke RtlZeroMemory,addr wc,SIZEOF wc
	mov wc.cbSize,SIZEOF WNMCLASSEX
	mov wc.style,CS_HREDRAW or CS_VREDRAW
	mov wc.lpfnWndProc,offset WndProc
	push hInst
	pop wc.hInstance
	mov wc.hbrBackground,COLOR_WINDOW+1
	mov wc.lpszClassName,offset szClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov wc.hIcon,eax
	invoke LoadCursor,NULL,IDI_ARROW
	mov wc.hCursor,eax
	invoke RegisterClassEx,addr wc
//	invoke LoadMenu,hInst,IDM_MYMENU ;װ�ز˵�
//	mov hMenu,eax ;�ڴ�������ʱ���ϲ˵�
	invoke CreateWindowEx,NULL,addr szClassName,addr szTitle,\
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

;---------------------�����ڵ���Ϣ������� WndProc-----------------------
WndProc proc hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	LOCAL hdc:HDC
//	LOCAL x:DWORD
.IF uMsg==WM_COMMAND ;�˵��ϵ���Ϣ
	.IF wParam==ID_OP_OPEN
		invoke DialogBoxParam,NULL,IDD_MY_DIALOG,hWnd,offset DialogProc,NULL
			;�����Ի��򴰿ڣ�ָ���ô��ڵĴ�������DialogProc
		invoke GetDC,hWnd
		mov hdc,eax
		invoke TextOut,hdc,40,40,addr szClearText,100
		invoke TextOut,hdc,40,40,addr szInputText,dwInputLength
			;��ʾ��Ϣ����Ϣ�ڶԻ������Ϣ������������
	.ELSEIF wParam==ID_OP_EXIT
		invoke DestroyWindow,hWnd
		invoke PostQuitMessage,NULL
	.ELSEIF wParam==ID_HELP_AUTHOR
		invoke MessageBox,hWnd,addr szAuthorInfo,addr szMessageBoxTitle,MB_OK
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

;-------------------------�Ի����ϵĴ�����Ϣ������� DialogProc----------------------------
DialogProc hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
LOCAL hEDIT:DWORD
.IF uMsg==WM_CLOSE
	invoke wsprintf,addr szInputText,addr szClosePress
	mov dwInputLength,dwClosePressLength
	invoke EndDialog,hWnd,NULL
.ELSEIF uMsg==WM_COMMAND
	.IF wParam==IDOK
		invoke GetDlgItem,hWnd,IDC_MYDIALOG_EDIT
		mov hEdit,eax
		invoke GetWindowTextLength,hEdit
		mov dwInputLength,eax
		invoke GetDlgItemText,hWnd,IDC_MYDIALOG_EDIT,offset szInputText,100
		invoke EndDialog,hWnd,NULL
	.ELSEIF wParam==IDCANCEL
		invoke wspritnf,addr szInputText,addr szCancelPress
		mov dwInputLength.dwCancelPressLength
		invoke EndDialog,hWnd,NULL
	.ENDIF
.ENDIF
 xor eax,eax
 ret
DialogProc endp
end start
