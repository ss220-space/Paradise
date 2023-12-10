// Dust implant, for CC officers. Prevents gear theft if they die.

/obj/item/implant/dust
	name = "duster bio-chip"
	desc = "A remote controlled bio-chip that will dust the user upon activation (or death of user)."
	icon = 'icons/obj/implants.dmi'
	icon_state = "dust"
	implant_state = "implant-nanotrasen"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	actions_types = list(/datum/action/item_action/hands_free/activate/always)
	trigger_causes = BIOCHIP_TRIGGER_DEATH_ONCE|BIOCHIP_TRIGGER_NOT_WHEN_GIBBED
	implant_data = /datum/implant_fluff/dust


/obj/item/implant/dust/death_trigger(mob/source, force)
	activate("death")


/obj/item/implant/dust/activate(cause)
	if(!cause || !imp_in || cause == "emp")
		return FALSE
	if(cause == "action_button" && alert(imp_in, "Are you sure you want to activate your dusting bio-chip? This will turn you to ash!", "Dusting Confirmation", "Yes", "No") != "Yes")
		return FALSE
	to_chat(imp_in, span_notice("Your dusting bio-chip activates!"))
	imp_in.visible_message(span_warning("[imp_in] burns up in a flash!"))
	imp_in.dust()


/obj/item/implant/dust/emp_act(severity)
	return


/obj/item/implanter/dust
	name = "bio-chip implanter (Dust-on-death)"
	imp = /obj/item/implant/dust


/obj/item/implantcase/dust
	name = "bio-chip case - 'Dust'"
	desc = "A glass case containing a dust bio-chip."
	imp = /obj/item/implant/dust

