/**
 * # sound_effect datum
 * Use for when you need multiple sound files to play at random in a playsound.
 * See var documentation below.
 * Initialized and added to sfx_datum_by_key in /datum/controller/subsystem/sounds/init_sound_keys()
 */
/datum/sound_effect
	/// sfx key define with which we are associated with, see code\__DEFINES\sound.dm
	var/key
	/// list of paths to our files, use the /assoc subtype if your paths are weighted
	var/list/file_paths

/datum/sound_effect/proc/return_sfx()
	return pick(file_paths)

/**
 * TODO:
 * 1. SORT ALL THE EFFECTS SOUNDS BY INDIVIDUAL FOLDERS INSIDE THE EFFECTS FOLDER
 * 2. TRANSFER EVERYTHING TO SFX
 * 3. PORTING SFX FROM TG
 * – LittleBoobs
 */

/datum/sound_effect/patchpack
	key = SFX_PATCHPACK
	file_paths = list(
		'sound/effects/CC0/patchpack1.ogg',
		'sound/effects/CC0/patchpack2.ogg',
		'sound/effects/CC0/patchpack3.ogg',
		'sound/effects/CC0/patchpack4.ogg',
		'sound/effects/CC0/patchpack5.ogg'
	)

/datum/sound_effect/pillbottle
	key = SFX_PILLBOTTLE
	file_paths = list(
		'sound/effects/CC0/pillbottle1.ogg',
		'sound/effects/CC0/pillbottle2.ogg',
		'sound/effects/CC0/pillbottle3.ogg',
		'sound/effects/CC0/pillbottle4.ogg'
	)

/datum/sound_effect/shatter
	key = SFX_SHATTER
	file_paths = list(
		'sound/effects/glassbr1.ogg',
		'sound/effects/glassbr2.ogg',
		'sound/effects/glassbr3.ogg'
	)

/datum/sound_effect/explosion
	key = SFX_EXPLOSION
	file_paths = list(
		'sound/effects/explosion1.ogg',
		'sound/effects/explosion2.ogg'
	)

/datum/sound_effect/explosion_creaking
	key = SFX_EXPLOSION_CREAKING
	file_paths = list(
		'sound/effects/explosioncreak1.ogg',
		'sound/effects/explosioncreak2.ogg'
	)

/datum/sound_effect/hull_creaking
	key = SFX_HULL_CREAKING
	file_paths = list(
		'sound/effects/creak1.ogg',
		'sound/effects/creak2.ogg',
		'sound/effects/creak3.ogg'
	)

/datum/sound_effect/sparks
	key = SFX_SPARKS
	file_paths = list(
		'sound/effects/sparks1.ogg',
		'sound/effects/sparks2.ogg',
		'sound/effects/sparks3.ogg',
		'sound/effects/sparks4.ogg'
	)

/datum/sound_effect/rustle
	key = SFX_RUSTLE
	file_paths = list(
		'sound/effects/rustle1.ogg',
		'sound/effects/rustle2.ogg',
		'sound/effects/rustle3.ogg',
		'sound/effects/rustle4.ogg',
		'sound/effects/rustle5.ogg'
	)

/datum/sound_effect/bodyfall
	key = SFX_BODYFALL
	file_paths = list(
		'sound/effects/bodyfall1.ogg',
		'sound/effects/bodyfall2.ogg',
		'sound/effects/bodyfall3.ogg',
		'sound/effects/bodyfall4.ogg'
	)

/datum/sound_effect/punch
	key = SFX_PUNCH
	file_paths = list(
		'sound/weapons/punch1.ogg',
		'sound/weapons/punch2.ogg',
		'sound/weapons/punch3.ogg',
		'sound/weapons/punch4.ogg'
	)

/datum/sound_effect/swing_hit
	key = SFX_SWING_HIT
	file_paths = list(
		'sound/weapons/genhit1.ogg',
		'sound/weapons/genhit2.ogg',
		'sound/weapons/genhit3.ogg'
	)

/datum/sound_effect/blade_scifi_swing
	key = SFX_BLADE_SCIFI_SWING
	file_paths = list(
		'sound/weapons/swings/blade_scifi_swing1.ogg',
		'sound/weapons/swings/blade_scifi_swing2.ogg',
		'sound/weapons/swings/blade_scifi_swing3.ogg',
		'sound/weapons/swings/blade_scifi_swing4.ogg'
	)

/datum/sound_effect/blade_swing_heavy
	key = SFX_BLADE_SWING_HEAVY
	file_paths = list(
		'sound/weapons/swings/blade_swing_heavy1.ogg',
		'sound/weapons/swings/blade_swing_heavy2.ogg',
		'sound/weapons/swings/blade_swing_heavy3.ogg',
		'sound/weapons/swings/blade_swing_heavy4.ogg'
	)

/datum/sound_effect/blade_swing_light
	key = SFX_BLADE_SWING_LIGHT
	file_paths = list(
		'sound/weapons/swings/blade_swing_light1.ogg',
		'sound/weapons/swings/blade_swing_light2.ogg',
		'sound/weapons/swings/blade_swing_light3.ogg',
		'sound/weapons/swings/blade_swing_light4.ogg'
	)

/datum/sound_effect/blunt_swing_heavy
	key = SFX_BLUNT_SWING_HEAVY
	file_paths = list(
		'sound/weapons/swings/blunt_swing_heavy1.ogg',
		'sound/weapons/swings/blunt_swing_heavy2.ogg',
		'sound/weapons/swings/blunt_swing_heavy3.ogg',
		'sound/weapons/swings/blunt_swing_heavy4.ogg'
	)

/datum/sound_effect/blunt_swing_light
	key = SFX_BLUNT_SWING_LIGHT
	file_paths = list(
		'sound/weapons/swings/blunt_swing_light1.ogg',
		'sound/weapons/swings/blunt_swing_light2.ogg',
		'sound/weapons/swings/blunt_swing_light3.ogg',
		'sound/weapons/swings/blunt_swing_light4.ogg'
	)

/datum/sound_effect/chainsaw_swing
	key = SFX_CHAINSAW_SWING
	file_paths = list(
		'sound/weapons/swings/chainsaw_swing1.ogg',
		'sound/weapons/swings/chainsaw_swing2.ogg',
		'sound/weapons/swings/chainsaw_swing3.ogg',
		'sound/weapons/swings/chainsaw_swing4.ogg'
	)

/datum/sound_effect/chop_swing_heavy
	key = SFX_CHOP_SWING_HEAVY
	file_paths = list(
		'sound/weapons/swings/chop_swing_heavy1.ogg',
		'sound/weapons/swings/chop_swing_heavy2.ogg',
		'sound/weapons/swings/chop_swing_heavy3.ogg',
		'sound/weapons/swings/chop_swing_heavy4.ogg'
	)

/datum/sound_effect/chop_swing_light
	key = SFX_CHOP_SWING_LIGHT
	file_paths = list(
		'sound/weapons/swings/chop_swing_light1.ogg',
		'sound/weapons/swings/chop_swing_light2.ogg',
		'sound/weapons/swings/chop_swing_light3.ogg',
		'sound/weapons/swings/chop_swing_light4.ogg'
	)

/datum/sound_effect/double_energy_swing
	key = SFX_DOUBLE_ENERGY_SWING
	file_paths = list(
		'sound/weapons/swings/double_energy_swing1.ogg',
		'sound/weapons/swings/double_energy_swing2.ogg',
		'sound/weapons/swings/double_energy_swing3.ogg',
		'sound/weapons/swings/double_energy_swing4.ogg'
	)

/datum/sound_effect/energy_sword_swing
	key = SFX_ENERGY_SWORD_SWING
	file_paths = list(
		'sound/weapons/swings/energy_sword_swing1.ogg',
		'sound/weapons/swings/energy_sword_swing2.ogg',
		'sound/weapons/swings/energy_sword_swing3.ogg',
		'sound/weapons/swings/energy_sword_swing4.ogg'
	)

/datum/sound_effect/generic_swing_heavy
	key = SFX_GENERIC_SWING_HEAVY
	file_paths = list(
		'sound/weapons/swings/generic_swing_heavy1.ogg',
		'sound/weapons/swings/generic_swing_heavy2.ogg',
		'sound/weapons/swings/generic_swing_heavy3.ogg',
		'sound/weapons/swings/generic_swing_heavy4.ogg'
	)

/datum/sound_effect/generic_swing_light
	key = SFX_GENERIC_SWING_LIGHT
	file_paths = list(
		'sound/weapons/swings/generic_swing_light1.ogg',
		'sound/weapons/swings/generic_swing_light2.ogg',
		'sound/weapons/swings/generic_swing_light3.ogg',
		'sound/weapons/swings/generic_swing_light4.ogg'
	)

/datum/sound_effect/katana_swing
	key = SFX_KATANA_SWING
	file_paths = list(
		'sound/weapons/swings/katana_swing1.ogg',
		'sound/weapons/swings/katana_swing2.ogg',
		'sound/weapons/swings/katana_swing3.ogg',
		'sound/weapons/swings/katana_swing4.ogg'
	)

/datum/sound_effect/knife_swing
	key = SFX_KNIFE_SWING
	file_paths = list(
		'sound/weapons/swings/knife_swing1.ogg',
		'sound/weapons/swings/knife_swing2.ogg',
		'sound/weapons/swings/knife_swing3.ogg',
		'sound/weapons/swings/knife_swing4.ogg'
	)

/datum/sound_effect/rapier_swing
	key = SFX_RAPIER_SWING
	file_paths = list(
		'sound/weapons/swings/rapier_swing1.ogg',
		'sound/weapons/swings/rapier_swing2.ogg',
		'sound/weapons/swings/rapier_swing3.ogg',
		'sound/weapons/swings/rapier_swing4.ogg'
	)

/datum/sound_effect/hiss
	key = SFX_HISS
	file_paths = list(
		'sound/voice/hiss1.ogg',
		'sound/voice/hiss2.ogg',
		'sound/voice/hiss3.ogg',
		'sound/voice/hiss4.ogg'
	)

/datum/sound_effect/page_turn
	key = SFX_PAGE_TURN
	file_paths = list(
		'sound/effects/pageturn1.ogg',
		'sound/effects/pageturn2.ogg',
		'sound/effects/pageturn3.ogg'
	)

/datum/sound_effect/ricochet
	key = SFX_RICOCHET
	file_paths = list(
		'sound/weapons/effects/ric1.ogg',
		'sound/weapons/effects/ric2.ogg',
		'sound/weapons/effects/ric3.ogg',
		'sound/weapons/effects/ric4.ogg',
		'sound/weapons/effects/ric5.ogg'
	)

/datum/sound_effect/honkbot_e
	key = SFX_HONKBOT_E
	file_paths = list(
		'sound/items/bikehorn.ogg',
		'sound/items/AirHorn2.ogg',
		'sound/misc/sadtrombone.ogg',
		'sound/items/AirHorn.ogg',
		'sound/items/WEEOO1.ogg',
		'sound/voice/biamthelaw.ogg',
		'sound/voice/bcreep.ogg',
		'sound/magic/Fireball.ogg' ,
		'sound/effects/pray.ogg',
		'sound/voice/hiss1.ogg',
		'sound/machines/buzz-sigh.ogg',
		'sound/machines/ping.ogg',
		'sound/weapons/flashbang.ogg',
		'sound/weapons/bladeslice.ogg'
	)

/datum/sound_effect/clown_step
	key = SFX_CLOWN_STEP
	file_paths = list(
		'sound/effects/clownstep1.ogg',
		'sound/effects/clownstep2.ogg'
	)

/datum/sound_effect/desecration
	key = SFX_DESECRATION
	file_paths = list(
		'sound/misc/desceration-01.ogg',
		'sound/misc/desceration-02.ogg',
		'sound/misc/desceration-03.ogg'
	)

/datum/sound_effect/growl
	key = SFX_GROWL
	file_paths = list(
		'sound/goonstation/voice/growl1.ogg',
		'sound/goonstation/voice/growl2.ogg',
		'sound/goonstation/voice/growl3.ogg'
	)

/datum/sound_effect/terminal_type
	key = SFX_TERMINAL_TYPE
	file_paths = list(
		'sound/machines/terminal_button01.ogg',
		'sound/machines/terminal_button02.ogg',
		'sound/machines/terminal_button03.ogg',
		'sound/machines/terminal_button04.ogg',
		'sound/machines/terminal_button05.ogg',
		'sound/machines/terminal_button06.ogg',
		'sound/machines/terminal_button07.ogg',
		'sound/machines/terminal_button08.ogg'
	)

/datum/sound_effect/u_fscream
	key = SFX_U_FSCREAM
	file_paths = list(
		'sound/voice/unathi/f_u_scream.ogg',
		'sound/voice/unathi/f_u_scream2.ogg'
	)

/datum/sound_effect/bonebreak
	key = SFX_BONEBREAK
	file_paths = list(
		'sound/effects/bone_break_1.ogg',
		'sound/effects/bone_break_2.ogg',
		'sound/effects/bone_break_3.ogg',
		'sound/effects/bone_break_4.ogg',
		'sound/effects/bone_break_5.ogg',
		'sound/effects/bone_break_6.ogg'
	)

/datum/sound_effect/boxing
	key = SFX_BOXING
	file_paths = list(
		'sound/weapons/boxing1.ogg',
		'sound/weapons/boxing2.ogg',
		'sound/weapons/boxing3.ogg',
		'sound/weapons/boxing4.ogg',
		'sound/weapons/boxing5.ogg',
		'sound/weapons/boxing6.ogg'
	)

/datum/sound_effect/bullet
	key = SFX_BULLET
	file_paths = list(
		'sound/weapons/bullet.ogg',
		'sound/weapons/bullet2.ogg',
		'sound/weapons/bullet3.ogg'
	)

/datum/sound_effect/gunshot
	key = SFX_GUNSHOT
	file_paths = list(
		'sound/weapons/gunshots/gunshot.ogg',
		'sound/weapons/gunshots/gunshot2.ogg',
		'sound/weapons/gunshots/gunshot3.ogg',
		'sound/weapons/gunshots/gunshot4.ogg'
	)

/datum/sound_effect/casing_drop
	key = SFX_CASING_DROP
	file_paths = list(
		'sound/weapons/gun_interactions/casingfall1.ogg',
		'sound/weapons/gun_interactions/casingfall2.ogg',
		'sound/weapons/gun_interactions/casingfall3.ogg'
	)

/datum/sound_effect/computer_ambience
	key = SFX_COMPUTER_AMBIENCE
	file_paths = list(
		'sound/goonstation/machines/ambicomp1.ogg',
		'sound/goonstation/machines/ambicomp2.ogg',
		'sound/goonstation/machines/ambicomp3.ogg'
	)

/datum/sound_effect/frog_warcry
	key = SFX_FROG_WARCRY
	file_paths = list(
		'sound/creatures/frog_scream_1.ogg',
		'sound/creatures/frog_scream_2.ogg',
		'sound/creatures/frog_scream_3.ogg'
	)
