// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T5 EMPRESS OF TERROR -------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ruling over planets of uncountable spiders, like Xenomorph Empresses.
// -------------: AI: none - this is strictly adminspawn-only and intended for RP events, coder testing, and teaching people 'how to queen'
// -------------: SPECIAL: Lay Eggs ability that allows laying queen-level eggs.
// -------------: TO FIGHT IT: run away screaming?
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress
	name = "Empress of Terror"
	desc = "Нечестивое порождение пауков, кошмаров и фантастики Лавкрафта."
	ru_names = list(
		NOMINATIVE = "Императрица Ужаса",
		GENITIVE = "Императрицы Ужаса",
		DATIVE = "Императрице Ужаса",
		ACCUSATIVE = "Императрицу Ужаса",
		INSTRUMENTAL = "Императрицой Ужаса",
		PREPOSITIONAL = "Императрице Ужаса",
	)
	ai_target_method = TS_DAMAGE_SIMPLE
	maxHealth = 1000
	health = 1000
	melee_damage_lower = 30
	melee_damage_upper = 60
	idle_ventcrawl_chance = 0
	ai_playercontrol_allowtype = 0
	canlay = 1000
	spider_tier = TS_TIER_5
	projectiletype = /obj/projectile/terrorspider/empress
	icon = 'icons/mob/terrorspider64.dmi'
	pixel_x = -16
	move_resist = MOVE_FORCE_STRONG // no more pushing a several hundred if not thousand pound spider
	mob_size = MOB_SIZE_LARGE
	icon_state = "terror_empress"
	icon_living = "terror_empress"
	icon_dead = "terror_empress_dead"
	datum_type = /datum/antagonist/terror_spider/main_spider/empress
	var/datum/action/innate/terrorspider/queen/empress/empresslings/empresslings_action
	var/datum/action/innate/terrorspider/queen/empress/empresserase/empresserase_action
	tts_seed = "Queen"
	spider_intro_text = "Вы - Императрица Ужаса, вершина иерархии гнезда и одно из самых опасных существ этого мира. Управляйте, разрушайте, захватывайте. Теперь это ВАША станция."

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/New()
	..()
	grant_actions()

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/proc/grant_actions()
	empresslings_action = new()
	empresslings_action.Grant(src)
	empresserase_action = new()
	empresserase_action.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/spider_special_action()
	return
/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/getSpiderLevel()
	return 50
/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/NestMode()
	..()
	queeneggs_action.button.name = "Empress Eggs"

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/LayQueenEggs()
	var/eggtype = tgui_input_list(usr, "Какой тип яиц?", "Тип яиц", list(TS_DESC_QUEEN, TS_DESC_MOTHER, TS_DESC_PRINCE, TS_DESC_PRINCESS, TS_DESC_KNIGHT, TS_DESC_LURKER, TS_DESC_HEALER, TS_DESC_WIDOW, TS_DESC_GUARDIAN, TS_DESC_DEFILER, TS_DESC_DESTROYER))
	var/numlings = tgui_input_number(usr, "Сколько в кладке?", "Количество яиц", 0, min(canlay, 50), 0)
	if(!eggtype || !numlings)
		to_chat(src, span_danger("Отменено."))
		return
	switch(eggtype)
		if(TS_DESC_KNIGHT)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/knight, numlings)
			canlay -= numlings
		if(TS_DESC_LURKER)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/lurker, numlings)
			canlay -= numlings
		if(TS_DESC_HEALER)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/healer, numlings)
			canlay -= numlings
		if(TS_DESC_WIDOW)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/widow, numlings)
			canlay -= numlings
		if(TS_DESC_GUARDIAN)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/guardian, numlings)
			canlay -= numlings
		if(TS_DESC_DEFILER)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/defiler, numlings)
			canlay -= numlings
		if(TS_DESC_DESTROYER)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/destroyer, numlings)
			canlay -= numlings
		if(TS_DESC_PRINCE)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/prince, numlings)
			canlay -= numlings
		if(TS_DESC_PRINCESS)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess, numlings)
			canlay -= numlings
		if(TS_DESC_MOTHER)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/mother, numlings)
			canlay -= numlings
		if(TS_DESC_QUEEN)
			DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/queen, numlings)
		else
			to_chat(src, span_danger("Неизвестный тип яйца."))

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/proc/EmpressLings()
	var/numlings = tgui_input_number(usr, "Сколько?", "", 10, 50, 10)
	var/sbpc = tgui_input_number(usr, "Шанс быть мертворождённым?", "", 0, 100, 0)
	if(!numlings || isnull(sbpc))
		return
	for(var/i=0, i<numlings, i++)
		var/obj/structure/spider/spiderling/terror_spiderling/S = new /obj/structure/spider/spiderling/terror_spiderling(get_turf(src))
		S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/knight, \
		/mob/living/simple_animal/hostile/poison/terror_spider/lurker, \
		/mob/living/simple_animal/hostile/poison/terror_spider/healer, \
		/mob/living/simple_animal/hostile/poison/terror_spider/defiler, \
		/mob/living/simple_animal/hostile/poison/terror_spider/widow)
		S.spider_myqueen = spider_myqueen
		S.spider_mymother = src
		if(prob(sbpc))
			S.stillborn = TRUE
		if(spider_growinstantly)
			S.amount_grown = 250

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/proc/EraseBrood()
	var/agreement = tgui_alert(usr, "Вы уверены? Это заставит умирать всех пауков ужаса.", "Искоренение рода", list("Да", "Нет") )
	if(agreement != "Да")
		return
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = thing
		if(T.spider_tier < spider_tier)
			T.degenerate = TRUE
			to_chat(T, span_userdanger("Через коллективный разум грубая сила [declent_ru(GENITIVE)] вливается в ваше тело, сжигая его изнутри!"))
	var/datum/team/terror_spiders/spider_team = GLOB.antagonist_teams[/datum/team/terror_spiders]
	spider_team?.erase_eggs()
	to_chat(src, span_userdanger("Все пауки ужаса, кроме вас, вскоре вымрут."))


/obj/projectile/terrorspider/empress
	name = "empress venom"
	icon_state = "toxin5"
	damage = 90
	damage_type = BRUTE

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/weak
	canlay = 10
	spider_spawnfrequency = 1000
	ai_playercontrol_allowtype = TRUE

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/weak/getSpiderLevel()
	return 7

/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/weak/grant_actions()
	empresserase_action = new()
	empresserase_action.Grant(src)
