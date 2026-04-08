/obj/structure/closet/malf/suits
	desc = "Это устройство для хранения снаряжения оперативников."
	icon_state = "syndicate"

/obj/structure/closet/malf/suits/populate_contents()
	new /obj/item/tank/jetpack/void(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/effect/nasavoidsuitspawner(src)
	new /obj/item/crowbar(src)
	new /obj/item/stock_parts/cell(src)
	new /obj/item/multitool(src)
