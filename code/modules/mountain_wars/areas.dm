// Зоны карты Mountain Wars.
//
// Все области карты должны быть подтипами /area/mountain_wars — на этом держится
// музыка зон: смена трека считается по границе между двумя нашими областями.
//
// Питание зонам не нужно: карта планетарная, APC на ней нет.

// По умолчанию зона — кусок поверхности под открытым небом. Освещать её лампами
// невозможно, светит небо: статический слой света выключен, зона освещена целиком.
// base_lighting_alpha — ручка времени суток: 255 полдень, ~150 сумерки, ~60 ночь.
// Всё, что под землёй, гасит это у себя (см. /tunnels).
/area/mountain_wars
	name = "Mountain Wars"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	// Штатное гудение станции на горном склоне ни к чему.
	ambient_buzz = null
	outdoors = TRUE
	static_lighting = FALSE
	base_lighting_alpha = 255
	sound_environment = SOUND_ENVIRONMENT_PLAIN
	/// Зацикленный трек зоны. Пусто — тишина. Один трек на несколько соседних зон
	/// не рвётся на границе между ними.
	var/music

// Трек гоняем на боссовом канале: у него уже есть ползунок в микшере громкости, и
// зонную музыку на нём же играет погода (weather/hell.dm). Заводить свой канал
// ради этого — плодить ещё одну строчку в настройках.
//
// ponytail: переподключившийся игрок услышит музыку не сразу, а с первого перехода
// между зонами — Login зовёт update_ambience_area(), а не Entered(). Если окажется
// заметно, вешать на /mob/Login().
/area/mountain_wars/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	var/mob/listener = arrived
	if(!ismob(arrived) || !listener.client)
		return
	var/area/mountain_wars/previous = old_area
	if(istype(previous) && previous.music == music)
		return
	listener.stop_sound_channel(CHANNEL_BOSS_MUSIC)
	if(!music)
		return
	var/volume = 40 * listener.client.prefs.get_channel_volume(CHANNEL_BOSS_MUSIC)
	SEND_SOUND(listener, sound(music, repeat = TRUE, channel = CHANNEL_BOSS_MUSIC, volume = volume))

// MARK: Зоны карты
// Разбивка под музыку, под реверб и под отчёты «где убили»: одна область — один кусок
// местности, который игрок опознаёт с земли.
//
// Область на карте одна на тип, а не на закрашенный кусок: загрузчик держит кэш
// loaded_areas и на второй участок того же типа отдаёт тот же объект. Значит два
// хребта с разной музыкой — это два разных типа, а не два пятна одного.
//
// holomap_color — цвет зоны на тактической карте. Подложку (пол, стены) SSholomaps
// рисует сам по типам турфов и умножает на синий HOLOMAP_HOLOFIER, а этот цвет
// кладётся сверху неизменённым. Отсюда альфа 99 в конце: сквозь заливку должна
// читаться геометрия. Своих define не завожу — семь цветов на один модуль, литерал
// рядом с областью честнее, чем константа в общем хедере.

/area/mountain_wars/wasteland
	name = "пустошь"
	holomap_color = "#c9a06a99"

/area/mountain_wars/mountains
	name = "горы"
	sound_environment = SOUND_ENVIRONMENT_MOUNTAINS
	holomap_color = "#8a745c99"

/area/mountain_wars/village
	name = "заброшенный посёлок"
	sound_environment = SOUND_ENVIRONMENT_CITY
	holomap_color = "#b9b9b999"

/area/mountain_wars/crash_site
	name = "место крушения"
	sound_environment = SOUND_ENVIRONMENT_QUARRY
	holomap_color = "#e06f0099"

// Ярус, на котором борта висят в полёте. Раньше он был размечен как /area/space, и
// оттуда лезли звёзды: у космоса base_lighting_color — COLOR_STARLIGHT, а звёздный
// эффект подмешивается оверлеем на плане света, то есть поверх всего, включая ленту
// пустыни. Здесь свет ровный и белый, звёзд нет.
//
// Своей музыки и звука не даём: снаружи борта никто не оказывается, а внутри играет
// область самого вертолёта.
/area/mountain_wars/sky
	name = "воздушный коридор"
	holomap_color = "#8fb8e099"

// Базы красим в цвета фракций: на карте они должны опознаваться первым взглядом,
// без чтения подписей.
/area/mountain_wars/fob_marine
	name = "база морпехов"
	holomap_color = "#3434d499"

/area/mountain_wars/fob_insurgent
	name = "лагерь повстанцев"
	holomap_color = "#ae121299"

// Тыловая база на своём z-уровне: отсюда вертолёты уходят в сектор. Отдельная зона, а
// не /area/space, которым уровень был залит по недосмотру: у космоса нет гравитации,
// и морпехи на построении висели бы в воздухе.
/area/mountain_wars/marine_base
	name = "тыловая база"
	holomap_color = "#3434d499"

// MARK: Под землёй
// Свет с поверхности сюда не достаёт: возвращаем статический слой и убираем базовое
// освещение. Значит в туннелях темно, и без фонаря там делать нечего.
/area/mountain_wars/tunnels
	name = "подземные ходы"
	outdoors = FALSE
	static_lighting = TRUE
	base_lighting_alpha = 0
	ambient_buzz = 'sound/ambience/ruin/ambimine.ogg'
	sound_environment = SOUND_ENVIRONMENT_CAVE
	holomap_color = "#5e5e5e99"
