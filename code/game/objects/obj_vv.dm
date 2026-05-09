/obj/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "--- /obj ---")
	VV_DROPDOWN_OPTION(VV_HK_OSAY, "Object Say")
	VV_DROPDOWN_OPTION(VV_HK_MASS_DEL_TYPE, "Delete all of type")
	if(!speed_process)
		VV_DROPDOWN_OPTION(VV_HK_MAKE_SPEEDY, "Make Speed Process")
	else
		VV_DROPDOWN_OPTION(VV_HK_MAKE_NORMAL_SPEED, "Make Normal Process")
	VV_DROPDOWN_OPTION(VV_HK_ARMOR_MOD, "Modify Armor")

/obj/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_OSAY])
		return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/object_say, src)

	if(href_list[VV_HK_MASS_DEL_TYPE])
		if(!check_rights(R_DEBUG|R_SERVER))
			return
		var/action_type = tgui_alert(usr, "Strict type ([type]) or type and all subtypes?", null, list("Strict type", "Type and subtypes", "Cancel"))
		if(action_type == "Cancel" || !action_type)
			return
		if(tgui_alert(usr, "Are you really sure you want to delete all objects of type [type]?", null, list("Yes", "No")) != "Yes")
			return
		if(tgui_alert(usr, "Second confirmation required. Delete?", null, list("Yes", "No")) != "Yes")
			return
		var/target_type = type
		switch(action_type)
			if("Strict type")
				var/deleted_count = 0
				for(var/obj/world_obj in world)
					if(world_obj.type == target_type)
						deleted_count++
						qdel(world_obj)
					CHECK_TICK
				if(!deleted_count)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type [target_type] ([deleted_count] objects deleted) ")
				message_admins(span_adminnotice("[key_name(usr)] deleted all objects of type [target_type] ([deleted_count] objects deleted) "))
			if("Type and subtypes")
				var/deleted_count = 0
				for(var/obj/world_obj in world)
					if(istype(world_obj, target_type))
						deleted_count++
						qdel(world_obj)
					CHECK_TICK
				if(!deleted_count)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type or subtype of [target_type] ([deleted_count] objects deleted) ")
				message_admins(span_adminnotice("[key_name(usr)] deleted all objects of type or subtype of [target_type] ([deleted_count] objects deleted) "))

	if(href_list[VV_HK_MAKE_SPEEDY])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return
		datum_flags |= DF_VAR_EDITED
		makeSpeedProcess()
		log_admin("[key_name(usr)] has made [src] speed process.")
		message_admins(span_adminnotice("[key_name(usr)] has made [src] speed process."))

	if(href_list[VV_HK_MAKE_NORMAL_SPEED])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return
		datum_flags |= DF_VAR_EDITED
		makeNormalProcess()
		log_admin("[key_name(usr)] has made [src] process normally")
		message_admins(span_adminnotice("[key_name(usr)] has made [src] process normally"))

	if(href_list[VV_HK_ARMOR_MOD])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return
		datum_flags |= DF_VAR_EDITED
		var/list/armorlist = armor.getList()
		var/list/displaylist

		var/result
		do
			displaylist = list()
			for(var/key in armorlist)
				displaylist += "[key] = [armorlist[key]]"
			result = tgui_input_list(usr, "Select an armor type to modify...", "Modify armor", displaylist + "(ADD ALL)" + "(SET ALL)" + "(DONE)")

			if(result == "(DONE)")
				break
			else if(result == "(ADD ALL)" || result == "(SET ALL)")
				var/new_amount = tgui_input_number(usr, result == "(ADD ALL)" ? "Enter armor to add to all types:" : "Enter new armor value for all types:", "Modify all types")
				if(isnull(new_amount))
					continue
				var/proper_amount = text2num(new_amount)
				if(isnull(proper_amount))
					continue
				for(var/key in armorlist)
					armorlist[key] = (result == "(ADD ALL)" ? armorlist[key] : 0) + proper_amount
			else if(result)
				var/list/fields = splittext(result, " = ")
				if(length(fields) != 2)
					continue
				var/type = fields[1]
				if(isnull(armorlist[type]))
					continue
				var/new_amount = tgui_input_number(usr, "Enter new armor value for [type]:", "Modify [type]")
				if(isnull(new_amount))
					continue
				var/proper_amount = text2num(new_amount)
				if(isnull(proper_amount))
					continue
				armorlist[type] = proper_amount
		while(result)

		if(!result || !QDELETED(src))
			return

		armor = armor.setRating(armorlist[MELEE], armorlist[BULLET], armorlist[LASER], armorlist[ENERGY], armorlist[BOMB], armorlist[FIRE], armorlist[ACID], armorlist[MAGIC])

		log_admin("[key_name(usr)] modified the armor on [src] to: melee = [armorlist[MELEE]], bullet = [armorlist[BULLET]], laser = [armorlist[LASER]], energy = [armorlist[ENERGY]], bomb = [armorlist[BOMB]], fire = [armorlist[FIRE]], acid = [armorlist[ACID]], magic = [armorlist[MAGIC]]")
		message_admins(span_adminnotice("[key_name(usr)] modified the armor on [src] to: melee = [armorlist[MELEE]], bullet = [armorlist[BULLET]], laser = [armorlist[LASER]], energy = [armorlist[ENERGY]], bomb = [armorlist[BOMB]], fire = [armorlist[FIRE]], acid = [armorlist[ACID]], magic = [armorlist[MAGIC]]"))

