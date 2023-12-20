/obj/item/implant/explosive
	name = "microbomb bio-chip"
	desc = "And boom goes the weasel."
	icon_state = "explosive_old"
	origin_tech = "materials=2;combat=3;biotech=4;syndicate=4"
	implant_state = "implant-syndicate"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	actions_types = list(/datum/action/item_action/hands_free/activate/always)
	trigger_causes = BIOCHIP_TRIGGER_DEATH_ONCE // Not surviving that
	implant_data = /datum/implant_fluff/explosive
	var/detonating = FALSE
	var/weak = 2
	var/medium = 0.8
	var/heavy = 0.4
	var/delay = (0.7 SECONDS)


/obj/item/implant/explosive/death_trigger(mob/source, gibbed)
	activate("death")


/obj/item/implant/explosive/activate(cause)
	if(!cause || QDELETED(imp_in))
		return FALSE
	if(cause == "action_button" && alert(imp_in, "Are you sure you want to activate your microbomb bio-chip? This will cause you to explode!", "Microbomb Bio-chip Confirmation", "Yes", "No") != "Yes")
		return FALSE
	if(detonating)
		return FALSE

	heavy = round(heavy)
	medium = round(medium)
	weak = round(weak)
	detonating = TRUE
	to_chat(imp_in, span_danger("You activate your microbomb bio-chip."))

	if(delay <= 7)	//If the delay is short, just blow up already jeez
		self_destruct()
		return

	timed_explosion()


/**
 * Gib the implantee and delete their destructible contents.
 */
/obj/item/implant/explosive/proc/self_destruct()
	if(QDELETED(imp_in))
		return

	explosion(src, heavy, medium, weak, weak, flame_range = weak, cause = src)

	// In case something happens to the implantee between now and the self-destruct
	var/current_location = get_turf(imp_in)
	var/list/destructed_items = list()

	// Iterate over the implantee's contents and take out indestructible
	// things to avoid having to worry about containers and recursion
	for(var/obj/item/check in imp_in.get_contents())
		if(check == src) // Don't delete ourselves prematurely
			continue
		// Drop indestructible items on the ground first, to avoid them
		// getting deleted when destroying the rest of the items, which we
		// track in a list to qdel afterwards
		if(check.resistance_flags & INDESTRUCTIBLE)
			check.forceMove(current_location)
		else
			destructed_items += check

	QDEL_LIST(destructed_items)
	imp_in.gib()
	qdel(src)


/obj/item/implant/explosive/proc/timed_explosion()
	imp_in.visible_message(span_warning("[imp_in] starts beeping ominously!"))
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	var/wait_delay = delay / 4
	sleep(wait_delay)
	if(!QDELETED(imp_in) && imp_in.stat)
		imp_in.visible_message(span_warning("[imp_in] doubles over in pain!"))
		imp_in.Weaken(14 SECONDS)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(wait_delay)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(wait_delay)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(wait_delay)
	self_destruct()


/obj/item/implant/explosive/implant(mob/living/carbon/human/source, mob/user, force = FALSE)
	var/obj/item/implant/explosive/same_imp = locate(type) in source
	if(same_imp && same_imp != src)
		same_imp.heavy += heavy
		same_imp.medium += medium
		same_imp.weak += weak
		same_imp.delay += delay
		qdel(src)
		return TRUE
	return ..()


/obj/item/implant/explosive/macro
	name = "macrobomb bio-chip"
	desc = "And boom goes the weasel. And everything else nearby."
	icon_state = "explosive_old"
	origin_tech = "materials=3;combat=5;biotech=4;syndicate=5"
	weak = 16
	medium = 8
	heavy = 4
	delay = (7 SECONDS)
	implant_data = new /datum/implant_fluff/explosive_macro


/obj/item/implant/explosive/macro/activate(cause)
	if(!cause || QDELETED(imp_in))
		return FALSE
	if(cause == "action_button" && alert(imp_in, "Are you sure you want to activate your macrobomb bio-chip? This will cause you to explode and gib!", "Macrobomb Bio-chip Confirmation", "Yes", "No") != "Yes")
		return FALSE
	to_chat(imp_in, span_notice("You activate your macrobomb bio-chip."))
	timed_explosion()


/obj/item/implant/explosive/macro/implant(mob/living/carbon/human/source, mob/user, force = FALSE)
	var/obj/item/implant/explosive/same_imp = locate(type) in source
	if(same_imp && same_imp != src)
		return FALSE
	same_imp = locate(/obj/item/implant/explosive) in source
	if(same_imp && same_imp != src)
		heavy += same_imp.heavy
		medium += same_imp.medium
		weak += same_imp.weak
		delay += same_imp.delay
		qdel(same_imp)
	return ..()


/obj/item/implanter/explosive
	name = "bio-chip implanter (micro-explosive)"
	imp = /obj/item/implant/explosive


/obj/item/implantcase/explosive
	name = "bio-chip case - 'Micro Explosive'"
	desc = "A glass case containing a micro explosive bio-chip."
	imp = /obj/item/implant/explosive


/obj/item/implanter/explosive_macro
	name = "bio-chip implanter (macro-explosive)"
	imp = /obj/item/implant/explosive/macro


/obj/item/implantcase/explosive_macro
	name = "bio-chip case - 'Macro Explosive'"
	desc = "A glass case containing a macro explosive bio-chip."
	imp = /obj/item/implant/explosive/macro

