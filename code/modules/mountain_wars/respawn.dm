// Возрождение: таймер на экране у госта и оповещение, когда пора возвращаться в бой.
//
// Условий два, и оба должны сойтись. Первое общее: с момента смерти прошло положенное
// время (GLOB.respawn_delay, режим ставит его в post_setup). Второе только у морпехов:
// открыто окно волны и остались билеты. Повстанцы уходят в бой сразу по первому.
//
// Считает и рисует один цикл на весь раунд, а не таймер на каждого госта: гостов к
// середине боя набирается под сотню, и сотня таймеров ради одной строки текста — лишнее.

/// Как часто перерисовываем строку.
#define MW_RESPAWN_TICK (1 SECONDS)
/// Строка таймера.
#define MW_RESPAWN_MAPTEXT(text, color) {"<span style='font-family: \"TinyUnicode\"; font-size: 24pt; line-height: 0.8; text-align: center; -dm-text-outline: 1px black; color: [color]'>[text]</span>"}

/// Гост уже получил «можно возрождаться» и второй раз его дёргать не надо.
/mob/dead/observer/var/mw_respawn_ready = FALSE

/atom/movable/screen/fullscreen/mw_respawn
	icon = null
	icon_state = null
	// Верх экрана: снизу лезут титры высадки и карточки приказов, а строка висит долго.
	screen_loc = "CENTER-7,CENTER+6"
	maptext_width = 480
	maptext_height = 32
	needs_offsetting = FALSE
	// Без этого штатная проверка спрячет экран от мёртвого, а мёртвым он и нужен.
	show_when_dead = TRUE

/datum/game_mode/mountain_wars/proc/start_respawn_hud()
	addtimer(CALLBACK(src, PROC_REF(respawn_hud_tick)), MW_RESPAWN_TICK, TIMER_LOOP)

/datum/game_mode/mountain_wars/proc/respawn_hud_tick()
	// Список возрождаемых переворачиваем в ключи один раз на тик. Иначе `гост in список`
	// — это линейный поиск по нему на каждого госта, то есть под сотню проходов по сотне
	// записей ежесекундно. С ключами обход стоит один, а проверка каждого — обращение
	// по хэшу.
	var/list/can_respawn = list()
	for(var/mob/ready as anything in GLOB.respawnable_list)
		can_respawn[ready] = TRUE
	for(var/mob/player as anything in GLOB.player_list)
		if(!isobserver(player) || !player.client)
			continue
		var/mob/dead/observer/ghost = player
		// Минное поле гостам и админам видно целиком: они не воюют, а смотрят, и
		// прятать от них закопанное незачем. Ловим тут, а не на создании госта: сюда
		// всё равно раз в секунду заходит каждый наблюдатель, включая админского.
		if(!GLOB.mw_mine_watchers[ghost.ckey])
			mw_mine_vision(ghost.ckey, TRUE)
		// Строку показываем только своим: админский призрак и зашедший наблюдателем
		// в бой не собираются, и мигающий таймер им ни к чему.
		if(!faction_by_ckey[ghost.ckey] || !can_respawn[ghost])
			ghost.clear_fullscreen("mw_respawn", FALSE)
			continue
		update_respawn_hud(ghost)

/datum/game_mode/mountain_wars/proc/update_respawn_hud(mob/dead/observer/ghost)
	var/faction = faction_by_ckey[ghost.ckey]
	var/wait = respawn_wait(ghost)
	var/ready = FALSE
	var/text
	var/color = "#c8b98a"
	if(wait > 0)
		text = "ВОЗРОЖДЕНИЕ ЧЕРЕЗ [mw_time_left(wait)]"
	else if(faction != JOB_TITLE_MW_MARINE)
		ready = TRUE
		text = "МОЖНО ВОЗРОДИТЬСЯ — КНОПКА «ПРИСОЕДИНИТЬСЯ»"
	else if(marine_tickets <= 0)
		text = "БИЛЕТЫ ПОДКРЕПЛЕНИЙ ИСЧЕРПАНЫ"
		color = "#c88a8a"
	else if(wave_open)
		ready = TRUE
		text = "ВОЛНА ОТКРЫТА — КНОПКА «ПРИСОЕДИНИТЬСЯ» · БИЛЕТОВ [marine_tickets]"
	else
		text = "ЖДЁМ ВОЛНУ: [mw_time_left(next_wave_time - world.time)] · БИЛЕТОВ [marine_tickets]"
	if(ready)
		color = "#a8e08a"

	var/atom/movable/screen/fullscreen/mw_respawn/line = ghost.overlay_fullscreen("mw_respawn", /atom/movable/screen/fullscreen/mw_respawn)
	if(line)
		line.maptext = MW_RESPAWN_MAPTEXT(text, color)

	// Оповещение шлём один раз на переход. Закрылась волна — взводим обратно, чтобы
	// следующая снова дала сигнал.
	if(ready == ghost.mw_respawn_ready)
		return
	ghost.mw_respawn_ready = ready
	if(!ready)
		return
	to_chat(ghost, span_boldnotice("Вы можете вернуться в бой. Нажмите «Присоединиться» в лобби-меню."))
	SEND_SOUND(ghost, sound('sound/misc/notice2.ogg', volume = 60))

/// Сколько осталось до конца общей выдержки после смерти. Ноль и меньше — вышла.
/datum/game_mode/mountain_wars/proc/respawn_wait(mob/dead/observer/ghost)
	var/died_at = ghost.persistent_client?.time_of_death
	if(isnull(died_at))
		return 0
	return died_at + GLOB.respawn_delay MINUTES - world.time

/// Остаток как М:СС. DisplayTimeText пишет «2 минуты», а на экране нужен счётчик.
/proc/mw_time_left(deciseconds)
	var/seconds = max(round(deciseconds / 10), 0)
	return "[round(seconds / 60)]:[add_zero(num2text(seconds % 60), 2)]"

#undef MW_RESPAWN_TICK
#undef MW_RESPAWN_MAPTEXT
