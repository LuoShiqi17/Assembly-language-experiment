.386
STACK   SEGMENT USE16 STACK
		DB 200 DUP(0)
STACK   ENDS

CODE    SEGMENT USE16
		ASSUME CS:CODE,DS:CODE,SS:STACK
;新的INT 08H使用的变量
		count db 18 ;滴答计数
		hour db ?,?,':' ;时的ASCII码
		min db ?,?,':' ;分
		sec db ?,? ;秒
		buf_len=$-hour ;计算显示信息长度
		cursor dw ? ;原光标位置
		old_int dw ?,? ;原INT 08H的中断矢量
		wsl dd 526
		llgg db '0'
		menu db "choice:1.top left 2.above 3.top right$"
;新的INT 08H代码
new08h  proc  far
		mov wsl,917
		pushf ;标志位入栈
		call dword ptr cs:old_int ;完成原功能
		dec cs:count ;倒计数
		jz DISP ;集满十八次，转时钟显示
		iret ;没计满，中断返回
DISP:	mov cs:count,18 ;重置计数初值
		sti ;开中断
		pusha ;保护现场
		push ds
		push es
		mov ax,cs ;将DS ES指向CS
		mov ds,ax
		mov es,ax
		call get_time ;获取当前时间，并转换成ASCII码
		mov bh,0
		mov ah,3
		int 10h ;(dh,dl) 行，列
		mov cursor,dx ;保存原光标位置
		mov bp,offset hour ;es:[bp]ָ指向显示信息的起始地址
		mov bh,0 ;显示到0号页面
		mov dh,0 ;显示在0行，修改行
		;mov dl,80-buf_len ;显示在最后几列（光标位置设到右上角
		;mov dl,36 ;修改列

		cmp llgg,'1' ;显示在左上角
		jz r1
		cmp llgg,'2' ;显示在偏正上方
		jz r2
		cmp llgg,'3' ;显示在右上角
		jz r3
		jnz rz
r1:		mov dl,0
		jmp r0
r2:		mov dl,35
		jmp r0
r3:		mov dl,80-buf_len
r0:		mov bl,07h ;显示字符的属性（白色）
		mov cx,buf_len ;显示的字符串长度
		mov al,0 ;bl包含显示属性，写后光标不动
		mov ah,13h ;调用显示字符串的功能
		int 10h ;在右上角显示出当天时间
		mov bh,0 ;对0号页面操作
		mov dx,cursor ;恢复原来的光标位置
		mov ah,2 ;设置光标位的功能号
		int 10h ;还原光标位置（保证主程序的光标位置不受影响）
rz:		pop es
		pop ds
		popa ;恢复现场
		iret ;中断返回
new08h  endp
;读取时间子程序。从RT/CMOS RAM中取得时分秒并转化成ASCII码存放到对应变量中
get_time  proc
		  mov al,4 ;4是“时”信息的偏移地址
		  out 70h,al ;设定将要访问的单元是偏移值为4的“时”信息
		  jmp $+2 ;延时，保证端口操作的可靠性
		  in al,71h ;读取“时”信息
		  mov ah,al ;将2位压缩的BCD码转换成未压缩的BCD码
		  and al,0fh
		  shr ah,4
		  add ax,3030h ;转换成对应的ASCII码
		  xchg ah,al ;高位放在前面显示
		  mov word ptr hour,ax ;保存到HOUR变量指示的前两个字节中
		  mov al,2 ;分
		  out 70h,al
		  jmp $+2
		  in al,71h
		  mov ah,al
		  and al,0fh
		  shr ah,4
		  add ax,3030h
		  xchg ah,al
		  mov word ptr min,ax;
		  mov al,0 ;秒
		  out 70h,al
		  jmp $+2
		  in al,71h
		  mov ah,al
		  and al,0fh
		  shr ah,4
		  add ax,3030h
		  xchg ah,al
		  mov word ptr sec,ax
		  ret
get_time  endp
;初始化中断处理程序的安装及主程序
BEGIN:  push cs
		pop ds
		mov ax,3508h ;获取原08H的中断矢量
		int 21h
		mov old_int,bx ;保存中断矢量
		mov old_int+2,es
		mov dx,offset new08h

		cmp wsl,917 ;判断是否重复安装
		je NEXT

		mov ax,2508h ;设置新的08H中断矢量
		int 21h
		mov dx,offset menu
		mov ah,09h
		int 21h
NEXT: 	mov llgg,al ;选择显示在首行的某个位置
		mov ah,0 ;等待按键
		int 16h
		;mov llgg,al ;选择显示在首行的某个位置
		cmp al,'q' ;若按下了q则退出
		jne NEXT
		;lds dx,dword ptr old_int ;取出保存的原08H中断矢量
		;mov ax,2508h
		;int 21h ;
		mov dx,offset BEGIN+15 ;驻留退出
		mov cl,4
		shr dx,cl
		add dx,23h
		mov al,0
		mov ah,31h
		int 21h
CODE    ENDS
		END BEGIN