.386
.model flat, STDCALL

include	.\Source\GraphWin.inc
include gdi32.inc
include msimg32.inc
includelib gdi32.lib
includelib msimg32.lib
includelib .\Source\irvine32.lib
includelib kernel32.lib
includelib user32.lib
include .\Source\bhw.inc
includelib msvcrt.lib

printf	PROTO	C :ptr sbyte,:VARARG
WriteDec PROTO
Crlf PROTO

.data

szScore BYTE "/",0
szMsg	BYTE "%d",0ah,0
WindowName BYTE "Star Trek - The Journey", 0
className BYTE "Plane", 0
imgName BYTE "djb.bmp", 0

;����һ�����ڣ����ڴ�������ʵ�֣�����ȷ�������ڵĴ��ڹ���(�ص�����)������������ʼΪNULL����������WinMain�����������
MainWin WNDCLASS <NULL, WindowProc, NULL, NULL, NULL, NULL, NULL, COLOR_WINDOW, NULL, className>

message MSGStruct <>	;��Ϣ�ṹ���û���Ż�ȡ��message
winRect RECT <>
hMainWnd DWORD ?		;�����ڵľ��
hInstance DWORD ?

hbitmap			DWORD ?		;ͼƬ�ľ��
hdcMem			DWORD ?		;hdc�����ʹ��Ƶ�ʸ�
hdcPic			DWORD ?		;hdc���������ʹ��
hdc				DWORD ?
holdbr			DWORD ?
holdft			DWORD ?
ps				PAINTSTRUCT <>

ScoreText BYTE "000000", 0			; ����ӡ������ֵ
DrawHalfSpiritMask DWORD 32, 32, 16, 16, 16, 16, 32, 32, 0, 0, 0, 16, 0, 16, 0, 0
BulletPosFix DWORD 10, 0, -10, 0, 0, 10, 0, -10
WaterSpirit DWORD ?					; ���е�ͼƬ����ʾ�����ڲ��ŵڼ�֡����Ҫx / 8 + 3

MenuType	 DWORD 0				; 0����Ϸ��ʼ���棬1���ؿ�ѡ����棬2����Ϸ���ڽ��н��棬3����Ϸ�������
NumberOfItem DWORD 5,6,0,3			; ��ͬҳ���ѡ������������0���棺����ð�ա�˫��ð�ա�˫�˾���������ģʽ���˳���Ϸ��1���棺�ؿ�1-5��������ҳ��3���棺�ؿ��÷֡�������ҳ���˳���Ϸ
SelectItem	 DWORD 0				; ��ǰѡ���ѡ���ţ�Ĭ��Ϊ��һ��
GameMode	 DWORD 0				; 0��ð��ģʽ��1������ģʽ��2������ģʽ
IfDouble	 DWORD 0				; 0������ģʽ��1��˫��ģʽ

; ���������źţ�1��ʾ�����£�0���෴
KeySign_Up			DWORD 0			; ��Ϸ��Ϊ���1���ϣ�ѡ����Ϊָ���Ϸ�ѡ��
KeySign_Down		DWORD 0			; ��Ϸ��Ϊ���1���£�ѡ����Ϊָ���·�ѡ��
KeySign_Left		DWORD 0			; ���1����
KeySign_Right		DWORD 0			; ���1����
KeySign_Space		DWORD 0			; ���1���
KeySign_W			DWORD 0			; ���2����
KeySign_S			DWORD 0			; ���2����
KeySign_A			DWORD 0			; ���2����
KeySign_D			DWORD 0			; ���2����
KeySign_R			DWORD 0			; ���2���
KeySign_Enter		DWORD 0			; ȷ�ϵ�ǰѡ��
KeySign_Esc			DWORD 0			; ȷ���˳�


Map			DWORD 225 DUP(?)		; ��ͼ
; ��Һ͵������ԣ���ǰ����ֱ�Ϊ��Ѫ�����˺����ٶȡ�X���ꡢY���ꡢ����1��2��3��4�ֱ�Ϊ���ϡ��¡����ң����ӵ�״̬��0�������ڣ�1�����ƶ���������������ը�����ӵ�X���ꡢ�ӵ�Y���ꡢ�ӵ����򡢷ɻ�����
Plane_Player1 DWORD 0,0,0,0,0,0,0,0,0,0,0
Plane_Player2 DWORD 0,0,0,0,0,0,0,0,0,0,0

; ������ͬʱ������8�����ۣ�����ʱ�������8�������۳�ʼѪ�������ͷ�Ϊ1��3��5
Plane_Enemy DWORD 0,0,0,0,0,0,0,0,0,0,0		
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0

Pic_Enemy	DWORD 0023h,0021h,0022h,0020h,002Bh,0029h,002Ah,0028h,0033h,0031h,0032h,0030h

Number_Enemy DWORD 0,0,0			; ÿ����Ϸ������۵�����
Round		 DWORD 0				; ð��ģʽѡ��Ĺؿ����
Score		 DWORD 0,0				; ���1��2����Ϸ���֣���ͨ�����ӡ
WaitingTime  DWORD -1

; ȫ�־�̬����
RoundEnemy	DWORD 999,999,999,8,0,0,8,0,0,8,0,2,9,3,4,8,5,5

; RoundMap�����Ԥ���ĵ�ͼ
; 0���޾�ģʽ��12345��Ӧð�գ�6Ϊ��������δ���ã�
; ��ͼ�ߴ�Ϊ225=15��15
			; Round 0 (��սģʽ)
RoundMap	DWORD  3, 3, 0, 3, 3, 3, 3, 0, 3, 3, 3, 3, 0, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3,11, 3,11, 3,11, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3,11, 3, 3,11, 3, 3,11, 3, 3, 3, 3
			DWORD  3, 3, 3, 3,11, 3, 3,11, 3, 3,11, 3, 3, 3, 3
			DWORD  3,11,11, 3,11, 3,11,11,11, 3,11, 3,11,11, 3
			DWORD  3, 3, 3, 3,11, 3, 3,11, 3, 3,11, 3, 3, 3, 3
			DWORD  3, 3, 3, 3,11,11, 3,11, 3,11,11, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3,11,11,11,11,11, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 3,11, 3, 3, 3,11, 3, 3, 3, 3, 3
			DWORD  3, 3, 3, 3, 0,11, 3, 8, 3,11, 0, 3, 3, 3, 3
			; Round 1                                    
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 3, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 2, 3, 0, 3, 0, 3, 0, 3, 2, 3, 0, 0
			DWORD  0, 0, 3, 2, 3, 0, 3, 0, 3, 0, 3, 2, 3, 0, 0
			DWORD  0, 0, 3, 2, 3, 0, 3, 0, 3, 0, 3, 2, 3, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 0, 3, 0, 3, 3, 3, 0, 3, 0, 3, 0, 0
			DWORD  0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0
			DWORD  0, 0, 0, 0, 0, 0,11,11,11, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0,12, 0, 0, 0, 0, 0, 0, 0
			DWORD 11, 0, 3, 3, 0, 0,13, 0,13, 0, 0, 3, 3, 0,11
			DWORD  1, 0, 3, 0, 0, 0, 3, 3, 3, 0, 0, 0, 3, 0, 1
			DWORD  1, 0, 3, 0, 0, 0, 3, 8, 3, 0, 0, 0, 3, 0, 1
			; Round 2
			DWORD  0, 0, 0, 5, 6, 7, 0, 0,13,14,15, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 2, 2,11, 0, 0, 0, 0
			DWORD  0, 0, 3, 3, 0, 0, 3, 0, 2, 3,11, 0, 3, 3, 0
			DWORD  0, 3, 0, 0, 3, 0, 3, 0, 3, 0,11, 3, 0, 0, 0
			DWORD  0, 3, 0, 0, 3, 0, 3, 3, 0, 0,11, 0, 3, 3, 0
			DWORD  0, 3, 0, 0, 3, 0, 3, 3, 0, 0,11, 0, 0, 0, 1
			DWORD  0, 3, 0, 3, 3, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1
			DWORD  0, 0, 3, 3, 3, 1, 1, 1, 1, 1, 0, 3, 3, 3, 0
			DWORD  0, 0, 0, 0, 3, 0, 3, 2, 2, 0, 0, 0, 0, 0, 0
			DWORD  0, 3, 3, 3, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0
			DWORD  3, 3, 3, 3, 3, 3, 3,11, 3, 3, 3, 3, 3, 3, 3
			DWORD  0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 3, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0
			DWORD  0, 3, 3, 0, 0, 0, 3, 8, 3, 0, 0, 0, 0, 0, 1
			; Round 3
			DWORD  0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0
			DWORD  0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 3, 2, 0, 0
			DWORD  0, 1, 1, 3, 0, 0, 3, 0, 3, 0, 0, 3, 2, 0, 0
			DWORD  0, 1, 1, 3, 0, 0, 3, 0, 3, 0, 0, 3, 2, 0, 0
			DWORD  0, 1, 1, 3, 3, 3, 3, 0, 3, 3, 3,11,11,11, 0
			DWORD  0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 3, 3, 3, 2, 2, 0, 2, 2, 0, 2, 3, 3, 3, 0
			DWORD  0, 3,11, 3, 2, 0,11,11,11,11, 2, 3,11, 3, 0
			DWORD  0, 3, 3, 3, 0, 2, 2, 0, 2, 2, 0, 3,11, 3, 0
			DWORD  0,11,11,11, 0, 0, 2, 2, 2,11, 0, 3, 3, 3, 0
			DWORD  0, 0, 0, 0, 0, 0, 0, 2, 0,11, 0, 0, 0, 0, 0
			DWORD  0, 0, 2, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0
			DWORD  0, 2, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 2, 2, 1, 0, 0, 3, 3, 3, 0, 0, 3, 3, 1, 3
			DWORD  0, 0, 0, 1, 0, 0, 3, 8, 3, 0, 0, 3, 3, 1, 3
			; Round 4
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 0,11, 0
			DWORD  2, 0,11, 0, 3, 3, 3, 3, 3, 3, 3, 0,11, 0, 0
			DWORD  2, 0,11, 0, 0, 3, 3, 3, 3, 3, 0, 0,11, 0, 1
			DWORD  2, 0,11, 0, 3, 3, 0, 3, 0, 3, 3, 0,11, 0, 1
			DWORD  2, 0,11, 0, 3, 0, 0, 0, 0, 0, 3, 0,11, 0, 1
			DWORD  2, 0, 0,11, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 1
			DWORD  0, 0, 0, 0, 0, 0,11,11,11, 0, 0, 0, 1, 1, 1
			DWORD  3, 3, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3
			DWORD  3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 3, 3
			DWORD  3, 1, 1, 1, 1, 1,11,11,11, 0, 0, 0, 0, 3, 3
			DWORD  0, 0, 2, 0, 0, 2, 2, 2, 2, 0, 0, 2, 2, 2, 0
			DWORD  0, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0
			DWORD  0, 0, 0, 0, 0, 0, 3, 8, 3, 0, 0, 0, 0, 0, 0
			; Round 5
			DWORD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DWORD  0,11, 3, 3,11, 3, 3,11, 3, 3,11, 3, 3,11, 0
			DWORD  0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0
			DWORD  0, 1, 2, 1, 3, 2, 3, 3, 3, 2, 3, 1, 2, 1, 0
			DWORD  0, 1, 2, 1, 3, 2, 3, 3, 3, 2, 3, 1, 2, 1, 0
			DWORD  0, 1, 2, 1, 3, 2, 3, 3, 3, 2, 3, 1, 2, 1, 0
			DWORD  0, 0, 2, 2, 2, 0, 3, 3, 3, 0, 2, 2, 2, 0, 0
			DWORD  0, 0, 2, 3, 0, 2, 2, 2, 2, 2, 0, 3, 2, 0, 0
			DWORD  3, 3, 2, 3, 0, 2, 3, 3, 3, 2, 0, 3, 2, 3, 3
			DWORD 11,11, 2, 3, 0, 2,11,11,11, 2, 0, 3, 2,11,11
			DWORD  0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0
			DWORD  0, 1, 1, 1, 0, 0,11,11,11, 0, 0, 1, 1, 1, 0
			DWORD  0, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0, 1, 3, 0, 0
			DWORD  0, 0, 3, 1, 0, 0, 3, 3, 3, 0, 0, 1, 3, 0, 0
			DWORD  0, 0,11, 1, 0, 0, 3, 8, 3, 0, 0, 1,11, 0, 0

.code

; �жϷɻ��ɷ��ƶ�
CheckPlaneCanGo			proc sign:DWORD
						local xl:DWORD, xr:DWORD, yu:DWORD, yd:DWORD, colL:DWORD, colR:DWORD,rowU:DWORD,rowD:DWORD   ;����x���꣬�ϡ���y���꣬���Ͻ�����15*15�ĵ�col�е�row��
		
		.IF sign<9
			lea esi,Plane_Enemy
			mov eax,sign
			mov edx,0
			mov ebx,44
			mul ebx
			add esi,eax
		.ELSEIF sign==9
			mov esi,offset Plane_Player1
		.ELSE
			mov esi,offset Plane_Player2
		.ENDIF
		mov ebx,[esi+12]
		mov xl,ebx
		mov xr,ebx
		add xr,32
		mov ebx,[esi+16]
		mov yu,ebx
		mov yd,ebx
		add yd,32
		.IF yu > 960
			mov yu,0
			mov yd,32
		.ENDIF
		.IF yd > 480
			mov yd,480
			mov yu,448
		.ENDIF
		.IF xl > 960
			mov xl,0
			mov xr,32
		.ENDIF
		.IF xr > 480
			mov xr,480
			mov xl,448
		.ENDIF
		mov edx,0
		mov eax,xl
		mov ebx,32
		div ebx
		mov colL,eax
		.IF edx>0
			add eax,1
		.ENDIF
		mov colR,eax
		mov edx,0
		mov eax,yu
		mov ebx,32
		div ebx
		mov rowU,eax
		.IF edx>0
			add eax,1
		.ENDIF
		mov rowD,eax
		mov ebx,[esi+20]
		.IF ebx==1
			mov eax,rowU
			mov edx,0
			mov ebx,15
			mul ebx
			mov edx,eax
			add edx,colL
			mov ebx,[Map+4*edx]
			.IF ebx==4
				mov eax,rowU
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==12
				mov eax,rowU
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==3
				mov eax,rowU
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ELSEIF ebx==11
				mov eax,rowU
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ELSE
				mov eax,rowU
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ENDIF
			.IF yu<eax
				mov yu,eax
				add eax,32
				mov yd,eax
			.ENDIF
			mov eax,rowU
			mov edx,0
			mov ebx,15
			mul ebx
			mov edx,eax
			add edx,colR
			mov ebx,[Map+4*edx]
			.IF ebx==4
				mov eax,rowU
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==12
				mov eax,rowU
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==3
				mov eax,rowU
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ELSEIF ebx==11
				mov eax,rowU
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ELSE
				mov eax,rowU
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ENDIF
			.IF yu<eax
				mov yu,eax
				add eax,32
				mov yd,eax
			.ENDIF
		.ELSEIF ebx==2
			mov eax,rowD
			mov edx,0
			mov ebx,15
			mul ebx
			mov edx,eax
			add edx,colL
			mov ebx,[Map+4*edx]
			.IF ebx==5
				mov eax,rowD
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==13
				mov eax,rowD
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==3
				mov eax,rowD
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ELSEIF ebx==11
				mov eax,rowD
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ELSE
				mov eax,rowD
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ENDIF
			.IF yd>eax
				mov yd,eax
				sub eax,32
				mov yu,eax
			.ENDIF
			mov eax,rowD
			mov edx,0
			mov ebx,15
			mul ebx
			mov edx,eax
			add edx,colR
			mov ebx,[Map+4*edx]
			.IF ebx==5
				mov eax,rowD
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==13
				mov eax,rowD
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==3
				mov eax,rowD
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ELSEIF ebx==11
				mov eax,rowD
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ELSE
				mov eax,rowD
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ENDIF
			.IF yd>eax
				mov yd,eax
				sub eax,32
				mov yu,eax
			.ENDIF
		.ELSEIF ebx==3
			mov eax,rowU
			mov edx,0
			mov ebx,15
			mul ebx
			mov edx,eax
			add edx,colL
			mov ebx,[Map+4*edx]
			.IF ebx==6
				mov eax,colL
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==14
				mov eax,colL
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==3
				mov eax,colL
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ELSEIF ebx==11
				mov eax,colL
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ELSE
				mov eax,colL
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ENDIF
			.IF xl<eax
				mov xl,eax
				add eax,32
				mov xr,eax
			.ENDIF
			mov eax,rowD
			mov edx,0
			mov ebx,15
			mul ebx
			mov edx,eax
			add edx,colL
			mov ebx,[Map+4*edx]
			.IF ebx==6
				mov eax,colL
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==14
				mov eax,colL
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==3
				mov eax,colL
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ELSEIF ebx==11
				mov eax,colL
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ELSE
				mov eax,colL
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ENDIF
			.IF xl<eax
				mov xl,eax
				add eax,32
				mov xr,eax
			.ENDIF
		.ELSE
			mov eax,rowU
			mov edx,0
			mov ebx,15
			mul ebx
			mov edx,eax
			add edx,colR
			mov ebx,[Map+4*edx]
			.IF ebx==7
				mov eax,colR
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==15
				mov eax,colR
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==3
				mov eax,colR
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ELSEIF ebx==11
				mov eax,colR
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ELSE
				mov eax,colR
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ENDIF
			.IF xr>eax
				mov xr,eax
				sub eax,32
				mov xl,eax
			.ENDIF
			mov eax,rowD
			mov edx,0
			mov ebx,15
			mul ebx
			mov edx,eax
			add edx,colR
			mov ebx,[Map+4*edx]
			.IF ebx==7
				mov eax,colR
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==15
				mov eax,colR
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,16
			.ELSEIF ebx==3
				mov eax,colR
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ELSEIF ebx==11
				mov eax,colR
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
			.ELSE
				mov eax,colR
				mov edx,0
				push ebx
				mov ebx,32
				mul ebx
				pop ebx
				add eax,32
			.ENDIF
			.IF xr>eax
				mov xr,eax
				sub eax,32
				mov xl,eax
			.ENDIF
		.ENDIF
		mov eax,xl
		mov DWORD ptr[esi+12],eax
		mov eax,yu
		mov DWORD ptr[esi+16],eax
		mov eax,1
		ret
		mov eax,0
		ret

CheckPlaneCanGo			endp

;�����б�
		;ebp+8��HWND hWnd,���ھ��
		;ebp+12��UINT message, �¼����ͣ����簴�¼��̣��ƶ����
		;ebp+16��WPARAM wParam,�¼�������Ϣ��������̣�
			;38�� 40�� 37�� 39�� 
			;32space 13enter 27esc
			;65a 68d 82r 83s 87w
		;ebp+24��LPARAM lParam

WindowProc:
					push ebp
					mov ebp,esp
					mov eax,[ebp+12]

					cmp eax,WM_KEYDOWN	;���¼��̣�����Ӧ��Hold������1���ҽ��ж�Ӧ����
					je KeyDownMessage
					
					cmp eax,WM_KEYUP	;�ɿ����̣�����Ӧ��Hold������0
					je KeyUpMessage
		
					cmp eax,WM_CREATE	;�ڳ�������֮������ʼ�����ڣ�ֻ�����һ��
					je CreateWindowMessage
		
					cmp eax,WM_CLOSE	;����������Ͻǡ��ţ��رմ��ڣ��˳�����ͬʱ���ٺ�̨�ļ�ʱ��
					je CloseWindowMessage
		
					cmp eax,WM_PAINT	;�κζԴ��ڵĸ��ģ��������һ��WM_PAINT��Ϣ��������ʱ��Ҳ�ᴥ��WM_PAINT��
					je PaintMessage
		
					cmp eax,WM_TIMER	;��ʱ���¼���ÿ��һ��ʱ�����»��ƴ��ڣ�������PaintMessage������֣�
					je TimerMessage
		
					jmp OtherMessage	;����Ĭ�ϻص���������
					
	KeyDownMessage:
					mov eax,[ebp+16]
					cmp eax,38
					jne @nup1
					call UpInMenu;��
					mov KeySign_Up,1
			@nup1:
					cmp eax,40
					jne @ndown1
					call DownInMenu;��
					mov KeySign_Down,1
			@ndown1:
					cmp eax,37
					jne @nleft1
					mov KeySign_Left,1;��
			@nleft1:
					cmp eax,39
					jne @nright1
					mov KeySign_Right,1;��
			@nright1:
					cmp eax,32
					jne @nspace1
					mov KeySign_Space,1
					call EnterInMenu				;�ո񣬵��ú���
			@nspace1:
					cmp eax,13
					jne @nenter1
					mov KeySign_Enter,1
					call EnterInMenu				;�س������ú���
			@nenter1:
					cmp eax,27
					jne @nescape1
					call EscapeInMenu				;esc�������ú���
			@nescape1:
					cmp eax,65
					jne @na1
					mov KeySign_A,1
			@na1:
					cmp eax,68
					jne @nd1
					mov KeySign_D,1
			@nd1:
					cmp eax,83
					jne @ns1
					mov KeySign_S,1
			@ns1:
					cmp eax,87
					jne @nw1
					mov KeySign_W,1
			@nw1:
					cmp eax,82
					jne @nr1
					mov KeySign_R,1
			@nr1:
					jmp WinProcExit					;����Ҫ����ļ�


	KeyUpMessage:
					mov eax,[ebp+16]
					cmp eax,38
					jne @nup2
					mov KeySign_Up,0
			@nup2:
					cmp eax,40
					jne @ndown2
					mov KeySign_Down,0
			@ndown2:
					cmp eax,37
					jne @nleft2
					mov KeySign_Left,0
			@nleft2:
					cmp eax,39
					jne @nright2
					mov KeySign_Right,0
			@nright2:
					cmp eax,32
					jne @nspace2
					mov KeySign_Space,0
			@nspace2:
					cmp eax,13
					jne @nenter2
					mov KeySign_Enter,0
			@nenter2:
					cmp eax,27
					jne @nescape2
					mov KeySign_Esc,0
			@nescape2:
					cmp eax,65
					jne @na2
					mov KeySign_A,0
			@na2:
					cmp eax,68
					jne @nd2
					mov KeySign_D,0
			@nd2:
					cmp eax,83
					jne @ns2
					mov KeySign_S,0
			@ns2:
					cmp eax,87
					jne @nw2
					mov KeySign_W,0
			@nw2:
					cmp eax,82
					jne @nr2
					mov KeySign_R,0
			@nr2:
					jmp WinProcExit

	CreateWindowMessage:
					mov eax,[ebp+8]
					mov hMainWnd,eax
					invoke printf,offset szMsg,eax				; ��ȡ���ھ������ʼ��hMainWnd
					invoke SetTimer,hMainWnd,1,30,NULL
					invoke GetDC,hMainWnd
					mov hdc,eax									; ���ص�ǰ���ڹ�����DC���
					invoke CreateCompatibleDC,eax
					mov hdcPic,eax								; �����ڴ�DC���
					invoke LoadImageA,hInstance,1002,0,0,0,0	; ����1002����Դ����bmpλͼ
					mov hbitmap,eax								; ������Դͼ���
					invoke SelectObject,hdcPic,hbitmap
					invoke CreateCompatibleDC,hdc
					mov hdcMem,eax								; �����ڶ�������DC
					invoke CreateCompatibleBitmap,hdc,640,480
					mov hbitmap,eax								; ���ش���õ�λͼ�ľ��
					invoke SelectObject,hdcMem,hbitmap
					invoke SetTextColor,hdcMem,0FFFFFFh			; �����µ�ͼ�ı���ɫ
					invoke SetBkColor,hdcMem,0					; ���ñ���Ϊ��ɫ
					invoke ReleaseDC,hMainWnd,hdc				; �ͷ��ɵ���GetDC��GetWindowDC������ȡ��ָ���豸����
					jmp WinProcExit

	CloseWindowMessage:
					;invoke printf,offset szMsg,2
					invoke PostQuitMessage,0					; �����̷����˳�ָ��
					invoke KillTimer,hMainWnd,1					; �رռ�ʱ��
					jmp WinProcExit

	PaintMessage:	
					invoke printf,offset szMsg,1
					invoke BeginPaint,hMainWnd,offset ps
					mov hdc,eax
					invoke GetStockObject,BLACK_BRUSH
					invoke SelectObject,hdcMem,eax
					mov holdbr,eax
					invoke GetStockObject,SYSTEM_FIXED_FONT
					invoke SelectObject,hdcMem,eax
					mov holdft,eax
					invoke Rectangle,hdcMem,0,0,640,480
					call DrawUI									; ���ú��ĵ�UI���ƺ������ڸ��������·��ø���ͼƬ��Դ�����еĻ���ȫ����DrawUIʵ��
					invoke SelectObject,hdcMem,holdbr
					invoke BitBlt,hdc,0,0,640,480,hdcMem,0,0,SRCCOPY
					invoke EndPaint,hMainWnd,offset ps
					jmp WinProcExit

	TimerMessage:
					invoke printf,offset szMsg,2
					call TimerTrick								; TimerTick��������Ϸ�����߼��ĺ���
					invoke RedrawWindow,hMainWnd,NULL,NULL,1
					jmp WinProcExit

	OtherMessage:	
					invoke DefWindowProc,[ebp+8],[ebp+12],[ebp+16],[ebp+20]

	WinProcExit:
					mov esp,ebp
					pop ebp
					ret 16


; ����UI�ĺ���
DrawUI:
					
					cmp MenuType,0
					je DrawStartMenu
					cmp MenuType,1
					je DrawRoundMenu
					cmp MenuType,2
					je DrawGameMode
					cmp MenuType,3
					je DrawReturnMenu

		DrawStartMenu:
					push 0Fh
					push 0Eh
					push 0Dh
					push 0Ch
					push 160
					push 256
					push 4
					call DrawLine		; ����ð��
					push 0Fh
					push 0Eh
					push 0Dh
					push 36h
					push 192
					push 256
					push 4
					call DrawLine		; ˫��ð��
					push 17h
					push 16h
					push 0Dh
					push 36h
					push 224
					push 256
					push 4
					call DrawLine		; ˫�˾���
					push 1Dh
					push 1Ch
					push 15h
					push 14h
					push 256
					push 256
					push 4
					call DrawLine		; ����ģʽ
					push 27h
					push 26h
					push 25h
					push 24h
					push 288
					push 256
					push 4
					call DrawLine		; �˳���Ϸ
					jmp DrawStartMenuOption

		DrawRoundMenu:
					push 40h
					push 0Fh
					push 0Eh
					push 128
					push 288
					push 3
					call DrawLine

					push 41h
					push 0Fh
					push 0Eh
					push 160
					push 288
					push 3
					call DrawLine

					push 42h
					push 0Fh
					push 0Eh
					push 192
					push 288
					push 3
					call DrawLine
					
					push 43h
					push 0Fh
					push 0Eh
					push 224
					push 288
					push 3
					call DrawLine

					push 44h
					push 0Fh
					push 0Eh
					push 256
					push 288
					push 3
					call DrawLine

					push 2Fh
					push 2Eh
					push 2Dh
					push 2Ch
					push 290
					push 256
					push 4
					call DrawLine		; ������Ϸ
					jmp DrawRoundMenuOption

		DrawReturnMenu:
					push 1Fh
					push 1Eh
					push 27h
					push 26h
					push 128
					push 198
					push 4
					call DrawLine

					push 2Fh
					push 2Eh
					push 2Dh
					push 2Ch
					push 160
					push 256
					push 4
					call DrawLine

					push 27h
					push 26h
					push 25h
					push 24h
					push 192
					push 256
					push 4
					call DrawLine

					; ������Ϸ����
					mov eax,[Score]			; ���1��Ӧ�ķ���
					mov esi,offset ScoreText; esi��Ӧ�������ַ���
					add esi,5
					mov ecx,6				; ������6λ����
					mov ebx,10

			DrawScoreTextPlayer1Loop:
					; ��score�е�����ת��Ϊ�ַ�����ڶ�Ӧ��scoretest��
					mov edx,0
					div ebx
					add edx,30h				; ����(eax)����10 ������edx������ת��Ϊ�ַ�
					mov [esi],dl
					dec esi
					loop DrawScoreTextPlayer1Loop

					;���Ʒ�����Ĺ���
					invoke TextOut,hdcMem,330,138,offset ScoreText,6

					cmp IfDouble,0
					je DrawResultMenuOption

					invoke TextOut,hdcMem,382,138,offset szScore,1

					mov eax,[Score+4]			; ���2��Ӧ�ķ���
					mov esi,offset ScoreText; esi��Ӧ�������ַ���
					add esi,5
					mov ecx,6				; ������6λ����
					mov ebx,10

			DrawScoreTextPlayer2Loop:
					; ��score�е�����ת��Ϊ�ַ�����ڶ�Ӧ��scoretest��
					mov edx,0
					div ebx
					add edx,30h				; ����(eax)����10 ������edx������ת��Ϊ�ַ�
					mov [esi],dl
					dec esi
					loop DrawScoreTextPlayer2Loop

					;���Ʒ�����Ĺ���
					invoke TextOut,hdcMem,392,138,offset ScoreText,6

					jmp DrawResultMenuOption


		DrawGameMode:
					call DrawGround						; �������汳��
					call DrawWall						; ����ǽ��
					call DrawPlaneAndBullet				; ���Ʒɻ����ӵ�
					;call DrawTree						; ������
					call DrawSideBar					; �����ұ߼���
					jmp DrawUIReturn
		
		DrawStartMenuOption:
					mov eax,SelectItem
					sal eax,5
					add eax,160
					push eax
					push 220
					push 10
					call DrawSpirit
					jmp DrawUIReturn

		DrawRoundMenuOption:
					mov eax,SelectItem
					sal eax,5
					add eax,128
					.IF SelectItem==6
						mov eax,290
					.ENDIF
					push eax
					push 220
					push 10
					call DrawSpirit
					jmp DrawUIReturn

		DrawResultMenuOption:
					mov eax,SelectItem
					sal eax,5
					add eax,160
					push eax
					push 220
					push 10
					call DrawSpirit

		DrawUIReturn:
					ret

;���ư��ͼƬ�����ڻ��ư��ǽ��
DrawHalfSpirit:
		push ebp
		mov ebp,esp
		push ecx
		push edx

		mov eax,[ebp+8]
		mov ebx,eax
		sar eax,3
		and ebx,7h
		sal eax,5
		sal ebx,5
		
		mov ecx,[ebp+12]

		push 0FF00h
		push [DrawHalfSpiritMask+16+ecx*4]	;+16
		push [DrawHalfSpiritMask+ecx*4]
		push eax
		push ebx
		push hdcPic
		push [DrawHalfSpiritMask+16+ecx*4]	;+16
		push [DrawHalfSpiritMask+ecx*4]
		mov edx,[DWORD PTR ebp+20]
		add edx,[DrawHalfSpiritMask+48+ecx*4]
		push edx
		mov edx,[DWORD PTR ebp+16]
		add edx,[DrawHalfSpiritMask+32+ecx*4];32
		push edx
		push hdcMem
		call TransparentBlt

		pop edx
		pop ecx
		mov esp,ebp
		pop ebp

		ret 16

;����һ��ͼƬ
;���ĺ�����DrawSpirit ǰ�������������꣬������������ͼƬ���	
DrawSpirit:
		push ebp
		mov ebp,esp

		mov eax,[ebp+8]
		mov ebx,eax
		sar eax,3
		and ebx,7h
		sal eax,5
		sal ebx,5

		push 0FF00h			;͸��ɫ
		push 32	;32->16Դ�߶�
		push 32	;32->16Դ���
		push eax
		push ebx
		push hdcPic
		push 32	;32->16
		push 32	;32->16	����ͼ�Ŀ��
		push [DWORD PTR ebp+16];
		push [DWORD PTR ebp+12]
		;��hdc�ϻ��Ƶ����ݣ�
		push hdcMem
		call TransparentBlt		;����͸��ɫ��λͼ����

		mov esp,ebp
		pop ebp

		ret 12

;����һ��ͼƬ����װDrawSpirit��
;���ĺ�����DrawLine ����Ϊ �ֵı�ţ������ɱ䣩 xy���� �ֵ������������ʼ�Ĳ��������ı䣩��
DrawLine:
		mov ecx,[esp+4]
		cmp ecx,0
		je DrawLineReturn

		push ebp
		mov ebp,esp
		cmp ecx,0
		mov esi,ebp
		add esi,20
		mov eax,[ebp+12]
	DrawLineLoop:
		push ecx
		push eax
		
		push [ebp+16]
		push eax
		push [esi]
		call DrawSpirit

		pop eax
		pop ecx
		add esi,4
		add eax,32
		loop DrawLineLoop
		
		mov esp,ebp
		pop ebp
		sub esi,16
		mov eax,[esp]
		mov esp,esi
		mov [esp],eax

	DrawLineReturn:
		ret 12


; ������Ӧ����
UpInMenu:
		dec SelectItem
		cmp SelectItem,0
		jnl UpInMenuReturn
		mov SelectItem,0
	UpInMenuReturn:
		ret

DownInMenu:
		push eax
		inc SelectItem
		mov ebx,MenuType
		mov eax,[NumberOfItem+ebx*4]
		dec eax
		cmp SelectItem,eax
		jng DownInMenuReturn
		mov SelectItem,eax
	DownInMenuReturn:
		pop eax
		ret

EnterInMenu:
		push eax				
		; ��һ���֧���жϵ�ǰ��������
		cmp MenuType,2						; ��Ϸ���н��棬ֱ��������֧
		je EnterInMenuReturn
		mov KeySign_Space,0					; �������ӵ�����������������ֹӰ���ӵ����䣩
		mov KeySign_R,0
		mov KeySign_Enter,0
		cmp MenuType,0						; ��ʼ����
		je EnterInMain
		cmp MenuType,1						; �ؿ�ѡ��
		je EnterInRound
		cmp MenuType,3						; �������
		je EnterInResult
		jmp EnterToEndGame					; �������������Ϸ

		; �ڶ����֧
		; �����EnterInXX������XX���������ת��֧�ж�

	EnterInMain:
		cmp SelectItem,1
		mov ebx,SelectItem
		mov IfDouble,ebx
		mov GameMode,0
		jng EnterToRound						; 0��1��ѡ���Ӧ����ð�ա�˫��ð�գ���������ؿ�ѡ�����
		cmp SelectItem,2
		mov IfDouble,1
		mov GameMode,1
		mov Round,0								; ˫�˾�����ͼ��Ψһ����
		je EnterToGame							; 2��ѡ���Ӧ˫�˾�����ֱ�ӽ�����Ϸ����ʱλ˫��ð�ղ���أ��������ƣ�
		cmp SelectItem,3						
		mov IfDouble,0
		mov GameMode,2
		mov Round,0								; ����ģʽ��ͼ��Ψһ����
		je EnterToGame							; 3��ѡ���Ӧ�����ˣ����У�ֱ�ӽ�����Ϸ
		jmp EnterToEndGame						; ѡ��������ѡ���ݶ��˳�

	EnterInRound:
		cmp SelectItem,5						; ѡ��5�������ϲ�
		je EnterToMain
		; ʣ�µ�0��1��2��3��4ѡ��ǽ�����Ϸ���ؿ���Ӧ1��2��3��4��5ֻ������Ϸģʽ��ͬ
		mov edx,[SelectItem]
		add edx,1
		mov Round,edx
		jmp EnterToGame							; ת�Ƶ���Ϸ���棬��ת��������Ҫ��GameMode��IsDoublePlayer���и�ֵ����ֵ��ͳһ�л�������2
		jmp EnterInMenuReturn

	EnterInResult:
		cmp SelectItem,0
		je EnterToMain							; 0 ��Ӧ����������
		jmp EnterToEndGame						; 1��Ӧ�˳���Ϸ

		;ת�Ƶ�0����ʼ����
	EnterToMain:
		mov MenuType,0
		mov SelectItem,0
		jmp EnterInMenuReturn
	
		;ת�Ƶ�1��ģʽѡ��
	EnterToRound:
		mov MenuType,1
		jmp EnterInMenuReturn

	; ǰ��ѡ��ģʽ�͹ؿ�ʱ�Ѿ���ʼ����Round��GameMode��IfDouble
	EnterToGame:
		mov MenuType,2							; �޸Ľ�������
		call ResetField							; ��Ϸ��ʼ��
		jmp EnterInMenuReturn

	; �˳���Ϸ
	EnterToEndGame:
		invoke PostQuitMessage,0
		invoke KillTimer,hMainWnd,1
	
	EnterInMenuReturn:
		pop eax
		ret
	
; Esc����Ӧ
EscapeInMenu:
		; ��ESC���˵���ʼ����
		mov SelectItem,0
		mov MenuType,0
		ret

; ��ʼ������
ResetField:
		mov [Score],0
		mov [Score+4],0

		mov [Plane_Player1],3
		cmp IfDouble,0
		je NoDouble
		mov [Plane_Player2],3
	NoDouble:
		call NewRound
		ret

NewRound:
		mov WaitingTime,-1
		; ���1
		mov [Plane_Player1+4],1			; ��ʼ�˺�
		mov [Plane_Player1+8],3			; �ٶ�
		mov [Plane_Player1+12],64		; X����
		mov [Plane_Player1+16],32		; Y����
		mov [Plane_Player1+20],2		; ��ʼ����Ϊ��
		mov [Plane_Player1+24],0		; �ӵ�״̬
		mov [Plane_Player1+40],1
		; ���2
		mov [Plane_Player2+4],1			; ��ʼ�˺�
		mov [Plane_Player2+8],3			; �ٶ�
		mov [Plane_Player2+12],128		; X����
		mov [Plane_Player2+16],448		; Y����
		mov [Plane_Player2+20],1		; ��ʼ����Ϊ��
		mov [Plane_Player2+24],0		; �ӵ�״̬
		mov [Plane_Player2+40],2
		; ��ʼ����������
	InitEnemyNum:
		mov eax,[Round]	;����ƫ�ã�ebx=Round��12����Ϊһ���ؿ���Ӧ3��DWORD����
		mov ebx,12
		mul ebx
		mov ebx,eax	

		mov eax,[RoundEnemy+ebx]		; ���ݹؿ���ʼ�����ַɻ�������
		mov [Number_Enemy],eax
		mov eax,[RoundEnemy+ebx+4]
		mov [Number_Enemy+4],eax
		mov eax,[RoundEnemy+ebx+8]
		mov [Number_Enemy+8],eax

		; ��յз��ɻ����ӵ�����Ӧ10��EnemyPlane��
		mov ecx,8
		mov esi,offset Plane_Enemy
	RemoveEnemyPlane:
		mov DWORD ptr [esi],0			; ��Ƿɻ�Ѫ��Ϊ0������
		mov DWORD ptr [esi+24],0		; ����ӵ�Ϊ0������
		add esi,44						; ����һ�У���һ���ɻ���
		loop RemoveEnemyPlane
		
		; ��ʼ����ͼ
		mov eax,Round
		mov ebx,225*4
		mul ebx
		mov ebx,eax						; ebx = Round��225��4�������˵�ǰRound��RoundMap�е�ƫ����
		mov ecx,225						; ��Ӧ225����ͼ�飬ѭ��225�Σ���RoundMap��Round��Ӧ�ĵ�ͼ�ŵ�Map��
	SetMap:
		mov eax,[RoundMap+ebx+ecx*4-4]
		mov [Map+ecx*4-4],eax
		loop SetMap
		ret


; ���Ƶ���
DrawGround:
		mov ecx,225

	DrawGroundLoop:
		mov edx,0
		mov eax,ecx
		dec eax				
		mov esi,15
		div esi				
		sal edx,5			
		sal eax,5
		add edx,80			
		
		cmp [Map+ecx*4-4],1	
		je DrawGroundWater
		
		push ecx
		push eax
		push edx
		push 0
		call DrawSpirit
		pop ecx
	
		loop DrawGroundLoop
		jmp DrawGroundReturn
		
	DrawGroundWater:
	
		push ecx
		mov ebx,[WaterSpirit]
		sar ebx,2
		sar eax,5
		sar edx,5
		add ebx,eax
		add ebx,edx
		and ebx,3
		add ebx,3
		sal eax,5
		sal edx,5
		add edx,16
		push eax
		push edx
		push ebx
		call DrawSpirit
		pop ecx
		
		loop DrawGroundLoop
		
	DrawGroundReturn:
		ret
		

DrawWall:
		mov ecx,225
	DrawWallLoop:
		mov edx,0
		mov eax,ecx ;eax=225
		dec eax
		mov esi,15
		div esi;edx=eax%15,eax=eax/15,eaxÿ15�ּ�һ��edxÿ�ּ�һ��ÿ����ͼ15��15�У�edx���У�eax����
		sal edx,5
		sal eax,5
		add edx,80
		
		; �жϵ�ͼ�����е�ֵ������һ����Ȼ��ȥ��Ӧ�ĺ������л���
		cmp [Map+ecx*4-4],3						; ��ʯ
		je DrawWallBlock
		cmp [Map+ecx*4-4],11					; ����
		je DrawWallMetal
		cmp [Map+ecx*4-4],8						; �ػ�����
		je DrawWallBase
		cmp [Map+ecx*4-4],4 
		jnl DrawWallHalf
		
		
	DrawWallDoLoop:
		loop DrawWallLoop
		jmp DrawWallReturn
	
	DrawWallBlock:
		push ecx
		push eax
		push edx
		push 1
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
	
	DrawWallMetal:
		push ecx
		push eax
		push edx
		push 2
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawWallBase:
		push ecx
		push eax
		push edx
		push 8
		call DrawSpirit
		pop ecx
		jmp DrawWallDoLoop
		
	DrawWallHalf:
		cmp [Map+ecx*4-4],12			
		jnl DrawMetalWallHalf
		mov ebx,[Map+ecx*4-4]
		and ebx,3

		push ecx
		push eax
		push edx
		push ebx  ;0
		push 1
		call DrawHalfSpirit 
		pop ecx
		jmp DrawWallDoLoop

	DrawMetalWallHalf:
		mov ebx,[Map+ecx*4-4]
		and ebx,3
		push ecx
		push eax
		push edx
		push ebx
		push 2
		call DrawHalfSpirit
		pop ecx
		jmp DrawWallDoLoop

	DrawWallReturn:
		ret

; �����ҷ��͵��۷ɻ����ӵ�
DrawPlaneAndBullet:
		; ���1
		mov eax,0
		cmp DWORD ptr[Plane_Player1],eax
		je BulletOfPlayer1
		mov edx,[Plane_Player1+20]
		.IF edx==1
			mov eax,13h
		.ELSEIF edx==2
			mov eax,11h
		.ELSEIF edx==3
			mov eax,12h
		.ELSE
			mov eax,10h
		.ENDIF
		mov ebx,[Plane_Player1+12]
		add ebx,80
		push [Plane_Player1+16]
		push ebx
		push eax
		call DrawSpirit
	BulletOfPlayer1:
		mov eax,0
		cmp [Plane_Player1+24],eax
		je DrawPlayer2
		mov eax,[Plane_Player1+24]
		add eax,54
		mov ebx,[Plane_Player1+28]
		add ebx,80
		push [Plane_Player1+32]
		push ebx
		push eax
		call DrawSpirit

		; ���2
	DrawPlayer2:
		mov eax,0
		cmp [Plane_Player2],eax
		je BulletOfPlayer2
		mov edx,[Plane_Player2+20]
		.IF edx==1
			mov eax,1Bh
		.ELSEIF edx==2
			mov eax,19h
		.ELSEIF edx==3
			mov eax,1Ah
		.ELSE
			mov eax,18h
		.ENDIF
		mov ebx,[Plane_Player2+12]
		add ebx,80
		push [Plane_Player2+16]
		push ebx
		push eax
		call DrawSpirit
	BulletOfPlayer2:
		mov eax,0
		cmp [Plane_Player2+24],eax
		je DrawEnemy
		mov eax,[Plane_Player2+24]
		add eax,54
		mov ebx,[Plane_Player2+28]
		add ebx,80
		push [Plane_Player2+32]
		push ebx
		push eax
		call DrawSpirit

	DrawEnemy:
		mov esi,offset Plane_Enemy
		mov ecx,8
	DrawEnemyLoop:
		push esi
		mov eax,0
		cmp [esi],eax
		je DrawEnemyBullet
		push ecx
		push esi
		mov eax,[esi+40]
		mov ebx,16
		mul ebx
		sub eax,52
		mov edx,eax
		mov eax,[esi+20]
		mov ebx,4
		mul ebx
		add edx,eax
		mov esi,offset Pic_Enemy
		mov eax,[esi+edx]
		pop esi
		mov ebx,[esi+12]
		add ebx,80
		push [esi+16]
		push ebx
		push eax
		call DrawSpirit
		pop ecx
	DrawEnemyBullet:
		mov esi,[esp]
		mov eax,0
		cmp [esi+24],eax
		je DrawEnemyLoopContinue
		push ecx
		mov eax,[esi+24]
		add eax,54
		mov ebx,[esi+28]
		add ebx,80
		push [esi+32]
		push ebx
		push eax
		call DrawSpirit
		pop ecx
	DrawEnemyLoopContinue:
		pop esi
		add esi,44
		loop DrawEnemyLoop
		ret

; ��Ϸ���н����Ҳ�Ĺ�����
DrawSideBar:
		mov ecx,5
		mov eax,64
		mov ebx,16
		mov esi,offset Plane_Player1 ;���������1��
	DrawLifePlayer1:
		push esi
		push ebx
		push ecx
		push eax
		
		push eax	
		push 568	
		push ebx	
		call DrawSpirit
		
		;��������
		mov eax,[esi]
		mov edx,0
		mov ebx,10
		div ebx
		add edx,30h
		mov ScoreText,dl
		
		mov eax,[esp]
		add eax,8
		invoke TextOut,hdcMem,608,eax,offset ScoreText,1
		
		pop eax
		pop ecx
		pop ebx
		pop esi
		
		cmp IfDouble,0
		je NoDoubleToDraw
		add ebx,8						; ����λͼ����һ���ɻ�������
		add eax,48
		mov esi,offset Plane_Player2	; ���������2��
	DrawLifePlayer2:
		push esi
		push ebx
		push ecx
		push eax
		
		push eax	
		push 568	
		push ebx	
		call DrawSpirit
		
		;��������
		mov eax,[esi]
		mov edx,0
		mov ebx,10
		div ebx
		add edx,30h
		mov ScoreText,dl
		
		mov eax,[esp]
		add eax,8
		invoke TextOut,hdcMem,608,eax,offset ScoreText,1
		pop eax
		pop ecx
		pop ebx
		pop esi

	NoDoubleToDraw:
		mov eax,0
	DrawSideBarRepeat:
		push eax
		sal eax,6
		add eax,320				;����������Yλ��
		push 1Fh
		push 1Eh
		push eax
		push 568
		push 2
		call DrawLine			; ���ơ�������

		; ÿ�θ��·�����Ĳ���
		mov esi,[esp]			; ��Ȼ�������������� plane
		mov eax,[Score+4*esi]	; ������Ҷ�Ӧ�ķ���
		mov esi,offset ScoreText; esi��Ӧ�������ַ���
		add esi,5
		mov ecx,6				; ������6λ����
		mov ebx,10
	DrawSideBarGetScoreText:
	; ��score�е�����ת��Ϊ�ַ�����ڶ�Ӧ��scoretest��
		mov edx,0
		div ebx
		add edx,30h				; ����(eax)����10 ������edx������ת��Ϊ�ַ�
		mov [esi],dl
		dec esi
		loop DrawSideBarGetScoreText

		;���Ʒ�����Ĺ���
		mov edi,[esp]
		sal edi,6
		add edi,360
		invoke TextOut,hdcMem,576,edi,offset ScoreText,6
		
		pop eax
		cmp eax,0
		mov eax,1
		je DrawSideBarRepeat

		ret

; TimerTrick�������ݰ��µİ����޸�״̬���޸ĺ���PaintMessage���DrawUIˢ��
TimerTrick:
		cmp WaitingTime,0			; �����жϲ�ͬ״̬��0��ʾ��Ϸ����
		jl DontWait
		je ChangeGame
		dec WaitingTime
		jmp DontWait
	ChangeGame:
		mov ebx,[Plane_Player1]
		mov edx,[Plane_Player2]
		.IF GameMode==1
			cmp ebx,0
			je ToOver
			cmp ecx,0
			jne NotGameOver
		.ELSE
			cmp ebx,0
			jne NotGameOver
		.ENDIF
	ToOver:
		mov MenuType,3				; ��Ϸ����
		mov SelectItem,0
	NotGameOver:
		call NewRound				; ˵����ʱ���Կ�ʼ�µ�һ����Ϸ
		mov WaitingTime,-1
	DontWait:
		inc WaterSpirit
		and WaterSpirit,0Fh

		; �Ƚ��Ƿ�����Ϸ״̬
		cmp MenuType,2
		je TimerTrickDontReturn
		jmp TimerTrickReturn

	TimerTrickDontReturn:
		cmp KeySign_Up,1
		jne TTDR@Up
		mov ebx,[Plane_Player1+8]
		sub [Plane_Player1+16],ebx
		mov [Plane_Player1+20],1
		; CheckPlaneCanGo�ж�Ŀ���Ƿ�����ƶ�������һ��������0��7��ʾ8�����ˣ�9��10��ʾ���1��2
		invoke CheckPlaneCanGo,9
	TTDR@Up:
		cmp KeySign_Down,1
		jne TTDR@Down
		mov ebx,[Plane_Player1+8]
		add [Plane_Player1+16],ebx
		mov [Plane_Player1+20],2
		invoke CheckPlaneCanGo,9
	TTDR@Down:
		cmp KeySign_Left,1
		jne TTDR@Left
		mov ebx,[Plane_Player1+8]
		sub [Plane_Player1+12],ebx
		mov [Plane_Player1+20],3
		invoke CheckPlaneCanGo,9
	TTDR@Left:
		cmp KeySign_Right,1
		jne TTDR@Right
		mov ebx,[Plane_Player1+8]
		add [Plane_Player1+12],ebx
		mov [Plane_Player1+20],4
		invoke CheckPlaneCanGo,9
	TTDR@Right:
		cmp KeySign_Space,1
		je HaveSpace
		cmp IfDouble,0
		jne TTDR@Space
	HaveSpace:
		cmp DWORD ptr[Plane_Player1+24],0
		jne TTDR@Space
		cmp DWORD ptr[Plane_Player1],0
		je TTDR@Space
		mov edx,[Plane_Player1+20]
		mov [Plane_Player1+24],1
		mov eax,[Plane_Player1+12]
		add eax,[BulletPosFix+16+4*edx]
		mov [Plane_Player1+28],eax
		mov eax,[Plane_Player1+16]
		add eax,[BulletPosFix+16+4*edx]
		mov [Plane_Player1+32],eax
	TTDR@Space:
		cmp KeySign_W,1
		jne TTDR@W
		mov ebx,[Plane_Player2+8]
		sub [Plane_Player2+16],ebx
		mov [Plane_Player2+20],1
		invoke CheckPlaneCanGo,10
	TTDR@W:
		cmp KeySign_S,1
		jne TTDR@S
		mov ebx,[Plane_Player2+8]
		add [Plane_Player2+16],ebx
		mov [Plane_Player2+20],2
		invoke CheckPlaneCanGo,10
	TTDR@S:
		cmp KeySign_A,1
		jne TTDR@A
		mov ebx,[Plane_Player2+8]
		sub [Plane_Player2+12],ebx
		mov [Plane_Player2+20],3
		invoke CheckPlaneCanGo,10
	TTDR@A:
		cmp KeySign_D,1
		jne TTDR@D
		mov ebx,[Plane_Player2+8]
		add [Plane_Player2+12],ebx
		mov [Plane_Player2+20],4
		invoke CheckPlaneCanGo,10
	TTDR@D:
	TimerTrickReturn:
		ret
		

		
		

main:
		call Randomize
		invoke GetModuleHandle,NULL							; ����ģ��ľ��
		mov hInstance,eax									; hInstance�д��о��
		invoke LoadIcon,hInstance,999						; ����ͼ�꣬999Ϊ��Դ�ļ���ͼ��ı��
		mov MainWin.hIcon,eax								; ���MainWin��ͼ����Ϣ
		invoke LoadCursor,0,IDC_ARROW
		mov MainWin.hCursor,eax								; ���MainWin���α���Ϣ
		push offset MainWin									; �Ѿ���һ���ṹ��ר�ż�¼�����������˾Ͳ�ʹ��invoke��	
		call RegisterClass									; ע�ᴰ���� ����һ��ATOM����ʾע��״̬
		invoke CreateWindowEx,0,offset className,offset WindowName,WS_BORDER or WS_CAPTION or WS_SYSMENU,CW_USEDEFAULT,CW_USEDEFAULT,650,510,NULL,NULL,hInstance,NULL

		mov hMainWnd,eax
		
		invoke ShowWindow,hMainWnd,SW_SHOW
		invoke UpdateWindow,hMainWnd

	.WHILE 1
			invoke GetMessage,offset message,NULL,NULL,NULL
			.IF eax==0
				.BREAK
			.ENDIF
			invoke TranslateMessage,offset message
			invoke DispatchMessage,offset message
	.ENDW

	invoke ExitProcess,NULL
	ret
end main