{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Asset.Cards.Hyperawareness where

import Arkham.Json
import Arkham.Types.Asset.Attrs
import Arkham.Types.Asset.Runner
import Arkham.Types.AssetId
import Arkham.Types.Classes
import Arkham.Types.Message
import Arkham.Types.Modifier
import Arkham.Types.SkillType
import Arkham.Types.Source
import Arkham.Types.Target
import qualified Arkham.Types.Window as Fast
import ClassyPrelude

newtype Hyperawareness = Hyperawareness Attrs
  deriving newtype (Show, ToJSON, FromJSON)

hyperawareness :: AssetId -> Hyperawareness
hyperawareness uuid = Hyperawareness $ baseAttrs uuid "01034"

instance HasModifiersFor env investigator Hyperawareness where
  getModifiersFor _ _ _ = pure []

instance (IsInvestigator investigator) => HasActions env investigator Hyperawareness where
  getActions i (Fast.WhenSkillTest SkillIntellect) (Hyperawareness Attrs {..})
    | Just (getId () i) == assetInvestigator = pure
      [ UseCardAbility (getId () i) (AssetSource assetId) Nothing 1
      | resourceCount i > 0
      ]
  getActions i (Fast.WhenSkillTest SkillAgility) (Hyperawareness Attrs {..})
    | Just (getId () i) == assetInvestigator = pure
      [ UseCardAbility (getId () i) (AssetSource assetId) Nothing 2
      | resourceCount i > 0
      ]
  getActions _ _ _ = pure []

instance (AssetRunner env) => RunMessage env Hyperawareness where
  runMessage msg a@(Hyperawareness attrs@Attrs {..}) = case msg of
    UseCardAbility iid (AssetSource aid) _ 1 | aid == assetId ->
      a <$ unshiftMessages
        [ SpendResources iid 1
        , AddModifiers
          SkillTestTarget
          (AssetSource aid)
          [SkillModifier SkillIntellect 1]
        ]
    UseCardAbility iid (AssetSource aid) _ 2 | aid == assetId ->
      a <$ unshiftMessages
        [ SpendResources iid 1
        , AddModifiers
          SkillTestTarget
          (AssetSource aid)
          [SkillModifier SkillAgility 1]
        ]
    _ -> Hyperawareness <$> runMessage msg attrs
