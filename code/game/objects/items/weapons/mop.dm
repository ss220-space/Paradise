#define MOP_SOUND_CD 2 SECONDS // How many seconds before the mopping sound triggers again

/obj/item/mop
	name = "mop"
	desc = "The world of janitalia wouldn't be complete without a mop."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("ударил", "огрел")
	resistance_flags = FLAMMABLE
	var/mopping = 0
	var/mopcount = 0
	var/mopcap = 5
	var/mopspeed = 30
	/// The cooldown between each mopping sound effect
	var/mop_sound_cooldown
	/// Max range of mopping.
	var/mop_range = 1

/obj/item/mop/Initialize(mapload)
	. = ..()
	create_reagents(mopcap)
	GLOB.janitorial_equipment += src

/obj/item/mop/Destroy()
	GLOB.janitorial_equipment -= src
	return ..()


/obj/item/mop/proc/wet_mop(obj/target, mob/user)
	if(user.a_intent == INTENT_GRAB)
		. = FALSE
		if(istype(target, /obj/structure/mopbucket))
			. = mopbucket_insert(user, target)
		else if(istype(target, /obj/structure/janitorialcart))
			. = janicart_insert(user, target)
		return .

	if(!target.reagents || target.reagents.total_volume < 1)
		to_chat(user, span_notice("Looks like [target]'s bucket is empty."))
		return FALSE

	. = TRUE
	target.reagents.trans_to(src, 5)
	to_chat(user, span_notice("You wet [src] in [target]."))
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)


/obj/item/mop/proc/clean(turf/simulated/atom)
	if(!reagents.has_reagent("water", 1) && !reagents.has_reagent("cleaner", 1) && !reagents.has_reagent("holywater", 1))
		reagents.reaction(atom, REAGENT_TOUCH, 10) //10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
		reagents.remove_any(1) //reaction() doesn't use up the reagents
		return

	atom.clean_blood()
	for(var/obj/effect/effect in atom)
		if(!effect.is_cleanable())
			continue

		qdel(effect)

	SEND_SIGNAL(atom, COMSIG_COMPONENT_CLEAN_ACT, 5)
	reagents.reaction(atom, REAGENT_TOUCH, 10) //10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents


/obj/item/mop/afterattack(atom/atom, mob/user, proximity, params)
	if(!proximity || iseffect(atom))
		return

	if(reagents.total_volume < 1)
		to_chat(user, span_warning("Your mop is dry!"))
		return

	if(istype(atom, /obj/item/reagent_containers/glass/bucket) || istype(atom, /obj/structure/janitorialcart) || istype(atom, /obj/structure/mopbucket))
		return

	if(world.time > mop_sound_cooldown)
		playsound(loc, pick('sound/weapons/mopping1.ogg', 'sound/weapons/mopping2.ogg'), 30, TRUE, -1)
		mop_sound_cooldown = world.time + MOP_SOUND_CD

	var/clicked_turf = get_turf(atom)
	var/list/turf/turfs = get_mopping_turfs(user, clicked_turf)
	if(!turfs.len)
		return

	user.visible_message(
		"[user] начина[pluralize_ru(user.gender, "ет", "ют")] возить по полу [declent_ru(INSTRUMENTAL)].",
		ignored_mobs = user
	)
	user.balloon_alert(user, "мытьё пола...")

	var/list/bubbles = list()
	for(var/turf/turf as anything in turfs)
		bubbles += new /obj/effect/temp_visual/bubbles(turf, mopspeed)

	if(!do_after(user, mopspeed, clicked_turf))
		QDEL_LAZYLIST(bubbles)
		return

	user.balloon_alert(user, "")
	to_chat(user, span_notice("мытьё закончено"))
	for(var/turf/turf as anything in turfs)
		clean(turf)

	QDEL_LAZYLIST(bubbles)


/obj/item/mop/proc/get_mopping_turfs(mob/user, turf/click_turf)
	var/turf/user_turf = get_turf(user)
	if(user_turf == click_turf)
		return list(click_turf)

	var/list/turfs = list()
	for(var/turf/simulated/turf in range(mop_range, click_turf) - user_turf)
		if(abs(turf.x - click_turf.x) + abs(turf.y - click_turf.y) > mop_range)
			continue

		if(get_dist(user_turf, turf) > mop_range)
			continue

		turfs |= turf

	return turfs


/obj/item/mop/proc/janicart_insert(mob/user, obj/structure/janitorialcart/cart)
	if(cart.mymop)
		to_chat(user, span_notice("There is already [cart.mymop] in [cart]."))
		return FALSE
	. = cart.put_in_cart(src, user)
	if(.)
		cart.mymop = src
		cart.updateUsrDialog()
		cart.update_icon(UPDATE_OVERLAYS)


/obj/item/mop/proc/mopbucket_insert(mob/user, obj/structure/mopbucket/bucket)
	if(bucket.mymop)
		to_chat(user, span_notice("There is already [bucket.mymop] in [bucket]."))
		return FALSE
	. = bucket.put_in_cart(src, user)
	if(.)
		bucket.mymop = src
		bucket.update_icon(UPDATE_OVERLAYS)


/obj/item/mop/wash(mob/user, atom/source)
	reagents.add_reagent("water", 5)
	to_chat(user, "<span class='notice'>You wet [src] in [source].</span>")
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
	return 1

/obj/item/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal. Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	mopcap = 10
	icon_state = "advmop"
	item_state = "advmop"
	origin_tech = "materials=3;engineering=3"
	force = 6
	throwforce = 8
	throw_range = 4
	mopspeed = 20
	mop_range = 2
	var/refill_enabled = TRUE //Self-refill toggle for when a janitor decides to mop with something other than water.
	var/refill_rate = 1 //Rate per process() tick mop refills itself
	var/refill_reagent = "water" //Determins what reagent to use for refilling, just in case someone wanted to make a HOLY MOP OF PURGING

/obj/item/mop/advanced/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mop/advanced/attack_self(mob/user)
	refill_enabled = !refill_enabled
	if(refill_enabled)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	to_chat(user, "<span class='notice'>You set the condenser switch to the '[refill_enabled ? "ON" : "OFF"]' position.</span>")
	playsound(user, 'sound/machines/click.ogg', 30, TRUE)

/obj/item/mop/advanced/process()

	if(reagents.total_volume < mopcap)
		reagents.add_reagent(refill_reagent, refill_rate)

/obj/item/mop/advanced/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The condenser switch is set to <b>[refill_enabled ? "ON" : "OFF"]</b>.</span>"

/obj/item/mop/advanced/Destroy()
	if(refill_enabled)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mop/advanced/cyborg

#undef MOP_SOUND_CD
