// Вертолёт Mountain Wars — не техника, а кусок карты.
//
// Снаружи виден вертолёт с крышей. Зашёл внутрь — крыша для зашедшего гаснет, и под
// ней оказывается второй кадр, тот же вертолёт без крыши, с креслами и аппарелью.
//
// Почему не /obj/vehicle: машина — это один атом с одной клеткой и своим отсеком
// в резервном блоке. Здесь же внутри надо ходить, стрелять из проёма и таскать
// раненых, то есть нужны настоящие клетки на той же карте.
//
// Почему корпус нарезан на клетки, а не лежит одним куском: BYOND рассылает объект
// клиенту по его собственной клетке. У спрайта во весь вертолёт клетка одна, и стоит
// ей уйти за край экрана, как пропадает весь вертолёт разом — а борта остаются, и
// игрок упирается в пустоту. Габариты bound_width/bound_height тут не спасают, они
// про столкновения. У потайловых кусков клетка своя у каждого, и пропадать нечему.
// Куски делает scratchpad/build_heli.py, имена состояний — "s_столбец_строка" для
// крыши и "d_..." для нутра, отсчёт от левого-нижнего угла корпуса.
//
// Лопасти нарезаны так же и по той же причине: кадр у них 15 клеток на 19, держатель
// одним куском вечно оказывался у края обзора, и винт выглядел отрезанным сверху.
//
// Площадку стыковки при этом не расширяем — она остаётся по корпусу, 5x14. Иначе борта в
// строю пришлось бы расставить дальше, чем игрок видит. Расплата в том, что куски лопастей
// торчат на пять клеток в стороны, то есть лежат вне области шаттла, и подсистема их не
// возит: после перелёта переставляем сами, см. place_blades().
//
// Борта — не турфы, а пустые плотные болванки. Турфы обшивки пришлось убрать: своей
// картинкой они торчали из-под скруглённых бортов, а непрозрачность делала весь
// корпус чёрным пятном.
//
// Габариты: корпус 5x14, нос на север, аппарель в корме по центру. Объект ставится за
// левый-нижний угол корпуса. Ходить можно не по всему корпусу: носовые три ряда — это
// кабина пилотов, на картинке там переборка с дверью и обшивка носа. Грузовой отсек —
// 9 рядов на 3, от аппарели до этой переборки.

/// Корпус, в клетках.
#define MW_HELI_HULL_WIDE 5
#define MW_HELI_HULL_TALL 14
/// Последний ряд грузового отсека. Выше — кабина, туда хода нет.
#define MW_HELI_CABIN_ROW 9
/// Откидные лавки вдоль бортов: с какого ряда по какой они нарисованы в кадре нутра.
#define MW_HELI_BENCH_LOW 3
#define MW_HELI_BENCH_HIGH 9
/// Кадр лопастей, в клетках, и насколько левее корпуса он начинается.
#define MW_HELI_BLADES_WIDE 15
#define MW_HELI_BLADES_TALL 19
#define MW_HELI_BLADES_LEFT 5
/// Насколько просвечивает крыша для того, кто внутри.
#define MW_HELI_HIDDEN_ALPHA 40

// MARK: Вертолёт
/obj/structure/mw_helicopter
	name = "вертолёт"
	desc = "Транспортный вертолёт. Аппарель в корме опущена."
	icon = 'icons/mountain_wars/helicopter.dmi'
	icon_state = null
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE
	/// Ставить борта под собой. Выключается, когда они уже расставлены на карте.
	var/build_hull = TRUE
	/// Куски крыши — только их гасим для тех, кто внутри.
	var/list/obj/effect/mw_heli_piece/roof
	/// Все куски картинки разом, включая нутро.
	var/list/obj/effect/mw_heli_piece/pieces
	var/list/obj/structure/mw_heli_wall/walls
	/// Откидные лавки десанта вдоль обоих бортов.
	var/list/obj/structure/chair/mw/heli_bench/benches
	/// Куски лопастей и голова ротора: лежат вне области шаттла, переставляем руками.
	var/list/obj/effect/mw_heli_piece/blade_slabs
	/// Кормовая аппарель: единственный проём в борту. В полёте закрывается.
	var/obj/structure/mw_heli_wall/ramp/ramp
	/// Гул винтов. Заведён на весь раунд, играет только на ходу.
	var/datum/looping_sound/mw_heli_rotor/rotor_sound
	/// Клетки корпуса: вошёл на любую — крыша гаснет.
	///
	/// Список ассоциативный, турф -> TRUE, и это не украшение. Проверка «клетка наша»
	/// стоит на каждом шаге каждого, кто ходит по корпусу: без ключей `in` перебирал бы
	/// семьдесят клеток линейно, а с ключами это одно обращение по хэшу. Перебор самих
	/// клеток от ассоциативности не страдает — for по такому списку идёт по ключам.
	var/list/turf/inside
	/// mob = список подменных картинок, выданных его клиенту.
	var/list/blinded

// Отложенно: куски и борта встают на соседние клетки, а делать это посреди
// инициализации атомов нельзя.
/obj/structure/mw_helicopter/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/mw_helicopter/LateInitialize()
	build_pieces()
	if(build_hull)
		raise_hull()
	place_benches()
	watch_inside()
	rotor_sound = new(src)
	// Борт умеет улетать шаттлом. Подписки висят на конкретных клетках корпуса, а
	// после перелёта клетки другие — иначе крыша перестала бы гаснуть.
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/structure/mw_helicopter/Destroy()
	QDEL_NULL(rotor_sound)
	for(var/mob/watcher as anything in blinded)
		reveal_roof(watcher)
	QDEL_LIST(pieces)
	QDEL_LIST(walls)
	QDEL_LIST(benches)
	roof = null
	inside = null
	return ..()

/// Раскладывает нарезанную картинку по клеткам. Пустые куски скрипт не сохраняет,
/// поэтому спрашиваем у самого файла, что в нём есть.
/obj/structure/mw_helicopter/proc/build_pieces()
	var/static/list/known_states
	if(!known_states)
		known_states = list()
		for(var/state in icon_states(icon))
			known_states[state] = TRUE
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	for(var/col in 0 to MW_HELI_HULL_WIDE - 1)
		for(var/row in 0 to MW_HELI_HULL_TALL - 1)
			var/turf/spot = locate(origin.x + col, origin.y + row, origin.z)
			if(!spot)
				continue
			if(known_states["d_[col]_[row]"])
				LAZYADD(pieces, new /obj/effect/mw_heli_piece(spot, "d_[col]_[row]"))
			if(known_states["s_[col]_[row]"])
				var/obj/effect/mw_heli_piece/slab = new /obj/effect/mw_heli_piece/roof(spot, "s_[col]_[row]")
				LAZYADD(pieces, slab)
				LAZYADD(roof, slab)
	// Лопасти — своя нарезка, свой лист. Кадр шире корпуса и уходит влево, поэтому у
	// столбцов свой отсчёт: нулевой столбец лежит на пять клеток левее корпуса.
	var/static/list/known_blades
	if(!known_blades)
		known_blades = list()
		for(var/state in icon_states('icons/mountain_wars/helicopter_blades_tiles.dmi'))
			known_blades[state] = TRUE
	for(var/col in 0 to MW_HELI_BLADES_WIDE - 1)
		for(var/row in 0 to MW_HELI_BLADES_TALL - 1)
			if(!known_blades["b_[col]_[row]"])
				continue
			var/obj/effect/mw_heli_piece/blades/slab = new(origin, "b_[col]_[row]")
			slab.grid_x = col
			slab.grid_y = row
			LAZYADD(pieces, slab)
			LAZYADD(roof, slab)
			LAZYADD(blade_slabs, slab)
	// Голова ротора живёт в той же сетке, клетка (7,14), и переставляется вместе с ними.
	var/obj/effect/mw_heli_piece/rotor_head/head = new(origin)
	head.grid_x = 7
	head.grid_y = 14
	LAZYADD(pieces, head)
	LAZYADD(roof, head)
	LAZYADD(blade_slabs, head)
	place_blades()

/// Разводит куски лопастей по клеткам от угла корпуса. Отдельно от расстановки, потому
/// что зовётся ещё и после перелёта: куски лежат вне области шаттла, и подсистема их не
/// переносит — без этого винт остался бы на прежней площадке.
/obj/structure/mw_helicopter/proc/place_blades()
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	for(var/obj/effect/mw_heli_piece/slab as anything in blade_slabs)
		var/turf/spot = locate(origin.x + slab.grid_x - MW_HELI_BLADES_LEFT, origin.y + slab.grid_y, origin.z)
		if(spot)
			slab.forceMove(spot)

/// Расставляет борта по кромке корпуса. Аппарель — разрыв кромки в корме по центру.
/// Кабина пилотов заливается плотно: пустой она была проходимой, и пассажир гулял прямо
/// по нарисованной переборке и обшивке носа.
/obj/structure/mw_helicopter/proc/raise_hull()
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	var/ramp_col = round((MW_HELI_HULL_WIDE - 1) / 2)
	for(var/col in 0 to MW_HELI_HULL_WIDE - 1)
		for(var/row in 0 to MW_HELI_HULL_TALL - 1)
			if(col > 0 && col < MW_HELI_HULL_WIDE - 1 && row > 0 && row <= MW_HELI_CABIN_ROW)
				continue
			var/turf/spot = locate(origin.x + col, origin.y + row, origin.z)
			if(!spot)
				continue
			// Аппарель — тот же борт, но проходимый на земле. Раньше на её месте был
			// просто разрыв кромки; в полёте через него выходили в космос транзитного
			// яруса, где темно и нечем дышать.
			if(row == 0 && col == ramp_col)
				ramp = new /obj/structure/mw_heli_wall/ramp(spot)
				LAZYADD(walls, ramp)
				continue
			LAZYADD(walls, new /obj/structure/mw_heli_wall(spot))

/// Ставит откидные лавки вдоль обоих бортов отсека. Сами лавки нарисованы в кадре нутра,
/// объект нужен только чтобы на них садились — потому он и невидимый.
///
/// Лавки лежат внутри корпуса, то есть внутри области шаттла, и перелёт возит их сам.
/obj/structure/mw_helicopter/proc/place_benches()
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	for(var/col in list(1, MW_HELI_HULL_WIDE - 2))
		for(var/row in MW_HELI_BENCH_LOW to MW_HELI_BENCH_HIGH)
			var/turf/spot = locate(origin.x + col, origin.y + row, origin.z)
			if(!spot)
				continue
			var/obj/structure/chair/mw/heli_bench/seat = new(spot)
			// Лицом в проход: сидящий смотрит от своего борта к середине отсека.
			seat.setDir(col == 1 ? EAST : WEST)
			LAZYADD(benches, seat)

/obj/structure/chair/mw/heli_bench
	name = "откидная лавка"
	desc = "Брезент на трубчатой раме вдоль борта. Ремень через плечо, держаться больше не за что."

// Винты гоняем на своём канале и через токен: борт двигается вместе с игроком, и без
// токена звук остался бы висеть в точке, где его завели. Стен не слышит — вертолёт
// снаружи громкий, из отсека его слышно так же.
/datum/looping_sound/mw_heli_rotor
	mid_sounds = list('sound/mountain_wars/heli_rotor.ogg' = 1)
	// Ровно длина клипа: он сведён в петлю, стык не слышен.
	mid_length = 6 SECONDS
	volume = 40
	extra_range = 6
	use_sound_tokens = TRUE
	reserve_random_channel = TRUE

/// Запустить или остановить машину: аппарель, винты, звук. Зовётся областью борта по
/// взлёту и посадке.
/obj/structure/mw_helicopter/proc/set_running(running)
	if(ramp)
		ramp.density = running
		ramp.name = running ? "аппарель вертолёта" : "опущенная аппарель"
	if(running)
		rotor_sound.start()
	else
		rotor_sound.stop()

// MARK: Гашение крыши
// Свой обход вместо /datum/component/seethrough: тот работает с одним атомом, а у
// нас крыша размазана по сотне кусков, и вешать на каждый по компоненту — это сотня
// подписок на каждую клетку корпуса.
/obj/structure/mw_helicopter/proc/watch_inside()
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	inside = list()
	for(var/turf/spot as anything in block(origin.x, origin.y, origin.z, origin.x + MW_HELI_HULL_WIDE - 1, origin.y + MW_HELI_HULL_TALL - 1, origin.z))
		inside[spot] = TRUE
		RegisterSignal(spot, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
		RegisterSignal(spot, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

// Шаттл переставляет своё содержимое по одному объекту, поэтому пересчитываем не
// сразу, а следующим тиком: к тому времени доехали и пассажиры.
/obj/structure/mw_helicopter/proc/on_moved()
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(rewatch_inside)), 0, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/structure/mw_helicopter/proc/rewatch_inside()
	place_blades()
	for(var/turf/spot as anything in inside)
		UnregisterSignal(spot, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	watch_inside()
	// Пассажиры переехали вместе с бортом: выход с клетки им засчитался, вход на
	// новую — нет. Раздаём и отбираем гашение заново по факту, кто где стоит.
	for(var/mob/watcher as anything in blinded?.Copy())
		var/turf/stands = get_turf(watcher)
		if(!stands || !inside[stands])
			reveal_roof(watcher)
	for(var/turf/spot as anything in inside)
		for(var/mob/passenger in spot)
			if(!blinded?[passenger] && passenger.client)
				hide_roof(passenger)

/obj/structure/mw_helicopter/proc/on_entered(turf/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!ismob(arrived))
		return
	var/mob/walker = arrived
	if(blinded?[walker])
		return
	if(!walker.client)
		RegisterSignal(walker, COMSIG_MOB_LOGIN, PROC_REF(on_login), override = TRUE)
		return
	hide_roof(walker)

/obj/structure/mw_helicopter/proc/on_exited(turf/source, atom/movable/gone)
	SIGNAL_HANDLER
	if(!ismob(gone))
		return
	// Шаг с клетки на клетку внутри того же корпуса — не выход.
	var/turf/stands = get_turf(gone)
	if(stands && inside[stands])
		return
	reveal_roof(gone)

/obj/structure/mw_helicopter/proc/on_login(mob/walker)
	SIGNAL_HANDLER
	UnregisterSignal(walker, COMSIG_MOB_LOGIN)
	var/turf/stands = get_turf(walker)
	if(stands && inside[stands])
		hide_roof(walker)

/// Подменяет каждому куску крыши внешность на полупрозрачную — но только для этого
/// клиента. Соседи снаружи по-прежнему видят целую машину.
/obj/structure/mw_helicopter/proc/hide_roof(mob/walker)
	if(!walker?.client)
		return
	var/list/ghosts = list()
	for(var/obj/effect/mw_heli_piece/slab as anything in roof)
		var/image/ghost = image(slab.icon, slab, slab.icon_state, slab.layer)
		ghost.plane = slab.plane
		ghost.override = TRUE
		ghost.alpha = slab.hidden_alpha
		// Подменная внешность строится с нуля и смещения куска не наследует, а у
		// лопастей оно ненулевое — без этого призрак съезжает на пять клеток вправо.
		ghost.pixel_x = slab.pixel_x
		ghost.pixel_y = slab.pixel_y
		ghosts += ghost
	walker.client.images += ghosts
	LAZYSET(blinded, walker, ghosts)
	RegisterSignal(walker, COMSIG_MOB_LOGOUT, PROC_REF(on_logout), override = TRUE)

/obj/structure/mw_helicopter/proc/reveal_roof(mob/walker)
	var/list/ghosts = blinded?[walker]
	if(!ghosts)
		return
	walker.client?.images -= ghosts
	LAZYREMOVE(blinded, walker)
	UnregisterSignal(walker, COMSIG_MOB_LOGOUT)

// Клиент отвалился — картинки ушли вместе с ним, остаётся забыть запись. Вернётся на
// ту же клетку — поймаем по COMSIG_MOB_LOGIN.
/obj/structure/mw_helicopter/proc/on_logout(mob/walker)
	SIGNAL_HANDLER
	LAZYREMOVE(blinded, walker)
	UnregisterSignal(walker, COMSIG_MOB_LOGOUT)
	RegisterSignal(walker, COMSIG_MOB_LOGIN, PROC_REF(on_login), override = TRUE)

/// Борта расставлены в редакторе карт — объект только раскладывает картинку.
/obj/structure/mw_helicopter/mapped
	build_hull = FALSE

// MARK: Кусок картинки
/obj/effect/mw_heli_piece
	name = "вертолёт"
	icon = 'icons/mountain_wars/helicopter.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_NORMAL_TURF_LAYER
	/// До какой прозрачности кусок гаснет для того, кто внутри.
	var/hidden_alpha = MW_HELI_HIDDEN_ALPHA
	/// Место куска в сетке кадра лопастей. По нему борт разводит их после перелёта.
	var/grid_x = 0
	var/grid_y = 0

/obj/effect/mw_heli_piece/Initialize(mapload, state)
	. = ..()
	icon_state = state

/// Крыша: рисуется поверх всех, кто стоит внутри, как крона дерева.
/obj/effect/mw_heli_piece/roof
	layer = FLY_LAYER

/obj/effect/mw_heli_piece/roof/Initialize(mapload, state)
	. = ..()
	SET_PLANE_IMPLICIT(src, ABOVE_GAME_PLANE)

// MARK: Лопасти
// Нарезаны по клеткам так же, как корпус, и по той же причине. Одним куском кадр лопастей
// занимает 15 клеток на 19 и висит на угловой клетке корпуса — а корпус сам 14 клеток в
// длину. Клетка-держатель постоянно оказывалась у края обзора, и кадр обрубался прямой
// кромкой: винт выглядел отрезанным сверху. У потайловых кусков клетка своя у каждого.
//
// Изнутри лопастей не видно совсем: над головой остаётся ротор, нарисованный в мозаике
// крыши. Просвечивающие лопасти в отсеке смотрелись бы разводами по всему потолку.
/obj/effect/mw_heli_piece/blades
	icon = 'icons/mountain_wars/helicopter_blades_tiles.dmi'
	layer = FLY_LAYER
	hidden_alpha = 0

/obj/effect/mw_heli_piece/blades/Initialize(mapload, state)
	. = ..()
	SET_PLANE_IMPLICIT(src, ABOVE_GAME_PLANE)

// Голова ротора — единственное, что остаётся над носом для сидящего внутри. Вырезана из
// кадра лопастей кругом с растворённой кромкой: клетки целиком брать нельзя, сквозь них
// проходят лопасти, и по бокам торчали бы обрубки.
//
// Гаснет изнутри как обычная крыша, до сорока, а не в ноль: над головой у пассажира и так
// всё просвечивает, ротор не должен выбиваться.
//
// Смещение внутри клетки: центр головы лежит в кадре лопастей на (238, 130), клетка (7,14)
// начинается на 224 по x и на 448 снизу, отсюда 238-224 = 14 и 477-448 = 29. Иконка
// ставится углом, поэтому вычитаем её половину.
/obj/effect/mw_heli_piece/rotor_head
	icon = 'icons/mountain_wars/helicopter_rotor_head.dmi'
	icon_state = "head"
	layer = FLY_LAYER
	pixel_x = -18
	pixel_y = -3

/obj/effect/mw_heli_piece/rotor_head/Initialize(mapload, state)
	. = ..()
	SET_PLANE_IMPLICIT(src, ABOVE_GAME_PLANE)

// MARK: Борт
// Пустышка без картинки: всю графику даёт кадр вертолёта, от борта нужна только
// плотность. Непрозрачным его не делаем — иначе корпус превращается в чёрное пятно.
/obj/structure/mw_heli_wall
	name = "борт вертолёта"
	desc = "Дюраль в палец толщиной. Ни выхода, ни обзора."
	icon = null
	anchored = TRUE
	density = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE

/// Проём в корме. На земле сквозь него ходят, в полёте он закрыт.
/obj/structure/mw_heli_wall/ramp
	name = "опущенная аппарель"
	desc = "Кормовая рампа. На земле опущена, на взлёте её поднимают."
	density = FALSE

#undef MW_HELI_BLADES_WIDE
#undef MW_HELI_BLADES_TALL
#undef MW_HELI_BLADES_LEFT
#undef MW_HELI_HULL_WIDE
#undef MW_HELI_HULL_TALL
#undef MW_HELI_CABIN_ROW
#undef MW_HELI_BENCH_LOW
#undef MW_HELI_BENCH_HIGH
#undef MW_HELI_HIDDEN_ALPHA
