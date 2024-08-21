/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen
	name = "Gravitational Singularity Generator"
	desc = "An odd device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	resistance_flags = FIRE_PROOF
	var/energy = 0
	var/creation_type = /obj/singularity

/obj/machinery/the_singularitygen/process()
	var/turf/T = get_turf(src)
	if(src.energy >= 200)
		message_admins("A [creation_type] has been created at [ADMIN_COORDJMP(src)]")
		investigate_log("A [creation_type] has been created at [AREACOORD(src)] last touched by [fingerprintslast]", INVESTIGATE_ENGINE)

		var/obj/singularity/S = new creation_type(T, 50)
		transfer_fingerprints_to(S)
		if(src) qdel(src)


/obj/machinery/the_singularitygen/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	if(anchored)
		user.visible_message(
			span_notice("[user] has secured [src] to the floor."),
			span_notice("You have secured [src] to the floor."),
			span_italics("You hear a ratchet"),
		)
	else
		user.visible_message(
			span_notice("[user] has unsecured [src] from floor."),
			span_notice("You have unsecured [src] from floor."),
			span_italics("You hear a ratchet"),
		)

