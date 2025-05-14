//MISC structures- if it is less than 100 lines and doesn't fit in a category, toss it in here!

/*CURRENT CONTENTS:
	NT recruitment signpost
	Ninja Teleportation Console
*/

/obj/structure/signpost
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = TRUE
	density = TRUE

/obj/structure/signpost/attack_hand(mob/user as mob)
	add_fingerprint(user)
	to_chat(user, "Civilians: NT is recruiting! Please head SOUTH to the NT Recruitment office to join the station's crew!")

/obj/structure/wooden_sign
	name = "Wooden sign"
	desc = "What?"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost2"
	anchored = TRUE
	density = FALSE

/obj/structure/respawner
	name = "\improper Long-Distance Cloning Machine"
	desc = "Top-of-the-line Nanotrasen technology allows for cloning of crew members from off-station upon bluespace request."
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger1(old)"
	anchored = TRUE
	density = TRUE
	var/use_old_mind = FALSE
	/// An outfit for ghosts to spawn with
	var/datum/outfit/selected_outfit

/obj/structure/respawner/attack_ghost(mob/dead/observer/user)
	if(check_rights(R_EVENT))
		var/outfit_pick = tgui_alert(user, "Хочешь выбрать снаряжение или возродиться?", "Выбрать снаряжение?", list("Выбрать снаряжение", "Возродиться", "Отмена"))
		if(outfit_pick == "Отмена")
			return
		if(outfit_pick == "Выбрать снаряжение")
			var/new_outfit = user.client.robust_dress_shop()
			if(!new_outfit)
				return
			log_admin("[key_name(user)] changed a respawner machine's outfit to [new_outfit].")
			message_admins("[key_name(user)] changed a respawner machine's outfit to [new_outfit].")
			if(new_outfit == "Naked")
				selected_outfit = null
				return
			selected_outfit = new new_outfit
			return

	var/response = tgui_alert(user, "Вы уверены, что хотите появиться здесь?\n(Если вы сделаете это, вас нельзя будет клонировать!)", "Возродиться?", list("Да", "Нет"))
	if(response == "Да")
		user.forceMove(get_turf(src))
		log_admin("[key_name_log(user)] was incarnated by a respawner machine.")
		message_admins("[key_name_admin(user)] was incarnated by a respawner machine.")
		var/mob/living/carbon/human/new_human = user.incarnate_ghost(use_old_mind)
		if(selected_outfit)
			selected_outfit.equip(new_human)
		new_human.mind.offstation_role = TRUE // To prevent them being an antag objective

/obj/structure/respawner/old_mind
	use_old_mind = TRUE

/obj/structure/ghost_beacon
	name = "ethereal beacon"
	desc = "A structure that draws ethereal attention when active. Use an empty hand to activate."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "anomaly_crystal"
	anchored = TRUE
	density = TRUE
	var/active = FALSE
	var/ghost_alert_delay = 30 SECONDS
	var/last_ghost_alert
	var/alert_title = "Ethereal Beacon Active!"
	var/atom/attack_atom


/obj/structure/ghost_beacon/Initialize()
	. = ..()
	last_ghost_alert = world.time
	attack_atom = src
	if(active)
		START_PROCESSING(SSobj, src)

/obj/structure/ghost_beacon/Destroy()
	if(active)
		STOP_PROCESSING(SSobj, src)
	attack_atom = null
	return ..()

/obj/structure/ghost_beacon/attack_ghost(mob/dead/observer/user)
	if(user.can_advanced_admin_interact())
		attack_hand(user)
	else if(attack_atom != src)
		attack_atom.attack_ghost(user)

/obj/structure/ghost_beacon/attack_hand(mob/user)
	if(!is_admin(user))
		return
	to_chat(user, "<span class='notice'>You [active ? "disable" : "enable"] \the [src].</span>")
	if(active)
		STOP_PROCESSING(SSobj, src)
	else
		START_PROCESSING(SSobj, src)
	active = !active

/obj/structure/ghost_beacon/process()
	if(last_ghost_alert + ghost_alert_delay < world.time)
		notify_ghosts("[src] active in [get_area(src)].", 'sound/effects/ghost2.ogg', title = alert_title, source = attack_atom, action = (attack_atom == src ? NOTIFY_JUMP : NOTIFY_ATTACK))
		last_ghost_alert = world.time

/obj/structure/boulder
	name = "boulder"
	desc = "A large rock."
	icon = 'icons/obj/mining.dmi'
	icon_state = "boulder1"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
