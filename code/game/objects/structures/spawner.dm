/obj/structure/spawner
	name = "monster nest"
	icon = 'icons/mob/animal.dmi'
	icon_state = "hole"
	max_integrity = 100
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = TRUE

	// === BASIC SETTINGS ===
	/// Operation mode: SIMPLE_SPAWNER, WAVE_SPAWNER, BURST_SPAWNER
	var/spawner_mode = SIMPLE_SPAWNER
	/// Mob types to spawn
	var/list/mob_types = list(/mob/living/simple_animal/hostile/carp)
	/// Mob faction
	var/list/faction = list("hostile")
	/// Spawn text ("emerges from", "crawls out of")
	var/spawn_text = "появляется из"
	/// Maximum living mobs at once (0 = no limit)
	var/max_mobs = 5

	// === SIMPLE MODE SETTINGS ===
	/// Spawn interval in simple mode
	var/spawn_time = 300

	// === WAVE MODE SETTINGS ===
	/// Wave size (mobs per cycle)
	var/wave_size = 3
	/// Interval between mobs within a wave
	var/wave_spawn_time = 100
	/// Cooldown between waves
	var/wave_cooldown = 600
	/// Activation message when wave starts
	var/activation_message = "начинает гудеть!"
	/// Deactivation message when wave ends
	var/deactivation_message = "затихает."

	// === BURST MODE SETTINGS ===
	/// Mobs per burst
	var/burst_size = 5
	/// Cooldown between bursts
	var/burst_cooldown = 1200

	// === VISUAL SETTINGS ===
	/// Icon state when active
	var/active_icon_state = "fab_robot"
	/// Icon state when inactive
	var/inactive_icon_state = "fab_robot"
	/// Sound when cycle starts
	var/activation_sound = 'sound/machines/synth_yes.ogg'
	/// Sound when cycle completes
	var/deactivation_sound = 'sound/machines/synth_no.ogg'

	// === GPS SETTINGS ===
	/// Is this spawner taggable with something?
	var/scanner_taggable = FALSE
	/// If this spawner's taggable, what can we tag it with?
	var/static/list/scanner_types = list(/obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner)
	/// If this spawner's taggable, what's the text we use to describe what we can tag it with?
	var/scanner_descriptor = "mining analyzer"
	/// Has this spawner been tagged/analyzed by a mining scanner?
	var/gps_tagged = FALSE
	/// A short identifier for the mob it spawns. Keep around 3 characters or less?
	var/mob_gps_id = "???"
	/// A short identifier for what kind of spawner it is, for use in putting together its GPS tag.
	var/spawner_gps_id = "Creature Nest"
	/// A complete identifier. Generated on tag (if tagged), used for its examine.
	var/assigned_tag

/obj/structure/spawner/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spawner, mob_types, spawner_mode, faction, spawn_text, max_mobs, spawn_time, wave_size, wave_spawn_time, wave_cooldown, activation_message, deactivation_message, burst_size, burst_cooldown, active_icon_state, inactive_icon_state, activation_sound, deactivation_sound)

/obj/structure/spawner/Destroy()
	return ..()

/obj/structure/spawner/attack_animal(mob/living/simple_animal/M)
	if(faction_check(faction, M.faction, FALSE) && !M.client)
		return
	..()

/obj/structure/spawner/examine(mob/user)
	. = ..()
	if(!scanner_taggable)
		return
	if(gps_tagged)
		. += span_notice("A holotag's been attached, projecting \"<b>[assigned_tag]</b>\".")
	else
		. += span_notice("It looks like you could probably scan and tag it with a <b>[scanner_descriptor]</b>.")

/obj/structure/spawner/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !scanner_taggable || !is_type_in_list(I, scanner_types))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	gps_tag(user)

/// Tag the spawner, prefixing its GPS entry with an identifier - or giving it one, if nonexistent.
/obj/structure/spawner/proc/gps_tag(mob/user)
	if(gps_tagged)
		to_chat(user, span_warning("[src] already has a holotag attached!"))
		return
	to_chat(user, span_notice("You affix a holotag to [src]."))
	playsound(src, 'sound/machines/twobeep.ogg', 50)
	gps_tagged = TRUE
	assigned_tag = "\[[mob_gps_id]-[rand(100,999)]\] " + spawner_gps_id
	var/obj/item/gps/internal = new /obj/item/gps/internal/tendril(src)
	if(internal)
		internal.gpstag = assigned_tag

/obj/item/gps/internal/tendril
	icon_state = null
	gpstag = "Null Signal"
	desc = "Holotag to a spawner."
	invisibility = 100

/obj/structure/spawner/syndicate
	name = "warp beacon"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	spawn_text = "warps in from"
	mob_types = list(/mob/living/simple_animal/hostile/syndicate/ranged)
	faction = list(ROLE_SYNDICATE)
	mob_gps_id = "SYN" // syndicate
	spawner_gps_id = "Hostile Warp Beacon"

/obj/structure/spawner/skeleton
	name = "bone pit"
	desc = "A pit full of bones, and some still seem to be moving..."
	icon = 'icons/mob/nest.dmi'
	max_integrity = 150
	max_mobs = 15
	spawn_time = 150
	mob_types = list(/mob/living/simple_animal/hostile/skeleton)
	spawn_text = "climbs out of"
	faction = list("undead")
	mob_gps_id = "SKL" // skeletons
	spawner_gps_id = "Bone Pit"

/obj/structure/spawner/clown
	name = "Laughing Larry"
	desc = "A laughing, jovial figure. Something seems stuck in his throat."
	icon_state = "clownbeacon"
	icon = 'icons/obj/device.dmi'
	max_integrity = 200
	max_mobs = 15
	spawn_time = 150
	mob_types = list(/mob/living/simple_animal/hostile/retaliate/clown)
	spawn_text = "climbs out of"
	faction = list("clown")
	spawner_gps_id = "Clown Planet Distortion"

/obj/structure/spawner/mining
	name = "monster den"
	desc = "A hole dug into the ground, harboring all kinds of monsters found within most caves or mining asteroids."
	max_integrity = 200
	max_mobs = 3
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls out of"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goldgrub, /mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/hivelord, /mob/living/simple_animal/hostile/asteroid/basilisk)
	faction = list("mining")

/obj/structure/spawner/mining/goldgrub
	name = "goldgrub den"
	desc = "A den housing a nest of goldgrubs, annoying but arguably much better than anything else you'll find in a nest."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goldgrub)
	mob_gps_id = "GG"

/obj/structure/spawner/mining/goliath
	name = "goliath den"
	desc = "A den housing a nest of goliaths, oh god why?"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goliath)
	mob_gps_id = "GL"

/obj/structure/spawner/mining/hivelord
	name = "hivelord den"
	desc = "A den housing a nest of hivelords."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord)
	mob_gps_id = "HL"

/obj/structure/spawner/mining/basilisk
	name = "basilisk den"
	desc = "A den housing a nest of basilisks, bring a coat."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/basilisk)
	mob_gps_id = "BK"

/obj/structure/spawner/headcrab
	name = "headcrab nest"
	desc = "A living nest for headcrabs. It is moving ominously."
	icon_state = "headcrab_nest"
	icon = 'icons/mob/headcrab.dmi'
	max_integrity = 200
	max_mobs = 15
	spawn_time = 600
	mob_types = list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/fast, /mob/living/simple_animal/hostile/headcrab/poison)
	spawn_text = "crawls out of"
	faction = list("hostile")
	mob_gps_id = "HC"

/obj/structure/spawner/test_simple
	name = "test_simple"
	spawn_time = 50
	max_mobs = 3
	mob_types = list(/mob/living/simple_animal/hostile/carp)
	spawn_text = "выпрыгивает из"

/obj/structure/spawner/test_wave
	name = "test_wave"
	spawner_mode = WAVE_SPAWNER
	wave_size = 2
	wave_spawn_time = 20
	wave_cooldown = 100
	activation_message = "запускает протокол!"
	deactivation_message = "отключается."
	mob_types = list(/mob/living/simple_animal/hostile/bear)

/obj/structure/spawner/test_burst
	name = "test_burst"
	spawner_mode = BURST_SPAWNER
	burst_size = 4
	burst_cooldown = 150
	mob_types = list(/mob/living/simple_animal/hostile/carp)

/obj/structure/spawner/test_unlimited
	max_mobs = 0
	spawn_time = 30

/obj/structure/spawner/test_single
	max_mobs = 1
	spawn_time = 20
