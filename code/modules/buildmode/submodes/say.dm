/datum/buildmode_mode/say
	key = "say"

/datum/buildmode_mode/say/show_help(mob/user)
	to_chat(user, span_purple(chat_box_examine(
		"[span_bold("Сказать")] -> ЛКМ\n\
		[span_bold("Издать эмоцию")] -> ПКМ"))
	)

/datum/buildmode_mode/say/handle_click(mob/user, params, atom/object)
	if(ismob(object))
		var/mob/target = object
		if(!isnull(target.ckey))
			tgui_alert(usr, "Это нельзя использовать на мобах с сикеем. Вместо этого используйте Forcesay на панели игрока.")
			return

	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		var/say = tgui_input_text(user, "Что должен сказать объект \"[object.declent_ru(NOMINATIVE)]\"?", "Что сказать?")
		if(isnull(say))
			return
		log_admin("Build Mode: [key_name(user)] made [object] at ([object.x],[object.y],[object.z] say [say].")
		message_admins(span_notice("Build Mode: [key_name(user)] made [object] at ([object.x],[object.y],[object.z] say [say]."))
		user.create_log(MISC_LOG, "Made [object] at ([object.x],[object.y],[object.z] say [say].")
		object.atom_say(say)
	else if(LAZYACCESS(modifiers, RIGHT_CLICK))
		var/emote = tgui_input_text(user, "Что должен сделать объект \"[object.declent_ru(NOMINATIVE)]\"?", "Какую эмоцию?")
		if(isnull(emote))
			return
		log_admin("Build Mode: [key_name(user)] made [object] at ([object.x],[object.y],[object.z] emote *[emote].")
		message_admins(span_notice("Build Mode: [key_name(user)] made [object] at ([object.x],[object.y],[object.z] emote *[emote]."))
		user.create_log(MISC_LOG, "Made [object] at ([object.x],[object.y],[object.z] emote *[emote].")
		object.atom_emote(emote)
