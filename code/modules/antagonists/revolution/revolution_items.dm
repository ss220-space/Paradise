#define HYPNOFLASH_DRUNK_THRESHOLD 60 SECONDS
#define CREW_PER_HORUS_IMPLANT 10

/obj/item/storage/box/revolution
	name = "syndicate agent kit"
	desc = "Плоский чемоданчик без опознавательных знаков."

/obj/item/storage/box/revolution/get_ru_names()
	return alist(
		NOMINATIVE = "набор агента Синдиката",
		GENITIVE = "набора агента Синдиката",
		DATIVE = "набору агента Синдиката",
		ACCUSATIVE = "набор агента Синдиката",
		INSTRUMENTAL = "набором агента Синдиката",
		PREPOSITIONAL = "наборе агента Синдиката",
	)

/obj/item/storage/box/revolution/populate_contents()
	new /obj/item/flash/hypno(src)
	new /obj/item/revolution_beacon(src)
	new /obj/item/encryptionkey/syndicate(src)
	new /obj/item/bowman_conversion_tool(src)
	var/implants = max(round(length(GLOB.data_core.general) / (CREW_PER_HORUS_IMPLANT * MAX_HEAD_REVOLUTIONARIES)), 1)
	for(var/count in 1 to implants)
		new /obj/item/implanter/horus(src)

/obj/item/implant/horus
	name = "Horus bio-chip"
	desc = "Био-чип производства Синдиката, перестраивающий центры лояльности носителя. Работает только с теми, кто согласился добровольно."
	origin_tech = "materials=3;biotech=5;programming=5;syndicate=3"
	implant_state = "implant-syndicate"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/horus

/obj/item/implant/horus/get_ru_names()
	return alist(
		NOMINATIVE = "био-чип Хоруса",
		GENITIVE = "био-чипа Хоруса",
		DATIVE = "био-чипу Хоруса",
		ACCUSATIVE = "био-чип Хоруса",
		INSTRUMENTAL = "био-чипом Хоруса",
		PREPOSITIONAL = "био-чипе Хоруса",
	)

/obj/item/implant/horus/implant(mob/living/target, mob/user, force = FALSE)
	. = ..()
	if(!. || !target.mind)
		return .
	SSticker.mode.add_revolutionary(target.mind, /datum/antagonist/rev/volunteer)

/datum/implant_fluff/horus
	name = "Cybersun Industries 'Horus' Loyalty Bio-chip"
	life = "До смерти носителя."
	notes = "Обнаружение данного био-чипа у сотрудника является достаточным основанием для обвинения в государственной измене."
	function = "Мягко перестраивает лимбическую систему носителя, закрепляя добровольно принятую им лояльность. Не работает против воли субъекта."

/obj/item/implanter/horus
	name = "bio-chip implanter (Horus)"
	desc = "Одноразовый инжектор с символикой Синдиката. Носитель должен согласиться на имплантацию сам."
	icon_state = "horus_implanter"
	origin_tech = "materials=3;biotech=5;programming=5;syndicate=3"
	imp = /obj/item/implant/horus

/obj/item/implanter/horus/get_ru_names()
	return alist(
		NOMINATIVE = "инжектор био-чипа Хоруса",
		GENITIVE = "инжектора био-чипа Хоруса",
		DATIVE = "инжектору био-чипа Хоруса",
		ACCUSATIVE = "инжектор био-чипа Хоруса",
		INSTRUMENTAL = "инжектором био-чипа Хоруса",
		PREPOSITIONAL = "инжекторе био-чипа Хоруса",
	)

/obj/item/implanter/horus/update_icon_state()
	return

/obj/item/implanter/horus/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!iscarbon(target) || !user || !imp)
		return .

	if(target == user)
		balloon_alert(user, "только на других!")
		return .

	if(!target.mind || target.stat != CONSCIOUS)
		balloon_alert(user, "цель без сознания!")
		return .

	if(ismindshielded(target))
		balloon_alert(user, "разум защищён!")
		return .

	if(target.mind.has_antag_datum(/datum/antagonist/rev))
		balloon_alert(user, "уже в революции!")
		return .

	target.visible_message(span_warning("[user] пыта[PLUR_ET_YUT(user)]ся имплантировать био-чип в [target]."))
	if(!do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL) || QDELETED(user) || QDELETED(target) || QDELETED(src) || QDELETED(imp))
		return .

	var/choice = tgui_alert(target, "Вам предлагают вступить в революцию Синдиката. Принять био-чип?", "Био-чип Хоруса", list("Принять", "Отказаться"), timeout = 30 SECONDS)
	if(choice != "Принять")
		to_chat(user, span_warning("[target] отверга[PLUR_ET_YUT(target)] предложение."))
		to_chat(target, span_notice("Вы отказываетесь от имплантации."))
		return .

	if(QDELETED(user) || QDELETED(target) || QDELETED(src) || QDELETED(imp) || target.stat != CONSCIOUS || ismindshielded(target) || !user.Adjacent(target))
		return .

	if(!imp.implant(target, user))
		return .

	. |= ATTACK_CHAIN_SUCCESS
	target.visible_message(
		span_warning("[user] имплантировал[GEND_A_O_I(user)] био-чип в [target]."),
		span_notice("[user] имплантировал[GEND_A_O_I(user)] вам био-чип."),
	)
	imp = null
	qdel(src)


/obj/item/flash/hypno
	name = "hypnotic flash"
	desc = "Флешер с перепрошитой матрицей. Вспышка вгоняет одурманенный разум в короткий транс, ломая волю жертвы."
	can_overcharge = FALSE

/obj/item/flash/hypno/get_ru_names()
	return alist(
		NOMINATIVE = "гипнофлеш",
		GENITIVE = "гипнофлеша",
		DATIVE = "гипнофлешу",
		ACCUSATIVE = "гипнофлеш",
		INSTRUMENTAL = "гипнофлешем",
		PREPOSITIONAL = "гипнофлеше",
	)

/obj/item/flash/hypno/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!iscarbon(target) || !is_head_revolutionary(user) || !can_hypnotise(target))
		return ..()

	if(!try_use_flash(user))
		return ATTACK_CHAIN_PROCEED

	if(!flash_carbon(target, user, 10 SECONDS, TRUE))
		return ATTACK_CHAIN_PROCEED

	target.Sleeping(3 SECONDS)
	to_chat(target, span_userdanger("Вспышка выжигает вашу волю. Мысли путаются, и остаётся только чужой голос."))
	add_attack_logs(user, target, "Hypnotised with [src]")
	SSticker.mode.add_revolutionary(target.mind, /datum/antagonist/rev/slave)
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/item/flash/hypno/proc/can_hypnotise(mob/living/target)
	if(!target.mind || target.stat != CONSCIOUS)
		return FALSE
	if(ismindshielded(target) || target.mind.has_antag_datum(/datum/antagonist/rev))
		return FALSE
	return target.get_drunkenness() >= HYPNOFLASH_DRUNK_THRESHOLD || target.AmountDruggy() > 0


/obj/item/revolution_beacon
	name = "syndicate support beacon"
	desc = "Одноразовый маяк, вызывающий с ближайшего корабля Синдиката один из подготовленных наборов снабжения."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "bluespace=4;syndicate=3"

/obj/item/revolution_beacon/get_ru_names()
	return alist(
		NOMINATIVE = "маяк поддержки Синдиката",
		GENITIVE = "маяка поддержки Синдиката",
		DATIVE = "маяку поддержки Синдиката",
		ACCUSATIVE = "маяк поддержки Синдиката",
		INSTRUMENTAL = "маяком поддержки Синдиката",
		PREPOSITIONAL = "маяке поддержки Синдиката",
	)

/obj/item/revolution_beacon/attack_self(mob/user)
	if(!is_head_revolutionary(user))
		balloon_alert(user, "маяк не отвечает!")
		return

	var/static/list/supply_crates = list(
		"Набор ликвидации" = /obj/structure/closet/crate/syndicate/revolution/liquidation,
		"Набор внедрения" = /obj/structure/closet/crate/syndicate/revolution/infiltration,
		"Набор изучения" = /obj/structure/closet/crate/syndicate/revolution/research,
	)

	var/choice = tgui_input_list(user, "Какой набор запросить у Синдиката?", "Маяк поддержки", supply_crates)
	if(!choice || QDELETED(src) || !user.is_in_active_hand(src))
		return

	var/turf/landing_spot = get_turf(user)
	var/crate_type = supply_crates[choice]
	do_sparks(4, TRUE, landing_spot)
	new crate_type(landing_spot)
	user.visible_message(
		span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] в руках [user.declent_ru(GENITIVE)] вспыхивает, и рядом материализуется ящик!"),
		span_notice("Маяк отработал. Синдикат прислал запрошенное."),
	)
	add_game_logs("used a revolution support beacon for [choice]", user)
	qdel(src)

/obj/structure/closet/crate/syndicate/revolution
	name = "syndicate supply crate"
	desc = "Ящик снабжения Синдиката, сброшенный по сигналу маяка поддержки."

/obj/structure/closet/crate/syndicate/revolution/liquidation
	name = "liquidation crate"

/obj/structure/closet/crate/syndicate/revolution/liquidation/populate_contents()
	new /obj/item/gun/projectile/automatic/pistol(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/gun_module/muzzle/suppressor(src)
	new /obj/item/pen/edagger(src)

/obj/structure/closet/crate/syndicate/revolution/infiltration
	name = "infiltration crate"

/obj/structure/closet/crate/syndicate/revolution/infiltration/populate_contents()
	new /obj/item/pen/fakesign(src)
	new /obj/item/stamp/chameleon(src)
	new /obj/item/storage/box/syndie_kit/chameleon(src)
	new /obj/item/card/id/syndicate(src)

/obj/structure/closet/crate/syndicate/revolution/research
	name = "research crate"

/obj/structure/closet/crate/syndicate/revolution/research/populate_contents()
	new /obj/item/circuitboard/rdconsole(src)
	new /obj/item/circuitboard/destructive_analyzer(src)
	new /obj/item/circuitboard/protolathe(src)
	new /obj/item/circuitboard/circuit_imprinter(src)
	new /obj/item/card/emag(src)
	new /obj/item/stack/sheet/metal(src, 100)
	new /obj/item/stack/sheet/glass(src, 50)
	new /obj/item/storage/part_replacer/bluespace/tier4(src)

#undef HYPNOFLASH_DRUNK_THRESHOLD
#undef CREW_PER_HORUS_IMPLANT
