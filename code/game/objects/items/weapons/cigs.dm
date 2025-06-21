/*
CONTENTS:
1. CIGARETTES
2. CIGARS
3. HOLO-CIGAR
4. PIPES
5. ROLLING

CIGARETTE PACKETS ARE IN FANCY.DM
LIGHTERS ARE IN LIGHTERS.DM
*/

//////////////////
//FINE SMOKABLES//
//////////////////

/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "Закрученный в бумагу табак."
	ru_names = list(
		NOMINATIVE = "сигарета",
		GENITIVE = "сигареты",
		DATIVE = "сигарете",
		ACCUSATIVE = "сигарету",
		INSTRUMENTAL = "сигаретой",
		PREPOSITIONAL = "сигарете"
	)
	gender = FEMALE
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_EARS
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	attack_verb = null
	container_type = INJECTABLE
	undyeable = TRUE
	/// Is the cigarette lit?
	var/lit = FALSE
	/// Lit cigarette sprite.
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	/// Unlit cigarette sprite.
	var/icon_off = "cigoff"
	/// Are we an extra-classy smokable?
	var/fancy = FALSE
	/// What trash item the cigarette makes when it burns out.
	var/type_butt = /obj/item/cigbutt
	/// How long does the cigarette last before going out? Decrements by 1 every cycle.
	var/smoketime = 150 // 300 seconds.
	/// The cigarette's total reagent capacity.
	var/chem_volume = 60
	var/list/list_reagents = list("nicotine" = 40)
	/// Has anyone taken any reagents from the cigarette? The first tick gives a bigger dose.
	var/first_puff = TRUE

	pickup_sound = 'sound/items/handling/generic_small_pickup.ogg'
	drop_sound = 'sound/items/handling/generic_small_drop.ogg'
	equip_sound = 'sound/items/handling/generic_equip5.ogg'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID =  'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi'
	)


/obj/item/clothing/mask/cigarette/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 30
	reagents.set_reacting(FALSE) // so it doesn't react until you light it
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/clothing/mask/cigarette/Destroy()
	QDEL_NULL(reagents)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/mask/cigarette/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user))
		C.stored_comms["wood"] += 1

/obj/item/clothing/mask/cigarette/attack(mob/living/M, mob/living/user, def_zone)
	if(istype(M) && M.on_fire)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(M)
		if(M != user)
			user.visible_message(
				span_notice("[user] хладнокровно прикурива[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] от горящего тела [M.declent_ru(GENITIVE)]. Очевидно, [genderize_ru(user.gender, "он", "она", "оно", "они")] жела[pluralize_ru(user.gender, "ет", "ют")] [M.declent_ru(DATIVE)] всего хорошего."),
				span_notice("Вы хладнокровно прикуриваете [declent_ru(ACCUSATIVE)] о горящее тело [M.declent_ru(GENITIVE)]")
			)
		else
			// The fire will light it in your hands by itself, but if you whip out the cig and click yourself fast enough, this will happen. TRULY you have your priorities stright.
			user.visible_message(
				span_notice("[user] быстро доста[pluralize_ru(user.gender, "ёт", "ют")] [src] и беспечно поджигает её своим горящим телом. [capitalize(genderize_ru(user.gender, "он", "она", "оно", "они"))] определённо уме[pluralize_ru(user.gender, "ет", "ют")] раставлять приоритеты."),
				span_notice("Вы быстро достаёте [src] и беспечно поджигаете её своим горящим телом. Вы определённо умеете выставлять приоритеты.")
			)
		light(user, user)
		return TRUE

/obj/item/clothing/mask/cigarette/afterattack(atom/target, mob/living/user, proximity)
	if(!proximity)
		return

	if(ismob(target))
		// If the target has no cig, try to give them the cig.
		var/mob/living/carbon/M = target
		if(istype(M) && user.zone_selected == "mouth" && !M.wear_mask && user.a_intent == INTENT_HELP)
			user.drop_item_ground(src)
			M.equip_to_slot_if_possible(src, ITEM_SLOT_MASK)
			if(target != user)
				user.visible_message(
					span_notice("[user] просовывает [declent_ru(ACCUSATIVE)] в рот [M]."),
					span_notice("Вы просовываете [declent_ru(ACCUSATIVE)] в рот [M]")
				)
			else
				to_chat(user, span_notice("Вы кладёте [declent_ru(ACCUSATIVE)] себе в рот."))
			return TRUE

	// You can dip cigarettes into beakers.
	if(istype(target, /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/glass = target
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered)
			to_chat(user, span_notice("Вы окунаете [declent_ru(ACCUSATIVE)] в [glass.declent_ru(ACCUSATIVE)]."))
			return

		// Either the beaker was empty, or the cigarette was full
		if(!glass.reagents.total_volume)
			user.balloon_alert(usr, "пусто!")
		else
			user.balloon_alert(usr, "уже заполнено!")

	return ..()

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		user.visible_message(
			span_notice("[user] спокойно зажима[pluralize_ru(user.gender, "ет", "ют")] прикуренный конец [declent_ru(GENITIVE)], мгновенно погасив [genderize_ru(gender, "его", "её", "его", "их")]."),
			span_notice("Вы спокойно зажимаете прикуренный конец [declent_ru(GENITIVE)], мгновенно погасив [genderize_ru(gender, "его", "её", "его", "их")]."),
			span_notice("Вы слышите, как кто-то наступает на что-то ногой, затем тихое шипение тлеющего уголька.")
		)
		die()
	return ..()

/obj/item/clothing/mask/cigarette/can_enter_storage(obj/item/storage/target, mob/user)
	if(lit && !istype(target, /obj/item/storage/ashtray))
		user.balloon_alert(user, "потушите сигарету!")
		return FALSE
	else
		return TRUE

/obj/item/clothing/mask/cigarette/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	light()

/obj/item/clothing/mask/cigarette/catch_fire()
	if(!lit)
		light(span_warning("[capitalize(declent_ru(NOMINATIVE))] зажигается от огня!"))

/obj/item/clothing/mask/cigarette/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!lit)
		user.balloon_alert(user, "сначала прикурите свою сигарету!")
		return TRUE
	if(target == user)
		user.visible_message(
			span_notice("[user] прижимает [declent_ru(ACCUSATIVE)] к [cig.declent_ru(DATIVE)], пока та не загорится."),
			span_notice("Вы прижимаете [declent_ru(ACCUSATIVE)] к [cig.declent_ru(DATIVE)], пока та не загорится.")
		)
	else
		user.visible_message(
			span_notice("[user] прижимает [declent_ru(ACCUSATIVE)] к [cig.declent_ru(DATIVE)], пока та не загорится."),
			span_notice("Вы прижимаете [declent_ru(ACCUSATIVE)] к [cig.declent_ru(DATIVE)], пока та не загорится. В тесноте, да не в обиде!")
		)
	cig.light(user, target)
	return TRUE

/obj/item/clothing/mask/cigarette/attackby(obj/item/I, mob/living/user, params)
	if(I.cigarette_lighter_act(user, user, src))
		return ATTACK_CHAIN_BLOCKED

	// Catch any item that has no cigarette_lighter_act but logically should be able to work as a lighter due to being hot.
	if(I.get_heat())
		//Give a generic light message.
		user.visible_message(
			"<span class='notice'>[user] зажигает [declent_ru(ACCUSATIVE)] [I.declent_ru(INSTRUMENTAL)]</span>",
			"<span class='notice'>Вы зажигаете [declent_ru(ACCUSATIVE)] [I.declent_ru(INSTRUMENTAL)].</span>"
		)
		light(user)
		return ..()

/obj/item/clothing/mask/cigarette/proc/light(mob/living/user, mob/living/target)
	if(lit)
		return

	lit = TRUE
	name = "lit [name]"
	ru_names = list(
		NOMINATIVE = "прикуренная сигарета",
		GENITIVE = "прикуренной сигареты",
		DATIVE = "прикуренной сигарете",
		ACCUSATIVE = "прикуренную сигарету",
		INSTRUMENTAL = "прикуренной сигаретой",
		PREPOSITIONAL = "прикуренной сигарете"
	)
	attack_verb = list("подпалил", "опалил")
	hitsound = 'sound/items/welder.ogg'
	damtype = BURN
	force = 4
	var/mob/M = loc

	// Plasma explodes when exposed to fire.
	if(reagents.get_reagent_amount("plasma"))
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount("plasma") / 2.5, 1), get_turf(src), 0, 0)
		e.start()
		if(ismob(M))
			M.drop_item_ground(src)
		qdel(src)
		return

	// Fuel explodes, too, but much less violently.
	if(reagents.get_reagent_amount("fuel"))
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
		e.start()
		if(ismob(M))
			M.drop_item_ground(src)
		qdel(src)
		return

	// If there is no target, the user is probably lighting their own cig.
	if(isnull(target))
		target = user

	// If there is also no user, the cig is being lit by atmos or something.
	if(target)
		target.update_inv_wear_mask()
		target.update_inv_l_hand()
		target.update_inv_r_hand()

	reagents.set_reacting(TRUE)
	reagents.handle_reactions()
	icon_state = icon_on
	item_state = icon_on
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(C.wear_mask == src) // Don't update if it's just in their hand
			C.wear_mask_update(src)
	set_light(2, 0.25, "#E38F46")
	START_PROCESSING(SSobj, src)
	playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)
	return TRUE

/obj/item/clothing/mask/cigarette/update_icon_state()
	icon_state = lit ? icon_on : icon_off
	item_state = lit ? icon_on : initial(item_state)
	update_equipped_item(update_speedmods = FALSE)


/obj/item/clothing/mask/cigarette/get_heat()
	return lit * 1000

/obj/item/clothing/mask/cigarette/proc/check_reagents_explosion()
	var/reagent = ""
	var/reagent_divisor = 2.5
	if(reagents.get_reagent_amount("plasma"))
		reagent = "plasma"
	else if(reagents.get_reagent_amount("fuel"))
		reagent = "fuel"
		reagent_divisor = 5
	if(!reagent)
		return FALSE

	var/datum/effect_system/reagents_explosion/explosion = new
	explosion.set_up(round(reagents.get_reagent_amount(reagent) / reagent_divisor, 1), get_turf(src), 0, 0)
	if(ismob(loc))
		var/mob/user = loc
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
	qdel(src)
	return TRUE


/obj/item/clothing/mask/cigarette/process()
	var/mob/living/M = loc
	if(isliving(loc))
		M.IgniteMob()
	smoketime--
	if(reagents.total_volume <= 0 || smoketime < 1)
		die()
		return
	smoke()

/obj/item/clothing/mask/cigarette/extinguish_light(force = FALSE)
	if(!force)
		return
	die()

/obj/item/clothing/mask/cigarette/proc/smoke()
	var/turf/location = get_turf(src)
	var/is_being_smoked = FALSE
	// Check whether this is actually in a mouth, being smoked
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(src == C.wear_mask)
			// There used to be a species check here, but synthetics can smoke now
			is_being_smoked = TRUE
	if(location)
		location.hotspot_expose(700, 5)
	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		if(is_being_smoked) // if it's being smoked, transfer reagents to the mob
			var/mob/living/carbon/C = loc
			for(var/datum/reagent/R in reagents.reagent_list)
				reagents.trans_id_to(C, R.id, first_puff ? 1 : max(REAGENTS_METABOLISM / reagents.reagent_list.len, 0.1)) //transfer at least .1 of each chem
			first_puff = FALSE
			if(!reagents.total_volume) // There were reagents, but now they're gone
				C.balloon_alert(C, "сигарета теряет вкус")
		else // else just remove some of the reagents
			reagents.remove_any(REAGENTS_METABOLISM)

/obj/item/clothing/mask/cigarette/proc/die()
	var/turf/T = get_turf(src)
	var/obj/item/butt = new type_butt(T)
	transfer_fingerprints_to(butt)
	if(ismob(loc))
		var/mob/living/M = loc
		M.balloon_alert(M, "сигарета гаснет")
		M.temporarily_remove_item_from_inventory(src, force = TRUE)		//Force the un-equip so the overlays update
	STOP_PROCESSING(SSobj, src)
	qdel(src)

/obj/item/clothing/mask/cigarette/get_heat()
	return lit * 1000

//////////////////////////////
// MARK: CIGARETTES
//////////////////////////////

/obj/item/clothing/mask/cigarette/menthol
	list_reagents = list("nicotine" = 40, "menthol" = 20)

/obj/item/clothing/mask/cigarette/random

/obj/item/clothing/mask/cigarette/random/New()
	list_reagents = list("nicotine" = 40, pick("fuel","saltpetre","synaptizine","green_vomit","potass_iodide","msg","lexorin","mannitol","spaceacillin","cryoxadone","holywater","tea","egg","haloperidol","mutagen","omnizine","carpet","aranesp","cryostylane","chocolate","bilk","cheese","rum","blood","charcoal","coffee","ectoplasm","space_drugs","milk","mutadone","antihol","teporone","insulin","salbutamol","toxin") = 20)
	..()

/obj/item/clothing/mask/cigarette/syndicate
	list_reagents = list("nicotine" = 40, "syndiezine" = 20)

/obj/item/clothing/mask/cigarette/medical_marijuana
	list_reagents = list("thc" = 40, "cbd" = 20)

/obj/item/clothing/mask/cigarette/robustgold
	list_reagents = list("nicotine" = 40, "gold" = 1)

/obj/item/clothing/mask/cigarette/shadyjims
	list_reagents = list("nicotine" = 40, "lipolicide" = 7.5, "ammonia" = 2, "atrazine" = 1, "toxin" = 1.5)

/obj/item/clothing/mask/cigarette/richard
	list_reagents = list("nicotine" = 40, "epinephrine" = 5, "absinthe" = 5)

/obj/item/clothing/mask/cigarette/rollie
	name = "rollie"
	desc = "Рулон высушенных растений, аккуратно завёрнутый в тонкую бумагу."
	ru_names = list(
		NOMINATIVE = "самокрутка",
		GENITIVE = "самокрутки",
		DATIVE = "самокрутке",
		ACCUSATIVE = "самокрутку",
		INSTRUMENTAL = "самокруткой",
		PREPOSITIONAL = "самокрутке"
	)
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	type_butt = /obj/item/cigbutt/roach
	throw_speed = 0.5
	item_state = "spliffoff"

/obj/item/clothing/mask/cigarette/rollie/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)


/obj/item/cigbutt/roach
	name = "roach"
	desc = "Вонючий старый бычок или, для тех, кто не курит, – выкуренная самокрутка."
	icon_state = "roach"
	item_state = "rolliebutt"

/obj/item/cigbutt/roach/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

//////////////////////////////
// MARK: CIGARS
//////////////////////////////

/obj/item/clothing/mask/cigarette/cigar
	name = "Premium Cigar"
	desc = "Свёрнутые в трубочку листья табака и... ну, бог его знает. Она просто огромная!"
	ru_names = list(
		NOMINATIVE = "сигара премиум-класса",
		GENITIVE = "сигары премиум-класса",
		DATIVE = "сигаре премиум-класса",
		ACCUSATIVE = "сигару премиум-класса",
		INSTRUMENTAL = "сигарой премиум-класса",
		PREPOSITIONAL = "сигаре премиум-класса"
	)
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff"
	fancy = TRUE
	type_butt = /obj/item/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 300
	chem_volume = 120
	list_reagents = list("nicotine" = 120)
	muhtar_fashion = /datum/muhtar_fashion/mask/cigar

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "Cohiba Robusto Cigar"
	desc = "От сигары сложно ожидать чего-то большего."
	ru_names = list(
		NOMINATIVE = "Сигара Коиба Робусто",
		GENITIVE = "Сигары Коиба Робусто",
		DATIVE = "Сигаре Коиба Робусто",
		ACCUSATIVE = "Сигару Коиба Робусто",
		INSTRUMENTAL = "Сигарой Коиба Робусто",
		PREPOSITIONAL = "Сигаре Коиба Робусто"
	)
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "Premium Havanian Cigar"
	desc = "Лучшая сигара в наблюдаемой Вселенной."
	ru_names = list(
		NOMINATIVE = "Гаванская Сигара премиум-класса",
		GENITIVE = "Гаванская Сигары премиум-класса",
		DATIVE = "Гаванская Сигаре премиум-класса",
		ACCUSATIVE = "Гаванская Сигару премиум-класса",
		INSTRUMENTAL = "Гаванская Сигарой премиум-класса",
		PREPOSITIONAL = "Гаванская Сигаре премиум-класса"
	)
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 450
	chem_volume = 180
	list_reagents = list("nicotine" = 180)

/obj/item/cigbutt
	name = "cigarette butt"
	desc = "Обмякшие останки выкуренной сигареты."
	ru_names = list(
		NOMINATIVE = "окурок",
		GENITIVE = "окурка",
		DATIVE = "окурку",
		ACCUSATIVE = "окурок",
		INSTRUMENTAL = "окурком",
		PREPOSITIONAL = "окурке"
	)
	gender = MALE
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	item_state = "cigbutt"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/cigbutt/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	transform = turn(transform,rand(0,360))

/obj/item/cigbutt/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user))
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "Обмякшие останки выкуренной сигары."
	icon_state = "cigarbutt"
	item_state = "cigarbutt"


/obj/item/clothing/mask/cigarette/cigar/attackby(obj/item/item, mob/user, params)
	var/static/list/lighters = typecacheof(list(
		/obj/item/lighter,
		/obj/item/match,
		/obj/item/melee/energy/sword/saber,
		/obj/item/gun/magic/wand/fireball,
		/obj/item/assembly/igniter,
		/obj/item/flashlight/flare,
		/obj/item/candle,
		/obj/item/clothing/mask/cigarette,
	))
	var/static/list/acceptable_lighters = typecacheof(list(
		/obj/item/lighter/zippo,
		/obj/item/match,
	))
	if(!is_type_in_typecache(item, lighters))
		return ..()
	if(!is_type_in_typecache(item, acceptable_lighters))
		add_fingerprint(user)
		to_chat(user, span_notice("[capitalize(declent_ru(NOMINATIVE))] просто ОТКАЗЫВА[pluralize_ru(gender, "ЕТ", "ЮТ")]СЯ быть прикуренной столь нецивилизованными методами."))
		return ATTACK_CHAIN_PROCEED
	return ..()


//////////////////////////////
// MARK: PIPES
//////////////////////////////

/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "Трубка для курения. Вероятно, сделана из пенопласта или чего-то такого."
	ru_names = list(
		NOMINATIVE = "курительная трубка",
		GENITIVE = "курительной трубки",
		DATIVE = "курительной трубке",
		ACCUSATIVE = "курительную трубку",
		INSTRUMENTAL = "курительной трубкой",
		PREPOSITIONAL = "курительной трубке"
	)
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	fancy = TRUE
	smoketime = 500
	chem_volume = 200
	list_reagents = list("nicotine" = 200)

/obj/item/clothing/mask/cigarette/pipe/light(flavor_text = null)
	if(!lit)
		lit = TRUE
		damtype = FIRE
		update_icon(UPDATE_ICON_STATE)
		if(flavor_text)
			var/turf/T = get_turf(src)
			T.visible_message(flavor_text)
		START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/cigarette/pipe/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		new /obj/effect/decal/cleanable/ash(location)
		lit = FALSE
		update_icon(UPDATE_ICON_STATE)
		if(ismob(loc))
			var/mob/living/M = loc
			M.balloon_alert(M, "трубка гаснет")
		STOP_PROCESSING(SSobj, src)
		return
	smoke()

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user) //Refills the pipe. Can be changed to an attackby later, if loose tobacco is added to vendors or something.
	if(lit)
		user.balloon_alert(user, "трубка потушена")
		lit = FALSE
		update_icon(UPDATE_ICON_STATE)
		STOP_PROCESSING(SSobj, src)
		return
	if(smoketime <= 0)
		user.balloon_alert(user, "трубка наполнена")
		reagents.add_reagent("nicotine", chem_volume)
		smoketime = initial(smoketime)
		first_puff = TRUE


/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/item, mob/user, params)
	var/static/list/lighters = typecacheof(list(
		/obj/item/lighter,
		/obj/item/match,
		/obj/item/melee/energy/sword/saber,
		/obj/item/gun/magic/wand/fireball,
		/obj/item/assembly/igniter,
		/obj/item/flashlight/flare,
		/obj/item/candle,
		/obj/item/clothing/mask/cigarette,
	))
	var/static/list/acceptable_lighters = typecacheof(list(
		/obj/item/lighter/zippo,
		/obj/item/match,
	))
	if(!is_type_in_typecache(item, lighters))
		return ..()
	if(!is_type_in_typecache(item, acceptable_lighters))
		add_fingerprint(user)
		to_chat(user, span_notice("[capitalize(declent_ru(NOMINATIVE))] просто ОТКАЗЫВАЕТСЯ быть прикуренной столь нецивилизованными методами."))
		return ATTACK_CHAIN_PROCEED
	return ..()


/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "Система доставки никотина, популяризированная жителями провинций и пользующаяся популярностью и в наше время. В основном у разного рода хипстеров."
	ru_names = list(
		NOMINATIVE = "кукурузная курительная трубка",
		GENITIVE = "кукурузной курительной трубки",
		DATIVE = "кукурузной курительной трубке",
		ACCUSATIVE = "кукурузную курительную трубку",
		INSTRUMENTAL = "кукурузной курительной трубкой",
		PREPOSITIONAL = "кукурузной курительной трубке"
	)
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	smoketime = 800
	chem_volume = 40

/obj/item/clothing/mask/cigarette/pipe/oldpipe
	name = "robust smoking pipe"
	desc = "Потрёпанная курительная трубка. Выглядит жёстко!"
	ru_names = list(
		NOMINATIVE = "крепкая курительная трубка",
		GENITIVE = "крепкой курительной трубки",
		DATIVE = "крепкой курительной трубке",
		ACCUSATIVE = "крепкую курительную трубку",
		INSTRUMENTAL = "крепкой курительной трубкой",
		PREPOSITIONAL = "крепкой курительной трубке"
	)
	icon_state = "oldpipeoff"
	item_state = "oldpipeoff"
	icon_on = "oldpipeon"
	icon_off = "oldpipeoff"

/////////////////////////////
// MARK: ROLLING
//////////////////////////////

/obj/item/rollingpaper
	name = "rolling paper"
	desc = "Тонкий лист бумаги, используемый для изготовления сигарет."
	ru_names = list(
		NOMINATIVE = "папиросная бумага",
		GENITIVE = "папиросной бумаги",
		DATIVE = "папиросной бумаге",
		ACCUSATIVE = "папиросная бумага",
		INSTRUMENTAL = "папиросной бумагой",
		PREPOSITIONAL = "папиросной бумаге"
	)
	gender = FEMALE
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	item_state = "cig_paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/rollingpaper/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(istype(target, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/O = target
		if(O.dry)
			user.temporarily_remove_item_from_inventory(target, force = TRUE)
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
			var/obj/item/clothing/mask/cigarette/rollie/R = new /obj/item/clothing/mask/cigarette/rollie(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to(R, R.chem_volume)
			user.put_in_active_hand(R)
			user.balloon_alert(user, "закручено в самокрутку")
			R.desc = "Высушенн[genderize_ru(target.gender, "ый", "ая", "ое", "ые")] [target.declent_ru(NOMINATIVE)], закрученн[genderize_ru(target.gender, "ый", "ая", "ое", "ые")] в папиросную бумагу."
			qdel(target)
			qdel(src)
		else
			user.balloon_alert(user, "сначала высушите!")
	else
		..()

//////////////////////////////
// MARK: HOLO-CIGAR
//////////////////////////////

/obj/item/clothing/mask/holo_cigar
	name = "Holo-Cigar"
	desc = "Изящная электронная сигара, изготовленна в Солнечной Системе. При одном взгляде на нее чувствуешь себя крутым..."
	ru_names = list(
		NOMINATIVE = "голографическая сигара",
		GENITIVE = "голографической сигары",
		DATIVE = "голографической сигаре",
		ACCUSATIVE = "голографическую сигару",
		INSTRUMENTAL = "голографической сигарой",
		PREPOSITIONAL = "голографической сигаре"
	)
	gender = FEMALE
	icon_state = "holocigaroff"
	item_state = "holocigaroff"
	/// Is the holo-cigar lit?
	var/enabled = FALSE
	/// Tracks if this is the first cycle smoking the cigar.
	var/has_smoked = FALSE

/obj/item/clothing/mask/holo_cigar/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/holo_cigar/update_icon_state()
	icon_state = "holocigar[enabled ? "on" : "off"]"

/obj/item/clothing/mask/holo_cigar/examine(mob/user)
	. = ..()
	if(enabled)
		. += span_boldnotice("Включена и синтезирует никотин.")
	else
		. += span_boldnotice("Выключена.")

/obj/item/clothing/mask/holo_cigar/process()
	if(!iscarbon(loc))
		return

	var/mob/living/carbon/C = loc
	if(C.wear_mask != src)
		return

	if(!has_smoked)
		C.reagents.add_reagent("nicotine", 2)
		has_smoked = TRUE
	else
		C.reagents.add_reagent("nicotine", REAGENTS_METABOLISM)

/obj/item/clothing/mask/holo_cigar/equipped(mob/user, slot, initial)
	. = ..()
	if(enabled && slot == ITEM_SLOT_MASK)
		if(!HAS_TRAIT_FROM(user, TRAIT_BADASS, HOLO_CIGAR_TRAIT))
			ADD_TRAIT(user, TRAIT_BADASS, HOLO_CIGAR_TRAIT)
			to_chat(user, span_notice("Вы чувствуете себя круче, пока курите [declent_ru(ACCUSATIVE)]."))

/obj/item/clothing/mask/holo_cigar/dropped(mob/user, slot, silent)
	. = ..()
	has_smoked = FALSE
	if(HAS_TRAIT_FROM(user, TRAIT_BADASS, HOLO_CIGAR_TRAIT))
		REMOVE_TRAIT(user, TRAIT_BADASS, HOLO_CIGAR_TRAIT)
		to_chat(user, span_notice("Вы чуствуете себя не таким крутым, как раньше."))

/obj/item/clothing/mask/holo_cigar/attack_self(mob/user)
	. = ..()
	if(enabled)
		enabled = FALSE
		user.balloon_alert(user, "включено")
		STOP_PROCESSING(SSobj, src)
	else
		enabled = TRUE
		user.balloon_alert(user, "выключено")
		START_PROCESSING(SSobj, src)

	update_appearance(UPDATE_ICON_STATE)
