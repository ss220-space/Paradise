/datum/component/echolocation
	///Default echo range
	var/default_echo_range = 4
	/// Current radius, will set itself to default
	var/echo_range
	/// Time between echolocations.
	var/cooldown_time = 2 SECONDS
	/// Time for the image to start fading out.
	var/image_expiry_time = 1.5 SECONDS
	/// Time for the image to fade in.
	var/fade_in_time = 0.5 SECONDS
	/// Time for the image to fade out and delete itself.
	var/fade_out_time = 0.5 SECONDS
	/// Are images static? If yes, spawns them on the turf and makes them not change location. Otherwise they change location and pixel shift with the original.
	var/images_are_static = TRUE
	/// With mobs that have this echo group in their echolocation receiver trait, we share echo images, defaults to quirk
	var/echo_group = null
	/// Color applied over the client
	var/client_color = null
	/// Associative list of world.time when created to a list of the images.
	var/list/images = list()
	/// Associative list of world.time when created to a list of receivers.
	var/list/receivers = list()
	/// All the saved appearances, keyed by icon-icon_state.
	var/static/list/saved_appearances = list()
	/// Typecache of all the allowed paths to render.
	var/static/list/allowed_paths
	/// Typecache of turfs that are dangerous, to give them a special icon.
	var/static/list/danger_turfs
	/// A matrix that turns everything except #ffffff into pure blackness, used for our images (the outlines are #ffffff).
	var/static/list/black_white_matrix = list(85, 85, 85, 0, 85, 85, 85, 0, 85, 85, 85, 0, 0, 0, 0, 1, -254, -254, -254, 0)
	/// A matrix that turns everything into pure white.
	var/static/list/white_matrix = list(255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 0, 0, 0, 1, 0, -0, 0, 0)

	/// Cooldown for the echolocation.
	COOLDOWN_DECLARE(cooldown_last)

/datum/component/echolocation/Initialize(echo_range, cooldown_time, image_expiry_time, fade_in_time, fade_out_time, images_are_static, blocking_trait, echo_group, echo_icon, color_path)
	. = ..()
	var/mob/living/echolocator = parent
	if(!istype(echolocator))
		return COMPONENT_INCOMPATIBLE
	if(!danger_turfs)
		danger_turfs = typecacheof(list(/turf/simulated/floor/chasm, /turf/simulated/floor/plating/lava))
	if(!allowed_paths)
		allowed_paths = typecacheof(list(/turf/simulated, /obj, /mob/living)) + danger_turfs - typecacheof(/obj/effect/decal)
	if(!isnull(echo_range))
		src.echo_range = default_echo_range
	if(!isnull(cooldown_time))
		src.cooldown_time = cooldown_time
	if(!isnull(image_expiry_time))
		src.image_expiry_time = image_expiry_time
	if(!isnull(fade_in_time))
		src.fade_in_time = fade_in_time
	if(!isnull(fade_out_time))
		src.fade_out_time = fade_out_time
	if(!isnull(images_are_static))
		src.images_are_static = images_are_static
	client_color = echolocator.add_client_colour(/datum/client_colour/echolocate)

	src.echo_group = echo_group
	ADD_TRAIT(parent, TRAIT_ECHOLOCATION_RECEIVER, src.echo_group)
	ADD_TRAIT(parent, ECHO_VISION, src.echo_group)//so they see all the tiles they echolocated, even if they are in the dark
	echolocator.BecomeBlind(ECHOLOCATION_TRAIT)
	echolocator.overlay_fullscreen("echo", /obj/screen/fullscreen/echo)
	START_PROCESSING(SSfastprocess, src)

/datum/component/echolocation/Destroy(force, silent)
	STOP_PROCESSING(SSfastprocess, src)
	var/mob/living/echolocator = parent
	REMOVE_TRAIT(parent, TRAIT_ECHOLOCATION_RECEIVER, echo_group)
	REMOVE_TRAIT(parent, ECHO_VISION, echo_group)
	echolocator.CureBlind(ECHOLOCATION_TRAIT)
	echolocator.clear_fullscreen("echo")
	for(var/timeframe in images)
		delete_images(timeframe)
	return ..()

/datum/component/echolocation/process()
	var/mob/living/echolocator = parent
	if(echolocator.stat == DEAD)
		return
	echolocate()

/datum/component/echolocation/proc/echolocate()
	if(!COOLDOWN_FINISHED(src, cooldown_last))
		return
	COOLDOWN_START(src, cooldown_last, cooldown_time)
	var/mob/living/echolocator = parent
	echo_range = echo_sound_environment(echolocator, default_echo_range)
	var/list/filtered = list()
	var/list/seen = dview(echo_range, get_turf(echolocator.client?.eye || echolocator), invis_flags = echolocator.see_invisible)
	for(var/atom/seen_atom as anything in seen)
		if(!seen_atom.alpha)
			continue
		if(allowed_paths[seen_atom.type])
			filtered += seen_atom
	if(!length(filtered))
		return
	var/current_time = "[world.time]"
	images[current_time] = list()
	receivers[current_time] = list()
	for(var/mob/living/viewer in filtered)
		if(HAS_TRAIT_FROM(viewer, TRAIT_ECHOLOCATION_RECEIVER, echo_group))
			receivers[current_time] += viewer
	for(var/atom/filtered_atom as anything in filtered)
		show_image(saved_appearances["[filtered_atom.icon]-[filtered_atom.icon_state]"] || generate_appearance(filtered_atom), filtered_atom, current_time)
	addtimer(CALLBACK(src, PROC_REF(fade_images), current_time), image_expiry_time)

/datum/component/echolocation/proc/echo_sound_environment(mob/living/creature, range)
	var/area/A = get_area(creature)
	var/sound_environment = A.sound_environment
	switch(sound_environment)
		if(SOUND_AREA_SPACE)
			return range -3
		if(SOUND_AREA_STANDARD_STATION)
			return range
		if(SOUND_AREA_LARGE_ENCLOSED)
			return range -1
		if(SOUND_AREA_SMALL_ENCLOSED)
			return range +1
		if(SOUND_AREA_TUNNEL_ENCLOSED)
			return range +2
		if(SOUND_AREA_LARGE_SOFTFLOOR)
			return range -1
		if(SOUND_AREA_ASTEROID)
			return range -2
		if(SOUND_AREA_LAVALAND)
			return range -1
		if(SOUND_AREA_WOODFLOOR)
			return range +1
		else
			return range

/datum/component/echolocation/proc/show_image(image/input_appearance, atom/input, current_time)
	var/image/final_image = image(input_appearance)
	final_image.layer += EFFECTS_LAYER
	final_image.plane = FULLSCREEN_PLANE
	final_image.loc = images_are_static ? get_turf(input) : input
	final_image.dir = input.dir
	final_image.alpha = 0
	if(images_are_static)
		final_image.pixel_x = input.pixel_x
		final_image.pixel_y = input.pixel_y
	if(HAS_TRAIT_FROM(input, TRAIT_ECHOLOCATION_RECEIVER, echo_group)) //mark other echolocation with full white
		final_image.color = white_matrix
	images[current_time] += final_image
	for(var/mob/living/echolocate_receiver as anything in receivers[current_time])
		if(echolocate_receiver == input)
			continue
		if(echolocate_receiver.client)
			echolocate_receiver.client.images += final_image
	animate(final_image, alpha = 255, time = fade_in_time)

/datum/component/echolocation/proc/generate_appearance(atom/input)
	var/use_outline = TRUE
	var/mutable_appearance/copied_appearance = new /mutable_appearance()
	copied_appearance.appearance = input
	if(istype(input, /obj/machinery/door/airlock)) //i hate you
		copied_appearance.cut_overlays()
		copied_appearance.icon = 'icons/obj/doors/airlocks/station/public.dmi'
		copied_appearance.icon_state = "closed"
	else if(danger_turfs[input.type])
		copied_appearance.icon = 'icons/turf/floors.dmi'
		copied_appearance.icon_state = "danger"
		use_outline = FALSE
	copied_appearance.color = black_white_matrix
	if(use_outline)
		copied_appearance.filters += outline_filter(size = 1, color = COLOR_WHITE)
	if(!images_are_static)
		copied_appearance.pixel_x = 0
		copied_appearance.pixel_y = 0
		copied_appearance.transform = matrix()
	if(!iscarbon(input)) //wacky overlay people get generated everytime
		saved_appearances["[input.icon]-[input.icon_state]"] = copied_appearance
	return copied_appearance

/datum/component/echolocation/proc/fade_images(from_when)
	for(var/image_echo in images[from_when])
		animate(image_echo, alpha = 0, time = fade_out_time)
	addtimer(CALLBACK(src, PROC_REF(delete_images), from_when), fade_out_time)

/datum/component/echolocation/proc/delete_images(from_when)
	for(var/mob/living/echolocate_receiver as anything in receivers[from_when])
		if(!echolocate_receiver.client)
			continue
		for(var/image_echo in images[from_when])
			echolocate_receiver.client.images -= image_echo
	images -= from_when
	receivers -= from_when

/obj/screen/fullscreen/echo
	icon_state = "echo"
	layer = ECHO_LAYER
	show_when_dead = TRUE

/obj/screen/fullscreen/echo/Initialize(mapload)
	. = ..()
	particles = new /particles/echo()

/obj/screen/fullscreen/echo/Destroy()
	QDEL_NULL(particles)
	return ..()

//tg stuff

/*
	Adds an instance of colour_type to the mob's client_colours list
	colour_type - a typepath (subtyped from /datum/client_colour)
*/
/mob
	var/list/client_colours = list()

/mob/proc/add_client_colour(colour_type)
	if(!ispath(colour_type, /datum/client_colour))
		return
	var/datum/client_colour/CC = new colour_type()
	client_colours |= CC
	sortTim(client_colours, /proc/cmp_clientcolour_priority)
	update_client_colour()

/mob/proc/remove_client_colour(colour_type)
	if(!ispath(colour_type, /datum/client_colour))
		return

	for(var/cc in client_colours)
		var/datum/client_colour/CC = cc
		if(CC.type == colour_type)
			client_colours -= CC
			qdel(CC)
			break
	update_client_colour()

/proc/cmp_clientcolour_priority(datum/client_colour/A, datum/client_colour/B)
	return B.priority - A.priority

/*
	Define subtypes of this datum
*/
/datum/client_colour
	var/colour = "" //Any client.color-valid value
	var/priority = 1 //Since only one client.color can be rendered on screen, we take the one with the highest priority value:
	//eg: "Bloody screen" > "goggles colour" as the former is much more important. EDIT: So, there is only one client_colour, so it's kinda don't work

/datum/client_colour/echolocate
	colour = "#25a5ea"
	priority = INFINITY
