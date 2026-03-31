//Security modules for MODsuits

// MARK: Holster
/// Holster - Instantly holsters any not huge gun.
/obj/item/mod/module/holster
	name = "MOD holster module"
	desc = "Модуль для МЭК, основанный на системе, схожей со стандартным модулем хранилища. Позволяет хранить в кобуре костюма оружие \
			с возможностью быстро извлечь его в любой момент."
	icon_state = "holster"
	module_type = MODULE_USABLE
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/holster)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	/// Gun we have holstered.
	var/obj/item/gun/holstered

/obj/item/mod/module/holster/get_ru_names()
	return list(
		NOMINATIVE = "модуль кобуры",
		GENITIVE = "модуля кобуры",
		DATIVE = "модулю кобуры",
		ACCUSATIVE = "модуль кобуры",
		INSTRUMENTAL = "модулем кобуры",
		PREPOSITIONAL = "модуле кобуры",
	)

/obj/item/mod/module/holster/on_use()
	if(!holstered)
		var/obj/item/gun/holding = mod.wearer.get_active_hand()
		if(!holding)
			balloon_alert(mod.wearer, "нечего класть!")
			return
		if(!istype(holding) || holding.w_class > WEIGHT_CLASS_NORMAL) //god no holstering a BSG / combat shotgun
			balloon_alert(mod.wearer, "не влезает!")
			return
		if(!mod.wearer.can_unEquip(holding))
			balloon_alert(mod.wearer, "нельзя выпустить из рук!")
			return
		holstered = holding
		mod.wearer.balloon_alert_to_viewers("убира[PLUR_ET_UT(mod.wearer)] оружие", "оружие убрано")
		mod.wearer.temporarily_remove_item_from_inventory(holding)
		holding.forceMove(src)
	else if(mod.wearer.put_in_active_hand(holstered))
		mod.wearer.balloon_alert_to_viewers("извлека[PLUR_ET_UT(mod.wearer)] оружие", "оружие извлечено")
	else
		balloon_alert(mod.wearer, "рука занята!")

/obj/item/mod/module/holster/on_uninstall(deleting = FALSE)
	. = ..()
	if(holstered)
		holstered.forceMove(drop_location())

/obj/item/mod/module/holster/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == holstered)
		holstered = null

/obj/item/mod/module/holster/Destroy()
	QDEL_NULL(holstered)
	return ..()

// MARK: Mirage grenade
/// Mirage grenade dispenser - Dispenses grenades that copy the user's appearance.
/obj/item/mod/module/dispenser/mirage
	name = "MOD mirage grenade dispenser module"
	desc = "Модуль для МЭК, производящий гранаты \"Мираж\", создающие при детонации голограмму-копию пользователя. \
			Предназначен для тактической дезинформации противника."
	icon_state = "mirage_grenade"
	cooldown_time = 20 SECONDS
	overlay_state_inactive = "module_mirage_grenade"
	dispense_type = /obj/item/grenade/mirage

/obj/item/mod/module/dispenser/mirage/on_use()
	var/obj/item/grenade/mirage/grenade = ..()
	grenade.attack_self(mod.wearer)

/obj/item/mod/module/dispenser/mirage/get_ru_names()
	return list(
		NOMINATIVE = "модуль гранат \"Мираж\"",
		GENITIVE = "модуля гранат \"Мираж\"",
		DATIVE = "модулю гранат \"Мираж\"",
		ACCUSATIVE = "модуль гранат \"Мираж\"",
		INSTRUMENTAL = "модулем гранат \"Мираж\"",
		PREPOSITIONAL = "модуле гранат \"Мираж\"",
	)

/obj/item/grenade/mirage
	name = "mirage grenade"
	desc = "Специальное устройство, напоминающее гранату. При активации создаёт голограмму-копию пользователя."
	icon_state = "mirage"
	det_time = 3 SECONDS
	/// Mob that threw the grenade.
	var/mob/living/thrower

/obj/item/grenade/mirage/get_ru_names()
	return list(
		NOMINATIVE = "граната \"Мираж\"",
		GENITIVE = "гранаты \"Мираж\"",
		DATIVE = "гранате \"Мираж\"",
		ACCUSATIVE = "гранату \"Мираж\"",
		INSTRUMENTAL = "гранатой \"Мираж\"",
		PREPOSITIONAL = "гранате \"Мираж\"",
	)

/obj/item/grenade/mirage/Destroy()
	thrower = null
	return ..()

/obj/item/grenade/mirage/attack_self(mob/user)
	. = ..()
	thrower = user

/obj/item/grenade/mirage/prime()
	do_sparks(rand(3, 6), FALSE, src)
	if(thrower)
		var/mob/living/simple_animal/hostile/illusion/mirage/M = new(get_turf(src))
		M.Copy_Parent(thrower, 15 SECONDS)
	qdel(src)

/mob/living/simple_animal/hostile/illusion/mirage //It's just standing there, menacingly
	AIStatus = AI_OFF
	density = FALSE

/mob/living/simple_animal/hostile/illusion/mirage/death(gibbed)
	do_sparks(rand(3, 6), FALSE, src)
	return ..()

// MARK: Active sonar
/// Active Sonar - Displays a hud circle on the turf of any living creatures in the given radius
/obj/item/mod/module/active_sonar
	name = "MOD active sonar"
	desc = "Модуль для МЭК, использующий импульсные звуковые волны для обнаружения \
			живых существ в радиусе действия. Воспроизводит аутентичный звуковой сигнал."
	icon_state = "active_sonar"
	module_type = MODULE_USABLE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 4
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/active_sonar)
	cooldown_time = 7.5 SECONDS //come on man this is discount thermals, it doesnt need a 15 second cooldown
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)

/obj/item/mod/module/active_sonar/get_ru_names()
	return list(
		NOMINATIVE = "модуль сонара",
		GENITIVE = "модуля сонара",
		DATIVE = "модулю сонара",
		ACCUSATIVE = "модуль сонара",
		INSTRUMENTAL = "модулем сонара",
		PREPOSITIONAL = "модуле сонара",
	)

/obj/item/mod/module/active_sonar/on_use()
	playsound(mod.wearer, 'sound/mecha/skyfall_power_up.ogg', vol = 20, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	if(!do_after(mod.wearer, 1.1 SECONDS, target = mod.wearer))
		return
	var/creatures_detected = 0
	for(var/mob/living/creature in range(9, mod.wearer))
		if(creature == mod.wearer || creature.stat == DEAD)
			continue
		new /obj/effect/temp_visual/sonar_ping(mod.wearer.loc, mod.wearer, creature)
		creatures_detected++
	playsound(mod.wearer, 'sound/effects/ping_hit.ogg', vol = 75, vary = TRUE, extrarange = 9) // Should be audible for the radius of the sonar
	to_chat(mod.wearer, (span_notice("Вы бьёте кулаком в пол, запуская звуковую волну сонара, которая обнаруживает [creatures_detected] жив[declension_ru(creatures_detected, "ое существо", "ых существ", "ых существ")]  поблизости!")))

/obj/effect/temp_visual/sonar_ping
	duration = 3 SECONDS
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	randomdir = FALSE
	/// The image shown to modsuit users
	var/image/modsuit_image
	/// The person in the modsuit at the moment, really just used to remove this from their screen
	var/source_UID
	/// The icon state applied to the image created for this ping.
	var/real_icon_state = "sonar_ping"

/obj/effect/temp_visual/sonar_ping/Initialize(mapload, mob/living/looker, mob/living/creature)
	. = ..()
	if(!looker || !creature)
		return INITIALIZE_HINT_QDEL
	modsuit_image = image(icon = icon, loc = src, icon_state = real_icon_state, layer = ABOVE_ALL_MOB_LAYER, pixel_w = ((creature.x - looker.x) * ICON_SIZE_X), pixel_z = ((creature.y - looker.y) * ICON_SIZE_Y))
	modsuit_image.plane = ABOVE_LIGHTING_PLANE
	modsuit_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	source_UID = looker.UID()
	add_mind(looker)

/obj/effect/temp_visual/sonar_ping/Destroy()
	var/mob/living/previous_user = locateUID(source_UID)
	if(previous_user)
		remove_mind(previous_user)
	// Null so we don't shit the bed when we delete
	modsuit_image = null
	return ..()

/// Add the image to the modsuit wearer's screen
/obj/effect/temp_visual/sonar_ping/proc/add_mind(mob/living/looker)
	looker?.client?.images |= modsuit_image

/// Remove the image from the modsuit wearer's screen
/obj/effect/temp_visual/sonar_ping/proc/remove_mind(mob/living/looker)
	looker?.client?.images -= modsuit_image

// MARK: Firewall
/// Firewall. Deployable dropwall that lights projectiles on fire.
/obj/item/mod/module/anomaly_locked/firewall
	name = "MOD firewall module"
	desc = "Модуль для МЭК, использующий ядро пирокластической аномалии для генерации термобарьера, \
			поджигающего проходящие через него снаряды."
	icon_state = "firewall"
	overlay_state_inactive = "module_mirage_grenade"
	incompatible_modules = list(
		/obj/item/mod/module/anomaly_locked/firewall,
		/obj/item/mod/module/dispenser/dropwall_module,
		/obj/item/mod/module/dispenser/dropwall_syndie,
	)
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	cooldown_time = 25 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	accepted_anomalies = list(/obj/item/assembly/signaler/core/atmospheric)
	/// Path we dispense.
	var/dispense_type = /obj/item/grenade/barrier/dropwall/firewall

/obj/item/mod/module/anomaly_locked/firewall/get_ru_names()
	return list(
		NOMINATIVE = "модуль огненного щита",
		GENITIVE = "модуля огненного щита",
		DATIVE = "модулю огненного щита",
		ACCUSATIVE = "модуль огненного щита",
		INSTRUMENTAL = "модулем огненного щита",
		PREPOSITIONAL = "модуле огненного щита",
	)

/obj/item/mod/module/anomaly_locked/firewall/update_core_powers()
	if(!core)
		dispense_type = null
		return

	dispense_type = /obj/item/grenade/barrier/dropwall/firewall/weak
	if(core.get_strength() > 100)
		dispense_type = /obj/item/grenade/barrier/dropwall/firewall
	if(core.get_strength() > 200)
		dispense_type = /obj/item/grenade/barrier/dropwall/firewall/strong

/obj/item/mod/module/anomaly_locked/firewall/on_use()
	var/obj/item/dispensed = new dispense_type(mod.wearer.loc)
	mod.wearer.put_in_hands(dispensed)
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	drain_power(use_energy_cost)
	var/obj/item/grenade/grenade = dispensed
	grenade.attack_self(mod.wearer)
	return grenade

/obj/item/mod/module/anomaly_locked/firewall/prebuilt
	prebuilt = TRUE
	removable = FALSE // No switching it into another suit / no free anomaly core

// MARK: Vortex shotgun
/// Vortex arm mounted shotgun. Fucks up reality in front of it, very power draining. Compeating with the vortex arm and stealth armor after all
/obj/item/mod/module/anomaly_locked/vortex_shotgun
	name = "MOD vortex shotgun module"
	desc = "Модуль для МЭК, использующий ядро вихревой аномалии в конструкции дробовика, встроенного в предплечье костюма, \
			чтобы искажать само пространство-время перед пользователем."
	icon_state = "vortex"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 750
	device = /obj/item/gun/energy/vortex_shotgun
	required_slots = list(ITEM_SLOT_GLOVES)
	accepted_anomalies = list(/obj/item/assembly/signaler/core/vortex)

/obj/item/mod/module/anomaly_locked/vortex_shotgun/get_ru_names()
	return list(
		NOMINATIVE = "модуль вихревого дробовика",
		GENITIVE = "модуля вихревого дробовика",
		DATIVE = "модулю вихревого дробовика",
		ACCUSATIVE = "модуль вихревого дробовика",
		INSTRUMENTAL = "модулем вихревого дробовика",
		PREPOSITIONAL = "модуле вихревого дробовика",
	)

#define DEFAULT_SHOT_DRAIN 1000 // обычный выстрел
#define LESSER_SHOT_DRAIN_CORE_REQ 100
#define LESSER_SHOT_DRAIN 750 // выстрел подешевле
#define LEAST_SHOT_DRAIN_CORE_REQ 200
#define LEAST_SHOT_DRAIN 500 // вообще дешёвый выстрел жестб

/obj/item/mod/module/anomaly_locked/vortex_shotgun/update_core_powers()
	if(!core)
		return
	use_energy_cost = DEFAULT_CHARGE_DRAIN * DEFAULT_SHOT_DRAIN
	if(core.get_strength() > LESSER_SHOT_DRAIN_CORE_REQ)
		use_energy_cost = DEFAULT_CHARGE_DRAIN * LESSER_SHOT_DRAIN
	if(core.get_strength() > LEAST_SHOT_DRAIN_CORE_REQ)
		use_energy_cost = DEFAULT_CHARGE_DRAIN * LEAST_SHOT_DRAIN

#undef DEFAULT_SHOT_DRAIN
#undef LESSER_SHOT_DRAIN_CORE_REQ
#undef LESSER_SHOT_DRAIN
#undef LEAST_SHOT_DRAIN_CORE_REQ
#undef LEAST_SHOT_DRAIN

/obj/item/mod/module/anomaly_locked/vortex_shotgun/Initialize(mapload)
	. = ..()
	RegisterSignal(device, COMSIG_GUN_FIRED, PROC_REF(on_gun_fire))

/obj/item/mod/module/anomaly_locked/vortex_shotgun/proc/on_gun_fire()
	SIGNAL_HANDLER

	var/obj/item/gun/energy/gun = device

	if(HAS_TRAIT(mod.wearer, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		return

	if(!gun.chambered.BB)
		gun.chambered.newshot()

	if(drain_power(use_energy_cost)) //no shoot when no energy
		return

	QDEL_NULL(gun.chambered.BB)
	balloon_alert(mod.wearer, "нет энергии!")

/obj/item/mod/module/anomaly_locked/vortex_shotgun/prebuilt
	prebuilt = TRUE
	removable = FALSE // No switching it into another suit / no free anomaly core

// MARK: Criminal Capture
/// Criminal Capture - Generates hardlight bags you can put people in and sinch.
/obj/item/mod/module/criminalcapture
	name = "MOD criminal capture module"
	desc = "Модуль для МЭК, создающий герметичные контейнеры из твёрдого света для безопасной \
			транспортировки задержанных в условиях опасной атмосферы."
	icon_state = "criminal_capture"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/criminalcapture)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// Time to capture a prisoner.
	var/capture_time = 2.5 SECONDS
	/// Time to dematerialize a bodybag.
	var/packup_time = 1 SECONDS
	/// Typepath of our bodybag
	var/bodybag_type = /obj/structure/closet/body_bag/environmental/prisoner/hardlight
	/// Our linked bodybag.
	var/obj/structure/closet/body_bag/linked_bodybag

/obj/item/mod/module/criminalcapture/get_ru_names()
	return list(
		NOMINATIVE = "модуль мешков для тел",
		GENITIVE = "модуля мешков для тел",
		DATIVE = "модулю мешков для тел",
		ACCUSATIVE = "модуль мешков для тел",
		INSTRUMENTAL = "модулем мешков для тел",
		PREPOSITIONAL = "модуле мешков для тел",
	)

/obj/item/mod/module/criminalcapture/on_process(seconds_per_tick)
	idle_power_cost = linked_bodybag ? (DEFAULT_CHARGE_DRAIN * 3) : 0
	return ..()

/obj/item/mod/module/criminalcapture/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(!linked_bodybag)
		return
	packup()

/obj/item/mod/module/criminalcapture/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(target == linked_bodybag)
		playsound(src, 'sound/machines/ding.ogg', 25, TRUE)
		if(!do_after(mod.wearer, packup_time, target = target))
			balloon_alert(mod.wearer, "прервано!")
		packup()
		return
	if(linked_bodybag)
		return
	var/turf/target_turf = get_turf(target)
	if(target_turf.is_blocked_turf(exclude_mobs = TRUE))
		return
	playsound(src, 'sound/machines/ding.ogg', 25, TRUE)
	if(!do_after(mod.wearer, capture_time, target = target))
		balloon_alert(mod.wearer, "прервано!")
		return
	if(linked_bodybag)
		return
	linked_bodybag = new bodybag_type(target_turf)
	linked_bodybag.take_contents()
	playsound(linked_bodybag, 'sound/weapons/egloves.ogg', 80, TRUE)
	RegisterSignal(linked_bodybag, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))

/obj/item/mod/module/criminalcapture/proc/packup()
	if(!linked_bodybag)
		return
	playsound(linked_bodybag, 'sound/weapons/egloves.ogg', 80, TRUE)
	apply_wibbly_filters(linked_bodybag)
	animate(linked_bodybag, 0.5 SECONDS, alpha = 50, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, PROC_REF(delete_bag), linked_bodybag), 0.5 SECONDS)
	linked_bodybag = null

/obj/item/mod/module/criminalcapture/proc/check_range()
	SIGNAL_HANDLER

	if(get_dist(mod.wearer, linked_bodybag) <= 9)
		return
	packup()

/obj/item/mod/module/criminalcapture/proc/delete_bag(obj/structure/closet/body_bag/bag)
	if(mod?.wearer)
		UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))
		balloon_alert(mod.wearer, "мешок рассеивается")
	bag.open()
	qdel(bag)

//Security modules for MODsuits

// MARK: Magnetic Harness
/// Magnetic Harness - Automatically puts guns in your suit storage when you drop them.
/obj/item/mod/module/magnetic_harness
	name = "MOD magnetic harness module"
	desc = "Модуль для МЭК, основанный на старой технологии, использовавшейся морской пехотой ТСФ. \
			Автоматически возвращает выпавшее оружие к пользователю с помощью системы управляемых магнитов."
	icon_state = "mag_harness"
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/magnetic_harness)
	required_slots = list(ITEM_SLOT_CLOTH_OUTER)
	/// Time before we activate the magnet.
	var/magnet_delay = 0.8 SECONDS
	/// The typecache of all guns we allow.
	var/static/list/guns_typecache
	/// The guns already allowed by the modsuit chestplate.
	var/list/already_allowed_guns = list()

/obj/item/mod/module/magnetic_harness/get_ru_names()
	return list(
		NOMINATIVE = "модуль магнитного ремня",
		GENITIVE = "модуля магнитного ремня",
		DATIVE = "модулю магнитного ремня",
		ACCUSATIVE = "модуль магнитного ремня",
		INSTRUMENTAL = "модулем магнитного ремня",
		PREPOSITIONAL = "модуле магнитного ремня",
	)

/obj/item/mod/module/magnetic_harness/Initialize(mapload)
	. = ..()
	if(!guns_typecache)
		guns_typecache = typecacheof(list(/obj/item/gun/projectile, /obj/item/gun/energy, /obj/item/gun/grenadelauncher, /obj/item/gun/syringe))

/obj/item/mod/module/magnetic_harness/on_install()
	. = ..()
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_CLOTH_OUTER)
	if(!istype(suit))
		return
	already_allowed_guns = guns_typecache & suit.allowed
	suit.allowed |= guns_typecache

/obj/item/mod/module/magnetic_harness/on_uninstall(deleting = FALSE)
	. = ..()
	if(deleting)
		return
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_CLOTH_OUTER)
	if(!istype(suit))
		return
	suit.allowed -= (guns_typecache - already_allowed_guns)

/obj/item/mod/module/magnetic_harness/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(check_dropped_item))

/obj/item/mod/module/magnetic_harness/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_MOB_UNEQUIPPED_ITEM)

/obj/item/mod/module/magnetic_harness/proc/check_dropped_item(datum/source, obj/item/dropped_item, force, new_location)
	SIGNAL_HANDLER

	if(!is_type_in_typecache(dropped_item, guns_typecache))
		return
	if(new_location != get_turf(src))
		return
	addtimer(CALLBACK(src, PROC_REF(pick_up_item), dropped_item), magnet_delay)

/obj/item/mod/module/magnetic_harness/proc/pick_up_item(obj/item/item)
	if(!isturf(item.loc) || !item.Adjacent(mod.wearer))
		return
	if(!mod.wearer.equip_to_slot_if_possible(item, ITEM_SLOT_SUITSTORE, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	playsound(src, 'sound/items/modsuit/magnetic_harness.ogg', 50, TRUE)
	balloon_alert(mod.wearer, "оружие возвращено")
	drain_power(use_energy_cost)

// MARK: Pepper shoulders
/// Pepper Shoulders - When hit, reacts with a spray of pepper spray around the user.
/obj/item/mod/module/pepper_shoulders
	name = "MOD pepper shoulders module"
	desc = "Модуль для МЭК, представляющий собой два перцовых распылителя, устанавливаемых в плечи костюма. Они настроены таким образом, \
			чтобы выпускать перцовую смесь при любом ударе по пользователю."
	icon_state = "pepper_shoulder"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/pepper_shoulders)
	cooldown_time = 5 SECONDS
	overlay_state_inactive = "module_pepper"
	overlay_state_use = "module_pepper_used"
	required_slots = list(ITEM_SLOT_CLOTH_OUTER)

/obj/item/mod/module/pepper_shoulders/get_ru_names()
	return list(
		NOMINATIVE = "модуль перцового газа",
		GENITIVE = "модуля перцового газа",
		DATIVE = "модулю перцового газа",
		ACCUSATIVE = "модуль перцового газа",
		INSTRUMENTAL = "модулем перцового газа",
		PREPOSITIONAL = "модуле перцового газа",
	)

/obj/item/mod/module/pepper_shoulders/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(on_check_block))

/obj/item/mod/module/pepper_shoulders/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/item/mod/module/pepper_shoulders/on_use()
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)
	var/datum/reagents/capsaicin_holder = new(10)
	capsaicin_holder.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 10)
	var/datum/effect_system/fluid_spread/smoke/chem/quick/smoke = new
	smoke.set_up(1, holder = src, location = get_turf(src), carry = capsaicin_holder)
	smoke.start(log = TRUE)
	QDEL_NULL(capsaicin_holder) // Reagents have a ref to their holder which has a ref to them. No leaks please.

/obj/item/mod/module/pepper_shoulders/proc/on_check_block()
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return
	if(!check_power(use_energy_cost))
		return
	mod.wearer.visible_message(
		span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] [mod.declent_ru(GENITIVE)] [mod.wearer.declent_ru(GENITIVE)] реагиру[PLUR_ET_UT(src)] на атаку и распыля[PLUR_ET_UT(src)] перцовый газ!"),
		span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] вашего [mod.declent_ru(GENITIVE)] распыля[PLUR_ET_UT(src)] облако перцового газа!")
	)
	on_use()

// MARK: Megaphone
/// Megaphone - Lets you speak loud.
/obj/item/mod/module/megaphone
	name = "MOD megaphone module"
	desc = "Модуль для МЭК, представляющий собой акустический усилитель. Увеличивает \
			громкость речи пользователя, предоставляя широкий спектр применений."
	icon_state = "megaphone"
	module_type = MODULE_ACTIVE
	complexity = 1
	device = /obj/item/megaphone
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	incompatible_modules = list(/obj/item/mod/module/megaphone)
	cooldown_time = 0.05 SECONDS

/obj/item/mod/module/megaphone/get_ru_names()
	return list(
		NOMINATIVE = "модуль мегафона",
		GENITIVE = "модуля мегафона",
		DATIVE = "модулю мегафона",
		ACCUSATIVE = "модуль мегафона",
		INSTRUMENTAL = "модулем мегафона",
		PREPOSITIONAL = "модуле мегафона",
	)

// MARK: Quick cuff
/obj/item/mod/module/quick_cuff
	name = "MOD restraint assist module"
	desc = "Модуль для МЭК, представляющий собой усовершенствованные накладки на перчатки, которые обеспечивают более надёжный захват \
			и позволяют быстрее заковывать цели в наручники. Снятие с МЭК после установки невозможно."
	removable = FALSE
	required_slots = list(ITEM_SLOT_GLOVES)

// idk
/obj/item/mod/module/quick_cuff/get_ru_names()
	return list(
		NOMINATIVE = "модуль надёжного хвата",
		GENITIVE = "модуля надёжного хвата",
		DATIVE = "модулю надёжного хвата",
		ACCUSATIVE = "модуль надёжного хвата",
		INSTRUMENTAL = "модулем надёжного хвата",
		PREPOSITIONAL = "модуле надёжного хвата",
	)

/obj/item/mod/module/quick_cuff/on_part_activation()
	. = ..()
	ADD_TRAIT(mod.wearer, TRAIT_FAST_CUFFING, UNIQUE_TRAIT_SOURCE(src))

/obj/item/mod/module/quick_cuff/on_part_deactivation(deleting = FALSE)
	. = ..()
	REMOVE_TRAIT(mod.wearer, TRAIT_FAST_CUFFING, UNIQUE_TRAIT_SOURCE(src))

/obj/item/mod/module/dispenser/dropwall_module
	name = "MOD dropwall module"
	desc = "Модуль МЭК, использующий энергию костюма для создания генератора энергощита, позволяющего безопасно обстреливать противника \
			без риска ответного огня."
	icon_state = "cryogrenade-core"
	overlay_state_inactive = "module_dropwall"
	module_type = MODULE_ACTIVE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 25
	cooldown_time = 20 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	incompatible_modules = list(
		/obj/item/mod/module/anomaly_locked/firewall,
		/obj/item/mod/module/dispenser/dropwall_module,
		/obj/item/mod/module/dispenser/dropwall_syndie,
	)
	dispense_type = /obj/item/grenade/barrier/dropwall

/obj/item/mod/module/dispenser/dropwall_module/get_ru_names()
	return list(
		NOMINATIVE = "модуль создания энергощита",
		GENITIVE = "модуля создания энергощита",
		DATIVE = "модулю создания энергощита",
		ACCUSATIVE = "модуль создания энергощита",
		INSTRUMENTAL = "модулем создания энергощита",
		PREPOSITIONAL = "модуле создания энергощита",
	)


/obj/item/mod/module/dispenser/dropwall_module/on_use()
	var/obj/item/grenade/barrier/dropwall/grenade = ..()
	grenade.attack_self(mod.wearer)

/obj/item/mod/module/dispenser/dropwall_syndie
	name = "MOD bloodwall module"
	desc = "Модуль МЭК, используемый \"Мародёрами Горлекса\", незаконная модификация стандартных генераторов энергощита. Данная модель создаёт \
			усиленный вариант щита, который, однако, разряжается значительно быстрее, чем его аналоги."
	icon_state = "bloodwall_module"
	overlay_state_inactive = "bloodwall_module"
	module_type = MODULE_ACTIVE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 15
	cooldown_time = 15 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	incompatible_modules = list(
		/obj/item/mod/module/anomaly_locked/firewall,
		/obj/item/mod/module/dispenser/dropwall_module,
		/obj/item/mod/module/dispenser/dropwall_syndie,
	)
	dispense_type = /obj/item/grenade/barrier/dropwall/syndie

/obj/item/mod/module/dispenser/dropwall_syndie/get_ru_names()
	return list(
		NOMINATIVE = "модуль создания военного энергощита",
		GENITIVE = "модуля создания военного энергощита",
		DATIVE = "модулю создания военного энергощита",
		ACCUSATIVE = "модуль создания военного энергощита",
		INSTRUMENTAL = "модулем создания военного энергощита",
		PREPOSITIONAL = "модуле создания военного энергощита",
	)

/obj/item/mod/module/dispenser/dropwall_syndie/on_use()
	var/obj/item/grenade/barrier/dropwall/syndie/grenade = ..()
	grenade.attack_self(mod.wearer)
