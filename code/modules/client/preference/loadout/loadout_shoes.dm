/datum/gear/shoes
	subtype_path = /datum/gear/shoes
	slot = ITEM_SLOT_FEET
	sort_category = "Shoes"

/datum/gear/shoes/sandals
	display_name = "sandals, wooden"
	path = /obj/item/clothing/shoes/sandal

/datum/gear/shoes/winterboots
	display_name = "winter boots"
	path = /obj/item/clothing/shoes/winterboots

/datum/gear/shoes/workboots
	display_name = "work boots"
	path = /obj/item/clothing/shoes/workboots

/datum/gear/shoes/leather
	display_name = "leather shoes"
	path = /obj/item/clothing/shoes/leather

/datum/gear/shoes/fancysandals
	display_name = "sandals, fancy"
	path = /obj/item/clothing/shoes/sandal/fancy

/datum/gear/shoes/dressshoes
	display_name = "dress shoes"
	path = /obj/item/clothing/shoes/centcom

/datum/gear/shoes/cowboyboots
	display_name = "cowboy boots, select"
	path = /obj/item/clothing/shoes/cowboy

/datum/gear/shoes/cowboyboots/New()
	..()
	var/list/boots = list("brown" = /obj/item/clothing/shoes/cowboy,
						  "black" = /obj/item/clothing/shoes/cowboy/black,
						  "white" = /obj/item/clothing/shoes/cowboy/white,
						  "pink" = /obj/item/clothing/shoes/cowboy/pink,)
	gear_tweaks += new /datum/gear_tweak/path(boots, src)

/datum/gear/shoes/jackboots
	display_name = "jackboots"
	path = /obj/item/clothing/shoes/jackboots

/datum/gear/shoes/jacksandals
	display_name = "jacksandals"
	path = /obj/item/clothing/shoes/jackboots/jacksandals

/datum/gear/shoes/laceup
	display_name = "laceup shoes"
	path = /obj/item/clothing/shoes/laceup

/datum/gear/shoes/shoes
	display_name = "shoes, select"
	path = /obj/item/clothing/shoes/black

/datum/gear/shoes/shoes/New()
	..()
	var/list/boots = list(/obj/item/clothing/shoes/black,
						  /obj/item/clothing/shoes/brown,
						  /obj/item/clothing/shoes/white)
	gear_tweaks += new /datum/gear_tweak/path(boots, src, TRUE)

/datum/gear/shoes/jackcross
	display_name = "jackcross"
	path = /obj/item/clothing/shoes/jackboots/cross

/datum/gear/shoes/leather_boots
	display_name = "high leather boots"
	path = /obj/item/clothing/shoes/leather_boots

/datum/gear/shoes/footwraps
	display_name = "cloth footwraps, select"
	path = /obj/item/clothing/shoes/footwraps

/datum/gear/shoes/footwraps/New()
	..()
	var/list/feet = list("classic" = /obj/item/clothing/shoes/footwraps,
						 "yellow" = /obj/item/clothing/shoes/footwraps/yellow,
						 "silver" = /obj/item/clothing/shoes/footwraps/silver,
						 "red" = /obj/item/clothing/shoes/footwraps/red,
						 "blue" = /obj/item/clothing/shoes/footwraps/blue,
						 "black" = /obj/item/clothing/shoes/footwraps/black,
						 "brown" = /obj/item/clothing/shoes/footwraps/brown,
						 )
	gear_tweaks += new /datum/gear_tweak/path(feet, src)
