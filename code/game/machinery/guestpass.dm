////////////////////////////////////////////
// MARK: Guest pass
////////////////////////////////////////////
/obj/item/card/id/guest
	name = "guest pass"
	desc = "Allows temporary access to station areas."
	icon_state = "guest"
	item_state = "guestpass-id"

	var/temp_access = list() //to prevent agent cards stealing access as permanent
	var/expiration_time = 0
	var/reason = ""

/obj/item/card/id/guest/GetAccess()
	if(world.time > expiration_time)
		return access
	else
		return temp_access

/obj/item/card/id/guest/examine(mob/user)
	. = ..()
	if(world.time < expiration_time)
		. += span_notice("This pass expires at [station_time_timestamp("hh:mm:ss", expiration_time)].")
	else
		. += span_warning("It expired at [station_time_timestamp("hh:mm:ss", expiration_time)].")
	. += span_notice("It grants access to following areas:")
	for(var/A in temp_access)
		. += span_notice("[get_access_desc(A)].")
	. += span_notice("Issuing reason: [reason].")

////////////////////////////////////////////
// MARK: Guest pass terminal
////////////////////////////////////////////

/obj/machinery/computer/guestpass
	name = "guest pass terminal"
	icon_state = "guest"
	icon_screen = "pass"
	icon_keyboard = null
	density = FALSE

	var/obj/item/card/id/giver
	var/list/accesses = list()
	var/giv_name = ""
	var/reason = ""
	var/duration = 5

	var/list/internal_log = list()
	var/mode = 0  // 0 - making pass, 1 - viewing logs
	var/list/region_map = list(
		"Service" = REGION_GENERAL,
		"Security" = REGION_SECURITY,
		"Medical" = REGION_MEDBAY,
		"Science" = REGION_RESEARCH,
		"Engineering" = REGION_ENGINEERING,
		"Supply" = REGION_SUPPLY,
		"Command" = REGION_COMMAND
	)
	var/uid

/obj/machinery/computer/guestpass/Initialize(mapload, obj/structure/computerframe/frame)
	uid = rand(1, 10000)
	. = ..()

/obj/machinery/computer/guestpass/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_id_card(I))
		add_fingerprint(user)
		if(giver)
			to_chat(user, span_warning("There is already ID card inside."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		giver = I
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/machinery/computer/guestpass/proc/get_changeable_accesses()
	return giver.access

/obj/machinery/computer/guestpass/syndicate
	name = "Syndicate guest pass terminal"

/obj/machinery/computer/guestpass/hop
	name = "HoP guest pass terminal"

/obj/machinery/computer/guestpass/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/guestpass/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GuestPassTerminal", name)
		ui.open()

/obj/machinery/computer/guestpass/ui_data(mob/user)
	var/list/data = list()
	data["mode"] = mode
	data["giver_name"] = giver ? "[giver.registered_name] ([giver.assignment])" : null
	data["giv_name"] = "[giv_name]"
	data["reason"] = "[reason]"
	data["duration"] = duration
	data["logs"] = internal_log ? internal_log : list()

	var/list/regions = list()
	var/list/selectedAccess = list()
	var/list/grantableList = list()

	if(giver)
		selectedAccess = accesses
		grantableList = get_changeable_accesses()

		for(var/region in region_map)
			var/list/accs = list()
			for(var/region_ref in get_region_accesses(region_map[region]))
				var/access_name = get_access_desc(region_ref)
				if(!access_name)
					continue

				accs += list(list(
					"ref" = region_ref,
					"desc" = "[access_name]",
					"name" = "[access_name]"
				))

			if(length(accs))
				regions += list(list(
					"name" = region,
					"regid" = region_map[region],
					"accesses" = accs
				))

	data["regions"] = regions
	data["selectedAccess"] = selectedAccess
	data["grantableList"] = grantableList
	return data

/obj/machinery/computer/guestpass/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("set_mode")
			mode = text2num(params["mode"])
			return TRUE

		if("eject_id")
			if(!giver)
				return TRUE
			if(ishuman(usr))
				giver.forceMove(usr.loc)
				usr.put_in_hands(giver)
			else
				giver.forceMove(loc)
			giver = null
			accesses.Cut()
			return TRUE

		if("set_name")
			giv_name = strip_html_simple(params["value"])
			return TRUE

		if("set_reason")
			reason = strip_html_simple(params["value"])
			return TRUE

		if("set_duration")
			var/value_duration = text2num(params["value"])
			duration = clamp(round(value_duration), 1, 30)
			return TRUE

		if("toggle_access")
			var/value_id = text2num(params["id"])
			if(value_id in accesses)
				accesses -= value_id
			else if(value_id in get_changeable_accesses())
				accesses |= value_id
			return TRUE

		if("grant_all")
			accesses |= get_changeable_accesses()
			return TRUE

		if("deny_all")
			accesses.Cut()
			return TRUE

		if("grant_region")
			var/rid = text2num(params["region"])
			accesses |= (get_region_accesses(rid) & get_changeable_accesses())
			return TRUE

		if("deny_region")
			var/rid = text2num(params["region"])
			accesses -= get_region_accesses(rid)
			return TRUE

		if("issue")
			if(!giver)
				to_chat(usr, span_warning("Необходима ID-карта для авторизации!"))
				return TRUE

			var/number = add_zero("[rand(0,9999)]", 4)
			var/current_time = station_time_timestamp()
			var/current_date = GLOB.current_date_string
			var/expire_timestamp = world.time + (duration * 600)
			var/expire_time_only = time2text(expire_timestamp, "hh:mm:ss")
			var/safe_giv_name = giv_name ? giv_name : "неизвестного"
			var/safe_reason = reason ? reason : "не указана"
			var/log_msg = "[current_date] [current_time] Пропуск #[number]: выдан \"[giver.registered_name]\" для \"[safe_giv_name]\". Причина: \"[safe_reason]\". Истекает в [current_date] [expire_time_only]."
			internal_log += log_msg

			var/obj/item/card/id/guest/pass = new(src.loc)
			if(pass)
				pass.temp_access = accesses.Copy()
				pass.registered_name = (safe_giv_name == "неизвестного") ? "Guest" : safe_giv_name
				pass.expiration_time = expire_timestamp
				pass.reason = (safe_reason == "не указана") ? "None" : safe_reason
				pass.name = "temporary pass #[number]"

			playsound(loc, 'sound/machines/twobeep.ogg', 50, TRUE)
			accesses.Cut()
			return TRUE
