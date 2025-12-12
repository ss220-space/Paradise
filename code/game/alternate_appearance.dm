GLOBAL_LIST_EMPTY(active_alternate_appearances)

/atom/proc/remove_alt_appearance(key)
	if(!LAZYLEN(alternate_appearances))
		return

	for(var/id in alternate_appearances)
		var/datum/atom_hud/alternate_appearance/hud = alternate_appearances[id]
		if(hud.appearance_key == key)
			hud.remove_atom_from_hud(src)
			break

/atom/proc/add_alt_appearance(type, key, ...)
	if(!type || !key)
		return

	if(alternate_appearances && alternate_appearances[key])
		return

	if(!ispath(type, /datum/atom_hud/alternate_appearance))
		CRASH("Invalid type passed in: [type]")

	var/list/arguments = args.Copy(2)
	return new type(arglist(arguments))


/datum/atom_hud/alternate_appearance
	var/appearance_key
	var/transfer_overlays = FALSE

/datum/atom_hud/alternate_appearance/New(key)
	// We use hud_icons to register our hud, so we need to do this before the parent call
	appearance_key = key
	hud_icons = list(appearance_key)
	..()

	GLOB.active_alternate_appearances += src

	for(var/mob in GLOB.player_list)
		apply_to_new_mob(mob)

/datum/atom_hud/alternate_appearance/Destroy(force)
	GLOB.active_alternate_appearances -= src
	return ..()

/// Wrapper for applying this alt hud to the passed mob (if they should see it)
/datum/atom_hud/alternate_appearance/proc/apply_to_new_mob(mob/applying_to)
	if(!mob_should_see(applying_to))
		return FALSE

	if(!hud_users_all_z_levels[applying_to])
		show_to(applying_to)

	return TRUE

/// Checks if the passed mob should be seeing this hud
/datum/atom_hud/alternate_appearance/proc/mob_should_see(mob/viewer)
	return FALSE

/datum/atom_hud/alternate_appearance/show_to(mob/new_viewer)
	. = ..()
	if(!new_viewer)
		return

	track_mob(new_viewer)

/// Registers some signals to track the mob's state to determine if they should be seeing the hud still
/datum/atom_hud/alternate_appearance/proc/track_mob(mob/new_viewer)
	return

/datum/atom_hud/alternate_appearance/hide_from(mob/former_viewer, absolute)
	. = ..()
	if(!former_viewer || hud_atoms_all_z_levels[former_viewer] >= 1)
		return

	untrack_mob(former_viewer)

/// Unregisters the signals that were tracking the mob's state
/datum/atom_hud/alternate_appearance/proc/untrack_mob(mob/former_viewer)
	return

/datum/atom_hud/alternate_appearance/proc/check_hud(mob/source)
	SIGNAL_HANDLER
	// Attempt to re-apply the hud entirely
	if(apply_to_new_mob(source))
		return

	// If that failed, probably shouldn't be seeing it at all, so nuke it
	hide_from(source, absolute = TRUE)

/datum/atom_hud/alternate_appearance/add_atom_to_hud(atom/new_hud_atom, image/hud)
	. = ..()
	if(!.)
		return

	LAZYSET(new_hud_atom.alternate_appearances, appearance_key, src)

/datum/atom_hud/alternate_appearance/remove_atom_from_hud(atom/hud_atom_to_remove)
	. = ..()
	if(!.)
		return

	LAZYREMOVE(hud_atom_to_remove.alternate_appearances, appearance_key)

/datum/atom_hud/alternate_appearance/proc/copy_overlays(atom/other, cut_old)
	return

//an alternate appearance that attaches a single image to a single atom
/datum/atom_hud/alternate_appearance/basic
	var/atom/target
	var/image/image
	var/add_ghost_version = FALSE
	var/datum/atom_hud/alternate_appearance/basic/observers/ghost_appearance
	uses_global_hud_category = FALSE

/datum/atom_hud/alternate_appearance/basic/New(key, image/hud, options = AA_TARGET_SEE_APPEARANCE)
	..()
	transfer_overlays = options & AA_MATCH_TARGET_OVERLAYS
	image = hud
	target = hud.loc
	LAZYADD(target.update_on_z, image)

	if(transfer_overlays)
		hud.copy_overlays(target)

	add_atom_to_hud(target)
	target.set_hud_image_active(appearance_key, exclusive_hud = src)

	if((options & AA_TARGET_SEE_APPEARANCE) && ismob(target))
		show_to(target)

	if(!add_ghost_version)
		return

	var/image/ghost_image = image(icon = hud.icon , icon_state = hud.icon_state, loc = hud.loc)
	ghost_image.override = FALSE
	ghost_image.alpha = 128
	ghost_appearance = new /datum/atom_hud/alternate_appearance/basic/observers(key + "_observer", ghost_image, NONE)

/datum/atom_hud/alternate_appearance/basic/Destroy(force)
	. = ..()
	LAZYREMOVE(target.update_on_z, image)
	QDEL_NULL(image)
	target = null

	if(!ghost_appearance)
		return

	QDEL_NULL(ghost_appearance)

/datum/atom_hud/alternate_appearance/basic/track_mob(mob/new_viewer)
	RegisterSignal(new_viewer, list(
		COMSIG_MOB_GHOSTIZE,
		COMSIG_MIND_TRANSER_TO,
		COMSIG_BODY_TRANSFER_TO,
	), PROC_REF(check_hud), override = TRUE)

/datum/atom_hud/alternate_appearance/basic/untrack_mob(mob/former_viewer)
	UnregisterSignal(former_viewer, list(
		COMSIG_MOB_GHOSTIZE,
		COMSIG_MIND_TRANSER_TO,
		COMSIG_BODY_TRANSFER_TO,
	))

/datum/atom_hud/alternate_appearance/basic/add_atom_to_hud(atom/new_hud_atom)
	LAZYINITLIST(new_hud_atom.hud_list)
	new_hud_atom.hud_list[appearance_key] = image
	. = ..()

/datum/atom_hud/alternate_appearance/basic/remove_atom_from_hud(atom/hud_atom_to_remove)
	. = ..()
	LAZYREMOVE(hud_atom_to_remove.hud_list, appearance_key)
	hud_atom_to_remove.set_hud_image_inactive(appearance_key)
	if(. && !QDELETED(src))
		qdel(src)

/datum/atom_hud/alternate_appearance/basic/copy_overlays(atom/other, cut_old)
		image.copy_overlays(other, cut_old)

/datum/atom_hud/alternate_appearance/basic/everyone
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/everyone/mob_should_see(mob/viewer)
	return !isobserver(viewer)

/datum/atom_hud/alternate_appearance/basic/silicons

/datum/atom_hud/alternate_appearance/basic/silicons/mob_should_see(mob/viewer)
	if(issilicon(viewer))
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/observers

/datum/atom_hud/alternate_appearance/basic/observers/mob_should_see(mob/viewer)
	return isobserver(viewer)

/// Only shows the image to one person
/datum/atom_hud/alternate_appearance/basic/one_person
	/// The guy who gets to see the image
	var/mob/seer

/datum/atom_hud/alternate_appearance/basic/one_person/mob_should_see(mob/viewer)
	return viewer == seer

/datum/atom_hud/alternate_appearance/basic/one_person/New(key, image/hud, options = NONE, mob/living/seer)
	src.seer = seer
	return ..()

/// Shows the image to everyone but one person
/datum/atom_hud/alternate_appearance/basic/one_person/reversed

/datum/atom_hud/alternate_appearance/basic/one_person/reversed/mob_should_see(mob/viewer)
	return viewer != seer
