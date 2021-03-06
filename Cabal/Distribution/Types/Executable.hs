{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}

module Distribution.Types.Executable (
    Executable(..),
    emptyExecutable,
    exeModules,
) where

import Prelude ()
import Distribution.Compat.Prelude

import Distribution.Types.BuildInfo
import Distribution.ModuleName

data Executable = Executable {
        exeName    :: String,
        modulePath :: FilePath,
        buildInfo  :: BuildInfo
    }
    deriving (Generic, Show, Read, Eq, Typeable, Data)

instance Binary Executable

instance Monoid Executable where
  mempty = gmempty
  mappend = (<>)

instance Semigroup Executable where
  a <> b = Executable{
    exeName    = combine' exeName,
    modulePath = combine modulePath,
    buildInfo  = combine buildInfo
  }
    where combine field = field a `mappend` field b
          combine' field = case (field a, field b) of
                      ("","") -> ""
                      ("", x) -> x
                      (x, "") -> x
                      (x, y) -> error $ "Ambiguous values for executable field: '"
                                  ++ x ++ "' and '" ++ y ++ "'"

emptyExecutable :: Executable
emptyExecutable = mempty

-- | Get all the module names from an exe
exeModules :: Executable -> [ModuleName]
exeModules exe = otherModules (buildInfo exe)
