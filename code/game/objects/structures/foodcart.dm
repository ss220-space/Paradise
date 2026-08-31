/obj/structure/foodcart
	name = "food cart"
	desc = "A cart for transporting food and drinks."
	icon = 'icons/obj/foodcart.dmi'
	icon_state = "cart"
	density = TRUE
	pull_push_slowdown = 1
	var/obj/item/storage/inventory

/obj/structure/foodcart/Initialize(mapload)
	. = ..()
	inventory = new /obj/item/storage(src)
	inventory.storage_slots = 18 //three lines of 7 slots
	inventory.max_w_class = WEIGHT_CLASS_NORMAL
	inventory.max_combined_w_class = 36

/obj/structure/foodcart/Destroy(force)
	QDEL_NULL(inventory)
	return ..()

/obj/structure/foodcart/attack_hand(mob/user)
	add_fingerprint(user)
	if(!user.Adjacent(src) || !inventory)
		return ..()
	inventory.open(user)

/obj/structure/foodcart/attackby(obj/item/item, mob/user, params)
	if(inventory)
		add_fingerprint(user)
		return inventory.attackby(item, user, params)
	return ..()

/obj/structure/foodcart/wrench_act(mob/living/user, obj/item/item)
	. = TRUE
	if(isinspace())
		to_chat(user, span_warning("Это тупая идея."))
		return .
	if(!item.use_tool(src, user, volume = item.tool_volume))
		return .
	set_anchored(!anchored)
	if(anchored)
		WRENCH_ANCHOR_MESSAGE
	else
		WRENCH_UNANCHOR_MESSAGE

/obj/structure/foodcart/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 4)
	qdel(src)
