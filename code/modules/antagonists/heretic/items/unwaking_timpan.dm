#define TIMPAN_RHYTM_GAIN 1
#define TIMPAN_STAMINA_THEFT 5
#define TIMPAN_BRUTE_DAMAGE 5
#define TIMPAN_RANGE 4
#define TIMPAN_SIGHT_RANGE 7
#define TIMPAN_COOLDOWN (3 SECONDS)
#define TIMPAN_HASTE_DURATION (3 SECONDS)
#define TIMPAN_SIGHT_DURATION (5 SECONDS)


/obj/item/unwaking_timpan
	name = "unwaking timpan"
	desc = "Небольшой барабан, обтянутый чужой кожей. Он никогда не замолкает до конца — \
			даже в тишине по нему пробегает едва слышная дрожь."
	gender = MALE
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "timpan"
	item_state = "timpan"
	lefthand_file = 'icons/mob/inhands/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FIRE_PROOF
	actions_types = list(/datum/action/item_action/beat_timpan)
	COOLDOWN_DECLARE(beat_cooldown)
	var/list/image/heard_outlines = list()
	var/datum/weakref/listener_ref
	var/sight_timer


/obj/item/unwaking_timpan/get_ru_names()
	return alist(
		NOMINATIVE = "неусыпный тимпан",
		GENITIVE = "неусыпного тимпана",
		DATIVE = "неусыпному тимпану",
		ACCUSATIVE = "неусыпный тимпан",
		INSTRUMENTAL = "неусыпным тимпаном",
		PREPOSITIONAL = "неусыпном тимпане",
	)


/obj/item/unwaking_timpan/Destroy()
	clear_outlines()
	return ..()


/obj/item/unwaking_timpan/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return
	. += span_notice("Удар по тимпану поднимает ваш ритм, разгоняет вас и вытягивает силы из всех вокруг. \
					Если вам нечего восполнять, удар просто отдаётся в их черепах. \
					Бить можно прямо из кармана.")


/obj/item/unwaking_timpan/attack_self(mob/user)
	beat(user)


/obj/item/unwaking_timpan/ui_action_click(mob/user, datum/action/action, leftclick)
	beat(user)


/obj/item/unwaking_timpan/proc/beat(mob/living/user)
	if(!IS_HERETIC_OR_MONSTER(user))
		to_chat(user, span_danger("Кожа тимпана дёргается под вашей рукой и замирает."))
		return

	if(!COOLDOWN_FINISHED(src, beat_cooldown))
		return

	COOLDOWN_START(src, beat_cooldown, TIMPAN_COOLDOWN)
	playsound(user, pick('sound/magic/heretic/rhytm/timpan1.ogg', 'sound/magic/heretic/rhytm/timpan2.ogg', 'sound/magic/heretic/rhytm/timpan3.ogg'), 60, TRUE)
	flick("timpan_use", src)

	var/datum/status_effect/heretic_passive/rhytm/our_rhythm = get_heretic_rhytm(user)
	our_rhythm?.adjust_rhythm(TIMPAN_RHYTM_GAIN)
	our_rhythm?.flourish()

	user.add_movespeed_modifier(/datum/movespeed_modifier/unwaking_timpan)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/unwaking_timpan), TIMPAN_HASTE_DURATION)

	var/nothing_to_steal = !user.getStaminaLoss()
	clear_outlines()
	listener_ref = WEAKREF(user)
	for(var/mob/living/heard in range(TIMPAN_SIGHT_RANGE, user))
		if(heard == user)
			continue
		show_outline(user, heard)
		if(IS_HERETIC_OR_MONSTER(heard) || get_dist(user, heard) > TIMPAN_RANGE)
			continue
		if(nothing_to_steal)
			heard.apply_damage(TIMPAN_BRUTE_DAMAGE, BRUTE, BODY_ZONE_HEAD)
			to_chat(heard, span_userdanger("Удар отдаётся у вас в черепе!"))
			continue
		var/stolen = min(TIMPAN_STAMINA_THEFT, MAX_STAMINA_LOSS - heard.getStaminaLoss())
		if(stolen <= 0)
			continue
		heard.adjustStaminaLoss(stolen, forced = TRUE)
		user.adjustStaminaLoss(-stolen)
		to_chat(heard, span_userdanger("Удар тимпана вытягивает из вас силы!"))

	sight_timer = addtimer(CALLBACK(src, PROC_REF(clear_outlines)), TIMPAN_SIGHT_DURATION, TIMER_STOPPABLE)


/obj/item/unwaking_timpan/proc/show_outline(mob/living/user, mob/living/heard)
	var/image/outline = image('icons/effects/eldritch.dmi', heard, "rhytm", ABOVE_LIGHTING_PLANE)
	outline.color = COLOR_MAROON
	outline.appearance_flags |= RESET_ALPHA
	SET_PLANE_EXPLICIT(outline, ABOVE_LIGHTING_PLANE, heard)
	heard_outlines += outline
	user.client?.images |= outline


/obj/item/unwaking_timpan/proc/clear_outlines()
	deltimer(sight_timer)
	sight_timer = null
	var/mob/listener = listener_ref?.resolve()
	for(var/image/outline as anything in heard_outlines)
		listener?.client?.images -= outline
	heard_outlines.Cut()
	listener_ref = null


/datum/action/item_action/beat_timpan
	name = "Ударить в тимпан"
	button_icon = 'icons/obj/eldritch.dmi'
	button_icon_state = "timpan"
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_rhytm"
	overlay_icon = 'icons/mob/actions/backgrounds.dmi'
	overlay_icon_state = "bg_heretic_border"


#undef TIMPAN_RHYTM_GAIN
#undef TIMPAN_STAMINA_THEFT
#undef TIMPAN_BRUTE_DAMAGE
#undef TIMPAN_RANGE
#undef TIMPAN_SIGHT_RANGE
#undef TIMPAN_COOLDOWN
#undef TIMPAN_HASTE_DURATION
#undef TIMPAN_SIGHT_DURATION
