/datum/action/cooldown/spell/aoe/rathens_secret
	name = "Rathen's Secret"
	desc = "Summons a powerful shockwave around you that tears the appendix out of enemies, and occasionally removes their limbs."
	cooldown_time = 50 SECONDS
	cooldown_reduction_per_rank = 7.5 SECONDS
	invocation = "APPEN NATH!"
	invocation_type = INVOCATION_SHOUT
	button_icon_state = "lungpunch"
	aoe_radius = 10
	max_targets = INFINITY
	targeting_type = /datum/aoe_targeting/human

/datum/action/cooldown/spell/aoe/rathens_secret/cast(atom/cast_on)
	. = ..()
	new /obj/effect/warp_effect/rathens(cast_on.loc)

/datum/action/cooldown/spell/aoe/rathens_secret/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/carbon/human/target = victim
	var/datum/effect_system/fluid_spread/smoke/s = new
	s.set_up(amount = 5, location = target)
	s.start()
	var/obj/item/organ/internal/appendix/A = target.get_int_organ(/obj/item/organ/internal/appendix)
	if(A)
		A.remove(target)
		A.forceMove(get_turf(target))
		spawn()
			A.throw_at(get_edge_target_turf(target, pick(GLOB.alldirs)), rand(1, 10), 5)
		target.visible_message(
			span_danger("[target]'s [A.name] flies out of their body in a magical explosion!"),\
			span_danger("Your [A.name] flies out of your body in a magical explosion!")
		)
		target.Weaken(4 SECONDS)
	else
		var/obj/effect/decal/cleanable/blood/gibs/G = new/obj/effect/decal/cleanable/blood/gibs(get_turf(target))
		spawn()
			G.throw_at(get_edge_target_turf(target, pick(GLOB.alldirs)), rand(1, 10), 5)
		target.apply_damage(10, BRUTE, BODY_ZONE_CHEST)
		to_chat(target, span_userdanger("You have no appendix, but something had to give! Holy shit, what was that?"))
		target.Weaken(6 SECONDS)
		for(var/obj/item/organ/external/E as anything in target.bodyparts)
			if(istype(E, /obj/item/organ/external/head))
				continue
			if(ischest(E))
				continue
			if(isgroin(E))
				continue
			if(prob(7))
				to_chat(target, span_userdanger("Your [E] was severed by the explosion!"))
				E.droplimb(1, DROPLIMB_SHARP, 0, 1)
