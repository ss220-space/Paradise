// MARK: .50 - Syndicate SR
/obj/item/ammo_box/magazine/sniper_rounds
	name = "sniper rounds (.50)"
	icon_state = ".50mag"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/point50
	max_ammo = 5
	caliber = CALIBER_DOT_50

/obj/item/ammo_box/magazine/sniper_rounds/update_icon_state()
	if(ammo_count())
		icon_state = "[initial(icon_state)]-ammo"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/ammo_box/magazine/sniper_rounds/soporific
	name = "sniper rounds (Zzzzz)"
	desc = "Soporific sniper rounds, designed for happy days and dead quiet nights..."
	icon_state = "soporific"
	ammo_type = /obj/item/ammo_casing/soporific
	max_ammo = 3

/obj/item/ammo_box/magazine/sniper_rounds/explosive
	name = "sniper rounds (boom)"
	desc = "What did you mean by saying warcrimes? There wasn't any millitary"
	icon_state = "explosive"
	ammo_type = /obj/item/ammo_casing/explosive

/obj/item/ammo_box/magazine/sniper_rounds/haemorrhage
	name = "sniper rounds (Bleed)"
	desc = "Haemorrhage sniper rounds, leaves your target in a pool of crimson pain"
	icon_state = "haemorrhage"
	ammo_type = /obj/item/ammo_casing/haemorrhage

/obj/item/ammo_box/magazine/sniper_rounds/penetrator
	name = "sniper rounds (penetrator)"
	desc = "An extremely powerful round capable of passing straight through cover and anyone unfortunate enough to be behind it."
	icon_state = "penetrator"
	ammo_type = /obj/item/ammo_casing/penetrator

// MARK: .50L - Compact Syndicate SR
/obj/item/ammo_box/magazine/sniper_rounds/compact
	name = "sniper rounds (compact)"
	desc = "An extremely powerful round capable of inflicting massive damage on a target."
	ammo_type = /obj/item/ammo_casing/compact
	max_ammo = 4
	caliber = CALIBER_DOT_50L

/obj/item/ammo_box/magazine/sniper_rounds/compact/penetrator
	name = "penetrator sniper rounds(compact)"
	desc = "An extremely powerful round capable of passing straight through cover and anyone unfortunate enough to be behind it."
	icon_state = "penetrator"
	ammo_type = /obj/item/ammo_casing/compact/penetrator
	max_ammo = 5

/obj/item/ammo_box/magazine/sniper_rounds/compact/soporific
	name = "soporofic sniper rounds(compact)"
	desc = "Soporific sniper rounds, designed for happy days and dead quiet nights..."
	icon_state = "soporific"
	ammo_type = /obj/item/ammo_casing/compact/soporific
	max_ammo = 3

// MARK: .338 - AXMC
/obj/item/ammo_box/magazine/a338
	name = "sniper rounds (.338)"
	icon_state = ".338mag"
	origin_tech = "combat=6"
	ammo_type = /obj/item/ammo_casing/a338
	max_ammo = 10
	caliber = CALIBER_DOT_338

/obj/item/ammo_box/magazine/a338/get_ru_names()
	return list(
		NOMINATIVE = "снайперские патроны .338",
		GENITIVE = "снайперских патронов .338",
		DATIVE = "снайперским патронам .338",
		ACCUSATIVE = "снайперские патроны .338",
		INSTRUMENTAL = "снайперскими патронами .338",
		PREPOSITIONAL = "снайперских патронах .338",
	)

/obj/item/ammo_box/magazine/a338/update_icon_state()
	if(ammo_count())
		icon_state = "[initial(icon_state)]-ammo"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/ammo_box/magazine/a338/soporific
	name = "sniper rounds .338 (Zzzzz)"
	desc = "Усыпляющие снайперские патроны калибра .338, созданные для счастливых дней и тихих ночей..."
	icon_state = ".338soporific"
	ammo_type = /obj/item/ammo_casing/a338_soporific
	max_ammo = 6

/obj/item/ammo_box/magazine/a338/soporific/get_ru_names()
	return list(
		NOMINATIVE = "снайперские патроны .338 (усыпляющие)",
		GENITIVE = "снайперских патронов .338 (усыпляющих)",
		DATIVE = "снайперским патронам .338 (усыпляющим)",
		ACCUSATIVE = "снайперские патроны .338 (усыпляющие)",
		INSTRUMENTAL = "снайперскими патронами .338 (усыпляющими)",
		PREPOSITIONAL = "снайперских патронах .338 (усыпляющих)",
	)

/obj/item/ammo_box/magazine/a338/explosive
	name = "sniper rounds .338 (boom)"
	desc = "Что вы имели в виду, говоря о военных преступлениях? Не было никаких военных."
	icon_state = ".338explosive"
	ammo_type = /obj/item/ammo_casing/a338_explosive

/obj/item/ammo_box/magazine/a338/explosive/get_ru_names()
	return list(
		NOMINATIVE = "снайперские патроны .338 (разрывные)",
		GENITIVE = "снайперских патронов .338 (разрывных)",
		DATIVE = "снайперским патронам .338 (разрывным)",
		ACCUSATIVE = "снайперские патроны .338 (разрывные)",
		INSTRUMENTAL = "снайперскими патронами .338 (разрывными)",
		PREPOSITIONAL = "снайперских патронах .338 (разрывных)",
	)

/obj/item/ammo_box/magazine/a338/haemorrhage
	name = "sniper rounds 338 (Bleed)"
	desc = "Кровопускающие снайперские выстрелы, оставляют вашу цель в луже кровавой боли"
	icon_state = ".338haemorrhage"
	ammo_type = /obj/item/ammo_casing/a338_haemorrhage

/obj/item/ammo_box/magazine/a338/haemorrhage/get_ru_names()
	return list(
		NOMINATIVE = "снайперские патроны .338 (кровопускающие)",
		GENITIVE = "снайперских патронов .338 (кровопускающих)",
		DATIVE = "снайперским патронам .338 (кровопускающим)",
		ACCUSATIVE = "снайперские патроны .338 (кровопускающие)",
		INSTRUMENTAL = "снайперскими патронами .338 (кровопускающими)",
		PREPOSITIONAL = "снайперских патронах .338 (кровопускающих)",
	)

/obj/item/ammo_box/magazine/a338/penetrator
	name = "sniper rounds 338 (penetrator)"
	desc = "Чрезвычайно мощный патрон, способный пронзить укрытие и любого, кому не повезло оказаться за ним."
	icon_state = ".338penetrator"
	ammo_type = /obj/item/ammo_casing/a338_penetrator

/obj/item/ammo_box/magazine/a338/penetrator/get_ru_names()
	return list(
		NOMINATIVE = "снайперские патроны .338 (проникающие)",
		GENITIVE = "снайперских патронов .338 (проникающих)",
		DATIVE = "снайперским патронам .338 (проникающим)",
		ACCUSATIVE = "снайперские патроны .338 (проникающие)",
		INSTRUMENTAL = "снайперскими патронами .338 (проникающими)",
		PREPOSITIONAL = "снайперских патронах .338 (проникающих)",
	)
