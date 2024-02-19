/*

Miscellaneous traitor devices

BATTERER


*/

/*

The Batterer, like a flashbang but 50% chance to knock people over. Can be either very
effective or pretty fucking useless.

*/

/obj/item/batterer
	name = "mind batterer"
	desc = "A strange device with twin antennas."
	icon = 'icons/obj/device.dmi'
	icon_state = "batterer"
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	flags = CONDUCT
	item_state = "electronic"
	origin_tech = "magnets=3;combat=3;syndicate=3"

	var/charges = 3


/obj/item/batterer/examine(mob/user)
	. = ..()
	. += span_notice("[src] has [charges] charges left.")


/obj/item/batterer/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user)
		return
	if(charges == 0)
		to_chat(user, span_danger("The mind batterer is out of charge!"))
		return


	for(var/mob/living/carbon/human/M in orange (10, user))
		if(prob(50))
			M.Weaken(rand(2,6) SECONDS)
			M.adjustStaminaLoss(rand(35, 60))
			add_attack_logs(user, M, "Stunned with [src]")
			to_chat(M, span_danger("You feel a tremendous, paralyzing wave flood your mind."))
		else
			to_chat(M, span_danger("You feel a sudden, electric jolt travel through your head."))
			M.Slowed(10 SECONDS)
			M.Confused(6 SECONDS)

	playsound(loc, 'sound/misc/interference.ogg', 50, 1)
	charges--
	to_chat(user,span_notice("You trigger [src]. It has [charges] charges left."))
	addtimer(CALLBACK(src, PROC_REF(recharge)), 3 MINUTES)


/obj/item/batterer/proc/recharge()
	charges++



/*
		The radioactive microlaser, a device disguised as a health analyzer used to irradiate people.

		The strength of the radiation is determined by the 'intensity' setting, while the delay between
	the scan and the irradiation kicking in is determined by the wavelength.

		Each scan will cause the microlaser to have a brief cooldown period. Higher intensity will increase
	the cooldown, while higher wavelength will decrease it.

		Wavelength is also slightly increased by the intensity as well.
*/

/obj/item/rad_laser
	name = "Health Analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health2"
	item_state = "healthanalyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject. A strange microlaser is hooked on to the scanning end."
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=400)
	origin_tech = "magnets=3;biotech=5;syndicate=1"
	var/intensity = 5 // how much damage the radiation does
	var/wavelength = 10 // time it takes for the radiation to kick in, in seconds
	var/used = 0 // is it cooling down?


/obj/item/rad_laser/update_icon_state()
	icon_state = used ? "health1" : "health2"


/obj/item/rad_laser/attack(mob/living/target, mob/living/user)
	if(used)
		to_chat(user, span_warning("The radioactive microlaser is still recharging."))
		return

	add_attack_logs(user, target, "Irradiated by [src]")
	user.visible_message(span_notice("[user] analyzes [target]'s vitals."))
	var/cooldown = round(max(100,(((intensity*8)-(wavelength/2))+(intensity*2))*10))
	used = TRUE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), cooldown)
	addtimer(CALLBACK(src, PROC_REF(delayed_effect), target), (wavelength + (intensity * 4)) SECONDS)


/obj/item/rad_laser/proc/reset_cooldown()
	used = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/item/rad_laser/proc/delayed_effect(mob/living/target)
	if(QDELETED(target))
		return
	if(intensity >= 5)
		target.Paralyse((intensity * 40 / 3) SECONDS)
		target.apply_effect(intensity * 10, IRRADIATE)


/obj/item/rad_laser/attack_self(mob/user)
	..()
	interact(user)


/obj/item/rad_laser/interact(mob/user)
	user.set_machine(src)

	var/cooldown = round(max(10,((intensity*8)-(wavelength/2))+(intensity*2)))
	var/dat = {"<meta charset="UTF-8">
	Radiation Intensity: <A href='?src=[UID()];radint=-5'>-</A><A href='?src=[UID()];radint=-1'>-</A> [intensity] <A href='?src=[UID()];radint=1'>+</A><A href='?src=[UID()];radint=5'>+</A><BR>
	Radiation Wavelength: <A href='?src=[UID()];radwav=-5'>-</A><A href='?src=[UID()];radwav=-1'>-</A> [(wavelength+(intensity*4))] <A href='?src=[UID()];radwav=1'>+</A><A href='?src=[UID()];radwav=5'>+</A><BR>
	Laser Cooldown: [cooldown] Seconds<BR>
	"}

	var/datum/browser/popup = new(user, "radlaser", "Radioactive Microlaser Interface", 400, 240)
	popup.set_content(dat)
	popup.open()


/obj/item/rad_laser/Topic(href, href_list)
	if(..())
		return 1

	usr.set_machine(src)

	if(href_list["radint"])
		var/amount = text2num(href_list["radint"])
		amount += intensity
		intensity = max(1,(min(10,amount)))

	else if(href_list["radwav"])
		var/amount = text2num(href_list["radwav"])
		amount += wavelength
		wavelength = max(1,(min(120,amount)))

	attack_self(usr)
	add_fingerprint(usr)



/obj/item/jammer
	name = "radio jammer"
	desc = "Device used to disrupt nearby radio communication."
	icon = 'icons/obj/device.dmi'
	icon_state = "jammer"
	var/active = FALSE
	var/range = 12


/obj/item/jammer/Destroy()
	GLOB.active_jammers -= src
	return ..()


/obj/item/jammer/attack_self(mob/user)
	to_chat(user, span_notice("You [active ? "deactivate" : "activate"] the [src]."))
	active = !active
	if(active)
		GLOB.active_jammers |= src
	else
		GLOB.active_jammers -= src

/obj/item/teleporter
	name = "Syndicate teleporter"
	desc = "A strange syndicate version of a cult veil shifter. Warranty voided if exposed to EMP."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndi-tele-4"
	base_icon_state = "syndi-tele"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 10
	flags = CONDUCT
	item_state = "electronic"
	origin_tech = "magnets=3;combat=3;syndicate=3"
	var/tp_range = 8
	var/inner_tp_range = 3
	var/charges = 4
	var/max_charges = 4
	var/saving_throw_distance = 3
	var/flawless = FALSE


/obj/item/teleporter/Destroy()
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/teleporter/examine(mob/user)
	. = ..()
	. += span_notice("[src] has <b>[charges]</b> out of <b>[max_charges]</b> charges left.")


/obj/item/teleporter/update_icon_state()
	icon_state = "[base_icon_state]-[charges]"


/obj/item/teleporter/attack_self(mob/user)
	attempt_teleport(user, FALSE)


/obj/item/teleporter/process()
	if(charges >= max_charges)
		return PROCESS_KILL

	if(prob(10))
		charges++
		update_icon(UPDATE_ICON_STATE)


/obj/item/teleporter/emp_act(severity)
	if(!prob(50 / severity))
		return

	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		to_chat(user, span_danger("The [src] buzzes and activates!"))
		attempt_teleport(user, TRUE)
		return

	// Well, it either is on a floor / locker, and won't teleport someone,
	// OR it's in someones bag. As such, we need to check the turf to see if people are there.
	var/teleported_something = FALSE
	var/turf/teleport_turf = get_turf(src)
	for(var/mob/living/user in teleport_turf)
		teleported_something = TRUE
		attempt_teleport(user, TRUE)

	if(teleported_something)
		teleport_turf.visible_message(span_danger("[src] activates sporadically, teleporting everyone around it!"))
		return

	visible_message(span_warning("The [src] activates and blinks out of existence!"))
	do_sparks(2, TRUE, src)
	qdel(src)


/obj/item/teleporter/proc/attempt_teleport(mob/living/user, EMP_D = FALSE)
	for(var/obj/item/grab/G in user)
		qdel(G)
	dir_correction(user)
	if(!charges && !EMP_D) //If it's empd, you are moving no matter what.
		to_chat(user, span_warning("[src] is still recharging."))
		return

	var/turf/mobloc = get_turf(user)
	var/list/turfs = list()
	var/found_turf = FALSE
	var/list/bagholding = user.search_contents_for(/obj/item/storage/backpack/holding)
	for(var/turf/check in range(user, tp_range))
		if(!is_teleport_allowed(check.z))
			break
		if(!(length(bagholding) && !flawless)) //Chaos if you have a bag of holding
			if(get_dir(user, check) != user.dir)
				continue
		if(check in range(user, inner_tp_range))
			continue
		if(check.x > world.maxx-tp_range || check.x < tp_range)
			continue	//putting them at the edge is dumb
		if(check.y > world.maxy-tp_range || check.y < tp_range)
			continue

		turfs += check
		found_turf = TRUE

	if(!found_turf)
		to_chat(user, span_danger("[src] will not work here!"))
		return

	if(user.loc != mobloc) // No locker / mech / sleeper teleporting, that breaks stuff
		to_chat(user, span_danger("[src] will not work here!"))

	if(charges > 0) //While we want EMP triggered teleports to drain charge, we also do not want it to go negative charge, as such we need this check here
		charges--
		update_icon(UPDATE_ICON_STATE)
		if(!isprocessing)
			START_PROCESSING(SSobj, src)

	var/turf/destination = pick(turfs)
	if(tile_check(destination) || flawless) // Why is there so many bloody floor types
		var/turf/fragging_location = destination
		telefrag(fragging_location, user)
		user.forceMove(destination)
		playsound(mobloc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		new/obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
		playsound(destination, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		new/obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
	else if(EMP_D == FALSE && !(length(bagholding) && !flawless)) // This is where the fun begins
		var/direction = get_dir(user, destination)
		panic_teleport(user, destination, direction)
	else // Emp activated? Bag of holding? No saving throw for you
		get_fragged(user, destination)


/obj/item/teleporter/proc/tile_check(turf/check_turf)
	return isfloorturf(check_turf) || isspaceturf(check_turf)


/obj/item/teleporter/proc/dir_correction(mob/user) //Direction movement, screws with teleport distance and saving throw, and thus must be removed first
	var/temp_direction = user.dir
	switch(temp_direction)
		if(NORTHEAST, SOUTHEAST)
			user.dir = EAST
		if(NORTHWEST, SOUTHWEST)
			user.dir = WEST


/obj/item/teleporter/proc/panic_teleport(mob/living/user, turf/destination, direction = NORTH)
	var/saving_throw
	switch(direction)
		if(NORTH, SOUTH)
			if(prob(50))
				saving_throw = EAST
			else
				saving_throw = WEST
		if(EAST, WEST)
			if(prob(50))
				saving_throw = NORTH
			else
				saving_throw = SOUTH
		else
			saving_throw = NORTH // just in case

	var/turf/mobloc = get_turf(user)
	var/list/turfs = list()
	var/found_turf = FALSE
	for(var/turf/check in range(destination, saving_throw_distance))
		if(get_dir(destination, check) != saving_throw)
			continue
		if(check.x > world.maxx-saving_throw_distance || check.x < saving_throw_distance)
			continue	//putting them at the edge is dumb
		if(check.y > world.maxy-saving_throw_distance || check.y < saving_throw_distance)
			continue
		if(!tile_check(check))
			continue // We are only looking for safe tiles on the saving throw, since we are nice
		turfs += check
		found_turf = TRUE

	if(!found_turf)
		get_fragged(user, destination)	//We tried to save. We failed. Death time.
		return

	var/turf/new_destination = pick(turfs)
	var/turf/fragging_location = new_destination
	telefrag(fragging_location, user)
	user.forceMove(new_destination)
	playsound(mobloc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(new_destination)
	playsound(new_destination, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)


/obj/item/teleporter/proc/get_fragged(mob/user, turf/destination)
	var/turf/mobloc = get_turf(user)
	user.forceMove(destination)
	playsound(mobloc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
	playsound(destination, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(destination, "sound/magic/disintegrate.ogg", 50, TRUE)
	destination.ex_act(rand(1,2))
	for(var/obj/item/thing as anything in user.get_equipped_items(TRUE, TRUE))
		if(!user.drop_item_ground(thing))
			qdel(thing)
	to_chat(user, span_dangerbigger("You teleport into the wall, the teleporter tries to save you, but--"))
	user.gib()


/obj/item/teleporter/proc/telefrag(turf/fragging_location, mob/user)
	for(var/mob/living/target in fragging_location)//Hit everything in the turf
		target.apply_damage(20, BRUTE)
		target.Weaken(6 SECONDS)
		to_chat(target, span_warning("[user] teleports into you, knocking you to the floor with the bluespace wave!"))


/obj/item/paper/teleporter
	name = "Teleporter Guide"
	icon_state = "paper"
	info = {"<b>Instructions on your new prototype syndicate teleporter</b><br>
	<br>
	This teleporter will teleport the user 4-8 meters in the direction they are facing. Unlike the cult veil shifter, you can not drag people with you.<br>
	<br>
	It has 4 charges, and will recharge uses over time. No, sticking the teleporter into the tesla, an APC, a microwave, or an electrified door, will not make it charge faster.<br>
	<br>
	<b>Warning:</b> Teleporting into walls will activate a failsafe teleport parallel up to 3 meters, but the user will be ripped apart and gibbed in a wall if it fails.<br>
	<br>
	Do not expose the teleporter to electromagnetic pulses or attempt to use with a bag of holding, unwanted malfunctions may occur.
"}


/obj/item/storage/box/syndie_kit/teleporter
	name = "syndicate teleporter kit"


/obj/item/storage/box/syndie_kit/teleporter/populate_contents()
	new /obj/item/teleporter(src)
	new /obj/item/paper/teleporter(src)
	new /obj/item/clothing/glasses/chameleon/meson(src)


/obj/effect/temp_visual/teleport_abductor/syndi_teleporter
	duration = 5


/obj/item/teleporter/admin
	desc = "A strange syndicate version of a cult veil shifter. \n This one seems EMP proof, and with much better saftey protocols."
	charges = 8
	max_charges = 8
	flawless = TRUE

