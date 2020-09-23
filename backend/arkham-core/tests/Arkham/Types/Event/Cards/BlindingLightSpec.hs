module Arkham.Types.Event.Cards.BlindingLightSpec
  ( spec
  )
where

import TestImport

import Arkham.Types.Difficulty
import Arkham.Types.Helpers
import Arkham.Types.Token

spec :: Spec
spec = do
  describe "Blinding Light" $ do
    it "Uses willpower to evade an enemy" $ do
      theGathering <- newScenario Easy "01104"
      (investigatorId, investigator) <- newInvestigator "00000"
        $ \stats -> stats { willpower = 5, agility = 3 }
      (icyGhoulId, icyGhoul) <- newEnemy "01119"
      (blindingLightId, blindingLight) <- newEvent "01066" investigatorId
      (hallwayId, hallway) <- newLocation "01112"
      game <-
        runGameTest
          investigator
          [ EnemySpawn hallwayId icyGhoulId
          , MoveTo investigatorId hallwayId
          , InvestigatorPlayEvent investigatorId blindingLightId
          ]
          ((events %~ insertMap blindingLightId blindingLight)
          . (enemies %~ insertMap icyGhoulId icyGhoul)
          . (locations %~ insertMap hallwayId hallway)
          . (chaosBag .~ Bag [MinusOne])
          . (scenario ?~ theGathering)
          )
        >>= runGameTestOnlyOption "Evade enemy"
        >>= runGameTestOnlyOption "Run skill check"
        >>= runGameTestOnlyOption "Apply results"
      blindingLight `shouldSatisfy` isInDiscardOf game investigator
      icyGhoul `shouldSatisfy` evadedBy game investigator

    it "deals 1 damage to the evaded enemy" $ do
      theGathering <- newScenario Easy "01104"
      (investigatorId, investigator) <- newInvestigator "01004" id
      (icyGhoulId, icyGhoul) <- newEnemy "01119"
      (blindingLightId, blindingLight) <- newEvent "01066" investigatorId
      (hallwayId, hallway) <- newLocation "01112"
      game <-
        runGameTest
          investigator
          [ EnemySpawn hallwayId icyGhoulId
          , MoveTo investigatorId hallwayId
          , InvestigatorPlayEvent investigatorId blindingLightId
          ]
          ((events %~ insertMap blindingLightId blindingLight)
          . (enemies %~ insertMap icyGhoulId icyGhoul)
          . (locations %~ insertMap hallwayId hallway)
          . (chaosBag .~ Bag [MinusOne])
          . (scenario ?~ theGathering)
          )
        >>= runGameTestOnlyOption "Evade enemy"
        >>= runGameTestOnlyOption "Run skill check"
        >>= runGameTestOnlyOption "Apply results"
      blindingLight `shouldSatisfy` isInDiscardOf game investigator
      icyGhoul `shouldSatisfy` hasDamage game (1, 0)

    it
        "On Skull, Cultist, Tablet, ElderThing, or AutoFail the investigator loses an action"
      $ for_ [Skull, Cultist, Tablet, ElderThing, AutoFail]
      $ \token -> do
          theDevourerBelow <- newScenario Easy "01142"
          (investigatorId, investigator) <- newInvestigator "01004" id
          (icyGhoulId, icyGhoul) <- newEnemy "01119"
          (blindingLightId, blindingLight) <- newEvent "01066" investigatorId
          (hallwayId, hallway) <- newLocation "01112"
          game <-
            runGameTest
              investigator
              [ EnemySpawn hallwayId icyGhoulId
              , MoveTo investigatorId hallwayId
              , InvestigatorPlayEvent investigatorId blindingLightId
              ]
              ((events %~ insertMap blindingLightId blindingLight)
              . (enemies %~ insertMap icyGhoulId icyGhoul)
              . (locations %~ insertMap hallwayId hallway)
              . (chaosBag .~ Bag [token])
              . (scenario ?~ theDevourerBelow)
              )
            >>= runGameTestOnlyOption "Evade enemy"
            >>= runGameTestOnlyOption "Run skill check"
            >>= runGameTestOnlyOption "Apply results"
            >>= (\game -> if token == Tablet
                  then runGameTestOnlyOption "take damage" game
                  else pure game
                )
          blindingLight `shouldSatisfy` isInDiscardOf game investigator
          investigator `shouldSatisfy` hasRemainingActions game 2
