import qualified Data.Map as M
import Data.Monoid

import System.Exit(ExitCode(ExitSuccess), exitWith)
import XMonad
import XMonad.Actions.CycleWS(nextScreen, swapNextScreen)
import XMonad.Actions.Navigation2D
import XMonad.Config.Desktop
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Maximize
import XMonad.Layout.NoBorders
import qualified XMonad.StackSet as W

main = do
    xmonad desktopConfig
        { modMask = mod4Mask
        , terminal = "alacritty"
        , manageHook = manageDocks
            <+> composeAll
                [ isFullscreen --> doFullFloat
                , className =? "Xfce4-notifyd" --> doIgnore
                , isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_MENU" --> doFloat
                ]
            <+> manageHook desktopConfig
        , keys = \c -> keys' c
        , layoutHook = maximizeWithPadding 0 layout'
        }

layout' = avoidStruts $ smartBorders $ tallLayout ||| Mirror tallLayout
tallLayout = Tall 1 (3/100) (1/2)

keys' (XConfig {modMask = modm, terminal = terminal, workspaces = workspaces}) = M.fromList $
    [ ((modm, xK_q), kill)
    , ((modm .|. shiftMask, xK_q), io $ exitWith ExitSuccess)
    , ((modm .|. shiftMask, xK_Return), spawn terminal)
    , ((modm, xK_space), sendMessage NextLayout)
    , ((modm, xK_p), spawn "rofi -show drun")
    , ((modm, xK_i), spawn "rofi -show ssh")
    -- xinerama movements
    , ((modm, xK_w), nextScreen)
    , ((modm, xK_e), swapNextScreen)
    -- window navigation
    , ((modm, xK_Tab), windows W.focusDown)
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
    , ((modm, xK_bracketright), spawn "playerctl next")
    , ((modm, xK_bracketleft), spawn "playerctl previous")
    , ((modm, xK_backslash), spawn "playerctl play-pause")
    ]
    ++
    -- workspace navigation
    [((modifier .|. modm, key), windows $ action i)
        | (i, key) <- zip workspaces [xK_1 .. xK_9]
        , (action, modifier) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
