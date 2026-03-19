/obj/item/weapons/tactical_hatchet
	name = "Tactical axe"
	desc = "Тактический топор из высокоуглеродистой стали и алюминиевого сплава. Смертельно опасен в умелых руках."
	icon = 'icons/mob/inhands/melee_lefthand.dmi'
	icon_state = "axe0"
	item_state = "axe0"
	belt_icon = "axe0"
	w_class = WEIGHT_CLASS_HUGE
	needs_permit = TRUE
	force = 30
	throwforce = 30
	throw_speed = 8
	throw_range = 8
	var/deflection_chance = 50
	var/reroute_deflection = TRUE
	block_chance = 75
	embed_chance = 50 //шанс застревания в теле не забыть поменять под БИ
	sharp = TRUE
	origin_tech = "combat=6;materials=5"
	attack_verb = list("ударил", "порезал", "полоснул", "рассёк")
	resistance_flags = FIRE_PROOF | ACID_PROOF

	var/hits_until_blunt = 3    //Про затупления тута
	var/current_hits = 0
	var/blunt = FALSE
	var/max_sharpness = 30
	var/min_sharpness = 15
	var/airlock_open_time = 100 //открытие шлюзов или типа того я на самом деле не знаю делает ли это хоть что-нибудь |
	var/active = FALSE
	var/last_trip = 0
	var/cooldown = 7 SECONDS
	var/force_before = 30

/obj/item/weapons/tactical_hatchet/get_ru_names()
	return list(
		NOMINATIVE = "тактический топор",
		GENITIVE = "тактического топора",
		DATIVE = "тактическому топору",
		ACCUSATIVE = "тактический топор",
		INSTRUMENTAL = "тактическим топором",
		PREPOSITIONAL = "тактическому топору",
	)

/obj/item/weapons/tactical_hatchet/proc/blunted()
	blunt = TRUE
	force = min_sharpness
	desc = "Тактический топор из высокоуглеродистой стали и алюминиевого сплава. Смертельно опасен в умелых руках. Кажется, он немного затупился..."
	playsound(src, 'sound/weapons/Tactical_hatchet1.ogg', 75, TRUE)

/obj/item/weapons/tactical_hatchet/attack(mob/living/target, mob/living/user)
	. = ..()
	if(!.)
		return
	current_hits++
	if(current_hits >= hits_until_blunt && !blunt)
		blunted()
	if (blunt)
		force = min_sharpness
	else
		force = max_sharpness

/obj/item/weapons/tactical_hatchet/proc/sharpen()
	blunt = FALSE
	current_hits = 0
	force = max_sharpness
	desc = "Тактический топор из высокоуглеродистой стали и алюминиевого сплава. Смертельно опасен в умелых руках."
	playsound(src, 'sound/weapons/Tactical_hatchet_sharpen.ogg', 75, TRUE)

/obj/item/weapons/tactical_hatchet/attack(mob/living/target, mob/living/user)
	if(user.a_intent == INTENT_DISARM)
		if(world.time >= last_trip + cooldown)
			last_trip = world.time
			var/force_before = force
			force *= 0.7
			. = ..()
			force = force_before
			if(!.)
				return
			target.Knockdown(4 SECONDS)
			user.visible_message(span_danger("[user] подсекает [target] обухом топора"))
			shake_camera(target, 4, 2)
			hitsound = 'sound/weapons/Tactical_hatchet3.ogg' //не забыть проверить как это сработает
			playsound(src, 'sound/weapons/Tactical_hatchet3.ogg', 75, TRUE)
			return
		else
			return . =..()
	. =..()


/obj/item/weapons/tactical_hatchet/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(is_airlock(target))
		var/obj/machinery/door/airlock/airlock = target

		if(!airlock.requiresID() || airlock.allowed(user))
			return

		if(airlock.locked)
			to_chat(user, span_notice("Болты шлюза не позволяют открыть его."))
			return

		if(airlock.arePowerSystemsOn())
			user.visible_message(span_warning("[user] вставляет [src] в шлюз, и пытается открыть его!"), \
								span_warning("Попытка открыть шлюз..."), \
								span_italics("Вы слышите металлический лязг."))

			playsound(airlock, 'sound/machines/airlock_alien_prying.ogg', 150, TRUE)
			if(!do_after(user, 1.5 SECONDS, airlock))
				return

		user.visible_message(span_warning("[user] открывает шлюз с помощью [user.p_their()] [name]!"), \
							span_warning("Шлюз поддался"), \
							span_warning("Вы слышите металлический лязг."))
		airlock.open(2)

/obj/item/weapons/tactical_hatchet/afterattack(obj/item/I, mob/user, proximity)  //это чтобы топором можно было кликнуть по точилке и заточить мне лень думать как сделать иначе
	if(!proximity)
		return

	if(istype(I, /obj/item/weapons/tactical_sharpener))

		if(!blunt)
			to_chat(user, "Топор уже заточен.")
			return

		to_chat(user, "Вы затачиваете топор.")
		sharpen()
		balloon_alert(user, "Заточка...")
		if(!do_after(user, 2 SECONDS, user, DA_IGNORE_USER_LOC_CHANGE | DA_IGNORE_LYING))     //тут прогрессбары и задержки заточки
			return

var/list/blacklist_items = list(/obj/item/shield, /obj/item/melee/rapier) //вещи запрещенные на юз с топором рапиры и щиты
