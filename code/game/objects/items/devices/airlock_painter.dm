// Airlock painter

/obj/item/airlock_painter
	name = "airlock painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on a completed airlock to change its paintjob."
	icon = 'icons/obj/device.dmi'
	icon_state = "airlock_painter"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	item_state = "airlock_painter"
	flags = CONDUCT
	item_flags = NOBLUDGEON
	usesound = 'sound/effects/spray2.ogg'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000)
	var/paint_setting

	/// The ink cartridge to pull charges from.
	var/obj/item/toner/ink = null
	/// The type path to instantiate for the ink cartridge the device initially comes with, eg. /obj/item/toner
	var/initial_ink_type = /obj/item/toner

	// All the different paint jobs that an airlock painter can apply.
	// If the airlock you're using it on is glass, the new paint job will also be glass
	var/list/available_paint_jobs = list(
		"Atmospherics" = /obj/machinery/door/airlock/atmos,
		"Command" = /obj/machinery/door/airlock/command,
		"Engineering" = /obj/machinery/door/airlock/engineering,
		"External" = /obj/machinery/door/airlock/external,
		"External Maintenance"= /obj/machinery/door/airlock/maintenance/external,
		"Freezer" = /obj/machinery/door/airlock/freezer,
		"Maintenance" = /obj/machinery/door/airlock/maintenance,
		"Medical" = /obj/machinery/door/airlock/medical,
		"Mining" = /obj/machinery/door/airlock/mining,
		"Public" = /obj/machinery/door/airlock/public,
		"Research" = /obj/machinery/door/airlock/research,
		"Science" = /obj/machinery/door/airlock/science,
		"Security" = /obj/machinery/door/airlock/security,
		"Standard" = /obj/machinery/door/airlock,
	)

/obj/item/airlock_painter/Initialize(mapload)
	. = ..()
	ink = new initial_ink_type(src)

/obj/item/airlock_painter/Destroy(force)
	QDEL_NULL(ink)
	return ..()

/obj/item/airlock_painter/examine(mob/user)
	. = ..()
	if(!ink)
		. += span_notice("It doesn't have a toner cartridge installed.")
		return
	var/ink_level = "high"
	if(ink.charges < 1)
		ink_level = "empty"
	else if((ink.charges / ink.max_charges) <= 0.25) //25%
		ink_level = "low"
	else if((ink.charges / ink.max_charges) > 1) //Over 100% (admin var edit)
		ink_level = "dangerously high"
	. += span_notice("Its ink levels look [ink_level].")


//This proc only checks if the painter can be used.
//Call this if you don't want the painter to be used right after this check, for example
//because you're expecting user input.
/obj/item/airlock_painter/proc/can_use(mob/user)
	if(!ink)
		balloon_alert(user, "no cartridge!")
		return FALSE
	else if(ink.charges < 1)
		balloon_alert(user, "out of ink!")
		return FALSE
	else
		return TRUE

//This proc doesn't just check if the painter can be used, but also uses it.
//Only call this if you are certain that the painter will be used right after this check!
/obj/item/airlock_painter/proc/use_paint(mob/user)
	if(can_use(user))
		ink.charges--
		playsound(loc, usesound, 50, TRUE)
		return TRUE
	else
		return FALSE

/obj/item/airlock_painter/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(W, /obj/item/toner))
		if(ink)
			to_chat(user, span_warning("[src] already contains \a [ink]!"))
			return
		if(!user.transfer_item_to_loc(W, src))
			return
		to_chat(user, span_notice("You install [W] into [src]."))
		ink = W
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	else
		return ..()

/obj/item/airlock_painter/click_alt(mob/user)
	if(!ink)
		return CLICK_ACTION_BLOCKING

	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	ink.forceMove(user.drop_location())
	user.put_in_hands(ink)
	to_chat(user, span_notice("You remove [ink] from [src]."))
	ink = null
	return CLICK_ACTION_SUCCESS

/obj/item/airlock_painter/attack_self(mob/user)
	paint_setting = tgui_input_list(user, "Please select a paintjob for this airlock", "Airlock painter", available_paint_jobs)
	if(!paint_setting)
		return
	to_chat(user, span_notice("The [paint_setting] paint setting has been selected."))

/obj/item/airlock_painter/suicide_act(mob/user)

	var/obj/item/organ/internal/lungs/L = user.get_organ_slot(INTERNAL_ORGAN_LUNGS)
	var/lungs_name = "[L.name]"

	if(L)
		user.visible_message(span_suicide("[user] is inhaling toner from [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		// Once you've inhaled the toner, you throw up your lungs
		// and then die.

		// they managed to lose their lungs between then and now. Good job.
		if(!L)
			return FALSE

		L.remove(user)

		// make some colorful reagent, and apply it to the lungs
		L.create_reagents(10)
		L.reagents.add_reagent("colorful_reagent", 10)
		L.reagents.reaction(L, REAGENT_TOUCH, 1)

		user.emote("scream")
		user.visible_message(span_suicide("[user] vomits out [user.p_their()] [lungs_name]!"))
		playsound(user.loc, 'sound/effects/splat.ogg', 50, TRUE)

		// make some vomit under the player, and apply colorful reagent
		var/obj/effect/decal/cleanable/vomit/V = new(get_turf(user))
		V.create_reagents(10)
		V.reagents.add_reagent("colorful_reagent", 10)
		V.reagents.reaction(V, REAGENT_TOUCH, 1)

		L.forceMove(get_turf(user))

		return OXYLOSS
	else
		return SHAME
