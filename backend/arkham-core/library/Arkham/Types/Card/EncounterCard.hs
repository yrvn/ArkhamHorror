module Arkham.Types.Card.EncounterCard
  ( module Arkham.Types.Card.EncounterCard
  , module Arkham.Types.Card.EncounterCardMatcher
  , module Arkham.Types.Card.EncounterCardType
  )
where

import Arkham.Json
import Arkham.Types.Card.CardCode
import Arkham.Types.Card.Class
import Arkham.Types.Card.EncounterCardMatcher
import Arkham.Types.Card.EncounterCardType
import Arkham.Types.Card.Id
import Arkham.Types.Keyword (Keyword)
import qualified Arkham.Types.Keyword as Keyword
import Arkham.Types.Trait
import ClassyPrelude
import qualified Data.HashMap.Strict as HashMap
import Safe (fromJustNote)

data EncounterCard = MkEncounterCard
  { ecCardCode :: CardCode
  , ecName :: Text
  , ecCardType :: EncounterCardType
  , ecTraits   :: HashSet Trait
  , ecKeywords   :: [Keyword]
  , ecId :: CardId
  , ecVictoryPoints :: Maybe Int
  }
  deriving stock (Show, Eq, Generic)
  deriving anyclass (Hashable)

lookupEncounterCard :: CardCode -> (CardId -> EncounterCard)
lookupEncounterCard cardCode =
  fromJustNote ("Unknown card: " <> show cardCode)
    $ HashMap.lookup cardCode allEncounterCards

baseEncounterCard
  :: CardId -> CardCode -> Text -> EncounterCardType -> EncounterCard
baseEncounterCard cardId cardCode name encounterCardType = MkEncounterCard
  { ecCardCode = cardCode
  , ecId = cardId
  , ecName = name
  , ecTraits = mempty
  , ecKeywords = mempty
  , ecCardType = encounterCardType
  , ecVictoryPoints = Nothing
  }

enemy :: CardId -> CardCode -> Text -> EncounterCard
enemy cardId cardCode name = baseEncounterCard cardId cardCode name EnemyType

treachery :: CardId -> CardCode -> Text -> EncounterCard
treachery cardId cardCode name =
  baseEncounterCard cardId cardCode name TreacheryType

instance ToJSON EncounterCard where
  toJSON = genericToJSON $ aesonOptions $ Just "ec"
  toEncoding = genericToEncoding $ aesonOptions $ Just "ec"

instance FromJSON EncounterCard where
  parseJSON = genericParseJSON $ aesonOptions $ Just "ec"

instance HasCardCode EncounterCard where
  getCardCode = ecCardCode

instance HasCardId EncounterCard where
  getCardId = ecId

encounterCardMatch :: EncounterCardMatcher -> EncounterCard -> Bool
encounterCardMatch (EncounterCardMatchByType (cardType, mtrait)) MkEncounterCard {..}
  = ecCardType == cardType && maybe True (`elem` ecTraits) mtrait
encounterCardMatch (EncounterCardMatchByCardCode cardCode) card =
  getCardCode card == cardCode

allEncounterCards :: HashMap CardCode (CardId -> EncounterCard)
allEncounterCards = HashMap.fromList
  [ ("enemy", placeholderEnemy)
  , ("treachery", placeholderTreachery)
  , ("01116", ghoulPriest)
  , ("01118", fleshEater)
  , ("01119", icyGhoul)
  , ("01121b", theMaskedHunter)
  , ("01135", huntingShadow)
  , ("01136", falseLead)
  , ("01137", wolfManDrew)
  , ("01138", hermanCollins)
  , ("01139", peterWarren)
  , ("01140", victoriaDevereux)
  , ("01141", ruthTurner)
  , ("01157", umordhoth)
  , ("01158", umordhothsWrath)
  , ("01159", swarmOfRats)
  , ("01160", ghoulMinion)
  , ("01161", ravenousGhoul)
  , ("01162", graspingHands)
  , ("01163", rottingRemains)
  , ("01164", frozenInFear)
  , ("01165", dissonantVoices)
  , ("01166", ancientEvils)
  , ("01167", cryptChill)
  , ("01168", obscuringFog)
  , ("01169", acolyte)
  , ("01170", wizardOfTheOrder)
  , ("01171", mysteriousChanting)
  , ("01172", huntingNightgaunt)
  , ("01173", onWingsOfDarkness)
  , ("01174", lockedDoor)
  , ("01175", screechingByakhee)
  , ("01176", theYellowSign)
  , ("01177", yithianObserver)
  , ("01178", offerOfPower)
  , ("01179", relentlessDarkYoung)
  , ("01180", goatSpawn)
  , ("01181", youngDeepOne)
  , ("01182", dreamsOfRlyeh)
  , ("50022", corpseHungryGhoul)
  , ("50023", ghoulFromTheDepths)
  , ("50024", theZealotsSeal)
  , ("50026b", narogath)
  , ("50031", maskedHorrors)
  , ("50038", graveEater)
  , ("50039", acolyteOfUmordhoth)
  , ("50040", chillFromBelow)
  , ("50041", discipleOfTheDevourer)
  , ("81022", bogGator)
  , ("81023", swampLeech)
  , ("81024", cursedSwamp)
  , ("81025", spectralMist)
  , ("81026", draggedUnder)
  , ("81027", ripplesOnTheSurface)
  , ("81028", theRougarou)
  , ("81031", slimeCoveredDhole)
  , ("81032", marshGug)
  , ("81033", darkYoungHost)
  , ("81034", onTheProwl)
  , ("81035", beastOfTheBayou)
  , ("81036", insatiableBloodlust)
  ]

placeholderEnemy :: CardId -> EncounterCard
placeholderEnemy cardId =
  baseEncounterCard cardId "enemy" "Placeholder Enemy Card" EnemyType

placeholderTreachery :: CardId -> EncounterCard
placeholderTreachery cardId = baseEncounterCard
  cardId
  "treachery"
  "Placeholder Treachery Card"
  TreacheryType

ghoulPriest :: CardId -> EncounterCard
ghoulPriest cardId = (enemy cardId "01116" "Ghoul Priest")
  { ecTraits = setFromList [Humanoid, Monster, Ghoul, Elite]
  , ecKeywords = [Keyword.Hunter, Keyword.Retaliate]
  , ecVictoryPoints = Just 2
  }

fleshEater :: CardId -> EncounterCard
fleshEater cardId = (enemy cardId "01118" "Flesh-Eater")
  { ecTraits = setFromList [Humanoid, Monster, Ghoul]
  , ecVictoryPoints = Just 1
  }

icyGhoul :: CardId -> EncounterCard
icyGhoul cardId = (enemy cardId "01119" "Icy Ghoul")
  { ecTraits = setFromList [Humanoid, Monster, Ghoul]
  , ecVictoryPoints = Just 1
  }

theMaskedHunter :: CardId -> EncounterCard
theMaskedHunter cardId = (enemy cardId "01121b" "The Masked Hunter")
  { ecTraits = setFromList [Humanoid, Cultist, Elite]
  , ecKeywords = [Keyword.Hunter]
  , ecVictoryPoints = Just 2
  }

huntingShadow :: CardId -> EncounterCard
huntingShadow cardId = (treachery cardId "01135" "Hunting Shadow")
  { ecTraits = setFromList [Curse]
  , ecKeywords = [Keyword.Peril]
  }

falseLead :: CardId -> EncounterCard
falseLead cardId = treachery cardId "01136" "False Lead"

wolfManDrew :: CardId -> EncounterCard
wolfManDrew cardId = (enemy cardId "01137" "\"Wolf-Man\" Drew")
  { ecTraits = setFromList [Humanoid, Cultist]
  , ecVictoryPoints = Just 1
  }

hermanCollins :: CardId -> EncounterCard
hermanCollins cardId = (enemy cardId "01138" "Herman Collins")
  { ecTraits = setFromList [Humanoid, Cultist]
  , ecVictoryPoints = Just 1
  }

peterWarren :: CardId -> EncounterCard
peterWarren cardId = (enemy cardId "01139" "Peter Warren")
  { ecTraits = setFromList [Humanoid, Cultist]
  , ecVictoryPoints = Just 1
  }

victoriaDevereux :: CardId -> EncounterCard
victoriaDevereux cardId = (enemy cardId "01140" "Victoria Devereux")
  { ecTraits = setFromList [Humanoid, Cultist]
  , ecVictoryPoints = Just 1
  }

ruthTurner :: CardId -> EncounterCard
ruthTurner cardId = (enemy cardId "01141" "Ruth Turner")
  { ecTraits = setFromList [Humanoid, Cultist]
  , ecVictoryPoints = Just 1
  }

umordhoth :: CardId -> EncounterCard
umordhoth cardId = (enemy cardId "01157" "Umôrdhoth")
  { ecTraits = setFromList [AncientOne, Elite]
  , ecKeywords = [Keyword.Hunter, Keyword.Massive]
  }

umordhothsWrath :: CardId -> EncounterCard
umordhothsWrath cardId = (treachery cardId "01158" "Umôrdhoth's Wrath")
  { ecTraits = setFromList [Curse]
  }

swarmOfRats :: CardId -> EncounterCard
swarmOfRats cardId = (enemy cardId "01159" "Swarm of Rats")
  { ecTraits = setFromList [Creature]
  , ecKeywords = [Keyword.Hunter]
  }

ghoulMinion :: CardId -> EncounterCard
ghoulMinion cardId = (enemy cardId "01160" "Ghoul Minion")
  { ecTraits = setFromList [Humanoid, Monster, Ghoul]
  }

ravenousGhoul :: CardId -> EncounterCard
ravenousGhoul cardId = (enemy cardId "01161" "Ravenous Ghoul")
  { ecTraits = setFromList [Humanoid, Monster, Ghoul]
  }

graspingHands :: CardId -> EncounterCard
graspingHands cardId = (treachery cardId "01162" "Grasping Hands")
  { ecTraits = setFromList [Hazard]
  }

rottingRemains :: CardId -> EncounterCard
rottingRemains cardId = (treachery cardId "01163" "Rotting Remains")
  { ecTraits = setFromList [Terror]
  }

frozenInFear :: CardId -> EncounterCard
frozenInFear cardId = (treachery cardId "01164" "Frozen in Fear")
  { ecTraits = setFromList [Terror]
  }

dissonantVoices :: CardId -> EncounterCard
dissonantVoices cardId = (treachery cardId "01165" "Dissonant Voices")
  { ecTraits = setFromList [Terror]
  }

ancientEvils :: CardId -> EncounterCard
ancientEvils cardId =
  (treachery cardId "01166" "Ancient Evils") { ecTraits = setFromList [Omen] }

cryptChill :: CardId -> EncounterCard
cryptChill cardId =
  (treachery cardId "01167" "Crypt Chill") { ecTraits = setFromList [Hazard] }

obscuringFog :: CardId -> EncounterCard
obscuringFog cardId =
  (treachery cardId "01168" "Obscuring Fog") { ecTraits = setFromList [Hazard] }

acolyte :: CardId -> EncounterCard
acolyte cardId = (enemy cardId "01169" "Acolyte")
  { ecTraits = setFromList [Humanoid, Cultist]
  }

wizardOfTheOrder :: CardId -> EncounterCard
wizardOfTheOrder cardId = (enemy cardId "01170" "Wizard of the Order")
  { ecTraits = setFromList [Humanoid, Cultist]
  , ecKeywords = [Keyword.Retaliate]
  }

mysteriousChanting :: CardId -> EncounterCard
mysteriousChanting cardId = (treachery cardId "01171" "Mysterious Chanting")
  { ecTraits = setFromList [Hex]
  }

huntingNightgaunt :: CardId -> EncounterCard
huntingNightgaunt cardId = (enemy cardId "01172" "Hunting Nightgaunt")
  { ecTraits = setFromList [Monster, Nightgaunt]
  , ecKeywords = [Keyword.Hunter]
  }

onWingsOfDarkness :: CardId -> EncounterCard
onWingsOfDarkness cardId = treachery cardId "01173" "On Wings of Darkness"

lockedDoor :: CardId -> EncounterCard
lockedDoor cardId =
  (treachery cardId "01174" "Locked Door") { ecTraits = setFromList [Obstacle] }

screechingByakhee :: CardId -> EncounterCard
screechingByakhee cardId = (enemy cardId "01175" "Screeching Byakhee")
  { ecTraits = setFromList [Monster, Byakhee]
  , ecKeywords = [Keyword.Hunter]
  }

theYellowSign :: CardId -> EncounterCard
theYellowSign cardId =
  (treachery cardId "01176" "The Yellow Sign") { ecTraits = setFromList [Omen] }

yithianObserver :: CardId -> EncounterCard
yithianObserver cardId = (enemy cardId "01177" "Yithian Observer")
  { ecTraits = setFromList [Monster, Yithian]
  }

offerOfPower :: CardId -> EncounterCard
offerOfPower cardId = (treachery cardId "01178" "Offer of Power")
  { ecTraits = setFromList [Pact]
  , ecKeywords = [Keyword.Peril]
  }

relentlessDarkYoung :: CardId -> EncounterCard
relentlessDarkYoung cardId = (enemy cardId "01179" "Relentless Dark Young")
  { ecTraits = setFromList [Monster, DarkYoung]
  , ecVictoryPoints = Just 1
  }

goatSpawn :: CardId -> EncounterCard
goatSpawn cardId = (enemy cardId "01180" "Goat Spawn")
  { ecTraits = setFromList [Humanoid, Monster]
  , ecKeywords = [Keyword.Hunter, Keyword.Retaliate]
  }

youngDeepOne :: CardId -> EncounterCard
youngDeepOne cardId = (enemy cardId "01181" "Young Deep One")
  { ecTraits = setFromList [Humanoid, Monster, DeepOne]
  , ecKeywords = [Keyword.Hunter]
  }

dreamsOfRlyeh :: CardId -> EncounterCard
dreamsOfRlyeh cardId = (treachery cardId "01182" "Dreams of R'lyeh")
  { ecTraits = setFromList [Omen]
  }

corpseHungryGhoul :: CardId -> EncounterCard
corpseHungryGhoul cardId = (enemy cardId "50022" "Corpse-Hungry Ghoul")
  { ecTraits = setFromList [Humanoid, Monster, Ghoul]
  , ecKeywords = [Keyword.Hunter]
  , ecVictoryPoints = Just 1
  }

ghoulFromTheDepths :: CardId -> EncounterCard
ghoulFromTheDepths cardId = (enemy cardId "50023" "Ghoul from the Depths")
  { ecTraits = setFromList [Humanoid, Monster, Ghoul]
  , ecKeywords = [Keyword.Retaliate]
  , ecVictoryPoints = Just 1
  }

theZealotsSeal :: CardId -> EncounterCard
theZealotsSeal cardId = (treachery cardId "50024" "The Zealot's Seal")
  { ecTraits = setFromList [Hex]
  }

narogath :: CardId -> EncounterCard
narogath cardId = (enemy cardId "50026b" "Narôgath")
  { ecTraits = setFromList [Humanoid, Monster, Cultist, Elite]
  , ecKeywords = [Keyword.Hunter]
  , ecVictoryPoints = Just 2
  }

maskedHorrors :: CardId -> EncounterCard
maskedHorrors cardId = (treachery cardId "50031" "Masked Horrors")
  { ecTraits = setFromList [Power, Scheme]
  }

graveEater :: CardId -> EncounterCard
graveEater cardId = (enemy cardId "50038" "Grave-Eater")
  { ecTraits = setFromList [Humanoid, Monster, Ghoul]
  }

acolyteOfUmordhoth :: CardId -> EncounterCard
acolyteOfUmordhoth cardId = (enemy cardId "50039" "Acolyte of Umôrdhoth")
  { ecTraits = setFromList [Humanoid, Monster, Ghoul]
  }

chillFromBelow :: CardId -> EncounterCard
chillFromBelow cardId = (treachery cardId "50040" "Chill from Below")
  { ecTraits = setFromList [Hazard]
  }

discipleOfTheDevourer :: CardId -> EncounterCard
discipleOfTheDevourer cardId = (enemy cardId "50041" "Disciple of the Devourer"
                               )
  { ecTraits = setFromList [Humanoid, Cultist]
  }

bogGator :: CardId -> EncounterCard
bogGator cardId =
  (enemy cardId "81022" "Bog Gator") { ecTraits = setFromList [Creature] }

swampLeech :: CardId -> EncounterCard
swampLeech cardId =
  (enemy cardId "81023" "Swamp Leech") { ecTraits = setFromList [Creature] }

cursedSwamp :: CardId -> EncounterCard
cursedSwamp cardId =
  (treachery cardId "81024" "Cursed Swamp") { ecTraits = setFromList [Hazard] }

spectralMist :: CardId -> EncounterCard
spectralMist cardId =
  (treachery cardId "81025" "Spectral Mist") { ecTraits = setFromList [Hazard] }

draggedUnder :: CardId -> EncounterCard
draggedUnder cardId =
  (treachery cardId "81026" "Dragged Under") { ecTraits = setFromList [Hazard] }

ripplesOnTheSurface :: CardId -> EncounterCard
ripplesOnTheSurface cardId = (treachery cardId "81027" "Ripples on the Surface"
                             )
  { ecTraits = setFromList [Terror]
  }

theRougarou :: CardId -> EncounterCard
theRougarou cardId = (enemy cardId "81028" "The Rougarou")
  { ecTraits = setFromList [Monster, Creature, Elite]
  , ecKeywords = [Keyword.Aloof, Keyword.Retaliate]
  }

slimeCoveredDhole :: CardId -> EncounterCard
slimeCoveredDhole cardId = (enemy cardId "81031" "Slime-Covered Dhole")
  { ecTraits = setFromList [Monster, Dhole]
  , ecKeywords = [Keyword.Hunter]
  }

marshGug :: CardId -> EncounterCard
marshGug cardId = (enemy cardId "81032" "Marsh Gug")
  { ecTraits = setFromList [Monster, Gug]
  , ecKeywords = [Keyword.Hunter]
  }

darkYoungHost :: CardId -> EncounterCard
darkYoungHost cardId = (enemy cardId "81033" "Dark Young Host")
  { ecTraits = setFromList [Monster, DarkYoung]
  , ecVictoryPoints = Just 1
  }

onTheProwl :: CardId -> EncounterCard
onTheProwl cardId =
  (treachery cardId "81034" "On the Prowl") { ecKeywords = [Keyword.Surge] }

beastOfTheBayou :: CardId -> EncounterCard
beastOfTheBayou cardId = treachery cardId "81035" "Beast of the Bayou"

insatiableBloodlust :: CardId -> EncounterCard
insatiableBloodlust cardId = treachery cardId "81026" "Insatiable Bloodlust"
