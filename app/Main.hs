module Main where

import Key
import Action
import DSL

chrome = [Instance "google-chrome-unstable"]
rubymine = [Class "jetbrains-rubymine"]
slack = [Instance "slack"]
telegram = [Title "Telegram"]
terminal = [Instance "urxvt", IsFloating]

setXkb layout = "setxkbmap " ++ layout ++ " && pkill -RTMIN+11 i3blocks"

config :: [I3ConfigStatement]
config = toList $ do
  execAlways "xinput set-prop 12 281 1" -- Enable Tapping.
  execAlways "xinput set-prop 12 283 0" -- Disable Tapping Drag.
  execAlways "xinput set-prop 12 289 0.85" -- Increase Accel Speed.
  execAlways "xinput set-prop 12 291 1" -- Enable natural scroll.
  execAlways "setxkbmap -option altwin:swap_alt_win"
  execAlways "setxkbmap -option ctrl:nocaps"
  raw "exec --no-startup-id dunst"

  exec "google-chrome-unstable"
  exec "slack"
  exec "telegram-desktop"

  font ["pango", "monospace"] 8

  bar "i3blocks"
  hideEdgeBorders

  bindsym [RaiseVolumeSym] (ExecAction "amixer -q sset Master 5%+ unmute && pkill -RTMIN+10 i3blocks")
  bindsym [LowerVolumeSym] (ExecAction "amixer -q sset Master 5%- unmute && pkill -RTMIN+10 i3blocks")
  bindsym [MuteSym] (ExecAction "amixer -q sset Master,0 toggle && pkill -RTMIN+10 i3blocks")

  bindsym [BrightnessUpSym] (ExecAction "xbacklight -inc 10")
  bindsym [BrightnessDownSym] (ExecAction "xbacklight -dec 10")

  Super Return ==> ExecAction "i3-sensible-terminal"
  Super W ==> Kill
  Super Slash ==> ExecAction "rofi -show drun"

  forWindow chrome [MoveAction Container (Workspace W1)]
  forWindow rubymine [MoveAction Container (Workspace W2)]
  forWindow slack [MoveAction Container (Workspace W4)]
  forWindow telegram [MoveAction Window Scratchpad, EnableSticky]

  bindsym [Mod4Sym, SpaceSym] (FocusAction ModeToggleFocusActionTarget)
  bindsym [Mod4Sym, ShiftSym, SpaceSym] [FloatingAction ToggleFloatingActionTarget]

  Super Minus ==> ShowScratchpad
  SuperShift Minus ==> [EnableSticky, MoveAction Window Scratchpad]

  Super J ==> action' chrome focus
  Super N ==> action' terminal ShowScratchpad
  Super K ==> action' rubymine focus
  Super Semicolon ==> action' slack focus
  bindsym [Mod4Sym, EqualSym] (action' telegram ShowScratchpad)

  Super LeftBracket ==> FocusLeft
  Super RightBracket ==> FocusRight
  Super F ==> ToggleFullscreen

  Super One ==> WorkspaceAction W1
  Super Two ==> WorkspaceAction W2
  Super Three ==> WorkspaceAction W3
  Super Four ==> WorkspaceAction W4
  Super Five ==> WorkspaceAction W5
  Super Six ==> WorkspaceAction W6
  Super Seven ==> WorkspaceAction W7
  Super Eight ==> WorkspaceAction W8
  Super Nine ==> WorkspaceAction W9
  Super Zero ==> WorkspaceAction W0

  mode (Super I) "Keyboard Layout Mode" $ do
    E ==> [ExecAction (setXkb "us"), exit]
    R ==> [ExecAction (setXkb "ru"), exit]
    U ==> [ExecAction (setXkb "ua"), exit]

  mode (Super Tilde) "i3 Management Mode" $ do
    C ==> [ReloadAction, exit]
    R ==> [RestartAction, exit]
    W ==> [ExecAction "rofi -show window", exit]

    mode L "Layout Mode" $ do
      S ==> [LayoutAction Stacking, exit]
      T ==> [LayoutAction Tabbed, exit]
      E ==> [LayoutAction ToggleSplit, exit]

  mode (Super R) "Resize Mode" $ do
    W ==> ResizeAction Grow Width 10
    N ==> ResizeAction Shrink Width 10
    H ==> ResizeAction Grow Height 10
    L ==> ResizeAction Shrink Height 10

  mode (Super M) "Move Mode" $ do
    H ==> MoveLeft
    L ==> MoveRight
    J ==> MoveDown
    K ==> MoveUp
    C ==> [MoveCenter, exit]

main :: IO ()
main = putStrLn $ interpret $ flatten [Mode (ModeName "default") config]
