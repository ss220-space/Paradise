/obj/item/clothing/shoes/black
	name = "black shoes"
	icon_state = "black"
	item_color = "black"
	desc = "A pair of black shoes."

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/black/redcoat
	item_color = "redcoat"	//Exists for washing machines. Is not different from black shoes in any way.

/obj/item/clothing/shoes/black/greytide


/obj/item/clothing/shoes/black/greytide/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/shoes/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/brown/captain
	item_color = "captain"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/brown/hop
	item_color = "hop"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/brown/ce
	item_color = "chief"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/brown/rd
	item_color = "director"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/brown/cmo
	item_color = "medical"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/brown/qm
	item_color = "cargo"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/blue
	name = "blue shoes"
	icon_state = "blue"
	item_color = "blue"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/green
	name = "green shoes"
	icon_state = "green"
	item_color = "green"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/yellow
	name = "yellow shoes"
	icon_state = "yellow"
	item_color = "yellow"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/purple
	name = "purple shoes"
	icon_state = "purple"
	item_color = "purple"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	icon_state = "brown"
	item_color = "brown"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"
	item_color = "red"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/white
	name = "white shoes"
	icon_state = "white"
	permeability_coefficient = 0.01
	item_color = "white"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/leather
	name = "leather shoes"
	desc = "A sturdy pair of leather shoes."
	icon_state = "leather"
	item_color = "leather"

/obj/item/clothing/shoes/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	item_color = "rainbow"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/orange
	name = "orange shoes"
	icon_state = "orange"
	item_color = "orange"
	dying_key = DYE_REGISTRY_SHOES
	var/obj/item/restraints/handcuffs/shackles

/obj/item/clothing/shoes/orange/Destroy()
	QDEL_NULL(shackles)
	return ..()


/obj/item/clothing/shoes/orange/attack_self(mob/user)
	if(shackles)
		user.put_in_hands(shackles)
		set_shackles(null)


/obj/item/clothing/shoes/orange/proc/set_shackles(obj/item/restraints/handcuffs/new_shackles)
	if(shackles == new_shackles)
		return
	. = shackles
	shackles = new_shackles
	if(shackles)
		slowdown = 15
	else
		slowdown = SHOES_SLOWDOWN
		if(.)
			var/obj/item/restraints/handcuffs/old_shackles = .
			if(old_shackles.loc == src)
				old_shackles.forceMove(drop_location())
	update_icon(UPDATE_ICON_STATE)
	update_equipped_item()


/obj/item/clothing/shoes/orange/update_icon_state()
	icon_state = "orange[shackles ? "1" : ""]"


/obj/item/clothing/shoes/orange/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/restraints/handcuffs))
		add_fingerprint(user)
		if(shackles)
			to_chat(user, span_warning("The [name] already has [shackles] attached."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		set_shackles(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

