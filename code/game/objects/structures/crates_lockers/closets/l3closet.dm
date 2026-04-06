/obj/structure/closet/l3closet
	name = "level-3 biohazard suit closet"
	desc = "It's a storage unit for level-3 biohazard gear."
	desc = "Это устройство для хранения биозащитного снаряжения 3 уровня."
	icon_state = "bio"

/obj/structure/closet/l3closet/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для биозащитного снаряжения 3 уровня",
        GENITIVE = "шкафчика для биозащитного снаряжения 3 уровня",
        DATIVE = "шкафчику для биозащитного снаряжения 3 уровня",
        ACCUSATIVE = "шкафчик для биозащитного снаряжения 3 уровня",
        INSTRUMENTAL = "шкафчиком для биозащитного снаряжения 3 уровня",
        PREPOSITIONAL = "шкафчике для биозащитного снаряжения 3 уровня",
    )

/obj/structure/closet/l3closet/populate_contents()
	new /obj/item/storage/bag/bio( src )
	new /obj/item/clothing/suit/bio_suit/general( src )
	new /obj/item/clothing/head/bio_hood/general( src )

/obj/structure/closet/l3closet/general

/obj/structure/closet/l3closet/general/populate_contents()
	new /obj/item/clothing/suit/bio_suit/general( src )
	new /obj/item/clothing/head/bio_hood/general( src )

/obj/structure/closet/l3closet/virology
	icon_state = "bio_virology"

/obj/structure/closet/l3closet/virology/populate_contents()
	new /obj/item/storage/bag/bio( src )
	new /obj/item/clothing/suit/bio_suit/virology( src )
	new /obj/item/clothing/head/bio_hood/virology( src )
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)

/obj/structure/closet/l3closet/security
	icon_state = "bio_security"

/obj/structure/closet/l3closet/security/populate_contents()
	new /obj/item/clothing/suit/bio_suit/security( src )
	new /obj/item/clothing/head/bio_hood/security( src )

/obj/structure/closet/l3closet/janitor
	icon_state = "bio_janitor"

/obj/structure/closet/l3closet/janitor/populate_contents()
	new /obj/item/clothing/suit/bio_suit/janitor( src )
	new /obj/item/clothing/head/bio_hood/janitor( src )

/obj/structure/closet/l3closet/scientist
	icon_state = "bio_scientist"

/obj/structure/closet/l3closet/scientist/populate_contents()
	new /obj/item/storage/bag/bio( src )
	new /obj/item/clothing/suit/bio_suit/scientist( src )
	new /obj/item/clothing/head/bio_hood/scientist( src )
