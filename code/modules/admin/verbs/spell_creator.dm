/mob/living/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_SPELL_CREATOR, "Create Spell From...")

/mob/living/vv_do_topic(list/href_list)
	. = ..()
	if(!.)
		return

	if(href_list[VV_HK_SPELL_CREATOR])
		if(!check_rights(R_VAREDIT))
			return
		usr.client?.open_spell_creator(src)

/client/proc/open_spell_creator(mob/living/target)
	var/datum/admin_spell_creator/creator = new(src, target)
	creator.ui_interact(mob)

/datum/admin_spell_creator
	var/client/owner
	var/datum/weakref/target_ref
	var/base_type
	var/datum/action/cooldown/spell/preview_spell

/datum/admin_spell_creator/New(client/user, mob/living/target)
	owner = user
	target_ref = WEAKREF(target)

/datum/admin_spell_creator/Destroy(force)
	owner = null
	target_ref = null
	QDEL_NULL(preview_spell)
	return ..()

/datum/admin_spell_creator/ui_state(mob/user)
	return ADMIN_STATE(R_VAREDIT)

/datum/admin_spell_creator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpellCreator")
		ui.open()

/datum/admin_spell_creator/ui_close(mob/user)
	. = ..()
	QDEL_IN(src, 0)

/// Sent once; the client filters this static list locally.
/datum/admin_spell_creator/ui_static_data(mob/user)
	var/list/data = list()

	var/list/names_to_paths = list()
	for(var/path in subtypesof(/datum/action/cooldown/spell))
		var/datum/action/cooldown/spell/spell_type = path
		var/display_name = "[initial(spell_type.name)] ([path])"
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
		data["cooldown"] = round(preview_spell.cooldown_time / 10, 0.1) // deciseconds -> seconds
		data["invocation"] = preview_spell.invocation || ""
		data["has_invocation"] = preview_spell.invocation_type != INVOCATION_NONE
		data["icon_state"] = preview_spell.button_icon_state
		data["icon_preview"] = get_icon_preview()
		data["flags"] = list(
			"wizard_garb" = !!(preview_spell.spell_requirements & SPELL_REQUIRES_WIZARD_GARB),
			"requires_human" = !!(preview_spell.spell_requirements & SPELL_REQUIRES_HUMAN),
			"castable_as_brain" = !!(preview_spell.spell_requirements & SPELL_CASTABLE_AS_BRAIN),
			"no_antimagic" = !!(preview_spell.spell_requirements & SPELL_REQUIRES_NO_ANTIMAGIC),
			"no_centcom" = !!(preview_spell.spell_requirements & SPELL_REQUIRES_NO_CENTCOM),
			"requires_mind" = !!(preview_spell.spell_requirements & SPELL_REQUIRES_MIND),
			"mime_vow" = !!(preview_spell.spell_requirements & SPELL_REQUIRES_MIME_VOW),
			"castable_without_invocation" = !!(preview_spell.spell_requirements & SPELL_CASTABLE_WITHOUT_INVOCATION),
		)

	return data

/// Builds a base64 preview of what the action button will actually look like,
/// layering background/button/overlay the same way build_button_icon() does.
/datum/admin_spell_creator/proc/get_icon_preview()
	if(!preview_spell)
		return null

	var/icon/preview_icon
	if(preview_spell.background_icon && preview_spell.background_icon_state && icon_exists(preview_spell.background_icon, preview_spell.background_icon_state))
		preview_icon = icon(preview_spell.background_icon, preview_spell.background_icon_state)
	if(preview_spell.button_icon && preview_spell.button_icon_state && icon_exists(preview_spell.button_icon, preview_spell.button_icon_state))
		var/icon/button_layer = icon(preview_spell.button_icon, preview_spell.button_icon_state)
		if(preview_icon)
			preview_icon.Blend(button_layer, ICON_OVERLAY)
		else
			preview_icon = button_layer
	if(preview_spell.overlay_icon && preview_spell.overlay_icon_state && icon_exists(preview_spell.overlay_icon, preview_spell.overlay_icon_state) && preview_icon)
		preview_icon.Blend(icon(preview_spell.overlay_icon, preview_spell.overlay_icon_state), ICON_OVERLAY)

	if(!preview_icon)
		return null
	return icon2base64(preview_icon)

/datum/admin_spell_creator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!check_rights(R_VAREDIT))
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
			preview_spell.invocation_type = (preview_spell.invocation_type == INVOCATION_NONE) ? INVOCATION_SHOUT : INVOCATION_NONE
			return TRUE

		if("pick_icon_file")
			if(!preview_spell)
				return FALSE
			var/new_icon = input(usr, "Выберите файл иконки", "Icon") as null|icon
			if(isnull(new_icon))
				return FALSE
			preview_spell.button_icon = new_icon
			return TRUE

		if("toggle_flag")
			if(!preview_spell)
				return FALSE
			var/flag_bit
			switch(params["flag"])
				if("wizard_garb")
					flag_bit = SPELL_REQUIRES_WIZARD_GARB
				if("requires_human")
					flag_bit = SPELL_REQUIRES_HUMAN
				if("castable_as_brain")
					flag_bit = SPELL_CASTABLE_AS_BRAIN
				if("no_antimagic")
					flag_bit = SPELL_REQUIRES_NO_ANTIMAGIC
				if("no_centcom")
					flag_bit = SPELL_REQUIRES_NO_CENTCOM
				if("requires_mind")
					flag_bit = SPELL_REQUIRES_MIND
				if("mime_vow")
					flag_bit = SPELL_REQUIRES_MIME_VOW
				if("castable_without_invocation")
					flag_bit = SPELL_CASTABLE_WITHOUT_INVOCATION
			if(!flag_bit)
				return FALSE
			preview_spell.spell_requirements ^= flag_bit
			return TRUE

		if("give_spell")
			var/mob/living/target = target_ref?.resolve()
			if(!target || !preview_spell)
				return FALSE

			var/datum/action/cooldown/spell/final_spell = preview_spell
			preview_spell = null // ownership moves to the spell system, don't let Destroy() qdel it
			final_spell.datum_flags |= DF_VAR_EDITED
			final_spell.Grant(target)

			log_admin("[key_name(usr)] created a custom spell '[final_spell.name]' (base: [base_type]) and gave it to [key_name(target)].")
			message_admins(span_adminnotice("[key_name_admin(usr)] created a custom spell '[final_spell.name]' and gave it to [key_name(target)]."))
			to_chat(usr, span_notice("Спелл '[final_spell.name]' выдан [target.name]."))

			SStgui.close_uis(src)
			return TRUE
