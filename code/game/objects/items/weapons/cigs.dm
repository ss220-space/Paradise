/*
CONTAINS:
CIGARETTES
CIGARS
SMOKING PIPES
HOLO-CIGAR

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
	var/lit = FALSE
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/cigbutt
	var/lastHolder = null
	var/smoketime = 150
	var/chem_volume = 60
	var/list/list_reagents = list("nicotine" = 40)
	var/first_puff = TRUE // the first puff is a bit more reagents ingested

	pickup_sound = 'sound/items/handling/pickup/generic_small_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/generic_small_drop.ogg'
	equip_sound = 'sound/items/handling/equip/generic_equip5.ogg'
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

/obj/item/clothing/mask/cigarette/pre_attackby(atom/target, mob/living/user, params)
	. = ..()
	var/obj/item/lighting_item = target
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !istype(lighting_item))
		return .

	if(lighting_item.get_heat())
		light()
		return .|ATTACK_CHAIN_BLOCKED

/obj/item/clothing/mask/cigarette/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(target.on_fire)
		user.do_attack_animation(target)
		light(span_notice("[user] хладнокровно прикурива[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] от горящего тела [target.declent_ru(GENITIVE)]. Очевидно, [genderize_ru(user.gender, "он", "она", "оно", "они")] жела[pluralize_ru(user.gender, "ет", "ют")] [target.declent_ru(DATIVE)] всего хорошего."))
		return ATTACK_CHAIN_PROCEED_SUCCESS
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

/obj/item/clothing/mask/cigarette/welder_act(mob/user, obj/item/item)
	. = TRUE
	if(item.tool_use_check(user, 0)) //Don't need to flash eyes because you are a badass
		light(span_notice("[user] непринуждённо прикурива[pluralize_ru(user, "ет", "ют")] [declent_ru(ACCUSATIVE)] с помощью [item.declent_ru(GENITIVE)]. Чёрт, как же он[genderize_ru(user.gender, "", "а", "о", "и")] крут[genderize_ru(user.gender, "", "а", "о", "ы")]!"))


/obj/item/clothing/mask/cigarette/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/weldingtool/sword))
		if(item.tool_enabled)
			light(span_notice("[user] непринуждённо прикурива[pluralize_ru(user, "ет", "ют")] [declent_ru(ACCUSATIVE)] с помощью [item.declent_ru(GENITIVE)]. Чёрт, как же он[genderize_ru(user.gender, "", "а", "о", "и")] крут[genderize_ru(user.gender, "", "а", "о", "ы")]!"))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(item, /obj/item/lighter/zippo))
		add_fingerprint(user)
		var/obj/item/lighter/zippo/zippo = item
		if(!zippo.lit)
			return ..()
		light(span_rose("Лёгким движением руки, [user] прикурива[pluralize_ru(user, "ет", "ют")] свою [declent_ru(ACCUSATIVE)] [zippo.declent_ru(INSTRUMENTAL)]. Чёрт, как же он[genderize_ru(user.gender, "", "а", "о", "и")] крут[genderize_ru(user.gender, "", "а", "о", "ы")]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(item, /obj/item/lighter))
		add_fingerprint(user)
		var/obj/item/lighter/lighter = item
		if(!lighter.lit)
			return ..()
		light(span_notice("Немного повозившись, [user.declent_ru(DATIVE)] удаётся зажечь свою [declent_ru(ACCUSATIVE)] [lighter.declent_ru(INSTRUMENTAL)]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(item, /obj/item/match/unathi))
		add_fingerprint(user)
		var/obj/item/match/unathi/match = item
		if(!match.lit)
			return ..()
		playsound(user.loc, 'sound/effects/unathiignite.ogg', 40, FALSE)
		light(span_rose("[user] плю[pluralize_ru(user.gender, "ёт", "ют")] огнём на свою [declent_ru(ACCUSATIVE)], зажигая её."))
		match.matchburnout()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(item, /obj/item/match))
		add_fingerprint(user)
		var/obj/item/match/match = item
		if(!match.lit)
			return ..()
		light(span_notice("[user] зажига[pluralize_ru(user.gender, "ет", "ют")] свою [declent_ru(ACCUSATIVE)] [match.declent_ru(INSTRUMENTAL)]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(item, /obj/item/melee/energy/sword/saber))
		add_fingerprint(user)
		var/obj/item/melee/energy/sword/saber/saber = item
		if(!saber.active)
			return ..()
		light(span_warning("[user] дела[pluralize_ru(user.gender, "ет", "ют")] резкое движение [saber.declent_ru(INSTRUMENTAL)], проводя [genderize_ru(saber.gender, "им", "ею", "им", "ими")] в считанных сантиметрах перед своим лицом и поджигая [declent_ru(ACCUSATIVE)] в процессе."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(isigniter(item))
		add_fingerprint(user)
		light(span_notice("[user] воз[pluralize_ru(user.gender, "ит", "ят")]ся с [item.declent_ru(INSTRUMENTAL)], но в конце концов прикурива[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(item, /obj/item/gun/magic/wand/fireball))
		add_fingerprint(user)
		var/obj/item/gun/magic/wand/fireball/wand = item
		if(!wand.charges)
			return ..()
		if(prob(50) || user.mind.assigned_role == "Wizard")
			light(span_notice("Египетская сила! Неужели [user.declent_ru(DATIVE)] только что удалось зажечь свою [declent_ru(ACCUSATIVE)] [wand.declent_ru(INSTRUMENTAL)], лишь слегка приподняв бровь?"))
		else
			visible_message(user, span_warning("Не разобравшись, где правильная сторона посоха, [user.declent_ru(DATIVE)] не смог[genderize_ru(user.gender, "", "ла", "ло", "ли")] зажечь [declent_ru(ACCUSATIVE)] [wand.declent_ru(INSTRUMENTAL)]."))
			explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
		wand.charges--
		wand.update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(item, /obj/item/flashlight/flare))
		add_fingerprint(user)
		var/obj/item/flashlight/flare/flare = item
		if(!flare.on || !flare.can_fire_cigs)
			return ..()
		light(span_notice("[user] не наход[pluralize_ru(user.gender, "ит", "ят")] ничего лучше [flare.declent_ru(GENITIVE)], чтобы прикурить [declent_ru(ACCUSATIVE)]. Бедолага..."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(item, /obj/item/candle))
		add_fingerprint(user)
		var/obj/item/candle/candle = item
		if(!candle.lit)
			return ..()
		light(span_notice("[user] прикурива[pluralize_ru(user.gender, "ет", "ют")] свою [declent_ru(ACCUSATIVE)] [candle.declent_ru(INSTRUMENTAL)]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(item, /obj/item/clothing/mask/cigarette))
		add_fingerprint(user)
		var/obj/item/clothing/mask/cigarette/cigarette = item
		if(!cigarette.lit)
			return ..()
		light(span_notice("[user] прикурива[pluralize_ru(user.gender, "ет", "ют")] свою [declent_ru(ACCUSATIVE)] другой [cigarette.declent_ru(INSTRUMENTAL)]. Бедолага..."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/clothing/mask/cigarette/afterattack(obj/item/reagent_containers/glass/glass, mob/user, proximity, params)
	..()
	if(!proximity)
		return
	if(istype(glass))	//you can dip cigarettes into beakers
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			to_chat(user, span_notice("Вы окунаете [declent_ru(ACCUSATIVE)] в [glass.declent_ru(ACCUSATIVE)]."))
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				user.balloon_alert(usr, "пусто!")
			else
				user.balloon_alert(usr, "уже заполнено!")


/obj/item/clothing/mask/cigarette/update_icon_state()
	icon_state = lit ? icon_on : icon_off
	item_state = lit ? icon_on : initial(item_state)
	update_equipped_item(update_speedmods = FALSE)


/obj/item/clothing/mask/cigarette/update_name(updates = ALL)
	. = ..()
	name = lit ? "lit [initial(name)]" : initial(name)
	if(ru_names && lit)
		ru_names[NOMINATIVE] = "прикуренная " + ru_names[NOMINATIVE]
		ru_names[GENITIVE] = "прикуренной " + ru_names[GENITIVE]
		ru_names[DATIVE] = "прикуренной " + ru_names[DATIVE]
		ru_names[ACCUSATIVE] = "прикуренную " + ru_names[ACCUSATIVE]
		ru_names[INSTRUMENTAL] = "прикуренной " + ru_names[INSTRUMENTAL]
		ru_names[PREPOSITIONAL] = "прикуренной " + ru_names[PREPOSITIONAL]

/obj/item/clothing/mask/cigarette/get_heat()
	return lit * 1000


/obj/item/clothing/mask/cigarette/proc/light(flavor_text = null)
	if(lit)
		return

	lit = TRUE
	attack_verb = list("подпалил", "опалил")
	hitsound = 'sound/items/welder.ogg'
	damtype = FIRE
	force = 4

	if(check_reagents_explosion())
		return

	reagents.set_reacting(TRUE)
	reagents.handle_reactions()
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
	if(flavor_text)
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
	START_PROCESSING(SSobj, src)
	playsound(src, 'sound/items/lighter/light.ogg', 25, TRUE)


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

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		user.visible_message(span_notice("[user] спокойно зажима[pluralize_ru(user.gender, "ет", "ют")] прикуренный конец [declent_ru(GENITIVE)], мгновенно погасив [genderize_ru(gender, "его", "её", "его", "их")]."))
		die()
	return ..()

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

////////////
// CIGARS //
////////////

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
	C.stored_comms["wood"] += 1
	qdel(src)
	return TRUE

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


/////////////////
//SMOKING PIPES//
/////////////////

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

///////////
//ROLLING//
///////////

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

//////////////
//HOLO CIGAR//
//////////////

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
