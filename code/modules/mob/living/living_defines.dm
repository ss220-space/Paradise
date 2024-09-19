/mob/living
	see_invisible = SEE_INVISIBLE_LIVING
	pressure_resistance = 10

	// Will be determined based on mob size if left null. Done in living/proc/determine_move_and_pull_forces()
	move_resist = null
	move_force = null
	pull_force = null

	//Health and life related vars
	var/maxHealth = 100 //Maximum health that should be possible.
	var/health = 100 	//A mob's health

	var/datum/middleClickOverride/middleClickOverride

	//Damage related vars, NOTE: THESE SHOULD ONLY BE MODIFIED BY PROCS
	var/bruteloss = 0	//Brutal damage caused by brute force (punching, being clubbed by a toolbox ect... this also accounts for pressure damage)
	var/oxyloss = 0	//Oxygen depravation damage (no air in lungs)
	var/toxloss = 0	//Toxic damage caused by being poisoned or radiated
	var/fireloss = 0	//Burn damage caused by being way too hot, too cold or burnt.
	var/cloneloss = 0	//Damage caused by being cloned or ejected from the cloner early. slimes also deal cloneloss damage to victims
	var/staminaloss = 0 //Stamina damage, or exhaustion. You recover it slowly naturally, and are stunned if it gets too high. Holodeck and hallucinations deal this.


	var/last_special = 0 //Used by the resist verb, likely used to prevent players from bypassing next_move by logging in/out.

	//Allows mobs to move through dense areas without restriction. For instance, in space or out of holder objects.
	var/incorporeal_move = INCORPOREAL_NONE

	/// Currently pushed movable
	var/atom/movable/now_pushing
	COOLDOWN_DECLARE(pushing_delay)

	COOLDOWN_DECLARE(grab_resist_delay)

	var/atom/movable/cameraFollow = null

	var/on_fire = 0 //The "Are we on fire?" var
	var/fire_stacks = 0 //Tracks how many stacks of fire we have on, max is usually 20

	var/mob_size = MOB_SIZE_HUMAN
	var/metabolism_efficiency = 1 //more or less efficiency to metabolize helpful/harmful reagents and regulate body temperature..
	var/digestion_ratio = 1 //controls how quickly reagents metabolize; largely governered by species attributes.

	var/holder = null //The holder for blood crawling

	/// Allows living mobs to have innate ventcrawl trait defined here.
	/// Values are: TRAIT_VENTCRAWLER_ALWAYS / TRAIT_VENTCRAWLER_NUDE / TRAIT_VENTCRAWLER_ALIEN
	var/ventcrawler_trait
	var/list/icon/pipes_shown
	var/last_played_vent
	/// The last direction we moved in a vent. Used to make holding two directions feel nice
	var/last_vent_dir = NONE

	var/smoke_delay = 0 //used to prevent spam with smoke reagent reaction on mob.

	var/step_count = 0

	var/list/butcher_results = null

	/// List of weather immunity traits that are then added on Initialize(), see traits.dm.
	var/list/weather_immunities

	var/list/surgeries = list()	//a list of surgery datums. generally empty, they're added when the player wants them.

	var/gene_stability = DEFAULT_GENE_STABILITY
	var/ignore_gene_stability = 0

	/// A log of what we've said, plain text, no spans or junk, essentially just each individual "message"
	var/list/say_log

	var/last_hallucinator_log // Used to log, what was last infliction to hallucination

	var/blood_volume = 0 //how much blood the mob has
	hud_possible = list(HEALTH_HUD,STATUS_HUD,SPECIALROLE_HUD,THOUGHT_HUD)

	var/list/status_effects //a list of all status effects the mob has

	var/deathgasp_on_death = FALSE

	var/stam_regen_start_time = 0 //used to halt stamina regen temporarily
	var/stam_regen_start_modifier = 1 //Modifier of time until regeneration starts

	///if this exists AND the normal sprite is bigger than 32x32, this is the replacement icon state (because health doll size limitations). the icon will always be screen_gen.dmi
	var/health_doll_icon
	///If mob can attack by choosing direction
	var/dirslash_enabled = FALSE

	///what multiplicative slowdown we get from turfs currently.
	var/current_turf_slowdown = 0
	/// This can either be a numerical direction or a soft object reference (UID). It makes the mob always face towards the selected thing.
	var/forced_look = null

	/// What our current gravity state is. Used to avoid duplicate animates and such
	var/gravity_state = null

	/// Flags that determine the potential of a mob to perform certain actions. Do not change this directly.
	var/mobility_flags = MOBILITY_FLAGS_DEFAULT

	/// Whether living is resting currently.
	var/resting = FALSE

	/// Variable to track the body position of a mob, regardgless of the actual angle of rotation (usually matching it, but not necessarily).
	var/body_position = STANDING_UP
	/// Number of degrees of rotation of a mob. 0 means no rotation, up-side facing NORTH. 90 means up-side rotated to face EAST, and so on.
	var/lying_angle = 0
	/// Value of lying lying_angle before last change. TODO: Remove the need for this.
	var/lying_prev = 0
	/// Does the mob rotate when lying
	var/rotate_on_lying = FALSE

	/// Is this mob allowed to be buckled/unbuckled to/from things?
	var/can_buckle_to = TRUE

	/// The x amount a mob's sprite should be offset due to the current position they're in
	var/body_position_pixel_x_offset = 0
	/// The y amount a mob's sprite should be offset due to the current position they're in or size (e.g. lying down moves your sprite down)
	var/body_position_pixel_y_offset = 0
	/// The height offset of a mob's maptext due to their current size.
	var/body_maptext_height_offset = 0

	/// Tracks the current size of the mob in relation to its original size. Use update_transform(resize) to change it.
	var/current_size = RESIZE_DEFAULT_SIZE

	/// Whether the mob is slowed down when pulling/pushing other mobs and objects
	var/slowed_by_pull_and_push = TRUE

	/// Hand currently used for pulling/grabing
	var/pull_hand = PULL_WITHOUT_HANDS

	//Did the blob infected mob burst.
	var/was_bursted = FALSE
	//Was death by turning to dust.
	var/dusted = FALSE

	// True devil variables
	/// Soullinks we are the owner of
	var/list/ownedSoullinks
	/// Soullinks we are a/the sharer of
	var/list/sharedSoullinks

	/// Famous last words -- if succumbing, what the user's last words were
	var/last_words
