
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 GUARDIAN TERROR -----------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: guarding queen nests
// -------------: AI: dies if too far from queen
// -------------: SPECIAL: chance to stun on hit
// -------------: TO FIGHT IT: shoot it from range, bring friends!
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/guardian
	name = "Guardian of Terror"
	desc = "Зловещего вида фиолетовый паук. Он смотрит по сторонам настороженно, словно чего-то ожидая."
	ai_target_method = TS_DAMAGE_BRUTE
	ru_names = list(
		NOMINATIVE = "Защитник Ужаса",
		GENITIVE = "Защитника Ужаса",
		DATIVE = "Защитнику Ужаса",
		ACCUSATIVE = "Защитника Ужаса",
		INSTRUMENTAL = "Защитником Ужаса",
		PREPOSITIONAL = "Защитнике Ужаса",
	)
	gender = MALE
	icon_state = "terror_purple"
	icon_living = "terror_purple"
	icon_dead = "terror_purple_dead"
	maxHealth = 250
	health = 250
	damage_coeff = list(BRUTE = 0.6, BURN = 1.1, TOX = 1, CLONE = 0, STAMINA = 0, OXY = 0.2)
	melee_damage_lower = 20
	melee_damage_upper = 25
	obj_damage = 70
	attack_sound = 'sound/creatures/terrorspiders/bite2.ogg'
	death_sound = 'sound/creatures/terrorspiders/death6.ogg'
	armour_penetration = 10
	spider_tier = TS_TIER_2
	move_to_delay = 5 // at 20ticks/sec, this is 4 tile/sec movespeed, same as a human. Faster than a normal spider, so it can intercept attacks on queen.
	spider_opens_doors = 2
	ventcrawler_trait = null
	move_resist = MOVE_FORCE_STRONG // no more pushing a several hundred if not thousand pound spider
	ai_ventcrawls = FALSE
	environment_smash = 2
	idle_ventcrawl_chance = 0 // stick to the queen!
	web_type = /obj/structure/spider/terrorweb/purple
	can_wrap = FALSE
	delay_web = 20
	special_abillity = list(/obj/effect/proc_holder/spell/aoe/conjure/build/terror_shield)
	can_wrap = FALSE
	spider_intro_text = "Будучи Защитником Ужаса, ваша задача - охрана гнезда, яиц, Принцесс и Королевы. Вы очень сильны и живучи, используйте это, чтобы защитить выводок. Ваша активная способность создаёт временный неразрушимый барьер, через который могут пройти только пауки. Если встанет выбор, спасти Принцессу, или Королеву, при этои обрекая себя на смерть - делайте это без раздумий!"
	ai_spins_webs = FALSE
	tts_seed = "Avozu"
	var/queen_visible = TRUE
	var/cycles_noqueen = 0
	var/max_queen_range = 15

/mob/living/simple_animal/hostile/poison/terror_spider/guardian/spider_specialattack(mob/living/carbon/human/L)
	. = ..()

	if(!.)
		return FALSE

	L.apply_damage(15, STAMINA)
	if(prob(20))
		visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] врезается в [L.declent_ru(ACCUSATIVE)], сбивая с ног!"))
		L.adjustBruteLoss(20)
		L.Weaken(4 SECONDS)

/mob/living/simple_animal/hostile/poison/terror_spider/guardian/death(gibbed)
	if(can_die() && spider_myqueen)
		if(spider_myqueen.stat != DEAD && !spider_myqueen.ckey)
			if(get_dist(src, spider_myqueen) > max_queen_range)
				if(!degenerate && !spider_myqueen.degenerate)
					degenerate = TRUE
					spider_myqueen.DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/guardian, 1)
					visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] стрекочет в направлении [spider_myqueen.declent_ru(GENITIVE)]!"))
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/guardian/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD) // Can't use if(.) for this due to the fact it can sometimes return FALSE even when mob is alive.
		if(!degenerate && spider_myqueen)
			if(times_fired % 5 == 0)
				purple_distance_check()

/mob/living/simple_animal/hostile/poison/terror_spider/guardian/proc/purple_distance_check()
	if(spider_myqueen)
		var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q = spider_myqueen
		if(Q)
			if(Q.stat == DEAD)
				spider_myqueen = null
				degenerate = TRUE
				to_chat(src, span_userdanger("[capitalize(Q.declent_ru(NOMINATIVE))] умерла! Её сила больше не поддерживает вас!"))
				return

			if(get_dist(src, Q) < vision_range)
				queen_visible = TRUE
			else
				queen_visible = FALSE

			if(queen_visible)
				cycles_noqueen = 0
				if(spider_debug)
					to_chat(src, span_notice("[capitalize(Q.declent_ru(NOMINATIVE))] в зоне видимости."))
			else
				cycles_noqueen++
				if(spider_debug)
					to_chat(src, span_danger("[capitalize(Q.declent_ru(NOMINATIVE))] НЕ в зоне видимости. Цикл: [cycles_noqueen]."))
			var/area/A = get_area(spider_myqueen)
			switch(cycles_noqueen)
				if(6)
					// one minute without queen sighted
					to_chat(src, span_danger("Вы отделились от [Q.declent_ru(GENITIVE)]. Вернитесь к ней в [A.declent_ru(PREPOSITIONAL)]."))
				if(12)
					// two minutes without queen sighted
					to_chat(src, span_danger("Ваша долгая разлука с [Q.declent_ru(INSTRUMENTAL)] ослабляет вас. Вернитесь к ней в [A.declent_ru(PREPOSITIONAL)]."))
				if(18)
					// three minutes without queen sighted, kill them.
					degenerate = TRUE
					to_chat(src, span_userdanger("Ваша связ с [Q] разорвана! Ваша жизненная сила начинает угасать!"))
					melee_damage_lower = 5
					melee_damage_upper = 10

/mob/living/simple_animal/hostile/poison/terror_spider/guardian/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	// Provides a status panel indicator, showing purples how long they can be away from their queen before their hivemind link breaks, and they die.
	// Uses <font color='#X'> because the status panel does NOT accept <span class='X'>.
	if(statpanel("Status") && ckey && stat == CONSCIOUS)
		if(spider_myqueen)
			var/area/A = get_area(spider_myqueen)
			if(degenerate)
				status_tab_data[++status_tab_data.len] = list("Связь:", "<font color='#eb4034'>РАЗРУШЕНА</font>") // color=red
			else if(queen_visible)
				status_tab_data[++status_tab_data.len] = list("Связь:", "<font color='#32a852'>[capitalize(spider_myqueen.declent_ru(NOMINATIVE))] рядом</font>") // color=green
			else if(cycles_noqueen >= 18)
				status_tab_data[++status_tab_data.len] = list("Связь:", "<font color='#eb4034'>Критическая - вернитесь к [spider_myqueen.declent_ru(DATIVE)] в [A.declent_ru(PREPOSITIONAL)]</font>") // color=red
			else
				status_tab_data[++status_tab_data.len] = list("Связь:", "<font color='#fcba03'>Опасная - вернитесь к  [spider_myqueen.declent_ru(DATIVE)] в [A.declent_ru(PREPOSITIONAL)]</font>") // color=orange

/obj/structure/spider/terrorweb/purple
	name = "thick web"
	desc = "Эта паутина настолько толстая, что большинство не может видеть сквозь нее."
	opacity = TRUE
	max_integrity = 40
	ru_names = list(
		NOMINATIVE = "толстая паутина",
		GENITIVE = "толстой паутины",
		DATIVE = "толстой паутине",
		ACCUSATIVE = "толстую паутину",
		INSTRUMENTAL = "толстой паутиной",
		PREPOSITIONAL = "толстой паутине",
	)
