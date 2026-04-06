/* Utility Closets
 * Contains:
 *		Emergency Closet
 *		Fire Closet
 *		Tool Closet
 *		Radiation Closet
 *		Bombsuit Closet
 *		Hydrant
 *		First Aid
 */

/*
 * Emergency Closet
 */
/obj/structure/closet/emcloset
	name = "emergency closet"
	desc = "It's a storage unit for emergency breathmasks and o2 tanks."
	desc = "Это устройство для хранения респираторов и кислородных баллонов."
	icon_state = "emergency"

/obj/structure/closet/emcloset/get_ru_names()
    return list(
        NOMINATIVE = "аварийный шкафчик",
        GENITIVE = "аварийного шкафчика",
        DATIVE = "аварийному шкафчику",
        ACCUSATIVE = "аварийный шкафчик",
        INSTRUMENTAL = "аварийным шкафчиком",
        PREPOSITIONAL = "аварийном шкафчике",
    )

/obj/structure/closet/emcloset/anchored
	anchored = TRUE

/obj/structure/closet/emcloset/populate_contents()
	switch(pickweight(list("small" = 55, "aid" = 25, "tank" = 10, "both" = 10, "nothing" = 0, "delete" = 0)))
		if("small")
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/clothing/mask/breath(src)
		if("aid")
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/storage/toolbox/emergency(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/storage/firstaid/o2(src)
		if("tank")
			new /obj/item/tank/internals/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/tank/internals/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/breath(src)
		if("both")
			new /obj/item/storage/toolbox/emergency(src)
			new /obj/item/tank/internals/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/storage/firstaid/o2(src)

		// teehee - Ah, tg coders...
		if("delete")
			qdel(src) // Please make this use init hints its called from Initialize() I beg

/obj/structure/closet/emcloset/legacy/populate_contents()
	new /obj/item/tank/internals/oxygen(src)
	new /obj/item/clothing/mask/gas(src)

// MARK: Fire Closet
/obj/structure/closet/firecloset
	name = "fire-safety closet"
	desc = "It's a storage unit for fire-fighting supplies."
	desc = "Это устройство для хранения противопожарных принадлежностей."
	icon_state = "firecloset"

/obj/structure/closet/firecloset/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик пожарной безопасности",
        GENITIVE = "шкафчика пожарной безопасности",
        DATIVE = "шкафчику пожарной безопасности",
        ACCUSATIVE = "шкафчик пожарной безопасности",
        INSTRUMENTAL = "шкафчиком пожарной безопасности",
        PREPOSITIONAL = "шкафчике пожарной безопасности",
    )

/obj/structure/closet/firecloset/populate_contents()
	new /obj/item/extinguisher(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/clothing/head/hardhat/red(src)
	new /obj/item/crowbar/red(src)

/obj/structure/closet/firecloset/full/populate_contents()
	new /obj/item/extinguisher(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/flashlight(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/clothing/head/hardhat/red(src)
	new /obj/item/crowbar/red(src)


/*
 * Tool Closet
 */
/obj/structure/closet/toolcloset
	name = "tool closet"
	desc = "It's a storage unit for tools."
	desc = "Это устройство для хранения инструментов."
	icon_state = "toolcloset"

/obj/structure/closet/toolcloset/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для инструментов",
        GENITIVE = "шкафчика для инструментов",
        DATIVE = "шкафчику для инструментов",
        ACCUSATIVE = "шкафчик для инструментов",
        INSTRUMENTAL = "шкафчиком для инструментов",
        PREPOSITIONAL = "шкафчике для инструментов",
    )

/obj/structure/closet/toolcloset/populate_contents()
	if(prob(40))
		new /obj/item/clothing/suit/storage/hazardvest(src)
	if(prob(70))
		new /obj/item/flashlight(src)
	if(prob(70))
		new /obj/item/screwdriver(src)
	if(prob(70))
		new /obj/item/wrench(src)
	if(prob(70))
		new /obj/item/weldingtool(src)
	if(prob(70))
		new /obj/item/crowbar(src)
	if(prob(70))
		new /obj/item/wirecutters(src)
	if(prob(70))
		new /obj/item/t_scanner(src)
	if(prob(20))
		new /obj/item/storage/belt/utility(src)
	if(prob(30))
		new /obj/item/stack/cable_coil/random(src)
	if(prob(30))
		new /obj/item/stack/cable_coil/random(src)
	if(prob(30))
		new /obj/item/stack/cable_coil/random(src)
	if(prob(20))
		new /obj/item/multitool(src)
	if(prob(5))
		new /obj/item/clothing/gloves/color/yellow(src)
	if(prob(40))
		new /obj/item/clothing/head/hardhat(src)

/*
 * Radiation Closet
 */
/obj/structure/closet/radiation
	name = "radiation suit closet"
	desc = "It's a storage unit for rad-protective suits."
	desc = "Это устройство для хранения радзащитного саняржения."
	icon_state = "toolcloset"
	custom_door_overlay = "radsuit"

/obj/structure/closet/radiation/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для радзащитного снаряжения",
        GENITIVE = "шкафчика для радзащитного снаряжения",
        DATIVE = "шкафчику для радзащитного снаряжения",
        ACCUSATIVE = "шкафчик для радзащитного снаряжения",
        INSTRUMENTAL = "шкафчиком для радзащитного снаряжения",
        PREPOSITIONAL = "шкафчике для радзащитного снаряжения",
    )

/obj/structure/closet/radiation/populate_contents()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)

//EOD - Explosive Ordnance Disposal - translate by FUNNER

/*
 * Bombsuit closet
 */
/obj/structure/closet/bombcloset
	name = "EOD closet"
	desc = "It's a storage unit for explosion-protective suits."
	desc = "Это устройство для хранения взрывозащитных костюмов."
	icon_state = "bombsuit"

/obj/structure/closet/bombcloset/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для ОВУ",
        GENITIVE = "шкафчика для ОВУ",
        DATIVE = "шкафчику для ОВУ",
        ACCUSATIVE = "шкафчик для ОВУ",
        INSTRUMENTAL = "шкафчиком для ОВУ",
        PREPOSITIONAL = "шкафчике для ОВУ",
    )

/obj/structure/closet/bombcloset/populate_contents()
	new /obj/item/clothing/suit/bomb_suit( src )
	new /obj/item/clothing/under/color/black( src )
	new /obj/item/clothing/shoes/color/black( src )
	new /obj/item/clothing/head/bomb_hood( src )

/obj/structure/closet/bombclosetsecurity
	name = "EOD closet"
	desc = "It's a storage unit for explosion-protective suits."
	desc = "Это устройство для хранения взрывозащитных костюмов."
	icon_state = "bombsuitsec"

/obj/structure/closet/bombcloset/get_ru_names()
/obj/structure/closet/bombclosetsecurity/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для ОВУ",
        GENITIVE = "шкафчика для ОВУ",
        DATIVE = "шкафчику для ОВУ",
        ACCUSATIVE = "шкафчик для ОВУ",
        INSTRUMENTAL = "шкафчиком для ОВУ",
        PREPOSITIONAL = "шкафчике для ОВУ",
    )

/obj/structure/closet/bombclosetsecurity/populate_contents()
	new /obj/item/clothing/suit/bomb_suit/security( src )
	new /obj/item/clothing/under/rank/security( src )
	new /obj/item/clothing/shoes/color/brown( src )
	new /obj/item/clothing/head/bomb_hood/security( src )

/*
 * Hydrant
 */
/obj/structure/closet/hydrant //wall mounted fire closet
	name = "fire-safety closet"
	desc = "It's a storage unit for fire-fighting supplies."
	desc = "Это настенное устройство для хранения противопожарных принадлежностей."
	icon_state = "hydrant"
	anchored = TRUE
	density = FALSE
	wall_mounted = TRUE

/obj/structure/closet/hydrant/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик пожарной безопасности",
        GENITIVE = "шкафчика пожарной безопасности",
        DATIVE = "шкафчику пожарной безопасности",
        ACCUSATIVE = "шкафчик пожарной безопасности",
        INSTRUMENTAL = "шкафчиком пожарной безопасности",
        PREPOSITIONAL = "шкафчике пожарной безопасности",
    )

/obj/structure/closet/hydrant/populate_contents()
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/flashlight(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/extinguisher(src)
	new /obj/item/clothing/head/hardhat/red(src)

/*
 * First Aid
 */
/obj/structure/closet/medical_wall //wall mounted medical closet
	name = "first-aid closet"
	desc = "It's wall-mounted storage unit for first aid supplies."
	desc = "Это настенное устройство для хранения принадлежностей для оказания первой помощи."
	icon_state = "medical_wall"
	anchored = TRUE
	density = FALSE
	wall_mounted = TRUE

/obj/structure/closet/medical_wall/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик первой помощи",
        GENITIVE = "шкафчика первой помощи",
        DATIVE = "шкафчику первой помощи",
        ACCUSATIVE = "шкафчик первой помощи",
        INSTRUMENTAL = "шкафчиком первой помощи",
        PREPOSITIONAL = "шкафчике первой помощи",
    )
