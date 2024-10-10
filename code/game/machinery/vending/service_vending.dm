//Автоматы сферы самообслуживания

/obj/machinery/vending/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."

	icon_state = "boozeomat_off"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	panel_overlay = "boozeomat_panel"
	screen_overlay = "boozeomat"
	lightmask_overlay = "boozeomat_lightmask"
	broken_overlay = "boozeomat_broken"
	broken_lightmask_overlay = "boozeomat_broken_lightmask"
	deny_overlay = "boozeomat_deny"

	products = list(/obj/item/reagent_containers/food/drinks/bottle/gin = 5,
					/obj/item/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/reagent_containers/food/drinks/bottle/tequila = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vermouth = 5,
					/obj/item/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/reagent_containers/food/drinks/bottle/wine = 5,
					/obj/item/reagent_containers/food/drinks/bottle/arrogant_green_rat = 3,
					/obj/item/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/reagent_containers/food/drinks/bottle/kahlua = 5,
					/obj/item/reagent_containers/food/drinks/bottle/champagne = 5,
					/obj/item/reagent_containers/food/drinks/bottle/aperol = 5,
					/obj/item/reagent_containers/food/drinks/bottle/jagermeister = 5,
					/obj/item/reagent_containers/food/drinks/bottle/schnaps = 5,
					/obj/item/reagent_containers/food/drinks/bottle/sheridan = 5,
					/obj/item/reagent_containers/food/drinks/bottle/bluecuracao = 5,
					/obj/item/reagent_containers/food/drinks/bottle/sambuka = 5,
					/obj/item/reagent_containers/food/drinks/bottle/bitter = 3,
					/obj/item/reagent_containers/food/drinks/cans/beer = 6,
					/obj/item/reagent_containers/food/drinks/cans/non_alcoholic_beer = 6,
					/obj/item/reagent_containers/food/drinks/cans/ale = 6,
					/obj/item/reagent_containers/food/drinks/cans/synthanol = 15,
					/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/tomatojuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/limejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/cream = 4,
					/obj/item/reagent_containers/food/drinks/cans/tonic = 8,
					/obj/item/reagent_containers/food/drinks/cans/cola = 8,
					/obj/item/reagent_containers/food/drinks/cans/sodawater = 15,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 30,
					/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass = 30,
					/obj/item/reagent_containers/food/drinks/ice = 9)
	contraband = list(/obj/item/reagent_containers/food/drinks/tea = 10,
					  /obj/item/reagent_containers/food/drinks/bottle/fernet = 5)
	vend_delay = 15
	slogan_list = list("Надеюсь, никто не попросит меня о чёртовой кружке чая…","Алкоголь — друг человека. Вы же не бросите друга?","Очень рад вас обслужить!","Никто на этой станции не хочет выпить?")
	ads_list = list("Выпьем!","Бухло пойдёт вам на пользу!","Алкоголь — друг человека.","Очень рад вас обслужить!","Хотите отличного холодного пива?","Ничто так не лечит, как бухло!","Пригубите!","Выпейте!","Возьмите пивка!","Пиво пойдёт вам на пользу!","Только лучший алкоголь!","Бухло лучшего качества с 2053 года!","Вино со множеством наград!","Максимум алкоголя!","Мужчины любят пиво","Тост: «За прогресс!»")
	refill_canister = /obj/item/vending_refill/boozeomat

/obj/machinery/vending/boozeomat/syndicate_access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/vending/coffee
	name = "\improper Solar's Best Hot Drinks"
	desc = "A vending machine which dispenses hot drinks."
	ads_list = list("Выпейте!","Выпьем!","На здоровье!","Не хотите горячего супчику?","Я бы убил за чашечку кофе!","Лучшие зёрна в галактике","Для Вас — только лучшие напитки","М-м-м-м… Ничто не сравнится с кофе","Я люблю кофе, а Вы?","Кофе помогает работать!","Возьмите немного чайку","Надеемся, Вы предпочитаете лучшее!","Отведайте наш новый шоколад!","Admin conspiracies")

	icon_state = "coffee_off"
	panel_overlay = "coffee_panel"
	screen_overlay = "coffee"
	lightmask_overlay = "coffee_lightmask"
	broken_overlay = "coffee_broken"
	broken_lightmask_overlay = "coffee_broken_lightmask"
	vend_overlay = "coffee_vend"
	vend_lightmask = "coffee_vend_lightmask"

	item_slot = TRUE
	vend_delay = 34
	products = list(/obj/item/reagent_containers/food/drinks/coffee = 25,
		/obj/item/reagent_containers/food/drinks/tea = 25,
		/obj/item/reagent_containers/food/drinks/h_chocolate = 25,
		/obj/item/reagent_containers/food/drinks/chocolate = 10,
		/obj/item/reagent_containers/food/drinks/chicken_soup = 10,
		/obj/item/reagent_containers/food/drinks/weightloss = 10,
		/obj/item/reagent_containers/food/drinks/mug = 15,
		/obj/item/reagent_containers/food/drinks/mug/novelty = 5)
	contraband = list(/obj/item/reagent_containers/food/drinks/ice = 10)
	prices = list(/obj/item/reagent_containers/food/drinks/coffee = 25,
		/obj/item/reagent_containers/food/drinks/tea = 25,
		/obj/item/reagent_containers/food/drinks/h_chocolate = 25,
		/obj/item/reagent_containers/food/drinks/chocolate = 25,
		/obj/item/reagent_containers/food/drinks/chicken_soup = 30,
		/obj/item/reagent_containers/food/drinks/weightloss = 50,
		/obj/item/reagent_containers/food/drinks/mug = 50,
		/obj/item/reagent_containers/food/drinks/mug/novelty = 100,
		/obj/item/reagent_containers/food/drinks/ice = 40)
	refill_canister = /obj/item/vending_refill/coffee

/obj/machinery/vending/coffee/free
	prices = list()

/obj/machinery/vending/coffee/item_slot_check(mob/user, obj/item/I)
	if(!(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks)))
		return FALSE
	if(!..())
		return FALSE
	if(!I.is_open_container())
		to_chat(user, "<span class='warning'>You need to open [I] before inserting it.</span>")
		return FALSE
	return TRUE

/obj/machinery/vending/coffee/do_vend(datum/data/vending_product/R, mob/user)
	if(..())
		return
	var/obj/item/reagent_containers/food/drinks/vended = new R.product_path()

	if(istype(vended, /obj/item/reagent_containers/food/drinks/mug))
		var/put_on_turf = TRUE
		if(user && iscarbon(user) && user.Adjacent(src))
			vended.forceMove_turf()
			if(user.put_in_hands(vended, ignore_anim = FALSE))
				put_on_turf = FALSE
		if(put_on_turf)
			var/turf/T = get_turf(src)
			vended.forceMove(T)
		return

	vended.reagents.trans_to(inserted_item, vended.reagents.total_volume)
	if(vended.reagents.total_volume)
		var/put_on_turf = TRUE
		if(user && iscarbon(user) && user.Adjacent(src))
			vended.forceMove_turf()
			if(user.put_in_hands(vended, ignore_anim = FALSE))
				put_on_turf = FALSE
		if(put_on_turf)
			var/turf/T = get_turf(src)
			vended.forceMove(T)
	else
		qdel(vended)


/obj/machinery/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	slogan_list = list("Попробуйте наш новый батончик с нугой!","Вдвое больше калорий за полцены!")
	ads_list = list("The healthiest!","Award-winning chocolate bars!","Mmm! So good!","Oh my god it's so juicy!","Have a snack.","Snacks are good for you!","Have some more Getmore!","Best quality snacks straight from mars.","We love chocolate!","Try our new jerky!")

	icon_state = "snack_off"
	panel_overlay = "snack_panel"
	screen_overlay = "snack"
	lightmask_overlay = "snack_lightmask"
	broken_overlay = "snack_broken"
	broken_lightmask_overlay = "snack_broken_lightmask"

	products = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 6,
					/obj/item/reagent_containers/food/drinks/dry_ramen = 6,
					/obj/item/reagent_containers/food/snacks/doshik = 6,
					/obj/item/reagent_containers/food/snacks/doshik_spicy = 6,
					/obj/item/reagent_containers/food/snacks/chips =6,
					/obj/item/reagent_containers/food/snacks/sosjerky = 6,
					/obj/item/reagent_containers/food/snacks/no_raisin = 6,
					/obj/item/reagent_containers/food/snacks/pistachios =6,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 6,
					/obj/item/reagent_containers/food/snacks/cheesiehonkers = 6,
					/obj/item/reagent_containers/food/snacks/tastybread = 6
					)
	contraband = list(/obj/item/reagent_containers/food/snacks/syndicake = 6)
	prices = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 20,
					/obj/item/reagent_containers/food/drinks/dry_ramen = 30,
					/obj/item/reagent_containers/food/snacks/doshik = 30,
					/obj/item/reagent_containers/food/snacks/doshik_spicy = 150,
					/obj/item/reagent_containers/food/snacks/chips =25,
					/obj/item/reagent_containers/food/snacks/sosjerky = 30,
					/obj/item/reagent_containers/food/snacks/no_raisin = 20,
					/obj/item/reagent_containers/food/snacks/pistachios = 35,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 30,
					/obj/item/reagent_containers/food/snacks/cheesiehonkers = 25,
					/obj/item/reagent_containers/food/snacks/tastybread = 30,
					/obj/item/reagent_containers/food/snacks/syndicake = 50)
	refill_canister = /obj/item/vending_refill/snack

/obj/machinery/vending/snack/free
	prices = list()

/obj/machinery/vending/chinese
	name = "\improper Mr. Chang"
	desc = "A self-serving Chinese food machine, for all your Chinese food needs."
	slogan_list = list("Попробуйте 5000 лет культуры!","Мистер Чанг, одобрен для безопасного потребления в более чем 10 секторах!","Китайская кухня отлично подходит для вечернего свидания или одинокого вечера!","Вы не ошибетесь, если попробуете настоящую китайскую кухню от мистера Чанга.!")

	icon_state = "chang_off"
	panel_overlay = "chang_panel"
	screen_overlay = "chang"
	lightmask_overlay = "chang_lightmask"
	broken_overlay = "chang_broken"
	broken_lightmask_overlay = "chang_broken_lightmask"

	products = list(
		/obj/item/reagent_containers/food/snacks/chinese/chowmein = 6,
		/obj/item/reagent_containers/food/snacks/chinese/tao = 6,
		/obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball = 6,
		/obj/item/reagent_containers/food/snacks/chinese/newdles = 6,
		/obj/item/reagent_containers/food/snacks/chinese/rice = 6,
		/obj/item/reagent_containers/food/snacks/fortunecookie = 6,
		/obj/item/storage/box/crayfish_bucket = 5,
	)

	contraband = list(
		/obj/item/poster/cheng = 5,
		/obj/item/storage/box/mr_cheng = 3,
		/obj/item/clothing/head/rice_hat = 3,
	)

	prices = list(
		/obj/item/reagent_containers/food/snacks/chinese/chowmein = 50,
		/obj/item/reagent_containers/food/snacks/chinese/tao = 50,
		/obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball = 50,
		/obj/item/reagent_containers/food/snacks/chinese/newdles = 50,
		/obj/item/reagent_containers/food/snacks/chinese/rice = 50,
		/obj/item/reagent_containers/food/snacks/fortunecookie = 50,
		/obj/item/storage/box/crayfish_bucket = 250,
		/obj/item/storage/box/mr_cheng = 200,
	)

	refill_canister = /obj/item/vending_refill/chinese

/obj/machinery/vending/chinese/free
	prices = list()

/obj/machinery/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "A soft drink vendor provided by Robust Industries, LLC."

	icon_state = "cola-machine_off"
	panel_overlay = "cola-machine_panel"
	screen_overlay = "cola-machine"
	lightmask_overlay = "cola-machine_lightmask"
	broken_overlay = "cola-machine_broken"
	broken_lightmask_overlay = "cola-machine_broken_lightmask"

	slogan_list = list("Роб+аст с+офтдринкс: крепче, чем тулбоксом по голове!")
	ads_list = list("Освежает!","Надеюсь, вас одолела жажда!","Продано больше миллиона бутылок!","Хотите пить? Почему бы не взять колы?","Пожалуйста, купите напиток","Выпьем!","Лучшие напитки во всём космосе")
	products = list(
		/obj/item/reagent_containers/food/drinks/cans/cola = 10,
		/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 10,
		/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 10,
		/obj/item/reagent_containers/food/drinks/cans/starkist = 10,
		/obj/item/reagent_containers/food/drinks/cans/space_up = 10,
		/obj/item/reagent_containers/food/drinks/cans/grape_juice = 10,
		/obj/item/reagent_containers/food/drinks/cans/energy = 10,
		/obj/item/reagent_containers/food/drinks/cans/energy/trop = 10,
		/obj/item/reagent_containers/food/drinks/cans/energy/milk = 10,
		/obj/item/reagent_containers/food/drinks/cans/energy/grey = 10)
	contraband = list(/obj/item/reagent_containers/food/drinks/cans/thirteenloko = 5, /obj/item/reagent_containers/food/drinks/zaza = 1)
	prices = list(
		/obj/item/reagent_containers/food/drinks/cans/cola = 20,
		/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 20,
		/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 20,
		/obj/item/reagent_containers/food/drinks/cans/starkist = 20,
		/obj/item/reagent_containers/food/drinks/cans/space_up = 20,
		/obj/item/reagent_containers/food/drinks/cans/grape_juice = 20,
		/obj/item/reagent_containers/food/drinks/cans/energy = 40,
		/obj/item/reagent_containers/food/drinks/cans/energy/trop = 40,
		/obj/item/reagent_containers/food/drinks/cans/energy/milk = 40,
		/obj/item/reagent_containers/food/drinks/cans/energy/grey = 40,
		/obj/item/reagent_containers/food/drinks/cans/thirteenloko = 80,
		/obj/item/reagent_containers/food/drinks/zaza = 200)
	refill_canister = /obj/item/vending_refill/cola

/obj/machinery/vending/cola/free
	prices = list()

/obj/machinery/vending/cigarette
	name = "ShadyCigs Deluxe"
	desc = "If you want to get cancer, might as well do it in style."
	slogan_list = list("Космосигареты весьма хороши на вкус, какими они и должны быть","I'd rather toolbox than switch.","Затянитесь!","Не верьте исследованиям — курите!")
	ads_list = list("Наверняка не очень-то и вредно для Вас!","Не верьте учёным!","На здоровье!","Не бросайте курить, купите ещё!","Затянитесь!","Никотиновый рай","Лучшие сигареты с 2150 года","Сигареты с множеством наград")
	vend_delay = 34

	icon_state = "cigs_off"
	panel_overlay = "cigs_panel"
	screen_overlay = "cigs"
	lightmask_overlay = "cigs_lightmask"
	broken_overlay = "cigs_broken"
	broken_lightmask_overlay = "cigs_broken_lightmask"

	products = list(/obj/item/storage/fancy/cigarettes/cigpack_robust = 12,
					/obj/item/storage/fancy/cigarettes/cigpack_uplift = 6,
					/obj/item/storage/fancy/cigarettes/cigpack_random = 6,
					/obj/item/reagent_containers/food/pill/patch/nicotine = 10,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/random = 4,
					/obj/item/storage/fancy/rollingpapers = 5,
					/obj/item/lighter/zippo = 4,
					/obj/item/clothing/mask/cigarette/cigar/havana = 2,
					/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1
					)
	contraband = list( /obj/item/clothing/mask/cigarette/pipe/oldpipe = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_med = 1
					)
	prices = list(/obj/item/storage/fancy/cigarettes/cigpack_robust = 180,
					/obj/item/storage/fancy/cigarettes/cigpack_uplift = 240,
					/obj/item/storage/fancy/cigarettes/cigpack_random = 360,
					/obj/item/reagent_containers/food/pill/patch/nicotine = 70,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/random = 60,
					/obj/item/storage/fancy/rollingpapers = 20,
					/obj/item/clothing/mask/cigarette/pipe/oldpipe = 250,
					/obj/item/lighter/zippo = 250,
					/obj/item/clothing/mask/cigarette/cigar/havana = 1000,
					/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 700,
					/obj/item/storage/fancy/cigarettes/cigpack_med = 500
					)
	refill_canister = /obj/item/vending_refill/cigarette

/obj/machinery/vending/cigarette/free
	prices = list()

/obj/machinery/vending/cigarette/syndicate
	products = list(/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 7,
					/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_robust = 2,
					/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_midori = 1,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/zippo = 4,
					/obj/item/storage/fancy/rollingpapers = 5)

/obj/machinery/vending/cigarette/syndicate/free
	prices = list()


/obj/machinery/vending/cigarette/beach //Used in the lavaland_biodome_beach.dmm ruin
	name = "\improper ShadyCigs Ultra"
	desc = "Now with extra premium products!"
	ads_list = list("Наверняка не очень-то и вредно для Вас!","Допинг проведёт через безденежье лучше, чем деньги через бездопингье!","На здоровье!")
	slogan_list = list("Включи, настрой, получи!","С химией жить веселей!","Затянитесь!","Сохраняй улыбку на устах и песню в своём сердце!")
	products = list(/obj/item/storage/fancy/cigarettes = 5,
					/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_robust = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_midori = 3,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/random = 4,
					/obj/item/storage/fancy/rollingpapers = 5)
	premium = list(/obj/item/clothing/mask/cigarette/cigar/havana = 2,
				   /obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
				   /obj/item/lighter/zippo = 3)
	prices = list()

/obj/machinery/vending/sovietsoda
	name = "\improper BODA"
	desc = "Old sweet water vending machine."

	icon_state = "sovietsoda_off"
	panel_overlay = "sovietsoda_panel"
	screen_overlay = "sovietsoda"
	lightmask_overlay = "sovietsoda_lightmask"
	broken_overlay = "sovietsoda_broken"
	broken_lightmask_overlay = "sovietsoda_broken_lightmask"

	ads_list = list("For Tsar and Country.","Have you fulfilled your nutrition quota today?","Very nice!","We are simple people, for this is all we eat.","If there is a person, there is a problem. If there is no person, then there is no problem.")
	products = list(/obj/item/reagent_containers/food/drinks/drinkingglass/soda = 30)
	contraband = list(/obj/item/reagent_containers/food/drinks/drinkingglass/cola = 20)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/sovietsoda

/obj/machinery/vending/sustenance
	name = "\improper Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	slogan_list = list("Enjoy your meal.","Enough calories to support strenuous labor.")
	ads_list = list("The healthiest!","Award-winning chocolate bars!","Mmm! So good!","Oh my god it's so juicy!","Have a snack.","Snacks are good for you!","Have some more Getmore!","Best quality snacks straight from mars.","We love chocolate!","Try our new jerky!")

	icon_state = "sustenance_off"
	panel_overlay = "snack_panel"
	screen_overlay = "snack"
	lightmask_overlay = "snack_lightmask"
	broken_overlay = "snack_broken"
	broken_lightmask_overlay = "snack_broken_lightmask"

	broken_lightmask_overlay = "snack_broken_lightmask"
	products = list(/obj/item/reagent_containers/food/snacks/tofu = 24,
					/obj/item/reagent_containers/food/drinks/ice = 12,
					/obj/item/reagent_containers/food/snacks/candy/candy_corn = 6)
	contraband = list(/obj/item/kitchen/knife = 6,
					  /obj/item/reagent_containers/food/drinks/coffee = 12,
					  /obj/item/tank/internals/emergency_oxygen = 6,
					  /obj/item/clothing/mask/breath = 6)
	refill_canister = /obj/item/vending_refill/sustenance

/obj/machinery/vending/sustenance/additional
	desc = "Какого этот автомат тут оказался?!"
	products = list(/obj/item/reagent_containers/food/snacks/tofu = 12,
					/obj/item/reagent_containers/food/drinks/ice = 6,
					/obj/item/reagent_containers/food/snacks/candy/candy_corn = 6)
	contraband = list(/obj/item/kitchen/knife=2)

/obj/machinery/vending/syndicigs
	name = "\improper Suspicious Cigarette Machine"
	desc = "Smoke 'em if you've got 'em."
	slogan_list = list("Космосигареты на вкус хороши, какими они и должны быть.","I'd rather toolbox than switch.","Затянитесь!","Не верьте исследованиям — курите сегодня!")
	ads_list = list("Наверняка не очень-то и вредно для Вас!","Не верьте учёным!","На здоровье!","Не бросайте курить, купите ещё!","Затянитесь!","Никотиновый рай.","Лучшие сигареты с 2150 года.","Сигареты с множеством наград.")
	vend_delay = 34

	icon_state = "cigs_off"
	panel_overlay = "cigs_panel"
	screen_overlay = "cigs"
	lightmask_overlay = "cigs_lightmask"
	broken_overlay = "cigs_broken"
	broken_lightmask_overlay = "cigs_broken_lightmask"

	products = list(/obj/item/storage/fancy/cigarettes/syndicate = 10,/obj/item/lighter/random = 5)

/obj/machinery/vending/syndisnack
	name = "\improper Getmore Chocolate Corp"
	desc = "A modified snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars"
	slogan_list = list("Try our new nougat bar!","Twice the calories for half the price!")
	ads_list = list("The healthiest!","Award-winning chocolate bars!","Mmm! So good!","Oh my god it's so juicy!","Have a snack.","Snacks are good for you!","Have some more Getmore!","Best quality snacks straight from mars.","We love chocolate!","Try our new jerky!")

	icon_state = "snack_off"
	panel_overlay = "snack_panel"
	screen_overlay = "snack"
	lightmask_overlay = "snack_lightmask"
	broken_overlay = "snack_broken"
	broken_lightmask_overlay = "snack_broken_lightmask"

	products = list(/obj/item/reagent_containers/food/snacks/chips =6,/obj/item/reagent_containers/food/snacks/sosjerky = 6,
					/obj/item/reagent_containers/food/snacks/syndicake = 6, /obj/item/reagent_containers/food/snacks/cheesiehonkers = 6)

