.386     
.model flat, stdcall
.DATA
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
END