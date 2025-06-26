// Amount of coffee beans that can fit inside the impressa coffeemaker
#define BEAN_CAPACITY 10

// Radial menu stuff
#define RADIAL_MENU_BREW 				"Варка"
#define RADIAL_MENU_EJECT_POT 			"Извлечь кофейник"
#define RADIAL_MENU_EJECT_CARTRIDGE 	"Извлечь картридж"
#define RADIAL_MENU_TAKE_CUP 			"Взять стакан"
#define RADIAL_MENU_TAKE_SUGAR 			"Взять сахар"
#define RADIAL_MENU_TAKE_SWEETENER 		"Взять подсластитель"
#define RADIAL_MENU_TAKE_CREAMER 		"Взять сливки"

/obj/machinery/coffeemaker
	name = "coffeemaker \"Modello 3\""
	desc = "Кофемашина модели \"Моделло 3\" — устройство для приготовления кофе при температуре в 80°C. \
			Кофейные зёрна загружаются в виде специальных картриджей. Машина оборудована слотами для сахара, подсластителей и сливок, \
			а также стойкой для бумажных стаканов. Произведено компанией \"Бытовая Техника Пиччонайя\"."
	ru_names = list(
		NOMINATIVE = "кофемашина \"Моделло 3\"",
		GENITIVE = "кофемашины \"Моделло 3\"",
		DATIVE = "кофемашине \"Моделло 3\"",
		ACCUSATIVE = "кофемашину \"Моделло 3\"",
		INSTRUMENTAL = "кофемашиной \"Моделло 3\"",
		PREPOSITIONAL = "кофемашине \"Моделло 3\""
	)
	anchored = TRUE
	gender = FEMALE
	icon = 'icons/obj/machines/coffee_maker.dmi'
	icon_state = "coffeemaker_nopot_nocart"
	base_icon_state = "coffeemaker"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	pixel_y = 4 //needed to make it sit nicely on tables
	density = TRUE
	pass_flags = PASSTABLE
	var/obj/item/reagent_containers/glass/coffeepot/coffeepot = null
	var/brewing = FALSE
	var/brew_time = 20 SECONDS
	var/speed = 1
	/// The coffee cartridge to make coffee from. In the future, coffee grounds are like printer ink.
	var/obj/item/coffee_cartridge/cartridge = null
	/// The type path to instantiate for the coffee cartridge the device initially comes with, eg. /obj/item/coffee_cartridge
	var/initial_cartridge = /obj/item/coffee_cartridge
	/// The number of cups left
	var/coffee_cups = 15
	var/max_coffee_cups = 15
	/// The amount of sugar packets left
	var/sugar_packs = 10
	var/max_sugar_packs = 10
	/// The amount of sweetener packets left
	var/sweetener_packs = 10
	var/max_sweetener_packs = 10
	/// The amount of creamer packets left
	var/creamer_packs = 10
	var/max_creamer_packs = 10

	var/static/radial_examine = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_examine")
	var/static/radial_brew = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_brew")
	var/static/radial_eject_pot = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject_pot")
	var/static/radial_eject_cartridge = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject_cartridge")
	var/static/radial_take_cup = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_take_cup")
	var/static/radial_take_sugar = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_take_sugar")
	var/static/radial_take_sweetener = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_take_sweetener")
	var/static/radial_take_creamer = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_take_creamer")

/obj/machinery/coffeemaker/Initialize(mapload)
	. = ..()
	if(mapload)
		coffeepot = new /obj/item/reagent_containers/glass/coffeepot(src)
		cartridge = new /obj/item/coffee_cartridge(src)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/coffeemaker(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/coffeemaker/Destroy()
	QDEL_NULL(coffeepot)
	QDEL_NULL(cartridge)
	return ..()

/obj/machinery/coffeemaker/Exited(atom/movable/departed, atom/newLoc)
	. = ..()
	if(departed == coffeepot)
		coffeepot = null
		update_appearance(UPDATE_OVERLAYS)
	if(departed == cartridge)
		cartridge = null
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/RefreshParts()
	speed = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		speed += laser.rating

/obj/machinery/coffeemaker/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_boldwarning("Отсюда не получается разглядеть дисплей и содержимое!")
		return

	if(brewing)
		. += span_boldwarning("В процессе варки.")

	if(panel_open)
		. += span_boldnotice("Панель техобслуживания открыта.")

	if(coffeepot || cartridge)
		. += span_boldnotice("Содержимое:")
		if(coffeepot)
			. += span_notice("- [capitalize(coffeepot.declent_ru(NOMINATIVE))].")
		if(cartridge)
			. += span_notice("- [capitalize(cartridge.declent_ru(NOMINATIVE))].")

	if(!(stat & (NOPOWER|BROKEN)))
		. += "[span_boldnotice("Дисплей сообщает:")]\n"+\
		span_notice("- Скорость варки – <b>[speed*100]</b>%.")
		if(coffeepot)
			for(var/datum/reagent/consumable/cawfee as anything in coffeepot.reagents.reagent_list)
				. += span_notice("- [coffeepot.declent_ru(NOMINATIVE)] содержит <b>[cawfee.volume]</b> единиц[declension_ru(cawfee.volume, "у", "ы", "")] вещества.")
		if(cartridge)
			if(cartridge.charges < 1)
				. += span_notice("- картридж <b>пуст</b>.")
			else
				. += span_notice("- картриджа хватит ещё на <b>[cartridge.charges]</b> использовани[declension_ru(cartridge.charges, "е", "я", "й")].")
	else
		. += span_boldwarning("Дислей не работает!")

	if(coffee_cups >= 1)
		. += span_notice("Отсек для стаканов содержит <b>[coffee_cups]</b> стакан[declension_ru(coffee_cups, "", "а", "ов")].")
	else
		. += span_notice("Отсек для стаканов <b>пуст</b>.")

	if(sugar_packs >= 1)
		. += span_notice("Отсек для сахара содержит <b>[sugar_packs]</b> пакетик[declension_ru(sugar_packs, "", "а", "ов")].")
	else
		. += span_notice("Отсек для сахара <b>пуст</b>.")

	if(sweetener_packs >= 1)
		. += span_notice("Отсек для подсластителей содержит <b>[sweetener_packs]</b> пакетик[declension_ru(sweetener_packs, "", "а", "ов")].")
	else
		. += span_notice("Отсек для подсластителей <b>пуст</b>.")

	if(creamer_packs > 1)
		. += span_notice("Отсек для сливок содержит <b>[creamer_packs]</b> пакетик[declension_ru(creamer_packs, "", "а", "ов")].")
	else
		. += span_notice("Отсек для сливок <b>пуст</b>.")


/obj/machinery/coffeemaker/update_overlays()
	. = ..()
	. += overlay_checks()

/obj/machinery/coffeemaker/proc/overlay_checks()
	. = list()
	if(coffeepot)
		. += "coffeemaker_pot_[coffeepot.reagents.total_volume ? "full" : "empty"]"
	if(cartridge)
		. += "coffeemaker_cartidge"
	return .

/obj/machinery/coffeemaker/proc/replace_pot(mob/living/user, obj/item/reagent_containers/glass/coffeepot/new_coffeepot)
	if(!user)
		return FALSE
	if(coffeepot && new_coffeepot)
		user.put_in_hands(coffeepot)
		coffeepot = new_coffeepot
		balloon_alert(user, "кофейник заменён")
	else if(!coffeepot && new_coffeepot)
		coffeepot = new_coffeepot
		balloon_alert(user, "кофейник вставлен")
	else if(coffeepot && !new_coffeepot)
		user.put_in_hands(coffeepot)
		balloon_alert(user, "кофейник извлечён")
	update_appearance(UPDATE_OVERLAYS)
	return TRUE


/obj/machinery/coffeemaker/proc/replace_cartridge(mob/living/user, obj/item/coffee_cartridge/new_cartridge)
	if(!user)
		return FALSE
	if(cartridge && new_cartridge)
		user.put_in_hands(cartridge)
		cartridge = new_cartridge
		balloon_alert(user, "картридж заменён")
	else if(!cartridge && new_cartridge)
		cartridge = new_cartridge
		balloon_alert(user, "картридж вставлен")
	else if(cartridge && !new_cartridge)
		user.put_in_hands(cartridge)
		balloon_alert(user, "картридж извлечён")
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/machinery/coffeemaker/attackby(obj/item/attack_item, mob/living/user, list/modifiers, list/attack_modifiers)
	//You can only screw open empty grinder
	if(!coffeepot && default_deconstruction_screwdriver(user, icon_state, icon_state, attack_item))
		return ATTACK_CHAIN_PROCEED

	if(panel_open) //Can't insert objects when its screwed open
		return ATTACK_CHAIN_PROCEED

	if(istype(attack_item, /obj/item/reagent_containers/glass/coffeepot) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		var/obj/item/reagent_containers/glass/coffeepot/new_pot = attack_item
		. = ATTACK_CHAIN_PROCEED
		if(!user.transfer_item_to_loc(new_pot, src))
			return ATTACK_CHAIN_PROCEED
		replace_pot(user, new_pot)
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/reagent_containers/food/drinks/coffee_cup) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		var/obj/item/reagent_containers/food/drinks/coffee_cup/new_cup = attack_item
		if(new_cup.reagents.total_volume > 0)
			balloon_alert(user, "стакан не пуст!")
			return
		if(coffee_cups >= max_coffee_cups)
			balloon_alert(user, "отсек для стаканов полон!")
			return
		if(!user.transfer_item_to_loc(attack_item, src))
			return
		balloon_alert(user, "стакан вставлен")
		coffee_cups++
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/reagent_containers/food/condiment/pack/sugar))
		var/obj/item/reagent_containers/food/condiment/pack/sugar/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пакетик не полон!")
			return
		if(sugar_packs >= max_sugar_packs)
			balloon_alert(user, "отсек для сахара полон")
			return
		if(!user.transfer_item_to_loc(attack_item, src))
			return
		balloon_alert(user, "пакетик вставлен")
		sugar_packs++
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/reagent_containers/food/condiment/pack/creamer))
		var/obj/item/reagent_containers/food/condiment/pack/creamer/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пакетик не полон!")
			return
		if(creamer_packs >= max_creamer_packs)
			balloon_alert(user, "отсек для сливок полон!")
			return
		if(!user.transfer_item_to_loc(attack_item, src))
			return
		balloon_alert(user, "пакетик вставлен")
		creamer_packs++
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/reagent_containers/food/condiment/pack/aspartame))
		var/obj/item/reagent_containers/food/condiment/pack/aspartame/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пакетик не полон!")
			return
		else if(sweetener_packs >= max_sweetener_packs)
			balloon_alert(user, "отсек для подсластителей полон")
			return
		else if(!user.transfer_item_to_loc(attack_item, src))
			return
		balloon_alert(user, "пакетик вставлен")
		sweetener_packs++
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/coffee_cartridge) && !(attack_item.item_flags & ABSTRACT))
		var/obj/item/coffee_cartridge/new_cartridge = attack_item
		if(!user.transfer_item_to_loc(new_cartridge, src))
			return
		replace_cartridge(user, new_cartridge)
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/machinery/coffeemaker/proc/try_brew()
	var/mob/user = usr
	if(!cartridge)
		balloon_alert(user, "картридж отсутствует!")
		return FALSE
	if(cartridge.charges < 1)
		balloon_alert(user, "картридж пуст!")
		return FALSE
	if(!coffeepot)
		balloon_alert(user, "кофейник отсутствует!")
		return FALSE
	if(stat & (NOPOWER|BROKEN))
		balloon_alert(user, "не работает!")
		return FALSE
	if(coffeepot.reagents.total_volume >= coffeepot.reagents.maximum_volume)
		balloon_alert(user, "кофейник полон!")
		return FALSE
	return TRUE

/obj/machinery/coffeemaker/attack_hand(mob/user)
	. = ..()
	radial_menu(user)

/obj/machinery/coffeemaker/proc/check_menu(mob/living/user)
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	if(brewing)
		return
	return TRUE

/obj/machinery/coffeemaker/proc/radial_menu(mob/user)
	var/list/choices = list(
		RADIAL_MENU_BREW = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_brew"),
		RADIAL_MENU_EJECT_POT = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject_pot"),
		RADIAL_MENU_EJECT_CARTRIDGE = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject_cartridge"),
		RADIAL_MENU_TAKE_CUP = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_take_cup"),
		RADIAL_MENU_TAKE_SUGAR = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_take_sugar"),
		RADIAL_MENU_TAKE_SWEETENER = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_take_sweetener"),
		RADIAL_MENU_TAKE_CREAMER = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_take_creamer")
	)

	var/selected_choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user))

	switch(selected_choice)
		if(RADIAL_MENU_BREW)
			brew(user)
		if(RADIAL_MENU_EJECT_POT)
			eject_pot(user)
		if(RADIAL_MENU_EJECT_CARTRIDGE)
			eject_cartridge(user)
		if(RADIAL_MENU_TAKE_CUP)
			take_cup(user)
		if(RADIAL_MENU_TAKE_SUGAR)
			take_sugar(user)
		if(RADIAL_MENU_TAKE_SWEETENER)
			take_sweetener(user)
		if(RADIAL_MENU_TAKE_CREAMER)
			take_creamer(user)
		else
			return //Either nothing was selected, or an invalid mode was selected

/obj/machinery/coffeemaker/proc/eject_pot(mob/user)
	if(coffeepot)
		replace_pot(user)

/obj/machinery/coffeemaker/proc/eject_cartridge(mob/user)
	if(cartridge)
		replace_cartridge(user)

/obj/machinery/coffeemaker/proc/take_cup(mob/user)
	if(!coffee_cups) //shouldn't happen, but we all know how stuff manages to break
		balloon_alert(user, "стаканы отсутствуют!")
		return
	balloon_alert(user, "стакан взят")
	var/obj/item/reagent_containers/food/drinks/coffee_cup/new_cup = new(get_turf(src))
	user.put_in_hands(new_cup)
	coffee_cups--
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/proc/take_sugar(mob/user)
	if(!sugar_packs)
		balloon_alert(user, "сахар отсутствует!")
		return
	balloon_alert(user, "сахар взят")
	var/obj/item/reagent_containers/food/condiment/pack/sugar/new_pack = new(get_turf(src))
	user.put_in_hands(new_pack)
	sugar_packs--
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/proc/take_sweetener(mob/user)
	if(!sweetener_packs)
		balloon_alert(user, "подсластитель отсутствует!")
		return
	balloon_alert(user, "подсластитель взят")
	var/obj/item/reagent_containers/food/condiment/pack/aspartame/new_pack = new(get_turf(src))
	user.put_in_hands(new_pack)
	sweetener_packs--
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/proc/take_creamer(mob/user)
	if(!creamer_packs)
		balloon_alert(user, "сливки отсутствуют!")
		return
	balloon_alert(user, "сливки взяты")
	var/obj/item/reagent_containers/food/condiment/pack/creamer/new_pack = new(get_turf(src))
	user.put_in_hands(new_pack)
	creamer_packs--
	update_appearance(UPDATE_OVERLAYS)

///Updates the smoke state to something else, setting particles if relevant
/obj/machinery/coffeemaker/proc/toggle_steam()
	QDEL_NULL(particles)
	if(brewing)
		particles = new /particles/smoke/steam/mild()
		particles.position = list(-6, 0, 0)

/obj/machinery/coffeemaker/proc/operate_for(time, silent = FALSE)
	brewing = TRUE
	if(!silent)
		playsound(src, 'sound/machines/coffeemaker_brew.ogg', 20, vary = TRUE)
	toggle_steam()
	use_power(active_power_usage * time / (1 SECONDS)) // .1 needed here to convert time (in deciseconds) to seconds such that watts * seconds = joules
	addtimer(CALLBACK(src, PROC_REF(stop_operating)), time / speed)

/obj/machinery/coffeemaker/proc/stop_operating()
	brewing = FALSE
	toggle_steam()

/obj/machinery/coffeemaker/proc/brew(mob/user)
	power_change()
	if(!try_brew())
		return
	balloon_alert(user, "варка кофе...")
	operate_for(brew_time)
	coffeepot.reagents.add_reagent_list(cartridge.drink_type)
	cartridge.charges--
	update_appearance(UPDATE_OVERLAYS)

//Coffee Cartridges: like toner, but for your coffee!
/obj/item/coffee_cartridge
	name = "coffeemaker cartridge – Caffè Generico"
	desc = "Картридж, содержащий перемолотые кофейные зёрна. \
			Совместим с кофемашиной \"Моделло 3\". \
			Произведён компанией \"Бытовая Техника Пиччонайя\"."
	ru_names = list(
		NOMINATIVE = "кофейный картридж \"Каффе Дженерико\"",
		GENITIVE = "кофейного картриджа \"Каффе Дженерико\"",
		DATIVE = "кофейному картриджу \"Каффе Дженерико\"",
		ACCUSATIVE = "кофейный картридж \"Каффе Дженерико\"",
		INSTRUMENTAL = "кофейным картриджем \"Каффе Дженерико\"",
		PREPOSITIONAL = "кофейном картридже \"Каффе Дженерико\""
	)
	gender = MALE
	icon = 'icons/obj/food/cartridges.dmi'
	icon_state = "cartridge_basic"
	w_class = WEIGHT_CLASS_SMALL
	var/charges = 4
	var/list/drink_type = list("coffee" = 150)

/obj/item/coffee_cartridge/examine(mob/user)
	. = ..()
	if(charges)
		. += span_notice("Хватит ещё на <b>[charges]</b> использовани[declension_ru(charges, "е", "я", "й")].")
	else
		. += span_notice("<b>Пусто</b>.")

/obj/item/coffee_cartridge/fancy
	name = "coffeemaker cartridge – Caffè Fantasioso"
	desc = "Преимального качества картридж, содержащий перемолотые кофейные зёрна. \
			Совместим с кофемашиной \"Моделло 3\". \
			Произведён компанией \"Бытовая Техника Пиччонайя\"."
	ru_names = list(
		NOMINATIVE = "премиальный кофе-картридж \"Каффе Фантазиосо\"",
		GENITIVE = "премиального кофе-картриджа \"Каффе Фантазиосо\"",
		DATIVE = "премиальному кофе-картриджу \"Каффе Фантазиосо\"",
		ACCUSATIVE = "премиальный кофе-картридж \"Каффе Фантазиосо\"",
		INSTRUMENTAL = "премиальным кофе-картриджем \"Каффе Фантазиосо\"",
		PREPOSITIONAL = "премиальном кофе-картридже \"Каффе Фантазиосо\""
	)
	icon_state = "cartridge_blend"

// Yep, same reagent for every cartridge – that's intentional
/obj/item/coffee_cartridge/fancy/Initialize(mapload)
	. = ..()
	var/coffee_type = pick("blend", "blue_mountain", "kilimanjaro", "mocha")
	switch(coffee_type)
		if("blend")
			name = "coffeemaker cartridge – Miscela di Piccione"
			ru_names = list(
				NOMINATIVE = "премиальный кофе-картридж \"Миццела Де Пиччионе\"",
				GENITIVE = "премиального кофе-картриджа \"Миццела Де Пиччионе\"",
				DATIVE = "премиальному кофе-картриджу \"Миццела Де Пиччионе\"",
				ACCUSATIVE = "премиальный кофе-картридж \"Миццела Де Пиччионе\"",
				INSTRUMENTAL = "премиальным кофе-картриджем \"Миццела Де Пиччионе\"",
				PREPOSITIONAL = "премиальном кофе-картридже \"Миццела Де Пиччионе\""
			)
			icon_state = "cartridge_blend"
		if("blue_mountain")
			name = "coffeemaker cartridge – Montagna Blu"
			ru_names = list(
				NOMINATIVE = "премиальный кофе-картридж \"Монтанна Блю\"",
				GENITIVE = "премиального кофе-картриджа \"Монтанна Блю\"",
				DATIVE = "премиальному кофе-картриджу \"Монтанна Блю\"",
				ACCUSATIVE = "премиальный кофе-картридж \"Монтанна Блю\"",
				INSTRUMENTAL = "премиальным кофе-картриджем \"Монтанна Блю\"",
				PREPOSITIONAL = "премиальном кофе-картридже \"Монтанна Блю\""
			)
			icon_state = "cartridge_blue_mtn"
		if("kilimanjaro")
			name = "coffeemaker cartridge – Kilimangiaro"
			ru_names = list(
				NOMINATIVE = "премиальный кофе-картридж \"Килиманджаро\"",
				GENITIVE = "премиального кофе-картриджа \"Килиманджаро\"",
				DATIVE = "премиальному кофе-картриджу \"Килиманджаро\"",
				ACCUSATIVE = "премиальный кофе-картридж \"Килиманджаро\"",
				INSTRUMENTAL = "премиальным кофе-картриджем \"Килиманджаро\"",
				PREPOSITIONAL = "премиальном кофе-картридже \"Килиманджаро\""
			)
			icon_state = "cartridge_kilimanjaro"
		if("mocha")
			name = "coffeemaker cartridge – Moka Arabica"
			ru_names = list(
				NOMINATIVE = "премиальный кофе-картридж \"Моккачино Арабика\"",
				GENITIVE = "премиального кофе-картриджа \"Моккачино Арабика\"",
				DATIVE = "премиальному кофе-картриджу \"Моккачино Арабика\"",
				ACCUSATIVE = "премиальный кофе-картридж \"Моккачино Арабика\"",
				INSTRUMENTAL = "премиальным кофе-картриджем \"Моккачино Арабика\"",
				PREPOSITIONAL = "премиальном кофе-картридже \"Моккачино Арабика\""
			)
			icon_state = "cartridge_mocha"

/obj/item/coffee_cartridge/decaf
	name = "coffeemaker cartridge – Caffè Decaffeinato"
	desc = "Картридж, содержащий перемолотые кофейные зёрна, \
			из которых был искусственно удалён кофеин. \
			Совместим с кофемашиной \"Моделло 3\". \
			Произведён компанией \"Бытовая Техника Пиччонайя\"."
	ru_names = list(
		NOMINATIVE = "кофе-картридж \"Каффе Декаффинато\"",
		GENITIVE = "кофе-картриджа \"Каффе Декаффинато\"",
		DATIVE = "кофе-картриджу \"Каффе Декаффинато\"",
		ACCUSATIVE = "кофе-картридж \"Каффе Декаффинато\"",
		INSTRUMENTAL = "кофе-картриджем \"Каффе Декаффинато\"",
		PREPOSITIONAL = "кофе-картридже \"Каффе Декаффинато\""
	)
	icon_state = "cartridge_decaf"

// no you can't just squeeze the juice bag into a glass!
/obj/item/coffee_cartridge/bootleg
	name = "coffeemaker cartridge – Botany Blend"
	desc = "Самодельный картридж, содержащий перемолотые кофейные зёрна. \
			Теоретически совместим с кофемашиной \"Моделло 3\", \
			но никто этого не гарантирует."
	ru_names = list(
		NOMINATIVE = "кофе-картридж \"Ботанический специальный\"",
		GENITIVE = "кофе-картриджа \"Ботанический специальный\"",
		DATIVE = "кофе-картриджу \"Ботанический специальный\"",
		ACCUSATIVE = "кофе-картридж \"Ботанический специальный\"",
		INSTRUMENTAL = "кофе-картриджем \"Ботанический специальный\"",
		PREPOSITIONAL = "кофе-картридже \"Ботанический специальный\""
	)
	icon_state = "cartridge_bootleg"

// blank cartridge for crafting's sake, can be made at the service lathe
/obj/item/blank_coffee_cartridge
	name = "blank coffee cartridge"
	desc = "Пустой картридж для перемолотых кофейных зёрен. \
			Совместим с кофемашиной \"Моделло 3\"."
	ru_names = list(
		NOMINATIVE = "пустой кофе-картридж",
		GENITIVE = "пустого кофе-картриджа",
		DATIVE = "пустому кофе-картриджу",
		ACCUSATIVE = "пустой кофе-картридж",
		INSTRUMENTAL = "пустым кофе-картриджем",
		PREPOSITIONAL = "пустом кофе-картридже"
	)
	gender = MALE
	icon = 'icons/obj/food/cartridges.dmi'
	icon_state = "cartridge_blank"
	w_class = WEIGHT_CLASS_SMALL

/*
 * impressa coffee maker
 * its supposed to be a premium line product, so its cargo-only, the board cant be therefore researched
 */

/obj/machinery/coffeemaker/impressa
	name = "coffeemaker \"Impressa Modello 5\""
	desc = "Кофемашина промышленного класса модели \"Импресса Моделло 5\" — устройство для приготовления кофе при температуре в 80°C. \
			В отличие от стандартных моделей, не использует предварительно упакованные картриджи, а работает непосредственно с цельными зёрнами кофе. \
			Такие пользуются спросом в кофейнях по всей Галактике. Произведено компанией \"Бытовая Техника Пиччонайя\"."
	ru_names = list(
		NOMINATIVE = "кофемашина \"Импресса Моделло 5\"",
		GENITIVE = "кофемашины \"Импресса Моделло 5\"",
		DATIVE = "кофемашине \"Импресса Моделло 5\"",
		ACCUSATIVE = "кофемашину \"Импресса Моделло 5\"",
		INSTRUMENTAL = "кофемашиной \"Импресса Моделло 5\"",
		PREPOSITIONAL = "кофемашине \"Импресса Моделло 5\""
	)
	icon_state = "coffeemaker_impressa"
	initial_cartridge = null //no cartridge, just coffee beans
	/// Current amount of coffee beans stored
	var/coffee_amount = 0
	/// List of coffee bean objects are stored
	var/list/coffee = list()

/obj/machinery/coffeemaker/impressa/Initialize(mapload)
	. = ..()
	if(mapload)
		coffeepot = new /obj/item/reagent_containers/glass/coffeepot(src)
		cartridge = null

/obj/machinery/coffeemaker/impressa/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/coffeemaker/impressa(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor/adv(null)
	component_parts += new /obj/item/stock_parts/micro_laser/high(null)
	component_parts += new /obj/item/stock_parts/micro_laser/high(null)
	RefreshParts()

/obj/machinery/coffeemaker/impressa/Destroy()
	QDEL_NULL(coffeepot)
	QDEL_NULL(cartridge)
	return ..()

/obj/machinery/coffeemaker/impressa/examine(mob/user)
	. = ..()
	if(coffee)
		. += span_notice("Отсек для зёрен содержит <b>[length(coffee)]</b> порци[declension_ru(length(coffee), "ю", "и", "й")] кофе.")

/obj/machinery/coffeemaker/impressa/update_overlays()
	. = ..()
	. += overlay_checks()

/obj/machinery/coffeemaker/impressa/overlay_checks()
	. = list()
	if(coffeepot)
		. += "pot_[coffeepot.reagents.total_volume ? "full" : "empty"]"
	if(coffee_cups > 0)
		if(coffee_cups >= max_coffee_cups/3)
			if(coffee_cups > max_coffee_cups/1.5)
				. += "cups_3"
			else
				. += "cups_2"
		else
			. += "cups_1"
	if(sugar_packs)
		. += "extras_1"
	if(creamer_packs)
		. += "extras_2"
	if(sweetener_packs)
		. += "extras_3"
	if(coffee_amount)
		if(coffee_amount < 0.7*BEAN_CAPACITY)
			. += "grinder_half"
		else
			. += "grinder_full"
	return .

/obj/machinery/coffeemaker/impressa/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone in coffee)
		coffee -= gone
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/impressa/try_brew()
	var/mob/user = usr
	if(coffee_amount <= 0)
		balloon_alert(user, "зёрна отсутствуют!")
		return FALSE
	if(!coffeepot)
		balloon_alert(user, "кофейник отсутствует!")
		return FALSE
	if(stat & (NOPOWER|BROKEN) )
		balloon_alert(user, "не работает!")
		return FALSE
	if(coffeepot.reagents.total_volume >= coffeepot.reagents.maximum_volume)
		balloon_alert(user, "кофейник полон!")
		return FALSE
	return TRUE

/obj/machinery/coffeemaker/impressa/attackby(obj/item/attack_item, mob/living/user, list/modifiers, list/attack_modifiers)
	//You can only screw open empty grinder
	if(!coffeepot && default_deconstruction_screwdriver(user, icon_state, icon_state, attack_item))
		return ATTACK_CHAIN_PROCEED

	if(panel_open) //Can't insert objects when its screwed open
		return ATTACK_CHAIN_PROCEED

	if(istype(attack_item, /obj/item/reagent_containers/glass/coffeepot) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		var/obj/item/reagent_containers/glass/coffeepot/new_pot = attack_item
		if(!user.transfer_item_to_loc(new_pot, src))
			return ATTACK_CHAIN_PROCEED
		replace_pot(user, new_pot)
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/reagent_containers/food/drinks/coffee) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		var/obj/item/reagent_containers/food/drinks/coffee/new_cup = attack_item //different type of cup
		if(new_cup.reagents.total_volume > 0 )
			balloon_alert(user, "стакан не пуст!")
			return ATTACK_CHAIN_PROCEED
		if(coffee_cups >= max_coffee_cups)
			balloon_alert(user, "отсек для стаканов полон!")
			return ATTACK_CHAIN_PROCEED
		if(!user.transfer_item_to_loc(attack_item, src))
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "стакан вставлен")
		coffee_cups++
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/reagent_containers/food/condiment/pack/sugar))
		var/obj/item/reagent_containers/food/condiment/pack/sugar/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пакетик не полон!")
			return ATTACK_CHAIN_PROCEED
		if(sugar_packs >= max_sugar_packs)
			balloon_alert(user, "отсек для сахара полон!")
			return ATTACK_CHAIN_PROCEED
		if(!user.transfer_item_to_loc(attack_item, src))
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "пакетик вставлен")
		sugar_packs++
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/reagent_containers/food/condiment/pack/creamer))
		var/obj/item/reagent_containers/food/condiment/pack/creamer/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пакетик не полон!")
			return ATTACK_CHAIN_PROCEED
		if(creamer_packs >= max_creamer_packs)
			balloon_alert(user, "отсек для сливок полон!")
			return ATTACK_CHAIN_PROCEED
		if(!user.transfer_item_to_loc(attack_item, src))
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "пакетик вставлен")
		creamer_packs++
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/reagent_containers/food/condiment/pack/aspartame))
		var/obj/item/reagent_containers/food/condiment/pack/aspartame/new_pack = attack_item
		if(new_pack.reagents.total_volume < new_pack.reagents.maximum_volume)
			balloon_alert(user, "пакетик не полон!")
			return ATTACK_CHAIN_PROCEED
		if(sweetener_packs >= max_sweetener_packs)
			balloon_alert(user, "отсек для подсластителей полон!")
			return ATTACK_CHAIN_PROCEED
		if(!user.transfer_item_to_loc(attack_item, src))
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "пакетик вставлен")
		sweetener_packs++
		update_appearance(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/reagent_containers/food/snacks/grown/coffee) && !(attack_item.item_flags & ABSTRACT))
		var/obj/item/reagent_containers/food/snacks/grown/coffee/new_coffee_grounds = attack_item
		if(coffee_amount >= BEAN_CAPACITY)
			balloon_alert(user, "отсек для зёрен полон!")
			return ATTACK_CHAIN_PROCEED
		if(!new_coffee_grounds.dry)
			balloon_alert(user, "зёрна не высушены!")
			return ATTACK_CHAIN_PROCEED
		var/obj/item/reagent_containers/food/snacks/grown/coffee/new_coffee = attack_item
		if(!user.transfer_item_to_loc(new_coffee, src))
			return ATTACK_CHAIN_PROCEED
		coffee += new_coffee
		balloon_alert(user, "зёрна добавлены")
		coffee_amount++


	if(istype(attack_item, /obj/item/storage/box/coffeepack))
		if(coffee_amount >= BEAN_CAPACITY)
			balloon_alert(user, "отсек для зёрен полон!")
			return ATTACK_CHAIN_PROCEED
		var/obj/item/storage/box/coffeepack/new_coffee_pack = attack_item
		for(var/obj/item/reagent_containers/food/snacks/grown/coffee/new_coffee in new_coffee_pack.contents)
			if(new_coffee.dry) //the coffee beans inside must be dry
				if(coffee_amount < BEAN_CAPACITY)
					if(user.transfer_item_to_loc(new_coffee, src))
						coffee += new_coffee
						balloon_alert(user, "зёрна добавлены")
						coffee_amount++
						new_coffee.forceMove(src)
						update_appearance(UPDATE_OVERLAYS)
					else
						return ATTACK_CHAIN_PROCEED
				else
					return ATTACK_CHAIN_PROCEED
			else
				balloon_alert(user, "невысушенные зёрна внутри!")
				return ATTACK_CHAIN_PROCEED

	update_appearance(UPDATE_OVERLAYS)
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/machinery/coffeemaker/impressa/take_cup(mob/user)
	if(!coffee_cups) //shouldn't happen, but we all know how stuff manages to break
		balloon_alert(user, "стаканы отсутствуют!")
		return
	balloon_alert(user, "стакан взят")
	var/obj/item/reagent_containers/food/drinks/coffee/no_lid/new_cup = new(get_turf(src))
	user.put_in_hands(new_cup)
	coffee_cups--
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/impressa/toggle_steam()
	QDEL_NULL(particles)
	if(brewing)
		particles = new /particles/smoke/steam/mild()
		particles.position = list(-2, 1, 0)

/obj/machinery/coffeemaker/impressa/brew(mob/user)
	power_change()
	if(!try_brew())
		return
	balloon_alert(user, "варка кофе...")
	operate_for(brew_time)

	// create a reference bean reagent list
	var/list/reference_bean_reagents = list()
	var/obj/item/reagent_containers/food/snacks/grown/coffee/reference_bean = new /obj/item/reagent_containers/food/snacks/grown/coffee(src)
	for(var/datum/reagent/ref_bean_reagent as anything in reference_bean.reagents.reagent_list)
		reference_bean_reagents += ref_bean_reagent.name

	// add all the reagents from the coffee beans to the coffeepot (ommit the ones from the reference bean)
	var/list/reagent_delta = list()
	var/obj/item/reagent_containers/food/snacks/grown/coffee/bean = coffee[coffee_amount]
	for(var/datum/reagent/substance as anything in bean.reagents.reagent_list)
		if(!(reference_bean_reagents.Find(substance.name)))	// we only add the reagent if it's a non-standard for coffee beans
			reagent_delta += list(substance.type = substance.volume)
	coffeepot.reagents.add_reagent_list(reagent_delta)

	qdel(reference_bean)

	// remove the coffee beans from the machine
	coffee.Cut(1,2)
	coffee_amount--

	// fill the rest of the pot with coffee
	if(coffeepot.reagents.total_volume < 150)
		var/extra_coffee_amount = 150 - coffeepot.reagents.total_volume
		coffeepot.reagents.add_reagent("coffee", extra_coffee_amount)

	update_appearance(UPDATE_OVERLAYS)

#undef BEAN_CAPACITY
