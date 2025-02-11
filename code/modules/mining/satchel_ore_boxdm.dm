
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "ore box"
	desc = "A heavy wooden box, which can be filled with a lot of ores."
	density = TRUE
	pressure_resistance = 5 * ONE_ATMOSPHERE


/obj/structure/ore_box/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/ore))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(isstorage(I))
		add_fingerprint(user)
		var/obj/item/storage/storage = I
		storage.hide_from(user)
		var/loaded = 0
		for(var/obj/item/stack/ore/ore in storage.contents)
			loaded++
			ore.add_fingerprint(user)
			storage.remove_from_storage(ore, src) //This will move the item to this item's contents
			CHECK_TICK
		if(!loaded)
			to_chat(user, span_warning("The [storage.name] has no ore."))
			return ATTACK_CHAIN_PROCEED
		storage.update_appearance()	// just in case
		to_chat(user, span_notice("You have emptied [storage] into [src]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/structure/ore_box/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume))
		return .
	user.visible_message(
		span_notice("[user] has pried [src] apart."),
		span_notice("You have pried [src] apart."),
		span_italics("You hear splitting wood."),
	)
	deconstruct(TRUE, user)


/obj/structure/ore_box/attack_hand(mob/user)
	if(Adjacent(user))
		add_fingerprint(user)
		show_contents(user)

/obj/structure/ore_box/attack_robot(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/proc/show_contents(mob/user)
	var/dat = text({"<meta charset="UTF-8"><b>The contents of the ore box reveal...</b><br>"})
	var/list/assembled = list()
	for(var/obj/item/stack/ore/O in src)
		assembled[O.type] += O.amount
	for(var/type in assembled)
		var/obj/item/stack/ore/O = type
		dat += "[initial(O.name)] - [assembled[type]]<br>"

	dat += text("<br><br><a href='byond://?src=[UID()];removeall=1'>Empty box</A>")
	var/datum/browser/popup = new(user, "orebox", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["removeall"])
		dump_box_contents()
		balloon_alert(usr, "разгружено")
	updateUsrDialog()

/obj/structure/ore_box/deconstruct(disassembled = TRUE, mob/user)
	var/obj/item/stack/sheet/wood/W = new (loc, 4)
	if(user)
		W.add_fingerprint(user)
	dump_box_contents()
	qdel(src)

/obj/structure/ore_box/proc/dump_box_contents()
	for(var/obj/item/stack/ore/O in src)
		if(QDELETED(O))
			continue
		if(QDELETED(src))
			break
		O.forceMove(loc)
		CHECK_TICK

/obj/structure/ore_box/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = FALSE)
	return ..()

/obj/structure/ore_box/verb/empty_box()
	set name = "Empty Ore Box"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(!Adjacent(usr))
		balloon_alert(usr, "слишком далеко!")
		return

	add_fingerprint(usr)

	if(contents.len < 1)
		balloon_alert(usr, "груз отсутствует")
		return

	dump_box_contents()
	balloon_alert(usr, "разгружено")
