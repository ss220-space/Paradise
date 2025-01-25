/datum/buildmode_mode/boom
	key = "boom"

	var/devastation = -1
	var/heavy = -1
	var/light = -1
	var/flash = -1
	var/flames = -1

/datum/buildmode_mode/boom/show_help(mob/user)
	to_chat(user, span_notice("***********************************************************"))
	to_chat(user, span_notice("Кнопка мыши на объекте = Кабум"))
	to_chat(user, span_notice("ПРИМЕЧАНИЕ. Использование кнопки «Event/Launch Supplypod» позволяет вам сделать в IC поле (т. е. заставить крылатую ракету упасть с неба и взорваться там, где вы щелкнете!)"))
	to_chat(user, span_notice("***********************************************************"))

/datum/buildmode_mode/boom/change_settings(mob/user)
	devastation = tgui_input_number(usr, "Дальность тотального разрушения.", text("Ввод"))
	if(devastation == null) devastation = -1
	heavy = tgui_input_number(usr, "Дальность сильного удара.", text("Ввод"))
	if(heavy == null) heavy = -1
	light = tgui_input_number(usr, "Дальность легкого удара.", text("Ввод"))
	if(light == null) light = -1
	flash = tgui_input_number(usr, "Дальность вспышки.", text("Ввод"))
	if(flash == null) flash = -1
	flames = tgui_input_number(usr, "Дальность пламени.", text("Ввод"))
	if(flames == null) flames = -1

/datum/buildmode_mode/boom/handle_click(user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")

	if(left_click)
		explosion(object, devastation, heavy, light, flash, null, TRUE, flames, cause = "build mode")
