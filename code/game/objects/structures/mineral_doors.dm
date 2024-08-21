//NOT using the existing /obj/machinery/door type, since that has some complications on its own, mainly based on its machineryness
/obj/structure/mineral_door
	name = "metal door"
	density = TRUE
	anchored = TRUE
	opacity = TRUE

	icon = 'icons/obj/doors/mineral_doors.dmi'
	icon_state = "metal"
	max_integrity = 200
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 50, "acid" = 50)
	var/initial_state
	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0
	var/close_delay = -1 //-1 if does not auto close.

	var/hardness = 1
	var/sheetType = /obj/item/stack/sheet/metal
	var/sheetAmount = 7
	var/openSound = 'sound/effects/stonedoor_openclose.ogg'
	var/closeSound = 'sound/effects/stonedoor_openclose.ogg'
	var/damageSound = null
	var/is_opaque = TRUE

/obj/structure/mineral_door/Initialize()
	. = ..()
	initial_state = icon_state
	air_update_turf(1)

/obj/structure/mineral_door/Destroy()
	set_density(FALSE)
	air_update_turf(1)
	return ..()

/obj/structure/mineral_door/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/mineral_door/Bumped(atom/movable/moving_atom)
	. = ..()
	if(!state)
		return TryToSwitchState(moving_atom)

/obj/structure/mineral_door/attack_ai(mob/user) //those aren't machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user) && Adjacent(user)) //but cyborgs can, but not remotely
		return TryToSwitchState(user)

/obj/structure/mineral_door/attack_hand(mob/user)
	return TryToSwitchState(user)

/obj/structure/mineral_door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		SwitchState()


/obj/structure/mineral_door/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	if(istype(mover, /obj/effect/beam))
		return !opacity


/obj/structure/mineral_door/CanAtmosPass(turf/T, vertical)
	return !density

/obj/structure/mineral_door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates)
		return
	if(isliving(user))
		var/mob/living/M = user
		if(world.time - user.last_bumped <= 60)
			return //NOTE do we really need that?
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					add_fingerprint(user)
					SwitchState()
			else
				add_fingerprint(user)
				SwitchState()
	else if(ismecha(user))
		SwitchState()

/obj/structure/mineral_door/proc/SwitchState()
	if(state)
		Close()
	else
		Open()

/obj/structure/mineral_door/proc/Open()
	isSwitchingStates = 1
	playsound(loc, openSound, 100, 1)
	flick("[initial_state]opening",src)
	sleep(10)
	set_density(FALSE)
	if(is_opaque)
		set_opacity(FALSE)
	state = 1
	air_update_turf(1)
	update_icon(UPDATE_ICON_STATE)
	isSwitchingStates = 0

	if(close_delay != -1)
		spawn(close_delay)
			Close()

/obj/structure/mineral_door/proc/Close()
	if(isSwitchingStates || state != 1)
		return FALSE
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		return FALSE
	. = TRUE
	isSwitchingStates = 1
	playsound(loc, closeSound, 100, 1)
	flick("[initial_state]closing",src)
	sleep(10)
	set_density(TRUE)
	if(is_opaque)
		set_opacity(TRUE)
	state = 0
	air_update_turf(1)
	update_icon(UPDATE_ICON_STATE)
	isSwitchingStates = 0


/obj/structure/mineral_door/update_icon_state()
	if(state)
		icon_state = "[initial_state]open"
	else
		icon_state = initial_state


/obj/structure/mineral_door/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pickaxe))
		add_fingerprint(user)
		var/obj/item/pickaxe/pickaxe = I
		user.visible_message(
			span_notice("[user] start digging into [src]."),
			span_notice("You start digging into [src]..."),
		)
		I.play_tool_sound(src, 100)
		if(!do_after(user, 4 SECONDS * pickaxe.toolspeed * hardness, src, category = DA_CAT_TOOL))
			return ATTACK_CHAIN_PROCEED
		I.play_tool_sound(src, 100)
		user.visible_message(
			span_notice("[user] finishes digging into [src]."),
			span_notice("You have finished digging into [src]."),
		)
		deconstruct(TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(user.a_intent != INTENT_HARM)
		attack_hand(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/mineral_door/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	if(sheetType)
		if(disassembled)
			new sheetType(T, sheetAmount)
		else
			new sheetType(T, max(sheetAmount - 2, 1))
	qdel(src)

/obj/structure/mineral_door/iron
	max_integrity = 300

/obj/structure/mineral_door/silver
	name = "silver door"
	icon_state = "silver"
	sheetType = /obj/item/stack/sheet/mineral/silver
	max_integrity = 300

/obj/structure/mineral_door/gold
	name = "gold door"
	icon_state = "gold"
	sheetType = /obj/item/stack/sheet/mineral/gold

/obj/structure/mineral_door/uranium
	name = "uranium door"
	icon_state = "uranium"
	sheetType = /obj/item/stack/sheet/mineral/uranium
	max_integrity = 300
	light_range = 2

/obj/structure/mineral_door/sandstone
	name = "sandstone door"
	icon_state = "sandstone"
	sheetType = /obj/item/stack/sheet/mineral/sandstone
	max_integrity = 100

/obj/structure/mineral_door/transparent
	opacity = FALSE
	is_opaque = FALSE

/obj/structure/mineral_door/transparent/plasma
	name = "plasma door"
	icon_state = "plasma"
	sheetType = /obj/item/stack/sheet/mineral/plasma


/obj/structure/mineral_door/transparent/plasma/attackby(obj/item/I, mob/user, params)
	var/hot_temp = is_hot(I)
	if(hot_temp)
		add_attack_logs(user, src, "Ignited using [I]", ATKLOG_FEW)
		investigate_log("was <span class='warning'>ignited</span> by [key_name_log(user)]",INVESTIGATE_ATMOS)
		TemperatureAct(hot_temp)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/structure/mineral_door/transparent/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		TemperatureAct(exposed_temperature)

/obj/structure/mineral_door/transparent/plasma/proc/TemperatureAct(temperature)
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 500)
	deconstruct(FALSE)

/obj/structure/mineral_door/transparent/diamond
	name = "diamond door"
	icon_state = "diamond"
	sheetType = /obj/item/stack/sheet/mineral/diamond
	max_integrity = 1000

/obj/structure/mineral_door/wood
	name = "wood door"
	icon_state = "wood"
	openSound = 'sound/effects/doorcreaky.ogg'
	closeSound = 'sound/effects/doorcreaky.ogg'
	sheetType = /obj/item/stack/sheet/wood
	hardness = 1
	resistance_flags = FLAMMABLE
	max_integrity = 200

/obj/structure/mineral_door/wood/paperframe
	name = "Paperframe door"
	desc = "Just looking at it's clean and simple design makes you at piece with your demons"
	icon_state = "paperframe"
	openSound = 'sound/effects/glider_door.ogg'
	closeSound = 'sound/effects/glider_door.ogg'
	sheetType = /obj/item/stack/sheet/wood
	hardness = 1
	resistance_flags = FLAMMABLE
	max_integrity = 200

/obj/structure/mineral_door/resin
	name = "resin door"
	icon_state = "resin"
	hardness = 1.5
	close_delay = 100
	openSound = 'sound/effects/attackblob.ogg'
	closeSound = 'sound/effects/attackblob.ogg'
	damageSound = 'sound/effects/attackblob.ogg'
	sheetType = null

/obj/structure/mineral_door/resin/TryToSwitchState(atom/user)
	if(isalien(user))
		return ..()

/obj/structure/mineral_door/ginger
	name = "gingerbread door"
	icon_state = "gingerbread"
	openSound = 'sound/effects/doorcreaky.ogg'
	closeSound = 'sound/effects/doorcreaky.ogg'
	sheetType = /obj/item/stack/sheet/gingerbread
	hardness = 0.5
	resistance_flags = FLAMMABLE
	max_integrity = 200
