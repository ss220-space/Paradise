#define CARBON 1
#define SILICON 2
#define CAMERA 3
/obj/item/holosign_creator/signmarer
	name = "Signmarer Clown"
	desc = "A handy-dandy holographic projector"
	icon_state = "signmarer_clown_off"
	item_state = "signmarer_clown"
	holosign_type = /obj/structure/holosign/soap

	var/obj/structure/holosign/sign
	var/emag = FALSE
	var/recharging = 0
	var/recharge_locked = 0

/obj/item/holosign_creator/signmarer/update_icon()
	if(sign)
		icon_state = "signmarer_clown_on"
	else
		icon_state = "signmarer_clown_off"

/obj/item/holosign_creator/signmarer/attack(mob/living/M, mob/user)
	icon_state = "signmarer_clown_on"
	laser_act(M, user)

/obj/item/holosign_creator/signmarer/emag_act()
	to_chat(usr, "You broke the pointer, oh no")
	holosign_type = /obj/structure/holosign/soap/soap_emag

/obj/item/holosign_creator/signmarer/attack_self(mob/user)
	qdel(sign)
	sign = null
	to_chat(user, "<span class='notice'>You clear active hologram.</span>")
	update_icon()

/obj/item/holosign_creator/signmarer/afterattack(var/atom/target, var/mob/living/user, params)
	icon_state = "signmarer_clown_on"
	laser_act(target, user, params)

/obj/item/holosign_creator/signmarer/proc/laser_act(var/atom/target, var/mob/living/user, var/params)
	if( !(user in (viewers(7,target))) )
		return
	add_fingerprint(user)

	//nothing happens if the battery is drained
	if(recharge_locked)
		to_chat(user, "<span class='notice'>You point [src] at [target], but it's still charging.</span>")
		return

	var/target_type = 0

	if(iscarbon(target))
		target_type = CARBON
	if(issilicon(target))
		target_type = SILICON
	if(istype(target, /obj/machinery/camera))
		target_type = CAMERA

	switch(target_type)
		if(CARBON)
			var/mob/living/carbon/C = target
			if(user.zone_selected == "eyes")
				add_attack_logs(user, C, "Shone a laser in the eyes with [src]")
			//20% chance to actually hit the eyes
			if(prob(20))
				visible_message("<span class='notice'>You blind [C] by shining [src] in [C.p_their()] eyes.</span>")
				if(C.weakeyes)
					C.Stun(1)
			else
				visible_message("<span class='warning'>You fail to blind [C] by shining [src] at [C.p_their()] eyes!</span>")
		if(SILICON)
			var/mob/living/silicon/S = target
			//20% chance to actually hit the sensors
			if(prob(20))
				S.flash_eyes(affect_silicon = 1)
				S.Weaken(rand(5,10))
				to_chat(S, "<span class='warning'>Your sensors were overloaded by a laser!</span>")
				visible_message("<span class='notice'>You overload [S] by shining [src] at [S.p_their()] sensors.</span>")

				add_attack_logs(user, S, "shone [src] in their eyes")
			else
				visible_message("<span class='notice'>You fail to overload [S] by shining [src] at [S.p_their()] sensors.</span>")
		if(CAMERA)
			var/obj/machinery/camera/C = target
			if(prob(20))
				C.emp_act(1)
				visible_message("<span class='notice'>You hit the lens of [C] with [src], temporarily disabling the camera!</span>")

				log_admin("[key_name(user)] EMPd a camera with a laser pointer")
				user.create_attack_log("[key_name(user)] EMPd a camera with a laser pointer")
				add_attack_logs(user, C, "EMPd with [src]", ATKLOG_ALL)
			else
				visible_message("<span class='info'>You missed the lens of [C] with [src].</span>")

		else
			create_holosign(target, user)
	update_icon()

/obj/item/holosign_creator/signmarer/proc/create_holosign(atom/target, mob/user)
	var/obj/structure/holosign/H = locate(holosign_type) in target
	if(locate(holosign_type) in target)
		to_chat(user, "<span class='notice'>You use [src] to deactivate [sign].</span>")
		qdel(sign)
		sign = null
		update_icon()
		return
	var/turf/T = get_turf(target)
	if(is_blocked_turf(T, TRUE)) //can't put holograms on a tile that has dense stuff
		return
	playsound(src, 'sound/machines/click.ogg', 20, 1)
	if(sign)
		qdel(sign)
		sign = null
	sign = new holosign_type(get_turf(target), src)
	to_chat(user, "<span class='notice'>You create [H] with [src].</span>")

/obj/structure/holosign/soap
	name = "holographic soap"
	desc = "looks like a real soap, but it's not."
	icon_state = "holo_soap"
	density = FALSE
	layer = ABOVE_MOB_LAYER
	anchored = TRUE

/obj/structure/holosign/soap/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/items/squeaktoy.ogg', 80, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/squeaktoy.ogg', 80, TRUE)

/obj/structure/holosign/soap/Crossed(atom/movable/AM, oldloc)
	playsound(loc, 'sound/misc/slip.ogg', 80, TRUE)
	. = ..()

/obj/structure/holosign/soap/soap_emag
	name = "solid holographic soap"
	desc = "looks like a real soap, but it's blocking your path now."
	density = TRUE

#undef CARBON
#undef SILICON
#undef CAMERA
