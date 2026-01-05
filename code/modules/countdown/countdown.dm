/obj/effect/countdown
	name = "countdown"
	desc = "We're leaving together\n\
		But still it's farewell\n\
		And maybe we'll come back\n\
		To earth, who can tell?"

	invisibility = INVISIBILITY_OBSERVER
	layer = MASSIVE_OBJ_LAYER
	color = "#ff0000" // text color
	var/text_size = 3 // larger values clip when the displayed text is larger than 2 digits.
	var/started = FALSE
	var/displayed_text
	var/atom/attached_to

/obj/effect/countdown/Initialize(mapload)
	. = ..()
	attach(loc)

/obj/effect/countdown/examine(mob/user)
	. = ..()
	. += span_notice("This countdown is displaying: [displayed_text].")

/obj/effect/countdown/proc/attach(atom/A)
	attached_to = A
	var/turf/loc_turf = get_turf(A)
	if(!loc_turf)
		RegisterSignal(attached_to, COMSIG_MOVABLE_MOVED, PROC_REF(retry_attach), TRUE)
	else
		forceMove(loc_turf)

/obj/effect/countdown/proc/retry_attach()
	SIGNAL_HANDLER

	var/turf/loc_turf = get_turf(attached_to)
	if(!loc_turf)
		return
	forceMove(loc_turf)
	UnregisterSignal(attached_to, COMSIG_MOVABLE_MOVED)

/obj/effect/countdown/proc/start()
	if(!started)
		START_PROCESSING(SSfastprocess, src)
		started = TRUE

/obj/effect/countdown/proc/stop()
	if(started)
		maptext = null
		STOP_PROCESSING(SSfastprocess, src)
		started = FALSE

/obj/effect/countdown/proc/get_value()
	// Get the value from our atom
	return

/obj/effect/countdown/process()
	if(!attached_to || QDELETED(attached_to))
		qdel(src)
	forceMove(get_turf(attached_to))
	var/new_val = get_value()
	if(new_val == displayed_text)
		return
	displayed_text = new_val

	if(displayed_text)
		maptext = MAPTEXT("[displayed_text]")
	else
		maptext = null

/obj/effect/countdown/Destroy()
	attached_to = null
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/countdown/ex_act(severity, target) //immune to explosions
	return

/obj/effect/countdown/singularity_pull()
	return

/obj/effect/countdown/singularity_act()
	return

/obj/effect/countdown/syndicatebomb
	name = "syndicate bomb countdown"

/obj/effect/countdown/syndicatebomb/get_value()
	var/obj/machinery/syndicatebomb/S = attached_to
	if(!istype(S))
		return
	else if(S.active)
		return S.seconds_remaining()

/obj/effect/countdown/clonepod
	name = "cloning pod countdown"

/obj/effect/countdown/clonepod/get_value()
	var/obj/machinery/clonepod/C = attached_to
	if(!istype(C))
		return
	else if(C.occupant)
		var/completion = round(C.get_completion())
		return completion

/obj/effect/countdown/anomaly
	name = "anomaly countdown"

/obj/effect/countdown/anomaly/get_value()
	var/obj/effect/old_anomaly/A = attached_to
	if(!istype(A))
		return
	var/time_left = max(0, (A.death_time - world.time) / 10)
	return round(time_left)

/obj/effect/countdown/clockworkgate
	name = "gateway countdown"
	color = "#BE8700"

/obj/effect/countdown/clockworkgate/get_value()
	var/obj/structure/clockwork/functional/celestial_gateway/G = attached_to
	if(!istype(G))
		return
	else if(G.obj_integrity && !G.purpose_fulfilled)
		return "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'>[GATEWAY_RATVAR_ARRIVAL - G.seconds_until_activation]</div>"

/obj/effect/countdown/hourglass
	name = "hourglass countdown"

/obj/effect/countdown/hourglass/get_value()
	var/obj/item/hourglass/H = attached_to
	if(!istype(H))
		return
	else
		var/time_left = max(0, (H.finish_time - world.time) / 10)
		return round(time_left)

// MARK: Supermatter
/obj/effect/countdown/supermatter
	name = "supermatter damage"
	color = "#00ff80"
	pixel_y = 8

/obj/effect/countdown/supermatter/attach(atom/attached_atom)
	. = ..()
	if(istype(attached_atom, /obj/machinery/atmospherics/supermatter_crystal/shard))
		pixel_y = -12

/obj/effect/countdown/supermatter/get_value()
	var/obj/machinery/atmospherics/supermatter_crystal/supermatter = attached_to
	if(!istype(supermatter))
		return
	return "<div align='center' valign='bottom' style='position:relative; top:0px; left:0px'>[round(supermatter.get_integrity_percent())]%</div>"
