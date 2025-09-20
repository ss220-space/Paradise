/obj/machinery/vending/boozeomat
	name = "Booze-O-Mat"
	desc = "Чудо техники, предположительно способное выдать идеальный напиток для вас в тот момент, когда вы об этом попросите."
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

	slogan_list = list(
		"Над+еюсь, никт+о не попр+осит мен+я о ч+ёртовой кр+ужке ч+ая…",
		"Алког+оль — друг гуман+оида. Вы же не бр+осите др+уга?",
		"+Очень рад вас обслуж+ить!",
		"Никт+о здесь не х+очет в+ыпить?",
		"В+ыпьем!",
		"Б+удем!",
		"Г+орько!",
		"Алког+оль пойд+ёт вам на п+ользу!",
		"Хот+ите отл+ичного хол+одного п+ива?",
		"Ничт+о так не л+ечит, как алког+оль!",
		"Пригуб+ите!",
		"В+ыпейте!",
		"Возьм+ите пивк+а!",
		"Т+олько л+учший алког+оль!",
		"Алког+оль л+учшего к+ачества с 2053-го г+ода!",
		"Вин+о со мн+ожеством нагр+ад!",
		"М+аксимум алког+оля!",
		"Мужч+ины л+юбят п+иво.",
		"Тост: «За прогр+есс!»"
	)

	refill_canister = /obj/item/vending_refill/boozeomat

/obj/machinery/vending/boozeomat/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Booze-O-Mat",
		GENITIVE = "торгового автомата Booze-O-Mat",
		DATIVE = "торговому автомату Booze-O-Mat",
		ACCUSATIVE = "торговый автомат Booze-O-Mat",
		INSTRUMENTAL = "торговым автоматом Booze-O-Mat",
		PREPOSITIONAL = "торговом автомате Booze-O-Mat"
	)

/obj/machinery/vending/boozeomat/syndicate_access
	req_access = list(ACCESS_SYNDICATE)
