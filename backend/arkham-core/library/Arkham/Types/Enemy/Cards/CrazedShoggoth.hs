module Arkham.Types.Enemy.Cards.CrazedShoggoth
  ( CrazedShoggoth(..)
  , crazedShoggoth
  ) where

import Arkham.Prelude

import qualified Arkham.Enemy.Cards as Cards
import Arkham.Types.Classes
import Arkham.Types.Enemy.Attrs
import Arkham.Types.Id
import Arkham.Types.Message
import Arkham.Types.Trait

newtype CrazedShoggoth = CrazedShoggoth EnemyAttrs
  deriving anyclass IsEnemy
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

crazedShoggoth :: EnemyCard CrazedShoggoth
crazedShoggoth =
  enemy CrazedShoggoth Cards.crazedShoggoth (3, Static 6, 4) (2, 2)

instance EnemyAttrsHasAbilities env => HasAbilities env CrazedShoggoth where
  getAbilities i window (CrazedShoggoth attrs) = getAbilities i window attrs

instance HasModifiersFor env CrazedShoggoth

instance
  ( HasSet ClosestLocationId env (LocationId , [Trait])
  , EnemyAttrsRunMessage env
  )
  => RunMessage env CrazedShoggoth where
  runMessage msg e@(CrazedShoggoth attrs) = case msg of
    InvestigatorDrawEnemy iid _ eid | eid == enemyId attrs -> do
      lid <- getId @LocationId iid
      closestAlteredLocationIds <- map unClosestLocationId
        <$> getSetList (lid, [Altered])
      e <$ spawnAtOneOf iid eid closestAlteredLocationIds
    InvestigatorWhenDefeated source iid | isSource attrs source ->
      e <$ push (InvestigatorKilled iid)
    _ -> CrazedShoggoth <$> runMessage msg attrs
