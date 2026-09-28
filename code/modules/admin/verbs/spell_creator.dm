/mob/living/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_SPELL_CREATOR, "Create Spell From...")

/mob/living/vv_do_topic(list/href_list)
	. = ..()
	if(!.)
		return

	if(href_list[VV_HK_SPELL_CREATOR])
		if(!check_rights(R_EVENT))
			return
		var/datum/admin_spell_creator/creator = new(src)
		creator.ui_interact(usr)

/datum/admin_spell_creator
	var/datum/weakref/target_ref
	var/base_type
	var/datum/action/cooldown/spell/preview_spell
	var/icon_preview
	var/static/list/requirement_flags = list(
		"wizard_garb" = SPELL_REQUIRES_WIZARD_GARB,
		"requires_human" = SPELL_REQUIRES_HUMAN,
		"castable_as_brain" = SPELL_CASTABLE_AS_BRAIN,
		"no_antimagic" = SPELL_REQUIRES_NO_ANTIMAGIC,
		"no_centcom" = SPELL_REQUIRES_NO_CENTCOM,
		"requires_mind" = SPELL_REQUIRES_MIND,
		"mime_vow" = SPELL_REQUIRES_MIME_VOW,
		"castable_without_invocation" = SPELL_CASTABLE_WITHOUT_INVOCATION,
	)

/datum/admin_spell_creator/New(mob/living/target)
	target_ref = WEAKREF(target)

/datum/admin_spell_creator/Destroy(force)
	target_ref = null
	QDEL_NULL(preview_spell)
	return ..()

/datum/admin_spell_creator/ui_state(mob/user)
	return ADMIN_STATE(R_EVENT)

/datum/admin_spell_creator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpellCreator")
		ui.open()

/datum/admin_spell_creator/ui_close(mob/user)
	. = ..()
	QDEL_IN(src, 0)

/datum/admin_spell_creator/ui_static_data(mob/user)
	var/list/data = list()

	var/list/names_to_paths = list()
	for(var/path in GLOB.spells)
		var/datum/action/cooldown/spell/spell_type = path
		var/display_name = "[spell_type::name] ([path])"
		names_to_paths[display_name] = "[path]"

	var/list/sorted_names = sort_list(names_to_paths)
	var/list/spells = list()
	for(var/display_name in sorted_names)
		spells += list(list(
			"name" = display_name,
			"path" = sorted_names[display_name],
		))

	data["spells"] = spells
	return data

/datum/admin_spell_creator/ui_data(mob/user)
	var/list/data = list()

	var/mob/living/target = target_ref?.resolve()
	data["target_name"] = target ? "[target.name] ([target.ckey || "no key"])" : null
	data["base_type"] = base_type

	if(preview_spell)
		data["name"] = preview_spell.name
		data["desc"] = preview_spell.desc
		data["cooldown"] = round(preview_spell.cooldown_time / (1 SECONDS), 0.1)
		data["invocation"] = preview_spell.invocation || ""
		data["has_invocation"] = preview_spell.invocation_type != INVOCATION_NONE
		data["icon_state"] = preview_spell.button_icon_state
		data["icon_preview"] = icon_preview
		var/list/flags = list()
		for(var/flag_name in requirement_flags)
			flags[flag_name] = !!(preview_spell.spell_requirements & requirement_flags[flag_name])
		data["flags"] = flags

	return data

/datum/admin_spell_creator/proc/get_icon_preview()
	if(!preview_spell)
		return null

	var/icon/preview_icon
	if(preview_spell.background_icon && preview_spell.background_icon_state && icon_exists(preview_spell.background_icon, preview_spell.background_icon_state))
		preview_icon = icon(preview_spell.background_icon, preview_spell.background_icon_state, dir = SOUTH, frame = 1)
	if(preview_spell.button_icon && preview_spell.button_icon_state && icon_exists(preview_spell.button_icon, preview_spell.button_icon_state))
		var/icon/button_layer = icon(preview_spell.button_icon, preview_spell.button_icon_state, dir = SOUTH, frame = 1)
		if(preview_icon)
			preview_icon.Blend(button_layer, ICON_OVERLAY)
		else
			preview_icon = button_layer
	if(preview_spell.overlay_icon && preview_spell.overlay_icon_state && icon_exists(preview_spell.overlay_icon, preview_spell.overlay_icon_state) && preview_icon)
		preview_icon.Blend(icon(preview_spell.overlay_icon, preview_spell.overlay_icon_state, dir = SOUTH, frame = 1), ICON_OVERLAY)

	if(!preview_icon)
		return null
	return icon2base64(preview_icon)

/datum/admin_spell_creator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!check_rights(R_EVENT))
		return FALSE

	switch(action)
		if("select_base")
			var/picked_path = params["path"]
			var/real_path = text2path(picked_path)
			if(!ispath(real_path, /datum/action/cooldown/spell))
				return FALSE

			QDEL_NULL(preview_spell)
			base_type = picked_path
			preview_spell = new real_path()
			icon_preview = get_icon_preview()
			return TRUE

		if("set_field")
			if(!preview_spell)
				return FALSE
			var/field = params["field"]
			var/value = params["value"]
			switch(field)
				if("name")
					if(!length(value))
						return FALSE
					preview_spell.name = value
				if("desc")
					preview_spell.desc = value
				if("invocation")
					preview_spell.invocation = value
				if("icon_state")
					if(!length(value))
						return FALSE
					preview_spell.button_icon_state = value
					icon_preview = get_icon_preview()
				if("cooldown")
					var/new_cooldown = text2num(value)
					if(!isnum(new_cooldown) || new_cooldown < 0)
						return FALSE
					preview_spell.cooldown_time = new_cooldown SECONDS
				else
					return FALSE
			return TRUE

		if("toggle_invocation")
			if(!preview_spell)
				return FALSE
			if(preview_spell.invocation_type != INVOCATION_NONE)
				preview_spell.invocation_type = INVOCATION_NONE
				return TRUE
			var/base_invocation_type = initial(preview_spell.invocation_type)
			preview_spell.invocation_type = base_invocation_type == INVOCATION_NONE ? INVOCATION_SHOUT : base_invocation_type
			return TRUE

		if("pick_icon_file")
			if(!preview_spell)
				return FALSE
			var/datum/action/cooldown/spell/edited_spell = preview_spell
			var/new_icon = input(usr, "Выберите файл иконки", "Icon") as null|icon
			if(isnull(new_icon))
				return FALSE
			var/new_icon_state = tgui_input_list(usr, "Выберите состояние иконки", "Icon", icon_states(new_icon))
			if(isnull(new_icon_state) || preview_spell != edited_spell)
				return FALSE
			preview_spell.button_icon = new_icon
			preview_spell.button_icon_state = new_icon_state
			icon_preview = get_icon_preview()
			return TRUE

		if("toggle_flag")
			if(!preview_spell)
				return FALSE
			var/flag_bit = requirement_flags[params["flag"]]
			if(!flag_bit)
				return FALSE
			preview_spell.spell_requirements ^= flag_bit
			return TRUE

		if("give_spell")
			var/mob/living/target = target_ref?.resolve()
			if(!target || !preview_spell)
				return FALSE

			var/datum/action/cooldown/spell/final_spell = preview_spell
			preview_spell = null
			final_spell.datum_flags |= DF_VAR_EDITED
			final_spell.Grant(target)

			BLACKBOX_LOG_ADMIN_VERB("Spell Creator")
			log_and_message_admins("created a custom spell '[final_spell.name]' (base: [base_type]) and gave it to [key_name_log(target)].")
			to_chat(usr, span_notice("Спелл '[final_spell.name]' выдан [target.declent_ru(DATIVE)]."), confidential = TRUE)

			SStgui.close_uis(src)
			return TRUE
