/obj/item/flash
	name = "flash"
	desc = "A powerful and versatile flashbulb device, with applications ranging from disorienting attackers to acting as visual receptors in robot production."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	item_state = "flashtool"	//looks exactly like a flash (and nothing like a flashbang)
	belt_icon = "flash"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	materials = list(MAT_METAL = 300, MAT_GLASS = 300)
	origin_tech = "magnets=2;combat=1"

	var/times_used = 0 //Number of times it's been used.
	var/broken = FALSE     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.
	var/battery_panel = FALSE //whether the flash can be modified with a cell or not
	var/overcharged = FALSE   //if overcharged the flash will set people on fire then immediately burn out (does so even if it doesn't blind them).
	var/can_overcharge = TRUE //set this to FALSE if you don't want your flash to be overcharge capable
	var/use_sound = 'sound/weapons/flash.ogg'
	/// This is the duration of the cooldown
	var/cooldown_duration = 1 SECONDS
	COOLDOWN_DECLARE(flash_cooldown)
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_WHITE


/obj/item/flash/update_icon_state()
	icon_state = "[initial(icon_state)][broken ? "burnt" : ""]"


/obj/item/flash/update_overlays()
	. = ..()
	if(overcharged)
		. += "overcharge"


/obj/item/flash/proc/clown_check(mob/user)
	if(user && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		flash_carbon(user, user, 30 SECONDS, 0)
		return FALSE
	return TRUE


/obj/item/flash/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!can_overcharge)
		to_chat(user, span_warning("This [name] has no panel!"))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	battery_panel = !battery_panel
	to_chat(user, span_notice("You [battery_panel ? "open" : "close"] the battery compartment on [src]."))


/obj/item/flash/attackby(obj/item/I, mob/user, params)
	if(!can_overcharge || !istype(I, /obj/item/stock_parts/cell))
		return ..()
	add_fingerprint(user)
	if(!battery_panel)
		to_chat(user, span_warning("You need to open the panel first!"))
		return ATTACK_CHAIN_PROCEED
	if(overcharged)
		to_chat(user, span_warning("The [name] is already overcharged!"))
		return ATTACK_CHAIN_PROCEED
	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()
	. = ATTACK_CHAIN_BLOCKED_ALL
	to_chat(user,  span_notice("You jam the cell into the battery compartment on [src]."))
	overcharged = TRUE
	update_icon(UPDATE_OVERLAYS)
	qdel(I)


/obj/item/flash/random/Initialize(mapload)
	. = ..()
	if(prob(25))
		broken = TRUE
		update_icon(UPDATE_ICON_STATE)


/obj/item/flash/proc/burn_out() //Made so you can override it if you want to have an invincible flash from R&D or something.
	broken = TRUE
	update_icon(UPDATE_ICON_STATE)
	visible_message("<span class='notice'>The [src.name] burns out!</span>")


/obj/item/flash/proc/flash_recharge(mob/user)
	if(prob(times_used * 2))	//if you use it 5 times in a minute it has a 10% chance to break!
		burn_out()
		return FALSE

	var/deciseconds_passed = world.time - last_used
	times_used -= round(deciseconds_passed / 100) //get 1 charge every 10 seconds

	last_used = world.time
	times_used = max(0, times_used) //sanity


/obj/item/flash/proc/try_use_flash(mob/user)

	if(broken)
		return FALSE
	if(!COOLDOWN_FINISHED(src, flash_cooldown))
		if(user)
			to_chat(user, "<span class='warning'>Your [name] is still too hot to use again!</span>")
		return FALSE
	COOLDOWN_START(src, flash_cooldown, cooldown_duration)
	flash_recharge(user)

	playsound(loc, use_sound, 100, 1)
	flick("[initial(icon_state)]2", src)
	set_light_on(TRUE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light_on), FALSE), 2)
	times_used++

	if(user && !clown_check(user))
		return FALSE

	return TRUE


/obj/item/flash/proc/flash_carbon(mob/living/carbon/M, mob/user, power = 10 SECONDS, targeted = TRUE)
	if(user)
		add_attack_logs(user, M, "Flashed with [src]")
		if(targeted)
			if(M.weakeyes)
				M.Weaken(6 SECONDS) //quick weaken bypasses eye protection but has no eye flash
			if(M.flash_eyes(1, TRUE))
				M.AdjustConfused(power)
				M.Stun(2 SECONDS)
				visible_message(span_disarm("[user] blinds [M] with the flash!"))
				to_chat(user, span_danger("You blind [M] with the flash!"))
				to_chat(M, span_userdanger("[user] blinds you with the flash!"))
				if(M.weakeyes)
					M.Stun(4 SECONDS)
					M.visible_message(span_disarm("[M] gasps and shields [M.p_their()] eyes!"), span_userdanger("You gasp and shield your eyes!"))
			else
				visible_message(span_disarm("[user] fails to blind [M] with the flash!"))
				to_chat(user, span_warning("You fail to blind [M] with the flash!"))
				to_chat(M, span_danger("[user] fails to blind you with the flash!"))
			return

	if(M.flash_eyes())
		M.AdjustConfused(power)


/obj/item/flash/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!try_use_flash(user))
		return .
	if(iscarbon(target))
		flash_carbon(target, user, 10 SECONDS, TRUE)
		if(overcharged)
			target.adjust_fire_stacks(6)
			target.IgniteMob()
			burn_out()
		return .|ATTACK_CHAIN_SUCCESS
	if(issilicon(target))
		add_attack_logs(user, target, "Flashed with [src]")
		if(target.flash_eyes(affect_silicon = TRUE))
			target.Weaken(rand(10 SECONDS, 20 SECONDS))
			user.visible_message(
				span_disarm("[user] overloads [target]'s sensors with the [name]!"),
				span_danger("You overload [target]'s sensors with the [name]!"),
			)
		return .|ATTACK_CHAIN_SUCCESS
	user.visible_message(
		span_disarm("[user] fails to blind [target] with the [name]!"),
		span_warning("You fail to blind [target] with the [name]!"),
	)


/obj/item/flash/attack_self(mob/living/carbon/user, flag = 0, emp = FALSE)
	if(!try_use_flash(user))
		return FALSE
	user.visible_message("<span class='disarm'>[user]'s [src.name] emits a blinding light!</span>", "<span class='danger'>Your [src.name] emits a blinding light!</span>")
	for(var/mob/living/carbon/M in oviewers(3, get_turf(src)))
		flash_carbon(M, user, 6 SECONDS, FALSE)


/obj/item/flash/emp_act(severity)
	if(!try_use_flash())
		return FALSE
	for(var/mob/living/carbon/M in viewers(3, get_turf(src)))
		flash_carbon(M, null, 20 SECONDS, FALSE)
	burn_out()
	..()

/obj/item/flash/cyborg
	origin_tech = null


/obj/item/flash/cyborg/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		new /obj/effect/temp_visual/borgflash(get_turf(src))


/obj/item/flash/cyborg/attack_self(mob/user)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/flash/cameraflash
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "electropack" //spelling, a coders worst enemy. This part gave me trouble for a while.
	belt_icon = null
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	can_overcharge = FALSE
	var/flash_max_charges = 5
	var/flash_cur_charges = 5
	var/charge_tick = 0
	use_sound = 'sound/items/polaroid1.ogg'

/obj/item/flash/cameraflash/burn_out() //stops from burning out
	return

/obj/item/flash/cameraflash/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/flash/cameraflash/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/flash/cameraflash/process() //this and the two parts above are part of the charge system.
	charge_tick++
	if(charge_tick < 10)
		return FALSE
	charge_tick = 0
	flash_cur_charges = min(flash_cur_charges+1, flash_max_charges)
	return TRUE

/obj/item/flash/cameraflash/try_use_flash(mob/user)
	if(!flash_cur_charges)
		if(user)
			to_chat(user, "<span class='warning'>[src] needs time to recharge!</span>")
		return FALSE
	. = ..()
	if(.)
		flash_cur_charges--
		if(user)
			to_chat(user, "[src] now has [flash_cur_charges] charge\s.")

/obj/item/flash/armimplant
	name = "photon projector"
	desc = "A high-powered photon projector implant normally used for lighting purposes, but also doubles as a flashbulb weapon. Self-repair protocols fix the flashbulb if it ever burns out."
	cooldown_duration = 2 SECONDS
	var/obj/item/organ/internal/cyberimp/arm/flash/I = null

/obj/item/flash/armimplant/Destroy()
	I = null
	return ..()

/obj/item/flash/armimplant/burn_out()
	if(I && I.owner)
		to_chat(I.owner, "<span class='warning'>Your [name] implant overheats and deactivates!</span>")
		I.Retract()

/obj/item/flash/synthetic //just a regular flash now
