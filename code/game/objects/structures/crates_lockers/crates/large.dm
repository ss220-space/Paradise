/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty wooden crate. You'll need a crowbar to get it open."
	desc = "Тяжелый деревянный ящик. Вам понадобится лом, чтобы открыть его."
	icon_state = "largecrate"
	base_icon_state = "largecrate"
	pass_flags_self = PASSSTRUCTURE
	material_drop = /obj/item/stack/sheet/wood
	material_drop_amount = 4
	integrity_failure = 0
	/// What animal type this crate contains
	var/animal_type

/obj/structure/closet/crate/large/get_ru_names()
    return list(
        NOMINATIVE = "большой ящик",
        GENITIVE = "большого ящика",
        DATIVE = "большому ящику",
        ACCUSATIVE = "большой ящик",
        INSTRUMENTAL = "большим ящиком",
        PREPOSITIONAL = "большом ящике",
    )

/obj/structure/closet/crate/large/Destroy()
	var/turf/crate_location = get_turf(src)
	for(var/obj/contained_object in contents)
		contained_object.forceMove(crate_location)
	return ..()

/obj/structure/closet/crate/large/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -40, 5)

/obj/structure/closet/crate/large/update_overlays()
	. = ..()
	if(manifest)
		. += "manifest"

/obj/structure/closet/crate/large/attack_hand(mob/user)
	if(manifest)
		tear_manifest(user)
	else
		to_chat(user, span_warning("You need a crowbar to pry this open!"))
		to_chat(user, span_warning("Вам нужен лом, чтобы открыть это!"))

/obj/structure/closet/crate/large/crowbar_act(mob/living/user, obj/item/item)
	. = TRUE
	if(!item.use_tool(src, user, volume = item.tool_volume))
		return

	if(manifest)
		manifest.forceMove(loc)
		manifest = null
		update_icon(UPDATE_OVERLAYS)

	if(animal_type)
		new animal_type(loc)

	new /obj/item/stack/sheet/wood(loc)
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(loc)

	user.visible_message(
		span_notice("[user] pries [src] open."),
		span_notice("You pry open [src]."),
		span_hear("You hear splitting wood."),
		span_notice("[user] вскрывает [src]."),
		span_notice("Вы вскрываете [src]."),
		span_notice("[user] вскрывает [src.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы вскрываете [src.declent_ru(ACCUSATIVE)]."),
		span_hear("Вы слышите треск раскалывающегося дерева."),
	)
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

/obj/structure/closet/crate/large/cow/get_ru_names()
    return list(
        NOMINATIVE = "ящик для коровы",
        GENITIVE = "ящика для коровы",
        DATIVE = "ящику для коровы",
        ACCUSATIVE = "ящик для коровы",
        INSTRUMENTAL = "ящиком для коровы",
        PREPOSITIONAL = "ящике для коровы",
    )

/obj/structure/closet/crate/large/goat
	name = "goat crate"
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/closet/crate/large/goat/get_ru_names()
    return list(
        NOMINATIVE = "ящик для козла",
        GENITIVE = "ящика для козла",
        DATIVE = "ящику для козла",
        ACCUSATIVE = "ящик для козла",
        INSTRUMENTAL = "ящиком для козла",
        PREPOSITIONAL = "ящике для козла",
    )

/obj/structure/closet/crate/large/cat
	name = "cat crate"
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/pet/cat

/obj/structure/closet/crate/large/cat/get_ru_names()
    return list(
        NOMINATIVE = "ящик для кошки",
        GENITIVE = "ящика для кошки",
        DATIVE = "ящику для кошки",
        ACCUSATIVE = "ящик для кошки",
        INSTRUMENTAL = "ящиком для кошки",
        PREPOSITIONAL = "ящике для кошки",
    )

/obj/structure/closet/crate/large/chick
	name = "chicken crate"
	icon_state = "lisacrate"

/obj/structure/closet/crate/large/chick/get_ru_names()
    return list(
        NOMINATIVE = "ящик для цыплёнка",
        GENITIVE = "ящика для цыплёнка",
        DATIVE = "ящику для цыплёнка",
        ACCUSATIVE = "ящик для цыплёнка",
        INSTRUMENTAL = "ящиком для цыплёнка",
        PREPOSITIONAL = "ящике для цыплёнка",
    )

/obj/structure/closet/crate/large/chick/crowbar_act(mob/living/user, obj/item/item)
	var/atom/cached_loc = loc
	. = ..()
	for(var/i in 1 to rand(4, 6))
		new /mob/living/simple_animal/chick(cached_loc)

