/obj/item/clothing/shoes/greaves_of_the_prophet
	name = "поножи пророка"
	ru_names = list(
		NOMINATIVE = "винтовка охотника на львов",
		GENITIVE = "винтовки охотника на львов",
		DATIVE = "винтовке охотника на львов",
		ACCUSATIVE = "винтовку охотника на львов",
		INSTRUMENTAL = "винтовкой охотника на львов",
		PREPOSITIONAL = "винтовке охотника на львов",
	)
	desc = "Грубые, изношенные железные башмаки. Кажется, что они прочнее, чем земля, по которой в них ходят. \
			Они покрыты тонким слоем ржавчины, и всё же, её вид почему-то успокивает вас."
	gender = PLURAL
	icon_state = "hereticgreaves"
	resistance_flags = ACID_PROOF | FIRE_PROOF | LAVA_PROOF


/obj/item/clothing/shoes/greaves_of_the_prophet/Initialize(mapload)
	. = ..()
	attach_clothing_traits(list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE, TRAIT_NO_SLIP_ALL))
