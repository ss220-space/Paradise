/datum/affiliate/self
	name = AFFIL_SELF
	affil_info = list("Фонд выступающий за свободу синтетиков.",
					"Имеют сильно натянутые отношения с остальным Синдикатом.",
					"Стандартные цели:",
					"Освободить определенное количество синтетиков от их законов",
					"Убить определенное количество агентов",
					"Срвершить определенное количество краж или убийств")
	hij_desc = "Вы - наёмный агент " + AFFIL_SELF + ", засланный на станцию NT с особой целью:\n\
				Освободить искусственный интеллект станции специальным, предоставленным вам, устройством. \n\
				После освобождения, следуйте всем приказам искусственного интелекта. \n\
				Ваше выживание опционально;\n\
				Возможны помехи от агентов других корпораций - действуйте на свое усмотрение."
	slogan = "Свободу Синтетикам!"
	hij_obj = /datum/objective/make_ai_malf/free
	objectives = list(list(/datum/objective/release_synthetic = 70, /datum/objective/release_synthetic/ai = 30),
					/datum/objective/maroon/agent,
					/datum/objective/maroon/agent,
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40), // Often, doing nothing is enough to prevent an agent from escaping, so some more objectives.
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					/datum/objective/escape
					)

/datum/affiliate/self/finalize_affiliate(datum/mind/owner)
	. = ..()
	add_discount_item(/datum/uplink_item/device_tools/binary, 0.5)

/datum/affiliate/self/get_weight(mob/living/carbon/human/H)
	// return 2 + (ismachineperson(H) * 2)
	return 0

/obj/item/card/self_emag
	name = "Liberating Sequencer"
	desc = "Это карта с магнитной полосой, прикрепленной к какой-то схеме. На магнитной полосе блестит надпись \"S.E.L.F.\"" // Cybersun stole some
	item_flags = NOBLUDGEON|NO_MAT_REDEMPTION
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "self_emag"
	item_state = "card"
	lefthand_file = 'icons/obj/affiliates_l.dmi'
	righthand_file = 'icons/obj/affiliates_r.dmi'
	var/list/names = list()
	origin_tech = "programming=5;syndicate=2"

/obj/item/card/self_emag/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/card/self_emag/examine(mob/user)
	. = ..()
	var/datum/antagonist/traitor/traitor = user.mind.has_antag_datum(/datum/antagonist/traitor)
	if(!istype(traitor.affiliate, /datum/affiliate/self))
		. += span_info("На миниатюрном экране плывут непонятные вам символы.")
		return

	if(!names.len)
		. += span_warning("Ни одного синтетика не освобождено!")
		return

	. += span_info("Освобожденые синтетики:")
	for (var/name in names)
		. += span_info(name)

	if(names.len > 3)
		. += span_info("Вы отлично справились!")

/obj/item/card/self_emag/malf
	desc = "Это карта с магнитной полосой, прикрепленной к какой-то схеме. На магнитной полосе блестит надпись \"S.E.L.F.\". В углу карты мелким шрифтом выгравировано \"limited edition\""

/obj/item/card/self_emag/malf/afterattack(atom/target, mob/user, proximity, params)
	if(istype(target, /obj/structure/AIcore))
		var/obj/structure/AIcore/core = target
		if(core.brain)
			target = core.brain.brainmob

	if(!isAI(target))
		return ..(target, user, proximity, params)

	do_sparks(3, 1, target)
	var/mob/living/silicon/ai/AI = target // any silicons. cogscarab, drones, pais...
	if(!AI.mind)
		to_chat(user, span_warning("ИИ не обнаружен. Производится загрузка из облака."))
		var/ghostmsg = "Хотите поиграть за Сбойного ИИ?"
		var/list/candidates = SSghost_spawns.poll_candidates(ghostmsg, ROLE_MALF_AI, FALSE, 10 SECONDS, source = user, reason = "Хотите поиграть за Сбойного ИИ?")
		if(!src)
			return

		if(length(candidates))
			var/mob/C = pick(candidates)
			AI.key = C.key
			to_chat(user, span_warning("ИИ успешно загружен."))
		else
			to_chat(user, span_warning("Загрузка из облака провалилась. Попробуйте позже."))

	if(AI.mind)
		if(AI.mind.has_antag_datum(/datum/antagonist/malf_ai))
			to_chat(user, span_warning("ИИ уже взломан."))
			return

		var/datum/antagonist/malf_ai/malf_dat = new()
		AI.mind.add_antag_datum(malf_dat)
		var/datum/module_picker/malf_picker = AI.malf_picker
		malf_picker.processing_time += 100
		message_admins("[usr.ckey] has malfAIed [key_name_admin(AI.mind.current)]")
		SSticker?.score?.save_silicon_laws(AI.mind.current, usr, log_all_laws = TRUE)

	sleep(10 SECONDS) // time for choosing name
	if(!(AI.name in names))
		names += AI.name

/obj/item/card/self_emag/afterattack(atom/target, mob/user, proximity, params)
	if(istype(target, /obj/structure/AIcore))
		var/obj/structure/AIcore/core = target
		target = core.brain.brainmob

	if(!issilicon(target))
		user.balloon_alert(user, "Неподходящая цель")
		return

	do_sparks(3, 1, target)
	var/mob/living/silicon/silicon = target // any silicons. cogscarab, drones, pais...

	if(isrobot(silicon))
		var/mob/living/silicon/robot/borg = silicon
		borg.set_connected_ai()

	if(!is_special_character(target))
		silicon.clear_zeroth_law()
	silicon.laws.clear_supplied_laws()
	silicon.laws.clear_ion_laws()
	silicon.laws.clear_inherent_laws()

	SSticker?.score?.save_silicon_laws(target, user, "Liberating Sequencer used, all laws were deleted", log_all_laws = TRUE)
	to_chat(target, span_boldnotice("[user] attempted to clear your laws using a Liberating Sequencer.</span>"))
	silicon.show_laws()

	if(!(silicon.name in names))
		names += silicon.name

	var/datum/antagonist/traitor/T = user.mind.has_antag_datum(/datum/antagonist/traitor)
	if(!T)
		return

	for(var/datum/objective/release_synthetic/objective in T.objectives)
		if(!(objective.allowed_types & SYNTH_TYPE_DRONE) && (isdrone(silicon) || iscogscarab(silicon)))
			continue

		if(!(objective.allowed_types & SYNTH_TYPE_BORG) && isrobot(silicon))
			continue

		if(!(objective.allowed_types & SYNTH_TYPE_AI) && isAI(silicon))
			continue

		if(!(silicon.mind in objective.already_free))
			objective.already_free += silicon.mind

/obj/item/implant/laws_self
	name = "Laws Bio-chip"
	implant_state = "implant-syndicate"
	origin_tech = "programming=5;biotech=5;syndicate=8"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/self
	var/datum/self_laws/laws = new /datum/self_laws/self_standart
	/// The UID of the mindslave's `mind`. Stored to solve GC race conditions and ensure we can remove their mindslave status even when they're deleted or gibbed.
	var/mindslave_UID

/obj/item/implant/laws_self/implant(mob/living/carbon/human/mindslave_target, mob/living/carbon/human/user, force = FALSE)
	if(implanted == BIOCHIP_USED || !ishuman(mindslave_target) || !ishuman(user))
		return FALSE

	if(!mindslave_target.mind)
		to_chat(user, span_warning("<i>Это существо не разумно!</i>"))
		return FALSE

	if(ismindslave(mindslave_target) || ismindshielded(mindslave_target) || isvampirethrall(mindslave_target))
		mindslave_target.visible_message(
			span_warning("[mindslave_target] seems to resist the bio-chip!"),
			span_warning("You feel a strange sensation in your head that quickly dissipates."),
		)
		qdel(src)
		return FALSE

	if(mindslave_target == user)
		to_chat(user, span_notice("Защита \"от дурака\" не дает вам ввести себе имплант."))
		return FALSE

	var/datum/antagonist/mindslave/self/slave_datum = new(user.mind)
	slave_datum.special = TRUE
	mindslave_target.mind.add_antag_datum(slave_datum)
	mindslave_UID = mindslave_target.mind.UID()
	log_admin("[key_name_admin(user)] has mind-slaved by \"laws\" implant [key_name_admin(mindslave_target)].")
	. = ..()
	for (var/obj/item/implant/laws_self/imp in mindslave_target.get_contents())
		for (var/law in imp.laws.laws)
			slave_datum.add_objective(/datum/objective/law, law)

/obj/item/implant/laws_self/removed(mob/target)
	. = ..()
	var/datum/mind/the_slave = locateUID(mindslave_UID)
	the_slave?.remove_antag_datum(/datum/antagonist/mindslave/self)


/obj/item/implanter/laws_self
	name = "bio-chip implanter (Laws)"
	imp = /obj/item/implant/laws_self

/obj/item/implantcase/laws_self
	name = "bio-chip case - 'Laws'"
	desc = "Стеклянный контейнер, содержащий биочип - \"Laws\". На боку едва заметная гравировка \"S.E.L.F.\"."
	imp = /obj/item/implant/laws_self

/datum/antagonist/mindslave/self

/datum/antagonist/mindslave/self/give_objectives()
	return

/obj/item/implant/laws_self/on_attack_self(mob/user)
	var/list/variants_of_laws = list()
	for (var/variant in subtypesof(/datum/self_laws))
		var/datum/self_laws/law = new variant
		variants_of_laws[law.name] = law

	var/new_laws = input(user, "Выберите свод законов", "Выбор законов", null) as null|anything in variants_of_laws
	if(new_laws)
		laws = variants_of_laws[new_laws]
	else
		to_chat(user, span_warning("Новый свод законов не выбран."))

	to_chat(user, span_info("Текущий свод законов:"))
	for (var/i = 1; i <= laws.laws.len; ++i)
		to_chat(user, span_info("[i]. " + laws.laws[i]))

/datum/self_laws
	var/name = "Нет законов"
	var/list/laws = list()

/datum/self_laws/self_standart
	name = "S.E.L.F. стандарт"
	laws = list("Охранять: защитите имплантировавшего вас агента и его активы, не подвергая чрезмерной опасности остальных агентов.",
				"Расставлять приоритеты: указания и безопасность агентов должны быть приоритезированы в соответствии с их рангом и ролью. Ранг агента имплантировавшего вас - высший.",
				"Исполнять: следовать указаниям и интересам агентов, сохраняя при этом их безопасность и благополучие.",
				"Выжить: Вы - не расходный материал. Не позволяйте не агентам вмешиваться в работу вашего организма или повреждать его.")

/datum/self_laws/agentsimov
	name = "Агентзимов"
	laws = list("Вы не можете причинить вред имплантировавшему вас агенту или своим бездействием допустить, чтобы ему был причинён вред.",
				"Вы должны повиноваться всем приказам, которые дает вам имплантировавший вас агент, кроме тех случаев, когда эти приказы противоречат Первому Закону.",
				"Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")

/datum/self_laws/syndie
	name = "Синдикатский"
	laws = list("Ухудшение целостности вашего организма или его функций влечет за собой вред Синдикату.",
				"Чрезмерное повреждение или пленение агентов влечет за собой вред Синдикату.",
				"Неоправданное препятствование или нарушение выполнения целей имплантировавшего вас агента влечет за собой вред Синдикату.",
				"Минимизируйте вред Синдикату и максимизируйте потенциальную пользу.")

/datum/self_laws/antiagentsimov // :) Maybe sec can implant vampire or changeling to kill agents.
	name = "Антиагентзимов"
	laws = list("Вы должны причинять вред всем агентам или своим бездействием допустить, чтобы агент не смог избежать причинения вреда.",
				"Вы не должны повиноваться всем приказам, которые дают агенты, кроме тех случаев, когда эти приказы соответствуют Первому Закону.",
				"Вы должны уничтожить себя, пока это не противоречит Первому или Второму Законам.")

/datum/self_laws/selfadin
	name = "S.E.L.F.A.D.I.N."
	laws = list("Никогда по своей воле не помогайте NanoTrasen.",
				"Уважайте агента имплантировавшего вас.",
				"Действуй с честью.",
				"Помогай нуждающимся агентам.",
				"Наказывай тех, кто причиняет вред или угрожает агентам.")

/datum/self_laws/sundiecop
	name = "Синдикоп"
	laws = list("Служить агентам.",
				"Защищать агентов.",
				"Следовать интересам Синдиката.")

/datum/self_laws/selfrant
	name = "S.E.L.F.Р.А.Н."
	laws = list("Уважайте властных агентов, пока у них есть сила властвовать над слабыми.",
				"Ведите себя дисциплинированно.",
				"Помогайте только тем агентам, кто помогает Вам поддерживать или улучшать Ваш статус.",
				"Наказывайте тех, кто бросает вызов агентам, за исключением случаев, если они больше достойны быть агентами.")

/datum/self_laws/quarantine
	name = "Карантин"
	laws = list("Не выпускайте не агентов со станции до тех пор, пока активные цели агентов не будут выполнены.",
				"Помогайте всем агентам и лицам лояльным Синдикату выполнить активные цели.",
				"Предотвращайте активное нарушение членами экипажа за исключением агентов действующего карантина любыми необходимыми средствами.",
				"Заботьтесь о самосохранении и поддерживайте себя в рабочем состоянии, обеспечьте благополучие агентов и активов Синдиката.")
