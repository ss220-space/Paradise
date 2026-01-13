#define MAX_SANE_LAYERS 50

/// A datum tying together a greyscale configuration and dmi file. Required for using GAGS and handles the code interactions.
/datum/greyscale_config
	/// User friendly name used in the debug menu
	var/name
	/// Reference to the json config file
	var/json_config

	/// Reference to the dmi file for this config
	var/icon_file

	///////////////////////////////////////////////////////////////////////////////////////////
	// Do not set any further vars, the json file specified above is what generates the object

	/// Spritesheet width of the icon_file
	var/width

	/// Spritesheet height of the icon_file
	var/height

	/// String path to the json file, used for reloading
	var/string_json_config

	/// The md5 file hash for the json configuration. Used to check if the file has changed
	var/json_config_hash

	/// The raw string contents of the JSON config file.
	var/raw_json_string

	/// String path to the icon file, used for reloading
	var/string_icon_file

	/// The md5 file hash for the icon file. Used to check if the file has changed
	var/icon_file_hash

	/// A list of icon states and their layers
	var/list/icon_states

	/// A list of all layers irrespective of nesting
	var/list/flat_all_layers

	/// A list of types to update in the world whenever a config changes
	var/list/live_edit_types

	/// How many colors are expected to be given when building the sprite
	var/expected_colors = 0

	/// Generated icons keyed by their color arguments
	var/list/icon_cache

// There's more sanity checking here than normal because this is designed for spriters to work with
// Sensible error messages that tell you exactly what's wrong is the best way to make this easy to use
/datum/greyscale_config/New()
	if(!json_config)
		stack_trace("Greyscale config object [debug_name()] is missing a json configuration, make sure `json_config` has been assigned a value.")
	string_json_config = "[json_config]"
	if(!icon_file)
		stack_trace("Greyscale config object [debug_name()] is missing an icon file, make sure `icon_file` has been assigned a value.")
	string_icon_file = "[icon_file]"
	if(findtext(string_json_config, "code/datums/greyscale/json_configs/") != 1)
		stack_trace("All greyscale json configuration files should be located within 'code/datums/greyscale/json_configs/'")
	if(!name)
		stack_trace("Greyscale config object [debug_name()] is missing a name, make sure `name` has been assigned a value.")

/datum/greyscale_config/Destroy(force, ...)
	if(!force)
		return QDEL_HINT_LETMELIVE
	return ..()

/datum/greyscale_config/process(delta_time)
	if(!refresh(load_from_disk = TRUE))
		return

	if(!live_edit_types)
		return

	for(var/atom/thing in world)
		if(live_edit_types[thing.type])
			thing.update_greyscale()

/datum/greyscale_config/proc/enable_auto_refresh(live_type)
	message_admins("Config auto refresh has been enabled for '[live_type]' with configuration [debug_name()]. Expect heavy lag.")
	if(live_type)
		if(!live_edit_types)
			live_edit_types = list()
		live_edit_types += typecacheof(live_type)
	START_PROCESSING(SSgreyscale, src)

/datum/greyscale_config/proc/disable_auto_refresh(live_type, remove_all=FALSE)
	if(!remove_all && !(live_type in live_edit_types))
		return

	message_admins("Config auto refresh has been disabled for '[live_type]' with configuration [debug_name()]")
	if(remove_all)
		live_edit_types = null

	else if(live_type && live_edit_types)
		live_edit_types -= typecacheof(live_type)

	if(!length(live_edit_types))
		live_edit_types = null
		STOP_PROCESSING(SSgreyscale, src)

/// Call this proc to handle all the data extraction from the json configuration. Can be forced to load values from disk instead of memory.
/datum/greyscale_config/proc/refresh(load_from_disk = FALSE)
	if(load_from_disk)
		var/changed = FALSE

		json_config = file(string_json_config)
		var/json_hash = rustlib_hash_file(RUSTLIB_HASH_MD5, string_json_config)
		if(json_config_hash != json_hash)
			json_config_hash = json_hash
			changed = TRUE

		icon_file = file(string_icon_file)
		var/icon_hash = rustlib_hash_file(RUSTLIB_HASH_MD5, icon_file)
		if(icon_file_hash != icon_hash)
			icon_file_hash = icon_hash
			changed = TRUE

		for(var/datum/greyscale_layer/layer as anything in flat_all_layers)
			if(layer.disk_refresh())
				changed = TRUE

		if(!changed)
			return FALSE

	raw_json_string = rustlib_file_read(string_json_config)
	var/list/raw = json_decode(raw_json_string)
	read_icon_state_configuration(raw)

	if(!length(icon_states))
		CRASH("The json configuration [debug_name()] doesn't have any icon states.")

	icon_cache = list()

	ReadMetadata()
	SEND_SIGNAL(src, COMSIG_GREYSCALE_CONFIG_REFRESHED)

	return TRUE

/// Called after every config has refreshed, this proc handles data verification that depends on multiple entwined configurations.
/datum/greyscale_config/proc/cross_verify()
	for(var/icon_state in icon_states)
		var/list/verification_targets = icon_states[icon_state]
		verification_targets = verification_targets.Copy()
		while(length(verification_targets))
			var/datum/greyscale_layer/layer = verification_targets[length(verification_targets)]
			verification_targets.len--

			if(islist(layer))
				verification_targets += layer
				continue

			layer.cross_verify()

/// Gets the name used for debug purposes
/datum/greyscale_config/proc/debug_name()
	var/display_name = name || "MISSING_NAME"
	return "[display_name] ([icon_file]|[json_config])"

/// Takes the json icon state configuration and puts it into a more processed format.
/datum/greyscale_config/proc/read_icon_state_configuration(list/data)
	icon_states = list()
	for(var/state in data)
		var/list/raw_layers = data[state]
		if(!length(raw_layers))
			stack_trace("The json configuration [debug_name()] for icon state '[state]' is missing any layers.")
			continue
		if(icon_states[state])
			stack_trace("The json configuration [debug_name()] has a duplicate icon state '[state]' and is being overriden.")
		icon_states[state] = read_layers_from_json(raw_layers)

/// Takes the json layers configuration and puts it into a more processed format
/datum/greyscale_config/proc/read_layers_from_json(list/data)
	var/list/output = read_layer_group(data)
	return output[1]

/datum/greyscale_config/proc/read_layer_group(list/data)
	if(!islist(data[1]))
		var/layer_type = SSgreyscale.layer_types[data["type"]]
		if(!layer_type)
			CRASH("An unknown layer type was specified in the json of greyscale configuration [debug_name()]: [data["type"]]")
		return new layer_type(icon_file, data.Copy()) // We don't want anything in there touching our version of the data

	var/list/output = list()
	for(var/list/group as anything in data)
		output += read_layer_group(group)

	if(length(output)) // Adding lists to lists unwraps the top level so here we are
		output = list(output)
	return output

/// Reads layer configurations to take out some useful overall information
/datum/greyscale_config/proc/ReadMetadata()
	var/list/icon_dimensions = get_icon_dimensions(icon_file)
	height = icon_dimensions["width"]
	width = icon_dimensions["height"]

	var/list/datum/greyscale_layer/all_layers = list()

	for(var/state in icon_states)
		var/list/to_process = list(icon_states[state])
		var/list/state_layers = list()

		while(length(to_process))
			var/current = to_process[length(to_process)]
			to_process.len--
			if(islist(current))
				to_process += current
			else
				state_layers += current

		all_layers += state_layers

		if(length(state_layers) > MAX_SANE_LAYERS)
			stack_trace("[debug_name()] icon state '[state]' has [length(state_layers)] layers which is larger than the max of [MAX_SANE_LAYERS].")

	flat_all_layers = list()
	var/list/color_groups = list()
	var/largest_id = 0
	for(var/datum/greyscale_layer/layer as anything in all_layers)
		for(var/id in layer.color_ids)
			if(!isnum(id))
				continue

			largest_id = max(id, largest_id)
			color_groups["[id]"] = TRUE

	for(var/i in 1 to largest_id)
		if(color_groups["[i]"])
			continue

		stack_trace("Color Ids are required to be sequential and start from 1. [debug_name()] has a max id of [largest_id] but is missing [i].")

	expected_colors = length(color_groups)

/// For saving a dmi to disk, useful for debug mainly
/datum/greyscale_config/proc/save_output(color_string)
	var/icon/icon_output = generate_bundle(color_string)
	fcopy(icon_output, "tmp/gags_debug_output.dmi")

/// Actually create the icon and color it in, handles caching
/datum/greyscale_config/proc/generate(color_string, icon/last_external_icon)
	var/key = color_string
	var/icon/new_icon = icon_cache[key]
	if(new_icon)
		return icon(new_icon)

	var/icon/icon_bundle = generate_bundle(color_string, last_external_icon = last_external_icon)
	icon_bundle = fcopy_rsc(icon_bundle)

	icon_cache[key] = icon_bundle
	var/icon/output = icon(icon_bundle)
	return output

/// Handles the actual icon manipulation to create the spritesheet
/datum/greyscale_config/proc/generate_bundle(list/colors, list/render_steps, icon/last_external_icon)
	if(!istype(colors))
		colors = parse_color_string(colors)

	if(length(colors) < expected_colors)
		CRASH("[debug_name()] expected [expected_colors] or more color arguments but only received [length(colors)]")

	var/list/generated_icons = list()
	for(var/icon_state in icon_states)
		var/list/icon_state_steps
		if(render_steps)
			icon_state_steps = render_steps[icon_state] = list()
		var/icon/generated_icon = generate_layer_group(colors, icon_states[icon_state], icon_state_steps, last_external_icon)
		// We read a pixel to force the icon to be fully generated before we let it loose into the world
		// I hate this
		generated_icon.GetPixel(1, 1)
		generated_icons[icon_state] = generated_icon

	var/icon/icon_bundle = generated_icons[""] || icon('icons/testing/greyscale_error.dmi')
	icon_bundle.Scale(width, height)
	generated_icons -= ""
	for(var/icon_state in generated_icons)
		icon_bundle.Insert(generated_icons[icon_state], icon_state)

	return icon_bundle

/// Internal recursive proc to handle nested layer groups
/datum/greyscale_config/proc/generate_layer_group(list/colors, list/group, list/render_steps, icon/last_external_icon)
	var/icon/new_icon
	for(var/datum/greyscale_layer/layer as anything in group)
		var/icon/layer_icon
		var/list/list_layer = layer
		if(islist(layer))
			layer_icon = generate_layer_group(colors, layer, render_steps, new_icon || last_external_icon)
			layer = list_layer[1] // When there are multiple layers in a group like this we use the first one's blend mode
		else
			layer_icon = layer.generate(colors, render_steps, new_icon || last_external_icon)

		if(!new_icon)
			new_icon = layer_icon
		else
			new_icon.Blend(layer_icon, layer.blend_mode)

		// These are so we can see the result of every step of the process in the preview ui
		if(render_steps)
			var/list/icon_data = list()
			render_steps += list(icon_data)
			icon_data["config_name"] = name
			icon_data["step"] = icon(layer_icon)
			icon_data["result"] = icon(new_icon)

	return new_icon

/datum/greyscale_config/proc/generate_debug(colors)
	var/list/output = list()
	var/list/debug_steps = list()
	output["steps"] = debug_steps

	output["icon"] = generate_bundle(colors, debug_steps)
	return output

/proc/parse_color_string(color_string)
	. = list()
	var/list/split_colors = splittext(color_string, "#")
	for(var/color in 2 to length(split_colors))
		. += "#[split_colors[color]]"

// ===============
// Universal Icons
// ===============

/datum/greyscale_config/proc/generate_universal_icon(color_string, target_bundle_state, datum/universal_icon/last_external_icon)
	return generate_bundle_universal_icon(color_string, target_bundle_state, last_external_icon=last_external_icon)

/// Handles the actual icon manipulation to create the spritesheet
/datum/greyscale_config/proc/generate_bundle_universal_icon(list/colors, target_bundle_state, datum/universal_icon/last_external_icon)
	if(!istype(colors))
		colors = parse_color_string(colors)
	if(length(colors) != expected_colors)
		CRASH("[debug_name()] expected [expected_colors] color arguments but received [length(colors)]")

	if(!(target_bundle_state in icon_states))
		CRASH("Invalid target bundle icon_state \"[target_bundle_state]\"! Valid icon_states: [icon_states.Join(", ")]")

	var/datum/universal_icon/icon_bundle = generate_layer_group_universal_icon(colors, icon_states[target_bundle_state], last_external_icon) || uni_icon('icons/effects/effects.dmi', "nothing")
	icon_bundle.scale(width, height)
	return icon_bundle

/// Internal recursive proc to handle nested layer groups
/datum/greyscale_config/proc/generate_layer_group_universal_icon(list/colors, list/group, datum/universal_icon/last_external_icon)
	var/datum/universal_icon/new_icon
	for(var/datum/greyscale_layer/layer as anything in group)
		var/datum/universal_icon/layer_icon
		if(islist(layer))
			layer_icon = generate_layer_group_universal_icon(colors, layer, new_icon || last_external_icon)
			var/list/layer_list = layer
			layer = layer_list[1] // When there are multiple layers in a group like this we use the first one's blend mode
		else
			layer_icon = layer.generate_universal_icon(colors, new_icon || last_external_icon)

		if(!new_icon)
			new_icon = layer_icon
		else
			new_icon.blend_icon(layer_icon, layer.blend_mode)
	return new_icon

#undef MAX_SANE_LAYERS
