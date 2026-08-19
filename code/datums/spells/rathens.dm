/obj/effect/proc_holder/spell/rathens
	name = "Rathen's Secret"
	desc = "Summons a powerful shockwave around you that tears the appendix out of enemies, and occasionally removes their limbs."
	base_cooldown = 50 SECONDS
	cooldown_min = 20 SECONDS
	invocation = "APPEN NATH!"
	invocation_type = "shout"
	action_icon_state = "lungpunch"

/obj/effect/proc_holder/spell/rathens/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.max_targets = INFINITY
	return T

/obj/effect/proc_holder/spell/rathens/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/human in targets)
		var/datum/effect_system/fluid_spread/smoke/smoke = new
		smoke.set_up(amount = 5, location = human)
		smoke.start()
		var/obj/item/organ/internal/appendix/appendix = human.get_int_organ(/obj/item/organ/internal/appendix)
		if(appendix)
			appendix.remove(human)
			appendix.forceMove(get_turf(human))
			spawn()
				appendix.throw_at(get_edge_target_turf(human, pick(GLOB.alldirs)), rand(1, 10), 5)
			human.visible_message(
				span_danger("[human]'s [appendix.name] flies out of their body in a magical explosion!"),\
				span_danger("Your [appendix.name] flies out of your body in a magical explosion!")
			)
			human.Weaken(4 SECONDS)
		else
			var/obj/effect/decal/cleanable/blood/gibs/gibs = new/obj/effect/decal/cleanable/blood/gibs(get_turf(human))
			spawn()
				gibs.throw_at(get_edge_target_turf(human, pick(GLOB.alldirs)), rand(1, 10), 5)
			human.apply_damage(10, BRUTE, BODY_ZONE_CHEST)
			to_chat(human, span_userdanger("You have no appendix, but something had to give! Holy shit, what was that?"))
			human.Weaken(6 SECONDS)
			for(var/obj/item/organ/external/external as anything in human.bodyparts)
				if(ishead(external) || ischest(external) || isgroin(external))
					continue
				if(prob(7))
					to_chat(human, span_userdanger("Your [external] was severed by the explosion!"))
					external.droplimb(1, DROPLIMB_SHARP, 0, 1)
