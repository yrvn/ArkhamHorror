module Arkham.Helpers.Modifiers
  ( module Arkham.Helpers.Modifiers
  , module X
  ) where

import Arkham.Prelude

import Arkham.Classes.Entity
import Arkham.Effect.Window
import Arkham.EffectMetadata
import {-# SOURCE #-} Arkham.Game ()
import {-# SOURCE #-} Arkham.GameEnv
import Arkham.Message
import Arkham.Modifier as X
import Arkham.Target

getModifiers :: (HasGame m, Targetable a) => a -> m [ModifierType]
getModifiers (toTarget -> target) = map modifierType <$> getModifiers' target

getModifiers' :: (HasGame m, Targetable a) => a -> m [Modifier]
getModifiers' (toTarget -> target) =
  findWithDefault [] target <$> getAllModifiers

hasModifier
  :: (HasGame m, Targetable a) => a -> ModifierType -> m Bool
hasModifier a m = (m `elem`) <$> getModifiers (toTarget a)

withoutModifier
  :: (HasGame m, Targetable a) => a -> ModifierType -> m Bool
withoutModifier a m = not <$> hasModifier a m

toModifier :: Sourceable a => a -> ModifierType -> Modifier
toModifier a mType = Modifier (toSource a) mType False

toModifiers :: Sourceable a => a -> [ModifierType] -> [Modifier]
toModifiers = map . toModifier

toModifiersWith :: Sourceable a => a -> (Modifier -> Modifier) -> [ModifierType] -> [Modifier]
toModifiersWith a f xs= map (f . toModifier a) xs

skillTestModifier
  :: (Sourceable source, Targetable target)
  => source
  -> target
  -> ModifierType
  -> Message
skillTestModifier source target modifier =
  skillTestModifiers source target [modifier]

skillTestModifiers
  :: (Sourceable source, Targetable target)
  => source
  -> target
  -> [ModifierType]
  -> Message
skillTestModifiers source target modifiers = CreateWindowModifierEffect
  EffectSkillTestWindow
  (EffectModifiers $ toModifiers source modifiers)
  (toSource source)
  (toTarget target)
