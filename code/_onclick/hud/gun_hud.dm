/**
 * HUD ammo indicator
 *
 * Displays a number and an icon representing the ammo.
 */

/atom/movable/screen/ammo
	name = "ammo counter"
	icon = 'icons/hud/gun_hud.dmi'
	icon_state = "ammo_red"
	screen_loc = ui_ammo1
	/// If the user has already had their warning played for running out of ammo
	var/warned = FALSE
	/// Holder for playing a out of ammo animation so that it doesnt get cut during updates
	var/atom/movable/flash_holder
	/// List of possible screen locs
	var/static/list/ammo_screen_loc_list = list(ui_ammo1, ui_ammo2, ui_ammo3, ui_ammo4)

	/// This is the color assigned to the OTH backing, numbers and indicator.
	var/backing_color = COLOR_RED

/atom/movable/screen/ammo/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	flash_holder = new
	flash_holder.icon_state = "frame"
	flash_holder.icon = icon
	flash_holder.vis_flags = VIS_INHERIT_PLANE
	flash_holder.layer = layer+0.001
	flash_holder.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_contents += flash_holder

/// wrapper to add this to the users screen with a owner
/atom/movable/screen/ammo/proc/add_hud(mob/living/user, datum/ammo_owner)
	if(isnull(ammo_owner))
		CRASH("/atom/movable/screen/ammo/proc/add_hud() has been called from [src] without the required param of ammo_owner")
	user?.client?.screen += src

/// wrapper to removing this ammo hud from the users screen
/atom/movable/screen/ammo/proc/remove_hud(mob/living/user)
	user?.client?.screen -= src

/// used for ammo overlay colours
/atom/movable/screen/ammo/proc/set_hud(ammo_overlay, ammo_colour)
	if(ammo_overlay)
		icon_state = ammo_overlay
	if(ammo_colour)
		backing_color = ammo_colour

///actually handles upadating the hud
/atom/movable/screen/ammo/proc/update_hud(mob/living/user, rounds)
	overlays.Cut()

	if(rounds <= 0)
		var/image/empty_image = image('icons/hud/gun_hud.dmi', src, "o0")
		empty_image.color = COLOR_RED
		overlays += empty_image

		var/image/empty_state = image('icons/hud/gun_hud.dmi', src, "empty")
		empty_state.color = COLOR_RED
		overlays += empty_state

		if(warned)
			return
		warned = TRUE
		flick("empty_flash", flash_holder)
		return

	warned = FALSE
	rounds = num2text(rounds)

	//Handle the amount of rounds. Probably we could do it better, but i don't know how
	switch(length(rounds))
		if(1)
			var/image/overlay_image_1 = image('icons/hud/gun_hud.dmi', src, "o[rounds[1]]")
			overlay_image_1.color = backing_color
			overlays += overlay_image_1
		if(2)
			var/image/overlay_image_2 = image('icons/hud/gun_hud.dmi', src, "o[rounds[2]]")
			overlay_image_2.color = backing_color
			overlays += overlay_image_2

			var/image/second_overlay_image_2 = image('icons/hud/gun_hud.dmi', src, "t[rounds[1]]")
			second_overlay_image_2.color = backing_color
			overlays += second_overlay_image_2

		if(3)
			var/image/overlay_image_3 = image('icons/hud/gun_hud.dmi', src, "o[rounds[3]]")
			overlay_image_3.color = backing_color
			overlays += overlay_image_3

			var/image/second_overlay_image_3 = image('icons/hud/gun_hud.dmi', src, "t[rounds[2]]")
			second_overlay_image_3.color = backing_color
			overlays += second_overlay_image_3

			var/image/third_overlay_image_3 = image('icons/hud/gun_hud.dmi', src, "h[rounds[1]]")
			third_overlay_image_3.color = backing_color
			overlays += third_overlay_image_3
		else //"0" is still length 1 so this means it's over 999
			var/image/overlay_image_4 = image('icons/hud/gun_hud.dmi', src, "o9")
			overlay_image_4.color = backing_color
			overlays += overlay_image_4

			var/image/second_overlay_image_4 = image('icons/hud/gun_hud.dmi', src, "t9")
			second_overlay_image_4.color = backing_color
			overlays += second_overlay_image_4

			var/image/third_overlay_image_4 = image('icons/hud/gun_hud.dmi', src, "h9")
			third_overlay_image_4.color = backing_color
			overlays += third_overlay_image_4
