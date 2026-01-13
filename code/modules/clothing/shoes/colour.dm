/obj/item/clothing/shoes/color
	icon = 'icons/map_icons/clothing/shoes.dmi'
	icon_state = "/obj/item/clothing/shoes/color"
	post_init_icon_state = "sneakers"
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_colors = "#545454#ffffff"
	greyscale_config_worn = list(
		ITEM_SLOT_FEET_STRING = /datum/greyscale_config/sneakers_worn,
	)
	greyscale_config_worn_species = list(
		SPECIES_VOX = /datum/greyscale_config/sneakers_worn/vox,
		SPECIES_DRASK = /datum/greyscale_config/sneakers_worn/drask,
		SPECIES_UNATHI = /datum/greyscale_config/sneakers_worn/unathi,
		SPECIES_ASHWALKER_BASIC = /datum/greyscale_config/sneakers_worn/unathi,
		SPECIES_ASHWALKER_SHAMAN = /datum/greyscale_config/sneakers_worn/unathi,
		SPECIES_DRACONOID = /datum/greyscale_config/sneakers_worn/unathi,
		SPECIES_MONKEY = /datum/greyscale_config/sneakers_worn/monkey,
		SPECIES_FARWA =  /datum/greyscale_config/sneakers_worn/monkey,
		SPECIES_WOLPIN =  /datum/greyscale_config/sneakers_worn/monkey,
		SPECIES_NEARA =  /datum/greyscale_config/sneakers_worn/monkey,
		SPECIES_STOK =  /datum/greyscale_config/sneakers_worn/monkey,
	)

/obj/item/clothing/shoes/color/black
	name = "black shoes"
	icon_state = "/obj/item/clothing/shoes/color/black"
	item_color = "black"
	desc = "A pair of black shoes."
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	dying_key = DYE_REGISTRY_SHOES


/obj/item/clothing/shoes/color/black/redcoat
	item_color = "redcoat"	//Exists for washing machines. Is not different from black shoes in any way.
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/clothing/shoes/color/black/greytide
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/clothing/shoes/black/fluff
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/clothing/shoes/color/black/greytide/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/shoes/color/brown
	name = "brown shoes"
	icon_state = "/obj/item/clothing/shoes/color/brown"
	desc = "A pair of brown shoes."
	greyscale_colors = "#814112#ffffff"
	item_state = "brown"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/color/brown/captain
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW
	item_color = "captain"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/color/brown/hop
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW
	item_color = "hop"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/color/brown/ce
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW
	item_color = "chief"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/color/brown/rd
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW
	item_color = "director"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/color/brown/cmo
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW
	item_color = "medical"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/color/brown/qm
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW
	item_color = "cargo"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/color/blue
	name = "blue shoes"
	icon_state = "/obj/item/clothing/shoes/color/blue"
	greyscale_colors = "#16a9eb#ffffff"
	item_color = "blue"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/color/green
	name = "green shoes"
	icon_state = "/obj/item/clothing/shoes/color/green"
	greyscale_colors = "#54eb16#ffffff"
	item_color = "green"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/color/yellow
	name = "yellow shoes"
	icon_state = "/obj/item/clothing/shoes/color/yellow"
	greyscale_colors = "#ebe216#ffffff"
	item_color = "yellow"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/color/purple
	name = "purple shoes"
	icon_state = "/obj/item/clothing/shoes/color/purple"
	greyscale_colors = "#ad16eb#ffffff"
	item_color = "purple"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/color/red
	name = "red shoes"
	icon_state = "/obj/item/clothing/shoes/color/red"
	desc = "Stylish red shoes."
	greyscale_colors = "#ff2626#ffffff"
	item_color = "red"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/color/white
	name = "white shoes"
	icon_state = "/obj/item/clothing/shoes/color/white"
	greyscale_colors = "#ffffff#ffffff"
	item_state = "white"
	permeability_coefficient = 0.01
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/color/white/secshoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "secshoes"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_species = null

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

/obj/item/clothing/shoes/color/orange
	name = "orange shoes"
	icon_state = "/obj/item/clothing/shoes/color/orange"
	greyscale_colors = "#eb7016#ffffff"
	item_color = "orange"
	dying_key = DYE_REGISTRY_SHOES

/obj/item/clothing/shoes/color/orange/prison
	icon_state = "/obj/item/clothing/shoes/color/orange/prison"
	greyscale_config = /datum/greyscale_config/sneakers_orange
	greyscale_config_worn = list(
		ITEM_SLOT_FEET_STRING = /datum/greyscale_config/sneakers_orange_worn,
	)
	greyscale_config_worn_species = list(
		SPECIES_VOX = /datum/greyscale_config/sneakers_orange_worn/vox,
		SPECIES_DRASK = /datum/greyscale_config/sneakers_orange_worn/drask,
		SPECIES_UNATHI = /datum/greyscale_config/sneakers_orange_worn/unathi,
		SPECIES_ASHWALKER_BASIC = /datum/greyscale_config/sneakers_orange_worn/unathi,
		SPECIES_ASHWALKER_SHAMAN = /datum/greyscale_config/sneakers_orange_worn/unathi,
		SPECIES_DRACONOID = /datum/greyscale_config/sneakers_orange_worn/unathi,
		SPECIES_MONKEY = /datum/greyscale_config/sneakers_orange_worn/monkey,
		SPECIES_FARWA =  /datum/greyscale_config/sneakers_orange_worn/monkey,
		SPECIES_WOLPIN =  /datum/greyscale_config/sneakers_orange_worn/monkey,
		SPECIES_NEARA =  /datum/greyscale_config/sneakers_orange_worn/monkey,
		SPECIES_STOK =  /datum/greyscale_config/sneakers_orange_worn/monkey,
	)
	var/obj/item/restraints/handcuffs/shackles

/obj/item/clothing/shoes/color/orange/prison/Destroy()
	QDEL_NULL(shackles)
	return ..()

/obj/item/clothing/shoes/color/orange/prison/attack_self(mob/user)
	if(shackles)
		user.put_in_hands(shackles)
		set_shackles(null)

/obj/item/clothing/shoes/color/orange/prison/proc/set_shackles(obj/item/restraints/handcuffs/new_shackles)
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

/obj/item/clothing/shoes/color/orange/prison/attackby(obj/item/I, mob/user, params)
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

/obj/item/clothing/shoes/color/orange/prison/update_icon_state()
	icon_state = "sneakers[shackles ? "_chained" : ""]"

/obj/item/clothing/shoes/prison
	name = "prison boots"
	desc = "Твердая и неудобная обувь, сделанная другими заключенными."
	icon_state = "prison_boots"
	item_state = "prison_boots"

/obj/item/clothing/shoes/prison/get_ru_names()
	return list(
		NOMINATIVE = "тюремные башмаки",
		GENITIVE = "тюремные башмаки",
		DATIVE = "тюремным башмакам",
		ACCUSATIVE = "тюремные башмаки",
		INSTRUMENTAL = "тюремныим башмаками",
		PREPOSITIONAL = "тюремных башмаках",
	)

/obj/item/clothing/shoes/convers
	name = "black convers"
	desc = "Пара высоких чёрных кед, сделанных по последнему писку моды. Выглядят просто отпадно."
	icon_state = "blackconvers"
	item_state = "blackconvers"

/obj/item/clothing/shoes/convers/get_ru_names()
	return list(
		NOMINATIVE = "чёрные высокие кеды",
		GENITIVE = "чёрных высоких кедов",
		DATIVE = "чёрным высоким кедам",
		ACCUSATIVE = "чёрные высокие кеды",
		INSTRUMENTAL = "чёрными высокими кедами",
		PREPOSITIONAL = "чёрных высоких кедах",
	)

/obj/item/clothing/shoes/convers/red
	name = "red convers"
	desc = "Пара высоких красных кед, сделанных по последнему писку моды. Выглядят просто отпадно."
	icon_state = "redconvers"
	item_state = "redconvers"

/obj/item/clothing/shoes/convers/red/get_ru_names()
	return list(
		NOMINATIVE = "красные высокие кеды",
		GENITIVE = "красных высоких кедов",
		DATIVE = "красным высоким кедам",
		ACCUSATIVE = "красные высокие кеды",
		INSTRUMENTAL = "красными высокими кедами",
		PREPOSITIONAL = "красных высоких кедах",
	)
