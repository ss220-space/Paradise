/obj/machinery/vending/medical
	name = "NanoMed Plus"
	desc = "Медицинский раздатчик веществ."
	icon_state = "med_off"
	panel_overlay = "med_panel"
	screen_overlay = "med"
	lightmask_overlay = "med_lightmask"
	broken_overlay = "med_broken"
	broken_lightmask_overlay = "med_broken_lightmask"
	deny_overlay = "med_deny"

	slogan_list = list(
		"Ид+и и спас+и н+есколько ж+изней!",
		"Л+учшее снаряж+ение для в+ашего медотд+ела!",
		"Т+олько л+учшие медикам+енты!",
		"Натур+альные химик+аты!",
		"+Эта шт+ука спас+ает ж+изни!",
		"М+ожет с+ами пр+имете?",
	)
	req_access = list(ACCESS_MEDICAL)
	default_price = PAYCHECK_MIN * 0.5
	default_premium_price = PAYCHECK_CREW

	product_categories = list(
		list(
			"name" = "Обработка травм и ранений",
			"icon" = "kit-medical",
			"products" = list(
				/obj/item/stack/medical/bruise_pack = 10,
				/obj/item/stack/medical/ointment = 10,
				/obj/item/stack/medical/bruise_pack/advanced = 5,
				/obj/item/stack/medical/ointment/advanced = 5,
				/obj/item/stack/medical/bruise_pack/synthflesh_kit = 5,
				/obj/item/stack/medical/suture = 10,
				/obj/item/stack/medical/splint = 8,
				/obj/item/tourniquet = 10,
				/obj/item/tourniquet/advanced = 5,
			),
		),
		list(
			"name" = "Шприцы и инъекторы",
			"icon" = "syringe",
			"products" = list(
				/obj/item/reagent_containers/hypospray/autoinjector = 10,
				/obj/item/reagent_containers/hypospray/autoinjector/traneksam = 10,
				/obj/item/reagent_containers/hypospray/autoinjector/salbutamol = 10,
				/obj/item/reagent_containers/hypospray/autoinjector/charcoal = 10,
				/obj/item/reagent_containers/syringe = 10,
				/obj/item/reagent_containers/syringe/antiviral = 8,
				/obj/item/reagent_containers/syringe/calomel = 8,
				/obj/item/reagent_containers/syringe/insulin = 8,
				/obj/item/reagent_containers/syringe/heparin = 8,
			),
		),
		list(
			"name" = "Таблетки и пластыри",
			"icon" = "pills",
			"products" = list(
				/obj/item/reagent_containers/food/pill/patch/styptic = 10,
				/obj/item/reagent_containers/food/pill/patch/silver_sulf = 10,
				/obj/item/reagent_containers/food/pill/mannitol = 10,
				/obj/item/reagent_containers/food/pill/salbutamol = 10,
				/obj/item/reagent_containers/food/pill/mutadone = 10,
			),
		),
		list(
			"name" = "Бутылки",
			"icon" = "flask",
			"products" = list(
				/obj/item/reagent_containers/glass/bottle/oculine = 5,
				/obj/item/reagent_containers/glass/bottle/epinephrine = 5,
				/obj/item/reagent_containers/glass/bottle/saline = 5,
				/obj/item/reagent_containers/glass/bottle/charcoal = 5,
				/obj/item/reagent_containers/glass/bottle/salicylic = 5,
				/obj/item/reagent_containers/glass/bottle/morphine = 5,
				/obj/item/reagent_containers/glass/bottle/ether = 5,
				/obj/item/reagent_containers/glass/bottle/potassium_iodide = 5,
				/obj/item/reagent_containers/glass/bottle/atropine = 5,
				/obj/item/reagent_containers/glass/bottle/diphenhydramine = 5,
			),
		),
		list(
			"name" = "Оборудование",
			"icon" = "pager",
			"products" = list(
				/obj/item/healthanalyzer = 5,
				/obj/item/healthupgrade = 5,
				/obj/item/reagent_containers/hypospray/safety = 3,
				/obj/item/sensor_device = 2,
				/obj/item/pinpointer/crew = 2,
			),
		),
		list(
			"name" = "Другое",
			"icon" = "ellipsis",
			"products" = list(
				/obj/item/reagent_containers/dropper = 5,
				/obj/item/reagent_containers/glass/beaker = 8,
				/obj/item/reagent_containers/iv_bag/slime = 2,
			),
		),
	)
	premium = list(
		/obj/item/reagent_containers/applicator/brute = 5,
		/obj/item/reagent_containers/applicator/burn = 5,
		/obj/item/stack/medical/bruise_pack/extended = 5,
		/obj/item/stack/medical/ointment/extended = 5,
		/obj/item/stack/medical/suture/advanced = 5,
		/obj/item/stack/medical/bruise_pack/military = 5,
	)
	contraband = list(
		/obj/item/reagent_containers/glass/bottle/sulfonal = 3,
		/obj/item/reagent_containers/glass/bottle/pancuronium = 3,
		/obj/item/reagent_containers/hypospray/autoinjector/neuromatin = 3,
	)
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/medical

/obj/machinery/vending/medical/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NanoMed Plus",
		GENITIVE = "торгового автомата NanoMed Plus",
		DATIVE = "торговому автомату NanoMed Plus",
		ACCUSATIVE = "торговый автомат NanoMed Plus",
		INSTRUMENTAL = "торговым автоматом NanoMed Plus",
		PREPOSITIONAL = "торговом автомате NanoMed Plus",
	)

/obj/machinery/vending/medical/syndicate_access
	name = "SyndiMed Plus"
	icon_state = "syndi-big-med_off"
	panel_overlay = "syndi-big-med_panel"
	screen_overlay = "syndi-big-med"
	deny_overlay = "syndi-big-med_deny"

	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/vending/medical/syndicate_access/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат SyndiMed Plus",
		GENITIVE = "торгового автомата SyndiMed Plus",
		DATIVE = "торговому автомату SyndiMed Plus",
		ACCUSATIVE = "торговый автомат SyndiMed Plus",
		INSTRUMENTAL = "торговым автоматом SyndiMed Plus",
		PREPOSITIONAL = "торговом автомате SyndiMed Plus",
	)

/obj/machinery/vending/medical/syndicate_access/beamgun
	premium = list(
		/obj/item/reagent_containers/applicator/brute = 5,
		/obj/item/reagent_containers/applicator/burn = 5,
		/obj/item/stack/medical/bruise_pack/extended = 5,
		/obj/item/stack/medical/ointment/extended = 5,
		/obj/item/stack/medical/suture/advanced = 5,
		/obj/item/stack/medical/bruise_pack/military = 5,
		/obj/item/gun/medbeam = 1,
	)
