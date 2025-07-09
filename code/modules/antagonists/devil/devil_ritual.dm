/datum/ritual/devil
	allowed_special_role = list(ROLE_DEVIL)
	cooldown_after_cast = null
	disaster_prob = 0
	fail_chance = 0

/datum/ritual/devil/imp
	name = "Ритуал призыва беса"
	description = "Призывает беса, который захочет получить"
	required_things = list(
		/obj/item/wirecutters = 3,
		/obj/item/organ/internal/kidneys = 2,
		/obj/item/organ/internal/heart = 1,
		/obj/effect/decal/cleanable/vomit = 2
	)
	var/ritual_lock = FALSE

/datum/ritual/devil/imp/del_things(list/used_things)
	for(var/obj/obj in used_things) // no type ignore for future.
		qdel(obj)

	return

/datum/ritual/devil/imp/do_ritual(mob/living/carbon/invoker, list/invokers, list/used_things)
	if(ritual_lock)
		ritual_object.balloon_alert(invoker, "ритуал временно недоступен")
		return RITUAL_FAILED_ON_PROCEED

	ritual_lock = TRUE
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за беса?", ROLE_DEVIL, TRUE, role_cleanname = "беса")
	ritual_lock = FALSE
	if(!LAZYLEN(candidates))
		ritual_object.balloon_alert(invoker, "призыв проигнорирован")
		return RITUAL_FAILED_ON_PROCEED

	var/mob/mob = pick(candidates)
	var/mob/living/simple_animal/imp/ritual/imp = new(get_turf(ritual_object))

	imp.key = mob.key
	imp.master_commander = invoker

	improve_imp(imp, invoker)

	return RITUAL_SUCCESSFUL

/datum/ritual/devil/imp/proc/improve_imp(mob/living/simple_animal/imp/imp, mob/living/carbon/invoker)
	var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)

	imp.universal_speak = TRUE
	imp.sentience_act()

	imp.mind.store_memory("Я подчиняюсь призывателю [imp.master_commander.name], также известному как [devil.info.truename].")
	imp.mind.add_antag_datum(/datum/antagonist/imp)

/datum/ritual/devil/sacrifice
	name = "Ритуал жертвоприношения"
	description = "Позволяет вам принести нужного вам гуманоида в жертву и получить его душу."
	ritual_should_del_things = FALSE
	required_things = list(
		/mob/living/carbon/human = 1
	)

/datum/ritual/devil/sacrifice/get_ui_things()
	var/list/things = list()
	things["жертва"] = 1
	return things

/datum/ritual/devil/sacrifice/check_contents(mob/living/carbon/invoker, list/used_things)
	. = ..()

	if(!.)
		return FALSE

	var/mob/living/carbon/human/human = locate() in used_things

	var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)

	if(human.stat != DEAD)
		ritual_object.balloon_alert(invoker, "жертва не мертва!")
		return FALSE

	if(!human.mind || !(human.mind.hasSoul || LAZYIN(devil.soulsOwned, human.mind)))
		ritual_object.balloon_alert(invoker, "жертва без души!")
		return FALSE

	if(!(SEND_SIGNAL(human.mind, COMSIG_DEVIL_SACRIFICE_CHECK) & COMPONENT_SACRIFICE_VALID))
		ritual_object.balloon_alert(invoker, "не имеет ценности!")
		return FALSE

	return TRUE

/datum/ritual/devil/sacrifice/do_ritual(mob/living/carbon/invoker, list/invokers, list/used_things)
	var/mob/living/carbon/human/human = locate() in used_things
	var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)

	if(!devil || !human || !human.mind)
		return RITUAL_FAILED_ON_PROCEED

	devil.sacrifice_soul(human.mind)

	SEND_SIGNAL(human.mind, COMSIG_DEVIL_SACRIFICE)

	return RITUAL_SUCCESSFUL


/datum/ritual/devil/ascendetion
	name = "Ритуал возвышения"
	description = "Представляет собой улучшенный ритуал жертвоприношения, необходимый дьяволу, чтобы возвыситься до Архидьявола."
	ritual_should_del_things = FALSE
	required_things = list(
		/mob/living/carbon/human = 2
	)
	var/static/list/timers_list = list(
		FIRST_DEVIL_ASCEND_STAGE = 10 SECONDS,
		SECOND_DEVIL_ASCEND_STAGE = 25 SECONDS,
		THIRD_DEVIL_ASCEND_STAGE = 20 SECONDS,
		FOURTH_DEVIL_ASCEND_STAGE = 10 SECONDS,
		FIFTH_DEVIL_ASCEND_STAGE = 4 SECONDS,
		SIXTH_DEVIL_ASCEND_STAGE = 4 SECONDS,
		SEVENTH_DEVIL_ASCEND_STAGE = 0.1 SECONDS,
		EIGHTH_DEVIL_ASCEND_STAGE = 5 SECONDS,
	)

/datum/ritual/devil/ascendetion/get_ui_params()
	var/list/params = ..()
	params["Необходимо соответствовать требованиям для возвышения"] = " "
	params["Необходимо выполнить цель на осквернение душ"] = " "
	params["Необходим ранг истинного дьявола"] = " "
	return params

/datum/ritual/devil/ascendetion/get_ui_things()
	var/list/things = list()
	things["жертва"] = 2
	return things

/datum/ritual/devil/ascendetion/check_contents(mob/living/carbon/invoker, list/used_things)
	. = ..()

	if(!.)
		return FALSE

	var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)

	var/datum/objective/devil/sintouch/sintouch_objective = locate() in devil.objectives

	if(!sintouch_objective || !(sintouch_objective.check_completion()))
		ritual_object.balloon_alert(invoker, "мало грешников!")
		return FALSE

	if(devil.soulsOwned.len < ASCEND_THRESHOLD)
		ritual_object.balloon_alert(invoker, "недостаточно душ!")
		return FALSE

	if(devil.rank.type != TRUE_DEVIL_RANK)
		ritual_object.balloon_alert(invoker, "вы слишком слабы!")
		return FALSE

	var/count

	for(var/mob/living/carbon/human/human in used_things)
		if(human.stat != DEAD)
			ritual_object.balloon_alert(invoker, "одна из жертв не мертва!")
			return FALSE

		if(!human.mind || !(human.mind.hasSoul || LAZYIN(devil.soulsOwned, human.mind)))
			ritual_object.balloon_alert(invoker, "одна из жертв без души!")
			return FALSE

		if(!(SEND_SIGNAL(human.mind, COMSIG_DEVIL_SACRIFICE_CHECK) & COMPONENT_SACRIFICE_VALID))
			ritual_object.balloon_alert(invoker, "одна из жертв бесполезна!")
			return FALSE

		count += 1

	if(count < required_things[/mob/living/carbon/human])
		ritual_object.balloon_alert(invoker, "мало жертв!")
		return FALSE

	return TRUE

/datum/ritual/devil/ascendetion/do_ritual(mob/living/carbon/invoker, list/invokers, list/used_things)
	var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)

	if(!devil)
		ritual_object.balloon_alert(invoker, "вы не дьявол!")
		return RITUAL_FAILED_ON_PROCEED

	var/count
	for(var/mob/living/carbon/human/human in used_things)
		if(!human.mind)
			return RITUAL_FAILED_ON_PROCEED
		count += 1
		devil.sacrifice_soul(human.mind)
		SEND_SIGNAL(human.mind, COMSIG_DEVIL_SACRIFICE)
	if(count < required_things[/mob/living/carbon/human])
		return RITUAL_FAILED_ON_PROCEED

	hell_coming(invoker, devil)
	return RITUAL_SUCCESSFUL

/datum/ritual/devil/ascendetion/proc/hell_coming(mob/living/carbon/human/invoker, datum/antagonist/devil/devil, stage = DEVIL_ASCEND_START_STAGE)
	if(QDELETED(invoker))
		return

	switch(stage)
		if(DEVIL_ASCEND_START_STAGE)
			invoker.RemoveSpell(/obj/effect/proc_holder/spell/infernal_jaunt)
			to_chat(invoker, span_warning("Вы чувствуете, будто вот-вот возвыситесь."))
			GLOB.major_announcement.announce("Тёмная сушность, известная как [devil.info.truename], из изменерния, известного как Ад, накапливает силу в [ritual_object.loc]. Сорвите ритуал любой ценой. Действие космического закона и стандартных рабочих процедур приостановлено. Весь экипаж должен уничтожать любые проявления ада на месте.",
											ANNOUNCE_CCPARANORMAL_RU,
											'sound/AI/commandreport.ogg'
			)
			stage = FIRST_DEVIL_ASCEND_STAGE

		if(FIRST_DEVIL_ASCEND_STAGE)
			invoker.visible_message(span_warning("Кожа [invoker.declent_ru(GENITIVE)] начинает покрываться шипами."),
							span_warning("Ваша плоть начинает образовывать вокруг вас щит."))
			stage = SECOND_DEVIL_ASCEND_STAGE

		if(SECOND_DEVIL_ASCEND_STAGE)
			invoker.visible_message(span_warning("Рога на голове [invoker.declent_ru(GENITIVE)] медленно растут и удлиняются."),
							span_warning("Ваше тело продолжает изменяться. Ваши телепатические способности усиливаются."))
			stage = THIRD_DEVIL_ASCEND_STAGE

		if(THIRD_DEVIL_ASCEND_STAGE)
			invoker.visible_message(span_warning("Тело [invoker.declent_ru(GENITIVE)] начинает яростно растягиваться и искажаться."),
							span_warning("Вы начинаете разрывать последние преграды на пути к абсолютной силе."))
			stage = FOURTH_DEVIL_ASCEND_STAGE

		if(FOURTH_DEVIL_ASCEND_STAGE)
			var/message = "<i><b>Да!</b></i>"
			to_chat(invoker, message)
			invoker.say(message)
			stage = FIFTH_DEVIL_ASCEND_STAGE

		if(FIFTH_DEVIL_ASCEND_STAGE)
			var/message = span_big("<i><b>ДА!!</b></i>")
			to_chat(invoker, message)
			invoker.say(message)
			stage = SIXTH_DEVIL_ASCEND_STAGE

		if(SIXTH_DEVIL_ASCEND_STAGE)
			var/message = span_reallybig("<i><b>Д--</b></i>")
			to_chat(invoker, message)
			invoker.say(message)
			send_to_playing_players(span_danger(span_fontsize5("<b>\"ЛЕНЬ, ГНЕВ, ОБЖОРСТВО, УНЫНИЕ, ЗАВИСТЬ, ЖАДНОСТЬ, ГОРДЫНЯ! ОГНИ АДА ПРОСЫПАЮТСЯ!!\"")))
			sound_to_playing_players('sound/hallucinations/veryfar_noise.ogg')
			stage = SEVENTH_DEVIL_ASCEND_STAGE

		if(SEVENTH_DEVIL_ASCEND_STAGE)
			devil.try_update_rank(TRUE)
			GLOB.major_announcement.announce("Зафиксировано критическое истончение завесы между мирами, указывающее на возвышение тёмной сущности, известной как [devil.info.truename]. Проникновение тёмных сущностей различного ранга обнаружено на борту станции [station_name()]. Всему оставшемуся экипажу надлежит немедленно эвакуироваться.",
											ANNOUNCE_CCPARANORMAL_RU,
											'sound/AI/commandreport.ogg'
			)
			var/area/area = get_area(invoker)
			if(area)
				notify_ghosts("Архидьявол вознёсся в [area.name].", source = invoker)
			stage = EIGHTH_DEVIL_ASCEND_STAGE

		if(EIGHTH_DEVIL_ASCEND_STAGE)
			SSweather.run_weather(/datum/weather/hell)
			return

	addtimer(CALLBACK(src, PROC_REF(hell_coming), invoker, devil, stage), timers_list[stage])

/datum/ritual/devil/clown
	name = "Ритуал клоунификации"
	description = "Заставляет офицеров службы безопасности с ЦК показать свою истинную натуру."
	required_things = list(
		/obj/item/stack/sheet/mineral/bananium = 1,
		/obj/item/clothing/head/helmet = 1,
		/obj/item/organ/internal/heart = 1,
		/obj/item/bikehorn = 1,
		/obj/item/clothing/shoes/clown_shoes= 1
	)
	var/static/sound/honk_sound = sound('sound/items/AirHorn.ogg')

/datum/ritual/devil/clown/del_things(list/used_things)
	for(var/obj/obj in used_things) // no type ignore for future.
		if(!isstack(obj))
			qdel(obj)
			continue

		var/obj/item/stack/stack = obj
		stack.use(required_things[stack.type])

	return

/datum/ritual/devil/clown/do_ritual(mob/living/carbon/invoker, list/invokers, list/used_things)
	for(var/datum/mind/possible_target in SSticker.minds)

		if(!(LAZYIN(GLOB.security_positions, possible_target.assigned_role)))
			continue

		if(!possible_target.current || possible_target.current.stat == DEAD)
			continue

		if(!ishuman(possible_target.current ))
			continue

		var/mob/living/carbon/human/human_target = possible_target.current
		human_target.bananatouched()
		playsound(human_target, honk_sound)

	return RITUAL_SUCCESSFUL

/datum/ritual/devil/change
	name = "Ритуал замены"
	description = "Позволяет заменить одну из целей на жертвоприношение ценой души."


/datum/ritual/devil/change/check_contents(mob/living/carbon/invoker, list/used_things)
	var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)

	if(!devil)
		ritual_object.balloon_alert(invoker, "вы не дьявол!")
		return FALSE

	if(!LAZYLEN(devil.soulsOwned))
		ritual_object.balloon_alert(invoker, "у вас нет душ!")
		return FALSE

	return TRUE

/datum/ritual/devil/change/get_ui_things()
	var/list/things = list()
	things["душа"] = 1
	return things

/datum/ritual/devil/change/do_ritual(mob/living/carbon/invoker, list/invokers, list/used_things)
	var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)

	if(!devil)
		ritual_object.balloon_alert(invoker, "вы не дьявол!")
		return RITUAL_FAILED_ON_PROCEED

	var/list/target_list = list()

	for(var/datum/objective/devil/sacrifice/objective in devil.objectives)
		if(objective.completed)
			continue

		target_list[objective.target.name] = objective

	if(!LAZYLEN(target_list))
		ritual_object.balloon_alert(invoker, "нет целей для замены!")
		return RITUAL_FAILED_ON_PROCEED

	var/target = tgui_input_list(invoker, "Какую цель вы хотите заменить?", "Заменить цель", target_list)

	if(!target)
		ritual_object.balloon_alert(invoker, "цель для замены не выбрана!")
		return RITUAL_FAILED_ON_PROCEED

	var/datum/objective/devil/sacrifice/objective = target_list[target]
	objective.find_target()
	devil.remove_soul(safepick(devil.soulsOwned), FALSE)

	return RITUAL_SUCCESSFUL


/datum/ritual/devil/slave
	name = "Ритуал порабощения"
	description = "Воскрешает труп и подчиняет его вашей воле. Уничтожает имплант защиты разума."
	required_things = list(
		/mob/living/carbon/human = 1,
		/obj/item/organ/internal/heart = 1,
		/obj/item/organ/internal/brain = 1,
	)

/datum/ritual/devil/slave/get_ui_things()
	var/list/things = ..()
	things["душа"] = 1
	return things

/datum/ritual/devil/slave/del_things(list/used_things)
	for(var/thing in used_things)
		if(ishuman(thing))
			continue
		qdel(thing)

/datum/ritual/devil/slave/check_contents(mob/living/carbon/invoker, list/used_things)
	. = ..()

	if(!.)
		return FALSE

	var/mob/living/carbon/human/human = locate() in used_things

	var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)

	if(human.stat != DEAD)
		ritual_object.balloon_alert(invoker, "цель не мертва!")
		return FALSE

	if(!human.mind || !(human.mind.hasSoul || LAZYIN(devil.soulsOwned, human.mind)))
		ritual_object.balloon_alert(invoker, "цель без души!")
		return FALSE

	if(ismindslave(human))
		ritual_object.balloon_alert(invoker, "эта цель уже порабощена!")
		return FALSE

	if(!LAZYLEN(devil.soulsOwned))
		ritual_object.balloon_alert(invoker, "у вас нет душ!")
		return FALSE

	return TRUE


/datum/ritual/devil/slave/do_ritual(mob/living/carbon/invoker, list/invokers, list/used_things)
	var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)

	if(!devil)
		ritual_object.balloon_alert(invoker, "вы не дьявол!")
		return RITUAL_FAILED_ON_PROCEED

	var/mob/living/carbon/human/human = locate(/mob/living/carbon/human) in used_things
	ADD_TRAIT(human.mind, TRAIT_BAD_SOUL, DEVIL_RITUAL_TRAIT)
	human.revive()

	for(var/obj/item/implant/mindshield/implant in human.contents)
		if(!implant.implanted)
			continue
		qdel(implant)

	var/datum/antagonist/mindslave/devil_pawn/pawn = new(invoker.mind)
	human.mind.add_antag_datum(pawn)

	devil.remove_soul(safepick(devil.soulsOwned), FALSE)

	return RITUAL_SUCCESSFUL
