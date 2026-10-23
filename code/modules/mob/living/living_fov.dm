/mob/living/proc/in_fov(atom/observed_atom, ignore_self = FALSE)
	if(ignore_self && observed_atom == src)
		return TRUE

	if(is_blind())
		return FALSE

	var/turf/my_turf = get_turf(src)
	var/rel_x = observed_atom.x - my_turf.x
	var/rel_y = observed_atom.y - my_turf.y

	var/obj/item/clothing/glasses/our_glasses
	if(iscarbon(src))
		our_glasses = src:glasses
	if(HAS_TRAIT(src, TRAIT_NEARSIGHTED) && (!istype(our_glasses) || !our_glasses.prescription))
		if(abs(rel_x) >= NEARSIGHTNESS_FOV_BLINDNESS || abs(rel_y) >= NEARSIGHTNESS_FOV_BLINDNESS)
			return FALSE

	if(!fov_view)
		return TRUE

	if(rel_x >= -1 && rel_x <= 1 && rel_y >= -1 && rel_y <= 1)
		return TRUE

	var/vector_len = sqrt(abs(rel_x) ** 2 + abs(rel_y) ** 2)

	var/dir_x = 0
	var/dir_y = 0

	if(dir & NORTH)
		dir_y += vector_len
	else if(dir & SOUTH)
		dir_y -= vector_len

	if(dir & EAST)
		dir_x += vector_len
	else if(dir & WEST)
		dir_x -= vector_len

	var/angle = arccos((dir_x * rel_x + dir_y * rel_y) / (sqrt(dir_x**2 + dir_y**2) * sqrt(rel_x**2 + rel_y**2)))

	var/vision_angle = (360 - abs(fov_view)) / 2
	if(fov_view > 0)
		return angle < vision_angle
	return angle > vision_angle

/// Updates the applied FOV value and applies the handler to client if able
/mob/living/proc/update_fov()
	var/highest_fov
	for(var/trait_type in fov_traits)
		var/fov_type = fov_traits[trait_type]
		if(!highest_fov || fov_type > highest_fov)
			highest_fov = fov_type
	fov_view = highest_fov
	if(HAS_TRAIT(src, TRAIT_EXPANDED_FOV))
		fov_view += 30
	update_fov_client()

/// Updates the FOV for the client.
/mob/living/proc/update_fov_client()
	if(!client)
		return
	var/datum/component/fov_handler/fov_component = GetComponent(/datum/component/fov_handler)
	if(fov_view)
		if(!fov_component)
			AddComponent(/datum/component/fov_handler, fov_view)
		else
			fov_component.set_fov_angle(fov_view)
	else if(fov_component)
		qdel(fov_component)

/mob/living/proc/add_fov_trait(source, type)
	LAZYSET(fov_traits, source, type)
	update_fov()

/mob/living/proc/remove_fov_trait(source, type)
	if(!fov_traits)
		return
	LAZYREMOVE(fov_traits, source)
	update_fov()

/image/fov_image
	icon = 'icons/effects/fov/fov_effects.dmi'
	layer = EFFECTS_LAYER + FOV_EFFECT_LAYER
	appearance_flags = RESET_COLOR | RESET_TRANSFORM
	plane = FULLSCREEN_PLANE

/proc/play_fov_effect(atom/center, range, icon_state, dir = SOUTH, ignore_self = FALSE, angle = 0, time = 1.5 SECONDS, list/override_list)
	var/turf/anchor_point = get_turf(center)
	var/image/fov_image/fov_image
	var/list/clients_shown

	for(var/mob/living/living_mob in override_list || get_hearers_in_view(range, center))
		var/client/mob_client = living_mob.client
		if(!mob_client)
			continue
		if(HAS_TRAIT(living_mob, TRAIT_DEAF))
			continue
		if(living_mob.in_fov(center, ignore_self))
			continue
		if(!fov_image)
			fov_image = new()
			fov_image.loc = anchor_point
			fov_image.icon_state = icon_state
			fov_image.dir = dir
			if(angle)
				var/matrix/matrix = new
				matrix.Turn(angle)
				fov_image.transform = matrix
			fov_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		LAZYADD(clients_shown, mob_client)

		mob_client.images += fov_image

	if(clients_shown)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_image_from_clients), fov_image, clients_shown), time)

/atom/movable/screen/fov_blocker
	icon = 'icons/effects/fov/field_of_view.dmi'
	icon_state = "90"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FIELD_OF_VISION_BLOCKER_PLANE
	render_target = FIELD_OF_VISION_BLOCKER_RENDER_TARGET
	screen_loc = "BOTTOM,LEFT"
	clear_with_screen = FALSE
