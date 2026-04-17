/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty wooden crate. You'll need a crowbar to get it open."
	icon_state = "largecrate"
	base_icon_state = "largecrate"
	pass_flags_self = PASSSTRUCTURE
	material_drop = /obj/item/stack/sheet/wood
	material_drop_amount = 4
	integrity_failure = 0
	/// What animal type this crate contains
	var/animal_type

/obj/structure/closet/crate/large/Destroy()
	var/turf/current_turf = get_turf(src)
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(current_turf)
	return ..()

/obj/structure/closet/crate/large/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -40, 5)

/obj/structure/closet/crate/large/update_overlays()
	. = ..()
	if(manifest)
		. += "manifest"

/obj/structure/closet/crate/large/attack_hand(mob/user)
	add_fingerprint(user)
	if(manifest)
		tear_manifest(user)
	else
		to_chat(user, span_warning("You need a crowbar to pry this open!"))

/obj/structure/closet/crate/large/crowbar_act(mob/living/user, obj/item/item)
	. = TRUE
	if(!item.use_tool(src, user, volume = item.tool_volume))
		return

	if(manifest)
		tear_manifest(user)

	if(!open(user))
		return FALSE

	user.visible_message(
		span_notice("[user] pries [src] open."),
		span_notice("You pry open [src]."),
		span_hear("You hear splitting wood."),
	)
	playsound(loc, 'sound/weapons/slashmiss.ogg', 75, TRUE)

	var/turf/current_turf = get_turf(src)
	for(var/i in 1 to material_drop_amount)
		new material_drop(src)

	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(current_turf)

	if(animal_type)
		new animal_type(current_turf)

	qdel(src)

/obj/structure/closet/crate/large/attackby(obj/item/item, mob/user, params)
	if(user.a_intent != INTENT_HARM)
		attack_hand(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/structure/closet/crate/large/mule

/obj/structure/closet/crate/large/lisa
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/pet/dog/corgi/Lisa

/obj/structure/closet/crate/large/cow
	name = "cow crate"
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/cow

/obj/structure/closet/crate/large/goat
	name = "goat crate"
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/closet/crate/large/cat
	name = "cat crate"
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/pet/cat

/obj/structure/closet/crate/large/chick
	name = "chicken crate"
	icon_state = "lisacrate"

/obj/structure/closet/crate/large/chick/crowbar_act(mob/living/user, obj/item/item)
	var/atom/current_turf = get_turf(src)
	. = ..()
	for(var/i in 1 to rand(4, 6))
		new /mob/living/simple_animal/chick(current_turf)

