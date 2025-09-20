GLOBAL_LIST_EMPTY(active_alternate_appearances)

/atom/proc/remove_alt_appearance(key)
	if(!alternate_appearances)
		return

	for(var/possible_key in alternate_appearances)
		var/datum/atom_hud/alternate_appearance/alternate_appearance = alternate_appearances[possible_key]
		if(alternate_appearance.appearance_key != key)
			continue

		alternate_appearances.Remove(possible_key)
		qdel(alternate_appearance)
		if(alternate_appearances && !alternate_appearances.len)
			qdel(alternate_appearances)

		break


/atom/proc/add_alt_appearance(type, key, ...)
	if(!type || !key)
		return

	if(alternate_appearances && alternate_appearances[key])
		return

	if(!ispath(type, /datum/atom_hud/alternate_appearance))
		CRASH("Invalid type passed in: [type]")

	if(!alternate_appearances)
		alternate_appearances = list()

	var/list/arguments = args.Copy(2)
	alternate_appearances[key] = new type(arglist(arguments))
	return alternate_appearances[key]


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


/datum/atom_hud/alternate_appearance/Destroy()
	GLOB.active_alternate_appearances -= src
	return ..()


/datum/atom_hud/alternate_appearance/on_mob_mind_update(mob/mob)
	apply_to_new_mob(mob)


/// Wrapper for applying this alt hud to the passed mob (if they should see it)
/datum/atom_hud/alternate_appearance/proc/apply_to_new_mob(mob/applying_to)
	if(!mobShouldSee(applying_to))
		return FALSE

	. = TRUE
	if(!hudusers[applying_to])
		add_hud_to(applying_to)


/// Checks if the passed mob should be seeing this hud
/datum/atom_hud/alternate_appearance/proc/mobShouldSee(mob/mob)
	return FALSE


/datum/atom_hud/alternate_appearance/add_hud_to(mob/new_viewer, only_once=FALSE)
	. = ..()
	if(!new_viewer)
		return

	track_mob(new_viewer)


/// Registers some signals to track the mob's state to determine if they should be seeing the hud still
/datum/atom_hud/alternate_appearance/proc/track_mob(mob/new_viewer)
	return


/datum/atom_hud/alternate_appearance/remove_from_hud(mob/former_viewer)
	. = ..()
	if(!former_viewer || hudusers[former_viewer] >= 1)
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
	remove_from_hud(source)


/datum/atom_hud/alternate_appearance/add_hud_to(atom/atom, only_once=FALSE, image/img)
	. = ..()
	if(!atom)
		return

	LAZYINITLIST(atom.alternate_appearances)
	atom.alternate_appearances[appearance_key] = src


/datum/atom_hud/alternate_appearance/remove_hud_from(atom/atom)
	. = ..()
	if(!atom)
		return

	LAZYREMOVE(atom.alternate_appearances, appearance_key)


/datum/atom_hud/alternate_appearance/proc/copy_overlays(atom/other, cut_old)
	return


//an alternate appearance that attaches a single image to a single atom
/datum/atom_hud/alternate_appearance/basic
	var/atom/target
	var/image/image
	var/add_ghost_version = FALSE
	var/datum/atom_hud/alternate_appearance/basic/observers/ghost_appearance
	//uses_global_hud_category = FALSE


/datum/atom_hud/alternate_appearance/basic/New(key, image/img, options = AA_TARGET_SEE_APPEARANCE)
	..()
	//transfer_overlays = options & AA_MATCH_TARGET_OVERLAYS
	image = img
	target = img.loc
	LAZYADD(target.update_on_z, image)
	//if(transfer_overlays)
	//	img.copy_overlays(target)

	add_to_hud(target)
	//target.set_hud_image_active(appearance_key, exclusive_hud = src)

	//if((options & AA_TARGET_SEE_APPEARANCE) && ismob(target))
	//	add_hud_to(target)

	if(!add_ghost_version)
		return

	var/image/ghost_image = image(icon = img.icon , icon_state = img.icon_state, loc = img.loc)
	ghost_image.override = FALSE
	ghost_image.alpha = 128
	ghost_appearance = new /datum/atom_hud/alternate_appearance/basic/observers(key + "_observer", ghost_image, NONE)


/datum/atom_hud/alternate_appearance/basic/Destroy()
	. = ..()
	LAZYREMOVE(target?.update_on_z, image)
	QDEL_NULL(image)
	target = null
	if(!ghost_appearance)
		return

	QDEL_NULL(ghost_appearance)


/datum/atom_hud/alternate_appearance/basic/track_mob(mob/new_viewer)
	RegisterSignal(new_viewer, list(
		COMSIG_MOB_ANTAGONIST_REMOVED,
		COMSIG_MOB_GHOSTIZE,
		COMSIG_MOB_MIND_TRANSFERRED_INTO,
		COMSIG_MOB_MIND_TRANSFERRED_OUT_OF,
	), PROC_REF(check_hud), override = TRUE)


/datum/atom_hud/alternate_appearance/basic/untrack_mob(mob/former_viewer)
	UnregisterSignal(former_viewer, list(
		COMSIG_MOB_ANTAGONIST_REMOVED,
		COMSIG_MOB_GHOSTIZE,
		COMSIG_MOB_MIND_TRANSFERRED_INTO,
		COMSIG_MOB_MIND_TRANSFERRED_OUT_OF,
	))


/datum/atom_hud/alternate_appearance/basic/add_to_hud(atom/atom)
	if(!atom)
		return

	LAZYINITLIST(atom?.hud_list)
	atom.hud_list[appearance_key] = image
	. = ..()


/datum/atom_hud/alternate_appearance/basic/remove_from_hud(atom/atom)
	if(!atom)
		return

	. = ..()
	LAZYREMOVE(atom?.hud_list, appearance_key)
	if(!. || QDELETED(src))
		return

	qdel(src)


/datum/atom_hud/alternate_appearance/basic/copy_overlays(atom/other, cut_old)
	image.copy_overlays(other, cut_old)


/datum/atom_hud/alternate_appearance/basic/everyone
	add_ghost_version = TRUE


/datum/atom_hud/alternate_appearance/basic/everyone/mobShouldSee(mob/mob)
	return !(mob.stat & DEAD)


/datum/atom_hud/alternate_appearance/basic/silicons


/datum/atom_hud/alternate_appearance/basic/silicons/mobShouldSee(mob/mob)
	if(issilicon(mob))
		return TRUE

	return FALSE


/datum/atom_hud/alternate_appearance/basic/silicons_or_self
	/// The guy who gets to see the image
	var/mob/seer


/datum/atom_hud/alternate_appearance/basic/silicons_or_self/New(key, image/img, options = NONE, mob/living/seer)
	src.seer = seer
	return ..()


/datum/atom_hud/alternate_appearance/basic/silicons_or_self/mobShouldSee(mob/mob)
	if(issilicon(mob) || mob == seer)
		return TRUE

	return FALSE


/datum/atom_hud/alternate_appearance/basic/observers


/datum/atom_hud/alternate_appearance/basic/observers/mobShouldSee(mob/mob)
	return isobserver(mob)


/datum/atom_hud/alternate_appearance/basic/noncult


/datum/atom_hud/alternate_appearance/basic/noncult/mobShouldSee(mob/mob)
	return !iscultist(mob)


/datum/atom_hud/alternate_appearance/basic/blessed_aware


/datum/atom_hud/alternate_appearance/basic/blessed_aware/mobShouldSee(mob/mob)
	if(mob.mind?.isholy)
		return TRUE

	if(iswraith(mob))
		return TRUE

	if(isrevenant(mob) || iswizard(mob) || isheretic(mob))
		return TRUE

	return FALSE


/// Only shows the image to one person
/datum/atom_hud/alternate_appearance/basic/one_person
	/// The guy who gets to see the image
	var/mob/seer


/datum/atom_hud/alternate_appearance/basic/one_person/mobShouldSee(mob/mob)
	return mob == seer


/datum/atom_hud/alternate_appearance/basic/one_person/New(key, image/img, options = NONE, mob/living/seer)
	src.seer = seer
	return ..()


/// Shows the image to everyone but one person
/datum/atom_hud/alternate_appearance/basic/one_person/reversed


/datum/atom_hud/alternate_appearance/basic/one_person/reversed/mobShouldSee(mob/mob)
	return mob != seer


/datum/atom_hud/alternate_appearance/basic/food_demands


/datum/atom_hud/alternate_appearance/basic/heretic


/datum/atom_hud/alternate_appearance/basic/heretic/mobShouldSee(mob/mob)
	if(isheretic(mob))
		return TRUE

	return FALSE


/mob/proc/update_seeable_alt_appearances()
	for(var/datum/atom_hud/alternate_appearance/alt_hud as anything in GLOB.active_alternate_appearances)
		if(alt_hud.apply_to_new_mob(src))
			continue

		alt_hud.remove_hud_from(src)
