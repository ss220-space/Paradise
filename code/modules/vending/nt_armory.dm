// Vendor flick sequence bitflags
/// Machine is not using vending/denying overlays
#define FLICK_NONE 0
/// Machine is currently vending wares, and will not update its icon, unless its stat change.
#define FLICK_VEND 1
/// Machine is currently denying wares, and will not update its icon, unless its stat change.
#define FLICK_DENY 2

/obj/machinery/vending/nta
	name = "NT Ammunition"
	desc = "Автомат-помощник по выдаче боеприпасов."
	slogan_list = list(
		"Возьм+и поб+ольше патр+онов!",
		"Не забыв+ай, снаряж+аться – пол+езно!",
		"Бжж-Бзз-з!",
		"Обезоп+асить, Удерж+ать, Сохран+ить!",
		"Сто+ять, сняряд+ись на зад+ание!"
	)

	icon_state = "nta_base"
	panel_overlay = "nta_panel"
	screen_overlay = "nta"
	lightmask_overlay = "nta_lightmask"
	broken_overlay = "nta_broken"
	broken_lightmask_overlay = "nta_lightmask"
	vend_overlay = "nta_vend"
	deny_overlay = "nta_deny"
	vend_overlay_time = 3 SECONDS

	req_access = list(ACCESS_SECURITY)
	products = list(
		/obj/item/grenade/flashbang = 4,
		/obj/item/flash = 5,
		/obj/item/flashlight/seclite = 4,
		/obj/item/restraints/legcuffs/bola/energy = 8,

		/obj/item/ammo_box/shotgun = 4,
		/obj/item/ammo_box/shotgun/buck = 4,
		/obj/item/ammo_box/shotgun/rubbershot = 4,
		/obj/item/ammo_box/shotgun/stunslug = 5,
		/obj/item/ammo_box/shotgun/ion = 2,
		/obj/item/ammo_box/shotgun/laserslug = 5,
		/obj/item/ammo_box/speedloader/shotgun = 8,

		/obj/item/ammo_box/magazine/lr30mag = 12,
		/obj/item/ammo_box/magazine/enforcer = 8,
		/obj/item/ammo_box/magazine/enforcer/lethal = 8,
		/obj/item/ammo_box/magazine/sp8 = 8,

		/obj/item/ammo_box/magazine/laser = 12,
		/obj/item/ammo_box/magazine/wt550m9 = 20,
		/obj/item/ammo_box/magazine/m556 = 12,
		/obj/item/ammo_box/a40mm = 4,

		/obj/item/ammo_box/c46x30mm = 8,
		/obj/item/ammo_box/inc46x30mm = 4,
		/obj/item/ammo_box/tox46x30mm = 4,
		/obj/item/ammo_box/ap46x30mm = 4,
		/obj/item/ammo_box/laserammobox = 4
	)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,/obj/item/storage/fancy/donut_box = 2,/obj/item/grenade/clusterbuster/apocalypsefake = 1)
	refill_canister = /obj/item/vending_refill/nta
	tiltable = FALSE //no ert tilt

/obj/machinery/vending/nta/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NT Ammunition",
		GENITIVE = "торгового автомата NT Ammunition",
		DATIVE = "торговому автомату NT Ammunition",
		ACCUSATIVE = "торговый автомат NT Ammunition",
		INSTRUMENTAL = "торговым автоматом NT Ammunition",
		PREPOSITIONAL = "торговом автомате NT Ammunition"
	)

/obj/machinery/vending/nta/ertarmory
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/machinery/vending/nta/ertarmory/update_overlays()
	. = list()

	underlays.Cut()

	. += base_icon_state

	if(panel_open)
		. += "nta_panel"

	if((stat & NOPOWER) || force_no_power_icon_state)
		. += "nta_off"
		return

	if(stat & BROKEN)
		. += "nta_broken"
	else
		if(flick_sequence & FLICK_VEND)
			. += vend_overlay

		else if(flick_sequence & FLICK_DENY)
			. += deny_overlay

	underlays += emissive_appearance(icon, "nta_lightmask", src)


/obj/machinery/vending/nta/ertarmory/blue
	name = "NT ERT Medium Gear & Ammunition"
	desc = "Автомат-помощник по выдаче снаряжения среднего класса."
	slogan_list = list(
		"Круш+и череп+а враг+ов Нанотр+ейзен!",
		"Не забыв+ай, спас+ать – пол+езно!",
		"Бжж-Бзз-з!",
		"Обезоп+асить, Удерж+ать, Сохран+ить!",
		"Сто+ять, сняряд+ись на зад+ание!"
	)

	base_icon_state = "nta-blue"
	deny_overlay = "nta-blue_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/gun/energy/gun = 3,
		/obj/item/gun/energy/ionrifle/carbine = 1,
		/obj/item/gun/projectile/automatic/lasercarbine = 3,
		/obj/item/ammo_box/magazine/laser = 6,
		/obj/item/gun_module/muzzle/suppressor = 4,
		/obj/item/ammo_box/speedloader/shotgun = 4,
		/obj/item/gun/projectile/automatic/sfg = 3,
		/obj/item/ammo_box/magazine/sfg9mm = 6,
		/obj/item/gun/projectile/shotgun/automatic/combat = 3,
		/obj/item/ammo_box/shotgun = 4,
		/obj/item/ammo_box/shotgun/buck = 4,
		/obj/item/ammo_box/shotgun/dragonsbreath = 2
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)

/obj/machinery/vending/nta/ertarmory/blue/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NT ERT Medium Gear & Ammunition",
		GENITIVE = "торгового автомата NT ERT Medium Gear & Ammunition",
		DATIVE = "торговому автомату NT ERT Medium Gear & Ammunition",
		ACCUSATIVE = "торговый автомат NT ERT Medium Gear & Ammunition",
		INSTRUMENTAL = "торговым автоматом NT ERT Medium Gear & Ammunition",
		PREPOSITIONAL = "торговом автомате NT ERT Medium Gear & Ammunition"
	)

/obj/machinery/vending/nta/ertarmory/red
	name = "NT ERT Heavy Gear & Ammunition"
	desc = "Автомат-помощник по выдаче снаряжения тяжелого класса."
	slogan_list = list(
		"Круш+и череп+а враг+ов Нанотр+ейзен!",
		"Не забыв+ай, спас+ать – пол+езно!",
		"Бжж-Бзз-з!",
		"Обезоп+асить, Удерж+ать, Сохран+ить!",
		"Сто+ять, сняряд+ись на зад+ание!"
	)

	base_icon_state = "nta-red"
	deny_overlay = "nta-red_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/gun/projectile/automatic/ar = 3,
		/obj/item/ammo_box/magazine/m556 = 6,
		/obj/item/gun/projectile/automatic/m52 = 3,
		/obj/item/ammo_box/magazine/m52mag = 6,
		/obj/item/gun/energy/sniperrifle = 1,
		/obj/item/gun/energy/lasercannon = 3,
		/obj/item/gun/energy/xray = 2,
		/obj/item/gun/energy/immolator/multi = 2,
		/obj/item/gun/energy/gun/nuclear = 3,
		/obj/item/gun/energy/gun/minigun = 1,
		/obj/item/storage/lockbox/t4 = 3,
		/obj/item/grenade/smokebomb = 3,
		/obj/item/grenade/frag = 4
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)

/obj/machinery/vending/nta/ertarmory/red/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NT ERT Heavy Gear & Ammunition",
		GENITIVE = "торгового автомата NT ERT Heavy Gear & Ammunition",
		DATIVE = "торговому автомату NT ERT Heavy Gear & Ammunition",
		ACCUSATIVE = "торговый автомат NT ERT Heavy Gear & Ammunition",
		INSTRUMENTAL = "торговым автоматом NT ERT Heavy Gear & Ammunition",
		PREPOSITIONAL = "торговом автомате NT ERT Heavy Gear & Ammunition"
	)

/obj/machinery/vending/nta/ertarmory/green
	name = "NT ERT Light Gear & Ammunition"
	desc = "Автомат-помощник по выдаче снаряжения лёгкого класса."
	slogan_list = list(
		"Круш+и череп+а враг+ов Нанотр+ейзен!",
		"Не забыв+ай, спас+ать – пол+езно!",
		"Бжж-Бзз-з!",
		"Обезоп+асить, Удерж+ать, Сохран+ить!",
		"Сто+ять, сняряд+ись на зад+ание!"
	)

	base_icon_state = "nta-green"
	deny_overlay = "nta-green_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/restraints/handcuffs = 5,
		/obj/item/restraints/handcuffs/cable/zipties = 5,
		/obj/item/grenade/flashbang = 3,
		/obj/item/flash = 2,
		/obj/item/gun/energy/gun/advtaser = 4,
		/obj/item/gun/projectile/automatic/pistol/enforcer = 6,
		/obj/item/storage/box/barrier = 2,
		/obj/item/gun/projectile/shotgun/riot = 3,
		/obj/item/ammo_box/shotgun/rubbershot = 6,
		/obj/item/ammo_box/shotgun/beanbag = 4,
		/obj/item/ammo_box/shotgun/tranquilizer = 4,
		/obj/item/ammo_box/speedloader/shotgun = 4,
		/obj/item/gun/projectile/automatic/wt550 = 3,
		/obj/item/ammo_box/magazine/wt550m9 = 6,
		/obj/item/gun/energy/dominator/sibyl = 2,
		/obj/item/melee/baton/telescopic = 4
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)

/obj/machinery/vending/nta/ertarmory/green/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NT ERT Light Gear & Ammunition",
		GENITIVE = "торгового автомата NT ERT Light Gear & Ammunition",
		DATIVE = "торговому автомату NT ERT Light Gear & Ammunition",
		ACCUSATIVE = "торговый автомат NT ERT Light Gear & Ammunition",
		INSTRUMENTAL = "торговым автоматом NT ERT Light Gear & Ammunition",
		PREPOSITIONAL = "торговом автомате NT ERT Light Gear & Ammunition"
	)

/obj/machinery/vending/nta/ertarmory/green/cc_jail
	name = "NT CentComm prison guards' Gear & Ammunition"
	desc = "Автомат с оборудованием для надзирателей тюрьмы Центрального Командования."
	products = list(/obj/item/restraints/handcuffs=5,
		/obj/item/restraints/handcuffs/cable/zipties=5,
		/obj/item/grenade/flashbang=3,
		/obj/item/flash=3,
		/obj/item/restraints/legcuffs/bola/energy=3,
		/obj/item/gun/energy/gun/advtaser=6,
		/obj/item/gun/projectile/automatic/pistol/enforcer=6,
		/obj/item/storage/box/barrier=2,
		/obj/item/gun/projectile/shotgun/riot=2,
		/obj/item/ammo_box/shotgun/rubbershot=4,
		/obj/item/ammo_box/shotgun=2,
		/obj/item/ammo_box/magazine/enforcer=6,
		/obj/item/gun/energy/dominator/sibyl=3)
	contraband = list(/obj/item/storage/fancy/donut_box=2,
		/obj/item/ammo_box/shotgun/buck=4,
		/obj/item/ammo_box/magazine/enforcer/lethal=4)

/obj/machinery/vending/nta/ertarmory/green/cc_jail/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NT CentComm prison guards' Gear & Ammunition",
		GENITIVE = "торгового автомата NT CentComm prison guards' Gear & Ammunition",
		DATIVE = "торговому автомату NT CentComm prison guards' Gear & Ammunition",
		ACCUSATIVE = "торговый автомат NT CentComm prison guards' Gear & Ammunition",
		INSTRUMENTAL = "торговым автоматом NT CentComm prison guards' Gear & Ammunition",
		PREPOSITIONAL = "торговом автомате NT CentComm prison guards' Gear & Ammunition"
	)

/obj/machinery/vending/nta/ertarmory/yellow
	name = "NT ERT Death Wish Gear & Ammunition"
	desc = "Автомат с оборудованием для ОБР — помогает людям осуществить их желание УМЕРЕТЬ."
	slogan_list = list(
		"Круш+и череп+а ВСЕХ!",
		"Не забыв+ай, УБИВ+АТЬ – пол+езно!",
		"УБИВ+АТЬ! УБИВ+АТЬ!! УБИВ+АТЬ!!!",
		"УБИВ+АТЬ, Удерж+ать, УБИВ+АТЬ!",
		"Сто+ять, сняряд+ись на УБИВ+АТЬ!",
		"РЕЗН+Я!",
		"РВИ И КРОМС+АЙ!",
		"ТР+УПОВ МН+ОГО НЕ БЫВ+АЕТ!",
		"НИ ОДН+А МРАЗЬ НЕ ДОЖИВ+ЁТ ДО З+АВТРА!"
	)

	base_icon_state = "nta-yellow"
	deny_overlay = "nta-yellow_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/gun/projectile/automatic/gyropistol = 8,
		/obj/item/ammo_box/magazine/m75 = 12,
		/obj/item/gun/projectile/automatic/l6_saw = 6,
		/obj/item/ammo_box/magazine/a762x51/ap = 12,
		/obj/item/gun/projectile/automatic/shotgun/bulldog = 6,
		/obj/item/gun/energy/immolator = 6,
		/obj/item/storage/backpack/duffel/syndie/ammo/shotgun = 12,
		/obj/item/gun/energy/xray = 8,
		/obj/item/gun/energy/pulse/destroyer/annihilator = 8,
		/obj/item/grenade/clusterbuster/inferno = 3,
		/obj/item/grenade/clusterbuster/emp = 3
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)
/obj/machinery/vending/nta/ertarmory/yellow/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NT ERT Death Wish Gear & Ammunition",
		GENITIVE = "торгового автомата NT ERT Death Wish Gear & Ammunition",
		DATIVE = "торговому автомату NT ERT Death Wish Gear & Ammunition",
		ACCUSATIVE = "торговый автомат NT ERT Death Wish Gear & Ammunition",
		INSTRUMENTAL = "торговым автоматом NT ERT Death Wish Gear & Ammunition",
		PREPOSITIONAL = "торговом автомате NT ERT Death Wish Gear & Ammunition"
	)

/obj/machinery/vending/nta/ertarmory/medical
	name = "NT ERT Medical Gear"
	desc = "Автомат с медицинским оборудованием ОБР."
	slogan_list = list(
		"В+ылечи всех р+аненых!",
		"Не забыв+ай, лечи+ть – пол+езно!",
		"Бжж-Бзз-з!",
		"Перевяз+ать, В+ылечить, В+ыписать!",
		"Сто+ять, сняряд+ись медикам+ентами на зад+ание!"
	)

	base_icon_state = "nta-medical"
	deny_overlay = "nta-medical_deny"

	req_access = list(ACCESS_CENT_MEDICAL)
	products = list(
		/obj/item/storage/firstaid/tactical = 2,
		/obj/item/reagent_containers/applicator/dual = 2,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis = 4,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis = 2,
		/obj/item/storage/belt/medical/surgery/loaded = 2,
		/obj/item/storage/belt/medical/response_team = 3,
		/obj/item/storage/pill_bottle/ert = 4,
		/obj/item/reagent_containers/food/pill/mannitol = 10,
		/obj/item/reagent_containers/food/pill/salbutamol = 10,
		/obj/item/reagent_containers/food/pill/morphine = 8,
		/obj/item/reagent_containers/food/pill/charcoal = 10,
		/obj/item/reagent_containers/food/pill/mutadone = 8,
		/obj/item/storage/pill_bottle/patch_pack = 4,
		/obj/item/reagent_containers/food/pill/patch/silver_sulf = 10,
		/obj/item/reagent_containers/food/pill/patch/styptic = 10,
		/obj/item/storage/toolbox/surgery = 2,
		/obj/item/scalpel/laser/manager = 2,
		/obj/item/reagent_containers/applicator/brute = 4,
		/obj/item/reagent_containers/applicator/burn = 4,
		/obj/item/healthanalyzer/advanced = 4,
		/obj/item/roller/holo = 2
	)
	contraband = list()

/obj/machinery/vending/nta/ertarmory/medical/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NT ERT Medical Gear",
		GENITIVE = "торгового автомата NT ERT Medical Gear",
		DATIVE = "торговому автомату NT ERT Medical Gear",
		ACCUSATIVE = "торговый автомат NT ERT Medical Gear",
		INSTRUMENTAL = "торговым автоматом NT ERT Medical Gear",
		PREPOSITIONAL = "торговом автомате NT ERT Medical Gear"
	)

/obj/machinery/vending/nta/ertarmory/engineer
	name = "NT ERT Engineer Gear"
	desc = "Автомат с инженерным оборудованием ОБР."
	slogan_list = list(
		"Почини всё поломанное!",
		"Не забыв+ай, чин+ить – пол+езно!",
		"Бжж-Бзз-з!",
		"Почин+ить, Завар+ить, Восстанов+ить!",
		"Сто+ять, сняряд+ись на поч+инку объ+екта!"
	)

	base_icon_state = "nta-engi"
	deny_overlay = "nta-engi_deny"

	req_access = list(ACCESS_CENT_GENERAL)
	products = list(
		/obj/item/storage/belt/utility/chief/full = 2,
		/obj/item/clothing/mask/gas/welding = 4,
		/obj/item/weldingtool/experimental = 3,
		/obj/item/crowbar/power = 3,
		/obj/item/screwdriver/power  = 3,
		/obj/item/extinguisher/mini = 3,
		/obj/item/multitool = 3,
		/obj/item/rcd/preloaded = 2,
		/obj/item/rcd_ammo  = 8,
		/obj/item/stack/cable_coil = 4
	)
	contraband = list(/obj/item/clothing/head/welding/flamedecal = 1,
		/obj/item/storage/fancy/donut_box = 2,
		/obj/item/clothing/head/welding/flamedecal/white  = 1,
		/obj/item/clothing/head/welding/flamedecal/blue = 1
		)

/obj/machinery/vending/nta/ertarmory/engineer/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NT ERT Engineer Gear",
		GENITIVE = "торгового автомата NT ERT Engineer Gear",
		DATIVE = "торговому автомату NT ERT Engineer Gear",
		ACCUSATIVE = "торговый автомат NT ERT Engineer Gear",
		INSTRUMENTAL = "торговым автоматом NT ERT Engineer Gear",
		PREPOSITIONAL = "торговом автомате NT ERT Engineer Gear"
	)

/obj/machinery/vending/nta/ertarmory/janitor
	name = "NT ERT Janitor Gear"
	desc = "Автомат с уборочным оборудованием ОБР."
	slogan_list = list(
		"В+ымой всё заг+аженное!",
		"Не забыв+ай, ч+истить – пол+езно!",
		"Бжж-Бзз-з!",
		"Пом+ыть, Постир+ать, Оттер+еть!",
		"Сто+ять, сняряд+ись на уб+орку!"
	)

	base_icon_state = "nta-janitor"
	deny_overlay = "nta-janitor_deny"

	req_access = list(ACCESS_CENT_GENERAL)
	products = list(
		/obj/item/storage/belt/janitor/ert = 2,
		/obj/item/clothing/shoes/galoshes = 2,
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/storage/bag/trash = 2,
		/obj/item/storage/box/lights/mixed = 4,
		/obj/item/melee/flyswatter= 1,
		/obj/item/soap/ert = 2,
		/obj/item/grenade/chem_grenade/cleaner = 4,
		/obj/item/clothing/mask/gas = 3,
		/obj/item/watertank/janitor  = 4,
		/obj/item/lightreplacer = 2
	)
	contraband = list(/obj/item/grenade/clusterbuster/cleaner = 1, /obj/item/storage/fancy/donut_box = 2, )

/obj/machinery/vending/nta/ertarmory/janitor/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NT ERT Janitor Gear",
		GENITIVE = "торгового автомата NT ERT Janitor Gear",
		DATIVE = "торговому автомату NT ERT Janitor Gear",
		ACCUSATIVE = "торговый автомат NT ERT Janitor Gear",
		INSTRUMENTAL = "торговым автоматом NT ERT Janitor Gear",
		PREPOSITIONAL = "торговом автомате NT ERT Janitor Gear"
	)

#undef FLICK_NONE
#undef FLICK_VEND
#undef FLICK_DENY
