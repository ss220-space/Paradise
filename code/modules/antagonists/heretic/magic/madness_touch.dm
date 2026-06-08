// Currently unused
/obj/effect/proc_holder/spell/touch/mad_touch
	name = "Прикосновение безумия"
	desc = "Заклинание, которое лишает врага рассудка и сбивает с ног."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mad_touch"

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 15 SECONDS
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND


/obj/effect/proc_holder/spell/touch/mad_touch/valid_target(atom/cast_on)
	if(!ishuman(cast_on))
		return FALSE

	var/mob/living/carbon/human/human_cast_on = cast_on
	if(!human_cast_on.mind || IS_HERETIC_OR_MONSTER(human_cast_on))
		return FALSE

	return TRUE

/*
/obj/effect/proc_holder/spell/touch/mad_touch/on_antimagic_triggered(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("The spell bounces off of [victim]!"),
		span_danger("The spell bounces off of you!"),
	)
*/

/*
/obj/effect/proc_holder/spell/touch/mad_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/victim, mob/living/carbon/caster)
	to_chat(caster, span_warning("[victim.name] has been cursed!"))
	return TRUE
*/
