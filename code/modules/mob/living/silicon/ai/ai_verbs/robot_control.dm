/datum/robot_control
	var/mob/living/silicon/ai/owner

/datum/robot_control/New(mob/living/silicon/ai/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/robot_control/proc/is_interactable(mob/user)
	if(user != owner || owner.stat || owner.lacks_power() || owner.aiRadio.disabledAi)
		if(owner.lacks_power())
			to_chat(user, span_warning("Сбой в энергосистеме!"))
		if(owner.aiRadio.disabledAi)
			to_chat(user, span_warning("Системная ошибка — приемопередатчик не работает!"))
		return FALSE
	if(owner.control_disabled)
		to_chat(user, span_warning("Беспроводное управление отключено."))
		return FALSE
	return TRUE

/datum/robot_control/ui_status(mob/user, datum/ui_state/state)
	if(is_interactable(user))
		return ..()
	return UI_CLOSE

/datum/robot_control/ui_state(mob/user)
	return GLOB.always_state

/datum/robot_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RemoteRobotControl", "Дистанционное управление ботами")
		ui.open()

/datum/robot_control/ui_data(mob/user)
	if(!owner || user != owner)
		return
	var/list/data = list()
	var/turf/ai_current_turf = get_turf(owner)

	data["robots"] = list()
	for(var/mob/living/our_bot as anything in GLOB.bots_list)
		if(!isbot(our_bot) || !is_valid_z_level(ai_current_turf, get_turf(our_bot)))
			continue

		//if(isbasicbot(our_bot))
		//	var/mob/living/basic/bot/basic_bot = our_bot
		//	if(!(basic_bot.bot_mode_flags & BOT_MODE_REMOTE_ENABLED))
		//		continue
		//	var/list/basic_bot_data = list(
		//		name = basic_bot.name,
		//		model = basic_bot.bot_type,
		//		mode = basic_bot.mode,
		//		hacked = !!(basic_bot.bot_access_flags & BOT_COVER_HACKED),
		//		location = get_area_name(basic_bot, TRUE),
		//		ref = basic_bot.UID(),
		//	)
		//	data["robots"] += list(basic_bot_data)
		//	continue

		var/mob/living/simple_animal/bot/simple_bot = our_bot
		if(simple_bot.remote_disabled || owner.control_disabled)
			continue
		var/list/simple_bot_data = list(
			name = simple_bot.name,
			model = simple_bot.bot_type,
			mode = simple_bot.get_mode(),
			hacked = simple_bot.hacked,
			location = get_area_name(simple_bot, TRUE),
			ref = simple_bot.UID(),
		)
		data["robots"] += list(simple_bot_data)

	return data

/datum/robot_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !isliving(ui.user))
		return
	var/mob/living/our_user = ui.user
	if(!is_interactable(our_user))
		return
	if(owner.control_disabled)
		return
	var/selected_UID = params["ref"]
	var/mob/living/bot = locateUID(selected_UID)
	if(isnull(bot))
		return

	switch(action)
		if("callbot") //Command a bot to move to a selected location.
			//if(isbasicbot(bot))
			//	var/mob/living/basic/bot/basic_bot = bot
			//	if(!(basic_bot.bot_mode_flags & BOT_MODE_REMOTE_ENABLED))
			//		return
			//else
			var/mob/living/simple_animal/bot/simple_bot = bot
			if(simple_bot.remote_disabled || owner.control_disabled)
				return

			owner.bot_ref = WEAKREF(bot)
			owner.setting_waypoint = TRUE
			to_chat(our_user, span_notice("Укажите место назначения, кликнув на свободную от препятствий точку на карте."))
		if("interface") //Remotely connect to a bot!
			owner.bot_ref = WEAKREF(bot)
			//if(isbasicbot(bot))
			//	var/mob/living/basic/bot/basic_bot = bot
			//	if(!(basic_bot.bot_mode_flags & BOT_MODE_REMOTE_ENABLED))
			//		return
			//else
			var/mob/living/simple_animal/bot/simple_bot = bot
			if(simple_bot.remote_disabled || owner.control_disabled)
				return
			bot.attack_ai(our_user)

	return TRUE
