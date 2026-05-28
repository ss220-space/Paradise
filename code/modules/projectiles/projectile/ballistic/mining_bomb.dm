/obj/projectile/bullet/reusable/mining_bomb
	name = "mining bomb"
	desc = "Это бомба. Может не стоит её так долго разглядывать?"
	icon_state = "mine_bomb"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	damage = 0
	range = 6
	flag = "bomb"
	light_range = 1
	light_color = LIGHT_COLOR_ORANGE
	ammo_type = /obj/structure/mining_bomb

/obj/projectile/bullet/reusable/mining_bomb/get_ru_names()
	return list(
		NOMINATIVE = "шахтёрская бомба",
		GENITIVE = "шахтёрской бомбы",
		DATIVE = "шахтёрскую бомбу",
		ACCUSATIVE = "шахтёрскую бомбу",
		INSTRUMENTAL = "шахтёрской бомбой",
		PREPOSITIONAL = "шахтёрской бомбе",
	)
