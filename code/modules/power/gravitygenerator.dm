
//
// Gravity Generator
//

GLOBAL_LIST_EMPTY(gravity_generators) // We will keep track of this by adding new gravity generators to the list, and keying it with the z level.

#define GRAV_POWER_IDLE 0
#define GRAV_POWER_UP 1
#define GRAV_POWER_DOWN 2

#define GRAV_NEEDS_SCREWDRIVER 0
#define GRAV_NEEDS_WELDING 1
#define GRAV_NEEDS_PLASTEEL 2
#define GRAV_NEEDS_WRENCH 3

//
// Abstract Generator
//

/obj/machinery/gravity_generator
	name = "gravitational generator"
	desc = "A device which produces a gravaton field when set up."
	icon = 'icons/obj/machines/gravity_generator.dmi'
	anchored = TRUE
	density = TRUE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | NO_MALF_EFFECT
	var/sprite_number = 0


/obj/machinery/gravity_generator/ex_act(severity)
	if(severity == EXPLODE_DEVASTATE) // Very sturdy.
		set_broken()


/obj/machinery/gravity_generator/blob_act(obj/structure/blob/B)
	if(prob(20))
		set_broken()


/obj/machinery/gravity_generator/tesla_act(power, explosive)
	..()
	if(explosive)
		qdel(src)//like the singulo, tesla deletes it. stops it from exploding over and over


/obj/machinery/gravity_generator/update_icon_state()
	icon_state = "[get_status()]_[sprite_number]"


/obj/machinery/gravity_generator/proc/get_status()
	return "off"


// You aren't allowed to move.
/obj/machinery/gravity_generator/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	qdel(src)


/obj/machinery/gravity_generator/proc/set_broken()
	stat |= BROKEN


/obj/machinery/gravity_generator/proc/set_fix()
	stat &= ~BROKEN



//
// Part generator which is mostly there for looks
//
/obj/machinery/gravity_generator/part
	var/obj/machinery/gravity_generator/main/main_part


/obj/machinery/gravity_generator/part/Destroy()
	UnregisterSignal(main_part, COMSIG_ATOM_UPDATED_ICON)
	if(!QDELETED(main_part))
		qdel(main_part)
	main_part = null
	return ..()


/obj/machinery/gravity_generator/part/attackby(obj/item/I, mob/user, params)
	if(!main_part)
		return ATTACK_CHAIN_BLOCKED_ALL
	return main_part.attackby(I, user, params)


/obj/machinery/gravity_generator/part/get_status()
	if(!main_part)
		return
	return main_part.get_status()


/obj/machinery/gravity_generator/part/attack_hand(mob/user)
	if(!main_part)
		return
	return main_part.attack_hand(user)


/obj/machinery/gravity_generator/part/set_broken()
	..()
	if(main_part && !(main_part.stat & BROKEN))
		main_part.set_broken()


/obj/machinery/gravity_generator/part/proc/on_update_icon(obj/machinery/gravity_generator/source, updates, updated)
	SIGNAL_HANDLER
	return update_icon(updates)


//
// Main Generator with the main code
//

/obj/machinery/gravity_generator/main
	icon_state = "on_8"
	idle_power_usage = 0
	active_power_usage = 3000
	power_channel = ENVIRON
	sprite_number = 8
	use_power = IDLE_POWER_USE
	interact_offline = TRUE
	/// Whether the gravity generator is currently active.
	var/on = TRUE
	/// If the main breaker is on/off, to enable/disable gravity.
	var/breaker = TRUE
	/// List of all gravity generator parts
	var/list/generator_parts = list()
	/// The gravity generator part in the very center, the fifth one, where we place the overlays.
	var/obj/machinery/gravity_generator/part/center_part
	/// If the generatir os idle, charging, or down.
	var/charging_state = GRAV_POWER_IDLE
	/// How much charge the gravity generator has, goes down when breaker is shut, and shuts down at 0.
	var/charge_count = 100
	/// The gravity overlay currently used.
	var/current_overlay
	/// When broken, what stage it is at (GRAV_NEEDS_SCREWDRIVER:0) (GRAV_NEEDS_WELDING:1) (GRAV_NEEDS_PLASTEEL:2) (GRAV_NEEDS_WRENCH:3)
	var/broken_state = GRAV_NEEDS_SCREWDRIVER


/obj/machinery/gravity_generator/main/station/Initialize(mapload)
	. = ..()
	setup_parts()
	if(on)
		enable()
		center_part.add_overlay("activated")


/obj/machinery/gravity_generator/main/Destroy() // If we somehow get deleted, remove all of our other parts.
	investigate_log("was destroyed!", INVESTIGATE_GRAVITY)
	disable()
	for(var/obj/machinery/gravity_generator/part/part as anything in generator_parts)
		if(!QDELETED(part))
			qdel(part)
	center_part = null
	return ..()


/obj/machinery/gravity_generator/main/proc/setup_parts()
	var/turf/our_turf = get_turf(src)
	// 9x9 block obtained from the bottom middle of the block
	var/list/spawn_turfs = block(our_turf.x - 1, our_turf.y + 2, our_turf.z, our_turf.x + 1, our_turf.y, our_turf.z)
	var/count = 10
	for(var/turf/part_turf as anything in spawn_turfs)
		count--
		if(part_turf == our_turf) // Skip our turf.
			continue
		var/obj/machinery/gravity_generator/part/part = new(part_turf)
		if(count == 5) // Middle
			center_part = part
		if(count <= 3) // Their sprite is the top part of the generator
			part.set_density(FALSE)
			part.layer = WALL_OBJ_LAYER
		part.sprite_number = count
		part.main_part = src
		generator_parts += part
		part.update_icon(UPDATE_ICON_STATE)
		part.RegisterSignal(src, COMSIG_ATOM_UPDATED_ICON, TYPE_PROC_REF(/obj/machinery/gravity_generator/part, on_update_icon))


/obj/machinery/gravity_generator/main/set_broken()
	. = ..()
	for(var/obj/machinery/gravity_generator/internal_part as anything in generator_parts)
		if(!(internal_part.stat & BROKEN))
			internal_part.set_broken()
	center_part.cut_overlays()
	charge_count = 0
	breaker = FALSE
	set_power()
	disable()
	investigate_log("has broken down.", INVESTIGATE_GRAVITY)


/obj/machinery/gravity_generator/main/set_fix()
	. = ..()
	for(var/obj/machinery/gravity_generator/internal_part as anything in generator_parts)
		if(internal_part.stat & BROKEN)
			internal_part.set_fix()
	broken_state = FALSE
	update_icon(UPDATE_ICON_STATE)
	set_power()


// Interaction

/obj/machinery/gravity_generator/main/examine(mob/user)
	. = ..()
	if(!(stat & BROKEN))
		return
	switch(broken_state)
		if(GRAV_NEEDS_SCREWDRIVER)
			. += span_info("The entire frame is barely holding together, the <b>screws</b> need to be refastened.")
		if(GRAV_NEEDS_WELDING)
			. += span_info("There's lots of broken seals on the framework, it could use some <b>welding</b>.")
		if(GRAV_NEEDS_PLASTEEL)
			. += span_info("Some of this damaged plating needs full replacement. <b>10 plasteel</> should be enough.")
		if(GRAV_NEEDS_WRENCH)
			. += span_info("The new plating just needs to be <b>bolted</b> into place now.")


/obj/machinery/gravity_generator/main/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || !(stat & BROKEN) || broken_state != GRAV_NEEDS_PLASTEEL || !istype(I, /obj/item/stack/sheet/plasteel))
		return ..()

	add_fingerprint(user)
	var/obj/item/stack/sheet/plasteel/plasteel = I
	var/cached_sound = plasteel.usesound
	if(!plasteel.use(10))
		to_chat(user, span_warning("You need at least ten sheets of plasteel to repair the framework."))
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_PROCEED_SUCCESS
	to_chat(user, span_notice("You have repaired the plating of the framework."))
	playsound(loc, cached_sound, 75, TRUE)
	broken_state++
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gravity_generator/main/screwdriver_act(mob/user, obj/item/I)
	if(broken_state != GRAV_NEEDS_SCREWDRIVER)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	add_fingerprint(user)
	to_chat(user, span_notice("You secure the screws of the framework."))
	broken_state++
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gravity_generator/main/welder_act(mob/user, obj/item/I)
	if(broken_state != GRAV_NEEDS_WELDING)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, amount = 1, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("You mend the damaged framework."))
	broken_state++
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gravity_generator/main/wrench_act(mob/user, obj/item/I)
	if(broken_state != GRAV_NEEDS_WRENCH)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	add_fingerprint(user)
	to_chat(user, span_notice("You secure the plating to the framework."))
	set_fix()


/obj/machinery/gravity_generator/main/attack_hand(mob/user)
	if(!..())
		return interact(user)


/obj/machinery/gravity_generator/main/attack_ai(mob/user)
	return TRUE


/obj/machinery/gravity_generator/main/attack_ghost(mob/user)
	return interact(user)


/obj/machinery/gravity_generator/main/interact(mob/user)
	if(stat & BROKEN)
		return

	var/dat = {"<meta charset="UTF-8">Gravity Generator Breaker: "}
	if(breaker)
		dat += "<span class='linkOn'>ON</span> <a href='byond://?src=[UID()];gentoggle=1'>OFF</A>"
	else
		dat += "<a href='byond://?src=[UID()];gentoggle=1'>ON</A> <span class='linkOn'>OFF</span> "

	dat += "<br>Generator Status:<br><div class='statusDisplay'>"
	if(charging_state != GRAV_POWER_IDLE)
		dat += "<font class='bad'>WARNING</font> Radiation Detected. <br>[charging_state == GRAV_POWER_UP ? "Charging..." : "Discharging..."]"
	else if(on)
		dat += "Powered."
	else
		dat += "Unpowered."

	dat += "<br>Gravity Charge: [charge_count]%</div>"

	var/datum/browser/popup = new(user, "gravgen", name)
	popup.set_content(dat)
	popup.open()


/obj/machinery/gravity_generator/main/Topic(href, href_list)
	if(..())
		return TRUE

	if(href_list["gentoggle"])
		breaker = !breaker
		investigate_log("was toggled [breaker ? "<font color='green'>ON</font>" : "<font color='red'>OFF</font>"] by [key_name_log(usr)].", INVESTIGATE_GRAVITY)
		set_power()
		updateUsrDialog()


// Power and Icon States

/obj/machinery/gravity_generator/main/power_change(forced = FALSE)
	. = ..()
	investigate_log("has [stat & NOPOWER ? "lost" : "regained"] power.", INVESTIGATE_GRAVITY)
	set_power()


/obj/machinery/gravity_generator/main/get_status()
	if(stat & BROKEN)
		return "fix[min(broken_state, 3)]"
	return on || charging_state != GRAV_POWER_IDLE ? "on" : "off"


// Set the charging state based on power/breaker.
/obj/machinery/gravity_generator/main/proc/set_power()
	var/new_state = FALSE
	if(stat & (NOPOWER|BROKEN) || !breaker)
		new_state = FALSE
	else if(breaker)
		new_state = TRUE

	charging_state = new_state ? GRAV_POWER_UP : GRAV_POWER_DOWN // Startup sequence animation.
	investigate_log("is now [charging_state == GRAV_POWER_UP ? "charging" : "discharging"].", INVESTIGATE_GRAVITY)
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gravity_generator/main/proc/enable()
	charging_state = GRAV_POWER_IDLE
	on = TRUE
	use_power = ACTIVE_POWER_USE

	var/old_gravity = gravity_in_level()
	update_icon(UPDATE_ICON_STATE)
	update_list()

	if(!old_gravity)
		investigate_log("was brought online and is now producing gravity for this level.", INVESTIGATE_GRAVITY)
		message_admins("The gravity generator was brought online. [ADMIN_VERBOSEJMP(src)]")
		shake_everyone()


/obj/machinery/gravity_generator/main/proc/disable()
	charging_state = GRAV_POWER_IDLE
	on = FALSE
	use_power = IDLE_POWER_USE

	var/old_gravity = gravity_in_level()
	update_icon(UPDATE_ICON_STATE)
	update_list()

	if(old_gravity)
		investigate_log("was brought offline and there is now no gravity for this level.", INVESTIGATE_GRAVITY)
		message_admins("The gravity generator was brought offline with no backup generator. [ADMIN_VERBOSEJMP(src)]")
		shake_everyone()


// Charge/Discharge and turn on/off gravity when you reach 0/100 percent.
// Also emit radiation and handle the overlays.
/obj/machinery/gravity_generator/main/process()
	if((stat & BROKEN) || charging_state == GRAV_POWER_IDLE)
		return
	if(charging_state == GRAV_POWER_UP && charge_count >= 100)
		enable()
		return
	if(charging_state == GRAV_POWER_DOWN && charge_count <= 0)
		disable()
		return

	switch(charging_state)
		if(GRAV_POWER_UP)
			charge_count += 2
		if(GRAV_POWER_DOWN)
			charge_count -= 2

	if(!(charge_count % 4) && prob(75)) // Let them know it is charging/discharging.
		playsound(loc, 'sound/effects/empulse.ogg', 100, TRUE)

	updateDialog()
	if(prob(25)) // To help stop "Your clothes feel warm" spam.
		for(var/mob/living/victim in view(7, src))
			victim.apply_effect(20, IRRADIATE)

	var/overlay_state = null
	switch(charge_count)
		if(21 to 40)
			overlay_state = "startup"
		if(41 to 60)
			overlay_state = "idle"
		if(61 to 80)
			overlay_state = "activating"
		if(81 to 100)
			overlay_state = "activated"

	if(center_part && overlay_state != current_overlay)
		center_part.cut_overlays()
		if(overlay_state)
			center_part.add_overlay(overlay_state)
		current_overlay = overlay_state


// Shake everyone on the z level to let them know that gravity was enagaged/disenagaged.
/obj/machinery/gravity_generator/main/proc/shake_everyone()
	var/turf/our_turf = get_turf(src)
	var/sound/alert_sound = sound('sound/effects/alert.ogg')
	for(var/mob/shaked as anything in GLOB.mob_list)
		var/turf/mob_turf = get_turf(shaked)
		if(!istype(mob_turf))
			continue
		if(!is_valid_z_level(our_turf, mob_turf))
			continue
		if(isliving(shaked))
			var/mob/living/living_shaked = shaked
			living_shaked.refresh_gravity()
		if(shaked.client)
			shake_camera(shaked, 15, 1)
			shaked.playsound_local(our_turf, null, 100, 1, 0.5, S = alert_sound)


// TODO: Make the gravity generator cooperate with the space manager
/obj/machinery/gravity_generator/main/proc/gravity_in_level()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return FALSE
	if(GLOB.gravity_generators["[our_turf.z]"])
		return length(GLOB.gravity_generators["[our_turf.z]"])
	return FALSE


/obj/machinery/gravity_generator/main/proc/update_list()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	var/list/z_list = list()
	// Multi-Z, station gravity generator generates gravity on all STATION_LEVEL z-levels.
	if(check_level_trait(our_turf.z, STATION_LEVEL))
		for(var/z in levels_by_trait(STATION_LEVEL))
			z_list += z
	else
		z_list += our_turf.z
	for(var/z in z_list)
		if(!GLOB.gravity_generators["[z]"])
			GLOB.gravity_generators["[z]"] = list()
		if(on)
			GLOB.gravity_generators["[z]"] |= src
		else
			GLOB.gravity_generators["[z]"] -= src


// Misc

/obj/item/paper/gravity_gen
	name = "paper- 'Generate your own gravity!'"
	info = {"<h1>Gravity Generator Instructions For Dummies</h1>
	<p>Surprisingly, gravity isn't that hard to make! All you have to do is inject deadly radioactive minerals into a ball of
	energy and you have yourself gravity! You can turn the machine on or off when required but you must remember that the generator
	will EMIT RADIATION when charging or discharging, you can tell it is charging or discharging by the noise it makes, so please WEAR PROTECTIVE CLOTHING.</p>
	<br>
	<h3>It blew up!</h3>
	<p>Don't panic! The gravity generator was designed to be easily repaired. If, somehow, the sturdy framework did not survive then
	please proceed to panic; otherwise follow these steps.</p><ol>
	<li>Secure the screws of the framework with a screwdriver.</li>
	<li>Mend the damaged framework with a welding tool.</li>
	<li>Add additional plasteel plating.</li>
	<li>Secure the additional plating with a wrench.</li></ol>"}

