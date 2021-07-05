module Arkham.Types.Location.Cards.UprootedWoods
  ( uprootedWoods
  , UprootedWoods(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Location.Cards as Cards (uprootedWoods)
import Arkham.Types.Ability
import Arkham.Types.Classes
import Arkham.Types.GameValue
import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Runner
import Arkham.Types.LocationSymbol
import Arkham.Types.Message
import Arkham.Types.Query
import Arkham.Types.Window

newtype UprootedWoods = UprootedWoods LocationAttrs
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

uprootedWoods :: LocationCard UprootedWoods
uprootedWoods = locationWith
  UprootedWoods
  Cards.uprootedWoods
  2
  (PerPlayer 1)
  NoSymbol
  []
  ((revealedSymbolL .~ Moon)
  . (revealedConnectedSymbolsL .~ setFromList [Square, T])
  . (unrevealedNameL .~ "Altered Path")
  )

instance HasModifiersFor env UprootedWoods where
  getModifiersFor = noModifiersFor

forcedAbility :: LocationAttrs -> Ability
forcedAbility a = mkAbility (toSource a) 1 ForcedAbility

instance ActionRunner env => HasActions env UprootedWoods where
  getActions iid (AfterRevealLocation You) (UprootedWoods attrs)
    | iid `on` attrs = do
      actionRemainingCount <- unActionRemainingCount <$> getCount iid
      pure [ UseAbility iid (forcedAbility attrs) | actionRemainingCount == 0 ]
  getActions iid window (UprootedWoods attrs) = getActions iid window attrs

instance LocationRunner env => RunMessage env UprootedWoods where
  runMessage msg l@(UprootedWoods attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> do
      l <$ unshiftMessage (DiscardTopOfDeck iid 5 Nothing)
    _ -> UprootedWoods <$> runMessage msg attrs
