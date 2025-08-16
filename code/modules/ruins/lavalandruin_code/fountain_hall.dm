/obj/structure/sacrificealtar
	name = "sacrificial altar"
	desc = "Алтарь, предназначенный для совершения кровавых жертвоприношений во имя божества."
	ru_names = list(
		NOMINATIVE = "жертвенный алтарь",
		GENITIVE = "жертвенного алтаря",
		DATIVE = "жертвенному алтарю",
		ACCUSATIVE = "жертвенный алтарь",
		INSTRUMENTAL = "жертвенным алтарем",
		PREPOSITIONAL = "жертвенном алтаре"
	)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	anchored = TRUE
	density = FALSE
	can_buckle = TRUE

/obj/structure/sacrificealtar/attack_hand(mob/living/user)
	if(user.incapacitated())
		return
	if(!has_buckled_mobs())
		return
	var/mob/living/L = locate() in buckled_mobs
	if(!L)
		return
	add_fingerprint(user)
	to_chat(user, span_notice("Вы пытаетесь принести [L.declent_ru(ACCUSATIVE)] в жертву, проводя ритуал жертвоприношения."))
	L.gib()
	message_admins("[ADMIN_LOOKUPFLW(user)] has sacrificed [key_name_admin(L)] on the sacrificial altar at [AREACOORD(src)].")

/obj/structure/healingfountain
	name = "healing fountain"
	desc = "Фонтан, содержащий воды жизни."
	ru_names = list(
		NOMINATIVE = "целебный фонтан",
		GENITIVE = "целебного фонтана",
		DATIVE = "целебному фонтану",
		ACCUSATIVE = "целебный фонтан",
		INSTRUMENTAL = "целебным фонтаном",
		PREPOSITIONAL = "целебном фонтане"
	)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "fountain"
	anchored = TRUE
	density = TRUE
	var/time_between_uses = 1800
	var/last_process = 0

/obj/structure/healingfountain/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(last_process + time_between_uses > world.time)
		to_chat(user, span_notice("Фонтан кажется пустым."))
		return
	last_process = world.time
	to_chat(user, span_notice("Вода кажется теплой и успокаивающей, когда вы касаетесь её. Фонтан мгновенно высыхает вскоре после этого."))
	user.reagents.add_reagent("godblood", 20)
	update_icon()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), UPDATE_ICON_STATE), time_between_uses)


/obj/structure/healingfountain/update_icon_state()
	if(last_process + time_between_uses > world.time)
		icon_state = "fountain"
	else
		icon_state = "fountain-red"
