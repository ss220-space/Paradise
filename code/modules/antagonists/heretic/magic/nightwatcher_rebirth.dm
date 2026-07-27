/obj/effect/proc_holder/spell/aoe/fiery_rebirth
	name = "Возрождение Ночного Дозорного"
	desc = "Заклинание, которое тушит вас и высасывает жизненную силу из язычников, охваченных огнём, \
			исцеляя вас за каждую жертву. Те, кто находится в критическом состоянии, \
			потеряют последние жизненные силы, что приведёт к их смерти."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "smoke"

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 1 MINUTES

	invocation = "СЛ'В Н'ЧН'М Д'З'РН'М"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_HUMAN
	sound = 'sound/magic/fireball.ogg'
	aoe_range = 14
	/// Tracks how many victims the spell drained this cast, used to lower the cooldown per victim.
	var/victims_counter = 0


/obj/effect/proc_holder/spell/aoe/fiery_rebirth/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/aoe/fiery_rebirth/get_things_to_cast_on(atom/center)
	victims_counter = 0
	var/list/things = list()
	for(var/mob/living/carbon/nearby_mob in range(aoe_range, center))
		if(nearby_mob == action.owner || nearby_mob == center)
			continue

		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue

		if(nearby_mob.stat == DEAD || !nearby_mob.on_fire)
			continue

		things += nearby_mob
		victims_counter++

	return things


/obj/effect/proc_holder/spell/aoe/fiery_rebirth/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/caster = user
	if(!istype(caster))
		return
	caster.ExtinguishMob()
	for(var/mob/living/carbon/victim as anything in get_things_to_cast_on(caster))
		new /obj/effect/temp_visual/eldritch_smoke(get_turf(victim))
		victim.Beam(caster, icon_state = "r_beam", time = 2 SECONDS)

		if(victim.CanSuccumb())
			victim.investigate_log("has been executed by fiery rebirth.", INVESTIGATE_DEATHS)
			victim.death()

		victim.apply_damage(20, BURN)
		victim.ExtinguishMob()

		var/need_mob_update = FALSE
		need_mob_update += caster.adjustBruteLoss(-10, updating_health = FALSE)
		need_mob_update += caster.adjustFireLoss(-10, updating_health = FALSE)
		need_mob_update += caster.adjustToxLoss(-10, updating_health = FALSE)
		need_mob_update += caster.adjustOxyLoss(-10, updating_health = FALSE)
		need_mob_update += caster.adjustStaminaLoss(-10, updating_health = FALSE)
		if(need_mob_update)
			caster.updatehealth()


/obj/effect/proc_holder/spell/aoe/fiery_rebirth/after_cast(list/targets, mob/user)
	. = ..()
	if(!victims_counter)
		cooldown_handler.start_recharge(base_cooldown)
		return
	cooldown_handler.start_recharge(max(9 SECONDS, base_cooldown - victims_counter * 10 SECONDS))


/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "smoke"
