//Автоматы, обычно относящиеся к определённому отделу

/obj/machinery/vending/medical
	name = "\improper NanoMed Plus"
	desc = "Medical drug dispenser."

	icon_state = "med_off"
	panel_overlay = "med_panel"
	screen_overlay = "med"
	lightmask_overlay = "med_lightmask"
	broken_overlay = "med_broken"
	broken_lightmask_overlay = "med_broken_lightmask"
	deny_overlay = "med_deny"

	ads_list = list("Иди и спаси несколько жизней!","Лучшее снаряжение для вашего медотдела","Только лучшие инструменты","Натуральные химикаты!","Эта штука спасает жизни","Может сами примете?","Пинг!")
	req_access = list(ACCESS_MEDICAL)
	products = list(/obj/item/reagent_containers/syringe = 12, /obj/item/reagent_containers/food/pill/patch/styptic = 4, /obj/item/reagent_containers/food/pill/patch/silver_sulf = 4, /obj/item/reagent_containers/applicator/brute = 3, /obj/item/reagent_containers/applicator/burn = 3,
					/obj/item/reagent_containers/glass/bottle/charcoal = 4, /obj/item/reagent_containers/glass/bottle/epinephrine = 4, /obj/item/reagent_containers/glass/bottle/diphenhydramine = 4,
					/obj/item/reagent_containers/glass/bottle/salicylic = 4, /obj/item/reagent_containers/glass/bottle/potassium_iodide = 3, /obj/item/reagent_containers/glass/bottle/saline = 5,
					/obj/item/reagent_containers/glass/bottle/morphine = 4, /obj/item/reagent_containers/glass/bottle/ether = 4, /obj/item/reagent_containers/glass/bottle/atropine = 3,
					/obj/item/reagent_containers/glass/bottle/oculine = 2, /obj/item/reagent_containers/glass/bottle/toxin = 4, /obj/item/reagent_containers/syringe/antiviral = 6,
					/obj/item/reagent_containers/syringe/insulin = 6, /obj/item/reagent_containers/syringe/calomel = 10, /obj/item/reagent_containers/syringe/heparin = 4, /obj/item/reagent_containers/hypospray/autoinjector = 5, /obj/item/reagent_containers/food/pill/salbutamol = 10,
					/obj/item/reagent_containers/food/pill/mannitol = 10, /obj/item/reagent_containers/food/pill/mutadone = 5, /obj/item/stack/medical/bruise_pack/advanced = 4, /obj/item/stack/medical/ointment/advanced = 4, /obj/item/stack/medical/bruise_pack = 4,
					/obj/item/stack/medical/ointment = 4, /obj/item/stack/medical/splint = 4, /obj/item/reagent_containers/glass/beaker = 4, /obj/item/reagent_containers/dropper = 4, /obj/item/healthanalyzer = 4,
					/obj/item/healthupgrade = 4, /obj/item/reagent_containers/hypospray/safety = 2, /obj/item/sensor_device = 2, /obj/item/pinpointer/crew = 2, /obj/item/reagent_containers/iv_bag/slime = 1)
	contraband = list(/obj/item/reagent_containers/glass/bottle/sulfonal = 1, /obj/item/reagent_containers/glass/bottle/pancuronium = 1)
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/medical

/obj/machinery/vending/medical/syndicate_access
	name = "\improper SyndiMed Plus"

	icon_state = "syndi-big-med_off"
	panel_overlay = "syndi-big-med_panel"
	screen_overlay = "syndi-big-med"
	lightmask_overlay = "med_lightmask"
	broken_overlay = "med_broken"
	broken_lightmask_overlay = "med_broken_lightmask"
	deny_overlay = "syndi-big-med_deny"

	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/vending/medical/syndicate_access/beamgun
	premium = list(/obj/item/gun/medbeam = 1)

/obj/machinery/vending/wallmed
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	ads_list = list("Иди и спаси несколько жизней!","Лучшее снаряжение для вашего медотдела","Только лучшие инструменты","Натуральные химикаты!","Эта штука спасает жизни","Может сами примете?","Пинг!")

	icon_state = "wallmed_off"
	panel_overlay = "wallmed_panel"
	screen_overlay = "wallmed"
	lightmask_overlay = "wallmed_lightmask"
	broken_overlay = "wallmed_broken"
	broken_lightmask_overlay = "wallmed_broken_lightmask"
	deny_overlay = "wallmed_deny"

	density = FALSE //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/stack/medical/bruise_pack = 2, /obj/item/stack/medical/ointment = 2, /obj/item/reagent_containers/hypospray/autoinjector = 4, /obj/item/healthanalyzer = 1)
	contraband = list(/obj/item/reagent_containers/syringe/charcoal = 4, /obj/item/reagent_containers/syringe/antiviral = 4, /obj/item/reagent_containers/food/pill/tox = 1)
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallmed
	tiltable = FALSE

/obj/machinery/vending/wallmed/syndicate
	name = "\improper SyndiWallMed"
	desc = "<b>EVIL</b> wall-mounted Medical Equipment dispenser."

	icon_state = "wallmed_off"
	panel_overlay = "wallmed_panel"
	screen_overlay = "syndimed"
	lightmask_overlay = "wallmed_lightmask"
	broken_overlay = "wallmed_broken"
	broken_lightmask_overlay = "wallmed_broken_lightmask"
	deny_overlay = "syndimed_deny"

	broken_lightmask_overlay = "wallmed_broken_lightmask"
	ads_list = list("Иди и оборви несколько жизней!","Лучшее снаряжение для вашего корабля","Только лучшие инструменты","Натуральные химикаты!","Эта штука спасает жизни","Может сами примете?","Пинг!")
	req_access = list(ACCESS_SYNDICATE)
	products = list(/obj/item/stack/medical/bruise_pack = 2,/obj/item/stack/medical/ointment = 2,/obj/item/reagent_containers/hypospray/autoinjector = 4,/obj/item/healthanalyzer = 1)
	contraband = list(/obj/item/reagent_containers/syringe/charcoal = 4,/obj/item/reagent_containers/syringe/antiviral = 4,/obj/item/reagent_containers/food/pill/tox = 1)

/obj/machinery/vending/plasmaresearch
	name = "\improper Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"

	icon_state = "generic_off"
	panel_overlay = "generic_panel"
	screen_overlay = "generic"
	lightmask_overlay = "generic_lightmask"
	broken_overlay = "generic_broken"
	broken_lightmask_overlay = "generic_broken_lightmask"

	products = list(/obj/item/assembly/prox_sensor = 8, /obj/item/assembly/igniter = 8, /obj/item/assembly/signaler = 8,
					/obj/item/wirecutters = 1, /obj/item/assembly/timer = 8)
	contraband = list(/obj/item/flashlight = 5, /obj/item/assembly/voice = 3, /obj/item/assembly/health = 3, /obj/item/assembly/infra = 3)

/obj/machinery/vending/security
	name = "\improper SecTech"
	desc = "A security equipment vendor."
	ads_list = list("Круши черепа капиталистов!","Отбей несколько голов!","Не забывай, вредительство - полезно!","Твое оружие здесь.","Наручники!","Стоять, подонок!","Не бей меня, брат!","Убей их, брат.","Почему бы не съесть пончик?")

	icon_state = "sec_off"
	panel_overlay = "sec_panel"
	screen_overlay = "sec"
	lightmask_overlay = "sec_lightmask"
	broken_overlay = "sec_broken"
	broken_lightmask_overlay = "sec_broken_lightmask"
	deny_overlay = "sec_deny"

	req_access = list(ACCESS_SECURITY)
	products = list(/obj/item/restraints/handcuffs = 8,/obj/item/restraints/handcuffs/cable/zipties = 8,/obj/item/grenade/flashbang = 4,/obj/item/flash = 5,
					/obj/item/reagent_containers/food/snacks/donut = 12,/obj/item/storage/box/evidence = 6,/obj/item/flashlight/seclite = 4,/obj/item/restraints/legcuffs/bola/energy = 7,
					/obj/item/clothing/mask/muzzle/safety = 4, /obj/item/storage/box/swabs = 6, /obj/item/storage/box/fingerprints = 6, /obj/item/eftpos/sec = 4, /obj/item/storage/belt/security/webbing = 2, /obj/item/grenade/smokebomb = 8,
					)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,/obj/item/storage/fancy/donut_box = 2,/obj/item/hailer = 5)
	prices = list(/obj/item/storage/belt/security/webbing = 2000,/obj/item/grenade/smokebomb = 250)
	refill_canister = /obj/item/vending_refill/security

/obj/machinery/vending/security/training
	name = "\improper SecTech Training"
	desc = "A security training equipment vendor."
	ads_list = list("Соблюдай чистоту на стрельбище!","Даже я стреляю лучше тебя!","Почему так косо, бухой что ли?!","Техника безопасности нам не писана, да?","1 из 10 попаданий... А ты хорош!","Инструктор это твой папочка!","Эй, ты куда целишься?!")

	icon_state = "sectraining_off"
	panel_overlay = "sec_panel"
	screen_overlay = "sec"
	lightmask_overlay = "sec_lightmask"
	broken_overlay = "sec_broken"
	broken_lightmask_overlay = "sectraining_broken_lightmask"
	deny_overlay = "sec_deny"

	req_access = list(ACCESS_SECURITY)
	products = list(/obj/item/clothing/ears/earmuffs = 2, /obj/item/gun/energy/laser/practice = 2, /obj/item/gun/projectile/automatic/toy/pistol/enforcer = 2,
				    /obj/item/gun/projectile/shotgun/toy = 2, /obj/item/gun/projectile/automatic/toy = 2)
	contraband = list(/obj/item/toy/figure/secofficer = 1)
	refill_canister = /obj/item/vending_refill/security


/obj/machinery/vending/security/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || !powered())
		return ..()

	if(istype(I, /obj/item/security_voucher))
		add_fingerprint(user)
		var/static/list/available_kits = list(
			"Dominator Kit" = /obj/item/storage/box/dominator_kit,
			"Enforcer Kit" = /obj/item/storage/box/enforcer_kit,
		)
		var/weapon_kit = tgui_input_list(user, "Select a weaponary kit:", "Weapon kits", available_kits)
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


/obj/item/security_voucher
	name = "security voucher"
	desc = "A token to redeem a weapon kit. Use it on a SecTech."
	icon_state = "security_voucher"
	w_class = WEIGHT_CLASS_SMALL

/obj/machinery/vending/hydronutrients
	name = "\improper NutriMax"
	desc = "A plant nutrients vendor"
	slogan_list = list("Вам не надо удобрять почву естественным путём — разве это не чудесно?","Теперь на 50% меньше вони!","Растения тоже люди!")
	ads_list = list("Мы любим растения!","Может сами примете?","Самые зелёные кнопки на свете.","Мы любим большие растения.","Мягкая почва…")

	icon_state = "nutri_off"
	panel_overlay = "nutri_panel"
	screen_overlay = "nutri"
	lightmask_overlay = "nutri_lightmask"
	broken_overlay = "nutri_broken"
	broken_lightmask_overlay = "nutri_broken_lightmask"
	deny_overlay = "nutri_deny"

	products = list(/obj/item/reagent_containers/glass/bottle/nutrient/ez = 20,/obj/item/reagent_containers/glass/bottle/nutrient/l4z = 13,/obj/item/reagent_containers/glass/bottle/nutrient/rh = 6,/obj/item/reagent_containers/spray/pestspray = 20,
					/obj/item/reagent_containers/syringe = 5,/obj/item/storage/bag/plants = 5,/obj/item/cultivator = 3,/obj/item/shovel/spade = 3,/obj/item/plant_analyzer = 4)
	contraband = list(/obj/item/reagent_containers/glass/bottle/ammonia = 10,/obj/item/reagent_containers/glass/bottle/diethylamine = 5)
	refill_canister = /obj/item/vending_refill/hydronutrients

/obj/machinery/vending/hydroseeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	slogan_list = list("THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!","Hands down the best seed selection on the station!","Also certain mushroom varieties available, more for experts! Get certified today!")
	ads_list = list("Мы любим растения!","Вырасти урожай!","Расти, малыш, расти-и-и-и!","Ды-а, сына!")

	icon_state = "seeds_off"
	panel_overlay = "seeds_panel"
	screen_overlay = "seeds"
	lightmask_overlay = "seeds_lightmask"
	broken_overlay = "seeds_broken"
	broken_lightmask_overlay = "seeds_broken_lightmask"

	products = list(/obj/item/seeds/aloe =3,
					/obj/item/seeds/ambrosia = 3,
					/obj/item/seeds/apple = 3,
					/obj/item/seeds/banana = 3,
					/obj/item/seeds/berry = 3,
					/obj/item/seeds/cabbage = 3,
					/obj/item/seeds/carrot = 3,
					/obj/item/seeds/cherry = 3,
					/obj/item/seeds/chanter = 3,
					/obj/item/seeds/chili = 3,
					/obj/item/seeds/cocoapod = 3,
					/obj/item/seeds/coffee = 3,
					/obj/item/seeds/comfrey =3,
					/obj/item/seeds/corn = 3,
					/obj/item/seeds/cotton = 3,
					/obj/item/seeds/nymph =3,
					/obj/item/seeds/eggplant = 3,
					/obj/item/seeds/garlic = 3,
					/obj/item/seeds/grape = 3,
					/obj/item/seeds/grass = 3,
					/obj/item/seeds/lemon = 3,
					/obj/item/seeds/lime = 3,
					/obj/item/seeds/onion = 3,
					/obj/item/seeds/orange = 3,
					/obj/item/seeds/peanuts = 3,
					/obj/item/seeds/peas =3,
					/obj/item/seeds/pineapple = 3,
					/obj/item/seeds/poppy = 3,
					/obj/item/seeds/geranium = 3,
					/obj/item/seeds/lily = 3,
					/obj/item/seeds/potato = 3,
					/obj/item/seeds/pumpkin = 3,
					/obj/item/seeds/replicapod = 3,
					/obj/item/seeds/wheat/rice = 3,
					/obj/item/seeds/soya = 3,
					/obj/item/seeds/sugarcane = 3,
					/obj/item/seeds/sunflower = 3,
					/obj/item/seeds/tea = 3,
					/obj/item/seeds/tobacco = 3,
					/obj/item/seeds/tomato = 3,
					/obj/item/seeds/cucumber = 3,
					/obj/item/seeds/tower = 3,
					/obj/item/seeds/watermelon = 3,
					/obj/item/seeds/wheat = 3,
					/obj/item/seeds/soya/olive = 3,
					/obj/item/seeds/whitebeet = 3,
					/obj/item/seeds/shavel = 3,
					/obj/item/seeds/redflower = 3,
					/obj/item/seeds/flowerlamp = 3,
					/obj/item/seeds/carnation = 3,
					/obj/item/seeds/tulp = 3,
					/obj/item/seeds/chamomile = 3,
					/obj/item/seeds/rose = 3
					)
	contraband = list(/obj/item/seeds/cannabis = 3,
					  /obj/item/seeds/amanita = 2,
					  /obj/item/seeds/fungus = 3,
					  /obj/item/seeds/glowshroom = 2,
					  /obj/item/seeds/liberty = 2,
					  /obj/item/seeds/nettle = 2,
					  /obj/item/seeds/plump = 2,
					  /obj/item/seeds/reishi = 2,
					  /obj/item/seeds/starthistle = 2,
					  /obj/item/seeds/random = 2,
					  /obj/item/seeds/moonlight = 2,
					  /obj/item/seeds/coca = 2)
	premium = list(/obj/item/reagent_containers/spray/waterflower = 1)
	refill_canister = /obj/item/vending_refill/hydroseeds

/obj/machinery/vending/dinnerware
	name = "\improper Plasteel Chef's Dinnerware Vendor"
	desc = "A kitchen and restaurant equipment vendor."
	ads_list = list("Mm, food stuffs!","Food and food accessories.","Get your plates!","You like forks?","I like forks.","Woo, utensils.","You don't really need these...")

	icon_state = "dinnerware_off"
	panel_overlay = "dinnerware_panel"
	screen_overlay = "dinnerware"
	lightmask_overlay = "dinnerware_lightmask"
	broken_overlay = "dinnerware_broken"
	broken_lightmask_overlay = "dinnerware_broken_lightmask"

	products = list(/obj/item/storage/bag/tray = 8,/obj/item/kitchen/utensil/fork = 6,
					/obj/item/kitchen/knife = 3,/obj/item/kitchen/rollingpin = 2,
					/obj/item/kitchen/sushimat = 3,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 8, /obj/item/clothing/suit/chef/classic = 2, /obj/item/storage/belt/chef = 2,
					/obj/item/reagent_containers/food/condiment/pack/ketchup = 5,
					/obj/item/reagent_containers/food/condiment/pack/hotsauce = 5,
					/obj/item/reagent_containers/food/condiment/saltshaker =5,
					/obj/item/reagent_containers/food/condiment/peppermill =5,
					/obj/item/reagent_containers/food/condiment/herbs = 2,
					/obj/item/whetstone = 2, /obj/item/mixing_bowl = 10,
					/obj/item/kitchen/mould/bear = 1, /obj/item/kitchen/mould/worm = 1,
					/obj/item/kitchen/mould/bean = 1, /obj/item/kitchen/mould/ball = 1,
					/obj/item/kitchen/mould/cane = 1, /obj/item/kitchen/mould/cash = 1,
					/obj/item/kitchen/mould/coin = 1, /obj/item/kitchen/mould/loli = 1,
					/obj/item/kitchen/cutter = 2, /obj/item/eftpos = 4)
	contraband = list(/obj/item/kitchen/rollingpin = 2, /obj/item/kitchen/knife/butcher = 2)
	refill_canister = /obj/item/vending_refill/dinnerware

/obj/machinery/vending/dinnerware/old
	products = list(/obj/item/storage/bag/tray = 1, /obj/item/kitchen/utensil/fork = 2,
					/obj/item/kitchen/knife = 0, /obj/item/kitchen/rollingpin = 0,
					/obj/item/kitchen/sushimat = 1,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 2,
					/obj/item/clothing/suit/chef/classic = 1,
					/obj/item/storage/belt/chef = 0, /obj/item/reagent_containers/food/condiment/pack/ketchup = 1,
					/obj/item/reagent_containers/food/condiment/pack/hotsauce = 0,/obj/item/reagent_containers/food/condiment/saltshaker = 1,
					/obj/item/reagent_containers/food/condiment/peppermill = 2,/obj/item/whetstone = 1,
					/obj/item/mixing_bowl = 3,/obj/item/kitchen/mould/bear = 1,
					/obj/item/kitchen/mould/worm = 0,/obj/item/kitchen/mould/bean = 0,
					/obj/item/kitchen/mould/ball = 1,/obj/item/kitchen/mould/cane = 1,
					/obj/item/kitchen/mould/cash = 0,/obj/item/kitchen/mould/coin = 0,
					/obj/item/kitchen/mould/loli = 1,/obj/item/kitchen/cutter = 0, /obj/item/eftpos = 1)

/obj/machinery/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."

	icon_state = "tool_off"
	panel_overlay = "tool_panel"
	screen_overlay = "tool"
	lightmask_overlay = "tool_lightmask"
	broken_overlay = "tool_broken"
	broken_lightmask_overlay = "tool_broken_lightmask"
	deny_overlay = "tool_deny"

	products = list(/obj/item/stack/cable_coil/random = 10,
					/obj/item/crowbar = 5,
					/obj/item/weldingtool = 3,
					/obj/item/wirecutters = 5,
					/obj/item/wrench = 5,
					/obj/item/analyzer = 5,
					/obj/item/t_scanner = 5,
					/obj/item/screwdriver = 5,
					/obj/item/clothing/gloves/color/fyellow = 2
					)
	contraband = list(/obj/item/weldingtool/hugetank = 2,
					/obj/item/clothing/gloves/color/yellow = 1
					)
	prices = list(/obj/item/stack/cable_coil/random = 30,
					/obj/item/crowbar = 50,/obj/item/weldingtool = 50,
					/obj/item/wirecutters = 50,
					/obj/item/wrench = 50,
					/obj/item/analyzer = 30,
					/obj/item/t_scanner = 30,
					/obj/item/screwdriver = 50,
					/obj/item/clothing/gloves/color/fyellow = 250,
					/obj/item/weldingtool/hugetank = 200,
					/obj/item/clothing/gloves/color/yellow = 500
	)
	refill_canister = /obj/item/vending_refill/youtool
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF


/obj/machinery/vending/engivend
	name = "\improper Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"

	icon_state = "engivend_off"
	panel_overlay = "engivend_panel"
	screen_overlay = "engivend"
	lightmask_overlay = "engivend_lightmask"
	broken_overlay = "engivend_broken"
	broken_lightmask_overlay = "engivend_broken_lightmask"
	deny_overlay = "engivend_deny"

	req_access = list(11,24) // Engineers and atmos techs can use this
	products = list(/obj/item/clothing/glasses/meson = 2,/obj/item/multitool = 4,/obj/item/airlock_electronics = 10,/obj/item/firelock_electronics = 10,/obj/item/firealarm_electronics = 10,/obj/item/apc_electronics = 10,/obj/item/airalarm_electronics = 10,/obj/item/access_control = 10,/obj/item/assembly/control/airlock = 10,/obj/item/stock_parts/cell/high = 10,/obj/item/camera_assembly = 10)
	contraband = list(/obj/item/stock_parts/cell/potato = 3)
	premium = list(/obj/item/storage/belt/utility = 3)
	refill_canister = /obj/item/vending_refill/engivend

/obj/machinery/vending/engineering
	name = "\improper Robco Tool Maker"
	desc = "Everything you need for do-it-yourself station repair."

	icon_state = "engi_off"
	panel_overlay = "engi_panel"
	screen_overlay = "engi"
	lightmask_overlay = "engi_lightmask"
	broken_overlay = "engi_broken"
	broken_lightmask_overlay = "engi_broken_lightmask"
	deny_overlay = "engi_deny"
	deny_lightmask = "engi_deny_lightmask"

	req_access = list(ACCESS_ENGINE_EQUIP)
	products = list(/obj/item/clothing/under/rank/chief_engineer = 4,/obj/item/clothing/under/rank/engineer = 4,/obj/item/clothing/shoes/workboots = 4,/obj/item/clothing/head/hardhat = 4,
					/obj/item/storage/belt/utility = 4,/obj/item/clothing/glasses/meson = 4,/obj/item/clothing/gloves/color/yellow = 4, /obj/item/screwdriver = 12,
					/obj/item/crowbar = 12,/obj/item/wirecutters = 12,/obj/item/multitool = 12,/obj/item/wrench = 12,/obj/item/t_scanner = 12,
					/obj/item/stack/cable_coil = 8, /obj/item/stock_parts/cell = 8, /obj/item/weldingtool = 8,/obj/item/clothing/head/welding = 8,
					/obj/item/light/tube = 10,/obj/item/clothing/suit/fire = 4, /obj/item/stock_parts/scanning_module = 5,/obj/item/stock_parts/micro_laser = 5,
					/obj/item/stock_parts/matter_bin = 5,/obj/item/stock_parts/manipulator = 5)
	refill_canister = /obj/item/vending_refill/engineering

/obj/machinery/vending/robotics
	name = "\improper Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."

	icon_state = "robotics_off"
	panel_overlay = "robotics_panel"
	screen_overlay = "robotics"
	lightmask_overlay = "robotics_lightmask"
	broken_overlay = "robotics_broken"
	broken_lightmask_overlay = "robotics_broken_lightmask"
	deny_overlay = "robotics_deny"
	deny_lightmask = "robotics_deny_lightmask"

	req_access = list(ACCESS_ROBOTICS)
	products = list(/obj/item/clothing/suit/storage/labcoat = 4,/obj/item/clothing/under/rank/roboticist = 4,/obj/item/stack/cable_coil = 4,/obj/item/flash = 4,
					/obj/item/stock_parts/cell/high = 12, /obj/item/assembly/prox_sensor = 3,/obj/item/assembly/signaler = 3,/obj/item/healthanalyzer = 3,
					/obj/item/scalpel = 2,/obj/item/circular_saw = 2,/obj/item/tank/internals/anesthetic = 2,/obj/item/clothing/mask/breath/medical = 5,
					/obj/item/screwdriver = 5,/obj/item/crowbar = 5)
	refill_canister = /obj/item/vending_refill/robotics

/obj/machinery/vending/robotics/nt
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/robotics/nt/durand
	products = list(/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay = 3,
		/obj/item/mecha_parts/mecha_equipment/repair_droid = 3,
		/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 3,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot = 3,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg = 3)

/obj/machinery/vending/robotics/nt/gygax
	products = list(/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay = 3,
	/obj/item/mecha_parts/mecha_equipment/repair_droid = 3,
	/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 3,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion = 3,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy = 3)

/obj/machinery/vending/syndierobotics
	name = "Синди Робо-ДеЛюкс!"
	desc = "Всё что нужно, чтобы сделать личного железного друга из ваших врагов!"
	ads_list = list("Make them beep-boop like a robot should!","Robotisation is NOT a crime!","Nyoom!")

	icon_state = "robotics_off"
	panel_overlay = "robotics_panel"
	screen_overlay = "robotics"
	lightmask_overlay = "robotics_lightmask"
	broken_overlay = "robotics_broken"
	broken_lightmask_overlay = "robotics_broken_lightmask"
	deny_overlay = "robotics_deny"
	deny_lightmask = "robotics_deny_lightmask"

	req_access = list(ACCESS_SYNDICATE)
	products = list(/obj/item/robot_parts/robot_suit = 2,
					/obj/item/robot_parts/chest = 2,
					/obj/item/robot_parts/head = 2,
					/obj/item/robot_parts/l_arm = 2,
					/obj/item/robot_parts/r_arm = 2,
					/obj/item/robot_parts/l_leg = 2,
					/obj/item/robot_parts/r_leg = 2,
					/obj/item/stock_parts/cell/high = 6,
					/obj/item/crowbar = 2,
					/obj/item/flash = 4,
					/obj/item/stack/cable_coil = 4,
					/obj/item/mmi/syndie = 2,
					/obj/item/robotanalyzer = 2)

