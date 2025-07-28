/client/proc/debug_bloom()
	set name = "Bloom Edit"
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return
	var/datum/bloom_edit/editor = new()
	editor.ui_interact(usr)

	message_admins("[key_name(src)] opened Bloom Edit panel.")
	log_admin("[key_name(src)] opened Bloom Edit panel.")

/datum/bloom_edit

/datum/bloom_edit/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BloomEdit")
		ui.open()

/datum/bloom_edit/ui_data(mob/user)
	. = ..()

	.["glow_brightness_base"] = GLOB.lighting_effects_configuration["glow_brightness_base"]
	.["glow_brightness_power"] = GLOB.lighting_effects_configuration["glow_brightness_power"]
	.["glow_contrast_base"] = GLOB.lighting_effects_configuration["glow_contrast_base"]
	.["glow_contrast_power"] = GLOB.lighting_effects_configuration["glow_contrast_power"]
	.["exposure_brightness_base"] = GLOB.lighting_effects_configuration["exposure_brightness_base"]
	.["exposure_brightness_power"] = GLOB.lighting_effects_configuration["exposure_brightness_power"]
	.["exposure_contrast_base"] = GLOB.lighting_effects_configuration["exposure_contrast_base"]
	.["exposure_contrast_power"] = GLOB.lighting_effects_configuration["exposure_contrast_power"]

/datum/bloom_edit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("glow_brightness_base")
			GLOB.lighting_effects_configuration["glow_brightness_base"] = clamp(params["value"], -10, 10)
		if("glow_brightness_power")
			GLOB.lighting_effects_configuration["glow_brightness_power"] = clamp(params["value"], -10, 10)
		if("glow_contrast_base")
			GLOB.lighting_effects_configuration["glow_contrast_base"] = clamp(params["value"], -10, 10)
		if("glow_contrast_power")
			GLOB.lighting_effects_configuration["glow_contrast_power"] = clamp(params["value"], -10, 10)
		if("exposure_brightness_base")
			GLOB.lighting_effects_configuration["exposure_brightness_base"] = clamp(params["value"], -10, 10)
		if("exposure_brightness_power")
			GLOB.lighting_effects_configuration["exposure_brightness_power"] = clamp(params["value"], -10, 10)
		if("exposure_contrast_base")
			GLOB.lighting_effects_configuration["exposure_contrast_base"] = clamp(params["value"], -10, 10)
		if("exposure_contrast_power")
			GLOB.lighting_effects_configuration["exposure_contrast_power"] = clamp(params["value"], -10, 10)
		if("default")
			var/list/config = CONFIG_GET(keyed_list/lighting_effects_configuration)
			GLOB.lighting_effects_configuration["exposure_contrast_power"] = config["exposure_contrast_power"]
			GLOB.lighting_effects_configuration["glow_brightness_power"] = config["glow_brightness_power"]
			GLOB.lighting_effects_configuration["glow_contrast_base"] = config["glow_contrast_base"]
			GLOB.lighting_effects_configuration["glow_contrast_power"] = config["glow_contrast_power"]
			GLOB.lighting_effects_configuration["exposure_brightness_base"] = config["exposure_brightness_base"]
			GLOB.lighting_effects_configuration["exposure_brightness_power"] = config["exposure_brightness_power"]
			GLOB.lighting_effects_configuration["exposure_contrast_base"] = config["exposure_contrast_base"]
			GLOB.lighting_effects_configuration["exposure_contrast_power"] = config["exposure_contrast_power"]

		if("update_lamps")
			world.log << "UPDATE_LAMPS"
			for(var/obj/machinery/light/L in GLOB.machines)
				if(L.glow_overlay || L.exposure_overlay)
					L.update_bloom()
		else
			. = FALSE

/datum/bloom_edit/ui_state(mob/user)
	return GLOB.admin_state