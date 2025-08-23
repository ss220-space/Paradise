/**
 * Crafting blueprints
 * Item for crafting items
 */
/obj/item/craft_blueprints
	name = "crafting blueprints"
	desc = "Чертежи для крафта"
	icon = 'icons/obj/craft_blueprints.dmi'
	icon_state = "blueprint"
	var/place_icon = "put_blueprint"
	w_class = WEIGHT_CLASS_NORMAL

	/// Placing state
	var/placed_on_table = FALSE
	/// Crafting item name
	var/crafting_name = "none"
	/// Crafting item path
	var/crafting_item = null
	/// Required tools for craft
	var/list/tools = list()
	/// Required components for craft
	var/list/components = list()
	/// Crafting duration
	var/craft_duration = 3 SECONDS
	/// Copy in printer type, if null - can not copy
	var/obj/item/craft_blueprints/copy_type = /obj/item/craft_blueprints/copy
	/// Requred toner in percent
	var/required_toner = 10


/obj/item/craft_blueprints/copy
	icon_state = "whiteprint"
	place_icon = "put_whiteprint"
	copy_type = null


/obj/item/craft_blueprints/Initialize(mapload)
	. = ..()
	update_desc()
	RegisterSignal(src, COMSIG_ITEM_PLACED_ON_TABLE, PROC_REF(on_table_place))


/obj/item/craft_blueprints/Destroy()
	. = ..()
	UnregisterSignal(COMSIG_ITEM_PLACED_ON_TABLE)


/obj/item/craft_blueprints/update_desc(updates)
	. = ..()
	desc = "[initial(desc)] \"[crafting_name]\""


/obj/item/craft_blueprints/examine(mob/user)
	update_desc()
	. = ..()
	if(length(tools))
		var/required_tools_text = "Требуемые инструменты: "
		for(var/tool as anything in tools)
			required_tools_text += "[tool] "
		. += span_notice(required_tools_text)
	if(length(components))
		var/required_components_text = "Вещи для крафта: "
		for(var/component in components)
			var/need_amount = components[component]
			var/atom/atom_comp = component
			required_components_text += "[need_amount] [initial(atom_comp.name)] "
		. += span_notice(required_components_text)


/obj/item/craft_blueprints/proc/on_table_place(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, span_notice("Вы разворачиваете [declent_ru(NOMINATIVE)] на столе."))
	placed_on_table = TRUE
	icon_state = place_icon
	pixel_x = 0
	pixel_y = 0
	layer = LOW_ITEM_LAYER


/obj/item/craft_blueprints/update_icon(updates)
	. = ..()
	icon_state = placed_on_table ? place_icon : initial(icon_state)


/obj/item/craft_blueprints/attack_hand(mob/user, pickupfireoverride)
	if(placed_on_table)
		try_craft_item(user)
		return FALSE
	. = ..()


/obj/item/craft_blueprints/attackby(obj/item/item, mob/user, params)
	if(!placed_on_table)
		return ..()
	if(user.a_intent == INTENT_HARM || (item.item_flags & ABSTRACT) || item.is_robot_module())
		return ..()
	if(!user.transfer_item_to_loc(item, loc))
		return ..()
	. = ATTACK_CHAIN_BLOCKED_ALL
	add_fingerprint(user)
	var/list/click_params = params2list(params)
	if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
		return .
	//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
	item.pixel_x = clamp(text2num(click_params["icon-x"]) - (ICON_SIZE_X / 2), - (ICON_SIZE_X / 2), ICON_SIZE_X / 2)
	item.pixel_y = clamp(text2num(click_params["icon-y"]) - (ICON_SIZE_Y / 2), - (ICON_SIZE_Y / 2), ICON_SIZE_Y / 2)


/obj/item/craft_blueprints/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(over_object != usr || !ishuman(usr) || !usr.Adjacent(src))
		return ..()
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		to_chat(usr, span_warning("Вы не можете этого сделать сейчас!"))
		return FALSE
	var/mob/living/human = usr
	to_chat(usr, span_notice("Вы сворачиваете [declent_ru(NOMINATIVE)] со стола."))
	placed_on_table = FALSE
	layer = initial(layer)
	update_icon()
	human.put_in_any_hand_if_possible(src, drop_on_fail = TRUE)
	return FALSE



// MARK: Crafting mechanic
// TODO обещаю отрефакторить попозже c:

/obj/item/craft_blueprints/proc/try_craft_item(mob/user)
	var/list/surroundings = get_surroundings(user)
	if(!check_tools(user, surroundings))
		balloon_alert(user, "не хватает инструментов")
		return
	if(!check_contents(surroundings))
		balloon_alert(user, "не хватает компонентов")
		return
	to_chat(user, span_notice("Вы начинаете крафт предмета \"[crafting_name]\"..."))
	if(!do_after(user, craft_duration, src))
		return
	surroundings = get_surroundings(user)
	if(!check_tools(user, surroundings))
		balloon_alert(user, "не хватает инструментов")
		return
	if(!check_contents(surroundings))
		balloon_alert(user, "не хватает компонентов")
		return
	requirements_deletion(user)
	var/item = new crafting_item(loc)
	to_chat(user, span_notice("Вы заканчиваете крафт предмета \"[crafting_name]\"..."))
	var/mob/living/human = user
	if(istype(human))
		human.put_in_any_hand_if_possible(item, drop_on_fail = TRUE)


/obj/item/craft_blueprints/proc/check_contents(list/contents)
	contents = contents["other"]
	main_loop:
		for(var/A in components)
			var/needed_amount = components[A]
			for(var/B in contents)
				if(ispath(B, A))
					if(contents[B] >= components[A])
						continue main_loop
					else
						needed_amount -= contents[B]
						if(needed_amount <= 0)
							continue main_loop
						else
							continue
			return 0
	return 1

/obj/item/craft_blueprints/proc/get_environment(mob/user)
	. = list()
	. += user.r_hand
	. += user.l_hand
	if(!isturf(user.loc))
		return
	var/list/L = block(get_step(user, SOUTHWEST), get_step(user, NORTHEAST))
	for(var/A in L)
		var/turf/T = A
		if(T.Adjacent(user))
			for(var/B in T)
				var/atom/movable/AM = B
				if(AM.flags & HOLOGRAM)
					continue
				. += AM
	for(var/slot in list(ITEM_SLOT_POCKET_RIGHT, ITEM_SLOT_POCKET_LEFT))
		. += user.get_item_by_slot(slot)


/obj/item/craft_blueprints/proc/get_surroundings(mob/user)
	. = list()
	.["other"] = list() //paths go in here
	.["toolsother"] = list() // items go in here
	for(var/obj/item/I in get_environment(user))
		if(I.flags & HOLOGRAM)
			continue
		if(isstack(I))
			var/obj/item/stack/S = I
			.["other"][I.type] += S.amount
		else
			if(istype(I, /obj/item/reagent_containers))
				var/obj/item/reagent_containers/RC = I
				if(RC.is_drainable())
					for(var/datum/reagent/A in RC.reagents.reagent_list)
						.["other"][A.type] += A.volume
			.["other"][I.type] += 1
		.["toolsother"][I] += 1

/obj/item/craft_blueprints/proc/check_tools(mob/user, list/contents)
	if(!tools.len) //does not run if no tools are needed
		return TRUE
	var/list/possible_tools = list()
	var/list/tools_used = list()
	for(var/obj/item/I in user.contents) //searchs the inventory of the mob
		if(isstorage(I))
			for(var/obj/item/SI in I.contents)
				if(SI.tool_behaviour) //filters for tool behaviours
					possible_tools += SI
		if(I.tool_behaviour)
			possible_tools += I

	possible_tools |= contents["toolsother"] // this add contents to possible_tools
	main_loop: // checks if all tools found are usable with the recipe
		for(var/A in tools)
			for(var/obj/item/I in possible_tools)
				if(A == I.tool_behaviour)
					tools_used += I
					continue main_loop
			return FALSE
	for(var/obj/item/T in tools_used)
		if(!T.tool_start_check(null, user, 0)) //Check if all our tools are valid for their use
			return FALSE
	return TRUE


/obj/item/craft_blueprints/proc/requirements_deletion(mob/user)
	var/list/surroundings = get_environment(user)
	var/list/parts_used = list()
	var/list/reagent_containers_for_deletion = list()
	var/list/item_stacks_for_deletion = list()
	for(var/thing in components)
		var/needed_amount = components[thing]
		if(ispath(thing, /datum/reagent))
			var/datum/reagent/part_reagent = locate(thing) in parts_used
			if(!part_reagent)
				part_reagent = new thing()
				parts_used += part_reagent

			for(var/obj/item/reagent_containers/container in surroundings)
				var/datum/reagent/contained_reagent = container.reagents.get_reagent(thing)
				if(!contained_reagent)
					continue

				var/extracted_amount = min(contained_reagent.volume, needed_amount)
				if(reagent_containers_for_deletion[container] == null)
					reagent_containers_for_deletion[container] = list()

				reagent_containers_for_deletion[container][contained_reagent] = extracted_amount

				part_reagent.volume += extracted_amount
				part_reagent.data += contained_reagent.data
				needed_amount -= extracted_amount
				if(needed_amount <= 0)
					break

			if(needed_amount > 0)
				stack_trace("While crafting [crafting_name] with blueprint [name], some of [thing] went missing (still need [needed_amount])!")
				continue // ignore the error, and continue crafting for player's benefit

		else if(ispath(thing, /obj/item/stack))
			var/obj/item/stack/part_stack = locate(thing) in parts_used
			if(!part_stack)
				part_stack = new thing()
				part_stack.amount = 0
				parts_used += part_stack

			for(var/obj/item/stack/item_stack in (surroundings - item_stacks_for_deletion))
				if(!istype(item_stack, thing))
					continue

				var/extracted_amount = min(item_stack.amount, needed_amount)
				item_stacks_for_deletion[item_stack] = extracted_amount
				part_stack.amount += extracted_amount
				needed_amount -= extracted_amount
				if(needed_amount <= 0)
					break

			if(needed_amount > 0)
				stack_trace("While crafting [crafting_name] with blueprint [name], some of [thing] went missing (still need [needed_amount])!")
				continue

		else
			for(var/i in 1 to needed_amount)
				var/atom/movable/part_atom = locate(thing) in (surroundings - parts_used)
				if(!part_atom)
					stack_trace("While crafting [crafting_name] with blueprint [name], the [thing] went missing!")
					continue
				parts_used += part_atom

	for(var/obj/item/reagent_containers/container_to_clear as anything in reagent_containers_for_deletion)
		for(var/datum/reagent/reagent_to_delete as anything in reagent_containers_for_deletion[container_to_clear])
			var/amount_to_delete = reagent_containers_for_deletion[container_to_clear][reagent_to_delete]

			if(amount_to_delete < reagent_to_delete.volume)
				reagent_to_delete.volume -= amount_to_delete
			else
				container_to_clear.reagents.reagent_list -= reagent_to_delete
			container_to_clear.reagents.conditional_update(container_to_clear)
			container_to_clear.update_icon()

	for(var/obj/item/stack/stack_to_delete as anything in item_stacks_for_deletion)
		var/amount_to_delete = item_stacks_for_deletion[stack_to_delete]
		stack_to_delete.use(amount_to_delete)

	// Sort out the used parts into the ones we need to return (denoted by components),
	// and the ones we need to delete (the rest of components)
	QDEL_LIST(parts_used)


// MARK: Specific blueprints

/obj/item/craft_blueprints/knife
	crafting_name = "Нож"
	crafting_item = /obj/item/kitchen/knife
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	components = list(
		/obj/item/stack/sheet/metal = 5,
		/obj/item/stack/rods = 1
	)
