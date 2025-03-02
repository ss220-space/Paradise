GLOBAL_LIST_EMPTY(ts_ckey_blacklist)
GLOBAL_VAR_INIT(ts_count_dead, 0)
GLOBAL_VAR_INIT(ts_count_alive_awaymission, 0)
GLOBAL_VAR_INIT(ts_count_alive_station, 0)
GLOBAL_VAR_INIT(ts_death_last, 0)
GLOBAL_VAR_INIT(ts_death_window, 9000) // 15 minutes
GLOBAL_LIST_EMPTY(ts_spiderlist)
GLOBAL_LIST_EMPTY(ts_egg_list)
GLOBAL_LIST_EMPTY(ts_spiderling_list)

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: DEFAULTS ---------------------------------
// --------------------------------------------------------------------------------
// Because: http://tvtropes.org/pmwiki/pmwiki.php/Main/SpidersAreScary

/mob/living/simple_animal/hostile/poison/terror_spider
	//COSMETIC
	name = "Паучок"
	desc = "Стандартный паук. Если ты это видишь, это баг."
	gender = FEMALE
	icon = 'icons/mob/terrorspider.dmi'
	icon_state = "terror_red"
	icon_living = "terror_red"
	icon_dead = "terror_red_dead"
	attacktext = "кусает"
	attack_sound = 'sound/creatures/terrorspiders/bite.ogg'
	deathmessage = "кричит от боли и медленно перестаёт двигаться."
	death_sound = 'sound/creatures/terrorspiders/death.ogg'
	damaged_sound = list('sound/creatures/spider_attack1.ogg', 'sound/creatures/spider_attack2.ogg')
	var/spider_intro_text = "Если ты это видишь, это баг."
	speak_chance = 0 // quiet but deadly
	speak_emote = list("hisses")
	emote_hear = list("hisses")
	tts_seed = "Anubarak"
	sentience_type = SENTIENCE_OTHER
	response_help  = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	friendly = "осторожно проводит лапками по"
	footstep_type = FOOTSTEP_MOB_CLAW
	talk_sound = list('sound/creatures/terrorspiders/speech_1.ogg', 'sound/creatures/terrorspiders/speech_2.ogg', 'sound/creatures/terrorspiders/speech_3.ogg', 'sound/creatures/terrorspiders/speech_4.ogg', 'sound/creatures/terrorspiders/speech_5.ogg', 'sound/creatures/terrorspiders/speech_6.ogg')
	damaged_sound = list('sound/creatures/terrorspiders/speech_1.ogg', 'sound/creatures/terrorspiders/speech_2.ogg', 'sound/creatures/terrorspiders/speech_3.ogg', 'sound/creatures/terrorspiders/speech_4.ogg', 'sound/creatures/terrorspiders/speech_5.ogg', 'sound/creatures/terrorspiders/speech_6.ogg')

	//HEALTH
	maxHealth = 120
	health = 120
	a_intent = INTENT_HARM
	var/regeneration = 2 //pure regen on life
	var/degenerate = FALSE // if TRUE, they slowly degen until they all die off.
	//also regenerates by using /datum/status_effect/terror/food_regen when wraps a carbon, wich grants full health witin ~25 seconds
	damage_coeff = list(BRUTE = 0.75, BURN = 1.25, TOX = 1, CLONE = 0, STAMINA = 0, OXY = 0.2)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	//ATTACK
	melee_damage_lower = 15
	melee_damage_upper = 20
	AI_delay_max = 0 SECONDS

	//MOVEMENT
	pass_flags = PASSTABLE
	turns_per_move = 3 // number of turns before AI-controlled spiders wander around. No effect on actual player or AI movement speed!
	move_to_delay = 6
	speed = 0
	// AI spider speed at chasing down targets. Higher numbers mean slower speed. Divide 20 (server tick rate / second) by this to get tiles/sec.

	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS

	//SPECIAL
	var/list/special_abillity = list()  //has spider unique abillities?
	var/can_wrap = TRUE   //can spider wrap corpses and objects?
	var/web_type = /obj/structure/spider/terrorweb
	var/delay_web = 25 // delay between starting to spin web, and finishing
	faction = list("terrorspiders")
	var/spider_opens_doors = 1 // all spiders can open firedoors (they have no security). 1 = can open depowered doors. 2 = can open powered doors
	var/ai_ventcrawls = TRUE
	var/idle_ventcrawl_chance = 15
	var/freq_ventcrawl_combat = 1800 // 3 minutes
	var/freq_ventcrawl_idle =  9000 // 15 minutes
	var/last_ventcrawl_time = -9000 // Last time the spider crawled. Used to prevent excessive crawling. Setting to freq*-1 ensures they can crawl once on spawn.
	var/ai_ventbreaker = 0
	// AI movement tracking
	var/spider_steps_taken = 0 // leave at 0, its a counter for ai steps taken.
	var/spider_max_steps = 15 // after we take X turns trying to do something, give up!

	// Vision
	vision_range = 10
	aggro_vision_range = 10
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS

	// HUD
	hud_type = /datum/hud/simple_animal/spider

	// AI aggression settings
	var/ai_target_method = TS_DAMAGE_SIMPLE

	// AI player control by ghosts
	var/ai_playercontrol_allowtype = 1 // if 0, this specific class of spider is not player-controllable. Default set in code for each class, cannot be changed.

	var/ai_break_lights = TRUE // AI lightbreaking behavior
	var/freq_break_light = 600
	var/last_break_light = 0 // leave this, changed by procs.

	var/ai_spins_webs = TRUE // AI web-spinning behavior
	var/freq_spins_webs = 600
	var/last_spins_webs = 0 // leave this, changed by procs.

	var/freq_cocoon_object = 1200 // two minutes between each attempt
	var/last_cocoon_object = 0 // leave this, changed by procs.

	var/spider_awaymission = 0 // if 1, limits certain behavior in away missions
	var/spider_uo71 = 0 // if 1, spider is in the UO71 away mission
	var/spider_unlock_id_tag = "" // if defined, unlock awaymission blast doors with this tag on death
	var/spider_placed = 0

	// AI variables designed for use in procs
	var/atom/movable/cocoon_target // for queen and nurse
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent // nearby vent they are going to try to get to, and enter
	var/obj/machinery/atmospherics/unary/vent_pump/exit_vent // remote vent they intend to come out of
	var/obj/machinery/atmospherics/unary/vent_pump/nest_vent // home vent, usually used by queens
	var/fed = 0
	var/travelling_in_vent = 0
	var/path_to_vent = 0
	var/killcount = 0
	var/busy = 0 // leave this alone!
	var/spider_tier = TS_TIER_1 // 1 for red,gray,green. 2 for purple,black,white, 3 for prince, mother. 4 for queen
	var/hasdied = 0
	var/list/spider_special_drops = list()
	var/attackstep = 0
	var/attackcycles = 0
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/spider_myqueen = null
	var/mob/living/simple_animal/hostile/poison/terror_spider/spider_mymother = null
	var/mylocation = null
	var/chasecycles = 0
	var/web_infects = 0
	var/spider_creation_time = 0

	var/datum/action/innate/terrorspider/web/web_action
	var/datum/action/innate/terrorspider/wrap/wrap_action

	// DATUM
	var/datum_type = /datum/antagonist/terror_spider

	// DEBUG OPTIONS & COMMANDS
	var/spider_growinstantly = FALSE
	var/spider_debug = FALSE


/mob/living/simple_animal/hostile/poison/terror_spider/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NEGATES_GRAVITY, INNATE_TRAIT)

/mob/living/simple_animal/hostile/poison/terror_spider/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		heat_damage = 6.5, \
	)

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: SHARED ATTACK CODE -----------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	// Forces terrors to use the 'bite' graphic when attacking something. Same as code/modules/mob/living/carbon/alien/larva/larva_defense.dm#L34
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/AttackingTarget()
	if(isterrorspider(target))
		if(target in enemies)
			enemies -= target
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = target
		if(T.spider_tier > spider_tier)
			visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] съёживается перед [target.declent_ru(INSTRUMENTAL)]."))
		else if(T.spider_tier == spider_tier)
			visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] тычется носом в [target.declent_ru(ACCUSATIVE)]."))
		else if(T.spider_tier < spider_tier && spider_tier >= 4)
			target.attack_animal(src)
		else
			visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] безобидно тычет носом [target.declent_ru(ACCUSATIVE)]."))
		T.CheckFaction()
		CheckFaction()
	else if(istype(target, /obj/structure/spider/royaljelly))
		consume_jelly(target)
	else if(istype(target, /obj/structure/spider)) // Prevents destroying coccoons (exploit), eggs (horrible misclick), etc
		to_chat(src, "Уничтожение вещей, созданных другими пауками, нам не поможет.")
	else if(istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = target
		if(F.density)
			if(F.welded)
				to_chat(src, "[capitalize(F.declent_ru(NOMINATIVE))] заварен.")
			else
				visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] открывает [F.declent_ru(ACCUSATIVE)]!"))
				F.open()
		else
			to_chat(src, "Закрытие противопожарных дверей не помогает.")
	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		try_open_airlock(A)
	else if(isliving(target) && (!client || a_intent == INTENT_HARM))
		var/mob/living/G = target
		if(issilicon(G))
			G.attack_animal(src)
			return
		else if(G.reagents && (iscarbon(G)))
			var/can_poison = 1
			if(ishuman(G))
				var/mob/living/carbon/human/H = G
				if(!(H.dna.species.reagent_tag & PROCESS_ORG) || (!H.dna.species.tox_mod))
					can_poison = 0
			spider_specialattack(G,can_poison)
		else
			G.attack_animal(src)
	else
		target.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/spider_specialattack(mob/living/carbon/human/L, poisonable)
	return L.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/proc/consume_jelly(obj/structure/spider/royaljelly/J)
	if(health == maxHealth)
		to_chat(src, span_warning("Вам не нужно лечиться!"))
		return
	to_chat(src, span_notice("Вы употребляете королевское желе, чтобы исцелить себя!"))
	playsound(src.loc, 'sound/creatures/terrorspiders/jelly.ogg', 100, 1)
	apply_status_effect(STATUS_EFFECT_TERROR_REGEN)
	qdel(J)

// --------------------------------------------------------------------------------
// --------------------- TERROR SPIDERS: PROC OVERRIDES ---------------------------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		if(key)
			. += span_warning("Внимательно осматривает окружение взглядом, говорящем о признаках разумности.")
		if(health > (maxHealth*0.95))
			. += span_notice("Не имеет видимых повреждений.")
		else if(health > (maxHealth*0.75))
			. += span_notice("Имеет несколько царапин.")
		else if(health > (maxHealth*0.55))
			. += span_warning("Имеет серьёзные травмы.")
		else if(health > (maxHealth*0.25))
			. += span_danger("Едва стоит на своих лапах!")
		if(degenerate || !spider_awaymission && GLOB.global_degenerate)
			. += span_danger("Находится на грани жизни и смерти.")
		if(killcount >= 1)
			. += span_warning("Разбрызгивает во все стороны алую кровь, струяющуюся из пасти.")

/mob/living/simple_animal/hostile/poison/terror_spider/New()
	..()
	GLOB.ts_spiderlist += src
	add_language(LANGUAGE_HIVE_TERRORSPIDER)
	for(var/spell in special_abillity)
		src.AddSpell(new spell)

	if(spider_tier >= TS_TIER_2)
		add_language(LANGUAGE_GALACTIC_COMMON)
	default_language = GLOB.all_languages[LANGUAGE_HIVE_TERRORSPIDER]

	if(web_type)
		web_action = new()
		web_action.Grant(src)
	if(can_wrap)
		wrap_action = new()
		wrap_action.Grant(src)
	name += " ([rand(1, 1000)])"
	real_name = name
	msg_terrorspiders("[capitalize(declent_ru(NOMINATIVE))] вырастает в локации \"[get_area(src)]\".")
	if(is_away_level(z))
		spider_awaymission = 1
		GLOB.ts_count_alive_awaymission++
		if(spider_tier >= 3)
			ai_ventcrawls = FALSE // means that pre-spawned bosses on away maps won't ventcrawl. Necessary to keep prince/mother in one place.
		if(istype(get_area(src), /area/awaymission/UO71)) // if we are playing the away mission with our special spiders...
			spider_uo71 = 1
			if(world.time < 600)
				// these are static spiders, specifically for the UO71 away mission, make them stay in place
				ai_ventcrawls = FALSE
				spider_placed = 1
	else
		GLOB.ts_count_alive_station++
	// after 3 seconds, assuming nobody took control of it yet, offer it to ghosts.
	addtimer(CALLBACK(src, PROC_REF(CheckFaction)), 20)
	addtimer(CALLBACK(src, PROC_REF(announcetoghosts)), 30)
	var/datum/atom_hud/U = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	U.add_hud_to(src)
	spider_creation_time = world.time

/mob/living/simple_animal/hostile/poison/terror_spider/proc/announcetoghosts()
	if(spider_awaymission)
		return
	if(stat == DEAD)
		return
	if(ckey)
		notify_ghosts("[capitalize(declent_ru(NOMINATIVE))] (контролируется игроком) появляется в локации \"[get_area(src)]\".")
	else if(ai_playercontrol_allowtype)
		var/image/alert_overlay = image(icon, icon_state)
		notify_ghosts("[capitalize(declent_ru(NOMINATIVE))] появляется в локации \"[get_area(src)]\".", enter_link = "<a href=?src=[UID()];activate=1>(Нажмите для взятия контроля)</a>", source = src, alert_overlay = alert_overlay, action = NOTIFY_ATTACK)

/mob/living/simple_animal/hostile/poison/terror_spider/Destroy()
	GLOB.ts_spiderlist -= src
	handle_dying()
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD) // Can't use if(.) for this due to the fact it can sometimes return FALSE even when mob is alive.
		if(prob(10))
			// 10% chance every cycle to decompose
			visible_message(span_notice("Труп [declent_ru(GENITIVE)] разлагается!"))
			gib()
	else
		if(health < maxHealth)
			adjustBruteLoss(-regeneration)
		if(degenerate || !spider_awaymission && GLOB.global_degenerate)
			adjustBruteLoss(6)
		if(prob(5))
			CheckFaction()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/handle_dying()
	if(!hasdied)
		hasdied = 1
		GLOB.ts_count_dead++
		GLOB.ts_death_last = world.time
		if(spider_awaymission)
			GLOB.ts_count_alive_awaymission--
		else
			GLOB.ts_count_alive_station--

/mob/living/simple_animal/hostile/poison/terror_spider/death(gibbed)
	if(can_die())
		if(!gibbed)
			msg_terrorspiders("[capitalize(declent_ru(NOMINATIVE))] умирает в локации \"[get_area(src)]\".")
		handle_dying()
		if(mind)
			SEND_SIGNAL(mind, COMSIG_TERROR_SPIDER_DIED)
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/spider_special_action()
	return

/mob/living/simple_animal/hostile/poison/terror_spider/ObjBump(obj/object)
	if(istype(object, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = object
		if(airlock.density) // must check density here, to avoid rapid bumping of an airlock that is in the process of opening, instantly forcing it closed
			return try_open_airlock(airlock)
	if(istype(object, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/firedoor = object
		if(firedoor.density && !firedoor.welded)
			firedoor.open()
			return TRUE
	. = ..()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/msg_terrorspiders(msgtext)
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = thing
		if(T.stat != DEAD)
			to_chat(T, "<span class='terrorspider'>TerrorSense: [msgtext]</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/proc/CheckFaction()
	if(faction.len != 2 || (!("terrorspiders" in faction)) || master_commander != null)
		to_chat(src, span_userdanger("Ваша связь с коллективным разумом разрывается!"))
		log_runtime(EXCEPTION("Terror spider with incorrect faction list at: [atom_loc_line(src)]"))
		gib()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/try_open_airlock(obj/machinery/door/airlock/D)
	if(D.operating)
		return
	if(D.welded)
		to_chat(src, span_warning("Дверь заварена."))
	else if(D.locked)
		to_chat(src, span_warning("Дверь заболтирована."))
	else if(D.allowed(src))
		if(D.density)
			D.open(TRUE)
		else
			D.close(TRUE)
		return TRUE
	else if(D.arePowerSystemsOn() && (spider_opens_doors != 2))
		to_chat(src, span_warning("Привод шлюза сопротивляется вашим попыткам взломать её."))
	else if(!spider_opens_doors)
		to_chat(src, span_warning("Вы недостаточно сильны, чтобы взломать шлюз."))
	else
		visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] открывает дверь силой!"))
		playsound(src.loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(D.density)
			D.open(TRUE)
		else
			D.close(TRUE)
		return TRUE


/mob/living/simple_animal/hostile/poison/terror_spider/get_spacemove_backup(moving_direction, continuous_move)
	. = ..()
	// If we don't find any normal thing to use, attempt to use any nearby spider structure instead.
	if(!.)
		for(var/obj/structure/spider/spider_thing in range(1, get_turf(src)))
			return spider_thing


/mob/living/simple_animal/hostile/poison/terror_spider/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	if(ckey && stat == CONSCIOUS)
		if(degenerate || !spider_awaymission && GLOB.global_degenerate)
			status_tab_data[++status_tab_data.len] = list("Связь:", "<font color='#eb4034'>Связь с Коллективным разумом разорвана! Смерть..</font>") // color=red

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoRemoteView()
	if(!isturf(loc))
		// This check prevents spiders using this ability while inside an atmos pipe, which will mess up their vision
		to_chat(src, span_warning("Для этого вам необходимо стоять на полу."))
		return
	if(client && (client.eye != client.mob))
		reset_perspective()
		return
	if(health <= (maxHealth*0.75))
		to_chat(src, span_warning("Для этого вы должны быть полностью здоровы!"))
		return
	var/list/targets = list()
	targets += src // ensures that self is always at top of the list
	for(var/thing in GLOB.ts_spiderlist)
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = thing
		if(T.stat == DEAD)
			continue
		if(T.spider_awaymission != spider_awaymission)
			continue
		targets |= T // we use |= instead of += to avoid adding src to the list twice
	var/mob/living/L = tgui_input_list(usr, "Выберите Паука Ужаса для просмотра.", "Выбор", targets)
	if(istype(L))
		reset_perspective(L)


/mob/living/simple_animal/hostile/poison/terror_spider/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/item/projectile/terrorspider))
		return TRUE


/mob/living/simple_animal/hostile/poison/terror_spider/experience_pressure_difference(pressure_difference, direction)
	if(!HAS_TRAIT(src, TRAIT_NEGATES_GRAVITY))
		return ..()

/obj/item/projectile/terrorspider
	name = "basic"
	damage = 0
	icon_state = "toxin"
	damage_type = TOX
