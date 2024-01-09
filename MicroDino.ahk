;▼▼▼ MICRO DINO ▼▼▼
A_IconTip:= "MICRO DINO v0.3 by DavidBevi" ; reddit.com/r/AutoHotkey/comments/185zu9v
A_IconTip.= "`n☻ Hold CTRL to run `n▲ Press SHIFT to jump"

;▼ CONTROLS
~Control::Sym   ;(hold)
~^Shift::Jump   ;(press)

;▼ SCREEN POSITION
PosX:= "x1325", PosY:= "y1046"

;▼ VARIABLES
h:= 0, v:= 0, i:= 0, score:= 0, fs:= 0
xOFagent:= 183

;▼ GUI
tray := WinExist("ahk_class Shell_TrayWnd")
MyGui := Gui("-Caption +ToolWindow +AlwaysOnTop -SysMenu +Owner" tray)
MyGui.BackColor := "000000"
WinSetTransColor("000000", MyGui)
MyGui.Show(PosX PosY " w200 h30 NoActivate")
MyGui.SetFont("ccccccc s9")
MyGui.Add("Text", "vObst x200 y18", "▲")
MyGui.Add("Text", "vScore x" xOFagent-1 " y2 h12 Center", "  0  ")
MyGui.SetFont("ccccccc s10")
MyGui.Add("Text", "vAgent x" xOFagent " y17 h12 Center", " ☻ ")

;▼ GUI OVER TASKBAR  tinyurl.com/plankoe-did-this
DllCall("dwmapi\DwmSetWindowAttribute", "ptr",MyGui.hwnd,
        "uint",12, "uint*",1, "uint",4)
hHook:=DllCall("SetWinEventHook", "UInt",0x8005, "UInt",0x800B, "Ptr",0,
       "Ptr",CallbackCreate(WinEventHookProc), "UInt",0, "UInt",0, "UInt",0x2)
WinEventHookProc(p1, p2, p3, p4, p5, p6, p7)
  { if !p3 and p4=0xFFFFFFF7
        return
    SetTimer () => DllCall("SetWindowPos","ptr",  Tray,"ptr",  MyGui.hwnd,"int", 
                   0,"int",  0,"int",  0,"int",  0,"uint",  0x10|0x2|0x200), -1
  }

;▼ FUNCTIONS
Sym()
  { hotkey:= SubStr(A_ThisHotkey,2)
    While GetKeyState(hotkey)
    { MyGui["Obst"].Move(i)                       ;▼ MOVE OBST
      global i+= 2+score/20
      MyGui["Agent"].Move(,17-h)                  ;▼ MOVE AGENT
      global v-= h<0? 0: 0.23
      global v:= h<0? 0: v
      global h:= h<0? 0: h+v
      if abs(xOFagent-i+6)+h < 10                 ;▼ IF COLLISION
       { global fs:= score
         global score:= 0
         global i:= -80
       }
      if i > 195                                  ;▼ GET POINT
       { global score+= 1
         global i:= 0
       }
      if i < 10                                   ;▼ UPDATE SCORE
       { MyGui["Score"].Value:= i<0? fs: score
         MyGui["Agent"].Value:= i<0? "😵":"☻"
         MyGui["Obst"].Redraw()
       }
      Sleep 20                                    ;>> FRAMERATE
    }
  }
Jump()
  { global v+= h>2? 0: 3
    global h:= h>2? h: h+v
  }
