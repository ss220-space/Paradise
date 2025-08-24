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
		"[span_bold("Set explosion destructiveness")] -> Right Mouse Button on buildmode button\n\
		[span_bold("Kaboom")] -> Mouse Button on obj\n\n\
		[span_warning("NOTE:")] Using the \"«Event/Launch Supplypod\" verb allows you to do this in an IC way (i.e., making a cruise missile come down from the sky and explode wherever you click!)"))
	)

/datum/buildmode_mode/boom/change_settings(mob/user)
	for (var/explosion_level in explosions)
		explosions[explosion_level] = input(user, "Range of total [explosion_level]. 0 to none", "Input") as num|null
		if(explosions[explosion_level] == null || explosions[explosion_level] < 0)
			explosions[explosion_level] = 0

/datum/buildmode_mode/boom/handle_click(user, params, obj/object)
	var/list/modifiers = params2list(params)

	var/value_valid = FALSE
	for(var/explosion_type in explosions)
		if (explosions[explosion_type] > 0)
			value_valid = TRUE
			break
	if(!value_valid)
		return

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		log_admin("Build Mode: [key_name(user)] caused an explosion(dev=[explosions[BOOM_DEVASTATION]], hvy=[explosions[BOOM_HEAVY]], lgt=[explosions[BOOM_LIGHT]], flash=[explosions[BOOM_FLASH]], flames=[explosions[BOOM_FLAMES]]) at [AREACOORD(object)]")
		explosion(object, explosions[BOOM_DEVASTATION], explosions[BOOM_HEAVY], explosions[BOOM_LIGHT], explosions[BOOM_FLASH], explosions[BOOM_FLAMES], adminlog = null, ignorecap = TRUE)

#undef BOOM_DEVASTATION
#undef BOOM_HEAVY
#undef BOOM_LIGHT
#undef BOOM_FLASH
#undef BOOM_FLAMES
