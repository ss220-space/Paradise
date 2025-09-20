/obj/machinery/vending/liberationstation
	name = "Liberation Station"
	desc = "При одном взгляде на эту машину вас охватывает непреодолимое чувство <b>древнего патриотизма</b>."
	icon_state = "liberationstation_off"
	panel_overlay = "liberationstation_panel"
	screen_overlay = "liberationstation"
	lightmask_overlay = "liberationstation_lightmask"
	broken_overlay = "liberationstation_broken"
	broken_lightmask_overlay = "liberationstation_broken_lightmask"

	req_access = list(ACCESS_SECURITY)

	slogan_list = list(
		"\"Liberation Station\": ваш универс+альный магаз+ин вс+его, что св+язано со втор+ой попр+авкой!",
		"Будь патри+отом, возьм+и в руки ор+ужие уж+е сег+одня!",
		"К+ачественное ор+ужие по н+изким ц+енам!",
		"Л+учше умер+еть, чем покрасн+еть!",
		"Порх+ай, как астрон+авт, жаль, как п+уля!",
		"Ты что, оп+ять сохран+яешься?",
		"Ор+ужие не убив+ает, а вот ты можешь!",
		"Как+ая ещ+ё м+ожет быть отв+етственность, +если у теб+я есть ствол?",
		"ЧТО ТАК+ОЕ КИЛОМ+ЕТР, Ч+ЁРТ ВОЗЬМ+И!!!",
		"ЗА СВОБ+ОДУ!!!"
	)
	vend_reply = "Зап+омни мо+ё +имя: Liberation Station!"
	products = list(/obj/item/gun/projectile/automatic/pistol/deagle/gold = 2,

	/obj/item/gun/projectile/automatic/pistol/deagle/camo = 2,
					/obj/item/gun/projectile/automatic/pistol/m1911 = 2,
					/obj/item/gun/projectile/automatic/proto = 2,
					/obj/item/gun/projectile/shotgun/automatic/combat = 2,
					/obj/item/gun/projectile/automatic/gyropistol = 1,
					/obj/item/gun/projectile/shotgun = 2,
					/obj/item/gun/projectile/automatic/ar = 2)
	premium = list(/obj/item/ammo_box/magazine/smgm9mm = 2,/obj/item/ammo_box/magazine/m50 = 4,/obj/item/ammo_box/magazine/m45 = 2,/obj/item/ammo_box/magazine/m75 = 2)
	contraband = list(/obj/item/clothing/under/patriotsuit = 1,/obj/item/bedsheet/patriot = 3)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/liberationstation/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Liberation Station",
		GENITIVE = "торгового автомата Liberation Station",
		DATIVE = "торговому автомату Liberation Station",
		ACCUSATIVE = "торговый автомат Liberation Station",
		INSTRUMENTAL = "торговым автоматом Liberation Station",
		PREPOSITIONAL = "торговом автомате Liberation Station"
	)


/obj/machinery/vending/toyliberationstation
	name = "Syndicate Donksoft Toy Vendor"
	desc = "Одобренный автомат игрушек для детей от 8 лет и старше."

	icon_state = "syndi_off"
	panel_overlay = "syndi_panel"
	screen_overlay = "syndi"
	lightmask_overlay = "syndi_lightmask"
	broken_overlay = "syndi_broken"
	broken_lightmask_overlay = "syndi_broken_lightmask"

	slogan_list = list(
		"Получ+ите крут+ые игр+ушки пр+ямо сейч+ас!",
		"Начн+ите сво+ю ох+оту уж+е сег+одня!",
		"К+ачественное игр+ушечное ор+ужие по н+изким ц+енам!",
		"Прояв+ите своег+о ваш+его вн+утреннего реб+ёнка уж+е сег+одня!",
		"Дав+ай, сраж+айся как мужч+ина!",
		"Как+ая к ч+ёрту отв+етственность, за игр+ушечный ствол?",
		"Сд+елайте сво+ё сл+едующее уб+ийство ВЕС+ЁЛЫМ!"
	)

	vend_reply = "Возвращ+айтесь за доб+авкой!"
	products = list(/obj/item/gun/projectile/automatic/toy = 10,
					/obj/item/gun/projectile/automatic/toy/pistol= 10,
					/obj/item/gun/projectile/shotgun/toy = 10,
					/obj/item/toy/sword = 10,
					/obj/item/ammo_box/foambox = 20,
					/obj/item/toy/foamblade = 10,
					/obj/item/toy/syndicateballoon = 10,
					/obj/item/clothing/suit/syndicatefake = 5,
					/obj/item/clothing/head/syndicatefake = 5) //OPS IN DORMS oh wait it's just an assistant
	contraband = list(/obj/item/gun/projectile/shotgun/toy/crossbow = 10,   //Congrats, you unlocked the +18 setting!
					/obj/item/gun/projectile/automatic/c20r/toy/riot = 10,
					/obj/item/gun/projectile/automatic/l6_saw/toy/riot = 10,
					/obj/item/gun/projectile/automatic/sniper_rifle/toy = 10,
					/obj/item/ammo_box/foambox/riot = 20,
					/obj/item/toy/katana = 10,
					/obj/item/twohanded/dualsaber/toy = 5,
					/obj/item/deck/cards/syndicate = 10) //Gambling and it hurts, making it a +18 item
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/toyliberationstation/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Syndicate Donksoft Toy Vendor",
		GENITIVE = "торгового автомата Syndicate Donksoft Toy Vendor",
		DATIVE = "торговому автомату Syndicate Donksoft Toy Vendor",
		ACCUSATIVE = "торговый автомат Syndicate Donksoft Toy Vendor",
		INSTRUMENTAL = "торговым автоматом Syndicate Donksoft Toy Vendor",
		PREPOSITIONAL = "торговом автомате Syndicate Donksoft Toy Vendor"
	)
