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



// MARK: Specific blueprints

/obj/item/craft_blueprints/knife
	crafting_name = "Нож"
	crafting_item = /obj/item/kitchen/knife
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	components = list(
		/obj/item/stack/sheet/metal = 5,
		/obj/item/stack/rods = 1
	)
