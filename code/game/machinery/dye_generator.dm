/obj/machinery/dye_generator
	name = "Dye Generator"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "barbervend_off"
	base_icon_state = "barbervend"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	light_range = 2


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
		underlays += emissive_appearance(icon, "[base_icon_state]_broken_lightmask", src)
	else
		. += "[base_icon_state]"
		underlays += emissive_appearance(icon, "[base_icon_state]_lightmask", src)


/obj/machinery/dye_generator/obj_break(damage_flag)
	..()
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/dye_generator/power_change(forced = FALSE)
	. = ..()
	if(.)
		set_light_on(!(stat & NOPOWER))
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/dye_generator/extinguish_light(force = FALSE)
	if(light_on)
		set_light_on(FALSE)
		underlays.Cut()


/obj/machinery/dye_generator/attack_hand(mob/user)
	..()
	if(stat & (BROKEN|NOPOWER))
		return
	var/temp = input(usr, "Choose a dye color", "Dye Color") as color|null
	if(!temp)
		return
	set_light_color(temp)


/obj/machinery/dye_generator/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)


/obj/machinery/dye_generator/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/hair_dye_bottle))
		add_fingerprint(user)
		var/obj/item/hair_dye_bottle/dye_bottle = I
		user.visible_message(
			span_notice("[user] fills [dye_bottle] up with some hair dye."),
			span_notice("You fill [dye_bottle] up with some hair dye."),
		)
		dye_bottle.hair_dye_color = light_color
		dye_bottle.update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

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
	var/hair_dye_color = "#FFFFFF"


/obj/item/hair_dye_bottle/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)


/obj/item/hair_dye_bottle/update_overlays()
	. = ..()
	. += mutable_appearance(icon, icon_state = "hairdyebottle-overlay", color = hair_dye_color)


/obj/item/hair_dye_bottle/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target) || user.a_intent != INTENT_HELP || !(target in view(1)))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	var/dye_list = list("hair", "alt. hair theme")
	if(target.gender == MALE || isvulpkanin(target))
		dye_list += "facial hair"
		dye_list += "alt. facial hair theme"

	if(target.dna.species.bodyflags & HAS_SKIN_COLOR)
		dye_list += "body"

	var/what_to_dye = tgui_input_list(user, "Choose an area to apply the dye", "Dye Application", dye_list)
	if(isnull(what_to_dye) || !user.Adjacent(target))
		to_chat(user, "You are too far away!")
		return .

	user.visible_message(
		span_notice("[user] starts dying [target]'s [what_to_dye]!"),
		span_notice("You start dying [target]'s [what_to_dye]!"),
	)

	if(!do_after(user, 5 SECONDS, target, category = DA_CAT_TOOL))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	switch(what_to_dye)
		if("hair")
			target.change_hair_color(hair_dye_color)
		if("alt. hair theme")
			target.change_hair_color(hair_dye_color, 1)
		if("facial hair")
			target.change_facial_hair_color(hair_dye_color)
		if("alt. facial hair theme")
			target.change_facial_hair_color(hair_dye_color, 1)
		if("body")
			target.change_skin_color(hair_dye_color)

	target.update_dna()
	user.visible_message(
		span_notice("[user] finishes dying [target]'s [what_to_dye]!"),
		span_notice("You finish dying [target]'s [what_to_dye]!"),
	)

