// MARK: Rack Parts
/obj/item/rack_parts
	name = "rack parts"
	desc = "Детали разобранного стеллажа."
	gender = PLURAL
	icon = 'icons/obj/structures/rack.dmi'
	icon_state = "rack_parts"
	item_state = "rack_parts"
	flags = CONDUCT
	materials = list(MAT_METAL = 2000)
	/// Protection against calling the assembly again.
	var/building = FALSE
	/// The type of structure that this item creates.
	var/rack_type = /obj/structure/rack

/obj/item/rack_parts/get_ru_names()
	return list(
		NOMINATIVE = "детали стеллажа",
		GENITIVE = "деталей стеллажа",
		DATIVE = "деталям стеллажа",
		ACCUSATIVE = "детали стеллажа",
		INSTRUMENTAL = "деталями стеллажа",
		PREPOSITIONAL = "деталях стеллажа",
	)

/obj/item/rack_parts/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/rack_parts/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		return NONE

	if(held_item == src)
		context[SCREENTIP_CONTEXT_LMB] = "Собрать"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Разобрать"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/rack_parts/wrench_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/rack_parts/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(drop_location())
	return ..()

/obj/item/rack_parts/attack_self(mob/user)
	if(building)
		return
	building = TRUE
	to_chat(user, span_notice("Вы начинаете собирать [declent_ru(ACCUSATIVE)]..."))
	if(!do_after(user, 3 SECONDS, target = user))
		building = FALSE
		return
	if(!user.temporarily_remove_item_from_inventory(src))
		building = FALSE
		return
	var/obj/structure/rack/constructed_rack = new rack_type(get_turf(src))
	user.visible_message(
		span_notice("[DECLENT_RU_CAP(user, NOMINATIVE)] собирает [constructed_rack.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы собираете [constructed_rack.declent_ru(ACCUSATIVE)].")
	)
	constructed_rack.add_fingerprint(user)
	qdel(src)
	building = FALSE

// MARK: Gun Rack Parts
/obj/item/rack_parts/gunrack_parts
	name = "gun rack parts"
	desc = "Части стойки для оружия."
	icon_state = "gunrack_parts"
	item_state = "gunrack_parts"
	materials = list(MAT_METAL = 2000)
	rack_type = /obj/structure/rack/gunrack

/obj/item/rack_parts/gunrack_parts/get_ru_names()
	return list(
		NOMINATIVE = "детали стеллажа для оружия",
		GENITIVE = "деталей стеллажа для оружия",
		DATIVE = "деталям стеллажа для оружия",
		ACCUSATIVE = "детали стеллажа для оружия",
		INSTRUMENTAL = "деталями стеллажа для оружия",
		PREPOSITIONAL = "деталях стеллажа для оружия",
	)

// MARK: Cargo Shelf Parts
/obj/item/rack_parts/cargo_shelf
	name = "crate shelf parts"
	desc = "Детали стеллажа, предназначенного для хранения ящиков."
	icon_state = "shelf_parts"
	item_state = "shelf_parts"
	materials = list(MAT_METAL = 2000)
	rack_type = /obj/structure/cargo_shelf

/obj/item/rack_parts/cargo_shelf/get_ru_names()
	return list(
		NOMINATIVE = "детали стеллажа для ящиков",
		GENITIVE = "деталей стеллажа для ящиков",
		DATIVE = "деталям стеллажа для ящиков",
		ACCUSATIVE = "детали стеллажа для ящиков",
		INSTRUMENTAL = "деталями стеллажа для ящиков",
		PREPOSITIONAL = "деталях стеллажа для ящиков",
	)
