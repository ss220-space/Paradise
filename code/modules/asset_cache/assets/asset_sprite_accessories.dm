#define ACCESSORY_PREVIEW_CROP_X1 9
#define ACCESSORY_PREVIEW_CROP_Y1 17
#define ACCESSORY_PREVIEW_CROP_X2 24
#define ACCESSORY_PREVIEW_CROP_Y2 32
#define ACCESSORY_PREVIEW_COLOR COLOR_DARK_BROWN
#define ACCESSORY_PREVIEW_SKIN_COLOR "#b07d5c"
#define ACCESSORY_PREVIEW_GRADIENT_HAIR "Long Hair"

/datum/asset/spritesheet_batched/sprite_accessories
	name = "sprite_accessories"
	ignore_dir_errors = TRUE
	var/list/preview_keys = list()

/datum/asset/spritesheet_batched/sprite_accessories/create_spritesheets()
	for(var/style in GLOB.hair_styles_full_list)
		insert_preview(ACCESSORY_CATEGORY_HAIR, style, build_head_preview(GLOB.hair_styles_full_list[style]))

	for(var/style in GLOB.facial_hair_styles_list)
		insert_preview(ACCESSORY_CATEGORY_FACIAL_HAIR, style, build_head_preview(GLOB.facial_hair_styles_list[style]))

	for(var/style in GLOB.head_accessory_styles_list)
		insert_preview(ACCESSORY_CATEGORY_HEAD_ACCESSORY, style, build_head_preview(GLOB.head_accessory_styles_list[style]))

	for(var/style in GLOB.hair_gradients_list)
		insert_preview(ACCESSORY_CATEGORY_HAIR_GRADIENT, style, build_gradient_preview(GLOB.hair_gradients_list[style]))

	for(var/style in GLOB.marking_styles_list)
		var/datum/sprite_accessory/body_markings/marking = GLOB.marking_styles_list[style]
		if(marking.marking_location == "head")
			insert_preview(ACCESSORY_CATEGORY_MARKING, style, build_head_preview(marking))
		else
			insert_preview(ACCESSORY_CATEGORY_MARKING, style, build_body_preview(marking))

	for(var/style in GLOB.alt_heads_list)
		insert_preview(ACCESSORY_CATEGORY_ALT_HEAD, style, build_alt_head_preview(GLOB.alt_heads_list[style]))

	for(var/style in GLOB.body_accessory_by_name)
		insert_preview(ACCESSORY_CATEGORY_BODY_ACCESSORY, style, build_body_accessory_preview(GLOB.body_accessory_by_name[style]))

	for(var/style in GLOB.underwear_list)
		insert_preview(ACCESSORY_CATEGORY_UNDERWEAR, style, build_undergarment_preview(GLOB.underwear_list[style], "uw"))

	for(var/style in GLOB.undershirt_list)
		insert_preview(ACCESSORY_CATEGORY_UNDERSHIRT, style, build_undergarment_preview(GLOB.undershirt_list[style], "us"))

	for(var/style in GLOB.socks_list)
		insert_preview(ACCESSORY_CATEGORY_SOCKS, style, build_undergarment_preview(GLOB.socks_list[style], "sk"))

/datum/asset/spritesheet_batched/sprite_accessories/proc/get_preview_key(category, style_name)
	var/list/category_keys = preview_keys[category]
	return category_keys?[style_name]

/datum/asset/spritesheet_batched/sprite_accessories/proc/insert_preview(category, style_name, datum/universal_icon/preview)
	if(!preview)
		return
	var/list/category_keys = preview_keys[category]
	if(!category_keys)
		category_keys = list()
		preview_keys[category] = category_keys
	var/key = "[category]_[length(category_keys)]"
	category_keys[style_name] = key
	insert_icon(key, preview)

/datum/asset/spritesheet_batched/sprite_accessories/proc/build_head_preview(datum/sprite_accessory/accessory)
	var/datum/universal_icon/preview = build_species_head(accessory.species_allowed)
	var/datum/universal_icon/layer = build_accessory_layer(accessory)
	if(layer)
		preview.blend_icon(layer, ICON_OVERLAY)
	return crop_to_head(preview)

/datum/asset/spritesheet_batched/sprite_accessories/proc/build_gradient_preview(datum/sprite_accessory/hair_gradient/gradient)
	var/datum/sprite_accessory/hair/reference = GLOB.hair_styles_public_list[ACCESSORY_PREVIEW_GRADIENT_HAIR]
	var/datum/universal_icon/preview = build_species_head(list(SPECIES_HUMAN))
	var/datum/universal_icon/hair = build_accessory_layer(reference)
	if(!hair)
		return crop_to_head(preview)

	preview.blend_icon(hair, ICON_OVERLAY)
	if(icon_exists(gradient.icon, gradient.icon_state))
		var/datum/universal_icon/tint = uni_icon(gradient.icon, "full")
		tint.blend_icon(uni_icon(gradient.icon, gradient.icon_state), ICON_AND)
		tint.blend_icon(uni_icon(reference.icon, "[reference.icon_state]_s"), ICON_AND)
		preview.blend_icon(tint, ICON_OVERLAY)
	return crop_to_head(preview)

/datum/asset/spritesheet_batched/sprite_accessories/proc/build_body_preview(datum/sprite_accessory/accessory)
	var/datum/universal_icon/preview = build_naked_body()
	var/datum/universal_icon/layer = build_accessory_layer(accessory)
	if(layer)
		preview.blend_icon(layer, ICON_OVERLAY)
	return preview

/datum/asset/spritesheet_batched/sprite_accessories/proc/build_alt_head_preview(datum/sprite_accessory/alt_heads/alt_head)
	var/datum/universal_icon/preview = build_species_head(alt_head.species_allowed, alt_head.icon_state)
	return crop_to_head(preview)

/datum/asset/spritesheet_batched/sprite_accessories/proc/build_body_accessory_preview(datum/body_accessory/accessory)
	if(!accessory || !icon_exists(accessory.icon, accessory.icon_state))
		return
	var/datum/universal_icon/layer = uni_icon(accessory.icon, accessory.icon_state, WEST)
	if(!isnull(accessory.blend_mode))
		layer.blend_color(ACCESSORY_PREVIEW_SKIN_COLOR, accessory.blend_mode)
	var/datum/universal_icon/preview = build_naked_body(WEST)
	preview.blend_icon(layer, ICON_OVERLAY)
	return preview

/datum/asset/spritesheet_batched/sprite_accessories/proc/build_undergarment_preview(datum/sprite_accessory/accessory, prefix)
	var/datum/universal_icon/preview = build_naked_body()
	var/state = "[prefix]_[accessory.icon_state]_s"
	if(icon_exists(accessory.icon, state))
		preview.blend_icon(uni_icon(accessory.icon, state), ICON_OVERLAY)
	return preview

/datum/asset/spritesheet_batched/sprite_accessories/proc/build_accessory_layer(datum/sprite_accessory/accessory)
	var/state = "[accessory.icon_state]_s"
	if(!icon_exists(accessory.icon, state))
		return
	var/datum/universal_icon/layer = uni_icon(accessory.icon, state)
	if(accessory.do_colouration)
		layer.blend_color(ACCESSORY_PREVIEW_COLOR, ICON_MULTIPLY)
	return layer

/datum/asset/spritesheet_batched/sprite_accessories/proc/build_naked_body(facing = SOUTH)
	var/static/list/body_states = list("torso_m", "groin_m", "head_m", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")
	var/datum/species/human = GLOB.all_species[SPECIES_HUMAN]
	var/datum/universal_icon/body = uni_icon(human.icobase, body_states[1], facing)
	for(var/state in body_states.Copy(2))
		body.blend_icon(uni_icon(human.icobase, state, facing), ICON_OVERLAY)
	return body

/datum/asset/spritesheet_batched/sprite_accessories/proc/build_species_head(list/species_allowed, head_state = "head")
	var/species_name = SPECIES_HUMAN
	if(length(species_allowed) && !(SPECIES_HUMAN in species_allowed))
		species_name = species_allowed[1]
	var/datum/species/species = GLOB.all_species[species_name] || GLOB.all_species[SPECIES_HUMAN]
	var/state = "[head_state]_m"
	if(!icon_exists(species.icobase, state))
		species = GLOB.all_species[SPECIES_HUMAN]
		state = "head_m"
	return uni_icon(species.icobase, state)

/datum/asset/spritesheet_batched/sprite_accessories/proc/crop_to_head(datum/universal_icon/preview)
	preview.crop(ACCESSORY_PREVIEW_CROP_X1, ACCESSORY_PREVIEW_CROP_Y1, ACCESSORY_PREVIEW_CROP_X2, ACCESSORY_PREVIEW_CROP_Y2)
	preview.scale(ICON_SIZE_X, ICON_SIZE_Y)
	return preview

#undef ACCESSORY_PREVIEW_CROP_X1
#undef ACCESSORY_PREVIEW_CROP_Y1
#undef ACCESSORY_PREVIEW_CROP_X2
#undef ACCESSORY_PREVIEW_CROP_Y2
#undef ACCESSORY_PREVIEW_COLOR
#undef ACCESSORY_PREVIEW_SKIN_COLOR
#undef ACCESSORY_PREVIEW_GRADIENT_HAIR
