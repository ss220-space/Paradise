/obj/item/clothing/gloves/ring/gadget
	origin_tech = "magnets=3;combat=3;syndicate=2"
	var/changing = FALSE
	var/op_time = 2 SECONDS
	var/op_time_upgaded = 1 SECONDS
	var/op_cd_time = 5 SECONDS
	var/op_cd_time_upgaded = 3 SECONDS
	var/breaking = FALSE
	COOLDOWN_DECLARE(operation_cooldown)
	var/old_mclick_override

/obj/item/clothing/gloves/ring/gadget/attack_self(mob/user)
	. = ..()

	if(changing)
		user.balloon_alert(user, "Подождите")
		return

	changing = TRUE

	var/list/choices // only types that we can meet in the game

	if(!stud)
		choices = list(
			"iron" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "ironring"),
			"silver" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "silverring"),
			"gold" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "goldring"),
			"plasma" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "plasmaring"),
			"uranium" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "uraniumring")
		)
	else
		choices = list(
			"iron" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "d_ironring"),
			"silver" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "d_silverring"),
			"gold" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "d_goldring"),
			"plasma" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "d_plasmaring"),
			"uranium" = image(icon = 'icons/obj/clothing/rings.dmi', icon_state = "d_uraniumring")
		)

	var/selected_chameleon = show_radial_menu(usr, loc, choices, require_near = TRUE)
	switch(selected_chameleon)
		if("iron")
			name =  "iron ring"
			icon_state = "ironring"
			material = "iron"
			ring_color = "iron"
		if("silver")
			name =  "silver ring"
			icon_state = "silverring"
			material = "silver"
			ring_color = "silver"
		if("gold")
			name =  "gold ring"
			icon_state = "goldring"
			material = "gold"
			ring_color = "gold"
		if("plasma")
			name = "plasma ring"
			icon_state = "plasmaring"
			material = "plasma"
			ring_color = "plasma"
		if("uranium")
			name = "uranium ring"
			icon_state = "uraniumring"
			material = "uranium"
			ring_color = "uranium"
		else
			changing = FALSE
			return

	usr.visible_message(span_warning("[usr] changes the look of his ring!"), span_notice("[selected_chameleon] selected."))
	playsound(loc, 'sound/items/screwdriver2.ogg', 50, 1)
	to_chat(usr, span_notice("Смена маскировки..."))
	update_icon(UPDATE_ICON_STATE)
	changing = FALSE

/obj/item/clothing/gloves/ring/gadget/Touch(atom/A, proximity)
	. = FALSE
	var/mob/living/carbon/human/user = loc

	if(user.a_intent != INTENT_DISARM)
		return

	if(get_dist(user, A) > 1)
		return

	if(user.incapacitated())
		return

	var/obj/item/clothing/gloves/ring/gadget/ring = user.gloves

	if(ring.breaking)
		return

	if(!istype(A, /obj/structure/window))
		return

	if(!COOLDOWN_FINISHED(ring, operation_cooldown))
		user.balloon_alert(user, "Идет перезарядка")
		return

	ring.breaking = TRUE
	if(do_after(user, ring.stud ? ring.op_time_upgaded : ring.op_time))
		COOLDOWN_START(ring, operation_cooldown, ring.stud ? ring.op_cd_time_upgaded : ring.op_cd_time)

		ring.visible_message(span_warning("BANG"))
		playsound(ring, 'sound/effects/bang.ogg', 100, TRUE)

		for (var/mob/living/M in range(A, 3))
			if(M.check_ear_prot() == HEARING_PROTECTION_NONE)
				M.Deaf(6 SECONDS)

		for (var/obj/structure/grille/grille in A.loc)
			grille.obj_break()

		for (var/obj/structure/window/window in range(A, 2))
			window.take_damage(window.max_integrity * rand(20, 60) / 100)

		var/obj/structure/window/window = A
		window.deconstruct()
		ring.breaking = FALSE
		return TRUE

	ring.breaking = FALSE
