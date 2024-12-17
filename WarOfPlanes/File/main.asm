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

;创建一个窗口，基于窗口类来实现，必须确定处理窗口的窗口过程(回调函数)。其他参数初始为NULL，后续会在WinMain主函数中填充
MainWin WNDCLASS <NULL, WinProc, NULL, NULL, NULL, NULL, NULL, COLOR_WINDOW, NULL, className>

msg MSGStruct <>	;消息结构，用户存放获取的message
winRect RECT <>
hMainWnd DWORD ?	;主窗口的句柄
hInstance DWORD ?

hbitmap DWORD ?		;图片的句柄
hdcMem DWORD ?		;hdc句柄，使用频率高
hdcPic DWORD ?		;hdc句柄，很少使用
hdc DWORD ?
holdbr DWORD ?
holdft DWORD ?
ps PAINTSTRUCT <>

MenuType DWORD ?					; 0：游戏初始界面，1：关卡选择界面，2：游戏正在进行界面，3：游戏结算界面
NumberOfItem DWORD 5,7,0,3			; 不同页面的选项文字数量。0界面：单人冒险、双人冒险、双人竞技、旅行模式、退出游戏，1界面：关卡1-6、返回上页，3界面：游戏结束、关卡得分、返回上页
SelectItem	 DWORD 0				; 当前选择的选项编号，默认为第一个
GameMode	 DWORD 0				; 0：冒险模式，1：竞技模式，2：旅行模式
IfDouble	 DWORD 0				; 0：单人模式，1：双人模式

; 按键操作信号，1表示被按下，0则相反
KeySign_Up			DWORD 0			; 游戏中为玩家1向上，选项中为指向上方选项
KeySign_Down		DWORD 0			; 游戏中为玩家1向下，选项中为指向下方选项
KeySign_Left		DWORD 0			; 玩家1向左
KeySign_Right		DWORD 0			; 玩家1向右
KeySign_Space		DWORD 0			; 玩家1射击
KeySign_W			DWORD O			; 玩家2向上
KeySign_S			DWORD O			; 玩家2向下
KeySign_A			DWORD O			; 玩家2向左
KeySign_D			DWORD O			; 玩家2向右
KeySign_R			DWORD 0			; 玩家2射击
KeySign_Enter		DWORD 0			; 确认当前选项
KeySign_Esc			DWORD 0			; 确认退出


