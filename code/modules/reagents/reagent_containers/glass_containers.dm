////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/glass
	name = " "
	var/base_name = " "
	desc = " "
	icon = 'icons/obj/chemical.dmi'
	icon_state = "null"
	item_state = "null"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50)
	volume = 50
	container_type = OPENCONTAINER
	has_lid = TRUE
	resistance_flags = ACID_PROOF
	blocks_emissive = FALSE
	var/label_text = ""

/obj/item/reagent_containers/glass/New()
	..()
	base_name = name

/obj/item/reagent_containers/glass/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2 && !is_open_container())
		. += "<span class='notice'>Airtight lid seals it completely.</span>"

	. += "<span class='notice'>[src] can hold up to [reagents.maximum_volume] units.</span>"


/obj/item/reagent_containers/glass/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!is_open_container())
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return .

	var/list/transferred = list()
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		transferred += reagent.name

	var/contained = english_list(transferred)

	if(user.a_intent == INTENT_HARM)
		target.visible_message(
			span_danger("[user] splashes the contents of [src] onto [target]!"),
			span_userdanger("[user] splashes the contents of [src] onto [target]!")
		)
		add_attack_logs(user, target, "Splashed with [name] containing [contained]")
		reagents.reaction(target, REAGENT_TOUCH)
		reagents.clear_reagents()
		return .|ATTACK_CHAIN_SUCCESS

	if(!iscarbon(target)) // Non-carbons can't process reagents
		to_chat(user, span_warning("You cannot find a way to feed [target]."))
		return .

	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		if(target == user)
			to_chat(user, span_warning("Your face is obscured"))
		else
			to_chat(user, span_warning("[target]'s face is obscured."))
		return .

	if(target != user)
		target.visible_message(
			span_danger("[user] attempts to feed something to [target]."),
			span_userdanger("[user] attempts to feed something to you."),
		)
		if(!do_after(user, 3 SECONDS, target, NONE) || !reagents || !reagents.total_volume)
			return .
		target.visible_message(
			span_danger("[user] feeds something to [target]."),
			span_userdanger("[user] feeds something to you."),
		)
		add_attack_logs(user, target, "Fed with [name] containing [contained]")
	else
		to_chat(user, span_notice("You swallow a gulp of [src]."))

	. |= ATTACK_CHAIN_SUCCESS
	var/fraction = min(5 / reagents.total_volume, 1)
	reagents.reaction(target, REAGENT_INGEST, fraction)
	addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, trans_to), target, 5), 5)
	playsound(target.loc,'sound/items/drink.ogg', rand(10,50), TRUE)


/obj/item/reagent_containers/glass/afterattack(obj/target, mob/user, proximity, params)
	if((!proximity) ||  !check_allowed_items(target,target_self = TRUE))
		return

	if(!is_open_container())
		return

	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return

		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution to [target].</span>")

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty and can't be refilled!</span>")
			return

		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] unit\s of the contents of [target].</span>")

	else if(reagents.total_volume)
		if(user.a_intent == INTENT_HARM)
			user.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
								"<span class='notice'>You splash the contents of [src] onto [target].</span>")
			reagents.reaction(target, REAGENT_TOUCH)
			reagents.clear_reagents()


/obj/item/reagent_containers/glass/attackby(obj/item/I, mob/user, params)
	if(is_pen(I) || istype(I, /obj/item/flashlight/pen))
		var/rename = rename_interactive(user, I)
		if(!isnull(rename))
			label_text = rename
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/item/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A simple glass beaker, nothing special."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	belt_icon = "beaker"
	materials = list(MAT_GLASS=500)
	var/obj/item/assembly_holder/assembly = null
	var/can_assembly = TRUE


/obj/item/reagent_containers/glass/beaker/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/item/reagent_containers/glass/beaker/examine(mob/user)
	. = ..()
	if(assembly)
		. += "<span class='notice'>There is an [assembly] attached to it, use a screwdriver to remove it.</span>"


/obj/item/reagent_containers/glass/beaker/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)


/obj/item/reagent_containers/glass/beaker/update_overlays()
	. = ..()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)
				filling.icon_state = "[icon_state]-10"
			if(10 to 24)
				filling.icon_state = "[icon_state]10"
			if(25 to 49)
				filling.icon_state = "[icon_state]25"
			if(50 to 74)
				filling.icon_state = "[icon_state]50"
			if(75 to 79)
				filling.icon_state = "[icon_state]75"
			if(80 to 90)
				filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)
				filling.icon_state = "[icon_state]100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling

	if(!is_open_container())
		. += "lid_[initial(icon_state)]"
		if(blocks_emissive == FALSE)
			. += emissive_blocker(icon, "lid_[initial(icon_state)]", src)

	if(assembly)
		. += "assembly"


/obj/item/reagent_containers/glass/beaker/verb/remove_assembly()
	set name = "Remove Assembly"
	set category = "Object"
	set src in usr
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if(assembly)
		to_chat(usr, "<span class='notice'>You detach [assembly] from [src]</span>")
		assembly.forceMove_turf()
		usr.put_in_hands(assembly, ignore_anim = FALSE)
		assembly = null
		qdel(GetComponent(/datum/component/proximity_monitor))
		update_icon(UPDATE_OVERLAYS)
	else
		to_chat(usr, "<span class='notice'>There is no assembly to remove.</span>")


/obj/item/reagent_containers/glass/beaker/proc/heat_beaker()
	if(reagents)
		reagents.temperature_reagents(4000)


/obj/item/reagent_containers/glass/beaker/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/assembly_holder))
		add_fingerprint(user)
		if(!can_assembly)
			to_chat(user, span_warning("The [name] is incompatible with [I]."))
			return ATTACK_CHAIN_PROCEED
		if(assembly)
			to_chat(user, span_warning("The [name] already has an assembly."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_warning("You have attached [I] to [src]."))
		if(assembly.has_prox_sensors())
			AddComponent(/datum/component/proximity_monitor)
		assembly = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/reagent_containers/glass/beaker/HasProximity(atom/movable/AM)
	if(assembly)
		assembly.HasProximity(AM)


/obj/item/reagent_containers/glass/beaker/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(assembly)
		assembly.assembly_crossed(arrived, old_loc)


/obj/item/reagent_containers/glass/beaker/on_found(mob/finder) //for mousetraps
	if(assembly)
		assembly.on_found(finder)

/obj/item/reagent_containers/glass/beaker/hear_talk(mob/living/M, list/message_pieces)
	if(assembly)
		assembly.hear_talk(M, message_pieces)

/obj/item/reagent_containers/glass/beaker/hear_message(mob/living/M, msg)
	if(assembly)
		assembly.hear_message(M, msg)

/obj/item/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large glass beaker with twice the capacity of a normal beaker."
	icon_state = "beakerlarge"
	belt_icon = "large_beaker"
	materials = list(MAT_GLASS=2500)
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	container_type = OPENCONTAINER

/obj/item/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial, often used by virologists of the 25th century."
	icon_state = "vial"
	belt_icon = "vial"
	materials = list(MAT_GLASS=250)
	volume = 25
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25)
	container_type = OPENCONTAINER
	can_assembly = 0

/obj/item/reagent_containers/glass/beaker/drugs
	name = "baggie"
	desc = "A small plastic baggie, often used by pharmaceutical \"entrepreneurs\"."
	icon_state = "baggie"
	amount_per_transfer_from_this = 2
	possible_transfer_amounts = null
	volume = 10
	container_type = OPENCONTAINER
	can_assembly = 0

/obj/item/reagent_containers/glass/beaker/thermite
	name = "Thermite load"
	desc = "A baggie loaded with combustible chemicals."
	icon_state = "baggie"
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = null
	volume = 25
	container_type = OPENCONTAINER
	can_assembly = 0
	list_reagents = list("thermite" = 25)

/obj/item/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions."
	icon_state = "beakernoreact"
	materials = list(MAT_METAL=3000)
	volume = 50
	amount_per_transfer_from_this = 10
	origin_tech = "materials=2;engineering=3;plasmatech=3"
	container_type = OPENCONTAINER
	blocks_emissive = EMISSIVE_BLOCK_GENERIC

/obj/item/reagent_containers/glass/beaker/noreact/New()
	..()
	reagents.set_reacting(FALSE)

/obj/item/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete."
	icon_state = "beakerbluespace"
	materials = list(MAT_GLASS=3000)
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100,300)
	container_type = OPENCONTAINER
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	origin_tech = "bluespace=5;materials=4;plasmatech=4"

/obj/item/reagent_containers/glass/beaker/cryoxadone
	list_reagents = list("cryoxadone" = 30)

/obj/item/reagent_containers/glass/beaker/sacid
	list_reagents = list("sacid" = 50)

/obj/item/reagent_containers/glass/beaker/slimejelly
	list_reagents = list("slimejelly" = 50)

/obj/item/reagent_containers/glass/beaker/drugs/meth
	list_reagents = list("methamphetamine" = 10)

/obj/item/reagent_containers/glass/beaker/laughter
	list_reagents = list("laughter" = 50)

/obj/item/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	materials = list(MAT_METAL=200)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(5,10,15,20,25,30,50,80,100,120)
	volume = 120
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 75, "acid" = 50) //Weak melee protection, because you can wear it on your head
	slot_flags = ITEM_SLOT_HEAD
	resistance_flags = NONE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	container_type = OPENCONTAINER
	var/paintable = TRUE


/obj/item/reagent_containers/glass/bucket/Initialize(mapload)
	. = ..()
	if(!color && paintable)
		color = "#0085E5"
	update_icon(UPDATE_OVERLAYS) //in case bucket's color has been changed in editor or by some deriving buckets


/obj/item/reagent_containers/glass/bucket/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon/spraycan))
		add_fingerprint(user)
		var/obj/item/toy/crayon/spraycan/can = I
		if(!paintable)
			to_chat(user, span_warning("You cannot paint [src]."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(can.capped)
			to_chat(user, span_warning("The cap on [can] is sealed."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		to_chat(user, span_notice("You have painted [src]."))
		playsound(user.loc, 'sound/effects/spray.ogg', 20, TRUE)
		color = can.colour
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	if(istype(I, /obj/item/mop))
		add_fingerprint(user)
		var/obj/item/mop/mop = I
		mop.wet_mop(src, user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(isprox(I))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		to_chat(user, span_notice("You have attached [I] to [src]."))
		var/obj/item/bucket_sensor/bucket_sensor = new(drop_location())
		transfer_fingerprints_to(bucket_sensor)
		I.transfer_fingerprints_to(bucket_sensor)
		bucket_sensor.add_fingerprint(user)
		if(loc == user)
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
			user.put_in_hands(bucket_sensor)
		qdel(I)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/reagent_containers/glass/bucket/update_overlays()
	. = ..()
	if(color)
		var/mutable_appearance/bucket_mask = mutable_appearance(icon='icons/obj/janitor.dmi', icon_state = "bucket_mask")
		. += bucket_mask

		var/mutable_appearance/bucket_hand = mutable_appearance(icon='icons/obj/janitor.dmi', icon_state = "bucket_hand", appearance_flags = RESET_COLOR)
		. += bucket_hand


/obj/item/reagent_containers/glass/bucket/equipped(mob/user, slot, initial)
	. = ..()

	if(slot == ITEM_SLOT_HEAD && reagents.total_volume)
		to_chat(user, span_userdanger("The [name]'s contents spill all over you!"))
		reagents.reaction(user, REAGENT_TOUCH)
		reagents.clear_reagents()



/obj/item/reagent_containers/glass/bucket/wooden
	name = "wooden bucket"
	icon_state = "woodbucket"
	item_state = "woodbucket"
	materials = null
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 50)
	resistance_flags = FLAMMABLE
	paintable = FALSE


/obj/item/reagent_containers/glass/bucket/wooden/update_overlays()
	. = list()


/obj/item/reagent_containers/glass/beaker/waterbottle
	name = "bottle of water"
	desc = "A bottle of water filled at an old Earth bottling facility."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "smallbottle"
	item_state = "bottle"
	list_reagents = list("water" = 49.5, "fluorine" = 0.5) //see desc, don't think about it too hard
	materials = list(MAT_GLASS = 0)
	volume = 50
	amount_per_transfer_from_this = 10

/obj/item/reagent_containers/glass/beaker/waterbottle/empty
	list_reagents = list()

/obj/item/reagent_containers/glass/beaker/waterbottle/large
	desc = "A fresh commercial-sized bottle of water."
	icon_state = "largebottle"
	materials = list(MAT_GLASS = 0)
	list_reagents = list("water" = 100)
	volume = 100
	amount_per_transfer_from_this = 20

/obj/item/reagent_containers/glass/beaker/waterbottle/large/empty
	list_reagents = list()

/obj/item/reagent_containers/glass/pet_bowl
	name = "pet bowl"
	desc = "Миска под еду для любимых домашних животных!"
	icon = 'icons/obj/pet_bowl.dmi'
	icon_state = "petbowl"
	item_state = "petbowl"
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = null
	volume = 15
	resistance_flags = FLAMMABLE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	color = "#0085E5"


/obj/item/reagent_containers/glass/pet_bowl/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)


/obj/item/reagent_containers/glass/pet_bowl/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon/spraycan))
		add_fingerprint(user)
		var/obj/item/toy/crayon/spraycan/can = I
		if(can.capped)
			to_chat(user, span_warning("The cap on [can] is sealed."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		to_chat(user, span_notice("You have painted [src]."))
		playsound(user.loc, 'sound/effects/spray.ogg', 20, TRUE)
		color = can.colour
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	return ..()


/obj/item/reagent_containers/glass/pet_bowl/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)


/obj/item/reagent_containers/glass/pet_bowl/update_overlays()
	. = ..()
	var/mutable_appearance/bowl_mask = mutable_appearance(icon = 'icons/obj/pet_bowl.dmi', icon_state = "colorable_overlay")
	. += bowl_mask
	var/mutable_appearance/bowl_nc_mask = mutable_appearance(icon = 'icons/obj/pet_bowl.dmi', icon_state = "nc_petbowl", appearance_flags = RESET_COLOR)
	. += bowl_nc_mask
	if(reagents.total_volume)
		var/datum/reagent/feed = reagents.has_reagent("afeed")
		if(feed && (feed.volume >= (reagents.total_volume - feed.volume)))
			var/image/feed_overlay = image(icon = 'icons/obj/pet_bowl.dmi', icon_state = "petfood_5", layer = FLOAT_LAYER)
			feed_overlay.appearance_flags = RESET_COLOR
			switch(feed.volume)
				if(6 to 10)
					feed_overlay.icon_state = "petfood_10"
				if(11 to 15)
					feed_overlay.icon_state = "petfood_15"
			. += feed_overlay
		else
			. += mutable_appearance(icon, "liquid_overlay", color = mix_color_from_reagents(reagents.reagent_list), appearance_flags = RESET_COLOR)


/obj/item/reagent_containers/glass/pet_bowl/attack_animal(mob/living/simple_animal/pet)
	if(!pet.client || !pet.safe_respawn(pet, check_station_level = FALSE) || !reagents.total_volume)
		return ..()
	if(reagents.has_reagent("afeed", 1))
		pet.heal_organ_damage(5, 5)
		reagents.remove_reagent("afeed", 1)
		playsound(pet.loc, 'sound/items/eatfood.ogg', rand(10, 30), TRUE)
	else
		reagents.remove_any(1)
		playsound(pet.loc, 'sound/items/drink.ogg', rand(10, 30), TRUE)
