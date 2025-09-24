//Science modules for MODsuits

///Reagent Scanner - Lets the user scan reagents.
/obj/item/mod/module/reagent_scanner
	name = "MOD reagent scanner module"
	desc = "A module based off research-oriented Nanotrasen HUDs, this is capable of scanning the contents of \
		containers and projecting the information in an easy-to-read format on the wearer's display. \
		It cannot detect flavors, so that's up to you."
	icon_state = "scanner"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/reagent_scanner)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)

/obj/item/mod/module/reagent_scanner/get_ru_names()
	return list(
		NOMINATIVE = "модуль сканера реагентов для МЭК",
		GENITIVE = "модуля сканера реагентов для МЭК",
		DATIVE = "модулю сканера реагентов для МЭК",
		ACCUSATIVE = "модуль сканера реагентов для МЭК",
		INSTRUMENTAL = "модулем сканера реагентов для МЭК",
		PREPOSITIONAL = "модуле сканера реагентов для МЭК",
	)

/obj/item/mod/module/reagent_scanner/on_activation()
	var/obj/item/clothing/head/mod/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	var/obj/item/clothing/glasses/glasses = mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(head_cover)
		head_cover.examine_extensions += EXAMINE_HUD_SCIENCE
	if(glasses)
		glasses.examine_extensions += EXAMINE_HUD_SCIENCE

/obj/item/mod/module/reagent_scanner/on_deactivation(display_message = TRUE, deleting = FALSE)
	var/obj/item/clothing/head/mod/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	var/obj/item/clothing/glasses/glasses = mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(head_cover)
		head_cover.examine_extensions -= EXAMINE_HUD_SCIENCE
	if(glasses)
		glasses.examine_extensions -= EXAMINE_HUD_SCIENCE


/obj/item/mod/module/reagent_scanner/advanced
	name = "MOD advanced reagent scanner module"
	complexity = 0
	removable = FALSE
	var/explosion_detection_dist = 21

/obj/item/mod/module/reagent_scanner/advanced/get_ru_names()
	return list(
		NOMINATIVE = "модуль продвинутого сканера реагентов для МЭК",
		GENITIVE = "модуля продвинутого сканера реагентов для МЭК",
		DATIVE = "модулю продвинутого сканера реагентов для МЭК",
		ACCUSATIVE = "модуль продвинутого сканера реагентов для МЭК",
		INSTRUMENTAL = "модулем продвинутого сканера реагентов для МЭК",
		PREPOSITIONAL = "модуле продвинутого сканера реагентов для МЭК",
	)

/obj/item/mod/module/reagent_scanner/advanced/on_activation()
	GLOB.doppler_arrays += src

/obj/item/mod/module/reagent_scanner/advanced/on_deactivation(display_message = TRUE, deleting = FALSE)
	GLOB.doppler_arrays -= src

/obj/item/mod/module/reagent_scanner/advanced/proc/sense_explosion(x0, y0, z0, devastation_range, heavy_impact_range,
		light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	var/turf/T = get_turf(src)
	var/dx = abs(x0 - T.x)
	var/dy = abs(y0 - T.y)
	var/distance
	if(T.z != z0)
		return
	if(dx > dy)
		distance = dx
	else
		distance = dy
	if(distance > explosion_detection_dist)
		return
	to_chat(mod.wearer, span_notice("Explosion detected! Epicenter: [devastation_range], Outer: [heavy_impact_range], Shock: [light_impact_range]"))

///Teleporter - Lets the user teleport to a nearby location.
/obj/item/mod/module/anomaly_locked/teleporter
	name = "MOD teleporter module"
	desc = "A module that uses a bluespace core to let the user transport their particles elsewhere."
	icon_state = "teleporter"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	cooldown_time = 5 SECONDS
	accepted_anomalies = list(/obj/item/assembly/signaler/core/bluespace)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// Time it takes to teleport
	var/teleport_time = 1.25 SECONDS //This is a bluespace core this should be fast, like you can get a phazon with this man, we don't have anomaly refining either

/obj/item/mod/module/anomaly_locked/teleporter/get_ru_names()
	return list(
		NOMINATIVE = "модуль телепортера для МЭК",
		GENITIVE = "модуля телепортера для МЭК",
		DATIVE = "модулю телепортера для МЭК",
		ACCUSATIVE = "модуль телепортера для МЭК",
		INSTRUMENTAL = "модулем телепортера для МЭК",
		PREPOSITIONAL = "модуле телепортера для МЭК",
	)

/obj/item/mod/module/anomaly_locked/teleporter/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/turf/target_turf = get_turf(target)
	if(!istype(target_turf) || target_turf.density || !((target in view(9, mod.wearer)) || mod.wearer.sight & SEE_TURFS) || (get_dist(target_turf, get_turf(mod.wearer)) > 9)) //No. No camera bug shenanigins.
		return
	var/matrix/pre_matrix = matrix()
	pre_matrix.Scale(4, 0.25)
	var/matrix/post_matrix = matrix()
	post_matrix.Scale(0.25, 4)
	animate(mod.wearer, teleport_time, color = COLOR_CYAN, transform = pre_matrix.Multiply(mod.wearer.transform), easing = SINE_EASING|EASE_OUT)
	if(!do_after(mod.wearer, teleport_time, target = mod.wearer))
		animate(mod.wearer, teleport_time * 0.1, color = null, transform = post_matrix.Multiply(mod.wearer.transform), easing = SINE_EASING|EASE_IN)
		return
	animate(mod.wearer, teleport_time * 0.1, color = null, transform = post_matrix.Multiply(mod.wearer.transform), easing = SINE_EASING|EASE_IN)
	if(!do_teleport(mod.wearer, target_turf, asoundin = 'sound/effects/phasein.ogg'))
		return
	drain_power(use_energy_cost)

/obj/item/mod/module/anomaly_locked/teleporter/prebuilt
	prebuilt = TRUE

///Anti-Gravity - Makes the user weightless.
/obj/item/mod/module/anomaly_locked/antigrav
	name = "MOD anti-gravity module"
	desc = "A module that uses a gravitational core to make the user completely weightless."
	icon_state = "antigrav"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.7
	incompatible_modules = list( /obj/item/mod/module/anomaly_locked/antigrav) //TODO: add /obj/item/mod/module/atrocinator
	accepted_anomalies = list(/obj/item/assembly/signaler/core/gravitational)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)

/obj/item/mod/module/anomaly_locked/antigrav/on_activation()
	if(mod.wearer.get_gravity())
		new /obj/effect/temp_visual/mook_dust(get_turf(src))
	mod.wearer.AddElement(/datum/element/forced_gravity, 0)
	playsound(src, 'sound/effects/gravhit.ogg', 50)

/obj/item/mod/module/anomaly_locked/antigrav/on_deactivation(display_message = TRUE, deleting = FALSE)
	mod.wearer.RemoveElement(/datum/element/forced_gravity, 0)
	if(deleting)
		return
	if(mod.wearer.get_gravity())
		new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/effects/gravhit.ogg', 50)

/obj/item/mod/module/anomaly_locked/antigrav/prebuilt
	prebuilt = TRUE

// /obj/item/mod/module/anomaly_locked/antigrav/prebuilt/locked
// 	core_removable = FALSE
