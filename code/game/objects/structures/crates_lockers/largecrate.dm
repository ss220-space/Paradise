/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
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
		to_chat(user, "<span class='notice'>You tear the manifest off of the crate.</span>")
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.forceMove_turf()
		if(ishuman(user))
			user.put_in_hands(manifest, ignore_anim = FALSE)
		manifest = null
		update_icon(UPDATE_OVERLAYS)
		return

	to_chat(user, "<span class='notice'>You need a crowbar to pry this open!</span>")


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
		span_notice("[user] pries [src] open."),
		span_notice("You pry open [src]."),
		span_italics("You hear splitting wood."),
	)
	qdel(src)


/obj/structure/largecrate/attackby(obj/item/I, mob/user, params)
	if(user.a_intent != INTENT_HARM)
		attack_hand(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/structure/largecrate/mule


/obj/structure/largecrate/lisa
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/pet/dog/corgi/Lisa


/obj/structure/largecrate/cow
	name = "cow crate"
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/cow


/obj/structure/largecrate/goat
	name = "goat crate"
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/hostile/retaliate/goat


/obj/structure/largecrate/cat
	name = "cat crate"
	icon_state = "lisacrate"
	animal_type = /mob/living/simple_animal/pet/cat


/obj/structure/largecrate/chick
	name = "chicken crate"
	icon_state = "lisacrate"


/obj/structure/largecrate/chick/crowbar_act(mob/living/user, obj/item/I)
	var/atom/cached_loc = loc
	. = ..()
	for(var/i = 1 to rand(4, 6))
		new /mob/living/simple_animal/chick(cached_loc)

