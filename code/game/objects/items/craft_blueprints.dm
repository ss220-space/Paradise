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

/obj/item/craft_blueprints/get_ru_names()
	return list(
        NOMINATIVE = "чертежи для крафта",
        GENITIVE = "чертежей для крафта",
        DATIVE = "чертежам для крафта",
        ACCUSATIVE = "чертежи для крафта",
        INSTRUMENTAL = "чертежами для крафта",
        PREPOSITIONAL = "чертежах для крафта"
	)

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
	if(!length(components))
		return
	var/required_components_text = "Вещи для крафта: "
	for(var/component in components)
		var/need_amount = components[component]
		var/atom/atom_comp = component
		required_components_text += "[need_amount] [initial(atom_comp.name)] "
	. += span_notice(required_components_text)


/obj/item/craft_blueprints/proc/on_table_place(datum/source, mob/user)
	SIGNAL_HANDLER
	balloon_alert(user, "развернуто")
	placed_on_table = TRUE
	anchored = TRUE
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
	var/x_offset = text2num(LAZYACCESS(click_params, ICON_X))
	var/y_offset = text2num(LAZYACCESS(click_params, ICON_Y))
	if(!x_offset || !y_offset)
		return .
	item.pixel_x = clamp(x_offset - (ICON_SIZE_X / 2), - (ICON_SIZE_X / 2), ICON_SIZE_X / 2)
	item.pixel_y = clamp(y_offset - (ICON_SIZE_Y / 2), - (ICON_SIZE_Y / 2), ICON_SIZE_Y / 2)


/obj/item/craft_blueprints/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(over_object != usr || !ishuman(usr) || !usr.Adjacent(src))
		return ..()
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		balloon_alert(usr, "не получилось!")
		return FALSE
	var/mob/living/human = usr
	usr.balloon_alert(usr, "свернуто")
	placed_on_table = FALSE
	anchored = FALSE
	layer = initial(layer)
	update_icon()
	human.put_in_any_hand_if_possible(src, drop_on_fail = TRUE)
	return FALSE



// MARK: Crafting mechanic

/obj/item/craft_blueprints/proc/try_craft_item(mob/user)
	var/list/surroundings = get_surroundings(user)
	var/list/empty = list()
	if(!check_tools(user, tools, surroundings))
		balloon_alert(user, "не хватает инструментов")
		return
	if(!check_contents(components, empty, empty, surroundings))
		balloon_alert(user, "не хватает компонентов")
		return
	to_chat(user, span_notice("Вы начинаете крафт предмета \"[crafting_name]\"..."))
	if(!do_after(user, craft_duration, src))
		return
	surroundings = get_surroundings(user)
	if(!check_tools(user, tools, surroundings))
		balloon_alert(user, "не хватает инструментов")
		return
	if(!check_contents(components, empty, empty, surroundings))
		balloon_alert(user, "не хватает компонентов")
		return
	requirements_deletion(components, empty, empty, user)
	var/item = new crafting_item(loc)
	balloon_alert(user, "завершено")
	var/mob/living/human = user
	if(!istype(human))
		return
	human.put_in_any_hand_if_possible(item, drop_on_fail = TRUE)


// MARK: Specific blueprints

/obj/item/craft_blueprints/knife
	crafting_name = "Нож"
	crafting_item = /obj/item/kitchen/knife
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	components = list(
		/obj/item/stack/sheet/metal = 5,
		/obj/item/stack/rods = 1
	)
