/obj/item/storage/backpack/vox
	name = "vox backpack"
	desc = "Рюкзак воксов из плотно переплетенного синтетического волокна. Хорошо защищает спину носителя при побегах и вмещает достаточно добра."
	icon_state = "backpack_vox"
	item_color = "backpack_vox"
	item_state = "backpack_vox"
	icon = 'icons/obj/clothing/species/vox/storage.dmi'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/back.dmi',
	)
	armor = list(MELEE = 5, BULLET = 5, LASER = 15, ENERGY = 10, BOMB = 10, FIRE = 60, ACID = 50)
	resistance_flags = FIRE_PROOF
	origin_tech = "syndicate=1"
	max_combined_w_class = 35

/obj/item/storage/backpack/satchel_flat/vox
	name = "vox satchel"
	desc = "Ранец воксов из синтетического волокна. Компактный, из-за чего его можно отлично прятать."
	icon_state = "satchel_vox"
	item_color = "satchel_vox"
	item_state = "satchel_vox"
	icon = 'icons/obj/clothing/species/vox/storage.dmi'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/back.dmi',
	)
	resistance_flags = FIRE_PROOF
	origin_tech = "syndicate=1"
	max_combined_w_class = 25

/obj/item/storage/backpack/duffel/vox
	name = "vox duffelbag"
	desc = "Сумка воксов из синтетического волокна. Емкий, вмещает много добра."
	icon_state = "duffel_vox"
	item_color = "duffel_vox"
	item_state = "duffel_vox"
	icon = 'icons/obj/clothing/species/vox/storage.dmi'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/back.dmi',
	)
	silent = TRUE
	resistance_flags = FIRE_PROOF
	origin_tech = "syndicate=1"
	max_combined_w_class = 45
	cant_hold = list(/obj/item/storage/backpack)

/obj/item/storage/belt/vox
	name = "vox belt"
	desc = "Удобный пояс с петельками для ношения всячины."
	icon_state = "securitybelt"
	item_state = "security"
	origin_tech = "syndicate=1"
	max_w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	use_item_overlays = TRUE // Will show the tools on the sprite
	max_combined_w_class = 25
	can_hold = list(
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/grenade,
		/obj/item/flash,
		/obj/item/kitchen/knife/combat,
		/obj/item/melee/baton,
		/obj/item/flashlight,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/restraints/handcuffs,
		/obj/item/biocore,
		/obj/item/stock_parts/cell/vox_spike,
		/obj/item/jammer,
	)

/obj/item/storage/belt/vox/bio
	name = "bio-vox belt"
	desc = "Удобный пояс с плетенными кармашками для ношения ядер, взрывчатки и шприцов."
	icon_state = "assaultbelt"
	item_state = "assault"
	storage_slots = 21
	max_combined_w_class = 45
	can_hold = list(
		/obj/item/grenade,
		/obj/item/flash,
		/obj/item/storage/dart_cartridge,
		/obj/item/biocore,
		/obj/item/reagent_containers/iv_bag/blood,
		/obj/item/reagent_containers/syringe,
	)
