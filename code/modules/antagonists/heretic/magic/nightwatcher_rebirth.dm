/datum/action/cooldown/spell/aoe/fiery_rebirth
	name = "Возрождение Ночного Дозорного"
	desc = "Заклинание, которое тушит вас и высасывает жизненную силу из язычников, охваченных огнём, \
			исцеляя вас за каждую жертву. Те, кто находится в критическом состоянии, \
			потеряют последние жизненные силы, что приведёт к их смерти."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "smoke"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation = "СЛ'В Н'ЧН'М Д'З'РН'М"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_HUMAN
	sound = 'sound/magic/fireball.ogg'
	aoe_radius = 14
	/// Tracks how many victims the spell drained this cast, used to lower the cooldown per victim.
	var/victims_counter = 0


/datum/action/cooldown/spell/aoe/fiery_rebirth/get_things_to_cast_on(atom/center)
	victims_counter = 0
	var/list/things = list()
	for(var/mob/living/carbon/nearby_mob in range(aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue

		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue

		if(nearby_mob.stat == DEAD || !nearby_mob.on_fire)
			continue

		things += nearby_mob
		victims_counter++

	return things


/datum/action/cooldown/spell/aoe/fiery_rebirth/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/caster = owner
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


/datum/action/cooldown/spell/aoe/fiery_rebirth/after_cast(atom/cast_on)
	. = ..()
	if(!victims_counter)
		StartCooldown(cooldown_time)
		return
	StartCooldown(max(9 SECONDS, cooldown_time - victims_counter * 10 SECONDS))


/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "smoke"
