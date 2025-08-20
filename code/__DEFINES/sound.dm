//max channel is 1024. Only go lower from here, because byond tends to pick the first availiable channel to play sounds on
#define CHANNEL_LOBBYMUSIC 1024
#define CHANNEL_ADMIN 1023
#define CHANNEL_VOX 1022
#define CHANNEL_JUKEBOX 1021
#define CHANNEL_HEARTBEAT 1020 //sound channel for heartbeats
#define CHANNEL_BUZZ 1019
#define CHANNEL_AMBIENCE 1018
#define CHANNEL_UNUSED 1017	// МОЛЮ, Если кто-то будет добавлять новый канал. ВОСПОЛЬЗУЙСЯ ЭТИМ! ОН ПУСТОЙ! -BeebBeebBoob
#define CHANNEL_GENERAL 1016 //Sound channel for playsound(), most of the sounds
#define CHANNEL_JUSTICAR_ARK 1015
#define CHANNEL_TTS_LOCAL 1014
#define CHANNEL_TTS_RADIO 1013
#define CHANNEL_RADIO_NOISE 1012 // radio headset noise
#define CHANNEL_BOSS_MUSIC 1011
#define CHANNEL_INTERACTION_SOUNDS 1010	// item pickup/equip/drop sounds
// THIS SHOULD ALWAYS BE THE LOWEST ONE!
// KEEP IT UPDATED
#define CHANNEL_HIGHEST_AVAILABLE 1009

#define MAX_INSTRUMENT_CHANNELS (128 * 6)

///Default range of a sound.
#define SOUND_RANGE 17
#define MEDIUM_RANGE_SOUND_EXTRARANGE -5
///default extra range for sounds considered to be quieter
#define SHORT_RANGE_SOUND_EXTRARANGE -9
///The range deducted from sound range for things that are considered silent / sneaky
#define SILENCED_SOUND_EXTRARANGE -11
///Percentage of sound's range where no falloff is applied
#define SOUND_DEFAULT_FALLOFF_DISTANCE 1 //For a normal sound this would be 1 tile of no falloff
///The default exponent of sound falloff
#define SOUND_FALLOFF_EXPONENT 6

#define SOUND_MINIMUM_PRESSURE 10

#define INTERACTION_SOUND_RANGE_MODIFIER -3
#define LIQUID_SLOSHING_SOUND_VOLUME 10
#define PICKUP_SOUND_VOLUME 15
#define DROP_SOUND_VOLUME 20
#define EQUIP_SOUND_VOLUME 30
#define HALFWAY_SOUND_VOLUME 50
#define BLOCK_SOUND_VOLUME 70
#define YEET_SOUND_VOLUME 90

#define USER_VOLUME(M, C) M?.client?.prefs?.get_channel_volume(C)

//Ambience types
#define GENERIC_SOUNDS list('sound/ambience/ambigen1.ogg', 'sound/ambience/ambigen3.ogg',\
								'sound/ambience/ambigen4.ogg', 'sound/ambience/ambigen5.ogg',\
								'sound/ambience/ambigen6.ogg', 'sound/ambience/ambigen7.ogg',\
								'sound/ambience/ambigen8.ogg', 'sound/ambience/ambigen9.ogg',\
								'sound/ambience/ambigen10.ogg', 'sound/ambience/ambigen11.ogg',\
								'sound/ambience/ambigen12.ogg', 'sound/ambience/ambigen14.ogg', 'sound/ambience/ambigen15.ogg')

#define HOLY_SOUNDS list('sound/ambience/ambicha1.ogg', 'sound/ambience/ambicha2.ogg', 'sound/ambience/ambicha3.ogg',\
										'sound/ambience/ambicha4.ogg', 'sound/ambience/ambiholy.ogg', 'sound/ambience/ambiholy2.ogg',\
										'sound/ambience/ambiholy3.ogg')

#define HIGHSEC_SOUNDS list('sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg')

#define RUINS_SOUNDS list('sound/ambience/ambimine.ogg', 'sound/ambience/ambicave.ogg', 'sound/ambience/ambiruin.ogg',\
									'sound/ambience/ambiruin2.ogg',  'sound/ambience/ambiruin3.ogg',  'sound/ambience/ambiruin4.ogg',\
									'sound/ambience/ambiruin5.ogg',  'sound/ambience/ambiruin6.ogg',  'sound/ambience/ambiruin7.ogg',\
									'sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg', 'sound/ambience/ambitech3.ogg',\
									'sound/ambience/ambimystery.ogg', 'sound/ambience/ambimaint1.ogg')

#define ENGINEERING_SOUNDS list('sound/ambience/ambisin1.ogg', 'sound/ambience/ambisin2.ogg', 'sound/ambience/ambisin3.ogg', 'sound/ambience/ambisin4.ogg',\
										'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg')

#define MINING_SOUNDS list('sound/ambience/ambimine.ogg', 'sound/ambience/ambicave.ogg', 'sound/ambience/ambiruin.ogg',\
											'sound/ambience/ambiruin2.ogg',  'sound/ambience/ambiruin3.ogg',  'sound/ambience/ambiruin4.ogg',\
											'sound/ambience/ambiruin5.ogg',  'sound/ambience/ambiruin6.ogg',  'sound/ambience/ambiruin7.ogg',\
											'sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg', 'sound/ambience/ambimaint1.ogg',\
											'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava2.ogg', 'sound/ambience/ambilava3.ogg')

#define MEDICAL_SOUNDS list('sound/ambience/ambinice.ogg')

#define SPOOKY_SOUNDS list('sound/ambience/ambimo1.ogg','sound/ambience/ambimo2.ogg','sound/ambience/ambiruin7.ogg','sound/ambience/ambiruin6.ogg',\
										'sound/ambience/ambiodd.ogg', 'sound/ambience/ambimystery.ogg')

#define SPACE_SOUNDS list('sound/ambience/ambispace.ogg', 'sound/ambience/ambispace2.ogg', 'sound/music/title2.ogg', 'sound/ambience/ambiatmos.ogg')

#define MAINTENANCE_SOUNDS list('sound/ambience/ambimaint1.ogg', 'sound/ambience/ambimaint2.ogg', 'sound/ambience/ambimaint3.ogg', 'sound/ambience/ambimaint4.ogg',\
											'sound/ambience/ambimaint5.ogg', 'sound/voice/lowHiss2.ogg', 'sound/voice/lowHiss3.ogg', 'sound/voice/lowHiss4.ogg', 'sound/ambience/ambitech2.ogg' )

#define AWAY_MISSION_SOUNDS list('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiruin.ogg',\
									'sound/ambience/ambiruin2.ogg',  'sound/ambience/ambiruin3.ogg',  'sound/ambience/ambiruin4.ogg',\
									'sound/ambience/ambiruin5.ogg',  'sound/ambience/ambiruin6.ogg',  'sound/ambience/ambiruin7.ogg',\
									'sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg', 'sound/ambience/ambimaint.ogg',\
									'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg', 'sound/ambience/ambiodd.ogg')



#define CREEPY_SOUNDS list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/heart_beat.ogg', 'sound/effects/screech.ogg',\
	'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
	'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
	'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
	'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')

//default byond sound environments
#define SOUND_ENVIRONMENT_NONE -1
#define SOUND_ENVIRONMENT_GENERIC 0
#define SOUND_ENVIRONMENT_PADDED_CELL 1
#define SOUND_ENVIRONMENT_ROOM 2
#define SOUND_ENVIRONMENT_BATHROOM 3
#define SOUND_ENVIRONMENT_LIVINGROOM 4
#define SOUND_ENVIRONMENT_STONEROOM 5
#define SOUND_ENVIRONMENT_AUDITORIUM 6
#define SOUND_ENVIRONMENT_CONCERT_HALL 7
#define SOUND_ENVIRONMENT_CAVE 8
#define SOUND_ENVIRONMENT_ARENA 9
#define SOUND_ENVIRONMENT_HANGAR 10
#define SOUND_ENVIRONMENT_CARPETED_HALLWAY 11
#define SOUND_ENVIRONMENT_HALLWAY 12
#define SOUND_ENVIRONMENT_STONE_CORRIDOR 13
#define SOUND_ENVIRONMENT_ALLEY 14
#define SOUND_ENVIRONMENT_FOREST 15
#define SOUND_ENVIRONMENT_CITY 16
#define SOUND_ENVIRONMENT_MOUNTAINS 17
#define SOUND_ENVIRONMENT_QUARRY 18
#define SOUND_ENVIRONMENT_PLAIN 19
#define SOUND_ENVIRONMENT_PARKING_LOT 20
#define SOUND_ENVIRONMENT_SEWER_PIPE 21
#define SOUND_ENVIRONMENT_UNDERWATER 22
#define SOUND_ENVIRONMENT_DRUGGED 23
#define SOUND_ENVIRONMENT_DIZZY 24
#define SOUND_ENVIRONMENT_PSYCHOTIC 25

//If we ever make custom ones add them here
#define SOUND_ENVIROMENT_PHASED list(1.8, 0.5, -1000, -4000, 0, 5, 0.1, 1, -15500, 0.007, 2000, 0.05, 0.25, 1, 1.18, 0.348, -5, 2000, 250, 0, 3, 100, 63)

// "sound areas": easy way of keeping different types of areas consistent.
#define SOUND_AREA_STANDARD_STATION SOUND_ENVIRONMENT_PARKING_LOT
#define SOUND_AREA_LARGE_ENCLOSED SOUND_ENVIRONMENT_QUARRY
#define SOUND_AREA_SMALL_ENCLOSED SOUND_ENVIRONMENT_BATHROOM
#define SOUND_AREA_TUNNEL_ENCLOSED SOUND_ENVIRONMENT_STONEROOM
#define SOUND_AREA_LARGE_SOFTFLOOR SOUND_ENVIRONMENT_CARPETED_HALLWAY
#define SOUND_AREA_MEDIUM_SOFTFLOOR SOUND_ENVIRONMENT_LIVINGROOM
#define SOUND_AREA_SMALL_SOFTFLOOR SOUND_ENVIRONMENT_ROOM
#define SOUND_AREA_ASTEROID SOUND_ENVIRONMENT_CAVE
#define SOUND_AREA_SPACE SOUND_ENVIRONMENT_UNDERWATER
#define SOUND_AREA_LAVALAND SOUND_ENVIRONMENT_MOUNTAINS
#define SOUND_AREA_ICEMOON SOUND_ENVIRONMENT_CAVE
#define SOUND_AREA_WOODFLOOR SOUND_ENVIRONMENT_CITY

// TTS sound defines
#define SOUND_EFFECT_NONE 0
#define SOUND_EFFECT_RADIO 1
#define SOUND_EFFECT_ROBOT 2
#define SOUND_EFFECT_RADIO_ROBOT 3
#define SOUND_EFFECT_MEGAPHONE 4
#define SOUND_EFFECT_MEGAPHONE_ROBOT 5

/// This is the lowest volume that can be used by playsound otherwise it gets ignored
/// Most sounds around 10 volume can barely be heard. Almost all sounds at 5 volume or below are inaudible
/// This is to prevent sound being spammed at really low volumes due to distance calculations
/// Recommend setting this to anywhere from 10-3 (or 0 to disable any sound minimum volume restrictions)
/// Ex. For a 70 volume sound, 17 tile range, 3 exponent, 2 falloff_distance:
/// Setting SOUND_AUDIBLE_VOLUME_MIN to 0 for the above will result in 17x17 radius (289 turfs)
/// Setting SOUND_AUDIBLE_VOLUME_MIN to 5 for the above will result in 14x14 radius (196 turfs)
/// Setting SOUND_AUDIBLE_VOLUME_MIN to 10 for the above will result in 11x11 radius (121 turfs)
#define SOUND_AUDIBLE_VOLUME_MIN 3

/* Calculates the max distance of a sound based on audible volume
 *
 * Note - you should NEVER pass in a volume that is lower than SOUND_AUDIBLE_VOLUME_MIN otherwise distance will be insanely large (like +250,000)
 *
 * Arguments:
 * * volume: The initial volume of the sound being played
 * * max_distance: The range of the sound in tiles (technically not real max distance since the furthest areas gets pruned due to SOUND_AUDIBLE_VOLUME_MIN)
 * * falloff_distance: Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.
 * * falloff_exponent: Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
 * Returns: The max distance of a sound based on audible volume range
 */
#define CALCULATE_MAX_SOUND_AUDIBLE_DISTANCE(volume, max_distance, falloff_distance, falloff_exponent)\
	floor(((((-(max(max_distance - falloff_distance, 0) ** (1 / falloff_exponent)) / volume) * (SOUND_AUDIBLE_VOLUME_MIN - volume)) ** falloff_exponent) + falloff_distance))

/* Calculates the volume of a sound based on distance
 * Arguments:
 * * volume: The initial volume of the sound being played
 * * distance: How far away the sound is in tiles from the source
 * * falloff_distance: Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.
 * * falloff_exponent: Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
 * Returns: The max distance of a sound based on audible volume range
 */
#define CALCULATE_SOUND_VOLUME(volume, distance, max_distance, falloff_distance, falloff_exponent)\
	((max(distance - falloff_distance, 0) ** (1 / falloff_exponent)) / ((max(max_distance, distance) - falloff_distance) ** (1 / falloff_exponent)) * volume)

/**
 * Assoc list of datum by key.
 * Initialized in SSsounds init.
 * k = SFX_KEY (see below)
 * v = singleton sound_effect datum ref
 */
GLOBAL_LIST_EMPTY(sfx_datum_by_key)

/**
 * List of all of our sound keys.
 * Used with /datum/sound_effect as the key.
 * See code\game\sound_keys\sound_keys.dm
 */
#define SFX_PATCHPACK "patchpack"
#define SFX_PILLBOTTLE "pillbottle"
#define SFX_BULLET "bullet"
#define SFX_CASING_DROP "casing_drop"
#define SFX_GUNSHOT "gunshot"
#define SFX_COMPUTER_AMBIENCE "computer_ambience"
#define SFX_BONEBREAK "bonebreak"
#define SFX_BOXING "boxing"
#define SFX_U_FSCREAM "u_fscream"
#define SFX_U_MSCREAM "u_mscream"
#define SFX_BLADE_SCIFI_SWING "blade_scifi_swing"
#define SFX_BLADE_SWING_HEAVY "blade_swing_heavy"
#define SFX_BLADE_SWING_LIGHT "blade_swing_light"
#define SFX_BLUNT_SWING_HEAVY "blunt_swing_heavy"
#define SFX_BLUNT_SWING_LIGHT "blunt_swing_light"
#define SFX_CHAINSAW_SWING "chainsaw_swing"
#define SFX_CHOP_SWING_HEAVY "chop_swing_heavy"
#define SFX_CHOP_SWING_LIGHT "chop_swing_light"
#define SFX_DOUBLE_ENERGY_SWING "double_energy_swing"
#define SFX_ENERGY_SWORD_SWING "energy_sword_swing"
#define SFX_GENERIC_SWING_HEAVY "generic_swing_heavy"
#define SFX_GENERIC_SWING_LIGHT "generic_swing_light"
#define SFX_KATANA_SWING "katana_swing"
#define SFX_KNIFE_SWING "knife_swing"
#define SFX_RAPIER_SWING "rapier_swing"
// Below is a list copied from TG, most of their defines are empty (without datum and sounds). But there are also those used by us.
#define SFX_BODYFALL "bodyfall"
#define SFX_BULLET_MISS "bullet_miss"
#define SFX_CAN_OPEN "can_open"
#define SFX_CLOWN_STEP "clown_step"
#define SFX_DESECRATION "desecration"
#define SFX_EXPLOSION "explosion"
#define SFX_EXPLOSION_CREAKING "explosion_creaking"
#define SFX_HISS "hiss"
#define SFX_HONKBOT_E "honkbot_e"
#define SFX_GOOSE "goose"
#define SFX_HULL_CREAKING "hull_creaking"
#define SFX_HYPERTORUS_CALM "hypertorus_calm"
#define SFX_HYPERTORUS_MELTING "hypertorus_melting"
#define SFX_IM_HERE "im_here"
#define SFX_LAW "law"
#define SFX_PAGE_TURN "page_turn"
#define SFX_PUNCH "punch"
#define SFX_REVOLVER_SPIN "revolver_spin"
#define SFX_RICOCHET "ricochet"
#define SFX_RUSTLE "rustle"
#define SFX_SHATTER "shatter"
#define SFX_SM_CALM "sm_calm"
#define SFX_SM_DELAM "sm_delam"
#define SFX_SPARKS "sparks"
#define SFX_SUIT_STEP "suit_step"
#define SFX_SWING_HIT "swing_hit"
#define SFX_TERMINAL_TYPE "terminal_type"
#define SFX_WARPSPEED "warpspeed"
#define SFX_CRUNCHY_BUSH_WHACK "crunchy_bush_whack"
#define SFX_TREE_CHOP "tree_chop"
#define SFX_ROCK_TAP "rock_tap"
#define SFX_SEAR "sear"
#define SFX_REEL "reel"
#define SFX_RATTLE "rattle"
#define SFX_PORTAL_ENTER "portal_enter"
#define SFX_PORTAL_CLOSE "portal_closed"
#define SFX_PORTAL_CREATED "portal_created"
#define SFX_SCREECH "screech"
#define SFX_TOOL_SWITCH "tool_switch"
#define SFX_KEYBOARD_CLICKS "keyboard_clicks"
#define SFX_STONE_DROP "stone_drop"
#define SFX_STONE_PICKUP "stone_pickup"
#define SFX_MUFFLED_SPEECH "muffspeech"
#define SFX_DEFAULT_FISH_SLAP "default_fish_slap"
#define SFX_ALT_FISH_SLAP "alt_fish_slap"
#define SFX_FISH_PICKUP "fish_pickup"
#define SFX_CAT_MEOW "cat_meow"
#define SFX_CAT_PURR "cat_purr"
#define SFX_LIQUID_POUR "liquid_pour"
#define SFX_SNORE_FEMALE "snore_female"
#define SFX_SNORE_MALE "snore_male"
#define SFX_PLASTIC_BOTTLE_LIQUID_SLOSH "plastic_bottle_liquid_slosh"
#define SFX_DEFAULT_LIQUID_SLOSH "default_liquid_slosh"
#define SFX_PLATE_ARMOR_RUSTLE "plate_armor_rustle"
#define SFX_PIG_OINK "pig_oink"
#define SFX_VISOR_UP "visor_up"
#define SFX_VISOR_DOWN "visor_down"
#define SFX_SIZZLE "sizzle"
#define SFX_GROWL "growl"
#define SFX_POLAROID "polaroid"
#define SFX_HALLUCINATION_TURN_AROUND "hallucination_turn_around"
#define SFX_HALLUCINATION_I_SEE_YOU "hallucination_i_see_you"
#define SFX_HALLUCINATION_OVER_HERE "hallucination_over_here"
#define SFX_HALLUCINATION_I_M_HERE "hallucination_i_m_here"
#define SFX_VOID_DEFLECT "void_deflect"
#define SFX_LOW_HISS "low_hiss"
#define SFX_INDUSTRIAL_SCAN "industrial_scan"
#define SFX_MALE_SIGH "male_sigh"
#define SFX_FEMALE_SIGH "female_sigh"
#define SFX_WRITING_PEN "writing_pen"
#define SFX_CLOWN_CAR_LOAD "clown_car_load"
#define SFX_SEATBELT_BUCKLE "buckle"
#define SFX_SEATBELT_UNBUCKLE "unbuckle"
#define SFX_HEADSET_EQUIP "headset_equip"
#define SFX_HEADSET_PICKUP "headset_pickup"
#define SFX_BANDAGE_BEGIN "bandage_begin"
#define SFX_BANDAGE_END "bandage_end"
#define SFX_CLOTH_DROP "cloth_drop"
#define SFX_CLOTH_PICKUP "cloth_pickup"
#define SFX_SUTURE_BEGIN "suture_begin"
#define SFX_SUTURE_CONTINUOUS "suture_continuous"
#define SFX_SUTURE_END "suture_end"
#define SFX_SUTURE_PICKUP "suture_pickup"
#define SFX_SUTURE_DROP "suture_drop"
#define SFX_REGEN_MESH_BEGIN "regen_mesh_begin"
#define SFX_REGEN_MESH_CONTINUOUS "regen_mesh_continuous"
#define SFX_REGEN_MESH_END "regen_mesh_end"
#define SFX_REGEN_MESH_PICKUP "regen_mesh_pickup"
#define SFX_REGEN_MESH_DROP "regen_mesh_drop"
#define SFX_CIG_PACK_DROP "cig_pack_drop"
#define SFX_CIG_PACK_INSERT "cig_pack_insert"
#define SFX_CIG_PACK_PICKUP "cig_pack_pickup"
#define SFX_CIG_PACK_RUSTLE "cig_pack_rustle"
#define SFX_CIG_PACK_THROW_DROP "cig_pack_throw_drop"
#define	SFX_RORO_WARBLE "roro_warble"
