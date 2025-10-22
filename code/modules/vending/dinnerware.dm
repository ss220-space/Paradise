/obj/machinery/vending/dinnerware
	name = "Plasteel Chef's Dinnerware Vendor"
	desc = "Поставщик кухонного и ресторанного оборудования."
	slogan_list = list(
		"Ммм, прод+укты пит+ания!",
		"П+ища и пищев+ые принадл+ежности.",
		"Принес+ите сво+и тар+елки!",
		"Теб+е нр+авятся в+илки?",
		"Я любл+ю в+илки.",
		"Ух ты, пос+уда."
	)

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

/obj/machinery/vending/dinnerware/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Plasteel Chef's Dinnerware Vendor",
		GENITIVE = "торгового автомата Plasteel Chef's Dinnerware Vendor",
		DATIVE = "торговому автомату Plasteel Chef's Dinnerware Vendor",
		ACCUSATIVE = "торговый автомат Plasteel Chef's Dinnerware Vendor",
		INSTRUMENTAL = "торговым автоматом Plasteel Chef's Dinnerware Vendor",
		PREPOSITIONAL = "торговом автомате Plasteel Chef's Dinnerware Vendor"
	)

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
