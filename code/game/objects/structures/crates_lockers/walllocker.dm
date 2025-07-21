//added by cael from old bs12
//not sure if there's an immediate place for secure wall lockers, but i'm sure the players will think of something

/obj/structure/closet/walllocker
	name = "wall locker"
	desc = "Небольшой шкафчик, устанавливаемый на стены. \
			Предназначен для хранения различных предметов. \
			Изготовлен из прочного металла, устойчивого к различным повреждениям. \
			Достаточно вместительный."
	ru_names = list(
		NOMINATIVE = "настенный шкафчик",
		GENITIVE = "настенного шкафчика",
		DATIVE = "настенному шкафчику",
		ACCUSATIVE = "настенный шкафчик",
		INSTRUMENTAL = "настенным шкафчиком",
		PREPOSITIONAL = "настенном шкафчике"
	)
	icon = 'icons/obj/walllocker.dmi'
	icon_state = "wall-locker"
	density = FALSE
	anchored = TRUE
	ignore_density_closed = TRUE
	no_overlays = TRUE
	icon_closed = "wall-locker"
	icon_opened = "wall-lockeropen"

/obj/structure/closet/walllocker/emerglocker
	name = "emergency locker"
	desc = "Небольшой шкафчик, устанавливаемый на стены. \
			Предназначен для хранения оборудования на случай чрезвычайной ситуации. \
			Изготовлен из прочного металла, устойчивого к различным повреждениям. \
			Достаточно вместительный."
	ru_names = list(
		NOMINATIVE = "аварийный настенный шкафчик",
		GENITIVE = "аварийного настенного шкафчика",
		DATIVE = "аварийному настенному шкафчику",
		ACCUSATIVE = "аварийный настенный шкафчик",
		INSTRUMENTAL = "аварийным настенным шкафчиком",
		PREPOSITIONAL = "аварийном настенном шкафчике"
	)
	icon_state = "emerg"
	icon_closed = "emerg"
	icon_opened = "emergopen"


/obj/structure/closet/walllocker/emerglocker/populate_contents()
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/crowbar(src)
	new /obj/item/crowbar(src)
	new /obj/item/crowbar(src)

/obj/structure/closet/walllocker/emerglocker/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/emerglocker/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/emerglocker/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/emerglocker/east
	pixel_x = 32
	dir = EAST
