import qualified Data.Map as M
import Data.Monoid

import System.Exit(ExitCode(ExitSuccess), exitWith)
import XMonad
import XMonad.Actions.CycleWS(nextScreen, swapNextScreen)
import XMonad.Actions.EasyMotion(selectWindow, EasyMotionConfig(..), ChordKeys(..))
import XMonad.Actions.Navigation2D
import XMonad.Config.Desktop
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Maximize
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Util.Themes
import qualified XMonad.StackSet as W

main = do
    xmonad desktopConfig
        { modMask = mod4Mask
        , terminal = "wezterm"
        , workspaces = map fst workspaces'
        , manageHook = insertPosition End Newer
            <+> manageDocks
            <+> composeAll
                [ isFullscreen --> doFullFloat
                , className =? "Xfce4-notifyd" --> doIgnore
                , isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_MENU" --> doFloat
                ]
            <+> manageHook desktopConfig
        , keys = \c -> keys' c
        , layoutHook = maximizeWithPadding 10 layout'
        }

layout' = avoidStruts $ noBorders (tabbed shrinkText theme') ||| Mirror tallLayout ||| tallLayout
tallLayout = Tall 1 (3/100) (1/2)

theme' = (theme smallClean)
    { decoHeight = 22
    , fontName = "xft:DejaVu Sans:style=Book;2"
    -- Adapted the tab colors
    -- https://github.com/EdenEast/nightfox.nvim/blob/main/extra/nightfox/wezterm.toml
    , activeColor         = "#71839b"
    , activeBorderColor   = "#71839b"
    , activeTextColor     = "#192330"
    , inactiveColor       = "#212e3f"
    , inactiveBorderColor = "#212e3f"
    , inactiveTextColor   = "#aeafb0"
    }

workspaces' =
    [ ("1", xK_1)
    , ("2", xK_2)
    , ("3", xK_3)
    , ("4", xK_4)
    , ("5", xK_5)
    , ("6", xK_6)
    , ("7", xK_7)
    , ("8", xK_8)
    , ("9", xK_9)
    , ("`", xK_grave)
    , ("0", xK_0)
    , ("-", xK_minus)
    , ("=", xK_equal)
    ]

keys' (XConfig {modMask = modm, terminal = terminal}) = M.fromList $
    [ ((modm, xK_q), kill)
    , ((modm .|. shiftMask, xK_q), io $ exitWith ExitSuccess)
    , ((modm .|. shiftMask, xK_w), spawn "systemctl suspend")
    , ((modm .|. shiftMask, xK_Return), spawn terminal)
    , ((modm, xK_space), sendMessage NextLayout)
    , ((modm, xK_o), spawn "zeal")
    , ((modm, xK_p), spawn "rofi -show drun")
    , ((modm, xK_i), spawn "rofi -show ssh")
    , ((modm, xK_u), spawn "rofimoji --files all --copy-only")
    -- xinerama movements
    , ((modm, xK_w), nextScreen)
    , ((modm, xK_e), swapNextScreen)
    -- window navigation
    , ((modm, xK_Tab), tabOrEasyMotion)
    , ((modm, xK_h), windowGo L True)
    , ((modm, xK_j), windowGo D True)
    , ((modm, xK_k), windowGo U True)
    , ((modm, xK_l), windowGo R True)
    -- layout
    , ((modm, xK_a), withFocused (sendMessage . maximizeRestore))
    , ((modm, xK_t), withFocused (windows . W.sink))
    , ((modm, xK_Return), windows W.swapMaster)
    , ((modm, xK_m), sendMessage Expand)
    , ((modm, xK_n), sendMessage Shrink)
    -- media keys
    , ((modm, xK_bracketright), spawn "playerctl -p spotify next")
    , ((modm, xK_bracketleft), spawn "playerctl -p spotify previous")
    , ((modm, xK_backslash), spawn "playerctl -p spotify play-pause")
    ]
    ++
    -- workspace navigation
    [((modm .|. modifier, key), windows $ action name)
        | (name, key) <- workspaces'
        , (action, modifier) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

tabOrEasyMotion = do
    -- https://stackoverflow.com/a/62075879
    numWindows <- length . W.index . windowset <$> get
    if numWindows <= 2 then tab else easymotion
  where
    tab = windows W.focusDown
    easymotion = selectWindow cfg >>= (`whenJust` windows . W.focusWindow)
    cfg = def {
        sKeys = AnyKeys [xK_a, xK_s, xK_d, xK_f, xK_h, xK_j, xK_k, xK_l]
    }
