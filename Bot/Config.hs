module Bot.Config

where

import System.IO
import System.Time

import Control.Monad.Reader as R

server     = "irc.freenode.org"
port       = 6667
chan       = "#developerslv"
nick       = "Xn_pls"
lambdabot  = "lambdabot"
clojurebot = "clojurebot"

--
-- The 'Net' monad, a wrapper over IO, carrying the bot's immutable state.
-- A socket and the bot's start time.
--
type Net = ReaderT Bot IO
data Bot = Bot { socket :: Handle, starttime :: ClockTime }

--
-- Convenience.
--
io :: IO a -> Net a
io = liftIO
