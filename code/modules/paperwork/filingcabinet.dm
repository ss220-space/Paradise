/* Filing cabinets!
 * Contains:
 * Filing Cabinets
 * Security Record Cabinets
 * Medical Record Cabinets
 * Employment Contract Cabinets
 */


/*
 * Filing Cabinets
 */
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "filing_cabinet"
	density = TRUE
	anchored = TRUE

/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chest_drawer"

/obj/structure/filingcabinet/chestdrawer/wheeled
	name = "rolling chest drawer"
	desc = "A small cabinet with drawers. This one has wheels!"
	anchored = FALSE

/obj/structure/filingcabinet/chestdrawer/autopsy
	name = "autopsy reports drawer"
	desc = "A large drawer for holding autopsy reports."

/obj/structure/filingcabinet/white
	icon_state = "tall_cabinet"

/obj/structure/filingcabinet/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/obj/item/I in loc)
			if(I.w_class < WEIGHT_CLASS_NORMAL) //there probably shouldn't be anything placed ontop of filing cabinets in a map that isn't meant to go in them
				I.forceMove(src)

/obj/structure/filingcabinet/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(loc, 2)
	for(var/obj/item/obj in src)
		obj.forceMove(loc)
	return ..()

/obj/structure/filingcabinet/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.w_class < WEIGHT_CLASS_NORMAL)
		if(!user.drop_transfer_item_to_loc(tool, src))
			return ITEM_INTERACT_BLOCKING
		to_chat(user, span_notice("You put [tool] in [src]."))
		icon_state = "[initial(icon_state)]_open"
		sleep(0.5 SECONDS)
		icon_state = initial(icon_state)
		return ITEM_INTERACT_SUCCESS
	if(!(user.a_intent == INTENT_HARM) || (tool.item_flags & NOBLUDGEON))
		to_chat(user, span_warning("You can't put [tool] in [src]!"))
		return ITEM_INTERACT_BLOCKING
	return NONE

/obj/structure/filingcabinet/wrench_act_secondary(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("You begin to [anchored ? "unwrench" : "wrench"] [src]."))
	if(!tool.use_tool(src, user, 20, volume = 50))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You successfully [anchored ? "unwrench" : "wrench"] [src]."))
	set_anchored(!anchored)
	return ITEM_INTERACT_SUCCESS

/obj/structure/filingcabinet/attack_hand(mob/living/carbon/user, list/modifiers)
	. = ..()
	ui_interact(user)

/obj/structure/filingcabinet/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FilingCabinet")
		ui.open()

/obj/structure/filingcabinet/ui_data(mob/user)
	var/list/data = list()

	data["cabinet_name"] = "[name]"
	data["contents"] = list()
	data["contents_ref"] = list()
	for(var/obj/item/content in contents)
		data["contents"] += "[content]"
		data["contents_ref"] += "[content?.UID()]"

	return data

/obj/structure/filingcabinet/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	if(user.incapacitated || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	switch(action)
		// Take the object out
		if("remove_object")
			var/obj/item/content = locateUID(params["ref"])
			if(istype(content) && in_range(src, user))
				user.put_in_hands(content)
				icon_state = "[initial(icon_state)]_open"
				addtimer(VARSET_CALLBACK(src, icon_state, initial(icon_state)), 0.5 SECONDS)
				return TRUE

/obj/structure/filingcabinet/attack_tk(mob/user)
	if(anchored)
		return attack_self_tk(user)
	return ..()

/obj/structure/filingcabinet/attack_self_tk(mob/user)
	. = ITEM_INTERACT_BLOCKING
	if(contents.len)
		if(prob(40 + contents.len * 5))
			var/obj/item/I = pick(contents)
			I.forceMove(loc)
			if(prob(25))
				step_rand(I)
			to_chat(user, span_notice("You pull \a [I] out of [src] at random."))
			return
	to_chat(user, span_notice("You find nothing in [src]."))

/*
 * MARK: Sec Record Cabinets
 */
/obj/structure/filingcabinet/security
	var/virgin = TRUE

/obj/structure/filingcabinet/security/proc/populate()
	if(!virgin)
		return
	for(var/datum/data/record/G in GLOB.data_core.general) // God damn we need some records refactor
		var/datum/data/record/S
		virgin = FALSE
		for(var/datum/data/record/R in GLOB.data_core.security)
			if(R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"])
				S = R
				break
		var/obj/item/paper/P = new /obj/item/paper(src)
		var/record_text = "<center>**Security Record**</center>\n"
		record_text += "Name: [G.fields["name"]] ID: [G.fields["id"]]\nSex: [G.fields["sex"]]\nAge: [G.fields["age"]]\nFingerprint: [G.fields["fingerprint"]]\nPhysical Status: [G.fields["p_stat"]]\nMental Status: [G.fields["m_stat"]]\n"
		record_text += "\n<center>**Security Data**</center>\nCriminal Status: [S.fields["criminal"]]\n\nMinor Crimes: [S.fields["mi_crim"]]\nDetails: [S.fields["mi_crim_d"]]\n\nMajor Crimes: [S.fields["ma_crim"]]\nDetails: [S.fields["ma_crim_d"]]\n\nImportant Notes:\n\t[S.fields["notes"]]\n\n<center>**Comments/Log**</center>\n"
		for(var/c in S.fields["comments"])
			record_text += "[c]\n"
		P.add_raw_text(record_text)
		P.update_appearance()
		P.name = "paper - '[G.fields["name"]]'"

/obj/structure/filingcabinet/security/attack_hand(mob/user, list/modifiers)
	populate()
	return ..()

/obj/structure/filingcabinet/security/attack_tk()
	populate()
	return ..()

/*
 * MARK: Med Record Cabinets
 */
/obj/structure/filingcabinet/medical
	///This var is so that its filled on crew interaction to be as accurate (including latejoins) as possible, true until first interact
	var/virgin = TRUE

/obj/structure/filingcabinet/medical/proc/populate()
	if(!virgin)
		return
	for(var/datum/data/record/G in GLOB.data_core.general)
		virgin = FALSE
		var/datum/data/record/M
		for(var/datum/data/record/R in GLOB.data_core.medical)
			if(R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"])
				M = R
				break
		var/obj/item/paper/P = new /obj/item/paper(src)
		var/record_text = "<center>**Medical Record**</center>\n"
		record_text += "Name: [G.fields["name"]] ID: [G.fields["id"]]\nSex: [G.fields["sex"]]\nAge: [G.fields["age"]]\nFingerprint: [G.fields["fingerprint"]]\nPhysical Status: [G.fields["p_stat"]]\nMental Status: [G.fields["m_stat"]]\n"
		record_text += "\n<center>**Medical Data**</center>\nBlood Type: [M.fields["b_type"]]\nDNA: [M.fields["b_dna"]]\n\nMinor Disabilities: [M.fields["mi_dis"]]\nDetails: [M.fields["mi_dis_d"]]\n\nMajor Disabilities: [M.fields["ma_dis"]]\nDetails: [M.fields["ma_dis_d"]]\n\nAllergies: [M.fields["alg"]]\nDetails: [M.fields["alg_d"]]\n\nCurrent Diseases: [M.fields["cdi"]] (per disease info placed in log/comment section)\nDetails: [M.fields["cdi_d"]]\n\nImportant Notes:\n\t[M.fields["notes"]]\n\n<center>**Comments/Log**</center>\n"
		for(var/c in M.fields["comments"])
			record_text += "[c]\n"
		P.add_raw_text(record_text)
		P.update_appearance()
		P.name = "paper - '[G.fields["name"]]'"

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/filingcabinet/medical/attack_hand(mob/user, list/modifiers)
	populate()
	return ..()

/obj/structure/filingcabinet/medical/attack_tk()
	populate()
	return ..()

/*
 * MARK: Employment Cabinets
 */

GLOBAL_LIST_EMPTY(employmentCabinets)
GLOBAL_LIST_EMPTY(employmentContracts)

/obj/structure/filingcabinet/employment
	icon_state = "employment_cabinet"
	///This var is so that its filled on crew interaction to be as accurate (including latejoins) as possible, true until first interact
	var/virgin = TRUE
	COOLDOWN_DECLARE(devil_interaction)

/obj/structure/filingcabinet/employment/Initialize(mapload)
	. = ..()
	GLOB.employmentCabinets += src

/obj/structure/filingcabinet/employment/Destroy()
	GLOB.employmentCabinets -= src
	return ..()

/obj/structure/filingcabinet/employment/proc/fillCurrent()
	//This proc fills the cabinet with the current crew.
	for(var/record in GLOB.data_core.locked)
		var/datum/data/record/G = record
		if(!G)
			continue

		if(!G.fields["reference"])
			continue

		var/datum/weakref/ref = G.fields["reference"]
		var/mob/referenced_mob = ref.resolve()

		if(!referenced_mob)
			continue

		addFile(referenced_mob)

/obj/structure/filingcabinet/employment/proc/addFile(mob/living/carbon/human/employee)
	new /obj/item/paper/contract/employment(src, employee)

/obj/structure/filingcabinet/employment/attack_hand(mob/user)
	if(!COOLDOWN_FINISHED(src, devil_interaction))
		to_chat(user, span_warning("[src] is jammed, give it a few seconds."))
	else
		if(virgin)
			add_fingerprint(user)
			fillCurrent()
			virgin = FALSE

		if(user.mind.special_role == "devil")
			COOLDOWN_START(src, devil_interaction, 10 SECONDS)

		return ..()
