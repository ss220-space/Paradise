/obj/item/pet_carrier
	name = "маленькая переноска"
	desc = "Переноска для маленьких животных."
	icon_state = "pet_carrier"
	item_state = "pet_carrier"
	max_integrity = 100
	w_class = WEIGHT_CLASS_SMALL
	var/mob_size = MOB_SIZE_TINY

	var/list/possible_skins = list("black", "blue", "red", "yellow", "green", "purple")
	var/color_skin

	var/opened = TRUE
	var/mob/living/pet = null
	var/color_opened = "#D8D8D8"
	var/color_closed = "#949494"
	var/breakout_time = 60 SECONDS
	var/breakout_time_open = 5 SECONDS

/obj/item/pet_carrier/examine(mob/user)
	. = ..()
	if(pet)
		. += span_notice("Внутри [pet.name]")
		. += span_notice("[pet.desc]")
	. += span_info("Вы можете нажать <b>Alt-Click</b> чтобы опустошить переноску.")

/obj/item/pet_carrier/normal
	name = "переноска"
	desc = "Переноска для небольших животных."
	icon_state = "pet_carrier_normal"
	item_state = "pet_carrier_normal"
	max_integrity = 200
	w_class = WEIGHT_CLASS_NORMAL
	mob_size = MOB_SIZE_SMALL


/obj/item/pet_carrier/Initialize(mapload)
	. = ..()
	if(!color_skin)
		color_skin = pick(possible_skins)
	update_icon(UPDATE_OVERLAYS)


/obj/item/pet_carrier/Destroy()
	free_content()
	. = ..()

/obj/item/pet_carrier/attack_self(mob/user)
	..()
	change_state()


/obj/item/pet_carrier/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/holder))
		var/obj/item/holder/H = I
		for(var/mob/M in H.contents)
			if(put_in_carrier(M, user))
				qdel(H)
				return TRUE
		return FALSE
	. = ..()


/obj/item/pet_carrier/emp_act(intensity)
	. = ..()
	for(var/mob/living/M in contents)
		M.emp_act(intensity)


/obj/item/pet_carrier/ex_act(intensity)
	. = ..()
	for(var/mob/living/M in contents)
		M.ex_act(intensity)


/obj/item/pet_carrier/AltClick(mob/user)
	if(ishuman(user) && Adjacent(user) && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		try_free_content(null, user)


/obj/item/pet_carrier/proc/put_in_carrier(mob/living/target, mob/living/user)
	if(!opened)
		to_chat(user, span_warning("Ваша переноска закрыта!"))
		return FALSE
	if(pet)
		to_chat(user, span_warning("Ваша переноска заполнена!"))
		return FALSE
	if(target.mob_size > mob_size)
		to_chat(user, span_warning("Ваша переноска слишком мала!"))
		return FALSE
	if(istype(target, /mob/living/simple_animal/revenant))
		return FALSE

	target.forceMove(src)
	pet = target
	update_appearance(UPDATE_OVERLAYS)

	to_chat(user, span_notice("Вы поместили [target.name] в [name]."))
	to_chat(target, span_notice("[user.name] поместил[genderize_ru(user.gender,"","а","о","и")] вас в [name]."))
	return TRUE


/obj/item/pet_carrier/proc/free_content(atom/new_location, mob/user)
	add_fingerprint(user)
	if(!opened)
		if(user)
			to_chat(user, span_warning("Ваша переноска закрыта! Содержимое невозможно выгрузить!"))
		return FALSE
	if(!pet)
		return FALSE
	pet.forceMove(get_turf(new_location))
	pet.resting = FALSE
	pet = null
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/item/pet_carrier/proc/change_state()
	opened = !opened
	update_icon(UPDATE_OVERLAYS)


/obj/item/pet_carrier/update_overlays()
	. = ..()
	if(pet)
		var/mob/living/M
		for(var/mob/living/temp_M in contents)
			M = temp_M
			break
		var/image/I = image(M.icon, icon_state = M.icon_state)
		I.color = opened ? color_opened : color_closed
		I.pixel_y = M.mob_size <= MOB_SIZE_TINY ? 6 : 3
		. += I

	if(!opened)
		. += image(icon, icon_state = "[icon_state]_door")

	if(color_skin)
		. += image(icon, icon_state = "[icon_state]_[color_skin]")


/obj/item/pet_carrier/emp_act(intensity)
	for(var/mob/living/M in contents)
		M.emp_act(intensity)


/obj/item/pet_carrier/ex_act(intensity)
	for(var/mob/living/M in contents)
		M.ex_act(intensity)


/obj/item/pet_carrier/container_resist(mob/living/pet)
	var/atom/target_atom = src
	if(ishuman(loc))
		target_atom = loc

	if(opened && L.loc == src)
		spawn(0)
			if(do_after(L, (breakout_time_open), target_atom))
				if(!src || !L || L.stat != CONSCIOUS || L.loc != src || !opened)
					to_chat(L, span_warning("Побег прерван!"))
					return

		free_content(get_turf(target_atom))
		visible_message(span_warning("[pet.name] вылез из переноски."))
		return

	to_chat(L, span_warning("Вы начали ломиться в закрытую дверцу переноски и пытаетесь её выбить или открыть (это займет [breakout_time/10] секунд, не двигайтесь)."))
	for(var/mob/O in viewers(usr.loc))
		O.show_message(span_danger("[name] начинает трястись!"), 1)

	spawn(0)
		if(do_after(L, (breakout_time), target_atom))
			if(!src || !L || L.stat != CONSCIOUS || L.loc != src || opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
				to_chat(L, span_warning("Побег прерван!"))
				return

			var/mob/M = loc
			if(istype(M))
				to_chat(M, "[name] вырывается из вашей переноски!")
				to_chat(L, "Вы вырываетесь из переноски [M.name]!")
			else
				to_chat(L, "Вы выбираетесь из переноски.")

			//Free & open
			free_content()
			change_state()
		return

	var/mob/M = loc
	if(istype(M))
		to_chat(M, span_warning("[name] вырывается из вашей переноски!"))
	to_chat(pet, span_notice("Вы выбираетесь из переноски!"))

	//Free & open
	if(!opened)
		change_state()
	free_content(get_turf(target_atom))

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	change_state()


/obj/item/pet_carrier/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	user.face_atom(over_object)

	// Stops inventory actions in a mech, while ventcrawling and while being incapacitated
	if(ismecha(user.loc) || is_ventcrawling(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE

	if(over_object == user && user.Adjacent(src)) // this must come before the screen objects only block
		try_free_content(user = user)
		return FALSE

	if(opened && (istype(over_object, /obj/structure/table) || isfloorturf(over_object) \
		&& length(contents) && loc == user && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) && user.Adjacent(over_object)))

		if(alert(user, "Вытащить питомца из [name] на [over_object.name]?", "Подтверждение", "Да", "Нет") != "Да")
			return FALSE

		if(!opened || !user || !over_object || user.incapacitated() || loc != user || !user.Adjacent(over_object))
			return FALSE

		user.face_atom(over_object)
		user.visible_message(
			span_notice("[user] вытащил питомца из [name] на [over_object.name]."),
			span_notice("Вы вытащили питомца из [name] на [over_object.name]."),
		)
		try_free_content(get_turf(over_object), user)
		return FALSE

	return ..()

	user.visible_message(span_notice("[user] вытащил питомца из [name] на [over_object.name]."),
		span_notice("Вы вытащили питомца из [name] на [over_object.name]."))
