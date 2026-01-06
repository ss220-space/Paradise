#define SINGLE "1 блок"
#define VERTICAL "3 вертикально"
#define HORIZONTAL "3 горизонтально"

/obj/item/grenade/barrier
	name = "barrier grenade"
	desc = "Взрывчатое устройство, предназначенное для ручного подрыва. \
			Создаёт баррикаду на месте детонации. Поддерживает 3 режима развёртывания."
	icon_state = "barrier"
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	var/mode = SINGLE

/obj/item/grenade/barrier/get_ru_names()
	return list(
		NOMINATIVE = "барьерная граната",
		GENITIVE = "барьерной гранаты",
		DATIVE = "барьерной гранате",
		ACCUSATIVE = "барьерную гранату",
		INSTRUMENTAL = "барьерной гранатой",
		PREPOSITIONAL = "барьерной гранате"
	)

/obj/item/grenade/barrier/examine(mob/user)
	. = ..()
	. += span_notice("Используйте <b>Alt+ЛКМ</b> для переключения режима развёртывания.")

/obj/item/grenade/barrier/click_alt(mob/living/carbon/user)
	toggle_mode(user)
	return CLICK_ACTION_SUCCESS

/obj/item/grenade/barrier/proc/toggle_mode(mob/user)
	switch(mode)
		if(SINGLE)
			mode = VERTICAL
		if(VERTICAL)
			mode = HORIZONTAL
		if(HORIZONTAL)
			mode = SINGLE
	balloon_alert(user, "режим — [mode]")

/obj/item/grenade/barrier/prime()
	new /obj/structure/barricade/security(get_turf(loc))
	switch(mode)
		if(VERTICAL)
			var/turf/target_turf = get_step(src, NORTH)
			if(!target_turf.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf)

			var/turf/target_turf2 = get_step(src, SOUTH)
			if(!target_turf2.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf2)
		if(HORIZONTAL)
			var/turf/target_turf = get_step(src, EAST)
			if(!target_turf.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf)

			var/turf/target_turf2 = get_step(src, WEST)
			if(!target_turf2.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf2)
	qdel(src)

/obj/item/grenade/barrier/ui_action_click(mob/user, datum/action/action, leftclick)
	toggle_mode(user)

#undef SINGLE
#undef VERTICAL
#undef HORIZONTAL
