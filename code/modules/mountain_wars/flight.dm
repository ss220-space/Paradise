// Перелёт: вертолёт — шаттл, в полёте под ним ползёт пустыня.
//
// Своего z-уровня под перелёт не нужно: шаттл уходит на транзитный уровень, который
// подсистема нарезает сама. Пустыня показывается ровно в транзите и снимается при
// стыковке.
//
// Пейзаж — не турфы, а одна лента-картинка на экране игрока.
//
// Лента собрана из трёх пейзажей, уложенных снизу вверх и повторённых дважды
// (scratchpad/build_flight.py). Прокручиваем её вниз ровно на три пейзажа — из-за
// повтора конец цикла совпадает с началом пиксель в пиксель, и animate с loop = -1
// замыкается без рывка. Двух копий, а не одной с хвостом, потому что лента обязана
// перекрывать экран и в конце прокрутки: три пейзажа сдвига плюс высота обзора.
//
// Небо у исходников срезано, кадры лежат внахлёст и растворяются друг в друге —
// иначе на стыке горизонт одного упирался бы в передний план другого. Из-за нахлёста
// шаг кадра меньше высоты обзора, поэтому цикл считается по MW_FLIGHT_CYCLE, а не
// по «три раза по 480».
//
// Показ и снятие висят на области шаттла: /mob/screens и reload_fullscreen уже умеют
// возвращать такие картинки после релога, смерти и пересадки разума, так что своей
// возни с клиентом здесь не нужно.

/// Сдвиг за полный цикл, в пикселях: три пейзажа с учётом нахлёста стыков.
#define MW_FLIGHT_CYCLE 1248
/// Сколько длится проход всех трёх пейзажей.
#define MW_FLIGHT_TIME (45 SECONDS)
/// Высота куска ленты — ровно экран при обзоре 15x15.
#define MW_FLIGHT_SLICE 480
/// На сколько кусков нарезана лента. Четырёх хватает: выше 1248 + 480 не уезжаем.
#define MW_FLIGHT_SLICES 4

/atom/movable/screen/fullscreen/mw_flight
	// Не по центру: картинку тянем от нижнего края обзора вверх, иначе
	// update_for_view начнёт растягивать её под размер экрана.
	screen_loc = "WEST,SOUTH"
	// Выше пола и стен, ниже предметов и людей.
	//
	// Раньше лента лежала на плане параллакса, то есть под всем миром. Оттуда её
	// закрывал любой турф: борт возит с собой свои пятнадцать на пять клеток пола, и в
	// воздухе они прямоугольником торчали поверх пустыни. Прозрачными их не сделать —
	// параллакс проступает только сквозь космические турфы, а под палубой турф обычный,
	// и на месте невидимого пола остаётся чёрный фон контрола карты.
	//
	// Отсюда лента сама накрывает и палубу, и голый космос воздушной стоянки, и стрелки
	// транзита. Предметы, борта и люди — объекты, они планом выше и остаются видны.
	plane = BELOW_GAME_PLANE
	layer = MASSIVE_OBJ_LAYER
	show_when_dead = TRUE

// Пристраивает по бокам копии куска. Иконка шириной ровно в обзор, а контрол карты
// обычно шире квадрата — BYOND добирает свободное место настоящим миром, и справа от
// ленты проглядывал параллакс. Расширять саму иконку нельзя: её ширина идёт в габарит
// карты и мир снова ужмётся.
//
// Копии прямые. Зеркальные шов на стыке прятали, но выдавали себя осью симметрии на
// пол-экрана. Вместо этого сама лента сведена по горизонтали с заворотом — крайний
// левый столбец пикселей совпадает с крайним правым, и прямая копия встаёт без шва.
/atom/movable/screen/fullscreen/mw_flight/proc/flank(state, offset_z = 0)
	for(var/side in list(-1, 1))
		var/mutable_appearance/piece = mutable_appearance(icon, state)
		piece.pixel_w = MW_FLIGHT_SLICE * side
		piece.pixel_z = offset_z
		add_overlay(piece)

// Ползущая земля.
//
// Лента высотой в пять экранов, но собственная иконка объекта — ровно один экран, а
// остальные куски висят оверлеями со сдвигом вверх. Так и надо: в габариты карты идёт
// своя иконка экранного объекта, оверлеи — нет. Одним куском в 480x2560 контрол карты
// при icon-size=0 ужимал масштаб, пока не влезали все 80 клеток по высоте, и мир
// сжимался до окошка в углу. Слои параллакса на этом же плане устроены так же.
/atom/movable/screen/fullscreen/mw_flight/ground
	icon = 'icons/mountain_wars/flight_backdrop.dmi'
	icon_state = "strip0"
	/// Прокрутка уже идёт. Пассажира могут пересчитать не раз, а рвать ленту незачем.
	var/scrolling = FALSE

/atom/movable/screen/fullscreen/mw_flight/ground/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	flank(icon_state)
	for(var/slice in 1 to MW_FLIGHT_SLICES - 1)
		var/mutable_appearance/piece = mutable_appearance(icon, "strip[slice]")
		piece.pixel_z = MW_FLIGHT_SLICE * slice
		add_overlay(piece)
		flank("strip[slice]", MW_FLIGHT_SLICE * slice)

/// Прокрутка идёт сдвигом в transform, а не пиксельными смещениями. Ни pixel_y, ни
/// pixel_z ленту не двинули, зато transform — единственное, чем гоняет себя параллакс на
/// этом же плане (update_parallax_motionblur), то есть заведомо рабочий путь.
///
/// Заводим снаружи, а не в Initialize(): overlay_fullscreen сразу после создания пишет
/// объекту icon_state, а запись во внешность обрывает начатую анимацию.
/atom/movable/screen/fullscreen/mw_flight/ground/proc/start_scroll()
	if(scrolling)
		return
	scrolling = TRUE
	animate(src, transform = matrix(1, 0, 0, 0, 1, -MW_FLIGHT_CYCLE), time = MW_FLIGHT_TIME, loop = -1)

// Крутящаяся земля: борт сбит, машину несёт, пейзаж уходит из-под винта каруселью.
//
// Отдельный экранный объект с одним куском картинки, а не поворот ползущей ленты.
// Оверлеи BYOND крутит каждый вокруг своего центра, а пиксельные смещения кладёт уже
// после поворота — то есть кусок вращается, оставаясь на прежнем месте. Лента из
// двенадцати кусков от этого разваливалась на карусель квадратов, между ними зияли дыры,
// и сквозь них был виден космос яруса. Пара pixel_x/pixel_y ведёт себя так же, менять
// смещения бесполезно. Здесь кусок ровно один, и разваливаться нечему.
//
// Кусок ровно в обзор, 480x480, и это потолок: в габарит контрола карты идёт размер
// самой картинки, причём не только своей, но и любого оверлея. Кадр 1280x1280 оверлеем
// ужимал мир втрое ровно так же, как когда-то лента одним куском в 480x2560. Смещения
// pixel_w/pixel_z в габарит при этом не идут — потому нарезка на равные куски и работает.
//
// Круг, вписанный в 480x480, радиусом 240, а половина диагонали обзора — 339: повёрнутый
// кадр не накрывал бы углы. Поэтому растягиваем его вдвое через transform. Растяжение
// живёт в матрице и размера картинки не меняет, значит габарит не трогает. Заодно рывок
// приближения на попадании работает на впечатление.
//
// Под каруселью оставлена обычная ползущая лента: если у кого-то окно шире рассчитанного,
// в углу окажется пустыня, а не звёзды.
#define MW_FLIGHT_SPIN_ZOOM 2
/// Полный оборот. Двенадцать шагов на него: между двумя ключами BYOND тянет матрицу по
/// прямой, и на крупных секторах картинка съезжала бы к центру по хорде.
#define MW_FLIGHT_SPIN_TIME (4 SECONDS)
#define MW_FLIGHT_SPIN_STEPS 12

/atom/movable/screen/fullscreen/mw_flight/spin
	icon = 'icons/mountain_wars/flight_backdrop.dmi'
	icon_state = "strip0"
	// Поверх ленты и неба: обе лежат под каруселью.
	layer = MASSIVE_OBJ_LAYER + 0.2
	/// Карусель уже пущена.
	var/spinning = FALSE

/// Заводим снаружи, а не в Initialize(): overlay_fullscreen сразу после создания пишет
/// объекту icon_state, а запись во внешность обрывает начатую анимацию.
/atom/movable/screen/fullscreen/mw_flight/spin/proc/start_spin()
	if(spinning)
		return
	spinning = TRUE
	transform = matrix(MW_FLIGHT_SPIN_ZOOM, 0, 0, 0, MW_FLIGHT_SPIN_ZOOM, 0)
	SpinAnimation(MW_FLIGHT_SPIN_TIME, loops = -1, segments = MW_FLIGHT_SPIN_STEPS, parallel = FALSE)

// MARK: Область борта
// Своя область обязательна: шаттл возит ровно свою область, и по ней же subsystem
// понимает, что именно двигать. Подтипом /area/mountain_wars её сделать нельзя —
// зонная музыка внутри борта заводится отдельно, если понадобится.
/area/shuttle/mw_heli
	name = "Вертолёт"
	icon_state = "shuttle"
	// Направление прокрутки штатного параллакса. Пустыню крутим своей лентой, но
	// пусть совпадают, если параллакс где-то всё же проглянет.
	parallax_movedir = NORTH
	static_lighting = FALSE
	base_lighting_alpha = 255
	/// Борт в транзите. По этому же флагу картинку получает тот, кто вошёл уже в полёте.
	var/flying = FALSE
	/// Борт сбит и падает вращаясь. Держим флагом на области, а не разово на экране:
	/// пересчёт пассажиров идёт и при релоге, и при смерти, и после стыковки.
	var/spinning = FALSE

// Бортов три, и область у каждого своя. Одну и ту же нарисовать в трёх местах нельзя:
// область — одна на тип, и шаттл потащил бы все три вертолёта разом.
/area/shuttle/mw_heli/one
	name = "Вертолёт «Альфа»"

/area/shuttle/mw_heli/two
	name = "Вертолёт «Браво»"

/area/shuttle/mw_heli/three
	name = "Вертолёт «Чарли»"

// Взлёт и посадка разом: пассажирам — пустыню на экран, борту — аппарель. Открытый
// проём в полёте выпускал наружу, а снаружи транзитный ярус: голый космос, темно и
// нечем дышать.
// Пересчёт безусловный, даже если состояние не менялось. Причаливание переставляет
// пассажиров на новые клетки, по дороге срабатывает Exited и снимает картинку. С выходом
// по «состояние то же» борт приходил с транзита на воздушную стоянку — та тоже полёт —
// и никто пустыню не возвращал: вокруг оказывался голый космос яруса.
/area/shuttle/mw_heli/proc/set_flying(new_flying)
	flying = new_flying
	for(var/turf/spot as anything in src)
		for(var/atom/movable/thing in spot)
			if(ismob(thing))
				update_passenger(thing)
				continue
			if(istype(thing, /obj/structure/mw_helicopter))
				var/obj/structure/mw_helicopter/heli = thing
				heli.set_running(new_flying)

/area/shuttle/mw_heli/proc/update_passenger(mob/passenger)
	if(flying)
		var/atom/movable/screen/fullscreen/mw_flight/ground/land = passenger.overlay_fullscreen("mw_flight_ground", /atom/movable/screen/fullscreen/mw_flight/ground)
		land?.start_scroll()
		if(spinning)
			// Лента остаётся под каруселью подстраховкой на широкое окно.
			var/atom/movable/screen/fullscreen/mw_flight/spin/whirl = passenger.overlay_fullscreen("mw_flight_spin", /atom/movable/screen/fullscreen/mw_flight/spin)
			whirl?.start_spin()
		return
	passenger.clear_fullscreen("mw_flight_ground")
	passenger.clear_fullscreen("mw_flight_spin")

/// Пустить карусель всем, кто на борту.
/area/shuttle/mw_heli/proc/set_spinning()
	spinning = TRUE
	for(var/turf/spot as anything in src)
		for(var/mob/passenger in spot)
			update_passenger(passenger)

/area/shuttle/mw_heli/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	if(flying && ismob(arrived))
		update_passenger(arrived)

/area/shuttle/mw_heli/Exited(atom/movable/gone, direction)
	. = ..()
	var/mob/passenger = gone
	if(ismob(passenger))
		passenger.clear_fullscreen("mw_flight_ground")
		passenger.clear_fullscreen("mw_flight_spin")

// MARK: Борт как шаттл
// Габарит — корпус, 5x14 клеток. Лопасти в него не входят: они висят одним куском на
// угловой клетке корпуса и едут вместе с ней. Будь площадка по кадру, она стала бы
// 15 клеток в ширину, а площадки перекрывать нельзя — и соседний борт в строю оказался
// бы дальше семи клеток, то есть за пределами видимости.
/obj/docking_port/mobile/mw_heli
	id = "mw_heli"
	name = "вертолёт"
	width = 5
	height = 14
	callTime = 1 MINUTES
	// Юг, хотя летим на север. Направление это идёт только в три места: сторона
	// транзитного причала, стрелки транзитных турфов и сторона прокрутки параллакса.
	// Последние два закрыты лентой пустыни, а первое здесь и важно.
	//
	// Транзитный причал разворачивают на dir2angle(preferred) + dir2angle(port) + 180.
	// С двумя NORTH выходил юг, причал смотрел встречно борту, и dock() крутил шаттл на
	// 180 градусов. Обычный шаттл поворот переживает, а вертолёт — мозаика из семидесяти
	// кусков, у каждого своя картинка на своей клетке: клетки при повороте меняются
	// местами, картинки остаются, и корпус рассыпается. На посадке крутило обратно,
	// поэтому на земле борт был целым, а в полёте — месивом.
	//
	// С югом сумма даёт 360, то есть север. Причал совпадает с бортом, поворота нет.
	preferred_direction = SOUTH
	rechargeTime = 30 SECONDS
	/// Этому борту не долететь. Ставится при вылете в сектор, если жребий выпал ему.
	var/doomed = FALSE

/obj/docking_port/mobile/mw_heli/one
	id = "mw_heli_1"
	name = "вертолёт «Альфа»"

/obj/docking_port/mobile/mw_heli/two
	id = "mw_heli_2"
	name = "вертолёт «Браво»"

/obj/docking_port/mobile/mw_heli/three
	id = "mw_heli_3"
	name = "вертолёт «Чарли»"

// Жребий тянем один раз за раунд и только когда первый борт пошёл на посадку в
// сектор: до этого момента никто, включая админов, не знает, в какой вертолёт
// садиться опаснее.
GLOBAL_VAR(mw_doomed_heli)

/proc/mw_doomed_heli()
	if(!GLOB.mw_doomed_heli)
		GLOB.mw_doomed_heli = pick("mw_heli_1", "mw_heli_2", "mw_heli_3")
	return GLOB.mw_doomed_heli

// Сбитие — это подмена пункта назначения, а не физика. Пилот жмёт «в сектор», борт
// уходит на площадку у краш-сайта, а по дороге трясёт и воет.
/obj/docking_port/mobile/mw_heli/request(obj/docking_port/stationary/S)
	if(!doomed && istype(S, /obj/docking_port/stationary/mw_heli/lz) && id == mw_doomed_heli())
		var/obj/docking_port/stationary/wreck = SSshuttle.getDock("mw_heli_crash")
		if(wreck)
			S = wreck
			doomed = TRUE
			INVOKE_ASYNC(src, PROC_REF(going_down))
	return ..(S)

/// Переговоры борта с землёй. Слышно только тем, кто в этом вертолёте: остальным по
/// сюжету докладывают уже постфактум.
/obj/docking_port/mobile/mw_heli/proc/radio_line(who, what)
	for(var/mob/passenger as anything in passengers())
		to_chat(passenger, span_deptradio("[who]: <b>[what]</b>"))

/// Дорога вниз: сирена, тряска и карусель, пока борт «падает».
/obj/docking_port/mobile/mw_heli/proc/going_down()
	for(var/area/shuttle/mw_heli/deck as anything in shuttle_areas)
		deck.set_spinning()
	for(var/mob/passenger as anything in passengers())
		to_chat(passenger, span_userdanger("Удар в хвостовую балку! Машину заваливает!"))
		passenger.playsound_local(passenger, 'sound/machines/alarm.ogg', 60, FALSE)
	radio_line("Пилот вертолёта", "Диспетчер! Мы падаем, падаем!")
	sleep(2 SECONDS)
	radio_line("Диспетчер", "Понял, вычёркиваю.")
	for(var/i in 1 to 6)
		for(var/mob/passenger as anything in passengers())
			shake_camera(passenger, 1.5 SECONDS, 2)
		sleep(2 SECONDS)

/// Приземление в обломки: всех валит с ног и мнёт, но не убивает.
/obj/docking_port/mobile/mw_heli/proc/crash_landing()
	for(var/mob/living/passenger in passengers())
		shake_camera(passenger, 3 SECONDS, 5)
		passenger.playsound_local(passenger, 'sound/effects/explosionfar.ogg', 80, TRUE)
		to_chat(passenger, span_userdanger("Борт бьётся о землю."))
		passenger.Weaken(6 SECONDS)
		passenger.adjustBruteLoss(rand(15, 30))
	var/turf/epicenter = get_turf(src)
	if(epicenter)
		var/datum/effect_system/fluid_spread/smoke/bad/black/smoke = new
		smoke.set_up(4, holder = src, location = epicenter)
		smoke.start()
	// Машины больше нет. Удаляем сам борт — за ним уходят вся мозаика корпуса, лопасти,
	// стенки, лавки и гул винтов. На земле остаётся площадка палубы: выжившие стоят на
	// ней, а сверху над ними уже открытое небо.
	//
	// ponytail: обломков не остаётся, спрайта под них нет. Появится — ставить здесь.
	for(var/area/shuttle/mw_heli/deck as anything in shuttle_areas)
		deck.spinning = FALSE
		for(var/turf/spot as anything in deck)
			for(var/obj/structure/mw_helicopter/heli in spot)
				qdel(heli)

/obj/docking_port/mobile/mw_heli/proc/passengers()
	. = list()
	for(var/area/shuttle/mw_heli/deck as anything in shuttle_areas)
		for(var/turf/spot as anything in deck)
			for(var/mob/passenger in spot)
				. += passenger

/obj/docking_port/mobile/mw_heli/dock(obj/docking_port/stationary/new_dock, force = FALSE, transit = FALSE)
	. = ..()
	if(istype(new_dock, /obj/docking_port/stationary/mw_heli/crash))
		INVOKE_ASYNC(src, PROC_REF(crash_landing))
		mw_clear_rockfall(/obj/structure/mw_rockfall/crash)
		// Упавшим — своя задача. Сектор подождёт, сначала бы уйти живыми с обломков.
		show_briefing("выжить")
	// Фаза подготовки кончается прилётом: до посадки первого борта зона высадки
	// закрыта завалом, чтобы повстанцы не встречали десант прямо на площадке.
	if(istype(new_dock, /obj/docking_port/stationary/mw_heli/lz))
		mw_clear_rockfall(/obj/structure/mw_rockfall/lz)
		show_briefing()

	// Пустыня идёт и в служебном транзите, и на стоянке в секторе перелёта.
	var/flying = istype(new_dock, /obj/docking_port/stationary/transit)
	if(istype(new_dock, /obj/docking_port/stationary/mw_heli))
		var/obj/docking_port/stationary/mw_heli/pad = new_dock
		flying = pad.airborne
	for(var/area/shuttle/mw_heli/deck as anything in shuttle_areas)
		deck.set_flying(flying)

/// Титры высадки всем, кто на борту. Земля под ногами — момент как раз для них.
/obj/docking_port/mobile/mw_heli/proc/show_briefing(task)
	for(var/mob/living/passenger in passengers())
		mw_briefing(passenger, task)

// Причалы. Габариты обязаны совпадать с бортом, иначе стыковка не сойдётся; и dir у
// всех до единого обязан быть NORTH, как у борта. Разошлись — dock() развернёт шаттл, а
// поворот рассыпает мозаику корпуса по клеткам, см. preferred_direction выше.
/obj/docking_port/stationary/mw_heli
	name = "площадка вертолёта"
	width = 5
	height = 14
	// Чем причал заливает клетки, когда борт с него улетел. Должно совпадать с тем,
	// что нарисовано вокруг площадки, иначе на месте стоянки останется чужая земля.
	turf_type = /turf/simulated/floor/indestructible/asteroid
	area_type = /area/mountain_wars/wasteland
	/// Стоянка в воздухе: пока борт здесь, пассажирам показывают пустыню.
	var/airborne = FALSE

// Площадки нумерованные, а не с идентификатором на var-редактировании: на карте их
// станет одиннадцать, и одна опечатка в id молча оставит борт без причала.
/obj/docking_port/stationary/mw_heli/base
	name = "стоянка на базе"

/obj/docking_port/stationary/mw_heli/base/one
	id = "mw_heli_base_1"

/obj/docking_port/stationary/mw_heli/base/two
	id = "mw_heli_base_2"

/obj/docking_port/stationary/mw_heli/base/three
	id = "mw_heli_base_3"

/obj/docking_port/stationary/mw_heli/lz
	name = "площадка в секторе"

/obj/docking_port/stationary/mw_heli/lz/one
	id = "mw_heli_lz_1"

/obj/docking_port/stationary/mw_heli/lz/two
	id = "mw_heli_lz_2"

/obj/docking_port/stationary/mw_heli/lz/three
	id = "mw_heli_lz_3"

// Сектор перелёта: отдельный z-уровень, на котором борта висят бок о бок и видят друг
// друга. Служебный транзит подсистемы для этого не годится — он у каждого шаттла свой.
/obj/docking_port/stationary/mw_heli/sky
	name = "воздушный коридор"
	airborne = TRUE
	turf_type = /turf/space
	area_type = /area/mountain_wars/sky

/obj/docking_port/stationary/mw_heli/sky/one
	id = "mw_heli_sky_1"

/obj/docking_port/stationary/mw_heli/sky/two
	id = "mw_heli_sky_2"

/obj/docking_port/stationary/mw_heli/sky/three
	id = "mw_heli_sky_3"

/// Куда падает сбитый. В списке пультов его нет — борт попадает сюда только жребием.
/obj/docking_port/stationary/mw_heli/crash
	id = "mw_heli_crash"
	name = "место падения"
	area_type = /area/mountain_wars/crash_site

// Пункты назначения общие у всех троих: садиться можно на любую свободную площадку,
// занятую подсистема просто не даст выбрать. Места падения в списке нет.
#define MW_HELI_DESTINATIONS "mw_heli_base_1;mw_heli_base_2;mw_heli_base_3;mw_heli_sky_1;mw_heli_sky_2;mw_heli_sky_3;mw_heli_lz_1;mw_heli_lz_2;mw_heli_lz_3"

/obj/machinery/computer/shuttle/mw_heli
	name = "пульт вертолёта"
	desc = "Отправляет борт на воздушный коридор, площадку в секторе и обратно на базу."
	possible_destinations = MW_HELI_DESTINATIONS
	req_access = list()
	resistance_flags = INDESTRUCTIBLE
	obj_flags = NODECONSTRUCT

/obj/machinery/computer/shuttle/mw_heli/one
	name = "пульт вертолёта «Альфа»"
	shuttleId = "mw_heli_1"

/obj/machinery/computer/shuttle/mw_heli/two
	name = "пульт вертолёта «Браво»"
	shuttleId = "mw_heli_2"

/obj/machinery/computer/shuttle/mw_heli/three
	name = "пульт вертолёта «Чарли»"
	shuttleId = "mw_heli_3"

#undef MW_HELI_DESTINATIONS

#undef MW_FLIGHT_CYCLE
#undef MW_FLIGHT_TIME
#undef MW_FLIGHT_SLICE
#undef MW_FLIGHT_SLICES
#undef MW_FLIGHT_SPIN_ZOOM
#undef MW_FLIGHT_SPIN_TIME
#undef MW_FLIGHT_SPIN_STEPS
