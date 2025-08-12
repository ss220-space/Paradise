// The proc you should always use to set the light of this atom.
// Nonesensical value for l_color default, so we can detect if it gets set to null.
#define NONSENSICAL_VALUE -99999
/atom/proc/set_light(l_range, l_power, l_color = NONSENSICAL_VALUE, l_on)
	if(l_range > 0 && l_range < MINIMUM_USEFUL_LIGHT_RANGE)
		l_range = MINIMUM_USEFUL_LIGHT_RANGE	//Brings the range up to 1.4, which is just barely brighter than the soft lighting that surrounds players.
	if(l_power != null)
		light_power = l_power

	if(l_range != null)
		light_range = l_range

	if(l_color != NONSENSICAL_VALUE)
		light_color = l_color

	if(!isnull(l_on))
		light_on = l_on

	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT, l_range, l_power, l_color, l_on)

	update_light()

#undef NONSENSICAL_VALUE

/atom/proc/remove_light()
	light_power = 0
	light_range = 0
	light_color = 0
	update_light()

// Will update the light (duh).
// Creates or destroys it if needed, makes it update values, makes sure it's got the correct source turf...
/atom/proc/update_light()
	SHOULD_NOT_SLEEP(TRUE)

	if(QDELETED(src))
		return

	if(light_system != STATIC_LIGHT)
		CRASH("update_light() for [src] with following light_system value: [light_system]")

	if (!light_power || !light_range || !light_on) // We won't emit light anyways, destroy the light source.
		QDEL_NULL(light)
	else
		if(!ismovable(loc)) // We choose what atom should be the top atom of the light here.
			. = src
		else
			. = loc

		if(light) // Update the light or create it if it does not exist.
			light.update(.)
		else
			light = new/datum/light_source(src, .)


/atom/proc/extinguish_light(force = FALSE)
	return


/atom/proc/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = LIGHT_COLOR_WHITE, _duration = FLASH_LIGHT_DURATION, _reset_lighting = TRUE)
	return

/turf/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = LIGHT_COLOR_WHITE, _duration = FLASH_LIGHT_DURATION, _reset_lighting = TRUE)
	if(!_duration)
		stack_trace("Lighting FX obj created on a turf without a duration")
	new /obj/effect/dummy/lighting_obj (src, _range, _power, _color, _duration)

/obj/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = LIGHT_COLOR_WHITE, _duration = FLASH_LIGHT_DURATION, _reset_lighting = TRUE)
	var/temp_color
	var/temp_power
	var/temp_range
	if(!_reset_lighting) //incase the obj already has a lighting color that you don't want cleared out after, ie computer monitors.
		temp_color = light_color
		temp_power = light_power
		temp_range = light_range
	set_light(_range, _power, _color)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), _reset_lighting ? initial(light_range) : temp_range, _reset_lighting ? initial(light_power) : temp_power, _reset_lighting ? initial(light_color) : temp_color), _duration, TIMER_OVERRIDE|TIMER_UNIQUE)

/mob/living/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = LIGHT_COLOR_WHITE, _duration = FLASH_LIGHT_DURATION, _reset_lighting = TRUE)
	mob_light(_color, _range, _power, _duration)

/mob/living/proc/mob_light(_color, _range, _power, _duration)
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj = new (src, _range, _power, _color, _duration)
	return mob_light_obj

/// Setter for the light power of this atom.
/atom/proc/set_light_power(new_power)
	if(new_power == light_power)
		return
	if(light_system == STATIC_LIGHT)
		set_light(l_power = new_power)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_POWER, new_power) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_power
	light_power = new_power
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_POWER, .)

/// Setter for the light range of this atom.
/atom/proc/set_light_range(new_range)
	if(new_range == light_range)
		return
	if(light_system == STATIC_LIGHT)
		set_light(l_range = new_range)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_RANGE, new_range) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_range
	light_range = new_range
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_RANGE, .)

/// Setter for the light color of this atom.
/atom/proc/set_light_color(new_color)
	if(new_color == light_color)
		return
	if(light_system == STATIC_LIGHT)
		set_light(l_color = new_color)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_COLOR, new_color) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_color
	light_color = new_color
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_COLOR, .)

/// Setter for whether or not this atom's light is on.
/atom/proc/set_light_on(new_value)
	if(new_value == light_on)
		return
	if(light_system == STATIC_LIGHT)
		set_light(l_on = new_value)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_ON, new_value) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_on
	light_on = new_value
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_ON, .)

/// Setter for the light flags of this atom.
/atom/proc/set_light_flags(new_value)
	if(new_value == light_flags)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_FLAGS, new_value) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_flags
	light_flags = new_value
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_FLAGS, .)

/atom/proc/update_bloom()
	cut_overlay(glow_overlay)
	cut_overlay(exposure_overlay)

	if(glow_icon && glow_icon_state)
		add_glow_overlay()

	if(exposure_icon && exposure_icon_state && (light_color != ""))
		add_exposure_overlay()

/atom/proc/add_glow_overlay()
	glow_overlay = image(icon = glow_icon, icon_state = glow_icon_state, dir = dir, layer = 1)
	glow_overlay.plane = LIGHTING_LAMPS_PLANE
	glow_overlay.blend_mode = BLEND_ADD

	if(glow_colored)
		var/datum/color_matrix/mat = new(
			light_color, 
			GLOB.lighting_effects_configuration["glow_contrast_base"] + GLOB.lighting_effects_configuration["glow_contrast_power"] * light_power,
			GLOB.lighting_effects_configuration["glow_brightness_base"] + GLOB.lighting_effects_configuration["glow_brightness_power"] * light_power)
		glow_overlay.color = mat.get()
	add_overlay(glow_overlay)

/atom/proc/add_exposure_overlay()
	exposure_overlay = image(icon = exposure_icon, icon_state = exposure_icon_state, dir = dir, layer = -1)
	exposure_overlay.plane = LIGHTING_EXPOSURE_PLANE
	exposure_overlay.blend_mode = BLEND_ADD
	exposure_overlay.appearance_flags = RESET_ALPHA | RESET_COLOR | KEEP_APART

	var/datum/color_matrix/mat = new(
		1,
		GLOB.lighting_effects_configuration["exposure_contrast_base"] + GLOB.lighting_effects_configuration["exposure_contrast_power"] * light_power,
		GLOB.lighting_effects_configuration["exposure_brightness_base"] + GLOB.lighting_effects_configuration["exposure_brightness_power"] * light_power)
	if(exposure_colored)
		mat.set_color(
			light_color,
			GLOB.lighting_effects_configuration["exposure_contrast_base"] + GLOB.lighting_effects_configuration["exposure_contrast_power"] * light_power,
			GLOB.lighting_effects_configuration["exposure_brightness_base"] + GLOB.lighting_effects_configuration["exposure_brightness_power"] * light_power)
	exposure_overlay.color = mat.get()

	var/icon/expo_template = icon(icon = exposure_icon, icon_state = exposure_icon_state)
	exposure_overlay.pixel_x = 16 - expo_template.Width() / 2
	exposure_overlay.pixel_y = 16 - expo_template.Height() / 2
	add_overlay(exposure_overlay)

/atom/proc/delete_lights()
	cut_overlay(glow_overlay)
	cut_overlay(exposure_overlay)
	QDEL_NULL(glow_overlay)
	QDEL_NULL(exposure_overlay)
