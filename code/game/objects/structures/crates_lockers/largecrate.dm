/obj/structure/largecrate
	name = "large crate"
	desc = "Ящик из дерева внушительного размера. \
			Предназначен для транспортировки крупных животных."
	ru_names = list(
		NOMINATIVE = "большой деревянный ящик",
		GENITIVE = "большого деревянного ящика",
		DATIVE = "большому деревянному ящику",
		ACCUSATIVE = "большой деревянный ящик",
		INSTRUMENTAL = "большим деревянным ящиком",
		PREPOSITIONAL = "большом деревянном ящике"
	)
	gender = MALE
	icon = 'icons/obj/crates.dmi'
	icon_state = "largecrate"
	density = TRUE
	var/obj/item/paper/manifest/manifest
	/// What animal type this crate contains
	var/animal_type


/obj/structure/largecrate/update_overlays()
	. = ..()
	if(manifest)
		. += "manifest"


/obj/structure/largecrate/attack_hand(mob/user)
	if(manifest)
		add_fingerprint(user)
		balloon_alert(user, "манифест снабжения откреплён")
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.forceMove_turf()
		if(ishuman(user))
			user.put_in_hands(manifest, ignore_anim = FALSE)
		manifest = null
		update_icon(UPDATE_OVERLAYS)
		return

	balloon_alert(user, "нужен поддевающий инструмент!")


/obj/structure/largecrate/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
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
		span_notice("[user] открыва[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] с помощью [I.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы открываете [declent_ru(ACCUSATIVE)] с помощью [I.declent_ru(ACCUSATIVE)]."),
		span_italics("Вы слышите треск древесины."),
		ignored_mobs = user
	)
	balloon_alert(user, "открыто")
	qdel(src)


/obj/structure/largecrate/attackby(obj/item/I, mob/user, params)
	if(user.a_intent != INTENT_HARM)
		attack_hand(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/structure/largecrate/mule


/obj/structure/largecrate/lisa
	name = "corgi Lisa crate"
	ru_names = list(
		NOMINATIVE = "большой деревянный ящик (Корги Лиза)",
		GENITIVE = "большого деревянного ящика (Корги Лиза)",
		DATIVE = "большому деревянному ящику (Корги Лиза)",
		ACCUSATIVE = "большой деревянный ящик (Корги Лиза)",
		INSTRUMENTAL = "большим деревянным ящиком (Корги Лиза)",
		PREPOSITIONAL = "большом деревянном ящике (Корги Лиза)"
	)
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/pet/dog/corgi/Lisa


/obj/structure/largecrate/cow
	name = "cow crate"
	ru_names = list(
		NOMINATIVE = "большой деревянный ящик (Корова)",
		GENITIVE = "большого деревянного ящика (Корова)",
		DATIVE = "большому деревянному ящику (Корова)",
		ACCUSATIVE = "большой деревянный ящик (Корова)",
		INSTRUMENTAL = "большим деревянным ящиком (Корова)",
		PREPOSITIONAL = "большом деревянном ящике (Корова)"
	)
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/cow


/obj/structure/largecrate/goat
	name = "goat crate"
	ru_names = list(
		NOMINATIVE = "большой деревянный ящик (Козёл)",
		GENITIVE = "большого деревянного ящика (Козёл)",
		DATIVE = "большому деревянному ящику (Козёл)",
		ACCUSATIVE = "большой деревянный ящик (Козёл)",
		INSTRUMENTAL = "большим деревянным ящиком (Козёл)",
		PREPOSITIONAL = "большом деревянном ящике (Козёл)"
	)
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/hostile/retaliate/goat


/obj/structure/largecrate/cat
	name = "cat crate"
	ru_names = list(
		NOMINATIVE = "большой деревянный ящик (Кошка)",
		GENITIVE = "большого деревянного ящика (Кошка)",
		DATIVE = "большому деревянному ящику (Кошка)",
		ACCUSATIVE = "большой деревянный ящик (Кошка)",
		INSTRUMENTAL = "большим деревянным ящиком (Кошка)",
		PREPOSITIONAL = "большом деревянном ящике (Кошка)"
	)
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/pet/cat


/obj/structure/largecrate/chick
	name = "chicken crate"
	ru_names = list(
		NOMINATIVE = "большой деревянный ящик (Курица)",
		GENITIVE = "большого деревянного ящика (Курица)",
		DATIVE = "большому деревянному ящику (Курица)",
		ACCUSATIVE = "большой деревянный ящик (Курица)",
		INSTRUMENTAL = "большим деревянным ящиком (Курица)",
		PREPOSITIONAL = "большом деревянном ящике (Курица)"
	)
	icon_state = "lisacrate"


/obj/structure/largecrate/chick/crowbar_act(mob/living/user, obj/item/I)
	var/atom/cached_loc = loc
	. = ..()
	for(var/i = 1 to rand(4, 6))
		new /mob/living/simple_animal/chick(cached_loc)

