/datum/action/cooldown/spell/pointed/apetra_vulnera
	name = "Усугубление"
	desc = "Ломает части тела, имеющие 15 единиц физических повреждений и выше. Если таковых нет, \
			ломает случайную часть тела."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "apetra_vulnera"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "С'Г'БЛ'Н!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 4


/datum/action/cooldown/spell/pointed/apetra_vulnera/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)


/datum/action/cooldown/spell/pointed/apetra_vulnera/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(IS_HERETIC_OR_MONSTER(cast_on))
		return FALSE

	if(!cast_on.blood_volume)
		return FALSE

	if(cast_on.can_block_magic(antimagic_flags))
		cast_on.visible_message(
			span_danger("Повреждения [cast_on.declent_ru(GENITIVE)] слегка мерцают!"),
			span_danger("Ваши раны немного покалывает, но вы защищены!")
		)
		return FALSE

	var/a_limb_got_damaged = FALSE
	for(var/obj/item/organ/external/bodypart in cast_on.bodyparts)
		if(bodypart.brute_dam < 15)
			continue

		a_limb_got_damaged = TRUE
		bodypart.fracture()


	if(!a_limb_got_damaged)
		var/obj/item/organ/external/bodypart = pick(cast_on.bodyparts)
		bodypart.fracture()


	cast_on.visible_message(
		span_danger("Царапины и синяки [cast_on.declent_ru(GENITIVE)] внезапно разрываются под действием какой-то нечестивой силы!"),
		span_danger("Ваши царапины и синяки внезапно разрываются какой-то ужасной нечестивой силой!")
	)

	new /obj/effect/temp_visual/cleave(get_turf(cast_on))
	return TRUE
