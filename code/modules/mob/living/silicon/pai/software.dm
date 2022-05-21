GLOBAL_LIST_INIT(pai_emotions, list(
		"Счастье" = 1,
		"Кот" = 2,
		"Невероятное счастье" = 3,
		"Лицо" = 4,
		"Смех" = 5,
		"Выкл" = 6,
		"Грусть" = 7,
		"Злость" = 8,
		"Что?" = 9
))

GLOBAL_LIST_EMPTY(pai_software_by_key)

/mob/living/silicon/pai/verb/paiInterface()
	set category = "Команды ПИИ"
	set name = "Программный интерфейс"

	ui_interact(src)

/mob/living/silicon/pai/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.self_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PAI", name, 600, 650, master_ui, state)
		ui.open()

/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["app_template"] = active_software.template_file
	data["app_icon"] = active_software.ui_icon
	data["app_title"] = active_software.name
	data["app_data"] = active_software.get_app_data(user)

	return data

// Yes the stupid amount of args here is important, so we can proxy stuff to child UIs
/mob/living/silicon/pai/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		// This call is global to all templates, hence the prefix
		if("MASTER_back")
			active_software = installed_software["mainmenu"]
			// Bail early
			return
		else
			active_software.ui_act(action, params, ui, state)
