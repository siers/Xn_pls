module Bot.General

where

import Bot.Config
import Control.Monad.IO.Class
import Control.Monad.RWS
import Control.Concurrent.Chan
import Data.List
import Text.Printf

-- Send a privmsg to the channel/user + server
privmsgPrio :: Bool -> String -> String -> Net ()
privmsgPrio prio target s = do
    chan <- asks out
    liftIO $ writeChan chan (prio, printf "%s :%s" target s)

privmsg = privmsgPrio True

-- Send a message out to the server we're currently connected to
write :: String -> String -> Net ()
write s t = do
    h <- asks socket
    liftIO $ hPrintf h "%s %s\r\n" s t
    liftIO $ printf    "> %s %s\n" s t

-- Clear message of prefix
clean     = drop 1 . dropWhile (/= ':') . drop 1

-- Set target of response
target :: String -> String
target x  = if parts !! 1 == "PRIVMSG" && t /= lambdabot && t /= clojurebot && ch /= chan then t else chan
    where
        parts  = words x
        ch     = parts !! 2
        t      = takeWhile (/= '!') $ drop 1 $ parts !! 0

-- Get sender of message
sender :: String -> String
sender x
    | x == ""                 = chan
    | parts !! 1 == "PRIVMSG" = t
    | otherwise               = chan
    where
        parts  = words x
        t      = takeWhile (/= '!') $ drop 1 $ parts !! 0

addSender = ('<' :) . (++ ">")

-- Checks if string is valid Integer number
isInteger s = case reads s :: [(Integer, String)] of
    [(_, "")] -> True
    _         -> False
