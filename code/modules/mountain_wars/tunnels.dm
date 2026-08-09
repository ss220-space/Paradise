// Сеть туннелей повстанцев.
//
// Вход — присыпанный землёй лаз, ведущий на отдельный z-уровень. Морпех его не видит
// и ткнуть не может: лаз висит на уровне невидимости выше обычного зрения, а зрение
// повстанцам поднимает их же команда при заходе в бой.
//
// Лазы двух видов, по способу связки верха с низом:
//
//   mw_tunnel — по id. Верх и низ ищут друг друга по совпадению id и разнице height
//     в единицу, координаты не при чём. Вход на восточном склоне выводит хоть за спину
//     морпехам. На карте каждой шахте задаётся свой id; два лаза с одинаковым id
//     слипнутся в одну шахту. Неразрушим — наследство /unbreakable.
//
//   mw_shaft — по координатам. Ищет лаз строго под собой: тот же x, тот же y, соседний
//     z. Прямой колодец, никуда не уводит. Зато разрушаемый, и на карте с ним не надо
//     следить за id — поставил две штуки одна под другой, и всё.
//     Требует ZTRAIT_UP / ZTRAIT_DOWN в определении карты: без них GET_TURF_BELOW()
//     возвращает null и связка не происходит вовсе.

/// Уровень невидимости лазов. Обычное зрение — SEE_INVISIBLE_LIVING (25), оно ниже.
///
/// Раньше здесь стоял INVISIBILITY_HIDDEN_RUNES, но апстрим выпилил скрытые руны culta
/// вместе с их уровнем. Число то же самое, 30: между обычным зрением и
/// SEE_INVISIBLE_LEVEL_ONE (35) оно свободно, и поведение лазов не меняется.
#define MW_TUNNEL_INVIS 30
/// Сколько лезть по лазу. Мгновенный вход превращает сеть в кнопку телепорта:
/// нырнуть от очереди в упор и вынырнуть в тылу не должно быть бесплатно.
#define MW_TUNNEL_TRAVEL (3 SECONDS)

// Невидимость сама по себе уже не пускает морпеха — ткнуть в то, чего не видишь,
// нельзя. Проверка на случай, если он попадёт к лазу другим путём: пролез следом за
// повстанцем, увидел через чужие глаза, залез в туннель админским способом.
/proc/mw_tunnel_allowed(obj/structure/ladder/hatch, mob/user, is_ghost)
	if(is_ghost || mountain_wars_faction(user) == JOB_TITLE_MW_INSURGENT)
		return TRUE
	hatch.balloon_alert(user, "не пролезть!")
	return FALSE

// Все лазы сети, обоих видов. Нужен тактической карте: повстанцу лазы на ней помечены,
// морпеху нет. Свой список, а не GLOB.ladders — туда пишутся только /unbreakable, и
// смешивать наши лазы с чужими лестницами станции незачем.
GLOBAL_LIST_EMPTY(mw_tunnel_hatches)

/proc/mw_register_hatch(obj/structure/ladder/hatch)
	GLOB.mw_tunnel_hatches += hatch

// MARK: Лаз сети — связка по id
/obj/structure/ladder/unbreakable/mw_tunnel
	name = "лаз"
	desc = "Присыпанный землёй лаз. Уходит вниз, в темноту."
	invisibility = MW_TUNNEL_INVIS
	travel_time = MW_TUNNEL_TRAVEL
	height = 2

/obj/structure/ladder/unbreakable/mw_tunnel/Initialize(mapload)
	. = ..()
	mw_register_hatch(src)

/obj/structure/ladder/unbreakable/mw_tunnel/Destroy()
	GLOB.mw_tunnel_hatches -= src
	return ..()

/obj/structure/ladder/unbreakable/mw_tunnel/bottom
	name = "выход из туннеля"
	desc = "Земляной ход, уходящий наверх."
	height = 1

/obj/structure/ladder/unbreakable/mw_tunnel/use(mob/user, is_ghost = FALSE)
	if(!mw_tunnel_allowed(src, user, is_ghost))
		return
	return ..()

// MARK: Лаз-колодец — связка по координатам
/obj/structure/ladder/mw_shaft
	name = "лаз"
	desc = "Присыпанный землёй лаз. Уходит вниз, в темноту."
	invisibility = MW_TUNNEL_INVIS
	travel_time = MW_TUNNEL_TRAVEL

/obj/structure/ladder/mw_shaft/Initialize(mapload)
	. = ..()
	mw_register_hatch(src)

/obj/structure/ladder/mw_shaft/Destroy()
	GLOB.mw_tunnel_hatches -= src
	return ..()

/obj/structure/ladder/mw_shaft/use(mob/user, is_ghost = FALSE)
	if(!mw_tunnel_allowed(src, user, is_ghost))
		return
	return ..()

// MARK: Обычная лестница
// Видна всем, лезут все, ломать нельзя, связка по координатам — поставил одну над
// другой, и всё.
//
// Это не придирка к типу: штатная /obj/structure/ladder/unbreakable ищет пару не по
// координатам, а по паре id + height, и её LateInitialize() выходит первой строкой,
// если id не задан на карте. То есть неразрушимая лестница без id не свяжется ни с
// чем, хоть ставь их стопкой. Здесь наследуемся от базовой лестницы — она ищет пару
// строго под собой через GET_TURF_BELOW() — и добавляем только неразрушимость.
/obj/structure/ladder/mw
	name = "лестница"
	desc = "Прочная металлическая лестница."
	resistance_flags = INDESTRUCTIBLE

// MARK: Зрение повстанцев
// Повстанцы видят лазы, остальные нет. Ставить see_invisible напрямую бесполезно:
// update_sight() у человека каждый раз возвращает значение с органа глаз и затирает
// наше. Поэтому вешаемся на сигнал смены и не даём опустить зрение ниже лазов.
/datum/team/mountain_wars/insurgent/add_member(datum/mind/new_member, add_objectives = TRUE, outfit_type)
	. = ..()
	var/mob/living/member = new_member?.current
	if(!member)
		return
	RegisterSignal(member, COMSIG_MOB_SEE_INVIS_CHANGE, PROC_REF(keep_tunnel_sight), TRUE)
	member.set_invis_see(MW_TUNNEL_INVIS)

/datum/team/mountain_wars/insurgent/proc/keep_tunnel_sight(mob/source, new_sight, old_sight)
	SIGNAL_HANDLER
	// Поднять зрение выше (призраки, спецсредства) не мешаем — режем только просадку.
	if(new_sight < MW_TUNNEL_INVIS)
		return COMPONENT_BLOCK_INVIS_CHANGE

#undef MW_TUNNEL_INVIS
#undef MW_TUNNEL_TRAVEL
