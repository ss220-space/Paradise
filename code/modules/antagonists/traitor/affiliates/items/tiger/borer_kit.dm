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

	for(var/mob/living/M in GLOB.alive_mob_list)
		var/mob/living/simple_animal/borer/B

		if(isborer(M))
			B = M

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			B = H.has_brain_worms()

		if(!B)
			continue

		var/turf/T1 = get_turf(user)
		var/turf/T2 = get_turf(B)
		if(T1.z != T2.z)
			continue

		if(B.stat == DEAD)
			dead++
			continue
		else
			alive++

		if(M.mind)
			with_mind++

		if(B.host)
			if(B.host.mind)
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
	popup.set_content(span_highlight("[jointext(scan_data, "<br>")]"))
	popup.open(no_focus = TRUE)

/obj/item/borer_scanner/proc/find_borer(mob/user)
	var/list/borers = list()
	var/list/borer_names = list()
	for(var/mob/living/M in GLOB.alive_mob_list)
		var/mob/living/simple_animal/borer/B

		if(isborer(M))
			B = M

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			B = H.has_brain_worms()

		if(!B)
			continue

		var/turf/T1 = get_turf(user)
		var/turf/T2 = get_turf(B)
		if(T1.z != T2.z)
			continue

		borers[B.truename] = B
		borer_names += B.truename

	var/borer_name = input("Выберите искомого борера", "Выбор борера") as null|anything in borer_names
	if(!borer_name)
		return

	var/mob/living/simple_animal/borer/borer = borers[borer_name]

	var/list/scan_data = list()
	if(borer.stat == DEAD)
		scan_data += "Выбранный борер мертв."

	scan_data += "Местоположение - (X: [borer.x] Y: [borer.y])"

	if(borer.host)
		scan_data += "Имеется носитель" + (borer.host.dna?.species ? (" расы " + span_boldnotice("[borer.host.dna?.species]")) : ".")
		scan_data += "Имя носителя - [borer.host.real_name]."
	else
		scan_data += "Носитель не обнаружен."
		if(is_ventcrawling(borer))
			scan_data += "Субъект находится в вентиляции."

	var/datum/browser/popup = new(user, "scanner", "Поиск борера", 300, 300)
	popup.set_content(span_highlight("[jointext(scan_data, "<br>")]"))
	popup.open(no_focus = TRUE)

/obj/item/borer_scanner/attack_self(mob/user)
	var/datum/antagonist/traitor/traitor = user?.mind?.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor || !istype(traitor?.affiliate, /datum/affiliate/tiger))
		to_chat(user, span_warning("[src] looks broken."))
		return

	if(!COOLDOWN_FINISHED(src, scan_cooldown))
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
	if(!traitor || !istype(traitor?.affiliate, /datum/affiliate/tiger))
		to_chat(user, span_warning("[src] looks broken."))
		return

	if(ishuman(target))
		var/mob/living/carbon/human/host = target
		target = host.has_brain_worms()
		if(!target)
			user.balloon_alert(user, "Бореров не обнаружено")
			return

	if(!isborer(target))
		return

	if(!COOLDOWN_FINISHED(src, scan_cooldown))
		user.balloon_alert(user, "Перезарядка не завершена")
		return

	var/mob/living/simple_animal/borer/borer = target

	var/list/scan_data = list()
	if(borer.stat == DEAD)
		scan_data += "Текущая особь мертва." // OMG! REALLY? 0_0

	scan_data += "Здоровье: [round(borer.health / borer.maxHealth * 100)]%"
	scan_data += "Поколение: [borer.generation]"
	scan_data += "Возраст в минутах: [round(((world.time - borer.birth_time) / (1 MINUTES)))]"
	scan_data += "Количество размножений: [borer.children]"
	scan_data += "Химикаты: [borer.chemicals]"

	if(borer.master_name)
		scan_data += span_info("Эта особь принадлежит к подвиду выведенному для помощи агентам.")

	var/datum/browser/popup = new(user, "scanner", borer.truename, 300, 300)
	popup.set_content(span_highlight("[jointext(scan_data, "<br>")]"))
	popup.open(no_focus = TRUE)


/obj/item/implanter/borer
	name = "bio-chip implanter (Hive)"
	desc = "На боку едва заметная гравировка \"Tiger Cooperative\"."
	imp = /obj/item/implant/borer

/obj/item/implant/borer
	name = "Hive Bio-chip"
	implant_state = "implant-syndicate"
	origin_tech = "programming=4;biotech=6;bluespace=4"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/borer

/obj/item/implant/borer/implant(mob/living/carbon/human/target, mob/living/carbon/human/user, force = FALSE)
	if(implanted == BIOCHIP_USED || !ishuman(target) || !ishuman(user)) // Both the target and the user need to be human.
		return FALSE

	target.add_language(LANGUAGE_HIVE_BORER)
	target.AddSpell(new /obj/effect/proc_holder/spell/remoteview/borer)
	target.AddSpell(new /obj/effect/proc_holder/spell/pm_for_borer)
	target.AddSpell(new /obj/effect/proc_holder/spell/msg_for_borers)
	return ..()

/obj/item/implant/borer/removed(mob/living/carbon/human/source)
	imp_in.remove_language(LANGUAGE_HIVE_BORER)
	imp_in.RemoveSpell(/obj/effect/proc_holder/spell/remoteview/borer)
	imp_in.RemoveSpell(/obj/effect/proc_holder/spell/pm_for_borer)
	imp_in.RemoveSpell(/obj/effect/proc_holder/spell/msg_for_borers)
	return ..()

/obj/effect/proc_holder/spell/remoteview/borer
	name = "Connect to borer"
	desc = "Смотрите глазами любого борера в том же секторе."
	base_cooldown = 3 SECONDS
	action_background_icon_state = "bg_alien"

/obj/effect/proc_holder/spell/remoteview/borer/create_new_targeting()
	return new /datum/spell_targeting/borer

/datum/spell_targeting/borer/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	var/list/borers_names = list()
	var/list/borers = list()
	for(var/mob/living/M in GLOB.alive_mob_list)
		var/mob/living/simple_animal/borer/B

		if(isborer(M))
			B = M

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			B = H.has_brain_worms()

		if(!B)
			continue

		var/turf/T1 = get_turf(user)
		var/turf/T2 = get_turf(B)
		if(T1.z != T2.z)
			continue

		borers_names += B.truename
		borers[B.truename] = B

	if(!length(borers))
		return

	var/target_name = tgui_input_list(user, "Выберите чьими глазами вы хотите смотреть", "Выбор цели", borers)

	var/mob/living/simple_animal/borer/target = borers[target_name]

	if(QDELETED(target))
		user.balloon_alert(user, "цели не существует")
		return

	if(target.stat == DEAD)
		user.balloon_alert(user, "цель мертва")
		return

	if(target.host && target.controlling)
		target = target.host

	return list(target)


/obj/effect/proc_holder/spell/msg_for_borers
	name = "Message for all borers"
	desc = "Послать сообщение всем борерам, включая тех, что контролируют носителей."
	base_cooldown = 2 SECONDS
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	action_icon_state = "genetic_project"
	action_background_icon_state = "bg_alien"
	break_remoteview = FALSE

/obj/effect/proc_holder/spell/msg_for_borers/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/msg_for_borers/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return

	if(user.mind?.miming)
		to_chat(user, span_warning("Вы не можете общаться, пока не нарушите обет молчания."))
		return

	var/say = tgui_input_text(user, "Что вы хотите сообщить?", "Сообшение борерам")
	if(!say)
		return

	for(var/mob/living/M in GLOB.alive_mob_list)
		var/mob/living/simple_animal/borer/B

		if(isborer(M))
			B = M

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			B = H.has_brain_worms()

		if(!B)
			continue

		var/turf/T1 = get_turf(user)
		var/turf/T2 = get_turf(B)
		if(T1.z != T2.z)
			continue

		if(B.host && B.controlling)
			to_chat(B.host, "Голос в голове говорит: \"" + span_alien(say) + "\"")
			SEND_SOUND(B.host, 'sound/effects/adminhelp.ogg')
		else
			to_chat(B, "Голос в голове говорит: \"" + span_alien(say) + "\"")
			SEND_SOUND(B, 'sound/effects/adminhelp.ogg') // neuron activation


/obj/effect/proc_holder/spell/pm_for_borer
	name = "Privat message for borer"
	desc = "Послать личное сообщение конкретному бореру."
	base_cooldown = 2 SECONDS
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	action_icon_state = "genetic_project"
	action_background_icon_state = "bg_alien"
	break_remoteview = FALSE

/obj/effect/proc_holder/spell/pm_for_borer/create_new_targeting()
	return new /datum/spell_targeting/borer

/obj/effect/proc_holder/spell/pm_for_borer/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return

	if(user.mind?.miming)
		to_chat(user, span_warning("Вы не можете общаться, пока не нарушите обет молчания."))
		return

	var/say = tgui_input_text(user, "Что вы хотите сообщить?", "[targets[1]]")

	if(!say)
		return

	for(var/mob/living/target in targets)
		to_chat(target, span_alien(say))
		SEND_SOUND(target, 'sound/effects/adminhelp.ogg') // neuron activation

/obj/item/storage/box/syndie_kit/borer
	name = "Borer kit box"

/obj/item/storage/box/syndie_kit/borer/populate_contents()
	new /obj/item/reagent_containers/food/snacks/egg/borer(src)
	new /obj/item/borer_scanner(src)
	new /obj/item/implanter/borer(src)

/obj/item/storage/box/syndie_kit/borer/New()
	if(prob(5))
		icon = 'icons/obj/affiliates.dmi'
		icon_state = "joker"
		new /obj/item/toy/plushie/blahaj/twohanded(src)

	. = ..()
