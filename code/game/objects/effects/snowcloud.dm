/obj/effect/snowcloud
	name = "snow cloud"
	desc = "Let it snow, let it snow, let it snow!"
	icon_state = "snowcloud"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/obj/machinery/snow_machine/parent_machine

/obj/effect/snowcloud/New(turf, obj/machinery/snow_machine/SM)
	..()
	START_PROCESSING(SSobj, src)
	if(SM && istype(SM))
		parent_machine = SM

/obj/effect/snowcloud/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/snowcloud/process()
	if(QDELETED(parent_machine))
		parent_machine = null
	var/turf/T = get_turf(src)
	if(isspaceturf(T))
		qdel(src)
		return
	var/turf_hotness
	if(issimulatedturf(T))
		var/turf/simulated/S = T
		turf_hotness = S.air.temperature
	if(turf_hotness > T0C && prob(10 * (turf_hotness - T0C))) //Cloud disappears if it's too warm
		qdel(src)
		return
	if(!parent_machine || !parent_machine.active || parent_machine.stat & NOPOWER) //All reasons a cloud could dissipate
		if(prob(10))
			qdel(src)
		return
	try_to_snow()
	try_to_spread_cloud()
	parent_machine.affect_turf_temperature(T, 0.25 * parent_machine.cooling_speed)

/obj/effect/snowcloud/proc/try_to_snow()
	var/turf/T = get_turf(src)
	if(locate(/obj/effect/snow, T))
		return
	if(issimulatedturf(T))
		var/turf/simulated/S = T
		if(prob(75 + S.air.temperature - T0C)) //Colder turf = more chance of snow
			return
	new /obj/effect/snow(T)

/obj/effect/snowcloud/proc/try_to_spread_cloud()
	if(prob(95 - parent_machine.cooling_speed * 5)) //10 / 15 / 20 / 25% chance to spawn a new cloud
		return
	var/list/random_dirs = shuffle(GLOB.cardinal)
	for(var/potential in random_dirs)
		var/turf/T = get_turf(get_step(src, potential))
		if(isspaceturf(T) || T.density)
			continue
		if(!T.CanAtmosPass(T, vertical = FALSE))
			continue
		if(parent_machine.make_snowcloud(T))
			return


//Snow stuff below

/obj/effect/snow
	desc = "Perfect for making snow angels, or throwing at other people!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "snow"
	layer = ABOVE_ICYOVERLAY_LAYER
	anchored = TRUE

/obj/effect/snow/New()
	START_PROCESSING(SSobj, src)
	icon_state = "snow[rand(1,6)]"
	..()

/obj/effect/snow/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/snow/process()
	var/turf/T = get_turf(src)
	if(isspaceturf(T))
		qdel(src)
		return
	else if(issimulatedturf(T))
		var/turf/simulated/S = T
		if(S.air.temperature <= T0C)
			return
		if(prob(10 + S.air.temperature - T0C))
			qdel(src)

/obj/effect/snow/attack_hand(mob/living/carbon/human/user)
	if(!istype(user)) //Nonhumans don't have the balls to fight in the snow
		return
	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/item/snowball/SB = new(get_turf(user))
	user.put_in_hands(SB)
	to_chat(user, "<span class='notice'>You scoop up some snow and make \a [SB]!</span>")


/obj/effect/snow/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/shovel))
		user.visible_message(
			span_notice("[user] starts clearing [name] away..."),
			span_notice("You start clearing [name] away..."),
			span_italics("You hear a wettish digging sound."),
		)
		playsound(loc, I.usesound, 50, TRUE)
		if(!do_after(user, 5 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] clears away [src]!"),
			span_notice("You clear away [src]!"),
		)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/effect/snow/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	qdel(src)

/obj/effect/snow/ex_act(severity)
	if(severity == 3 && prob(50))
		return
	qdel(src)

/obj/item/snowball
	name = "snowball"
	desc = "Get ready for a snowball fight!"
	icon_state = "snowball"
	/// The amount of stamina damage to do on hit.
	var/stamina_damage = 10

/obj/item/snowball/throw_impact(atom/target, datum/thrownthing/throwingdatum)
	. = ..()
	if(!. && isliving(target))
		var/mob/living/M = target
		M.apply_damage(stamina_damage, STAMINA)
		playsound(target, 'sound/weapons/tap.ogg', 50, TRUE)
	qdel(src)

/obj/item/snowball/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	qdel(src)

/obj/item/snowball/ex_act(severity)
	qdel(src)
