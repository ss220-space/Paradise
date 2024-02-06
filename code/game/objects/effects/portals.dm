#define EFFECT_COOLDOWN (0.5 SECONDS)
#define UNSTABLE_TIME_DELAY (2 SECONDS)

/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	base_icon_state = "portal"
	anchored = TRUE

	var/obj/item/target
	/// The UID and `name` of the object that created this portal. For example, a wormhole jaunter.
	var/list/creation_obj_data
	/// The ckey of the mob which was responsible for the creation of the portal. For example, the mob who used a wormhole jaunter.
	var/creation_mob_ckey

	var/failchance = 5
	var/fail_icon = "portal1"
	var/failed_teleport = TRUE

	/// How close to the portal you will teleport: 0 = on the portal, 1 = adjacent. Basically `in range(precision, portal)`, random turf will be choosen.
	var/precision = 0
	var/can_multitool_to_remove = FALSE
	var/can_mecha_pass = FALSE
	var/ignore_tele_proof_area_setting = FALSE
	var/one_use = FALSE // Does this portal go away after one teleport?
	/// The time after which the effects should play again. Too many effects can lag the server
	var/effect_cooldown = 0
	///Whether or not portal use will cause sparks
	var/create_sparks = TRUE


/obj/effect/portal/New(loc, turf/target = null, obj/creation_object = null, lifespan = 30 SECONDS, mob/creation_mob = null, create_sparks = TRUE)
	..()

	GLOB.portals += src
	src.target = target
	src.create_sparks = create_sparks

	if(creation_object)
		creation_obj_data = list(creation_object.UID(), "[creation_object.name]") // Store the name incase the object is deleted.
	else
		creation_obj_data = list(null, null)

	creation_mob_ckey = creation_mob?.ckey

	set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon(UPDATE_OVERLAYS)

	for(var/obj/effect/portal/other_portal in loc)
		if(other_portal != src)
			QDEL_IN(other_portal, 0)
			stack_trace("More than one portal has been opened in [atom_loc_line(loc)]") 	// YEAH, FIX IT SOMEONE!

	if(lifespan > 0)
		QDEL_IN(src, lifespan)


/obj/effect/portal/Destroy()
	GLOB.portals -= src

	var/obj/parent = locateUID(creation_obj_data[1])
	if(!QDELETED(parent))
		parent.portal_destroyed(src)

	target = null

	if(create_sparks)
		do_sparks(5, 0, loc)

	return ..()


/obj/effect/portal/update_icon_state()
	if(fail_icon && failed_teleport)
		icon_state = fail_icon
	else
		icon_state = base_icon_state


/obj/effect/portal/update_overlays()
	. = ..()
	underlays.Cut()
	underlays += emissive_appearance(icon, "[base_icon_state]_lightmask")


/obj/effect/portal/singularity_pull()
	return


/obj/effect/portal/singularity_act()
	return


/obj/effect/portal/Crossed(atom/movable/AM, oldloc)
	if(isobserver(AM))
		return ..()

	if(target && (get_turf(oldloc) == get_turf(target)))
		return ..()

	if(istype(AM, /obj/effect/portal))
		qdel(AM)
		qdel(src)
		log_debug("Portal [src] crossed by another portal [AM]")
		return

	if(!teleport(AM))
		return ..()


/obj/effect/portal/attack_tk(mob/user)
	return


/obj/effect/portal/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(get_turf(user) == get_turf(src))
		teleport(user)
	if(Adjacent(user))
		user.forceMove(get_turf(src))


/obj/effect/portal/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(can_multitool_to_remove)
		qdel(src)
	else
		user.forceMove(get_turf(src))


/obj/effect/portal/proc/can_teleport(atom/movable/M)
	. = TRUE

	if(!istype(M))
		. = FALSE

	if(!M.simulated || iseffect(M))
		. = FALSE

	if(!can_mecha_pass && M.anchored && ismecha(M))
		. = FALSE


/obj/effect/portal/proc/teleport(atom/movable/M)
	if(!can_teleport(M))
		return FALSE

	if(!target)
		qdel(src)
		return FALSE

	if(ismegafauna(M))
		var/creator_string = ""
		var/obj_name = creation_obj_data[2]
		if(creation_mob_ckey)
			creator_string = " created by [key_name_admin(GLOB.directory[creation_mob_ckey])][obj_name ? " using \a [obj_name]" : ""]"
		else if(obj_name)
			creator_string = " created by \a [obj_name]"
		message_admins("[M] has used a portal at [ADMIN_VERBOSEJMP(src)][creator_string].")
		investigate_log("[M] has used a portal, [creator_string].", INVESTIGATE_TELEPORTATION)

	if(prob(failchance))
		icon_state = fail_icon
		update_icon(UPDATE_ICON_STATE)
		var/list/target_z = levels_by_trait(SPAWN_RUINS)
		target_z -= M.z
		if(!attempt_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), pick(target_z)), 0, FALSE)) // Try to send them to deep space.
			return FALSE
	else
		if(!attempt_teleport(M, target, precision)) // Try to send them to a turf adjacent to target.
			return FALSE
	if(one_use)
		qdel(src)

	return TRUE


/obj/effect/portal/proc/attempt_teleport(atom/movable/victim, turf/destination, variance = 0, force_teleport = TRUE)
	var/use_effects = world.time >= effect_cooldown
	var/effect = null // Will result in the default effect being used
	if(!use_effects)
		effect = NONE // No effect

	if(!do_teleport(victim, destination, variance, force_teleport, effect, effect, bypass_area_flag = ignore_tele_proof_area_setting))
		invalid_teleport()
		return FALSE
	effect_cooldown = world.time + EFFECT_COOLDOWN
	return TRUE


/obj/effect/portal/proc/invalid_teleport()
	visible_message(span_warning("[src] flickers and fails due to bluespace interference!"))
	if(create_sparks)
		do_sparks(5, 0, loc)
	qdel(src)


/obj/effect/portal/hand_tele
	/// After you touch the portal, it will be unstable with high bad teleport chance, this variable contains time when it will be fine again
	var/unstable_time = 0
	/// If this is TRUE, you will not be able to teleport with that portal
	var/inactive = FALSE


/obj/effect/portal/hand_tele/examine(mob/user, infix, suffix)
	. = ..()
	if(unstable_time > world.time)
		. += span_warning("[src] is shaking, it looks very unstable!")


/obj/effect/portal/hand_tele/can_teleport(atom/movable/M)
	if(inactive)
		return FALSE
	return ..()


/obj/effect/portal/hand_tele/teleport(atom/movable/M)
	. = ..()
	adjust_unstable()


/obj/effect/portal/hand_tele/proc/adjust_unstable()
	unstable_time = world.time + UNSTABLE_TIME_DELAY
	failed_teleport = TRUE
	update_icon(UPDATE_ICON_STATE)
	failchance = 33
	inactive = TRUE
	addtimer(CALLBACK(src, PROC_REF(check_unstable), unstable_time), UNSTABLE_TIME_DELAY)
	addtimer(VARSET_CALLBACK(src, inactive, FALSE), 0.5 SECONDS) // after unstable is setted you have 0.5 safe seconds to think if you want to use it


/obj/effect/portal/hand_tele/proc/check_unstable(current_unstable_time)
	if(current_unstable_time != unstable_time)
		return
	failchance = 0
	failed_teleport = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/effect/portal/redspace
	name = "redspace portal"
	desc = "A portal capable of bypassing bluespace interference."
	icon_state = "portal-syndicate"
	base_icon_state = "portal-syndicate"
	failchance = 0
	precision = 0
	ignore_tele_proof_area_setting = TRUE


/obj/effect/portal/wormhole_projector
	icon_state = "portal-projector0"
	base_icon_state = "portal-projector"
	failchance = 0
	can_multitool_to_remove = TRUE
	var/is_orange = FALSE


/obj/effect/portal/wormhole_projector/update_icon_state()
	icon_state = "[base_icon_state][is_orange]"


/obj/effect/portal/wormhole_projector/update_overlays()
	. = list()
	underlays.Cut()
	underlays += emissive_appearance(icon, "portal-syndicate_lightmask")


#undef EFFECT_COOLDOWN
#undef UNSTABLE_TIME_DELAY
