// Синематик победы.
//
// Видео BYOND не проигрывает, и обходить это через окно TGUI не надо: у движка уже есть
// штатный /datum/cinematic, на котором сделаны ядерка и призывы богов. Он гасит OOC,
// вешает всем TRAIT_NO_TRANSFORM, закрывает открытые окна, чернит экран подложкой,
// показывает картинку вернувшемуся после перезахода и сам прибирается по таймеру.
//
// Ролик — многокадровое состояние в .dmi, а не видеофайл. Штатные синематики гоняют его
// через flick(), то есть один раз с остановкой на финальном кадре. Нам нужна петля,
// поэтому состояние просто ставится в icon_state: многокадровое состояние с loop = 0
// движок крутит сам, без таймеров и без повторных вызовов.
//
// Кадры режет scratchpad из ролика: 10 кадров в секунду по 480x270, шестьдесят семь штук
// на 6.7 секунды. Десять, а не двадцать четыре: задержка кадра в .dmi считается в
// десятых долях секунды, и только на десяти она выходит ровно единицей. Палитра сведена
// к 256 цветам — на этой рисовке ошибка 2.1 из 255, глазом не видно, а лист худеет вчетверо.
//
// Кадр 480x270 — ровно в ширину обзора. Шире нельзя: контрол карты при icon-size=0 подбирает
// масштаб под всё содержимое, а не под обзор, и кадр в 512 растил границы, из-за чего
// картинку прижимало к левому краю.

/// Размер кадра синематика.
#define MW_CINEMATIC_WIDE 480
#define MW_CINEMATIC_TALL 270

/// Победа одной из фракций. Подтипы отличаются картинкой и треком.
/datum/cinematic/mw_victory
	/// Лист кадров ролика.
	var/reel
	/// Что играет под ролик. Гоняется в петле, пока синематик не свернут.
	var/anthem
	/// client -> его личный кадр. Окно карты у каждого своё, значит и смещение своё.
	var/list/frames

/datum/cinematic/mw_victory/Destroy()
	for(var/client/viewer as anything in frames)
		var/atom/movable/screen/frame = frames[viewer]
		viewer?.screen -= frame
		qdel(frame)
	frames = null
	return ..()

/datum/cinematic/mw_victory/play_cinematic()
	// Музыка идёт первой и от картинки не зависит: если ролика нет, молчать всё равно хуже.
	play_anthem()
	// Общий кадр датума не используем вовсе. Гасим его: по умолчанию у штатного
	// /atom/movable/screen/cinematic состояние — станция, и она проступала бы под нашим.
	screen.icon = null
	if(!reel)
		return
	for(var/client/viewer as anything in watching)
		show_frame(viewer)

// Кадр у каждого зрителя свой, а не один общий на всех: место кадра считается по размеру
// его окна, а окна у всех разные. Одним объектом на всех этого не сделать.
//
// ponytail: зашедший в середине синематика кадра не получит — show_to() у родителя висит
// на сигнале входа в тело, а из обработчика сигнала нельзя спрашивать окно (см. frame_loc).
// Синематик живёт полминуты, так что случай редкий; понадобится — вешать таймером.
/datum/cinematic/mw_victory/proc/show_frame(client/viewer)
	if(!viewer)
		return
	var/atom/movable/screen/cinematic/frame = new(src)
	frame.icon = reel
	frame.icon_state = "victory"
	frame.screen_loc = frame_loc(viewer)
	viewer.screen += frame
	LAZYSET(frames, viewer, frame)

/// Куда поставить кадр, чтобы он сел по центру окна карты, а не по центру обзора.
///
/// Обзор квадратный, 15 на 15, а окно карты у игрока обычно шире. BYOND вписывает квадрат
/// по меньшей стороне и прижимает к левому нижнему углу — справа остаётся чёрная полоса, и
/// кадр, стоящий ровно посередине обзора, оказывается левее середины окна. Своими силами
/// сервер этого не знает: размер контрола приходится спрашивать у клиента через winget.
/// Оттого и не годится обработчик сигнала — winget ждёт ответа.
///
/// Смещение раскладываем на клетки и остаток: пиксельный сдвиг в screen_loc рассчитан на
/// доводку внутри клетки, а не на сотню пикселей.
/datum/cinematic/mw_victory/proc/frame_loc(client/viewer)
	var/list/view_size = getviewsize(viewer.view)
	var/across = view_size[1] * ICON_SIZE_X
	var/down = view_size[2] * ICON_SIZE_Y
	// Центр обзора — это минимум, который мы обязаны выдержать.
	var/left = round((across - MW_CINEMATIC_WIDE) / 2)
	var/bottom = round((down - MW_CINEMATIC_TALL) / 2)
	var/list/size = splittext(winget(viewer, "mapwindow", "size"), "x")
	if(length(size) == 2)
		var/wide = text2num(size[1])
		var/tall = text2num(size[2])
		if(wide && tall)
			// Масштаб задаёт та сторона, которой тесно. Вторая остаётся с запасом, и вот
			// половину этого запаса кадр и добирает.
			var/scale = min(wide / across, tall / down)
			left += round((wide / scale - across) / 2)
			bottom += round((tall / scale - down) / 2)
	// round() с одним аргументом — это округление вниз, ровно деление нацело.
	return "WEST+[round(left / ICON_SIZE_X)]:[left % ICON_SIZE_X],SOUTH+[round(bottom / ICON_SIZE_Y)]:[bottom % ICON_SIZE_Y]"

// Не через play_cinematic_sound(): тот шлёт один звук на весь мир, а громкость канала у
// каждого своя. Канал — боссовый: на нём же играет зонная музыка карты, так что победный
// трек её собой и вытесняет, второй дорожкой поверх ничего не остаётся.
/datum/cinematic/mw_victory/proc/play_anthem()
	if(!anthem)
		return
	for(var/client/listener as anything in watching)
		var/volume = 60 * listener.prefs.get_channel_volume(CHANNEL_BOSS_MUSIC)
		SEND_SOUND(listener, sound(anthem, repeat = TRUE, channel = CHANNEL_BOSS_MUSIC, volume = volume))

// Трек зациклен и сам не кончится — снимаем вместе с картинкой.
/datum/cinematic/mw_victory/stop_cinematic()
	for(var/client/listener as anything in watching)
		listener.mob?.stop_sound_channel(CHANNEL_BOSS_MUSIC)
	return ..()

/datum/cinematic/mw_victory/insurgent
	reel = 'icons/mountain_wars/cinematic_insurgent.dmi'
	anthem = 'sound/mountain_wars/victory_insurgent.ogg'

// У морпехов не ролик, а одна картинка: состояние в один кадр. Тому же коду всё равно,
// сколько кадров в состоянии, — просто стоять будет неподвижно.
/datum/cinematic/mw_victory/marine
	reel = 'icons/mountain_wars/cinematic_marine.dmi'
	anthem = 'sound/mountain_wars/victory_marine.ogg'

#undef MW_CINEMATIC_WIDE
#undef MW_CINEMATIC_TALL
