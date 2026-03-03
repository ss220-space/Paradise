//Supply modules for MODsuits

// MARK: GPS
/// Internal GPS - Extends a GPS you can use.
/obj/item/mod/module/gps
	name = "MOD internal GPS module"
	desc = "Модуль для МЭК, использующий стандартную технологию \"Нанотрейзен\" для вычисления \
			местоположения пользователя с точностью до метра. Отображает сигналы других подобных устройств."
	icon_state = "gps"
	module_type = MODULE_ACTIVE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.2
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	incompatible_modules = list(/obj/item/mod/module/gps)
	cooldown_time = 0.5 SECONDS
	device = /obj/item/gps/mod

/obj/item/mod/module/gps/get_ru_names()
	return list(
		NOMINATIVE = "модуль ГПС",
		GENITIVE = "модуля ГПС",
		DATIVE = "модулю ГПС",
		ACCUSATIVE = "модуль ГПС",
		INSTRUMENTAL = "модулем ГПС",
		PREPOSITIONAL = "модуле ГПС",
	)

// MARK: Hydraulic clamp
/// Hydraulic Clamp - Lets you pick up and drop crates.
/obj/item/mod/module/clamp
	name = "MOD hydraulic clamp module"
	desc = "Модуль для МЭК. Набор сервоприводов с клешнёй, устанавливаемой в руки костюма. \
			Многократно увеличивает грузоподъёмность пользователя, позволяя перемещать тяжеловесные грузы."
	icon_state = "clamp"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/clamp)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_clamp"
	overlay_state_active = "module_clamp_on"
	required_slots = list(ITEM_SLOT_GLOVES, ITEM_SLOT_BACK)
	/// Time it takes to load a crate.
	var/load_time = 3 SECONDS
	/// The max amount of crates you can carry.
	var/max_crates = 3
	/// The crates stored in the module.
	var/list/stored_crates = list()

/obj/item/mod/module/clamp/get_ru_names()
	return list(
		NOMINATIVE = "модуль гидравлической клешни",
		GENITIVE = "модуля гидравлической клешни",
		DATIVE = "модулю гидравлической клешни",
		ACCUSATIVE = "модуль гидравлической клешни",
		INSTRUMENTAL = "модулем гидравлической клешни",
		PREPOSITIONAL = "модуле гидравлической клешни",
	)

/obj/item/mod/module/clamp/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(istype(target, /obj/structure/closet/crate) || istype(target, /obj/structure/closet/critter/mecha))
		var/obj/structure/closet/picked_crate = target
		if(!check_crate_pickup(picked_crate))
			return
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		if(!do_after(mod.wearer, load_time, target = target))
			return
		if(!check_crate_pickup(picked_crate))
			return
		stored_crates += picked_crate
		picked_crate.forceMove(src)
		drain_power(use_energy_cost)
		return
	if(length(stored_crates))
		var/turf/target_turf = get_turf(target)
		if(target_turf.density)
			return
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		if(!do_after(mod.wearer, load_time, target = target))
			return
		if(target_turf.density)
			return
		var/obj/structure/closet/crate/dropped_crate = pop(stored_crates)
		if(isnull(dropped_crate))
			return
		dropped_crate.forceMove(target_turf)
		drain_power(use_energy_cost)
		return
	balloon_alert(mod.wearer, "невозможно поднять!")

/obj/item/mod/module/clamp/on_part_deactivation(deleting = FALSE)
	if(deleting)
		return
	for(var/obj/structure/closet/crate/crate as anything in stored_crates)
		crate.forceMove(drop_location())
		stored_crates -= crate

/obj/item/mod/module/clamp/proc/check_crate_pickup(atom/movable/target)
	if(length(stored_crates) >= max_crates)
		balloon_alert(mod.wearer, "лимит ящиков!")
		return FALSE
	for(var/mob/living/mob in target.client_mobs_in_contents)
		if(mob.mob_size < MOB_SIZE_HUMAN)
			continue
		balloon_alert(mod.wearer, "слишком тяжело!")
		return FALSE
	return TRUE

/obj/item/mod/module/clamp/loader
	name = "MOD loader hydraulic clamp module"
	icon_state = "clamp_loader"
	complexity = 0
	removable = FALSE
	overlay_state_inactive = null
	overlay_state_active = "module_clamp_loader"
	load_time = 1 SECONDS
	max_crates = 5
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_BACK)

/obj/item/mod/module/clamp/loader/get_ru_names()
	return list(
		NOMINATIVE = "модуль грузовой клешни",
		GENITIVE = "модуля грузовой клешни",
		DATIVE = "модулю грузовой клешни",
		ACCUSATIVE = "модуль грузовой клешни",
		INSTRUMENTAL = "модулем грузовой клешни",
		PREPOSITIONAL = "модуле грузовой клешни",
	)

// MARK: Drill
/// Drill - Lets you dig through rock and basalt.
/obj/item/mod/module/drill
	name = "MOD drill module"
	desc = "Модуль для МЭК, представляющий собой интегрированную в предплечье костюма дрель. \
			Благодаря алмазному напылению наконечника модуль эффективен при работе с широким спектром \
			материалов разного уровня прочности."
	icon_state = "drill"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/drill)
	cooldown_time = 0.5 SECONDS
	overlay_state_active = "module_drill"
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/drill/get_ru_names()
	return list(
		NOMINATIVE = "модуль дрели",
		GENITIVE = "модуля дрели",
		DATIVE = "модулю дрели",
		ACCUSATIVE = "модуль дрели",
		INSTRUMENTAL = "модулем дрели",
		PREPOSITIONAL = "модуле дрели",
	)

/obj/item/mod/module/drill/on_activation()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP, PROC_REF(bump_mine))

/obj/item/mod/module/drill/on_deactivation(display_message = TRUE, deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP)

/obj/item/mod/module/drill/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(!ismineralturf(target))
		return
	var/turf/simulated/mineral/mineral_turf = target
	mineral_turf.gets_drilled(mod.wearer)
	drain_power(use_energy_cost)

/obj/item/mod/module/drill/proc/bump_mine(mob/living/carbon/human/bumper, atom/bumped_into, proximity)
	SIGNAL_HANDLER

	if(!ismineralturf(bumped_into) || !drain_power(use_energy_cost))
		return
	var/turf/simulated/mineral/mineral_turf = bumped_into
	mineral_turf.gets_drilled(mod.wearer)
	return COMPONENT_CANCEL_ATTACK_CHAIN

// MARK: Ore bag
/// Ore Bag - Lets you pick up ores and drop them from the suit.
/obj/item/mod/module/orebag
	name = "MOD ore bag module"
	desc = "Модуль для МЭК, являющийся специализированной версией стандартного модуля хранилища, \
			предназначенной для хранения руды. Оснащён системой электромагнитов, автоматически \
			собирающих руду в малом радиусе от пользователя."
	icon_state = "ore"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/orebag)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	required_slots = list(ITEM_SLOT_BACK)
	/// The ores stored in the bag.
	var/list/ores = list()

/obj/item/mod/module/orebag/get_ru_names()
	return list(
		NOMINATIVE = "модуль хранилища руды",
		GENITIVE = "модуля хранилища руды",
		DATIVE = "модулю хранилища руды",
		ACCUSATIVE = "модуль хранилища руды",
		INSTRUMENTAL = "модулем хранилища руды",
		PREPOSITIONAL = "модуле хранилища руды",
	)

/obj/item/mod/module/orebag/on_equip()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(ore_pickup))
	..()

/obj/item/mod/module/orebag/on_unequip()
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	..()

/obj/item/mod/module/orebag/proc/ore_pickup(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	for(var/obj/item/stack/ore/ore in get_turf(mod.wearer))
		INVOKE_ASYNC(src, PROC_REF(move_ore), ore)

/obj/item/mod/module/orebag/proc/move_ore(obj/item/stack/ore)
	for(var/obj/item/stack/stored_ore as anything in ores)
		if(!ore.can_merge(stored_ore))
			continue
		ore.merge(stored_ore)
		if(QDELETED(ore))
			return
		break
	ore.forceMove(src)
	ores += ore

/obj/item/mod/module/orebag/on_use()
	for(var/obj/item/ore as anything in contents)
		ore.forceMove(drop_location())
		ores -= ore
	drain_power(use_energy_cost)

// MARK: Hydraulic arms
/obj/item/mod/module/hydraulic
	name = "MOD loader hydraulic arms module"
	desc = "Модуль для МЭК, представляющий собой пару внешних манипуляторов с гидравлическим усилением и сервоприводами. \
			Предназначен для облегчения транспортировки крупногабаритных грузов."
	icon_state = "launch_loader"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_energy_cost = DEFAULT_CHARGE_DRAIN*10
	incompatible_modules = list(/obj/item/mod/module/hydraulic)
	cooldown_time = 4 SECONDS
	overlay_state_inactive = "module_hydraulic"
	overlay_state_active = "module_hydraulic_active"
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_BACK)
	/// Time it takes to launch
	var/launch_time = 2 SECONDS
	/// The overlay used to show that you are charging.
	var/image/charge_up_overlay

/obj/item/mod/module/hydraulic/get_ru_names()
	return list(
		NOMINATIVE = "модуль гидравлических рук",
		GENITIVE = "модуля гидравлических рук",
		DATIVE = "модулю гидравлических рук",
		ACCUSATIVE = "модуль гидравлических рук",
		INSTRUMENTAL = "модулем гидравлических рук",
		PREPOSITIONAL = "модуле гидравлических рук",
	)

/obj/item/mod/module/hydraulic/Initialize(mapload)
	. = ..()
	charge_up_overlay = image(icon = 'icons/effects/effects.dmi', icon_state = "electricity3", layer = EFFECTS_LAYER)

/obj/item/mod/module/hydraulic/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(mod.wearer.buckled)
		return
	var/current_time = world.time
	var/atom/movable/plane_master_controller/pm_controller = mod.wearer.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	for(var/atom/movable/screen/plane_master/pm_iterator as anything in pm_controller.get_planes())
		animate(pm_iterator, launch_time, transform = matrix(1.25, MATRIX_SCALE))
	mod.wearer.visible_message(span_warning("[mod.wearer] начинает громко гудеть!"))
	playsound(src, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	mod.wearer.add_overlay(charge_up_overlay)
	var/power = launch_time
	if(!do_after(mod.wearer, launch_time, target = mod.wearer))
		power = world.time - current_time
	drain_power(use_energy_cost)
	for(var/atom/movable/screen/plane_master/pm_iterator as anything in pm_controller.get_planes())
		animate(pm_iterator, 0.1 SECONDS, transform = matrix(1, MATRIX_SCALE))
	playsound(src, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	var/angle = get_angle(mod.wearer, target)
	mod.wearer.transform = mod.wearer.transform.Turn(mod.wearer.transform, angle)
	mod.wearer.throw_at(
		get_ranged_target_turf_direct(mod.wearer, target, power),
		range = power,
		speed = max(round(0.2 * power), 1),
		thrower = mod.wearer, spin = FALSE,
		callback = CALLBACK(src, PROC_REF(on_throw_end), mod.wearer, -angle),
		)

/obj/item/mod/module/hydraulic/proc/on_throw_end(mob/user, angle)
	if(!user)
		return
	user.transform = user.transform.Turn(user.transform, angle)
	user.cut_overlay(charge_up_overlay)

// MARK: Magnet
/obj/item/mod/module/magnet
	name = "MOD loader hydraulic magnet module"
	desc = "Модуль для МЭК, представляющий собой мощный гидравлический электромагнит, способный притягивать \
			шкафчики и ящики к пользователю и удерживать их."
	icon_state = "magnet_loader"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/magnet)
	cooldown_time = 1.5 SECONDS
	overlay_state_active = "module_magnet"
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_BACK)

/obj/item/mod/module/magnet/get_ru_names()
	return list(
		NOMINATIVE = "модуль грузового магнита",
		GENITIVE = "модуля грузового магнита",
		DATIVE = "модулю грузового магнита",
		ACCUSATIVE = "модуль грузового магнита",
		INSTRUMENTAL = "модулем грузового магнита",
		PREPOSITIONAL = "модуле грузового магнита",
	)

/obj/item/mod/module/magnet/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(iscloset(mod.wearer.pulling))
		var/obj/structure/closet/locker = mod.wearer.pulling
		playsound(locker, 'sound/effects/gravhit.ogg', 75, TRUE)
		locker.forceMove(mod.wearer.loc)
		locker.throw_at(target, range = 7, speed = 4, thrower = mod.wearer)
		return
	if(!iscloset(target) || !(target in view(mod.wearer)))
		balloon_alert(mod.wearer, "неподходящая цель!")
		return
	var/obj/structure/closet/locker = target
	if(locker.anchored || locker.move_resist >= MOVE_FORCE_OVERPOWERING)
		return
	playsound(locker, 'sound/effects/gravhit.ogg', 75, TRUE)
	locker.throw_at(
		get_step_towards(mod.wearer, target),
		range = 7,
		speed = 3,
		force = MOVE_FORCE_WEAK,
		callback = CALLBACK(src, PROC_REF(check_locker), locker),
		)

/obj/item/mod/module/magnet/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(istype(mod.wearer.pulling, /obj/structure/closet))
		mod.wearer.stop_pulling()

/obj/item/mod/module/magnet/proc/check_locker(obj/structure/closet/locker)
	if(!mod?.wearer)
		return
	if(!locker.Adjacent(mod.wearer) || !isturf(locker.loc) || !isturf(mod.wearer.loc))
		return
	mod.wearer.start_pulling(locker)

// MARK: Ash accretion
/obj/item/mod/module/ash_accretion
	name = "MOD ash accretion module"
	desc = "Модуль для МЭК, представляющий собой систему сбора и распределения взвешенного пепла. Формирует из него защитный слой на поверхности костюма, \
			повышающий устойчивость к термическому и физическому воздействию. При нахождении в среде без пепла защита стремительно деградирует и разрушается."
	icon_state = "ash_accretion"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/ash_accretion)
	overlay_state_inactive = "module_ash"
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_CLOTH_OUTER|ITEM_SLOT_CLOTH_INNER, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// How many tiles we can travel to max out the armor.
	var/max_traveled_tiles = 10
	/// How many tiles we traveled through.
	var/traveled_tiles = 0
	/// Armor values per tile.
	var/obj/item/mod/armor/armor_mod_1 = /obj/item/mod/armor/mod_ash_accretion
	/// Speed added when you're fully covered in ash.
	var/speed_added = -0.5
	/// Speed that we actually added.
	var/actual_speed_added = 0
	/// Turfs that let us accrete ash.
	var/static/list/accretion_turfs
	/// Turfs that let us keep ash.
	var/static/list/keep_turfs

/obj/item/mod/module/ash_accretion/get_ru_names()
	return list(
		NOMINATIVE = "модуль пепельного аттрактора",
		GENITIVE = "модуля пепельного аттрактора",
		DATIVE = "модулю пепельного аттрактора",
		ACCUSATIVE = "модуль пепельного аттрактора",
		INSTRUMENTAL = "модулем пепельного аттрактора",
		PREPOSITIONAL = "модуле пепельного аттрактора",
	)

/obj/item/mod/module/ash_accretion/Initialize(mapload)
	. = ..()
	armor_mod_1 = new armor_mod_1()

/obj/item/mod/module/ash_accretion/Destroy()
	QDEL_NULL(armor_mod_1)
	return ..()

/obj/item/mod/armor/mod_ash_accretion
	armor = list(MELEE = 4, BULLET = 1, LASER = 2, ENERGY = 1, BOMB = 4, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/mod/module/ash_accretion/Initialize(mapload)
	. = ..()
	if(!accretion_turfs)
		accretion_turfs = typecacheof(list(
			/turf/simulated/floor/plating/asteroid
		))
	if(!keep_turfs)
		keep_turfs = typecacheof(list(
			/turf/simulated/floor/lava,
			/turf/simulated/floor/indestructible/hierophant,
			/turf/simulated/floor/indestructible/necropolis
			))

/obj/item/mod/module/ash_accretion/on_part_activation()
	mod.wearer.add_traits(list(TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), UNIQUE_TRAIT_SOURCE(src))
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(mod, COMSIG_MOD_UPDATE_SPEED, PROC_REF(on_update_speed))

/obj/item/mod/module/ash_accretion/on_part_deactivation(deleting = FALSE)
	mod.wearer.remove_traits(list(TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), UNIQUE_TRAIT_SOURCE(src))
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(mod, COMSIG_MOD_UPDATE_SPEED)
	if(!traveled_tiles)
		return
	for(var/obj/item/part as anything in mod.get_parts(TRUE))
		part.armor = part.set_armor(/datum/armor/mod_theme_mining) //TODO: ANYTHING BUT FUCKING THIS
	if(traveled_tiles == max_traveled_tiles)
		mod.update_speed()
	traveled_tiles = 0

/obj/item/mod/module/ash_accretion/proc/on_update_speed(datum/source, list/module_slowdowns)
	SIGNAL_HANDLER
	if(traveled_tiles == max_traveled_tiles)
		module_slowdowns += speed_added

/obj/item/mod/module/ash_accretion/generate_worn_overlay(obj/item/source, mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	return ..()

/obj/item/mod/module/ash_accretion/proc/on_move(atom/source, atom/oldloc, dir, forced)
	if(!isturf(mod.wearer.loc)) //dont lose ash from going in a locker
		return
	if(traveled_tiles) //leave ash every tile
		new /obj/effect/temp_visual/light_ash(get_turf(src))

	if(is_type_in_typecache(mod.wearer.loc, keep_turfs))
		return

	if(!is_type_in_typecache(mod.wearer.loc, accretion_turfs))
		if(traveled_tiles <= 0)
			return
		traveled_tiles--
		if(traveled_tiles == max_traveled_tiles - 1) // Just lost our speed buff
			mod.update_speed()
		for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
			part.armor = part.armor?.detachArmor(armor_mod_1.armor)
		if(traveled_tiles <= 0)
			balloon_alert(mod.wearer, "недостаточно пепла!")
		return

	if(traveled_tiles >= max_traveled_tiles)
		return
	traveled_tiles++
	for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
		part.armor = part.armor?.attachArmor(armor_mod_1.armor)
	if(traveled_tiles < max_traveled_tiles)
		return
	balloon_alert(mod.wearer, "полное покрытие пеплом")
	mod.wearer.color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,3) //make them super light
	animate(mod.wearer, 1 SECONDS, color = null, flags = ANIMATION_PARALLEL)
	playsound(src, 'sound/effects/sparks1.ogg', 100, TRUE)
	mod.update_speed()

/obj/effect/temp_visual/light_ash
	icon_state = "light_ash"
	icon = 'icons/effects/weather_effects.dmi'
	duration = 3.2 SECONDS

// MARK: Sphere transform
/obj/item/mod/module/sphere_transform
	name = "MOD sphere transform module"
	desc = "Модуль для МЭК, активирующий режим полной реконфигурации каркаса костюма в компактную сферу. \
			В этом режиме пользователь сохраняет полное управление и может развивать высокую скорость передвижения. \
			Дополнительно поддерживается запуск шахтёрских бомб для быстрой расчистки местности."
	icon_state = "sphere"
	complexity = 3
	module_type = MODULE_ACTIVE
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/sphere_transform)
	cooldown_time = 2 SECONDS
	allow_flags = MODULE_ALLOW_INCAPACITATED //Required so hands blocked doesnt block bombs
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_CLOTH_OUTER|ITEM_SLOT_CLOTH_INNER, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// Time it takes us to complete the animation.
	var/animate_time = 0.25 SECONDS
	/// List of traits to add/remove from our subject as needed.
	var/static/list/user_traits = list(
		TRAIT_FORCED_STANDING,
		TRAIT_HANDS_BLOCKED,
		TRAIT_NO_SLIP_ALL,
	)
	/// Can our bombs be blown on station?
	var/safe = TRUE


/obj/item/mod/module/sphere_transform/emag_act(mob/user)
	safe = !safe
	balloon_alert(user, "протоколы безопасности [safe ? "восстановлены" : "сняты"]!")

/obj/item/mod/module/sphere_transform/get_ru_names()
	return list(
		NOMINATIVE = "модуль превращения в сферу",
		GENITIVE = "модуля превращения в сферу",
		DATIVE = "модулю превращения в сферу",
		ACCUSATIVE = "модуль превращения в сферу",
		INSTRUMENTAL = "модулем превращения в сферу",
		PREPOSITIONAL = "модуле превращения в сферу",
	)

/obj/item/mod/module/sphere_transform/on_activation()
	if(!get_gravity(get_turf(src)))
		balloon_alert(mod.wearer, "нет гравитации!")
		return FALSE
	playsound(src, 'sound/items/modsuit/ballin.ogg', 100, TRUE)
	mod.wearer.add_filter("mod_ball", 1, alpha_mask_filter(icon = icon('icons/mob/clothing/modsuit/mod_modules.dmi', "ball_mask"), flags = MASK_INVERSE))
	mod.wearer.add_filter("mod_blur", 2, angular_blur_filter(size = 15))
	mod.wearer.add_filter("mod_outline", 3, outline_filter(color = "#000000AA"))
	animate(mod.wearer, animate_time, pixel_y = mod.wearer.pixel_y - 4, flags = ANIMATION_PARALLEL)
	mod.wearer.SpinAnimation(1.5)
	mod.wearer.add_traits(user_traits, MODSUIT_TRAIT)
	mod.wearer.add_movespeed_modifier(/datum/movespeed_modifier/sphere)
	RegisterSignal(mod.wearer, COMSIG_MOB_STATCHANGE, PROC_REF(on_statchange))

/obj/item/mod/module/sphere_transform/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(!deleting)
		playsound(src, 'sound/items/modsuit/ballin.ogg', 100, TRUE, frequency = -1)
	animate(mod.wearer, animate_time, pixel_y = 0)
	addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/datum, remove_filter), list("mod_ball", "mod_blur", "mod_outline")), animate_time)
	mod.wearer.remove_traits(user_traits, MODSUIT_TRAIT)
	mod.wearer.remove_movespeed_modifier(/datum/movespeed_modifier/sphere)
	UnregisterSignal(mod.wearer, COMSIG_MOB_STATCHANGE)

/obj/item/mod/module/sphere_transform/used()
	if(!safe)
		return ..()
	if(!lavaland_equipment_pressure_check(get_turf(src)))
		balloon_alert(mod.wearer, "слишком высокое давление!")
		playsound(src, 'sound/weapons/gun_interactions/dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/sphere_transform/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/projectile/bomb = new /obj/projectile/bullet/reusable/mining_bomb(get_turf(mod.wearer))
	bomb.original = target
	bomb.firer = mod.wearer
	bomb.preparePixelProjectile(target, mod.wearer)
	bomb.fire()
	playsound(src, 'sound/weapons/grenadelaunch.ogg', 75, TRUE)
	INVOKE_ASYNC(bomb, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_energy_cost)

/obj/item/mod/module/sphere_transform/on_active_process()
	animate(mod.wearer) //stop the animation
	mod.wearer.SpinAnimation(1.5) //start it back again
	if(!get_gravity(get_turf(src)))
		on_deactivation() //deactivate in no grav

/obj/item/mod/module/sphere_transform/proc/on_statchange(datum/source)
	SIGNAL_HANDLER
	if(!mod.wearer.stat)
		return
	on_deactivation()

// MARK: Mining bomb
/obj/projectile/bullet/reusable/mining_bomb
	name = "mining bomb"
	desc = "Это бомба. Может не стоит её так долго разглядывать?"
	icon_state = "mine_bomb"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	damage = 0
	range = 6
	flag = "bomb"
	light_range = 1
	light_color = LIGHT_COLOR_ORANGE
	ammo_type = /obj/structure/mining_bomb

/obj/projectile/bullet/reusable/mining_bomb/get_ru_names()
	return list(
		NOMINATIVE = "шахтёрская бомба",
		GENITIVE = "шахтёрской бомбы",
		DATIVE = "шахтёрскую бомбу",
		ACCUSATIVE = "шахтёрскую бомбу",
		INSTRUMENTAL = "шахтёрской бомбой",
		PREPOSITIONAL = "шахтёрской бомбе",
	)

/obj/structure/mining_bomb
	name = "mining bomb"
	desc = "Это бомба. Может не стоит её так долго разглядывать?"
	icon_state = "mine_bomb"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	anchored = TRUE
	resistance_flags = FIRE_PROOF|LAVA_PROOF
	light_range = 1
	light_color = LIGHT_COLOR_ORANGE
	/// Time to prime the explosion
	var/prime_time = 0.5 SECONDS
	/// Time to explode from the priming
	var/explosion_time = 1 SECONDS
	/// Damage done on explosion.
	var/damage = 12
	/// Damage multiplier on hostile fauna.
	var/fauna_boost = 4
	/// Image overlaid on explosion.
	var/static/image/explosion_image

/obj/structure/mining_bomb/get_ru_names()
	return list(
		NOMINATIVE = "шахтёрская бомба",
		GENITIVE = "шахтёрской бомбы",
		DATIVE = "шахтёрскую бомбу",
		ACCUSATIVE = "шахтёрскую бомбу",
		INSTRUMENTAL = "шахтёрской бомбой",
		PREPOSITIONAL = "шахтёрской бомбе",
	)

/obj/structure/mining_bomb/Initialize(mapload, atom/movable/firer)
	. = ..()
	generate_image()
	addtimer(CALLBACK(src, PROC_REF(prime), firer), prime_time)

/obj/structure/mining_bomb/proc/generate_image()
	explosion_image = image('icons/effects/96x96.dmi', "judicial_explosion")
	explosion_image.pixel_w = -32
	explosion_image.pixel_z = -32

/obj/structure/mining_bomb/proc/prime(atom/movable/firer)
	add_overlay(explosion_image)
	addtimer(CALLBACK(src, PROC_REF(boom), firer), explosion_time)

/obj/structure/mining_bomb/proc/boom(atom/movable/firer)
	visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] взрывается!"))
	playsound(src, 'sound/magic/magic_missile.ogg', 200, vary = TRUE)
	for(var/turf/our_turf as anything in circle_view_turfs(src, 2))
		if(!ismineralturf(our_turf))
			continue
		var/turf/simulated/mineral/mineral_turf = our_turf
		mineral_turf.attempt_drill(firer)
	for(var/mob/living/mob in range(1, src))
		mob.apply_damage(damage * (ishostile(mob) ? fauna_boost : 1), BRUTE)
		if(!ishostile(mob) || !firer)
			continue
		var/mob/living/simple_animal/hostile/hostile_mob = mob
		hostile_mob.GiveTarget(firer)
	for(var/obj/object in range(1, src))
		object.take_damage(damage, BRUTE)
	qdel(src)
