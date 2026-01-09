////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//////Freeze Mob/Mech Verb -- Ported from NSS Pheonix (Unbound Travels)/////////
////////////////////////////////////////////////////////////////////////////////
//////Allows admin's to right click on any mob/mech and freeze them in place.///
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

GLOBAL_LIST_EMPTY(frozen_atom_list) // A list of admin-frozen atoms.

ADMIN_VERB_ONLY_CONTEXT_MENU(admin_freeze, R_ADMIN, "Freeze", atom/movable/target in view())
	target.admin_Freeze(user)

/// Created here as a base proc. Override as needed for any type of object or mob you want able to be frozen.
/atom/movable/proc/admin_Freeze(client/admin)
	to_chat(admin, span_warning("Freeze is not able to be called on this type of object."))
	return

//mob freeze procs
/mob/living/admin_Freeze(client/admin, skip_overlays = FALSE, mech = null)
	if(!istype(admin))
		return

	if(!(src in GLOB.frozen_atom_list))
		GLOB.frozen_atom_list += src

		var/obj/effect/overlay/adminoverlay/AO = new
		if(skip_overlays)
			add_overlay(AO)

		set_anchored(TRUE)
		admin_prev_sleeping = AmountSleeping()
		PermaSleeping()
		frozen = AO

	else
		GLOB.frozen_atom_list -= src

		if(skip_overlays)
			cut_overlay(frozen)

		set_anchored(FALSE)
		frozen = null
		SetSleeping(admin_prev_sleeping)
		admin_prev_sleeping = null

	to_chat(src, "<b><font color= red>You have been [frozen ? "frozen" : "unfrozen"] by [admin]</b></font>")
	message_admins(span_notice("[key_name_admin(admin)] [frozen ? "froze" : "unfroze"] [key_name_admin(src)] [mech ? "in a [mech]" : ""]"))
	log_admin("[key_name(admin)] [frozen ? "froze" : "unfroze"] [key_name(src)] [mech ? "in a [mech]" : ""]")
	update_icons()

	return frozen

/mob/living/simple_animal/slime/admin_Freeze(admin)
	if(..()) // The result of the parent call here will be the value of the mob's `frozen` variable after they get (un)frozen.
		adjustHealth(1000) //arbitrary large value
	else
		revive()

/mob/living/simple_animal/admin_Freeze(admin)
	if(..()) // The result of the parent call here will be the value of the mob's `frozen` variable after they get (un)frozen.
		admin_prev_health = health
		health = 0
	else
		revive()

//////////////////////////Freeze Mech

/obj/mecha/admin_Freeze(client/admin)
	var/obj/effect/overlay/adminoverlay/freeze_overlay = new
	if(!frozen)
		GLOB.frozen_atom_list += src
		frozen = TRUE
		add_overlay(freeze_overlay)
	else
		GLOB.frozen_atom_list -= src
		frozen = FALSE
		cut_overlay(freeze_overlay)

	if(occupant)
		occupant.admin_Freeze(admin, mech = name) // We also want to freeze the driver of the mech.
	else
		message_admins(span_notice("[key_name_admin(admin)] [frozen ? "froze" : "unfroze"] an empty [name]"))
		log_admin("[key_name(admin)] [frozen ? "froze" : "unfroze"] an empty [name]")
