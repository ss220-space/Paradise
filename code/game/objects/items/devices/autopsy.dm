/obj/item/autopsy_scanner
	name = "autopsy scanner"
	desc = "Extracts information on wounds."
	icon = 'icons/obj/autopsy_scanner.dmi'
	icon_state = "autopsy_scanner"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "magnets=1;biotech=1"
	var/list/datum/autopsy_data_scanner/wdata = list()
	var/list/chemtraces = list()
	var/target_UID = null
	var/target_name = null	// target.name can change after scanning, so better save it here.
	var/timeofdeath = null

/obj/item/autopsy_scanner/Destroy()
	QDEL_LIST_ASSOC_VAL(wdata)
	return ..()

/datum/autopsy_data_scanner
	var/weapon = null // this is the DEFINITE weapon type that was used
	var/list/organs_scanned = list() // this maps a number of scanned organs to
									 // the wounds to those organs with this data's weapon type
	var/organ_names = ""

/datum/autopsy_data_scanner/Destroy()
	QDEL_LIST_ASSOC_VAL(organs_scanned)
	return ..()

/datum/autopsy_data
	var/weapon = null
	var/damage = 0
	var/hits = 0
	var/time_inflicted = 0

/datum/autopsy_data/proc/copy()
	var/datum/autopsy_data/W = new()
	W.weapon = weapon
	W.damage = damage
	W.hits = hits
	W.time_inflicted = time_inflicted
	return W

/obj/item/autopsy_scanner/proc/add_data(obj/item/organ/check_organ)
	for(var/index in check_organ.autopsy_data)
		var/datum/autopsy_data/weapon_data = check_organ.autopsy_data[index]

		var/datum/autopsy_data_scanner/scanner_data = wdata[index]
		if(!scanner_data)
			scanner_data = new
			scanner_data.weapon = weapon_data.weapon
			wdata[index] = scanner_data

		if(!scanner_data.organs_scanned[check_organ.name])
			if(scanner_data.organ_names == "")
				scanner_data.organ_names = check_organ.name
			else
				scanner_data.organ_names += ", [check_organ.name]"

		qdel(scanner_data.organs_scanned[check_organ.name])
		scanner_data.organs_scanned[check_organ.name] = weapon_data.copy()

	for(var/chemID in check_organ.trace_chemicals)
		if(check_organ.trace_chemicals[chemID] > 0 && !chemtraces.Find(chemID))
			chemtraces += chemID


/obj/item/autopsy_scanner/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		add_fingerprint(user)
		var/dead_name = tgui_input_text(user, "Insert name of the deceased individual", "Enter Name") || "Unknown"
		var/dead_rank = tgui_input_text(user, "Insert rank of deceased individual", "Enter Rank") || "Not Available"
		var/dead_tod = tgui_input_text(user, "Insert time of death", "Time Of Death") || "Unknown"
		var/dead_cause = tgui_input_text(user, "Insert cause of death", "Cause Of Death") || "Unknown"
		var/dead_chems = tgui_input_text(user, "Insert any chemical traces", "Chemical Traces") || "Unknown"
		var/dead_notes = tgui_input_text(user, "Insert any relevant notes", "Relevant Notes") || "None"
		playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
		sleep(1 SECONDS)
		var/obj/item/paper/paper = new(user.loc)
		paper.name = "Official Coroner's Report - [dead_name]"
		paper.info = "<b>Nanotrasen Science Station [SSmapping.map_datum.station_short] - Coroner's Report</b><br><br><b>Name of Deceased:</b> [dead_name]</br><br><b>Rank of Deceased:</b> [dead_rank]<br><br><b>Time of Death:</b> [dead_tod]<br><br><b>Cause of Death:</b> [dead_cause]<br><br><b>Trace Chemicals:</b> [dead_chems]<br><br><b>Additional Coroner's Notes:</b> [dead_notes]<br><br><b>Coroner's Signature:</b> <span class=\"paper_field\">"
		user.put_in_hands(paper, ignore_anim = FALSE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/autopsy_scanner/attack_self(mob/user)
	var/scan_data = ""

	if(timeofdeath)
		scan_data += "<b>Time of death:</b> [station_time_timestamp("hh:mm:ss", timeofdeath)]<br><br>"
	else
		scan_data += "<b>Time of death:</b> No data<br><br>"

	if(wdata.len)
		var/n = 1
		for(var/wdata_idx in wdata)
			var/datum/autopsy_data_scanner/D = wdata[wdata_idx]
			var/total_hits = 0
			var/total_score = 0
			var/age = 0

			for(var/wound_idx in D.organs_scanned)
				var/datum/autopsy_data/W = D.organs_scanned[wound_idx]
				total_hits += W.hits
				total_score+=W.damage


				var/wound_age = W.time_inflicted
				age = max(age, wound_age)

			var/damage_desc
			// total score happens to be the total damage
			switch(total_score)
				if(1 to 5)
					damage_desc = "<font color='green'>negligible</font>"
				if(5 to 15)
					damage_desc = "<font color='green'>light</font>"
				if(15 to 30)
					damage_desc = "<font color='orange'>moderate</font>"
				if(30 to 1000)
					damage_desc = "<font color='red'>severe</font>"
				else
					damage_desc = "Unknown"

			var/damaging_weapon = (total_score != 0)
			scan_data += "<b>Weapon #[n]</b><br>"
			if(damaging_weapon)
				scan_data += "Severity: [damage_desc]<br>"
				scan_data += "Hits by weapon: [total_hits]<br>"
			scan_data += "Approximate time of wound infliction: [station_time_timestamp("hh:mm", age)]<br>"
			scan_data += "Affected limbs: [D.organ_names]<br>"
			scan_data += "Weapon: [D.weapon]<br>"
			scan_data += "<br>"

			n++

	if(chemtraces.len)
		scan_data += "<b>Trace Chemicals: </b><br>"
		for(var/chemID in chemtraces)
			scan_data += chemID
			scan_data += "<br>"
	user.visible_message(span_notice("[src] rattles and prints out a sheet of paper."))

	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	flick("autopsy_scanner_anim", src)
	sleep(3 SECONDS)

	var/obj/item/paper/P = new(drop_location())
	P.name = "Autopsy Data ([target_name])"
	P.info = "<tt>[scan_data]</tt>"
	P.update_icon()

	user.put_in_hands(P, ignore_anim = FALSE)


/obj/item/autopsy_scanner/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target) || !on_operable_surface(target))
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_PROCEED_SUCCESS

	if(target_UID != target.UID())
		to_chat(user, span_notice("A new patient has been registered.[target_UID ? " Purging data for previous patient." : ""]"))
		target_UID = target.UID()
		target_name = target.name
		wdata.Cut()
		chemtraces.Cut()
		timeofdeath = null

	timeofdeath = target.timeofdeath

	var/obj/item/organ/external/limb = target.get_organ(user.zone_selected)
	if(!limb)
		to_chat(user, span_warning("You can't scan this body part!"))
		return NONE
	target.visible_message(span_notice("[user] scans the wounds on [target]'s [limb] with [src]."))

	add_data(limb)

