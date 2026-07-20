
/obj/effect/proc_holder/spell/pointed/packet_loss
	name = "Потеря Пакета"
	desc = "Повреждает соединение выбранного противника на восемь секунд. \
			Следующее его осознанное действие не дойдёт до мира и оставит после себя Runtime Error. \
			Если за это время цель ничего не предпримет, эффект спадёт без последствий."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "packet_loss"

	sound = 'sound/machines/deniedbeep.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "П'К'Т П'Т'Р'Н!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 7
	active_msg = "Вы нащупываете соединение цели..."


/obj/effect/proc_holder/spell/pointed/packet_loss/valid_target(atom/cast_on, mob/user)
	if(!isliving(cast_on) || cast_on == user)
		return FALSE
	var/mob/living/living_target = cast_on
	return !IS_HERETIC_OR_MONSTER(living_target)


/obj/effect/proc_holder/spell/pointed/packet_loss/cast(list/targets, mob/user = usr)
	var/mob/living/caster = action?.owner
	var/mob/living/cast_on = targets[1]
	if(!caster || !isliving(cast_on))
		return FALSE

	if(cast_on.can_block_magic(MAGIC_RESISTANCE))
		to_chat(caster, span_warning("Соединение [cast_on.declent_ru(GENITIVE)] защищено!"))
		return FALSE

	cast_on.apply_status_effect(/datum/status_effect/packet_loss, caster)
	return TRUE
