
/// The number of influences spawned per heretic
#define NUM_INFLUENCES_PER_HERETIC 5

/**
 * #Reality smash tracker
 *
 * A global singleton data that tracks all the heretic
 * influences ("reality smashes") that we've created,
 * and all of the heretics (minds) that can see them.
 *
 * Handles ensuring all minds can see influences, generating
 * new influences for new heretic minds, and allowing heretics
 * to see new influences that are created.
 */
/datum/reality_smash_tracker
	/// The total number of influences that have been drained, for tracking.
	var/num_drained = 0
	/// List of tracked influences (reality smashes)
	var/list/obj/effect/heretic_influence/smashes = list()
	/// List of minds with the ability to see influences
	var/list/datum/mind/tracked_heretics = list()


/datum/reality_smash_tracker/Destroy(force)
	if(GLOB.reality_smash_track == src)
		stack_trace("[type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
		message_admins("The [type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")

	QDEL_LIST(smashes)
	tracked_heretics.Cut()
	return ..()

/**
 * Generates a set amount of reality smashes
 * based on the number of already existing smashes
 * and the number of minds we're tracking.
 */
/datum/reality_smash_tracker/proc/generate_new_influences()
	var/how_many_can_we_make = 0
	for(var/heretic_number in 1 to length(tracked_heretics))
		how_many_can_we_make += max(NUM_INFLUENCES_PER_HERETIC - heretic_number + 1, 1)

	var/location_sanity = 0
	while((length(smashes) + num_drained) < how_many_can_we_make && location_sanity < 100)
		var/turf/chosen_location = get_safe_random_station_turf()

		var/list/nearby_things = range(1, chosen_location)
		var/obj/effect/heretic_influence/what_if_i_have_one = locate() in nearby_things
		var/obj/effect/visible_heretic_influence/what_if_i_had_one_but_its_used = locate() in nearby_things
		if(what_if_i_have_one || what_if_i_had_one_but_its_used)
			location_sanity++
			continue

		new /obj/effect/heretic_influence(chosen_location)

/**
 * Adds a mind to the list of people that can see the reality smashes
 *
 * Use this whenever you want to add someone to the list
 */
/datum/reality_smash_tracker/proc/add_tracked_mind(datum/mind/heretic)
	tracked_heretics |= heretic

	if(ishuman(heretic.current) && !is_centcomm(heretic.current.z))
		generate_new_influences()

	rework_existing_influences(heretic.current)

/**
 * (Re-)applies every existing influence's reality-smash hud to [show_to_mob].
 * Safe to call repeatedly: apply_to_new_mob() no-ops if the mob is already a hud user.
 */
/datum/reality_smash_tracker/proc/rework_existing_influences(mob/show_to_mob)
	if(!show_to_mob)
		return
	for(var/obj/effect/heretic_influence/influence as anything in smashes)
		var/datum/atom_hud/alternate_appearance/influence_hud = LAZYACCESS(influence.alternate_appearances, "reality_smash")
		influence_hud?.apply_to_new_mob(show_to_mob)

/**
 * Removes a mind from the list of people that can see the reality smashes
 *
 * Use this whenever you want to remove someone from the list
 */
/datum/reality_smash_tracker/proc/remove_tracked_mind(datum/mind/heretic)
	tracked_heretics -= heretic


/obj/effect/visible_heretic_influence
	name = "pierced reality"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion"
	layer = BELOW_MOB_LAYER
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	alpha = 0


/obj/effect/visible_heretic_influence/get_ru_names()
	return alist(
		NOMINATIVE = "раскол реальности",
		GENITIVE = "раскола реальности",
		DATIVE = "расколу реальности",
		ACCUSATIVE = "раскол реальности",
		INSTRUMENTAL = "расколом реальности",
		PREPOSITIONAL = "расколе реальности",
	)


/obj/effect/visible_heretic_influence/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(show_presence)), 15 SECONDS)
	var/image/silicon_image = image('icons/effects/eldritch.dmi', src, null, OBJ_LAYER)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "pierced_reality", silicon_image)

/*
 * Makes the influence fade in after 15 seconds.
 */
/obj/effect/visible_heretic_influence/proc/show_presence()
	animate(src, alpha = 255, time = 15 SECONDS)


/obj/effect/visible_heretic_influence/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		return

	. = TRUE
	if(isheretic(user))
		to_chat(user, span_boldwarning("Вы решаете, что не стоит играть с неподконтрольными вам силами!"))
		return

	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/external/their_poor_arm = user.hand ? user.get_organ(BODY_ZONE_L_ARM) : user.get_organ(BODY_ZONE_R_ARM)
	if(prob(75))
		to_chat(human_user, span_danger("Вы в последний момент отдёргиваете руку от дыры, видя как потусторонняя энергия пытается ухватиться за нее!"))
		return

	if(!their_poor_arm) // that hand's already gone - nothing left for the hole to tear off
		to_chat(human_user, span_danger("Вы тянетесь к дыре тем, чего у вас уже нет..."))
		return TRUE

	to_chat(human_user, span_userdanger("Нечто потустороннее отрывает и поглощает вашу [their_poor_arm.declent_ru(ACCUSATIVE)], когда вы пытаетесь прикоснуться к дыре в ткани реальности!"))
	their_poor_arm.dismember()
	their_poor_arm.forceMove(src) // stored for later fishage
	return TRUE


/obj/effect/visible_heretic_influence/attack_tk(mob/user)
	if(!ishuman(user))
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN

	if(isheretic(user))
		to_chat(user, span_boldwarning("Вы решаете, что не стоит играть с неподконтрольными вам силами!"))
		return

	var/mob/living/carbon/human/human_user = user

	if(human_user.can_block_magic(MAGIC_RESISTANCE_MIND))
		visible_message(span_danger("Эфимерные щупальца вылезают из [declent_ru(GENITIVE)], но не могут достичь головы [human_user]."))
		return

	visible_message(span_userdanger("Эфимерные щупальца вылезают из [declent_ru(GENITIVE)], обхватывают голову [human_user] и отрывают её!"))
	var/obj/item/organ/external/head/head = locate() in human_user.bodyparts
	if(head)
		head.dismember()
		head.forceMove(src) // stored for later fishage
	else
		human_user.gib()

	human_user.investigate_log("has died from using telekinesis on a heretic influence.", INVESTIGATE_DEATHS)
	var/datum/effect_system/reagents_explosion/explosion = new()
	explosion.set_up(1, get_turf(human_user), TRUE, 0)
	explosion.start(src)


/obj/effect/visible_heretic_influence/examine(mob/living/user)
	. = ..()
	. += span_purple(pick_list(HERETIC_INFLUENCE_FILE, "examine"))
	if(isheretic(user) || !ishuman(user))
		return

	. += span_userdanger("Ваш разум горит, когда вы смотрите на разлом!")
	user.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 10, 190)


/obj/effect/visible_heretic_influence/get_examine_time()
	return 0.5 SECONDS


/obj/effect/heretic_influence
	name = "pierced reality"
	icon = 'icons/effects/eldritch.dmi'
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_OBSERVER
	layer = BELOW_MOB_LAYER
	/// Whether we're currently being drained or not.
	var/being_drained = FALSE
	/// The icon state applied to the image created for this influence.
	var/real_icon_state = "reality_smash"


/obj/effect/heretic_influence/get_ru_names()
	return alist(
		NOMINATIVE = "раскол реальности",
		GENITIVE = "раскола реальности",
		DATIVE = "расколу реальности",
		ACCUSATIVE = "раскол реальности",
		INSTRUMENTAL = "расколом реальности",
		PREPOSITIONAL = "расколе реальности",
	)


/obj/effect/heretic_influence/Initialize(mapload)
	. = ..()
	GLOB.reality_smash_track.smashes += src
	generate_name()

	var/image/heretic_image = image(icon, src, real_icon_state, OBJ_LAYER)
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/heretic, "reality_smash", heretic_image)

	AddComponent(/datum/component/redirect_attack_hand_from_turf, interact_check = CALLBACK(src, PROC_REF(verify_user_can_see)))

	proximity_monitor = new /datum/proximity_monitor/influence_monitor(src, 7)


/obj/effect/heretic_influence/proc/verify_user_can_see(mob/user)
	return (user.mind in GLOB.reality_smash_track.tracked_heretics)


/obj/effect/heretic_influence/Destroy()
	GLOB.reality_smash_track.smashes -= src
	return ..()


/obj/effect/heretic_influence/attack_hand(mob/living/user, list/modifiers)
	if(!isheretic(user))
		return ..()

	if(being_drained)
		loc.balloon_alert(user, "уже иссушается!")
	else
		INVOKE_ASYNC(src, PROC_REF(drain_influence), user, 1, 15 SECONDS)


/obj/effect/heretic_influence/attackby(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(drain_influence_with_codex(user, weapon))
		return ATTACK_CHAIN_PROCEED


/obj/effect/heretic_influence/proc/drain_influence_with_codex(mob/user, obj/item/codex_cicatrix/codex)
	if(!istype(codex) || being_drained)
		return FALSE

	if(!codex.book_open)
		codex.attack_self(user) // open booke

	INVOKE_ASYNC(src, PROC_REF(drain_influence), user, 2, codex.drain_speed)
	return TRUE


/**
 * Begin to drain the influence, setting being_drained,
 * registering an examine signal, and beginning a do_after.
 *
 * If successful, the influence is drained and deleted.
 */
/obj/effect/heretic_influence/proc/drain_influence(mob/living/user, knowledge_to_gain, drain_speed = 10 SECONDS)

	being_drained = TRUE
	loc.balloon_alert(user, "иссушение разлома...")

	if(!do_after(user, drain_speed, src))
		being_drained = FALSE
		if(!QDELETED(src))
			loc.balloon_alert(user, "прервано!")
		return

	loc.balloon_alert(user, "разлом иссушен")

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_datum.knowledge_points += knowledge_to_gain

	after_drain(user)


/**
 * Handle the effects of the drain.
 */
/obj/effect/heretic_influence/proc/after_drain(mob/living/user)
	if(user)
		to_chat(user, span_purple(pick_list(HERETIC_INFLUENCE_FILE, "drain_message")))
		to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] начинает проявляться в реальности!"))

	var/obj/effect/visible_heretic_influence/illusion = new /obj/effect/visible_heretic_influence(drop_location())
	var/choosen_name = pick_list(HERETIC_INFLUENCE_FILE, "drained")
	illusion.name = "\improper" + choosen_name + "ый " + format_text(name)
	illusion.ru_names = alist(
		NOMINATIVE = "[choosen_name]ый [declent_ru(NOMINATIVE)]",
		GENITIVE = "[choosen_name]ого [declent_ru(GENITIVE)]",
		DATIVE = "[choosen_name]ому [declent_ru(DATIVE)]",
		ACCUSATIVE = "[choosen_name]ый [declent_ru(ACCUSATIVE)]",
		INSTRUMENTAL = "[choosen_name]ым [declent_ru(INSTRUMENTAL)]",
		PREPOSITIONAL = "[choosen_name]ом [declent_ru(PREPOSITIONAL)]",
	)

	GLOB.reality_smash_track.num_drained++
	qdel(src)


/**
 * Generates a random name for the influence.
 */
/obj/effect/heretic_influence/proc/generate_name()
	name = pick_list(HERETIC_INFLUENCE_FILE, "prefix") + " " + pick_list(HERETIC_INFLUENCE_FILE, "postfix")


#undef NUM_INFLUENCES_PER_HERETIC


/// Proximity monitor that grants a passing heretic Eldritch Sight (temporary x-ray), on a personal cooldown.
/datum/proximity_monitor/influence_monitor
	/// Cooldown before this influence can grant Eldritch Sight again.
	COOLDOWN_DECLARE(xray_cooldown)


/datum/proximity_monitor/influence_monitor/on_entered(atom/source, atom/movable/arrived, turf/old_loc)
	. = ..()
	if(!isliving(arrived))
		return
	if(!COOLDOWN_FINISHED(src, xray_cooldown))
		return
	var/mob/living/arrived_living = arrived
	if(!isheretic(arrived_living))
		return
	arrived_living.apply_status_effect(/datum/status_effect/temporary_xray/eldritch)
	COOLDOWN_START(src, xray_cooldown, 3 MINUTES)
