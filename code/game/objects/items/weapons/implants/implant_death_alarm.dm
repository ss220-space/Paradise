/obj/item/implant/death_alarm
	name = "death alarm bio-chip"
	desc = "An alarm which monitors host vital signs and transmits a radio message upon death."
	implant_state = "implant-nanotrasen"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	trigger_causes = BIOCHIP_TRIGGER_DEATH_ANY
	implant_data = /datum/implant_fluff/death_alarm
	var/mobname = UNKNOWN_NAME_RUS
	var/static/list/stealth_areas = typecacheof(list(/area/syndicate_mothership, /area/shuttle/syndicate_elite))

/obj/item/implant/death_alarm/implant(mob/living/carbon/human/source, mob/user, force = FALSE)
	. = ..()
	if(.)
		mobname = source.real_name

/obj/item/implant/death_alarm/activate(cause) // Death signal sends name followed by the gibbed / not gibbed check
	var/area/mob_area = get_area(imp_in)

	var/message
	var/destroy = FALSE

	switch(cause)
		if("gib")
			message = "[mobname] has died-zzzzt in-in-in..."
			destroy = TRUE
		if("emp")
			var/name = prob(50) ? mob_area.name : pick(SSmapping.teleportlocs)
			message = "[mobname] has died in [name]!"
		else
			if(is_type_in_typecache(mob_area, stealth_areas))
				//give the syndies a bit of stealth
				message = "[mobname] has died in Space!"
			else
				message = "[mobname] has died in [mob_area.name]!"
			destroy = TRUE
	radio_announce(message, "[mobname]'s Death Alarm", PUB_FREQ, follow_target_override = imp_in)

	if(!destroy)
		return

	qdel(src)

/obj/item/implant/death_alarm/emp_act(severity)	//for some reason alarms stop going off in case they are emp'd, even without this
	activate("emp")	//let's shout that this dude is dead

/obj/item/implant/death_alarm/death_trigger(mob/source, gibbed)
	if(gibbed)
		activate("gib")
	else
		activate("death")

/obj/item/implant/death_alarm/removed(mob/target)
	if(..())
		UnregisterSignal(target, COMSIG_MOB_DEATH)
		return TRUE
	return FALSE

/obj/item/implanter/death_alarm
	name = "bio-chip implanter (Death Alarm)"
	imp = /obj/item/implant/death_alarm

/obj/item/implantcase/death_alarm
	name = "bio-chip Case - 'Death Alarm'"
	desc = "A case containing a death alarm bio-chip."
	imp = /obj/item/implant/death_alarm

