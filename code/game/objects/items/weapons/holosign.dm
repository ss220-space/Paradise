/obj/item/holosign_creator
	name = "holographic sign projector"
	desc = "Этого не должно быть, сообщите в баг-репорт."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker"
	item_state = "signmaker"
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	origin_tech = "magnets=1;programming=3"
	item_flags = NOBLUDGEON
	var/list/signs = list()
	var/max_signs = 10
	var/creation_time = 0 //time to create a holosign in deciseconds.
	var/holosign_type = /obj/structure/holosign/wetsign // because runtime if type == null
	var/holocreator_busy = FALSE //to prevent placing multiple holo barriers at once

/obj/item/holosign_creator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/holosign_creator/afterattack(atom/target, mob/user, flag, params)
	if(flag)
		if(!check_allowed_items(target, 1))
			return
		var/turf/T = get_turf(target)
		var/obj/structure/holosign/H = locate(holosign_type) in T
		if(H)
			to_chat(user, span_notice("Вы используете [declent_ru(NOMINATIVE)] для деактивации [H]."))
			qdel(H)
		else
			if(!T.is_blocked_turf(exclude_mobs = TRUE)) //can't put holograms on a tile that has dense stuff
				if(holocreator_busy)
					to_chat(user, span_notice("[declent_ru(NOMINATIVE)] занят созданием голограммы."))
					return
				if(signs.len < max_signs)
					playsound(src.loc, 'sound/machines/click.ogg', 20, 1)
					if(creation_time)
						holocreator_busy = TRUE
						if(!do_after(user, creation_time, target))
							holocreator_busy = FALSE
							return
						holocreator_busy = FALSE
						if(signs.len >= max_signs)
							return
						if(T.is_blocked_turf(exclude_mobs = TRUE)) //don't try to sneak dense stuff on our tile during the wait.
							return
					H = new holosign_type(get_turf(target), src)
					to_chat(user, span_notice("Вы создаете [H.declent_ru(NOMINATIVE)] с помощью [declent_ru(GENITIVE)]."))
					return H
				else
					to_chat(user, span_notice("[declent_ru(NOMINATIVE)] работает на максимальной мощности!"))


/obj/item/holosign_creator/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED


/obj/item/holosign_creator/attack_self(mob/user)
	if(signs.len)
		for(var/H in signs)
			qdel(H)
		balloon_alert(user, "голограммы удалены")

/obj/item/holosign_creator/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	afterattack(target, user, proximity_flag, click_parameters)

/obj/item/holosign_creator/janitor
	name = "голографический проектор уборщика"
	desc = "Удобный голографический проектор, отображающий знак уборщика."
	ru_names = list(
        NOMINATIVE = "голографический проектор уборщика",
        GENITIVE = "голографического проектора уборщика",
        DATIVE = "голографическому проектору уборщика",
        ACCUSATIVE = "голографический проектор уборщика",
        INSTRUMENTAL = "голографическим проектором уборщика",
        PREPOSITIONAL = "голографическом проекторе уборщика"
    )
	belt_icon = "sign_projector"
	holosign_type = /obj/structure/holosign/wetsign
	var/wet_enabled = TRUE

/obj/item/holosign_creator/janitor/click_alt(mob/living/user)
	wet_enabled = !wet_enabled
	playsound(loc, 'sound/weapons/empty.ogg', 20)
	if(wet_enabled)
		to_chat(user, span_notice("Вы активируете функцию W.E.T. (таймер влажного испарения)\nНовые голографические надписи исчезают, когда вымытая плитка полностью высыхает."))
	else
		to_chat(user, span_notice("Вы деактивируете функцию W.E.T. (таймер влажного испарения)\nНовые голографические вывески будут оставаться на месте без ограничений по времени."))
	return CLICK_ACTION_SUCCESS

/obj/item/holosign_creator/janitor/examine(mob/user)
	. = ..()
	. += span_info("Нажмите \"Alt-Click\", чтобы [wet_enabled ? "деактивировать" : "активировать"] встроенный таймер влажного испарения.")

/obj/item/holosign_creator/janitor/afterattack(atom/target, mob/user, flag, params)
	var/obj/structure/holosign/wetsign/WS = ..()
	if(WS && wet_enabled)
		WS.wet_timer_start(src)

/obj/item/holosign_creator/janitor/syndie
	holosign_type = /obj/structure/holosign/wetsign/mine
	creation_time = 5
	max_signs = 5
	wet_enabled = FALSE

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "Голографический проектор, который создает голографические барьеры службы безопасности."
	ru_names = list(
        NOMINATIVE = "проектор голобарьера службы безопасности",
        GENITIVE = "проектора голобарьера службы безопасности",
        DATIVE = "проектору голобарьера службы безопасности",
        ACCUSATIVE = "проектор голобарьера службы безопасности",
        INSTRUMENTAL = "проектором голобарьера службы безопасности",
        PREPOSITIONAL = "проекторе голобарьера службы безопасности"
    )
	icon_state = "signmaker_sec"
	item_state = "signmaker_sec"
	belt_icon = "security_sign_projector"
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 30
	max_signs = 6

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "Голографический проектор, который создает инженерные голографические барьеры."
	ru_names = list(
        NOMINATIVE = "инженерный проектор голобарьера",
        GENITIVE = "инженерного проектора голобарьера",
        DATIVE = "инженерному проектору голобарьера",
        ACCUSATIVE = "инженерный проектор голобарьера",
        INSTRUMENTAL = "инженерным проектором голобарьера",
        PREPOSITIONAL = "инженерном проекторе голобарьера"
    )
	icon_state = "signmaker_engi"
	item_state = "signmaker_engi"
	holosign_type = /obj/structure/holosign/barrier/engineering
	creation_time = 30
	max_signs = 6

/obj/item/holosign_creator/atmos
	name = "ATMOS holofan projector"
	desc = "Голографический проектор, создающий голографические барьеры, препятствующие изменению атмосферы."
	ru_names = list(
        NOMINATIVE = "атмосферный проектор голобарьера",
        GENITIVE = "атмосферного проектора голобарьера",
        DATIVE = "атмосферному проектору голобарьера",
        ACCUSATIVE = "атмосферный проектор голобарьера",
        INSTRUMENTAL = "атмосферным проектором голобарьера",
        PREPOSITIONAL = "атмосферном проекторе голобарьера"
    )
	icon_state = "signmaker_engi"
	item_state = "signmaker_engi"
	holosign_type = /obj/structure/holosign/barrier/atmos
	creation_time = 0
	max_signs = 3

/obj/item/holosign_creator/cyborg
	name = "Energy Barrier Projector"
	desc = "Голографический проектор, создающий хрупкие энергетические поля."
	ru_names = list(
        NOMINATIVE = "проектор энергетического барьера",
        GENITIVE = "проектора энергетического барьера",
        DATIVE = "проектору энергетического барьера",
        ACCUSATIVE = "проектор энергетического барьера",
        INSTRUMENTAL = "проектором энергетического барьера",
        PREPOSITIONAL = "проекторе энергетического барьера"
    )
	creation_time = 15
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg
	var/shock = 0

/obj/item/holosign_creator/cyborg/attack_self(mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user

		if(shock)
			balloon_alert(user, "голограммы удалены")
			holosign_type = /obj/structure/holosign/barrier/cyborg
			creation_time = 5
			if(signs.len)
				for(var/H in signs)
					qdel(H)
			shock = 0
			return
		else if(R.emagged && !shock)
			balloon_alert(user, "голограммы удалены")
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 30
			if(signs.len)
				for(var/H in signs)
					qdel(H)
			shock = 1
			return
		else
			if(signs.len)
				for(var/H in signs)
					qdel(H)
				balloon_alert(user, "голограммы удалены")
	if(signs.len)
		for(var/H in signs)
			qdel(H)
		balloon_alert(user, "голограммы удалены")
