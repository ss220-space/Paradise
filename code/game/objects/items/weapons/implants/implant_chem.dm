/obj/item/implant/chem
	name = "chem bio-chip"
	desc = "Injects things."
	icon_state = "reagents_old"
	implant_state = "implant-nanotrasen"
	origin_tech = "materials=3;biotech=4"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	container_type = OPENCONTAINER
	trigger_causes = BIOCHIP_TRIGGER_DEATH_ANY
	implant_data = /datum/implant_fluff/chem


/obj/item/implant/chem/Initialize(mapload)
	. = ..()
	create_reagents(50)
	GLOB.tracked_implants += src


/obj/item/implant/chem/Destroy()
	GLOB.tracked_implants -= src
	return ..()


/obj/item/implant/chem/death_trigger(mob/victim, gibbed)
	activate(reagents.total_volume)


/obj/item/implant/chem/activate(cause)
	if(!cause || !imp_in)
		return FALSE
	var/mob/living/carbon/carrier = imp_in
	var/injectamount

	var/list/implant_chems = list()
	for(var/datum/reagent/chems in reagents.reagent_list)
		implant_chems += chems.name
	var/contained_chemicals = english_list(implant_chems)

	if(cause == "action_button")
		injectamount = reagents.total_volume
	else
		injectamount = cause

	reagents.trans_to(carrier, injectamount)
	add_attack_logs(usr, carrier, "Chem bio-chip activated injecting [injectamount]u of [contained_chemicals]")

	if(!reagents.total_volume)
		to_chat(carrier, span_italics("You hear a faint click from your chest."))
		qdel(src)
	else
		to_chat(carrier, span_italics("You hear a faint beep."))


/obj/item/implanter/chem
	name = "bio-chip implanter (chem)"
	imp = /obj/item/implant/chem


/obj/item/implantcase/chem
	name = "bio-chip case - 'Remote Chemical'"
	desc = "A glass case containing a remote chemical bio-chip."
	imp = /obj/item/implant/chem

