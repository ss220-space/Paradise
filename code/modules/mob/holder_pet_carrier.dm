/obj/item/pet_carrier
	name = "Переноска"
	desc = "Переноска для маленьких животных. "
	icon_state = "pet_carrier"
	item_state = "sheet-titaniumglass"
	max_integrity = 100
	w_class = WEIGHT_CLASS_SMALL
	var/mob_size = MOB_SIZE_TINY

	var/opened = TRUE
	var/contains_pet = FALSE
	var/contains_pet_color_open = "#b6b6b6ff"
	var/contains_pet_color_close = "#5f5f5fff"

/obj/item/pet_carrier/Destroy()
	free_content()
	. = ..()

/obj/item/pet_carrier/attack_self(mob/user)
	..()
	change_state()

/obj/item/pet_carrier/AltClick(mob/user)
	if(ishuman(user) && Adjacent(user) && !user.incapacitated(FALSE, TRUE, TRUE))
		change_state()

/obj/item/pet_carrier/MouseDrop(obj/over_object)
	if(!opened)
		to_chat(usr, "<span class='warning'>Ваша переноска закрыта!</span>")
		return FALSE

	if(ishuman(usr))
		if((istype(over_object, /obj/structure/table) || istype(over_object, /turf/simulated/floor)) \
			&& contents.len && loc == usr && !usr.stat && !usr.restrained() && usr.canmove && over_object.Adjacent(usr))
			var/turf/T = get_turf(over_object)
			if(istype(over_object, /turf/simulated/floor))
				if(get_turf(usr) != T)
					return // Can only empty containers onto the floor under you
				if("Да" != alert(usr,"Вытащить питомца из [src.name] на [T]?","Подтверждение","Да","Нет"))
					return
				if(!(usr && over_object && contents.len && loc == usr && !usr.stat && !usr.restrained() && usr.canmove && get_turf(usr) == T))
					return // Something happened while the player was thinking

			usr.face_atom(over_object)
			usr.visible_message("<span class='notice'>[usr] вытащил питомца из [src.name] на [over_object].</span>",
				"<span class='notice'>Вы вытащили питомца из [src.name] на [over_object].</span>")
			free_content()
			return

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
	if(target.mob_size < mob_size)
		to_chat(user, "<span class='warning'>Ваша переноска слишком большая!</span>")
		return FALSE

	target.forceMove(src)
	name += " ([target.name])"
	if(target.desc)
		desc += "\n\nВнутри [target.name]\n"
		desc += target.desc
	contains_pet = TRUE

	to_chat(user, 	"<span class='notice'>Вы поместили [target.name] в [src.name].")
	to_chat(target, "<span class='notice'>[user.name] поместил[genderize_ru(user.gender,"","а","о","и")] вас в [src.name].</span>")
	update_icon()
	return TRUE

/obj/item/pet_carrier/proc/free_content()
	//if(istype(loc,/turf) || !(length(contents)))
	if(!(length(contents)))
		for(var/mob/M in contents)
			var/atom/movable/mob_container
			mob_container = M
			mob_container.forceMove(get_turf(src))
			contains_pet = FALSE
			name = initial(name)
			desc = initial(desc)
			update_icon()

/obj/item/pet_carrier/proc/change_state()
	opened = !opened
	update_icon()

/obj/item/pet_carrier/update_icon()
	overlays.Cut()
	if(contains_pet)
		var/mob/living/M
		for(var/mob/living/temp_M in contents)
			M = temp_M
			break
		var/image/I = image(M.icon, icon_state = M.icon_state)
		I.color = opened ? contains_pet_color_open : contains_pet_color_close
		I.pixel_y = M.mob_size <= MOB_SIZE_TINY ? 6 : 3
		overlays += I

	if(!opened)
		var/image/I = image(icon, icon_state = "[icon_state]_door")
		overlays += I

/obj/item/pet_carrier/emp_act(var/intensity)
	for(var/mob/living/M in contents)
		M.emp_act(intensity)

/obj/item/pet_carrier/ex_act(var/intensity)
	for(var/mob/living/M in contents)
		M.ex_act(intensity)

/obj/item/pet_carrier/container_resist(var/mob/living/L)
	var/breakout_time = 120 //2 minutes
	var/breakout_time_open = 5 //seconds for escape
	if(opened && L.loc == src)
		spawn(0)
			to_chat(L, "<span class='warning'>Вы начали вылезать из переноски (это займет [breakout_time_open] секунд)</span>")
			if(do_after(L,(breakout_time_open*10), target = src)) //seconds * 10deciseconds
				if(!src || !L || L.stat != CONSCIOUS || L.loc != src || !opened)
					return

				free_content()
				visible_message("<span class='warning'>[L.name] вылез из переноски.</span>")
		return

	to_chat(L, "<span class='warning'>Вы начали ломиться в закрытую дверцу переноски и пытаетесь её выбить или открыть. (это займет [breakout_time] секунд)</span>")
	for(var/mob/O in viewers(usr.loc))
		O.show_message("<span class='danger'>[src.name] начинает трястись!</span>", 1)

	spawn(0)
		if(do_after(L,(breakout_time*10), target = src)) //seconds * 10deciseconds
			if(!src || !L || L.stat != CONSCIOUS || L.loc != src || opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
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

/obj/item/pet_carrier/normal
	name = "Средняя переноска"
	desc = "Переноска для небольших животных. "
	icon_state = "pet_carrier_normal"
	item_state = "sheet-titaniumglass"
	max_integrity = 200
	w_class = WEIGHT_CLASS_NORMAL
	mob_size = MOB_SIZE_SMALL
