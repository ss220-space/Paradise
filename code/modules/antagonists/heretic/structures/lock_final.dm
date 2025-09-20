/obj/structure/lock_tear
	name = "???"
	// No ru_names, because it's ???
	desc = "Оно смотрит в ответ. Почему ты стоишь и смотришь на это? Беги!"
	max_integrity = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	color = COLOR_VOID_PURPLE
	light_color = COLOR_VOID_PURPLE
	light_range = 20
	anchored = TRUE
	layer = ABOVE_NORMAL_TURF_LAYER
	move_resist = INFINITY
	/// Who is our daddy?
	var/datum/mind/ascendee
	/// True if we're currently checking for ghost opinions
	var/gathering_candidates = TRUE
	///a static list of heretic summons we cam create, automatically populated from heretic monster subtypes
	var/static/list/monster_types
	/// A static list of heretic summons which we should not create
	var/static/list/monster_types_blacklist = list(
		/mob/living/simple_animal/hostile/heretic_summon/armsy,
		/mob/living/simple_animal/hostile/heretic_summon/star_gazer,
	)

/obj/structure/lock_tear/Initialize(mapload, datum/mind/ascendant_mind)
	. = ..()
	transform *= 3
	if(isnull(monster_types))
		monster_types = subtypesof(/mob/living/simple_animal/hostile/heretic_summon) - monster_types_blacklist

	if(!isnull(ascendant_mind))
		ascendee = ascendant_mind
		RegisterSignal(ascendant_mind.current, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(end_madness))

	GLOB.poi_list |= src
	notify_ghosts("Что это?", "???", source = src)
	poll_ghosts()


/// Ask ghosts if they want to make some noise
/obj/structure/lock_tear/proc/poll_ghosts()
	var/list/candidates = SSghost_spawns.poll_candidates("Вы бы хотели стать случайным [span_notice("древним монстром")], атакующим экипаж?", ROLE_SENTIENT, FALSE, 10 SECONDS, source = src, role_cleanname = "eldritch monster")
	while(LAZYLEN(candidates))
		var/mob/dead/observer/candidate = pick_n_take(candidates)
		ghost_to_monster(candidate, should_ask = FALSE)

	gathering_candidates = FALSE

/// Destroy the rift if you kill the heretic
/obj/structure/lock_tear/proc/end_madness(datum/former_master)
	SIGNAL_HANDLER
	var/turf/our_turf = get_turf(src)
	playsound(our_turf, 'sound/magic/castsummon.ogg', vol = 100, vary = TRUE)
	visible_message(span_boldwarning("Разрыв в пространстве сжимается и исчезает!"))
	UnregisterSignal(former_master, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING)) // Just in case they die THEN delete
	new /obj/effect/temp_visual/destabilising_tear(our_turf)
	qdel(src)


/obj/structure/lock_tear/attack_ghost(mob/user)
	. = ..()
	ghost_to_monster(user)


/obj/structure/lock_tear/examine(mob/user)
	. = ..()
	if(!isobserver(user) || gathering_candidates)
		return

	. += span_notice("Вы можете использовать это, чтобы войти в этот мир став отвратительным монстром.")

/// Turn a ghost into an 'orrible beast
/obj/structure/lock_tear/proc/ghost_to_monster(mob/dead/observer/user, should_ask = TRUE)
	if(should_ask)
		var/ask = tgui_alert(user, "Стать монстром?", "Разлом Вознесения", list("Да", "Нет"))
		if(ask != "Да" || QDELETED(src) || QDELETED(user))
			return FALSE

	var/monster_type = pick(monster_types)
	var/mob/living/monster = new monster_type(loc)
	monster.key = user.key
	monster.set_name()
	ADD_TRAIT(monster, TRAIT_HERETIC_SUMMON, INNATE_TRAIT)
	var/datum/antagonist/heretic_monster/woohoo_free_antag = new(src)
	monster.mind.add_antag_datum(woohoo_free_antag)
	if(ascendee)
		monster.faction = ascendee.current.faction
		woohoo_free_antag.set_owner(ascendee)

	var/datum/objective/kill_all_your_friends = new()
	kill_all_your_friends.owner = monster.mind
	kill_all_your_friends.explanation_text = "Персонал станции необходимо уволить. Уволить самым простым способом."
	kill_all_your_friends.completed = TRUE
	woohoo_free_antag.objectives += kill_all_your_friends

/obj/structure/lock_tear/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/obj/structure/lock_tear/Destroy(force)
	if(ascendee)
		ascendee = null

	return ..()

/obj/effect/temp_visual/destabilising_tear
	name = "нестабильный разлом"
	icon_state = "bhole3"
	color = COLOR_VOID_PURPLE
	light_color = COLOR_VOID_PURPLE
	light_range = 20
	layer = ABOVE_NORMAL_TURF_LAYER


/obj/effect/temp_visual/destabilising_tear/get_ru_names()
	return list(
		NOMINATIVE = "нестабильный разлом",
		GENITIVE = "нестабильного разлома",
		DATIVE = "нестабильному разлому",
		ACCUSATIVE = "нестабильный разлом",
		INSTRUMENTAL = "нестабильным разломом",
		PREPOSITIONAL = "нестабильном разломе",
	)


/obj/effect/temp_visual/destabilising_tear/Initialize(mapload)
	. = ..()
	transform *= 3
	animate(src, transform = matrix().Scale(3.2), time = 0.15 SECONDS)
	animate(transform = matrix().Scale(0.2), time = 0.75 SECONDS)
	animate(transform = matrix().Scale(3, 0), time = 0.1 SECONDS)
	animate(src, color = COLOR_WHITE, time = 0.25 SECONDS, flags = ANIMATION_PARALLEL)
	animate(color = COLOR_VOID_PURPLE, time = 0.3 SECONDS)
