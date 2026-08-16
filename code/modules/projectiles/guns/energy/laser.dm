// MARK: Generic
/obj/item/gun/energy/laser
	name = "laser gun"
	desc = "A basic energy-based laser gun that fires concentrated beams of light which pass through glass and thin metal."
	icon_state = "lasergun"
	item_state = null
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=4;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/laser)
	ammo_x_offset = 1
	shaded_charge = TRUE
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 4, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = -5),
	)

// MARK: Hitscan
/obj/item/gun/energy/laser/hitscan
	name = "Mk.3 laser gun"
	desc = "Третье поколение стандартной лазерной винтовки службы безопасности. Важнейшим отличием от ранних моделей является импульсная система ведения огня."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hitscan)
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BELT
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 9, "y" = -5),
	)

/obj/item/gun/energy/laser/hitscan/get_ru_names()
	return alist(
		NOMINATIVE = "лазерная винтовка «Страж»",
		GENITIVE = "лазерной винтовки «Страж»",
		DATIVE = "лазерной винтовке «Страж»",
		ACCUSATIVE = "лазерную винтовку «Страж»",
		INSTRUMENTAL = "лазерной винтовкой «Страж»",
		PREPOSITIONAL = "лазерной винтовке «Страж»",
	)

/obj/item/gun/energy/laser/hitscan/attackby(obj/item/item, mob/user, params)
	if(!is_laser_modification_case(item))
		return ..()

	var/choosen_weapon
	var/list/upgradable_variants = list(
		"карабин «Страж»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "lasergun"),
		"пистолет «Шершень»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "laserpistol"),
		"автомат «Зенит»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "lasermg"),
		"дробовик «Фокус»" = image(icon = 'icons/obj/weapons/energy.dmi', icon_state = "lasershotgun"),
		"снайперская винтовка «Игла»" = image(icon = 'icons/obj/weapons/guns_48x32.dmi', icon_state = "laserrifle"),
	)
	var/choosen_type = show_radial_menu(user, item, upgradable_variants, src, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!choosen_type || !check_menu(user) || item.loc != user)
		return ATTACK_CHAIN_PROCEED

	switch(choosen_type)
		if("карабин «Страж»")
			choosen_weapon = /obj/item/gun/energy/laser/hitscan
		if("пистолет «Шершень»")
			choosen_weapon = /obj/item/gun/energy/laser/hitscan/laser_pistol
		if("автомат «Зенит»")
			choosen_weapon = /obj/item/gun/energy/laser/hitscan/laser_mg
		if("дробовик «Фокус»")
			choosen_weapon = /obj/item/gun/energy/laser/hitscan/laser_shotgun
		if("снайперская винтовка «Игла»")
			choosen_weapon = /obj/item/gun/energy/laser/hitscan/laser_rifle

	if(!choosen_weapon)
		return ATTACK_CHAIN_PROCEED

	if(choosen_weapon == src.type)
		user.balloon_alert(user, "уже модифицировано в это!")
		return ATTACK_CHAIN_PROCEED

	user.balloon_alert(user, "модификация оружия...")
	if(!do_after(user, 10 SECONDS))
		return ATTACK_CHAIN_PROCEED

	var/turf/spawn_turf = get_turf(user)
	var/obj/item/new_gun = new choosen_weapon(spawn_turf)

	user.temporarily_remove_item_from_inventory(item)
	qdel(item)

	user.put_in_hands(new_gun)
	playsound(user, 'sound/machines/ding.ogg', 50, TRUE)
	do_sparks(3, TRUE, spawn_turf)

	user.temporarily_remove_item_from_inventory(src)
	qdel(src)


	return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

/obj/item/gun/energy/laser/hitscan/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

// MARK: Hitscan sniper rifle
/obj/item/gun/energy/laser/hitscan/laser_rifle
	name = "laser sniper rifle"
	desc = "Высококачественная лазерная снайперская винтовка, применяемая службой безопасности. Имеет два режима стрельбы: тяжёлый выстрел широкого диапазона и бронебойный выстрел, способный поражать цели за препятствием."
	icon = 'icons/obj/weapons/guns_48x32.dmi'
	icon_state = "laserrifle"
	ammo_type = list(
		/obj/item/ammo_casing/energy/laser/hitscan/laser_rifle,
		/obj/item/ammo_casing/energy/laser/hitscan/laser_rifle/armorpierce,
	)
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BACK
	accuracy = GUN_ACCURACY_SNIPER
	weapon_weight = WEAPON_HEAVY
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 4),
		ATTACHMENT_SLOT_UNDER = list("x" = 21, "y" = -9),
	)

/obj/item/gun/energy/laser/hitscan/laser_rifle/get_ru_names()
	return alist(
		NOMINATIVE = "лазерная снайперская винтовка «Игла»",
		GENITIVE = "лазерной снайперской винтовки «Игла»",
		DATIVE = "лазерной снайперской винтовке «Игла»",
		ACCUSATIVE = "лазерную снайперскую винтовку «Игла»",
		INSTRUMENTAL = "лазерной снайперской винтовкой «Игла»",
		PREPOSITIONAL = "лазерной снайперской винтовке «Игла»",
	)

// MARK: Hitscan shotgun
/obj/item/gun/energy/laser/hitscan/laser_shotgun
	name = "laser shotgun"
	desc = "Экспериментальный лазерный дробовик с возможностью настройки фокусировки линз. В зависимости от настройки, дробовик способен бить как рассеяным, так и сфокусированным лучом."
	icon_state = "lasershotgun"
	ammo_type = list(
		/obj/item/ammo_casing/energy/laser/hitscan/laser_shotgun,
		/obj/item/ammo_casing/energy/laser/hitscan/laser_shotgun/wide,
	)
	slot_flags = ITEM_SLOT_SUITSTORE
	accuracy = GUN_ACCURACY_RIFLE
	weapon_weight = WEAPON_HEAVY
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 2, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 9, "y" = -6),
	)

/obj/item/gun/energy/laser/hitscan/laser_shotgun/get_ru_names()
	return alist(
		NOMINATIVE = "лазерный дробовик «Фокус»",
		GENITIVE = "лазерного дробовика «Фокус»",
		DATIVE = "лазерному дробовику «Фокус»",
		ACCUSATIVE = "лазерный дробовик «Фокус»",
		INSTRUMENTAL = "лазерным дробовиком «Фокус»",
		PREPOSITIONAL = "лазерном дробовике «Фокус»",
	)

// MARK: Hitscan MG
/obj/item/gun/energy/laser/hitscan/laser_mg
	name = "laser machine gun"
	desc = "Лазерная винтовка, используемый службой безопасности. Экспериментальный генератор частиц способен запускать снаряды, рикошетящие от стен."
	icon_state = "lasermg"
	ammo_type = list(
		/obj/item/ammo_casing/energy/laser/hitscan/laser_mg,
		/obj/item/ammo_casing/energy/laser/hitscan/laser_mg/ricochet,
	)
	slot_flags = ITEM_SLOT_SUITSTORE
	accuracy = GUN_ACCURACY_RIFLE
	weapon_weight = WEAPON_HEAVY
	burst_amount = 3
	fire_delay = 0.2 SECONDS
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 2, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 7, "y" = -6),
	)
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE)
	gun_flags = GUN_AMMO_COUNTER
	ammo_count_overlay = "counter_laser"
	ammo_count_colour = COLOR_CYAN

/obj/item/gun/energy/laser/hitscan/laser_mg/get_ru_names()
	return alist(
		NOMINATIVE = "лазерная винтовка «Зенит»",
		GENITIVE = "лазерной винтовки «Зенит»",
		DATIVE = "лазерной винтовке «Зенит»",
		ACCUSATIVE = "лазерную винтовку «Зенит»",
		INSTRUMENTAL = "лазерной винтовкой «Зенит»",
		PREPOSITIONAL = "лазерной винтовке «Зенит»",
	)

// MARK: Hitscan pistol
/obj/item/gun/energy/laser/hitscan/laser_pistol
	name = "laser pistol"
	desc = "Тактический лазерный пистолет, используемый службой безопасности. Способен вести огонь как в обычном, так и в ускоренном режиме."
	icon_state = "laserpistol"
	ammo_type = list(
		/obj/item/ammo_casing/energy/laser/hitscan/laser_pistol,
		/obj/item/ammo_casing/energy/laser/hitscan/laser_pistol/light,
	)
	w_class = WEIGHT_CLASS_NORMAL
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 5, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 4, "y" = -5),
	)

/obj/item/gun/energy/laser/hitscan/laser_pistol/get_ru_names()
	return alist(
		NOMINATIVE = "лазерный пистолет «Шершень»",
		GENITIVE = "лазерного пистолета «Шершень»",
		DATIVE = "лазерному пистолету «Шершень»",
		ACCUSATIVE = "лазерный пистолет «Шершень»",
		INSTRUMENTAL = "лазерным пистолетом «Шершень»",
		PREPOSITIONAL = "лазерном пистолете «Шершень»",
	)

// MARK: Sibyl variants
/obj/item/gun/energy/laser/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/laser/hitscan/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

// MARK: Practice
/obj/item/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	icon_state = "laser"
	item_state = "laser"
	origin_tech = "combat=2;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = 0
	needs_permit = FALSE
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_NONE

// MARK: Retro
/obj/item/gun/energy/laser/retro
	name = "retro laser gun"
	icon_state = "retro"
	item_state = "laser"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's private security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	ammo_x_offset = 3
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_NONE

// MARK: Antique (Captain)
/obj/item/gun/energy/laser/captain
	name = "antique laser gun"
	icon_state = "caplaser"
	item_state = "caplaser"
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	force = 10
	origin_tech = null
	ammo_x_offset = 3
	selfcharge = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/high_risk = TRUE
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/energy/laser/captain/Initialize(mapload, ...)
	. = ..()
	if(high_risk)
		AddElement(/datum/element/high_value_item)

/obj/item/gun/energy/laser/captain/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

/obj/item/gun/energy/laser/captain/scattershot
	name = "scatter shot laser rifle"
	icon_state = "lasercannon"
	item_state = "laser"
	desc = "An industrial-grade heavy-duty laser rifle with a modified laser lense to scatter its shot into multiple smaller lasers. The inner-core can self-charge for theorically infinite use."
	origin_tech = "combat=5;materials=4;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)
	shaded_charge = FALSE
	high_risk = FALSE
	accuracy = GUN_ACCURACY_SHOTGUN

// MARK: Cyborg
/obj/item/gun/energy/laser/cyborg
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/cyborg)
	can_charge = FALSE
	origin_tech = null
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/energy/laser/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/laser/cyborg/emp_act()
	return

/obj/item/gun/energy/laser/scatter
	name = "scatter laser gun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)
	accuracy = GUN_ACCURACY_SHOTGUN
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 4, ATTACHMENT_OFFSET_Y = 8),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = -5),
	)

// MARK: Laser cannon
/obj/item/gun/energy/lasercannon
	name = "accelerator laser cannon"
	desc = "An advanced laser cannon that does more damage the farther away the target is."
	icon_state = "lasercannon"
	item_state = null
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	force = 10
	slot_flags = ITEM_SLOT_BACK
	can_holster = FALSE
	origin_tech = "combat=4;magnets=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/accelerator)
	ammo_x_offset = 3
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = 7),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = -7),
	)

/obj/item/gun/energy/lasercannon/cyborg
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/energy/lasercannon/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/lasercannon/cyborg/emp_act()
	return

// MARK: X-ray
/obj/item/gun/energy/xray
	name = "x-ray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts. These blasts will penetrate solid objects, but will decrease in power the longer they have to travel."
	icon_state = "xray"
	origin_tech = "combat=6;materials=4;magnets=4"
	ammo_type = list(/obj/item/ammo_casing/energy/xray)
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = 7),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = -7),
	)

// MARK: Immolator
/obj/item/gun/energy/immolator
	name = "Immolator laser gun"
	desc = "A modified laser gun, shooting highly concetrated beams with higher intensity that ignites the target, for the cost of draining more power per shot"
	icon_state = "immolator"
	item_state = "laser"
	ammo_type = list(/obj/item/ammo_casing/energy/immolator)
	origin_tech = "combat=4;magnets=4;powerstorage=3"
	shaded_charge = TRUE
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = 7),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = -7),
	)

/obj/item/gun/energy/immolator/multi
	name = "multi lens immolator cannon"
	desc = "A large laser cannon, similar to the Immolator Laser, with toggleable firemodes. It is frequently used by military-like forces through Nanotrasen."
	icon_state = "multilensimmolator"
	ammo_type = list(/obj/item/ammo_casing/energy/immolator/strong, /obj/item/ammo_casing/energy/immolator/scatter)
	origin_tech = "combat=5;magnets=5;powerstorage=4"
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_ENERGY_WEAPON

/obj/item/gun/energy/immolator/multi/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/immolator/multi/update_overlays()
	. = ..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/append = shot.select_name
	. += image(icon, icon_state = "multilensimmolator-[append]")

/obj/item/gun/energy/immolator/multi/cyborg
	name = "cyborg immolator cannon"
	ammo_type = list(/obj/item/ammo_casing/energy/immolator/scatter/cyborg, /obj/item/ammo_casing/energy/immolator/strong/cyborg) // scatter is default, because it is more useful
	attachable_allowed = GUN_MODULE_CLASS_NONE

// MARK: Laser tag
/obj/item/gun/energy/laser/tag
	icon_state = "bluetag"
	item_state = "laser"
	name = "laser tag gun"
	desc = "Standard issue weapon of the Imperial Guard"
	origin_tech = "combat=2;magnets=2"
	clumsy_check = FALSE
	needs_permit = FALSE
	ammo_x_offset = 2
	selfcharge = TRUE
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/energy/laser/tag/blue
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)

/obj/item/gun/energy/laser/tag/red
	icon_state = "redtag"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)

// MARK: Mounted
/obj/item/gun/energy/laser/mounted
	name = "mounted laser"
	desc = "An arm mounted cannon that fires lethal lasers."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "laser"
	item_state = "armcannonlase"
	selfcharge = TRUE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	attachable_allowed = null
