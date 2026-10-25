/obj/machinery/bsa/full/ship
	name = "ship bluespace artillery"
	use_power = NO_POWER_USE
	max_integrity = 300
	bound_width = 32
	bound_height = 32
	bound_x = 0
	var/sprite_half_x
	var/sprite_half_y
	var/sprite_center_x
	var/sprite_center_y
	var/sprite_rotation = 0
	var/list/ship_parts = list()

/obj/machinery/bsa/full/ship/Initialize(mapload, direction)
	. = ..()
	var/icon/picture = icon(icon, icon_state)
	sprite_half_x = (picture.Width() - ICON_SIZE_X) / 2
	sprite_half_y = (picture.Height() - ICON_SIZE_Y) / 2
	sprite_center_x = pixel_x + sprite_half_x
	sprite_center_y = pixel_y + sprite_half_y
	var/datum/component/ship_weapon/weapon = AddComponent(/datum/component/ship_weapon)
	weapon.arc = 30
	weapon.automatic = FALSE
	weapon.mount_dir = cannon_direction
	weapon.muzzle_distance = cannon_direction == EAST ? 4.8 : 6.8

/obj/machinery/bsa/full/ship/Destroy()
	QDEL_LIST(ship_parts)
	return ..()

/obj/machinery/bsa/full/ship/shuttleRotate(rotation, params = ROTATE_DIR | ROTATE_SMOOTH | ROTATE_OFFSET)
	sprite_rotation = SIMPLIFY_DEGREES(sprite_rotation + rotation)
	. = ..(rotation, params & ~ROTATE_OFFSET)
	pixel_x = sprite_center_x * cos(sprite_rotation) + sprite_center_y * sin(sprite_rotation) - sprite_half_x
	pixel_y = sprite_center_y * cos(sprite_rotation) - sprite_center_x * sin(sprite_rotation) - sprite_half_y
	var/datum/component/ship_weapon/weapon = GetComponent(/datum/component/ship_weapon)
	if(weapon)
		weapon.mount_dir = angle2dir(dir2angle(weapon.mount_dir) + rotation)
	transform = matrix(transform).Turn(rotation)

/obj/structure/ship_artillery_frame
	name = "bluespace artillery structure"
	density = TRUE
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	max_integrity = 300
	var/obj/machinery/bsa/full/ship/cannon

/obj/structure/ship_artillery_frame/Destroy()
	if(!QDELETED(cannon))
		qdel(cannon)
	cannon = null
	return ..()

/obj/effect/spawner/portable_bsa
	name = "complete ship bluespace artillery spawner"
	icon = 'icons/obj/engines_and_power/particle_accelerator3.dmi'
	icon_state = "emitter_center"
	dir = WEST

/obj/effect/spawner/portable_bsa/Initialize(mapload)
	. = ..()
	var/turf/center = get_turf(src)
	if(!center)
		return INITIALIZE_HINT_QDEL
	var/direction = dir == EAST ? EAST : WEST
	var/list/footprint = list()
	for(var/forward in -6 to 4)
		for(var/side in -1 to 1)
			var/turf/spot = locate(center.x + forward, center.y + side, center.z)
			if(!spot || spot.is_blocked_turf(exclude_mobs = TRUE))
				return INITIALIZE_HINT_QDEL
			footprint += spot
	var/obj/machinery/bsa/full/ship/gun = new(center, direction)
	for(var/turf/spot as anything in footprint)
		if(spot == center)
			continue
		var/obj/structure/ship_artillery_frame/part = new(spot)
		part.cannon = gun
		gun.ship_parts += part
	return INITIALIZE_HINT_QDEL
