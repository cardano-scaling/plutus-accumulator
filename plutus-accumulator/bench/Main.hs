module Main where

import Bls.Run (runBls)
import System.IO (stdout)

main :: IO ()
main = do runBls stdout