#define MIN_CONTROLLER_SPEED 1
#define MAX_CONTROLLER_SPEED 10
#define MIN_ELECTRICITY_LEVEL 1
#define MAX_ELECTRICITY_LEVEL 12
#define MIN_MAGNETIC_FIELD 1
#define MAX_MAGNETIC_FIELD 4
#define MAX_PATH_LENGTH 50


// Magnetic attractor, creates variable magnetic fields and attraction.
// Can also be used to emit electron/proton beams to create a center of magnetism on another tile

// tl;dr: it's magnets lol
// This was created for firing ranges, but I suppose this could have other applications - Doohl

/obj/machinery/magnetic_module
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_magnet-f"
	name = "Electromagnetic Generator"
	desc = "A device that uses station power to create points of magnetic energy."
	level = 1		// underfloor
	layer = WIRE_LAYER+0.001
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	/// Radio frequency
	var/freq = AIRLOCK_FREQ
	/// Intensity of the magnetic pull
	var/electricity_level = MIN_ELECTRICITY_LEVEL
	/// The range of magnetic attraction
	var/magnetic_field = MIN_MAGNETIC_FIELD
	/// Frequency code, they should be different unless you have a group of magnets working together or something
	var/code = 0
	/// The center of magnetic attraction
	var/turf/center
	var/on = FALSE
	var/magpulling = FALSE

	// x, y modifiers to the center turf; (0, 0) is centered on the magnet, whereas (1, -1) is one tile right, one tile down
	var/center_x = 0
	var/center_y = 0
	/// absolute value of center_x,y cannot exceed this integer
	var/max_dist = 20


/obj/machinery/magnetic_module/Initialize(mapload)
	..()
	var/turf/T = loc
	if(!T.transparent_floor)
		hide(T.intact)
	center = T

	SSradio.add_object(src, freq, RADIO_MAGNETS)

	INVOKE_ASYNC(src, PROC_REF(magnetic_process))


	// update the invisibility and icon
/obj/machinery/magnetic_module/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	update_icon(UPDATE_ICON_STATE)


	// update the icon_state
/obj/machinery/magnetic_module/update_icon_state()
	// if invisible, set icon to faded version
	// in case of being revealed by T-scanner
	icon_state = "floor_magnet[on ? "" : "0"][invisibility ? "-f" : ""]"


/obj/machinery/magnetic_module/receive_signal(datum/signal/signal)
	var/command = signal.data["command"]
	var/modifier = signal.data["modifier"]
	var/signal_code = signal.data["code"]
	if(command && (signal_code == code))
		Cmd(command, modifier)


/obj/machinery/magnetic_module/proc/Cmd(command, modifier)
	if(command)
		switch(command)
			if("set-electriclevel")
				if(modifier)
					electricity_level = modifier
			if("set-magneticfield")
				if(modifier)
					magnetic_field = modifier
			if("add-elec")
				electricity_level++
				if(electricity_level > MAX_ELECTRICITY_LEVEL)
					electricity_level = MAX_ELECTRICITY_LEVEL
			if("sub-elec")
				electricity_level--
				if(electricity_level < MIN_ELECTRICITY_LEVEL)
					electricity_level = MIN_ELECTRICITY_LEVEL
			if("add-mag")
				magnetic_field++
				if(magnetic_field > MAX_MAGNETIC_FIELD)
					magnetic_field = MAX_MAGNETIC_FIELD
			if("sub-mag")
				magnetic_field--
				if(magnetic_field < MIN_MAGNETIC_FIELD)
					magnetic_field = MIN_MAGNETIC_FIELD

			if("set-x")
				if(modifier)
					center_x = modifier
			if("set-y")
				if(modifier)
					center_y = modifier

			if("N") // NORTH
				center_y++
			if("S")	// SOUTH
				center_y--
			if("E") // EAST
				center_x++
			if("W") // WEST
				center_x--
			if("C") // CENTER
				center_x = 0
				center_y = 0
			if("R") // RANDOM
				center_x = rand(-max_dist, max_dist)
				center_y = rand(-max_dist, max_dist)

			if("set-code")
				if(modifier)	code = modifier
			if("toggle-power")
				on = !on
				if(on)
					INVOKE_ASYNC(src, PROC_REF(magnetic_process))


/obj/machinery/magnetic_module/process()
	if(stat & NOPOWER)
		on = FALSE

	// Sanity checks:
	if(electricity_level < MIN_ELECTRICITY_LEVEL)
		electricity_level = MIN_ELECTRICITY_LEVEL
	if(magnetic_field < MIN_MAGNETIC_FIELD)
		magnetic_field = MIN_MAGNETIC_FIELD

	// Limitations:
	if(abs(center_x) > max_dist)
		center_x = max_dist
	if(abs(center_y) > max_dist)
		center_y = max_dist
	if(magnetic_field > MAX_MAGNETIC_FIELD)
		magnetic_field = MAX_MAGNETIC_FIELD
	if(electricity_level > MAX_ELECTRICITY_LEVEL)
		electricity_level = MAX_ELECTRICITY_LEVEL

	// Update power usage:
	if(on)
		use_power = ACTIVE_POWER_USE
		active_power_usage = electricity_level * 15
	else
		use_power = NO_POWER_USE
		update_icon(UPDATE_ICON_STATE)


// proc that actually does the pulling
/obj/machinery/magnetic_module/proc/magnetic_process()
	if(magpulling)
		return

	while(on)
		magpulling = TRUE
		center = locate(x+center_x, y+center_y, z)
		if(center)
			for(var/obj/object in orange(magnetic_field, center))
				if(!object.anchored && (object.flags & CONDUCT))
					step_towards(object, center)

			for(var/mob/living/silicon/silicon in orange(magnetic_field, center))
				if(isAI(silicon))
					continue
				step_towards(silicon, center)

		use_power(electricity_level * 5)
		sleep(1.3 SECONDS - electricity_level)

	magpulling = FALSE


/obj/machinery/magnetic_controller
	name = "Magnetic Control Console"
	icon = 'icons/obj/machines/airlock_machines.dmi' // uses an airlock machine icon, THINK GREEN HELP THE ENVIRONMENT - RECYCLING!
	icon_state = "airlock_control_standby"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 45
	frequency = AIRLOCK_FREQ
	var/code = 0
	var/list/magnets = list()
	var/title = "Magnetic Control Console"
	/// If set to TRUE, can't probe for other magnets!
	var/autolink = FALSE
	var/probing = FALSE

	/// Position in the path
	var/pathpos = 1
	/// Text path of the magnet
	var/path = "NULL"
	var/speed = MIN_CONTROLLER_SPEED
	/// Real path of the magnet, used in iterator
	var/list/rpath = list()
	var/static/list/valid_paths = list("n", "s", "e", "w", "c", "r")

	/// TRUE if scheduled to loop
	var/moving = FALSE
	/// TRUE if looping
	var/looping = FALSE


/obj/machinery/magnetic_controller/Initialize(mapload)
	. = ..()

	radio_connection = SSradio.add_object(src, frequency, RADIO_MAGNETS)

	if(path) // check for default path
		filter_path() // renders rpath

	if(autolink)
		return INITIALIZE_HINT_LATELOAD


/obj/machinery/magnetic_controller/LateInitialize()
	..()
	if(autolink)
		// GLOB.machines is populated in /machinery/Initialize
		// so linkage gets delayed until that one finished.
		link_magnets()


/obj/machinery/magnetic_controller/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()


/obj/machinery/magnetic_controller/proc/link_magnets()
	magnets = list()
	for(var/obj/machinery/magnetic_module/module in GLOB.machines)
		if(module.freq == frequency && module.code == code)
			magnets += module
			RegisterSignal(module, COMSIG_QDELETING, PROC_REF(on_magnet_del), TRUE)


/obj/machinery/magnetic_controller/proc/on_magnet_del(magnet)
	SIGNAL_HANDLER
	magnets -= magnet


/obj/machinery/magnetic_controller/process()
	if(!length(magnets) && autolink)
		for(var/obj/machinery/magnetic_module/module in GLOB.machines)
			if(module.freq == frequency && module.code == code)
				magnets += module


/obj/machinery/magnetic_controller/attack_ai(mob/user as mob)
	return attack_hand(user)


/obj/machinery/magnetic_controller/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)
	var/dat = {"<meta charset="UTF-8"><B>Magnetic Control Console</B><BR><BR>"}
	if(!autolink)
		dat += {"
		Frequency: <a href='byond://?src=[UID()];operation=setfreq'>[frequency]</a><br>
		Code: <a href='byond://?src=[UID()];operation=setfreq'>[code]</a><br>
		<a href='byond://?src=[UID()];operation=probe'>Probe Generators</a><br>
		"}

	if(length(magnets))

		dat += "Magnets confirmed: <br>"
		var/i = 0
		for(var/obj/machinery/magnetic_module/module as anything in magnets)
			i++
			dat += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;< \[[i]\] (<a href='byond://?src=[UID()];radio-op=togglepower'>[module.on ? "On":"Off"]</a>) | Electricity level: <a href='byond://?src=[UID()];radio-op=minuselec'>-</a> [module.electricity_level] <a href='byond://?src=[UID()];radio-op=pluselec'>+</a>; Magnetic field: <a href='byond://?src=[UID()];radio-op=minusmag'>-</a> [module.magnetic_field] <a href='byond://?src=[UID()];radio-op=plusmag'>+</a><br>"

	add_fingerprint(user)
	dat += "<br>Speed: <a href='byond://?src=[UID()];operation=minusspeed'>-</a> [speed] <a href='byond://?src=[UID()];operation=plusspeed'>+</a><br>"
	dat += "Path: {<a href='byond://?src=[UID()];operation=setpath'>[path]</a>}<br>"
	dat += "Moving: <a href='byond://?src=[UID()];operation=togglemoving'>[moving ? "Enabled":"Disabled"]</a>"


	user << browse(dat, "window=magnet;size=400x500")
	onclose(user, "magnet")


/obj/machinery/magnetic_controller/Topic(href, href_list)
	if(stat & (BROKEN|NOPOWER))
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)

	if(href_list["radio-op"])

		// Prepare signal beforehand, because this is a radio operation
		var/datum/signal/signal = new
		signal.transmission_method = 1 // radio transmission
		signal.source = src
		signal.frequency = frequency
		signal.data["code"] = code

		// Apply any necessary commands
		switch(href_list["radio-op"])
			if("togglepower")
				signal.data["command"] = "toggle-power"

			if("minuselec")
				signal.data["command"] = "sub-elec"
			if("pluselec")
				signal.data["command"] = "add-elec"

			if("minusmag")
				signal.data["command"] = "sub-mag"
			if("plusmag")
				signal.data["command"] = "add-mag"


		// Broadcast the signal

		radio_connection.post_signal(src, signal, filter = RADIO_MAGNETS)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj, updateUsrDialog)), 0.1 SECONDS)	// pretty sure this increases responsiveness

	if(href_list["operation"])
		switch(href_list["operation"])
			if("plusspeed")
				speed++
				if(speed > 10)
					speed = 10
			if("minusspeed")
				speed --
				if(speed <= 0)
					speed = 1
			if("setpath")
				var/newpath = sanitize(copytext_char(input(usr, "Please define a new path!",,path) as text|null,1,MAX_MESSAGE_LEN))
				if(newpath && newpath != "")
					moving = FALSE // stop moving
					path = newpath
					pathpos = 1 // reset position
					filter_path() // renders rpath

			if("togglemoving")
				moving = !moving
				if(moving)
					INVOKE_ASYNC(src, PROC_REF(MagnetMove))

	updateUsrDialog()


/obj/machinery/magnetic_controller/proc/MagnetMove()
	if(looping)
		return

	while(moving && length(rpath) >= 1)

		if(stat & (BROKEN|NOPOWER))
			break

		looping = TRUE

		// Prepare the radio signal
		var/datum/signal/signal = new
		signal.transmission_method = 1 // radio transmission
		signal.source = src
		signal.frequency = frequency
		signal.data["code"] = code

		if(pathpos > length(rpath)) // if the position is greater than the length, we just loop through the list!
			pathpos = 1

		var/nextmove = uppertext(rpath[pathpos]) // makes it un-case-sensitive

		if(!(nextmove in list("N","S","E","W","C","R")))
			// N, S, E, W are directional
			// C is center
			// R is random (in magnetic field's bounds)
			qdel(signal)
			break // break the loop if the character located is invalid

		signal.data["command"] = nextmove

		pathpos++ // increase iterator

		// Broadcast the signal
		INVOKE_ASYNC(radio_connection, TYPE_PROC_REF(/datum/radio_frequency, post_signal), src, signal, RADIO_MAGNETS)

		if(speed == 10)
			sleep(1)
		else
			sleep(12-speed)

	looping = FALSE


/obj/machinery/magnetic_controller/proc/filter_path()
	// Generates the rpath variable using the path string, think of this as "string2list"
	// Doesn't use params2list() because of the akward way it stacks entities
	rpath = list() //  clear rpath
	var/maximum_character = min(MAX_PATH_LENGTH, length(path) ) // chooses the maximum length of the iterator. 50 max length

	for(var/i=1, i<=maximum_character, i++) // iterates through all characters in path

		var/nextchar = copytext(path, i, i+1) // find next character

		if(!(nextchar in list(";", "&", "*", " "))) // if char is a separator, ignore
			rpath += copytext(path, i, i+1) // else, add to list

		// there doesn't HAVE to be separators but it makes paths syntatically visible


#undef MIN_CONTROLLER_SPEED
#undef MAX_CONTROLLER_SPEED
#undef MIN_ELECTRICITY_LEVEL
#undef MAX_ELECTRICITY_LEVEL
#undef MIN_MAGNETIC_FIELD
#undef MAX_MAGNETIC_FIELD
#undef MAX_PATH_LENGTH

