{-# LANGUAGE LambdaCase    #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE MultiWayIf #-}

import           System.IO
import           System.Environment -- idea: envirnoment variable for display
import           XMonad
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers hiding (CW, CCW)
import           XMonad.Hooks.EwmhDesktops -- steam
import           XMonad.Layout.LayoutModifier (ModifiedLayout)
import           XMonad.Layout.Dwindle
import           XMonad.Layout.NoBorders
import           XMonad.Layout.Spacing
import           XMonad.Util.EZConfig         (additionalKeysP, removeMouseBindings)
import           XMonad.StackSet

import           Data.Monoid                  (All)
import           Data.Word                    (Word32)
import           Data.List                    (isPrefixOf)

main :: IO ()
main = do
    display <- getEnv "CURRENT_DISPLAY"
    xmonad =<< statusBar myBar myPP myToggleStrutsKey (myConfig display)

myBar :: String
myBar = "xmobar ~/.xmonad/.xmobarrc"

myPP :: PP
myPP = xmobarPP
    { ppHiddenNoWindows = xmobarColor "#6b7089" ""
    , ppCurrent = xmobarColor "#b4be82" "" . wrap "[" "]"
    , ppHidden = xmobarColor "#d2d4de" ""
    , ppSep = " || "
    , ppLayout = \str ->
        if | "Spacing Dwindle R" `isPrefixOf` str -> "Dwindle"
           | "Spacing Dwindle D" `isPrefixOf` str -> "Dwundle"
           | str == "Full"                        -> "  Full "
           | otherwise                            -> str
    , ppOrder =
        \case
                x:y:_ -> [x,y]
                _ -> []
    }

myToggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
myToggleStrutsKey XConfig { modMask = mask } = (mask, xK_t)

myKeyBindings :: [(String, X ())]
myKeyBindings =
    [ ("M-<Backspace>", spawn "pamixer -t")
    , ("M-=",           spawn "pamixer -i 2")
    , ("M--",           spawn "pamixer -d 2")
    , ("M-S-=",         spawn "light -A 5")
    , ("M-S--",         spawn "light -U 5")
    , ("M-f",           spawn "firefox")
    , ("M-i",           spawn "firefox --private-window")
    , ("M-S-l",         spawn "physlock -d")
    , ("M-S-f",         spawn "scrot ~/Pictures/screenshots/%Y-%m-%d-%T.png")
    , ("M-h",           spawn "headphones")
    , ("M-S-h",         spawn "headset")
    , ("M-z",           spawn "zoom")
    , ("M-v",           spawn $ myTerminal ++ " --command ~/.config/vifm/scripts/vifmrun ~ ~/Documents")
    , ("M-m",           spawn $ myTerminal ++ " --command mutt")
    ]

myConfig :: String -> XConfig MyLayout
myConfig display = docks $ ewmh $
    def
        { terminal           = myTerminal
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , modMask            = myModMask
        , layoutHook         = myLayoutHook display
        , borderWidth        = case display of
                                 "dell" -> 6
                                 _ -> 2
        }
        `additionalKeysP` myKeyBindings `removeMouseBindings` map (myModMask, ) [button1, button2, button3]

myTerminal :: String
myTerminal = "alacritty"

myNormalBorderColor :: String
myNormalBorderColor = "#161821"

myFocusedBorderColor :: String
myFocusedBorderColor = "#6b7089"
--myFocusedBorderColor = "#4D4E4F"

myModMask :: KeyMask
myModMask = mod4Mask

type MyLayout = Choose (ModifiedLayout Spacing Dwindle) (Choose (ModifiedLayout Spacing Dwindle) (ModifiedLayout WithBorder Full))

myLayoutHook :: String -> MyLayout Window
myLayoutHook display = spaced dwindle1 ||| spaced dwindle2 ||| noBorders Full
    where
        b = case display of
              "dell" -> 3
              _      -> 1
        spaced = spacingRaw True screenB True windowB True
        screenB = Border b b b b
        windowB = Border b b b b
        dwindle1 = Dwindle R CW 1 1.1
        dwindle2 = Dwindle D CCW 1 1.1
