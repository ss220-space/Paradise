/obj/machinery/vending/wallmed
	name = "NanoMed"
	desc = "Настенный раздатчик медикаментов."
	slogan_list = list(
		"Ид+и и спас+и н+есколько ж+изней!",
		"Прихват+ите немн+ого на вс+який сл+учай!",
		"Т+олько л+учшие медикам+енты!",
		"Натур+альные химик+аты!",
		"+Эта шт+ука спас+ает ж+изни!",
		"М+ожет с+ами пр+имете?",
	)

	icon_state = "wallmed_off"
	panel_overlay = "wallmed_panel"
	screen_overlay = "wallmed"
	lightmask_overlay = "wallmed_lightmask"
	broken_overlay = "wallmed_broken"
	broken_lightmask_overlay = "wallmed_broken_lightmask"
	deny_overlay = "wallmed_deny"
	default_price = PAYCHECK_LOWER
	default_premium_price = PAYCHECK_CREW

	density = FALSE
	products = list(
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/reagent_containers/hypospray/autoinjector = 4,
		/obj/item/reagent_containers/hypospray/autoinjector/salbutamol = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/charcoal = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/traneksam = 2,
		/obj/item/stack/medical/suture = 4,
		/obj/item/healthanalyzer = 1,
		/obj/item/tourniquet = 3,
	)
	contraband = list(
		/obj/item/reagent_containers/syringe/charcoal = 4,
		/obj/item/reagent_containers/syringe/antiviral = 4,
		/obj/item/reagent_containers/food/pill/tox = 1,
	)
	armor = list(MELEE = 50, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallmed
	tiltable = FALSE

/obj/machinery/vending/wallmed/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат NanoMed",
		GENITIVE = "торгового автомата NanoMed",
		DATIVE = "торговому автомату NanoMed",
		ACCUSATIVE = "торговый автомат NanoMed",
		INSTRUMENTAL = "торговым автоматом NanoMed",
		PREPOSITIONAL = "торговом автомате NanoMed",
	)

/obj/machinery/vending/wallmed/syndicate
	name = "SyndiWallMed"
	desc = "<b>Злое</b> воплощение настенного раздатчика медицинских изделий."
	screen_overlay = "syndimed"
	deny_overlay = "syndimed_deny"

	slogan_list = list(
		"Ид+и и оборв+и н+есколько ж+изней!",
		"Л+учшее снаряж+ение для в+ашего корабл+я!",
		"Т+олько л+учшие +яды!",
		"Ненатур+альные химик+аты!",
		"+Эта шт+ука обрыв+ает ж+изни!",
		"М+ожет с+ами пр+имете?",
	)

	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/vending/wallmed/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат SyndiWallMed",
		GENITIVE = "торгового автомата SyndiWallMed",
		DATIVE = "торговому автомату SyndiWallMed",
		ACCUSATIVE = "торговый автомат SyndiWallMed",
		INSTRUMENTAL = "торговым автоматом SyndiWallMed",
		PREPOSITIONAL = "торговом автомате SyndiWallMed",
	)
