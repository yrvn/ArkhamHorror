module Arkham.Skill.Cards.InspiringPrescence
  ( inspiringPrescence
  , InspiringPrescence(..)
  )
where

import Arkham.Prelude

import qualified Arkham.Skill.Cards as Cards
import Arkham.Asset.Attrs
import Arkham.Classes
import Arkham.Matcher hiding (AssetExhausted)
import Arkham.Message hiding (AssetDamage)
import Arkham.Projection
import Arkham.Target
import Arkham.Trait
import Arkham.Skill.Attrs
import Arkham.Skill.Runner

newtype InspiringPrescence = InspiringPrescence SkillAttrs
  deriving anyclass (IsSkill, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

inspiringPrescence :: SkillCard InspiringPrescence
inspiringPrescence =
  skill InspiringPrescence Cards.inspiringPrescence

instance SkillRunner env => RunMessage env InspiringPrescence where
  runMessage msg s@(InspiringPrescence attrs) = case msg of
    PassedSkillTest _ _ _ (isTarget attrs -> True) _ _ -> do
      assets <- selectList
        $ AssetAt
          (LocationWithInvestigator $ InvestigatorWithId $ skillOwner attrs)
        <> AllyAsset
      choices <- flip mapMaybeM assets $ \a -> do
        let target = AssetTarget a
            healDamage = HealDamage target 1
            healHorror = HealHorror target 1
        hasDamage <- fieldP AssetDamage (> 0) a
        hasHorror <- fieldP AssetHorror (> 0) a
        exhausted <- field AssetExhausted a
        let
          andChoices = if hasDamage && hasHorror
            then
              [ chooseOne (skillOwner attrs)
                [ Label "Heal 1 damage" [healDamage]
                , Label "Heal 1 horror" [healHorror]
                ]
              ]
            else [healDamage | hasDamage] <> [healHorror | hasHorror]
          msgs = [Ready target | exhausted] <> andChoices

        pure $ if null msgs then Nothing else Just $ TargetLabel target msgs

      unless (null choices) $
        push $ chooseOne (skillOwner attrs) choices
      pure s
    _ -> InspiringPrescence <$> runMessage msg attrs
