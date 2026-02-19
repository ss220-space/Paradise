/obj/machinery/vending/coffee
	name = "Solar's Best Hot Drinks"
	desc = "Это машина, которая готовит горячие напитки. Ну, знаете, такие, которые кипятком заливают."
	slogan_list = list(
		"В+ыпейте!",
		"В+ыпьем!",
		"На здор+овье!",
		"Не хот+ите гор+ячего с+упчику?",
		"Я бы убил за ч+ашечку к+офе!",
		"Л+учшие з+ёрна в гал+актике.",
		"Для вас — т+олько л+учшие нап+итки.",
		"М-м-м-м… Ничт+о не сравн+ится с к+офе.",
		"Я любл+ю к+офе, а вы?",
		"К+офе помог+ает раб+отать!",
		"Возьм+ите немн+ого чайк+у.",
		"Над+еемся, вы предпочит+аете л+учшее!",
		"Отв+едайте н+аш н+овый шокол+ад!"
	)
	icon_state = "coffee_off"
	panel_overlay = "coffee_panel"
	screen_overlay = "coffee"
	lightmask_overlay = "coffee_lightmask"
	broken_overlay = "coffee_broken"
	broken_lightmask_overlay = "coffee_broken_lightmask"
	vend_overlay = "coffee_vend"
	vend_lightmask = "coffee_vend_lightmask"
	refill_canister = /obj/item/vending_refill/coffee
	default_price = PAYCHECK_MIN * 0.7
	default_premium_price = PAYCHECK_LOWER * 0.7

	item_slot = TRUE
	products = list(
		/obj/item/reagent_containers/food/drinks/coffee = 25,
		/obj/item/reagent_containers/food/drinks/tea = 25,
		/obj/item/reagent_containers/food/drinks/h_chocolate = 25,
		/obj/item/reagent_containers/food/drinks/chocolate = 10,
		/obj/item/reagent_containers/food/drinks/chicken_soup = 10,
		/obj/item/reagent_containers/food/drinks/weightloss = 10,
		/obj/item/reagent_containers/food/drinks/mug = 15,
		/obj/item/reagent_containers/food/drinks/mug/novelty = 5,
	)
	contraband = list(
		/obj/item/reagent_containers/food/drinks/ice = 10,
	)

/obj/machinery/vending/coffee/get_ru_names()
	return list(
		NOMINATIVE = "торговый автомат Solar's Best Hot Drinks",
		GENITIVE = "торгового автомата Solar's Best Hot Drinks",
		DATIVE = "торговому автомату Solar's Best Hot Drinks",
		ACCUSATIVE = "торговый автомат Solar's Best Hot Drinks",
		INSTRUMENTAL = "торговым автоматом Solar's Best Hot Drinks",
		PREPOSITIONAL = "торговом автомате Solar's Best Hot Drinks",
	)

/obj/machinery/vending/coffee/item_slot_check(mob/user, obj/item/I)
	if(!(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks)))
		return FALSE
	if(!..())
		return FALSE
	if(!I.is_open_container())
		balloon_alert(user, "контейнер закрыт!")
		return FALSE
	return TRUE

/obj/machinery/vending/coffee/do_vend(datum/data/vending_product/product_record, mob/user)
	if(..())
		return
	var/obj/item/reagent_containers/food/drinks/vended = new product_record.product_path()

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
