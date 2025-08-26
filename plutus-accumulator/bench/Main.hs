module Main where

import Accumulator.Run (runCheckMembership, runCheckNonMembership)
import Bls.Run (runBls)
import System.IO (stdout)

main :: IO ()
main = do 
    runBls stdout
    runCheckMembership stdout
    runCheckNonMembership stdout