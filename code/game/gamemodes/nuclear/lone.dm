/datum/event/operative
	name = "Оперативник-одиночка"

/datum/event/operative/proc/assign_nuke()
	var/nuke_code = rand(10000, 99999)
	var/obj/machinery/nuclearbomb/nuke = locate()
	if(nuke)
		if(nuke.r_code == "ADMIN")
			nuke.r_code = nuke_code
		else //Already set by admins/something else?
			nuke_code = nuke.r_code
	else
		stack_trace("Station self-destruct not found during lone op team creation.")
		nuke_code = null
	return nuke_code

/datum/event/operative/proc/store_nuke_code(datum/mind/synd_mind, nuke_code)
	if(nuke_code)
		synd_mind.store_memory("<B>Код от ядерной боеголовки</B>: [nuke_code]", 0, 0)
		to_chat(synd_mind.current, "Код от ядерной боеголовки: <B>[nuke_code]</B>")
	else
		nuke_code = "Код будет сообщен позже."

/datum/event/operative/proc/make_operative()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you wish to be a lone nuclear operative?", ROLE_OPERATIVE, TRUE, source = /obj/machinery/nuclearbomb/)
	if(candidates.len)
		var/mob/dead/observer/selected = pick(candidates)
		var/mob/living/carbon/human/new_character = makeBody(selected)
		new_character.loc = get_turf(locate("landmark*Syndicate-Spawn"))
		var/datum/mind/operative_mind = new_character.mind
		SSticker.mode.create_syndicate(operative_mind)
		var/mob/living/carbon/human/operative = operative_mind.current

		SSticker.mode.syndicates += operative_mind
		SSticker.mode.update_synd_icons_added(operative_mind)
		operative.real_name = "[syndicate_name()] Lone Operative"
		operative_mind.special_role = SPECIAL_ROLE_NUKEOPS
		operative_mind.assigned_role = SPECIAL_ROLE_NUKEOPS
		SSticker.mode.forge_syndicate_objectives(operative_mind)
		SSticker.mode.greet_syndicate(operative_mind)

		SSticker.mode.equip_syndicate(operative)
		store_nuke_code(operative_mind, assign_nuke())
		SSticker.mode.update_syndicate_id(operative_mind, TRUE)

		var/additional_tk = max(0, (GLOB.player_list.len - 30)*2)
		var/obj/item/radio/uplink/Uplink = locate() in operative.back
		if(istype(Uplink))
			Uplink.hidden_uplink.uplink_owner = "[operative.key]"
			Uplink.hidden_uplink.uses = 20 + additional_tk

		return TRUE
	else
		return FALSE



/datum/event/operative/start()
	processing = 0
	if(length(GLOB.player_list) < 30)
		message_admins("Lone operative event failed to start. Not enough players.")
		return
	if(!make_operative())
		message_admins("Lone operative event failed to find players. Retrying in 30s.")
		addtimer(CALLBACK(src, .proc/make_operative), 30 SECONDS)
