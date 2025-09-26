/obj/machinery/vending/cola
	name = "Robust Softdrinks"
	desc = "Автомат с безалкогольными напитками, предоставляемый компанией Robust Industries, LLC."
	icon_state = "cola-machine_off"
	panel_overlay = "cola-machine_panel"
	screen_overlay = "cola-machine"
	lightmask_overlay = "cola-machine_lightmask"
	broken_overlay = "cola-machine_broken"
	broken_lightmask_overlay = "cola-machine_broken_lightmask"

	slogan_list = list(
		"Освеж+ает!",
		"Над+еюсь, вас одол+ела ж+ажда!",
		"Пр+одано б+ольше милли+арда бут+ылок!",
		"Хот+ите пить? Почем+у бы не взять к+олы?",
		"Пож+алуйста, куп+ите нап+иток",
		"В+ыпьем!",
		"Л+учшие нап+итки во всём к+осмосе",
		"Роб+аст с+офтдринкс: кр+епче, чем монтир+овкой по гол+ов+е!"
	)

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
		/obj/item/reagent_containers/food/drinks/cans/cola = 19,
		/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 19,
		/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 19,
		/obj/item/reagent_containers/food/drinks/cans/starkist = 19,
		/obj/item/reagent_containers/food/drinks/cans/space_up = 19,
		/obj/item/reagent_containers/food/drinks/cans/grape_juice = 19,
		/obj/item/reagent_containers/food/drinks/cans/energy = 39,
		/obj/item/reagent_containers/food/drinks/cans/energy/trop = 39,
		/obj/item/reagent_containers/food/drinks/cans/energy/milk = 39,
		/obj/item/reagent_containers/food/drinks/cans/energy/grey = 39,
		/obj/item/reagent_containers/food/drinks/cans/thirteenloko = 79,
		/obj/item/reagent_containers/food/drinks/zaza = 199)
	refill_canister = /obj/item/vending_refill/cola

/obj/machinery/vending/cola/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Robust Softdrinks",
		GENITIVE = "торгового автомата Robust Softdrinks",
		DATIVE = "торговому автомату Robust Softdrinks",
		ACCUSATIVE = "торговый автомат Robust Softdrinks",
		INSTRUMENTAL = "торговым автоматом Robust Softdrinks",
		PREPOSITIONAL = "торговом автомате Robust Softdrinks"
	)

/obj/machinery/vending/cola/free
	prices = list()
