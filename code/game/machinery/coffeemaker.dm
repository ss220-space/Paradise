// Radial menu stuff
#define RADIAL_MENU_BREW "Варка кофе"
#define RADIAL_MENU_EJECT_POT "Извлечь кофейник"
#define RADIAL_MENU_EJECT_CARTRIDGE "Извлечь картридж"

// MARK: Base coffeemaker
/obj/machinery/coffeemaker
	name = "coffeemaker"
	desc = "Нет, эту кофемашину вы ТОЧНО не должны были увидеть. Пожалуйста, сообщите о баге."
	gender = FEMALE
	icon = 'icons/obj/machines/coffee_maker.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF
	pixel_y = 8 // needed to make it sit nicely on tables
	density = TRUE
	pass_flags = PASSTABLE
	anchored = TRUE

	/// The coffee pot currently in the machine
	var/obj/item/reagent_containers/glass/coffeepot/coffeepot
	/// Whether the machine is currently brewing
	var/brewing = FALSE
	/// Time required to brew coffee
	var/brew_time = 20 SECONDS
	/// Brewing speed multiplier from parts
	var/speed = 1
	/// Whether this machine uses cartridges instead of beans
	var/uses_cartridges = FALSE
	/// The coffee cartridge to make coffee from
	var/obj/item/coffee_cartridge/cartridge
	/// Associative list of resource datums [resource_id] = datum
	var/list/resources = list()
	/// Current amount of coffee beans stored
	var/coffee_amount = 0
	/// Maximum amount of coffee beans that can be stored
	var/max_coffee_amount = 10
	/// List of coffee bean objects stored
	var/list/coffee = list()

/obj/machinery/coffeemaker/Destroy()
	QDEL_NULL(coffeepot)
	QDEL_NULL(cartridge)
	QDEL_LIST_ASSOC_VAL(resources)
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
		. += "[span_boldnotice("Дисплей сообщает:")]\n" + span_notice("- Скорость варки — <b>[speed * 100]</b>%.")
		if(coffeepot?.reagents.total_volume)
			. += span_notice("- [coffeepot.declent_ru(NOMINATIVE)] содержит <b>[coffeepot.reagents.total_volume]</b> единиц[declension_ru(coffeepot.reagents.total_volume, "у", "ы", "")] вещества.")
		if(cartridge)
			if(cartridge.charges < 1)
				. += span_notice("- Картридж <b>пуст</b>.")
			else
				. += span_notice("- Картриджа хватит ещё на <b>[cartridge.charges]</b> использовани[declension_ru(cartridge.charges, "е", "я", "й")].")
	else
		. += span_boldwarning("Дисплей не работает!")

	// Display resource information
	for(var/resource_id in resources)
		var/datum/coffeemaker_resource/resource = resources[resource_id]
		. += resource.get_examine_string()

	if(!uses_cartridges)
		if(length(coffee))
			. += span_notice("Отсек для зёрен содержит <b>[length(coffee)]</b> порци[declension_ru(length(coffee), "ю", "и", "й")] кофе.")
		else
			. += span_notice("Отсек для зёрен <b>пуст</b>.")

/obj/machinery/coffeemaker/attackby(obj/item/attack_item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(SEND_SIGNAL(attack_item, COMSIG_ITEM_ATTACKED_BY_COFFEEMAKER, src, user) & COMSIG_ITEM_COFFEEMAKER_ACCEPTED)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	// Handle coffeepot separately (not a resource)
	if(istype(attack_item, /obj/item/reagent_containers/glass/coffeepot) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		handle_coffeepot_insertion(user, attack_item)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/machinery/coffeemaker/update_overlays()
	. = ..()
	. += overlay_checks()

/obj/machinery/coffeemaker/proc/overlay_checks()
	return

/obj/machinery/coffeemaker/proc/handle_item_replacement(mob/living/user, obj/inserting_item, item_slot, replacing_message, inserting_message, ejecting_message)
	if(!user)
		return FALSE
	if(item_slot && inserting_item)
		user.put_in_hands(item_slot)
		item_slot = inserting_item
		balloon_alert(user, replacing_message)
	else if(!item_slot && inserting_item)
		item_slot = inserting_item
		balloon_alert(user, inserting_message)
	else if(item_slot && !inserting_item)
		user.put_in_hands(item_slot)
		item_slot = null
		balloon_alert(user, ejecting_message)
	update_appearance(UPDATE_OVERLAYS)
	return item_slot

/obj/machinery/coffeemaker/proc/replace_pot(mob/living/user, obj/item/reagent_containers/glass/coffeepot/new_coffeepot)
	coffeepot = handle_item_replacement(user, new_coffeepot, coffeepot, "кофейник заменён", "кофейник вставлен", "кофейник извлечён")

/obj/machinery/coffeemaker/proc/replace_cartridge(mob/living/user, obj/item/coffee_cartridge/new_cartridge)
	cartridge = handle_item_replacement(user, new_cartridge, cartridge, "картридж заменён", "картридж вставлен", "картридж извлечён")

/obj/machinery/coffeemaker/proc/try_brew(mob/living/user)
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
	if(user.incapacitated() || !user.Adjacent(src))
		return
	if(brewing)
		balloon_alert(user, "в процессе варки!")
		return
	return TRUE

/obj/machinery/coffeemaker/proc/choice_processing(mob/user, selected_choice)
	switch(selected_choice)
		if(RADIAL_MENU_BREW)
			brew(user)
		if(RADIAL_MENU_EJECT_POT)
			eject_pot(user)
		if(RADIAL_MENU_EJECT_CARTRIDGE)
			eject_cartridge(user)
		else
			// Handle resource extraction for dynamically added options
			for(var/resource_id in resources)
				var/datum/coffeemaker_resource/resource = resources[resource_id]
				if(resource.radial_name == selected_choice)
					resource.take_resource(user, src)
					return

/obj/machinery/coffeemaker/proc/radial_menu(mob/user)
	var/list/radial_menu_choices = list()

	// Always available brewing option
	radial_menu_choices[RADIAL_MENU_BREW] = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_brew")

	// Special actions based on machine state
	if(coffeepot)
		radial_menu_choices[RADIAL_MENU_EJECT_POT] = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject_pot")
	if(cartridge)
		radial_menu_choices[RADIAL_MENU_EJECT_CARTRIDGE] = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject_cartridge")

	// Dynamically add options for available resources
	for(var/resource_id in resources)
		var/datum/coffeemaker_resource/resource = resources[resource_id]
		if(resource.can_take(user))
			radial_menu_choices[resource.radial_name] = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_take_[resource_id]")

	var/selected_choice = show_radial_menu(user, src, radial_menu_choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user))
	choice_processing(user, selected_choice)

/obj/machinery/coffeemaker/proc/eject_pot(mob/user)
	if(coffeepot)
		replace_pot(user)

/obj/machinery/coffeemaker/proc/eject_cartridge(mob/user)
	if(cartridge)
		replace_cartridge(user)

/obj/machinery/coffeemaker/proc/handle_coffeepot_insertion(mob/user, inserting_item)
	if(panel_open)
		balloon_alert(user, "техпанель открыта!")
		return ATTACK_CHAIN_PROCEED

	var/obj/item/reagent_containers/glass/coffeepot/new_pot = inserting_item
	. = ATTACK_CHAIN_PROCEED

	if(!user.transfer_item_to_loc(new_pot, src))
		return ATTACK_CHAIN_PROCEED

	replace_pot(user, new_pot)
	update_appearance(UPDATE_OVERLAYS)

/// Updates the smoke state to something else, setting particles if relevant
/obj/machinery/coffeemaker/proc/toggle_steam()
	return

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
	return

/obj/machinery/coffeemaker/crowbar_act(mob/user, obj/item/item)
	if(default_deconstruction_crowbar(user, item))
		return TRUE

/obj/machinery/coffeemaker/screwdriver_act(mob/user, obj/item/item)
	if(coffeepot)
		balloon_alert(user, "уберите кофейник!")
		return FALSE
	if(cartridge)
		balloon_alert(user, "уберите картридж!")
		return FALSE
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, item))
		return TRUE

// MARK: Standard coffeemaker
/obj/machinery/coffeemaker/standard
	name = "coffeemaker \"Modello 3\""
	desc = "Кофемашина модели \"Моделло 3\" — устройство для приготовления кофе при температуре в 80°C. \
			Кофейные зёрна загружаются в виде специальных картриджей. Машина оборудована слотами для сахара, аспартама и сливок, \
			а также стойкой для бумажных стаканов. Произведено компанией \"Бытовая Техника Пиччонайя\"."
	icon_state = "coffeemaker_nopot_nocart"
	base_icon_state = "coffeemaker"
	coffee = null
	uses_cartridges = TRUE

/obj/machinery/coffeemaker/standard/get_ru_names()
	return list(
		NOMINATIVE = "кофемашина \"Моделло 3\"",
		GENITIVE = "кофемашины \"Моделло 3\"",
		DATIVE = "кофемашине \"Моделло 3\"",
		ACCUSATIVE = "кофемашину \"Моделло 3\"",
		INSTRUMENTAL = "кофемашиной \"Моделло 3\"",
		PREPOSITIONAL = "кофемашине \"Моделло 3\""
	)

/obj/machinery/coffeemaker/standard/Initialize(mapload)
	. = ..()

	// Initialize resources
	resources["cups"] = new /datum/coffeemaker_resource/cups/small()
	resources["sugar"] = new /datum/coffeemaker_resource/sugar()
	resources["aspartame"] = new /datum/coffeemaker_resource/aspartame()
	resources["creamer"] = new /datum/coffeemaker_resource/creamer()

	if(mapload)
		coffeepot = new /obj/item/reagent_containers/glass/coffeepot(src)
		cartridge = new /obj/item/coffee_cartridge(src)

	component_parts = list()
	component_parts += new /obj/item/circuitboard/coffeemaker/standard(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/standard/overlay_checks()
	. = list()
	if(coffeepot)
		. += "coffeemaker_pot_[coffeepot.reagents.total_volume ? "full" : "empty"]"
	if(cartridge)
		. += "coffeemaker_cartidge"
	return .

/obj/machinery/coffeemaker/standard/attackby(obj/item/attack_item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(SEND_SIGNAL(attack_item, COMSIG_ITEM_ATTACKED_BY_COFFEEMAKER, src, user) & COMSIG_ITEM_COFFEEMAKER_ACCEPTED)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/reagent_containers/glass/coffeepot) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		handle_coffeepot_insertion(user, attack_item)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/machinery/coffeemaker/standard/try_brew(mob/living/user)
	if(!cartridge)
		balloon_alert(user, "картридж отсутствует!")
		return FALSE
	if(cartridge.charges < 1)
		balloon_alert(user, "картридж пуст!")
		return FALSE
	return ..()

/obj/machinery/coffeemaker/standard/toggle_steam()
	QDEL_NULL(particles)
	if(brewing)
		particles = new /particles/smoke/steam/mild()
		particles.position = list(-6, 0, 0)

/obj/machinery/coffeemaker/standard/brew(mob/user)
	power_change()
	if(!try_brew(user))
		return
	balloon_alert_to_viewers("варка кофе...")
	operate_for(brew_time)
	coffeepot.reagents.add_reagent_list(cartridge.drink_type)
	cartridge.charges--
	update_appearance(UPDATE_OVERLAYS)

// Coffee Cartridges: like toner, but for your coffee!
/obj/item/coffee_cartridge
	name = "coffeemaker cartridge – Caffè Generico"
	desc = "Картридж, содержащий перемолотые кофейные зёрна. \
			Совместим с кофемашиной \"Моделло 3\". \
			Произведён компанией \"Бытовая Техника Пиччонайя\"."
	gender = MALE
	icon = 'icons/obj/food/cartridges.dmi'
	icon_state = "cartridge_basic"
	w_class = WEIGHT_CLASS_SMALL
	var/charges = 4
	var/list/drink_type = list("coffee" = 150)

/obj/item/coffee_cartridge/get_ru_names()
	return list(
		NOMINATIVE = "кофейный картридж \"Каффе Дженерико\"",
		GENITIVE = "кофейного картриджа \"Каффе Дженерико\"",
		DATIVE = "кофейному картриджу \"Каффе Дженерико\"",
		ACCUSATIVE = "кофейный картридж \"Каффе Дженерико\"",
		INSTRUMENTAL = "кофейным картриджем \"Каффе Дженерико\"",
		PREPOSITIONAL = "кофейном картридже \"Каффе Дженерико\""
	)

/obj/item/coffee_cartridge/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader)

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
	icon_state = "cartridge_blend"

/obj/item/coffee_cartridge/fancy/get_ru_names()
	return list(
		NOMINATIVE = "премиальный кофе-картридж \"Каффе Фантазиосо\"",
		GENITIVE = "премиального кофе-картриджа \"Каффе Фантазиосо\"",
		DATIVE = "премиальному кофе-картриджу \"Каффе Фантазиосо\"",
		ACCUSATIVE = "премиальный кофе-картридж \"Каффе Фантазиосо\"",
		INSTRUMENTAL = "премиальным кофе-картриджем \"Каффе Фантазиосо\"",
		PREPOSITIONAL = "премиальном кофе-картридже \"Каффе Фантазиосо\"",
	)

/obj/item/coffee_cartridge/fancy/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader)

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
	icon_state = "cartridge_decaf"

/obj/item/coffee_cartridge/decaf/get_ru_names()
	return list(
		NOMINATIVE = "кофе-картридж \"Каффе Декаффинато\"",
		GENITIVE = "кофе-картриджа \"Каффе Декаффинато\"",
		DATIVE = "кофе-картриджу \"Каффе Декаффинато\"",
		ACCUSATIVE = "кофе-картридж \"Каффе Декаффинато\"",
		INSTRUMENTAL = "кофе-картриджем \"Каффе Декаффинато\"",
		PREPOSITIONAL = "кофе-картридже \"Каффе Декаффинато\""
	)

/obj/item/coffee_cartridge/decaf/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader)

// no you can't just squeeze the juice bag into a glass!
/obj/item/coffee_cartridge/bootleg
	name = "coffeemaker cartridge – Botany Blend"
	desc = "Самодельный картридж, содержащий перемолотые кофейные зёрна. \
			Теоретически совместим с кофемашиной \"Моделло 3\", \
			но никто этого не гарантирует."
	icon_state = "cartridge_bootleg"

/obj/item/coffee_cartridge/bootleg/get_ru_names()
	return list(
		NOMINATIVE = "кофе-картридж \"Ботанический специальный\"",
		GENITIVE = "кофе-картриджа \"Ботанический специальный\"",
		DATIVE = "кофе-картриджу \"Ботанический специальный\"",
		ACCUSATIVE = "кофе-картридж \"Ботанический специальный\"",
		INSTRUMENTAL = "кофе-картриджем \"Ботанический специальный\"",
		PREPOSITIONAL = "кофе-картридже \"Ботанический специальный\""
	)

/obj/item/coffee_cartridge/bootleg/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/coffeemaker_item_loader)

// blank cartridge for crafting's sake, can be made at the service lathe
/obj/item/blank_coffee_cartridge
	name = "blank coffee cartridge"
	desc = "Пустой картридж для перемолотых кофейных зёрен. \
			Совместим с кофемашиной \"Моделло 3\"."
	gender = MALE
	icon = 'icons/obj/food/cartridges.dmi'
	icon_state = "cartridge_blank"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/blank_coffee_cartridge/get_ru_names()
	return list(
		NOMINATIVE = "пустой кофе-картридж",
		GENITIVE = "пустого кофе-картриджа",
		DATIVE = "пустому кофе-картриджу",
		ACCUSATIVE = "пустой кофе-картридж",
		INSTRUMENTAL = "пустым кофе-картриджем",
		PREPOSITIONAL = "пустом кофе-картридже"
	)

// MARK: Impressa coffeemaker
/obj/machinery/coffeemaker/impressa
	name = "coffeemaker \"Impressa Modello 5\""
	desc = "Кофемашина промышленного класса модели \"Импресса Моделло 5\" — устройство для приготовления кофе при температуре в 80°C. \
			В отличие от стандартных моделей, не использует предварительно упакованные картриджи, а работает непосредственно с цельными зёрнами кофе. \
			Такие пользуются спросом в кофейнях по всей Галактике. Произведено компанией \"Бытовая Техника Пиччонайя\"."
	icon_state = "coffeemaker_impressa"
	pixel_x = 2 //needed to make it sit nicely on tables
	brew_time = 15 SECONDS //industrial grade, its faster than the regular one

/obj/machinery/coffeemaker/impressa/get_ru_names()
	return list(
		NOMINATIVE = "кофемашина \"Импресса Моделло 5\"",
		GENITIVE = "кофемашины \"Импресса Моделло 5\"",
		DATIVE = "кофемашине \"Импресса Моделло 5\"",
		ACCUSATIVE = "кофемашину \"Импресса Моделло 5\"",
		INSTRUMENTAL = "кофемашиной \"Импресса Моделло 5\"",
		PREPOSITIONAL = "кофемашине \"Импресса Моделло 5\""
	)

/obj/machinery/coffeemaker/impressa/Initialize(mapload)
	. = ..()

	// Initialize resources
	resources["cups"] = new /datum/coffeemaker_resource/cups/normal()
	resources["sugar"] = new /datum/coffeemaker_resource/sugar()
	resources["aspartame"] = new /datum/coffeemaker_resource/aspartame()
	resources["creamer"] = new /datum/coffeemaker_resource/creamer()

	if(mapload)
		coffeepot = new /obj/item/reagent_containers/glass/coffeepot(src)
		cartridge = null

	component_parts = list()
	component_parts += new /obj/item/circuitboard/coffeemaker/impressa(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor/adv(null)
	component_parts += new /obj/item/stock_parts/micro_laser/high(null)
	component_parts += new /obj/item/stock_parts/micro_laser/high(null)
	RefreshParts()
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/impressa/overlay_checks()
	. = list()
	if(coffeepot)
		. += "pot_[coffeepot.reagents.total_volume ? "full" : "empty"]"

	var/datum/coffeemaker_resource/cups_resource = resources["cups"]
	if(cups_resource?.current_amount > 0)
		if(cups_resource.current_amount > cups_resource.max_amount / 1.5)
			. += "cups_3"
		else if(cups_resource.current_amount > cups_resource.max_amount / 3)
			. += "cups_2"
		else
			. += "cups_1"

	var/datum/coffeemaker_resource/sugar_resource = resources["sugar"]
	if(sugar_resource?.current_amount > 0)
		. += "extras_1"

	var/datum/coffeemaker_resource/creamer_resource = resources["creamer"]
	if(creamer_resource?.current_amount > 0)
		. += "extras_2"

	var/datum/coffeemaker_resource/aspartame_resource = resources["aspartame"]
	if(aspartame_resource?.current_amount > 0)
		. += "extras_3"

	if(coffee_amount)
		if(coffee_amount < 0.7 * max_coffee_amount)
			. += "grinder_half"
		else
			. += "grinder_full"
	return .

/obj/machinery/coffeemaker/impressa/Exited(atom/movable/gone, direction)
	. = ..()
	if(!(gone in coffee))
		return
	coffee -= gone
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/coffeemaker/impressa/attackby(obj/item/attack_item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(SEND_SIGNAL(attack_item, COMSIG_ITEM_ATTACKED_BY_COFFEEMAKER, src, user) & COMSIG_ITEM_COFFEEMAKER_ACCEPTED)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(attack_item, /obj/item/reagent_containers/glass/coffeepot) && !(attack_item.item_flags & ABSTRACT) && attack_item.is_open_container())
		handle_coffeepot_insertion(user, attack_item)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/machinery/coffeemaker/impressa/try_brew(mob/living/user)
	if(coffee_amount <= 0)
		balloon_alert(user, "зёрна отсутствуют!")
		return FALSE
	return ..()

/obj/machinery/coffeemaker/impressa/toggle_steam()
	QDEL_NULL(particles)
	if(!brewing)
		return
	particles = new /particles/smoke/steam/mild()
	particles.position = list(-2, 1, 0)

/obj/machinery/coffeemaker/impressa/brew(mob/user)
	power_change()
	if(!try_brew(user))
		return
	balloon_alert_to_viewers("варка кофе...")
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
		if(!(reference_bean_reagents.Find(substance.name))) // we only add the reagent if it's a non-standard for coffee beans
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

#undef RADIAL_MENU_BREW
#undef RADIAL_MENU_EJECT_POT
#undef RADIAL_MENU_EJECT_CARTRIDGE
