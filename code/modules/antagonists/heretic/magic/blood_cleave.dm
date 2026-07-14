/obj/effect/proc_holder/spell/pointed/cleave
	name = "Кровавое Рассечение" // Crimson Cleave
	desc = "Направленное заклинание: вытягивает здоровье и кровь у жертв в небольшом радиусе вокруг цели, \
			исцеляя вас. При применении очищает все ваши раны."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "Р'СЧЛ'Н'Н!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 5

	/// The radius of the cleave effect
	var/cleave_radius = 1


/obj/effect/proc_holder/spell/pointed/cleave/valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)


/obj/effect/proc_holder/spell/pointed/cleave/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/cast_on = targets[1]
	. = ..()
	var/mob/living/caster = action?.owner || user
	if(isliving(caster))
		caster.adjustBruteLoss(-20)
		caster.adjustFireLoss(-20)
	for(var/mob/living/carbon/human/victim in range(cleave_radius, cast_on))
		if(victim == caster || IS_HERETIC_OR_MONSTER(victim))
			continue
		if(victim.can_block_magic(antimagic_flags))
			victim.visible_message(
				span_danger("[DECLENT_RU_CAP(victim, NOMINATIVE)] слегка мерцает!"),
				span_danger("Ваше тело начинает светиться огненным свечением, но затем постепенно затухает!")
			)
			continue

		if(!victim.blood_volume)
			continue

		victim.visible_message(
			span_danger("[DECLENT_RU_CAP(victim, NOMINATIVE)] покрывается множеством мелких порезов, кровь хлещет наружу!"),
			span_danger("Ваши вены лопаются изнутри, и нечестивое пламя вырывается из вашей крови!")
		)

		victim.apply_damage(15, BRUTE)
		if(isliving(caster))
			caster.adjustBruteLoss(-15)
			victim.transfer_blood_to(caster, 15, forced = TRUE, ignore_incompatibility = TRUE)

		new /obj/effect/temp_visual/cleave(get_turf(victim))

	return TRUE


/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6
