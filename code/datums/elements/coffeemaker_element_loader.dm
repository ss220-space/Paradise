#define MODE_RESOURCE "resource"
#define MODE_CARTRIDGE "cartridge"
#define MODE_BEAN "bean"

/**
 * Universal element for loading items into coffeemakers
 * Supports three modes:
 * 1. RESOURCE: items that go into resource compartments (sugar, aspartame, creamer, cups)
 * 2. CARTRIDGE: coffee cartridges for standard coffeemakers
 * 3. BEAN: coffee beans for impressa coffeemakers (single beans or boxes)
 */
/datum/element/coffeemaker_item_loader
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// Resource identifier for RESOURCE mode (e.g., "sugar", "cups")
	var/resource_id

/datum/element/coffeemaker_item_loader/Attach(datum/target, resource_id = null)
	. = ..()

	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.resource_id = resource_id

	RegisterSignal(target, COMSIG_ITEM_ATTACKED_BY_COFFEEMAKER, PROC_REF(handle_coffeemaker_attack), override = TRUE)

/datum/element/coffeemaker_item_loader/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ITEM_ATTACKED_BY_COFFEEMAKER)
	return ..()

/datum/element/coffeemaker_item_loader/proc/handle_coffeemaker_attack(obj/item/source, obj/machinery/coffeemaker/machine, mob/user)
	SIGNAL_HANDLER

	if(machine.panel_open)
		machine.balloon_alert(user, "техпанель открыта!")
		return

	// Determine mode based on current item and arguments
	if(resource_id)
		return handle_resource(source, machine, user)
	if(istype(source, /obj/item/coffee_cartridge))
		return handle_cartridge(source, machine, user)
	if(istype(source, /obj/item/reagent_containers/food/snacks/grown/coffee) || istype(source, /obj/item/storage/box/coffeepack))
		return handle_bean(source, machine, user)

/datum/element/coffeemaker_item_loader/proc/handle_resource(obj/item/source, obj/machinery/coffeemaker/machine, mob/user)
	if(!machine.resources)
		return

	var/datum/coffeemaker_resource/resource = machine.resources[resource_id]
	if(!resource)
		return

	if(!resource.can_insert(source, user))
		return

	return resource.insert_resource(source, user, machine)

/datum/element/coffeemaker_item_loader/proc/handle_cartridge(obj/item/source, obj/machinery/coffeemaker/machine, mob/user)
	if(!machine.uses_cartridges)
		return

	var/obj/item/coffee_cartridge/new_cartridge = source
	if(!user.transfer_item_to_loc(new_cartridge, machine))
		return

	machine.replace_cartridge(user, new_cartridge)
	machine.update_appearance(UPDATE_OVERLAYS)
	return COMSIG_ITEM_COFFEEMAKER_ACCEPTED

/datum/element/coffeemaker_item_loader/proc/handle_bean(obj/item/source, obj/machinery/coffeemaker/machine, mob/user)
	if(machine.uses_cartridges)
		return

	// Single coffee bean
	if(istype(source, /obj/item/reagent_containers/food/snacks/grown/coffee))
		var/obj/item/reagent_containers/food/snacks/grown/coffee/new_coffee = source

		if(machine.coffee_amount >= machine.max_coffee_amount)
			machine.balloon_alert(user, "отсек для зёрен полон!")
			return COMSIG_ITEM_COFFEEMAKER_REJECTED

		if(!new_coffee.dry)
			machine.balloon_alert(user, "зёрна не высушены!")
			return COMSIG_ITEM_COFFEEMAKER_REJECTED

		if(!user.transfer_item_to_loc(new_coffee, machine))
			return

		machine.coffee += new_coffee
		machine.balloon_alert(user, "зёрна добавлены")
		machine.coffee_amount++
		machine.update_appearance(UPDATE_OVERLAYS)
		return COMSIG_ITEM_COFFEEMAKER_ACCEPTED

	// Box of coffee beans
	else if(istype(source, /obj/item/storage/box/coffeepack))
		var/obj/item/storage/box/coffeepack/new_coffee_pack = source

		if(machine.coffee_amount >= machine.max_coffee_amount)
			machine.balloon_alert(user, "отсек для зёрен полон!")
			return COMSIG_ITEM_COFFEEMAKER_REJECTED

		if(!length(new_coffee_pack.contents))
			machine.balloon_alert(user, "пакет пуст!")
			return COMSIG_ITEM_COFFEEMAKER_REJECTED

		var/coffee_added = FALSE
		for(var/obj/item/reagent_containers/food/snacks/grown/coffee/new_coffee in new_coffee_pack.contents)
			if(!new_coffee.dry)
				machine.balloon_alert(user, "невысушенные зёрна внутри!")
				return COMSIG_ITEM_COFFEEMAKER_REJECTED
			if(!user.transfer_item_to_loc(new_coffee, machine))
				return
			machine.coffee += new_coffee
			coffee_added = TRUE
			machine.coffee_amount++
			new_coffee.forceMove(machine)

		if(coffee_added)
			machine.balloon_alert(user, "зёрна добавлены")

		machine.update_appearance(UPDATE_OVERLAYS)
		return COMSIG_ITEM_COFFEEMAKER_ACCEPTED

#undef MODE_RESOURCE
#undef MODE_CARTRIDGE
#undef MODE_BEAN
