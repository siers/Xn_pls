module Bot.Bot

where

import Data.Acid
import Text.Printf

import Control.Concurrent.Chan
import Control.Concurrent.Async
import Control.Monad.RWS hiding (listen)
import Control.Exception

import System.IO
import System.Time

import Network

import Bot.Config
import Bot.General
import Bot.Messaging

-- Connect to the server and return the initial bot state
connect :: IO Handle
connect = connectTo server (PortNumber (fromIntegral port))

makeBot :: ClockTime -> Handle -> IO Bot
makeBot time h = notify $ do
    c <- newChan
    t <- getClockTime
    hSetBuffering h NoBuffering
    hSetEncoding  h utf8
    return $ Bot h time c
        where
            notify a = bracket_
                (printf "Connecting to %s ... " server >> hFlush stdout)
                (putStrLn "done.")
                a

-- Join a channel, and start processing commands
ident :: Net ()
ident = do
    write "NICK" nick
    write "USER" (nick ++" 0 * :" ++ chan ++ " channel bot")
    write "JOIN" chan
