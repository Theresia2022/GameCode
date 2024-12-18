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

;创建一个窗口，基于窗口类来实现，必须确定处理窗口的窗口过程(回调函数)。其他参数初始为NULL，后续会在WinMain主函数中填充
MainWin WNDCLASS <NULL, WindowProc, NULL, NULL, NULL, NULL, NULL, COLOR_WINDOW, NULL, className>

message MSGStruct <>	;消息结构，用户存放获取的message
winRect RECT <>
hMainWnd DWORD ?		;主窗口的句柄
hInstance DWORD ?

hbitmap			DWORD ?		;图片的句柄
hdcMem			DWORD ?		;hdc句柄，使用频率高
hdcPic			DWORD ?		;hdc句柄，很少使用
hdc				DWORD ?
holdbr			DWORD ?
holdft			DWORD ?
ps				PAINTSTRUCT <>

ScoreText BYTE "000000", 0			; 被打印的生命值
DrawHalfSpiritMask DWORD 32, 32, 16, 16, 16, 16, 32, 32, 0, 0, 0, 16, 0, 16, 0, 0
BulletPosFix DWORD 10, 0, -10, 0, 0, 10, 0, -10
WaterSpirit DWORD ?					; 旋涡的图片，表示其正在播放第几帧，需要x / 8 + 3

MenuType	 DWORD 0				; 0：游戏初始界面，1：关卡选择界面，2：游戏正在进行界面，3：游戏结算界面
NumberOfItem DWORD 5,6,0,3			; 不同页面的选项文字数量。0界面：单人冒险、双人冒险、双人竞技、旅行模式、退出游戏，1界面：关卡1-5、返回上页，3界面：关卡得分、返回上页、退出游戏
SelectItem	 DWORD 0				; 当前选择的选项编号，默认为第一个
GameMode	 DWORD 0				; 0：冒险模式，1：竞技模式，2：旅行模式
IfDouble	 DWORD 0				; 0：单人模式，1：双人模式

; 按键操作信号，1表示被按下，0则相反
KeySign_Up			DWORD 0			; 游戏中为玩家1向上，选项中为指向上方选项
KeySign_Down		DWORD 0			; 游戏中为玩家1向下，选项中为指向下方选项
KeySign_Left		DWORD 0			; 玩家1向左
KeySign_Right		DWORD 0			; 玩家1向右
KeySign_Space		DWORD 0			; 玩家1射击
KeySign_W			DWORD 0			; 玩家2向上
KeySign_S			DWORD 0			; 玩家2向下
KeySign_A			DWORD 0			; 玩家2向左
KeySign_D			DWORD 0			; 玩家2向右
KeySign_R			DWORD 0			; 玩家2射击
KeySign_Enter		DWORD 0			; 确认当前选项
KeySign_Esc			DWORD 0			; 确认退出


Map			DWORD 225 DUP(?)		; 地图
; 玩家和敌役属性，从前往后分别为：血量、伤害、速度、X坐标、Y坐标、方向（1、2、3、4分别为朝上、下、左、右）、子弹状态（0：不存在，1：在移动，其他：触发爆炸）、子弹X坐标、子弹Y坐标、子弹方向、飞机类型
Plane_Player1 DWORD 0,0,0,0,0,0,0,0,0,0,0
Plane_Player2 DWORD 0,0,0,0,0,0,0,0,0,0,0

; 理论上同时最多存在8个敌役，生成时最多生成8个，敌役初始血量按类型分为1、3、5
Plane_Enemy DWORD 0,0,0,0,0,0,0,0,0,0,0		
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0
			DWORD 0,0,0,0,0,0,0,0,0,0,0

Pic_Enemy	DWORD 0023h,0021h,0022h,0020h,002Bh,0029h,002Ah,0028h,0033h,0031h,0032h,0030h

Number_Enemy DWORD 0,0,0			; 每场游戏三类敌役的总数
Round		 DWORD 0				; 冒险模式选择的关卡编号
Score		 DWORD 0,0				; 玩家1、2的游戏评分，若通关则打印
WaitingTime  DWORD -1

; 全局静态变量
RoundEnemy	DWORD 999,999,999,8,0,0,8,0,0,8,0,2,9,3,4,8,5,5

; RoundMap存放了预留的地图
; 0是无尽模式，12345对应冒险，6为竞技（暂未设置）
; 地图尺寸为225=15×15
			; Round 0 (挑战模式)
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

; 判断飞机可否移动
CheckPlaneCanGo			proc sign:DWORD
						local xl:DWORD, xr:DWORD, yu:DWORD, yd:DWORD, colL:DWORD, colR:DWORD,rowU:DWORD,rowD:DWORD   ;左、右x坐标，上、下y坐标，左上角落于15*15的第col列第row行
		
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

;参数列表：
		;ebp+8：HWND hWnd,窗口句柄
		;ebp+12：UINT message, 事件类型，比如按下键盘，移动鼠标
		;ebp+16：WPARAM wParam,事件具体信息，比如键盘：
			;38上 40下 37左 39右 
			;32space 13enter 27esc
			;65a 68d 82r 83s 87w
		;ebp+24：LPARAM lParam

WindowProc:
					push ebp
					mov ebp,esp
					mov eax,[ebp+12]

					cmp eax,WM_KEYDOWN	;按下键盘，将对应的Hold变量赋1，且进行对应操作
					je KeyDownMessage
					
					cmp eax,WM_KEYUP	;松开键盘，将对应的Hold变量赋0
					je KeyUpMessage
		
					cmp eax,WM_CREATE	;在程序运行之初，初始化窗口，只会调用一次
					je CreateWindowMessage
		
					cmp eax,WM_CLOSE	;点击窗口右上角×号，关闭窗口，退出程序，同时销毁后台的计时器
					je CloseWindowMessage
		
					cmp eax,WM_PAINT	;任何对窗口的更改，都会产生一个WM_PAINT消息（包括定时器也会触发WM_PAINT）
					je PaintMessage
		
					cmp eax,WM_TIMER	;计时器事件，每隔一段时间重新绘制窗口（基本和PaintMessage交替出现）
					je TimerMessage
		
					jmp OtherMessage	;交由默认回调函数处理
					
	KeyDownMessage:
					mov eax,[ebp+16]
					cmp eax,38
					jne @nup1
					call UpInMenu;上
					mov KeySign_Up,1
			@nup1:
					cmp eax,40
					jne @ndown1
					call DownInMenu;下
					mov KeySign_Down,1
			@ndown1:
					cmp eax,37
					jne @nleft1
					mov KeySign_Left,1;左
			@nleft1:
					cmp eax,39
					jne @nright1
					mov KeySign_Right,1;右
			@nright1:
					cmp eax,32
					jne @nspace1
					mov KeySign_Space,1
					call EnterInMenu				;空格，调用函数
			@nspace1:
					cmp eax,13
					jne @nenter1
					mov KeySign_Enter,1
					call EnterInMenu				;回车，调用函数
			@nenter1:
					cmp eax,27
					jne @nescape1
					call EscapeInMenu				;esc键，调用函数
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
					jmp WinProcExit					;不需要处理的键


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
					invoke printf,offset szMsg,eax				; 获取窗口句柄，初始化hMainWnd
					invoke SetTimer,hMainWnd,1,30,NULL
					invoke GetDC,hMainWnd
					mov hdc,eax									; 返回当前窗口工作区DC句柄
					invoke CreateCompatibleDC,eax
					mov hdcPic,eax								; 兼容内存DC句柄
					invoke LoadImageA,hInstance,1002,0,0,0,0	; 加载1002号资源，即bmp位图
					mov hbitmap,eax								; 返回资源图句柄
					invoke SelectObject,hdcPic,hbitmap
					invoke CreateCompatibleDC,hdc
					mov hdcMem,eax								; 创建第二个兼容DC
					invoke CreateCompatibleBitmap,hdc,640,480
					mov hbitmap,eax								; 返回创造好的位图的句柄
					invoke SelectObject,hdcMem,hbitmap
					invoke SetTextColor,hdcMem,0FFFFFFh			; 设置新地图文本颜色
					invoke SetBkColor,hdcMem,0					; 设置背景为黑色
					invoke ReleaseDC,hMainWnd,hdc				; 释放由调用GetDC或GetWindowDC函数获取的指定设备场景
					jmp WinProcExit

	CloseWindowMessage:
					;invoke printf,offset szMsg,2
					invoke PostQuitMessage,0					; 给进程发送退出指令
					invoke KillTimer,hMainWnd,1					; 关闭计时器
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
					call DrawUI									; 调用核心的UI绘制函数，在给定背景下放置各种图片资源。所有的绘制全部由DrawUI实现
					invoke SelectObject,hdcMem,holdbr
					invoke BitBlt,hdc,0,0,640,480,hdcMem,0,0,SRCCOPY
					invoke EndPaint,hMainWnd,offset ps
					jmp WinProcExit

	TimerMessage:
					invoke printf,offset szMsg,2
					call TimerTrick								; TimerTick是运行游戏运行逻辑的函数
					invoke RedrawWindow,hMainWnd,NULL,NULL,1
					jmp WinProcExit

	OtherMessage:	
					invoke DefWindowProc,[ebp+8],[ebp+12],[ebp+16],[ebp+20]

	WinProcExit:
					mov esp,ebp
					pop ebp
					ret 16


; 绘制UI的函数
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
					call DrawLine		; 单人冒险
					push 0Fh
					push 0Eh
					push 0Dh
					push 36h
					push 192
					push 256
					push 4
					call DrawLine		; 双人冒险
					push 17h
					push 16h
					push 0Dh
					push 36h
					push 224
					push 256
					push 4
					call DrawLine		; 双人竞技
					push 1Dh
					push 1Ch
					push 15h
					push 14h
					push 256
					push 256
					push 4
					call DrawLine		; 旅行模式
					push 27h
					push 26h
					push 25h
					push 24h
					push 288
					push 256
					push 4
					call DrawLine		; 退出游戏
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
					call DrawLine		; 返回游戏
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

					; 绘制游戏评分
					mov eax,[Score]			; 玩家1对应的分数
					mov esi,offset ScoreText; esi对应分数板字符串
					add esi,5
					mov ecx,6				; 分数是6位数字
					mov ebx,10

			DrawScoreTextPlayer1Loop:
					; 将score中的数字转化为字符后存在对应的scoretest中
					mov edx,0
					div ebx
					add edx,30h				; 分数(eax)除以10 余数在edx，数字转化为字符
					mov [esi],dl
					dec esi
					loop DrawScoreTextPlayer1Loop

					;绘制分数板的过程
					invoke TextOut,hdcMem,330,138,offset ScoreText,6

					cmp IfDouble,0
					je DrawResultMenuOption

					invoke TextOut,hdcMem,382,138,offset szScore,1

					mov eax,[Score+4]			; 玩家2对应的分数
					mov esi,offset ScoreText; esi对应分数板字符串
					add esi,5
					mov ecx,6				; 分数是6位数字
					mov ebx,10

			DrawScoreTextPlayer2Loop:
					; 将score中的数字转化为字符后存在对应的scoretest中
					mov edx,0
					div ebx
					add edx,30h				; 分数(eax)除以10 余数在edx，数字转化为字符
					mov [esi],dl
					dec esi
					loop DrawScoreTextPlayer2Loop

					;绘制分数板的过程
					invoke TextOut,hdcMem,392,138,offset ScoreText,6

					jmp DrawResultMenuOption


		DrawGameMode:
					call DrawGround						; 绘制宇宙背景
					call DrawWall						; 绘制墙面
					call DrawPlaneAndBullet				; 绘制飞机和子弹
					;call DrawTree						; 绘制树
					call DrawSideBar					; 绘制右边计数
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

;绘制半个图片（用于绘制半个墙）
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

;绘制一个图片
;核心函数：DrawSpirit 前两个参数是坐标，第三个参数是图片标号	
DrawSpirit:
		push ebp
		mov ebp,esp

		mov eax,[ebp+8]
		mov ebx,eax
		sar eax,3
		and ebx,7h
		sal eax,5
		sal ebx,5

		push 0FF00h			;透明色
		push 32	;32->16源高度
		push 32	;32->16源宽度
		push eax
		push ebx
		push hdcPic
		push 32	;32->16
		push 32	;32->16	整体图的宽度
		push [DWORD PTR ebp+16];
		push [DWORD PTR ebp+12]
		;在hdc上绘制的内容；
		push hdcMem
		call TransparentBlt		;包含透明色的位图绘制

		mov esp,ebp
		pop ebp

		ret 12

;绘制一行图片（封装DrawSpirit）
;核心函数：DrawLine 参数为 字的标号（数量可变） xy坐标 字的数量（根据最开始的参数个数改变）。
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


; 按键响应函数
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
		; 第一层分支，判断当前所处界面
		cmp MenuType,2						; 游戏进行界面，直接跳出分支
		je EnterInMenuReturn
		mov KeySign_Space,0					; 不发射子弹则清零两个键（防止影响子弹发射）
		mov KeySign_R,0
		mov KeySign_Enter,0
		cmp MenuType,0						; 初始界面
		je EnterInMain
		cmp MenuType,1						; 关卡选择
		je EnterInRound
		cmp MenuType,3						; 结算界面
		je EnterInResult
		jmp EnterToEndGame					; 意外情况结束游戏

		; 第二层分支
		; 下面的EnterInXX都是在XX界面进行跳转分支判断

	EnterInMain:
		cmp SelectItem,1
		mov ebx,SelectItem
		mov IfDouble,ebx
		mov GameMode,0
		jng EnterToRound						; 0、1号选项，对应单人冒险、双人冒险，都将进入关卡选择界面
		cmp SelectItem,2
		mov IfDouble,1
		mov GameMode,1
		mov Round,0								; 双人竞技地图，唯一地形
		je EnterToGame							; 2号选项，对应双人竞技，直接进入游戏（暂时位双人冒险补充关，后续完善）
		cmp SelectItem,3						
		mov IfDouble,0
		mov GameMode,2
		mov Round,0								; 旅行模式地图，唯一地形
		je EnterToGame							; 3号选项，对应（单人）旅行，直接进入游戏
		jmp EnterToEndGame						; 选到了其他选项暂定退出

	EnterInRound:
		cmp SelectItem,5						; 选项5，返回上层
		je EnterToMain
		; 剩下的0、1、2、3、4选项都是进入游戏，关卡对应1、2、3、4、5只不过游戏模式不同
		mov edx,[SelectItem]
		add edx,1
		mov Round,edx
		jmp EnterToGame							; 转移到游戏界面，在转换过程中要对GameMode和IsDoublePlayer进行赋值，赋值后统一切换到界面2
		jmp EnterInMenuReturn

	EnterInResult:
		cmp SelectItem,0
		je EnterToMain							; 0 对应返回主界面
		jmp EnterToEndGame						; 1对应退出游戏

		;转移到0：初始界面
	EnterToMain:
		mov MenuType,0
		mov SelectItem,0
		jmp EnterInMenuReturn
	
		;转移到1：模式选择
	EnterToRound:
		mov MenuType,1
		jmp EnterInMenuReturn

	; 前面选择模式和关卡时已经初始化了Round、GameMode和IfDouble
	EnterToGame:
		mov MenuType,2							; 修改界面属性
		call ResetField							; 游戏初始化
		jmp EnterInMenuReturn

	; 退出游戏
	EnterToEndGame:
		invoke PostQuitMessage,0
		invoke KillTimer,hMainWnd,1
	
	EnterInMenuReturn:
		pop eax
		ret
	
; Esc键响应
EscapeInMenu:
		; 按ESC回退到初始界面
		mov SelectItem,0
		mov MenuType,0
		ret

; 初始化函数
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
		; 玩家1
		mov [Plane_Player1+4],1			; 初始伤害
		mov [Plane_Player1+8],3			; 速度
		mov [Plane_Player1+12],64		; X坐标
		mov [Plane_Player1+16],32		; Y坐标
		mov [Plane_Player1+20],2		; 初始朝向为上
		mov [Plane_Player1+24],0		; 子弹状态
		mov [Plane_Player1+40],1
		; 玩家2
		mov [Plane_Player2+4],1			; 初始伤害
		mov [Plane_Player2+8],3			; 速度
		mov [Plane_Player2+12],128		; X坐标
		mov [Plane_Player2+16],448		; Y坐标
		mov [Plane_Player2+20],1		; 初始朝向为上
		mov [Plane_Player2+24],0		; 子弹状态
		mov [Plane_Player2+40],2
		; 初始化敌人数量
	InitEnemyNum:
		mov eax,[Round]	;计算偏置：ebx=Round×12，因为一个关卡对应3个DWORD数据
		mov ebx,12
		mul ebx
		mov ebx,eax	

		mov eax,[RoundEnemy+ebx]		; 根据关卡初始化三种飞机的总数
		mov [Number_Enemy],eax
		mov eax,[RoundEnemy+ebx+4]
		mov [Number_Enemy+4],eax
		mov eax,[RoundEnemy+ebx+8]
		mov [Number_Enemy+8],eax

		; 清空敌方飞机和子弹（对应10行EnemyPlane）
		mov ecx,8
		mov esi,offset Plane_Enemy
	RemoveEnemyPlane:
		mov DWORD ptr [esi],0			; 标记飞机血量为0不存在
		mov DWORD ptr [esi+24],0		; 标记子弹为0不存在
		add esi,44						; 换下一行（下一个飞机）
		loop RemoveEnemyPlane
		
		; 初始化地图
		mov eax,Round
		mov ebx,225*4
		mul ebx
		mov ebx,eax						; ebx = Round×225×4，锁定了当前Round在RoundMap中的偏移量
		mov ecx,225						; 对应225个地图块，循环225次，把RoundMap中Round对应的地图放到Map中
	SetMap:
		mov eax,[RoundMap+ebx+ecx*4-4]
		mov [Map+ecx*4-4],eax
		loop SetMap
		ret


; 绘制地面
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
		div esi;edx=eax%15,eax=eax/15,eax每15轮减一，edx每轮减一，每个地图15列15行，edx是列，eax是行
		sal edx,5
		sal eax,5
		add edx,80
		
		; 判断地图矩阵中的值属于哪一个，然后去对应的函数进行绘制
		cmp [Map+ecx*4-4],3						; 陨石
		je DrawWallBlock
		cmp [Map+ecx*4-4],11					; 星球
		je DrawWallMetal
		cmp [Map+ecx*4-4],8						; 守护物资
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

; 绘制我方和敌役飞机、子弹
DrawPlaneAndBullet:
		; 玩家1
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

		; 玩家2
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

; 游戏进行界面右侧的功能栏
DrawSideBar:
		mov ecx,5
		mov eax,64
		mov ebx,16
		mov esi,offset Plane_Player1 ;生命（玩家1）
	DrawLifePlayer1:
		push esi
		push ebx
		push ecx
		push eax
		
		push eax	
		push 568	
		push ebx	
		call DrawSpirit
		
		;命的数字
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
		add ebx,8						; 换做位图中下一个飞机来绘制
		add eax,48
		mov esi,offset Plane_Player2	; 生命（玩家2）
	DrawLifePlayer2:
		push esi
		push ebx
		push ecx
		push eax
		
		push eax	
		push 568	
		push ebx	
		call DrawSpirit
		
		;命的数字
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
		add eax,320				;“分数”的Y位置
		push 1Fh
		push 1Eh
		push eax
		push 568
		push 2
		call DrawLine			; 绘制“分数”

		; 每次更新分数板的操作
		mov esi,[esp]			; 仍然代表的是两个玩家 plane
		mov eax,[Score+4*esi]	; 两个玩家对应的分数
		mov esi,offset ScoreText; esi对应分数板字符串
		add esi,5
		mov ecx,6				; 分数是6位数字
		mov ebx,10
	DrawSideBarGetScoreText:
	; 将score中的数字转化为字符后存在对应的scoretest中
		mov edx,0
		div ebx
		add edx,30h				; 分数(eax)除以10 余数在edx，数字转化为字符
		mov [esi],dl
		dec esi
		loop DrawSideBarGetScoreText

		;绘制分数板的过程
		mov edi,[esp]
		sal edi,6
		add edi,360
		invoke TextOut,hdcMem,576,edi,offset ScoreText,6
		
		pop eax
		cmp eax,0
		mov eax,1
		je DrawSideBarRepeat

		ret

; TimerTrick函数根据按下的按键修改状态，修改后交由PaintMessage里的DrawUI刷新
TimerTrick:
		cmp WaitingTime,0			; 用来判断不同状态，0表示游戏结束
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
		mov MenuType,3				; 游戏结算
		mov SelectItem,0
	NotGameOver:
		call NewRound				; 说明此时可以开始新的一轮游戏
		mov WaitingTime,-1
	DontWait:
		inc WaterSpirit
		and WaterSpirit,0Fh

		; 比较是否处于游戏状态
		cmp MenuType,2
		je TimerTrickDontReturn
		jmp TimerTrickReturn

	TimerTrickDontReturn:
		cmp KeySign_Up,1
		jne TTDR@Up
		mov ebx,[Plane_Player1+8]
		sub [Plane_Player1+16],ebx
		mov [Plane_Player1+20],1
		; CheckPlaneCanGo判断目标是否可以移动，接收一个参数，0到7表示8个敌人，9和10表示玩家1和2
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
		invoke GetModuleHandle,NULL							; 返回模块的句柄
		mov hInstance,eax									; hInstance中存有句柄
		invoke LoadIcon,hInstance,999						; 加载图标，999为资源文件中图标的编号
		mov MainWin.hIcon,eax								; 填充MainWin的图标信息
		invoke LoadCursor,0,IDC_ARROW
		mov MainWin.hCursor,eax								; 填充MainWin的游标信息
		push offset MainWin									; 已经有一个结构体专门记录各项参数，因此就不使用invoke了	
		call RegisterClass									; 注册窗口类 返回一个ATOM，表示注册状态
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