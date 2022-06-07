{-# OPTIONS_GHC -Wno-orphans #-}
module Arkham.Treachery.Runner
  ( module X
  ) where

import Arkham.Prelude

import Arkham.Treachery.Attrs as X

import Arkham.Classes.Entity
import Arkham.Classes.HasQueue
import Arkham.Classes.RunMessage
import Arkham.Message
import Arkham.Target

instance RunMessage TreacheryAttrs where
  runMessage msg a@TreacheryAttrs {..} = case msg of
    InvestigatorEliminated iid
      | InvestigatorTarget iid `elem` treacheryAttachedTarget -> a
      <$ push (Discard $ toTarget a)
    AttachTreachery tid target | tid == treacheryId ->
      pure $ a & attachedTargetL ?~ target
    PlaceResources target n | isTarget a target -> do
      pure $ a & resourcesL +~ n
    PlaceEnemyInVoid eid | EnemyTarget eid `elem` treacheryAttachedTarget ->
      a <$ push (Discard $ toTarget a)
    AddTreacheryToHand iid tid | tid == treacheryId ->
      pure $ a & inHandOfL ?~ iid
    Discarded target _ | target `elem` treacheryAttachedTarget ->
      a <$ push (Discard $ toTarget a)
    After (Revelation _ source) | isSource a source -> a <$ when
      (isNothing treacheryAttachedTarget && isNothing treacheryInHandOf)
      (push $ Discard $ toTarget a)
    _ -> pure a
