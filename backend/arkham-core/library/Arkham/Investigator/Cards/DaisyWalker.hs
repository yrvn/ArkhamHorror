module Arkham.Investigator.Cards.DaisyWalker (
  DaisyWalker (..),
  daisyWalker,
) where

import Arkham.Prelude

import Arkham.Action.Additional
import Arkham.Helpers.Modifiers
import Arkham.Investigator.Cards qualified as Cards
import Arkham.Investigator.Runner
import Arkham.Matcher
import Arkham.Message

newtype DaisyWalker = DaisyWalker InvestigatorAttrs
  deriving anyclass (IsInvestigator, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

daisyWalker :: InvestigatorCard DaisyWalker
daisyWalker =
  investigator
    DaisyWalker
    Cards.daisyWalker
    Stats
      { health = 5
      , sanity = 9
      , willpower = 3
      , intellect = 5
      , combat = 2
      , agility = 2
      }

instance HasTokenValue DaisyWalker where
  getTokenValue iid ElderSign (DaisyWalker attrs)
    | iid == toId attrs =
        pure $ TokenValue ElderSign (PositiveModifier 0)
  getTokenValue _ token _ = pure $ TokenValue token mempty

instance HasModifiersFor DaisyWalker where
  getModifiersFor target (DaisyWalker a)
    | isTarget a target =
        pure $ toModifiers a [GiveAdditionalAction $ TraitRestrictedAdditionalAction Tome AbilitiesOnly]
  getModifiersFor _ _ = pure []

instance RunMessage DaisyWalker where
  runMessage msg i@(DaisyWalker attrs@InvestigatorAttrs {..}) = case msg of
    PassedSkillTest iid _ _ (TokenTarget token) _ _ | iid == investigatorId ->
      do
        when (tokenFace token == ElderSign) $ do
          tomeCount <-
            selectCount $
              assetControlledBy investigatorId
                <> AssetWithTrait Tome
          when (tomeCount > 0) $ do
            drawing <- drawCards iid attrs tomeCount
            push drawing
        pure i
    _ -> DaisyWalker <$> runMessage msg attrs
