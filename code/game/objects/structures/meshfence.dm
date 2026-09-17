// CM-style mesh fences (poles + metal mesh between them)
// Sprites: icons/obj/electric_fence.dmi, icons/obj/electric_fence_alt.dmi, icons/obj/electric_fence_alt_door.dmi

/obj/structure/meshfence
	name = "fence"
	desc = "Большая металлическая сетка, натянутая между двумя столбами. Дешёвый способ разделить зоны, не мешая обзору."
	icon = 'icons/obj/electric_fence.dmi'
	icon_state = "fence0"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_OBJ_LAYER
	max_integrity = 200
	resistance_flags = FLAMMABLE
	/// Whether the mesh has been cut through - only the frame remains
	var/cut = FALSE
	/// Junction bitfield for icon state, built from orthogonally adjacent fences
	var/junction = 0
	var/basestate = "fence"
	/// Do we form junction sprites with neighbours?
	var/forms_junctions = TRUE
	/// Is this a sliding door variant?
	var/door = FALSE
	var/open = FALSE

/obj/structure/meshfence/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(isprojectile(mover))
		return TRUE

/obj/structure/meshfence/Initialize(mapload)
	. = ..()
	update_fence()

/obj/structure/meshfence/Destroy()
	density = FALSE
	update_nearby_icons()
	return ..()

/obj/structure/meshfence/examine(mob/user)
	. = ..()
	if(cut)
		. += span_notice("Сетка срезана, осталась только рама.")

/// Called whenever the mesh takes structural damage - cuts the mesh at 0
/obj/structure/meshfence/proc/healthcheck(make_hit_sound = TRUE, mob/user)
	if(cut) // It's broken/cut, just a frame!
		return
	if(obj_integrity <= 0)
		if(user)
			user.visible_message(span_danger("[user] проламывается сквозь [src]!"))
		playsound(loc, 'sound/effects/fencehit.ogg', 25, TRUE)
		cut_mesh()
		return
	if(make_hit_sound)
		playsound(loc, 'sound/effects/fencehit.ogg', 25, TRUE)

/obj/structure/meshfence/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			cut_mesh()
		if(EXPLODE_LIGHT)
			take_damage(25, BRUTE, BOMB)
			healthcheck(FALSE)

/obj/structure/meshfence/hitby(atom/movable/AM)
	..()
	visible_message(span_danger("[src] was hit by [AM]."))
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce / 2
	take_damage(tforce, BRUTE, MELEE, 1)
	healthcheck()

/obj/structure/meshfence/attack_animal(mob/user)
	. = ..()
	if(. && !QDELETED(src))
		var/mob/living/simple_animal/simple = user
		if(simple.melee_damage_upper > 0)
			take_damage(simple.melee_damage_upper, BRUTE, MELEE, 1)
			visible_message(span_danger("[user] бьёт в [src]!"))
			healthcheck(TRUE, user)

/obj/structure/meshfence/bullet_act(obj/projectile/P, def_zone)
	playsound(src, 'sound/effects/fencehit.ogg', 35, TRUE)
	return TRUE

/obj/structure/meshfence/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		take_damage(floor(exposed_volume / 100), BURN, FIRE, 1)
		healthcheck(FALSE)

/obj/structure/meshfence/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	playsound(loc, 'sound/items/wirecutter.ogg', 25, TRUE)
	if(cut)
		balloon_alert(user, "используйте сварку!")
		return TRUE

	user.visible_message(
		span_notice("[user] начинает срезать [src] кусачками."),
		span_notice("You start cutting through [src] with [I]."),
	)
	if(!I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume))
		return
	playsound(loc, 'sound/items/wirecutter.ogg', 25, TRUE)
	to_chat(user, span_notice("You cut through [src]."))
	cut_mesh()

/obj/structure/meshfence/attackby(obj/item/I, mob/user, params)
	if(!cut && istype(I, /obj/item/stack/rods))
		return ..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = I
		if(!cut)
			balloon_alert(user, "сетка цела, чинить нечего")
			return ATTACK_CHAIN_PROCEED
		if(rods.get_amount() < 5)
			balloon_alert(user, "нужно 5 прутьев")
			return ATTACK_CHAIN_PROCEED
		user.visible_message(span_notice("[user] начинает чинить [src] прутьями."),
			span_notice("Вы начинаете чинить [src] прутьями."))
		if(!do_after(user, 5 SECONDS, src, category = DA_CAT_TOOL))
			return ATTACK_CHAIN_PROCEED
		if(!rods.use(5) || !cut)
			return ATTACK_CHAIN_PROCEED
		cut = FALSE
		set_density(TRUE)
		update_integrity(max_integrity)
		update_fence()
		update_nearby_icons()
		user.visible_message(span_notice("[user] чинит [src]."),
			span_notice("Вы починили [src]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/structure/meshfence/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!cut)
		return TRUE
	if(!tool.use_tool(src, user, 5 SECONDS, volume = tool.tool_volume))
		return TRUE
	user.visible_message(span_notice("[user] разваривает [src]."),
		span_notice("Вы разварили [src]."))
	deconstruct(FALSE)
	return TRUE

/obj/structure/meshfence/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(door)
		toggle_open(user)
		return TRUE
	if(!cut)
		playsound(loc, 'sound/effects/fencehit.ogg', 25, TRUE)
		return TRUE
	return TRUE

/obj/structure/meshfence/proc/toggle_open(mob/user)
	open = !open
	set_density(!open)
	if(open)
		flick("door_opening", src)
		icon_state = "door_open"
	else
		flick("door_closing", src)
		icon_state = "door_closed"
	visible_message(span_notice("[user] [open ? "открывает" : "закрывает"] [src]."))
	playsound(src, 'sound/machines/door_open.ogg', 25, TRUE)

/// The mesh is destroyed - only the frame remains, passable but still visible
/obj/structure/meshfence/proc/cut_mesh()
	obj_integrity = 0
	cut = TRUE
	set_density(FALSE)
	update_fence()
	update_nearby_icons()

/obj/structure/meshfence/deconstruct(disassembled = TRUE)
	if(disassembled)
		new /obj/item/stack/rods(loc, 10)
	return ..()

/obj/structure/meshfence/proc/update_fence()
	// Junction calculation: connect to orthogonal neighbours
	junction = 0
	for(var/obj/structure/meshfence/fence in orange(src, 1))
		if(abs(x - fence.x) - abs(y - fence.y)) // Skip diagonal neighbours
			junction |= get_dir(src, fence)

	if(cut)
		icon_state = "broken[basestate][junction]"
		if(!forms_junctions)
			icon_state = "brokendoor"
		return

	if(door)
		icon_state = open ? "door_open" : "door_closed"
		return

	icon_state = "[basestate][junction]"

/// Updates our own icon and the icons of all adjacent fences
/obj/structure/meshfence/proc/update_nearby_icons()
	update_fence()
	for(var/direction in GLOB.cardinal)
		for(var/obj/structure/meshfence/fence in get_step(src, direction))
			fence.update_fence()

// Subtypes matching the imported DMI files

/// Dark fence with warning stripes - electric_fence.dmi
/obj/structure/meshfence/warning
	name = "fence"
	desc = "Большая металлическая сетка между двумя столбами. Дешёвый способ разделить зоны, не мешая обзору."
	icon = 'icons/obj/electric_fence.dmi'

/// Slim fence - electric_fence_alt.dmi
/obj/structure/meshfence/slim
	icon = 'icons/obj/electric_fence_alt.dmi'

/// Slim fence door - electric_fence_alt_door.dmi
/obj/structure/meshfence/slim/door
	name = "fence door"
	desc = "Прочная сетчатая дверь между двумя металлическими столбами. Дешёвый способ отделить зоны, сохраняя обзор."
	icon = 'icons/obj/electric_fence_alt_door.dmi'
	icon_state = "door_closed"
	door = TRUE
	forms_junctions = FALSE
	max_integrity = 70

/obj/structure/meshfence/dark
	icon = 'icons/obj/dark_fence.dmi'

/obj/structure/meshfence/dark_slim
	icon = 'icons/obj/dark_fence_alt.dmi'

/obj/structure/meshfence/dark_slim/door
	name = "fence door"
	desc = "Прочная сетчатая дверь между двумя металлическими столбами. Дешёвый способ отделить зоны, сохраняя обзор."
	icon = 'icons/obj/dark_fence_alt_door.dmi'
	icon_state = "door_closed"
	door = TRUE
	forms_junctions = FALSE
	max_integrity = 70
