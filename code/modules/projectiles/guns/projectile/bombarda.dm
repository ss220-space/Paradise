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
	if(istype(item, /obj/item/ammo_casing))
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


/obj/item/gun/projectile/bombarda/process_chamber(eject_casing = TRUE, empty_chamber = TRUE)
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


/obj/item/gun/projectile/bombarda/attack_self(mob/living/user)
	if(!COOLDOWN_FINISHED(src, last_pump))
		return
	COOLDOWN_START(src, last_pump, pump_cooldown)
	add_fingerprint(user)
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


// MARK: Security GL
/obj/item/gun/projectile/bombarda/secgl
	name = "grenade launcher GL-06"
	desc = "Однозарядный ручной гранатомёт, разработанный специально для сотрудников службы безопасности. Примеяется для подавления беспорядков с помощью нелетальных боеприпасов. Может запускать 40 мм гранаты."
	ru_names = list(
		NOMINATIVE = "ручной гранатомет GL-06",
		GENITIVE = "ручного гранатомета GL-06",
		DATIVE = "ручному гранатомету GL-06",
		ACCUSATIVE = "ручной гранатомет GL-06",
		INSTRUMENTAL = "ручным гранатометом GL-06",
		PREPOSITIONAL = "ручном гранатомете GL-06"
	)
	icon_state = "secgl"
	item_state = "secgl"
	mag_type = /obj/item/ammo_box/magazine/internal/bombarda/secgl
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_HIGH


/obj/item/gun/projectile/bombarda/secgl/x4
	name = "grenade launcher GL-08-4"
	desc = "Четырехзарядный ручной гранатомёт, разработанный специально для сотрудников службы безопасности. Применяется для подавления беспорядков с помощью не летальных боеприпасов. Может запускать 40 мм гранаты."
	ru_names = list(
		NOMINATIVE = "ручной гранатомет GL-08-4",
		GENITIVE = "ручного гранатомета GL-08-4",
		DATIVE = "ручному гранатомету GL-08-4",
		ACCUSATIVE = "ручной гранатомет GL-08-4",
		INSTRUMENTAL = "ручным гранатометом GL-08-4",
		PREPOSITIONAL = "ручном гранатомете GL-08-4"
	)
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

/obj/item/gun/projectile/bombarda/secgl/x4/Initialize(mapload, ...)
	. = ..()
	if(high_risk)
		AddElement(/datum/element/high_value_item)

// MARK: M79
/obj/item/gun/projectile/bombarda/secgl/m79
	name = "grenade launcher M79"
	desc = "Классический однозарядный ручной гранатомёт, разработанный в 1961 году. Использует 40 мм гранаты."
	ru_names = list(
		NOMINATIVE = "ручной гранатомет M79",
		GENITIVE = "ручного гранатомета M79",
		DATIVE = "ручному гранатомету M79",
		ACCUSATIVE = "ручной гранатомет M79",
		INSTRUMENTAL = "ручным гранатометом M79",
		PREPOSITIONAL = "ручном гранатомете M79"
	)
	icon_state = "m79"
	item_state = "m79"


// MARK: Bombplet

/obj/item/gun/projectile/bombarda/bombplet
	name = "bombplet"
	desc = "Двуствольная самодельная бомбарда. Использует 40 мм гранаты."
	ru_names = list(
		NOMINATIVE = "самодельный двуствольный гранатомет",
		GENITIVE = "самодельного двуствольного гранатомета",
		DATIVE = "самодельному двуствольному гранатомету",
		ACCUSATIVE = "самодельный двуствольный гранатомет",
		INSTRUMENTAL = "самодельным двуствольным гранатометом",
		PREPOSITIONAL = "самодельном двуствольном гранатомете"
	)
	icon_state = "bombplet"
	item_state = "bombplet"
	mag_type = /obj/item/ammo_box/magazine/internal/bombarda/x2


// MARK: Bombarda ammo
/obj/item/ammo_box/magazine/internal/bombarda
	name = "bombarda internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm/improvised
	caliber = CALIBER_40MM
	max_ammo = 1
	insert_sound = 'sound/weapons/bombarda/load.ogg'
	remove_sound = 'sound/weapons/bombarda/open.ogg'
	load_sound = 'sound/weapons/bombarda/load.ogg'
	start_empty = TRUE

/obj/item/ammo_box/magazine/internal/bombarda/x2
	max_ammo = 2

/obj/item/ammo_box/magazine/internal/bombarda/ammo_count(countempties = TRUE)
	. = 0
	for(var/obj/item/ammo_casing/bullet in stored_ammo)
		if(bullet.BB || countempties)
			.++


/obj/item/ammo_casing/a40mm/improvised
	name = "Improvised shell"
	desc = "Does something upon impact or after some time. If you see this, contact the coder."
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "exp_shell"
	item_state = "exp_shell"
	drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'

/obj/item/ammo_casing/a40mm/improvised/exp_shell
	name = "Improvised explosive shell"
	desc = "Explodes upon impact or after some time."
	projectile_type = /obj/projectile/grenade/improvised/exp_shot
	icon_state = "exp_shell"
	item_state = "exp_shell"

/obj/item/ammo_casing/a40mm/improvised/flame_shell
	name = "Improvised flame shell"
	desc = "Explodes with flames upon impact or after some time"
	projectile_type = /obj/projectile/grenade/improvised/flame_shot
	icon_state = "flame_shell"
	item_state = "flame_shell"

/obj/item/ammo_casing/a40mm/improvised/smoke_shell
	name = "Improvised smoke shell"
	desc = "Explodes with smoke upon impact or after some time"
	projectile_type = /obj/projectile/grenade/improvised/smoke_shot
	icon_state = "smoke_shell"
	item_state = "smoke_shell"

/obj/projectile/grenade/improvised
	icon = 'icons/obj/weapons/bombarda.dmi'
	hitsound = SFX_BULLET
	hitsound_wall = SFX_RICOCHET

/obj/projectile/grenade/improvised/exp_shot
	icon_state = "exp_shot"

/obj/projectile/grenade/improvised/exp_shot/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	explosion(loc, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flame_range = 3, cause = src)

/obj/projectile/grenade/improvised/flame_shot
	icon_state = "flame_shot"

/obj/projectile/grenade/improvised/flame_shot/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	explosion(loc, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flame_range = 8, cause = src)
	fireflash(loc, 2, 682)

/obj/projectile/grenade/improvised/smoke_shot
	icon_state = "smoke_shot"

/obj/projectile/grenade/improvised/smoke_shot/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
	smoke.set_up(amount = 18, location = loc)
	smoke.effect_type = /obj/effect/particle_effect/fluid/smoke/bad/bombarda
	smoke.start()

/datum/crafting_recipe/bombarda
	name = "Bombarda"
	result = /obj/item/gun/projectile/bombarda
	reqs = list(/obj/item/restraints/handcuffs/cable = 2,
				/obj/item/stack/tape_roll = 10,
				/obj/item/pipe = 1,
				/obj/item/weaponcrafting/receiver = 1,
				/obj/item/stack/sheet/metal = 2,
				/obj/item/weaponcrafting/stock = 1)
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
	reqs = list(/datum/reagent/blackpowder = 20,
				/obj/item/grenade/iedcasing = 1,
				/obj/item/grenade/chem_grenade = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/assembly/prox_sensor = 1)
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
	reqs = list(/obj/item/grenade/chem_grenade = 1,
					/obj/item/stack/cable_coil = 5,
					/obj/item/stack/sheet/metal = 1,
					/obj/item/assembly/igniter = 1,
					/datum/reagent/fuel = 20,
					/datum/reagent/consumable/sugar = 10,
					/datum/reagent/plasma_dust = 10)
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
	reqs = list(/obj/item/grenade/chem_grenade = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/stack/sheet/metal = 1,
				/datum/reagent/consumable/sugar = 10,
				/datum/reagent/phosphorus = 10,
				/obj/item/reagent_containers/spray/pestspray = 1)
	time = 2 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
	always_availible = FALSE

/datum/crafting_recipe/smoke_shell/New()
	. = ..()
	if(CONFIG_GET(flag/enable_bombarda_craft))
		always_availible = TRUE


// MARK: 40mm ammo
/obj/item/ammo_box/magazine/internal/bombarda/secgl
	name = "security grenade launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = CALIBER_40MM
	max_ammo = 1
	insert_sound = 'sound/weapons/bombarda/load.ogg'
	remove_sound = 'sound/weapons/bombarda/open.ogg'
	load_sound = 'sound/weapons/bombarda/load.ogg'
	start_empty = TRUE

/obj/item/ammo_box/magazine/internal/bombarda/secgl/x4
	max_ammo = 4

/obj/item/ammo_casing/a40mm/secgl
	name = "40mm grenade"
	ru_names = list(
		NOMINATIVE = "граната (40 мм)",
		GENITIVE = "гранаты (40 мм)",
		DATIVE = "гранате (40 мм)",
		ACCUSATIVE = "гранату (40 мм)",
		INSTRUMENTAL = "гранатой (40 мм)",
		PREPOSITIONAL = "гранате (40 мм)"
	)
	desc = "Граната калибра 40 мм."
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "secgl_solid"
	item_state = "secgl_solid"
	caliber = CALIBER_40MM
	drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'
	casing_drop_sound = 'sound/weapons/gun_interactions/shotgun_fall.ogg'

/obj/projectile/grenade/a40mm/secgl
	icon = 'icons/obj/weapons/bombarda.dmi'
	hitsound = "bullet"
	hitsound_wall = "ricochet"
	damage = 5
	stamina = 15
	armour_penetration = -30

/obj/item/ammo_box/secgl
	icon = 'icons/obj/weapons/bombarda.dmi'
	icon_state = "secgl_box_gas"
	ammo_type = /obj/item/ammo_casing/a40mm/secgl
	max_ammo = 4



/obj/item/ammo_casing/a40mm/secgl/solid
	name = "40mm grenade (rubber slug)"
	ru_names = list(
		NOMINATIVE = "граната (40 мм цельная резина)",
		GENITIVE = "гранаты (40 мм цельная резина)",
		DATIVE = "гранате (40 мм цельная резина)",
		ACCUSATIVE = "гранату (40 мм цельная резина)",
		INSTRUMENTAL = "гранатой (40 мм цельная резина)",
		PREPOSITIONAL = "гранате (40 мм цельная резина)"
	)
	desc = "Граната калибра 40 мм с цельной резиновой пулей. Отлично подходит для нейтрализации активных митингующих из толпы нелетальным способом."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/solid
	icon_state = "secgl_solid"
	item_state = "secgl_solid"

/obj/projectile/grenade/a40mm/secgl/solid
	icon_state = "secgl_projectile_solid"
	damage_type = BRUTE
	damage = 20
	tile_dropoff = 1
	stamina = 120
	tile_dropoff_s = 5
	min_stamina = 90
	armour_penetration = -30

/obj/item/ammo_box/secgl/solid
	name = "ammo box (40mm solid)"
	desc = "Коробка, содержащая гранаты с цельной резиновой пулей калибра 40 мм."
	ru_names = list(
		NOMINATIVE = "коробка гранат (40 мм цельная резина)",
		GENITIVE = "коробки гранат (40 мм цельная резина)",
		DATIVE = "коробке гранат (40 мм цельная резина)",
		ACCUSATIVE = "коробку гранат (40 мм цельная резина)",
		INSTRUMENTAL = "коробкой гранат (40 мм цельная резина)",
		PREPOSITIONAL = "коробке гранат (40 мм цельная резина)"
	)
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/solid
	icon_state = "secgl_box_solid"


/obj/item/ammo_casing/a40mm/secgl/flash
	name = "40mm grenade (flashbang)"
	ru_names = list(
		NOMINATIVE = "граната (40 мм светошумовая)",
		GENITIVE = "гранаты (40 мм светошумовая)",
		DATIVE = "гранате (40 мм светошумовая)",
		ACCUSATIVE = "гранату (40 мм светошумовая)",
		INSTRUMENTAL = "гранатой (40 мм светошумовая)",
		PREPOSITIONAL = "гранате (40 мм светошумовая)"
	)
	desc = "Граната калибра 40 мм со светошумовой гранатой. Отличная возможность закинуть светошумовую гранату на далекие расстояния."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/flash
	icon_state = "secgl_flash"
	item_state = "secgl_flash"

/obj/projectile/grenade/a40mm/secgl/flash
	icon_state = "secgl_porjectile_flash"

/obj/projectile/grenade/a40mm/secgl/flash/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	// VFX and SFX
	do_sparks(rand(5, 9), FALSE, src)
	playsound(loc, 'sound/effects/bang.ogg', 100, TRUE)
	new /obj/effect/dummy/lighting_obj(loc, range + 2, 10, light_color, 0.2 SECONDS)
	// Blob damage
	for(var/obj/structure/blob/blob in hear(range + 1, loc))
		var/damage = round(30 / (get_dist(blob, loc) + 1))
		blob.take_damage(damage, BURN, MELEE, FALSE)
	// Stunning & damaging mechanic
	bang(loc, src, 7, direct_bang = FALSE)

/obj/item/ammo_box/secgl/flash
	name = "ammo box (40mm flashbang)"
	desc = "Коробка, содержащая светошумовые гранаты калибра 40 мм."
	ru_names = list(
		NOMINATIVE = "коробка гранат (40 мм светошумовая)",
		GENITIVE = "коробки гранат (40 мм светошумовая)",
		DATIVE = "коробке гранат (40 мм светошумовая)",
		ACCUSATIVE = "коробку гранат (40 мм светошумовая)",
		INSTRUMENTAL = "коробкой гранат (40 мм светошумовая)",
		PREPOSITIONAL = "коробке гранат (40 мм светошумовая)"
	)
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/flash
	icon_state = "secgl_box_flash"


/obj/item/ammo_casing/a40mm/secgl/gas
	name = "40mm grenade (gatears)"
	ru_names = list(
		NOMINATIVE = "граната (40 мм слезоточивый газ)",
		GENITIVE = "гранаты (40 мм слезоточивый газ)",
		DATIVE = "гранате (40 мм слезоточивый газ)",
		ACCUSATIVE = "гранату (40 мм слезоточивый газ)",
		INSTRUMENTAL = "гранатой (40 мм слезоточивый газ)",
		PREPOSITIONAL = "гранате (40 мм слезоточивый газ)"
	)
	desc = "Граната калибра 40 мм со слезоточивым газом. Позволяет разогнать толпу митингующих без защиты органов дыхания."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/gas
	icon_state = "secgl_gas"
	item_state = "secgl_gas"

/obj/projectile/grenade/a40mm/secgl/gas
	icon_state = "secgl_projectile_gas"

/obj/projectile/grenade/a40mm/secgl/gas/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/obj/item/grenade/grenade = new /obj/item/grenade/chem_grenade/teargas(loc)
	grenade.prime()

/obj/item/ammo_box/secgl/gas
	name = "ammo box (40mm teargas)"
	desc = "Коробка, содержащая гранаты со слезоточивым газом калибра 40 мм."
	ru_names = list(
		NOMINATIVE = "коробка гранат (40 мм слезоточивый газ)",
		GENITIVE = "коробки гранат (40 мм слезоточивый газ)",
		DATIVE = "коробке гранат (40 мм слезоточивый газ)",
		ACCUSATIVE = "коробку гранат (40 мм слезоточивый газ)",
		INSTRUMENTAL = "коробкой гранат (40 мм слезоточивый газ)",
		PREPOSITIONAL = "коробке гранат (40 мм слезоточивый газ)"
	)
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/gas
	icon_state = "secgl_box_gas"


/obj/item/ammo_casing/a40mm/secgl/barricade
	name = "40mm grenade (barricade)"
	ru_names = list(
		NOMINATIVE = "граната (40 мм баррикада)",
		GENITIVE = "гранаты (40 мм баррикада)",
		DATIVE = "гранате (40 мм баррикада)",
		ACCUSATIVE = "гранату (40 мм баррикада)",
		INSTRUMENTAL = "гранатой (40 мм баррикада)",
		PREPOSITIONAL = "гранате (40 мм баррикада)"
	)
	desc = "Граната калибра 40 мм со слезоточивым газом. Позволяет разогнать толпу митингующих без защиты органов дыхания."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/barricade
	icon_state = "secgl_barricade"
	item_state = "secgl_barricade"

/obj/projectile/grenade/a40mm/secgl/barricade
	icon_state = "secgl_projectile_barricade"

/obj/projectile/grenade/a40mm/secgl/barricade/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/obj/item/grenade/grenade = new /obj/item/grenade/barrier(loc)
	grenade.prime()

/obj/item/ammo_box/secgl/barricade
	name = "ammo box (40mm barricade)"
	desc = "Коробка, содержащая гранаты с баррикадой калибра 40 мм."
	ru_names = list(
		NOMINATIVE = "коробка гранат (40 мм баррикада)",
		GENITIVE = "коробки гранат (40 мм баррикада)",
		DATIVE = "коробке гранат (40 мм баррикада)",
		ACCUSATIVE = "коробку гранат (40 мм баррикада)",
		INSTRUMENTAL = "коробкой гранат (40 мм баррикада)",
		PREPOSITIONAL = "коробке гранат (40 мм баррикада)"
	)
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/barricade
	icon_state = "secgl_box_barricade"


/obj/item/ammo_casing/a40mm/secgl/exp
	name = "40mm grenade (frag)"
	ru_names = list(
		NOMINATIVE = "граната (40 мм осколочная)",
		GENITIVE = "гранаты (40 мм осколочная)",
		DATIVE = "гранате (40 мм осколочная)",
		ACCUSATIVE = "гранату (40 мм осколочная)",
		INSTRUMENTAL = "гранатой (40 мм осколочная)",
		PREPOSITIONAL = "гранате (40 мм осколочная)"
	)
	desc = "Граната калибра 40 мм с осколочной рубашкой. Летальный боеприпас для закидывания на дальнее расстояние."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/exp
	icon_state = "secgl_exp"
	item_state = "secgl_exp"

/obj/projectile/grenade/a40mm/secgl/exp
	icon_state = "secgl_projectile_exp"

/obj/projectile/grenade/a40mm/secgl/exp/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/obj/item/grenade/grenade = new /obj/item/grenade/frag/less(loc)
	grenade.prime()

/obj/item/grenade/frag/less
	range = 2
	max_shrapnel = 3
	embed_prob = 100

/obj/item/ammo_box/secgl/exp
	name = "ammo box (40mm frag)"
	desc = "Коробка, содержащая осколочные гранаты калибра 40 мм."
	ru_names = list(
		NOMINATIVE = "коробка гранат (40 мм осколочные)",
		GENITIVE = "коробки гранат (40 мм осколочные)",
		DATIVE = "коробке гранат (40 мм осколочные)",
		ACCUSATIVE = "коробку гранат (40 мм осколочные)",
		INSTRUMENTAL = "коробкой гранат (40 мм осколочные)",
		PREPOSITIONAL = "коробке гранат (40 мм осколочные)"
	)
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/exp
	icon_state = "secgl_box_exp"


/obj/item/ammo_casing/a40mm/secgl/paint
	name = "40mm grenade (paint)"
	ru_names = list(
		NOMINATIVE = "граната (40 мм краска)",
		GENITIVE = "гранаты (40 мм краска)",
		DATIVE = "гранате (40 мм краска)",
		ACCUSATIVE = "гранату (40 мм краска)",
		INSTRUMENTAL = "гранатой (40 мм краска)",
		PREPOSITIONAL = "гранате (40 мм краска)"
	)
	desc = "Граната калибра 40 мм с краской. Граната которая закрашивает цель для его отслеживания."
	projectile_type = /obj/projectile/grenade/a40mm/secgl/paint
	icon_state = "secgl_paint"
	item_state = "secgl_paint"

/obj/projectile/grenade/a40mm/secgl/paint
	icon_state = "secgl_projectile_paint"
	var/paint_color = "#e99518"

/obj/projectile/grenade/a40mm/secgl/paint/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/obj/effect/decal/cleanable/blood/paint/paint = new(loc)
	paint.basecolor = paint_color
	paint.update_icon()
	var/mob/living/carbon/human/human = target
	if(istype(human))
		human.add_blood(human.get_blood_dna_list(), color = paint_color)
		var/datum/component/paint_splatter/component = human.GetComponent(/datum/component/paint_splatter)
		if(component)
			component.restart_live_timer(amount = 25)
			return
		human.AddComponent(/datum/component/paint_splatter, color = paint_color, amount = 25, chance = 50, duration = 60 SECONDS)

/obj/item/ammo_box/secgl/paint
	name = "ammo box (40mm paint)"
	desc = "Коробка, содержащая гранаты с краской калибра 40 мм."
	ru_names = list(
		NOMINATIVE = "коробка гранат (40 мм краска)",
		GENITIVE = "коробки гранат (40 мм краска)",
		DATIVE = "коробке гранат (40 мм краска)",
		ACCUSATIVE = "коробку гранат (40 мм краска)",
		INSTRUMENTAL = "коробкой гранат (40 мм краска)",
		PREPOSITIONAL = "коробке гранат (40 мм краска)"
	)
	ammo_type = /obj/item/ammo_casing/a40mm/secgl/paint
	icon_state = "secgl_box_paint"


/obj/effect/decal/cleanable/blood/paint
	name = "paint"
	dryname = "dried paint"
	desc = "Она густая и липкая. Возможно, кто то разлил тут краску?"
	drydesc = "Она сухая и засохшая. Кто-то явно халтурит."
	ru_names = list(
		NOMINATIVE = "краска",
		GENITIVE = "краски",
		DATIVE = "краске",
		ACCUSATIVE = "краску",
		INSTRUMENTAL = "краской",
		PREPOSITIONAL = "краске"
	)
	gender = FEMALE
	blood_state = BLOOD_STATE_NOT_BLOODY
	//drying_time = 1

/obj/effect/decal/cleanable/blood/paint/dry()
	. = ..()
	ru_names = list(
		NOMINATIVE = "краска",
		GENITIVE = "краски",
		DATIVE = "краске",
		ACCUSATIVE = "краску",
		INSTRUMENTAL = "краской",
		PREPOSITIONAL = "краске"
	)

/obj/effect/decal/cleanable/blood/drip/paint
	name = "paint"
	dryname = "dried paint"
	desc = "Оно густое и липкое. Возможно, кто то разлил тут краску?"
	drydesc = "Оно сухое и засохшее. Кто-то явно халтурит."
	ru_names = list(
		NOMINATIVE = "капли краска",
		GENITIVE = "капель краски",
		DATIVE = "каплям краски",
		ACCUSATIVE = "капли краски",
		INSTRUMENTAL = "каплями краски",
		PREPOSITIONAL = "каплях краски"
	)
	blood_state = BLOOD_STATE_NOT_BLOODY
	//drying_time = 1

/obj/effect/decal/cleanable/blood/drip/paint/dry()
	. = ..()
	ru_names = list(
		NOMINATIVE = "засохшая краска",
		GENITIVE = "засохшей краски",
		DATIVE = "засохшей краске",
		ACCUSATIVE = "засохшую краску",
		INSTRUMENTAL = "засохшей краской",
		PREPOSITIONAL = "засохшей краске"
	)
