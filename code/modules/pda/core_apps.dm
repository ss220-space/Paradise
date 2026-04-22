/datum/data/pda/app/main_menu
	icon = "home"
	template = "pda_main_menu"
	hidden = 1

/datum/data/pda/app/main_menu/update_ui(mob/user as mob, list/data)
	title = pda.name

	data["app"]["is_home"] = TRUE

	data["apps"] = pda.shortcut_cache
	data["categories"] = pda.shortcut_cat_order
	data["pai"] = !isnull(pda.pai)				// pAI inserted?

	var/list/notifying = list()
	for(var/datum/data/pda/P in pda.notifying_programs)
		notifying["[P.UID()]"] = TRUE
	data["notifying"] = notifying

/datum/data/pda/app/main_menu/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("UpdateInfo")
			pda.ownjob = pda.id.assignment
			pda.ownrank = pda.id.rank
			pda.owner = pda.id.registered_name
			pda.update_appearance(UPDATE_NAME)
			if(!pda.silent)
				playsound(pda, 'sound/machines/terminal_processing.ogg', 15, TRUE)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), pda, 'sound/machines/terminal_success.ogg', 15, TRUE), 1.3 SECONDS)
		if("pai")
			if(pda.pai)
				if(pda.pai.loc != pda)
					pda.pai = null
				else
					switch(text2num(params["option"]))
						if(1)		// Configure pAI device
							pda.pai.attack_self(usr)
						if(2)		// Eject pAI device
							var/turf/T = get_turf(pda.loc)
							if(T)
								pda.pai.forceMove(T)
								pda.pai = null
								playsound(pda, 'sound/machines/terminal_eject.ogg', 50, TRUE)

/datum/data/pda/app/notekeeper
	name = "Заметки"
	icon = "sticky-note"
	template = "pda_notes"

	var/note

/datum/data/pda/app/notekeeper/start()
	. = ..()
	if(!note)
		note = "Congratulations, your station has chosen the [pda.model_name]!"

/datum/data/pda/app/notekeeper/update_ui(mob/user as mob, list/data)
	data["note"] = html_decode(note)	// current pda notes

/datum/data/pda/app/notekeeper/ui_act(action, params)
	if(..())
		return

	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	. = TRUE

	switch(action)
		if("Edit")
			var/n = tgui_input_text(usr, "Please enter message", name, note, multiline = TRUE, encode = FALSE)
			if(isnull(n))
				return

			if(pda.loc == usr)
				note = n
			else
				pda.close(usr)

/datum/data/pda/app/manifest
	name = "Манифест экипажа"
	icon = "user"
	template = "pda_manifest"
	update = PDA_APP_UPDATE_SLOW

/datum/data/pda/app/manifest/update_ui(mob/user as mob, list/data)
	GLOB.data_core.get_manifest_json()
	data["manifest"] = GLOB.PDA_Manifest

/datum/data/pda/app/atmos_scanner
	name = "Атмосферный сканер"
	icon = "fire"
	template = "pda_atmos_scan"
	category = "Utilities"
	update = PDA_APP_UPDATE_SLOW

/datum/data/pda/app/atmos_scanner/update_ui(mob/user as mob, list/data)
	var/list/results = list()
	var/turf/location = get_turf(user.loc)
	if(!isnull(location))
		var/datum/gas_mixture/environment = location.get_readonly_air()

		var/list/gas_data = gas_mixture_parser_faster(environment)
		var/pressure = gas_data[TLV_PRESSURE]
		var/total_moles = gas_data[TLV_TOTAL_MOLES]

		if(total_moles)
			var/datum/tlv/tlv
			var/list/tlv_list = GLOB.human_tlv
			for(var/gas_id, meta_list in GLOB.gas_meta)
				var/list/gas_meta_list = meta_list
				tlv = tlv_list[gas_id]
				var/gas_value = gas_data[gas_id]
				var/gas_level = gas_value / total_moles
				results += list(list("entry" = gas_meta_list[META_GAS_NAME], "units" = "%", "val" = "[round(gas_level * 100, 0.1)]", "danger" = tlv.get_danger_level(gas_value)))

			tlv = tlv_list[TLV_PRESSURE]
			results += list(list("entry" = "Pressure", "units" = "kPa", "val" = "[round(pressure, 0.1)]", "danger" = tlv.get_danger_level(pressure)))
			tlv = tlv_list[TLV_TEMPERATURE]
			var/temperature = gas_data[TLV_TEMPERATURE]
			results += list(list("entry" = "Temperature", "units" = "C", "val" = "[round(temperature - T0C, 0.1)]", "danger" = tlv.get_danger_level(temperature)))

	if(isnull(results))
		results = list(list("entry" = "pressure", "units" = "%", "val" = "0", "danger" = 0))

	data["aircontents"] = results
