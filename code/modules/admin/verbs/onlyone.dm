/client/proc/only_one()
	if(!SSticker)
		tgui_alert(usr, "The game hasn't started yet!")
		return

	var/list/incompatible_species = list(/datum/species/plasmaman, /datum/species/vox)
	for(var/mob/living/carbon/human/human in GLOB.player_list)
		if(human.stat == DEAD || !(human.client))
			continue
		if(is_special_character(human))
			continue
		if(is_type_in_list(human.dna.species, incompatible_species))
			human.set_species(/datum/species/human)
			var/datum/preferences/preferences = new()	// Randomize appearance
			preferences.copy_to(human)

		SSticker.mode.traitors += human.mind
		human.mind.special_role = SPECIAL_ROLE_TRAITOR

		var/datum/objective/hijack/hijack_objective = new
		hijack_objective.owner = human.mind
		human.mind.objectives += hijack_objective

		var/list/messages = list()
		messages.Add("<b>You are a Highlander. Kill all other Highlanders. There can be only one.</b>")
		messages.Add(human.mind.prepare_announce_objectives(FALSE))
		to_chat(human, custom_boxed_message("red_box center", messages.Join("<br>")))

		for(var/obj/item/item in human)
			if(istype(item, /obj/item/implant))
				continue
			if(is_organ(item))
				continue
			qdel(item)

		human.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(human), ITEM_SLOT_CLOTH_INNER)
		human.equip_to_slot_or_del(new /obj/item/radio/headset/heads/captain(human), ITEM_SLOT_EAR_LEFT)
		human.equip_to_slot_or_del(new /obj/item/clothing/head/beret(human), ITEM_SLOT_HEAD)
		human.equip_to_slot_or_del(new /obj/item/melee/claymore/highlander(human), ITEM_SLOT_HAND_RIGHT)
		human.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(human), ITEM_SLOT_FEET)
		human.equip_to_slot_or_del(new /obj/item/pinpointer(human.loc), ITEM_SLOT_POCKET_LEFT)

		var/obj/item/card/id/id = new(human)
		id.name = "[human.real_name]’s ID Card"
		id.icon_state = "centcom"
		id.access = get_all_accesses()
		id.access += get_all_centcom_access()
		id.assignment = "Highlander"
		id.registered_name = human.real_name
		human.equip_to_slot_or_del(id, ITEM_SLOT_ID)
		human.dna.species.after_equip_job(null, human)
		human.regenerate_icons()

	log_and_message_admins("used THERE CAN BE ONLY ONE! -NO ATTACK LOGS WILL BE SENT TO ADMINS FROM THIS POINT FORTH-")
	GLOB.nologevent = 1

	GLOB.pacifism_after_gt = FALSE
	SSticker.toggle_pacifism = FALSE

	var/sound/music = sound('sound/music/thunderdome.ogg', channel = CHANNEL_ADMIN)
	for(var/mob/mob in GLOB.player_list)
		if(mob.client.prefs.sound & SOUND_MIDI)
			if(isnewplayer(mob) && (mob.client.prefs.sound & SOUND_LOBBY))
				// mob.stop_sound_channel(CHANNEL_LOBBYMUSIC)
				mob.client?.tgui_panel?.stop_music()
			music.volume = 100 * mob.client.prefs.get_channel_volume(CHANNEL_ADMIN)
			SEND_SOUND(mob, music)

/client/proc/only_me()
	if(!SSticker)
		tgui_alert(usr, "The game hasn't started yet!")
		return

	for(var/mob/living/carbon/human/human in GLOB.player_list)
		if(human.stat == 2 || !(human.client)) continue
		if(is_special_character(human)) continue

		SSticker.mode.traitors += human.mind
		human.mind.special_role = "[human.real_name] Prime"

		var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
		hijack_objective.owner = human.mind
		human.mind.objectives += hijack_objective

		var/list/messages = list()
		messages.Add("<b>You are the multiverse summoner. Activate your blade to summon copies of yourself from another universe to fight by your side.</b>")
		messages.Add(human.mind.prepare_announce_objectives(FALSE))
		to_chat(human, custom_boxed_message("red_box center", messages.Join("<br>")))

		var/obj/item/slot_item_ID = human.get_item_by_slot(ITEM_SLOT_ID)
		qdel(slot_item_ID)
		var/obj/item/slot_item_hand = human.get_item_by_slot(ITEM_SLOT_HAND_RIGHT)
		human.drop_item_ground(slot_item_hand)

		var/obj/item/multisword/pure_evil/multi = new(human)
		human.equip_to_slot_or_del(multi, ITEM_SLOT_HAND_RIGHT)

		var/obj/item/card/id/id = new(human)
		id.icon_state = "centcom"
		id.access = get_all_accesses()
		id.access += get_all_centcom_access()
		id.assignment = "Multiverse Summoner"
		id.registered_name = human.real_name
		id.update_label(human.real_name)
		human.equip_to_slot_or_del(id, ITEM_SLOT_ID)

		human.update_icons()

	message_admins("[key_name_admin(usr)] used THERE CAN BE ONLY ME! -NO ATTACK LOGS WILL BE SENT TO ADMINS FROM THIS POINT FORTH-")
	log_admin("[key_name(usr)] used there can be only me.")
	GLOB.nologevent = 1

	var/sound/music = sound('sound/music/thunderdome.ogg', channel = CHANNEL_ADMIN)
	for(var/mob/mob as anything in GLOB.player_list)
		if(mob.client.prefs.sound & SOUND_MIDI)
			if(isnewplayer(mob) && (mob.client.prefs.sound & SOUND_LOBBY))
				mob.stop_sound_channel(CHANNEL_LOBBYMUSIC)
			music.volume = 100 * mob.client.prefs.get_channel_volume(CHANNEL_ADMIN)
			SEND_SOUND(mob, music)
