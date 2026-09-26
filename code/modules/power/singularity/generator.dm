/obj/machinery/the_singularitygen
	name = "gravitational singularity generator"
	desc = "An odd device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "TheSingGen"
	density = TRUE
	use_power = NO_POWER_USE
	resistance_flags = FIRE_PROOF
	/// Current energy level of the generator; when it reaches, gen is spawned.
	var/energy = 0
	/// Type path of the object to create.
	var/creation_type = /obj/singularity

/obj/machinery/the_singularitygen/process()
	var/turf/current_turf = get_turf(src)
	if(energy < 200)
		return

	message_admins("A [creation_type] has been created at [ADMIN_COORDJMP(src)]")
	investigate_log("A [creation_type] has been created at [AREACOORD(src)] last touched by [fingerprintslast]", INVESTIGATE_ENGINE)

	var/obj/created_object = create_object(current_turf)
	transfer_fingerprints_to(created_object)
	qdel(src)

/obj/machinery/the_singularitygen/proc/create_object(turf/target_turf)
	return new creation_type(target_turf, 50)

/obj/machinery/the_singularitygen/wrench_act(mob/living/user, obj/item/wrench)
	. = TRUE
	if(!wrench.use_tool(src, user, volume = wrench.tool_volume))
		return
	set_anchored(!anchored)
	if(anchored)
		WRENCH_ANCHOR_MESSAGE
	else
		WRENCH_UNANCHOR_MESSAGE

