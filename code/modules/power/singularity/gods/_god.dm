/// Shared base for round-ending eldritch avatars (Nar'Sie, Ratvar).
/// Wraps the singularity component, the POI bookkeeping, the spawn animation,
/// and the mesmerize tick. Subtypes only customize their flavor.
/obj/god
	abstract_type = /obj/god
	name = "Бог"
	desc = "Ваш разум пульсирует и плывёт в безуспешных попытках осознать ЭТО."
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	move_resist = INFINITY
	obj_flags = DANGEROUS_POSSESSION
	plane = MASSIVE_OBJ_PLANE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags = SUPERMATTER_IGNORES

	/// How many humans got killed by it. For now used only for /proc/apocalypse cinematics
	var/soul_devoured = 0

	/// The singularity component. Weakref so admin removal of the component preserves the obj.
	var/datum/weakref/singularity

	// Singularity component config
	/// Tiles in which the god consumes outright.
	var/consume_range = 6
	/// Tiles out from which the god pulls in atoms.
	var/grav_pull = 5
	/// Stage size handed to the component (mostly used by singularity_act).
	var/singularity_size = STAGE_SIX

	// Mesmerize
	var/mesmerize_chance = 25
	var/mesmerize_effect = 6 SECONDS
	var/mesmerize_range = 8

	// Spawn animation
	var/spawn_anim_icon
	var/spawn_anim_state
	var/spawn_anim_duration = 1.1 SECONDS

	/// Name passed to /datum/game_mode/proc/apocalypse on rise.
	var/apocalypse_god_name

	// Rise/fall flavor (override or set per subtype)
	var/rise_sound
	var/fall_sound = 'sound/hallucinations/wail.ogg'
	var/ghost_alert_icon
	var/ghost_alert_state
	/// Prefix for the ghost notification; the spawn area name is appended.
	var/ghost_alert_message

/obj/god/Initialize(mapload)
	. = ..()
	GLOB.poi_list |= src
	START_PROCESSING(SSobj, src)

	singularity = WEAKREF(AddComponent(
		/datum/component/singularity, \
		bsa_targetable = FALSE, \
		consume_callback = CALLBACK(src, PROC_REF(consume)), \
		consume_range = consume_range, \
		disregard_failed_movements = TRUE, \
		grav_pull = grav_pull, \
		notify_admins = FALSE, \
		roaming = FALSE, /* enabled once the spawn animation finishes */ \
		singularity_size = singularity_size, \
	))

	if(mapload)
		return

	on_rise()
	if(spawn_anim_icon)
		spawn_animation()
	if(apocalypse_god_name)
		addtimer(CALLBACK(SSticker.mode, TYPE_PROC_REF(/datum/game_mode, apocalypse), apocalypse_god_name), 10 SECONDS)

/obj/god/Destroy()
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list -= src
	on_fall()
	return ..()

/obj/god/process()
	if(prob(mesmerize_chance))
		mezzer()

/// Singularity component's consume callback. Override per god.
/obj/god/proc/consume(atom/thing)
	return

/// Whether the given mob is an aligned devotee (cultist, clockcultist).
/obj/god/proc/is_devotee(mob/living/carbon/mob)
	return FALSE

/// Stun nearby non-devotee carbons.
/obj/god/proc/mezzer()
	for(var/mob/living/carbon/victim in oviewers(mesmerize_range, src))
		if(victim.stat != CONSCIOUS || is_devotee(victim))
			continue
		to_chat(victim, span_warning("Вы чувствуете, как от одного только взгляда на [declent_ru(ACCUSATIVE)] ваше сознание раскалывается на части..."))
		victim.apply_effect(mesmerize_effect, STUN)

/// Wraps an announcement string in the god's themed span. Subtypes should override.
/obj/god/proc/wrap_announce(text)
	return span_warning(text)

/// Called from on_rise to fire the gamemode-specific summon hook (cult_objs, clocker_objs).
/obj/god/proc/announce_summon()
	return

/// Called from on_fall to fire the gamemode-specific death hook.
/obj/god/proc/announce_death()
	return

/// Devotees that get the retribution chat on death (cultists, clockcultists).
/obj/god/proc/devotees()
	return list()

/obj/god/proc/on_rise()
	send_to_playing_players(wrap_announce(uppertext("[declent_ru(NOMINATIVE)] ПРОБУДИЛ[GEND_SYA_AS_OS_IS(src)]")))
	if(rise_sound)
		sound_to_playing_players(rise_sound)
	announce_summon()
	if(!ghost_alert_message)
		return
	var/area/area = get_area(src)
	if(!area)
		return
	var/image/alert_overlay
	if(ghost_alert_icon && ghost_alert_state)
		alert_overlay = image(ghost_alert_icon, ghost_alert_state)
	notify_ghosts("[ghost_alert_message] [area.name].", source = src, alert_overlay = alert_overlay, action = NOTIFY_ATTACK)

/obj/god/proc/on_fall()
	send_to_playing_players(wrap_announce(uppertext("[declent_ru(NOMINATIVE)] ПОВЕРЖЕН[GEND_A_O_I(src)]")))
	if(fall_sound)
		sound_to_playing_players(fall_sound)
	announce_death()
	for(var/datum/mind/devotee_mind in devotees())
		if(!devotee_mind?.current)
			continue
		to_chat(devotee_mind.current, wrap_announce("ОТМЩЕНИЕ!!"))
		to_chat(devotee_mind.current, wrap_announce("Текущая цель: Истребить всех неверных!"))

/obj/god/proc/spawn_animation()
	icon = spawn_anim_icon
	setDir(SOUTH)
	flick(spawn_anim_state, src)
	addtimer(CALLBACK(src, PROC_REF(spawn_animation_end)), spawn_anim_duration)

/obj/god/proc/spawn_animation_end()
	icon = initial(icon)
	var/datum/component/singularity/singularity_component = singularity?.resolve()
	singularity_component?.roaming = TRUE
