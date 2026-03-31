// MARK: Bombarda
/obj/item/gun/projectile/bombarda
	name = "Bombarda"
	desc = "Hand made analog of grenade launcher. Can fire improvised shells."
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "bombarda"
	item_state = "bombarda"
	mag_type = /obj/item/ammo_box/magazine/internal/bombarda
	fire_sound = 'sound/weapons/gunshots/1grenlauncher.ogg'
	can_holster = FALSE
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_delay = 1.8
	var/pump_cooldown = 0.5 SECONDS
	COOLDOWN_DECLARE(last_pump)
	accuracy = GUN_ACCURACY_MINIMAL
	recoil = GUN_RECOIL_MEGA
	var/opened = FALSE

/obj/item/gun/projectile/bombarda/attackby(obj/item/item, mob/user, params)
	if(isammocasing(item))
		add_fingerprint(user)
		if(!opened)
			balloon_alert(user, "необходимо открыть")
			return ATTACK_CHAIN_PROCEED
		if(chambered)
			balloon_alert(user, "уже заряжено!")
			return ATTACK_CHAIN_PROCEED
		var/loaded = magazine.reload(item, user, silent = TRUE)
		if(loaded)
			balloon_alert(user, "заряжено")
			return ATTACK_CHAIN_BLOCKED_ALL
		balloon_alert(user, "не удалось!")
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/gun/projectile/bombarda/update_icon_state()
	icon_state = initial(icon_state) + (opened ?  "_open" : "")
	item_state = initial(item_state) + (opened ?  "_open" : "")

/obj/item/gun/projectile/bombarda/handle_chamber(eject_casing = TRUE, empty_chamber = TRUE)
	..(FALSE, empty_chamber)

/obj/item/gun/projectile/bombarda/chamber_round()
	return

/obj/item/gun/projectile/bombarda/get_ammo(countchambered = FALSE, countempties = FALSE)
	return ..(countchambered, countempties)

/obj/item/gun/projectile/bombarda/can_shoot(mob/user)
	if(!chambered)
		return FALSE
	if(opened)
		return FALSE
	return (chambered.BB ? TRUE : FALSE)

/obj/item/gun/projectile/bombarda/unload_act(mob/user)
	if(!COOLDOWN_FINISHED(src, last_pump))
		return
	COOLDOWN_START(src, last_pump, pump_cooldown)
	if(opened)
		close_pump(user)
		return
	open_pump(user)

/obj/item/gun/projectile/bombarda/proc/open_pump(mob/user)
	if(opened)
		return FALSE
	opened = TRUE
	chambered = null
	var/atom/drop_loc = drop_location()
	while(get_ammo(countempties = TRUE) > 0)
		var/obj/item/ammo_casing/casing
		casing = magazine.get_round(FALSE)
		if(!casing)
			continue
		casing.forceMove(drop_loc)
		casing.pixel_x = rand(-10, 10)
		casing.pixel_y = rand(-10, 10)
		casing.setDir(pick(GLOB.alldirs))
		casing.update_appearance()
		casing.SpinAnimation(10, 1)
		playsound(drop_loc, casing.casing_drop_sound, 60, TRUE)
	playsound(loc, 'sound/weapons/bombarda/pump.ogg', 60, TRUE)
	update_icon()
	return TRUE

/obj/item/gun/projectile/bombarda/chamber_round(spin = TRUE)
	if(!magazine)
		return
	if(spin)
		chambered = magazine.get_round(TRUE)
		return
	if(!length(magazine.stored_ammo))
		return
	chambered = magazine.stored_ammo[1]

/obj/item/gun/projectile/bombarda/secgl/x4/shoot_with_empty_chamber(mob/living/user)
	..()
	chamber_round(TRUE)

/obj/item/gun/projectile/bombarda/proc/close_pump(mob/user)
	if(!opened)
		return FALSE
	opened = FALSE
	if(!chambered)
		chambered = magazine.get_round(TRUE)
	playsound(loc, 'sound/weapons/bombarda/pump.ogg', 60, TRUE)
	update_icon()
	return TRUE

// MARK: GL-06
/obj/item/gun/projectile/bombarda/secgl
	name = "grenade launcher GL-06"
	desc = "Однозарядный ручной гранатомёт, разработанный специально для сотрудников службы безопасности. Примеяется для подавления беспорядков с помощью нелетальных боеприпасов. Может запускать 40 мм гранаты."
	icon_state = "secgl"
	item_state = "secgl"
	mag_type = /obj/item/ammo_box/magazine/internal/bombarda/secgl
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/bombarda/secgl/get_ru_names()
	return list(
		NOMINATIVE = "ручной гранатомет GL-06",
		GENITIVE = "ручного гранатомета GL-06",
		DATIVE = "ручному гранатомету GL-06",
		ACCUSATIVE = "ручной гранатомет GL-06",
		INSTRUMENTAL = "ручным гранатометом GL-06",
		PREPOSITIONAL = "ручном гранатомете GL-06",
	)

// MARK: GL-08-04
/obj/item/gun/projectile/bombarda/secgl/x4
	name = "grenade launcher GL-08-4"
	desc = "Четырехзарядный ручной гранатомёт, разработанный специально для сотрудников службы безопасности. Применяется для подавления беспорядков с помощью не летальных боеприпасов. Может запускать 40 мм гранаты."
	icon_state = "secgl_4"
	item_state = "secgl_4"
	mag_type = /obj/item/ammo_box/magazine/internal/bombarda/secgl/x4
	w_class = WEIGHT_CLASS_HUGE
	weapon_weight = WEAPON_DUAL_WIELD
	slot_flags = FALSE
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_HIGH
	var/high_risk = TRUE
	fire_delay = 1.5 SECONDS

/obj/item/gun/projectile/bombarda/secgl/x4/get_ru_names()
	return list(
		NOMINATIVE = "ручной гранатомет GL-08-4",
		GENITIVE = "ручного гранатомета GL-08-4",
		DATIVE = "ручному гранатомету GL-08-4",
		ACCUSATIVE = "ручной гранатомет GL-08-4",
		INSTRUMENTAL = "ручным гранатометом GL-08-4",
		PREPOSITIONAL = "ручном гранатомете GL-08-4",
	)

/obj/item/gun/projectile/bombarda/secgl/x4/Initialize(mapload, ...)
	. = ..()
	if(high_risk)
		AddElement(/datum/element/high_value_item)

// MARK: M79
/obj/item/gun/projectile/bombarda/secgl/m79
	name = "grenade launcher M79"
	desc = "Классический однозарядный ручной гранатомёт, разработанный в 1961 году. Использует 40 мм гранаты."
	icon_state = "m79"
	item_state = "m79"

/obj/item/gun/projectile/bombarda/secgl/m79/get_ru_names()
	return list(
		NOMINATIVE = "ручной гранатомет M79",
		GENITIVE = "ручного гранатомета M79",
		DATIVE = "ручному гранатомету M79",
		ACCUSATIVE = "ручной гранатомет M79",
		INSTRUMENTAL = "ручным гранатометом M79",
		PREPOSITIONAL = "ручном гранатомете M79",
	)

// MARK: Double bombarda
/obj/item/gun/projectile/bombarda/bombplet
	name = "bombplet"
	desc = "Двуствольная самодельная бомбарда. Использует 40 мм гранаты."
	icon_state = "bombplet"
	item_state = "bombplet"
	mag_type = /obj/item/ammo_box/magazine/internal/bombarda/x2

/obj/item/gun/projectile/bombarda/bombplet/get_ru_names()
	return list(
		NOMINATIVE = "самодельный двуствольный гранатомет",
		GENITIVE = "самодельного двуствольного гранатомета",
		DATIVE = "самодельному двуствольному гранатомету",
		ACCUSATIVE = "самодельный двуствольный гранатомет",
		INSTRUMENTAL = "самодельным двуствольным гранатометом",
		PREPOSITIONAL = "самодельном двуствольном гранатомете",
	)

// MARK: Crafts and other shit
// TODO: move the stuff below into it's own files
/datum/crafting_recipe/bombarda
	name = "Bombarda"
	result = /obj/item/gun/projectile/bombarda
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 2,
		/obj/item/stack/tape_roll = 10,
		/obj/item/pipe = 1,
		/obj/item/weaponcrafting/receiver = 1,
		/obj/item/stack/sheet/metal = 2,
		/obj/item/weaponcrafting/stock = 1,
	)
	time = 6 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_availible = FALSE

// No fun allowed: https://github.com/ss220-space/Paradise/pull/7473#issuecomment-3217889330
// /datum/crafting_recipe/bombplet
// 	name = "Bombplet"
// 	result = /obj/item/gun/projectile/bombarda/bombplet
// 	reqs = list(/obj/item/restraints/handcuffs/cable = 2,
// 				/obj/item/stack/tape_roll = 10,
// 				/obj/item/gun/projectile/bombarda = 2)
// 	time = 6 SECONDS
// 	category = CAT_WEAPONRY
// 	subcategory = CAT_WEAPON
// 	always_availible = FALSE

/datum/crafting_recipe/bombarda/New()
	. = ..()
	if(CONFIG_GET(flag/enable_bombarda_craft))
		always_availible = TRUE

/datum/crafting_recipe/explosion_shell
	name = "Improvised explosive shell"
	result = /obj/item/ammo_casing/a40mm/improvised/exp_shell
	reqs = list(
		/datum/reagent/blackpowder = 20,
		/obj/item/grenade/iedcasing = 1,
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/assembly/prox_sensor = 1,
	)
	time = 2 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
	always_availible = FALSE

/datum/crafting_recipe/explosion_shell/New()
	. = ..()
	if(CONFIG_GET(flag/enable_bombarda_craft))
		always_availible = TRUE

/datum/crafting_recipe/flame_shell
	name = "Improvised flame shell"
	result = /obj/item/ammo_casing/a40mm/improvised/flame_shell
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/metal = 1,
		/obj/item/assembly/igniter = 1,
		/datum/reagent/fuel = 20,
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/plasma_dust = 10,
	)
	time = 2 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
	always_availible = FALSE

/datum/crafting_recipe/flame_shell/New()
	. = ..()
	if(CONFIG_GET(flag/enable_bombarda_craft))
		always_availible = TRUE

/datum/crafting_recipe/smoke_shell
	name = "Improvised smoke shell"
	result = /obj/item/ammo_casing/a40mm/improvised/smoke_shell
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/metal = 1,
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/phosphorus = 10,
		/obj/item/reagent_containers/spray/pestspray = 1,
	)
	time = 2 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
	always_availible = FALSE

/datum/crafting_recipe/smoke_shell/New()
	. = ..()
	if(CONFIG_GET(flag/enable_bombarda_craft))
		always_availible = TRUE

/obj/effect/decal/cleanable/blood/paint
	name = "paint"
	dryname = "dried paint"
	desc = "Она густая и липкая. Возможно, кто то разлил тут краску?"
	drydesc = "Она сухая и засохшая. Кто-то явно халтурит."
	gender = FEMALE
	blood_state = BLOOD_STATE_NOT_BLOODY
	//drying_time = 1

/obj/effect/decal/cleanable/blood/paint/get_ru_names()
	return list(
		NOMINATIVE = "краска",
		GENITIVE = "краски",
		DATIVE = "краске",
		ACCUSATIVE = "краску",
		INSTRUMENTAL = "краской",
		PREPOSITIONAL = "краске",
	)

/obj/effect/decal/cleanable/blood/paint/dry()
	. = ..()
	ru_names = list(
		NOMINATIVE = "краска",
		GENITIVE = "краски",
		DATIVE = "краске",
		ACCUSATIVE = "краску",
		INSTRUMENTAL = "краской",
		PREPOSITIONAL = "краске",
	)

/obj/effect/decal/cleanable/blood/drip/paint
	name = "paint"
	dryname = "dried paint"
	desc = "Оно густое и липкое. Возможно, кто то разлил тут краску?"
	blood_state = BLOOD_STATE_NOT_BLOODY
	//drying_time = 1

/obj/effect/decal/cleanable/blood/drip/paint/get_ru_names()
	return list(
		NOMINATIVE = "капли краска",
		GENITIVE = "капель краски",
		DATIVE = "каплям краски",
		ACCUSATIVE = "капли краски",
		INSTRUMENTAL = "каплями краски",
		PREPOSITIONAL = "каплях краски",
	)

/obj/effect/decal/cleanable/blood/drip/paint/dry()
	. = ..()
	ru_names = list(
		NOMINATIVE = "засохшая краска",
		GENITIVE = "засохшей краски",
		DATIVE = "засохшей краске",
		ACCUSATIVE = "засохшую краску",
		INSTRUMENTAL = "засохшей краской",
		PREPOSITIONAL = "засохшей краске",
	)
