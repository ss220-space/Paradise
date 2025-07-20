/obj/effect/proc_holder/spell/caretaker
	name = "Caretaker’s Last Refuge"
	desc = "Shifts you into the Caretaker's Refuge, rendering you translucent and intangible. \
		While in the Refuge your movement is unrestricted, but you cannot use your hands or cast any spells. \
		You cannot enter the Refuge while near other sentient beings, \
		and you can be removed from it upon contact with antimagical artifacts."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "caretaker"
	sound = 'sound/effects/curse/curse2.ogg'

	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	base_cooldown = 1 MINUTES

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

/obj/effect/proc_holder/spell/caretaker/on_spell_loss(mob/living/remove_from)
	if(remove_from.has_status_effect(/datum/status_effect/caretaker_refuge))
		remove_from.remove_status_effect(/datum/status_effect/caretaker_refuge)
	return ..()

/obj/effect/proc_holder/spell/caretaker/valid_target(atom/cast_on)
	return isliving(cast_on)

/obj/effect/proc_holder/spell/caretaker/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	for(var/mob/living/alive in orange(5, action.owner))
		if(alive.stat != DEAD && alive.client)
			action.owner.balloon_alert(action.owner, "other minds nearby!")
			return . | SPELL_CANCEL_CAST

	if(!cast_on.has_status_effect(/datum/status_effect/caretaker_refuge))
		return SPELL_NO_IMMEDIATE_COOLDOWN // cooldown only on exit

/obj/effect/proc_holder/spell/caretaker/cast(mob/living/cast_on)
	. = ..()

	var/mob/living/carbon/carbon_user = action.owner
	if(carbon_user.has_status_effect(/datum/status_effect/caretaker_refuge))
		carbon_user.remove_status_effect(/datum/status_effect/caretaker_refuge)
	else
		carbon_user.apply_status_effect(/datum/status_effect/caretaker_refuge)
	return TRUE
