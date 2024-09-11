/obj/item/clothing/gloves/ring
	name = "iron ring"
	desc = "A band that goes around your finger.  It's considered gauche to wear more than one."
	gender = "neuter" // not plural anymore
	transfer_prints = TRUE
	clothing_flags = NONE
	icon_state = "ironring"
	item_state = ""
	icon = 'icons/obj/clothing/rings.dmi'
	pickup_sound = 'sound/items/handling/ring_pickup.ogg'
	drop_sound = 'sound/items/handling/ring_drop.ogg'
	var/fluff_material = FALSE	//If true, will ignore the material when examining
	var/material = "iron"
	var/stud = FALSE
	var/ring_color = "iron"

/obj/item/clothing/gloves/ring/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/clothing/gloves/ring/update_icon_state()
	icon_state = "[stud ? "d_" : ""][ring_color]ring"

/obj/item/clothing/gloves/ring/examine(mob/user)
	. = ..()
	if(!fluff_material)
		. += "<span class='notice'>This one is made of [material].</span>"
	if(stud)
		. += "<span class='notice'>It is adorned with a single gem.</span>"


/obj/item/clothing/gloves/ring/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/mineral/diamond))
		add_fingerprint(user)
		var/obj/item/stack/sheet/mineral/diamond/diamond = I
		if(stud)
			to_chat(user, span_warning("The [name] already has a gem."))
			return ATTACK_CHAIN_PROCEED
		if(!diamond.use(1))
			to_chat(user, span_warning("You need at least one diamond to fill the socket."))
			return ATTACK_CHAIN_PROCEED
		stud = TRUE
		update_icon()
		to_chat(user, span_notice("You socket the diamond into [src]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


// s'pensive
/obj/item/clothing/gloves/ring/silver
	name =  "silver ring"
	icon_state = "silverring"
	material = "silver"
	ring_color = "silver"

/obj/item/clothing/gloves/ring/silver/blessed // todo
	name = "blessed silver ring"

/obj/item/clothing/gloves/ring/gold
	name =  "gold ring"
	icon_state = "goldring"
	material = "gold"
	ring_color = "gold"

/obj/item/clothing/gloves/ring/gold/blessed
	name = "wedding band"

// cheap
/obj/item/clothing/gloves/ring/plastic
	name =  "white plastic ring"
	icon_state = "whitering"
	material = "plastic"
	ring_color = "white"

/obj/item/clothing/gloves/ring/plastic/blue
	name =  "blue plastic ring"
	icon_state = "bluering"
	ring_color = "blue"

/obj/item/clothing/gloves/ring/plastic/red
	name =  "red plastic ring"
	icon_state = "redring"
	ring_color = "red"

/obj/item/clothing/gloves/ring/plastic/random/Initialize(mapload)
	ring_color = pick("white","blue","red")
	name = "[ring_color] plastic ring"
	. = ..()

// weird
/obj/item/clothing/gloves/ring/glass
	name = "glass ring"
	icon_state = "whitering"
	material = "glass"
	ring_color = "white"

/obj/item/clothing/gloves/ring/plasma
	name = "plasma ring"
	icon_state = "plasmaring"
	material = "plasma"
	ring_color = "plasma"

/obj/item/clothing/gloves/ring/uranium
	name = "uranium ring"
	icon_state = "uraniumring"
	material = "uranium"
	ring_color = "uranium"

// cultish
/obj/item/clothing/gloves/ring/shadow
	name = "shadow ring"
	icon_state = "shadowring"
	material = "shadows"
	ring_color = "shadow"
