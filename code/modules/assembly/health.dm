#define MAX_HEALTH_ACTIVATE 0
#define MIN_HEALTH_ACTIVATE -90

/obj/item/assembly/health
	name = "health sensor"
	desc = "Used for scanning and monitoring health."
	icon_state = "health"
	materials = list(MAT_METAL=800, MAT_GLASS=200)
	origin_tech = "magnets=1;biotech=1"
	secured = FALSE

	/// Are we scanning our user's health?
	var/scanning = FALSE
	/// Our user's health
	var/user_health
	/// The health amount on which to activate
	var/alarm_health = MAX_HEALTH_ACTIVATE


/obj/item/assembly/health/activate()
	if(!..())
		return FALSE//Cooldown check
	toggle_scan()
	return FALSE


/obj/item/assembly/health/toggle_secure()
	secured = !secured
	if(secured && scanning)
		START_PROCESSING(SSobj, src)
	else
		scanning = FALSE
		user_health = null // Clear out the user data, we're no longer scanning
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured


/obj/item/assembly/health/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(alarm_health == MAX_HEALTH_ACTIVATE)
		alarm_health = MIN_HEALTH_ACTIVATE
		user.show_message("You toggle [src] to \"detect death\" mode.")
	else
		alarm_health = MAX_HEALTH_ACTIVATE
		user.show_message("You toggle [src] to \"detect critical state\" mode.")


/obj/item/assembly/health/process()
	if(!scanning || !secured)
		return PROCESS_KILL	// It should never reach here, but if it somehow does stop processing

	var/mob/living/user = get(loc, /mob/living)
	if(!user)
		user_health = null // We aint on a living thing, remove the previous data
		return

	user_health = user.health
	if(user_health <= alarm_health) // Its a health detector, not a death detector
		pulse(FALSE, user)
		user.audible_message("[bicon(src)] *beep* *beep*")
		toggle_scan()


/obj/item/assembly/health/proc/toggle_scan()
	if(!secured)
		return FALSE
	scanning = !scanning
	if(scanning)
		START_PROCESSING(SSobj, src)
	else
		user_health = null // Clear out the user data, we're no longer scanning
		STOP_PROCESSING(SSobj, src)


/obj/item/assembly/health/interact(mob/user)//TODO: Change this to the wires thingy
	if(!secured)
		user.show_message(span_warning("The [name] is unsecured!"))
		return FALSE
	var/dat = {"<meta charset="UTF-8"><TT><B>Health Sensor</B> <a href='byond://?src=[UID()];scanning=1'>[scanning?"On":"Off"]</A>"}
	if(scanning && !isnull(user_health))
		dat += "<BR>Health: [user_health]"
	var/datum/browser/popup = new(user, "hscan", name, 400, 400, src)
	popup.set_content(dat)
	popup.open()


/obj/item/assembly/health/Topic(href, href_list)
	..()
	if(!isliving(usr))
		return

	var/mob/living/user = usr

	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !in_range(loc, user))
		user << browse(null, "window=hscan")
		onclose(user, "hscan")
		return

	if(href_list["scanning"])
		toggle_scan()

	if(href_list["close"])
		user << browse(null, "window=hscan")
		return

	attack_self(user)


#undef MAX_HEALTH_ACTIVATE
#undef MIN_HEALTH_ACTIVATE

