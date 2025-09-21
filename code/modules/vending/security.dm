/obj/machinery/vending/security
	name = "SecTech"
	desc = "Раздатчик снаряжения службы безопасности."
	slogan_list = list(
		"Круш+и череп+а прест+упников!",
		"Отб+ей н+есколько гол+ов!",
		"Не забыв+ай, ты здесь зак+он!",
		"Тво+ё ор+ужие здесь!",
		"Нар+учники, да поб+ольше!",
		"Сто+ять, подонок!",
		"Не бей мен+я, брат!",
		"Уб+ей их, брат.",
		"Почем+у бы не съесть п+ончик?",
		"Это не во+енное преступл+ение, +если теб+е б+ыло в+есело!",
		"Люб+ой, кто беж+ит - прест+упник! Люб+ой, кто сто+ит - дисциплин+ированный прест+упник!",
		"Стрел+яя по чл+енам экип+ажа, ты одн+ажды попад+ёшь в аг+ента Синдик+ата!"
	)

	icon_state = "sec_off"
	panel_overlay = "sec_panel"
	screen_overlay = "sec"
	lightmask_overlay = "sec_lightmask"
	broken_overlay = "sec_broken"
	broken_lightmask_overlay = "sec_broken_lightmask"
	deny_overlay = "sec_deny"

	req_access = list(ACCESS_SECURITY)
	products = list(
		/obj/item/restraints/handcuffs = 8,
		/obj/item/restraints/handcuffs/cable/zipties = 8,
		/obj/item/grenade/flashbang = 4,
		/obj/item/flash = 5,
		/obj/item/reagent_containers/food/snacks/donut = 12,
		/obj/item/storage/box/evidence = 6,
		/obj/item/flashlight/seclite = 4,
		/obj/item/restraints/legcuffs/bola/energy = 7,
		/obj/item/clothing/mask/muzzle/safety = 4,
		/obj/item/storage/box/swabs = 6,
		/obj/item/storage/box/fingerprints = 6,
		/obj/item/eftpos/sec = 4,
		/obj/item/storage/belt/security/webbing = 2,
		/obj/item/storage/pouch/fast = 2,
		/obj/item/clothing/mask/gas/sechailer/tactical = 5,
		/obj/item/flashlight/sectaclight = 2,
		/obj/item/grenade/smokebomb = 8,
		/obj/item/storage/belt/security/judobelt = 3,
		/obj/item/stack/medical/bruise_pack/military = 5,
	)
	contraband = list(
		/obj/item/clothing/glasses/sunglasses = 2,
		/obj/item/storage/fancy/donut_box = 2,
		/obj/item/hailer = 5,
	)
	prices = list(
		/obj/item/storage/belt/security/judobelt = 499,
		/obj/item/storage/belt/security/webbing = 999,
		/obj/item/storage/pouch/fast = 999,
		/obj/item/clothing/mask/gas/sechailer/tactical = 299,
		/obj/item/flashlight/sectaclight = 299,
		/obj/item/grenade/smokebomb = 249,
		/obj/item/stack/medical/bruise_pack/military = 299,
	)
	refill_canister = /obj/item/vending_refill/security

/obj/machinery/vending/security/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат SecTech",
		GENITIVE = "торгового автомата SecTech",
		DATIVE = "торговому автомату SecTech",
		ACCUSATIVE = "торговый автомат SecTech",
		INSTRUMENTAL = "торговым автоматом SecTech",
		PREPOSITIONAL = "торговом автомате SecTech"
	)

/obj/machinery/vending/security/training
	name = "SecTech Training"
	desc = "Раздатчик тренировочного снаряжения службы безопасности."
	slogan_list = list(
		"Соблюд+ай чистот+у на стр+ельбище!",
		"Да мо+я б+абушка стрел+яет л+учше!",
		"Почем+у так к+осо, бух+ой что ли?!",
		"Т+ехника безоп+асности нам не п+исана, да?",
		"1 из 10-ти попад+аний... А ты хор+ош!",
		"Инстр+уктор – ++это твой п+апочка!",
		"Эй, ты куд+а ц+елишься?!"
	)

	icon_state = "sectraining_off"
	broken_lightmask_overlay = "sectraining_broken_lightmask"

	req_access = list(ACCESS_SECURITY)
	products = list(
		/obj/item/clothing/ears/earmuffs = 2, /obj/item/gun/energy/laser/practice = 2, /obj/item/gun/projectile/automatic/toy/pistol/enforcer = 2,
		/obj/item/gun/projectile/shotgun/toy = 2, /obj/item/gun/projectile/automatic/toy = 2
	)
	contraband = list(/obj/item/toy/figure/secofficer = 1)

/obj/machinery/vending/security/training/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат SecTech Training",
		GENITIVE = "торгового автомата SecTech Training",
		DATIVE = "торговому автомату SecTech Training",
		ACCUSATIVE = "торговый автомат SecTech Training",
		INSTRUMENTAL = "торговым автоматом SecTech Training",
		PREPOSITIONAL = "торговом автомате SecTech Training"
	)


/obj/machinery/vending/security/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || !powered())
		return ..()

	if(istype(I, /obj/item/security_voucher))
		add_fingerprint(user)
		var/static/list/available_kits = list(
			"Доминатор" = /obj/item/storage/box/dominator_kit,
			"Блюститель" = /obj/item/storage/box/enforcer_kit,
			"Спектр" = /obj/item/storage/box/specter_kit,
		)
		var/weapon_kit = tgui_input_list(user, "Выберите оружейный набор для выдачи:", "Получение оружия", available_kits)
		if(!weapon_kit || !Adjacent(user) || QDELETED(I) || I.loc != user)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_BLOCKED_ALL
		qdel(I)
		sleep(0.5 SECONDS)
		playsound(loc, 'sound/machines/machine_vend.ogg', 50, TRUE)
		var/path = available_kits[weapon_kit]
		var/obj/item/box = new path(loc)
		if(Adjacent(user))
			user.put_in_hands(box, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/machinery/vending/security/ert
	name = "NT ERT Consumables Gear"
	desc = "Расходное оборудование для различных ситуаций."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta


	density = FALSE
	products = list(
		/obj/item/restraints/handcuffs = 10,
		/obj/item/flashlight/seclite = 10,
		/obj/item/shield/riot/tele = 10,
		/obj/item/storage/box/flare = 5,
		/obj/item/storage/box/bodybags = 5,
		/obj/item/storage/box/bola = 5,
		/obj/item/grenade/smokebomb = 10,
		/obj/item/grenade/barrier = 15,
		/obj/item/grenade/flashbang = 10,
		/obj/item/grenade/plastic/c4_shaped/flash = 5,
		/obj/item/flash = 5,
		/obj/item/storage/box/evidence = 5,
		/obj/item/storage/box/swabs = 5,
		/obj/item/storage/box/fingerprints = 5)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/security/ert/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NT ERT Consumables Gear",
		GENITIVE = "торгового автомата NT ERT Consumables Gear",
		DATIVE = "торговому автомату NT ERT Consumables Gear",
		ACCUSATIVE = "торговый автомат NT ERT Consumables Gear",
		INSTRUMENTAL = "торговым автоматом NT ERT Consumables Gear",
		PREPOSITIONAL = "торговом автомате NT ERT Consumables Gear"
	)

/obj/item/security_voucher
	name = "security voucher"
	desc = "Жетон, позволяющий получить набор оружия из торгового автомата \"SecTech\". Выдаётся всем сотрудникам службы безопасности в штатном порядке."
	gender = MALE
	icon_state = "security_voucher"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/security_voucher/get_ru_names()
	return list(
		NOMINATIVE = "ваучер",
		GENITIVE = "ваучера",
		DATIVE = "ваучеру",
		ACCUSATIVE = "ваучер",
		INSTRUMENTAL = "ваучером",
		PREPOSITIONAL = "ваучере"
	)
