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
	anchored = 1
	density = 0
	invisibility = INVISIBILITY_MAXIMUM
	opacity = 0
	layer = BELOW_MOB_LAYER
	resistance_flags = INDESTRUCTIBLE

/**
 * Changed copy of /proc/notify_ghosts designed to be customizable across user preferences
 */
/datum/mini_game/proc/notify_players(message, ghost_sound = null, enter_link = null, title = null, atom/source = null, image/alert_overlay = null, flashwindow = TRUE, var/action = NOTIFY_JUMP) //Easy notification of ghosts.
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(!O.client?.prefs?.minigames_notifications || !(role in O.client?.prefs?.be_special))
			return
		to_chat(O, span_ghostalert("[message][(enter_link) ? " [enter_link]" : ""]"))
		if(ghost_sound)
			O << sound(ghost_sound)
		if(flashwindow)
			window_flash(O.client)
		if(source)
			var/obj/screen/alert/notify_action/A = O.throw_alert("\ref[source]_notify_action", /obj/screen/alert/notify_action)
			if(A)
				if(O.client.prefs && O.client.prefs.UI_style)
					A.icon = ui_style2icon(O.client.prefs.UI_style)
				if(title)
					A.name = title
				A.desc = message
				A.action = action
				A.target = source
				if(!alert_overlay)
					var/old_layer = source.layer
					var/old_plane = source.plane
					source.layer = FLOAT_LAYER
					source.plane = FLOAT_PLANE
					A.add_overlay(source)
					source.layer = old_layer
					source.plane = old_plane
				else
					alert_overlay.layer = FLOAT_LAYER
					alert_overlay.plane = FLOAT_PLANE
					A.add_overlay(alert_overlay)
