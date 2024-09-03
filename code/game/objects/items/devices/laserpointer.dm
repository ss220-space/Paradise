/obj/item/laser_pointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	icon = 'icons/obj/device.dmi'
	icon_state = "pointer"
	item_state = "pen"
	var/pointer_icon_state
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=500, MAT_GLASS=500)
	w_class = WEIGHT_CLASS_SMALL //Increased to 2, because diodes are w_class 2. Conservation of matter.
	origin_tech = "combat=1;magnets=2"
	var/energy = 5
	var/max_energy = 5
	var/effectchance = 33
	var/recharging = 0
	var/recharge_locked = 0
	var/obj/item/stock_parts/micro_laser/diode //used for upgrading!
	var/is_pointing = FALSE


/obj/item/laser_pointer/red
	pointer_icon_state = "red_laser"
/obj/item/laser_pointer/green
	pointer_icon_state = "green_laser"
/obj/item/laser_pointer/blue
	pointer_icon_state = "blue_laser"
/obj/item/laser_pointer/purple
	pointer_icon_state = "purple_laser"

/obj/item/laser_pointer/New()
	..()
	diode = new(src)
	if(!pointer_icon_state)
		pointer_icon_state = pick("red_laser","green_laser","blue_laser","purple_laser")

/obj/item/laser_pointer/Destroy()
	QDEL_NULL(diode)
	return ..()

/obj/item/laser_pointer/upgraded/New()
	..()
	diode = new /obj/item/stock_parts/micro_laser/ultra


/obj/item/laser_pointer/update_icon_state()
	icon_state = "pointer[is_pointing ? "_[pointer_icon_state]" : ""]"


/obj/item/laser_pointer/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(laser_act(target, user))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ATTACK_CHAIN_PROCEED


/obj/item/laser_pointer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/micro_laser))
		add_fingerprint(user)
		if(diode)
			user.balloon_alert(user, "уже установлено!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		diode = I
		user.balloon_alert(user, "установлено")
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/laser_pointer/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(diode)
		user.balloon_alert(user, "микролазер извлечён")
		diode.forceMove(get_turf(loc))
		diode = null

/obj/item/laser_pointer/afterattack(atom/target, mob/living/user, flag, params)
	if(flag)	//we're placing the object on a table or in backpack
		return
	laser_act(target, user, params)

/obj/item/laser_pointer/proc/laser_act(atom/target, mob/living/user, params)
	if(!(user in (viewers(7,target))) )
		return FALSE
	if(!diode)
		user.balloon_alert(user, "не функционирует!")
		return FALSE
	if(!user.IsAdvancedToolUser())
		user.balloon_alert(user, "вы недостаточно ловки!")
		return FALSE
	add_fingerprint(user)

	//nothing happens if the battery is drained
	if(recharge_locked)
		user.balloon_alert(user, "идёт перезарядка")
		return FALSE

	. = TRUE
	var/outmsg
	var/turf/targloc = get_turf(target)

	//human/alien mobs
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(user.zone_selected == BODY_ZONE_PRECISE_EYES)
			add_attack_logs(user, C, "Shone a laser in the eyes with [src]")

			//20% chance to actually hit the eyes
			if(prob(effectchance * diode.rating) && C.flash_eyes(intensity = rand(0, 2)))
				outmsg = span_notice("You blind [C] by shining [src] in [C.p_their()] eyes.")
				if(C.weakeyes)
					C.Stun(2 SECONDS)
			else
				outmsg = span_warning("You fail to blind [C] by shining [src] at [C.p_their()] eyes!")

	//robots and AI
	else if(issilicon(target))
		var/mob/living/silicon/S = target
		//20% chance to actually hit the sensors
		if(prob(effectchance * diode.rating) && S.flash_eyes(affect_silicon = TRUE))
			S.Weaken(rand(10 SECONDS, 20 SECONDS))
			to_chat(S, span_warning("Your sensors were overloaded by a [src]!"))
			outmsg = span_notice("You overload [S] by shining [src] at [S.p_their()] sensors.")

			add_attack_logs(user, S, "shone [src] in their eyes")
		else
			outmsg = span_notice("You fail to overload [S] by shining [src] at [S.p_their()] sensors.")

	//cameras
	else if(istype(target, /obj/machinery/camera))
		var/obj/machinery/camera/C = target
		if(prob(effectchance * diode.rating))
			C.emp_act(1)
			outmsg = span_notice("You hit the lens of [C] with [src], temporarily disabling the camera!")

			log_admin("[key_name(user)] EMPd a camera with a laser pointer")
			add_attack_logs(user, C, "EMPd with [src]", ATKLOG_ALL)
		else
			outmsg = span_info("You missed the lens of [C] with [src].")

	//laser pointer image
	is_pointing = TRUE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(stop_pointing)), 1 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT)
	var/image/I = image('icons/obj/weapons/projectiles.dmi',targloc,pointer_icon_state,10)
	var/list/click_params = params2list(params)
	if(click_params)
		if(click_params["icon-x"])
			I.pixel_x = (text2num(click_params["icon-x"]) - 16)
		if(click_params["icon-y"])
			I.pixel_y = (text2num(click_params["icon-y"]) - 16)
	else
		I.pixel_x = target.pixel_x + rand(-5,5)
		I.pixel_y = target.pixel_y + rand(-5,5)

	if(outmsg)
		to_chat(user, outmsg)
	else
		to_chat(user, "<span class='info'>You point [src] at [target].</span>")

	energy -= 1
	if(energy <= max_energy)
		if(!recharging)
			recharging = 1
			START_PROCESSING(SSobj, src)
		if(energy <= 0)
			to_chat(user, "<span class='warning'>You've overused the battery of [src], now it needs time to recharge!</span>")
			recharge_locked = 1

	flick_overlay_view(I, 1 SECONDS)


/obj/item/laser_pointer/proc/stop_pointing()
	is_pointing = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/item/laser_pointer/process()
	if(prob(20 - recharge_locked*5))
		energy += 1
		if(energy >= max_energy)
			energy = max_energy
			recharging = 0
			recharge_locked = 0
			..()
