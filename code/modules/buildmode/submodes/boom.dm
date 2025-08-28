#define BOOM_DEVASTATION "devastation"
#define BOOM_HEAVY "heavy"
#define BOOM_LIGHT "light"
#define BOOM_FLASH "flash"
#define BOOM_FLAMES "flames"

/datum/buildmode_mode/boom
	key = "boom"

	var/list/explosions = list(
		BOOM_DEVASTATION = 0,
		BOOM_HEAVY = 0,
		BOOM_LIGHT = 0,
		BOOM_FLASH = 0,
		BOOM_FLAMES = 0
		)

/datum/buildmode_mode/boom/show_help(mob/builder)
	to_chat(builder, span_purple(chat_box_examine(
		"[span_bold("Установить силу взрыва")] -> ПКМ по кнопке buildmode\n\
		[span_bold("KABOOM")] -> ЛКМ на obj\n\n\
		[span_warning("ПРИМЕЧАНИЕ:")] Использование кнопки \"Event/Launch Supplypod\" позволит вам сделать это в IC поле (т. е. заставить крылатую ракету упасть с неба и взорваться там, где вы щелкнете!)"))
	)

/datum/buildmode_mode/boom/change_settings(mob/user)
	for(var/explosion_level in explosions)
		explosions[explosion_level] = tgui_input_number(user, "Дальность тотального [explosion_level]. \"0\" – значит нет.", text("Ввод"))
		if(explosions[explosion_level] == null || explosions[explosion_level] < 0)
			explosions[explosion_level] = 0

/datum/buildmode_mode/boom/handle_click(user, params, obj/object)
	var/list/modifiers = params2list(params)

	var/value_valid = FALSE
	for(var/explosion_type in explosions)
		if(explosions[explosion_type] > 0)
			value_valid = TRUE
			break
	if(!value_valid)
		return

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		log_admin("Build Mode: [key_name(user)] caused an explosion(dev=[explosions[BOOM_DEVASTATION]], hvy=[explosions[BOOM_HEAVY]], lgt=[explosions[BOOM_LIGHT]], flash=[explosions[BOOM_FLASH]], flames=[explosions[BOOM_FLAMES]]) at [AREACOORD(object)]")
		explosion(object, explosions[BOOM_DEVASTATION], explosions[BOOM_HEAVY], explosions[BOOM_LIGHT], explosions[BOOM_FLASH], flame_range = explosions[BOOM_FLAMES], adminlog = null, ignorecap = TRUE, cause = "Buildmode Boom")

#undef BOOM_DEVASTATION
#undef BOOM_HEAVY
#undef BOOM_LIGHT
#undef BOOM_FLASH
#undef BOOM_FLAMES
