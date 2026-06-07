/**
 * Base datum for all coffeemaker resources
 */
/datum/coffeemaker_resource
	/// Unique identifier for the resource
	var/id
	/// Name of resource
	var/resource_name
	/// Current amount of the resource
	var/current_amount = 0
	/// Maximum capacity for this resource
	var/max_amount = 0
	/// Icon state for radial menu
	var/icon_state = null
	/// Type of item to create when taking
	var/item_type
	/// Display name for radial menu
	var/radial_name
	/// The name of the resource in the compartment
	var/section_name

/datum/coffeemaker_resource/New()
	. = ..()
	if(!item_type)
		CRASH("Coffeemaker resource [type] created without 'item_type'.")

/**
 * Check if resource can be taken
 *
 * Arguments:
 * * user - The mob attempting to take the resource
 */
/datum/coffeemaker_resource/proc/can_take(mob/user)
	return current_amount > 0

/**
 * Take one unit of the resource from the machine
 *
 * Arguments:
 * * user - The mob taking the resource
 * * machine - The coffeemaker machine
 */
/datum/coffeemaker_resource/proc/take_resource(mob/user, obj/machinery/coffeemaker/machine)
	if(!can_take(user))
		machine.balloon_alert(user, "[resource_name] отсутствует!")
		return FALSE

	var/obj/new_item = new item_type(get_turf(machine))
	user.put_in_hands(new_item)
	current_amount--
	machine.balloon_alert(user, "[resource_name] взят")
	machine.update_appearance(UPDATE_OVERLAYS)
	return TRUE

/**
 * Check if an item can be inserted as this resource
 *
 * Arguments:
 * * inserting_item - The item being inserted
 * * user - The mob inserting the item
 */
/datum/coffeemaker_resource/proc/can_insert(obj/item/inserting_item, mob/user)
	return istype(inserting_item, item_type)

/**
 * Insert an item as this resource
 *
 * Arguments:
 * * inserting_item - The item being inserted
 * * user - The mob inserting the item
 * * machine - The coffeemaker machine
 */
/datum/coffeemaker_resource/proc/insert_resource(obj/item/inserting_item, mob/user, obj/machinery/coffeemaker/machine)
	if(current_amount >= max_amount)
		machine.balloon_alert(user, "отсек полон!")
		return COMSIG_ITEM_COFFEEMAKER_REJECTED

	if(!user.transfer_item_to_loc(inserting_item, machine))
		return COMSIG_ITEM_COFFEEMAKER_REJECTED

	current_amount++
	machine.balloon_alert(user, "[resource_name] вставлен")
	machine.update_appearance(UPDATE_OVERLAYS)
	return COMSIG_ITEM_COFFEEMAKER_ACCEPTED

/// Get examine string for this resource
/datum/coffeemaker_resource/proc/get_examine_string()
	if(current_amount >= 1)
		return span_notice("Отсек для [section_name] содержит <b>[current_amount]</b> предмет[DECL_CREDIT(current_amount)].")
	else
		return span_notice("Отсек для [section_name] <b>пуст</b>.")

// MARK: Small Coffee Cup
/datum/coffeemaker_resource/cups/small
	id = "cup"
	current_amount = 15
	max_amount = 15
	icon_state = "cup"
	item_type = /obj/item/reagent_containers/food/drinks/cups/coffee_cup/small
	radial_name = "Взять стакан"
	resource_name = "стакан"
	section_name = "стаканов"

/datum/coffeemaker_resource/cups/small/can_insert(obj/item/inserting_item, mob/user)
	return ..() && inserting_item.is_open_container()

/datum/coffeemaker_resource/cups/small/insert_resource(obj/item/inserting_item, mob/user, obj/machinery/coffeemaker/machine)
	if(inserting_item.reagents.total_volume > 0)
		machine.balloon_alert(user, "стакан не пуст!")
		return COMSIG_ITEM_COFFEEMAKER_REJECTED
	return ..()

// MARK: Normal Coffee Cup
/datum/coffeemaker_resource/cups/normal
	id = "cup"
	current_amount = 15
	max_amount = 15
	icon_state = "cup"
	item_type = /obj/item/reagent_containers/food/drinks/cups/coffee_cup/normal
	radial_name = "Взять стаканчик"
	resource_name = "стаканчик"
	section_name = "стаканчиков"

/datum/coffeemaker_resource/cups/normal/can_insert(obj/item/inserting_item, mob/user)
	return ..() && inserting_item.is_open_container()

/datum/coffeemaker_resource/cups/normal/insert_resource(obj/item/inserting_item, mob/user, obj/machinery/coffeemaker/machine)
	if(inserting_item.reagents.total_volume > 0)
		machine.balloon_alert(user, "стаканчик не пуст!")
		return COMSIG_ITEM_COFFEEMAKER_REJECTED
	return ..()

// MARK: Sugar
/datum/coffeemaker_resource/sugar
	id = "sugar"
	current_amount = 10
	max_amount = 10
	icon_state = "sugar"
	item_type = /obj/item/reagent_containers/food/condiment/pack/sugar
	radial_name = "Взять сахар"
	resource_name = "пакетик сахара"
	section_name = "сахара"

// MARK: Aspartame
/datum/coffeemaker_resource/aspartame
	id = "aspartame"
	current_amount = 10
	max_amount = 10
	icon_state = "aspartame"
	item_type = /obj/item/reagent_containers/food/condiment/pack/aspartame
	radial_name = "Взять аспартам"
	resource_name = "пакетик аспартама"
	section_name = "аспартама"

// MARK: Creamer
/datum/coffeemaker_resource/creamer
	id = "creamer"
	current_amount = 10
	max_amount = 10
	icon_state = "creamer"
	item_type = /obj/item/reagent_containers/food/condiment/pack/creamer
	radial_name = "Взять сливки"
	resource_name = "пакетик сливок"
	section_name = "сливок"
