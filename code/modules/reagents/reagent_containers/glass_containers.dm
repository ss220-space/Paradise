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

/obj/item/reagent_containers/glass/attack(mob/M, mob/user, def_zone)
	if(!is_open_container())
		return ..()

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(istype(M))
		var/list/transferred = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			transferred += R.name
		var/contained = english_list(transferred)

		if(user.a_intent == INTENT_HARM)
			M.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [M]!</span>", \
							"<span class='userdanger'>[user] splashes the contents of [src] onto [M]!</span>")
			add_attack_logs(user, M, "Splashed with [name] containing [contained]")

			reagents.reaction(M, REAGENT_TOUCH)
			reagents.clear_reagents()
		else
			if(!iscarbon(M)) // Non-carbons can't process reagents
				to_chat(user, "<span class='warning'>You cannot find a way to feed [M].</span>")
				return
			if(M != user)
				M.visible_message("<span class='danger'>[user] attempts to feed something to [M].</span>", \
							"<span class='userdanger'>[user] attempts to feed something to you.</span>")
				if(!do_mob(user, M))
					return
				if(!reagents || !reagents.total_volume)
					return // The drink might be empty after the delay, such as by spam-feeding
				M.visible_message("<span class='danger'>[user] feeds something to [M].</span>", "<span class='userdanger'>[user] feeds something to you.</span>")
				add_attack_logs(user, M, "Fed with [name] containing [contained]")
			else
				to_chat(user, "<span class='notice'>You swallow a gulp of [src].</span>")

			var/fraction = min(5 / reagents.total_volume, 1)
			reagents.reaction(M, REAGENT_INGEST, fraction)
			addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, trans_to), M, 5), 5)
			playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)

/obj/item/reagent_containers/glass/afterattack(obj/target, mob/user, proximity)
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
	if(istype(I, /obj/item/pen) || istype(I, /obj/item/flashlight/pen))
		var/t = rename_interactive(user, I)
		if(!isnull(t))
			label_text = t
	else
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
			. += emissive_blocker(icon, "lid_[initial(icon_state)]")

	if(assembly)
		. += "assembly"


/obj/item/reagent_containers/glass/beaker/verb/remove_assembly()
	set name = "Remove Assembly"
	set category = "Object"
	set src in usr
	if(usr.incapacitated())
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


/obj/item/reagent_containers/glass/beaker/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/assembly_holder) && can_assembly)
		if(assembly)
			to_chat(usr, "<span class='warning'>[src] already has an assembly.</span>")
			return ..()
		if(user.drop_transfer_item_to_loc(W, src))
			if(assembly.has_prox_sensors())
				AddComponent(/datum/component/proximity_monitor)
			assembly = W
			update_icon(UPDATE_OVERLAYS)
		return ..()
	return ..()


/obj/item/reagent_containers/glass/beaker/HasProximity(atom/movable/AM)
	if(assembly)
		assembly.HasProximity(AM)

/obj/item/reagent_containers/glass/beaker/Crossed(atom/movable/AM, oldloc)
	if(assembly)
		assembly.Crossed(AM, oldloc)

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
	slot_flags = SLOT_HEAD
	resistance_flags = NONE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	container_type = OPENCONTAINER
	var/paintable = TRUE


/obj/item/reagent_containers/glass/bucket/Initialize(mapload)
	. = ..()
	if(!color && paintable)
		color = "#0085E5"
	update_icon(UPDATE_OVERLAYS) //in case bucket's color has been changed in editor or by some deriving buckets


/obj/item/reagent_containers/glass/bucket/attackby(obj/D, mob/user, params)
	. = ..()
	if(paintable && istype(D, /obj/item/toy/crayon/spraycan))
		var/obj/item/toy/crayon/spraycan/can = D
		if(!can.capped && Adjacent(can, 1))
			color = can.colour
			update_icon(UPDATE_OVERLAYS)


/obj/item/reagent_containers/glass/bucket/update_overlays()
	. = ..()
	if(color)
		var/mutable_appearance/bucket_mask = mutable_appearance(icon='icons/obj/janitor.dmi', icon_state = "bucket_mask")
		. += bucket_mask

		var/mutable_appearance/bucket_hand = mutable_appearance(icon='icons/obj/janitor.dmi', icon_state = "bucket_hand", appearance_flags = RESET_COLOR)
		. += bucket_hand


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


/obj/item/reagent_containers/glass/bucket/equipped(mob/user, slot, initial)
    . = ..()

    if(slot == slot_head && reagents.total_volume)
        to_chat(user, "<span class='userdanger'>[src]'s contents spill all over you!</span>")
        reagents.reaction(user, REAGENT_TOUCH)
        reagents.clear_reagents()


/obj/item/reagent_containers/glass/bucket/attackby(obj/D, mob/user, params)
	if(istype(D, /obj/item/mop))
		var/obj/item/mop/m = D
		m.wet_mop(src, user)
		return
	if(isprox(D))
		to_chat(user, "You add [D] to [src].")
		qdel(D)
		user.put_in_hands(new /obj/item/bucket_sensor)
		user.temporarily_remove_item_from_inventory(src)
		qdel(src)
	else
		..()

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
