/obj/effect/proc_holder/spell/caretaker
	name = "Последнее пристанище смотрителя"
	desc = "Переносит вас в Убежище Смотрителя, делая вас прозрачным и неосязаемым. \
			Находясь в Убежище, вы защищены почти от всех угроз, но не можете \
			использовать руки и произносить заклинания. \
			Вы не можете войти в Убежище, находясь рядом с другими разумными существами, \
			и вас могут выкинуть из него различными антимагическими предметами."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "caretaker"
	sound = 'sound/effects/curse/curse2.ogg'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 1 MINUTES

	spell_requirements = NONE


/obj/effect/proc_holder/spell/caretaker/on_spell_loss(mob/living/remove_from)
	if(!remove_from.has_status_effect(/datum/status_effect/caretaker_refuge))
		return ..()

	remove_from.remove_status_effect(/datum/status_effect/caretaker_refuge)


/obj/effect/proc_holder/spell/caretaker/valid_target(atom/cast_on)
	return isliving(cast_on)


/obj/effect/proc_holder/spell/caretaker/before_cast(list/targets)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	for(var/mob/living/alive in orange(5, action.owner))
		if(alive.stat == DEAD || !alive.client)
			continue

		action.owner.balloon_alert(action.owner, "рядом разумное существо!")
		return . | SPELL_CANCEL_CAST

	if(!action.owner.has_status_effect(/datum/status_effect/caretaker_refuge))
		return SPELL_NO_IMMEDIATE_COOLDOWN // cooldown only on exit


/obj/effect/proc_holder/spell/caretaker/cast(list/targets)
	. = ..()

	var/mob/living/carbon/carbon_user = action.owner
	if(carbon_user.has_status_effect(/datum/status_effect/caretaker_refuge))
		carbon_user.remove_status_effect(/datum/status_effect/caretaker_refuge)
	else
		carbon_user.apply_status_effect(/datum/status_effect/caretaker_refuge)

	return TRUE
