/obj/item/grenade/frag
	name = "frag grenade"
	desc = "Взрывчатое устройство, предназначенное для ручного подрыва. При детонации создаёт \
			взрывную волну и выпускает множественные осколки."
	icon_state = "frag"
	origin_tech = "materials=3;magnets=4"
	det_time = 3 SECONDS
	shrapnel_type = /obj/projectile/shrapnel
	shrapnel_radius = 4
	var/range = 5

/obj/item/grenade/frag/get_ru_names()
	return list(
		NOMINATIVE = "осколочная граната",
		GENITIVE = "осколочной гранаты",
		DATIVE = "осколочной гранате",
		ACCUSATIVE = "осколочную гранату",
		INSTRUMENTAL = "осколочной гранатой",
		PREPOSITIONAL = "осколочной гранате"
	)

/obj/item/grenade/frag/prime()
	. = ..()
	update_mob()
	explosion(loc, devastation_range = 0, heavy_impact_range = 1, light_impact_range = range, breach = FALSE, cause = src)
	qdel(src)
