/mob/living/simple_animal/human_lighter
	name = "human lighter"
	real_name = "человек-зажигала"
	desc = "Кожанная зажигалка."
	gender = MALE
	icon = 'icons/obj/lighters.dmi'
	icon_state = "human_zippo"
	icon_living = "human_zippo"
	icon_dead = "human_zippo"
	icon_resting = "human_zippo"
	speak_emote = list("скрипит")
	faction = list("neutral")
	tts_seed = "Gyro"
	maxHealth = 50
	health = 50
	blood_volume = BLOOD_VOLUME_SURVIVE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/humanoid/human = 1)
	response_help  = "гладит"
	response_disarm = "тычет пальцем в глаз"
	response_harm   = "бьёт"
	density = FALSE
	mobility_flags = NONE
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSMOB
	melee_damage_type = BRUTE
	melee_damage_lower = 2
	melee_damage_upper = 6
	attack_sound = 'sound/items/trayhit1.ogg'
	attacktext = "ударил"
	holder_type = /obj/item/holder/human_lighter
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 2
	light_on = FALSE
	var/lit = FALSE
	var/next_toggle

/mob/living/simple_animal/human_lighter/get_ru_names()
	return list(
		NOMINATIVE = "человек-зажигалка",
		GENITIVE = "человека-зажигалки",
		DATIVE = "человеку-зажигалке",
		ACCUSATIVE = "человека-зажигалку",
		INSTRUMENTAL = "человеком-зажигалкой",
		PREPOSITIONAL = "человеке-зажигалке",
	)

/mob/living/simple_animal/human_lighter/Initialize(mapload)
	. = ..()
	update_attack_params()
	update_icon()

/mob/living/simple_animal/human_lighter/update_icon()
	if(stat == DEAD)
		icon_state = "human_zippo"
		icon_living = "human_zippo"
		set_light_on(FALSE)
	else if(lit)
		icon_state = "human_zippo_on"
		icon_living = "human_zippo_on"
		set_light_on(TRUE)
	else
		icon_state = "human_zippo"
		icon_living = "human_zippo"
		set_light_on(FALSE)

	if(istype(loc, /obj/item/holder/human_lighter))
		var/obj/item/holder/human_lighter/H = loc
		if(H.lit != lit)
			H.lit = lit
			H.update_icon()

/mob/living/simple_animal/human_lighter/proc/update_attack_params()
	if(lit)
		melee_damage_type = BURN
		attack_sound = 'sound/items/welder.ogg'
		attacktext = "опалил"
	else
		melee_damage_type = BRUTE
		attack_sound = 'sound/items/trayhit1.ogg'
		attacktext = "ударил"

/mob/living/simple_animal/human_lighter/proc/toggle_lighter(mob/living/user)
	if((stat == DEAD) && user)
		user.balloon_alert(user, "мертв!")
		return

	if((next_toggle > world.time) && user)
		to_chat(user, span_warning("Зажигалка не готова к переключению!"))
		return

	if(!lit)
		turn_on_lighter(user)
		return

	turn_off_lighter(user)

/mob/living/simple_animal/human_lighter/proc/turn_on_lighter(mob/living/user)
	if((stat == DEAD) && user)
		user.balloon_alert(user, "мертв!")
		return

	if(lit)
		return

	lit = TRUE
	next_toggle = world.time + 5 SECONDS
	update_icon()
	update_attack_params()

	playsound(src, 'sound/goonstation/voice/male_scream.ogg', 25, TRUE)
	playsound(src, 'sound/items/zippolight.ogg', 25, TRUE)

	if(user)
		user.balloon_alert(user, "включено")

/mob/living/simple_animal/human_lighter/proc/turn_off_lighter(mob/living/user)
	if(!lit)
		return

	lit = FALSE
	next_toggle = world.time + 5 SECONDS
	update_icon()
	update_attack_params()

	playsound(src, 'sound/goonstation/voice/male_scream_reverse.ogg', 25, TRUE)
	playsound(src, 'sound/items/zippoclose.ogg', 25, TRUE)

	if(user)
		user.balloon_alert(user, "выключено")

/mob/living/simple_animal/human_lighter/death(gibbed)
	. = ..()
	if(.)
		if(lit)
			lit = FALSE
			update_icon()
			playsound(src, 'sound/items/zippoclose.ogg', 25, TRUE)

/mob/living/simple_animal/human_lighter/get_scooped(mob/living/carbon/grabber)
	var/obj/item/holder/H = ..()

	if(istype(H, /obj/item/holder/human_lighter))
		var/obj/item/holder/human_lighter/HL = H
		HL.lit = lit
		HL.update_icon()
		to_chat(grabber, span_notice("Вы подобрали [src]."))
	return H

/mob/living/simple_animal/human_lighter/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	..()

/mob/living/simple_animal/human_lighter/verb/toggle_lighter_verb()
	set name = "Переключить зажигалку"
	set category = STATPANEL_IC
	set src = usr

	if(usr != src)
		return

	if(world.time < next_toggle)
		return

	toggle_lighter(src)

/obj/item/holder/human_lighter
	name = "human lighter"
	desc = "Кожанная зажигалка."
	icon = 'icons/obj/lighters.dmi'
	icon_state = "human_zippo"
	item_state = "human_zippo"
	origin_tech = "biotech=2"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 2
	light_on = FALSE
	var/lit = FALSE

/obj/item/holder/human_lighter/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/holder/human_lighter/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/holder/human_lighter/update_icon()
	. = ..()
	if(lit)
		icon_state = "human_zippo_on"
		item_state = "human_zippo_on"
		set_light_on(TRUE)
	else
		icon_state = "human_zippo"
		item_state = "human_zippo"
		set_light_on(FALSE)

/obj/item/holder/human_lighter/get_heat()
	return lit * 1500

/obj/item/holder/human_lighter/attack_self(mob/living/user)
	var/mob/living/simple_animal/human_lighter/L = locate() in contents
	if(L)
		if(L.stat == DEAD)
			user.balloon_alert(user, "мертв!")
			return

		L.toggle_lighter(user)
		lit = L.lit
		update_icon()

/obj/item/holder/human_lighter/container_resist(mob/living/L)
	var/mob/living/simple_animal/human_lighter/HL = locate() in contents
	if(HL && HL.lit != lit)
		HL.lit = lit
		HL.update_icon()
	..()

/obj/item/holder/human_lighter/process()
	. = ..()

	var/mob/living/simple_animal/human_lighter/L = locate() in contents
	if(L)
		if(L.stat == DEAD && lit)
			lit = FALSE
			update_icon()

		else if(L.lit != lit)
			L.lit = lit
			L.update_icon()
