#define BOMB_OVERLAY_ID "bomb_overlay_id"

/obj/item/grenade/plastic
	name = "plastic explosive"
	desc = "Used to put holes in specific areas without too much extra hole."
	icon_state = "plastic-explosive0"
	item_state = "plastic-explosive"
	item_flags = NOBLUDGEON
	det_time = 10 SECONDS
	display_timer = 0
	origin_tech = "syndicate=1"
	toolspeed = 1
	var/atom/target
	var/mutable_appearance/image_overlay
	var/obj/item/assembly_holder/nadeassembly
	var/assemblyattacher
	var/notify_admins = TRUE


/obj/item/grenade/plastic/Initialize(mapload)
	. = ..()
	image_overlay = mutable_appearance('icons/obj/weapons/grenade.dmi', "[item_state]2")
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/item/grenade/plastic/Destroy()
	QDEL_NULL(nadeassembly)
	target = null
	return ..()


/obj/item/grenade/plastic/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/assembly_holder))
		add_fingerprint(user)
		if(nadeassembly)
			to_chat(user, span_warning("There is [nadeassembly] already installed!"))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/assembly_holder/assembly_holder = I
		if(!assembly_holder.secured)
			to_chat(user, span_warning("The [assembly_holder.name] must be secured first!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(assembly_holder, src))
			return ..()
		nadeassembly = assembly_holder
		assembly_holder.master = src
		assemblyattacher = user.ckey
		to_chat(user, span_notice("You add [assembly_holder] to the [name]."))
		playsound(src, 'sound/weapons/tap.ogg', 20, TRUE)
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/grenade/plastic/wirecutter_act(mob/living/user, obj/item/I)
	if(!nadeassembly)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return .
	nadeassembly.forceMove_turf()
	nadeassembly.master = null
	nadeassembly = null
	update_icon(UPDATE_ICON_STATE)


//assembly stuff
/obj/item/grenade/plastic/receive_signal()
	prime()


/obj/item/grenade/plastic/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(nadeassembly)
		nadeassembly.assembly_crossed(arrived, old_loc)


/obj/item/grenade/plastic/on_found(mob/finder)
	if(nadeassembly)
		nadeassembly.on_found(finder)


/obj/item/grenade/plastic/attack_self(mob/user)
	if(nadeassembly)
		nadeassembly.attack_self(user)
		return
	var/newtime = input(usr, "Please set the timer (in seconds).", "Timer", det_time/10) as null|num
	if(isnull(newtime) || !user.is_in_active_hand(src))
		return
	newtime = newtime SECONDS
	var/init_timer = initial(det_time)
	if(newtime < init_timer || newtime > 10 MINUTES)
		to_chat(user, span_warning("Timer cannot be lower than [init_timer / 10] seconds or higher than 10 minutes."))
		return
	det_time = newtime
	to_chat(user, "Timer set for [newtime / 10] seconds.")


/obj/item/grenade/plastic/afterattack(atom/movable/AM, mob/user, flag, params)
	if(!flag)
		return
	if(iscarbon(AM))
		to_chat(user, "<span class='warning'>You can't get the [src] to stick to [AM]!</span>")
		return
	if(isobserver(AM))
		to_chat(user, "<span class='warning'>Your hand just phases through [AM]!</span>")
		return
	to_chat(user, "<span class='notice'>You start planting [src].[isnull(nadeassembly) ? " The timer is set to [det_time/10]..." : ""]</span>")

	if(!do_after(user, 5 SECONDS * toolspeed, AM, category = DA_CAT_TOOL))
		return

	if(!user.drop_item_ground(src))
		return

	target = AM
	do_pickup_animation(AM)
	loc = null
	if(notify_admins)
		message_admins("[ADMIN_LOOKUPFLW(user)] planted [src.name] on [target.name] at [ADMIN_COORDJMP(target)] with [det_time/10] second fuse")
		add_game_logs("planted [name] on [target.name] at [COORD(target)] with [det_time/10] second fuse", user)

	target.add_persistent_overlay(image_overlay, BOMB_OVERLAY_ID)
	if(!nadeassembly)
		to_chat(user, "<span class='notice'>You plant the bomb. Timer counting down from [det_time/10].</span>")
		addtimer(CALLBACK(src, PROC_REF(prime)), det_time)


/obj/item/grenade/plastic/suicide_act(mob/user)
	message_admins("[ADMIN_LOOKUPFLW(user)] suicided with [src.name] at [ADMIN_COORDJMP(user)]")
	add_game_logs("suicided with [name] at [COORD(user)]", user)
	user.visible_message("<span class='suicide'>[user] activates the [name] and holds it above [user.p_their()] head! It looks like [user.p_theyre()] going out with a bang!</span>")
	var/message_say = "FOR NO RAISIN!"
	if(user.mind)
		if(user.mind.special_role)
			var/role = lowertext(user.mind.special_role)
			if(role == ROLE_TRAITOR || role == "syndicate" || role == "syndicate commando")
				message_say = "FOR THE SYNDICATE!"
			else if(role == ROLE_CHANGELING)
				message_say = "FOR THE HIVE!"
			else if(role == ROLE_CULTIST)
				message_say = "FOR NARSIE!"
			else if(role == ROLE_NINJA)
				message_say = "FOR THE SPIDER CLAN!"
			else if(role == ROLE_WIZARD)
				message_say = "FOR THE FEDERATION!"
			else if(role == ROLE_REV || role == "head revolutionary")
				message_say = "FOR THE REVOLUTION!"
			else if(role == "death commando" || role == ROLE_ERT)
				message_say = "FOR NANOTRASEN!"
			else if(role == ROLE_DEVIL)
				message_say = "FOR INFERNO!"
	user.say(message_say)
	target = user
	sleep(10)
	prime()
	user.gib()
	return OBLITERATION


/obj/item/grenade/plastic/update_icon_state()
	if(nadeassembly)
		icon_state = "[item_state]1"
	else
		icon_state = "[item_state]0"


//////////////////////////
///// The Explosives /////
//////////////////////////

/obj/item/grenade/plastic/c4
	name = "C4"
	desc = "Used to put holes in specific areas without too much extra hole. A saboteurs favourite."
	var/devastation_range = 0
	var/heavy_impact_range = 0
	var/light_impact_range = 3
	var/flash_range = 0

/obj/item/grenade/plastic/c4/prime()
	var/turf/location
	if(target)
		if(!QDELETED(target))
			if(istype(target, /turf/))
				location = get_turf(target)	// Set the explosion location to turf if planted directly on a wall or floor
			else
				location = get_atom_on_turf(target)	// Otherwise, make sure we're blowing up what's on top of the turf
	else
		location = get_atom_on_turf(src)
	if(location)
		explosion(location, devastation_range = devastation_range, heavy_impact_range = heavy_impact_range, light_impact_range = light_impact_range, flash_range = flash_range, cause = src)
		location.ex_act(2, target)
	if(istype(target, /mob))
		var/mob/M = target
		M.gib()
	qdel(src)

// X4 is an upgraded directional variant of c4 which is relatively safe to be standing next to. And much less safe to be standing on the other side of.
// C4 is intended to be used for infiltration, and destroying tech. X4 is intended to be used for heavy breaching and tight spaces.
// Intended to replace C4 for nukeops, and to be a randomdrop in surplus/random traitor purchases.

/obj/item/grenade/plastic/x4
	name = "X4"
	desc = "A specialized shaped high explosive breaching charge. Designed to be safer for the user, and less so, for the wall."
	var/aim_dir = NORTH
	icon_state = "plasticx40"
	item_state = "plasticx4"

/obj/item/grenade/plastic/x4/prime()
	var/turf/location
	if(target)
		if(!QDELETED(target))
			if(istype(target, /turf/))
				location = get_turf(target)
			else
				location = get_atom_on_turf(target)
	else
		location = get_atom_on_turf(src)
	if(location)
		if(target && target.density)
			var/turf/T = get_step(location, aim_dir)
			explosion(get_step(T, aim_dir),0,0,3, cause = "Dir. X4")
			explosion(T,0,2,0, cause = src)
			location.ex_act(2, target)
		else
			explosion(location, 0, 2, 3, cause = src)
			location.ex_act(2, target)
	if(istype(target, /mob))
		var/mob/M = target
		M.gib()
	qdel(src)

/obj/item/grenade/plastic/x4/afterattack(atom/movable/AM, mob/user, flag, params)
	aim_dir = get_dir(user,AM)
	..()

// Shaped charge
// Same blasting power as C4, but with the same idea as the X4 -- Everyone on one side of the wall is safe.

/obj/item/grenade/plastic/c4_shaped
	name = "C4 (shaped)"
	desc = "A brick of C4 shaped to allow more precise breaching."
	var/aim_dir = NORTH

/obj/item/grenade/plastic/c4_shaped/prime()
	var/turf/location
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
	else
		location = get_turf(src)
	if(location)
		if(target && target.density)
			var/turf/T = get_step(location, aim_dir)
			explosion(get_step(T, aim_dir),0,0,3, cause = src)
			location.ex_act(2, target)
		else
			explosion(location, 0, 0, 3, cause = src)
			location.ex_act(2, target)
	if(istype(target, /mob))
		var/mob/M = target
		M.gib()
	qdel(src)

/obj/item/grenade/plastic/c4_shaped/afterattack(atom/movable/AM, mob/user, flag, params)
	aim_dir = get_dir(user,AM)
	..()

/obj/item/grenade/plastic/c4_shaped/flash
	name = "C4 (flash)"
	desc = "A C4 charge with an altered chemical composition, designed to blind and deafen the occupants of a room before breaching."

/obj/item/grenade/plastic/c4_shaped/flash/prime()
	var/turf/T
	if(target && target.density)
		T = get_step(get_turf(target), aim_dir)
	else if(target)
		T = get_turf(target)
	else
		T = get_turf(src)

	var/obj/item/grenade/flashbang/CB = new/obj/item/grenade/flashbang(T)
	CB.prime()

	..()

/obj/item/grenade/plastic/x4/thermite
	name = "T4"
	desc = "A wall breaching charge, containing fuel, metal oxide and metal powder mixed in just the right way. One hell of a combination. Effective against walls, ineffective against airlocks..."
	det_time = 2 SECONDS
	icon_state = "t4breach0"
	item_state = "t4breach"

/obj/item/grenade/plastic/x4/thermite/prime()
	var/turf/location
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
	else
		location = get_turf(src)
	if(location)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(8,0, location, aim_dir)
		if(target && target.density)
			var/turf/T = get_step(location, aim_dir)
			for(var/turf/simulated/wall/W in range(1, location))
				W.thermitemelt(time = 3 SECONDS)
			addtimer(CALLBACK(GLOBAL_PROC, /proc/explosion, T, 0, 0, 2), 3)
			addtimer(CALLBACK(smoke, TYPE_PROC_REF(/datum/effect_system/smoke_spread, start)), 3)
		else
			var/turf/T = get_step(location, aim_dir)
			addtimer(CALLBACK(GLOBAL_PROC, /proc/explosion, T, 0, 0, 2), 3)
			addtimer(CALLBACK(smoke, TYPE_PROC_REF(/datum/effect_system/smoke_spread, start)), 3)

	if(isliving(target))
		var/mob/living/M = target
		M.adjust_fire_stacks(2)
		M.IgniteMob()
	qdel(src)


#undef BOMB_OVERLAY_ID

