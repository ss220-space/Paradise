/obj/effect/proc_holder/spell/pointed/cleave
	name = "Расчленение"
	desc = "Вызывает тошноту кровью жертв в небольшом радиусе от выбранной точки."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "cleave"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 45 SECONDS

	invocation = "Р'СЧЛ'Н'Н!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 4

	/// The radius of the cleave effect
	var/cleave_radius = 1


/obj/effect/proc_holder/spell/pointed/cleave/valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)


/obj/effect/proc_holder/spell/pointed/cleave/cast(list/targets)
	var/mob/living/carbon/human/cast_on = targets[1]
	. = ..()
	for(var/mob/living/carbon/human/victim in range(cleave_radius, cast_on))
		if(victim == action.owner || IS_HERETIC_OR_MONSTER(victim))
			continue
		if(victim.can_block_magic(antimagic_flags))
			victim.visible_message(
				span_danger("[victim.declent_ru(NOMINATIVE)] слегка мерцает!"),
				span_danger("Ваше тело начинает светиться огненным свечением, но затем постепенно затухает!")
			)
			continue

		if(!victim.blood_volume)
			continue

		victim.visible_message(
			span_danger("[victim.declent_ru(NOMINATIVE)] покрывается множеством мелких порезов!"),
			span_danger("Ваши вены лопаются изнутри, и нечестивое пламя вырывается из вашей крови!")
		)

		//var/obj/item/organ/external/bodypart = pick(victim.bodyparts)
		victim.apply_damage(20, BURN/*, wound_bonus = CANT_WOUND*/)
		victim.vomit(0, VOMIT_BLOOD)

		new /obj/effect/temp_visual/cleave(get_turf(victim))

	return TRUE


/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6
