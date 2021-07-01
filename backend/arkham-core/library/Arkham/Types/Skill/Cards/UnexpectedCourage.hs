module Arkham.Types.Skill.Cards.UnexpectedCourage where

import Arkham.Prelude

import qualified Arkham.Skill.Cards as Cards
import Arkham.Types.Classes
import Arkham.Types.Skill.Attrs
import Arkham.Types.Skill.Runner

newtype UnexpectedCourage = UnexpectedCourage SkillAttrs
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

unexpectedCourage :: SkillCard UnexpectedCourage
unexpectedCourage = skill UnexpectedCourage Cards.unexpectedCourage

instance HasModifiersFor env UnexpectedCourage where
  getModifiersFor = noModifiersFor

instance HasActions env UnexpectedCourage where
  getActions i window (UnexpectedCourage attrs) = getActions i window attrs

instance (SkillRunner env) => RunMessage env UnexpectedCourage where
  runMessage msg (UnexpectedCourage attrs) =
    UnexpectedCourage <$> runMessage msg attrs
