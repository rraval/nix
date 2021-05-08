import qualified Data.Map as M
import Data.Monoid

import XMonad

import XMonad.Actions.CycleWS(nextScreen, swapNextScreen)
import XMonad.Actions.Navigation2D
import XMonad.Config.Xfce
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Maximize
import XMonad.Layout.NoBorders

main = do
    xmonad xfceConfig
        { modMask = mod4Mask
        , manageHook = manageDocks
            <+> composeAll
                [ isFullscreen --> doFullFloat
                , className =? "Xfce4-notifyd" --> doIgnore
                , isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_MENU" --> doFloat
                ]
            <+> manageHook xfceConfig
        , keys = \c -> keys' c `M.union` keys xfceConfig c
        , layoutHook = maximizeWithPadding 0 layout'
        }

layout' = avoidStruts $ smartBorders $ tallLayout ||| Mirror tallLayout
tallLayout = Tall 1 (3/100) (1/2)

keys' conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm, xK_q), kill)
    , ((modm .|. shiftMask, xK_c), spawn "xmonad --recompile && xmonad --restart")
    , ((modm .|. shiftMask, xK_Return), spawn "alacritty")
    , ((modm, xK_r), spawn "xflock4")
    -- xinerama movements
    , ((modm, xK_w), nextScreen)
    , ((modm, xK_e), swapNextScreen)
    -- 2D navigation
    , ((modm, xK_h), windowGo L True)
    , ((modm, xK_j), windowGo D True)
    , ((modm, xK_k), windowGo U True)
    , ((modm, xK_l), windowGo R True)
    -- shrink & expand master pane
    , ((modm, xK_a), withFocused (sendMessage . maximizeRestore))
    , ((modm, xK_m), sendMessage Expand)
    , ((modm, xK_n), sendMessage Shrink)
    -- restore defaults
    , ((modm, xK_p), spawn "xfce4-popup-whiskermenu")
    , ((modm, xK_o), spawn "zeal")
    -- media keys
    , ((modm, xK_bracketright), spawn "playerctl next")
    , ((modm, xK_bracketleft), spawn "playerctl previous")
    , ((modm, xK_backslash), spawn "playerctl play-pause")
    ]
