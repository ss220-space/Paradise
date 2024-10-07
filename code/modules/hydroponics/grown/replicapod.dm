// A very special plant, deserving it's own file.

/obj/item/seeds/replicapod
	name = "pack of replica pod seeds"
	desc = "These seeds grow into replica pods. They say these are used to harvest humans."
	icon_state = "seed-replicapod"
	species = "replicapod"
	plantname = "Replica Pod"
	product = /mob/living/carbon/human/diona //verrry special -- Urist
	lifespan = 50
	endurance = 8
	maturation = 10
	production = 1
	yield = 1 //seeds if there isn't a dna inside
	potency = 30
	var/ckey = null
	var/realName = null
	var/datum/mind/mind = null
	var/blood_gender = null
	var/blood_type = null
	var/factions = null
	var/contains_sample = 0

/obj/item/seeds/replicapod/Destroy()
	mind = null
	return ..()


/obj/item/seeds/replicapod/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/syringe))
		add_fingerprint(user)
		var/obj/item/reagent_containers/syringe/syringe = I
		if(contains_sample)
			to_chat(user, span_warning("The seeds already contain a genetic sample."))
			return ATTACK_CHAIN_PROCEED
		if(!syringe.reagents.total_volume)
			to_chat(user, span_warning("The [syringe.name] is empty."))
			return ATTACK_CHAIN_PROCEED
		if(!syringe.mode != 1)	// inject
			to_chat(user, span_warning("The [syringe.name] should be in inject mode."))
			return ATTACK_CHAIN_PROCEED
		for(var/datum/reagent/blood/sample in syringe.reagents.reagent_list)
			if(!sample.data["mind"] || !sample.data["cloneable"])
				continue
			var/datum/mind/tempmind = sample.data["mind"]
			if(!tempmind.is_revivable())
				continue
			mind = sample.data["mind"]
			ckey = sample.data["ckey"]
			realName = sample.data["real_name"]
			blood_gender = sample.data["gender"]
			blood_type = sample.data["blood_type"]
			factions = sample.data["factions"]
			syringe.reagents.clear_reagents()
			syringe.update_icon()
			contains_sample = TRUE
			break
		if(!contains_sample)
			to_chat(user, span_warning("The seeds reject the sample."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have injected the contents of the syringe into the seeds."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/seeds/replicapod/get_analyzer_text()
	var/text = ..()
	if(contains_sample)
		text += "\n It contains a blood sample!"
	return text


/obj/item/seeds/replicapod/harvest(mob/user = usr) //now that one is fun -- Urist
	var/obj/machinery/hydroponics/parent = loc
	var/make_podman = 0
	var/ckey_holder = null
	if(CONFIG_GET(number/revival_pod_plants))
		if(ckey)
			for(var/mob/M in GLOB.player_list)
				if(isobserver(M))
					var/mob/dead/observer/O = M
					if(O.ckey == ckey && O.can_reenter_corpse)
						make_podman = 1
						break
				else
					if(M.ckey == ckey && M.stat == DEAD && !M.suiciding)
						make_podman = 1
						break
		else //If the player has ghosted from his corpse before blood was drawn, his ckey is no longer attached to the mob, so we need to match up the cloned player through the mind key
			for(var/mob/M in GLOB.player_list)
				if(mind && M.mind && ckey(M.mind.key) == ckey(mind.key) && M.ckey && M.client && M.stat == DEAD && !M.suiciding)
					if(isobserver(M))
						var/mob/dead/observer/O = M
						if(!O.can_reenter_corpse)
							break
					make_podman = 1
					ckey_holder = M.ckey
					break

	if(mind && !mind.is_revivable())
		make_podman = 0

	if(make_podman)	//all conditions met!
		var/mob/living/carbon/human/pod_diona/podman = new /mob/living/carbon/human/pod_diona(parent.loc)
		if(realName)
			podman.real_name = realName
		mind.transfer_to(podman)
		if(ckey)
			podman.ckey = ckey
		else
			podman.ckey = ckey_holder
		podman.gender = blood_gender
		podman.faction |= factions

	else //else, one packet of seeds. maybe two
		var/seed_count = 1
		if(prob(getYield() * 20))
			seed_count++
		var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc //needed for TK
		for(var/i=0,i<seed_count,i++)
			var/obj/item/seeds/replicapod/harvestseeds = src.Copy()
			harvestseeds.forceMove(output_loc)

	investigate_log("[key_name_log(mind)] cloned as a diona via [src] in [parent]", INVESTIGATE_BOTANY)
	parent.update_tray()
