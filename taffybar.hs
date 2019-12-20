module Main where

import           System.Taffybar                ( dyreTaffybar )
import           System.Taffybar.Context        ( Context
                                                , TaffyIO
                                                )
import           System.Taffybar.SimpleConfig
import           System.Taffybar.Widget.SimpleClock
                                                ( textClockNew )
import           System.Taffybar.Widget         ( windowsNew
                                                , layoutNew
                                                , defaultLayoutConfig
                                                , defaultWindowsConfig
                                                , buildContentsBox
                                                )
import           System.Taffybar.Widget.Workspaces
                                                ( showWorkspaceFn
                                                , defaultWorkspacesConfig
                                                , hideEmpty
                                                , workspacesNew
                                                , WorkspacesConfig
                                                )
import           System.Taffybar.Widget.FreedesktopNotifications
                                                ( notifyAreaNew
                                                , defaultNotificationConfig
                                                )
import           System.Taffybar.Widget.SNITray ( getHost
                                                , sniTrayNewFromHost
                                                )
import           GI.Gtk.Objects.Widget          ( Widget(..) )
import           Control.Monad.Trans.Reader     ( ReaderT )


workspaces, layout, windows, notifyArea :: TaffyIO Widget
workspaces = workspacesNew config
  where config = defaultWorkspacesConfig { showWorkspaceFn = hideEmpty }

layout = layoutNew config where config = defaultLayoutConfig
windows = windowsNew config where config = defaultWindowsConfig
notifyArea = notifyAreaNew config where config = defaultNotificationConfig

clock, tray :: ReaderT Context IO Widget
clock = textClockNew Nothing "%a %b %_d %I:%M %p" 5
tray = getHost True >>= sniTrayNewFromHost

config :: SimpleTaffyConfig
config = defaultSimpleTaffyConfig
  { startWidgets = workspaces : mkBox [layout, windows]
  , endWidgets   = mkBox [clock, tray, notifyArea]
  , barHeight    = 50
  , barPosition  = Top
  }
  where mkBox = map (>>= buildContentsBox)

main :: IO ()
main = dyreTaffybar $ toTaffyConfig config
