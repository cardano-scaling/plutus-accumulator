{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Bls.Scripts (
    blsAddScalarListScript,
    blsNegateScalarListScript,
    blsMulScalarListScript,
    blsRecipScalarListScript,
    listOfSizedByteStrings,
) where

import PlutusTx (compile, getPlcNoAnn, liftCodeDef, unsafeApplyCode)
import PlutusTx.List (foldr, map)
import PlutusTx.Prelude (Integer, ($), (*), (+), (.))

import Plutus.Crypto.BlsUtils (Scalar (..), mkScalar, negateScalar, recip)
import PlutusCore (DefaultFun, DefaultUni)
import qualified UntypedPlutusCore as UPLC

import Data.ByteString (ByteString)
import qualified Hedgehog.Internal.Gen as G
import qualified Hedgehog.Internal.Range as R
import System.IO.Unsafe (unsafePerformIO)
import qualified Prelude as Haskell

blsAddScalarListScript :: [Scalar] -> UPLC.Program UPLC.NamedDeBruijn DefaultUni DefaultFun ()
blsAddScalarListScript xs =
    getPlcNoAnn
        $ $$(compile [||foldr (+) (mkScalar 0)||])
        `unsafeApplyCode` liftCodeDef xs

blsMulScalarListScript :: [Scalar] -> UPLC.Program UPLC.NamedDeBruijn DefaultUni DefaultFun ()
blsMulScalarListScript xs =
    getPlcNoAnn
        $ $$(compile [||foldr (*) (mkScalar 1)||])
        `unsafeApplyCode` liftCodeDef xs

blsNegateScalarListScript :: [Scalar] -> UPLC.Program UPLC.NamedDeBruijn DefaultUni DefaultFun ()
blsNegateScalarListScript xs =
    getPlcNoAnn
        $ $$(compile [||map negateScalar||])
        `unsafeApplyCode` liftCodeDef xs

blsRecipScalarListScript :: [Scalar] -> UPLC.Program UPLC.NamedDeBruijn DefaultUni DefaultFun ()
blsRecipScalarListScript xs =
    getPlcNoAnn
        $ $$(compile [||map (recip @Scalar)||])
        `unsafeApplyCode` liftCodeDef xs

{-# NOINLINE listOfSizedByteStrings #-}
listOfSizedByteStrings :: Integer -> Integer -> [ByteString]
listOfSizedByteStrings n l =
    unsafePerformIO
        . G.sample
        $ G.list
            (R.singleton $ Haskell.fromIntegral n)
            (G.bytes (R.singleton $ Haskell.fromIntegral l))