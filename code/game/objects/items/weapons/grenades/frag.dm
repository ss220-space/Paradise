/obj/item/grenade/frag
	name = "frag grenade"
	desc = "Взрывчатое устройство, предназначенное для ручного подрыва. При детонации создаёт \
			взрывную волну и выпускает множественные осколки."
	icon_state = "frag"
	origin_tech = "materials=3;magnets=4"
	det_time = 3 SECONDS
	shrapnel_type = /obj/projectile/shrapnel/grenade
	shrapnel_radius = 4
	var/range = 5

/obj/item/grenade/frag/get_ru_names()
	return alist(
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

/obj/item/grenade/frag/contact
	name = "contact frag grenade"
	desc = "Контактная осколочная граната. Взрывается по таймеру или при приземлении. При детонации \
			создаёт взрывную волну и выпускает множественные осколки."
	det_time = 5 SECONDS

/obj/item/grenade/frag/contact/get_ru_names()
	return alist(
		NOMINATIVE = "контактная осколочная граната",
		GENITIVE = "контактной осколочной гранаты",
		DATIVE = "контактной осколочной гранате",
		ACCUSATIVE = "контактную осколочную гранату",
		INSTRUMENTAL = "контактной осколочной гранатой",
		PREPOSITIONAL = "контактной осколочной гранате"
	)

/obj/item/grenade/frag/contact/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!active || !throwingdatum || QDELETED(src))
		return
	var/turf/impact_turf = get_turf(hit_atom)
	if(!impact_turf || is_space_or_openspace(impact_turf))
		return
	prime()

/obj/item/grenade/frag/contact/examine(mob/user)
	. = ..()
	. += span_notice("Таймер установлен на <b>[det_time/10]</b> секунд[DECL_U_Y_0(det_time/10)].")

/obj/item/grenade/frag/contact/screwdriver_act(mob/living/user, obj/item/I)
	return
