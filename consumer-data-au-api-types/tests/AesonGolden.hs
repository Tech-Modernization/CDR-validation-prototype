{-# LANGUAGE ScopedTypeVariables #-}

module AesonGolden where

import           Data.Aeson
    (FromJSON, ToJSON, decodeStrict, encode, encodeFile, toJSON)
import           Data.Aeson.Diff (diff, patchOperations)
import           Data.Bool       (bool)
import qualified Data.ByteString as BS

import Test.Tasty                 (TestName, TestTree)
import Test.Tasty.Golden.Advanced (goldenTest)

aesonGolden ::
  forall a.
  ( FromJSON a
  , ToJSON a
  )
  => TestName
  -> FilePath
  -> IO a
  -> TestTree
aesonGolden name gf a =
  let
    bsToVal =
      maybe (error "Unable to decode golden file") pure . decodeStrict
    readGolden =
      bsToVal =<< BS.readFile gf
  in
    goldenTest
      name
      readGolden
      a
      aesonDiff
      (encodeFile gf)

aesonDiff ::
  ToJSON a
  => a
  -> a
  -> IO (Maybe String)
aesonDiff v1 v2 =
  let
    patch = diff (toJSON v1) (toJSON v2)
    hasPatch = null . patchOperations $ patch
    prettyPatch = Just . show . encode $ patch
  in
    pure $ bool prettyPatch Nothing hasPatch
