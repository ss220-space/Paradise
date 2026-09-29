#define SPELL_CREATOR_MAX_PRESET_LENGTH 262144
#define SPELL_CREATOR_MAX_COOLDOWN 3600
#define IS_PRESET_BOOLEAN(value) (isnum(value) && (value == TRUE || value == FALSE))

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

/datum/admin_spell_creator/proc/set_base_type(spell_path)
	QDEL_NULL(preview_spell)
	base_type = "[spell_path]"
	preview_spell = new spell_path()
	icon_preview = get_icon_preview()

/datum/admin_spell_creator/proc/set_invocation_enabled(enabled)
	if(!enabled)
		preview_spell.invocation_type = INVOCATION_NONE
		return
	var/base_invocation_type = initial(preview_spell.invocation_type)
	preview_spell.invocation_type = base_invocation_type == INVOCATION_NONE ? INVOCATION_SHOUT : base_invocation_type

/datum/admin_spell_creator/proc/load_preset(json_text)
	if(!istext(json_text) || !length(json_text) || length(json_text) > SPELL_CREATOR_MAX_PRESET_LENGTH)
		return FALSE

	var/list/preset_data = safe_json_decode(json_text)
	if(!islist(preset_data))
		return FALSE

	var/static/list/allowed_keys = list("base_type", "flags", "name", "desc", "cooldown", "has_invocation", "invocation", "icon_state")
	for(var/key in preset_data)
		if(!(key in allowed_keys))
			return FALSE

	var/picked_path = preset_data["base_type"]
	if(!istext(picked_path))
		return FALSE
	var/real_path = text2path(picked_path)
	if(!ispath(real_path, /datum/action/cooldown/spell))
		return FALSE

	var/list/flags_data = preset_data["flags"]
	if("flags" in preset_data)
		if(!islist(flags_data))
			return FALSE
		for(var/flag_name in flags_data)
			if(!istext(flag_name) || !(flag_name in requirement_flags) || !IS_PRESET_BOOLEAN(flags_data[flag_name]))
				return FALSE

	if(("name" in preset_data) && (!istext(preset_data["name"]) || !length(preset_data["name"])))
		return FALSE
	if(("desc" in preset_data) && !istext(preset_data["desc"]))
		return FALSE
	if(("cooldown" in preset_data) && (!isnum(preset_data["cooldown"]) || preset_data["cooldown"] < 0 || preset_data["cooldown"] > SPELL_CREATOR_MAX_COOLDOWN))
		return FALSE
	if(("has_invocation" in preset_data) && !IS_PRESET_BOOLEAN(preset_data["has_invocation"]))
		return FALSE
	if(("invocation" in preset_data) && !istext(preset_data["invocation"]))
		return FALSE
	if(("icon_state" in preset_data) && (!istext(preset_data["icon_state"]) || !length(preset_data["icon_state"])))
		return FALSE

	set_base_type(real_path)
	for(var/flag_name in flags_data)
		if(flags_data[flag_name])
			preview_spell.spell_requirements |= requirement_flags[flag_name]
		else
			preview_spell.spell_requirements &= ~requirement_flags[flag_name]
	if("name" in preset_data)
		preview_spell.name = preset_data["name"]
	if("desc" in preset_data)
		preview_spell.desc = preset_data["desc"]
	if("cooldown" in preset_data)
		preview_spell.cooldown_time = preset_data["cooldown"] SECONDS
	if("has_invocation" in preset_data)
		set_invocation_enabled(preset_data["has_invocation"])
	if("invocation" in preset_data)
		preview_spell.invocation = preset_data["invocation"]
	if("icon_state" in preset_data)
		preview_spell.button_icon_state = preset_data["icon_state"]
		icon_preview = get_icon_preview()
	return TRUE

/datum/admin_spell_creator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!check_rights(R_EVENT))
		return FALSE

	switch(action)
		if("load_preset")
			if(!load_preset(params["json"]))
				to_chat(usr, span_warning("Не удалось загрузить пресет: некорректный JSON или неподдерживаемые значения."), confidential = TRUE)
				return FALSE

			to_chat(usr, span_notice("Пресет загружен."), confidential = TRUE)
			return TRUE

		if("select_base")
			var/real_path = text2path(params["path"])
			if(!ispath(real_path, /datum/action/cooldown/spell))
				return FALSE

			set_base_type(real_path)
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
					if(!isnum(new_cooldown) || new_cooldown < 0 || new_cooldown > SPELL_CREATOR_MAX_COOLDOWN)
						return FALSE
					preview_spell.cooldown_time = new_cooldown SECONDS
				else
					return FALSE
			return TRUE

		if("toggle_invocation")
			if(!preview_spell)
				return FALSE
			set_invocation_enabled(preview_spell.invocation_type == INVOCATION_NONE)
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

#undef SPELL_CREATOR_MAX_PRESET_LENGTH
#undef SPELL_CREATOR_MAX_COOLDOWN
#undef IS_PRESET_BOOLEAN
