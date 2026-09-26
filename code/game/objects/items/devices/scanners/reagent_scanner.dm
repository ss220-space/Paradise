/obj/item/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents and blood types."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=30, MAT_GLASS=20)
	origin_tech = "magnets=2;biotech=1;plasmatech=2"
	var/details = FALSE
	var/datatoprint = ""
	var/scanning = TRUE
	actions_types = list(/datum/action/item_action/print_report)

/obj/item/reagent_scanner/afterattack(obj/target, mob/user, proximity_flag, list/modifiers, status)
	if(user.stat)
		return

	if(!user.IsAdvancedToolUser())
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	if(!istype(target))
		return

	if(!isnull(target.reagents))
		var/dat = ""
		var/blood_type = ""
		var/blood_species = ""
		if(length(target.reagents.reagent_list) > 0)
			var/one_percent = target.reagents.total_volume / 100
			for(var/datum/reagent/R in target.reagents.reagent_list)
				if(R.id != "blood")
					dat += "<br>[TAB][span_notice("[R][details ? ": [R.volume / one_percent]%" : ""]")]"
				else
					blood_species = R.data["blood_species"]
					blood_type = R.data["blood_type"]
					dat += "<br>[TAB][span_notice("[R][blood_type ? " [blood_type]" : ""][blood_species ? " [blood_species]" : ""][details ? ": [R.volume / one_percent]%" : ""]")]"
		if(dat)
			to_chat(user, span_notice("Chemicals found: [dat]"))
			datatoprint = dat
			scanning = FALSE
		else
			to_chat(user, span_notice("No active chemical agents found in [target]."))
	else
		to_chat(user, span_notice("No significant chemical agents found in [target]."))

/obj/item/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = TRUE
	origin_tech = "magnets=4;biotech=3;plasmatech=3"

/obj/item/reagent_scanner/proc/print_report()
	if(!scanning)
		usr.visible_message(span_warning("[src] rattles and prints out a sheet of paper."))
		playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
		if(!details)
			flick("spectrometer_anim", src)
		else
			flick("adv_spectrometer_anim", src)
		sleep(50)

		var/obj/item/paper/P = new(drop_location())
		P.name = "Reagent Scanner Report: [station_time_timestamp()]"
		P.info = "<center><b>Reagent Scanner</b></center><br><center>Data Analysis:</center><br><hr><br><b>Chemical agents detected:</b><br> [datatoprint]<br><hr>"

		if(ismob(loc))
			var/mob/M = loc
			M.put_in_hands(P, ignore_anim = FALSE)
			to_chat(M, span_notice("Report printed. Log cleared."))
			datatoprint = ""
			scanning = TRUE
	else
		to_chat(usr, span_notice("[src]  has no logs or is already in use."))

/obj/item/reagent_scanner/ui_action_click(mob/user, datum/action/action, leftclick)
	print_report()
