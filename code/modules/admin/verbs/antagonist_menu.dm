/datum/ui_module/admin/antagonist_menu
	name = "Antagonist Menu"
	var/list/cached_data
	COOLDOWN_DECLARE(cache_cooldown)

/datum/ui_module/admin/antagonist_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminAntagMenu")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/admin/antagonist_menu/ui_data(mob/user)
	if(COOLDOWN_FINISHED(src, cache_cooldown))
		update_cached_data()
		COOLDOWN_START(src, cache_cooldown, 1 SECONDS)
	return cached_data

/datum/ui_module/admin/antagonist_menu/proc/update_cached_data()
	cached_data = list()
	cached_data["antagonists"] = list()
	var/list/antagonists = cached_data["antagonists"]
	prepare_nodatum_antags(cached_data, antagonists)
	for(var/datum/antagonist/antagonist as anything in GLOB.antagonists)
		var/datum/mind/antag_mind = antagonist.owner
		if(!antag_mind || !antagonist.check_anatag_menu_ability())
			continue
		prepare_antag_data(antag_mind, cached_data, antagonist.get_antag_menu_name(), antagonists)

	cached_data["objectives"] = list()
	for(var/datum/objective/objective as anything in GLOB.all_objectives)
		if(!objective.check_anatag_menu_ability())
			continue
		var/list/temp_list = list()
		temp_list["obj_name"] = objective.antag_menu_name || objective.name || objective.type
		temp_list["obj_desc"] = objective.explanation_text
		temp_list["obj_uid"] = objective.UID()

		temp_list["status"] = objective.completed
		if(!objective.owner)
			temp_list["owner_uid"] = "Это дерьмо сломано"
			temp_list["owner_name"] = "???"
			if(istype(objective.owner, /datum/mind))
				// special handling for contractor objectives I guess
				temp_list["owner_uid"] = objective.owner.UID()
				temp_list["owner_name"] = objective.owner.name
		else
			var/datum/thingy = objective.owner
			temp_list["owner_uid"] = thingy.UID()
			if(istype(thingy, /datum/antagonist))
				var/datum/antagonist/antag = thingy
				temp_list["owner_name"] = antag.owner.name
			else
				temp_list["owner_name"] = "[thingy]"

		var/datum/the_target = objective.target
		temp_list["no_target"] = (!objective.needs_target && !the_target)
		temp_list["target_name"] = "\[Нет назначенной цели\]"
		temp_list["track"] = list()
		if(istype(the_target, /datum/mind))
			var/datum/mind/mind = the_target
			temp_list["target_name"] = mind.name
			temp_list["track"] = list(the_target.UID())

		if(istype(objective, /datum/objective/steal))
			var/datum/objective/steal/steal_obj = objective
			var/datum/theft_objective/theft = steal_obj.steal_target
			if(!theft)
				continue
			temp_list["target_name"] = theft.name
			var/list/target_uids = list()
			for(var/atom/target in GLOB.high_value_items)
				if(!istype(target, theft.typepath))
					continue
				var/turf/T = get_turf(target)
				if(!T || is_admin_level(T.z))
					continue
				target_uids += target.UID()
			temp_list["track"] = target_uids

		cached_data["objectives"] += list(temp_list)

	cached_data["high_value_items"] = list()
	for(var/atom/target in GLOB.high_value_items)
		if(QDELETED(target))
			continue
		var/list/temp_list = list()
		temp_list["name"] = target.name
		temp_list["person"] = get(target, /mob/living)
		temp_list["loc"] = target.loc.name
		temp_list["uid"] = target.UID()
		var/turf/T = get_turf(target)
		temp_list["admin_z"] = !T || is_admin_level(T.z)
		cached_data["high_value_items"] += list(temp_list)

	cached_data["security"] = list()
	var/list/security_list = SSticker.mode.get_all_sec()
	security_list |= SSticker.mode.ert
	for(var/mob/living/silicon/robot/robot in GLOB.silicon_mob_list)
		if(robot.mind && istype(robot.module, /obj/item/robot_module/security))
			security_list |= robot.mind

	for(var/datum/mind/sec_mind as anything in security_list)
		var/mob/living/carbon/human/player = sec_mind.current
		var/role = determine_role(player)
		var/list/temp_list = list()
		temp_list["name"] = (!player)? sec_mind.name : player.real_name
		temp_list["role"] = (!isrobot(player))? role : \
							(sec_mind.special_role == SPECIAL_ROLE_ERT )? "ОБР [role]" : "СБ [role]"
		temp_list["mind_uid"] = sec_mind.UID()
		temp_list["ckey"] = ckey(sec_mind.key)
		temp_list["status"] = player.stat
		temp_list["antag"] = (isAntag(player) && sec_mind.special_role != SPECIAL_ROLE_ERT ? sec_mind.special_role : "")
		temp_list["broken_bone"] = FALSE
		temp_list["internal_bleeding"] = FALSE
		if(istype(player))
			for(var/name in player.bodyparts_by_name)
				var/obj/item/organ/external/e = player.bodyparts_by_name[name]
				if(!e)
					continue
				temp_list["broken_bone"] |= (e.status & ORGAN_BROKEN)
				temp_list["internal_bleeding"] |= (e.status & ORGAN_INT_BLEED)
		temp_list["health"] = player.health
		temp_list["max_health"] = player.maxHealth
		cached_data["security"] += list(temp_list)


/datum/ui_module/admin/antagonist_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("refresh")
			return TRUE
		if("show_player_panel")
			var/datum/mind/mind = locateUID(params["mind_uid"])
			if(QDELETED(mind.current))
				to_chat(ui.user, span_warning("У разума нет соответствующего моба."))
				return
			ui.user.client.holder.show_player_panel(mind.current)
		if("pm")
			ui.user.client.cmd_admin_pm(params["ckey"], null)
		if("follow")
			var/client/C = ui.user.client
			if(!isobserver(ui.user))
				if(!check_rights(R_ADMIN|R_MOD)) // Need to be mod or admin to aghost
					return
				C.admin_ghost()
			var/datum/target = locateUID(params["datum_uid"])
			if(QDELETED(target))
				to_chat(ui.user, span_warning("Датум удален!"))
				return

			if(istype(target, /datum/mind))
				var/datum/mind/mind = target
				if(!ismob(mind.current))
					to_chat(ui.user, span_warning("Это можно использовать только для экземпляров типа /mob."))
					return
				target = mind.current

			var/mob/dead/observer/A = C.mob
			A.ManualFollow(target)
		if("obs")
			var/client/C = ui.user.client
			var/datum/mind/mind = locateUID(params["mind_uid"])

			if(!ismob(mind.current))
				to_chat(ui.user, span_warning("Это можно использовать только для экземпляров типа /mob."))
				return
			C.admin_observe_target(mind.current, TRUE)
		if("tp")
			var/datum/mind/mind = locateUID(params["mind_uid"])
			if(QDELETED(mind))
				to_chat(ui.user, span_warning("Нет разума!"))
				return
			mind.edit_memory()
		if("vv")
			ui.user.client.debug_variables(locateUID(params["uid"]), null)
		if("obj_owner")
			var/client/C = ui.user.client
			var/datum/target = locateUID(params["owner_uid"])
			if(QDELETED(target))
				to_chat(ui.user, span_warning("Цель, которую вы ищете, не существует или была удалена."))
				return
			if(istype(target, /datum/antagonist))
				var/datum/antagonist/antag = target
				target = antag.owner
			if(istype(target, /datum/mind))
				var/datum/mind/mind = target
				if(!ismob(mind.current))
					to_chat(ui.user, span_warning("Это можно использовать только для экземпляров типа /mob."))
					return
				target = mind.current
				var/mob/dead/observer/A = C.mob
				A.ManualFollow(target)
				return
			if(istype(target, /datum/team))
				ui.user.client.holder.check_teams()
				return
			to_chat(ui.user, span_warning("Тип [target.type] не поддерживает поиск владельца цели."))
