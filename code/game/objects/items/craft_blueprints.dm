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
	var/required_toner = 40


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
			required_components_text += "[component] x[components[component]] "
		. += span_notice(required_components_text)


/obj/item/craft_blueprints/proc/on_table_place(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, span_notice("Вы разворачиваете [declent_ru(NOMINATIVE)] на столе."))
	placed_on_table = TRUE
	icon_state = place_icon
	pixel_x = 0
	pixel_y = 0

/obj/item/craft_blueprints/update_icon(updates)
	. = ..()
	icon_state = placed_on_table ? place_icon : initial(icon_state)

/obj/item/craft_blueprints/attack_hand(mob/user, pickupfireoverride)
	if(placed_on_table)
		to_chat(user, span_notice("Вы используете [declent_ru(NOMINATIVE)]."))
		// TODO use logic here
		return FALSE
	. = ..()



// MARK: Specific blueprints

/obj/item/craft_blueprints/knife
	crafting_name = "Нож"
	crafting_item = /obj/item/kitchen/knife
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	components = list(
		/obj/item/stack/sheet/metal = 5,
		/obj/item/stack/rods = 1
	)
