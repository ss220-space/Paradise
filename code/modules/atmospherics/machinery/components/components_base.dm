/*
So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
On top of that, now people can add component-speciic procs/vars if they want!
*/

/obj/machinery/atmospherics/components
	/// Whether its currently welded
	var/welded = 0
	var/showpipe = 0

	var/list/datum/pipeline/parents = list()
	var/list/datum/gas_mixture/airs = list()


/obj/machinery/atmospherics/components/New() //it's workiiiing
	parents.len = device_type
	airs.len = device_type
	. = ..()
	for(DEVICE_TYPE_LOOP)
		var/datum/gas_mixture/A = new
		A.volume = 200
		AIR_I = A


/*
Pipenet stuff; housekeeping
*/
/obj/machinery/atmospherics/components/nullifyNode(I)
	..()
	if(NODE_I)
		nullifyPipenet(PARENT_I)
		qdel(AIR_I)
		AIR_I = null

/obj/machinery/atmospherics/components/atmos_init() //doesn't work for another reason
	. = ..()

/obj/machinery/atmospherics/components/on_construction() //doesn't work
	..()
	update_parents()

/obj/machinery/atmospherics/components/build_network(remove_deferral) //doesn't work
	for(DEVICE_TYPE_LOOP)
		if(!PARENT_I)
			PARENT_I = new /datum/pipeline()
			var/datum/pipeline/P = PARENT_I
			P.build_pipeline(src)

/obj/machinery/atmospherics/components/proc/nullifyPipenet(datum/pipeline/reference)
	var/I = parents.Find(reference)
	reference.other_airs -= AIR_I
	reference.other_atmosmch -= src
	PARENT_I = null

/obj/machinery/atmospherics/components/returnPipenetAir(datum/pipeline/reference) //untestable; should work
	var/I = parents.Find(reference)
	return AIR_I

/obj/machinery/atmospherics/components/pipeline_expansion(datum/pipeline/reference)
	if(reference)
		var/I = parents.Find(reference)
		return list(NODE_I)
	else
		return ..()

/obj/machinery/atmospherics/components/setPipenet(datum/pipeline/reference, obj/machinery/atmospherics/A)
	var/I = nodes.Find(A)
	PARENT_I = reference

/obj/machinery/atmospherics/components/returnPipenet(obj/machinery/atmospherics/A = NODE1)
	var/I = nodes.Find(A)
	return PARENT_I

/obj/machinery/atmospherics/components/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	var/I = parents.Find(Old)
	PARENT_I = New

/obj/machinery/atmospherics/components/return_pipenets()
	. = list()
	for(DEVICE_TYPE_LOOP)
		. += returnPipenet(NODE_I)

/obj/machinery/atmospherics/components/unsafe_pressure_release(mob/user, pressures) //untestable; I'll fix this last
	..()

	var/turf/T = get_turf(src)
	if(T)
		//Remove the gas from airs and assume it
		var/datum/gas_mixture/environment = T.return_air()
		var/lost = null
		var/times_lost = 0
		for(var/A = 1; A <= device_type; A++)
			var/datum/gas_mixture/air = airs[A]
			lost += pressures*environment.volume/(air.temperature * R_IDEAL_GAS_EQUATION)
			times_lost++
		var/shared_loss = lost/times_lost

		var/datum/gas_mixture/to_release
		for(var/A = 1; A <= device_type; A++)
			var/datum/gas_mixture/air = airs[A]
			if(!to_release)
				to_release = air.remove(shared_loss)
				continue
			to_release.merge(air.remove(shared_loss))
		T.assume_air(to_release)
		air_update_turf(1)

/obj/machinery/atmospherics/components/proc/safe_input(title, text, default_set)
	var/new_value = tgui_input_number(usr, text, title, default_set)
	if(usr.default_can_use_topic(src))
		return new_value
	return default_set


/*
Helpers
*/
/obj/machinery/atmospherics/components/proc/update_parents()
	for(DEVICE_TYPE_LOOP)
		var/datum/pipeline/parent = PARENT_I
		parent.update = 1


/obj/machinery/atmospherics/components/proc/set_welded(new_value)
	if(welded == new_value)
		return

	. = welded
	welded = new_value
	update_icon()
	update_pipe_image()
