/obj/item/implant/second_chance
	name = "second chance bio-chip"
	desc = "Simulates your death and teleports you to an exact safe place."
	icon_state = "explosive_old"
	origin_tech = "materials=1;combat=2;biotech=4;syndicate=3;bluespace=1"
	implant_state = "implant-syndicate"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	actions_types = list(/datum/action/item_action/hands_free/activate/always)
	implant_data = /datum/implant_fluff/second_chance


/obj/item/implant/second_chance/activate()
	var/turf/old_turf = get_turf(imp_in)

	if(is_teleport_allowed(imp_in.z))
		var/turf/new_turf = find_safe_turf(level_name_to_num(MAIN_STATION))
		do_teleport(imp_in, new_turf, 0)
		playsound(imp_in, 'sound/effects/sparks4.ogg', 50, TRUE)
		do_sparks(4, TRUE, imp_in)
		imp_in.rejuvenate()
		investigate_log("[key_name_log(imp_in)] fake-gib himself using [name] and teleports to [COORD(new_turf)].", INVESTIGATE_TELEPORTATION)

		explosion(old_turf, 0, 0, 3, 6, cause = imp_in)

		if(isnucleation(imp_in))
			imp_in.visible_message(span_warning("Тело [imp_in] взрывается, оставляя после себя множество микроскопических кристаллов!"))
		else if(!ismachineperson(imp_in))
			new /obj/effect/temp_visual/gib(old_turf)
			new /obj/effect/gibspawner/human(old_turf)
			playsound(old_turf, 'sound/goonstation/effects/gib.ogg', 50, TRUE)
		else
			do_sparks(3, TRUE, old_turf)
			playsound(old_turf, 'sound/goonstation/effects/robogib.ogg', 50, TRUE)
			new /obj/effect/decal/cleanable/blood/gibs/robot(old_turf)

	else
		to_chat(imp_in, span_userdanger("[src] is malfunctioning!"))
		explosion(old_turf, 0, 0, 3, 6, cause = imp_in)
	qdel(src)


/obj/item/implanter/second_chance
	name = "bio-chip implanter (second chance)"
	imp = /obj/item/implant/second_chance


/obj/item/implantcase/second_chance
	name = "bio-chip case - 'Second Chance'"
	desc = "A glass case containing an second chance bio-chip."
	imp = /obj/item/implant/second_chance

