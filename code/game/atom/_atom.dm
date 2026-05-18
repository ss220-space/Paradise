/// Update the screentip to reflect what we're hovering over
/atom/MouseEntered(location, control, params)
	SSmouse_entered.hovers[usr.client] = src

/// Fired whenever this atom is the most recent to be hovered over in the tick.
/// Preferred over MouseEntered if you do not need information such as the position of the mouse.
/// Especially because this is deferred over a tick, do not trust that `client` is not null.
/atom/proc/on_mouse_enter(client/client)
	SHOULD_NOT_SLEEP(TRUE)

	var/mob/user = client?.mob
	if(isnull(user))
		return

	SEND_SIGNAL(user, COMSIG_ATOM_MOUSE_ENTERED, src)

	// Screentips
	var/datum/hud/active_hud = user.hud_used
	if(!active_hud)
		return

	var/screentips_enabled = user.client.prefs.screentip_mode
	if(screentips_enabled == 0 || flags & NO_SCREENTIPS)
		active_hud.screentip_text.maptext = ""
		return

	var/list/lmb_rmb_line
	var/list/ctrl_lmb_ctrl_rmb_line = list()
	var/list/alt_lmb_alt_rmb_line = list()
	var/list/shift_lmb_ctrl_shift_lmb_line = list()
	var/extra_lines = 0
	var/extra_context = ""
	var/used_name = declent_ru(NOMINATIVE)

	if(isliving(user) || isovermind(user) || isAIEye(user))
		var/obj/item/held_item = user.get_active_hand()

		if(user.mob_flags & MOB_HAS_SCREENTIPS_NAME_OVERRIDE)
			var/list/returned_name = list(used_name)

			var/name_override_returns = SEND_SIGNAL(user, COMSIG_MOB_REQUESTING_SCREENTIP_NAME_FROM_USER, returned_name, held_item, src)
			if(name_override_returns & SCREENTIP_NAME_SET)
				used_name = returned_name[1]

		if(flags & HAS_CONTEXTUAL_SCREENTIPS || held_item?.item_flags & ITEM_HAS_CONTEXTUAL_SCREENTIPS)
			var/list/context = list()

			var/contextual_screentip_returns = \
				SEND_SIGNAL(src, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, context, held_item, user) \
				| (held_item && SEND_SIGNAL(held_item, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, context, src, user))

			if(contextual_screentip_returns & CONTEXTUAL_SCREENTIP_SET)
				var/screentip_images = active_hud.screentip_images
				// LMB and RMB on one line...
				var/lmb_text = build_context(context, SCREENTIP_CONTEXT_LMB, screentip_images)
				var/rmb_text = build_context(context, SCREENTIP_CONTEXT_RMB, screentip_images)

				if(lmb_text != "")
					lmb_rmb_line = list(lmb_text)
					if(rmb_text != "")
						lmb_rmb_line += " | [rmb_text]"
				else if(rmb_text != "")
					lmb_rmb_line = list(rmb_text)

				// Ctrl-LMB, Ctrl-RMB on one line...
				if(length(lmb_rmb_line))
					lmb_rmb_line += "<br>"
					extra_lines++
				if(SCREENTIP_CONTEXT_CTRL_LMB in context)
					ctrl_lmb_ctrl_rmb_line += build_context(context, SCREENTIP_CONTEXT_CTRL_LMB, screentip_images)

				if(SCREENTIP_CONTEXT_CTRL_RMB in context)
					if(length(ctrl_lmb_ctrl_rmb_line))
						ctrl_lmb_ctrl_rmb_line += " | "
					ctrl_lmb_ctrl_rmb_line += build_context(context, SCREENTIP_CONTEXT_CTRL_RMB, screentip_images)

				// Alt-LMB, Alt-RMB on one line...
				if(length(ctrl_lmb_ctrl_rmb_line))
					ctrl_lmb_ctrl_rmb_line += "<br>"
					extra_lines++
				if(SCREENTIP_CONTEXT_ALT_LMB in context)
					alt_lmb_alt_rmb_line += build_context(context, SCREENTIP_CONTEXT_ALT_LMB, screentip_images)
				if(SCREENTIP_CONTEXT_ALT_RMB in context)
					if(length(alt_lmb_alt_rmb_line))
						alt_lmb_alt_rmb_line += " | "
					alt_lmb_alt_rmb_line += build_context(context, SCREENTIP_CONTEXT_ALT_RMB, screentip_images)

				// Shift-LMB, Ctrl-Shift-LMB on one line...
				if(length(alt_lmb_alt_rmb_line))
					alt_lmb_alt_rmb_line += "<br>"
					extra_lines++
				if(SCREENTIP_CONTEXT_SHIFT_LMB in context)
					shift_lmb_ctrl_shift_lmb_line += build_context(context, SCREENTIP_CONTEXT_SHIFT_LMB, screentip_images)
				if(SCREENTIP_CONTEXT_CTRL_SHIFT_LMB in context)
					if(length(shift_lmb_ctrl_shift_lmb_line))
						shift_lmb_ctrl_shift_lmb_line += " | "
					shift_lmb_ctrl_shift_lmb_line += build_context(context, SCREENTIP_CONTEXT_CTRL_SHIFT_LMB, screentip_images)

				if(length(shift_lmb_ctrl_shift_lmb_line))
					extra_lines++

				if(extra_lines)
					extra_context = "<br><span class='subcontext'>[lmb_rmb_line?.Join("")][ctrl_lmb_ctrl_rmb_line.Join("")][alt_lmb_alt_rmb_line.Join("")][shift_lmb_ctrl_shift_lmb_line.Join("")]</span>"

	var/new_maptext
	if(screentips_enabled == 0 && extra_context == "")
		new_maptext = ""
	else
		//We inline a MAPTEXT() here, because there's no good way to statically add to a string like this
		new_maptext = "<span class='context' style='text-align: center; color: [user.client.prefs.screentip_color]'>[used_name][extra_context]</span>"

	if(length(used_name) * 10 > active_hud.screentip_text.maptext_width)
		INVOKE_ASYNC(src, PROC_REF(set_hover_maptext), client, active_hud, new_maptext)
		return

	active_hud.screentip_text.maptext = new_maptext
	active_hud.screentip_text.maptext_y = 10 - (extra_lines > 0 ? 11 + 9 * (extra_lines - 1): 0)

/atom/proc/set_hover_maptext(client/client, datum/hud/active_hud, new_maptext)
	var/map_height
	WXH_TO_HEIGHT(client.MeasureText(new_maptext, null, active_hud.screentip_text.maptext_width), map_height)
	active_hud.screentip_text.maptext = new_maptext
	active_hud.screentip_text.maptext_y = 26 - map_height
