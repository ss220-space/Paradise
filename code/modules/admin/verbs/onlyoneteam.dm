/client/proc/only_one_team()
	if(!SSticker)
		tgui_alert(usr, "The game hasn't started yet!")
		return

	var/list/incompatible_species = list(/datum/species/plasmaman, /datum/species/vox)
	var/team_toggle = 0
	for(var/mob/living/carbon/human/human in GLOB.player_list)
		if(human.stat == DEAD || !(human.client))
			continue
		if(is_special_character(human))
			continue
		if(is_type_in_list(human.dna.species, incompatible_species))
			human.set_species(/datum/species/human)
			var/datum/preferences/preferences = new()	// Randomize appearance
			preferences.copy_to(human)

		for(var/obj/item/item in human)
			if(istype(item, /obj/item/implant))
				continue
			if(is_organ(item))
				continue
			qdel(item)

		to_chat(human, "<b>You are part of the [station_name()] dodgeball tournament. Throw dodgeballs at crewmembers wearing a different color than you. OOC: Use THROW on an EMPTY-HAND to catch thrown dodgeballs.</b>")

		human.equip_to_slot_or_del(new /obj/item/radio/headset/heads/captain(human), ITEM_SLOT_EAR_LEFT)
		human.equip_to_slot_or_del(new /obj/item/beach_ball/dodgeball(human), ITEM_SLOT_HAND_RIGHT)
		human.equip_to_slot_or_del(new /obj/item/clothing/shoes/color/white(human), ITEM_SLOT_FEET)

		if(!team_toggle)
			GLOB.team_alpha += human

			human.equip_to_slot_or_del(new /obj/item/clothing/under/color/red/dodgeball(human), ITEM_SLOT_CLOTH_INNER)
			var/obj/item/card/id/id = new(human)
			id.name = "[human.real_name]’s ID Card"
			id.icon_state = "centcom"
			id.access = get_all_accesses()
			id.access += get_all_centcom_access()
			id.assignment = "Professional Pee-Wee League Dodgeball Player"
			id.registered_name = human.real_name
			human.equip_to_slot_or_del(id, ITEM_SLOT_ID)

		else
			GLOB.team_bravo += human

			human.equip_to_slot_or_del(new /obj/item/clothing/under/color/blue/dodgeball(human), ITEM_SLOT_CLOTH_INNER)
			var/obj/item/card/id/id = new(human)
			id.name = "[human.real_name]’s ID Card"
			id.icon_state = "centcom"
			id.access = get_all_accesses()
			id.access += get_all_centcom_access()
			id.assignment = "Professional Pee-Wee League Dodgeball Player"
			id.registered_name = human.real_name
			human.equip_to_slot_or_del(id, ITEM_SLOT_ID)

		team_toggle = !team_toggle
		human.dna.species.after_equip_job(null, human)
		human.regenerate_icons()

	log_and_message_admins("used DODGEBAWWWWWWWL! -NO ATTACK LOGS WILL BE SENT TO ADMINS FROM THIS POINT FORTH-")
	GLOB.nologevent = 1

/obj/item/beach_ball/dodgeball
	name = "dodgeball"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "dodgeball"
	item_state = "basketball"
	desc = "Used for playing the most violent and degrading of childhood games."

/obj/item/beach_ball/dodgeball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if((ishuman(hit_atom)))
		var/mob/living/carbon/human/H = hit_atom
		if(H.r_hand == src)
			return
		if(H.l_hand == src)
			return
		var/mob/A = locateUID(thrownby)
		if((H in GLOB.team_alpha) && (A in GLOB.team_alpha))
			to_chat(A, span_warning("He's on your team!"))
			return
		else if((H in GLOB.team_bravo) && (A in GLOB.team_bravo))
			to_chat(A, span_warning("He's on your team!"))
			return
		else if(!(A in GLOB.team_alpha) && !(A in GLOB.team_bravo))
			to_chat(A, span_warning("You're not part of the dodgeball game, sorry!"))
			return
		else
			playsound(src, 'sound/items/dodgeball.ogg', 50, TRUE)
			visible_message(span_danger("[H] HAS BEEN ELIMINATED!"))
			H.melt()
