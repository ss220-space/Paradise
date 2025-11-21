//Science modules for MODsuits
// MARK: Reagent scanner
/// Reagent Scanner - Lets the user scan reagents.
/obj/item/mod/module/reagent_scanner
	name = "MOD reagent scanner module"
	desc = "Модуль для МЭК, встраиваемый в визор костюма. Собирает и выводит на дисплей пользователя информацию о содержимом \
			различных ёмкостей. К счастью или нет, не может распознавать ароматы."
	icon_state = "scanner"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/reagent_scanner)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)

/obj/item/mod/module/reagent_scanner/get_ru_names()
	return list(
		NOMINATIVE = "модуль сканера реагентов",
		GENITIVE = "модуля сканера реагентов",
		DATIVE = "модулю сканера реагентов",
		ACCUSATIVE = "модуль сканера реагентов",
		INSTRUMENTAL = "модулем сканера реагентов",
		PREPOSITIONAL = "модуле сканера реагентов",
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
	desc = "Модуль для МЭК, встраиваемый в визор костюма. Улучшенная версия обычного сканера реагентов, собирающая информацию \
			о мощности ближайших взрывов и выводящая их на визор пользователя. Всё ещё не может распознавать ароматы."
	complexity = 0
	removable = FALSE
	var/explosion_detection_dist = 21

/obj/item/mod/module/reagent_scanner/advanced/get_ru_names()
	return list(
		NOMINATIVE = "модуль продвинутого сканера реагентов",
		GENITIVE = "модуля продвинутого сканера реагентов",
		DATIVE = "модулю продвинутого сканера реагентов",
		ACCUSATIVE = "модуль продвинутого сканера реагентов К",
		INSTRUMENTAL = "модулем продвинутого сканера реагентов",
		PREPOSITIONAL = "модуле продвинутого сканера реагентов",
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
	to_chat(mod.wearer, span_notice("Зафиксирован взрыв! Радиус эпицентра: [devastation_range], Радиус серьёзных повреждений: [heavy_impact_range], Радиус ударной волны: [light_impact_range]"))

// MARK: Teleporter
/// Teleporter - Lets the user teleport to a nearby location.
/obj/item/mod/module/anomaly_locked/teleporter
	name = "MOD teleporter module"
	desc = "Модуль для МЭК, использующий ядро блюспейс-аномалии для телепортации пользователя. \
			Безопасность процесса для последнего остаётся под вопросом."
	icon_state = "teleporter"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 500 //too good
	cooldown_time = 5 SECONDS
	accepted_anomalies = list(/obj/item/assembly/signaler/core/bluespace)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// Time it takes to teleport
	var/teleport_time = 1.25 SECONDS
	/// Maximum turf range
	var/max_range = 9
	///Limit of range, that we can get from the core
	var/limited_range = 12

/obj/item/mod/module/anomaly_locked/teleporter/get_ru_names()
	return list(
		NOMINATIVE = "модуль телепортера",
		GENITIVE = "модуля телепортера",
		DATIVE = "модулю телепортера",
		ACCUSATIVE = "модуль телепортера",
		INSTRUMENTAL = "модулем телепортера",
		PREPOSITIONAL = "модуле телепортера",
	)
/*
tier 1 - 2-3 range, 375 energy per teleport, 3 sec teleport
tier 2 - 5-6 range, 250 energy per teleport, 2 sec teleport
tier 3 - 10-12 range, 125 energy per teleport, 1 sec teleport
*/
/obj/item/mod/module/anomaly_locked/teleporter/update_core_powers()
	if(!core)
		teleport_time = 3 SECONDS
		use_energy_cost = DEFAULT_CHARGE_DRAIN * 500
		max_range = 0
		return

	var/calculated_range = min(round(core.get_strength() / 20), limited_range)
	max_range = calculated_range
	if(core.get_strength() > 100)
		use_energy_cost = DEFAULT_CHARGE_DRAIN * 200
		teleport_time = 2 SECONDS
	if(core.get_strength() > 200)
		use_energy_cost = DEFAULT_CHARGE_DRAIN * 100
		teleport_time = 1 SECONDS

/obj/item/mod/module/anomaly_locked/teleporter/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/turf/target_turf = get_turf(target)
	if(get_dist(target_turf, mod.wearer) > max_range)
		balloon_alert(mod.wearer, "слишком далеко!")
		return
	if(!istype(target_turf))
		balloon_alert(mod.wearer, "неподходящая цель!")
		return
	if(target_turf.density)
		balloon_alert(mod.wearer, "невозможно!")
		return
	if(!is_teleport_allowed(target_turf.z))
		balloon_alert(mod.wearer, "сбой в работе!")
		return

	balloon_alert(mod.wearer, "телепортация...")
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
	removable = FALSE

// MARK: Anti-gravity
/// Anti-Gravity - Makes the user weightless.
/obj/item/mod/module/anomaly_locked/antigrav
	name = "MOD anti-gravity module"
	desc = "Модуль для МЭК, использующий ядро гравитационной аномалии для полной компенсации гравитационного воздействия. \
			Обеспечивает контролируемую невесомость пользователя."
	icon_state = "antigrav"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.7
	incompatible_modules = list(/obj/item/mod/module/anomaly_locked/antigrav) //TODO: add /obj/item/mod/module/atrocinator
	accepted_anomalies = list(/obj/item/assembly/signaler/core/gravitational)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)

/obj/item/mod/module/anomaly_locked/antigrav/get_ru_names()
	return list(
		NOMINATIVE = "модуль антигравитации",
		GENITIVE = "модуля антигравитации",
		DATIVE = "модулю антигравитации",
		ACCUSATIVE = "модуль антигравитации",
		INSTRUMENTAL = "модулем антигравитации",
		PREPOSITIONAL = "модуле антигравитации",
	)

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
	removable = FALSE
