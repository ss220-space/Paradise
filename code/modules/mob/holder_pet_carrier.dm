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
	if(!Adjacent(user) || user.incapacitated() || !ishuman(user))
		return
	free_content(get_turf(user), user)


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

	if(opened)
		to_chat(pet, span_warning("Вы начали вылезать из переноски. Это займет [breakout_time_open/10] секунд."))
		if(!do_after(pet, breakout_time_open, target = target_atom) || !pet)
			return
		if(!src || pet.stat || pet.loc != src || !opened)
			to_chat(pet, span_warning("Побег прерван!"))
			return

		free_content(get_turf(target_atom))
		visible_message(span_warning("[pet.name] вылез из переноски."))
		return

	to_chat(pet, span_warning("Вы начали ломиться в закрытую дверцу переноски и пытаетесь её выбить или открыть. Это займет [breakout_time/10] секунд."))
	visible_message(span_danger("[name] начинает трястись!"))
	if(!do_after(pet, breakout_time, target = target_atom) || !pet)
		return
	if(!src || pet.stat || pet.loc != src || opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
		to_chat(pet, span_warning("Побег прерван!"))
		return

	var/mob/M = loc
	if(istype(M))
		to_chat(M, span_warning("[name] вырывается из вашей переноски!"))
	to_chat(pet, span_notice("Вы выбираетесь из переноски!"))

	//Free & open
	if(!opened)
		change_state()
	free_content(get_turf(target_atom))

/obj/item/pet_carrier/MouseDrop(obj/over_object)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	user.face_atom(over_object)

	if(!isturf(user.loc) || user.incapacitated()|| !Adjacent(user) || !over_object.Adjacent(user))
		return
	if(!istype(over_object, /obj/structure/table) && !isfloorturf(over_object))
		return
	if(!pet)
		to_chat(user, span_warning("Переноска пуста!"))
		return
	if(loc != user)
		to_chat(user, span_warning("Вы должны держать переноску чтобы достать питомца!"))
		return
	if(!free_content(over_object, user))
		return

	user.visible_message(span_notice("[user] вытащил питомца из [name] на [over_object.name]."),
		span_notice("Вы вытащили питомца из [name] на [over_object.name]."))
