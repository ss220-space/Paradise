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
		"Люб+ой, кто беж+ит — прест+упник! Люб+ой, кто сто+ит — дисциплин+ированный прест+упник!",
		"Стрел+яя по чл+енам экип+ажа, ты одн+ажды попад+ёшь в аг+ента Синдик+ата!",
	)

	icon_state = "sec_off"
	panel_overlay = "sec_panel"
	screen_overlay = "sec"
	lightmask_overlay = "sec_lightmask"
	broken_overlay = "sec_broken"
	broken_lightmask_overlay = "sec_broken_lightmask"
	deny_overlay = "sec_deny"
	default_price = PAYCHECK_LOWER
	default_premium_price = PAYCHECK_COMMAND

	req_access = list(ACCESS_SECURITY)
	product_categories = list(
		list(
			"name" = "Расходники и приспособления",
			"icon" = "handcuffs",
			"products" = list(
				/obj/item/restraints/handcuffs = 8,
				/obj/item/restraints/handcuffs/cable/zipties = 8,
				/obj/item/restraints/legcuffs/bola/energy = 7,
				/obj/item/grenade/flashbang = 5,
				/obj/item/flash = 5,
				/obj/item/storage/box/evidence = 3,
				/obj/item/storage/box/swabs = 3,
				/obj/item/storage/box/fingerprints = 3,
				/obj/item/grenade/smokebomb = 8,
				/obj/item/clothing/mask/muzzle/safety = 4,

			),
		),
		list(
			"name" = "Оборудование и экипировка",
			"icon" = "vest-patches",
			"products" = list(
				/obj/item/storage/belt/security/webbing = 2,
				/obj/item/clothing/mask/gas/sechailer/tactical = 5,
				/obj/item/storage/belt/security/judobelt = 3,
				/obj/item/eftpos/sec = 4,
				/obj/item/flashlight/seclite = 4,
				/obj/item/flashlight/sectaclight = 2,
			),
		),
		list(
			"name" = "Другое",
			"icon" = "ellipsis",
			"products" = list(
				/obj/item/reagent_containers/food/snacks/donut = 12,
				/obj/item/stack/medical/bruise_pack/military = 5,
				/obj/item/tourniquet/advanced = 5,
			),
		),
	)
	contraband = list(
		/obj/item/clothing/glasses/sunglasses = 2,
		/obj/item/storage/fancy/donut_box = 2,
		/obj/item/hailer = 5,
	)
	refill_canister = /obj/item/vending_refill/security

/obj/machinery/vending/security/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат SecTech",
		GENITIVE = "торгового автомата SecTech",
		DATIVE = "торговому автомату SecTech",
		ACCUSATIVE = "торговый автомат SecTech",
		INSTRUMENTAL = "торговым автоматом SecTech",
		PREPOSITIONAL = "торговом автомате SecTech",
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
		"Инстр+уктор – +это твой п+апочка!",
		"Эй, ты куд+а ц+елишься?!",
	)

	icon_state = "sectraining_off"
	broken_lightmask_overlay = "sectraining_broken_lightmask"
	req_access = list(ACCESS_SECURITY)
	all_products_free = TRUE
	product_categories = null
	products = list(
		/obj/item/clothing/ears/earmuffs = 2,
		/obj/item/gun/energy/laser/practice = 2,
		/obj/item/gun/projectile/automatic/toy/pistol/enforcer = 2,
		/obj/item/gun/projectile/shotgun/toy = 2,
		/obj/item/gun/projectile/automatic/toy = 2,
	)
	contraband = list(/obj/item/toy/figure/secofficer = 1)

/obj/machinery/vending/security/training/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат SecTech Training",
		GENITIVE = "торгового автомата SecTech Training",
		DATIVE = "торговому автомату SecTech Training",
		ACCUSATIVE = "торговый автомат SecTech Training",
		INSTRUMENTAL = "торговым автоматом SecTech Training",
		PREPOSITIONAL = "торговом автомате SecTech Training",
	)

/obj/machinery/vending/security/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM || !powered())
		return ..()

	if(istype(item, /obj/item/security_voucher))
		var/obj/item/security_voucher/voucher = item
		add_fingerprint(user)
		var/list/available_kits = voucher.redeem_kits_list()
		var/choice = show_radial_menu(user, voucher, available_kits, radius = 40, custom_check = CALLBACK(src, PROC_REF(check_voucher_menu), user), require_near = TRUE)
		if(!choice || !Adjacent(user) || QDELETED(voucher) || voucher.loc != user)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(!user.drop_transfer_item_to_loc(voucher, src))
			return ATTACK_CHAIN_BLOCKED_ALL
		qdel(voucher)
		addtimer(CALLBACK(src, PROC_REF(vend_kit), user, choice), 5)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/machinery/vending/security/proc/vend_kit(mob/user, choice)
	playsound(loc, 'sound/machines/machine_vend.ogg', 50, TRUE)
	var/obj/item/box = new choice(loc)
	if(Adjacent(user))
		user.put_in_hands(box, ignore_anim = FALSE)

/obj/machinery/vending/security/proc/check_voucher_menu(mob/living/user)
	if(!istype(user) || !Adjacent(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/machinery/vending/security/ert
	name = "NT ERT Consumables Gear"
	desc = "Расходное оборудование для различных ситуаций."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta
	density = FALSE
	product_categories = null

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
		/obj/item/storage/box/fingerprints = 5,
	)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/security/ert/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NT ERT Consumables Gear",
		GENITIVE = "торгового автомата NT ERT Consumables Gear",
		DATIVE = "торговому автомату NT ERT Consumables Gear",
		ACCUSATIVE = "торговый автомат NT ERT Consumables Gear",
		INSTRUMENTAL = "торговым автоматом NT ERT Consumables Gear",
		PREPOSITIONAL = "торговом автомате NT ERT Consumables Gear",
	)

/obj/item/security_voucher
	name = "security voucher"
	desc = "Жетон, позволяющий получить набор оружия из торгового автомата \"SecTech\". Выдаётся всем сотрудникам службы безопасности в штатном порядке."
	gender = MALE
	icon_state = "security_voucher"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/security_voucher/proc/redeem_kits_list()
	var/static/list/available_kits
	if(!available_kits)
		available_kits = list()
		var/list/kits = subtypesof(/datum/security_voucher_kit/officer)
		for(var/datum/security_voucher_kit/kit as anything in kits)
			available_kits[kit.kit_box] = image(kit.icon, kit.icon_state)
	return available_kits.Copy()

/obj/item/security_voucher/get_ru_names()
	return list(
		NOMINATIVE = "ваучер",
		GENITIVE = "ваучера",
		DATIVE = "ваучеру",
		ACCUSATIVE = "ваучер",
		INSTRUMENTAL = "ваучером",
		PREPOSITIONAL = "ваучере",
	)

/obj/item/security_voucher/detective
	name = "detective's security voucher"
	desc = "Жетон, позволяющий получить детективский набор оружия из торгового автомата \"SecTech\". Выдаётся детективам в штатном порядке."
	icon_state = "detectives_voucher"

/obj/item/security_voucher/detective/redeem_kits_list()
	var/static/list/detectives_available_kits
	if(!detectives_available_kits)
		detectives_available_kits = ..()
		var/list/kits = typesof(/datum/security_voucher_kit/detective)
		for(var/datum/security_voucher_kit/kit as anything in kits)
			detectives_available_kits[kit.kit_box] = image(kit.icon, kit.icon_state)
	return detectives_available_kits.Copy()

/obj/item/security_voucher/detective/get_ru_names()
	return list(
		NOMINATIVE = "детективский ваучер",
		GENITIVE = "детективского ваучера",
		DATIVE = "детективскому ваучеру",
		ACCUSATIVE = "детективский ваучер",
		INSTRUMENTAL = "детективским ваучером",
		PREPOSITIONAL = "детективском ваучере",
	)

/datum/security_voucher_kit
	var/obj/item/storage/box/kit_box
	var/icon
	var/icon_state

/datum/security_voucher_kit/officer

/datum/security_voucher_kit/officer/dominator
	kit_box = /obj/item/storage/box/dominator_kit
	icon = 'icons/obj/weapons/dominator.dmi'
	icon_state = "dominator"

/datum/security_voucher_kit/officer/enforcer
	kit_box = /obj/item/storage/box/enforcer_kit
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "enforcer_grey"

/datum/security_voucher_kit/officer/specter
	kit_box = /obj/item/storage/box/specter_kit
	icon = 'icons/obj/weapons/energy.dmi'
	icon_state = "specter"

/datum/security_voucher_kit/officer/taurus
	kit_box = /obj/item/storage/box/taurus_kit
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "taurus"

/datum/security_voucher_kit/detective
	kit_box = /obj/item/storage/box/revolver_kit
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "detective"
