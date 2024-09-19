/*
 FUN ZONE OF ADMIN LISTINGS
 Try to keep this in sync with __DEFINES/traits.dm
 quirks have it's own panel so we don't need them here.

 USE ALPABETIC ORDER HERE! (please)
*/
GLOBAL_LIST_INIT(traits_by_type, list(
	/atom = list(
		"TRAIT_BEING_SHOCKED" = TRAIT_BEING_SHOCKED,
		"TRAIT_BLOCK_RADIATION" = TRAIT_BLOCK_RADIATION,
		"TRAIT_CMAGGED" = TRAIT_CMAGGED,
	),
	/atom/movable = list(
		"TRAIT_ASHSTORM_IMMUNE" = TRAIT_ASHSTORM_IMMUNE,
		"TRAIT_BLOBSTORM_IMMUNE" = TRAIT_BLOBSTORM_IMMUNE,
		"TRAIT_CHASM_STOPPER" = TRAIT_CHASM_STOPPER,
		"TRAIT_LAVA_IMMUNE" = TRAIT_LAVA_IMMUNE,
		"TRAIT_MOVE_FLOATING" = TRAIT_MOVE_FLOATING,
		"TRAIT_MOVE_FLYING" = TRAIT_MOVE_FLYING,
		"TRAIT_MOVE_GROUND" = TRAIT_MOVE_GROUND,
		"TRAIT_MOVE_PHASING" = TRAIT_MOVE_PHASING,
		"TRAIT_MOVE_UPSIDE_DOWN" = TRAIT_MOVE_UPSIDE_DOWN,
		"TRAIT_MOVE_VENTCRAWLING" = TRAIT_MOVE_VENTCRAWLING,
		"TRAIT_NO_FLOATING_ANIM" = TRAIT_NO_FLOATING_ANIM,
		"TRAIT_NO_IMMOBILIZE" = TRAIT_NO_IMMOBILIZE,
		"TRAIT_NO_TELEPORT" = TRAIT_NO_TELEPORT,
		"TRAIT_RADSTORM_IMMUNE" = TRAIT_RADSTORM_IMMUNE,
		"TRAIT_SILENT_FOOTSTEPS" = TRAIT_SILENT_FOOTSTEPS,
		"TRAIT_SOLARFLARE_IMMUNE" = TRAIT_SOLARFLARE_IMMUNE,
		"TRAIT_SNOWSTORM_IMMUNE" = TRAIT_SNOWSTORM_IMMUNE,
		"TRAIT_WEATHER_IMMUNE" = TRAIT_WEATHER_IMMUNE,
	),
	/mob = list(
		"TRAIT_AI_UNTRACKABLE" = TRAIT_AI_UNTRACKABLE,
		"TRAIT_BADASS" = TRAIT_BADASS,
		"TRAIT_BLIND" = TRAIT_BLIND,
		"TRAIT_BLOODCRAWL" = TRAIT_BLOODCRAWL,
		"TRAIT_BLOODCRAWL_EAT" = TRAIT_BLOODCRAWL_EAT,
		"TRAIT_CAN_STRIP" = TRAIT_CAN_STRIP,
		"TRAIT_NO_GUNS" = TRAIT_NO_GUNS,
		"TRAIT_COLORBLIND" = TRAIT_COLORBLIND,
		"TRAIT_COMIC" = TRAIT_COMIC,
		"TRAIT_CLUMSY" = TRAIT_CLUMSY,
		"TRAIT_DEAF" = TRAIT_DEAF,
		"TRAIT_DWARF" = TRAIT_DWARF,
		"TRAIT_ELITE_CHALLENGER" = TRAIT_ELITE_CHALLENGER,
		"TRAIT_EMBEDIMMUNE" = TRAIT_EMBEDIMMUNE,
		"TRAIT_EMPATHY" = TRAIT_EMPATHY,
		"TRAIT_EMOTE_MUTE" = TRAIT_EMOTE_MUTE,
		"TRAIT_EXOTIC_BLOOD" = TRAIT_EXOTIC_BLOOD,
		"TRAIT_FAKEDEATH" = TRAIT_FAKEDEATH,
		"TRAIT_FAT" = TRAIT_FAT,
		"TRAIT_FLOORED" = TRAIT_FLOORED,
		"TRAIT_FORCE_DOORS" = TRAIT_FORCE_DOORS,
		"TRAIT_FORCED_GRAVITY" = TRAIT_FORCED_GRAVITY,
		"TRAIT_FORCED_STANDING" = TRAIT_FORCED_STANDING,
		"TRAIT_GENE_STRONG" = TRAIT_GENE_STRONG,
		"TRAIT_GENE_WEAK" = TRAIT_GENE_WEAK,
		"TRAIT_HANDS_BLOCKED" = TRAIT_HANDS_BLOCKED,
		"TRAIT_HAS_LIPS" = TRAIT_HAS_LIPS,
		"TRAIT_HAS_REGENERATION" = TRAIT_HAS_REGENERATION,
		"TRAIT_HEALS_FROM_ASH_TENDRIL" = TRAIT_HEALS_FROM_ASH_TENDRIL,
		"TRAIT_HEALS_FROM_CARP_RIFTS" = TRAIT_HEALS_FROM_CARP_RIFTS,
		"TRAIT_HEALS_FROM_CULT_PYLONS" = TRAIT_HEALS_FROM_CULT_PYLONS,
		"TRAIT_HEALS_FROM_HOLY_PYLONS" = TRAIT_HEALS_FROM_HOLY_PYLONS,
		"TRAIT_HULK" = TRAIT_HULK,
		"TRAIT_HUSK" = TRAIT_HUSK,
		"TRAIT_IGNOREDAMAGESLOWDOWN" = TRAIT_IGNOREDAMAGESLOWDOWN,
		"TRAIT_IGNORESLOWDOWN" = TRAIT_IGNORESLOWDOWN,
		"TRAIT_IGNORING_GRAVITY" = TRAIT_IGNORING_GRAVITY,
		"TRAIT_IMMOBILIZED" = TRAIT_IMMOBILIZED,
		"TRAIT_INCAPACITATED" = TRAIT_INCAPACITATED,
		"TRAIT_IWASBATONED" = TRAIT_IWASBATONED,
		"TRAIT_GUSTPROTECTION" = TRAIT_GUSTPROTECTION,
		"TRAIT_JESTER" = TRAIT_JESTER,
		"TRAIT_KNOCKEDOUT" = TRAIT_KNOCKEDOUT,
		"TRAIT_LASEREYES" = TRAIT_LASEREYES,
		"TRAIT_LEGION_TUMOUR" = TRAIT_LEGION_TUMOUR,
		"TRAIT_MASTER_SURGEON" = TRAIT_MASTER_SURGEON,
		"TRAIT_MUTE" = TRAIT_MUTE,
		"TRAIT_NEARSIGHTED" = TRAIT_NEARSIGHTED,
		"TRAIT_NEGATES_GRAVITY" = TRAIT_NEGATES_GRAVITY,
		"TRAIT_NO_BIOCHIPS" = TRAIT_NO_BIOCHIPS,
		"TRAIT_NO_BLOOD" = TRAIT_NO_BLOOD,
		"TRAIT_NO_BLOOD_RESTORE" = TRAIT_NO_BLOOD_RESTORE,
		"TRAIT_NO_BREATH" = TRAIT_NO_BREATH,
		"TRAIT_NO_CLONE" = TRAIT_NO_CLONE,
		"TRAIT_NO_CYBERIMPLANTS" = TRAIT_NO_CYBERIMPLANTS,
		"TRAIT_NO_DECAY" = TRAIT_NO_DECAY,
		"TRAIT_NO_DNA" = TRAIT_NO_DNA,
		"TRAIT_NO_FAT" = TRAIT_NO_FAT,
		"TRAIT_NO_FINGERPRINTS" = TRAIT_NO_FINGERPRINTS,
		"TRAIT_NO_GERMS" = TRAIT_NO_GERMS,
		"TRAIT_NO_GLIDE" = TRAIT_NO_GLIDE,
		"TRAIT_NO_HUNGER" = TRAIT_NO_HUNGER,
		"TRAIT_NO_INTORGANS" = TRAIT_NO_INTORGANS,
		"TRAIT_NO_PAIN" = TRAIT_NO_PAIN,
		"TRAIT_NO_PAIN_HUD" = TRAIT_NO_PAIN_HUD,
		"TRAIT_NO_ROBOPARTS" = TRAIT_NO_ROBOPARTS,
		"TRAIT_NO_SCAN" = TRAIT_NO_SCAN,
		"TRAIT_NO_SLIP_ALL" = TRAIT_NO_SLIP_ALL,
		"TRAIT_NO_SLIP_ICE" = TRAIT_NO_SLIP_ICE,
		"TRAIT_NO_SLIP_SLIDE" = TRAIT_NO_SLIP_SLIDE,
		"TRAIT_NO_SLIP_WATER" = TRAIT_NO_SLIP_WATER,
		"TRAIT_NO_SPECIES_EXAMINE" = TRAIT_NO_SPECIES_EXAMINE,
		"TRAIT_NO_TRANSFORM" = TRAIT_NO_TRANSFORM,
		"TRAIT_OBESITY" = TRAIT_OBESITY,
		"TRAIT_OPEN_MIND" = TRAIT_OPEN_MIND,
		"TRAIT_PACIFISM" = TRAIT_PACIFISM,
		"TRAIT_PIERCEIMMUNE" = TRAIT_PIERCEIMMUNE,
		"TRAIT_PLANT_ORIGIN" = TRAIT_PLANT_ORIGIN,
		"TRAIT_PULL_BLOCKED" = TRAIT_PULL_BLOCKED,
		"TRAIT_PUSHIMMUNE" = TRAIT_PUSHIMMUNE,
		"TRAIT_PSY_RESIST" = TRAIT_PSY_RESIST,
		"TRAIT_RADIMMUNE" = TRAIT_RADIMMUNE,
		"TRAIT_RESIST_COLD" = TRAIT_RESIST_COLD,
		"TRAIT_RESIST_HEAT" = TRAIT_RESIST_HEAT,
		"TRAIT_RESTRAINED" = TRAIT_RESTRAINED,
		"TRAIT_SECDEATH" = TRAIT_SECDEATH,
		"TRAIT_SHOCKIMMUNE" = TRAIT_SHOCKIMMUNE,
		"TRAIT_SOBER" = TRAIT_SOBER,
		"TRAIT_SKELETON" = TRAIT_SKELETON,
		"TRAIT_SPECIES_LIMBS" = TRAIT_SPECIES_LIMBS,
		"TRAIT_STRONG_GRABBER" = TRAIT_STRONG_GRABBER,
		"TRAIT_TELEKINESIS" = TRAIT_TELEKINESIS,
		"TRAIT_TESLA_SHOCKIMMUNE" = TRAIT_TESLA_SHOCKIMMUNE,
		"TRAIT_UI_BLOCKED" = TRAIT_UI_BLOCKED,
		"TRAIT_UNDENSE" = TRAIT_UNDENSE,
		"TRAIT_VENTCRAWLER_ALIEN" = TRAIT_VENTCRAWLER_ALIEN,
		"TRAIT_VENTCRAWLER_ALWAYS" = TRAIT_VENTCRAWLER_ALWAYS,
		"TRAIT_VENTCRAWLER_ITEM_BASED" = TRAIT_VENTCRAWLER_ITEM_BASED,
		"TRAIT_VENTCRAWLER_NUDE" = TRAIT_VENTCRAWLER_NUDE,
		"TRAIT_VIRUSIMMUNE" = TRAIT_VIRUSIMMUNE,
		"TRAIT_WATERBREATH"	= TRAIT_WATERBREATH,
		"TRAIT_WINGDINGS" = TRAIT_WINGDINGS,
		"TRAIT_XENO_HOST" = TRAIT_XENO_HOST,
		"TRAIT_XRAY" = TRAIT_XRAY,
	),
	/obj/item = list(
		"TRAIT_NEEDS_TWO_HANDS" = TRAIT_NEEDS_TWO_HANDS,
		"TRAIT_NODROP" = TRAIT_NODROP,
		"TRAIT_TRANSFORM_ACTIVE" = TRAIT_TRANSFORM_ACTIVE,
		"TRAIT_WIELDED" = TRAIT_WIELDED,
	),
	/turf = list(
		"TRAIT_CHASM_STOPPED" = TRAIT_CHASM_STOPPED,
		"TRAIT_LAVA_STOPPED" = TRAIT_LAVA_STOPPED,
		"TRAIT_TURF_COVERED" = TRAIT_TURF_COVERED,
		"TRAIT_TURF_IGNORE_SLIPPERY" = TRAIT_TURF_IGNORE_SLIPPERY,
		"TRAIT_TURF_IGNORE_SLOWDOWN" = TRAIT_TURF_IGNORE_SLOWDOWN,
	),
))


/// value -> trait name, list of ALL traits that exist in the game, used for any type of accessing.
GLOBAL_LIST(global_trait_name_map)

/proc/generate_global_trait_name_map()
	. = list()
	for(var/key in GLOB.traits_by_type)
		for(var/tname in GLOB.traits_by_type[key])
			var/val = GLOB.traits_by_type[key][tname]
			.[val] = tname

	return .


GLOBAL_LIST_INIT(movement_type_trait_to_flag, list(
	TRAIT_MOVE_GROUND = GROUND,
	TRAIT_MOVE_FLYING = FLYING,
	TRAIT_MOVE_VENTCRAWLING = VENTCRAWLING,
	TRAIT_MOVE_FLOATING = FLOATING,
	TRAIT_MOVE_PHASING = PHASING,
	TRAIT_MOVE_UPSIDE_DOWN = UPSIDE_DOWN,
))


GLOBAL_LIST_INIT(movement_type_addtrait_signals, set_movement_type_addtrait_signals())
GLOBAL_LIST_INIT(movement_type_removetrait_signals, set_movement_type_removetrait_signals())


/proc/set_movement_type_addtrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_ADDTRAIT(trait)
	return .


/proc/set_movement_type_removetrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_REMOVETRAIT(trait)
	return .

