#define TTS_CATEGORY_OTHER "Другое"
#define TTS_CATEGORY_WARCRAFT3 "WarCraft 3"
#define TTS_CATEGORY_HALFLIFE2 "Half-Life 2"
#define TTS_CATEGORY_STARCRAFT "StarCraft"
#define TTS_CATEGORY_PORTAL2 "Portal 2"
#define TTS_CATEGORY_STALKER "STALKER"
#define TTS_CATEGORY_DOTA2 "Dota 2"
#define TTS_CATEGORY_LOL "League of Legends"
#define TTS_CATEGORY_FALLOUT "Fallout"
#define TTS_CATEGORY_FALLOUT2 "Fallout 2"
#define TTS_CATEGORY_POSTAL2 "Postal 2"
#define TTS_CATEGORY_TEAMFORTRESS2 "Team Fortress 2"
#define TTS_CATEGORY_ATOMIC_HEART "Atomic Heart"
#define TTS_CATEGORY_OVERWATCH "Overwatch"
#define TTS_CATEGORY_SKYRIM "Skyrim"
#define TTS_CATEGORY_RITA "Rita"
#define TTS_CATEGORY_METRO "Metro"
#define TTS_CATEGORY_HEROESOFTHESTORM "Heroes of the Storm"
#define TTS_CATEGORY_HEARTHSTONE "Hearthstone"
#define TTS_CATEGORY_VALORANT "Valorant"
#define TTS_CATEGORY_EVILISLANDS "Evil Islands"
#define TTS_CATEGORY_WITCHER "Witcher"
#define TTS_CATEGORY_LEFT4DEAD "Left 4 Dead"
#define TTS_CATEGORY_SPONGEBOB "SpongeBob"
#define TTS_CATEGORY_TINYBUNNY "Tiny Bunny"
#define TTS_CATEGORY_TMNT "Teenage Mutant Ninja Turtles"
#define TTS_CATEGORY_STARWARS "Star Wars"
#define TTS_CATEGORY_TRANSFORMERS "Transformers"
#define TTS_CATEGORY_LOTR "Lord of the Rings"
#define TTS_CATEGORY_SHREK "Shrek"
#define TTS_CATEGORY_POTC "Pirates of the Caribbean"
#define TTS_CATEGORY_HARRY_POTTER "Harry Potter"
#define TTS_CATEGORY_X3 "X3"
#define TTS_CATEGORY_OVERLORD "Overlord"
#define TTS_CATEGORY_MARVEL "Marvel"
#define TTS_CATEGORY_TREASURE_ISLAND "Treasure Island"

#define TTS_GENDER_ANY "Любой"
#define TTS_GENDER_MALE "Мужской"
#define TTS_GENDER_FEMALE "Женский"

/datum/tts_seed
	var/name = "STUB"
	var/value = "STUB"
	var/category = TTS_CATEGORY_OTHER
	var/gender = TTS_GENDER_ANY
	var/datum/tts_provider/provider = /datum/tts_provider
	var/donator_level = 0

/datum/tts_seed/vv_edit_var(var_name, var_value)
	return FALSE
