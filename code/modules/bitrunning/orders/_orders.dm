#define BITRUNNER_ORDER_FLAIR "Flair"
#define BITRUNNER_ORDER_GEAR "Gear"
#define BITRUNNER_ORDER_TECH "Tech"

#define BITRUNNER_ORDER(order_name, object_type, price) order_name = new /datum/data/mining_equipment(order_name, object_type, price)

GLOBAL_LIST_INIT(bitrunner_order_items, list(
	BITRUNNER_ORDER_FLAIR = list(
		BITRUNNER_ORDER("Cornchips", /obj/item/reagent_containers/food/snacks/cornchips, 100),
		BITRUNNER_ORDER("Space Mountain Wind", /obj/item/reagent_containers/cup/soda_cans/space_mountain_wind, 100),
		BITRUNNER_ORDER("Thirteen Loko", /obj/item/reagent_containers/cup/soda_cans/thirteenloko, 200),
		BITRUNNER_ORDER("Heart Attack", /obj/item/reagent_containers/cup/soda_cans/energy, 200),
		BITRUNNER_ORDER("GreyPower", /obj/item/reagent_containers/cup/soda_cans/energy/grey, 200),
		BITRUNNER_ORDER("Sunglasses", /obj/item/clothing/glasses/sunglasses, 1000),
		BITRUNNER_ORDER("Brown Trenchcoat", /obj/item/clothing/suit/storage/browntrenchcoat, 1000),
		BITRUNNER_ORDER("Black Trenchcoat", /obj/item/clothing/suit/storage/blacktrenchcoat, 1000),
		BITRUNNER_ORDER("Jackboots", /obj/item/clothing/shoes/jackboots, 1000),
	),
	BITRUNNER_ORDER_GEAR = list(
		BITRUNNER_ORDER("Brute First-Aid Kit", /obj/item/storage/firstaid/brute, 500),
		BITRUNNER_ORDER("Fire First-Aid Kit", /obj/item/storage/firstaid/fire, 500),
		BITRUNNER_ORDER("Laser Pointer", /obj/item/laser_pointer, 750),
		BITRUNNER_ORDER("Personal AI Device", /obj/item/paicard, 1500),
	),
	BITRUNNER_ORDER_TECH = list(
		BITRUNNER_ORDER("Simple Gear Program", /obj/item/disk/bitrunning/item/tier1, 750),
		BITRUNNER_ORDER("Complex Gear Program", /obj/item/disk/bitrunning/item/tier2, 1250),
		BITRUNNER_ORDER("Advanced Gear Program", /obj/item/disk/bitrunning/item/tier3, 2000),
		BITRUNNER_ORDER("Basic Ability Program", /obj/item/disk/bitrunning/ability/tier1, 750),
		BITRUNNER_ORDER("Complex Ability Program", /obj/item/disk/bitrunning/ability/tier2, 1500),
		BITRUNNER_ORDER("Elite Ability Program", /obj/item/disk/bitrunning/ability/tier3, 2500),
		BITRUNNER_ORDER("Sports Gimmick Program", /obj/item/disk/bitrunning/gimmick/sports, 750),
		BITRUNNER_ORDER("Dungeon Gimmick Program", /obj/item/disk/bitrunning/gimmick/dungeon, 1250),
		BITRUNNER_ORDER("PKA Mod Program", /obj/item/disk/bitrunning/item/pka_mods, 750),
		BITRUNNER_ORDER("Premium PKA Mod Program", /obj/item/disk/bitrunning/item/pka_mods/premium, 1600),
		BITRUNNER_ORDER("PKC Mod Program", /obj/item/disk/bitrunning/item/pkc_mods, 750),
		BITRUNNER_ORDER("Premium PKC Mod Program", /obj/item/disk/bitrunning/item/pkc_mods/premium, 1600),
	),
))

#undef BITRUNNER_ORDER

/datum/supply_packs/bitrunning
	name = "HEADER"
	cost = 0
	containername = "NexaCache crate"
	containertype = /obj/structure/closet/crate/secure/bitrunning
	access = ACCESS_BITRUNNING
	hidden = TRUE
