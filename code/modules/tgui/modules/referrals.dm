/datum/ui_module/referrals
	name = "Реферальная система"
	var/list/stats = list()
	var/last_error

/datum/ui_module/referrals/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/referrals/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	stats = user.client.referral_stats()
	ui = new(user, src, "Referrals", name)
	ui.set_autoupdate(FALSE)
	ui.open()

/datum/ui_module/referrals/ui_data(mob/user)
	var/list/data = stats.Copy()
	data["error"] = last_error
	return data

/datum/ui_module/referrals/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("apply")
			last_error = usr.client.apply_referral_code(params["code"])
			if(!last_error)
				to_chat(usr, custom_boxed_message("green_box", span_darkmblue("Код принят! Как только вы освоитесь на станции, пригласивший вас игрок получит уровень подписки.")), confidential = TRUE)
			stats = usr.client.referral_stats()
		if("refresh")
			last_error = null
			stats = usr.client.referral_stats()
		else
			return FALSE
