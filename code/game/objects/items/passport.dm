/obj/item/passport
	name = "TSF Passport"
	desc = "Паспорт Транс-Солнечной Федерации. На обложке нарисаво Солнце."
	icon = 'icons/obj/library.dmi'
	icon_state = "tsf_passport"
	var/list/avail_nations = list("tsf", "ussp")
	var/list/owner_info = list( "name" = "Error",
								"year" = 0,
								"race" = "Неопределенная",
								"gender" = "Неопределенный",
								"front" = "",
								"side" = "",
								"rand" = "None",
								"work" = list("station" = "None", "command" = "None", "system" = "None"))
	var/nation = "tsf"

/obj/item/passport/attack_self(mob/user)
	ui_interact(user)

/obj/item/passport/update_name(updates)
	. = ..()
	switch(nation)
		if("tsf")
			desc = "Паспорт Транс-Солнечной Федерации. На обложке изображено Солнце."
		if("ussp")
			desc = "Паспорт СССП. На обложке ярко блестят желтые серп и молот."

/obj/item/passport/update_desc(updates)
	. = ..()
	switch(nation)
		if("tsf")
			name = "TSF Passport"
		if("ussp")
			name = "USSP Passport"

/obj/item/passport/update_icon_state()
	icon_state = "[nation]_passport"

/obj/item/passport/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Passport", name, 400, 500, master_ui, state)
		ui.autoupdate = FALSE
		ui.open()

/obj/item/passport/ui_data(mob/user)
	var/list/data = list("ownerInfo" = owner_info, "nation" = nation)
	return data

/obj/item/passport/admin
	name = "Admin passport"
	icon_state = "passport"
	var/setted = FALSE

/obj/item/passport/admin/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	if(setted)
		..()
	else
		ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
		if(!ui)
			ui = new(user, src, ui_key, "PassportSet", name, 760, 450, master_ui, state)
			ui.set_autoupdate(FALSE)
			ui.open()

/obj/item/passport/admin/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	switch(action)
		if("set")
			switch(params["type"])
				if("Name")
					if(!(ui && ui.user))
						owner_info["name"] = "Error"
						SStgui.update_uis(src)
						return
					if(params["auto"] == "true")
						owner_info["name"] = ui.user.name
					else
						if(params["content"] != "")
							owner_info["name"] = params["content"]
				if("Age")
					owner_info["year"] = params["content"]
				if("Gender")
					var/new_gender = tgui_input_list(ui.user, "Выберите пол.", "Пол", list("Мужской", "Женский", "Неопределенный"), owner_info["gender"])
					if(new_gender)
						owner_info["gender"] = new_gender
				if("Race")
					var/new_race = tgui_input_list(ui.user, "Выберите расы.", "Раса", GLOB.russian_species, owner_info["race"])
					if(new_race)
						owner_info["race"] = new_race
				if("Rand")
					owner_info["rand"] = generate_rand_message()
				if("Station")
					if(params["auto"] == "true")
						owner_info["work"]["station"] = station_name()
					else
						if(params["content"] != "")
							owner_info["work"]["station"] = params["content"]
				if("Command")
					if(params["auto"] == "true")
						owner_info["work"]["command"] = command_name()
					else
						if(params["content"] != "")
							owner_info["work"]["command"] = params["content"]
				if("System")
					if(params["auto"] == "true")
						owner_info["work"]["system"] = system_name()
					else
						if(params["content"] != "")
							owner_info["work"]["system"] = params["content"]
				if("Photo")
					if(!ishuman(ui.user))
						return
					var/job = tgui_input_list(ui.user, "Выберите униформу.", "Униформа", GLOB.joblist)
					var/icon/front = new(get_id_photo(ui.user, job), dir = SOUTH)
					var/icon/side = new(get_id_photo(ui.user, job), dir = WEST)
					owner_info["front"] = icon2base64(front)
					owner_info["side"] = icon2base64(side)
				if("Nation")
					var/new_nation = tgui_input_list(ui.user, "Выберите государство.", "Государство", avail_nations, nation)
					if(new_nation)
						nation = new_nation
			SStgui.update_uis(src)
		if("Finish")
			ui.close()
			update_appearance()
			setted = TRUE

/obj/item/passport/admin/proc/generate_rand_message()
	var/list/message = list()
	var/devided = FALSE
	var/textmessage = ""
	var/list/pieces = list(owner_info["age"], owner_info["gender"]) + splittext(owner_info["name"], " ")
	while(length(textmessage) < 100)
		if(!devided && length(textmessage) > 50)
			message += "\n"
			devided = TRUE
			continue

		var/piece = ""
		var/type = rand(1,3)
		switch(type)
			if(1)
				piece = pick_n_take(pieces)
			if(2)
				for(var/i in 1 to rand(1, 5))
					message += "<"
				continue
			if(3)
				piece = rand(1000, 999999)

		message += piece
		message += "<"
		textmessage = message.Join()
	return textmessage

