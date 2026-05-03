#define WAND_OPEN "Open Door"
#define WAND_BOLT "Toggle Bolts"
#define WAND_EMERGENCY "Toggle Emergency Access"
#define WAND_SPEED "Change Closing Speed"
#define WAND_ELECTRIFY "Electrify Door"

/obj/item/door_remote
	icon_state = "gangtool-white"
	item_state = "electronic"
	icon = 'icons/obj/device.dmi'
	name = "control wand"
	desc = "Remotely controls airlocks."
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	var/mode = WAND_OPEN
	var/region_access = list()
	var/additional_access = list()
	var/obj/item/card/id/ID
	var/z_cross = TRUE //Allows using remoters cross-sectory

/obj/item/door_remote/New()
	..()
	ID = new /obj/item/card/id
	for(var/region in region_access)
		ID.access += get_region_accesses(region)
	ID.access += additional_access
	ID.access = unique_list(ID.access)

/obj/item/door_remote/Destroy()
	QDEL_NULL(ID)
	return ..()

/obj/item/door_remote/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		if(user)
			to_chat(user, span_warning("You short out the safeties on [src]"))

/obj/item/door_remote/attack_self(mob/user)
	if(emagged)
		switch(mode)
			if(WAND_OPEN)
				mode = WAND_BOLT
			if(WAND_BOLT)
				mode = WAND_EMERGENCY
			if(WAND_EMERGENCY)
				mode = WAND_SPEED
			if(WAND_SPEED)
				mode = WAND_ELECTRIFY
			if(WAND_ELECTRIFY)
				mode = WAND_OPEN
	else
		switch(mode)
			if(WAND_OPEN)
				mode = WAND_BOLT
			if(WAND_BOLT)
				mode = WAND_EMERGENCY
			if(WAND_EMERGENCY)
				mode = WAND_SPEED
			if(WAND_SPEED)
				mode = WAND_OPEN

	to_chat(user, span_notice("Now in mode: [mode]."))

/obj/item/door_remote/afterattack(obj/machinery/door/airlock/target, mob/user, proximity_flag, list/modifiers, status)
	if(!istype(target))
		target = locate() in get_turf(target)
	if(!istype(target))
		return
	var/turf/user_location = get_turf(user)
	if((target.z != user_location.z) && !z_cross)
		to_chat(user, span_danger("[target] is too far away to be controlled!"))
		return
	if(HAS_TRAIT(target, TRAIT_CMAGGED))
		to_chat(user, span_danger("The door doesn't respond to [src]"))
		return
	if(target.is_special)
		to_chat(user, span_danger("[src] cannot access this kind of door!"))
		return
	if(!(target.arePowerSystemsOn()))
		to_chat(user, span_danger("[target] has no power!"))
		return
	if(!target.requiresID())
		to_chat(user, span_danger("[target]'s ID scan is disabled!"))
		return
	if(target.check_access(src.ID))
		target.add_hiddenprint(user)
		if(emagged)
			switch(mode)
				if(WAND_OPEN)
					if(target.density)
						target.open()
						add_attack_logs(user, target, "opened")
					else
						target.close()
						add_attack_logs(user, target, "closed")
				if(WAND_BOLT)
					if(target.locked)
						target.unlock()
						add_attack_logs(user, target, "unlocked")
					else
						target.lock()
						add_attack_logs(user, target, "locked")
				if(WAND_EMERGENCY)
					if(target.emergency)
						target.emergency = FALSE
						add_attack_logs(user, target, "toggled off emergency access")
					else
						target.emergency = TRUE
						add_attack_logs(user, target, "toggled on emergency access")
					target.update_icon()
				if(WAND_SPEED)
					target.normalspeed = !target.normalspeed
					to_chat(user, span_notice("[target] is now in [target.normalspeed ? "normal" : "fast"] mode."))
					add_attack_logs(user, target, "changed speed mode")
				if(WAND_ELECTRIFY)
					if(target.electrified_until == -1)
						target.electrified_until = 0
						to_chat(user, span_notice("[target] is no longer electrified."))
						add_attack_logs(user, target, "un-electrified")
					else
						target.electrified_until = -1
						to_chat(user, span_notice("You electrify [target]."))
						add_attack_logs(user, target, "electrified")
		if(emagged == FALSE)
			switch(mode)
				if(WAND_OPEN)
					if(target.density)
						target.open()
						add_attack_logs(user, target, "opened")
					else
						target.close()
						add_attack_logs(user, target, "closed")
				if(WAND_BOLT)
					if(target.locked)
						target.unlock()
						add_attack_logs(user, target, "unlocked")
					else
						target.lock()
						add_attack_logs(user, target, "locked")
				if(WAND_EMERGENCY)
					if(target.emergency)
						target.emergency = FALSE
						add_attack_logs(user, target, "toggled off emergency access")
					else
						target.emergency = TRUE
						add_attack_logs(user, target, "toggled on emergency access")
					target.update_icon()
				if(WAND_SPEED)
					target.normalspeed = !target.normalspeed
					to_chat(user, span_notice("[target] is now in [target.normalspeed ? "normal" : "fast"] mode."))
					add_attack_logs(user, target, "changed speed mode")
	else
		to_chat(user, span_danger("[src] does not have access to this door."))

/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	icon_state = "gangtool-yellow"
	region_access = list(REGION_ALL)

/obj/item/door_remote/captain
	name = "command door remote"
	icon_state = "gangtool-yellow"
	region_access = list(REGION_COMMAND)

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	icon_state = "gangtool-orange"
	region_access = list(REGION_ENGINEERING)

/obj/item/door_remote/research_director
	name = "research door remote"
	icon_state = "gangtool-purple"
	region_access = list(REGION_RESEARCH)

/obj/item/door_remote/head_of_security
	name = "security door remote"
	icon_state = "gangtool-red"
	region_access = list(REGION_SECURITY)

/obj/item/door_remote/quartermaster
	name = "supply door remote"
	icon_state = "gangtool-green"
	region_access = list(REGION_SUPPLY)

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	icon_state = "gangtool-blue"
	region_access = list(REGION_MEDBAY)

/obj/item/door_remote/civillian
	name = "civilian door remote"
	region_access = list(REGION_GENERAL)
	additional_access = list(ACCESS_HOP)

/obj/item/door_remote/centcomm
	name = "centcomm door remote"
	desc = "High-ranking NT officials only."
	icon_state = "gangtool-blue"
	region_access = list(REGION_CENTCOMM)

/obj/item/door_remote/taipan
	name = "Taipan door remote"
	desc = "High-ranking Syndicate officials only."
	icon_state = "gangtool-syndie"
	region_access = list(REGION_TAIPAN)
	z_cross = FALSE

/obj/item/door_remote/omni/access_tuner
	name = "access tuner"
	desc = "A device used for illegally interfacing with doors."
	icon_state = "hacktool"
	item_state = "hacktool"
	emagged = TRUE
	var/hack_speed = 1 SECONDS
	var/busy = FALSE

/obj/item/door_remote/omni/access_tuner/update_icon_state()
	icon_state = "hacktool[busy ? "-g" : ""]"

/obj/item/door_remote/omni/access_tuner/afterattack(obj/machinery/door/airlock/target, mob/user, proximity_flag, list/modifiers, status)
	if(!istype(target))
		return
	if(HAS_TRAIT(target, TRAIT_CMAGGED))
		to_chat(user, span_danger("The door doesn't respond to [src]!"))
		return
	if(busy)
		to_chat(user, span_warning("[src] is alreading interfacing with a door!"))
		return
	busy = TRUE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("[src] is attempting to interface with [target]..."))
	if(do_after(user, hack_speed, target))
		. = ..()
	busy = FALSE
	update_icon(UPDATE_ICON_STATE)

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
#undef WAND_SPEED
#undef WAND_ELECTRIFY
