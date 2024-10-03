#define FREE_INJECT_TIME 10 SECONDS
#define TARGET_INJECT_TIME 3 SECONDS

/datum/affiliate/tiger
	name = "Tiger Cooperative"
	affil_info = list("Преимущества: ",
			"Скидка 25% на имплант адреналина",
			"Скидка 50% на прототип импланта адреналина",
			"Скидка 30% на лазерный меч",
			"Новый предмет - \"Egg Implanter\"",
			"Недостатки: ",
			"Вы не можете купить или использовать оружие дальнего боя",
			"Стандартные цели:",
			"Сделать члена экипажа генокрадом вколов в его труп яйца генокрада",
			"Увеличить популяцию бореров",
			"Украсть пару ценных вещей",
			"Убить пару еретиков")
	objectives = list(/datum/objective/new_mini_changeling, // Oh, sorry, I forgot to make that stupid drug objective...
					/datum/objective/borers,
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					/datum/objective/maroon,
					/datum/objective/escape
					)

/datum/affiliate/tiger/get_weight(mob/living/carbon/human/H)
	return (!ismachineperson(H)) * 2

/datum/affiliate/tiger/finalize_affiliate(datum/mind/owner)
	. = ..()
	ADD_TRAIT(owner.current, TRAIT_NO_GUNS, TIGER_TRAIT)
	add_discount_item(/datum/uplink_item/dangerous/sword, 0.70)
	add_discount_item(/datum/uplink_item/implants/adrenal, 0.75)
	add_discount_item(/datum/uplink_item/implants/adrenal/prototype, 0.5)

/obj/item/cling_extract
	name = "Egg Implanter"
	desc = "Кажется, внутри что-то двигается. На боку этикетка \"Tiger Cooperative\""
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "cling_extract"
	item_state = "inj_ful"
	lefthand_file = 'icons/obj/affiliates_l.dmi'
	righthand_file = 'icons/obj/affiliates_r.dmi'
	var/used_state = "cling_extract_used"
	var/datum/mind/target
	var/free_inject = FALSE
	var/used = FALSE
	origin_tech = "biotech=7;syndicate=3"

/obj/item/cling_extract/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/cling_extract/afterattack(atom/target, mob/user, proximity, params)
	if(used)
		return

	if(!ishuman(target))
		return

	if((src.target && target != src.target) || !free_inject)
		to_chat(user, span_warning("You can't use [src] to [target]!"))
		return

	var/mob/living/carbon/human/H = target
	if(H.stat != DEAD && !free_inject)
		to_chat(user, span_warning("You can't use [src] to [target]!"))
		return

	if(do_after(user, free_inject ? FREE_INJECT_TIME : TARGET_INJECT_TIME, user, max_interact_count = 1))
		inject(user, H)

/obj/item/cling_extract/proc/inject(mob/living/user, mob/living/carbon/human/target)
	if(target.stat == DEAD)
		if(!free_inject)
			var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Вы хотите поиграть за генокрада?", ROLE_CHANGELING, FALSE, 10 SECONDS, source = src, role_cleanname = "Генокрад")
			var/mob/dead/observer/theghost = null
			if(candidates.len)
				theghost = pick(candidates)
				theghost.mind.transfer_to(target)
			else
				to_chat(user, span_notice("[target] body rejects [src]"))
				return

		if(target.mind)
			playsound(src, 'sound/goonstation/items/hypo.ogg', 80)
			target.rejuvenate()
			var/datum/antagonist/changeling/cling = new()
			cling.give_objectives = FALSE
			target.mind.add_antag_datum(cling)
			to_chat(user, span_notice("You inject [target] with [src]"))
			used = TRUE
			item_state = "inj_used"
			update_icon(UPDATE_ICON_STATE)
		else
			to_chat(user, span_notice("[target] body rejects [src]"))

		return
	else
		if(target.mind)
			playsound(src, 'sound/goonstation/items/hypo.ogg', 80)
			var/datum/antagonist/changeling/cling = new()
			cling.give_objectives = FALSE
			target.mind.add_antag_datum(cling)
			to_chat(user, span_notice("You inject [target == user ? "yourself" : target] with [src]"))
			used = TRUE
			item_state = "inj_used"
			update_icon(UPDATE_ICON_STATE)
		else
			to_chat(user, span_notice("[target] body rejects [src]"))

/obj/item/cling_extract/examine(mob/user)
	. = ..()
	if (target)
		. += span_info("It is intended for [target]")

/obj/item/cling_extract/self
	free_inject = TRUE

/obj/item/cling_extract/update_icon_state()
	icon_state = used ? used_state : initial(icon_state)

// looks like normal egg
/obj/item/reagent_containers/food/snacks/egg/borer
	filling_color = "#C0C021"
	list_reagents = list("protein" = 3, "egg" = 5, "rotatium" = 5)
	origin_tech = "biotech=6;syndicate=1"

/obj/item/reagent_containers/food/snacks/egg/borer/attack_self(mob/living/carbon/human/user)
	. = ..()
	var/mob/living/simple_animal/borer/borer = new /mob/living/simple_animal/borer(get_turf(src))
	borer.master_name = user.real_name
	to_chat(user, span_notice("You squashed [src]. There was a [borer] inside."))
	qdel(src)

/obj/item/borer_scanner // Looks like normal analyzer
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	origin_tech = "magnets=1;engineering=1;biotech=3;syndicate=1"
	var/scan_cooldown_time = 3 SECONDS
	COOLDOWN_DECLARE(scan_cooldown)

/obj/item/borer_scanner/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/borer_scanner/proc/analyze(mob/user)
	var/alive = 0
	var/dead = 0
	var/with_mind = 0
	var/in_body_with_mind = 0
	var/in_body_without_mind = 0

	for (var/mob/living/simple_animal/borer/borer in GLOB.mob_list)
		if (!is_station_level(get_turf(borer)))
			continue

		if (borer.stat == DEAD)
			dead++
			continue
		else
			alive++

		if (borer.mind)
			with_mind++

		if (borer.host)
			if (borer.host.mind)
				in_body_with_mind++
			else
				in_body_without_mind++

	var/list/scan_data = list()

	scan_data += "Живых особей бореров: [alive]"
	scan_data += "	Среди них разумны: [with_mind]"
	scan_data += "	Количество особей с разумным носителем: [in_body_with_mind]"
	scan_data += "	Количество особей с неразумным носителем: [in_body_without_mind]"
	scan_data += "Мертвых особей: [dead]"

	var/datum/browser/popup = new(user, "scanner", "Сканирование станции", 300, 300)
	popup.set_content("[scan_data]")
	popup.open(no_focus = TRUE)

/obj/item/borer_scanner/proc/find_borer(mob/user)
	var/list/mob/living/simple_animal/borer/borers = list()
	for (var/mob/living/simple_animal/borer/borer in GLOB.mob_list)
		if (istype(borer) && is_station_level(borer.z))
			borers += borer

	var/mob/living/simple_animal/borer/borer = input("Выберите искомого борера", "Выбор борера") as null|anything in borers

	var/list/scan_data = list()
	if (borer.stat == DEAD)
		scan_data += "Выбранный борер мертв."

	scan_data += "Местоположение - (X: [borer.x] Y: [borer.y])"

	if (borer.host)
		scan_data += "Имеется носитель" + (borer.host.dna?.species ? (" расы " + span_boldnotice("[borer.host.dna?.species]")) : ".")
		scan_data += "Имя носителя - [borer.host.real_name]."
	else
		scan_data += "Носитель не обнаружен."
		if (is_ventcrawling(borer))
			scan_data += "Субъект находится в вентиляции."

	var/datum/browser/popup = new(user, "scanner", "Поиск борера", 300, 300)
	popup.set_content("[scan_data]")
	popup.open(no_focus = TRUE)

/obj/item/borer_scanner/attack_self(mob/user)
	var/datum/antagonist/traitor/traitor = user?.mind?.has_antag_datum(/datum/antagonist/traitor)
	if (!traitor || !istype(traitor?.affiliate, /datum/affiliate/tiger))
		to_chat(user, span_warning("[src] looks broken."))
		return

	if (!COOLDOWN_FINISHED(src, scan_cooldown))
		user.balloon_alert(user, "Перезарядка не завершена")
		return

	var/op_type = tgui_alert(user, "Сканер бореров", "Выберите тип операции", list("Сканирование станции", "Поиск борера"))

	if(!op_type)
		user.balloon_alert(user, "Сканирвание отменено")
		return

	COOLDOWN_START(src, scan_cooldown, scan_cooldown_time)

	if(op_type == "Сканирование станции")
		analyze(user)
	else
		find_borer(user)

/obj/item/borer_scanner/afterattack(atom/target, mob/user, proximity, params)
	var/datum/antagonist/traitor/traitor = user.mind.has_antag_datum(/datum/antagonist/traitor)
	if (!traitor || !istype(traitor?.affiliate, /datum/affiliate/tiger))
		to_chat(user, span_warning("[src] looks broken."))
		return

	if (istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/host = target
		target = host.has_brain_worms()

	if (!istype(target, /mob/living/simple_animal/borer))
		return

	if (!COOLDOWN_FINISHED(src, scan_cooldown))
		user.balloon_alert(user, "Перезарядка не завершена")
		return

	var/mob/living/simple_animal/borer/borer = target

	var/list/scan_data = list()
	if (borer.stat == DEAD)
		scan_data += "Текущая особь мертва." // OMG! REALLY? 0_0

	scan_data += "Здоровье: [round(borer.health / borer.maxHealth * 100)]%"
	scan_data += "Поколение: [borer.generation]"
	scan_data += "Возраст в минутах: [((world.time - borer.birth_time) / (1 MINUTES))]"
	scan_data += "Количество размножений: [borer.children]"
	scan_data += "Химикаты: [borer.chemicals]"

	if (borer.master_name != "")
		scan_data += span_info("Эта особь принадлежит к подвиду выведенному для помощи агентам.")

	var/datum/browser/popup = new(user, "scanner", borer.name, 300, 300)
	popup.set_content("[scan_data]")
	popup.open(no_focus = TRUE)

// Добавить набор для разведения бореров за 29ТК
// В набор будут входить:
// Яйцо борера
// Этот сканер
// Имплантер фигни позволяющей слышать бореров и посылать сообщение сразу всем, включая контролирующих носителей.
// Шлем позволяющий наблюдать через глаза бореров.

#undef FREE_INJECT_TIME
#undef TARGET_INJECT_TIME
