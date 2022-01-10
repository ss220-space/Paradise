/obj/item/holosign_creator/signmarer
	name = "Signmarer Clown"
	desc = "A handy-dandy holographic projector"
	icon_state = "signmarer_clown_off"
	item_state = "signmarer_clown"
	holosign_type = /obj/structure/holosign/soap
	creation_time = 30
	max_signs = 1

	var/energy = 5
	var/max_energy = 5
	var/effectchance = 33
	var/recharging = 0
	var/recharge_locked = 0

/obj/item/holosign_creator/signmarer/attack(mob/living/M, mob/user)
	laser_act(M, user)
	icon_state = "signmarer_clown_on"

/obj/item/holosign_creator/signmarer/attack_self(mob/user)
	if(signs.len)
		for(var/H in signs)
			qdel(H)
		to_chat(user, "<span class='notice'>You clear all active holograms.</span>")
		icon_state = "signmarer_clown_off"

/obj/item/holosign_creator/signmarer/afterattack()
	if(!signs)
		icon_state = "signmarer_clown_off"

/obj/item/holosign_creator/signmarer/proc/laser_act(var/atom/target, var/mob/living/user, var/params)
	if( !(user in (viewers(7,target))) )
		return
	add_fingerprint(user)

	//nothing happens if the battery is drained
	if(recharge_locked)
		to_chat(user, "<span class='notice'>You point [src] at [target], but it's still charging.</span>")
		return

	var/outmsg
	var/turf/targloc = get_turf(target)

	//human/alien mobs
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(user.zone_selected == "eyes")
			add_attack_logs(user, C, "Shone a laser in the eyes with [src]")

			var/severity = 1
			if(prob(33))
				severity = 2
			else if(prob(50))
				severity = 0

			//20% chance to actually hit the eyes
			if(prob(20))
				outmsg = "<span class='notice'>You blind [C] by shining [src] in [C.p_their()] eyes.</span>"
				if(C.weakeyes)
					C.Stun(1)
			else
				outmsg = "<span class='warning'>You fail to blind [C] by shining [src] at [C.p_their()] eyes!</span>"

	//robots and AI
	if(issilicon(target))
		var/mob/living/silicon/S = target
		//20% chance to actually hit the sensors
		if(prob(20)
			S.flash_eyes(affect_silicon = 1)
			S.Weaken(rand(5,10))
			to_chat(S, "<span class='warning'>Your sensors were overloaded by a laser!</span>")
			outmsg = "<span class='notice'>You overload [S] by shining [src] at [S.p_their()] sensors.</span>"

			add_attack_logs(user, S, "shone [src] in their eyes")
		else
			outmsg = "<span class='notice'>You fail to overload [S] by shining [src] at [S.p_their()] sensors.</span>"

	//cameras
	if(istype(target, /obj/machinery/camera))
		var/obj/machinery/camera/C = target
		if(prob(20))
			C.emp_act(1)
			outmsg = "<span class='notice'>You hit the lens of [C] with [src], temporarily disabling the camera!</span>"

			log_admin("[key_name(user)] EMPd a camera with a laser pointer")
			user.create_attack_log("[key_name(user)] EMPd a camera with a laser pointer")
			add_attack_logs(user, C, "EMPd with [src]", ATKLOG_ALL)
		else
			outmsg = "<span class='info'>You missed the lens of [C] with [src].</span>"

	if(isturf(target))
		create_holosign(target, user)

	energy -= 1
	if(energy <= max_energy)
		if(!recharging)
			recharging = 1
			START_PROCESSING(SSobj, src)
		if(energy <= 0)
			to_chat(user, "<span class='warning'>You've overused the battery of [src], now it needs time to recharge!</span>")
			recharge_locked = 1

	icon_state = "pointer"

/obj/item/holosign_creator/signmarer/proc/create_holosign(atom/target, mob/user)
	var/obj/structure/holosign/H = locate(holosign_type) in target
	if(H)
		to_chat(user, "<span class='notice'>You use [src] to deactivate [H].</span>")
		qdel(H)
		return
	if(is_blocked_turf(target, TRUE)) //can't put holograms on a tile that has dense stuff
		return
	if(signs.len <= max_signs)
		playsound(src.loc, 'sound/machines/click.ogg', 20, 1)
			if(signs.len() == max_signs)
				for(var/Q = 0 in signs)
					qdel(Q)
			if(is_blocked_turf(T, TRUE)) //don't try to sneak dense stuff on our tile during the wait.
				return
		H = new holosign_type(get_turf(target), src)
		to_chat(user, "<span class='notice'>You create [H] with [src].</span>")

/obj/item/holosign_creator/signmarer/process()
	if(prob(20 - recharge_locked*5))
		energy += 1
		if(energy >= max_energy)
			energy = max_energy
			recharging = 0
			recharge_locked = 0
			..()

/obj/structure/holosign/soap
	name = "holographic soap"
	desc = "looks like a real soap, but it's not."
	icon_state = "holo_soap"
	density = FALSE
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
