/obj/item/pet_carrier
	name = "маленькая переноска"
	desc = "Переноска для маленьких животных. "
	icon_state = "pet_carrier"
	item_state = "pet_carrier"
	max_integrity = 100
	w_class = WEIGHT_CLASS_SMALL
	var/mob_size = MOB_SIZE_TINY

	var/list/possible_skins = list("black", "blue", "red", "yellow", "green", "purple")
	var/color_skin

	var/opened = TRUE
	var/contains_pet = FALSE
	var/contains_pet_color_open = "#d8d8d8ff"
	var/contains_pet_color_close = "#949494ff"

/obj/item/pet_carrier/normal
	name = "переноска"
	desc = "Переноска для небольших животных. "
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

/obj/item/pet_carrier/emp_act(var/intensity)
	for(var/mob/living/M in contents)
		M.emp_act(intensity)

/obj/item/pet_carrier/ex_act(var/intensity)
	for(var/mob/living/M in contents)
		M.ex_act(intensity)

/obj/item/pet_carrier/AltClick(mob/user)
	if(ishuman(user) && Adjacent(user) && !user.incapacitated(FALSE, TRUE, TRUE))
		try_free_content(user = user)

/obj/item/pet_carrier/proc/put_in_carrier(var/mob/living/target, var/mob/living/user)
	if(!opened)
		to_chat(user, "<span class='warning'>Ваша переноска закрыта!</span>")
		return FALSE
	if(contains_pet)
		to_chat(user, "<span class='warning'>Ваша переноска заполнена!</span>")
		return FALSE
	if(target.mob_size > mob_size)
		to_chat(user, "<span class='warning'>Ваша переноска слишком мала!</span>")
		return FALSE
	if(istype(target, /mob/living/simple_animal/revenant))
		return FALSE
	//if(target.mob_size < mob_size)
	//	to_chat(user, "<span class='warning'>Ваша переноска слишком большая!</span>")
	//	return FALSE

	target.forceMove(src)
	contains_pet = TRUE
	update_appearance(UPDATE_OVERLAYS|UPDATE_NAME|UPDATE_DESC)

	to_chat(user, 	"<span class='notice'>Вы поместили [target.name] в [src.name].")
	to_chat(target, "<span class='notice'>[user.name] поместил[genderize_ru(user.gender,"","а","о","и")] вас в [src.name].</span>")
	return TRUE

/obj/item/pet_carrier/proc/try_free_content(atom/new_location, mob/user)
	add_fingerprint(user)
	if(!opened)
		if(user)
			to_chat(user, "<span class='warning'>Ваша переноска закрыта! Содержимое невозможно выгрузить!</span>")
		return FALSE
	free_content(new_location)

/obj/item/pet_carrier/proc/free_content(atom/new_location)
	if(istype(loc,/turf) || length(contents))
		for(var/mob/living/L in contents)
			var/atom/movable/mob_container
			mob_container = L
			mob_container.forceMove(new_location ? new_location : get_turf(src))
			contains_pet = FALSE
			update_appearance(UPDATE_OVERLAYS|UPDATE_NAME|UPDATE_DESC)
			L.resting = FALSE
		return TRUE
	return FALSE

/obj/item/pet_carrier/proc/change_state()
	opened = !opened
	update_icon(UPDATE_OVERLAYS)


/obj/item/pet_carrier/update_name(updates = ALL)
	. = ..()
	name = initial(name)
	var/mob/living/animal = locate() in src
	if(animal)
		name += " ([animal.name])"


/obj/item/pet_carrier/update_desc(updates = ALL)
	. = ..()
	desc = initial(desc)
	var/mob/living/animal = locate() in src
	if(animal)
		desc += "\n\nВнутри [animal.name]\n"
		desc += animal.desc


/obj/item/pet_carrier/update_overlays()
	. = ..()
	if(contains_pet)
		var/mob/living/M
		for(var/mob/living/temp_M in contents)
			M = temp_M
			break
		var/image/I = image(M.icon, icon_state = M.icon_state)
		I.color = opened ? contains_pet_color_open : contains_pet_color_close
		I.pixel_y = M.mob_size <= MOB_SIZE_TINY ? 6 : 3
		. += I

	if(!opened)
		var/image/I = image(icon, icon_state = "[icon_state]_door")
		. += I

	if(color_skin)
		var/image/I = image(icon, icon_state = "[icon_state]_[color_skin]")
		. += I


/obj/item/pet_carrier/emp_act(var/intensity)
	for(var/mob/living/M in contents)
		M.emp_act(intensity)

/obj/item/pet_carrier/ex_act(var/intensity)
	for(var/mob/living/M in contents)
		M.ex_act(intensity)

/obj/item/pet_carrier/container_resist(var/mob/living/L)
	var/breakout_time = 60 //1 minute
	var/breakout_time_open = 5 //seconds for escape
	var/dcsec = 10 //seconds * 10deciseconds

	to_chat(L, "<span class='warning'>Вы начали вылезать из переноски (это займет [breakout_time_open] секунд, не двигайтесь)</span>")

	var/atom/target_atom = src
	if(ishuman(src.loc))
		target_atom = src.loc

	if(opened && L.loc == src)
		spawn(0)
			if(do_after(L,(breakout_time_open*dcsec), target = target_atom))
				if(!src || !L || L.stat != CONSCIOUS || L.loc != src || !opened)
					to_chat(L, "<span class='warning'>Побег прерван!</span>")
					return

				free_content()
				visible_message("<span class='warning'>[L.name] вылез из переноски.</span>")
		return

	to_chat(L, "<span class='warning'>Вы начали ломиться в закрытую дверцу переноски и пытаетесь её выбить или открыть. (это займет [breakout_time] секунд, не двигайтесь)</span>")
	for(var/mob/O in viewers(usr.loc))
		O.show_message("<span class='danger'>[src.name] начинает трястись!</span>", 1)

	spawn(0)
		if(do_after(L,(breakout_time*dcsec), target = target_atom))
			if(!src || !L || L.stat != CONSCIOUS || L.loc != src || opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
				to_chat(L, "<span class='warning'>Побег прерван!</span>")
				return

			var/mob/M = src.loc
			if(istype(M))
				to_chat(M, "[src.name] вырывается из вашей переноски!")
				to_chat(L, "Вы вырываетесь из переноски [M.name]!")
			else
				to_chat(L, "Вы выбираетесь из переноски.")

			//Free & open
			free_content()
			change_state()
		return

/obj/item/pet_carrier/verb/open_close()
	set name = "Открыть/закрыть переноску"
	set desc = "Меняет состояние дверцы переноски, блокируя или разблокируя возможность достать содержимое."
	set category = "Object"

	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return

	change_state()

/obj/item/pet_carrier/verb/unload_content()
	set name = "Опустошить переноску"
	set desc = "Вытаскивает животное из переноски."
	set category = "Object"

	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return

	try_free_content(user = usr)


/obj/item/pet_carrier/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(!ishuman(usr))
		return FALSE

	var/mob/living/carbon/human/user = usr

	// Stops inventory actions in a mech, while ventcrawling and while being incapacitated
	if(ismecha(user.loc) || is_ventcrawling(user) || user.incapacitated(FALSE, TRUE, TRUE))
		return FALSE

	if(over_object == user && user.Adjacent(src)) // this must come before the screen objects only block
		try_free_content(user = user)
		return FALSE

	if(opened && (istype(over_object, /obj/structure/table) || istype(over_object, /turf/simulated/floor) \
		&& length(contents) && loc == user && !user.incapacitated() && user.Adjacent(over_object)))

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

