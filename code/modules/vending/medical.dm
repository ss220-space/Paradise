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
	products = list(
		/obj/item/reagent_containers/hypospray/autoinjector = 10,
		/obj/item/reagent_containers/hypospray/autoinjector/traneksam = 10,
		/obj/item/reagent_containers/hypospray/autoinjector/salbutamol = 10,
		/obj/item/reagent_containers/hypospray/autoinjector/charcoal = 10,
		/obj/item/stack/medical/bruise_pack = 4,
		/obj/item/stack/medical/ointment = 4,
		/obj/item/stack/medical/bruise_pack/advanced = 6,
		/obj/item/stack/medical/ointment/advanced = 6,
		/obj/item/stack/medical/bruise_pack/synthflesh_kit = 3,
		/obj/item/stack/medical/bruise_pack/extended = 3,
		/obj/item/stack/medical/ointment/extended = 3,
		/obj/item/stack/medical/suture = 15,
		/obj/item/stack/medical/suture/advanced = 5,
		/obj/item/stack/medical/bruise_pack/military = 10,
		/obj/item/stack/medical/splint = 4,
		/obj/item/reagent_containers/food/pill/patch/styptic = 4,
		/obj/item/reagent_containers/food/pill/patch/silver_sulf = 4,
		/obj/item/reagent_containers/applicator/brute = 3,
		/obj/item/reagent_containers/applicator/burn = 3,
		/obj/item/healthanalyzer = 4,
		/obj/item/healthupgrade = 4,
		/obj/item/reagent_containers/hypospray/safety = 2,
		/obj/item/sensor_device = 2,
		/obj/item/pinpointer/crew = 2,
		/obj/item/reagent_containers/food/pill/mannitol = 10,
		/obj/item/reagent_containers/food/pill/salbutamol = 10,
		/obj/item/reagent_containers/food/pill/mutadone = 5,
		/obj/item/reagent_containers/syringe/antiviral = 6,
		/obj/item/reagent_containers/syringe/calomel = 10,
		/obj/item/reagent_containers/syringe/insulin = 6,
		/obj/item/reagent_containers/syringe/heparin = 4,
		/obj/item/reagent_containers/glass/bottle/oculine = 2,
		/obj/item/reagent_containers/glass/bottle/epinephrine = 4,
		/obj/item/reagent_containers/glass/bottle/saline = 5,
		/obj/item/reagent_containers/glass/bottle/charcoal = 4,
		/obj/item/reagent_containers/glass/bottle/salicylic = 4,
		/obj/item/reagent_containers/glass/bottle/morphine = 4,
		/obj/item/reagent_containers/glass/bottle/ether = 4,
		/obj/item/reagent_containers/glass/bottle/potassium_iodide = 3,
		/obj/item/reagent_containers/glass/bottle/atropine = 3,
		/obj/item/reagent_containers/glass/bottle/diphenhydramine = 4,
		/obj/item/reagent_containers/glass/bottle/toxin = 4,
		/obj/item/reagent_containers/syringe = 12,
		/obj/item/reagent_containers/dropper = 4,
		/obj/item/reagent_containers/glass/beaker = 4,
		/obj/item/reagent_containers/iv_bag/slime = 1,
	)
	contraband = list(
		/obj/item/reagent_containers/glass/bottle/sulfonal = 1,
		/obj/item/reagent_containers/glass/bottle/pancuronium = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/neuromatin = 3,
	)
	prices = list(
		/obj/item/reagent_containers/hypospray/autoinjector/traneksam = 49,
		/obj/item/stack/medical/bruise_pack/extended = 199,
		/obj/item/stack/medical/ointment/extended = 199,
		/obj/item/stack/medical/bruise_pack/advanced = 99,
		/obj/item/stack/medical/ointment/advanced = 99,
		/obj/item/stack/medical/bruise_pack/synthflesh_kit = 99,
		/obj/item/stack/medical/suture/advanced = 149,
		/obj/item/stack/medical/bruise_pack/military = 299,
		/obj/item/reagent_containers/hypospray/safety = 199,
		/obj/item/pinpointer/crew = 299,
		/obj/item/sensor_device = 599,
		/obj/item/reagent_containers/hypospray/autoinjector/salbutamol = 19,
		/obj/item/reagent_containers/hypospray/autoinjector/charcoal = 19,
		/obj/item/reagent_containers/hypospray/autoinjector/neuromatin = 499,
		/obj/item/reagent_containers/applicator/brute = 149,
		/obj/item/reagent_containers/applicator/burn = 149,
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
	premium = list(/obj/item/gun/medbeam = 1)

/obj/machinery/vending/plasmaresearch
	name = "Toximate 3000"
	desc = "Всё, что вам нужно, в одном удобном месте!"

	panel_overlay = "generic_panel"
	screen_overlay = "generic"
	lightmask_overlay = "generic_lightmask"
	broken_overlay = "generic_broken"
	broken_lightmask_overlay = "generic_broken_lightmask"

	products = list(
		/obj/item/assembly/prox_sensor = 8,
		/obj/item/assembly/igniter = 8,
		/obj/item/assembly/signaler = 8,
		/obj/item/wirecutters = 1,
		/obj/item/assembly/timer = 8,
	)
	contraband = list(
		/obj/item/flashlight = 5,
		/obj/item/assembly/voice = 3,
		/obj/item/assembly/health = 3,
		/obj/item/assembly/infra = 3,
	)

/obj/machinery/vending/plasmaresearch/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Toximate 3000",
		GENITIVE = "торгового автомата Toximate 3000",
		DATIVE = "торговому автомату Toximate 3000",
		ACCUSATIVE = "торговый автомат Toximate 3000",
		INSTRUMENTAL = "торговым автоматом Toximate 3000",
		PREPOSITIONAL = "торговом автомате Toximate 3000",
	)

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

	density = FALSE //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/reagent_containers/hypospray/autoinjector = 4,
		/obj/item/reagent_containers/hypospray/autoinjector/salbutamol = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/charcoal = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/traneksam = 2,
		/obj/item/stack/medical/suture = 4,
		/obj/item/healthanalyzer = 1,
	)
	contraband = list(
		/obj/item/reagent_containers/syringe/charcoal = 4,
		/obj/item/reagent_containers/syringe/antiviral = 4,
		/obj/item/reagent_containers/food/pill/tox = 1,
	)
	prices = list(
		/obj/item/reagent_containers/hypospray/autoinjector/salbutamol = 69,
		/obj/item/reagent_containers/hypospray/autoinjector/charcoal = 69,
		/obj/item/reagent_containers/hypospray/autoinjector/traneksam = 99,
		/obj/item/stack/medical/suture = 99,
		/obj/item/healthanalyzer = 99,
	)
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
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
	products = list(
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/stack/medical/suture = 4,
		/obj/item/reagent_containers/hypospray/autoinjector = 4,
		/obj/item/healthanalyzer = 1,
	)
	contraband = list(
		/obj/item/reagent_containers/syringe/charcoal = 4,
		/obj/item/reagent_containers/syringe/antiviral = 4,
		/obj/item/reagent_containers/food/pill/tox = 1,
	)

/obj/machinery/vending/wallmed/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат SyndiWallMed",
		GENITIVE = "торгового автомата SyndiWallMed",
		DATIVE = "торговому автомату SyndiWallMed",
		ACCUSATIVE = "торговый автомат SyndiWallMed",
		INSTRUMENTAL = "торговым автоматом SyndiWallMed",
		PREPOSITIONAL = "торговом автомате SyndiWallMed",
	)
