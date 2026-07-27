/obj/effect/proc_holder/spell/lunatic_track
	name = "Эхо Лунного Света"
	desc = "Узнайте местоположение вашего Лидера."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "moon_smile"
	base_cooldown = 4 SECONDS
	clothes_req = FALSE


/obj/effect/proc_holder/spell/lunatic_track/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/lunatic_track/on_spell_gain(mob/user = usr)
	if(!IS_LUNATIC(user))
		return

	return ..()


/obj/effect/proc_holder/spell/lunatic_track/cast(list/targets, mob/user)
	for(var/mob/target as anything in targets)
		var/datum/antagonist/lunatic/lunatic_datum = IS_LUNATIC(action.owner)
		var/mob/living/carbon/human/ascended_heretic = lunatic_datum.ascended_body
		if(!(ascended_heretic))
			action.owner.balloon_alert(action.owner, "вашего хозяина больше нет...")
			cooldown_handler.start_recharge(1 SECONDS)
			return FALSE

		playsound(action.owner, 'sound/effects/singlebeat.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		action.owner.balloon_alert(action.owner, get_balloon_message(ascended_heretic))

		if(ascended_heretic.stat == DEAD)
			to_chat(action.owner, span_mansus("[ascended_heretic.declent_ru(NOMINATIVE)] [GEND_MERTV(ascended_heretic)]. Рыдайте, ибо ложь победила."))

		cooldown_handler.start_recharge()
		return TRUE


/// Gets the balloon message for the heretic we are tracking.
/obj/effect/proc_holder/spell/lunatic_track/proc/get_balloon_message(mob/living/carbon/human/tracked_mob)
	var/balloon_message = generate_balloon_message(tracked_mob)
	if(tracked_mob.stat == DEAD)
		balloon_message = "[GEND_MERTV(tracked_mob)] " + balloon_message

	return balloon_message


/// Create the text for the balloon message
/obj/effect/proc_holder/spell/lunatic_track/proc/generate_balloon_message(mob/living/carbon/human/tracked_mob)
	var/balloon_message = "ошибка!"
	var/turf/their_turf = get_turf(tracked_mob)
	var/turf/our_turf = get_turf(action.owner)
	var/their_z = their_turf?.z
	var/our_z = our_turf?.z

	var/dist = get_dist(our_turf, their_turf)
	var/dir = get_dir(our_turf, their_turf)

	switch(dist)
		if(0 to 15)
			balloon_message = "очень близко, [dir2text(dir)]!"
		if(16 to 31)
			balloon_message = "близко, [dir2text(dir)]!"
		if(32 to 127)
			balloon_message = "далеко, [dir2text(dir)]!"
		else
			balloon_message = "очень далеко!"

	if(our_z == their_z)
		return balloon_message

	if(is_mining_level(their_z))
		balloon_message = "на лавовой земле!"
		return balloon_message

	if(is_away_level(their_z) || is_admin_level(their_z))
		balloon_message = "за вратами!"
		return balloon_message

	if(!is_station_level(their_z))
		balloon_message = "на другом слое реальности!!"
		return balloon_message

	if(!is_station_level(our_z))
		balloon_message = "на станции!"
		return balloon_message

	if(our_z > their_z)
		balloon_message = "ниже вас!"
		return balloon_message

	if(our_z < their_z)
		balloon_message = "выше вас!"
		return balloon_message

	return balloon_message
