;▼▼▼ MICRO DINO - github.com/DavidBevi/MicroDino ▼▼▼
A_IconTip:= "MICRO DINO v2 by DavidBevi`n☻ Hold CTRL to run `n▲ Press SHIFT to jump"
CoordMode("Mouse")
CoordMode("Pixel")
~F2::(A_ThisHotkey=A_PriorHotkey and A_TimeSincePriorHotkey<200)? Reload(): {}


;▼ GET TRAY AREA POSITION
taskbar:= WinExist("ahk_class Shell_TrayWnd")
find(X,Y:=taskbar) => DllCall("FindWindowEx", "ptr",Y, "ptr",0, "str",X, "ptr",0, "ptr")
(tray:= find("TrayNotifyWnd"))? {}: (tray:= find("User Promoted Notification Area"))
WinGetPos(&trayX,&trayY,&_,&_,find("ToolbarWindow32",tray))


;▼ SET GUI POSITION
guiW:=200,  guiH:=30
guiX:= trayX - guiW -50
guiY:= trayY


;▼ USE ARGUMENTS IF PROVIDED
guiX:=A_Args.Length>0?A_Args[1]:guiX, guiY:=A_Args.Length>1?A_Args[2]:guiY


;▼ VARIABLES
agentX:=183,  state:=0,  fps:=120,  gg:="Game over:  ",  hs:="High score:  "

/* SAVE THE HIGH SCORE ACROSS INSTANCES
[s]
hs=55
*/
highscore(X:=0)=>(X? IniWrite(X,A_ScriptName,"s","hs"): IniRead(A_ScriptName,"s","hs"))

;▼ GUI
MyGui:= Gui("-Caption +ToolWindow +AlwaysOnTop -SysMenu +Owner" taskbar)
WinSetTransColor("000000", MyGui)
MyGui.BackColor:=((SysGet(78)-guiW)<guiX||(SysGet(79)-guiH)<guiY)?"995500":"000000"
guiX:=min(guiX,(SysGet(78)-guiW)),  guiY:=min(guiY,(SysGet(79)-guiH))
MyGui.Show("x" guiX " y" guiY " w" guiW " h" guiH " NoActivate")
MyGui.SetFont("ccccccc s9")
MyGui.Add("Text", "vScore y2 w184 Right", "MicroDino - Click for info")
MyGui.Add("Text", "vObst x200 y18", "▲")
MyGui.SetFont("ccccccc s10")
MyGui.Add("Text", "vAgent x" agentX " y17 h10 Right", " ☻")

;▼ GUI OVER TASKBAR  tinyurl.com/plankoe-did-this
DllCall("dwmapi\DwmSetWindowAttribute","ptr",MyGui.hwnd,"uint",12,"uint*",1,"uint",4)
hHook:=DllCall("SetWinEventHook", "UInt",0x8005, "UInt",0x800B, "Ptr",0,
       "Ptr",CallbackCreate(WinEventHookProc), "UInt",0, "UInt",0, "UInt",0x2)
WinEventHookProc(p1, p2, p3, p4, p5, p6, p7) {
    If !p3 and p4=0xFFFFFFF7
        return
    SetTimer(()=>DllCall("SetWindowPos","ptr",  taskbar,"ptr",  MyGui.hwnd,"int", 
                 0,"int",  0,"int",  0,"int",  0,"uint",  0x10|0x2|0x200), -1)
}


;▼ FUNCTIONS
Sym(jump:=0) {
    Static h:=0,  v:=0,  i:=0,  score:=0
    Static fs:= A_IsCompiled? 0: highscore()
    jump? (v+=h>2?0:3, h:=h>2?h:h+v) :{}
    MyGui["Obst"].Move(i)
    i+= 2+score/20
    MyGui["Agent"].Move(,17-h)
    v:=h<0?0:v-0.23,  h:=h<0?0:h+v
    If abs(agentX-i+6)+h < 10 {
        MyGui["Score"].Value:= gg score (h<2?"":"  _")
        MyGui["Agent"].Value:= "X"
        KeyWait("Control")
            fs:=max(fs,score),  score:=0,  i:=-1,  (A_IsCompiled? {}: highscore(fs))
    }
    If i > 195
        score+=1,  i:=0
    If i < 10 {
        MyGui["Score"].Value:=i<0&&score=0?hs fs (h<2?"":"  _"):score
        MyGui["Agent"].Value:= i<0? "X": " ☻"
        MyGui["Obst"].Redraw()
    }
}

~LButton:: {
    MouseGetPos(&mouX, &mouY)
    If guiX<mouX and mouX<(guiX+guiW) and guiY<mouY and mouY<(guiY+guiH) {
        MyGui.BackColor:= "995500"
        Tooltip("Hold CTRL to run - Press SHIFT to jump", guiX, guiY+guiH)
        SetTimer(()=>ToolTip(),-3000)
        deltaX:=mouX-guiX,  deltaY:=mouY-guiY,  wspX:=SysGet(78)-guiW,  wspY:=SysGet(79)-guiH
        Loop {
            MouseGetPos(&mouX, &mouY)
            global guiX:=(min(wspX,mouX-deltaX)),  guiY:=(min(wspY,mouY-deltaY))
            MyGui.Show("x" guiX " y" guiY " NoActivate")
            If !GetKeyState("LButton")
                MyGui.BackColor:= "301000"
        } Until !GetKeyState("LButton")
    } Else MyGui.BackColor:="000000"
}


;▼ RUN SYM
SetTimer(()=>(GetKeyState("Control")? Sym(GetKeyState("Shift")): {}),1000/fps)


;▼ CUSTOM TRAY ICON
If "SET CUSTOM TRAY ICON" {
    B64:= "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAIAAADYYG7QAAAABnRSTlMAAAAAAABupgeRAAABn0lEQVRYhd2ZQU7DMBBFvwtbDlAJVoDgCkis2zXHAMEVqipXAMExWJcVSJW64QKIA3CMsBg0hMQZT8zYsfJXqePUr3/G43bq4FNd197xdHLO/Vx07+WnIRFTG4hpXr421dM6A8fqer2YL5npD1B+mi7T3ug0AN7eXw/Pj44PTsAhG5GGta12AGaF0LBmRdGAHEIxNGCgQmgA7GsmUboJulxdWMAA7JCAEqSBglgvySF5mbOrU7r4eP60ooHg0NAPbWVSIGT5pUpqr2wjxSrOoUkDmeR1L5BhrRskKamZybDuBaXaZV63vJQ0qHF3W+280+JzSFg1eOAIdxPusrhAp932Qlj7FA+kNKA1LfhUzNGR9NydUKVOVDljQmaC0vcm/wpZCpMmlEOkOJOEpwwcGsokz7cJmZ4pODP+O3V3JS6AzVWbVVHDnS+plS7aONR3OEQc+AZArVXJCe+gRsXVIUcNK/6hPpbuHx+o71mEQ0yDEoCaNM65GY+WQAN2aDFf5mfq0oD61M1G7N3N7Yg06DbO86v198bvi1GYWjQAvgEzjLgoeOsyNQAAAABJRU5ErkJggg=="
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", StrPtr(B64), "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", &DecLen:=0, "Ptr", 0, "Ptr", 0)
        GoTo End
    Dec:= Buffer(DecLen, 0)
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", StrPtr(B64), "UInt", 0, "UInt", 0x01, "Ptr", Dec, "UIntP", &DecLen, "Ptr", 0, "Ptr", 0)
        GoTo End
    SI:= Buffer(8 + 2 * A_PtrSize, 0), NumPut("UInt", 1, SI, 0)
    hData:= DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
    pData:= DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
    hGdip:= DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
    DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", Dec, "UPtr", DecLen)
    DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
    DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream:=ComValue(13, 0))
    DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", &pToken := 0, "Ptr", SI, "Ptr", 0)
    DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", &pBitmap:=0)
    DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", &hBitmap:=0, "UInt", 0)
    TraySetIcon("hbitmap:*" hBitmap)
    DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
    DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
    DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
    End:
 }
