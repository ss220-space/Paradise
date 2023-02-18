/obj/machinery/ninja_bloodscan_machine
	anchored = TRUE
	density = TRUE
	name = "Blood-Scan Machine"
	desc = "A very complex machine designed to scan blood samples on the smallest level. Created by the Spider-Clan to scan the blood of the most otherworldly beasts and creatures."
	tts_seed = "Sorceress"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "BSM_0"
	pixel_x = 4
	pixel_y = 10
	/// Нельзя чтобы такая дорогая технология была сломана игроком по фану
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | NO_MALF_EFFECT
	var/list/blood_samples = list()
	var/list/vials = list()
	var/mob/living/carbon/human/ninja
	// Our "collect blood" objective
	var/datum/objective/collect_blood/objective
	// Blocks TGUI buttons
	var/blocked = FALSE

/obj/machinery/ninja_bloodscan_machine/Initialize()
	. = ..()

/obj/machinery/ninja_bloodscan_machine/Destroy()
	//Выкидываем колбочки и обнуляем
	objective = null
	ninja = null
	if(vials)
		for(var/obj/item/reagent_containers/glass/beaker/vial/vial in vials)
			vial.forceMove(get_turf(src))
		vials = null
	if(blood_samples)
		blood_samples = null
	. = ..()

/obj/machinery/ninja_bloodscan_machine/attack_hand(mob/user)
	if(..(user))
		return
	if(!isninja(user))
		to_chat(user, span_boldwarning("ERROR!!! UNAUTORISED USER!!!"))
		return
	if(!objective || user != ninja)
		var/temp_objective = locate(/datum/objective/collect_blood) in user.mind.objectives
		if(!temp_objective)
			to_chat(user, span_boldwarning("Your clan does not need you to collect and scan any samples right now."))
			return
		objective = temp_objective
		ninja = user
		to_chat(user, span_boldwarning("User: [user] registered. Ready to scan."))
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/ninja_bloodscan_machine/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!isninja(user))
		to_chat(user, span_boldwarning("ERROR!!! UNAUTORISED USER!!!"))
		return
	if(!objective || user != ninja)
		to_chat(user, span_boldwarning("The machine won't accept any samples without a registered user. Please touch the machine's hand-scan terminal, to proceed forward."))
		return
	if(istype(I, /obj/item/reagent_containers/glass/beaker))
		if(!istype(I, /obj/item/reagent_containers/glass/beaker/vial))
			to_chat(user, span_boldwarning("This machine only accept's small vial's. Beaker's won't fit."))
			return
		var/obj/item/reagent_containers/glass/beaker/vial/blood_vial = I
		if(!length(blood_vial.reagents.reagent_list))
			to_chat(user, span_info("Vial is empty..."))
			return
		var/datum/reagent/blood/blood_sample = locate(/datum/reagent/blood) in blood_vial.reagents.reagent_list
		if(!istype(blood_sample) || length(blood_vial.reagents.reagent_list) > 1)
			to_chat(user, span_boldwarning("The machine won't accept any other reagent than the one prescribed by the clan. Which in your case is [span_redtext("BLOOD")]!"))
			return
		user.drop_item()
		blood_vial.forceMove(src)
		vials += blood_vial
		blood_samples += blood_sample
		update_state_icon()
		to_chat(user, span_info("You place [blood_vial] in the machine."))
		return

/obj/machinery/ninja_bloodscan_machine/proc/update_state_icon()
	if(!blood_samples || !vials)
		icon_state = initial(icon_state)
		return
	icon_state = "BSM_[clamp(length(blood_samples), 0, 3)]"


/obj/machinery/ninja_bloodscan_machine/proc/scan_samples()


/obj/machinery/ninja_bloodscan_machine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "NinjaBloodScan", name, 500, 400, master_ui, state)
		ui.open()

/obj/machinery/ninja_bloodscan_machine/ui_data(mob/user)
	var/list/data = list()
	//Иконки виалов
	var/list/vial_icons = list()
	for(var/obj/item/reagent_containers/glass/beaker/vial/blood_vial in vials)
		var/icon/vial_icon = getFlatIcon(blood_vial, no_anim = TRUE)
		vial_icons += icon2base64(vial_icon)
	var/icon/no_vial_icon = icon('icons/obj/chemical.dmi', "vial", SOUTH, frame = 1)
	data["vialIcons"] = vial_icons
	data["noVialIcon"] = icon2base64(no_vial_icon)
	//Имена обладателей крови
	var/list/blood_owner_names = list()
	var/list/blood_owner_species = list()
	var/list/blood_owner_types = list()
	if(blood_samples)
		for(var/datum/reagent/blood/sample_blood in blood_samples)
			blood_owner_names += sample_blood.data["real_name"]
			blood_owner_species += sample_blood.data["blood_species"]
			blood_owner_types += sample_blood.data["blood_type"]
	data["bloodOwnerNames"] = blood_owner_names
	data["bloodOwnerSpecies"] = blood_owner_species
	data["bloodOwnerTypes"] = blood_owner_types
	data["blockButtons"] = blocked
	return data

/obj/machinery/ninja_bloodscan_machine/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("vial_out")
			log_debug("vial_out")
			return
		if("scan_blood")
			log_debug("scan_blood")
			return

