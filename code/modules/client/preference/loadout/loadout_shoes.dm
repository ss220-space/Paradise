/datum/gear/shoes
	subtype_path = /datum/gear/shoes
	slot = ITEM_SLOT_FEET
	sort_category = "Shoes"

/datum/gear/shoes/sandals
	index_name = "sandals, wooden"
	path = /obj/item/clothing/shoes/sandal

/datum/gear/shoes/winterboots
	index_name = "winter boots"
	path = /obj/item/clothing/shoes/winterboots

/datum/gear/shoes/workboots
	index_name = "work boots"
	path = /obj/item/clothing/shoes/workboots

/datum/gear/shoes/leather
	index_name = "leather shoes"
	path = /obj/item/clothing/shoes/leather

/datum/gear/shoes/fancysandals
	index_name = "sandals, fancy"
	path = /obj/item/clothing/shoes/sandal/fancy

/datum/gear/shoes/dressshoes
	index_name = "dress shoes"
	path = /obj/item/clothing/shoes/centcom

/datum/gear/shoes/cowboyboots
	index_name = "cowboy boots, select"
	display_name = "cowboy boots"
	path = /obj/item/clothing/shoes/cowboy

/datum/gear/shoes/cowboyboots/New()
	..()
	var/list/boots = list("brown" = /obj/item/clothing/shoes/cowboy,
						  "black" = /obj/item/clothing/shoes/cowboy/black,
						  "white" = /obj/item/clothing/shoes/cowboy/white,
						  "pink" = /obj/item/clothing/shoes/cowboy/pink,)
	gear_tweaks += new /datum/gear_tweak/path(boots, src)

/datum/gear/shoes/jackboots
	index_name = "jackboots"
	path = /obj/item/clothing/shoes/jackboots

/datum/gear/shoes/jacksandals
	index_name = "jacksandals"
	path = /obj/item/clothing/shoes/jackboots/jacksandals

/datum/gear/shoes/laceup
	index_name = "laceup shoes"
	path = /obj/item/clothing/shoes/laceup

/datum/gear/shoes/shoes
	index_name = "shoes, select"
	display_name = "shoes"
	path = /obj/item/clothing/shoes/black

/datum/gear/shoes/shoes/New()
	..()
	var/list/boots = list(/obj/item/clothing/shoes/black,
						  /obj/item/clothing/shoes/brown,
						  /obj/item/clothing/shoes/white)
	gear_tweaks += new /datum/gear_tweak/path(boots, src, TRUE)

/datum/gear/shoes/jackcross
	index_name = "jackcross"
	path = /obj/item/clothing/shoes/jackboots/cross

/datum/gear/shoes/leather_boots
	index_name = "high leather boots"
	path = /obj/item/clothing/shoes/leather_boots

/datum/gear/shoes/footwraps
	index_name = "cloth footwraps, color"
	path = /obj/item/clothing/shoes/footwraps

/datum/gear/shoes/footwraps/New()
	..()
	gear_tweaks += new /datum/gear_tweak/color(parent = src)
