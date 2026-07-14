/**
 * Datum designed for mini games. Currently does not represent anything except thunderdome.
 */

/datum/mini_game
	var/name = "mini game name placeholder"
	var/spawn_minimum_limit = 1
	var/spawn_coefficent = 1
	var/is_going = FALSE
	var/maxplayers = 2
	var/time_limit = 5 MINUTES
	var/role = ROLE_THUNDERDOME

/**
 * Invisible and indestructible anchor for defining locations and stuff
 */
/obj/minigame_anchor
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "thunderdome-bomb"
	anchored = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	layer = BELOW_MOB_LAYER
	resistance_flags = INDESTRUCTIBLE

/**
 * Changed copy of /proc/notify_ghosts designed to be customizable across user preferences
 */
/datum/mini_game/proc/notify_players(message, ghost_sound = null, enter_link = null, title = null, atom/source = null, image/alert_overlay = null, flashwindow = TRUE, action = NOTIFY_JUMP) //Easy notification of ghosts.
	for(var/mob/dead/observer/observer in GLOB.player_list)
		if(!observer.client?.prefs?.minigames_notifications || !(role in observer.client?.prefs?.be_special))
			return
		to_chat(observer, span_ghostalert("[message][(enter_link) ? " [enter_link]" : ""]"))
		if(ghost_sound)
			SEND_SOUND(observer, sound(ghost_sound))
		if(flashwindow)
			window_flash(observer.client)
		if(source)
			var/atom/movable/screen/alert/notify_action/notify_action = observer.throw_alert("[source.UID()]_notify_action", /atom/movable/screen/alert/notify_action)
			if(notify_action)
				if(observer.client.prefs && observer.client.prefs.UI_style)
					notify_action.icon = ui_style2icon(observer.client.prefs.UI_style)
				if(title)
					notify_action.name = title
				notify_action.desc = message
				notify_action.action = action
				notify_action.target_ref = WEAKREF(source)
				if(!alert_overlay)
					var/old_layer = source.layer
					var/old_plane = source.plane
					source.layer = FLOAT_LAYER
					source.plane = FLOAT_PLANE
					notify_action.add_overlay(source)
					source.layer = old_layer
					source.plane = old_plane
				else
					alert_overlay.layer = FLOAT_LAYER
					alert_overlay.plane = FLOAT_PLANE
					notify_action.add_overlay(alert_overlay)
