// Basic lighters
/obj/item/lighter
	name = "cheap lighter"
	desc = "Дешёвая пластиковая зажигалка."
	gender = FEMALE
	icon = 'icons/obj/lighters.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 4
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	attack_verb = null
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 2
	light_on = FALSE
	light_power = 1
	var/lit = FALSE
	var/icon_on = "lighter-g-on"
	var/icon_off = "lighter-g"
	/// Cooldown until the next turned on message/sound can be activated
	var/next_on_message
	/// Cooldown until the next turned off message/sound can be activated
	var/next_off_message

/obj/item/lighter/get_ru_names()
	return list(
		NOMINATIVE = "дешёвая зажигалка",
		GENITIVE = "дешёвой зажигалки",
		DATIVE = "дешёвой зажигалке",
		ACCUSATIVE = "дешёвую зажигалку",
		INSTRUMENTAL = "дешёвой зажигалкой",
		PREPOSITIONAL = "дешёвой зажигалке"
	)

/obj/item/lighter/random/New()
	..()
	var/color = pick("r","c","y","g")
	icon_on = "lighter-[color]-on"
	icon_off = "lighter-[color]"
	icon_state = icon_off

/obj/item/lighter/attack_self(mob/living/user)
	. = ..()
	if(!lit)
		turn_on_lighter(user)
	else
		turn_off_lighter(user)

/obj/item/lighter/get_heat()
	return lit * 1500

/obj/item/lighter/proc/turn_on_lighter(mob/living/user)
	lit = TRUE
	w_class = WEIGHT_CLASS_BULKY
	icon_state = icon_on
	force = 5
	damtype = BURN
	hitsound = 'sound/items/welder.ogg'
	attack_verb = list("подпалил", "опалил")

	attempt_light(user)
	set_light_on(TRUE)
	START_PROCESSING(SSobj, src)

/obj/item/lighter/proc/attempt_light(mob/living/user)
	if(prob(75) || issilicon(user)) // Robots can never burn themselves trying to light it.
		user.balloon_alert(user, "включено")
	else if(HAS_TRAIT(user, TRAIT_BADASS))
		user.balloon_alert(user, "включено")
		to_chat(user, span_notice("Как только вы зажгли [declent_ru(ACCUSATIVE)], [genderize_ru(user.gender, "его", "её", "его", "их")] пламя окутывает вашу руку, но вы даже не дёрнулись."))
	else
		user.balloon_alert(user, "включено")
		user.apply_damage(5, BURN, def_zone = user.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)	//INFERNO
		to_chat(user, span_notice("Вы зажгли [declent_ru(ACCUSATIVE)], но в процессе обожгли себе руку."))
	if(world.time > next_on_message)
		user.balloon_alert(user, "включено")
		playsound(src, 'sound/items/lighter/plastic_strike.ogg', 25, TRUE)
		next_on_message = world.time + 5 SECONDS

/obj/item/lighter/proc/turn_off_lighter(mob/living/user)
	lit = FALSE
	w_class = WEIGHT_CLASS_TINY
	icon_state = icon_off
	damtype = BRUTE
	hitsound = "swing_hit"
	force = 0
	attack_verb = null //human_defense.dm takes care of it

	show_off_message(user)
	set_light_on(FALSE)
	STOP_PROCESSING(SSobj, src)

/obj/item/lighter/extinguish_light(force = FALSE)
	if(!force)
		return
	turn_off_lighter()

/obj/item/lighter/proc/show_off_message(mob/living/user)
	user.balloon_alert(user, "выключено")
	if(world.time > next_off_message)
		playsound(src, 'sound/items/lighter/plastic_close.ogg', 25, TRUE)
		next_off_message = world.time + 5 SECONDS


/obj/item/lighter/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!lit)
		return ..()

	var/return_flags = ATTACK_CHAIN_PROCEED

	if(target.IgniteMob())
		return_flags |= ATTACK_CHAIN_SUCCESS
		add_attack_logs(user, target, "set on fire", ATKLOG_FEW)

	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH || !istype(target.wear_mask, /obj/item/clothing/mask/cigarette))
		return ..() | return_flags

	var/obj/item/clothing/mask/cigarette/cig = target.wear_mask
	if(cig.lit)
		user.balloon_alert(user, "сигарета уже горит!")
		return return_flags

	if(target == user)
		return cig.attackby(src, user, params) | return_flags

	return_flags |= ATTACK_CHAIN_SUCCESS
	. = return_flags

	if(istype(src, /obj/item/lighter/zippo))
		cig.light(span_rose("[user] доста[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] и держ[pluralize_ru(user.gender, "ит", "ат")] [src.declent_ru(gender, "его", "её", "его", "их")] у [target.declent_ru(GENITIVE)]. Рука [user] тверда, как немигающее пламя, которым [genderize_ru(user.gender, "он", "она", "оно", "они")] прикурива[pluralize_ru(user.gender, "ет", "ют")] [cig.declent_ru(ACCUSATIVE)]."))
	else
		cig.light(span_notice("[user] держ[pluralize_ru(user.gender, "ит", "ат")] [declent_ru(ACCUSATIVE)] у [target.declent_ru(GENITIVE)], зажигая [cig.declent_ru(GENITIVE)]."))

	playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)
	target.update_inv_wear_mask()


/obj/item/lighter/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5)
	return

// Zippo lighters
/obj/item/lighter/zippo
	name = "Зажигалка Зиппо"
	desc = "Металлическая бензиновая зажигалка Зиппо."
	icon_state = "zippo"
	item_state = "zippo"
	icon_on = "zippoon"
	icon_off = "zippo"
	lefthand_file = 'icons/mob/inhands/zippo_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/zippo_righthand.dmi'

/obj/item/lighter/zippo/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо",
		GENITIVE = "зажигалки Зиппо",
		DATIVE = "зажигалке Зиппо",
		ACCUSATIVE = "зажигалку Зиппо",
		INSTRUMENTAL = "зажигалкой Зиппо",
		PREPOSITIONAL = "зажигалке Зиппо"
	)

/obj/item/lighter/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		user.balloon_alert(user, "потушите зажигалку!")
		return FALSE
	else
		return TRUE

/obj/item/lighter/zippo/turn_on_lighter(mob/living/user)
	. = ..()
	user.balloon_alert(user, "включено")
	if(world.time > next_on_message)
		user.visible_message(span_rose("Не отвлекаясь от дела, [user] одним плавным движением открыва[pluralize_ru(user.gender, "ет", "ют")] и зажига[pluralize_ru(user.gender, "ет", "ют")] [src.declent_ru(ACCUSATIVE)]."))
		playsound(src.loc, 'sound/items/zippolight.ogg', 25, TRUE)
		next_on_message = world.time + 5 SECONDS

/obj/item/lighter/zippo/turn_off_lighter(mob/living/user)
	. = ..()
	if(!user)
		return
	user.balloon_alert(user, "выключено")
	if(world.time > next_off_message)
		user.visible_message(span_rose("Вы слышите тихий щелчок, когда [user] закрыва[pluralize_ru(user.gender, "ет", "ют")] [src.declent_ru(ACCUSATIVE)], даже не смотря в её сторону. Во даёт!"))
		playsound(src.loc, 'sound/items/zippoclose.ogg', 25, TRUE)
		next_off_message = world.time + 5 SECONDS

/obj/item/lighter/zippo/show_off_message(mob/living/user)
	return

/obj/item/lighter/zippo/attempt_light(mob/living/user)
	return

//EXTRA LIGHTERS
/obj/item/lighter/zippo/nt_rep
	name = "gold engraved zippo"
	desc = "Золотая зажигалка Зиппо с выгравированными буквами \"НТ\" на ней."
	icon_state = "zippo_nt_off"
	item_state = "ntzippo"
	icon_on = "zippo_nt_on"
	icon_off = "zippo_nt_off"

/obj/item/lighter/zippo/nt_rep/get_ru_names()
	return list(
		NOMINATIVE = "золотая зажигалка Зиппо",
		GENITIVE = "золотой зажигалки Зиппо",
		DATIVE = "золотой зажигалке Зиппо",
		ACCUSATIVE = "золотую зажигалку Зиппо",
		INSTRUMENTAL = "золотой зажигалкой Зиппо",
		PREPOSITIONAL = "золотой зажигалке Зиппо"
	)

/obj/item/lighter/zippo/blue
	name = "blue zippo lighter"
	desc = "Зажигалка Зиппо, сделанная из какого-то синего металла."
	icon_state = "bluezippo"
	item_state = "bluezippo"
	icon_on = "bluezippoon"
	icon_off = "bluezippo"

/obj/item/lighter/zippo/blue/get_ru_names()
	return list(
		NOMINATIVE = "синяя зажигалка Зиппо",
		GENITIVE = "синей зажигалки Зиппо",
		DATIVE = "синей зажигалке Зиппо",
		ACCUSATIVE = "синюю зажигалку Зиппо",
		INSTRUMENTAL = "синей зажигалкой Зиппо",
		PREPOSITIONAL = "синей зажигалке Зиппо"
	)

/obj/item/lighter/zippo/black
	name = "black zippo lighter"
	desc = "Чёрная зажигалка Зиппо."
	icon_state = "blackzippo"
	item_state = "chapzippo"
	icon_on = "blackzippoon"
	icon_off = "blackzippo"

/obj/item/lighter/zippo/black/get_ru_names()
	return list(
		NOMINATIVE = "чёрная зажигалка Зиппо",
		GENITIVE = "чёрной зажигалки Зиппо",
		DATIVE = "чёрной зажигалке Зиппо",
		ACCUSATIVE = "чёрную зажигалку Зиппо",
		INSTRUMENTAL = "чёрной зажигалкой Зиппо",
		PREPOSITIONAL = "чёрной зажигалке Зиппо"
	)

/obj/item/lighter/zippo/engraved
	name = "engraved zippo lighter"
	desc = "Зажигалка Зиппо с замысловатой гравировкой."
	icon_state = "engravedzippo"
	item_state = "engravedzippo"
	icon_on = "engravedzippoon"
	icon_off = "engravedzippo"

/obj/item/lighter/zippo/engraved/get_ru_names()
	return list(
		NOMINATIVE = "гравированная зажигалка Зиппо",
		GENITIVE = "гравированной зажигалки Зиппо",
		DATIVE = "гравированной зажигалке Зиппо",
		ACCUSATIVE = "гравированную зажигалку Зиппо",
		INSTRUMENTAL = "гравированной зажигалкой Зиппо",
		PREPOSITIONAL = "гравированной зажигалке Зиппо"
	)

/obj/item/lighter/zippo/gonzofist
	name = "Gonzo Fist zippo"
	desc = "Зажигалка Зиппо с культовым изображением Кулака Гонзо на матовой чёрной поверхности."
	icon_state = "gonzozippo"
	item_state = "gonzozippo"
	icon_on = "gonzozippoon"
	icon_off = "gonzozippo"

/obj/item/lighter/zippo/gonzofist/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо с кулаком Гонзо",
		GENITIVE = "зажигалки Зиппо с кулаком Гонзо",
		DATIVE = "зажигалке Зиппо с кулаком Гонзо",
		ACCUSATIVE = "зажигалку Зиппо с кулаком Гонзо",
		INSTRUMENTAL = "зажигалкой Зиппо с кулаком Гонзо",
		PREPOSITIONAL = "зажигалке Зиппо с кулаком Гонзо"
	)

/obj/item/lighter/zippo/cap
	name = "Captain's zippo"
	desc = "Ограниченная серия золотых Зиппо специально для капитанов станций НаноТрейзен. Выглядит очень роскошно."
	icon_state = "zippo_cap"
	item_state = "capzippo"
	icon_on = "zippo_cap_on"
	icon_off = "zippo_cap"

/obj/item/lighter/zippo/cap/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо Капитана",
		GENITIVE = "зажигалки Зиппо Капитана",
		DATIVE = "зажигалке Зиппо Капитана",
		ACCUSATIVE = "зажигалку Зиппо Капитана",
		INSTRUMENTAL = "зажигалкой Зиппо Капитана",
		PREPOSITIONAL = "зажигалке Зиппо Капитана"
	)

/obj/item/lighter/zippo/hop
	name = "Head of Personnel zippo"
	desc = "Ограниченная серия Зиппо для Глав станций НаноТрейзен. Старается изо всех сил выглядеть как капитанская."
	icon_state = "zippo_hop"
	item_state = "hopzippo"
	icon_on = "zippo_hop_on"
	icon_off = "zippo_hop"

/obj/item/lighter/zippo/hop/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо Главы Персонала",
		GENITIVE = "зажигалки Зиппо Главы Персонала",
		DATIVE = "зажигалке Зиппо Главы Персонала",
		ACCUSATIVE = "зажигалку Зиппо Главы Персонала",
		INSTRUMENTAL = "зажигалкой Зиппо Главы Персонала",
		PREPOSITIONAL = "зажигалке Зиппо Главы Персонала"
	)


/obj/item/lighter/zippo/hos
	name = "Head of Security zippo"
	desc = "Ограниченная серия Зиппо для Глав станций НаноТрейзен. Она просто не может не работать на крови и слезах клоунов."
	icon_state = "zippo_hos"
	item_state = "hoszippo"
	icon_on = "zippo_hos_on"
	icon_off = "zippo_hos"

/obj/item/lighter/zippo/hos/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо Главы Службы Безопасности",
		GENITIVE = "зажигалки Зиппо Главы Службы Безопасности",
		DATIVE = "зажигалке Зиппо Главы Службы Безопасности",
		ACCUSATIVE = "зажигалку Зиппо Главы Службы Безопасности",
		INSTRUMENTAL = "зажигалкой Зиппо Главы Службы Безопасности",
		PREPOSITIONAL = "зажигалке Зиппо Главы Службы Безопасности"
	)

/obj/item/lighter/zippo/cmo
	name = "Chief Medical Officer zippo"
	desc = "Ограниченная серия Зиппо для Глав станций НаноТрейзен. Сделано из гипоаллергенной стали."
	icon_state = "zippo_cmo"
	item_state = "bluezippo"
	icon_on = "zippo_cmo_on"
	icon_off = "zippo_cmo"

/obj/item/lighter/zippo/cmo/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо Главного Врача",
		GENITIVE = "зажигалки Зиппо Главного Врача",
		DATIVE = "зажигалке Зиппо Главного Врача",
		ACCUSATIVE = "зажигалку Зиппо Главного Врача",
		INSTRUMENTAL = "зажигалкой Зиппо Главного Врача",
		PREPOSITIONAL = "зажигалке Зиппо Главного Врача"
	)

/obj/item/lighter/zippo/ce
	name = "Chief Engineer zippo"
	desc = "Ограниченная серия Зиппо для глав станций НаноТрейзен. Выглядит совсем потрескавшейся."
	icon_state = "zippo_ce"
	item_state = "cezippo"
	icon_on = "zippo_ce_on"
	icon_off = "zippo_ce"

/obj/item/lighter/zippo/ce/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо Старшего Инженера",
		GENITIVE = "зажигалки Зиппо Старшего Инженера",
		DATIVE = "зажигалке Зиппо Старшего Инженера",
		ACCUSATIVE = "зажигалку Зиппо Старшего Инженера",
		INSTRUMENTAL = "зажигалкой Зиппо Старшего Инженера",
		PREPOSITIONAL = "зажигалке Зиппо Старшего Инженера"
	)

/obj/item/lighter/zippo/rd
	name = "Research Director zippo"
	desc = "Ограниченная серия Зиппо для глав станций НаноТрейзен. Работает на жидкой плазме."
	icon_state = "zippo_rd"
	item_state = "rdzippo"
	icon_on = "zippo_rd_on"
	icon_off = "zippo_rd"

/obj/item/lighter/zippo/rd/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо Научного Руководителя",
		GENITIVE = "зажигалки Зиппо Научного Руководителя",
		DATIVE = "зажигалке Зиппо Научного Руководителя",
		ACCUSATIVE = "зажигалку Зиппо Научного Руководителя",
		INSTRUMENTAL = "зажигалкой Зиппо Научного Руководителя",
		PREPOSITIONAL = "зажигалке Зиппо Научного Руководителя"
	)

/obj/item/lighter/zippo/qm
	name = "Quartermaster Lighter"
	desc = "Ограниченная серия Зиппо для глав станций НаноТрейзен. Нужно 400.000 кредитов, чтобы держать эту зажигалку включеной 12 секунд."
	icon_state = "zippo_qm"
	item_state = "qmzippo"
	icon_on = "zippo_qm_on"
	icon_off = "zippo_qm"

/obj/item/lighter/zippo/qm/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо Квартирмейстера",
		GENITIVE = "зажигалки Зиппо Квартирмейстера",
		DATIVE = "зажигалке Зиппо Квартирмейстера",
		ACCUSATIVE = "зажигалку Зиппо Квартирмейстера",
		INSTRUMENTAL = "зажигалкой Зиппо Квартирмейстера",
		PREPOSITIONAL = "зажигалке Зиппо Квартирмейстера"
	)

/obj/item/lighter/zippo/detective
	name = "Detective zippo"
	desc = "Лимитированная версия зажигалки Зиппо для детектива. Кажется, что её доставили прямиком из нуарных фильмов."
	icon_state = "zippo_dec"
	item_state = "deczippo"
	icon_on = "zippo_dec_on"
	icon_off = "zippo_dec"

/obj/item/lighter/zippo/detective/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо детектива",
		GENITIVE = "зажигалки Зиппо детектива",
		DATIVE = "зажигалке Зиппо детектива",
		ACCUSATIVE = "зажигалку Зиппо детектива",
		INSTRUMENTAL = "зажигалкой Зиппо детектива",
		PREPOSITIONAL = "зажигалке Зиппо детектива"
	)

/obj/item/lighter/zippo/contractor
	name = "contractor zippo lighter"
	desc = "Уникальная чёрная Zippo с золотыми вкраплениями. Такие обычно достаются элите агентуры Синдиката."
	icon_state = "contractorzippo"
	item_state = "contractorzippo"
	icon_on = "contractorzippoon"
	icon_off = "contractorzippo"

/obj/item/lighter/zippo/contractor/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо контрактора",
		GENITIVE = "зажигалки Зиппо контрактора",
		DATIVE = "зажигалке Зиппо контрактора",
		ACCUSATIVE = "зажигалку Зиппо контрактора",
		INSTRUMENTAL = "зажигалкой Зиппо контрактора",
		PREPOSITIONAL = "зажигалке Зиппо контрактора"
	)

//Ninja-Zippo//
/obj/item/lighter/zippo/ninja
	name = "\"Shinobi on a rice field\" zippo"
	desc = "Zippo, сделанная на заказ. Она выглядит практически как упаковка китайской лапши. На ней есть пятно крови, и от неё несёт горелым рисом..."
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "zippo_ninja"
	item_state = "zippo_ninja"
	icon_on = "zippo_ninja_on"
	icon_off = "zippo_ninja"

/obj/item/lighter/zippo/ninja/get_ru_names()
	return list(
		NOMINATIVE = "зажигалка Зиппо \"Шиноби в рисовом поле\"",
		GENITIVE = "зажигалки Зиппо \"Шиноби в рисовом поле\"",
		DATIVE = "зажигалке Зиппо \"Шиноби в рисовом поле\"",
		ACCUSATIVE = "зажигалку Зиппо \"Шиноби в рисовом поле\"",
		INSTRUMENTAL = "зажигалкой Зиппо \"Шиноби в рисовом поле\"",
		PREPOSITIONAL = "зажигалке Зиппо \"Шиноби в рисовом поле\""
	)

///////////
//MATCHES//
///////////
/obj/item/match
	name = "match"
	desc = "Обычная спичка, предназначенная для поджигания курительных смесей."
	gender = FEMALE
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	item_state = "match_unlit"
	var/lit = FALSE
	var/burnt = FALSE
	var/smoketime = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1"
	attack_verb = null
	pickup_sound = 'sound/items/handling/pickup/generic_small_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/generic_small_drop.ogg'

/obj/item/match/get_ru_names()
	return list(
		NOMINATIVE = "спичка",
		GENITIVE = "спички",
		DATIVE = "спичке",
		ACCUSATIVE = "спичку",
		INSTRUMENTAL = "спичкой",
		PREPOSITIONAL = "спичке"
	)


/obj/item/match/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		matchburnout()
	if(location)
		location.hotspot_expose(700, 5)


/obj/item/match/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	matchignite()


/obj/item/match/extinguish_light(force = FALSE)
	if(!force)
		return
	matchburnout()


/obj/item/match/update_icon_state()
	icon_state = lit ? "match_lit" : "match_burnt"
	item_state = lit ? "match_lit" : "match_burnt"


/obj/item/match/update_name(updates = ALL)
	. = ..()
	var/init_name = initial(name)
	name = lit ? "lit [init_name]" : burnt ? "burnt [init_name]" : initial(name)
	if(ru_names)
		if(lit)
			ru_names[NOMINATIVE] = "горящая спичка"
			ru_names[GENITIVE] = "горящей спички"
			ru_names[DATIVE] = "горящей спичке"
			ru_names[ACCUSATIVE] = "горящую спичку"
			ru_names[INSTRUMENTAL] = "горящей спичкой"
			ru_names[PREPOSITIONAL] = "горящей спичке"
		if(burnt)
			ru_names[NOMINATIVE] = "сгоревшая спичка"
			ru_names[GENITIVE] = "сгоревшей спички"
			ru_names[DATIVE] = "сгоревшей спичке"
			ru_names[ACCUSATIVE] = "сгоревшую спичку"
			ru_names[INSTRUMENTAL] = "сгоревшей спичкой"
			ru_names[PREPOSITIONAL] = "сгоревшей спичке"
		if(!lit && !burnt)
			ru_names = get_ru_names_cached()



/obj/item/match/update_desc(updates = ALL)
	. = ..()
	desc = lit ? "[capitalize(declent_ru(NOMINATIVE))], охваченная пламенем." : burnt ? "[capitalize(declent_ru(NOMINATIVE))]. Повидала всякое." : initial(desc)

/obj/item/match/get_heat()
	return lit * 1000

/obj/item/match/proc/matchignite()
	if(!lit && !burnt)
		lit = TRUE
		damtype = FIRE
		force = 3
		hitsound = 'sound/weapons/tap.ogg'
		attack_verb = list("подпалил","опалил")
		START_PROCESSING(SSobj, src)
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		return TRUE


/obj/item/match/proc/matchburnout()
	if(lit)
		lit = FALSE
		burnt = TRUE
		damtype = BRUTE
		force = initial(force)
		attack_verb = list("чиркнул")
		STOP_PROCESSING(SSobj, src)
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		return TRUE


/obj/item/match/dropped(mob/user, slot, silent = FALSE)
	matchburnout()
	. = ..()


/obj/item/match/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!lit)
		return ..()

	var/return_flags = ATTACK_CHAIN_PROCEED

	if(target.IgniteMob())
		return_flags |= ATTACK_CHAIN_SUCCESS
		add_attack_logs(user, target, "set on fire", ATKLOG_FEW)

	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(target)
	if(!cig || user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		return ..() | return_flags

	if(cig.lit)
		user.balloon_alert(user, "сигарета уже горит!")
		return return_flags

	if(target == user)
		return cig.attackby(src, user, params) | return_flags

	return_flags |= ATTACK_CHAIN_SUCCESS
	. = return_flags

	if(istype(src, /obj/item/match/unathi))
		if(prob(50))
			cig.light(span_rose("[user] изверга[pluralize_ru(user.gender, "ет", "ют")] пламя на [target.declent_ru(ACCUSATIVE)] и зажига[pluralize_ru(user.gender, "ет", "ют")] [cig.declent_ru(ACCUSATIVE)], чуть не опалив [genderize_ru(target.gender, "его", "её", "его", "их")] лицо!"))
			matchburnout()
		else
			cig.light(span_rose("[user] изверга[pluralize_ru(user.gender, "ет", "ют")] пламя на [target.declent_ru(ACCUSATIVE)] , опаливая [genderize_ru(target.gender, "его", "её", "его", "их")] лицо и зажигая [cig.declent_ru(ACCUSATIVE)]."))
			target.apply_damage(5, BURN, def_zone = BODY_ZONE_HEAD)
			playsound(src, 'sound/effects/unathiignite.ogg', 40, FALSE)
	else
		cig.light(span_notice("[user] держ[pluralize_ru(user.gender, "ит", "ат")] [declent_ru(ACCUSATIVE)] у [target.declent_ru(GENITIVE)], и зажига[pluralize_ru(user.gender, "ет", "ют")] [cig.declent_ru(ACCUSATIVE)]."))
		playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)


/obj/item/match/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(burnt)
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()


/obj/item/proc/help_light_cig(mob/living/M)
	var/mask_item = M.get_item_by_slot(ITEM_SLOT_MASK)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette))
		return mask_item


/obj/item/match/firebrand
	name = "firebrand"
	desc = "Незажжённая лучина. Интересно, почему её не называют просто палкой?"
	smoketime = 20 //40 seconds

/obj/item/match/firebrand/get_ru_names()
	return list(
		NOMINATIVE = "лучина",
		GENITIVE = "лучины",
		DATIVE = "лучине",
		ACCUSATIVE = "лучину",
		INSTRUMENTAL = "лучиной",
		PREPOSITIONAL = "лучине"
	)

/obj/item/match/firebrand/Initialize(mapload)
	. = ..()
	matchignite()


/obj/item/match/unathi
	name = "small blaze"
	desc = "Ваше собственное маленькое пламя, которое в данный момент находится прямо у вас во рту."
	icon_state = "match_unathi"
	attack_verb = null
	force = 0
	item_flags = DROPDEL|ABSTRACT
	origin_tech = null
	lit = TRUE
	w_class = WEIGHT_CLASS_BULKY //to prevent it going to pockets

/obj/item/match/unathi/get_ru_names()
	return list(
		NOMINATIVE = "маленькое пламя",
		GENITIVE = "маленького пламени",
		DATIVE = "маленькому пламени",
		ACCUSATIVE = "маленькое пламея",
		INSTRUMENTAL = "маленьким пламенем",
		PREPOSITIONAL = "маленьком плами"
	)


/obj/item/match/unathi/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/match/unathi/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	return	// we are already burning


/obj/item/match/unathi/matchburnout()
	if(!lit)
		return
	lit = FALSE //to avoid a qdel loop
	qdel(src)


/obj/item/match/unathi/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

