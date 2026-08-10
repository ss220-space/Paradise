// Тактическая карта Mountain Wars — окно в углу экрана, кнопкой включается и гасится.
//
// Своего генератора карты тут нет и не будет: подложку рисует SSholomaps, он и так
// обходит все уровни с трейтом STATION_LEVEL, а у нашей карты их два. Мы берём готовую
// картинку уровня, вырезаем из неё кусок вокруг бойца и вешаем на скрин-объект.
// Логика выреза, курсора «вы здесь» и маркеров живёт в /datum/station_holomap.

/// На сколько тайлов боец должен отойти от центра выреза, чтобы карту перерисовали.
#define MW_MINIMAP_DRIFT 12
/// Экранное место минимапы. Своё, а не ui_mini_holomap: у того сдвиг на 8 пикселей под
/// окно импланта в 80, и наши 96 вылезали за край экрана.
#define ui_mw_minimap "EAST-2:0,NORTH-2:0"
/// Экранное место развёрнутой карты. 255 пикселей — восемь тайлов, отсюда сдвиг на 4.
#define ui_mw_tacmap "CENTER-4,CENTER-4"
/// Сторона метки в пикселях. Готовые спрайты из misc/8x8 при масштабе «пиксель = тайл»
/// накрывают по восемь тайлов каждый и сливаются в кашу поверх местности.
#define MW_BLIP_SIZE 3
/// Цвет меток лазов. Своих красим цветом фракции, лазы — отдельным ярким.
#define MW_BLIP_HATCH "#ff9d00"
#define MW_MINIMAP_REFRESH (1 SECONDS)
/// Цвет линий командира. Жёлтый читается и на тёмной подложке, и на цветных зонах.
#define MW_TACMAP_INK "#ffe066"
/// Как часто рисунок командира доезжает до остальной фракции. Он перерисовывает
/// подложку у каждого зрителя, а это копия и обрезка холста 480x480 — на полсотне
/// человек такое нельзя делать на каждое движение мыши командира.
#define MW_TACMAP_PUSH (5 SECONDS)
/// А себе командир перерисовывает часто — он один, и рисовать вслепую невозможно.
#define MW_TACMAP_SELF_PUSH (2 DECISECONDS)
/// Предел длины одного отрезка в пикселях. Курсор, прыгнувший через полкарты (окно
/// потеряло фокус, игрок дёрнул мышь за край), не должен чертить линию через весь холст.
#define MW_TACMAP_MAX_STEP 32
/// Пауза, после которой следующая точка начинает новый штрих, а не продолжает старый.
#define MW_TACMAP_BREAK (1.5 SECONDS)

// MARK: Холст фракции
// Рисунок хранится не списком штрихов, а сразу картинкой в координатах холста 480x480 —
// тех же, в которых лежит подложка. Значит его не надо ни пересчитывать под чужой вырез,
// ни сериализовать: обрезал по вырезу зрителя и наложил.
GLOBAL_LIST_EMPTY(mw_tacmap_canvas)
/// Номер правки на фракцию. Зритель сравнивает со своим и перерисовывает окно.
GLOBAL_LIST_EMPTY(mw_tacmap_version)
/// world.time, до которого правки копятся молча.
GLOBAL_LIST_EMPTY(mw_tacmap_next_push)

/// Чертит отрезок на холсте фракции. Координаты — пиксели холста, не тайлы карты.
/proc/mw_tacmap_draw(faction, x1, y1, x2, y2)
	if(!faction)
		return
	var/icon/canvas = GLOB.mw_tacmap_canvas[faction]
	if(!canvas)
		canvas = icon(HOLOMAP_ICON, "blank")
		GLOB.mw_tacmap_canvas[faction] = canvas
	var/steps = max(abs(x2 - x1), abs(y2 - y1))
	if(steps > MW_TACMAP_MAX_STEP)
		return
	// DrawBox рисует прямоугольники, линии в BYOND нет — идём по длинной оси и ставим
	// точки 2x2. Без интерполяции получился бы пунктир: MouseDrag срабатывает реже,
	// чем движется курсор.
	for(var/i in 0 to steps)
		var/px = steps ? round(x1 + (x2 - x1) * i / steps) : x1
		var/py = steps ? round(y1 + (y2 - y1) * i / steps) : y1
		canvas.DrawBox(MW_TACMAP_INK, px, py, px + 1, py + 1)
	if(GLOB.mw_tacmap_next_push[faction] > world.time)
		return
	GLOB.mw_tacmap_next_push[faction] = world.time + MW_TACMAP_PUSH
	// Отложенный толчок, а не немедленный: пока командир ведёт линию, зрителям незачем
	// перерисовываться, а последний штрих всё равно доедет по этому таймеру.
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(mw_tacmap_push), faction), MW_TACMAP_PUSH)

/proc/mw_tacmap_push(faction)
	GLOB.mw_tacmap_version[faction] += 1

/// Где боец находится с точки зрения карты.
///
/// Обычно это просто его клетка, но экипаж бронемашины стоит в десантном отсеке, а
/// отсек живёт в резервном блоке — на z-уровне, которого на карте боя нет вовсе.
/// Оттуда минимапа не могла ни вырезать подложку, ни поставить метку, и у сидящих
/// внутри окно оставалось пустым. Считаем такого бойца стоящим на корпусе машины.
///
/// Проверка уровня стоит первой не для красоты: она отсекает всех, кто на карте, за
/// одно сравнение, и список техники перебирается только для тех, кто уехал в отсек.
/proc/mw_map_turf(atom/thing)
	var/turf/where = get_turf(thing)
	if(!where || !is_reserved_level(where.z))
		return where
	for(var/obj/vehicle/mw/vehicle as anything in GLOB.mw_vehicles)
		if(vehicle.is_occupant(thing))
			return get_turf(vehicle)
	return where

/// Квадратик нужного цвета под метку. Кэшируется: цветов всего три, а генерятся они
/// обрезкой холста 480x480 — делать это на каждую метку каждую секунду нельзя.
/proc/mw_blip_icon(color)
	var/static/list/cache = list()
	var/icon/dot = cache[color]
	if(dot)
		return dot
	dot = icon(HOLOMAP_ICON, "blank")
	dot.Crop(1, 1, MW_BLIP_SIZE, MW_BLIP_SIZE)
	dot.DrawBox(color, 1, 1, MW_BLIP_SIZE, MW_BLIP_SIZE)
	cache[color] = dot
	return dot

/proc/mw_tacmap_wipe(faction)
	GLOB.mw_tacmap_canvas -= faction
	mw_tacmap_push(faction)

// MARK: Окно
/atom/movable/screen/mw_minimap
	name = "тактическая карта"
	icon = null
	screen_loc = ui_mw_minimap
	// Мышь ловим только у командиров — остальным незачем перехватывать треть экрана.
	// Ставится в Activate(), и именно OPAQUE: незакрашенные куски карты прозрачны,
	// а по прозрачному пикселю MOUSE_OPACITY_ICON событий не даёт — рисовать можно было
	// бы только по закрашенному.
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/datum/action/innate/mw_minimap/host

/atom/movable/screen/mw_minimap/Destroy()
	host = null
	return ..()

// MouseDown/MouseUp тут не годятся: /client/MouseDown и /client/MouseUp в drag_drop.dm
// не зовут ..(), поэтому до атома событие не доходит вовсе. Работают только Click
// (через обычный роутинг кликов) и клиентские сигналы, которые те же процы шлют сами.
/atom/movable/screen/mw_minimap/Click(location, control, params)
	if(LAZYACCESS(params2list(params), RIGHT_CLICK))
		host?.wipe()
		return
	host?.stroke_to(params)

/datum/action/innate/mw_minimap
	name = "Тактическая карта"
	desc = "Показать карту сектора в углу экрана."
	button_icon_state = "scan_mode"
	check_flags = AB_CHECK_CONSCIOUS
	/// Сторона окна в пикселях, она же в тайлах карты. 96 — ровно три тайла экрана
	/// под слот ui_mini_holomap.
	var/crop_size = 96
	/// Экранное место окна.
	var/window_loc = ui_mini_holomap
	/// Окно едет за бойцом. Ложь — вырез стоит на центре карты и не двигается.
	var/follow = TRUE
	/// Вырез подложки, курсор и маркеры.
	var/datum/station_holomap/holomap
	/// Скрин-объект, на котором всё это видно.
	var/atom/movable/screen/mw_minimap/window
	/// Турф, вокруг которого вырезан текущий кусок подложки.
	var/turf/anchor
	var/timer_id
	/// Командир отряда: может рисовать. Ставится при выдаче кнопки, см. teams.dm.
	var/can_draw = FALSE
	/// Режим рисования включён. Пока выключен, окно мышь не трогает вовсе.
	var/drawing = FALSE
	/// Номер правки рисунка, который уже видно в окне.
	var/drawn_version = 0
	/// Конец предыдущего отрезка в координатах холста. Ноль — штрих начинается заново.
	var/last_x = 0
	var/last_y = 0
	/// world.time последней точки. По паузе штрих считается оборванным.
	var/last_point_time = 0
	/// Когда командиру можно перерисовать своё окно.
	var/next_self_push = 0
	/// Картинки меток. Переиспользуются от тика к тику, см. blip_at().
	var/list/image/blip_pool = list()
	/// Сколько картинок из пула разобрано в текущем проходе.
	var/blips_used = 0

/datum/action/innate/mw_minimap/Destroy()
	Deactivate()
	QDEL_NULL(window)
	holomap = null
	anchor = null
	blip_pool = null
	return ..()

/datum/action/innate/mw_minimap/Activate()
	if(!owner?.client)
		return
	active = TRUE
	if(!window)
		window = new
		window.host = src
		window.screen_loc = window_loc
	if(!holomap)
		holomap = new
	redraw(get_turf(owner))
	timer_id = addtimer(CALLBACK(src, PROC_REF(tick)), MW_MINIMAP_REFRESH, TIMER_LOOP | TIMER_STOPPABLE)

// Правый клик по кнопке — режим рисования. Отдельным переключателем, а не «всегда
// включено у командира»: окно с пойманной мышью висит поверх трети экрана и в бою
// съедает клики по местности. Заодно ничего нашего не трогает мышь, пока командир
// сам не попросил.
/datum/action/innate/mw_minimap/Trigger(mob/clicker, trigger_flags)
	if(!can_draw || !(trigger_flags & TRIGGER_SECONDARY_ACTION))
		return ..()
	drawing = !drawing
	update_mouse()
	to_chat(owner, span_notice("Режим рисования по карте [drawing ? "включён" : "выключен"]."))
	return TRUE

// Ctrl-клик по кнопке — стереть разметку. Дублирует правый клик по самой карте:
// правый клик по экранным объектам доходит не в любой сборке клиента, а стирать
// нарисованное командир должен иметь возможность всегда.
/datum/action/innate/mw_minimap/AltTrigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	wipe()

/datum/action/innate/mw_minimap/proc/update_mouse()
	if(!window)
		return
	// Именно OPAQUE, а не ICON: незакрашенные куски карты прозрачны, а по прозрачному
	// пикселю BYOND событий не даёт — рисовать можно было бы только поверх закрашенного.
	window.mouse_opacity = (drawing && active) ? MOUSE_OPACITY_OPAQUE : MOUSE_OPACITY_TRANSPARENT

/datum/action/innate/mw_minimap/Deactivate()
	active = FALSE
	update_mouse()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	if(owner?.client)
		UnregisterSignal(owner.client, COMSIG_CLIENT_MOUSEDRAG)
	if(window)
		owner?.client?.screen -= window

/// Протяжка мыши. Ловим через клиентский сигнал, а не через atom/MouseDrag: так не
/// зависим от того, доходит ли до атома роутинг, а сигнал шлётся безусловно.
/datum/action/innate/mw_minimap/proc/on_drag(client/source, src_object, atom/over_object, src_location, over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(over_object != window)
		return
	stroke_to(params)

// Тик делает всё: и перецентровку, и маркеры. Отдельной подписки на COMSIG_MOVABLE_MOVED
// нет намеренно — окно шириной 96 тайлов, за секунду из него не выбежать, а на сотне
// игроков лишний обработчик каждого шага стоит дороже, чем секундный таймер.
/datum/action/innate/mw_minimap/proc/tick()
	if(!active)
		return
	if(!owner?.client)
		return
	var/turf/where = mw_map_turf(owner)
	if(!where)
		return
	if(where.z != holomap.map_z || !anchor)
		redraw(where)
		return
	if(follow && (abs(where.x - anchor.x) > MW_MINIMAP_DRIFT || abs(where.y - anchor.y) > MW_MINIMAP_DRIFT))
		redraw(where)
		return
	if(drawn_version != GLOB.mw_tacmap_version[mountain_wars_faction(owner)])
		redraw(where)
		return
	holomap.location_turf = where
	draw_markers()

/// Режет подложку заново вокруг переданного турфа. Единственная тяжёлая операция здесь —
/// icon.Crop() внутри initialize_holomap, поэтому зовём её только по сносу или смене z.
/datum/action/innate/mw_minimap/proc/redraw(turf/where)
	if(!where)
		return
	// Развёрнутая карта не ездит за бойцом: вырез стоит на центре уровня, где боец
	// сейчас находится. Уровень всё равно берём от него — в туннелях нужна карта туннелей.
	if(!follow)
		where = locate(round(world.maxx / 2), round(world.maxy / 2), where.z)
		if(!where)
			return
	anchor = where
	var/half = round(crop_size / 2)
	// Координаты выреза — в пикселях холста 480x480, а не в тайлах карты, отсюда сдвиг
	// на HOLOMAP_CENTER: карта лежит по центру холста.
	var/x1 = HOLOMAP_CENTER_X + where.x - half
	var/y1 = HOLOMAP_CENTER_Y + where.y - half
	holomap.initialize_holomap(
		where,
		where.z,
		reinit_base_map = TRUE,
		show_legend = FALSE,
		// Минус единица не описка: Crop() включает обе границы, и без неё кусок выходит
		// на пиксель больше заказанного. Миникарта прижата к углу обзора, где этот пиксель
		// вылезает за край и заставляет клиент дорисовывать лишнюю полосу мира.
		crop = list(CROP_X1 = x1, CROP_Y1 = y1, CROP_X2 = x1 + crop_size - 1, CROP_Y2 = y1 + crop_size - 1),
	)
	// Рисунок командира вжигаем в подложку, а не вешаем оверлеями: штрих — это сотни
	// точек, а create_overlays() режет список на восьмидесяти.
	var/faction = mountain_wars_faction(owner)
	var/icon/canvas = GLOB.mw_tacmap_canvas[faction]
	if(canvas)
		var/icon/piece = icon(canvas)
		piece.Crop(x1, y1, x1 + crop_size - 1, y1 + crop_size - 1)
		holomap.map_icon.Blend(piece, ICON_OVERLAY)
	drawn_version = GLOB.mw_tacmap_version[faction]
	window.icon = holomap.map_icon
	draw_markers()

// MARK: Рисование
/datum/action/innate/mw_minimap/proc/stroke_to(params)
	if(!can_draw || !drawing || !active || !holomap)
		return
	// Конца штриха нам не сообщают — MouseUp до атома не доходит. Считаем штрих
	// оборванным по паузе: отпустил мышь, подумал, ткнул в другом месте — новая линия,
	// а не отрезок через пол-карты.
	if(world.time - last_point_time > MW_TACMAP_BREAK)
		last_x = 0
		last_y = 0
	last_point_time = world.time
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, "icon-x"))
	var/icon_y = text2num(LAZYACCESS(modifiers, "icon-y"))
	if(isnull(icon_x) || isnull(icon_y))
		return
	// icon-x отсчитывается от единицы внутри вырезанного куска, холст — абсолютный.
	var/canvas_x = holomap.crop_x + icon_x - 1
	var/canvas_y = holomap.crop_y + icon_y - 1
	var/faction = mountain_wars_faction(owner)
	mw_tacmap_draw(faction, last_x || canvas_x, last_y || canvas_y, canvas_x, canvas_y)
	last_x = canvas_x
	last_y = canvas_y
	// Себе показываем сразу: рисующий один, и вести линию вслепую нельзя.
	if(world.time < next_self_push)
		return
	next_self_push = world.time + MW_TACMAP_SELF_PUSH
	redraw(anchor)

/datum/action/innate/mw_minimap/proc/wipe()
	if(!can_draw)
		return
	mw_tacmap_wipe(mountain_wars_faction(owner))
	to_chat(owner, span_notice("Вы стираете разметку с тактической карты."))

/datum/action/innate/mw_minimap/proc/draw_markers()
	// Пул отдаём с начала: всё, что было роздано в прошлый тик, уже перерисовано.
	blips_used = 0
	var/list/blips = holomap.create_overlays(markers())
	window.cut_overlays()
	// Одним вызовом на весь список, а не по метке за раз. add_overlay на каждую картинку
	// заново собирает список внешностей, проверяет лимит оверлеев и обходит
	// alternate_appearances — на полусотне своих это полсотни таких проходов в секунду
	// у каждого игрока. Список проц принимает сам.
	if(length(blips))
		window.add_overlay(blips)
	// Пересоединившийся игрок получает чистый client.screen и новый объект клиента:
	// окно выпадает из экрана, подписка на мышь умирает вместе со старым клиентом.
	// Вместо ловли логина просто восстанавливаем то и другое каждый тик — обе операции
	// идемпотентные, override у RegisterSignal ровно для этого.
	owner.client.screen |= window
	if(!drawing)
		return
	RegisterSignal(owner.client, COMSIG_CLIENT_MOUSEDRAG, PROC_REF(on_drag), TRUE)
	update_mouse()

/// Что показывать поверх подложки, кроме курсора. Формат — как в /datum/station_holomap:
/// list("подпись" = list("icon" = image, "markers" = list(image))).
///
/// Список собирается заново каждый тик у каждого игрока — и иначе нельзя: вырез у всех
/// свой, значит и пиксельные координаты метки у всех разные, общий список картинок на
/// фракцию не переиспользуешь. Держится это на отсечении по окну в blip_at(): за границу
/// выреза картинка не создаётся вовсе, остаётся сравнение двух чисел.
///
/// ponytail: на сотне игроков это сотня проходов по составу фракции в секунду. Если
/// профайлер покажет, что дорого — резать по звеньям, а не по всей фракции.
///
/// Готовый SSholomaps.holomap_z_transitions сюда не годится: в нём все лестницы уровня
/// без разбора, и морпех увидел бы всю сеть туннелей с первого взгляда на карту.
/datum/action/innate/mw_minimap/proc/markers()
	. = list()
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(!istype(mode))
		return
	var/faction = mountain_wars_faction(owner)
	var/datum/team/mountain_wars/team = mode.teams[faction]
	if(!team)
		return

	var/list/mates = list()
	for(var/datum/mind/mind as anything in team.members)
		var/mob/living/mate = mind?.current
		if(QDELETED(mate) || mate == owner || mate.stat == DEAD)
			continue
		var/image/blip = blip_at(mw_map_turf(mate), team.team_color)
		if(blip)
			mates += blip
	if(length(mates))
		.["Свои"] = list("icon" = null, "markers" = mates)

	// Лазы — только повстанцам. Морпех на них не наступит даже случайно: они у него
	// и на земле невидимы (см. tunnels.dm), так что метка на карте была бы единственной
	// подсказкой, где копать.
	if(faction != JOB_TITLE_MW_INSURGENT)
		return
	var/list/hatches = list()
	for(var/obj/structure/ladder/hatch as anything in GLOB.mw_tunnel_hatches)
		var/image/blip = blip_at(get_turf(hatch), MW_BLIP_HATCH)
		if(blip)
			hatches += blip
	if(length(hatches))
		.["Лазы"] = list("icon" = null, "markers" = hatches)

/// Картинка метки на нужном месте выреза, или null, если метка за его границей.
/// Координаты — как у курсора в /datum/station_holomap: пиксели холста минус угол выреза.
/datum/action/innate/mw_minimap/proc/blip_at(turf/where, tint)
	if(!where || where.z != holomap.map_z)
		return null
	var/offset_x = HOLOMAP_CENTER_X + where.x - holomap.crop_x - 1
	var/offset_y = HOLOMAP_CENTER_Y + where.y - holomap.crop_y - 1
	// Метка 3x3, поэтому в окно она должна поместиться целиком — иначе торчит за край
	// картинки и тянет за собой границу отрисовки.
	if(offset_x < 1 || offset_y < 1 || offset_x > crop_size - MW_BLIP_SIZE || offset_y > crop_size - MW_BLIP_SIZE)
		return null
	// Картинку берём из пула, а не создаём заново. Меток на экране столько же, сколько
	// своих в округе, и раздаются они каждую секунду: на сотне игроков это тысячи новых
	// объектов в секунду на выброс. Переиспользовать их можно, потому что add_overlay
	// кладёт в оверлеи копию внешности — переставленная на следующем тике картинка уже
	// нарисованное не трогает.
	blips_used++
	var/image/blip
	if(blips_used <= length(blip_pool))
		blip = blip_pool[blips_used]
		blip.icon = mw_blip_icon(tint)
	else
		blip = image(mw_blip_icon(tint))
		blip_pool += blip
	// Метка 3x3, поэтому сдвигаем на пиксель — иначе точка стоит не на объекте,
	// а справа сверху от него.
	blip.pixel_w = offset_x - 1
	blip.pixel_z = offset_y - 1
	return blip

// MARK: Развёрнутая карта
// Вторая кнопка, вся карта уровня целиком в центре экрана. Нужна командиру: рисовать
// он может только внутри своего выреза, а из угловой минимапы дотянуться до чужого
// фланга нельзя. Рядовым она тоже выдаётся — на чтение.
//
// Держится на тех же процах, что и минимапа, разница только в трёх переменных. Карта
// 255x255 влезает в холст без масштабирования, поэтому пиксель по-прежнему равен тайлу.
/datum/action/innate/mw_minimap/full
	name = "Развернуть карту"
	desc = "Показать карту сектора целиком."
	button_icon_state = "mech_zoom_off"
	crop_size = 255
	window_loc = ui_mw_tacmap
	follow = FALSE

// У развёрнутой карты рисование включается вместе с ней, без отдельного переключателя:
// она и так закрывает пол-экрана, кликать сквозь неё всё равно некуда. Скрытый правый
// клик по кнопке оставался единственным входом в режим, и до него не догадывались.
/datum/action/innate/mw_minimap/full/Activate()
	drawing = can_draw
	. = ..()
	if(!drawing)
		return
	to_chat(owner, span_notice("Рисование по карте включено: ЛКМ — линия, Ctrl-клик по кнопке — стереть."))

/datum/action/innate/mw_minimap/full/Deactivate()
	drawing = FALSE
	return ..()

#undef ui_mw_minimap
#undef ui_mw_tacmap
#undef MW_BLIP_SIZE
#undef MW_BLIP_HATCH
#undef MW_MINIMAP_DRIFT
#undef MW_MINIMAP_REFRESH
#undef MW_TACMAP_INK
#undef MW_TACMAP_PUSH
#undef MW_TACMAP_SELF_PUSH
#undef MW_TACMAP_MAX_STEP
#undef MW_TACMAP_BREAK
