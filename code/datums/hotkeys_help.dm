/datum/hotkeys_help
	var/static/list/hotkeys = list()

/datum/hotkeys_help/ui_state()
	return GLOB.always_state

/datum/hotkeys_help/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HotkeysHelp")
		ui.open()

/datum/hotkeys_help/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(action == "open_keybindings")
		user.client.prefs.current_tab = TAB_KEYS
		user.client.prefs.ShowChoices(user)
		user.client.uiclose(ui.window.id)
		return TRUE

// Not static data since user could rebind keys.
/datum/hotkeys_help/ui_data(mob/user)
	// List every keybind to chat.
	var/list/keys_list = list()

	// Show them in alphabetical order by key
	var/list/key_bindings_by_key = user.client.prefs.keybindings.Copy()
	sortTim(key_bindings_by_key, cmp = GLOBAL_PROC_REF(cmp_text_asc))
	key_bindings_by_key -= UNBOUND_KEY

	for(var/key, bindings in key_bindings_by_key)
		// Get the full names
		var/list/binding_names = list()
		for(var/datum/keybinding/binding as anything in bindings)
			if(!binding)
				continue
			binding_names += list(list(
				"name" = binding.full_name,
				"desc" = binding.description
			))

		// Add to list
		keys_list += list(list(
			"key" = key,
			"bindings" = binding_names
		))

	return list(
		"hotkeys" = keys_list
	)
