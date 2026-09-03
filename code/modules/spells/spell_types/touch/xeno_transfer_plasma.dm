/datum/action/cooldown/spell/touch/transfer_plasma
	name = "Transfer Plasma"
	desc = "Transfers plasma to a nearby alien"
	hand_path = /obj/item/melee/touch_attack/transfer_plasma
	button_icon_state = "alien_transfer"
	background_icon_state = "bg_alien"
	active_background_icon_state = "bg_alien"
	background_icon_state_active = "bg_alien"
	invocation_type = INVOCATION_NONE
	invocation = ""
	draw_message = span_noticealien_alt("You vomit some plasma in your hand and prepare to transfer it.")
	drop_message = span_noticealien_alt("You decide not to use plasma for now...")
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	var/plasma_amount

/datum/action/cooldown/spell/touch/transfer_plasma/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src)
	return handler

/datum/action/cooldown/spell/touch/transfer_plasma/PreActivate(atom/target)
	plasma_amount = tgui_input_number(usr, "Amount:", "How much plasma to transfer?")
	if(!plasma_amount)
		return
	var/mob/living/carbon/user = owner
	if(user.get_plasma() < plasma_amount)
		to_chat(owner, span_warning("You don't have that much plasma!"))
		return
	plasma_amount = abs(round(plasma_amount))
	user.adjust_alien_plasma(-plasma_amount)
	return ..()

/datum/action/cooldown/spell/touch/transfer_plasma/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/mob/living/carbon/transfering_to = victim
	transfering_to.adjust_alien_plasma(plasma_amount)
	to_chat(caster, span_noticealien("You have transfered [plasma_amount] plasma to [transfering_to]."))
	to_chat(transfering_to, span_noticealien("[caster] has transfered [plasma_amount] plasma to you!"))
	plasma_amount = 0
	return TRUE

/datum/action/cooldown/spell/touch/transfer_plasma/on_hand_dropped(datum/source, mob/living/dropper)
	. = ..()
	var/mob/living/carbon/user = dropper
	user.adjust_alien_plasma(plasma_amount)
	plasma_amount = 0

/obj/item/melee/touch_attack/transfer_plasma
	name = "plasma transfer"
	desc = "Transfers plasma to another alien."
	icon_state = "alien_transfer"

/obj/item/melee/touch_attack/alien/transfer_plasma/New()
	. = ..()
	var/datum/action/cooldown/spell/touch/transfer_plasma/transfer_spell = spell_which_made_us.resolve()
	name = "[name] ([(transfer_spell.plasma_amount)])"
	update_appearance(UPDATE_NAME)
