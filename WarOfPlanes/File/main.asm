.386
.model flat, STDCALL

include	..\source\GraphWin.inc
include ..\source\bhw.inc
includelib ..\source\irvine32.lib
include gdi32.inc
include msimg32.inc
includelib gdi32.lib
includelib msimg32.lib
includelib kernel32.lib
includelib user32.lib
includelib msvcrt.lib

printf	PROTO	C :ptr sbyte,:VARARG
WriteDec PROTO
Crlf PROTO

.data

;����һ�����ڣ����ڴ�������ʵ�֣�����ȷ�������ڵĴ��ڹ���(�ص�����)������������ʼΪNULL����������WinMain�����������
MainWin WNDCLASS <NULL, WinProc, NULL, NULL, NULL, NULL, NULL, COLOR_WINDOW, NULL, className>

msg MSGStruct <>	;��Ϣ�ṹ���û���Ż�ȡ��message
winRect RECT <>
hMainWnd DWORD ?	;�����ڵľ��
hInstance DWORD ?

hbitmap DWORD ?		;ͼƬ�ľ��
hdcMem DWORD ?		;hdc�����ʹ��Ƶ�ʸ�
hdcPic DWORD ?		;hdc���������ʹ��
hdc DWORD ?
holdbr DWORD ?
holdft DWORD ?
ps PAINTSTRUCT <>

MenuType DWORD ?					; 0����Ϸ��ʼ���棬1���ؿ�ѡ����棬2����Ϸ���ڽ��н��棬3����Ϸ�������
NumberOfItem DWORD 5,7,0,3			; ��ͬҳ���ѡ������������0���棺����ð�ա�˫��ð�ա�˫�˾���������ģʽ���˳���Ϸ��1���棺�ؿ�1-6��������ҳ��3���棺��Ϸ�������ؿ��÷֡�������ҳ
SelectItem	 DWORD 0				; ��ǰѡ���ѡ���ţ�Ĭ��Ϊ��һ��
GameMode	 DWORD 0				; 0��ð��ģʽ��1������ģʽ��2������ģʽ
IfDouble	 DWORD 0				; 0������ģʽ��1��˫��ģʽ

; ���������źţ�1��ʾ�����£�0���෴
KeySign_Up			DWORD 0			; ��Ϸ��Ϊ���1���ϣ�ѡ����Ϊָ���Ϸ�ѡ��
KeySign_Down		DWORD 0			; ��Ϸ��Ϊ���1���£�ѡ����Ϊָ���·�ѡ��
KeySign_Left		DWORD 0			; ���1����
KeySign_Right		DWORD 0			; ���1����
KeySign_Space		DWORD 0			; ���1���
KeySign_W			DWORD O			; ���2����
KeySign_S			DWORD O			; ���2����
KeySign_A			DWORD O			; ���2����
KeySign_D			DWORD O			; ���2����
KeySign_R			DWORD 0			; ���2���
KeySign_Enter		DWORD 0			; ȷ�ϵ�ǰѡ��
KeySign_Esc			DWORD 0			; ȷ���˳�

; ��Һ͵������ԣ���ǰ����ֱ�Ϊ��Ѫ������ʼʱ��������Ϊ3�����˺����ٶȡ�X���ꡢY���ꡢ����1��2��3��4�ֱ�Ϊ���ϡ��¡����ң����ӵ�״̬��0�������ڣ�1�����ƶ���������������ը�����ӵ�X���ꡢ�ӵ�Y���ꡢ�ӵ�����
Plane_Player1 DWORD 0,0,0,0,0,0,0,0,0,0
Plane_Player2 DWORD 0,0,0,0,0,0,0,0,0,0

; ������ͬʱ������8�����ۣ�����ʱ�������6�������۳�ʼѪ�������ͷ�Ϊ1��3��5
Plane_Enemy DWORD 0,0,0,0,0,0,0,0,0,0		
			DWORD 0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0

Number_Enemy DOWRD 0,0,0			; ÿ����Ϸ������۵�����
Round		 DWORD 0				; ð��ģʽѡ��Ĺؿ����
Score		 DWORD 0,0				; ���1��2����Ϸ���֣���ͨ�����ӡ


