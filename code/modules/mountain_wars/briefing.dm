// Титры высадки: имя бойца, подразделение и задача. Появляются, когда борт коснулся
// земли в секторе, — тот самый момент, ради которого весь перелёт и затевался.
//
// Текст набирается по буквам, как телетайп, потом висит и гаснет. Шрифт пиксельный
// (TinyUnicode, он же под маптекст в билде и лежит) — экранный текст должен читаться
// как строчка в прицеле, а не как системное окно.
//
// Строки печатаются в одном маптексте, а не тремя объектами: так они гарантированно
// стоят друг под другом и гаснут разом.

/// Как часто дописываются буквы.
#define MW_BRIEF_STEP 1
/// Сколько букв за шаг.
#define MW_BRIEF_CHARS 2
/// Сколько дописанный текст висит целиком.
#define MW_BRIEF_HOLD (5 SECONDS)
/// Затухание в конце.
#define MW_BRIEF_FADE (1.5 SECONDS)
/// Одна строка титров.
///
/// line-height с запасом: кегль в пунктах меньше реальной высоты буквы, и на единице
/// строки наезжают друг на друга — тем сильнее, чем крупнее шрифт над ними.
#define MW_BRIEF_LINE(text, size) {"<span style='font-family: \"TinyUnicode\"; font-size: [size]pt; line-height: 1.4; -dm-text-outline: 1px black; color: #ffffff'>[text]</span>"}

/atom/movable/screen/fullscreen/mw_briefing
	// Картинки нет: титры — это только маптекст. Пустая иконка заодно не растит
	// границы контрола карты.
	icon = null
	icon_state = null
	// Левый верхний угол, строкой ниже кнопок способностей. Маптекст растёт вниз от
	// верха своего короба, а короб стоит на клетке низом — поэтому его опускаем на всю
	// высоту минус клетка, иначе текст уехал бы за край экрана.
	screen_loc = "WEST,NORTH-1"
	maptext_width = 384
	maptext_height = 96
	maptext_x = 4
	maptext_y = -64
	needs_offsetting = FALSE
	/// Строки титров сверху вниз.
	var/list/lines
	/// Сколько букв уже напечатано, сквозной счёт по всем строкам.
	var/shown = 0
	/// Сколько их всего. Считается один раз на титры, см. type_out().
	var/chars_total = 0
	var/timer_id

/atom/movable/screen/fullscreen/mw_briefing/Destroy()
	if(timer_id)
		deltimer(timer_id)
	return ..()

/// Кегль строки: имя крупнее, остальное подписью под ним.
/atom/movable/screen/fullscreen/mw_briefing/proc/line_size(index)
	return index == 1 ? 18 : 12

/atom/movable/screen/fullscreen/mw_briefing/proc/type_out(list/text_lines)
	if(timer_id)
		deltimer(timer_id)
	lines = text_lines
	shown = 0
	maptext = ""
	// Длину строк считаем один раз на титры. Дальше они не меняются, а спрашивать её
	// заново на каждом шаге печати — это лишний проход по всем строкам на каждую букву,
	// и так у каждого, кто сошёл с борта.
	chars_total = 0
	for(var/line in lines)
		chars_total += length_char(line)
	tick()

/// Сколько букв во всех строках вместе. По ним и считается прогресс печати.
/atom/movable/screen/fullscreen/mw_briefing/proc/total_chars()
	return chars_total

/atom/movable/screen/fullscreen/mw_briefing/proc/tick()
	shown = min(shown + MW_BRIEF_CHARS, chars_total)
	redraw()
	if(shown >= chars_total)
		timer_id = null
		return
	timer_id = addtimer(CALLBACK(src, PROC_REF(tick)), MW_BRIEF_STEP, TIMER_STOPPABLE)

/atom/movable/screen/fullscreen/mw_briefing/proc/redraw()
	var/list/out = list()
	var/left = shown
	for(var/i in 1 to length(lines))
		if(left <= 0)
			break
		var/line = lines[i]
		var/line_chars = length_char(line)
		// copytext_char, а не copytext: имена и задачи кириллические, а байтовый срез
		// разрубил бы букву пополам и выдал мусор.
		var/visible = copytext_char(line, 1, min(line_chars, left) + 1)
		left -= line_chars
		out += MW_BRIEF_LINE(html_encode(visible), line_size(i))
	maptext = out.Join("<br>")

/**
 * Показывает бойцу титры высадки.
 *
 * Зовётся посадкой борта, см. flight.dm. Вне режима и без команды молчит: подразделение
 * и задачу писать неоткуда, а титры из одного имени ничего не добавляют.
 *
 * task перебивает задачу команды. Нужно упавшим: у сбитого борта своя повестка, и она
 * короче любых планов на сектор.
 */
/proc/mw_briefing(mob/living/soldier, task)
	if(!soldier?.client || !soldier.mind)
		return
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(!istype(mode))
		return
	var/datum/team/mountain_wars/team = mode.teams[mountain_wars_faction(soldier)]
	if(!istype(team))
		return
	var/list/lines = list(
		uppertext(soldier.real_name),
		uppertext(team.unit_line(soldier.mind)),
		uppertext("Задача: [task || team.briefing_task]"),
	)
	var/atom/movable/screen/fullscreen/mw_briefing/titles = soldier.overlay_fullscreen("mw_briefing", /atom/movable/screen/fullscreen/mw_briefing)
	if(!titles)
		return
	titles.type_out(lines)
	// Печать плюс выдержка. Гасит штатный clear_fullscreen — он же и снимает объект.
	var/reveal = CEILING(titles.total_chars() / MW_BRIEF_CHARS, 1) * MW_BRIEF_STEP
	addtimer(CALLBACK(soldier, TYPE_PROC_REF(/mob, clear_fullscreen), "mw_briefing", MW_BRIEF_FADE), reveal + MW_BRIEF_HOLD, TIMER_UNIQUE | TIMER_OVERRIDE)

#undef MW_BRIEF_STEP
#undef MW_BRIEF_CHARS
#undef MW_BRIEF_HOLD
#undef MW_BRIEF_FADE
#undef MW_BRIEF_LINE
