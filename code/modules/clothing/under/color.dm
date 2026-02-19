/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	dying_key = DYE_REGISTRY_UNDER
	icon = 'icons/map_icons/clothing/under/color.dmi'
	icon_state = "/obj/item/clothing/under/color"
	post_init_icon_state = "jumpsuit"
	item_state = "jumpsuit"
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = list(
		ITEM_SLOT_CLOTH_INNER_STRING = /datum/greyscale_config/jumpsuit_worn,
	)
	greyscale_config_worn_species = list(
		SPECIES_VOX = /datum/greyscale_config/jumpsuit_worn/vox,
		SPECIES_UNATHI = /datum/greyscale_config/jumpsuit_worn/unathi,
		SPECIES_ASHWALKER_BASIC = /datum/greyscale_config/jumpsuit_worn/unathi,
		SPECIES_ASHWALKER_SHAMAN = /datum/greyscale_config/jumpsuit_worn/unathi,
		SPECIES_DRACONOID = /datum/greyscale_config/jumpsuit_worn/unathi,
		SPECIES_DRASK = /datum/greyscale_config/jumpsuit_worn/drask,
		SPECIES_GREY = /datum/greyscale_config/jumpsuit_worn/grey,
		SPECIES_MONKEY = /datum/greyscale_config/jumpsuit_worn/monkey,
		SPECIES_FARWA = /datum/greyscale_config/jumpsuit_worn/monkey,
		SPECIES_WOLPIN = /datum/greyscale_config/jumpsuit_worn/monkey,
		SPECIES_NEARA = /datum/greyscale_config/jumpsuit_worn/monkey,
		SPECIES_STOK = /datum/greyscale_config/jumpsuit_worn/monkey,
	)


/obj/item/clothing/under/color/random/Initialize(mapload)
	. = ..()
	var/static/list/allowed_colors
	if(!allowed_colors)
		var/list/excluded = list(
			/obj/item/clothing/under/color/random,
			/obj/item/clothing/under/color/blue/dodgeball,
			/obj/item/clothing/under/color/orange/prison,
			/obj/item/clothing/under/prison,
			/obj/item/clothing/under/color/red/dodgeball,
			/obj/item/clothing/under/color/red/jersey,
			/obj/item/clothing/under/color/blue/jersey,
		)
		allowed_colors = subtypesof(/obj/item/clothing/under/color) - excluded
	var/obj/item/clothing/under/color/new_color = pick(allowed_colors)
	name = new_color.name
	item_color = initial(new_color.item_color)
	set_greyscale_colors(new_color.greyscale_colors)


/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	resistance_flags = NONE
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/clothing/under/color/blackf
	name = "feminine black jumpsuit"
	desc = "It's very smart and in a ladies-size!"
	item_state = "bl_suit"
	item_color = "blackf"
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "/obj/item/clothing/under/color/blue"
	greyscale_colors = "#52aecc"

/obj/item/clothing/under/color/blue/dodgeball
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/clothing/under/color/blue/dodgeball/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "/obj/item/clothing/under/color/green"
	greyscale_colors = "#9ed63a"

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	icon_state = "/obj/item/clothing/under/color/grey"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	greyscale_colors = "#b3b3b3"

/obj/item/clothing/under/color/grey/greytide
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/clothing/under/color/grey/greytide/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/under/color/grey/glorf
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."

/obj/item/clothing/under/color/grey/glorf/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	owner.forcesay(GLOB.hit_appends)
	return 0

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	icon_state = "/obj/item/clothing/under/color/orange"
	desc = "Don't wear this near paranoid security officers"
	greyscale_colors = "#ff8c19"

/obj/item/clothing/under/color/orange/prison
	name = "old prison jumpsuit"
	desc = "Старая одежда заключенных из \"Нанотрейзен\". Датчики костюма заблокированы в максимальном режиме отслеживания."
	icon_state = "/obj/item/clothing/under/color/orange/prison"
	has_sensor = 2
	sensor_mode = 3
	greyscale_colors = "#ff8300"
	greyscale_config = /datum/greyscale_config/jumpsuit_prison
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_prison_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_prison_inhand_right
	greyscale_config_worn = list(
		ITEM_SLOT_CLOTH_INNER_STRING = /datum/greyscale_config/jumpsuit_prison_worn,
	)
	greyscale_config_worn_species = list(
		SPECIES_VOX = /datum/greyscale_config/jumpsuit_prison_worn/vox,
		SPECIES_DRASK = /datum/greyscale_config/jumpsuit_prison_worn/drask,
		SPECIES_UNATHI = /datum/greyscale_config/jumpsuit_prison_worn/unathi,
		SPECIES_ASHWALKER_BASIC = /datum/greyscale_config/jumpsuit_prison_worn/unathi,
		SPECIES_ASHWALKER_SHAMAN = /datum/greyscale_config/jumpsuit_prison_worn/unathi,
		SPECIES_DRACONOID = /datum/greyscale_config/jumpsuit_prison_worn/unathi,
		SPECIES_GREY = /datum/greyscale_config/jumpsuit_prison_worn/grey,
		SPECIES_MONKEY = /datum/greyscale_config/jumpsuit_prison_worn/monkey,
		SPECIES_FARWA =  /datum/greyscale_config/jumpsuit_prison_worn/monkey,
		SPECIES_WOLPIN =  /datum/greyscale_config/jumpsuit_prison_worn/monkey,
		SPECIES_NEARA =  /datum/greyscale_config/jumpsuit_prison_worn/monkey,
		SPECIES_STOK =  /datum/greyscale_config/jumpsuit_prison_worn/monkey,
	)

/obj/item/clothing/under/color/orange/prison/get_ru_names()
	return list(
		NOMINATIVE = "старый тюремный комбинезон",
		GENITIVE = "старый тюремный комбинезон",
		DATIVE = "старому тюремному комбинезону",
		ACCUSATIVE = "старый тюремный комбинезон",
		INSTRUMENTAL = "старым тюремным комбинезоном",
		PREPOSITIONAL = "старом тюремном комбинезоне",
	)

/obj/item/clothing/under/prison
	name = "prison jumpsuit"
	desc = "Cтандартная одежда заключенных из \"Нанотрейзен\". Датчики костюма заблокированы в максимальном режиме отслеживания."
	icon_state = "prison"
	item_state = "prison"
	item_color = "prison"
	has_sensor = 2
	sensor_mode = 3
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/clothing/under/prison/get_ru_names()
	return list(
		NOMINATIVE = "тюремный комбинезон",
		GENITIVE = "тюремный комбинезон",
		DATIVE = "тюремному комбинезону",
		ACCUSATIVE = "тюремный комбинезон",
		INSTRUMENTAL = "тюремным комбинезоном",
		PREPOSITIONAL = "тюремном комбинезоне",
	)

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	icon_state = "/obj/item/clothing/under/color/pink"
	greyscale_colors = "#ffa69b"

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "/obj/item/clothing/under/color/red"
	greyscale_colors = "#eb0c07"

/obj/item/clothing/under/color/red/dodgeball
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/clothing/under/color/red/dodgeball/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "/obj/item/clothing/under/color/white"
	greyscale_colors = "#ffffff"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "/obj/item/clothing/under/color/yellow"
	greyscale_colors = "#ffe14d"

/obj/item/clothing/under/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	item_color = "psyche"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	greyscale_config_worn_species = null
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

/obj/item/clothing/under/color/lightblue
	name = "light blue jumpsuit"
	icon_state = "/obj/item/clothing/under/color/lightblue"
	greyscale_colors = "#6eb6ff"

/obj/item/clothing/under/color/aqua
	name = "aqua jumpsuit"
	icon_state = "/obj/item/clothing/under/color/aqua"
	greyscale_colors = "#00ffff"

/obj/item/clothing/under/color/purple
	name = "purple jumpsuit"
	icon_state = "/obj/item/clothing/under/color/purple"
	greyscale_colors = "#800080"

/obj/item/clothing/under/color/purple/sensor	//for jani ert
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW

/obj/item/clothing/under/color/lightpurple
	name = "light purple jumpsuit"
	icon_state = "/obj/item/clothing/under/color/lightpurple"
	greyscale_colors = "#9f70cc"

/obj/item/clothing/under/color/lightgreen
	name = "light green jumpsuit"
	icon_state = "/obj/item/clothing/under/color/lightgreen"
	greyscale_colors = "#90ee90"

/obj/item/clothing/under/color/lightbrown
	name = "light brown jumpsuit"
	icon_state = "/obj/item/clothing/under/color/lightbrown"
	greyscale_colors = "#c59431"

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	icon_state = "/obj/item/clothing/under/color/brown"
	greyscale_colors = "#a17229"

/obj/item/clothing/under/color/yellowgreen
	name = "yellow green jumpsuit"
	icon_state = "/obj/item/clothing/under/color/yellowgreen"
	greyscale_colors = "#9acd32"

/obj/item/clothing/under/color/darkblue
	name = "dark blue jumpskirt"
	icon_state = "/obj/item/clothing/under/color/darkblue"
	greyscale_colors = "#3285ba"

/obj/item/clothing/under/color/lightred
	name = "light red jumpsuit"
	icon_state = "/obj/item/clothing/under/color/lightred"
	greyscale_colors = "#ff6b6b"

/obj/item/clothing/under/color/darkred
	name = "dark red jumpsuit"
	icon_state = "/obj/item/clothing/under/color/darkred"
	greyscale_colors = "#8b0000"

/obj/item/clothing/under/color/red/jersey
	name = "red team jersey"
	desc = "The jersey of the Nanotrasen Phi-ghters!"
	icon = 'icons/obj/clothing/uniforms.dmi'
	icon_state = "redjersey"
	item_color = "redjersey"
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	greyscale_config_worn_species = null

/obj/item/clothing/under/color/blue/jersey
	name = "blue team jersey"
	desc = "The jersey of the Nanotrasen Pi-rates!"
	icon = 'icons/obj/clothing/uniforms.dmi'
	icon_state = "bluejersey"
	item_color = "bluejersey"
	flags = parent_type::flags | NO_NEW_GAGS_PREVIEW
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	greyscale_config_worn_species = null
