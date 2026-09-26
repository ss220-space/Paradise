/datum/team/bingles
	name = "Бинглы"
	antag_datum_type = /datum/antagonist/bingle
	need_antag_hud = FALSE
	/// List of all bingle holes ingame. Added and removed privately.
	var/list/bingle_holes = list()
	/// Main bingle objective. Given to all bingles.
	var/datum/objective/bingle/main_objective
	/// Have we made an announcement about bingles if pit got too large?
	var/made_announcement = FALSE
	/// Have we sent nuclear codes if the pit got even larger
	var/sent_nuclear_codes = FALSE
	/// Have we gotten a hole with max size reached?
	var/goal_size_achieved = FALSE
	/// Timerid of gamma code up
	var/gamma_timerid
	/// Timerid of roundend countdown
	var/win_timerid
	/// Assoc list (hole UID -> timerid) of all loop timer ids of holes growing
	var/list/win_grow_timerids = list()

/datum/team/bingles/New(list/starting_members)
	..()
	RegisterSignal(src, COMSIG_BINGLE_HOLE_INITIALIZED, PROC_REF(on_hole_init))
	RegisterSignal(src, COMSIG_MASS_BINGLE_EVOLVE, PROC_REF(on_hole_evolve))
	main_objective = new(team_to_join = src)
	add_objective_to_members(main_objective)

/datum/team/bingles/Destroy(force)
	UnregisterSignal(src, COMSIG_BINGLE_HOLE_INITIALIZED)
	UnregisterSignal(src, COMSIG_MASS_BINGLE_EVOLVE)
	for(var/obj/structure/bingle_hole/hole as anything in bingle_holes)
		UnregisterSignal(hole, COMSIG_QDELETING)
		UnregisterSignal(hole, COMSIG_BINGLE_HOLE_GROW)
	QDEL_NULL(main_objective)
	bingle_holes = null
	return ..()

/datum/team/bingles/declare_completion()
	var/list/text = list()
	if(goal_size_achieved)
		text += span_fontsize3("<br><br><b>Победа \"Бинглов\"!</b>")
		text += "<br><b>Яма Бинглов стала такой большой, что поглотила всю станцию целиком!</b>"
	else
		text += span_fontsize3("<br><br><b>Поражение \"Бинглов\"!</b>")
		text += "<br><b>Бинглы не смогли поглотить станцию целиком, так как экипаж станции сумел их остановить.</b>"
	return text.Join("")

/// Signal proc called on hole initialization
/datum/team/bingles/proc/on_hole_init(datum/source, obj/structure/bingle_hole/hole)
	SIGNAL_HANDLER
	bingle_holes += hole
	RegisterSignal(hole, COMSIG_QDELETING, PROC_REF(on_hole_destroy))
	RegisterSignal(hole, COMSIG_BINGLE_HOLE_GROW, PROC_REF(on_hole_grow))

/**
 * Signal proc called on hole destroy
 *
 * Kills all bingles related to that hole (except for bingle lords),
 * Unregisters some signals
 */
/datum/team/bingles/proc/on_hole_destroy(obj/structure/bingle_hole/source)
	SIGNAL_HANDLER
	bingle_holes -= source
	UnregisterSignal(source, COMSIG_QDELETING)
	UnregisterSignal(source, COMSIG_BINGLE_HOLE_GROW)
	gib_related_bingles(source)
	INVOKE_ASYNC(src, PROC_REF(handle_roundend_destroy), source)
	INVOKE_ASYNC(src, PROC_REF(try_remove_gamma))

/// Proc used to gib all bingles connected to a hole given as an argument
/datum/team/bingles/proc/gib_related_bingles(obj/structure/bingle_hole/hole)
	if(!LAZYACCESS(GLOB.bingles_by_hole, hole.UID()))
		return
	for(var/mob/living/simple_animal/hostile/bingle/bingle as anything in GLOB.bingles_by_hole[hole.UID()])
		bingle?.gib()
	GLOB.bingles_by_hole -= hole.UID()

/// Proc used to stop the roundend timer if there are no more max size holes present
/datum/team/bingles/proc/handle_roundend_destroy(obj/structure/bingle_hole/destroyed_hole)
	if(!goal_size_achieved)
		return

	deltimer(win_grow_timerids[destroyed_hole.UID()])
	// If we find any hole with a size bigger than rounend requirement, then we dont stop the timer.
	for(var/obj/structure/bingle_hole/hole as anything in bingle_holes)
		if(hole.current_pit_size >= BINGLE_PIT_SIZE_GOAL)
			return

	deltimer(win_timerid)
	GLOB.major_announcement.announce(
		message = "Яма критического размера на [station_name()] уничтожена. \
				В случае, если код не будет снижен, то на станции существуют ещё ямы. \
				Рекомендуется вызов шаттла.",
		new_title = ANNOUNCE_CCPARANORMAL_RU,
	)
	goal_size_achieved = FALSE

/// Proc used to lower gamma code if it was caused by any bingle holes
/datum/team/bingles/proc/try_remove_gamma()
	if(!made_announcement)
		return
	// If we find any hole with a size bigger than announce requirement, then we dont lower code.
	for(var/obj/structure/bingle_hole/hole as anything in bingle_holes)
		if(hole.current_pit_size >= ANNOUNCE_BINGLE_PIT_SIZE)
			return
	deltimer(gamma_timerid)
	GLOB.major_announcement.announce(
		message = "Замечено снижение паранормальной активности на [station_name()]. \
				Действие Космического Закона и Стандартных Рабочих Процедур возвращается в норму. \
				Экипажу следует удостовериться в безопасности станции.",
		new_title = ANNOUNCE_CCPARANORMAL_RU,
	)
	SSsecurity_level.set_level(SEC_LEVEL_RED)
	made_announcement = FALSE

/// Signal proc that sends evolve signal to all bingles related to the hole
/datum/team/bingles/proc/on_hole_evolve(datum/source, obj/structure/bingle_hole/hole)
	SIGNAL_HANDLER
	if(!LAZYACCESS(GLOB.bingles_by_hole, hole.UID()))
		return
	for(var/mob/living/simple_animal/hostile/bingle/bingle as anything in GLOB.bingles_by_hole[hole.UID()])
		if(!bingle || bingle.evolved)
			continue
		SEND_SIGNAL(bingle, COMSIG_BINGLE_EVOLVE)

/**
 * Signal proc called on hole grow
 *
 * Does following things:
 * Announce to the station and set gamma code if requirements are met;
 * Send nuclear codes if requirements are met;
 * End the round if requirements are met.
 */
/datum/team/bingles/proc/on_hole_grow(obj/structure/bingle_hole/source, old_size, new_size)
	if(new_size < ANNOUNCE_BINGLE_PIT_SIZE)
		return
	if(!made_announcement)
		made_announcement = TRUE
		INVOKE_ASYNC(src, PROC_REF(make_announcement), source)

	if(new_size < NUCLEAR_CODE_BINGLE_PIT_SIZE)
		return
	if(!sent_nuclear_codes)
		sent_nuclear_codes = TRUE
		INVOKE_ASYNC(src, PROC_REF(send_nuclear_codes))

	if(new_size < BINGLE_PIT_SIZE_GOAL)
		return
	INVOKE_ASYNC(src, PROC_REF(start_growing_hole), source)

	if(goal_size_achieved)
		return
	goal_size_achieved = TRUE
	INVOKE_ASYNC(src, PROC_REF(start_bingle_win), source)

/// Proc to announce to the station about bingles and raise code to gamma
/datum/team/bingles/proc/make_announcement(obj/structure/bingle_hole/hole)
	GLOB.major_announcement.announce(
		message = "Обнаружено массовое нашествие Бинглов на [station_name()]. \
				Действие Космического Закона и Стандартных Рабочих Процедур приостановлено. \
				Всему экипажу надлежит защитить станцию от неминуемого уничтожения.",
		new_title = ANNOUNCE_BIOHAZARD_RU,
		new_sound = 'sound/effects/siren-spooky.ogg',
	)
	gamma_timerid = addtimer(CALLBACK(SSsecurity_level, TYPE_PROC_REF(/datum/controller/subsystem/security_level, set_level), SEC_LEVEL_GAMMA), 5 SECONDS, TIMER_STOPPABLE | TIMER_DELETE_ME)

/// Proc to send nuclear codes to the station
/datum/team/bingles/proc/send_nuclear_codes()
	var/nukecode = GLOB.nuke_codes[/obj/machinery/nuclearbomb]
	var/intercept_name = "Ядерные коды от боеголовки [command_name()]"

	var/list/intercept_text_list = list()
	intercept_text_list += span_fontsize3("<b>Постановление Nanotrasen</b>: Биологическая угроза.<hr>")
	intercept_text_list += "Для [station_name()] была издана директива 7-12.<br>"
	intercept_text_list += "Биологическая угроза вышла из-под контроля и скоро поглотит станцию.<br>"
	intercept_text_list += "Вам приказано следующее:<br>"
	intercept_text_list += " 1. Защищать диск ядерной аутентификации.<br>"
	intercept_text_list += " 2. Взорвать ядерную боеголовку, находящуюся в хранилище станции.<br>"
	intercept_text_list += "Код ядерной аутентификации: [nukecode]<br>"
	intercept_text_list += "Конец сообщения."

	var/intercept_text = intercept_text_list.Join("")
	SSticker?.mode?.special_directive(intercept_text, intercept_name)
	GLOB.major_announcement.announce(
		message = "Угроза вышла из под контроля. Коды от ядерной боеголовки загружены и распечатаны на всех консолях связи. Слава НТ!",
		new_title = ANNOUNCE_CCPARANORMAL_RU,
		new_sound = 'sound/AI/commandreport.ogg'
	)

/**
 * Proc to start bingle win.
 *
 * Starts a timer, after which lays the cinematic,
 * sends an announce and ends the game.
 */
/datum/team/bingles/proc/start_bingle_win(obj/structure/bingle_hole/hole)
	GLOB.major_announcement.announce(
		message = "Яма Бинглов доросла до критических размеров. Уничтожение станции неизбежно. \
			До момента, когда яма поглотит станцию целиком, остаётся [BINGLE_PIT_WIN_DELAY / 10] секунд[declension_ru(BINGLE_PIT_WIN_DELAY, "а", "ы", "")]. \
			Уничтожьте яму любой ценой!",
		new_title = "Отчёт об объекте [station_name()].",
		new_sound = 'sound/AI/commandreport.ogg'
	)
	win_timerid = addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/team/bingles, bingle_win)), BINGLE_PIT_WIN_DELAY, TIMER_STOPPABLE | TIMER_DELETE_ME)

/**
 * Proc called to end the round (and win)
 *
 * Makes all holes indestructible and calls the cinematic.
 */
/datum/team/bingles/proc/bingle_win()
	var/list/win_grow_timerids_cached = win_grow_timerids
	for(var/obj/structure/bingle_hole/hole as anything in bingle_holes)
		hole.resistance_flags |= INDESTRUCTIBLE // We already won, no you can't break the hole while the cinematic plays
		deltimer(win_grow_timerids_cached[hole.UID()]) // Stop the grow timer loop
	/*
	// Pick a hole to grow mid cinematic
	var/obj/structure/bingle_hole/hole_to_grow = get_largest_bingle_pit()
	// Basically grow over the whole sector
	var/datum/callback/grow_callback = CALLBACK(hole_to_grow, TYPE_PROC_REF(/obj/structure/bingle_hole, grow_pit), BINGLE_PIT_AFTER_WIN_SIZE)
	play_cinematic(/datum/cinematic/nuke, world, grow_callback)
	*/
	GLOB.major_announcement.announce(
		message = "Объект потерян. Причина: распространение биологической угрозы Бинглов. Взведение устройства самоуничтожения персоналом или внешними силами в данный момент не представляется возможным из-за высокого уровня заражения. Активация протоколов изоляции.",
		new_title = "Отчёт об объекте [station_name()].",
		new_sound = 'sound/AI/commandreport.ogg'
	)
	SSticker.mode.end_game()

/// Proc used to get the largest bingle pit we have
/datum/team/bingles/proc/get_largest_bingle_pit()
	var/obj/structure/bingle_hole/hole_to_return = /obj/structure/bingle_hole
	for(var/obj/structure/bingle_hole/hole as anything in bingle_holes)
		if(hole.current_pit_size >= hole_to_return.current_pit_size)
			hole_to_return = hole
	return hole_to_return

/// Proc to grow a hole in a loop with a cooldown while win timer is active
/datum/team/bingles/proc/start_growing_hole(obj/structure/bingle_hole/hole_to_grow)
	if(!hole_to_grow)
		return
	win_grow_timerids[hole_to_grow.UID()] = addtimer(CALLBACK(hole_to_grow, TYPE_PROC_REF(/obj/structure/bingle_hole, grow_pit_by_set_amount), 1), BINGLE_PIT_WIN_GROW_COOLDOWN, TIMER_UNIQUE | TIMER_LOOP | TIMER_STOPPABLE | TIMER_DELETE_ME)
