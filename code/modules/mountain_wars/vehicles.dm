// Техника Mountain Wars. Спрайты из TerraGov Marine Corps (CC BY-NC-SA 3.0).
//
// Родная система TGMC (/obj/vehicle/sealed/armored) тянет за собой хитбоксы-релеи,
// интерьеры на отдельных z-уровнях, хардпоинты и минимапу — около 3500 строк и
// лишние z-уровни, что бьёт по 4 ГБ сервера. Поэтому взяты идеи, а не код:
// каркас /obj/vehicle из Paradise уже даёт пассажиров, флаги управления и
// целостность, многоклеточность вешаем через bound_*, турель — через
// click_intercept (та же машинерия, на которой работают спеллы).
//
// Габариты квадратные: bound_width/bound_height в BYOND не меняются местами при
// повороте, а прямоугольную технику TGMC держит отдельной системой хитбоксов.
//
// Многоклеточность: bound_* нельзя вешать прямо на подвижный объект — BYOND
// считает его габарит и при обычном шаге, из-за чего машина упирается в саму
// себя. Поэтому, как и в TGMC, габарит несёт отдельный невидимый хитбокс:
// он anchored, его только forceMove'ят следом за корпусом, и он пропускает
// сквозь себя свою же машину с экипажем.

/// Вся техника режима. Нужен, чтобы по бойцу найти машину, в которой он едет:
/// экипаж машины с отсеком физически стоит в резервном блоке, а не на карте боя,
/// и всё, что считает координаты (минимапа), обязано брать их с корпуса.
GLOBAL_LIST_EMPTY(mw_vehicles)

/// Сколько ждать замену подбитой машине.
#define MW_VEHICLE_RESPAWN (5 MINUTES)

/obj/vehicle/mw
	abstract_type = /obj/vehicle/mw
	icon = 'icons/mountain_wars/vehicle_lav.dmi'
	// Кадр задаёт каждая машина, здесь его нет и быть не может: тип абстрактный, а лист
	// у машин разный. Пустой, а не унаследованный: от /obj/vehicle достаётся "error",
	// которого в нашем листе нет, и юнит-тест missing_icons считает это потерянным
	// спрайтом. На null он такие типы пропускает — так же объявлен и вертолёт.
	icon_state = null
	layer = ABOVE_MOB_LAYER
	// Технику не сдвинуть руками — только водитель.
	move_resist = INFINITY
	// У многоклеточной техники loc — это центральная клетка, до неё нельзя встать
	// вплотную, поэтому штатная проверка примыкания у драг-энд-дропа не проходит.
	// Отключаем её и считаем дистанцию сами, от габарита.
	interaction_flags_atom = INTERACT_ATOM_MOUSEDROP_IGNORE_ADJACENT
	max_occupants = 8
	movedelay = 3
	/// Радиус корпуса поперёк движения, в тайлах от центральной клетки.
	/// 1 — корпус шириной три тайла.
	var/hull_radius = 1
	/// Сколько тайлов корпус добирает вперёд сверх hull_radius. Ноль — квадрат.
	///
	/// Чётную длину на нечётной сетке не отцентровать, поэтому лишний тайл достаётся
	/// носу: сзади hull_radius, спереди hull_radius + hull_nose. Нос длиннее кормы и
	/// у самой машины, и упирается в препятствия первым.
	var/hull_nose = 0
	/// Сколько занимает посадка.
	var/enter_delay = 2 SECONDS
	/// Урон при наезде на пехоту.
	var/ram_damage = 25
	/// Фракция-владелец: чужие внутрь не сядут.
	var/faction
	/// Чем стреляет турель.
	var/turret_projectile
	/// Задержка между выстрелами турели.
	var/turret_delay = 1 SECONDS
	var/turret_sound = 'sound/weapons/gunshots/1mg2.ogg'
	/// Турель даётся вместе с постом наводчика, без кнопки: сел за перископ — кликай
	/// по цели. Так это работает в TGMC и так это устроено у машины с башней, где
	/// наводчик всё равно ничего другого руками не делает. У технички наводчик стоит
	/// у пулемёта открыто и в кузове ему нужны руки, поэтому там остаётся кнопка.
	var/gunner_periscope = FALSE
	/// Кто из экипажа сейчас смотрит в приборы наблюдения.
	var/list/zoom_crew = list()
	/// Невидимый габарит, который таскается следом за корпусом.
	var/obj/mw_hitbox/hitbox
	/// Состояние вращающейся башни в том же .dmi. Пусто — башни нет, только пулемёт.
	var/turret_icon_state
	/// Куда смотрит башня. Своё направление, независимое от направления хода.
	var/turret_dir = SOUTH
	/// Куда башня доворачивает. Совпало с turret_dir — привод стоит.
	var/turret_goal = SOUTH
	/// Время на один шаг привода, 45 градусов. Разворот на 180 стоит четырёх шагов.
	var/turret_rotate_delay = 2 DECISECONDS
	/// Привод крутится прямо сейчас — второй таймер поверх первого не заводим.
	var/turret_rotating = FALSE
	/// Кадр башни, который сейчас стоит в собранном icon. См. build_turret_icon().
	var/turret_art_dir
	/// Сдвиг погона от центра кадра, своя пара x,y на каждое направление корпуса.
	/// Ключ — dir числом в тексте: list("[NORTH]" = list(0, 9), ...). Пусто — погон
	/// нарисован ровно в центре и доводить нечего. См. align_turret().
	var/list/turret_offset
	/// Когда по машине последний раз сработал взрыв — см. ex_act().
	var/last_ex_act = 0
	/// Ключ шаблона десантного отсека. Пусто — экипаж едет «в корпусе», без интерьера.
	var/interior_key
	/// Резервный блок с загруженным отсеком.
	var/datum/turf_reservation/interior
	/// Клетка отсека, на которую попадает десант.
	var/turf/interior_entry
	/// Петли двигателя: холостые и в движении. Тип при загрузке, датум после.
	var/datum/looping_sound/idle_loop
	var/datum/looping_sound/drive_loop
	/// То же для экипажа. Висят на клетке отсека — снаружи туда звук не доходит.
	var/datum/looping_sound/idle_loop_interior
	var/datum/looping_sound/drive_loop_interior
	/// Хлопок глушения двигателя снаружи и внутри.
	var/engine_off_sound
	var/engine_off_sound_interior
	/// Водитель на посту — двигатель заведён.
	var/engine_running = FALSE
	/// Машина катится прямо сейчас, а не стоит на холостых.
	var/engine_moving = FALSE
	COOLDOWN_DECLARE(turret_cooldown)
	COOLDOWN_DECLARE(message_cooldown)
	/// Откат дальнего эха выстрелов турели — см. ambience.dm.
	COOLDOWN_DECLARE(mw_distant_cooldown)
	/// Во сколько билетов подкреплений обходится потеря машины. Ноль — ни во сколько.
	/// Работает только у морпехов: у повстанцев билетов нет, им терять нечего.
	var/ticket_cost = 0
	/// Через сколько на месте появится замена. Ноль — машина невосполнима.
	var/respawn_delay = MW_VEHICLE_RESPAWN
	/// Клетка и направление, в которых машина стояла на карте. Туда вернётся замена.
	var/turf/home_turf
	var/home_dir

/obj/vehicle/mw/Initialize(mapload)
	. = ..()
	GLOB.mw_vehicles += src
	home_turf = get_turf(src)
	home_dir = dir
	if(hull_radius > 0)
		hitbox = new(loc, src)
	// Без своего glide_size техника не едет, а телепортируется потайлово: шаг
	// редкий (movedelay), а интерполяция по умолчанию рассчитана на шаг пехоты.
	// Ставится один раз: obj, шагающий сам себя, glide между шагами не сбрасывает.
	set_glide_size(DELAY_TO_GLIDE_SIZE(movedelay))
	if(ispath(idle_loop))
		idle_loop = new idle_loop(src)
	if(ispath(drive_loop))
		drive_loop = new drive_loop(src)
	build_turret_icon()

/obj/vehicle/mw/Destroy()
	GLOB.mw_vehicles -= src
	// Смещение живёт на клиенте: подбитая машина не должна оставить экипаж со
	// съехавшим экраном.
	// Копия списка: stop_crew_zoom вычёркивает из него по ходу.
	for(var/mob/crew as anything in zoom_crew.Copy())
		stop_crew_zoom(crew)
	QDEL_NULL(hitbox)
	if(isdatum(idle_loop))
		QDEL_NULL(idle_loop)
	if(isdatum(drive_loop))
		QDEL_NULL(drive_loop)
	if(isdatum(idle_loop_interior))
		QDEL_NULL(idle_loop_interior)
	if(isdatum(drive_loop_interior))
		QDEL_NULL(drive_loop_interior)
	interior_entry = null
	if(interior)
		interior.Release()
		interior = null
	return ..()

/obj/vehicle/mw/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	hitbox?.follow_root()

/obj/vehicle/mw/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/mw/exit)
	if(!gunner_periscope)
		initialize_controller_action_type(/datum/action/vehicle/mw/turret, VEHICLE_CONTROL_EQUIPMENT)
	// Приборы наблюдения — обоим постам. Десанту в отсеке смотреть некуда, у него
	// перед глазами обшивка.
	initialize_controller_action_type(/datum/action/vehicle/mw/zoom, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/mw/zoom, VEHICLE_CONTROL_EQUIPMENT)

// Первый севший — водитель, второй — наводчик, остальные десант.
/obj/vehicle/mw/auto_assign_occupant_flags(mob/M)
	// У машин с отсеком посты раздают кресла, а не очередь на посадку.
	if(interior_key)
		return
	if(driver_amount() < max_drivers)
		add_control_flags(M, VEHICLE_CONTROL_DRIVE)
		return
	if(turret_projectile && !return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT))
		add_control_flags(M, VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/mw/examine(mob/user)
	. = ..()
	. += span_notice("Экипаж: [occupant_amount()]/[max_occupants]. Перетащите себя на корпус, чтобы забраться внутрь.")

// MARK: Посадка и высадка
// Основной способ — перетащить себя на технику, как в мехи и как в TGMC.
/obj/vehicle/mw/mouse_drop_receive(atom/dropped, mob/user, params)
	if(dropped != user || !isliving(user))
		return
	if(!in_hull_range(user))
		balloon_alert(user, "слишком далеко!")
		return
	INVOKE_ASYNC(src, PROC_REF(mob_try_enter), user)

// Клик пустой рукой работает только у машин, к центру которых можно встать вплотную.
/obj/vehicle/mw/attack_hand(mob/user)
	. = ..()
	if(. || !isliving(user) || !in_hull_range(user))
		return
	INVOKE_ASYNC(src, PROC_REF(mob_try_enter), user)
	return TRUE

/// Стоит ли боец достаточно близко к корпусу, а не к его центральной клетке.
/// Считаем от следа: у длинной машины нос уходит от центра дальше, чем борт.
/obj/vehicle/mw/proc/in_hull_range(mob/user)
	if(!hull_radius)
		return Adjacent(user)
	var/turf/standing = get_turf(user)
	for(var/turf/covered as anything in hull_turfs(get_turf(src)))
		if(get_dist(standing, covered) <= 1)
			return TRUE
	return FALSE

/obj/vehicle/mw/proc/mob_try_enter(mob/living/user)
	if(is_occupant(user))
		return FALSE
	if(occupant_amount() >= max_occupants)
		balloon_alert(user, "мест нет!")
		return FALSE
	if(faction && mw_faction_of(user) != faction)
		balloon_alert(user, "чужая техника!")
		return FALSE
	balloon_alert(user, "забираетесь внутрь...")
	// Примыкание уже проверено по габариту — do_after не должен проверять его снова.
	if(!do_after(user, enter_delay, src, DA_IGNORE_TARGET_LOC_CHANGE | DA_IGNORE_USER_LOC_CHANGE))
		return FALSE
	if(!in_hull_range(user))
		return FALSE
	if(occupant_amount() >= max_occupants)
		return FALSE
	user.forceMove(get_interior_entry() || src)
	add_occupant(user)
	return TRUE

/obj/vehicle/mw/proc/mob_exit(mob/living/user)
	if(!is_occupant(user))
		return
	// Из кресла сначала отстёгиваем: иначе пост останется занятым, а глаз — на корпусе.
	user.buckled?.unbuckle_mob(user, force = TRUE)
	remove_occupant(user)
	user.forceMove(exit_turf())

/// Свободная клетка сразу за корпусом. Высаживать в центр нельзя — там габарит,
/// и боец оказывается запертым внутри собственной машины.
/obj/vehicle/mw/proc/exit_turf()
	var/turf/center = get_turf(src)
	if(!hull_radius)
		return center
	var/list/turf/occupied = hull_turfs(center)
	var/list/turf/candidates = list()
	for(var/turf/nearby as anything in RANGE_TURFS(hull_radius + hull_nose + 1, center))
		if(occupied[nearby])
			continue
		if(nearby.density || nearby.is_blocked_turf(exclude_mobs = TRUE))
			continue
		candidates += nearby
	if(!length(candidates))
		return center
	// Ближайшая по направлению взгляда, чтобы вылезать «сзади», а не куда попало.
	var/turf/behind = get_ranged_target_turf(center, REVERSE_DIR(dir), hull_radius + 1)
	if(behind in candidates)
		return behind
	return pick(candidates)

// MARK: Габарит
/obj/mw_hitbox
	name = "корпус"
	density = TRUE
	anchored = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = INDESTRUCTIBLE
	move_resist = INFINITY
	/// Машина, которой принадлежит габарит. Весь урон уходит ей.
	var/obj/vehicle/mw/root

/obj/mw_hitbox/Initialize(mapload, obj/vehicle/mw/new_root)
	. = ..()
	root = new_root
	// Без refresh: объект ещё создаётся, переставлять его некуда и незачем.
	align(root?.dir || SOUTH, refresh = FALSE)

/// Раскладывает габарит по текущему направлению корпуса.
///
/// bound_* в BYOND при повороте местами не меняются — объект как был широким, так и
/// остаётся. Поэтому прямоугольный габарит приходится пересобирать на каждый разворот
/// руками. Ровно из-за этого вся остальная техника тут квадратная: ей пересборка не
/// нужна. Нам нужна, потому что ЛАВ вчетверо длиннее, чем шире.
/obj/mw_hitbox/proc/align(facing, refresh = TRUE)
	if(QDELETED(root))
		return
	var/radius = root.hull_radius
	var/nose = root.hull_nose
	var/across = (radius * 2 + 1) * ICON_SIZE_X
	var/along = (radius * 2 + 1 + nose) * ICON_SIZE_X
	// Начало габарита — левый нижний угол, отсчитывается от клетки корпуса. С той
	// стороны, куда смотрит нос, отступ меньше: туда уходит лишний тайл.
	switch(facing)
		if(NORTH)
			bound_x = -(radius * ICON_SIZE_X)
			bound_y = -(radius * ICON_SIZE_Y)
			bound_width = across
			bound_height = along
		if(SOUTH)
			bound_x = -(radius * ICON_SIZE_X)
			bound_y = -((radius + nose) * ICON_SIZE_Y)
			bound_width = across
			bound_height = along
		if(EAST)
			bound_x = -(radius * ICON_SIZE_X)
			bound_y = -(radius * ICON_SIZE_Y)
			bound_width = along
			bound_height = across
		else  // WEST и всё, что не кардинальное
			bound_x = -((radius + nose) * ICON_SIZE_X)
			bound_y = -(radius * ICON_SIZE_Y)
			bound_width = along
			bound_height = across
	// Габарит с новыми bound_* надо переставить, иначе BYOND держит старую занятость.
	if(refresh && loc)
		forceMove(loc)

/obj/mw_hitbox/Destroy()
	root = null
	return ..()

/// Своя машина, её экипаж и её же снаряды проходят сквозь габарит — иначе корпус
/// блокирует сам себя.
/obj/mw_hitbox/CanAllowThrough(atom/movable/mover, border_dir)
	if(mover == root || (root && root.is_occupant(mover)))
		return TRUE
	if(root?.is_own_projectile(mover))
		return TRUE
	return ..()

/// Габарит только forceMove'ят: обычное движение объекта с нестандартными
/// bound_* в BYOND ломается.
/obj/mw_hitbox/proc/follow_root()
	if(QDELETED(root))
		return
	forceMove(root.loc)
	root.crush_footprint()

// Урон по габариту — это урон по машине.
/obj/mw_hitbox/bullet_act(obj/projectile/P)
	return root ? root.bullet_act(P) : ..()

// Габарит INDESTRUCTIBLE, поэтому /obj/ex_act на нём выходит сразу. Без трансляции
// ракета детонировала на борту, а урон получала только центральная клетка — в неё
// взрыв часто уже не доставал, и техника переживала прямое попадание.
/obj/mw_hitbox/ex_act(severity, target)
	return root ? root.ex_act(severity, target) : ..()

/obj/mw_hitbox/attackby(obj/item/I, mob/user, params)
	return root ? root.attackby(I, user, params) : ..()

/// Габарит переносится forceMove, поэтому пехоту под корпусом давим вручную.
/obj/vehicle/mw/proc/crush_footprint()
	if(!ram_damage)
		return
	for(var/turf/covered as anything in hull_turfs(get_turf(src)))
		for(var/mob/living/victim in covered)
			if(is_occupant(victim))
				continue
			victim.visible_message(span_userdanger("[src] проезжает по [victim.declent_ru(DATIVE)]!"))
			victim.apply_damage(ram_damage, BRUTE)
			victim.Weaken(3 SECONDS)
			playsound(src, 'sound/effects/bang.ogg', 70, TRUE)

// Сопротивление изнутри тоже высаживает — на случай, если кнопка потерялась.
/obj/vehicle/mw/container_resist_act(mob/living/user)
	mob_exit(user)

/obj/vehicle/mw/after_remove_occupant(mob/M)
	if(M.loc == src)
		M.forceMove(get_turf(src))

// MARK: Движение
/obj/vehicle/mw/relaymove(mob/living/user, direction)
	if(!canmove)
		return FALSE
	if(!is_driver(user))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, 3 SECONDS)
			to_chat(user, span_warning("Вы не за рулём — место водителя занято."))
		return FALSE
	if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return FALSE
	COOLDOWN_START(src, cooldown_vehicle_move, movedelay)
	// Двигатель ревёт и когда машина упёрлась в стену, поэтому до шага.
	engine_drive()
	setDir(direction)
	if(!hull_fits(get_step(src, direction)))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, 3 SECONDS)
			to_chat(user, span_warning("Корпус не проходит — с этой стороны не проехать."))
		return FALSE
	. = step(src, direction)
	if(!. && COOLDOWN_FINISHED(src, message_cooldown))
		COOLDOWN_START(src, message_cooldown, 3 SECONDS)
		to_chat(user, span_warning("Корпус упирается — с этой стороны не проехать."))

/// Влезет ли корпус целиком, если центр встанет на destination.
///
/// step() проверяет только клетку самого корпуса: габарит несёт хитбокс, а его
/// переставляют forceMove'ом уже после шага, без проверок. Из-за этого машина 3x3
/// заезжала в проход шириной в тайл — стены оказывались «внутри» корпуса.
/// Проверяем сами передний край: клетки, которые корпус займёт и которые ещё не
/// заняты им сейчас. Пехоту в расчёт не берём — её давят, а не объезжают.
/obj/vehicle/mw/proc/hull_fits(turf/destination)
	if(!destination)
		return FALSE
	if(!hull_radius)
		return TRUE
	// Направление уже выставлено setDir'ом до шага, так что новый след считаем по нему.
	var/list/turf/occupied = hull_turfs(get_turf(src))
	for(var/turf/ahead as anything in hull_turfs(destination))
		if(occupied[ahead])
			continue
		if(ahead.is_blocked_turf(exclude_mobs = TRUE, ignore_atoms = list(src, hitbox)))
			return FALSE
	return TRUE

/obj/vehicle/mw/Bump(atom/bumped)
	. = ..()
	if(!isliving(bumped) || !ram_damage)
		return
	var/mob/living/victim = bumped
	if(is_occupant(victim))
		return
	victim.visible_message(span_userdanger("[src] сбива[PLUR_ET_YUT(src)] [victim.declent_ru(ACCUSATIVE)]!"))
	victim.apply_damage(ram_damage, BRUTE)
	victim.Weaken(3 SECONDS)
	playsound(src, 'sound/effects/bang.ogg', 70, TRUE)

// MARK: Двигатель
// Заводится, когда кто-то сел за руль, и глохнет, когда последний водитель встал.
/obj/vehicle/mw/grant_controller_actions_by_flag(mob/M, flag)
	. = ..()
	if(!.)
		return
	if(flag & VEHICLE_CONTROL_DRIVE)
		start_engine()
	if(gunner_periscope && (flag & VEHICLE_CONTROL_EQUIPMENT))
		grab_turret(M)

/obj/vehicle/mw/remove_controller_actions_by_flag(mob/M, flag)
	. = ..()
	if(!.)
		return
	// Флаг снимают до вызова, так что уходящий водитель здесь уже не считается.
	if((flag & VEHICLE_CONTROL_DRIVE) && !return_amount_of_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		stop_engine()
	if(flag & VEHICLE_CONTROL_EQUIPMENT)
		release_turret(M)
	// Встал с поста — смотрит своими глазами, а не через приборы.
	stop_crew_zoom(M)

// MARK: Перископ наводчика
// Место наводчика само по себе и есть управление турелью: перехват кликов вешается
// на посадку в кресло и снимается, когда наводчик встал. Кнопки нет.
/obj/vehicle/mw/proc/grab_turret(mob/gunner)
	if(!gunner)
		return
	// Перезаход стирает клиенту перехват вместе со старым клиентом, а кнопки, чтобы
	// взяться заново, у этих машин нет. Поэтому ловим возвращение в тело — и ловим
	// до проверки на клиент: сесть за пост тело могло и без него.
	RegisterSignal(gunner, COMSIG_MOB_LOGIN, PROC_REF(on_gunner_login), TRUE)
	if(!gunner.client)
		return
	if(istype(gunner.client.click_intercept, /datum/click_intercept/mw_turret))
		return
	new /datum/click_intercept/mw_turret(gunner.client, src)
	to_chat(gunner, span_notice("Вы у перископа наводчика. Кликайте по цели — башня довернёт и ударит."))

/obj/vehicle/mw/proc/release_turret(mob/gunner)
	if(!gunner)
		return
	UnregisterSignal(gunner, COMSIG_MOB_LOGIN)
	var/datum/click_intercept/mw_turret/grip = gunner.client?.click_intercept
	// Чужой перехват не трогаем: у наводчика в руках мог оказаться свой.
	if(istype(grip) && grip.vehicle == src)
		qdel(grip)

/obj/vehicle/mw/proc/on_gunner_login(mob/gunner)
	SIGNAL_HANDLER
	if(LAZYACCESS(occupants, gunner) & VEHICLE_CONTROL_EQUIPMENT)
		grab_turret(gunner)

// MARK: Приборы наблюдения
// Экран экипажа уходит вперёд по корпусу. Не по башне: она доворачивает сама, по
// 45 градусов за шаг, и обзор мотало бы вслед за приводом.
/// На сколько клеток вперёд. Вдвое больше, чем даёт прицел стрелку: у машины на это
/// есть оптика, а бьёт её турель дальше винтовки.
#define MW_VEHICLE_ZOOM 4

/obj/vehicle/mw/proc/toggle_crew_zoom(mob/crew)
	// Состояние читаем с самого клиента, а не из списка: после перезахода клиент
	// новый и смещения на нём нет, а в списке боец ещё числится.
	var/client/view = crew?.client
	if(!view)
		return
	if(view.pixel_x || view.pixel_y)
		stop_crew_zoom(crew)
		return
	zoom_crew |= crew
	// Умер в кресле — ушёл в наблюдатели вместе со своим клиентом, а смещение живёт
	// на клиенте и уехало бы с ним.
	RegisterSignal(crew, COMSIG_MOB_DEATH, PROC_REF(on_zoom_crew_death), TRUE)
	apply_crew_zoom(crew, TRUE)

/obj/vehicle/mw/proc/stop_crew_zoom(mob/crew)
	// Не наш смещённый экран не трогаем: у бойца в кресле мог быть сведён прицел.
	if(!(crew in zoom_crew))
		return
	zoom_crew -= crew
	UnregisterSignal(crew, COMSIG_MOB_DEATH)
	apply_crew_zoom(crew, FALSE)

/obj/vehicle/mw/proc/on_zoom_crew_death(mob/crew)
	SIGNAL_HANDLER
	stop_crew_zoom(crew)

/obj/vehicle/mw/proc/apply_crew_zoom(mob/crew, looking)
	var/client/view = crew?.client
	if(!view)
		return
	var/shift_x = 0
	var/shift_y = 0
	if(looking)
		// Смотрим туда, куда наведена башня, а не куда стоит корпус. Зум — это оптика
		// наводчика (сам действие выдаётся только при gunner_periscope), и обзор должен
		// ехать за прицелом: иначе башня развёрнута вбок, а экипаж видит перед носом.
		// У машины без башни turret_dir остаётся на своём SOUTH, поэтому берём корпус.
		var/looking_dir = turret_icon_state ? turret_dir : dir
		// По битам, а не switch по четырём сторонам: и корпус, и башня ходят по
		// диагоналям, а на них штатный проц оружия даёт ноль.
		if(looking_dir & NORTH)
			shift_y = MW_VEHICLE_ZOOM
		else if(looking_dir & SOUTH)
			shift_y = -MW_VEHICLE_ZOOM
		if(looking_dir & EAST)
			shift_x = MW_VEHICLE_ZOOM
		else if(looking_dir & WEST)
			shift_x = -MW_VEHICLE_ZOOM
	view.pixel_x = ICON_SIZE_X * shift_x
	view.pixel_y = ICON_SIZE_Y * shift_y

/// Развернулись — обзор переезжает следом. Иначе после первого поворота экипаж
/// смотрел бы себе в корму.
/obj/vehicle/mw/proc/refresh_crew_zoom()
	for(var/mob/crew as anything in zoom_crew)
		apply_crew_zoom(crew, TRUE)

/// Петли отсека рождаются вместе с самим отсеком: до первой посадки его ещё нет.
/obj/vehicle/mw/proc/setup_interior_loops()
	if(!interior_entry)
		return
	if(ispath(idle_loop_interior))
		idle_loop_interior = new idle_loop_interior(interior_entry)
	if(ispath(drive_loop_interior))
		drive_loop_interior = new drive_loop_interior(interior_entry)

/obj/vehicle/mw/proc/start_engine()
	if(engine_running)
		return
	engine_running = TRUE
	setup_interior_loops()
	idle_loop?.start()
	idle_loop_interior?.start()

/obj/vehicle/mw/proc/stop_engine()
	engine_running = FALSE
	engine_moving = FALSE
	idle_loop?.stop()
	drive_loop?.stop()
	idle_loop_interior?.stop()
	drive_loop_interior?.stop()
	if(engine_off_sound)
		playsound(src, engine_off_sound, 40)
	if(engine_off_sound_interior && interior_entry)
		playsound(interior_entry, engine_off_sound_interior, 40)

/// Водитель дал ход. Обратно на холостые машина вернётся сама, если пропустит
/// несколько тактов хода подряд — отдельного «стоп» водитель не жмёт.
/obj/vehicle/mw/proc/engine_drive()
	if(!engine_moving)
		engine_moving = TRUE
		idle_loop?.stop()
		idle_loop_interior?.stop()
		drive_loop?.start()
		drive_loop_interior?.start()
	addtimer(CALLBACK(src, PROC_REF(engine_idle)), movedelay * 3, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/vehicle/mw/proc/engine_idle()
	if(!engine_moving)
		return
	engine_moving = FALSE
	drive_loop?.stop()
	drive_loop_interior?.stop()
	if(!engine_running)
		return
	idle_loop?.start()
	idle_loop_interior?.start()

// Сэмплы двигателя из TGMC (sound/vehicles/looping, CC BY-NC-SA 3.0). Внутренние
// петли у них играют каждому члену экипажа напрямую; здесь одна петля висит на
// клетке отсека и слышна всем внутри — отсек размером с комнату.
/datum/looping_sound/mw_apc_idle
	mid_sounds = list(
		'sound/mountain_wars/tank_eng_idle_1.ogg' = 1,
		'sound/mountain_wars/tank_eng_idle_2.ogg' = 1,
		'sound/mountain_wars/tank_eng_idle_3.ogg' = 1,
		'sound/mountain_wars/tank_eng_idle_4.ogg' = 1,
	)
	mid_length = 2 SECONDS
	start_sound = 'sound/mountain_wars/tank_eng_start.ogg'
	start_length = 1.2 SECONDS
	volume = 50

/datum/looping_sound/mw_apc_drive
	mid_sounds = list(
		'sound/mountain_wars/engine_rev_1.ogg' = 1,
		'sound/mountain_wars/engine_rev_2.ogg' = 1,
	)
	mid_length = 2 SECONDS
	vary = TRUE
	volume = 50

/datum/looping_sound/mw_apc_idle_interior
	mid_sounds = list(
		'sound/mountain_wars/tank_eng_interior_idle_1.ogg' = 2,
		'sound/mountain_wars/tank_eng_interior_idle_2.ogg' = 1,
	)
	mid_length = 2 SECONDS
	start_sound = 'sound/mountain_wars/tank_eng_interior_start.ogg'
	start_volume = 20
	start_length = 2.5 SECONDS
	volume = 25

/datum/looping_sound/mw_apc_drive_interior
	mid_sounds = list(
		'sound/mountain_wars/tank_eng_interior_loop_1.ogg' = 1,
		'sound/mountain_wars/tank_eng_interior_loop_2.ogg' = 1,
		'sound/mountain_wars/tank_eng_interior_loop_3.ogg' = 1,
	)
	mid_length = 2 SECONDS
	volume = 30

// У технички холостых нет: это пикап, на стоянке он просто заглушён.
/datum/looping_sound/mw_technical_drive
	mid_sounds = list('sound/mountain_wars/carrev.ogg' = 1)
	mid_length = 2 SECONDS
	vary = TRUE
	volume = 45

// MARK: Башня
// Разворот корпуса башню не пересобирает: собранный icon держит все четыре кадра.
/obj/vehicle/mw/setDir(newdir)
	. = ..()
	hitbox?.align(dir)
	refresh_crew_zoom()

/// Задаёт башне цель. Корпус не трогает, мгновенно не поворачивает: привод отработает
/// её сам, по 45 градусов за шаг.
/obj/vehicle/mw/proc/aim_turret(newdir)
	if(!turret_icon_state || !newdir)
		return
	turret_goal = newdir
	// Наводчик водит курсором постоянно, и цель меняется чаще, чем идёт шаг привода.
	// Поэтому таймер заводится один раз на весь разворот, а новую цель уже крутящийся
	// привод подхватывает на следующем шаге.
	if(turret_rotating || turret_dir == turret_goal)
		return
	turret_rotating = TRUE
	addtimer(CALLBACK(src, PROC_REF(rotate_turret)), turret_rotate_delay)

/// Один шаг привода в сторону цели, кратчайшей дугой.
/obj/vehicle/mw/proc/rotate_turret()
	if(turret_dir == turret_goal)
		turret_rotating = FALSE
		return
	// Разница углов по часовой стрелке. Больше полуоборота — короче идти против неё.
	//
	// Приводить её к кругу через SIMPLIFY_DEGREES нельзя: тот считает через %%, а он
	// оставляет знак делимого, и -45 остаётся -45 вместо 315. С отрицательной разницей
	// привод уходил в обратную сторону, промахивался мимо цели и вечно мотался между
	// двумя соседними направлениями. Поэтому доводим до круга сложением: углы тут
	// не больше 315, так что +720 хватает с запасом на любой знак.
	var/delta = (dir2angle(turret_goal) - dir2angle(turret_dir) + 720) % 360
	turret_dir = angle2dir(dir2angle(turret_dir) + (delta > 180 ? -45 : 45))
	build_turret_icon()
	// Обзор едет за башней тем же шагом, что и сама башня.
	refresh_crew_zoom()
	if(turret_dir == turret_goal)
		turret_rotating = FALSE
		return
	addtimer(CALLBACK(src, PROC_REF(rotate_turret)), turret_rotate_delay)

/// Клетки, которые займёт корпус, если его центр встанет на where и он будет смотреть
/// в facing. Считаем по осям машины, а не кругом: длина и ширина у неё разные.
///
/// Список ассоциативный, турф -> TRUE. Половина вызывающих спрашивает не «перечисли
/// клетки», а «эта клетка наша?» — у ЛАВ след в двадцать одну клетку, и на каждом шаге
/// такой вопрос задаётся по разу на клетку нового следа. По ключам это обращение по
/// хэшу вместо перебора. Перечислению ключи не мешают: for по такому списку идёт по ним.
/obj/vehicle/mw/proc/hull_turfs(turf/where, facing = dir)
	. = list()
	if(!where || !hull_radius)
		return
	// Единичный вектор «вперёд» и перпендикулярный ему «вбок».
	var/forward_x = 0
	var/forward_y = 0
	switch(facing)
		if(NORTH)
			forward_y = 1
		if(SOUTH)
			forward_y = -1
		if(EAST)
			forward_x = 1
		else
			forward_x = -1
	var/side_x = forward_y ? 1 : 0
	var/side_y = forward_x ? 1 : 0
	for(var/along = -hull_radius to hull_radius + hull_nose)
		for(var/across = -hull_radius to hull_radius)
			var/turf/covered = locate(
				where.x + forward_x * along + side_x * across,
				where.y + forward_y * along + side_y * across,
				where.z,
			)
			if(covered)
				.[covered] = TRUE

/// Собирает кадр «корпус плюс башня» и ставит его машине как icon.
///
/// Башня — не отдельный спрайт. Ни объектом в vis_contents, ни оверлеем её поверх
/// корпуса удержать не вышло: кадр машины 224x224 накрывает семь клеток, и башня
/// уходила под него даже с явным слоем выше. Свой dir у оверлея тоже не отработал —
/// башня не поворачивалась. Поэтому обе картинки сплавляются в один спрайт: у него
/// нет ни слоя относительно корпуса, ни своего направления, спорить нечему.
///
/// Кадры собираются на все четыре направления корпуса разом, поэтому разворот
/// машины пересборки не требует — нужный кадр движок берёт сам по dir. Пересобирать
/// приходится только на поворот башни, и результат кэшируется: направлений четыре,
/// значит и сборок за раунд четыре на тип машины.
///
/// Погон нарисован не в середине корпуса, а ближе к носу, и в профиль ещё и выше
/// середины кадра. Центровать кадры корпуса по нему нельзя: тогда на длинную корму
/// остаётся меньше половины кадра, и она из него вылезает — либо кадр приходится
/// растить, либо машину мельчить. Поэтому кадры центрованы по самой машине, а
/// разницу добирает сдвиг башни, свой на каждое направление корпуса.
/obj/vehicle/mw/proc/build_turret_icon()
	if(!turret_icon_state)
		return
	var/static/list/cache = list()
	// Кадров у башни четыре, а направлений привода восемь — на диагонали берём
	// ближайший кардинальный кадр, как это делает и сам движок для четырёхкадровых
	// стейтов.
	var/art_dir = angle2dir_cardinal(dir2angle(turret_dir))
	// Привод идёт по 45 градусов, а кадров у башни четыре: на диагональном шаге кадр
	// остаётся прежним. Выходим до записи в icon — присвоение внешности рассылается
	// всем, кто машину видит, и делать это ради того же самого кадра незачем.
	if(art_dir == turret_art_dir)
		return
	turret_art_dir = art_dir
	var/key = "[type]-[art_dir]"
	var/icon/composed = cache[key]
	if(!composed)
		composed = new /icon()
		for(var/hull_dir in GLOB.cardinal)
			// initial(): icon у машины уже подменён собранным кадром, исходник только здесь.
			var/icon/frame = icon(initial(icon), icon_state, hull_dir)
			var/icon/gun = icon(initial(icon), turret_icon_state, art_dir)
			var/list/offset = LAZYACCESS(turret_offset, "[hull_dir]")
			if(offset)
				gun.Shift(offset[1] >= 0 ? EAST : WEST, abs(offset[1]))
				gun.Shift(offset[2] >= 0 ? NORTH : SOUTH, abs(offset[2]))
			frame.Blend(gun, ICON_OVERLAY)
			composed.Insert(new_icon = frame, icon_state = icon_state, dir = hull_dir)
		cache[key] = composed
	icon = composed

// MARK: Турель
/obj/vehicle/mw/proc/fire_turret(atom/target, mob/living/gunner, params)
	if(!turret_projectile || QDELETED(target))
		return
	if(target == src || target == hitbox)
		target = turf_under_click(params)
	if(!target || target == get_turf(src))
		return
	// Ствол доворачивается и на перезарядке: наводчик видит, куда смотрит башня.
	var/aim = get_dir(src, target)
	aim_turret(aim)
	// Стреляем только тем, куда башня уже смотрит. Иначе привод не значит ничего:
	// наводчик бил бы за спину, пока ствол ещё идёт туда.
	if(turret_icon_state && turret_dir != aim)
		return
	if(!COOLDOWN_FINISHED(src, turret_cooldown))
		return
	COOLDOWN_START(src, turret_cooldown, turret_delay)
	// Корпус на выстрел не разворачиваем: dir машины — это направление хода, на нём
	// висят и спрайт, и выбор клетки для высадки. Разворот на цель их ломал бы.
	playsound(src, turret_sound, 90, TRUE)
	// Отдельно — внутрь отсека. Экипаж машины с отсеком физически стоит в резервном
	// блоке, а playsound рассылает звук по клеткам вокруг корпуса: наводчик не слышал
	// собственного выстрела вовсе. Тише, чем снаружи: между ним и стволом броня.
	if(interior_entry)
		playsound(interior_entry, turret_sound, 60, TRUE)
	// За пределами слышимости самого выстрела уходит глухой удар вдали.
	mw_distant_turret_shot(src, src)
	// Стреляем снарядом напрямую, минуя ammo_casing.fire(): тот берёт стартовую клетку
	// у стрелка, а наводчик сидит в отсеке на резервном z-уровне — очередь уходила бы
	// в стену десантного отсека. Точка отсчёта здесь всегда клетка корпуса.
	var/turf/origin = get_turf(src)
	var/obj/projectile/shot = new turret_projectile(origin)
	shot.firer = gunner
	shot.firer_source_atom = src
	shot.def_zone = ran_zone()
	shot.preparePixelProjectile(target, origin)
	shot.fire()

/// Клетка под курсором, когда кликнули по собственному корпусу. Спрайт занимает
/// 3x3 клетки экрана, поэтому без пересчёта наводчик не может стрелять по тем, кто
/// стоит вплотную: клик уходит в машину, а не в цель за ней.
/obj/vehicle/mw/proc/turf_under_click(params)
	var/turf/origin = get_turf(src)
	if(!origin || !params)
		return null
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	if(isnull(icon_x) || isnull(icon_y))
		return null
	// icon-x отсчитывается от левого нижнего угла спрайта, а тот сдвинут на pixel_x.
	var/offset_x = FLOOR((pixel_x + icon_x - 1) / ICON_SIZE_X, 1)
	var/offset_y = FLOOR((pixel_y + icon_y - 1) / ICON_SIZE_Y, 1)
	return locate(origin.x + offset_x, origin.y + offset_y, origin.z)

/// Снаряд собственной турели. Стартует он с клетки стрелка, а тот сидит в центре
/// корпуса, так что без этого турель расстреливает свою же машину.
/obj/vehicle/mw/proc/is_own_projectile(atom/movable/mover)
	if(!isprojectile(mover))
		return FALSE
	var/obj/projectile/proj = mover
	return proj.firer_source_atom == src || is_occupant(proj.firer)

// Пропускаем свой снаряд ещё на входе. Гасить его в bullet_act нельзя: при возврате
// -1 снаряд получает `loc = bumped_turf`, а у габарита loc — центральная клетка,
// то есть снаряд телепортировало бы обратно в машину на каждом шаге.
/obj/vehicle/mw/CanAllowThrough(atom/movable/mover, border_dir)
	if(is_own_projectile(mover))
		return TRUE
	return ..()

// Прямой клик по своей же машине идёт мимо полёта — там снаряд бьёт цель сразу.
/obj/vehicle/mw/bullet_act(obj/projectile/P)
	if(is_own_projectile(P))
		return -1
	return ..()

/// Сколько попаданий гранатомёта в упор держит корпус.
#define MW_VEHICLE_ROCKET_HITS 3

/// Взрыв накрывает и центральную клетку корпуса, и его габарит, так что от одного
/// попадания приходит несколько вызовов. Считаем только первый за тик.
///
/// Считаем свой урон, а не зовём /obj/ex_act. Штатный на EXPLODE_DEVASTATE бьёт
/// INFINITY, а девастация начинается у любой ракеты HE: одно попадание из РПГ
/// разбирало БТР целиком, сколько брони ему ни дай. На EXPLODE_HEAVY там rand(100, 250),
/// то есть время до уничтожения гуляет вдвое от броска кубика.
///
/// Отсюда доля от запаса прочности: тяжёлый взрыв снимает треть, и корпус выдерживает
/// ровно три ракеты независимо от того, чем в него бьют.
///
/// Броню не применяем (damage_flag не передаём): вся суть в предсказуемом числе
/// попаданий, а BOMB в списке брони сдвигал бы его у каждой машины по-своему. Эта же
/// строка брони по-прежнему работает на пехоте в отсеке и на осколках.
/obj/vehicle/mw/ex_act(severity, target)
	if(world.time == last_ex_act)
		return
	last_ex_act = world.time
	var/share = max_integrity / MW_VEHICLE_ROCKET_HITS
	switch(severity)
		if(EXPLODE_DEVASTATE, EXPLODE_HEAVY)
			take_damage(share, BRUTE, sound_effect = FALSE)
		if(EXPLODE_LIGHT)
			take_damage(share * 0.2, BRUTE, sound_effect = FALSE)

// MARK: Ремонт сваркой
// Подбитую машину чинят в поле, но это работа, а не нажатие кнопки: за один проход
// заваривается двадцатая часть корпуса, и стоит проход шести секунд и двух единиц
// топлива. Полное восстановление с нуля — двадцать проходов, две минуты под огнём и
// ровно один полный бак промышленного аппарата. Долю берём от запаса прочности, а не
// фиксированным числом: иначе БТР на тысяче чинился бы вчетверо дольше технички.
//
// Штатный default_welder_repair не годится — он чинит корпус целиком за один заход
// длиной в пять секунд и не тратит ничего.
#define MW_VEHICLE_REPAIR_SHARE 0.05
#define MW_VEHICLE_REPAIR_TIME (6 SECONDS)
#define MW_VEHICLE_REPAIR_FUEL 2

/obj/vehicle/mw/attackby(obj/item/tool, mob/user, params)
	if(tool.tool_behaviour != TOOL_WELDER)
		return ..()
	if(obj_integrity >= max_integrity)
		balloon_alert(user, "корпус цел")
		return ATTACK_CHAIN_BLOCKED_ALL
	// Цикл, а не один проход: держать нажатой мышь двадцать раз подряд — не игра.
	// Каждый виток проверяет топливо и целость заново, так что прерывание, пустой бак
	// и добитая по дороге машина выводят из него сами.
	while(obj_integrity < max_integrity)
		if(!tool.tool_use_check(user, MW_VEHICLE_REPAIR_FUEL))
			return ATTACK_CHAIN_BLOCKED_ALL
		balloon_alert(user, "завариваем...")
		if(!tool.use_tool(src, user, MW_VEHICLE_REPAIR_TIME, MW_VEHICLE_REPAIR_FUEL, tool.tool_volume))
			return ATTACK_CHAIN_BLOCKED_ALL
		if(QDELETED(src))
			return ATTACK_CHAIN_BLOCKED_ALL
		update_integrity(min(obj_integrity + max_integrity * MW_VEHICLE_REPAIR_SHARE, max_integrity))
	balloon_alert(user, "корпус восстановлен")
	return ATTACK_CHAIN_BLOCKED_ALL

#undef MW_VEHICLE_REPAIR_SHARE
#undef MW_VEHICLE_REPAIR_TIME
#undef MW_VEHICLE_REPAIR_FUEL

// MARK: Уничтожение
/obj/vehicle/mw/obj_destruction(damage_flag)
	var/turf/wreck_turf = get_turf(src)
	visible_message(span_boldwarning("[src] охватывает пламя, машина детонирует!"))
	// Копия списка: remove_occupant правит occupants прямо во время обхода. Копия
	// ленивая, потому что тот же remove_occupant зануляет список, когда тот пустеет:
	// на .Copy() пустой машины проц падал прямо здесь, до ..(), и техника от этого
	// не умирала вовсе — сколько в неё ни стреляй.
	for(var/mob/living/passenger in LAZYCOPY(occupants))
		passenger.buckled?.unbuckle_mob(passenger, force = TRUE)
		remove_occupant(passenger)
		passenger.forceMove(wreck_turf)
		passenger.apply_damage(40, BRUTE)
	explosion(wreck_turf, heavy_impact_range = 1, light_impact_range = 3, cause = "уничтожение техники")
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(istype(mode))
		if(ticket_cost)
			mode.lose_tickets(ticket_cost)
			mode.message_faction(faction, span_boldwarning("[name] потерян[GEND_A_O_Y(src)]. Списано билетов подкреплений: [ticket_cost]."))
		if(respawn_delay && home_turf)
			mode.message_faction(faction, span_boldnotice("Замена придёт через [respawn_delay / 600] мин."))
	// Тип, клетка и направление уходят в таймер значениями: к моменту срабатывания
	// самой машины уже нет, и ссылаться на неё не на что.
	if(respawn_delay && home_turf)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(mw_respawn_vehicle), type, home_turf, home_dir, faction), respawn_delay)
	return ..()

/// Ставит на место уничтоженную машину. Клетку не проверяем: точка выхода стоит в
/// глубине базы, а отменять пополнение из-за брошенного поперёк ящика — хуже, чем
/// разложить корпус поверх него.
/proc/mw_respawn_vehicle(vehicle_type, turf/where, facing, faction)
	if(!ispath(vehicle_type, /obj/vehicle/mw) || !where)
		return
	var/obj/vehicle/mw/replacement = new vehicle_type(where)
	replacement.setDir(facing || SOUTH)
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(istype(mode))
		mode.message_faction(faction, span_boldnotice("[replacement.name] снова на ходу и ждёт экипаж на точке выхода."))

// MARK: M113 (морпехи)
// Башни нет — только 12,7-мм Browning в люке, поэтому вращающийся оверлей не нужен.
/obj/vehicle/mw/m113
	name = "M113"
	interior_key = LAZY_TEMPLATE_KEY_MW_APC_INTERIOR
	desc = "Старый гусеничный бронетранспортёр. Башни нет, только крупнокалиберный пулемёт в люке командира. Возит восемь человек и держит пулю."
	icon_state = "apc"
	// Спрайт из TGMC нарисован в кадре 126x126 под смещения — берём их как есть.
	pixel_x = -48
	pixel_y = -40
	max_integrity = 1000
	// Пули корпус почти не берут, взрывчатка — берёт. Гранатомёт остаётся ответом на технику.
	//
	// Пулестойкость выше сотни намеренно: она гасится пробитием снаряда, а из брони
	// вычитается только разница. 114 против пробития 90 у автопушки оставляет те же
	// 25 процентов среза, что раньше давал темп стрельбы — см. блок боеприпасов.
	armor = list(MELEE = 70, BULLET = 114, LASER = 80, ENERGY = 70, BOMB = 20, BIO = 100, FIRE = 60, ACID = 60)
	ram_damage = 40
	ticket_cost = 5
	faction = JOB_TITLE_MW_MARINE
	turret_projectile = /obj/projectile/bullet/mw_kpvt
	turret_delay = 0.8 SECONDS
	gunner_periscope = TRUE
	idle_loop = /datum/looping_sound/mw_apc_idle
	drive_loop = /datum/looping_sound/mw_apc_drive
	idle_loop_interior = /datum/looping_sound/mw_apc_idle_interior
	drive_loop_interior = /datum/looping_sound/mw_apc_drive_interior
	engine_off_sound = 'sound/mountain_wars/tank_eng_stop.ogg'
	engine_off_sound_interior = 'sound/mountain_wars/tank_eng_interior_stop.ogg'

// MARK: Technical (повстанцы)
/obj/vehicle/mw/technical
	name = "Technical"
	desc = "Пикап с приваренным в кузове КПВТ. Кустарные листы держат стрелковку, но не крупный калибр и не взрыв. Вдвое быстрее любой бронемашины."
	icon = 'icons/mountain_wars/vehicle_technical.dmi'
	icon_state = "land_rover_machinegun"
	// Кадры в .dmi пересобраны так, что машина стоит в центре каждого из четырёх
	// направлений. Кадр 128x128 на клетке 32x32 центрируется сдвигом (128 - 32) / 2.
	pixel_x = -48
	pixel_y = -48
	// 265, а не 200: у технички брони нет, гасить возросший урон калибров нечем, и
	// поправка ушла в запас прочности. Иначе пришлось бы дать пикапу пулестойкость
	// уровня БТРа — то есть ровно то, чего у него по определению нет.
	max_integrity = 265
	// Пулестойкость 82 — это про стрелковку, и только про неё. Считается разница
	// «броня минус пробитие», а у башенных калибров пробитие 85 и 90: всё, что ниже
	// 85, они не замечают вовсе. Поэтому здесь броню можно крутить свободно, не
	// трогая время до уничтожения между машинами — его держит запас прочности.
	// Винтовке при этом нужно порядка сорока попаданий вместо восьми.
	// Взрыв корпус не держит по-прежнему: гранатомёт остаётся ответом на технику.
	armor = list(MELEE = 20, BULLET = 82, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 100, FIRE = 20, ACID = 20)
	max_occupants = 4
	movedelay = 1.5
	// Билетов у повстанцев нет, снимать нечего: техничка стоит только времени на замену.
	faction = JOB_TITLE_MW_INSURGENT
	turret_projectile = /obj/projectile/bullet/mw_kpvt
	turret_delay = 0.6 SECONDS
	drive_loop = /datum/looping_sound/mw_technical_drive

// MARK: LAV-25 (морпехи)
// Колёсная, быстрая, с башенной автопушкой. Броня заметно тоньше, чем у M113:
// M113 остаётся автобусом, ЛАВ — огневой поддержкой, которой нельзя стоять.
/obj/vehicle/mw/lav25
	name = "LAV-25"
	interior_key = LAZY_TEMPLATE_KEY_MW_APC_INTERIOR
	desc = "Колёсный бронетранспортёр разведбата. Башня с 25-мм автоматической пушкой. Быстрее гусеничной техники, но борт держит только пулю."
	icon = 'icons/mountain_wars/vehicle_lav25.dmi'
	icon_state = "lav25"
	turret_icon_state = "lav25_turret"
	// Кадр 224x224 на клетке 32x32 центрируется сдвигом (224 - 32) / 2. Кадр больше,
	// чем у остальной техники, и не от щедрости: всё меряется от оси башни, потому
	// что она стоит в центре кадра, а башня у ЛАВ в корме — значит в половину кадра
	// должен влезть весь корпус перед ней, 96 пикселей, плюс ствол в профиль, 87.
	pixel_x = -96
	pixel_y = -96
	// Кадр корпуса центрован по самой машине, чтобы спрайт не съезжал с хитбокса,
	// а погон нарисован не в середине — вот разница. Числа не руками: их печатает
	// build_sheet.py, там же и ручки посадки. Правил спрайт — перенеси блок сюда.
	// Ключи — числа направлений литералами: "[SOUTH]" компилятор в списке типа не
	// возьмёт, ему нужна константа.
	turret_offset = list(
		"2" = list(0, 17),    // SOUTH
		"1" = list(0, 4),     // NORTH
		"4" = list(-15, 36),  // EAST
		"8" = list(15, 36),   // WEST
	)
	// Три тайла поперёк, четыре вдоль: ЛАВ длиннее гусеничных, и в его нос при
	// квадратном габарите заходили пешком.
	hull_nose = 1
	// 450, а не 400: тяжёлый взрыв снимает треть запаса, и сверх него кумулятивная
	// ракета кладёт ещё и свои 70 прямым попаданием. На четырёх сотнях второе попадание
	// HEDP как раз добирало корпус, и ЛАВ умирал за две ракеты вместо трёх.
	max_integrity = 450
	// Пулестойкость 112 — та же поправка на возросший урон калибров, что и у М113.
	armor = list(MELEE = 50, BULLET = 112, LASER = 50, ENERGY = 50, BOMB = 15, BIO = 100, FIRE = 40, ACID = 40)
	max_occupants = 6
	movedelay = 2
	ram_damage = 35
	// Вдвое дороже М113: у ЛАВ пушка, и терять его должно быть больнее.
	ticket_cost = 10
	faction = JOB_TITLE_MW_MARINE
	turret_projectile = /obj/projectile/bullet/mw_25mm
	turret_delay = 1.2 SECONDS
	// Один выстрел, вырезанный из очереди на записи учений морпехов — та же 25-мм
	// пушка ЛАВ, что и здесь. Очередь целиком не берём: турель бьёт по снаряду за
	// нажатие, и три хлопка на один снаряд читались бы как промах глазами.
	// freesound 854186 (qubodup) — в атрибуцию PR.
	turret_sound = 'sound/mountain_wars/lav25_cannon.ogg'
	gunner_periscope = TRUE
	idle_loop = /datum/looping_sound/mw_apc_idle
	drive_loop = /datum/looping_sound/mw_apc_drive
	idle_loop_interior = /datum/looping_sound/mw_apc_idle_interior
	drive_loop_interior = /datum/looping_sound/mw_apc_drive_interior
	engine_off_sound = 'sound/mountain_wars/tank_eng_stop.ogg'
	engine_off_sound_interior = 'sound/mountain_wars/tank_eng_interior_stop.ogg'

// MARK: Мотоцикл (повстанцы)
// Не /obj/vehicle/mw: мотоцикл — обычный ездовой каркас Paradise, корпуса и экипажа у
// него нет, и вся многоклеточная машинерия ему не нужна. Отсюда и невосполнимость:
// пополнение живёт на /obj/vehicle/mw, а сюда его тянуть незачем.
/obj/vehicle/ridden/motorcycle/mw
	name = "мотоцикл"
	desc = "Разбитый дорожный мотоцикл. Брони нет вовсе, зато по грунтовке уходит от любой машины."

/obj/vehicle/ridden/motorcycle/mw/Initialize(mapload)
	. = ..()
	// Родитель уже повесил ездовой элемент со штатной скоростью. Второй поверх него
	// не встанет — оба сядут на одни и те же сигналы, поэтому сначала снимаем.
	RemoveElement(/datum/element/ridable, /datum/component/riding/vehicle/motorcycle)
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/motorcycle/mw)

/// Шаг 1 вместо 1.5 у технички: мотоцикл на треть быстрее самой быстрой машины.
/datum/component/riding/vehicle/motorcycle/mw
	vehicle_move_delay = 1

// MARK: Боеприпасы турелей
// Гильз нет: турель стреляет снарядом напрямую, без ammo_casing.
// Автоматическая пушка бьёт броню ещё увереннее крупнокалиберного пулемёта —
// иначе башенная машина не отличалась бы от пулемётной ничем, кроме вида.
//
// Урон обоих калибров поднят на треть: 45 в упор из 14,5-мм не вязались с тем, что
// такая пуля делает с человеком. Темп стрельбы прежний, а между машинами время до
// уничтожения удержано бронёй принимающей стороны — она поднята на те же 25% среза.
// Считается разница «броня минус пробитие», поэтому пулестойкость у бронемашин ушла
// за сотню: против пробития 85 и 90 это не неуязвимость, а как раз нужный срез.
/obj/projectile/bullet/mw_25mm
	name = "снаряд 25 мм"
	damage = 80
	armour_penetration = 90
	weaken = 2 SECONDS

/obj/projectile/bullet/mw_25mm/on_hit(atom/target, blocked = 0)
	. = ..()
	shell_burst(get_turf(target) || get_turf(src))

/// Осколки снаряда по клетке попадания и вокруг неё.
///
/// Не explosion(): лёгкий взрыв бьёт по технике на rand(10, 90) BOMB, то есть кладёт
/// в снаряд больше урона, чем в нём самого, и ТТК между машинами уезжает вдвое.
/// Плюс это вызов SSexplosions на каждый выстрел автопушки. Поэтому осколки бьют
/// только пехоту, а бронирование остаётся работой самого снаряда.
/obj/projectile/bullet/mw_25mm/proc/shell_burst(turf/where)
	if(!where)
		return
	new /obj/effect/temp_visual/explosion(where, 1, LIGHT_COLOR_LAVA, TRUE)
	playsound(where, 'sound/effects/explosion1.ogg', 55, TRUE)
	for(var/mob/living/victim in range(1, where))
		victim.apply_damage(30, BRUTE, null, victim.run_armor_check(null, BOMB))

// Пулемёт на турели — крупный калибр, его работа как раз в том, чтобы прошивать
// лёгкую броню. Пробитие держим выше брони БТРа (90): без этого по корпусу
// проходило 16 урона из 40, и очередь в упор не делала машине ничего. Пехотную
// броню такая пуля игнорирует и так, поэтому по бойцам ничего не меняется.
/obj/projectile/bullet/mw_kpvt
	name = "пуля 14,5 мм"
	damage = 60
	armour_penetration = 85

// MARK: Кнопки в технике
/datum/action/vehicle/mw
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/vehicle/mw/exit
	name = "Покинуть машину"
	desc = "Выбраться наружу."
	// Состояния "vehicle_eject" из /datum/action/vehicle в actions_vehicle.dmi нет,
	// поэтому кнопка родителя рисуется заглушкой ERROR.
	button_icon_state = "car_eject"

/datum/action/vehicle/mw/exit/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/vehicle/mw/vehicle = vehicle_target
	if(!istype(vehicle) || !isliving(owner))
		return
	vehicle.mob_exit(owner)

/datum/action/vehicle/mw/turret
	name = "Турель"
	desc = "Взять турель под управление. Кликайте по цели, чтобы стрелять."
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "sniper_zoom"

/datum/action/vehicle/mw/turret/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/vehicle/mw/vehicle = vehicle_target
	if(!istype(vehicle) || !owner?.client)
		return
	if(istype(owner.client.click_intercept, /datum/click_intercept/mw_turret))
		qdel(owner.client.click_intercept)
		to_chat(owner, span_notice("Вы отпускаете рукояти турели."))
		return
	new /datum/click_intercept/mw_turret(owner.client, vehicle)
	to_chat(owner, span_notice("Вы берётесь за турель. Кликайте по цели."))

/datum/action/vehicle/mw/zoom
	name = "Приборы наблюдения"
	desc = "Смотреть вперёд по корпусу. Ещё раз — вернуть обзор."
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "sniper_zoom"

/datum/action/vehicle/mw/zoom/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/vehicle/mw/vehicle = vehicle_target
	if(!istype(vehicle))
		return
	vehicle.toggle_crew_zoom(owner)

/// Пока перехват активен, любой клик наводчика — это выстрел из турели. Кнопка
/// удерживается — турель бьёт очередью и ведёт цель за курсором.
/datum/click_intercept/mw_turret
	var/obj/vehicle/mw/vehicle
	/// Куда бьём, пока кнопка зажата. Пусто — очередь остановлена.
	var/atom/held_target
	var/held_params
	var/firing = FALSE

/datum/click_intercept/mw_turret/New(client/C, obj/vehicle/mw/target)
	vehicle = target
	. = ..(C)
	if(C?.mob)
		RegisterSignal(C.mob, COMSIG_MOB_MOUSEDOWN, PROC_REF(on_mouse_down))
		RegisterSignal(C.mob, COMSIG_MOB_MOUSEDRAG, PROC_REF(on_mouse_drag))
		RegisterSignal(C.mob, COMSIG_MOB_MOUSEUP, PROC_REF(on_mouse_up))

/datum/click_intercept/mw_turret/Destroy()
	held_target = null
	vehicle = null
	return ..()

/datum/click_intercept/mw_turret/proc/on_mouse_down(mob/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	if(!isatom(object) || is_screen_atom(object))
		return
	held_target = object
	held_params = params
	if(!firing)
		INVOKE_ASYNC(src, PROC_REF(fire_loop), source)

/// Курсор поехал по экрану — очередь идёт следом.
/datum/click_intercept/mw_turret/proc/on_mouse_drag(mob/source, src_object, atom/over_object, src_location, over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(!held_target || !isatom(over_object) || is_screen_atom(over_object))
		return
	held_target = over_object
	held_params = params

/datum/click_intercept/mw_turret/proc/on_mouse_up(mob/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	held_target = null

/// Права на турель дают не посадка в машину, а место наводчика: встал с поста —
/// перехват мёртв, иначе десант в отсеке продолжал бы стрелять по своему курсору.
/datum/click_intercept/mw_turret/proc/still_gunner(mob/user)
	if(QDELETED(vehicle) || QDELETED(user))
		return FALSE
	// Через LAZYACCESS: у машины без экипажа occupants занулён, а вышедший наводчик
	// из списка уже удалён — прямое обращение по ключу падало на «bad index».
	return LAZYACCESS(vehicle.occupants, user) & VEHICLE_CONTROL_EQUIPMENT

/// Темп очереди держит COOLDOWN самой турели, здесь только опрос кнопки.
/datum/click_intercept/mw_turret/proc/fire_loop(mob/living/gunner)
	firing = TRUE
	while(held_target)
		if(!still_gunner(gunner))
			break
		vehicle.fire_turret(held_target, gunner, held_params)
		sleep(1)
	firing = FALSE

/datum/click_intercept/mw_turret/InterceptClickOn(mob/user, params, atom/object)
	if(!isliving(user) || !still_gunner(user))
		qdel(src)
		return
	// Стреляет очередь по нажатию мыши, клик только подавляем.
	return TRUE

/// Фракция бойца по режиму. Вне Mountain Wars возвращает null.
/proc/mw_faction_of(mob/user)
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(!istype(mode) || !user?.ckey)
		return null
	return mode.faction_by_ckey[user.ckey]

#undef MW_VEHICLE_ZOOM
#undef MW_VEHICLE_ROCKET_HITS
#undef MW_VEHICLE_RESPAWN
