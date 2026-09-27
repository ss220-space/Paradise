ADMIN_VERB(dynamic_panel, R_ADMIN, "Dynamic Panel", "Inspect and steer the dynamic game mode.", ADMIN_CATEGORY_GAME)
	var/datum/dynamic_panel/panel = new
	panel.ui_interact(user.mob)

/datum/dynamic_panel
	var/list/ruleset_catalogue

/datum/dynamic_panel/New()
	. = ..()
	build_catalogue()

/datum/dynamic_panel/proc/build_catalogue()
	ruleset_catalogue = list(
		DYNAMIC_ROUNDSTART = list(),
		DYNAMIC_MIDROUND = list(),
		DYNAMIC_LATEJOIN = list(),
	)
	for(var/ruleset_type in subtypesof(/datum/dynamic_ruleset))
		var/datum/dynamic_ruleset/ruleset = new ruleset_type
		if(!ruleset.config_tag)
			qdel(ruleset)
			continue

		var/category = DYNAMIC_ROUNDSTART
		if(istype(ruleset, /datum/dynamic_ruleset/midround))
			category = DYNAMIC_MIDROUND
		else if(istype(ruleset, /datum/dynamic_ruleset/latejoin))
			category = DYNAMIC_LATEJOIN

		ruleset_catalogue[category] += list(list(
			"name" = ruleset.name,
			"id" = ruleset.config_tag,
			"typepath" = "[ruleset_type]",
			"weight" = format_tier_value(ruleset, ruleset.weight),
			"min_pop" = format_tier_value(ruleset, ruleset.min_pop),
			"min_round_time" = format_tier_value(ruleset, ruleset.min_round_time, 1 MINUTES),
			"high_impact" = !!(ruleset.ruleset_flags & RULESET_HIGH_IMPACT),
		))
		qdel(ruleset)

/datum/dynamic_panel/proc/format_tier_value(datum/dynamic_ruleset/ruleset, value, divisor = 1)
	if(!isalist(value))
		return "[value / divisor]"
	var/list/per_tier = list()
	for(var/tier in DYNAMIC_TIER_GREEN to DYNAMIC_TIER_HIGH)
		per_tier += "[ruleset.get_tier_value(value, tier) / divisor]"
	return per_tier.Join("/")

/datum/dynamic_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/dynamic_panel/ui_close(mob/user)
	qdel(src)

/datum/dynamic_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DynamicPanel")
		ui.open()

/datum/dynamic_panel/ui_static_data(mob/user)
	var/list/data = list()
	data["all_rulesets"] = ruleset_catalogue
	return data

/datum/dynamic_panel/ui_data(mob/user)
	var/list/data = list()
	var/datum/game_mode/dynamic/mode = SSticker.mode
	if(!istype(mode))
		mode = null

	data["mode_running"] = !!mode
	data["round_started"] = SSticker.HasRoundStarted()

	var/datum/dynamic_tier/forced_tier = GLOB.dynamic_forced_tier
	data["forced_tier"] = forced_tier ? forced_tier::name : null
	if(mode?.current_tier)
		data["current_tier"] = list(
			"number" = mode.current_tier.tier,
			"name" = mode.current_tier.name,
		)

	data["ruleset_count"] = list()
	data["active_rulesets"] = list()
	if(mode)
		for(var/category in mode.rulesets_to_spawn)
			data["ruleset_count"][category] = max(mode.rulesets_to_spawn[category], 0)
		data["time_until_midround"] = COOLDOWN_TIMELEFT(mode, midround_cooldown)
		data["time_until_latejoin"] = COOLDOWN_TIMELEFT(mode, latejoin_cooldown)
		for(var/datum/dynamic_ruleset/ruleset as anything in mode.executed_rulesets)
			var/list/players = list()
			for(var/datum/mind/selected as anything in ruleset.selected_minds)
				players += selected.name
			data["active_rulesets"] += list(list(
				"name" = ruleset.name,
				"id" = ruleset.config_tag,
				"players" = players,
			))

	data["queued_rulesets"] = list()
	for(var/i in 1 to length(GLOB.dynamic_queued_rulesets))
		var/datum/dynamic_ruleset/queued = GLOB.dynamic_queued_rulesets[i]
		data["queued_rulesets"] += list(list(
			"name" = queued::name,
			"id" = queued::config_tag,
			"index" = i,
		))

	data["disabled_rulesets"] = list()
	for(var/ruleset_type in GLOB.dynamic_disabled_rulesets)
		data["disabled_rulesets"] += "[ruleset_type]"

	return data

/datum/dynamic_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE

	var/mob/admin = ui.user
	var/datum/game_mode/dynamic/mode = SSticker.mode
	if(!istype(mode))
		mode = null

	switch(action)
		if("set_tier")
			if(SSticker.HasRoundStarted())
				return TRUE
			var/list/tier_choices = list("Случайный" = null)
			for(var/datum/dynamic_tier/tier_type as anything in subtypesof(/datum/dynamic_tier))
				tier_choices[tier_type::name] = tier_type
			var/chosen = tgui_input_list(admin, "Какой тир форсировать?", "Dynamic", tier_choices, ui_state = ADMIN_STATE(R_ADMIN))
			if(isnull(chosen) || SSticker.HasRoundStarted())
				return TRUE
			GLOB.dynamic_forced_tier = tier_choices[chosen]
			log_and_message_admins("has set the forced dynamic tier to [chosen]")
			return TRUE

		if("add_ruleset_count")
			var/category = params["category"]
			if(!mode || !(category in mode.rulesets_to_spawn))
				return TRUE
			mode.rulesets_to_spawn[category]++
			log_and_message_admins("has added a [category] dynamic ruleset slot")
			return TRUE

		if("zero_ruleset_count")
			var/category = params["category"]
			if(!mode || !(category in mode.rulesets_to_spawn))
				return TRUE
			mode.rulesets_to_spawn[category] = 0
			log_and_message_admins("has zeroed the [category] dynamic ruleset slots")
			return TRUE

		if("queue_ruleset")
			var/datum/dynamic_ruleset/ruleset_type = text2path(params["ruleset_type"])
			var/is_roundstart = ispath(ruleset_type, /datum/dynamic_ruleset/roundstart)
			if(!is_roundstart && !ispath(ruleset_type, /datum/dynamic_ruleset/latejoin))
				return TRUE
			if(is_roundstart && SSticker.HasRoundStarted())
				return TRUE
			GLOB.dynamic_queued_rulesets += ruleset_type
			log_and_message_admins("has queued the dynamic ruleset [ruleset_type::config_tag]")
			return TRUE

		if("unqueue_ruleset")
			var/index = params["index"]
			if(!isnum(index) || index < 1 || index > length(GLOB.dynamic_queued_rulesets))
				return TRUE
			var/datum/dynamic_ruleset/removed = GLOB.dynamic_queued_rulesets[index]
			GLOB.dynamic_queued_rulesets.Cut(index, index + 1)
			log_and_message_admins("has removed the dynamic ruleset [removed::config_tag] from the queue")
			return TRUE

		if("execute_ruleset")
			var/datum/dynamic_ruleset/ruleset_type = text2path(params["ruleset_type"])
			if(!mode || !ispath(ruleset_type, /datum/dynamic_ruleset/midround))
				return TRUE
			log_and_message_admins("has forced the dynamic ruleset [ruleset_type::config_tag]")
			INVOKE_ASYNC(mode, TYPE_PROC_REF(/datum/game_mode/dynamic, force_ruleset), ruleset_type, admin)
			return TRUE

		if("toggle_ruleset")
			var/datum/dynamic_ruleset/ruleset_type = text2path(params["ruleset_type"])
			if(!ispath(ruleset_type, /datum/dynamic_ruleset))
				return TRUE
			if(ruleset_type in GLOB.dynamic_disabled_rulesets)
				GLOB.dynamic_disabled_rulesets -= ruleset_type
				log_and_message_admins("has re-enabled the dynamic ruleset [ruleset_type::config_tag]")
				return TRUE
			GLOB.dynamic_disabled_rulesets += ruleset_type
			log_and_message_admins("has disabled the dynamic ruleset [ruleset_type::config_tag]")
			return TRUE

		if("disable_all")
			for(var/datum/dynamic_ruleset/ruleset_type as anything in subtypesof(/datum/dynamic_ruleset))
				if(!ruleset_type::config_tag)
					continue
				GLOB.dynamic_disabled_rulesets |= ruleset_type
			log_and_message_admins("has disabled every dynamic ruleset")
			return TRUE

		if("enable_all")
			GLOB.dynamic_disabled_rulesets.Cut()
			log_and_message_admins("has re-enabled every dynamic ruleset")
			return TRUE

		if("reset_midround_cooldown")
			if(!mode)
				return TRUE
			COOLDOWN_RESET(mode, midround_cooldown)
			log_and_message_admins("has reset the dynamic midround cooldown")
			return TRUE

		if("reset_latejoin_cooldown")
			if(!mode)
				return TRUE
			COOLDOWN_RESET(mode, latejoin_cooldown)
			log_and_message_admins("has reset the dynamic latejoin cooldown")
			return TRUE

		if("roll_midround")
			if(!mode?.current_tier)
				return TRUE
			mode.rulesets_to_spawn[DYNAMIC_MIDROUND]++
			log_and_message_admins("has rolled an extra dynamic midround ruleset")
			if(!mode.try_spawn_midround())
				mode.rulesets_to_spawn[DYNAMIC_MIDROUND]--
			return TRUE

		if("vv")
			if(!mode)
				return TRUE
			admin.client?.debug_variables(mode)
			return TRUE
