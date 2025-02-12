GLOBAL_DATUM_INIT(the_gateway, /obj/machinery/gateway/centerstation, null)
/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/active = FALSE


/obj/machinery/gateway/Initialize()
	. = ..()
	update_icon(UPDATE_ICON_STATE)
	update_density_from_dir()


/obj/machinery/gateway/proc/update_density_from_dir()
	if(dir == SOUTH)
		set_density(FALSE)


/obj/machinery/gateway/update_icon_state()
	icon_state = active ? "on" : "off"


//this is da important part wot makes things go
/obj/machinery/gateway/centerstation
	icon_state = "offcenter"
	use_power = IDLE_POWER_USE

	//warping vars
	var/list/linked = list()
	var/ready = FALSE				//have we got all the parts for a gateway?
	var/wait = 0				//this just grabs world.time at world start
	var/obj/machinery/gateway/centeraway/awaygate = null


/obj/machinery/gateway/centerstation/New()
	..()
	if(!GLOB.the_gateway)
		GLOB.the_gateway = src


/obj/machinery/gateway/centerstation/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)
	wait = world.time + CONFIG_GET(number/gateway_delay)
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/gateway/centerstation/Destroy()
	if(GLOB.the_gateway == src)
		GLOB.the_gateway = null
	return ..()


/obj/machinery/gateway/centerstation/LateInitialize()
	awaygate = locate(/obj/machinery/gateway/centeraway) in GLOB.machines


/obj/machinery/gateway/centerstation/update_density_from_dir()
	return


/obj/machinery/gateway/centerstation/update_icon_state()
	icon_state = active ? "oncenter" : "offcenter"


/obj/machinery/gateway/centerstation/process()
	if(stat & (NOPOWER))
		if(active)
			toggleoff()
		return

	if(active)
		use_power(5000)


/obj/machinery/gateway/centerstation/proc/detect()
	linked = list()	//clear the list
	var/turf/T = loc

	for(var/i in GLOB.alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = FALSE
		toggleoff()
		break

	if(length(linked) == 8)
		ready = TRUE


/obj/machinery/gateway/centerstation/proc/toggleon(mob/user)
	if(!ready)
		return
	if(length(linked) != 8)
		return
	if(!powered())
		return
	if(!awaygate)
		awaygate = locate(/obj/machinery/gateway/centeraway) in GLOB.machines
		if(!awaygate)
			to_chat(user, "<span class='notice'>Error: No destination found.</span>")
			return
	if(world.time < wait)
		to_chat(user, "<span class='notice'>Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes.</span>")
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = TRUE
		G.update_icon()
	active = TRUE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gateway/centerstation/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = FALSE
		G.update_icon(UPDATE_ICON_STATE)
	active = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gateway/centerstation/attack_hand(mob/user)
	add_fingerprint(user)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()


//okay, here's the good teleporting stuff
/obj/machinery/gateway/centerstation/Bumped(atom/movable/moving_atom)
	. = ..()
	if(!ready || !active || !awaygate)
		return
	if(awaygate.calibrated)
		moving_atom.forceMove(get_step(awaygate.loc, SOUTH))
		moving_atom.dir = SOUTH
		return

	var/obj/effect/landmark/dest = pick(GLOB.awaydestinations)
	if(dest)
		moving_atom.forceMove(dest.loc)
		moving_atom.dir = SOUTH
		use_power(5000)


/obj/machinery/gateway/centerstation/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	add_fingerprint(user)
	to_chat(user, span_warning("The gate is already calibrated, there is no work for you to do here."))


/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	icon_state = "offcenter"
	use_power = NO_POWER_USE
	var/calibrating_on_activating = FALSE
	var/calibrated = TRUE
	var/list/linked = list()	//a list of the connected gateway chunks
	var/ready = FALSE
	var/obj/machinery/gateway/centeraway/stationgate = null


/obj/machinery/gateway/centeraway/Initialize()
	. = ..()
	update_icon()
	stationgate = locate(/obj/machinery/gateway/centerstation) in GLOB.machines


/obj/machinery/gateway/centeraway/update_density_from_dir()
	return


/obj/machinery/gateway/centeraway/update_icon_state()
	icon_state = active ? "oncenter" : "offcenter"


/obj/machinery/gateway/centeraway/proc/detect()
	linked = list()	//clear the list
	var/turf/T = loc

	for(var/i in GLOB.alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = FALSE
		toggleoff()
		break

	if(length(linked) == 8)
		ready = TRUE


/obj/machinery/gateway/centeraway/proc/toggleon(mob/user)
	if(!ready)
		return
	if(length(linked) != 8)
		return
	if(!stationgate)
		stationgate = locate(/obj/machinery/gateway/centerstation) in GLOB.machines
		if(!stationgate)
			to_chat(user, "<span class='notice'>Error: No destination found.</span>")
			return
	if(!calibrated && calibrating_on_activating)
		calibrated = TRUE

	for(var/obj/machinery/gateway/G in linked)
		G.active = TRUE
		G.update_icon(UPDATE_ICON_STATE)
	active = TRUE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gateway/centeraway/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = FALSE
		G.update_icon(UPDATE_ICON_STATE)
	active = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/gateway/centeraway/attack_hand(mob/user)
	add_fingerprint(user)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()


/obj/machinery/gateway/centeraway/Bumped(atom/movable/moving_atom)
	. = ..()
	if(!ready || !active || QDELETED(stationgate))
		return
	if(isliving(moving_atom))
		if(exilecheck(moving_atom))
			return
	else
		for(var/mob/living/L in moving_atom.contents)
			if(exilecheck(L))
				atom_say("Rejecting [moving_atom]: Exile implant detected in contained lifeform.")
				return
	if(moving_atom.has_buckled_mobs())
		for(var/mob/living/L in moving_atom.buckled_mobs)
			if(exilecheck(L))
				atom_say("Rejecting [moving_atom]: Exile implant detected in close proximity lifeform.")
				return
	var/turf/destination = get_step(stationgate.loc, SOUTH)
	moving_atom.forceMove(destination)
	moving_atom.setDir(SOUTH)
	if(ismob(moving_atom))
		var/mob/M = moving_atom
		if(M.client)
			M.client.move_delay = max(world.time + 5, M.client.move_delay)


/obj/machinery/gateway/centeraway/proc/exilecheck(mob/living/carbon/user)
	for(var/obj/item/implant/exile/imp in user)//Checking that there is an exile implant in the contents
		if(imp.imp_in == user)//Checking that it's actually implanted vs just in their pocket
			to_chat(user, "<span class='notice'>The station gate has detected your exile implant and is blocking your entry.</span>")
			return TRUE
	return FALSE


/obj/machinery/gateway/centeraway/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(calibrated)
		to_chat(user, span_warning("The gate is already calibrated, there is no work for you to do here."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	to_chat(user, "[span_boldnotice("Recalibration successful! ")][span_notice("This gate's systems have been fine tuned. Travel to this gate will now be on target.")]")
	calibrated = TRUE

