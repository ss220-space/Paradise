/obj/item/organ/internal/cyberimp/eyes
	name = "cybernetic eyes"
	desc = "artificial photoreceptors with specialized functionality."
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
	slot = INTERNAL_ORGAN_EYE_SIGHT_DEVICE
	parent_organ_zone = BODY_ZONE_PRECISE_EYES
	w_class = WEIGHT_CLASS_TINY

	var/vision_flags = 0
	var/see_in_dark = 0
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

	var/eye_colour = "#000000" // Should never be null
	var/flash_protect = FLASH_PROTECTION_NONE
	var/aug_message = "Your vision is augmented!"

/obj/item/organ/internal/cyberimp/eyes/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	var/mob/living/carbon/human/H = M
	if(istype(H) && eye_colour)
		H.update_body() //Apply our eye colour to the target.
	if(aug_message && !special)
		to_chat(owner, span_notice("[aug_message]"))
	M.update_sight()

/obj/item/organ/internal/cyberimp/eyes/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	M.update_sight()

/obj/item/organ/internal/cyberimp/eyes/proc/generate_icon(mob/living/carbon/human/HA)
	var/mob/living/carbon/human/H = HA
	if(!istype(H))
		H = owner
	var/icon/cybereyes_icon = new /icon('icons/mob/human_face.dmi', H.dna.species.eyes)
	cybereyes_icon.Blend(eye_colour, ICON_ADD) // Eye implants override native DNA eye color

	return cybereyes_icon

/obj/item/organ/internal/cyberimp/eyes/emp_act(severity)
	if(!owner || emp_proof)
		return
	if(emp_shielded(severity))
		return

	if(severity > 1)
		if(prob(10 * severity))
			return

	to_chat(owner, span_warning("Static obfuscates your vision!"))

	if(HAS_TRAIT(owner, TRAIT_ADVANCED_CYBERIMPLANTS))
		owner.EyeBlurry(1.5 SECONDS)
	else
		owner.flash_eyes(3, visual = TRUE)

/obj/item/organ/internal/cyberimp/eyes/meson
	name = "meson scanner implant"
	desc = "These cybernetic eyes will allow you to see the structural layout of the station, and, well, everything else."
	eye_colour = "#199900"
	icon_state = "mesonhud_implant"
	origin_tech = "materials=4;engineering=4;biotech=4;magnets=4"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	aug_message = "Suddenly, you realize how much of a mess the station really is..."

/obj/item/organ/internal/cyberimp/eyes/meson/insert(mob/living/carbon/human/user_human, special = FALSE)
	ADD_TRAIT(user_human, TRAIT_MESON_VISION, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/obj/item/organ/internal/cyberimp/eyes/meson/remove(mob/living/carbon/human/user_human, special = FALSE)
	REMOVE_TRAIT(user_human, TRAIT_MESON_VISION, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/obj/item/organ/internal/cyberimp/eyes/xray
	name = "X-ray implant"
	desc = "These cybernetic eye implants will give you X-ray vision. Blinking is futile."
	implant_color = "#000000"
	origin_tech = "materials=4;programming=4;biotech=7;magnets=4"
	vision_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/obj/item/organ/internal/cyberimp/eyes/thermals
	name = "Thermals implant"
	desc = "These cybernetic eye implants will give you Thermal vision. Vertical slit pupil included."
	icon_state = "thermal_implant"
	eye_colour = "#FFCC00"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = FLASH_PROTECTION_SENSITIVE
	origin_tech = "materials=5;programming=4;biotech=4;magnets=4"
	aug_message = "You see prey everywhere you look..."

/obj/item/organ/internal/cyberimp/eyes/thermals/empproof/emp_act(severity)
	if(emp_shielded(severity))
		return
	return

// HUD implants
/obj/item/organ/internal/cyberimp/eyes/hud
	name = "HUD implant"
	desc = "These cybernetic eyes will display a HUD over everything you see. Maybe."
	slot = INTERNAL_ORGAN_EYE_HUD_DEVICE
	var/HUDType = 0
	/// A list of extension kinds added to the examine text. Things like medical or security records.
	var/examine_extensions = EXAMINE_HUD_NONE

/obj/item/organ/internal/cyberimp/eyes/hud/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(HUDType)
		var/datum/atom_hud/H = GLOB.huds[HUDType]
		H.show_to(M)

/obj/item/organ/internal/cyberimp/eyes/hud/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(HUDType)
		var/datum/atom_hud/H = GLOB.huds[HUDType]
		H.hide_from(M)

/obj/item/organ/internal/cyberimp/eyes/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	icon_state = "medhud_implant"
	eye_colour = "#0000D0"
	origin_tech = "materials=4;programming=4;biotech=4"
	aug_message = "You suddenly see health bars floating above people's heads..."
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL

/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	name = "Diagnostic HUD implant"
	desc = "These cybernetic eye implants will display a diagnostic HUD over everything you see."
	icon_state = "diagnosticalhud_implant"
	eye_colour = "#723E02"
	origin_tech = "materials=4;engineering=4;biotech=4"
	aug_message = "You see the diagnostic information of the synthetics around you..."
	HUDType = DATA_HUD_DIAGNOSTIC

/obj/item/organ/internal/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	icon_state = "sechud_implant"
	eye_colour = "#D00000"
	origin_tech = "materials=4;programming=4;biotech=3;combat=3"
	aug_message = "Job indicator icons pop up in your vision. That is not a certified surgeon..."
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE

/obj/item/organ/internal/cyberimp/eyes/hud/science
	name = "Science HUD implant"
	desc = "These cybernetic eye implants with an analyzer for scanning items and reagents."
	icon_state = "sciencehud_implant"
	item_state = "sciencehud_implant"
	implant_overlay = null
	eye_colour = "#923DAC"
	origin_tech = "materials=4;programming=4;biotech=4"
	aug_message = "You see the technological nature of things around you."
	examine_extensions = EXAMINE_HUD_SCIENCE
	actions_types = list(/datum/action/item_action/toggle_research_scanner)

// Welding shield implant
/obj/item/organ/internal/cyberimp/eyes/shield
	name = "welding shield implant"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	icon_state = "welding_implant"
	slot = INTERNAL_ORGAN_EYE_SHIELD_DEVICE
	origin_tech = "materials=4;biotech=3;engineering=4;plasmatech=3"
	flash_protect = FLASH_PROTECTION_WELDER
	// Welding with thermals will still hurt your eyes a bit.

/obj/item/organ/internal/cyberimp/eyes/shield/emp_act(severity)
	if(emp_shielded(severity))
		return
	return

/obj/item/organ/internal/cyberimp/eyes/hud/universal
	name = "universal HUD implant"
	desc = "Устанавливает подходящий вашей должности ИЛС имплант. Менее приоритетный, чем выбранные вручную импланты."
	icon_state = "universal_implant"
	aug_message = "Этот имплант не имеет смысла..."

/obj/item/organ/internal/cyberimp/eyes/hud/universal/get_ru_names()
		return list(
		NOMINATIVE = "универсальный ИЛС имплант",
		GENITIVE = "универсального ИЛС импланта",
		DATIVE = "универсальному ИЛС импланту",
		ACCUSATIVE = "универсальный ИЛС имплант",
		INSTRUMENTAL = "универсальным ИЛС имплантом",
		PREPOSITIONAL = "универсальном ИЛС импланте",
	)

// MARK: mini map implant
/obj/item/organ/internal/cyberimp/eyes/map
	name = "citizen map implant"
	desc = "Имплант для постоянного отображения мини-карты в левом верхнем углу поля зрения пользователя с помощью технологии дополненной реальности."
	icon_state = "citizen_map_implant"
	eye_colour = "#4255e6"
	slot = INTERNAL_ORGAN_EYE_HUD_DEVICE
	origin_tech = "materials=4;biotech=3;engineering=4;plasmatech=3"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/active = FALSE
	/// Z level for draw
	var/current_z_level
	/// Last mini map redraw turf
	var/turf/current_turf
	/// The various images and icons for the map are stored in here, as well as the actual big map itself.
	var/datum/station_holomap/holomap_datum
	/// Global station map crop position x (bottom left)
	var/crop_x = 0
	/// Global station map crop position y (bottom left)
	var/crop_y = 0
	/// Global station map crop size
	var/crop_size = 80

/obj/item/organ/internal/cyberimp/eyes/map/Destroy()
	holomap_datum = null
	current_turf = null
	return ..()

/obj/item/organ/internal/cyberimp/eyes/map/ui_action_click(mob/user, datum/action/action, leftclick)
	active = !active
	if(active)
		show_mini_map(user)
	else
		hide_mini_map(user)

/obj/item/organ/internal/cyberimp/eyes/map/proc/show_mini_map(mob/user)
	if(!user?.client || user.hud_used.mini_holomap.used_station_map)
		return FALSE

	current_z_level = user.loc.z
	holomap_datum = new()
	setup_holomap(user)
	if(!holomap_datum)
		// Something is very wrong if we have to un-fuck ourselves here.
		stack_trace("Mini holomap at [user.name]([COORD(user)]) couldn't setup holomap_datum.")
		to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] сбоит и выдает сообщение: \"ОШИБКА: NTOS не отвечает.\""))
		return

	var/datum/hud/human/user_hud = user.hud_used
	holomap_datum.base_map.loc = user_hud.mini_holomap  // Put the image on the holomap hud
	holomap_datum.base_map.alpha = 0 // Set to transparent so we can fade in
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(check_position))

	playsound(user, 'sound/effects/holomap_open.ogg', 125)
	animate(holomap_datum.base_map, alpha = 255, time = 5, easing = LINEAR_EASING)

	user.hud_used.mini_holomap.used_station_map = src
	user.hud_used.mini_holomap.used_base_map = holomap_datum.base_map
	user.hud_used.mini_holomap.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	user.client.screen |= user.hud_used.mini_holomap
	user.client.images |= holomap_datum.base_map

	if(holomap_datum.bogus)
		to_chat(user, span_warning("Ошибка инициализации голокарты. Этот сектор пространства невозможно отобразить."))
	else
		to_chat(user, span_warning("На краю поля зрения появляется голографическая проекция станции."))

	return TRUE

/obj/item/organ/internal/cyberimp/eyes/map/proc/setup_holomap(mob/user)
	current_turf = get_turf(user)
	crop_x = HOLOMAP_CENTER_X + current_turf.x - round(crop_size/2)
	crop_y = HOLOMAP_CENTER_X + current_turf.y - round(crop_size/2)
	var/list/crop_params = list(CROP_X1 = crop_x, CROP_Y1 = crop_y, CROP_X2 = crop_x + crop_size, CROP_Y2 = crop_y + crop_size)
	holomap_datum.initialize_holomap(current_turf, current_z_level, reinit_base_map = TRUE, extra_overlays = handle_overlays(user), show_legend = FALSE, crop = crop_params)


/obj/item/organ/internal/cyberimp/eyes/map/proc/handle_overlays(mob/user)
	// Each entry in this list contains the text for the legend, and the icon and icon_state use. Null or non-existent icon_state ignore hiding logic.
	// If an entry contains an icon,
	var/list/legend = list() //+ GLOB.holomap_default_legend

	var/list/z_transitions = SSholomaps.holomap_z_transitions["[current_z_level]"]
	if(length(z_transitions))
		legend += z_transitions
	return legend

/obj/item/organ/internal/cyberimp/eyes/map/proc/create_overlay_icon(icon_name, turf/target_loc, list/output)
	if(target_loc.z != current_z_level || !is_in_crop_area(target_loc))
		return
	var/image/overlay_icon = image('icons/misc/8x8.dmi', icon_state = icon_name)
	overlay_icon.pixel_w = HOLOMAP_CENTER_X + target_loc.x - crop_x - 1
	overlay_icon.pixel_z = HOLOMAP_CENTER_Y + target_loc.y - crop_y - 1
	output += overlay_icon

/obj/item/organ/internal/cyberimp/eyes/map/proc/create_overlays_entry(list/overlays, name, icon_name, list/markers)
	if(!length(markers))
		return
	overlays[name] = list("icon" = image('icons/misc/8x8.dmi', icon_state = icon_name), "markers" = markers)

/obj/item/organ/internal/cyberimp/eyes/map/proc/is_in_crop_area(turf/target)
	return target.x >= (current_turf.x - crop_size / 2)  && target.x <= (current_turf.x + crop_size / 2)\
		&& target.y >= (current_turf.y - crop_size / 2)  && target.y <= (current_turf.y + crop_size / 2)


/obj/item/organ/internal/cyberimp/eyes/map/proc/check_position(mob/moved_mob)
	SIGNAL_HANDLER

	if(!moved_mob)
		return

	if(!moved_mob.client)
		return

	current_z_level = moved_mob.loc.z
	moved_mob.client.images -= holomap_datum.base_map
	setup_holomap(moved_mob)
	holomap_datum.base_map.loc = moved_mob.hud_used.mini_holomap
	moved_mob.hud_used.mini_holomap.used_base_map = holomap_datum.base_map
	moved_mob.client.images |= holomap_datum.base_map


/obj/item/organ/internal/cyberimp/eyes/map/proc/hide_mini_map(mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	playsound(src, 'sound/effects/holomap_close.ogg', 125)

	to_chat(user, span_interface("Мини-карта исчезает."))
	if(!user.client)
		holomap_datum.reset_map()
		return

	animate(holomap_datum.base_map, alpha = 0, time = 5, easing = LINEAR_EASING)
	addtimer(CALLBACK(src, PROC_REF(remove_mini_map), user), 5)

/obj/item/organ/internal/cyberimp/eyes/map/proc/remove_mini_map(mob/user)
	if(!user || !user.client)
		return
	user.client.screen -= user.hud_used.mini_holomap
	user.client.images -= holomap_datum.base_map
	user.hud_used.mini_holomap.used_station_map = null
	user.hud_used.mini_holomap.used_base_map = null
	holomap_datum.reset_map()


/obj/item/organ/internal/cyberimp/eyes/map/security
	name = "security map implant "
	desc = "Имплант для постоянного отображения мини-карты в левом верхнем углу поля зрения пользователя с помощью технологии дополненной реальности. Показывает владельцев импланта защиты разума."
	icon_state = "security_map_implant"
	eye_colour = "#e41618"

/obj/item/organ/internal/cyberimp/eyes/map/security/handle_overlays(mob/user)
	var/list/extra_overlays = ..()
	if(holomap_datum.bogus)
		return extra_overlays

	var/list/mindshields = list()
	for(var/mob/living/carbon/human/check as anything in GLOB.human_list)
		if(check == user)
			continue
		if(!ismindshielded(check))
			continue
		var/turf/check_turf = get_turf(check)
		create_overlay_icon("security", check_turf, mindshields)

	create_overlays_entry(extra_overlays, "Mindshields", icon_name = "security", markers = mindshields)
	return extra_overlays


/obj/item/organ/internal/cyberimp/eyes/map/medical
	name = "medical map implant "
	desc = "Имплант для постоянного отображения мини-карты в левом верхнем углу поля зрения пользователя с помощью технологии дополненной реальности. Показывает медицинские датчики и критическе состояния."
	icon_state = "medical_map_implant"
	eye_colour = "#00e3e3"

/obj/item/organ/internal/cyberimp/eyes/map/medical/handle_overlays(mob/user)
	var/list/extra_overlays = ..()
	if(holomap_datum.bogus)
		return extra_overlays

	var/list/death_bodies = list()
	var/list/critical_states = list()
	var/list/medical_sensors = list()
	for(var/mob/living/carbon/human/check as anything in GLOB.human_list)
		if(check == user)
			continue
		var/turf/check_turf = get_turf(check)
		if(check.is_dead())
			create_overlay_icon("death_body", check_turf, death_bodies)
		else if(check.is_in_crit())
			create_overlay_icon("critical_state", check_turf, critical_states)
		else if(hassensorlevel(check, SUIT_SENSOR_TRACKING))
			create_overlay_icon("medical_sensor", check_turf, medical_sensors)

	create_overlays_entry(extra_overlays, "Death bodies", icon_name = "death_body", markers = death_bodies)
	create_overlays_entry(extra_overlays, "Critical states", icon_name = "critical_state", markers = critical_states)
	create_overlays_entry(extra_overlays, "Medical sensors", icon_name = "medical_sensor", markers = medical_sensors)
	return extra_overlays


/obj/item/organ/internal/cyberimp/eyes/map/fire
	name = "fire map implant "
	desc = "Имплант для постоянного отображения мини-карты в левом верхнем углу поля зрения пользователя с помощью технологии дополненной реальности. Показывает отсеки с активной пожарной сигнализацией."
	icon_state = "fire_map_implant"
	eye_colour = "#0abd33"

/obj/item/organ/internal/cyberimp/eyes/map/fire/handle_overlays(mob/user)
	var/list/extra_overlays = ..()
	if(holomap_datum.bogus)
		return extra_overlays

	var/list/fire_alarms = list()
	for(var/obj/machinery/firealarm/alarm as anything in GLOB.station_fire_alarms["[current_z_level]"])
		if(!alarm?.myArea?.fire)
			continue
		var/alarm_turf = get_turf(alarm)
		create_overlay_icon("fire_marker", alarm_turf, fire_alarms)

	var/list/air_alarms = list()
	for(var/obj/machinery/alarm/air_alarm in GLOB.air_alarms)
		var/area/alarms = get_area(air_alarm)
		if(alarms?.atmosalm == ATMOS_ALARM_NONE)
			continue
		var/alarm_turf = get_turf(air_alarm)
		create_overlay_icon("atmos_marker", alarm_turf, air_alarms)

	create_overlays_entry(extra_overlays, "Fire Alarms", icon_name = "fire_marker", markers = fire_alarms)
	create_overlays_entry(extra_overlays, "Air Alarms", icon_name = "atmos_marker", markers = air_alarms)
	return extra_overlays


/obj/item/organ/internal/cyberimp/eyes/map/nuke
	name = "nuke ops map implant "
	desc = "Имплант для постоянного отображения мини-карты в левом верхнем углу поля зрения пользователя с помощью технологии дополненной реальности. Показывает членов вашего отряда и остальных живых целей. Также показывает где находится диск."
	icon_state = "nuke_map_implant"
	eye_colour = "#292929"

/obj/item/organ/internal/cyberimp/eyes/map/nuke/handle_overlays(mob/user)
	var/list/extra_overlays = ..()
	if(holomap_datum.bogus)
		return extra_overlays

	var/list/teammates = list()
	var/list/crew_members = list()
	for(var/mob/living/carbon/human/check as anything in GLOB.human_list)
		if(check == user)
			continue
		var/turf/check_turf = get_turf(check)
		if(isAntag(check))
			create_overlay_icon("nuker", check_turf, teammates)
		else if(!check.is_dead())
			create_overlay_icon("crew", check_turf, teammates)

	var/list/nuclear_disks = list()
	for(var/obj/item/disk/nuclear/the_disk in GLOB.poi_list)
		var/turf/disk_location = get_turf(the_disk)
		create_overlay_icon("nuclear_disk", disk_location, nuclear_disks)

	create_overlays_entry(extra_overlays, "Teammates", icon_name = "nuker", markers = teammates)
	create_overlays_entry(extra_overlays, "Crew members", icon_name = "crew", markers = crew_members)
	create_overlays_entry(extra_overlays, "Nuclear authentification disk", icon_name = "nuclear_disk", markers = nuclear_disks)
	return extra_overlays

