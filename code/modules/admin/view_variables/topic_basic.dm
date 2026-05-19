/**
 * Core topics are VV topics which should work even if the code responsible for processing vv topics for that datum is runtiming.
 * They're kept separately from [/datum/proc/vv_do_topic] for that reason.
 */
/client/proc/vv_do_basic(datum/target, href_list)
	var/target_var = GET_VV_VAR_TARGET
	if(target_var)
		if(!check_rights(R_VAREDIT))
			return
		// MARK: basic_edit
		if(href_list[VV_HK_BASIC_EDIT])
			if(!modify_variables(target, target_var, TRUE))
				return
			switch(target_var)
				if("name")
					vv_update_display(target, "name", "[target]")
				if("dir")
					var/atom/target_atom = target
					if(istype(target_atom))
						vv_update_display(target, "dir", dir2text(target_atom.dir) || target_atom.dir)
				if("ckey")
					var/mob/living/target_living = target
					if(istype(target_living))
						vv_update_display(target, "ckey", target_living.ckey || "No ckey")
				if("real_name")
					var/mob/living/target_living = target
					if(istype(target_living))
						vv_update_display(target, "real_name", target_living.real_name || "No real name")

		// MARK: basic change
		if(href_list[VV_HK_BASIC_CHANGE])
			modify_variables(target, target_var, FALSE)

		// MARK: mass edit
		if(href_list[VV_HK_BASIC_MASSEDIT])
			cmd_mass_modify_object_variables(target, target_var)

	// MARK: expose
	if(href_list[VV_HK_EXPOSE])
		if(!check_rights(R_ADMIN))
			return
		var/value = vv_get_value(VV_CLIENT)
		if(value["class"] != VV_CLIENT)
			return
		var/client/target_client = value["value"]
		if(!target_client)
			return
		if(!target)
			to_chat(usr, span_warning("The object you tried to expose to [target_client] no longer exists (nulled or hard-deled)"), confidential = TRUE)
			return
		message_admins(span_adminnotice("[key_name_admin(usr)] Showed [key_name_admin(target_client)] a <a href='byond://?_src_=vars;datumrefresh=[UID_of(target)]'>VV window</a>"))
		log_admin("Admin [key_name(usr)] Showed [key_name(target_client)] a VV window of a [target]")
		to_chat(target_client, span_notice("[holder.fakekey ? "an Administrator" : "[usr.client.key]"] has granted you access to view a View Variables window"), confidential = TRUE)
		target_client.debug_variables(target)

	// MARK: delete
	if(href_list[VV_HK_DELETE])
		if(!check_rights(R_DEBUG))
			return

		usr.client.admin_delete(target)
		if(isturf(target)) // show the turf that took its place
			usr.client.debug_variables(target)
			return

	// MARK: mark datum
	if(href_list[VV_HK_MARK])
		if(!check_rights(R_VIEWRUNTIMES|R_ADMIN))
			return
		usr.client.mark_datum(target)

	// MARK: tag datum
	if(href_list[VV_HK_TAG])
		if(!check_rights(R_VIEWRUNTIMES|R_ADMIN))
			return
		usr.client.tag_datum(target)

	// MARK: add component
	if(href_list[VV_HK_ADDCOMPONENT])
		if(!check_rights(R_DEBUG|R_EVENT))
			return
		var/list/names = list()
		var/list/componentsubtypes = sort_list(subtypesof(/datum/component), GLOBAL_PROC_REF(cmp_typepaths_asc))
		names += "---Components---"
		names += componentsubtypes
		names += "---Elements---"
		names += sort_list(subtypesof(/datum/element), GLOBAL_PROC_REF(cmp_typepaths_asc))
		var/result = tgui_input_list(usr, "Choose a component/element to add", "Add Component", names)
		if(isnull(result))
			return
		if(!usr || result == "---Components---" || result == "---Elements---")
			return
		if(QDELETED(src))
			to_chat(usr, "That thing doesn't exist anymore!", confidential = TRUE)
			return
		var/add_source
		if(ispath(result, /datum/component))
			var/datum/component/comp_path = result
			if(initial(comp_path.dupe_mode) == COMPONENT_DUPE_SOURCES)
				add_source = tgui_input_text(usr, "Enter a source for the component", "Add Component", "ADMIN-ABUSE")
				if(isnull(add_source))
					return
		var/list/args_list = get_callproc_args()
		if(!args_list)
			return
		var/datumname = "error"
		args_list.Insert(1, result)
		if(result in componentsubtypes)
			datumname = "component"
			target._AddComponent(args_list, add_source)
		else
			datumname = "element"
			target._AddElement(args_list)
		log_admin("[key_name(usr)] has added [result] [datumname] to [key_name(target)].")
		message_admins(span_notice("[key_name_admin(usr)] has added [result] [datumname] to [key_name_admin(target)]."))

	// MARK: remove component
	if(href_list[VV_HK_REMOVECOMPONENT] || href_list[VV_HK_MASS_REMOVECOMPONENT])
		if(!check_rights(R_DEBUG|R_EVENT))
			return
		var/mass_remove = href_list[VV_HK_MASS_REMOVECOMPONENT]
		var/list/components = target._datum_components.Copy()
		var/list/names = list()
		names += "---Components---"
		if(length(components))
			names += sort_list(components, GLOBAL_PROC_REF(cmp_typepaths_asc))
		names += "---Elements---"
		// We have to list every element here because there is no way to know what element is on this object without doing some sort of hack.
		names += sort_list(subtypesof(/datum/element), GLOBAL_PROC_REF(cmp_typepaths_asc))
		var/path = tgui_input_list(usr, "Choose a component/element to remove. All elements listed here may not be on the datum.", "Remove element", names)
		if(isnull(path))
			return
		if(!usr || path == "---Components---" || path == "---Elements---")
			return
		if(QDELETED(src))
			to_chat(usr, "That thing doesn't exist anymore!")
			return
		var/list/targets_to_remove_from = list(target)
		if(mass_remove)
			var/method = vv_subtype_prompt(target.type)
			targets_to_remove_from = get_all_of_type(target.type, method)
			if(tgui_alert(usr, "Are you sure you want to mass-delete [path] on [target.type]?", "Mass Remove Confirmation", list("Yes", "No")) == "No")
				return
		for(var/datum/target_to_remove_from as anything in targets_to_remove_from)
			if(ispath(path, /datum/element))
				var/list/args_list = get_callproc_args()
				if(!args_list)
					args_list = list()
				args_list.Insert(1, path)
				target._RemoveElement(args_list)
			else
				var/list/components_actual = target_to_remove_from.GetComponents(path)
				for(var/to_delete in components_actual)
					qdel(to_delete)
		message_admins(span_notice("[key_name_admin(usr)] has [mass_remove? "mass" : ""] removed [path] component from [mass_remove? target.type : key_name_admin(target)]."))

	// MARK: greyscale
	if(href_list[VV_HK_MODIFY_GREYSCALE])
		if(!check_rights(R_VAREDIT))
			return
		var/datum/greyscale_modify_menu/menu = new(target, usr, SSgreyscale.configurations, unlocked = TRUE)
		menu.ui_interact(usr)

	// MARK: call proc
	if(href_list[VV_HK_CALLPROC])
		return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/call_proc_datum, target)
