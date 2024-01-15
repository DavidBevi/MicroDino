;▼▼▼ MICRO DINO ▼▼▼
A_IconTip:= "MICRO DINO v0.6 by DavidBevi"  ;github.com/DavidBevi/MicroDino
A_IconTip.= "`n☻ Hold CTRL to run `n▲ Press SHIFT to jump"
CoordMode "Mouse", "Screen"

;▼ CONTROLS
~Control::Sym   ;(hold)
~^Shift::Jump   ;(press)

;▼ SCREEN POSITION [Try 1325x1046 or 1300x0]
guiX:= 1325
guiY:= 1046
guiW:=200,  guiH:=30

;USE ARGUMENTS IF PROVIDED
guiX:=A_Args.Length>0?A_Args[1]:guiX, guiY:=A_Args.Length>1?A_Args[2]:guiY

;VARIABLES
h:=0,  v:=0,  i:=0,  score:=0,  fs:= 0,  agentX:=183
gg:="Game over:  ",  hs:="High score:  "

;GUI
tray:= WinExist("ahk_class Shell_TrayWnd")
MyGui:= Gui("-Caption +ToolWindow +AlwaysOnTop -SysMenu +Owner" tray)
WinSetTransColor("000000", MyGui)
MyGui.BackColor:=((SysGet(78)-guiW)<guiX||(SysGet(79)-guiH)<guiY)?"995500":"000000"
guiX:=min(guiX,(SysGet(78)-guiW)),  guiY:=min(guiY,(SysGet(79)-guiH))
MyGui.Show("x" guiX " y" guiY " w" guiW " h" guiH " NoActivate")
MyGui.SetFont("ccccccc s9")
MyGui.Add("Text", "vScore y2 w184 Right", "MicroDino - Click for info")
MyGui.Add("Text", "vObst x200 y18", "▲")
MyGui.SetFont("ccccccc s10")
MyGui.Add("Text", "vAgent x" agentX " y17 h10 Right", " ☻")

;GUI OVER TASKBAR  tinyurl.com/plankoe-did-this
DllCall("dwmapi\DwmSetWindowAttribute","ptr",MyGui.hwnd,"uint",12,"uint*",1,"uint",4)
hHook:=DllCall("SetWinEventHook", "UInt",0x8005, "UInt",0x800B, "Ptr",0,
       "Ptr",CallbackCreate(WinEventHookProc), "UInt",0, "UInt",0, "UInt",0x2)
WinEventHookProc(p1, p2, p3, p4, p5, p6, p7)
  { if !p3 and p4=0xFFFFFFF7
        return
    SetTimer(()=>DllCall("SetWindowPos","ptr",  Tray,"ptr",  MyGui.hwnd,"int", 
                 0,"int",  0,"int",  0,"int",  0,"uint",  0x10|0x2|0x200), -1)
  }

;FUNCTIONS
Sym()
  { hotkey:= SubStr(A_ThisHotkey,2)
    While GetKeyState(hotkey)
     { MyGui["Obst"].Move(i)
       global i+= 2+score/20
       MyGui["Agent"].Move(,17-h)
       global v:=h<0?0:v-0.23,  h:=h<0?0:h+v
       if abs(agentX-i+6)+h < 10
        { MyGui["Score"].Value:= gg score (h<2?"":"  _")
          MyGui["Agent"].Value:= "😵"
          KeyWait(hotkey)
              global fs:=max(fs,score),  score:=0,  i:=-1
        }
       if i > 195
          global score+=1,  i:=0
       if i < 10
        { MyGui["Score"].Value:=i<0&&score=0?hs fs (h<2?"":"  _"):score
          MyGui["Agent"].Value:= i<0? "😵": " ☻"
          MyGui["Obst"].Redraw()
        }
       Sleep 20   ;>>>FRAMERATE
     }
  }
Jump()
  { global v+=h>2?0:3, h:=h>2?h:h+v
  }
~LButton::
  { MouseGetPos(&mouX, &mouY)
    if guiX<mouX and mouX<(guiX+guiW) and guiY<mouY and mouY<(guiY+guiH)
      { MyGui.BackColor:= "995500"
        Tooltip("Hold CTRL to run - Press SHIFT to jump", guiX, guiY+guiH)
        SetTimer () => ToolTip(),-3000
        deltaX:=mouX-guiX,  deltaY:=mouY-guiY,  wspX:=SysGet(78)-guiW,  wspY:=SysGet(79)-guiH
        Loop
          { MouseGetPos(&mouX, &mouY)
            global guiX:=(min(wspX,mouX-deltaX)),  guiY:=(min(wspY,mouY-deltaY))
            MyGui.Show("x" guiX " y" guiY " NoActivate")
            if !GetKeyState("LButton")
                MyGui.BackColor:= "301000"
          } Until !GetKeyState("LButton")
       }
    else if MyGui.BackColor!="000000"
        MyGui.BackColor:="000000"
  }