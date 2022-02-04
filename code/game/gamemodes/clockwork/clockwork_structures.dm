/obj/structure/clockwork
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/clockwork.dmi'

/obj/structure/clockwork/beacon
	name = "herald's beacon"
	desc = "An imposing spire formed of brass. It somewhat pulsates."
	icon_state = "beacon"

/obj/structure/clockwork/altar
	name = "credence"
	desc = "A strange brass platform with spinning cogs inside. It demands somethinge in exchange for goods..."
	icon_state = "altar"
	density = 0

/obj/structure/clockwork/workshop
	name = "ratvar's workshop"
	desc = "A workshop of elder god. Has unique brass tools to manipulate both power and metal to make fine clockwork pieces."

/obj/structure/clockwork/functional
	max_integrity = 100
	var/cooldowntime = 0
	var/death_message = "<span class='danger'>The structure falls apart.</span>" //The message shown when the structure is destroyed
	var/death_sound = 'sound/items/bikehorn.ogg'

/obj/structure/clockwork/functional/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(user))
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "":"un"]secure [src] [anchored ? "to":"from"] the floor.</span>")
		if(!anchored)
			icon_state = "[initial(icon_state)]-off"
		else
			icon_state = "[initial(icon_state)]"
		update_icon()
		return
	return ..()

/obj/structure/clockwork/functional/obj_destruction()
	visible_message(death_message)
	playsound(src, death_sound, 50, TRUE)
	..()

/obj/structure/clockwork/functional/beacon
	name = "herald's beacon"
	desc = "An imposing spire formed of brass. It somewhat pulsates."
	icon_state = "beacon"
	max_integrity = 500 // A very important one
	death_message = "<span class='danger'>The beacon crumbles and falls in parts to the ground relaesing it's power!</span>"
	var/heal_delay = 60
	var/last_heal = 0
	var/area/areabeacon
	var/areastring = null
	color = "#FFFFFF"

/obj/structure/clockwork/functional/beacon/New()
	SSticker.mode.clocker_objs.beacon_check()
	areabeacon = get_area(src)
	GLOB.clockwork_beacons += src
	..()

/obj/structure/clockwork/functional/beacon/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	var/area/A = get_area(src)
	//if area isn't specified use current
	if(isarea(A))
		areabeacon = A

/obj/structure/clockwork/functional/beacon/process()
	adjust_clockwork_power(CLOCK_POWER_BEACON)

	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(isclocker(L))
				if(L.health != L.maxHealth)
					new /obj/effect/temp_visual/heal(get_turf(L), "#960000")

					if(ishuman(L))
						L.heal_overall_damage(2, 2, TRUE, FALSE, TRUE)

					else if(isshade(L) || isconstruct(L))
						var/mob/living/simple_animal/M = L
						if(M.health < M.maxHealth)
							M.adjustHealth(-2)

				if(ishuman(L) && L.blood_volume < BLOOD_VOLUME_NORMAL)
					L.blood_volume += 1

/obj/structure/clockwork/functional/beacon/Destroy()
	GLOB.clockwork_beacons -= src
	for(var/datum/mind/M in SSticker.mode.clockwork_cult)
		to_chat(M.current, "<span class='danger'>You get the feeling that one of the beacons have been destroyed! The source comes from [areabeacon.name]</span>")
	return ..()

/obj/structure/clockwork/functional/beacon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(user))
		to_chat(user, "<span class='danger'>You try to unsecure [src], but it's secures himself back tightly!</span>")
		return
	return ..()

/obj/structure/clockwork/functional/altar
	name = "credence"
	desc = "A strange brass platform with spinning cogs inside. It demands somethinge in exchange for goods..."
	icon_state = "altar"
	density = 0
	var/convert_time = 80
	var/glow_type = /obj/effect/temp_visual/ratvar/altar_convert

/obj/structure/clockwork/functional/altar/Crossed(atom/movable/AM)
	if(!src.anchored)
		return
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.stat != DEAD && !isclocker(L) && !issilicon(L) && L.mind)
			var/obj/item/I = L.null_rod_check()
			if(I)
				L.visible_message("<span class='warning'>[L]'s [I.name] glows, protecting them from [src]'s effects!</span>", \
				"<span class='userdanger'>Your [I.name] glows, protecting you!</span>")
				return
			try_convert(L)

/obj/structure/clockwork/functional/altar/proc/try_convert(mob/living/L)
	var/has_clocker = null
	for(var/mob/living/M in range(1, src))
		if(isclocker(M) && !M.stat)
			has_clocker = M
			break
	if(!has_clocker)
		visible_message("<span class='warning'>[src] strains into a gentle yellow color, but quietly fades...</span>")
		return
	L.visible_message("<span class='warning'>[src] begins to glow a piercing amber!</span>", "<span class='clock'>You feel something start to invade your mind...</span>")
	var/obj/effect/temp_visual/ratvar/altar_convert/glow
	glow = new glow_type(get_turf(src))
	animate(glow, alpha = 255, time = convert_time)
	icon_state = "[initial(icon_state)]-fast"
	var/I = 0
	// We doing some converting here
	while(I < convert_time && get_turf(L) == get_turf(src) && src.anchored)
		if(!in_range(src, has_clocker))
			for(var/mob/living/M in range(1, src))
				if(isclocker(M) && !M.stat)
					has_clocker = M
					break
			has_clocker = null
			break
		I++
		sleep(1)
	if(get_turf(L) != get_turf(src) || !src.anchored || !has_clocker)
		if(glow)
			qdel(glow)
		if(src.anchored)
			icon_state = "[initial(icon_state)]"
		else
			icon_state = "[initial(icon_state)]-off"
		visible_message("<span class='warning'>[src] slowly stops glowing!</span>")
		return
	if(is_convertable_to_clocker(L.mind))
		to_chat(L, "<span class='clocklarge'><b>\"You belong to me now.\"</b></span>")
		// Brass golem now and the master Ratvar. One way only: Serve or die perma.
		if(isgolem(L))
			L.mind.wipe_memory()
			var/mob/living/carbon/human/H = L
			H.set_species(/datum/species/golem/clockwork)
		if(SSticker.mode.add_clocker(L.mind))
			L.create_log(CONVERSION_LOG, "[L] been converted by [src.name]")
		L.Weaken(5) //Accept new power... and new information
		L.EyeBlind(5)
	else // Start tearing him apart until GIB
		I = 0
		L.visible_message("<span class='warning'>[src] in glowing manner starts rupturing [L]!</span>", \
		"<span class='danger'>[src] underneath you starts to tear you to pieces!</span>")
		while(I < convert_time && get_turf(L) == get_turf(src) && src.anchored)
			if(!in_range(src, has_clocker))
				for(var/mob/living/M in range(1, src))
					if(isclocker(M) && !M.stat)
						has_clocker = M
						break
				has_clocker = null
				break
			I++
			sleep(1)
			if(I > convert_time*0.8)
				L.adjustBruteLoss(30)
			else
				L.adjustBruteLoss(5)
		if(get_turf(L) == get_turf(src) && src.anchored && has_clocker)
			if((ishuman(L) || isbrain(L)) && L.mind)
				var/obj/item/mmi/robotic_brain/clockwork/cube = new /obj/item/mmi/robotic_brain/clockwork(get_turf(src))
				cube.transfer_personality(L)
			L.gib()
			adjust_clockwork_power(CLOCK_POWER_SACRIFICE)

		if(src.anchored)
			icon_state = "[initial(icon_state)]"
		else
			icon_state = "[initial(icon_state)]-off"
	if(glow)
		qdel(glow)
	visible_message("<span class='warning'>[src] slowly stops glowing!</span>")

/// for area.get_beacon() returns BEACON if it exists
/area/proc/get_beacon()
	for(var/thing in GLOB.clockwork_beacons)
		var/obj/structure/clockwork/functional/beacon/BEACON = thing
		if(BEACON.areabeacon == get_area(src))
			return BEACON



// Walls, Gears, Windows


// Wall gears
//A massive gear, effectively a girder for clocks.
/obj/structure/clockwork/wall_gear
	name = "massive gear"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "wall_gear"
	climbable = TRUE
	max_integrity = 100
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	desc = "A massive brass gear. You could probably secure or unsecure it with a wrench, or just climb over it."

/obj/structure/clockwork/wall_gear/displaced
	anchored = FALSE

/obj/structure/clockwork/wall_gear/Initialize()
	. = ..()
	new /obj/effect/temp_visual/ratvar/gear(get_turf(src))

/obj/structure/clockwork/wall_gear/emp_act(severity)
	return

/obj/structure/clockwork/wall_gear/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(anchored)
		to_chat(user, "<span class='warning'>[src] needs to be unsecured to disassemble it!</span>")
		return
	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 30, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(TRUE)

/obj/structure/clockwork/wall_gear/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I, 10)

/obj/structure/clockwork/wall_gear/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/brass))
		var/obj/item/stack/sheet/brass/W = I
		if(W.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one brass sheet to do this!</span>")
			return
		var/turf/T = get_turf(src)
		if(iswallturf(T))
			to_chat(user, "<span class='warning'>There is already a wall present!</span>")
			return
		if(!isfloorturf(T))
			to_chat(user, "<span class='warning'>A floor must be present to build a [anchored ? "false ":""]wall!</span>")
			return
		if(locate(/obj/structure/falsewall) in T.contents)
			to_chat(user, "<span class='warning'>There is already a false wall present!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
		if(do_after(user, 20, target = src))
			var/brass_floor = FALSE
			if(istype(T, /turf/simulated/floor/clockwork)) //if the floor is already brass, costs less to make(conservation of masssssss)
				brass_floor = TRUE
			if(W.use(2 - brass_floor))
				if(anchored)
					T.ChangeTurf(/turf/simulated/wall/clockwork)
				else
					T.ChangeTurf(/turf/simulated/floor/clockwork)
					new /obj/structure/falsewall/brass(T)
				qdel(src)
			else
				to_chat(user, "<span class='warning'>You need more brass to make a [anchored ? "false ":""]wall!</span>")
		return 1
	return ..()

/obj/structure/clockwork/wall_gear/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT) && disassembled)
		new /obj/item/stack/sheet/brass(loc, 3)
	return ..()
