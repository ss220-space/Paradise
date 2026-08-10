// Интерьеры техники Mountain Wars.
//
// Планировка и графика отсека — из TGMC (_maps/interiors/apc_transport.dmm,
// icons/obj/armored/3x3/apc_interior.dmi, CC BY-NC-SA 3.0). Их система интерьеров
// не портировалась: отсек грузится штатным для Paradise /datum/lazy_template в
// резервный блок при первой посадке и только тогда. В обычном раунде ни один блок
// не резервируется.
//
// Управление привязано не к факту посадки, а к креслам: сел за руль — получил
// VEHICLE_CONTROL_DRIVE и вид с корпуса, встал — потерял. Движение уходит в
// машину само, через штатную ветку buckled.relaymove() в mob_movement.dm.

/datum/lazy_template/mw_apc_interior
	key = LAZY_TEMPLATE_KEY_MW_APC_INTERIOR
	map_name = "mw_apc_interior"

// Базовый /area/mountain_wars — в areas.dm.
/area/mountain_wars/vehicle_interior
	name = "десантный отсек"
	// Отсек всегда освещён: иначе внутрь пришлось бы тянуть питание и лампы.
	// Одного static_lighting мало — он лишь отключает статический слой, а свет в
	// зоне даёт base_lighting_alpha, без него отсек чёрный.

/// Куда высаживается десант при посадке в машину. Не /obj/effect/landmark: тот
/// вешает на себя уникальный tag, а копий отсека столько же, сколько машин.
/obj/effect/mw_interior_entry
	name = "mw interior entry"
	icon = 'icons/misc/landmarks.dmi'
	icon_state = "standart"
	invisibility = INVISIBILITY_ABSTRACT

// MARK: Кресла
// Видимые, в отличие от лавок вертолёта: на планировке отсека сидений не нарисовано, и
// без спрайта десант садился в пустоту, не понимая куда.
//
// Кадр — тёмное шаттловое кресло: оно на четыре направления, поэтому и само сиденье
// поворачивается, и сидящий садится лицом куда надо. Прежний vehicle_chair этим и был
// плох: одно направление на все четыре.
//
// Общее поведение — в /obj/structure/chair/mw, structures.dm. Путь оставлен старым, он
// записан в шаблоне отсека; родитель подменён вручную.
/obj/structure/chair/mw_vehicle
	parent_type = /obj/structure/chair/mw
	name = "сиденье"
	desc = "Складное сиденье, приваренное к полу отсека."
	icon_state = "shuttle_chair_dark"
	/// Машина, которой принадлежит отсек. Проставляется при загрузке интерьера.
	var/obj/vehicle/mw/vehicle
	/// Что даёт это место. 0 — обычная лавка для десанта.
	var/control_flags = NONE

/obj/structure/chair/mw_vehicle/Destroy()
	vehicle = null
	return ..()

/obj/structure/chair/mw_vehicle/examine(mob/user)
	. = ..()
	if(control_flags)
		. += span_notice("Пристегнитесь, чтобы занять пост.")

// Штатная ветка в mob_movement.dm: пристёгнутый мобом двигает то, к чему пристёгнут.
/obj/structure/chair/mw_vehicle/relaymove(mob/living/user, direction)
	if(QDELETED(vehicle))
		return FALSE
	return vehicle.relaymove(user, direction)

/obj/structure/chair/mw_vehicle/post_buckle_mob(mob/living/target)
	. = ..()
	if(!control_flags || QDELETED(vehicle) || !vehicle.is_occupant(target))
		return
	vehicle.add_control_flags(target, control_flags)
	// Из отсека не видно поля боя, поэтому глаз занявшего пост переезжает на корпус.
	target.reset_perspective(vehicle)

/obj/structure/chair/mw_vehicle/post_unbuckle_mob(mob/living/target)
	. = ..()
	if(!control_flags)
		return
	if(!QDELETED(vehicle))
		vehicle.remove_control_flags(target, control_flags)
	target.reset_perspective(null)

/obj/structure/chair/mw_vehicle/driver
	name = "место водителя"
	desc = "Сиденье механика-водителя с рычагами и триплексом."
	control_flags = VEHICLE_CONTROL_DRIVE

/obj/structure/chair/mw_vehicle/gunner
	name = "место наводчика"
	desc = "Сиденье под люком, прямо под рукоятями пулемёта."
	control_flags = VEHICLE_CONTROL_EQUIPMENT

/obj/structure/chair/mw_vehicle/bench
	name = "десантная лавка"
	desc = "Жёсткая скамья вдоль борта. Держаться не за что."

// MARK: Обшивка и пол отсека
// Отсек — цельная иллюстрация из TGMC, нарезанная на клетки: каждый кусок это
// отдельный тип турфа со своим состоянием. Обшивка сделана плотным полом, а не
// стеной: стены Paradise тянут за собой сглаживание, каркасы и разборку, которые
// внутри машины только мешают.
/turf/simulated/floor/indestructible/mw_apc
	name = "пол отсека"
	icon = 'icons/mountain_wars/interior_apc.dmi'

// Отсек не бьётся и не обгорает — по той же причине, что и палуба вертолёта, см.
// structures.dm. Пол здесь тоже нарезанная иллюстрация, и копоть поверх одной клетки
// рвёт рисунок ровно посередине.
/turf/simulated/floor/indestructible/mw_apc/break_tile()
	return

/turf/simulated/floor/indestructible/mw_apc/burn_tile()
	return

/turf/simulated/floor/indestructible/mw_apc/hull
	name = "обшивка"
	desc = "Броневой лист изнутри. Ни выхода, ни обзора."
	density = TRUE

/turf/simulated/floor/indestructible/mw_apc/hull/p1
	icon_state = "apc_interior_1"
/turf/simulated/floor/indestructible/mw_apc/hull/p2
	icon_state = "apc_interior_2"
/turf/simulated/floor/indestructible/mw_apc/hull/p3
	icon_state = "apc_interior_3"
/turf/simulated/floor/indestructible/mw_apc/hull/p4
	icon_state = "apc_interior_4"
/turf/simulated/floor/indestructible/mw_apc/hull/p5
	icon_state = "apc_interior_5"
/turf/simulated/floor/indestructible/mw_apc/hull/p6
	icon_state = "apc_interior_6"
/turf/simulated/floor/indestructible/mw_apc/hull/p12
	icon_state = "apc_interior_12"
/turf/simulated/floor/indestructible/mw_apc/hull/p13
	icon_state = "apc_interior_13"
/turf/simulated/floor/indestructible/mw_apc/hull/p17
	icon_state = "apc_interior_17"
/turf/simulated/floor/indestructible/mw_apc/hull/p19
	icon_state = "apc_interior_19"
	// Верхняя кромка корпуса рисуется поверх экипажа.
	layer = ABOVE_ALL_MOB_LAYER
/turf/simulated/floor/indestructible/mw_apc/hull/p20
	icon_state = "apc_interior_20"
	// Верхняя кромка корпуса рисуется поверх экипажа.
	layer = ABOVE_ALL_MOB_LAYER
/turf/simulated/floor/indestructible/mw_apc/hull/p23
	icon_state = "apc_interior_23"
/turf/simulated/floor/indestructible/mw_apc/hull/p24
	icon_state = "apc_interior_24"
/turf/simulated/floor/indestructible/mw_apc/hull/p27
	icon_state = "apc_interior_27"
	// Верхняя кромка корпуса рисуется поверх экипажа.
	layer = ABOVE_ALL_MOB_LAYER
/turf/simulated/floor/indestructible/mw_apc/hull/p28
	icon_state = "apc_interior_28"

/turf/simulated/floor/indestructible/mw_apc/hull/hatch
	name = "десантный люк"
	desc = "Кормовая аппарель. Изнутри не открывается — только покинуть машину."
	icon = 'icons/mountain_wars/interior_tank.dmi'
	icon_state = "tank_interior_7"

/turf/simulated/floor/indestructible/mw_apc/p8
	icon_state = "apc_interior_8"
/turf/simulated/floor/indestructible/mw_apc/p9
	icon_state = "apc_interior_9"
/turf/simulated/floor/indestructible/mw_apc/p10
	icon_state = "apc_interior_10"
/turf/simulated/floor/indestructible/mw_apc/p11
	icon_state = "apc_interior_11"
/turf/simulated/floor/indestructible/mw_apc/p14
	icon_state = "apc_interior_14"
/turf/simulated/floor/indestructible/mw_apc/p15
	icon_state = "apc_interior_15"
/turf/simulated/floor/indestructible/mw_apc/p16
	icon_state = "apc_interior_16"
/turf/simulated/floor/indestructible/mw_apc/p22
	icon_state = "apc_interior_22"
/turf/simulated/floor/indestructible/mw_apc/p29
	icon_state = "apc_interior_29"

// MARK: Загрузка отсека
/// Клетка, на которую высаживается десант. Отсек грузится при первой посадке.
/obj/vehicle/mw/proc/get_interior_entry()
	if(!interior_key)
		return null
	if(interior_entry)
		return interior_entry
	interior = SSmapping.lazy_load_template(interior_key, TRUE)
	if(!interior)
		stack_trace("[type]: не удалось загрузить интерьер '[interior_key]'")
		return null
	var/turf/bottom_left = interior.bottom_left_turfs[1]
	var/turf/top_right = interior.top_right_turfs[1]
	// По этой линии решаем, какой ряд лавок нижний: он смотрит в проход, то есть вверх.
	var/midline = (bottom_left.y + top_right.y) / 2
	// Шаблон один на все машины, так что связь «отсек — корпус» проставляется здесь.
	for(var/turf/candidate as anything in block(bottom_left, top_right))
		for(var/atom/movable/thing in candidate)
			if(istype(thing, /obj/effect/mw_interior_entry))
				interior_entry = candidate
			else if(istype(thing, /obj/structure/chair/mw_vehicle))
				var/obj/structure/chair/mw_vehicle/seat = thing
				seat.vehicle = src
				// Посты смотрят вперёд по ходу машины, то есть вправо. Десант сидит
				// лицом в проход: нижний ряд разворачиваем вверх, верхний и так вниз.
				seat.setDir(seat.control_flags ? EAST : (candidate.y < midline ? NORTH : SOUTH))
	return interior_entry

// Отсек есть у обеих бронемашин: техничка — открытый пикап, десант сидит в кузове
// на виду. Планировка одна на двоих, у ЛАВ она просто заполнена не до конца.
// Сам interior_key выставлен там же, где объявлены машины, — см. vehicles.dm.
