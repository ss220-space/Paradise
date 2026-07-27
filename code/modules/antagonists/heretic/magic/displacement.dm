
/obj/effect/proc_holder/spell/pointed/displacement
	name = "Смещение"
	desc = "Вырывает выбранного противника из пространства на восемь секунд. \
			Следующее его осознанное действие уйдёт в изнанку и оставит после себя Разлом. \
			Если за это время цель ничего не предпримет, эффект спадёт без последствий."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "displacement"

	sound = 'sound/effects/phasein.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "СМ'Щ'Н'!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	active_msg = "Вы нащупываете нить, которой цель держится за мир..."


/obj/effect/proc_holder/spell/pointed/displacement/valid_target(atom/cast_on, mob/user)
	if(!isliving(cast_on) || cast_on == user)
		return FALSE
	var/mob/living/living_target = cast_on
	return !IS_HERETIC_OR_MONSTER(living_target)


/obj/effect/proc_holder/spell/pointed/displacement/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action?.owner
	var/mob/living/cast_on = targets[1]
	if(!caster || !isliving(cast_on))
		return FALSE

	if(cast_on.can_block_magic(MAGIC_RESISTANCE))
		to_chat(caster, span_warning("Связь [cast_on.declent_ru(GENITIVE)] с миром защищена!"))
		return FALSE

	cast_on.apply_status_effect(/datum/status_effect/displacement, caster)
	return TRUE
