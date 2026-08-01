/**
 * `UID_of()` returns a `UID()` for datums and `\ref` for lists,
 * so we choose the locate() method based on the string format, instead of locateUID().
 * -- LittleBoobs
 */
/proc/locate_vv_href(value)
	return (copytext(value, 1, 2) == "\[") ? locate(value) : locateUID(value)

/**
 * DO NOT add new branches to view_var_Topic() — this is a legacy dispatcher, kept only for existing handlers.
 *
 * * For new VV actions on a datum, override /datum/proc/vv_do_topic() in the appropriate type.
 * * For actions on lists, use /client/proc/vv_do_list().
 * * For basic operations, use /client/proc/vv_do_basic().
 */
/client/proc/view_var_Topic(href, href_list, hsrc)
	var/target = locate_vv_href(href_list[VV_HK_TARGET])
	vv_do_basic(target, href_list, href)
	if(isdatum(target))
		var/datum/datum = target
		datum.vv_do_topic(href_list)
	else if(islist(target))
		vv_do_list(target, href_list)

	if(href_list["Vars"])
		var/vars_target = locate_vv_href(href_list["Vars"])
		if(href_list["special_varname"]) // Some special vars can't be located even if you have their ref, you have to use this instead
			var/datum/datum_vars_target = vars_target
			vars_target = datum_vars_target.vars[href_list["special_varname"]]
		debug_variables(vars_target)

	// MARK: rename
	if(href_list["rename"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/target_mob = locateUID(href_list["rename"])
		if(!istype(target_mob))
			to_chat(usr, "This can only be used on instances of type /mob", confidential = TRUE)
			return

		var/new_name = reject_bad_name(sanitize(tgui_input_text(usr, "What would you like to name this mob?", "Input a name", target_mob.real_name, encode = FALSE, max_length = MAX_NAME_LEN)), allow_numbers = TRUE)
		if(!new_name || !target_mob)
			return

		message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(target_mob)] to [new_name].")
		target_mob.rename_character(target_mob.real_name, new_name)
		vv_update_display(target_mob, "name", new_name)
		vv_update_display(target_mob, "real_name", target_mob.real_name || "No real name")

	// MARK: rotatedatum
	else if(href_list["rotatedatum"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		var/atom/target_atom = locateUID(href_list["rotatedatum"])
		if(!istype(target_atom))
			to_chat(usr, "This can only be done to instances of type /atom", confidential = TRUE)
			return

		switch(href_list["rotatedir"])
			if("right")
				target_atom.dir = turn(target_atom.dir, -45)
			if("left")
				target_atom.dir = turn(target_atom.dir, 45)

		log_and_message_admins("has rotated [target_atom]")
		vv_update_display(target_atom, "dir", dir2text(target_atom.dir))

	// MARK: adjustDamage
	else if(href_list["adjustDamage"] && href_list["mobToDamage"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_EVENT))
			return

		var/mob/living/target_living = locateUID(href_list["mobToDamage"])
		if(!istype(target_living))
			return

		var/loss_proc_text = href_list["adjustDamage"]

		var/amount = tgui_input_number(usr, "Deal how much damage to mob? (Negative values here heal)", "Adjust [loss_proc_text]loss", 0, 1000, -1000)
		if(isnull(amount))
			return

		if(!target_living)
			to_chat(usr, "Mob doesn't exist anymore.", confidential = TRUE)
			return

		var/new_amount
		switch(loss_proc_text)
			if("brute")
				if(ishuman(target_living))
					var/mob/living/carbon/human/target_human = target_living
					target_human.adjustBruteLoss(amount, forced = TRUE, affect_robotic = TRUE)
				else
					target_living.adjustBruteLoss(amount, forced = TRUE)
				new_amount = target_living.getBruteLoss()
			if("fire")
				if(ishuman(target_living))
					var/mob/living/carbon/human/target_human = target_living
					target_human.adjustFireLoss(amount, forced = TRUE, affect_robotic = TRUE)
				else
					target_living.adjustFireLoss(amount, forced = TRUE)
				new_amount = target_living.getFireLoss()
			if("toxin")
				target_living.adjustToxLoss(amount, forced = TRUE)
				new_amount = target_living.getToxLoss()
			if("oxygen")
				target_living.adjustOxyLoss(amount, forced = TRUE)
				new_amount = target_living.getOxyLoss()
			if("brain")
				target_living.adjustBrainLoss(amount, forced = TRUE)
				new_amount = target_living.getBrainLoss()
			if("clone")
				target_living.adjustCloneLoss(amount, forced = TRUE)
				new_amount = target_living.getCloneLoss()
			if("stamina")
				target_living.adjustStaminaLoss(amount, forced = TRUE)
				new_amount = target_living.getStaminaLoss()
			else
				to_chat(usr, "You caused an error. DEBUG: Text:[loss_proc_text] Mob:[target_living]", confidential = TRUE)
				return

		if(amount != 0)
			var/log_msg = "[key_name(usr)] dealt [amount] amount of [loss_proc_text] damage to [key_name(target_living)]"
			message_admins(span_adminnotice("[key_name(usr)] dealt [amount] amount of [loss_proc_text] damage to [ADMIN_LOOKUPFLW(target_living)]"))
			log_admin(log_msg)
			vv_update_display(target_living, loss_proc_text, "[new_amount]")

	// MARK: item var tweak
	else if(href_list["item_to_tweak"] && href_list["var_tweak"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_EVENT))
			return
		var/obj/item/editing = locateUID(href_list["item_to_tweak"])
		if(!istype(editing) || QDELING(editing))
			return

		var/existing_val = -1
		switch(href_list["var_tweak"])
			if("damtype")
				existing_val = editing.damtype
			if("force")
				existing_val = editing.force
			else
				CRASH("Invalid var_tweak passed to item vv set var: [href_list["var_tweak"]]")

		var/new_val
		if(href_list["var_tweak"] == "damtype")
			new_val = tgui_input_list(usr, "Enter the new damage type for [editing]", "Set Damtype", list(BRUTE, BURN, TOX, OXY, CLONE, STAMINA, BRAIN), existing_val)
		else
			new_val = tgui_input_number(usr, "Enter the new value for [editing]'s [href_list["var_tweak"]]", "Set [href_list["var_tweak"]]", existing_val, max_value = 10000, min_value = -10000)
		if(isnull(new_val) || new_val == existing_val || QDELETED(editing) || !check_rights(R_VAREDIT))
			return

		switch(href_list["var_tweak"])
			if("damtype")
				editing.damtype = new_val
			if("force")
				editing.force = new_val

		message_admins(span_adminnotice("[key_name(usr)] set [editing]'s [href_list["var_tweak"]] to [new_val] (was [existing_val])"))
		log_admin("[key_name(usr)] set [editing]'s [href_list["var_tweak"]] to [new_val] (was [existing_val])")
		vv_update_display(editing, href_list["var_tweak"], istext(new_val) ? uppertext(new_val) : new_val)

	// MARK: datumrefresh
	if(href_list["datumrefresh"])
		var/datum = locate_vv_href(href_list["datumrefresh"])
		if(!isdatum(datum) && !isclient(datum) && !islist(datum))
			return
		debug_variables(datum)
