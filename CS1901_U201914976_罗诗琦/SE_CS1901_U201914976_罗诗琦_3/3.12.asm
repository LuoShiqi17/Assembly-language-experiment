.386     
.model flat, stdcall
.DATA
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
END