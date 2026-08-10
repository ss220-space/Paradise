// MARK: FOB-рация
// Точка респавна фракции: пока стоит — фракция спавнится и на ней.
/obj/structure/mw_fob
	name = "полевая рация"
	desc = "Развёрнутая полевая радиостанция. Служит точкой сбора подкреплений."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	anchored = TRUE
	density = TRUE
	max_integrity = 150
	/// Фракция, которой принадлежит точка (JOB_TITLE_MW_*).
	var/faction
	var/turf/registered_turf

/obj/structure/mw_fob/Initialize(mapload)
	. = ..()
	if(!faction)
		return
	registered_turf = get_turf(src)
	var/list/fobs = GLOB.mountain_wars_fobs[faction]
	fobs += registered_turf

/obj/structure/mw_fob/Destroy()
	if(faction && registered_turf)
		var/list/fobs = GLOB.mountain_wars_fobs[faction]
		fobs -= registered_turf
	registered_turf = null
	return ..()

/obj/structure/mw_fob/marine
	faction = JOB_TITLE_MW_MARINE

/obj/structure/mw_fob/insurgent
	faction = JOB_TITLE_MW_INSURGENT

// Свёрнутая рация — разворачивается на месте за 5 секунд.
//
// Габарит оставлен родительским, то есть NORMAL. Объёмным его делать нельзя: рация
// выдаётся через backpack_contents, у рюкзака max_w_class как раз NORMAL, и BULKY в
// него не лез. equip_or_collect на отказ кладёт вещь под ноги, то есть комплект
// оставался лежать на точке высадки, а командир уходил в бой без него и не знал об этом.
/obj/item/mw_fob_kit
	name = "свёрнутая полевая рация"
	desc = "Полевая радиостанция в походном виде. Активируйте, чтобы развернуть."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	/// Тип разворачиваемой структуры.
	var/fob_type

/obj/item/mw_fob_kit/attack_self(mob/user)
	if(!fob_type)
		return
	balloon_alert(user, "разворачиваем...")
	if(!do_after(user, 5 SECONDS, user))
		return
	new fob_type(get_turf(user))
	qdel(src)

/obj/item/mw_fob_kit/marine
	fob_type = /obj/structure/mw_fob/marine

/obj/item/mw_fob_kit/insurgent
	fob_type = /obj/structure/mw_fob/insurgent

// MARK: Грунт поверхности
// Родительский песок унаследовал от /turf режим ATMOS_MODE_SEALED: каждый тайл — свой
// герметичный объём, который MILLA считает отдельно и гоняет перетоки к соседям. На
// станции это уместно, а тут таких тайлов шестьдесят пять тысяч под открытым небом.
//
// EXPOSED_TO_ENVIRONMENT снимает симуляцию совсем: тайл просто прижат к неподвижной
// среде. Так объявлены поверхности Лавеленда и снежных карт.
/turf/simulated/floor/indestructible/asteroid/mw
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE

// Пол грузового отсека. Борт возит свои клетки с собой, и на карте под ним был обычный
// песок — в воздухе тот песок торчал из-под скруглённых бортов поверх пустыни.
//
// Прозрачным его не сделать. Пустыня — экранный объект на плане параллакса, а параллакс
// проступает только сквозь космические турфы. Под палубой турф обычный, и на месте
// невидимого пола остаётся чёрный фон контрола карты, а не пейзаж. Поэтому не прячем, а
// красим железом: по кромке корпуса это читается как борт машины, а не как земля.
//
// Не подтип asteroid: тот подмешивает состояния раскопок, и icon_state ему менять нельзя.
// Режим атмосферы приходится повторить, зато лишней логики не тащим.
/turf/simulated/floor/indestructible/mw_heli_deck
	name = "палуба"
	desc = "Рифлёный настил грузового отсека."
	icon_state = "plating"
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE

// Ветра здесь не бывает. По кромке отсека борта — плотные объекты, а атмосферу держат
// только турфы, поэтому MILLA видит палубу под давлением впритык к вакууму за бортом и
// рисует по периметру струи утечки. Утечки при этом нет: палуба прижата к неподвижной
// среде и газ не теряет. Картинка врала, её и убираем.
/turf/simulated/floor/indestructible/mw_heli_deck/update_wind()
	QDEL_NULL(wind_effect)
	wind_tick = null
	return FALSE

// Палуба не бьётся и не обгорает.
//
// Неразрушимый пол гасит ex_act, но break_tile и burn_tile родитель не трогает, а они
// заходят другой дверью: пламя взрыва греет клетку, temperature_expose зовёт burn_tile,
// и та кладёт поверх настила состояние копоти. Турф при этом цел — портится только
// картинка, и по всему отсеку идут разномастные обгорелые квадраты вперемешку с целыми.
// На мозаике вертолёта это читается как разломанный корпус.
/turf/simulated/floor/indestructible/mw_heli_deck/break_tile()
	return

/turf/simulated/floor/indestructible/mw_heli_deck/burn_tile()
	return

// MARK: Песчаная скала
// Неразрушимый камень карты, перекрашенный в песчаник. Отдельный подтип, а не правка
// mineral_rock: тот стоит на всех шахтёрских картах, и трогать его нельзя.
//
// Склейка достаётся от родителя даром — он уже в группе SMOOTH_GROUP_MINERAL_WALLS и
// использует битмаску smoothrocks. Своя группа тут не нужна и вредна: тогда наш камень
// перестанет стыковаться с чужим.
//
// ponytail: color поверх чужого спрайта. Свой лист песчаника — это 47 кадров под все
// сочетания соседей (smoothrocks-0 ... smoothrocks-255), одной плиткой не обойтись.
/turf/simulated/wall/indestructible/mineral_rock/mw_sandstone
	name = "песчаник"
	desc = "Слоистая порода, выветренная до охры."
	color = "#c9a06a"

// MARK: Скальный уступ
// Имитация высоты без второго z-уровня. Уступ плотный: пройти сквозь него нельзя,
// только залезть. У каждого уступа свой ярус, и залезть можно лишь на один выше того,
// где стоишь: чтобы попасть на третий, надо взять первый и второй.
//
// Настоящей высоты в игре нет — мобу сдвигается pixel_z, и всё. Уступ делает уступом
// не высота, а то, что наверх нет прямого хода и подъём занимает время под огнём.

/// На сколько пикселей приподнимается моб за каждый ярус.
#define MW_LEDGE_SHIFT 8
/// Брут за ярус падения, поровну на обе ноги.
#define MW_LEDGE_FALL_DAMAGE 10
/// Шанс, что уступ поймает пулю, летящую снизу. Умножается на разницу ярусов.
#define MW_LEDGE_COVER 35

/obj/structure/mw_ledge
	name = "нижний уступ"
	desc = "Каменная ступень. Чтобы забраться, под ногами нужна опора."
	// Берём готовый лист сглаживания скал: там 47 кадров под все сочетания соседей,
	// поэтому уступы собираются в сплошной массив с нормальными краями, а не в решётку
	// из одинаковых булыжников. Группа одна на все ярусы: гряда — единое тело камня,
	// а где кончается ступень, показывает цвет, а не шов.
	icon = 'icons/turf/smoothrocks.dmi'
	icon_state = "smoothrocks-0"
	base_icon_state = "smoothrocks"
	smooth = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_MW_LEDGE
	canSmoothWith = SMOOTH_GROUP_MW_LEDGE
	// Песчаник, а не серый камень, и по склону светлее: подножие в тени, гребень на
	// солнце. Отличать ярусы надо с одного взгляда, иначе непонятно, куда можно залезть.
	// ponytail: подкраска чужого спрайта. Появятся свои листы — снять color.
	color = "#a8845a"
	anchored = TRUE
	density = TRUE
	max_integrity = 500
	/// Ярус уступа. Залезть можно только с яруса tier - 1.
	var/tier = 1

/obj/structure/mw_ledge/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable/mw_ledge, 3 SECONDS, 0.5 SECONDS)
	AddElement(/datum/element/climb_walkable/mw_ledge)
	AddElement(/datum/element/elevation, pixel_shift = tier * MW_LEDGE_SHIFT)
	// pixel_y тут был и его пришлось убрать: кадры сглаживания рисуют края в расчёте
	// на то, что тайл стоит ровно в своей клетке. Сдвинешь спрайт вверх — снизу
	// открывается полоса грунта, и вместо сплошного массива выходит гряда отдельных
	// плашек. Высоту несут цвет, кромка обрыва и подъём моба, который живёт на мобе.
	// Слои разводим: верхний ярус должен перекрывать нижний на стыке.
	layer = initial(layer) + tier * 0.01
	// Кромку считаем после загрузки: на Initialize соседей ещё может не быть.
	return INITIALIZE_HINT_LATELOAD

/obj/structure/mw_ledge/LateInitialize()
	update_icon(UPDATE_OVERLAYS)

/// Обрыв на сторонах, где сосед ниже нас.
///
/// Сглаживание сшивает все ярусы в единое тело камня — так гряда и должна читаться,
/// но тогда ступень видна только по оттенку, а этого мало. Дорисовываем с каждой
/// открытой стороны боковину скалы: получается настоящий выступ, за которым видно,
/// что кусок камня лежит выше соседнего.
///
/// Сосед ровно нашего яруса кромки не даёт — там сплошная поверхность, обрываться
/// нечему. Ниже на ярус или голая земля — даёт.
/obj/structure/mw_ledge/update_overlays()
	. = ..()
	var/static/list/lip_states = list(
		"[NORTH]" = "rock_side_n",
		"[SOUTH]" = "rock_side_s",
		"[EAST]" = "rock_side_e",
		"[WEST]" = "rock_side_w",
	)
	for(var/step_dir in GLOB.cardinal)
		if(mw_ledge_level(get_step(src, step_dir)) >= tier)
			continue
		var/mutable_appearance/lip = mutable_appearance('icons/turf/mining.dmi', lip_states["[step_dir]"])
		// Затемняем: боковина обрыва — это всегда теневая грань, и именно контраст
		// между ней и верхом плиты читается как высота.
		lip.color = "#9a8f80"
		. += lip

/obj/structure/mw_ledge/examine(mob/user)
	. = ..()
	var/standing = mw_ledge_level(get_turf(user))
	. += span_notice("Ярус [tier]. Вы на ярусе [standing].")
	if(tier > standing + 1)
		. += span_warning("Отсюда не залезть — сначала нужен ярус [tier - 1].")

// Плотный уступ по умолчанию ловит любую пулю, влетающую в его тайл. Для стены это
// верно, для ступени — нет: стрелок, стоящий на такой же высоте, бьёт поверх неё, а
// боец на уступе иначе оказывался бы неуязвим для всех, кто стоит на земле.
//
// Правило: уступ не ниже стрелка — не помеха. Выше — бруствер: не щит, но с дистанции
// часто съедает пулю, и тем чаще, чем больше разница по высоте. В упор не спасает.
/obj/structure/mw_ledge/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return TRUE
	if(!isprojectile(mover))
		return
	var/obj/projectile/bullet = mover
	var/height_gap = tier - mw_ledge_level(get_turf(bullet.firer))
	if(height_gap <= 0)
		return TRUE
	if(in_range(bullet.starting, loc))
		return TRUE
	return !prob(min(MW_LEDGE_COVER * height_gap, 90))

// Слезать надо шагом. Спрыгнул бегом — прилетело по ногам, тем больше, чем выше был.
/obj/structure/mw_ledge/on_climb_exit(datum/source, atom/movable/gone, atom/new_loc)
	. = ..()
	if(!isliving(gone) || !isturf(new_loc))
		return
	var/drop = tier - mw_ledge_level(new_loc)
	if(drop <= 0)
		return
	var/mob/living/faller = gone
	if(faller.m_intent == MOVE_INTENT_WALK)
		return
	var/damage = drop * MW_LEDGE_FALL_DAMAGE
	faller.apply_damage(damage / 2, BRUTE, BODY_ZONE_L_LEG)
	faller.apply_damage(damage / 2, BRUTE, BODY_ZONE_R_LEG)
	faller.AdjustKnockdown(drop * (2 SECONDS))
	playsound(new_loc, 'sound/effects/bang.ogg', 40, TRUE)
	faller.visible_message(
		span_danger("[faller] спрыгивает с уступа и тяжело приземляется!"),
		span_userdanger("Вы спрыгиваете с уступа. Ноги отзываются болью — надо было спускаться шагом."),
	)

/obj/structure/mw_ledge/tier2
	name = "средний уступ"
	color = "#c9a06a"
	tier = 2

/obj/structure/mw_ledge/tier3
	name = "верхний уступ"
	color = "#e3c493"
	tier = 3

/// Ярус того, кто стоит на этом тайле. Голая земля — нулевой.
/proc/mw_ledge_level(turf/where)
	var/obj/structure/mw_ledge/ledge = locate() in where
	return ledge ? ledge.tier : 0

// Вверх — только лазаньем и только на ярус за раз.
/datum/element/climbable/mw_ledge/can_climb(obj/structure/mw_ledge/source, mob/user)
	if(!..())
		return FALSE
	if(source.tier > mw_ledge_level(get_turf(user)) + 1)
		source.balloon_alert(user, "слишком высоко!")
		return FALSE
	return TRUE

// Родитель пускает сквозь плотный уступ любого, кто уже стоит на уступе. Нам этого
// мало: иначе с первого яруса шагают сразу на третий в обход подъёма. Вниз и вбок
// оставляем свободными — иначе с уступа не слезть тем же путём, которым залез.
/datum/element/climb_walkable/mw_ledge/can_allow_through(obj/structure/mw_ledge/source, atom/movable/mover, border_dir)
	if(source.tier > mw_ledge_level(get_turf(mover)))
		return
	return ..()

#undef MW_LEDGE_SHIFT
#undef MW_LEDGE_FALL_DAMAGE
#undef MW_LEDGE_COVER

// MARK: Завал фазы подготовки
// Пока борта не пришли, зона высадки и место падения закрыты каменной пробкой:
// повстанцам туда рано. Пробку не берёт ничего — она сходит сама, когда борт садится.
//
// Мапперу: класть сплошной линией по границе зоны, тип выбирать по событию. Своей
// переменной на объекте нет намеренно: переменную забывают выставить, а тип — видно.
//
// Со скальными уступами завал не сглаживается и покрашен иначе. Уступ можно перелезть,
// завал нельзя, и путать их с одного взгляда игрок не должен.
GLOBAL_LIST_EMPTY(mw_rockfalls)

/obj/structure/mw_rockfall
	name = "завал"
	desc = "Камень лёг плотно, от земли до верха. Не растащить и не пролезть — такие сходят сами."
	icon = 'icons/turf/smoothrocks.dmi'
	icon_state = "smoothrocks-0"
	base_icon_state = "smoothrocks"
	smooth = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_MW_ROCKFALL
	canSmoothWith = SMOOTH_GROUP_MW_ROCKFALL
	// Свежий скол — серый камень, без выгоревшей на солнце охры уступов.
	// ponytail: подкраска чужого спрайта, как и у уступов. Появятся свои листы — снять.
	color = "#8e8b86"
	anchored = TRUE
	density = TRUE
	opacity = TRUE
	// Ни взрывом, ни киркой, ни резаком: завал — это таймер фазы, а не преграда,
	// которую предлагается пройти.
	resistance_flags = INDESTRUCTIBLE
	obj_flags = NODECONSTRUCT

/obj/structure/mw_rockfall/Initialize(mapload)
	. = ..()
	var/list/kin = GLOB.mw_rockfalls[type]
	if(!kin)
		kin = list()
		GLOB.mw_rockfalls[type] = kin
	kin += src

/obj/structure/mw_rockfall/Destroy()
	var/list/kin = GLOB.mw_rockfalls[type]
	kin -= src
	return ..()

/obj/structure/mw_rockfall/proc/crumble()
	// Звук с каждого камня разом — это стена шума на сотню источников. Хватает
	// россыпи: грохот идёт по всей линии, но слышно его как один обвал.
	if(prob(20))
		playsound(loc, 'sound/effects/break_stone.ogg', 60, TRUE)
	qdel(src)

/// Сводит завал указанного типа. Зовётся посадкой борта, см. flight.dm.
/proc/mw_clear_rockfall(rockfall_type)
	var/list/kin = GLOB.mw_rockfalls[rockfall_type]
	if(!length(kin))
		return
	// По копии: crumble() удаляет камень из того же списка, по которому идём.
	for(var/obj/structure/mw_rockfall/rock as anything in kin.Copy())
		rock.crumble()

/// Стена вокруг зоны высадки. Сходит, когда первый борт сел в секторе.
/obj/structure/mw_rockfall/lz

/// Стена вокруг места падения. Сходит, когда сбитый борт лёг на землю.
/obj/structure/mw_rockfall/crash

// MARK: Сиденья
// Общее поведение лавок и постов режима. По умолчанию сиденье невидимо: нутро вертолёта —
// цельная иллюстрация, лавки на ней уже нарисованы, и спрайт поверх давал вторую
// табуретку прямо на нарисованной скамье.
//
// Гасим альфой, а не icon = null: без картинки у объекта нет габаритов, а значит и цели
// для мыши — на такое сиденье не сядешь. MOUSE_OPACITY_OPAQUE берёт клетку целиком,
// чтобы попадать по невидимому.
//
// Отсекам техники это не подошло, там сиденья видимые — см. mw_vehicle.
/obj/structure/chair/mw
	name = "сиденье"
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	// Сиденье не отвинтить и не унести с собой посреди боя.
	item_chair = null
	buildstacktype = null

// MARK: Химзавод
// Цель под подрыв. Один кадр 288x352 — рисуется от левого-нижнего тайла вверх и
// вправо, за этот угол его и ставят в редакторе карт. Перекрывает всё позади: так и
// задумано. Неразрушим для всего, кроме пластида, прилепленного прямо на него.
/obj/structure/mw_chem_plant
	name = "химический завод"
	desc = "Перегонные колонны, реактор и стойка баллонов. Ради этой установки сюда и пришли. \
		Обстрел и обычная взрывчатка ей нипочём — только заряд пластида на самой установке."
	icon = 'icons/mountain_wars/chem_plant.dmi'
	icon_state = "plant"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	bound_width = 288
	bound_height = 352
	pixel_x = -5
	pixel_y = -6
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | UNACIDABLE | LAVA_PROOF

// Обычный взрыв шлёт вторым аргументом свой эпицентр-турф, и до нас он не дотянется.
// Ровно один случай даёт target == src: пластид (C4, X4, направленный C4 — всё
// семейство /obj/item/grenade/plastic) прилеплен прямо на установку и сдетонировал.
// Тот же признак используют обычные объекты в /obj/ex_act, так что правило не наше
// самодельное, а движковое.
/obj/structure/mw_chem_plant/ex_act(severity, target)
	if(target != src)
		return
	detonate()

/obj/structure/mw_chem_plant/proc/detonate()
	// Взрыв в середине площади, а не в углу-якоре, иначе дальний край не заденет.
	var/turf/epicenter = locate(x + round(bound_width / ICON_SIZE_X * 0.5), y + round(bound_height / ICON_SIZE_Y * 0.5), z) || get_turf(src)
	visible_message(span_boldwarning("[name] разлетается на куски!"))
	// Отсюда начинается финал раунда: объявление, отсчёт на отход и победа морпехов.
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(istype(mode))
		mode.plant_destroyed()
	qdel(src)
	explosion(epicenter, devastation_range = 2, heavy_impact_range = 5, light_impact_range = 9, flash_range = 12, cause = "Химзавод")
