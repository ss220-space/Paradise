// Speeds up the offering process and optionally allows the admin to set up playtime requirement and "Show role" only once.
// Default setting is 20H like the default recommendation for offering from drop down menu.
/datum/buildmode_mode/offer
	key = "offer"
	var/hours = 20
	var/hide_role

/datum/buildmode_mode/offer/show_help(mob/user)
	to_chat(user, span_purple(chat_box_examine(
		"[span_bold("Предложить существо")] -> ЛКМ по существу\n\
		[span_bold("Изменить необходимое количество часов, необходимое для управления существом")] -> ПКМ по кнопке билдмода"))
	)

/datum/buildmode_mode/offer/change_settings(mob/user)
	hours = tgui_input_number(user, "Необходимое число часов", "Ввод", 20)
	if(tgui_alert(user, "Хотите показывать спецроль существа?", null, list("Да", "Нет")) == "Да")
		hide_role = FALSE
	else
		hide_role = TRUE

/datum/buildmode_mode/offer/handle_click(mob/user, params, atom/A)
	var/list/modifiers = params2list(params)
	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/selected_atom

	if(left_click && ismob(A) && !isobserver(A))
		selected_atom = A
		offer_control(selected_atom, hours, hide_role)
