module Bls.Run (
    runBls,
) where

import Bls.Scripts (
    blsAddScalarListScript,
    blsMulScalarListScript,
    blsNegateScalarListScript,
    blsRecipScalarListScript,
    listOfSizedByteStrings,
 )
import GHC.ByteOrder (ByteOrder (..))
import Plutus.Crypto.BlsUtils (mkScalar)
import PlutusTx.Builtins (byteStringToInteger)
import PlutusTx.Prelude (toBuiltin)

import PlutusBenchmark.Common (TestSize (..), printHeader, printSizeStatistics)

import System.IO (Handle)
import Text.Printf (hPrintf)

runBls :: Handle -> IO ()
runBls h = do
    hPrintf h "\n\nBLS Scalar Field Operation Benchmarks\n\n"

    let ns = [1,10,20,30,40,50,60,70,80,90,100]

    let bench opName scriptGen = do
            hPrintf h "%s\n\n" opName
            printHeader h
            mapM_
                ( \n -> do
                    let inputs = map (mkScalar . byteStringToInteger BigEndian . toBuiltin) $ listOfSizedByteStrings n 31
                    printSizeStatistics h (TestSize n) (scriptGen inputs)
                )
                ns
            hPrintf h "\n"

    bench "Addition of Scalars" blsAddScalarListScript
    bench "Multiplication of Scalars" blsMulScalarListScript
    bench "Negation of Scalars" blsNegateScalarListScript
    bench "Reciprocal (Inverse) of Scalars" blsRecipScalarListScript