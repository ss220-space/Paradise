/**********************Mining Scanner**********************/
/obj/item/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results. \nIt has a speaker that can be toggled with <b>alt+click</b>"
	name = "manual mining scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "miningmanual"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	var/cooldown = 35
	var/current_cooldown = 0
	var/speaker = TRUE // Speaker that plays a sound when pulsed.
	var/soundone = 'sound/lavaland/area_scan1.ogg'
	var/soundtwo = 'sound/lavaland/area_scan2.ogg'

	origin_tech = "engineering=1;magnets=1"

/obj/item/mining_scanner/AltClick(mob/user)
	if(!Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	speaker = !speaker
	to_chat(user, "<span class='notice'>You toggle [src]'s speaker to [speaker ? "<b>ON</b>" : "<b>OFF</b>"].</span>")

/obj/item/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		mineral_scan_pulse(get_turf(user), 5)
		if(speaker)
			playsound(src, pick(soundone, soundtwo), 35)


//Debug item to identify all ore spread quickly
/obj/item/mining_scanner/admin

/obj/item/mining_scanner/admin/attack_self(mob/user)
	for(var/turf/simulated/mineral/M in world)
		if(M.scan_state)
			M.icon_state = M.scan_state
	qdel(src)

/obj/item/t_scanner/adv_mining_scanner
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results. This one has an extended range. \nIt has a speaker that can be toggled with <b>alt+click</b>"
	name = "advanced automatic mining scanner"
	icon_state = "adv_mining0"
	base_icon_state = "adv_mining"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	var/cooldown = 1 SECONDS
	var/current_cooldown = 0
	var/range = 9
	var/speaker = TRUE // Speaker that plays a sound when pulsed.
	var/soundone = 'sound/lavaland/area_scan1.ogg'
	var/soundtwo = 'sound/lavaland/area_scan2.ogg'

	origin_tech = "engineering=3;magnets=3"

/obj/item/t_scanner/adv_mining_scanner/AltClick(mob/user)
	if(!Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	speaker = !speaker
	to_chat(user, "<span class='notice'>You toggle [src]'s speaker to [speaker ? "<b>ON</b>" : "<b>OFF</b>"].</span>")

/obj/item/t_scanner/adv_mining_scanner/cyborg
	flags = CONDUCT
	speaker = FALSE //you know...


/obj/item/t_scanner/adv_mining_scanner/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)


/obj/item/t_scanner/adv_mining_scanner/lesser
	name = "automatic mining scanner"
	icon_state = "mining0"
	base_icon_state = "mining"
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results. \nIt has a speaker that can be toggled with <b>alt+click</b>"
	range = 4
	cooldown = 50

/obj/item/mining_scanner/cyborg
	cooldown = 50
	flags = CONDUCT
	speaker = FALSE


/obj/item/mining_scanner/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)


/obj/item/t_scanner/adv_mining_scanner/scan()
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		var/turf/t = get_turf(src)
		mineral_scan_pulse(t, range)
		if(speaker)
			playsound(src, pick(soundone, soundtwo), 35)

/proc/mineral_scan_pulse(turf/T, range = world.view)
	var/list/minerals = list()
	for(var/turf/simulated/mineral/M in range(range, T))
		if(M.scan_state)
			minerals += M
	if(LAZYLEN(minerals))
		for(var/turf/simulated/mineral/M in minerals)
			var/obj/effect/temp_visual/mining_overlay/oldC = locate(/obj/effect/temp_visual/mining_overlay) in M
			if(oldC)
				qdel(oldC)
			var/obj/effect/temp_visual/mining_overlay/C = new /obj/effect/temp_visual/mining_overlay(M)
			C.icon_state = M.scan_state

/obj/effect/temp_visual/mining_overlay
	plane = FULLSCREEN_PLANE
	layer = FLASH_LAYER
	icon = 'icons/effects/ore_visuals.dmi'
	appearance_flags = LONG_GLIDE //to avoid having TILE_BOUND in the flags, so that the 480x480 icon states let you see it no matter where you are
	duration = 35
	pixel_x = -224
	pixel_y = -224

/obj/effect/temp_visual/mining_overlay/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = EASE_IN)
