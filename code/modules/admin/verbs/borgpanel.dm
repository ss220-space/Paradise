ADMIN_VERB(borg_panel, R_ADMIN, "Show Borg Panel", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/living/silicon/robot/borgo in GLOB.silicon_mob_list)
	var/datum/borgpanel/borgpanel = new(user.mob, borgo)
	borgpanel.ui_interact(user.mob)

ADMIN_VERB(borg_panel_in_list, R_ADMIN, "Show Borg Panel in List", "Open Borg Panel.", ADMIN_CATEGORY_EVENTS)
	var/mob/borgo = tgui_input_list(user, "Please, select a player!", "Grant Full Access", GLOB.silicon_mob_list)
	if(!borgo)
		return

	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/borg_panel, borgo)

/datum/borgpanel
	var/mob/living/silicon/robot/borg
	var/user

/datum/borgpanel/New(to_user, mob/living/silicon/robot/to_borg)
	if(!istype(to_borg))
		qdel(src)
		CRASH("Borg panel is only available for borgs")
	user = CLIENT_FROM_VAR(to_user)
	if(!user)
		CRASH("Borg panel attempted to open to a mob without a client")
	borg = to_borg

/datum/borgpanel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/borgpanel/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorgPanel", "Borg Panel")
		ui.open()

/datum/borgpanel/ui_data(mob/user)
	. = list()
	.["borg"] = list(
		"name" = "[borg]",
		"emagged" = borg.emagged,
		"active_module" = "[borg.module ? borg.module.name : "No module"]",
		"lawupdate" = borg.lawupdate,
		"lockdown" = borg.lockcharge,
		"scrambledcodes" = borg.scrambledcodes
	)
	.["upgrades"] = list()
	for(var/upgradetype in subtypesof(/obj/item/borg/upgrade)-list(/obj/item/borg/upgrade/rename, /obj/item/borg/upgrade/restart, /obj/item/borg/upgrade/reset))
		var/obj/item/borg/upgrade/upgrade = upgradetype
		if(!borg.module && initial(upgrade.require_module)) //Borg needs to select a module first
			continue
		if(initial(upgrade.module_type) && (borg.module != initial(upgrade.module_type))) // Upgrade requires a different module
			continue
		var/installed = FALSE
		if(locate(upgradetype) in borg)
			installed = TRUE
		.["upgrades"] += list(list("name" = initial(upgrade.name), "installed" = installed, "type" = upgradetype))
	.["laws"] = list()
	for(var/datum/ai_law/law in borg.laws?.all_laws())
		.["laws"] += "[law.index]. [law.law]"
	.["channels"] = list()
	for(var/k in SSradio.radiochannels)
		if(k == PUB_FREQ)
			continue
		.["channels"] += list(list("name" = k, "installed" = (k in borg.radio.channels)))
	.["cell"] = borg.cell ? list("missing" = FALSE, "maxcharge" = borg.cell.maxcharge, "charge" = borg.cell.charge) : list("missing" = TRUE, "maxcharge" = 1, "charge" = 0)
	.["modules"] = list()
	for(var/module_type in typesof(/obj/item/robot_module)-/obj/item/robot_module)
		var/obj/item/robot_module/module = module_type
		var/name = initial(module.name)
		.["modules"] += list(list("name" = "[name]", "type" = module_type))
	.["ais"] = list(list("ref" = "", "name" = "None", "connected" = isnull(borg.connected_ai)))
	for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
		.["ais"] += list(list("ref" = ai, "name" = ai.name, "connected" = (borg.connected_ai == ai)))

/datum/borgpanel/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_charge")
			var/newcharge = tgui_input_number(usr, "Set new charge", borg.name, borg.cell.charge, max_value = INFINITY)
			newcharge = between(0,newcharge, borg.cell.maxcharge)
			if(isnull(newcharge))
				return
			borg.cell.charge = newcharge
			message_admins("[key_name_admin(user)] set the charge of [ADMIN_LOOKUPFLW(borg)] to [borg.cell.charge].")
			log_admin("[key_name(user)] set the charge of [key_name(borg)] to [borg.cell.charge].")
		if("remove_cell")
			var/datum/robot_component/cell/C = borg.components["power cell"]
			if(!borg.cell)
				to_chat(usr, "There is no power cell installed!")
				return
			borg.cell = null
			C.wrapped = null
			C.installed = FALSE
			C.uninstall()
			message_admins("[key_name_admin(user)] deleted the cell of [ADMIN_LOOKUPFLW(borg)].")
			log_admin("[key_name(user)] deleted the cell of [key_name(borg)].")
		if("change_cell")
			var/datum/robot_component/cell/C = borg.components["power cell"]
			var/chosen = pick_closest_path(null, make_types_fancy(typesof(/obj/item/stock_parts/cell)))
			if(!ispath(chosen))
				chosen = text2path(chosen)
			if(chosen)
				if(borg.cell)
					borg.cell = null
					C.wrapped = null
					C.installed = FALSE
					C.uninstall()
				var/obj/item/stock_parts/cell/new_cell = new chosen(borg)
				borg.cell = new_cell
				C.wrapped = new_cell
				C.installed = TRUE
				C.install()
				borg.cell.charge = borg.cell.maxcharge
				borg.diag_hud_set_borgcell()
				message_admins("[key_name_admin(user)] changed the cell of [ADMIN_LOOKUPFLW(borg)] to [new_cell].")
				log_admin("[key_name(user)] changed the cell of [key_name(borg)] to [new_cell].")
		if("toggle_emagged")
			borg.SetEmagged(!borg.emagged)
			if(borg.emagged)
				message_admins("[key_name_admin(user)] emagged [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] emagged [key_name(borg)].")
			else
				message_admins("[key_name_admin(user)] un-emagged [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] un-emagged [key_name(borg)].")
		if("lawmanager")
			var/datum/ui_module/law_manager/L = new(borg)
			L.ui_interact(usr)
			message_admins("[key_name_admin(user)] opened law manager of [ADMIN_LOOKUPFLW(borg)].")
			log_admin("[key_name(user)] opened law manager of [key_name(borg)].")
		if("toggle_lawupdate")
			borg.lawupdate = !borg.lawupdate
			if(borg.lawupdate)
				message_admins("[key_name_admin(user)] enabled lawsync on [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] enabled lawsync on [key_name(borg)].")
			else
				message_admins("[key_name_admin(user)] disabled lawsync on [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] disabled lawsync on [key_name(borg)].")
		if("toggle_lockdown")
			borg.SetLockdown(!borg.lockcharge)
			if(borg.lockcharge)
				message_admins("[key_name_admin(user)] locked down [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] locked down [key_name(borg)].")
			else
				message_admins("[key_name_admin(user)] released [ADMIN_LOOKUPFLW(borg)] from lockdown.")
				log_admin("[key_name(user)] released [key_name(borg)] from lockdown.")
		if("toggle_scrambledcodes")
			borg.scrambledcodes = !borg.scrambledcodes
			if(borg.scrambledcodes)
				message_admins("[key_name_admin(user)] enabled scrambled codes on [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] enabled scrambled codes on [key_name(borg)].")
			else
				message_admins("[key_name_admin(user)] disabled scrambled codes on [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] disabled scrambled codes on [key_name(borg)].")
		if("rename")
			var/new_name = sanitize(tgui_input_text(user, "What would you like to name this cyborg?", "Cyborg Reclassification", borg.real_name, encode = FALSE))
			if(!new_name)
				return
			message_admins("[key_name_admin(user)] renamed [ADMIN_LOOKUPFLW(borg)] to [new_name].")
			log_admin("[key_name(user)] renamed [key_name(borg)] to [new_name].")
			borg.rename_character(borg.real_name,new_name)
		if("toggle_upgrade")
			var/upgradepath = text2path(params["upgrade"])
			var/obj/item/borg/upgrade/installedupgrade = locate(upgradepath) in borg
			if(installedupgrade)
				message_admins("[key_name_admin(user)] removed the [installedupgrade] upgrade from [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] removed the [installedupgrade] upgrade from [key_name(borg)].")
				qdel(installedupgrade) // see [mob/living/silicon/robot/on_upgrade_deleted()].
			else
				var/obj/item/borg/upgrade/upgrade = new upgradepath(borg)
				if(!upgrade.action(borg))
					return
				borg.install_upgrade(upgrade)
				message_admins("[key_name_admin(user)] added the [upgrade] borg upgrade to [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] added the [upgrade] borg upgrade to [key_name(borg)].")
		if("toggle_radio")
			var/channel = params["channel"]
			if(channel in borg.radio.channels) // We're removing a channel
				if(!borg.radio.keyslot) // There's no encryption key. This shouldn't happen but we can cope
					borg.radio.channels -= channel
				else
					borg.radio.keyslot.channels -= channel
					if(channel == SYND_FREQ_NAME)
						borg.radio.keyslot.syndie = FALSE
				message_admins("[key_name_admin(user)] removed the [channel] radio channel from [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] removed the [channel] radio channel from [key_name(borg)].")
			else // We're adding a channel
				if(!borg.radio.keyslot) // Assert that an encryption key exists
					borg.radio.keyslot = new()
				borg.radio.keyslot.channels[channel] = 1
				if(channel == SYND_FREQ_NAME)
					borg.radio.keyslot.syndie = TRUE
				message_admins("[key_name_admin(user)] added the [channel] radio channel to [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] added the [channel] radio channel to [key_name(borg)].")
			borg.radio.recalculate_channels()
		if("setmodule")
			var/new_module = params["module"]
			if(borg.module)
				borg.reset_module()
			borg.pick_module(new_module)
			message_admins("[key_name_admin(user)] changed the model of [ADMIN_LOOKUPFLW(borg)] to [new_module].")
			log_admin("[key_name(user)] changed the model of [key_name(borg)] to [new_module].")
		if("reset_module")
			var/obj/item/borg/upgrade/reset/reset = new(borg)
			if(reset.action(borg))
				borg.install_upgrade(reset)
				message_admins("[key_name_admin(user)] resets module of [ADMIN_LOOKUPFLW(borg)].")
				log_admin("[key_name(user)] resets module of [key_name(borg)].")
		if("slavetoai")
			var/mob/living/silicon/ai/newai
			for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
				if(ai.name == params["slavetoai"])
					newai = ai
			if(newai && newai != borg.connected_ai)
				borg.notify_ai(ROBOT_NOTIFY_AI_CONNECTED)
				borg.connect_to_ai(newai)
				borg.notify_ai(TRUE)
				message_admins("[key_name_admin(user)] slaved [ADMIN_LOOKUPFLW(borg)] to the AI [ADMIN_LOOKUPFLW(newai)].")
				log_admin("[key_name(user)] slaved [key_name(borg)] to the AI [key_name(newai)].")
			else if(params["slavetoai"] == "")
				borg.notify_ai(ROBOT_NOTIFY_AI_CONNECTED)
				borg.disconnect_from_ai()
				message_admins("[key_name_admin(user)] freed [ADMIN_LOOKUPFLW(borg)] from being slaved to an AI.")
				log_admin("[key_name(user)] freed [key_name(borg)] from being slaved to an AI.")
			if(borg.lawupdate)
				borg.lawsync()
				if(borg.connected_ai?.laws)
					SSticker?.score?.save_silicon_laws(borg, usr, "laws sync with AI", log_all_laws = TRUE)
		if("set_skin_permission")
			if(!check_rights(R_SKINS, FALSE))
				return

			if(!borg?.mind)
				return

			var/permissions = length(borg?.mind?.cyborg_skin_permissions)? borg?.mind?.cyborg_skin_permissions : GLOB.all_skin_permissions

			var/new_permissions = tgui_input_checkbox_list(usr, "Выберите разрешенные скины", "Разрешенные скины", permissions) || list()

			borg?.mind?.cyborg_skin_permissions = new_permissions
			message_admins("[key_name_admin(user)] set skin permissions to [ADMIN_LOOKUPFLW(borg)].")
			log_admin("[key_name(user)] set skin permissions to [key_name(borg)].")

		if("allow_set_skin")
			borg?.choose_icon()
			message_admins("[key_name_admin(user)] allowed skin selection to [ADMIN_LOOKUPFLW(borg)].")
			log_admin("[key_name(user)] allowed skin selection to [key_name(borg)].")

	. = TRUE
