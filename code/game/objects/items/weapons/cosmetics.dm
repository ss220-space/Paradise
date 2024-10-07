/obj/item/lipstick
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick"
	w_class = WEIGHT_CLASS_TINY
	var/colour = "red"
	var/open = FALSE
	var/static/list/lipstick_colors

/obj/item/lipstick/Initialize(mapload)
	. = ..()
	if(!lipstick_colors)
		lipstick_colors = list(
			"black" = "#000000",
			"white" = "#FFFFFF",
			"red" = "#FF0000",
			"green" = "#00C000",
			"blue" = "#0000FF",
			"purple" = "#D55CD0",
			"jade" = "#216F43",
			"lime" = "#00FF00",
		)

/obj/item/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/lipstick/jade
	name = "jade lipstick"
	colour = "jade"

/obj/item/lipstick/lime
	name = "lime lipstick"
	colour = "lime"

/obj/item/lipstick/black
	name = "black lipstick"
	colour = "black"

/obj/item/lipstick/green
	name = "green lipstick"
	colour = "green"

/obj/item/lipstick/blue
	name = "blue lipstick"
	colour = "blue"

/obj/item/lipstick/white
	name = "white lipstick"
	colour = "white"

/obj/item/lipstick/random
	name = "lipstick"

/obj/item/lipstick/random/Initialize(mapload)
	. = ..()
	colour = pick(lipstick_colors)
	name = "[colour] lipstick"


/obj/item/lipstick/update_icon_state()
	. = ..()
	icon_state = "lipstick[open ? "_uncap" : ""]"


/obj/item/lipstick/update_overlays()
	. = ..()
	if(open)
		. += mutable_appearance(icon, icon_state = "lipstick_uncap_color", color = lipstick_colors[colour])


/obj/item/lipstick/attack_self(mob/user)
	user.balloon_alert(user, "колпачок [open ? "надет" : "снят"]")
	open = !open
	update_icon()


/obj/item/lipstick/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!open)
		return .

	if(!ishuman(target) || !target.get_organ(BODY_ZONE_HEAD))
		to_chat(user, span_notice("Where are the lips on that?"))
		return .


	if(target.lip_style)	// If they already have lipstick on
		to_chat(user, span_notice("You need to wipe off the old lipstick first!"))
		return .

	if(target == user)
		user.visible_message(
			span_notice("[user] does [user.p_their()] lips with [src]."),
			span_notice("You take a moment to apply [src]. Perfect!"),
		)
		target.lip_style = "lipstick"
		target.lip_color = lipstick_colors[colour]
		target.update_body()
		return .|ATTACK_CHAIN_SUCCESS

	user.visible_message(
		span_warning("[user] begins to do [target]'s lips with [src]."),
		span_notice("You begin to apply [src]."),
	)
	if(!do_after(user, 2 SECONDS, target))
		return .

	user.visible_message(
		span_notice("[user] does [target]'s lips with [src]."),
		span_notice("You apply [src] to [target]."),
	)
	target.lip_style = "lipstick"
	target.lip_color = lipstick_colors[colour]
	target.update_body()
	return .|ATTACK_CHAIN_SUCCESS


/obj/item/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items.dmi'
	icon_state = "razor"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	usesound = 'sound/items/welder2.ogg'
	toolspeed = 1


/obj/item/razor/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target) || (user.zone_selected != BODY_ZONE_PRECISE_MOUTH && user.zone_selected != BODY_ZONE_HEAD))
		return ..()

	var/obj/item/organ/external/head/head = target.get_organ(BODY_ZONE_HEAD)
	if(!head)
		return ..()

	. = ATTACK_CHAIN_PROCEED
	var/datum/robolimb/robohead = GLOB.all_robolimbs[head.model]
	if(user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
			to_chat(user, span_warning("The mask is in the way."))
			return .
		//If the target is of a species that can have prosthetic heads, but the head doesn't support human hair 'wigs'...
		if((head.dna.species.bodyflags & ALL_RPARTS) && robohead?.is_monitor)
			to_chat(user, span_warning("You find yourself disappointed at the appalling lack of facial hair."))
			return .
		if(head.f_style == "Shaved")
			to_chat(user, span_notice("Already clean-shaven."))
			return .
		if(target == user) //shaving yourself
			user.visible_message(
				span_notice("[user] starts to shave [user.p_their()] facial hair with [src]."),
				span_notice("You take a moment shave your facial hair with [src]."),
			)
			if(!do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL) || QDELETED(head))
				return .
			user.visible_message(
				span_notice(">[user] shaves [user.p_their()] facial hair clean with [src]."),
				span_notice("You finish shaving with [src]. Fast and clean!"),
			)
			head.f_style = "Shaved"
			target.update_fhair()
			playsound(loc, usesound, 20, TRUE)
			return .|ATTACK_CHAIN_SUCCESS

		user.visible_message(
			span_danger("[user] tries to shave [target]'s facial hair with [src]."),
			span_warning("You start shaving [target]'s facial hair."),
		)
		if(!do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL) || QDELETED(head))
			return .
		user.visible_message(
			span_danger("[user] shaves off [target]'s facial hair with [src]."),
			span_notice("You shave [target]'s facial hair clean off."),
		)
		head.f_style = "Shaved"
		target.update_fhair()
		playsound(loc, usesound, 20, TRUE)
		return .|ATTACK_CHAIN_SUCCESS

	if(!get_location_accessible(target, BODY_ZONE_HEAD))
		to_chat(user, span_warning("The headgear is in the way."))
		return .

	if((head.dna.species.bodyflags & ALL_RPARTS) && robohead?.is_monitor)
		to_chat(user, span_warning("You find yourself disappointed at the appalling lack of hair."))
		return .
	if(head.h_style == "Bald" || head.h_style == "Balding Hair" || head.h_style == "Skinhead")
		to_chat(user, span_notice("There is not enough hair left to shave..."))
		return .
	if(isskrell(target))
		to_chat(user, span_warning("Your razor isn't going to cut through tentacles."))
		return .
	if(target == user)
		user.visible_message(
			span_warning("[user] starts to shave [user.p_their()] head with [src]."),
			span_warning("You start to shave your head with [src]."),
		)
		if(!do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL) || QDELETED(head))
			return .
		user.visible_message(
			span_notice("[user] shaves [user.p_their()] head with [src]."),
			span_notice("You finish shaving with [src]."),
		)
		head.h_style = "Skinhead"
		target.update_hair()
		playsound(loc, usesound, 40, TRUE)
		return .|ATTACK_CHAIN_SUCCESS

	user.visible_message(
		span_danger("[user] tries to shave [target]'s head with [src]!"),
		span_warning("You start shaving [target]'s head."),
	)
	if(!do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL) || QDELETED(head))
		return .
	user.visible_message(
		span_danger("[user] shaves [target]'s head bald with [src]!"),
		span_warning("You shave [target]'s head bald."),
	)
	head.h_style = "Skinhead"
	target.update_hair()
	playsound(loc, usesound, 40, TRUE)
	return .|ATTACK_CHAIN_SUCCESS

