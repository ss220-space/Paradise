#define DIGITAL_AURA_ALPHA 210

/datum/component/digital_aura
	var/previous_alpha
	var/previous_light_range
	var/previous_light_power
	var/previous_light_color
	var/previous_light_on

/datum/component/digital_aura/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/target = parent
	previous_alpha = target.alpha
	previous_light_range = target.light_range
	previous_light_power = target.light_power
	previous_light_color = target.light_color
	previous_light_on = target.light_on

	target.alpha = DIGITAL_AURA_ALPHA
	target.set_light(l_range = 2, l_power = 1, l_color = LIGHT_COLOR_BUBBLEGUM, l_on = TRUE)

/datum/component/digital_aura/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))

	var/atom/target = parent
	target.update_icon(UPDATE_OVERLAYS)

/datum/component/digital_aura/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)

	var/atom/target = parent
	if(QDELETED(target))
		return

	target.alpha = previous_alpha
	target.set_light(l_range = previous_light_range, l_power = previous_light_power, l_color = previous_light_color, l_on = previous_light_on)
	target.update_icon(UPDATE_OVERLAYS)

/datum/component/digital_aura/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER

	var/list/dimensions = get_icon_dimensions(source.icon)
	var/aura_icon
	switch(dimensions["width"])
		if(32)
			aura_icon = 'icons/effects/bitrunning.dmi'
		if(48)
			aura_icon = 'icons/effects/bitrunning_48.dmi'
		if(64)
			aura_icon = 'icons/effects/bitrunning_64.dmi'
		else
			return

	var/mutable_appearance/redshift = mutable_appearance(aura_icon, "redshift", layer = -MUTATIONS_LAYER)
	redshift.blend_mode = BLEND_MULTIPLY
	overlays += redshift
	overlays += mutable_appearance(aura_icon, "glitch", layer = -MUTATIONS_LAYER, alpha = 150)

#undef DIGITAL_AURA_ALPHA
