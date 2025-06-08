// Basic lighters
/obj/item/lighter
	name = "cheap lighter"
	desc = "Стандартная дешёвая зажигалка."
	icon = 'icons/obj/items.dmi'
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
		to_chat(user, span_notice("Вы зажгли [src]."))
	else if(HAS_TRAIT(user, TRAIT_BADASS))
		to_chat(user, span_notice("Как только вы зажгли [src], [genderize_ru(user.gender, "его", "её", "его", "их")] пламя окутывает вашу руку, но вы даже не дёрнулись."))
	else
		user.apply_damage(5, BURN, def_zone = user.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)	//INFERNO
		to_chat(user, span_notice("Вы зажгли [src], но в процессе обожгли себе руку."))
	if(world.time > next_on_message)
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
	to_chat(user, "<span class='notice'>Вы затушили [src.declent_ru(ACCUSATIVE)].")
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
		to_chat(user, span_notice("[cig.name] уже зажжена."))
		return return_flags

	if(target == user)
		return cig.attackby(src, user, params) | return_flags

	return_flags |= ATTACK_CHAIN_SUCCESS
	. = return_flags

	if(istype(src, /obj/item/lighter/zippo))
		cig.light(span_rose("[user] достает [name] и держит его у [target]. Рука [user.declent_ru(GENITIVE)] тверда, как негасимое пламя, которым [genderize_ru(living_pawn.gender, "он", "она", "оно", "они")] прикурива[pluralize_ru(user.gender, "ет", "ют")] [cig.declent_ru(ACCUSATIVE)]."))
	else
		cig.light(span_notice("[user] держит [name.declent_ru(ACCUSATIVE)] у [target.declent_ru(GENITIVE)], зажигая [cig.declent_ru(GENITIVE)]."))

	playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)
	target.update_inv_wear_mask()


/obj/item/lighter/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5)
	return

// Zippo lighters
/obj/item/lighter/zippo
	name = "Зажигалка Zippo"
	desc = "Металлическая бензиновая зажигалка Zippo."
	icon_state = "zippo"
	item_state = "zippo"
	icon_on = "zippoon"
	icon_off = "zippo"
	lefthand_file = 'icons/mob/inhands/zippo_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/zippo_righthand.dmi'


/obj/item/lighter/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		user.balloon_alert(user, "Потушите зажигалку!")
		return FALSE
	else
		return TRUE

/obj/item/lighter/zippo/turn_on_lighter(mob/living/user)
	. = ..()
	if(world.time > next_on_message)
		user.visible_message("<span class='rose'>Не отвлекаясь от дела, [user] одним плавным движением открывает и зажигает [src.declent_ru(ACCUSATIVE)].</span>")
		playsound(src.loc, 'sound/items/zippolight.ogg', 25, 1)
		next_on_message = world.time + 5 SECONDS
	else
		to_chat(user, "<span class='notice'>Вы зажигаете [src.declent_ru(ACCUSATIVE)].</span>")

/obj/item/lighter/zippo/turn_off_lighter(mob/living/user)
	. = ..()
	if(!user)
		return

	if(world.time > next_off_message)
		user.visible_message("<span class='rose'>Вы слышите тихий щелчок, когда [user] закрывает [src.declent_ru(ACCUSATIVE)], даже не обращая внимания на то, что дела[pluralize_ru(user.gender, "ет", "ют")]. Во дает.")
		playsound(src.loc, 'sound/items/zippoclose.ogg', 25, 1)
		next_off_message = world.time + 5 SECONDS
	else
		to_chat(user, "<span class='notice'>Вы закрываете [src.declent_ru(ACCUSATIVE)].")

/obj/item/lighter/zippo/show_off_message(mob/living/user)
	return

/obj/item/lighter/zippo/attempt_light(mob/living/user)
	return

//EXTRA LIGHTERS
/obj/item/lighter/zippo/nt_rep
	name = "gold engraved zippo"
	desc = "Золотая зажигалка Zippo с гравировкой и буквами NT на ней."
	icon_state = "zippo_nt_off"
	item_state = "ntzippo"
	icon_on = "zippo_nt_on"
	icon_off = "zippo_nt_off"

/obj/item/lighter/zippo/blue
	name = "blue zippo lighter"
	desc = "Зажигалка Zippo, сделанная из какого-то синего металла."
	icon_state = "bluezippo"
	item_state = "bluezippo"
	icon_on = "bluezippoon"
	icon_off = "bluezippo"

/obj/item/lighter/zippo/black
	name = "black zippo lighter"
	desc = "Чёрная зажигалка Zippo."
	icon_state = "blackzippo"
	item_state = "chapzippo"
	icon_on = "blackzippoon"
	icon_off = "blackzippo"

/obj/item/lighter/zippo/engraved
	name = "engraved zippo lighter"
	desc = "Зажигалка zippo с замысловатой гравировкой."
	icon_state = "engravedzippo"
	item_state = "engravedzippo"
	icon_on = "engravedzippoon"
	icon_off = "engravedzippo"

/obj/item/lighter/zippo/gonzofist
	name = "Gonzo Fist zippo"
	desc = "Зажигалка Zippo с культовым изображением Кулака Гонзо на матовой чёрной поверхности."
	icon_state = "gonzozippo"
	item_state = "gonzozippo"
	icon_on = "gonzozippoon"
	icon_off = "gonzozippo"

/obj/item/lighter/zippo/cap
	name = "Captain's zippo"
	desc = "Ограниченная серия золотых Zippo специально для капитанов НТ. Выглядит очень роскошно."
	icon_state = "zippo_cap"
	item_state = "capzippo"
	icon_on = "zippo_cap_on"
	icon_off = "zippo_cap"

/obj/item/lighter/zippo/hop
	name = "Head of personnel zippo"
	desc = "Ограниченная серия Zippo для Глав станций НаноТрейзен. Старается изо всех сил выглядеть как капитанская."
	icon_state = "zippo_hop"
	item_state = "hopzippo"
	icon_on = "zippo_hop_on"
	icon_off = "zippo_hop"

/obj/item/lighter/zippo/hos
	name = "Head of Security zippo"
	desc = "Ограниченная серия Zippo для Глав станций НаноТрейзен. Работает на клоунских слезах."
	icon_state = "zippo_hos"
	item_state = "hoszippo"
	icon_on = "zippo_hos_on"
	icon_off = "zippo_hos"

/obj/item/lighter/zippo/cmo
	name = "Chief Medical Officer zippo"
	desc = "Ограниченная серия Zippo для Глав станций НаноТрейзен. Сделано из гипоаллергенной стали."
	icon_state = "zippo_cmo"
	item_state = "bluezippo"
	icon_on = "zippo_cmo_on"
	icon_off = "zippo_cmo"

/obj/item/lighter/zippo/ce
	name = "Chief Engineer zippo"
	desc = "Ограниченная серия Zippo для глав станций НаноТрейзен. Оформленно в виде кристала суперматерии."
	icon_state = "zippo_ce"
	item_state = "cezippo"
	icon_on = "zippo_ce_on"
	icon_off = "zippo_ce"

/obj/item/lighter/zippo/rd
	name = "Research Director zippo"
	desc = "Ограниченная серия Zippo для глав станций НаноТрейзен. Работает на жидкой плазме."
	icon_state = "zippo_rd"
	item_state = "rdzippo"
	icon_on = "zippo_rd_on"
	icon_off = "zippo_rd"

/obj/item/lighter/zippo/qm
	name = "Quartermaster Lighter"
	desc = "Нужно 400.000 кредитов чтобы держать эту зажигалку включенной 12 секунд."
	icon_state = "zippo_qm"
	item_state = "qmzippo"
	icon_on = "zippo_qm_on"
	icon_off = "zippo_qm"

/obj/item/lighter/zippo/detective
	name = "Detective zippo"
	desc = "Лимитированная версия зажигалки Зиппо для детектива. Кажется, что её доставили прямиком из нуарных фильмов."
	ru_names = list(
		NOMINATIVE = "зажигалка Зиппо детектива",
		GENITIVE = "зажигалки Зиппо детектива",
		DATIVE = "зажигалке Зиппо детектива",
		ACCUSATIVE = "зажигалку Зиппо детектива",
		INSTRUMENTAL = "зажигалкой Зиппо детектива",
		PREPOSITIONAL = "зажигалке Зиппо детектива"
	)
	icon_state = "zippo_dec"
	item_state = "deczippo"
	icon_on = "zippo_dec_on"
	icon_off = "zippo_dec"

/obj/item/lighter/zippo/contractor
	name = "contractor zippo lighter"
	desc = "Уникальная чёрная Zippo с золотыми вкраплениями. Такие обычно достаются элите агентуры Синдиката.."
	icon_state = "contractorzippo"
	item_state = "contractorzippo"
	icon_on = "contractorzippoon"
	icon_off = "contractorzippo"

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

///////////
//MATCHES//
///////////
/obj/item/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = FALSE
	var/burnt = FALSE
	var/smoketime = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1"
	attack_verb = null
	pickup_sound = 'sound/items/handling/generic_small_pickup.ogg'
	drop_sound = 'sound/items/handling/generic_small_drop.ogg'


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
	item_state = lit ? "cigon" : "cigoff"


/obj/item/match/update_name(updates = ALL)
	. = ..()
	var/init_name = initial(name)
	name = lit ? "lit [init_name]" : burnt ? "burnt [init_name]" : initial(name)


/obj/item/match/update_desc(updates = ALL)
	. = ..()
	var/init_name = initial(name)
	desc = lit ? "A [init_name]. This one is lit." : burnt ? "A [init_name]. This one has seen better days." : initial(desc)

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
		to_chat(user, span_notice("The [cig.name] is already lit."))
		return return_flags

	if(target == user)
		return cig.attackby(src, user, params) | return_flags

	return_flags |= ATTACK_CHAIN_SUCCESS
	. = return_flags

	if(istype(src, /obj/item/match/unathi))
		if(prob(50))
			cig.light(span_rose("[user] spits fire at [target], lighting [cig] and nearly burning [user.p_their()] face!"))
			matchburnout()
		else
			cig.light(span_rose("[user] spits fire at [target], burning [user.p_their()] face and lighting [cig] in the process."))
			target.apply_damage(5, BURN, def_zone = BODY_ZONE_HEAD)
			playsound(src, 'sound/effects/unathiignite.ogg', 40, FALSE)
	else
		cig.light(span_notice("[user] holds [src] out for [target], and lights [cig]."))
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
	desc = "An unlit firebrand. It makes you wonder why it's not just called a stick."
	smoketime = 20 //40 seconds


/obj/item/match/firebrand/Initialize(mapload)
	. = ..()
	matchignite()


/obj/item/match/unathi
	name = "small blaze"
	desc = "A little flame of your own, currently located dangerously in your mouth."
	icon_state = "match_unathi"
	attack_verb = null
	force = 0
	item_flags = DROPDEL|ABSTRACT
	origin_tech = null
	lit = TRUE
	w_class = WEIGHT_CLASS_BULKY //to prevent it going to pockets


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

