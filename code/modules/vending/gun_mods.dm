/obj/machinery/vending/gun_mods
	name = "ModTech"
	desc = "Торговый автомат с модулями для оружия, предназначенный для сотрудников службы безопасности."
	slogan_list = list(
		"Улу+чши сво+ё ору+жие!",
		"Купи+ глуши+тель, будь на сти+ле!",
		"Разли+чные прице+лы на любо+й вкус!",
		"Купи+ глуши+тель, соблюда+й тишину+.",
		"Почему+ тво+й ствол не улу+чшен?!",
		"Твоя+ пу+шка недоста+точно такти+ческая!"
	)
	icon_state = "attachments_off"
	panel_overlay = "attachments_panel"
	screen_overlay = "attachments"
	broken_overlay = "attachments_broken"
	deny_overlay = "attachments_deny"
	req_access = list(ACCESS_SECURITY)
	refill_canister = /obj/item/vending_refill/gun_mods
	default_price = PAYCHECK_CREW
	default_premium_price = PAYCHECK_MAX
	vandal_secure = TRUE

	products = list(
		/obj/item/gun_module/muzzle/compensator = 8,
		/obj/item/gun_module/rail/scope/collimator/pistol = 8,
		/obj/item/gun_module/rail/scope/collimator = 5,
		/obj/item/gun_module/under/flashlight/pistol = 10,
		/obj/item/gun_module/under/flashlight/rifle = 10,
		/obj/item/gun_module/under/laser/point = 5,
		/obj/item/gun_module/under/hand/simple = 5,
		/obj/item/gun_module/under/hand/angle = 5,
		/obj/item/ammo_box/magazine/enforcer/extended = 10,
		/obj/item/gun_module/rail/hud/medical = 3,
		/obj/item/gun_module/rail/hud/security = 3,
	)
	contraband = list(
		/obj/item/gun_module/muzzle/suppressor = 3,
		/obj/item/gun_module/muzzle/suppressor/shotgun = 2,
		/obj/item/gun_module/rail/scope/x4 = 1,
	)

/obj/machinery/vending/gun_mods/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат ModTech",
		GENITIVE = "торгового автомата ModTech",
		DATIVE = "торговому автомату ModTech",
		ACCUSATIVE = "торговый автомат ModTech",
		INSTRUMENTAL = "торговым автоматом ModTech",
		PREPOSITIONAL = "торговом автомате ModTech",
	)

// all items free, this vending is for Central command and Syndicate
/obj/machinery/vending/gun_mods/advanced
	desc = "Раздатчик с модулями для оружия."
	req_access = list()

	products = list(
		/obj/item/gun_module/muzzle/compensator = 5,
		/obj/item/gun_module/rail/scope/collimator/pistol = 5,
		/obj/item/gun_module/rail/scope/collimator = 5,
		/obj/item/gun_module/rail/scope/x4 = 5,
		/obj/item/gun_module/rail/hud/medical = 5,
		/obj/item/gun_module/rail/hud/security = 5,
		/obj/item/gun_module/under/flashlight/pistol = 5,
		/obj/item/gun_module/under/flashlight/rifle = 5,
		/obj/item/gun_module/under/laser/point = 5,
		/obj/item/gun_module/under/laser/ray = 5,
		/obj/item/gun_module/under/hand/simple = 5,
		/obj/item/gun_module/under/hand/angle = 5,
		/obj/item/gun_module/muzzle/suppressor = 5,
		/obj/item/gun_module/muzzle/suppressor/shotgun = 4,
		/obj/item/gun_module/muzzle/suppressor/heavy = 2,
		/obj/item/gun_module/rail/scope/x8 = 5,
		/obj/item/gun_module/rail/scope/x16 = 3,
	)
	contraband = list()
