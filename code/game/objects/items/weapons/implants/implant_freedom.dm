/obj/item/implant/freedom
	name = "freedom bio-chip"
	desc = "Use this to escape from those evil Red Shirts."
	icon_state = "freedom_old"
	implant_state = "implant-syndicate"
	item_color = "r"
	origin_tech = "combat=5;magnets=3;biotech=4;syndicate=2"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	implant_data = /datum/implant_fluff/freedom
	uses = 4


/obj/item/implant/freedom/activate(cause)
	uses--
	to_chat(imp_in, "You feel a faint click.")
	if(iscarbon(imp_in))
		var/mob/living/carbon/C_imp_in = imp_in
		C_imp_in.uncuff()
		if(C_imp_in.pulledby)
			var/mob/living/grabber = C_imp_in.pulledby
			C_imp_in.visible_message(span_warning("[C_imp_in] suddenly shocks [grabber] from their wrists and slips out of their grab!"))
			grabber.apply_damage(2, BURN, BODY_ZONE_PRECISE_R_HAND, grabber.run_armor_check(BODY_ZONE_PRECISE_R_HAND, ENERGY))
			grabber.apply_damage(2, BURN, BODY_ZONE_PRECISE_L_HAND, grabber.run_armor_check(BODY_ZONE_PRECISE_L_HAND, ENERGY))
			playsound(C_imp_in.loc, 'sound/weapons/egloves.ogg', 75, TRUE)
			grabber.stop_pulling()
			C_imp_in.client?.move_delay = world.time	// to skip move delay we probably got from resisting the grab

	if(!uses)
		qdel(src)


/obj/item/implanter/freedom
	name = "bio-chip implanter (freedom)"
	imp = /obj/item/implant/freedom


/obj/item/implantcase/freedom
	name = "bio-chip case - 'Freedom'"
	desc = "A glass case containing a freedom bio-chip."
	imp = /obj/item/implant/freedom


/obj/item/implant/freedom/prototype
	name = "prototype freedom bio-chip"
	desc = "Use this to escape from those evil Red Shirts. Works only once!"
	origin_tech = "combat=5;magnets=3;biotech=3;syndicate=1"
	implant_data = /datum/implant_fluff/protofreedom
	uses = 1



/obj/item/implanter/freedom/prototype
	name = "bio-chip implanter (proto-freedom)"
	imp = /obj/item/implant/freedom/prototype


/obj/item/implantcase/freedom/prototype
	name = "bio-chip case - 'Proto-Freedom'"
	desc = "A glass case containing a prototype freedom bio-chip."
	imp = /obj/item/implant/freedom/prototype

