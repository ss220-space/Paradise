/obj/machinery/vending/protein
	name = "Автомат спортивного питания"
	desc = "Автомат самообслуживания, любезно предоставленный корпорацией Donk Co. Исключительная польза!"
	slogan_list = list(
		"Попр+обуйте н+аш н+овый проте+иновый бат+ончик!",
		"Накач+аться никогд+а не п+оздно!",
		"В чём с+ила, брат? В кол+ичестве съ+еденных бат+ончиков!", //Брат 2
		"С+амый с+ильный!",
		"+Если не накач+аешься, он+а на теб+я д+аже не посм+отрит!",
		"Поч+увствуй С+ИЛУ!",
		"Д+аже мо+я б+абушка сильн+ее теб+я! Подк+ачайся!",
		"Чем ты сильн+ее, тем м+еньше у теб+я вол+ос.",
		"Пред+ел есть у вс+его, кр+оме гуман+оида!", // Onepunchman
		"Насто+ящая с+ила заключ+ается в спос+обности измен+иться по сво+ей в+оле!", // Onepunchman
		"Кто сильн+ее, тот и прав!",
		"Дод+елал подх+од? Иди сюд+а и закреп+и +это бат+ончиком!"
	)
	icon_state = "protein_off"
	panel_overlay = "cola-machine_panel"
	screen_overlay = "protein_overlay"
	refill_canister = /obj/item/vending_refill/protein

	products = list(
		/obj/item/reagent_containers/food/snacks/proteinbar_banana = 10,
		/obj/item/reagent_containers/food/snacks/proteinbar_cherry = 10,
		/obj/item/reagent_containers/food/snacks/proteinbar_beef = 10,
		/obj/item/reagent_containers/food/drinks/protein/zaza = 1,
		/obj/item/reagent_containers/food/drinks/protein/cherry = 1,
		/obj/item/reagent_containers/food/drinks/protein/chocolate = 1,
		/obj/item/reagent_containers/food/drinks/protein/bananastrawberry = 1,
		/obj/item/reagent_containers/food/drinks/creatine = 4,
		/obj/item/reagent_containers/food/drinks/guarana = 12,
	)
	contraband = list(
		/obj/item/reagent_containers/syringe/steroids = 5,
	)

/obj/machinery/vending/protein/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат спортивного питания",
		GENITIVE = "торгового автомата спортивного питания",
		DATIVE = "торговому автомату спортивного питания",
		ACCUSATIVE = "торговый автомат спортивного питания",
		INSTRUMENTAL = "торговым автоматом спортивного питания",
		PREPOSITIONAL = "торговом автомате спортивного питания",
	)
