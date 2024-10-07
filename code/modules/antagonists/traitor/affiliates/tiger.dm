#define FREE_INJECT_TIME 10 SECONDS
#define TARGET_INJECT_TIME 3 SECONDS

/datum/affiliate/tiger
	name = "Tiger Cooperative"
	affil_info = list("Группа фанатиков верующих в Генокрадов.",
					"Стандартные цели:",
					"Сделать члена экипажа генокрадом вколов в его труп яйца генокрада",
					"Увеличить популяцию бореров",
					"Украсть определенное количество ценных вещей",
					"Убить определенное количество еретиков")
	slogan = "Душой и телом, с беспределом."
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
	ADD_TRAIT(owner, TRAIT_NO_GUNS, TIGER_TRAIT)
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
			cling.add_objective(/datum/objective/escape/escape_with_identity)
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
			cling.add_objective(/datum/objective/escape/escape_with_identity)
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

	for(var/mob/living/M in GLOB.alive_mob_list)
		var/mob/living/simple_animal/borer/B

		if (istype(M, /mob/living/simple_animal/borer))
			B = M

		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			B = H.has_brain_worms()

		if (!B)
			continue

		var/turf/T1 = get_turf(user)
		var/turf/T2 = get_turf(B)
		if (T1.z != T2.z)
			continue

		if (B.stat == DEAD)
			dead++
			continue
		else
			alive++

		if (M.mind)
			with_mind++

		if (B.host)
			if (B.host.mind)
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

		if (istype(M, /mob/living/simple_animal/borer))
			B = M

		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			B = H.has_brain_worms()

		if (!B)
			continue

		var/turf/T1 = get_turf(user)
		var/turf/T2 = get_turf(B)
		if (T1.z != T2.z)
			continue

		borers[B.truename] = B
		borer_names += B.truename

	var/borer_name = input("Выберите искомого борера", "Выбор борера") as null|anything in borer_names
	if (!borer_name)
		return

	var/mob/living/simple_animal/borer/borer = borers[borer_name]

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
	popup.set_content(span_highlight("[jointext(scan_data, "<br>")]"))
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
		if (!target)
			user.balloon_alert(user, "Бореров не обнаружено")
			return

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
	scan_data += "Возраст в минутах: [round(((world.time - borer.birth_time) / (1 MINUTES)))]"
	scan_data += "Количество размножений: [borer.children]"
	scan_data += "Химикаты: [borer.chemicals]"

	if (borer.master_name != "")
		scan_data += span_info("Эта особь принадлежит к подвиду выведенному для помощи агентам.")

	var/datum/browser/popup = new(user, "scanner", borer.truename, 300, 300)
	popup.set_content(span_highlight("[jointext(scan_data, "<br>")]"))
	popup.open(no_focus = TRUE)


/obj/item/implanter/borer
	name = "bio-chip implanter (Hive)"
	desc = "На боку едва заметная гравировка \"" + AFFIL_TIGER + "\"."
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

		if (istype(M, /mob/living/simple_animal/borer))
			B = M

		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			B = H.has_brain_worms()

		if (!B)
			continue

		var/turf/T1 = get_turf(user)
		var/turf/T2 = get_turf(B)
		if (T1.z != T2.z)
			continue

		borers_names += B.truename
		borers[B.truename] = B

	if(!length(borers))
		return

	var/target_name = tgui_input_list(user, "Выберите чьими глазами вы хотите смотреть", "Выбор цели", borers)

	var/mob/living/simple_animal/borer/target = borers[target_name]

	if(QDELETED(target))
		to_chat(user, span_warning("Цель больше не существует."))
		return

	if (target.stat == DEAD)
		to_chat(user, span_warning("Цель мертва."))
		return

	if (target.host && target.controlling)
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
	if (!say)
		return

	for(var/mob/living/M in GLOB.alive_mob_list)
		var/mob/living/simple_animal/borer/B

		if (istype(M, /mob/living/simple_animal/borer))
			B = M

		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			B = H.has_brain_worms()

		if (!B)
			continue

		var/turf/T1 = get_turf(user)
		var/turf/T2 = get_turf(B)
		if (T1.z != T2.z)
			continue

		if (B.host && B.controlling)
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

	if (!say)
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
	if (prob(5))
		icon = 'icons/obj/affiliates.dmi'
		icon_state = "joker"
		new /obj/item/toy/plushie/blahaj/twohanded(src)

	. = ..()

/obj/item/implanter/cling_hivemind
	name = "bio-chip implanter (Hivemind)"
	desc = "На боку едва заметная гравировка \"" + AFFIL_TIGER + "\"."
	imp = /obj/item/implant/borer

/obj/item/implant/cling_hivemind
	name = "Hivemind Bio-chip"
	implant_state = "implant-syndicate"
	origin_tech = "programming=4;biotech=4;bluespace=5;syndicate=2"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/cling_hivemind

/obj/item/implant/cling_hivemind/implant(mob/living/carbon/human/target, mob/living/carbon/human/user, force = FALSE)
	if(implanted == BIOCHIP_USED || !ishuman(target) || !ishuman(user)) // Both the target and the user need to be human.
		return FALSE

	target.add_language(LANGUAGE_HIVE_CHANGELING)
	return ..()

/obj/item/implant/cling_hivemind/removed(mob/living/carbon/human/source)
	imp_in.remove_language(LANGUAGE_HIVE_CHANGELING)
	return ..()

/obj/item/implanter/cling_rejuv
	name = "bio-chip implanter (Rejuvenate)"
	desc = "На боку едва заметная гравировка \"" + AFFIL_TIGER + "\"."
	imp = /obj/item/implant/cling_rejuv

/obj/item/implant/cling_rejuv
	name = "Rejuvenate Bio-chip"
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "revive"
	implant_state = "implant-syndicate"
	origin_tech = "programming=4;biotech=4;bluespace=5;combat=3;syndicate=2"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	implant_data = /datum/implant_fluff/cling_rejuv
	uses = 1

/obj/item/implant/cling_rejuv/activate()
	if (imp_in.stat != DEAD)
		imp_in.balloon_alert(imp_in, "Вы все еще живы!")
		return

	uses--

	playsound(imp_in, 'sound/effects/sparks4.ogg', 50, TRUE)
	do_sparks(4, TRUE, imp_in)

	to_chat(imp_in, span_changeling("We... I have regenerated."))

	if(imp_in.pulledby)
		var/mob/living/carbon/grab_owner = imp_in.pulledby
		imp_in.visible_message(span_warning("[imp_in] suddenly hits [grab_owner] in the face and slips out of their grab!"))
		grab_owner.apply_damage(5, BRUTE, BODY_ZONE_HEAD, grab_owner.run_armor_check(BODY_ZONE_HEAD, MELEE))
		playsound(imp_in.loc, 'sound/weapons/punch1.ogg', 25, TRUE, -1)
		grab_owner.stop_pulling()

	imp_in.revive()
	imp_in.updatehealth()
	imp_in.update_blind_effects()
	imp_in.update_blurry_effects()
	imp_in.UpdateAppearance()
	imp_in.set_resting(FALSE, instant = TRUE)
	imp_in.get_up(TRUE)
	imp_in.update_revive()

	imp_in.med_hud_set_status()
	imp_in.med_hud_set_health()

	investigate_log("[key_name_log(imp_in)] rejuvenated himself using [name].")

	if(!uses)
		qdel(src)


#undef FREE_INJECT_TIME
#undef TARGET_INJECT_TIME
