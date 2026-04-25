// MARK: Basic Crate
/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	climbable = TRUE
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	pass_flags_self = PASSSTRUCTURE | LETPASSTHROW
	x_shake_pixel_shift = 1
	y_shake_pixel_shift = 2
	dense_when_open = TRUE
	/// The reference of the manifest paper attached to the cargo crate.
	var/datum/weakref/manifest
	// A list of beacon names that the crate will announce the arrival of, when delivered.
	var/list/announce_beacons = list()
	/// Overlay for lightmask of our crate
	var/overlay_lightmask
	/// Can our crate make emissive light?
	var/can_be_emissive = FALSE
	/// Wired up and ready to be fitted with an electropack trap.
	var/wired_for_trap = FALSE

/obj/structure/closet/crate/Destroy()
	manifest = null
	return ..()

/obj/structure/closet/crate/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(iscloset(mover))
		return
	var/obj/structure/closet/crate/located_crate = locate(/obj/structure/closet/crate) in get_turf(mover)
	if(!located_crate) // you can walk on it like tables, if you're not in an open crate trying to move to a closed crate
		return
	if(opened) // if we're open, allow entering regardless of located crate openness
		return TRUE
	if(!located_crate.opened) // otherwise, if the located crate is closed, allow entering
		return TRUE

/obj/structure/closet/crate/update_icon_state()
	icon_state = "[initial(icon_state)][opened ? "_open" : ""]"

/obj/structure/closet/crate/update_overlays()
	// . = ..() is not needed here because of different overlay handling logic for crates
	underlays.Cut()
	. = list()
	if(manifest)
		. += "manifest"
	if(can_be_emissive)
		underlays += emissive_appearance(icon, overlay_lightmask, src)

/obj/structure/closet/crate/after_open(mob/living/user, force)
	. = ..()
	tear_manifest()

/obj/structure/closet/crate/before_open(mob/living/user, force)
	. = ..()
	if(!.)
		return FALSE

	if(climbable)
		structure_shaken()

	return do_trap_effect(user)

/obj/structure/closet/crate/proc/do_trap_effect(mob/living/user)
	if(!wired_for_trap || !locate(/obj/item/radio/electropack) in src)
		return TRUE
	if(!user.electrocute_act(17, src))
		return TRUE
	do_sparks(5, TRUE, src)
	return FALSE

/obj/structure/closet/crate/attackby(obj/item/used_item, mob/user, params)
	if(!opened && try_rig(used_item, user))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/structure/closet/crate/proc/try_rig(obj/item/used_item, mob/user)
	if(iscoil(used_item))
		var/obj/item/stack/cable_coil/coil = used_item

		if(wired_for_trap)
			to_chat(user, span_notice("[src] is already wired!"))
			return TRUE

		var/wires_amount = 15
		if(!coil.use(wires_amount))
			to_chat(user, span_warning("You need atleast [wires_amount] wires to rig [src]!"))
			return TRUE

		to_chat(user, span_notice("You rig [src]."))
		wired_for_trap = TRUE
		return TRUE

	if(istype(used_item, /obj/item/radio/electropack))
		if(!wired_for_trap)
			return TRUE

		if(!user.drop_transfer_item_to_loc(used_item, src))
			to_chat(user, span_warning("[used_item] seems to be stuck to your hand!"))
			return TRUE

		to_chat(user, span_notice("You attach [used_item] to [src]."))
		return TRUE

/obj/structure/closet/crate/wirecutter_act(mob/living/user, obj/item/item)
	if(opened)
		return
	if(!wired_for_trap)
		return
	if(item.use_tool(src, user))
		to_chat(user, span_notice("You cut away the wiring."))
		playsound(loc, item.usesound, 100, TRUE)
		wired_for_trap = FALSE
		return TRUE

/obj/structure/closet/crate/welder_act()
	return

/// Removes the supply manifest from the closet
/obj/structure/closet/crate/proc/tear_manifest(mob/user)
	var/obj/item/paper/manifest/our_manifest = manifest?.resolve()
	if(QDELETED(our_manifest))
		manifest = null
		return
	if(user)
		to_chat(user, span_notice("You tear the manifest off of [src]."))
	playsound(src, 'sound/items/poster_ripped.ogg', 75, TRUE)

	if(!ishuman(user))
		our_manifest.forceMove(drop_location(src))
	user.put_in_hands(our_manifest)
	manifest = null
	update_appearance()

/obj/structure/closet/crate/attack_hand(mob/user, list/modifiers)
	. = ..()
	handle_electropack_trap(user)
	if(.)
		return
	tear_manifest(user)

/obj/structure/closet/crate/proc/handle_electropack_trap(mob/living/user)
	var/obj/item/radio/electropack = locate() in src
	if(!wired_for_trap || !electropack)
		return FALSE

	if(!isliving(user))
		return FALSE

	if(!user.electrocute_act(17, electropack))
		return FALSE

	do_sparks(5, TRUE, src)
	return TRUE

/// Called when a crate is delivered by MULE at a location, for notifying purposes
/obj/structure/closet/crate/proc/notify_recipient(destination)
	var/message = "[capitalize(name)] has arrived at [destination]."
	if(!(destination in announce_beacons))
		return

	for(var/obj/machinery/requests_console/console as anything in GLOB.allRequestConsoles)
		if(!(console.department in announce_beacons[destination]))
			continue
		console.createMessage(name, "Your Crate has Arrived!", message, 1)

/obj/structure/closet/crate/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(!isliving(user))
		return

	// 1) Prevent dragging from shelf onto non-turf objects
	if(is_cargo_shelf(loc) && !isturf(over_object))
		return

	// 2) If the target is a crate on a shelf, we work with the shelf itself.
	if(is_crate(over_object) && is_cargo_shelf(over_object.loc))
		over_object = over_object.loc

	// 3) If the crate is on a shelf, the user must be able to reach the shelf (or the crate itself)
	if(is_cargo_shelf(loc) && !loc.IsReachableBy(user) && !IsReachableBy(user))
		return

	// 4) Unloading from shelf to turf
	if(!isopenspaceturf(over_object) && is_cargo_shelf(loc) && !is_cargo_shelf(over_object))
		if(!over_object.IsReachableBy(user))
			return
		var/obj/structure/cargo_shelf/shelf = loc
		shelf.unload(src, user, over_object)
		return

	var/list/modifiers = params2list(params)
	var/y_offset = text2num(modifiers[ICON_Y])

	// 5) Shelf to Shelf (drag from one shelf to another)
	if(is_cargo_shelf(over_object) && is_cargo_shelf(loc))
		var/obj/structure/cargo_shelf/source_shelf = loc
		var/obj/structure/cargo_shelf/destination_shelf = over_object

		// Must be able to reach the destination shelf
		if(!destination_shelf.IsReachableBy(user))
			return

		if(destination_shelf.can_load(src, user, y_offset) && source_shelf.unload(src, user, destination_shelf))
			if(!destination_shelf.load(src, user, y_offset, instant = TRUE)) // Might have been filled up in that the time it took to load
				forceMove(source_shelf.get_spill_location()) // So let's get rid of it in that case
		return

	// 6) Turf to shelf (normal loading)
	if(is_cargo_shelf(over_object) && isturf(loc))
		var/obj/structure/cargo_shelf/shelf = over_object
		if(!shelf.IsReachableBy(user) && !IsReachableBy(user))
			return
		shelf.load(src, user, y_offset)
		return
