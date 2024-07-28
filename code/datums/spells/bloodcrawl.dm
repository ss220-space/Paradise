//Travel through pools of blood. Slaughter Demon powers for everyone!
#define BLOODCRAWL     1
#define BLOODCRAWL_EAT 2


/obj/effect/proc_holder/spell/bloodcrawl
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	base_cooldown = 0
	clothes_req = FALSE
	human_req = FALSE
	phase_allowed = TRUE
	cooldown_min = 0
	should_recharge_after_cast = FALSE
	overlay = null
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	var/allowed_type = /obj/effect/decal/cleanable
	var/phased = FALSE


/obj/effect/proc_holder/spell/bloodcrawl/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.allowed_type = allowed_type
	T.random_target = TRUE
	T.range = 1
	T.use_turf_of_user = TRUE
	return T


/obj/effect/proc_holder/spell/bloodcrawl/valid_target(obj/effect/decal/cleanable/target, user)
	return target.can_bloodcrawl_in()


/obj/effect/proc_holder/spell/bloodcrawl/can_cast(mob/living/user, charge_check, show_message)
	. = ..()
	if(!.)
		return
	if(!isliving(user))
		return FALSE


/obj/effect/proc_holder/spell/bloodcrawl/cast(list/targets, mob/living/user)
	var/atom/target = targets[1]
	if(phased)
		if(phasein(target, user))
			phased = FALSE
	else
		if(phaseout(target, user))
			phased = TRUE
	cooldown_handler.start_recharge()


/obj/item/bloodcrawl
	name = "blood crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/effects/blood.dmi'
	item_flags = ABSTRACT


/obj/item/bloodcrawl/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)


/obj/effect/dummy/slaughter //Can't use the wizard one, blocked by jaunt/slow
	name = "odd blood"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/obj/effect/dummy/slaughter/relaymove(mob/user, direction)
	forceMove(get_step(src, direction))


/obj/effect/dummy/slaughter/ex_act()
	return


/obj/effect/dummy/slaughter/bullet_act()
	return


/obj/effect/dummy/slaughter/singularity_act()
	return


/obj/effect/proc_holder/spell/bloodcrawl/proc/block_hands(mob/living/carbon/user)
	if(user.l_hand || user.r_hand)
		to_chat(user, span_warning("You may not hold items while blood crawling!"))
		return FALSE

	var/obj/item/bloodcrawl/left_hand = new(user)
	var/obj/item/bloodcrawl/right_hand = new(user)
	left_hand.icon_state = "bloodhand_left"
	right_hand.icon_state = "bloodhand_right"
	user.put_in_l_hand(left_hand)
	user.put_in_r_hand(right_hand)
	user.regenerate_icons()
	return TRUE


/obj/effect/temp_visual/dir_setting/bloodcrawl
	icon = 'icons/mob/mob.dmi'
	icon_state = "blank" // Flicks are used instead
	duration = 0.6 SECONDS
	layer = MOB_LAYER + 0.1


/obj/effect/temp_visual/dir_setting/bloodcrawl/Initialize(mapload, set_dir, animation_state)
	. = ..()
	flick(animation_state, src) // Setting the icon_state to the animation has timing issues and can cause frame skips


/obj/effect/proc_holder/spell/bloodcrawl/proc/sink_animation(atom/enter_point, mob/living/user)
	var/turf/mob_loc = get_turf(user)
	visible_message(span_danger("[user] sinks into [enter_point]."))
	playsound(mob_loc, 'sound/misc/enter_blood.ogg', 100, TRUE, -1)
	new /obj/effect/temp_visual/dir_setting/bloodcrawl(mob_loc, user.dir, "jaunt")


/obj/effect/proc_holder/spell/bloodcrawl/proc/handle_consumption(mob/living/user, mob/living/victim, atom/enter_point, obj/effect/dummy/slaughter/holder)
	if(!HAS_TRAIT(user, TRAIT_BLOODCRAWL_EAT))
		return

	if(!istype(victim))
		return

	if(victim.stat == CONSCIOUS)
		enter_point.visible_message(span_warning("[victim] kicks free of [enter_point] just before entering it!"))
		user.stop_pulling()
		return

	victim.emote("scream")
	victim.forceMove(holder)
	enter_point.visible_message(span_warning("<b>[user] drags [victim] into [enter_point]!</b>"))
	to_chat(user, "<b>You begin to feast on [victim]. You can not move while you are doing this.</b>")
	enter_point.visible_message(span_warning("<B>Loud eating sounds come from the blood...</b>"))
	var/sound
	if(isslaughterdemon(user))
		var/mob/living/simple_animal/demon/slaughter/demon = user
		sound = demon.feast_sound
	else
		sound = 'sound/misc/demon_consume.ogg'

	for(var/i in 1 to 3)
		playsound(get_turf(user), sound, 100, TRUE)
		sleep(3 SECONDS)

	if(!victim)
		to_chat(user, span_danger("You happily devour... nothing? Your meal vanished at some point!"))
		return

	if(ishuman(victim) || isrobot(victim))
		to_chat(user, span_warning("You devour [victim]. Your health is fully restored."))
		user.heal_damages(brute = 1000, burn = 1000, tox = 1000, oxy = 1000)
	else
		to_chat(user, span_warning("You devour [victim], but this measly meal barely sates your appetite!"))
		user.heal_damages(brute = 25, burn = 25)

	if(isslaughterdemon(user))
		var/mob/living/simple_animal/demon/slaughter/demon = user
		demon.devoured++
		to_chat(victim, span_userdanger("You feel teeth sink into your flesh, and the--"))
		var/obj/item/organ/internal/regenerative_core/legion/core = victim.get_int_organ(/obj/item/organ/internal/regenerative_core/legion)
		if(core)
			core.remove(victim)
			qdel(core)
		victim.adjustBruteLoss(1000)
		victim.forceMove(demon)
		demon.consumed_mobs.Add(victim)
		//ADD_TRAIT(victim, TRAIT_UNREVIVABLE, "demon")
		if(ishuman(victim))
			var/mob/living/carbon/human/h_victim = victim
			if(h_victim.w_uniform && istype(h_victim.w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/uniform = h_victim.w_uniform
				uniform.sensor_mode = SENSOR_OFF
	else
		victim.ghostize()
		qdel(victim)


/obj/effect/proc_holder/spell/bloodcrawl/proc/post_phase_in(mob/living/user, obj/effect/dummy/slaughter/holder)
	REMOVE_TRAIT(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))


/obj/effect/proc_holder/spell/bloodcrawl/proc/phaseout(obj/effect/decal/cleanable/enter_point, mob/living/carbon/user)

	if(istype(user) && !block_hands(user))
		return FALSE

	ADD_TRAIT(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
	INVOKE_ASYNC(src, PROC_REF(async_phase), enter_point, user)
	return TRUE


/obj/effect/proc_holder/spell/bloodcrawl/proc/async_phase(obj/effect/decal/cleanable/enter_point, mob/living/user)
	var/turf/mobloc = get_turf(user)
	sink_animation(enter_point, user)
	var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(mobloc)
	var/victim = user.pulling
	user.forceMove(holder)
	user.ExtinguishMob()
	handle_consumption(user, victim, enter_point, holder)
	post_phase_in(user, holder)


/obj/effect/proc_holder/spell/bloodcrawl/proc/rise_animation(turf/tele_loc, mob/living/user, atom/exit_point)
	new /obj/effect/temp_visual/dir_setting/bloodcrawl(tele_loc, user.dir, "jauntup")
	if(prob(25) && isdemon(user))
		var/list/voice = list('sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/i_see_you1.ogg')
		playsound(tele_loc, pick(voice), 50, TRUE, -1)
	exit_point.visible_message(span_warning("<b>[user] rises out of [exit_point]!</b>"))
	playsound(get_turf(tele_loc), 'sound/misc/exit_blood.ogg', 100, TRUE, -1)


/obj/effect/proc_holder/spell/bloodcrawl/proc/unblock_hands(mob/living/carbon/user)
	if(!istype(user))
		return
	for(var/obj/item/bloodcrawl/item in user)
		qdel(item)


/obj/effect/proc_holder/spell/bloodcrawl/proc/rise_message(atom/exit_point)
	exit_point.visible_message(span_warning("[exit_point] starts to bubble..."))


/obj/effect/proc_holder/spell/bloodcrawl/proc/post_phase_out(atom/exit_point, mob/living/user)
	if(isslaughterdemon(user))
		user.add_movespeed_modifier(/datum/movespeed_modifier/slaughter_boost)
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/slaughter_boost), 6 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	user.color = exit_point.color
	addtimer(VARSET_CALLBACK(user, color, null), 6 SECONDS)


/obj/effect/proc_holder/spell/bloodcrawl/proc/phasein(atom/enter_point, mob/living/user)
	if(HAS_TRAIT_NOT_FROM(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src)))
		return FALSE
	if(HAS_TRAIT_FROM(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src)))
		to_chat(user, span_warning("Finish eating first!"))
		return FALSE
	rise_message(enter_point)
	if(!do_after(user, 2 SECONDS, enter_point))
		return FALSE
	if(!enter_point)
		return FALSE
	var/turf/tele_loc = isturf(enter_point) ? enter_point : enter_point.loc
	var/holder = user.loc
	user.forceMove(tele_loc)
	user.client.eye = user

	rise_animation(tele_loc, user, enter_point)

	unblock_hands(user)

	QDEL_NULL(holder)

	post_phase_out(enter_point, user)
	return TRUE


/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl
	name = "Shadow Crawl"
	desc = "Use darkness to phase out of existence."
	action_background_icon_state = "shadow_demon_bg"
	action_icon_state = "shadow_crawl"
	allowed_type = /turf


/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/valid_target(turf/target, user)
	return target.get_lumcount() < 0.2


/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/rise_message(atom/exit_point)
	return


/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/rise_animation(turf/tele_loc, mob/living/user, atom/exit_point)
	new /obj/effect/temp_visual/dir_setting/bloodcrawl(get_turf(user), user.dir, "shadowwalk_appear")


/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/handle_consumption(mob/living/L, mob/living/victim, atom/enter_point, obj/effect/dummy/slaughter/holder)
	return


/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/sink_animation(atom/enter_point, mob/living/user)
	enter_point.visible_message(span_danger("[user] sinks into the shadows..."))
	new /obj/effect/temp_visual/dir_setting/bloodcrawl(get_turf(user), user.dir, "shadowwalk_disappear")


/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/post_phase_in(mob/living/user, obj/effect/dummy/slaughter/holder)
	..()
	if(!istype(user, /mob/living/simple_animal/demon/shadow))
		return
	var/mob/living/simple_animal/demon/shadow/demon = user
	demon.RegisterSignal(holder, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/living/simple_animal/demon/shadow, check_darkness))

