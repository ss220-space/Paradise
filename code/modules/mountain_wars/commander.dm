// Способности командиров Mountain Wars.
// Всё на родном спелл-каркасе Paradise (/obj/effect/proc_holder/spell):
// кнопки, кулдауны и клик-таргетинг уже готовы. Спеллы выдаются на моба
// (не на майнд) в post_equip аутфита лидера — при респавне тело новое,
// способности сами не переносятся на другую роль.

// MARK: База
/obj/effect/proc_holder/spell/mw
	abstract_type = /obj/effect/proc_holder/spell/mw
	clothes_req = FALSE
	action_background_icon_state = "bg_default"
	/// Радиус, в котором не должно быть своих точек спавна — чтобы не бомбили базы.
	var/spawn_safe_range = 15

/obj/effect/proc_holder/spell/mw/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/targeting = new
	targeting.allowed_type = /atom
	return targeting

/// Общая проверка точки удара: не бить впритык к точкам спавна любой фракции.
/obj/effect/proc_holder/spell/mw/proc/strike_turf_check(turf/target, mob/user)
	if(!target)
		return FALSE
	for(var/faction in GLOB.mountain_wars_spawns)
		for(var/turf/spawn_turf as anything in GLOB.mountain_wars_spawns[faction])
			if(get_dist(target, spawn_turf) < spawn_safe_range)
				to_chat(user, span_warning("Слишком близко к базовому лагерю — удар отменён."))
				return FALSE
	return TRUE

/// За кого играет моб. Пусто — режим не тот или игрок вне фракций.
/obj/effect/proc_holder/spell/mw/proc/faction_of(mob/who)
	return mountain_wars_faction(who)

/// Сообщение своей фракции через режим.
/obj/effect/proc_holder/spell/mw/proc/message_own_faction(mob/user, text)
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(!istype(mode))
		return
	var/faction = faction_of(user)
	if(faction)
		mode.message_faction(faction, text)

// MARK: Артудар (морпехи)
// Залп с задержкой: маркеры видны всем — из-под удара можно выбежать.
/obj/effect/proc_holder/spell/mw/artillery
	name = "Артиллерийский удар"
	desc = "Вызвать залп корабельной артиллерии по указанной точке. Снаряды прилетают через 8 секунд."
	action_icon_state = "explosion"
	base_cooldown = 5 MINUTES
	/// Число снарядов в залпе.
	var/shells = 5
	/// Разброс от точки наводки, тайлов.
	var/scatter = 3
	/// Задержка прилёта.
	var/shell_delay = 8 SECONDS
	var/shell_heavy = 1
	var/shell_light = 3

/obj/effect/proc_holder/spell/mw/artillery/cast(list/targets, mob/user = usr)
	var/turf/target = get_turf(targets[1])
	if(!strike_turf_check(target, user))
		revert_cast(user)
		return
	message_own_faction(user, span_boldwarning("[user.real_name] вызывает артиллерийский удар! Координаты переданы."))
	playsound(target, 'sound/machines/alarm.ogg', 70, TRUE)
	var/list/strike_turfs = list()
	for(var/i in 1 to shells)
		var/turf/shell_turf = locate(
			clamp(target.x + rand(-scatter, scatter), 1, world.maxx),
			clamp(target.y + rand(-scatter, scatter), 1, world.maxy),
			target.z)
		if(!shell_turf)
			continue
		strike_turfs += shell_turf
		new /obj/effect/temp_visual/target/mw(shell_turf, shell_delay)
	addtimer(CALLBACK(src, PROC_REF(rain_shells), strike_turfs), shell_delay)

/obj/effect/proc_holder/spell/mw/artillery/proc/rain_shells(list/strike_turfs)
	for(var/turf/shell_turf as anything in strike_turfs)
		explosion(shell_turf, heavy_impact_range = shell_heavy, light_impact_range = shell_light, cause = name)

// Маркер прилёта: как у дрейка, но живёт до самого взрыва и без огня.
/obj/effect/temp_visual/target/mw
	duration = 8 SECONDS

/obj/effect/temp_visual/target/mw/Initialize(mapload, life)
	if(life)
		duration = life
	// Родительский Initialize запускает fall() с огнём дрейка — нам нужен только маркер.
	return ..(mapload, null)

/obj/effect/temp_visual/target/mw/fall(list/flame_hit)
	playsound(src, 'sound/magic/fleshtostone.ogg', 50, TRUE)

// MARK: Миномётный веер (повстанцы)
// Слабее и шире арты, зато чаще.
/obj/effect/proc_holder/spell/mw/artillery/mortar
	name = "Миномётный обстрел"
	desc = "Накрыть район миномётным огнём. Мины ложатся широко и прилетают через 6 секунд."
	action_icon_state = "explosion_old"
	base_cooldown = 3 MINUTES
	shells = 8
	scatter = 5
	shell_delay = 6 SECONDS
	shell_heavy = 0
	shell_light = 2

// MARK: Разведдрон (морпехи)
/obj/effect/proc_holder/spell/mw/recon
	name = "Разведдрон"
	desc = "Дрон сканирует район и помечает всех бойцов в радиусе 12 тайлов от точки."
	action_icon_state = "scan_mode"
	base_cooldown = 2 MINUTES
	var/scan_range = 12

/obj/effect/proc_holder/spell/mw/recon/cast(list/targets, mob/user = usr)
	var/turf/target = get_turf(targets[1])
	if(!target)
		revert_cast(user)
		return
	var/found = 0
	for(var/mob/living/carbon/human/victim in range(scan_range, target))
		if(victim.stat == DEAD)
			continue
		new /obj/effect/temp_visual/target/mw(get_turf(victim), 6 SECONDS)
		found++
	to_chat(user, span_notice("Дрон отработал: в районе замечено бойцов — [found]."))

// MARK: Сброс снабжения (морпехи)
/obj/effect/proc_holder/spell/mw/supply
	name = "Сброс снабжения"
	desc = "Запросить капсулу с боеприпасами и медикаментами в указанную точку."
	action_icon_state = "set_drop"
	base_cooldown = 5 MINUTES

/obj/effect/proc_holder/spell/mw/supply/cast(list/targets, mob/user = usr)
	var/turf/target = get_turf(targets[1])
	if(!target)
		revert_cast(user)
		return
	message_own_faction(user, span_boldwarning("[user.real_name] запросил сброс снабжения — капсула в пути!"))
	var/obj/structure/closet/supplypod/pod = new /obj/structure/closet/supplypod/bluespacepod()
	new /obj/structure/closet/crate/mw_supply(pod)
	new /obj/effect/pod_landingzone(target, pod)

/obj/structure/closet/crate/mw_supply
	name = "ящик снабжения КМП"

/obj/structure/closet/crate/mw_supply/populate_contents()
	for(var/i in 1 to 4)
		new /obj/item/ammo_box/magazine/m556/mw_m16a4(src)
		new /obj/item/storage/firstaid/mw_marine(src)
	new /obj/item/ammo_box/magazine/l6saw/mw_m249(src)
	// Труба целиком, а не её внутренний магазин: тот отдельным предметом бесполезен,
	// зарядить его некуда. Одна на сброс — это единственный ответ пехоты на броню.
	new /obj/item/gun/projectile/revolver/rocketlauncher/mw_law(src)

// MARK: Дымовая завеса (повстанцы)
/obj/effect/proc_holder/spell/mw/smokescreen
	name = "Песчаная завеса"
	desc = "Поднять плотное облако пыли и дыма, скрывающее передвижение."
	action_icon_state = "smoke"
	base_cooldown = 2 MINUTES

/obj/effect/proc_holder/spell/mw/smokescreen/cast(list/targets, mob/user = usr)
	var/turf/target = get_turf(targets[1])
	if(!target)
		revert_cast(user)
		return
	playsound(target, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/fluid_spread/smoke/solid/smoke = new
	smoke.set_up(amount = DIAMOND_AREA(6), location = target)
	smoke.start()

// MARK: Приказы (обе фракции)
// По образцу TGMC: приказ — не пометка на карте, а короткий бафф всем своим вокруг
// указанной точки. Раньше здесь был выбор строки из списка, который только писал в
// чат; бойцы никакой разницы не чувствовали, поэтому приказ и не работал.
//
// Три приказа делят один кулдаун: иначе лидер вешал бы на отряд все три разом, и
// выбор приказа перестал бы быть выбором.
#define MW_ORDER_RANGE 7
#define MW_ORDER_DURATION 45 SECONDS
/// Источник трейта у приказа «Огонь» — чтобы снимать только своё.
#define MW_ORDER_TRAIT "mw_order"

/datum/movespeed_modifier/mw_order_advance
	multiplicative_slowdown = -0.4

/datum/status_effect/mw_order
	abstract_type = /datum/status_effect/mw_order
	duration = MW_ORDER_DURATION
	// Баффы статичные: тикать нечего, а тик задаром жёг бы процессор на всём отряде.
	tick_interval = STATUS_EFFECT_NO_TICK
	// Повторный приказ продлевает уже висящий, а не вешает второй поверх.
	status_type = STATUS_EFFECT_REFRESH

// MARK: Приказ «Вперёд»
/datum/status_effect/mw_order/advance
	id = "mw_order_advance"
	alert_type = /atom/movable/screen/alert/status_effect/mw_order_advance

/atom/movable/screen/alert/status_effect/mw_order_advance
	name = "Приказ: вперёд"
	desc = "Командир гонит отряд вперёд. Вы двигаетесь быстрее."
	icon_state = "adrenaline"

/datum/status_effect/mw_order/advance/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/mw_order_advance)
	return TRUE

/datum/status_effect/mw_order/advance/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/mw_order_advance)

// MARK: Приказ «Держать позицию»
/datum/status_effect/mw_order/hold
	id = "mw_order_hold"
	alert_type = /atom/movable/screen/alert/status_effect/mw_order_hold
	/// Плоское снижение входящего урона, в процентах.
	var/resistance = 12
	/// Множитель длительности станов и нокдаунов.
	var/stun_scale = 0.8

/atom/movable/screen/alert/status_effect/mw_order_hold
	name = "Приказ: держать позицию"
	desc = "Отряд окопался. Вы держите удар лучше обычного."
	icon_state = "hypernob_protection"

/datum/status_effect/mw_order/hold/on_apply()
	var/mob/living/carbon/human/soldier = owner
	if(!istype(soldier))
		return FALSE
	soldier.physiology.damage_resistance += resistance
	soldier.physiology.stun_mod *= stun_scale
	return TRUE

/datum/status_effect/mw_order/hold/on_remove()
	var/mob/living/carbon/human/soldier = owner
	if(!istype(soldier))
		return
	soldier.physiology.damage_resistance -= resistance
	soldier.physiology.stun_mod /= stun_scale

// MARK: Приказ «Сосредоточить огонь»
// Кучность считается в самом стволе, поэтому вешаем трейт: гнуть accuracy-датум
// нельзя, он у части оружия общий на тип и правка растеклась бы на все стволы.
/datum/status_effect/mw_order/focus
	id = "mw_order_focus"
	alert_type = /atom/movable/screen/alert/status_effect/mw_order_focus

/atom/movable/screen/alert/status_effect/mw_order_focus
	name = "Приказ: сосредоточить огонь"
	desc = "Вы бьёте по указанной цели. Разброс меньше."
	icon_state = "aimed"

/datum/status_effect/mw_order/focus/on_apply()
	ADD_TRAIT(owner, TRAIT_MW_FOCUSED, MW_ORDER_TRAIT)
	return TRUE

/datum/status_effect/mw_order/focus/on_remove()
	REMOVE_TRAIT(owner, TRAIT_MW_FOCUSED, MW_ORDER_TRAIT)

// MARK: Приказ на экране
// Приказ должен доходить без чтения чата: боец в перестрелке в него не смотрит. Поэтому
// в левом верхнем углу — портрет отдавшего и текст приказа. Угол, а не середина: бой
// идёт в центре экрана, и перекрывать его сообщением нельзя.
//
// Портрет — аппиранс самого командира оверлеем: отдельных лиц под роли нет, а своего
// лидера боец узнаёт по силуэту и форме. Оверлей 32x32 границы контрола карты не растит,
// в отличие от полноэкранной картинки — на этом уже обжигались, см. cinematic.dm.
//
// Общий объект на всех не годится: карточка у каждого своя, потому что снимается она по
// своему таймеру, а приказы прилетают бойцам вразнобой. Штатный overlay_fullscreen как
// раз и держит по экрану на моба и умеет гасить его с затуханием.

/// Сколько приказ висит на экране.
#define MW_ORDER_CARD_TIME (5 SECONDS)
/// Во сколько раз увеличен портрет.
#define MW_ORDER_FACE_ZOOM 2
/// Карточка приказа: строка отправителя с подчёркиванием и сам приказ под ней.
/// line-height 1.4, а не единица: кегль в пунктах меньше реальной высоты буквы, и на
/// единице вторая строка залезала на подчёркивание первой.
#define MW_ORDER_MAPTEXT(sender, body) {"<span style='font-family: \"Pixellari\"; font-size: 11pt; line-height: 1.4; -dm-text-outline: 1px black; color: #ffffff'><u>[sender]</u><br>[body]</span>"}

/atom/movable/screen/fullscreen/mw_order
	// Картинки у карточки нет вовсе: она состоит из текста и портрета-оверлея.
	icon = null
	icon_state = null
	// Левый верхний угол, справа от портрета — текст. Короб маптекста опущен на свою
	// высоту минус клетка: растёт он вниз от верха, а стоит на клетке низом.
	//
	// Двумя строками ниже верха. Одной не хватало: портрет увеличен вдвое и растёт от
	// своего центра, то есть занимает по высоте две клетки вместо одной и верхней
	// половиной заезжал на ряд кнопок способностей.
	screen_loc = "WEST,NORTH-2"
	maptext_width = 288
	maptext_height = 64
	// Отступ вправо за портрет. Тот увеличен вдвое и растёт от своего центра в обе
	// стороны, то есть занимает не клетку, а две: 40 пикселей текст ещё накрывал.
	maptext_x = 76
	maptext_y = -32
	needs_offsetting = FALSE

/atom/movable/screen/fullscreen/mw_order/proc/fill(mob/living/commander, body)
	cut_overlays()
	var/mutable_appearance/face = new(commander.appearance)
	// Плоскость и слой аппиранс притащил от моба — сбрасываем на плавающие, иначе
	// портрет уедет рисоваться в игровой мир, а не поверх интерфейса.
	face.plane = FLOAT_PLANE
	face.layer = FLOAT_LAYER
	face.maptext = null
	face.transform = matrix(MW_ORDER_FACE_ZOOM, 0, 0, 0, MW_ORDER_FACE_ZOOM, 0)
	// Слева от текста. Увеличение крутится вокруг центра оверлея, поэтому клетку
	// сдвигаем на половину прироста — иначе портрет вылезает за края экрана.
	face.pixel_x = ICON_SIZE_X / 2
	face.pixel_y = -ICON_SIZE_Y / 2
	add_overlay(face)
	maptext = body

/// Показывает приказ бойцу. Повторный приказ перебивает предыдущий и продлевает показ.
/// body — готовая строка maptext, см. MW_ORDER_MAPTEXT.
/proc/mw_order_card(mob/living/commander, mob/living/soldier, body)
	if(!commander || !soldier?.client)
		return
	var/atom/movable/screen/fullscreen/mw_order/card = soldier.overlay_fullscreen("mw_order", /atom/movable/screen/fullscreen/mw_order)
	if(!card)
		return
	card.fill(commander, body)
	SEND_SOUND(soldier, sound('sound/misc/notice2.ogg', volume = 40))
	addtimer(CALLBACK(soldier, TYPE_PROC_REF(/mob, clear_fullscreen), "mw_order"), MW_ORDER_CARD_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)

// MARK: Приказ своими словами
// Способности отдают три заранее написанных приказа, а тут лидер пишет что угодно и
// это встаёт на экране у всего его отряда. Не спелл: цели у приказа нет, кликать не по
// чему, а кнопка действия делает то же самое без каркаса таргетинга.

/// Как часто лидер может слать текст отряду.
#define MW_ORDER_NOTE_COOLDOWN (15 SECONDS)
/// Предел длины приказа. Длиннее в короб карточки всё равно не влезет.
#define MW_ORDER_NOTE_LENGTH 200

/datum/action/innate/mw_order_note
	name = "Приказ отряду"
	desc = "Передать отряду приказ своими словами. Текст встанет у каждого на экране."
	button_icon_state = "commune"
	check_flags = AB_CHECK_CONSCIOUS
	/// Когда можно слать следующий.
	var/next_order = 0

/datum/action/innate/mw_order_note/Activate()
	var/mob/living/leader = owner
	if(!istype(leader))
		return
	if(world.time < next_order)
		to_chat(leader, span_warning("Эфир занят: следующий приказ через [DisplayTimeText(next_order - world.time)]."))
		return
	// Текст спрашиваем до всех проверок отряда: пока лидер печатает, состав всё равно
	// успеет измениться, так что считать его надо после.
	var/text = tgui_input_text(leader, "Что передать отряду?", name, max_length = MW_ORDER_NOTE_LENGTH)
	if(!text || QDELETED(leader))
		return
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(!istype(mode))
		return
	var/datum/team/mountain_wars/team = mode.teams[mountain_wars_faction(leader)]
	if(!istype(team))
		return
	var/list/audience = team.order_audience(leader.mind)
	if(!length(audience))
		to_chat(leader, span_warning("Отряд не отвечает — приказ принимать некому."))
		return
	next_order = world.time + MW_ORDER_NOTE_COOLDOWN
	// tgui_input_text отдаёт текст уже безопасным (encode = TRUE по умолчанию), так что
	// второй раз кодировать нельзя — в maptext полезут &amp; вместо букв.
	var/sign = html_encode(leader.real_name)
	for(var/mob/living/soldier as anything in audience)
		mw_order_card(leader, soldier, MW_ORDER_MAPTEXT("Сообщение от [sign]", text))
		// Копия в чат: карточка живёт пять секунд, а перечитать приказ надо и потом.
		to_chat(soldier, span_boldnotice("ПРИКАЗ от [sign]: [text]"))
	log_say("[key_name(leader)] отдал приказ отряду ([length(audience)] бойцов): [text]")

// MARK: Выдача приказа
/obj/effect/proc_holder/spell/mw/order
	abstract_type = /obj/effect/proc_holder/spell/mw/order
	base_cooldown = 45 SECONDS
	/// Что вешаем на бойцов в радиусе.
	var/effect_type
	/// Как приказ звучит в оповещении фракции.
	var/shout

/obj/effect/proc_holder/spell/mw/order/cast(list/targets, mob/user = usr)
	var/turf/target = get_turf(targets[1])
	var/faction = faction_of(user)
	if(!target || !faction)
		revert_cast(user)
		return
	var/count = 0
	for(var/mob/living/carbon/human/soldier in range(MW_ORDER_RANGE, target))
		if(soldier.stat == DEAD || faction_of(soldier) != faction)
			continue
		soldier.apply_status_effect(effect_type)
		mw_order_card(user, soldier, MW_ORDER_MAPTEXT("Приказ от [html_encode(user.real_name)]", shout))
		count++
	if(!count)
		to_chat(user, span_warning("В районе никого из своих — приказ некому выполнять."))
		revert_cast(user)
		return
	playsound(user, 'sound/misc/notice2.ogg', 40, FALSE)
	message_own_faction(user, span_boldnotice("ПРИКАЗ от [user.real_name]: [shout] ([target.x], [target.y]). Под приказом бойцов: [count]."))
	share_cooldown(user)

/// Отдав один приказ, лидер не может тут же навесить сверху два других.
/obj/effect/proc_holder/spell/mw/order/proc/share_cooldown(mob/user)
	for(var/obj/effect/proc_holder/spell/mw/order/other in user.mob_spell_list)
		if(other != src)
			other.cooldown_handler.start_recharge()

/obj/effect/proc_holder/spell/mw/order/advance
	name = "Приказ: вперёд"
	desc = "Погнать отряд вперёд: все свои в районе точки двигаются быстрее 45 секунд."
	action_icon_state = "adrenaline"
	effect_type = /datum/status_effect/mw_order/advance
	shout = "ВПЕРЁД"

/obj/effect/proc_holder/spell/mw/order/hold
	name = "Приказ: держать позицию"
	desc = "Приказать окопаться: все свои в районе точки 45 секунд держат удар лучше."
	action_icon_state = "shield"
	effect_type = /datum/status_effect/mw_order/hold
	shout = "ДЕРЖАТЬ ПОЗИЦИЮ"

/obj/effect/proc_holder/spell/mw/order/focus
	name = "Приказ: сосредоточить огонь"
	desc = "Указать цель: все свои в районе точки 45 секунд стреляют кучнее."
	action_icon_state = "sniper_zoom"
	effect_type = /datum/status_effect/mw_order/focus
	shout = "СОСРЕДОТОЧИТЬ ОГОНЬ"

#undef MW_ORDER_RANGE
#undef MW_ORDER_DURATION
#undef MW_ORDER_TRAIT
#undef MW_ORDER_CARD_TIME
#undef MW_ORDER_FACE_ZOOM
#undef MW_ORDER_MAPTEXT

#undef MW_ORDER_NOTE_COOLDOWN
#undef MW_ORDER_NOTE_LENGTH

// MARK: Выдача
/datum/outfit/job/mountain_wars/marine/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	H.AddSpell(new /obj/effect/proc_holder/spell/mw/artillery)
	H.AddSpell(new /obj/effect/proc_holder/spell/mw/recon)
	H.AddSpell(new /obj/effect/proc_holder/spell/mw/supply)
	H.AddSpell(new /obj/effect/proc_holder/spell/mw/order/advance)
	H.AddSpell(new /obj/effect/proc_holder/spell/mw/order/hold)
	H.AddSpell(new /obj/effect/proc_holder/spell/mw/order/focus)

/datum/outfit/job/mountain_wars/insurgent/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	H.AddSpell(new /obj/effect/proc_holder/spell/mw/artillery/mortar)
	H.AddSpell(new /obj/effect/proc_holder/spell/mw/smokescreen)
	H.AddSpell(new /obj/effect/proc_holder/spell/mw/order/advance)
	H.AddSpell(new /obj/effect/proc_holder/spell/mw/order/hold)
	H.AddSpell(new /obj/effect/proc_holder/spell/mw/order/focus)
