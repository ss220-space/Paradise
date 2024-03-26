/obj/machinery/dye_generator
	name = "Dye Generator"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "barbervend_off"
	base_icon_state = "barbervend"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	var/dye_color = "#FFFFFF"


/obj/machinery/dye_generator/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/dye_generator/update_overlays()
	. = ..()

	underlays.Cut()

	if(panel_open)
		. += "[base_icon_state]_panel"

	if(stat & NOPOWER)
		if(stat & BROKEN)
			. += "[base_icon_state]_broken"
		return

	if(stat & BROKEN)
		. += "[base_icon_state]_broken"
		underlays += emissive_appearance(icon, "[base_icon_state]_broken_lightmask")
	else
		. += "[base_icon_state]"
		underlays += emissive_appearance(icon, "[base_icon_state]_lightmask")


/obj/machinery/dye_generator/obj_break(damage_flag)
	..()
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/dye_generator/power_change(forced = FALSE)
	. = ..()
	if(stat & NOPOWER)
		set_light_on(FALSE)
	else
		set_light(1, LIGHTING_MINIMUM_POWER, dye_color)
	if(.)
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/dye_generator/extinguish_light(force = FALSE)
	if(light)
		set_light_on(FALSE)
		underlays.Cut()


/obj/machinery/dye_generator/attack_hand(mob/user)
	..()
	if(stat & (BROKEN|NOPOWER))
		return
	var/temp = input(usr, "Choose a dye color", "Dye Color") as color
	dye_color = temp
	set_light(1, LIGHTING_MINIMUM_POWER, temp)


/obj/machinery/dye_generator/attackby(obj/item/I, mob/user, params)

	if(default_unfasten_wrench(user, I, time = 60))
		add_fingerprint(user)
		return

	if(istype(I, /obj/item/hair_dye_bottle))
		add_fingerprint(user)
		var/obj/item/hair_dye_bottle/HD = I
		user.visible_message(span_notice("[user] fills the [HD] up with some dye."),span_notice("You fill the [HD] up with some hair dye."))
		HD.dye_color = dye_color
		HD.update_icon(UPDATE_OVERLAYS)
		return
	return ..()


//Hair Dye Bottle
/obj/item/hair_dye_bottle
	name = "Hair Dye Bottle"
	desc = "A refillable bottle used for holding hair dyes of all sorts of colors."
	icon = 'icons/obj/items.dmi'
	icon_state = "hairdyebottle"
	throwforce = 0
	throw_speed = 4
	throw_range = 7
	force = 0
	w_class = WEIGHT_CLASS_TINY
	var/dye_color = "#FFFFFF"


/obj/item/hair_dye_bottle/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)


/obj/item/hair_dye_bottle/update_overlays()
	. = ..()
	. += mutable_appearance(icon, icon_state = "hairdyebottle-overlay", color = dye_color)


/obj/item/hair_dye_bottle/attack(mob/living/carbon/M, mob/user)
	if(user.a_intent != INTENT_HELP)
		..()
		return
	if(!(M in view(1)))
		..()
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/dye_list = list("hair", "alt. hair theme")

		if(H.gender == MALE || isvulpkanin(H))
			dye_list += "facial hair"
			dye_list += "alt. facial hair theme"

		if(H && (H.dna.species.bodyflags & HAS_SKIN_COLOR))
			dye_list += "body"

		var/what_to_dye = input(user, "Choose an area to apply the dye", "Dye Application") in dye_list
		if(!user.Adjacent(M))
			to_chat(user, "You are too far away!")
			return
		user.visible_message(span_notice("[user] starts dying [M]'s [what_to_dye]!"), span_notice("You start dying [M]'s [what_to_dye]!"))
		if(do_after(user, 50, target = H))
			switch(what_to_dye)
				if("hair")
					H.change_hair_color(dye_color)
				if("alt. hair theme")
					H.change_hair_color(dye_color, 1)
				if("facial hair")
					H.change_facial_hair_color(dye_color)
				if("alt. facial hair theme")
					H.change_facial_hair_color(dye_color, 1)
				if("body")
					H.change_skin_color(dye_color)
			H.update_dna()
		user.visible_message(span_notice("[user] finishes dying [M]'s [what_to_dye]!"), span_notice("You finish dying [M]'s [what_to_dye]!"))
