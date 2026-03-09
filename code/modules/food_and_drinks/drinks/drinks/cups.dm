// MARK: Coffee cups
/obj/item/reagent_containers/food/drinks/cups/coffee_cup
	name = ""
	desc = ""
	max_integrity = 20
	var/has_cup = FALSE
	var/cap_on = FALSE

/obj/item/reagent_containers/food/drinks/cups/coffee_cup/examine(mob/user)
	. = ..()
	. += span_notice("Вмещает до <b>[volume]</b> единиц[declension_ru(volume, "ы", "", "")] вещества.")

/obj/item/reagent_containers/food/drinks/cups/coffee_cup/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/food/drinks/cups/coffee_cup/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader, "cups")

// MARK: Coffee cup
/obj/item/reagent_containers/food/drinks/cups/coffee_cup/normal
	name = "coffee cup"
	desc = "Удобный бумажный стакан со снимающейся крышкой. Предназначен для питья кофе."
	icon_state = "coffeecup"
	base_icon_state = "coffeecup"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10,25,50)
	has_cup = TRUE

/obj/item/reagent_containers/food/drinks/cups/coffee_cup/normal/get_ru_names()
	return list(
		NOMINATIVE = "стакан кофе",
		GENITIVE = "стакана кофе",
		DATIVE = "стакану кофе",
		ACCUSATIVE = "стакан кофе",
		INSTRUMENTAL = "стаканом кофе",
		PREPOSITIONAL = "стакане кофе"
	)

#define COFFEE_CUP_EXAMINE_RANGE 2

/obj/item/reagent_containers/food/drinks/cups/coffee_cup/normal/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= COFFEE_CUP_EXAMINE_RANGE && cap_on)
		. += span_boldnotice("Крышка надета.")

#undef COFFEE_CUP_EXAMINE_RANGE

/obj/item/reagent_containers/food/drinks/cups/coffee_cup/normal/update_icon_state()
	. = ..()
	if(cap_on)
		icon_state = "[base_icon_state]_lid"
	else
		icon_state = "[base_icon_state]"

/obj/item/reagent_containers/food/drinks/cups/coffee_cup/normal/update_overlays()
	. = ..()
	underlays.Cut()
	if(icon_state == "[base_icon_state]_lid")
		return
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', "[base_icon_state]")
		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(40 to 55)
				filling.icon_state = "[base_icon_state]55"
			if(55 to 70)
				filling.icon_state = "[base_icon_state]70"
			if(70 to 85)
				filling.icon_state = "[base_icon_state]85"
			if(85 to INFINITY)
				filling.icon_state = "[base_icon_state]100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling

/obj/item/reagent_containers/food/drinks/cups/coffee_cup/normal/attack_self(mob/user)
	if(!has_cup)
		return

	cap_on = !cap_on
	user.balloon_alert(user, "крышка [cap_on ? "надета" : "снята"]")
	update_icon()

// MARK: Small coffee cup
/obj/item/reagent_containers/food/drinks/cups/coffee_cup/small
	name = "small coffee cup"
	desc = "Небольшой бумажный стакан. Обычно в таких подают кофе. Далеко не самый удобный."
	icon_state = "coffeecup_small"
	base_icon_state = "coffeecup_small"
	possible_transfer_amounts = list(10,30)
	volume = 30

/obj/item/reagent_containers/food/drinks/cups/coffee_cup/small/get_ru_names()
	return list(
		NOMINATIVE = "стаканчик кофе",
		GENITIVE = "стаканчика кофе",
		DATIVE = "стаканчику кофе",
		ACCUSATIVE = "стаканчик кофе",
		INSTRUMENTAL = "стаканчиком кофе",
		PREPOSITIONAL = "стаканчике кофе"
	)

/obj/item/reagent_containers/food/drinks/cups/coffee_cup/small/update_overlays()
	. = ..()
	underlays.Cut()
	if(!reagents.total_volume)
		return

	var/image/filling = image('icons/obj/reagentfillings.dmi', "[base_icon_state]")
	var/percent = round((reagents.total_volume / volume) * 100)
	switch(percent)
		if(20 to 40)
			filling.icon_state = "[base_icon_state]40"
		if(40 to 60)
			filling.icon_state = "[base_icon_state]60"
		if(60 to 80)
			filling.icon_state = "[base_icon_state]80"
		if(80 to INFINITY)
			filling.icon_state = "[base_icon_state]100"

	filling.icon += mix_color_from_reagents(reagents.reagent_list)
	. += filling

/obj/item/reagent_containers/food/drinks/cups/coffee_cup/small/coffee
	list_reagents = list("coffee" = 30)
