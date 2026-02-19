/obj/item/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	bomb_name = "proximity mine"
	/// Is it currently scanning in proximity
	var/scanning = FALSE
	/// Is it arming right now
	var/timing = FALSE
	/// Time before armed
	var/time = 10

/obj/item/assembly/prox_sensor/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, _ignore_if_not_on_turf = FALSE)

/obj/item/assembly/prox_sensor/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(proximity_monitor)
	return ..()

/obj/item/assembly/prox_sensor/examine(mob/user)
	. = ..()
	if(timing)
		. += span_notice("The proximity sensor is arming.")
	else
		. += span_notice("The proximity sensor is [scanning ? "armed" : "disarmed"].")

/obj/item/assembly/prox_sensor/activate()
	if(!..())
		return FALSE //Cooldown check
	timing = !timing
	update_icon()
	return FALSE

/obj/item/assembly/prox_sensor/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	sense(user)

/obj/item/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		scanning = FALSE
		timing = FALSE
		STOP_PROCESSING(SSobj, src)
	update_appearance()
	return secured

/obj/item/assembly/prox_sensor/HasProximity(atom/movable/movable)
	if(iseffect(movable))
		return
	sense()

/obj/item/assembly/prox_sensor/proc/sense(atom/movable/movable)
	if(!secured || !scanning || !COOLDOWN_FINISHED(src, cooldown))
		return FALSE

	var/mob/triggered
	if(ismob(movable))
		triggered = movable

	COOLDOWN_START(src, cooldown, cooldown_time)
	pulse(FALSE, triggered)
	audible_message("[icon2html(src, hearers(loc))] *beep* *beep* *beep*")
	playsound(src, 'sound/machines/triple_beep.ogg', 40, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

/obj/item/assembly/prox_sensor/process()
	if(timing && (time >= 0))
		time--
	if(timing && time <= 0)
		timing = FALSE
		toggle_scan()
		time = 10

/obj/item/assembly/prox_sensor/proc/toggle_scan()
	if(!secured)
		return FALSE
	scanning = !scanning
	update_icon()

/obj/item/assembly/prox_sensor/update_overlays()
	. = ..()
	attached_overlays = list()
	if(timing)
		. += "prox_timing"
		attached_overlays += "prox_timing"
	if(scanning)
		. += "prox_scanning"
		attached_overlays += "prox_scanning"
	holder?.update_icon()

/obj/item/assembly/prox_sensor/interact(mob/user)//TODO: Change this to the wires thingy
	if(!secured)
		user.show_message(span_warning("The [name] is unsecured!"))
		return FALSE
	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = "<tt><b>Proximity Sensor</b>\n[(timing ? "<a href='byond://?src=[UID()];time=0'>Arming</a>" : "<a href='byond://?src=[UID()];time=1'>Not Arming</a>")] [minute]:[second]\n \
	<a href='byond://?src=[UID()];tp=-30'>-</a> <a href='byond://?src=[UID()];tp=-1'>-</a> <a href='byond://?src=[UID()];tp=1'>+</a> <a href='byond://?src=[UID()];tp=30'>+</a>\n</tt>"
	dat += "<br><a href='byond://?src=[UID()];scanning=1'>[scanning?"Armed":"Unarmed"]</a> (Movement sensor active when armed!)"
	dat += "<br><br><a href='byond://?src=[UID()];refresh=1'>Refresh</a>"
	dat += "<br><br><a href='byond://?src=[UID()];close=1'>Close</a>"
	var/datum/browser/popup = new(user, "prox", name, 400, 400, src)
	popup.set_content(dat)
	popup.open()

/obj/item/assembly/prox_sensor/Topic(href, href_list)
	..()
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || !in_range(loc, usr))
		close_window(usr, "prox")
		onclose(usr, "prox")
		return

	if(href_list["scanning"])
		toggle_scan()

	if(href_list["time"])
		timing = text2num(href_list["time"])
		update_icon()

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 0), 600)

	if(href_list["close"])
		close_window(usr, "prox")
		return

	if(usr)
		attack_self(usr)

