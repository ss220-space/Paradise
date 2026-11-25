/*

VAZZ

Одинокая фигура в личной броне H.E.C.K. Mk II. Кем он был и чем стал — остаётся неясным.
Он не рычит и не бросается в бой слепо: говорит редко, действует выверенно.

Странник: пока цели нет, Vazz ходит по маршруту из нескольких точек вокруг места появления. Его GPS—сигнал движется,
земля отдаётся глухой дрожью, и только потом появляется он сам. Если контакт потерян, Vazz доходит до последней
известной позиции цели и возвращается на маршрут. В обычном режиме он не ищет игроков сам; в хардмоде (enraged) иногда
идёт прямо к ближайшему.
Пока Vazz бродит, у него есть собственные дела, не связанные с игроками:
— Крашер по фауне: иногда подходит к обычной фауне Лаваленда (фракция mining, не boss) и добивает её крашером (поза vazz_crusher).
— Крашер по породе: если маршрут перекрыт разрушаемой породой, пробивает проход штатным способом (дестабилизатор —> attempt_drill).
— Питание: раненый Vazz доедает трупы обычной фауны и восстанавливает немного здоровья (см. VAZZ_FEED_*).
Любая эта задача мгновенно обрывается, как только Vazz замечает цель: бой всегда важнее.

Основной цикл: рывок —> бластеры черепа —> крестовой разряд —> выстрел с телепортом.
После каждой атаки у Vazz есть окно ближнего боя: пока цель рядом, он дерётся, а не запускает следующую атаку.
Вне очереди:
— Рывок           — если цель далеко и рывок готов.
— Выстрел с телепортом — если игрок слишком долго стоит вплотную (Vazz уходит и стреляет).
— Арена           — ниже 50% здоровья, ОДИН раз и коротко (3 волны). Vazz встаёт перед ареной, на время арены неуязвим.
					В хардмоде арена полная (8 волн) и повторяется по кулдауну, как раньше.
					Волны: лучи черепов, веера снарядов и "заградительный огонь" с безопасными полосами.
— Ближний бой     — обычные удары.

Вторая фаза (после арены): Vazz перестаёт отступать от "прилипших" игроков (выстрел при затяжном ближнем бое не
вызывается), дольше держит окно ближнего боя, использует рывок как сближение с меньшей дистанции, а выстрел с
телепортом делает коротким отскоком (2—3 клетки). Порядок основного цикла атак не меняется.

Спрайты поз лежат в основном icons/mob/lavaland/vazz.dmi отдельными icon_state (список — перед vazz_pose()).
Нет нужного состояния в файле — Vazz остаётся в основном спрайте.

Урон от каждого луча наносится ОДИН раз в момент разряда по клеткам, зафиксированным в начале телеграфа.
Постоянных таймеров урона нет, поэтому повторных попаданий одним лучом быть не может.

Режим enraged (хардмод): на игроков накладывается существующее проклятие /datum/status_effect/bubblegum_curse
(сбежать от босса нельзя). Это временное решение, пока нет собственного эффекта для Vazz.

Difficulty: Insane
*/

#define VAZZ_ATTACK_CHARGE 1
#define VAZZ_ATTACK_CROSS 2
#define VAZZ_ATTACK_SHOT 3
#define VAZZ_ATTACK_BLASTERS 4
#define VAZZ_ATTACK_ARENA 5

/// Столько попыток ближнего боя подряд — и следующей атакой будет выстрел с телепортом
#define VAZZ_MELEE_STREAK_LIMIT 3
/// Окно ближнего боя после каждой атаки
#define VAZZ_MELEE_WINDOW (3 SECONDS)
/// В пределах скольких клеток цель считается "рядом" для окна ближнего боя
#define VAZZ_MELEE_WINDOW_DISTANCE 2
/// Отмашка: пока Vazz занят атакой, он бьёт всех, кто стоит вплотную (раз в VAZZ_SWAT_INTERVAL)
#define VAZZ_SWAT_DAMAGE 20
#define VAZZ_SWAT_INTERVAL (1 SECONDS)
/// TRUE — отмашка работает и во время восстановления после атаки (как в исходной версии).
/// FALSE — восстановление становится честным окном для удара: игрок, прочитавший замах и подошедший, не получает отмашку.
#define VAZZ_SWAT_DURING_RECOVERY TRUE

// Патруль
#define VAZZ_PATROL_TICK (2 SECONDS)
#define VAZZ_PATROL_POINTS 4
/// Радиус вокруг места появления, в котором выбираются точки маршрута
#define VAZZ_PATROL_RADIUS 30
#define VAZZ_PATROL_PAUSE_MIN (3 SECONDS)
#define VAZZ_PATROL_PAUSE_MAX (7 SECONDS)
/// Сколько тиков подряд без движения считается "застрял"
#define VAZZ_PATROL_STUCK_LIMIT 3
/// Сколько раз подряд Vazz бросает цель, прежде чем маршрут перестраивается
#define VAZZ_PATROL_GIVEUP_LIMIT 3
#define VAZZ_PATROL_ARRIVE_DISTANCE 1
/// Хардмод: шанс, что следующей точкой маршрута станет ближайший игрок, и максимальная дальность такой "охоты"
#define VAZZ_PATROL_HUNT_CHANCE 40
#define VAZZ_PATROL_HUNT_RANGE 45
/// Дрожь земли при шагах: дальность сообщения и дальность тряски камеры
#define VAZZ_TREMOR_RANGE 14
#define VAZZ_TREMOR_CAMERA_RANGE 7

// Задачи патруля (крашер по фауне, питание)
#define VAZZ_TASK_CRUSH 1
#define VAZZ_TASK_FEED 2
#define VAZZ_TASK_SCAN_INTERVAL (5 SECONDS)
#define VAZZ_TASK_SCAN_RANGE 7
/// За это время Vazz должен дойти до цели задачи, иначе бросает её
#define VAZZ_TASK_TIMEOUT (15 SECONDS)

// Крашер
/// Шанс на каждом сканировании (раз в VAZZ_TASK_SCAN_INTERVAL), что Vazz пойдёт добивать замеченную фауну
#define VAZZ_CRUSHER_CHANCE 35
#define VAZZ_CRUSHER_COOLDOWN (25 SECONDS)
#define VAZZ_CRUSHER_WINDUP (1.2 SECONDS)
#define VAZZ_CRUSHER_STRIKE_TIME (0.6 SECONDS)
/// Урон по фауне (не меньше её maxHealth: тяжёлый удар убивает)
#define VAZZ_CRUSHER_FAUNA_DAMAGE 600
/// Сколько ударов Vazz тратит на одну породу, прежде чем решит, что её не пробить
#define VAZZ_CRUSHER_ROCK_ATTEMPTS 3

// Питание трупами (единственный источник самолечения; пассивной регенерации нет)
/// Ищет труп, только если здоровье не выше этой доли
#define VAZZ_FEED_HEALTH_THRESHOLD 0.9
/// Доля maxHealth, восстанавливаемая одним трупом
#define VAZZ_FEED_HEAL_FRACTION 0.04
/// Потолок суммарного лечения за всю жизнь Vazz (доля maxHealth)
#define VAZZ_FEED_TOTAL_CAP_FRACTION 0.25
#define VAZZ_FEED_TIME (4 SECONDS)
#define VAZZ_FEED_COOLDOWN (60 SECONDS)
/// Размер клетки "места" для защиты от фарма: в одной клетке лечение не чаще VAZZ_FEED_SITE_COOLDOWN
#define VAZZ_FEED_SITE_GRID 12
#define VAZZ_FEED_SITE_COOLDOWN (5 MINUTES)

// Вторая фаза (после арены)
#define VAZZ_PHASE2_MELEE_WINDOW (4.5 SECONDS)
#define VAZZ_PHASE2_CHARGE_FAR_DISTANCE 4
#define VAZZ_PHASE2_CHARGE_COOLDOWN (4 SECONDS)
#define VAZZ_PHASE2_SHOT_BLINK_MIN_DISTANCE 2
#define VAZZ_PHASE2_SHOT_BLINK_MAX_DISTANCE 3

// Позы (только визуал, на тайминги боя не влияют)
#define VAZZ_POSE_SHOT_HOP (0.4 SECONDS)
#define VAZZ_POSE_SHOT_FIRE (0.3 SECONDS)

// Крестовой разряд
#define VAZZ_CROSS_ARM_LENGTH 9
#define VAZZ_CROSS_WINDUP (1.8 SECONDS)
#define VAZZ_FOLLOWUP_WINDUP (1.4 SECONDS)
#define VAZZ_CROSS_RECOVERY (3.0 SECONDS)
#define VAZZ_CROSS_DAMAGE 40

// Рывок (по мотивам рывка Легионера)
#define VAZZ_CHARGE_LENGTH 6
#define VAZZ_CHARGE_WINDUP (0.9 SECONDS)
#define VAZZ_CHARGE_FOLLOWUP_WINDUP (0.7 SECONDS)
/// Сколько деци—секунд на одну клетку рывка
#define VAZZ_CHARGE_STEP_TIME 0.5
#define VAZZ_CHARGE_RECOVERY (1.5 SECONDS)
#define VAZZ_CHARGE_COOLDOWN (6 SECONDS)
/// С какой дистанции рывок используется как сближение
#define VAZZ_CHARGE_FAR_DISTANCE 8
#define VAZZ_CHARGE_DAMAGE 35
#define VAZZ_CHARGE_THROW_RANGE 4

// Выстрел с телепортом (по мотивам выстрела Колосса)
#define VAZZ_SHOT_RANGE 10
#define VAZZ_SHOT_SPREAD 12.5
#define VAZZ_SHOT_WINDUP (1.4 SECONDS)
#define VAZZ_SHOT_RECOVERY (2.0 SECONDS)
#define VAZZ_SHOT_BLINK_MIN_DISTANCE 5
#define VAZZ_SHOT_BLINK_MAX_DISTANCE 7

// Бластеры черепа
#define VAZZ_BLASTER_COUNT 3
#define VAZZ_BLASTER_RANGE 12
#define VAZZ_BLASTER_MIN_DISTANCE 4
#define VAZZ_BLASTER_MAX_DISTANCE 7
#define VAZZ_BLASTER_WINDUP (1.4 SECONDS)
#define VAZZ_BLASTER_STAGGER (0.4 SECONDS)
#define VAZZ_BLASTER_RECOVERY (2.0 SECONDS)
#define VAZZ_BLASTER_DAMAGE 30
#define VAZZ_SKULL_LEAVE_TIME (0.5 SECONDS)
/// Во сколько раз уменьшен спрайт Legion для черепа (1 = исходный размер 96x96)
#define VAZZ_SKULL_SCALE 0.4

// Арена
#define VAZZ_ARENA_RADIUS 4
#define VAZZ_ARENA_WAVES 6
/// Обычный режим: одна короткая арена (по одной волне каждого типа)
#define VAZZ_ARENA_WAVES_SHORT 3
#define VAZZ_ARENA_SETUP (1.5 SECONDS)
#define VAZZ_ARENA_WAVE_PERIOD (2.6 SECONDS)
#define VAZZ_ARENA_RECOVERY (3.0 SECONDS)
#define VAZZ_ARENA_COOLDOWN (40 SECONDS)
#define VAZZ_ARENA_COOLDOWN_ENRAGED (28 SECONDS)
#define VAZZ_ARENA_BLASTERS 4
#define VAZZ_ARENA_BLASTER_WINDUP (1.5 SECONDS)
#define VAZZ_ARENA_BLASTER_DAMAGE 25
#define VAZZ_ARENA_BOLT_SKULLS 4
#define VAZZ_ARENA_BOLT_CHARGE (1.2 SECONDS)
#define VAZZ_BOLT_DAMAGE 15
/// Заградительный огонь: ряды черепов стреляют вдоль арены, оставляя безопасную полосу без линий
#define VAZZ_ARENA_BARRAGE_CHARGE (1.3 SECONDS)
#define VAZZ_ARENA_BARRAGE_BURST 2
#define VAZZ_ARENA_BARRAGE_DELAY (0.5 SECONDS)
#define VAZZ_ARENA_BARRAGE_RANGE (VAZZ_ARENA_RADIUS * 2)
#define VAZZ_ARENA_SAFE_WIDTH 3
#define VAZZ_ARENA_SAFE_WIDTH_ENRAGED 2
/// Запасной срок жизни барьеров. Обычно они убираются раньше, когда арена заканчивается или Vazz умирает.
#define VAZZ_ARENA_WALL_DURATION (40 SECONDS)

// Общие тайминги лучей
#define VAZZ_FIRE_TIME (0.5 SECONDS)
/// Сколько живёт невидимая точка—источник лучей (больше самой долгой подготовки + разряда)
#define VAZZ_ANCHOR_LIFETIME (6 SECONDS)

/// Невидимая точка, из которой рисуются лучи. Фиксирует начало луча, даже если Vazz сдвинется.
/obj/effect/vazz_beam_anchor
	name = "vazz beam anchor"
	icon = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/// Череп бластер. Он же является источником луча.
/// Спрайт — череп мегафауны Legion (96x96). Смещения такие же, как у самого Legion, чтобы череп стоял по центру клетки.
/obj/effect/vazz_beam_anchor/skull
	name = "череп"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	icon_state = "mega_legion"
	pixel_x = -32
	pixel_y = -16
	layer = LARGE_MOB_LAYER
	alpha = 0
	/// На сколько градусов довернуть спрайт, чтобы при угле 0 череп смотрел на север.
	/// 180 — если спрайт по умолчанию смотрит на юг (вниз). Если череп повёрнут не туда, меняем это значение.
	var/sprite_angle_offset = 180

/obj/effect/vazz_beam_anchor/skull/proc/appear(angle)
	var/matrix/M = new
	// Исходный спрайт Legion огромный (у самого Legion он ещё и увеличен в 2 раза), поэтому сильно уменьшаем
	M.Scale(VAZZ_SKULL_SCALE, VAZZ_SKULL_SCALE)
	M.Turn(angle + sprite_angle_offset)
	transform = M
	animate(src, alpha = 255, time = 3)

/obj/effect/vazz_beam_anchor/skull/proc/leave()
	animate(src, alpha = 0, pixel_y = pixel_y + 16, time = VAZZ_SKULL_LEAVE_TIME)

/// Предупреждение о рывке. Основа — телеграф рывка Легионера, но с нужной длительностью.
/obj/effect/temp_visual/dragon_swoop/legionnaire/vazz
	duration = VAZZ_CHARGE_WINDUP

/// Барьер арены. Основа — существующий drakewall, пока нет собственного спрайта.
/obj/effect/temp_visual/drakewall/vazz
	name = "барьер"
	desc = "Барьер из мерцающего света. Пока он стоит, выйти из круга не получится."
	duration = VAZZ_ARENA_WALL_DURATION
	// TODO(спрайт): icon и icon_state барьера.

/// Снаряд Vazz. Медленный, чтобы от него можно было увернуться.
/obj/projectile/vazz_bolt
	name = "призрачный снаряд"
	icon_state = "chronobolt" // TODO(спрайт): собственный снаряд
	damage = VAZZ_BOLT_DAMAGE
	speed = 3.5

/obj/projectile/vazz_bolt/get_ru_names()
	return alist(
		NOMINATIVE = "призрачный снаряд",
		GENITIVE = "призрачного снаряда",
		DATIVE = "призрачному снаряду",
		ACCUSATIVE = "призрачный снаряд",
		INSTRUMENTAL = "призрачным снарядом",
		PREPOSITIONAL = "призрачном снаряде",
	)

/mob/living/simple_animal/hostile/megafauna/vazz
	name = "Vazz"
	desc = "Одинокая фигура в личной броне. Кем он был и чем стал — неизвестно."
	health = 5000
	maxHealth = 5000
	icon_state = "vazz"
	icon_living = "vazz"
	icon = 'icons/mob/lavaland/vazz.dmi'
	crusher_loot = list(/obj/structure/closet/crate/necropolis/vazz/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/vazz)
	enraged_loot = /obj/item/disk/fauna_research/vazz
	enraged_unique_loot = /obj/item/melee/spellblade/other/random
	// Мегафауна: обычная фауна (mining) его не трогает, а он не трогает её. Boss — чтобы не путать его с обычной фауной и
	// не устраивать бои с другой мегафауной (см. vazz_valid_prey). Совпадает с MINING_FACTIONS.
	faction = list("mining", "boss")
	light_color = "#A5603A"
	speak_emote = list("говорит")
	tts_seed = "Wrathion_Deathwing"
	speed = 3
	melee_damage_lower = 28
	melee_damage_upper = 32
	// Количество ударов за один цикл ИИ. Раньше был один удар, поэтому в ближнем бою Vazz почти не дрался.
	rapid_melee = 2
	ranged = TRUE
	internal_type = /obj/item/gps/internal/vazz
	del_on_death = TRUE
	deathmessage = "медленно оседает на землю. Свет в пластинах H.E.C.K. Mk II гаснет."
	death_sound = SFX_BODYFALL
	footstep_type = FOOTSTEP_MOB_HEAVY
	achievement_type = /datum/award/achievement/boss/vazz_kill
	crusher_achievement_type = /datum/award/achievement/boss/vazz_crusher
	score_achievement_type = /datum/award/score/vazz_score
	attack_action_types = list(
		/datum/action/innate/megafauna_attack/vazz_charge,
		/datum/action/innate/megafauna_attack/vazz_cross,
		/datum/action/innate/megafauna_attack/vazz_shot,
		/datum/action/innate/megafauna_attack/vazz_blasters,
		/datum/action/innate/megafauna_attack/vazz_arena,
	)
	/// Порядок атак в основном цикле
	var/list/attack_sequence = list(VAZZ_ATTACK_CHARGE, VAZZ_ATTACK_BLASTERS, VAZZ_ATTACK_CROSS, VAZZ_ATTACK_SHOT)
	/// Индекс следующей атаки в attack_sequence
	var/combo_step = 1
	/// Сколько раз подряд Vazz пытался бить в ближнем бою
	var/melee_streak = 0
	/// До какого момента Vazz занят атакой. Истекает сам, поэтому навсегда зависнуть не может.
	var/busy_until = 0
	/// До какого момента длится окно ближнего боя
	var/melee_until = 0
	/// Когда Vazz сможет в следующий раз отмахнуться от стоящих вплотную
	var/next_swat_at = 0
	/// Когда рывок снова можно использовать как сближение
	var/charge_ready_at = 0
	/// Когда снова можно запустить арену
	var/arena_ready_at = 0
	/// До какого момента Vazz неуязвим (щит арены). Истекает сам.
	var/arena_shield_until = 0
	/// Оверлей щита
	var/mutable_appearance/arena_shield_overlay
	/// Барьеры текущей арены
	var/list/arena_walls = list()
	/// До какого момента работает отмашка (см. VAZZ_SWAT_DURING_RECOVERY)
	var/swat_until = 0
	/// Арена уже была: Vazz перешёл во вторую фазу
	var/phase_two = FALSE
	/// До какого момента держится поза атаки (см. vazz_pose)
	var/pose_until = 0
	/// Патруль включён
	var/patrol_enabled = TRUE
	/// Место появления: вокруг него строится маршрут
	var/turf/patrol_home
	/// Точки маршрута
	var/list/patrol_route = list()
	var/patrol_index = 0
	/// Куда Vazz идёт сейчас (точка маршрута, последняя известная позиция цели или игрок в хардмоде)
	var/turf/patrol_destination
	var/turf/patrol_last_pos
	var/patrol_stuck = 0
	var/patrol_giveups = 0
	var/patrol_pause_until = 0
	/// Текущая задача (VAZZ_TASK_*) и её цель. Ссылка живёт недолго: чистится по таймауту и при удалении цели.
	var/patrol_task = 0
	var/mob/living/patrol_task_target
	var/patrol_task_until = 0
	var/next_task_scan = 0
	/// До какого момента Vazz занят крашером или едой (патруль в это время его не двигает)
	var/task_busy_until = 0
	var/crusher_ready_at = 0
	/// Сколько ударов уже ушло в породу (ключ "x:y:z") и какие породы пробить не вышло
	var/list/crusher_rock_attempts = list()
	var/list/crusher_failed_rocks = list()
	var/feed_ready_at = 0
	/// Сколько здоровья уже восстановлено питанием
	var/feed_total = 0
	/// Защита от фарма: ключ клетки места —> когда там снова можно лечиться
	var/list/feed_sites = list()
	/// Редкие сдержанные реплики. TODO: заменить на утверждённые тексты.
	var/list/quiet_lines = list(
		"...Не спеши.",
		"...Всё это я уже видел.",
		"...Тише.",
	)

/obj/item/gps/internal/vazz
	icon_state = null
	gpstag = "Vazzek Zrakc Signal"
	desc = "Вы не можете понять, почему сигнал искажён.."
	/// Настоящий тег, который изредка проступает сквозь помехи
	var/true_tag = "Vazzek Zrakc Signal"
	/// Символы помех
	var/static/list/glitch_glyphs = list("Ѱ", "Ж", "Ψ", "Ξ", "Ω", "Σ", "Ѫ", "Ҩ", "Ʒ", "Ŧ", "Ǯ", "Ϟ", "¤", "§")

/obj/item/gps/internal/vazz/Initialize(mapload)
	. = ..()
	// Родитель вписывает тег в name, а name могут увидеть призраки через orbit. И мне лично нужно чтобы на тестах проще искать
	name = "Искажённый сигнал"
	START_PROCESSING(SSobj, src)

/obj/item/gps/internal/vazz/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gps/internal/vazz/process(seconds_per_tick)
	if(prob(10))
		gpstag = true_tag
		return
	var/new_tag = ""
	for(var/i in 1 to rand(5, 7))
		new_tag += pick(glitch_glyphs)
	new_tag += " "
	for(var/i in 1 to rand(4, 6))
		new_tag += pick(glitch_glyphs)
	gpstag = new_tag

/mob/living/simple_animal/hostile/megafauna/vazz/get_ru_names()
	return alist(
		NOMINATIVE = "Вазз",
		GENITIVE = "Вазза",
		DATIVE = "Ваззу",
		ACCUSATIVE = "Вазза",
		INSTRUMENTAL = "Ваззом",
		PREPOSITIONAL = "Ваззе",
	)

/mob/living/simple_animal/hostile/megafauna/vazz/Initialize(mapload)
	. = ..()
	if(true_spawn)
		for(var/mob/living/simple_animal/hostile/megafauna/vazz/B in GLOB.alive_mob_list)
			if(B != src)
				return INITIALIZE_HINT_QDEL // There can be only one
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/boss_music, 'sound/music/boss/boundless_boss.ogg', COMSIG_HOSTILE_FOUND_TARGET)
	addtimer(CALLBACK(src, PROC_REF(vazz_guard_tick)), 2)
	patrol_home = get_turf(src)
	if(patrol_enabled)
		addtimer(CALLBACK(src, PROC_REF(vazz_patrol_tick)), VAZZ_PATROL_TICK)

/mob/living/simple_animal/hostile/megafauna/vazz/Destroy()
	vazz_clear_arena()
	vazz_shield_off()
	// Таймеры (guard, patrol, позы) сами обрываются на проверке QDELETED. Здесь только отпускаем ссылки.
	patrol_enabled = FALSE
	patrol_home = null
	patrol_destination = null
	patrol_last_pos = null
	patrol_task_target = null
	patrol_route = null
	crusher_rock_attempts = null
	crusher_failed_rocks = null
	feed_sites = null
	return ..()

/mob/living/simple_animal/hostile/megafauna/vazz/death(gibbed)
	vazz_clear_arena()
	vazz_shield_off()
	new /obj/effect/temp_visual/dir_setting/vazz(get_turf(src), dir)
	return ..()

/obj/effect/temp_visual/dir_setting/vazz
	icon_state = "cultout"

/// Пока активен щит арены, урон по Vazz не проходит. Лечение и принудительный урон (forced) работают.
/mob/living/simple_animal/hostile/megafauna/vazz/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	if(!forced && amount > 0 && world.time < arena_shield_until)
		return FALSE
	return ..()
/// Пока активен щит арены, Vazz стоит на месте. Телепорты и рывки (forceMove) это не блокирует.
/mob/living/simple_animal/hostile/megafauna/vazz/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(world.time < arena_shield_until)
		return FALSE
	return ..()

// --------------------------------------------------------------------------
// Управление игроком
// --------------------------------------------------------------------------

/datum/action/innate/megafauna_attack/vazz_charge
	name = "Рывок"
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = span_colossus_alt("Вы готовитесь к рывку.")
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/vazz_cross
	name = "Крестовой разряд"
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = span_colossus_alt("Вы готовите крестовой разряд.")
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/vazz_shot
	name = "Выстрел с телепортом"
	button_icon = 'icons/obj/weapons/projectile.dmi'
	button_icon_state = "shotgun"
	chosen_message = span_colossus_alt("Вы телепортируетесь и стреляете веером.")
	chosen_attack_num = 3

/datum/action/innate/megafauna_attack/vazz_blasters
	name = "Бластеры черепа"
	button_icon = 'icons/obj/weapons/projectile.dmi'
	button_icon_state = "pistol"
	chosen_message = span_colossus_alt("Вы призываете черепа.")
	chosen_attack_num = 4

/datum/action/innate/megafauna_attack/vazz_arena
	name = "Арена"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "at_shield2"
	chosen_message = span_colossus_alt("Вы замыкаете арену вокруг цели.")
	chosen_attack_num = 5

// --------------------------------------------------------------------------
// Ближний бой и выбор атаки
// --------------------------------------------------------------------------

/mob/living/simple_animal/hostile/megafauna/vazz/AttackingTarget()
	if(recovery_time >= world.time)
		return
	// Если цель — труп, а рядом есть живые, переключаемся на них
	if(isliving(target))
		var/mob/living/current_target = target
		if(current_target.stat == DEAD)
			var/mob/living/living_target = vazz_find_living_target()
			if(living_target)
				GiveTarget(living_target)
				return
	melee_streak++
	return ..()
/// Выбор цели: пока есть живые, трупы не рассматриваются
/mob/living/simple_animal/hostile/megafauna/vazz/PickTarget(list/Targets)
	var/list/living_targets = list()
	for(var/atom/candidate in Targets)
		if(isliving(candidate))
			var/mob/living/L = candidate
			if(L.stat != DEAD)
				living_targets += L
	if(length(living_targets))
		return ..(living_targets)
	return ..()

/mob/living/simple_animal/hostile/megafauna/vazz/OpenFire(the_target)
	if(stat == DEAD || world.time < busy_until || world.time < ranged_cooldown)
		return
	var/atom/aim_target = the_target || target
	// Трупы не цель, если рядом есть живые
	if(!client && isliving(aim_target))
		var/mob/living/aim_living = aim_target
		if(aim_living.stat == DEAD)
			aim_target = vazz_find_living_target() || aim_target
	var/turf/aim_turf = get_turf(aim_target)
	// Цель на другом Z—уровне или вне карты — не атакуем
	if(!aim_turf || aim_turf.z != z)
		return
	// Окно ближнего боя: пока цель рядом, Vazz дерётся, а не запускает следующую атаку
	if(!client && world.time < melee_until && get_dist(src, aim_turf) <= VAZZ_MELEE_WINDOW_DISTANCE)
		return

	var/attack_type
	if(client)
		attack_type = chosen_attack
	else
		attack_type = vazz_choose_attack(aim_turf)
	melee_streak = 0

	switch(attack_type)
		if(VAZZ_ATTACK_CHARGE)
			vazz_charge_attack(aim_target)
		if(VAZZ_ATTACK_CROSS)
			vazz_cross_attack(aim_target)
		if(VAZZ_ATTACK_SHOT)
			vazz_shot_attack(aim_target)
		if(VAZZ_ATTACK_BLASTERS)
			vazz_blasters_attack(aim_target)
		if(VAZZ_ATTACK_ARENA)
			vazz_arena_attack(aim_target)

/// Выбор следующей атаки для ИИ. Приоритет: арена, выстрел с телепортом (против "прилипших"), рывок (сближение), основной цикл.
/// Арена в обычном режиме одна: после неё начинается вторая фаза. В хардмоде арена повторяется по кулдауну.
/// Вторая фаза: Vazz не отступает от "прилипших" игроков и использует рывок как сближение с меньшей дистанции.
/// Основной цикл (attack_sequence) от этого не меняется.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_choose_attack(turf/aim_turf)
	if(vazz_is_wounded() && world.time >= arena_ready_at && (enraged || !phase_two))
		return VAZZ_ATTACK_ARENA
	if(!phase_two && melee_streak >= VAZZ_MELEE_STREAK_LIMIT)
		// Цель слишком долго стоит вплотную — уходим и стреляем, цикл не сдвигаем
		return VAZZ_ATTACK_SHOT
	var/charge_distance = phase_two ? VAZZ_PHASE2_CHARGE_FAR_DISTANCE : VAZZ_CHARGE_FAR_DISTANCE
	if(world.time >= charge_ready_at && get_dist(src, aim_turf) >= charge_distance)
		return VAZZ_ATTACK_CHARGE
	var/next_attack = attack_sequence[combo_step]
	combo_step = (combo_step % length(attack_sequence)) + 1
	return next_attack

// --------------------------------------------------------------------------
// Хардмод (enraged)
// --------------------------------------------------------------------------

/mob/living/simple_animal/hostile/megafauna/vazz/enrage()
	. = ..()
	if(!.)
		return
	visible_message(span_warning("Свет в пластинах H.E.C.K. Mk II на [declent_ru(PREPOSITIONAL)] становится ярче."))
	for(var/mob/living/L in range(aggro_vision_range, src))
		vazz_bind(L)

/mob/living/simple_animal/hostile/megafauna/vazz/unrage()
	. = ..()
	for(var/mob/living/L in GLOB.mob_list)
		var/datum/status_effect/bubblegum_curse/curse = L.has_status_effect(/datum/status_effect/bubblegum_curse/vazz)
		if(curse && curse.source_UID == UID())
			qdel(curse)

/mob/living/simple_animal/hostile/megafauna/vazz/GiveTarget(new_target)
	. = ..()
	if(. && enraged && isliving(target))
		vazz_bind(target)

/// Накладывает проклятие, не дающее сбежать. Временно используется существующий эффект Bubblegum.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_bind(mob/living/L)
	if(!L.client || L.stat == DEAD || L.has_status_effect(/datum/status_effect/bubblegum_curse) || L.has_status_effect(/datum/status_effect/bubblegum_curse/vazz))
		return
	L.apply_status_effect(/datum/status_effect/bubblegum_curse/vazz, src)

// --------------------------------------------------------------------------
// Состояние и масштабирование
// --------------------------------------------------------------------------

/// Ниже половины здоровья Vazz действует жёстче
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_is_wounded()
	return health <= maxHealth * 0.5

/// Ускоряет подготовку и восстановление: ниже 50% здоровья и в режиме enraged
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_time(base_time)
	var/multiplier = 1
	if(vazz_is_wounded())
		multiplier *= 0.85
	if(enraged)
		multiplier *= 0.85
	return round(base_time * multiplier)

/// Режим enraged усиливает урон
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_damage(base_damage)
	return round(base_damage * (enraged ? 1.25 : 1))

/// Блокирует новые атаки и ближний бой на время всей атаки (подготовка + восстановление),
/// после чего открывается окно ближнего боя (во второй фазе оно дольше).
/// recovery — последняя часть duration, которая является восстановлением (см. VAZZ_SWAT_DURING_RECOVERY).
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_lock_state(duration, recovery = 0)
	busy_until = world.time + duration
	swat_until = busy_until - (VAZZ_SWAT_DURING_RECOVERY ? 0 : recovery)
	melee_until = busy_until + (phase_two ? VAZZ_PHASE2_MELEE_WINDOW : VAZZ_MELEE_WINDOW)
	SetRecoveryTime(duration)
	walk(src, 0)

/// Редкая сдержанная реплика
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_speak(chance)
	if(length(quiet_lines) && prob(chance))
		say(pick(quiet_lines))

/// Страж Vazz, срабатывает каждые 0.2 секунды, пока он жив:
/// 1) не даёт трофеям вроде крыла наблюдателя откладывать его атаки (они двигают ranged_cooldown);
/// 2) отмахивается от тех, кто стоит вплотную, пока он занят атакой (подробнее — VAZZ_SWAT_DURING_RECOVERY).
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_guard_tick()
	if(QDELETED(src) || stat == DEAD)
		return
	var/cooldown_cap = max(world.time, busy_until)
	if(ranged_cooldown > cooldown_cap)
		ranged_cooldown = cooldown_cap
	if(world.time < swat_until && world.time >= next_swat_at)
		vazz_swat()
	addtimer(CALLBACK(src, PROC_REF(vazz_guard_tick)), 2)

/// Отмашка: урон всем живым вокруг (диагонали тоже), раз в VAZZ_SWAT_INTERVAL
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_swat()
	var/list/already_hit = list()
	for(var/mob/living/victim in range(1, src))
		vazz_hit(victim, vazz_damage(VAZZ_SWAT_DAMAGE), BRUTE, already_hit, "[DECLENT_RU_CAP(src, NOMINATIVE)] отмахивается от вас.")
	if(length(already_hit))
		next_swat_at = world.time + VAZZ_SWAT_INTERVAL
		playsound(src, 'sound/weapons/rapierhit.ogg', 100, TRUE, -1)

/// Ближайшая живая цель. Трупов Vazz касается в последнюю очередь.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_find_living_target()
	var/mob/living/best_target
	var/best_dist = INFINITY
	for(var/mob/living/L in range(aggro_vision_range, src))
		if(L == src || L.stat == DEAD || length(faction & L.faction))
			continue
		var/target_dist = get_dist(src, L)
		if(target_dist < best_dist)
			best_dist = target_dist
			best_target = L
	return best_target

/// Щит: на время duration Vazz неуязвим (см. adjustHealth). Снимается сам, даже если атака оборвалась.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_shield_on(duration)
	arena_shield_until = world.time + duration
	if(arena_shield_overlay)
		return
	arena_shield_overlay = mutable_appearance('icons/effects/effects.dmi', "shield-cult")
	add_overlay(arena_shield_overlay)
	addtimer(CALLBACK(src, PROC_REF(vazz_shield_expire)), duration + 1 SECONDS)

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_shield_expire()
	if(world.time >= arena_shield_until)
		vazz_shield_off()

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_shield_off()
	arena_shield_until = 0
	if(!arena_shield_overlay)
		return
	cut_overlay(arena_shield_overlay)
	arena_shield_overlay = null

/// Мгновенное перемещение с дымом и остаточным изображением
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_blink(turf/destination)
	var/turf/origin = get_turf(src)
	if(!origin || !destination)
		return
	new /obj/effect/temp_visual/decoy/fading/halfsecond(origin, src)
	new /obj/effect/temp_visual/small_smoke/halfsecond(origin)
	forceMove(destination)
	new /obj/effect/temp_visual/small_smoke/halfsecond(destination)
	playsound(destination, 'sound/weapons/punchmiss.ogg', 40, TRUE, -1)

// --------------------------------------------------------------------------
// Позы. Все спрайты лежат в основном icons/mob/lavaland/vazz.dmi отдельными icon_state:
//   vazz_crusher       — крашер (уже есть): удар по фауне и по породе
//   vazz_feed          — питание: склонился над трупом
//   vazz_charge_windup — рывок: подготовка
//   vazz_charge        — сам рывок
//   vazz_cross         — крестовой разряд
//   vazz_blasters      — бластеры черепов
//   vazz_shot_hop      — выстрел: отскок
//   vazz_shot_aim      — выстрел: показывает веер
//   vazz_shot_fire     — выстрел: сам выстрел
//   vazz_shot_reload   — выстрел: перезарядка
//   vazz_arena         — арена
// Нет нужного состояния в файле — Vazz остаётся в основном спрайте, ничего не ломается.
// --------------------------------------------------------------------------

/// Показывает позу на duration, затем возвращает основной спрайт (icon_living).
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_pose(state, duration)
	var/static/list/known_states
	if(!known_states)
		known_states = icon_states(icon)
	if(!(state in known_states) || duration <= 0)
		return
	icon_state = state
	pose_until = world.time + duration
	addtimer(CALLBACK(src, PROC_REF(vazz_pose_expire)), duration)

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_pose_expire()
	if(QDELETED(src) || stat == DEAD || world.time < pose_until)
		return
	icon_state = icon_living

/// Сбрасывает позу сразу
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_pose_clear()
	pose_until = 0
	if(stat != DEAD)
		icon_state = icon_living

/// Сбрасывает позу задачи, но не трогает позу боевой атаки, если бой уже начался
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_task_pose_clear()
	if(!target && world.time >= busy_until)
		vazz_pose_clear()

// --------------------------------------------------------------------------
// Патруль. Пока цели нет, Vazz ходит по маршруту. GPS-сигнал при этом движется (внутренний GPS следует за мобом),
// земля дрожит, а потом появляется он сам. Идёт бой — патруль молчит и только запоминает, где цель:
// если контакт потерян, Vazz доходит до этой точки и возвращается на маршрут.
// --------------------------------------------------------------------------

/// Точка маршрута вокруг места появления. Проходимая клетка в той же зоне (area), что и место появления,
/// чтобы Vazz не уходил в посторонние помещения. Над лавой и пропастями ему можно: он летает.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_pick_patrol_turf()
	var/turf/home = patrol_home
	if(!home)
		return null
	var/area/home_area = get_area(home)
	for(var/attempt in 1 to 15)
		var/turf/candidate = locate(clamp(home.x + rand(-VAZZ_PATROL_RADIUS, VAZZ_PATROL_RADIUS), 2, world.maxx - 1), clamp(home.y + rand(-VAZZ_PATROL_RADIUS, VAZZ_PATROL_RADIUS), 2, world.maxy - 1), home.z)
		if(!candidate || candidate.density || candidate.is_blocked_turf(exclude_mobs = TRUE))
			continue
		if(get_area(candidate) != home_area)
			continue
		return candidate
	return null

/// Хардмод: ближайший живой игрок на этом уровне в пределах VAZZ_PATROL_HUNT_RANGE
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_nearest_player_turf()
	var/turf/best_turf
	var/best_dist = VAZZ_PATROL_HUNT_RANGE
	for(var/mob/living/L in GLOB.player_list)
		if(L.stat == DEAD || length(faction & L.faction))
			continue
		var/turf/L_turf = get_turf(L)
		if(!L_turf || L_turf.z != z)
			continue
		var/dist = get_dist(src, L_turf)
		if(dist <= best_dist)
			best_dist = dist
			best_turf = L_turf
	return best_turf

/// Следующая точка: по кругу из VAZZ_PATROL_POINTS точек (маршрут строится при первом вызове).
/// В хардмоде иногда вместо точки маршрута — ближайший игрок.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_next_patrol_destination()
	if(enraged && prob(VAZZ_PATROL_HUNT_CHANCE))
		var/turf/hunt_turf = vazz_nearest_player_turf()
		if(hunt_turf)
			return hunt_turf
	if(!length(patrol_route))
		for(var/i in 1 to VAZZ_PATROL_POINTS)
			var/turf/point = vazz_pick_patrol_turf()
			if(point)
				patrol_route += point
		if(!length(patrol_route))
			return null
	patrol_index = (patrol_index % length(patrol_route)) + 1
	return patrol_route[patrol_index]

/// Тяжёлый шаг: звук, тряска камеры рядом и редкое сообщение подальше
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_tremor()
	playsound(src, 'sound/effects/bang.ogg', 25, TRUE, 12) // TODO(звук): тяжёлые шаги
	for(var/mob/M in range(VAZZ_TREMOR_RANGE, src))
		if(!M.client)
			continue
		if(get_dist(src, M) <= VAZZ_TREMOR_CAMERA_RANGE)
			shake_camera(M, 2, 1)
		else if(prob(10))
			to_chat(M, span_notice("Земля под ногами отдаётся глухой дрожью."))

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_task_clear()
	patrol_task = 0
	patrol_task_target = null
	patrol_task_until = 0

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_patrol_tick()
	if(QDELETED(src) || stat == DEAD)
		return
	addtimer(CALLBACK(src, PROC_REF(vazz_patrol_tick)), VAZZ_PATROL_TICK)
	// Патруль никогда не мешает бою, атакам, арене и телепортам: в любом из этих состояний он просто молчит
	if(!patrol_enabled || client || world.time < busy_until || world.time < arena_shield_until || world.time < task_busy_until)
		return
	if(target)
		// Идёт бой: запоминаем, где цель. Потеряет её — дойдёт до этой точки и вернётся на маршрут.
		var/turf/seen_turf = get_turf(target)
		if(seen_turf)
			patrol_destination = seen_turf
		patrol_last_pos = null
		patrol_stuck = 0
		vazz_task_clear()
		return
	if(world.time < patrol_pause_until)
		return
	var/turf/here = get_turf(src)
	if(!here)
		return

	// Задача с целью: крашер по фауне или питание
	if(patrol_task_target && (!vazz_task_target_valid() || world.time > patrol_task_until))
		vazz_task_clear()
	if(!patrol_task_target && world.time >= next_task_scan)
		next_task_scan = world.time + VAZZ_TASK_SCAN_INTERVAL
		vazz_pick_task()
	if(patrol_task_target)
		var/turf/task_turf = get_turf(patrol_task_target)
		if(!task_turf)
			vazz_task_clear()
			return
		if(get_dist(here, task_turf) <= 1)
			var/mob/living/task_mob = patrol_task_target
			var/finished_task = patrol_task
			vazz_task_clear()
			walk(src, 0)
			if(finished_task == VAZZ_TASK_FEED)
				INVOKE_ASYNC(src, PROC_REF(vazz_feed), task_mob)
			else
				INVOKE_ASYNC(src, PROC_REF(vazz_crush_fauna), task_mob)
			return
		// К цели задачи идём, но породу ради неё не пробиваем: это только для маршрута
		vazz_patrol_step(here, task_turf, 1, FALSE)
		return

	// Маршрут
	if(patrol_destination && get_dist(here, patrol_destination) <= VAZZ_PATROL_ARRIVE_DISTANCE)
		patrol_destination = null
		patrol_last_pos = null
		patrol_stuck = 0
		patrol_giveups = 0
		patrol_pause_until = world.time + rand(VAZZ_PATROL_PAUSE_MIN, VAZZ_PATROL_PAUSE_MAX)
		walk(src, 0)
		vazz_speak(10)
		return
	if(!patrol_destination)
		patrol_destination = vazz_next_patrol_destination()
		patrol_last_pos = null
		patrol_stuck = 0
		if(!patrol_destination)
			return
	vazz_patrol_step(here, patrol_destination, 0, TRUE)

/// Один шаг патруля к goal. Если Vazz застрял: при allow_dig пробует пробить породу на пути, иначе или если не вышло —
/// бросает цель (после нескольких неудач подряд маршрут перестраивается).
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_patrol_step(turf/here, turf/goal, min_dist, allow_dig)
	if(patrol_last_pos && here == patrol_last_pos)
		patrol_stuck++
	else
		patrol_stuck = 0
		if(patrol_last_pos)
			vazz_tremor() // сдвинулись с прошлого тика
	patrol_last_pos = here
	if(patrol_stuck >= VAZZ_PATROL_STUCK_LIMIT)
		patrol_stuck = 0
		if(allow_dig && vazz_clear_path(here, goal))
			return
		vazz_patrol_give_up()
		return
	walk_to(src, goal, min_dist, move_to_delay)

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_patrol_give_up()
	walk(src, 0)
	vazz_task_clear()
	patrol_destination = null
	patrol_last_pos = null
	patrol_stuck = 0
	patrol_giveups++
	if(patrol_giveups >= VAZZ_PATROL_GIVEUP_LIMIT)
		// Маршрут негодный: строим новый и немного отдыхаем. Так Vazz не мечется между недостижимыми точками бесконечно.
		patrol_route = list()
		patrol_index = 0
		patrol_giveups = 0
		patrol_pause_until = world.time + VAZZ_PATROL_PAUSE_MAX * 2

// --------------------------------------------------------------------------
// Крашер: порода на пути
// --------------------------------------------------------------------------

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_rock_key(turf/T)
	return "[T.x]:[T.y]:[T.z]"

/// Можно ли пробить эту клетку. Только разрушаемая порода (mineral turf) в зоне Vazz, без структур на клетке
/// (спавнеры, постройки), без газибтонита (он взрывается) и без пород, которые уже не поддались.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_can_crush_rock(turf/T)
	if(!T || !ismineralturf(T) || istype(T, /turf/simulated/mineral/gibtonite))
		return FALSE
	if(!patrol_home || get_area(T) != get_area(patrol_home))
		return FALSE
	if(vazz_rock_key(T) in crusher_failed_rocks)
		return FALSE
	for(var/obj/O in T)
		if(O.density || istype(O, isstructure(O)))
			return FALSE
	return TRUE

/// Пробует найти породу, блокирующую путь к goal, и запускает удар. Возвращает TRUE, если удар запущен.
/// Смотрим на клетку по прямой; в стороны — только если прямая клетка непроходима.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_clear_path(turf/here, turf/goal)
	var/dir_to = get_dir(here, goal)
	if(!dir_to)
		return FALSE
	var/turf/straight = get_step(here, dir_to)
	if(!straight || !straight.density)
		return FALSE
	var/list/candidates = list(straight, get_step(here, turn(dir_to, 45)), get_step(here, turn(dir_to, -45)))
	for(var/turf/candidate in candidates)
		if(vazz_can_crush_rock(candidate))
			INVOKE_ASYNC(src, PROC_REF(vazz_crush_rock), candidate)
			return TRUE
	return FALSE

/// Выстрел дестабилизатора в соседнюю породу. Порода разрушается штатно: снаряд сам вызывает attempt_drill().
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_fire_crusher(turf/rock)
	var/turf/startloc = get_turf(src)
	if(!startloc || !rock)
		return
	var/obj/projectile/destabilizer/shot = new(startloc)
	shot.firer = src
	shot.preparePixelProjectile(rock, src)
	shot.fire(get_angle(startloc, rock))

/// Если крашер прерван (появилась цель): снимаем занятость и позу
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_crusher_abort()
	task_busy_until = 0
	vazz_task_pose_clear()

/// Удар крашером по породе. Прерывается, как только у Vazz появляется цель. Не больше VAZZ_CRUSHER_ROCK_ATTEMPTS ударов
/// на одну породу: если она не поддалась, помечается как непроходимая, и Vazz выбирает другой путь.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_crush_rock(turf/rock)
	if(!vazz_can_crush_rock(rock))
		return
	// Турф после разрушения заменяется новым объектом, поэтому запоминаем координаты, а не ссылку
	var/rock_x = rock.x
	var/rock_y = rock.y
	var/rock_z = rock.z
	var/rock_key = vazz_rock_key(rock)
	task_busy_until = world.time + VAZZ_CRUSHER_WINDUP + VAZZ_CRUSHER_STRIKE_TIME + 10
	walk(src, 0)
	face_atom(rock)
	visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] замахивается крашером на каменную породу."))
	vazz_pose("vazz_crusher", VAZZ_CRUSHER_WINDUP + VAZZ_CRUSHER_STRIKE_TIME)
	SLEEP_CHECK_DEATH(src, VAZZ_CRUSHER_WINDUP)
	if(target || client)
		vazz_crusher_abort() // появилась цель: бой важнее
		return
	vazz_fire_crusher(rock)
	SLEEP_CHECK_DEATH(src, VAZZ_CRUSHER_STRIKE_TIME)
	var/turf/after = locate(rock_x, rock_y, rock_z)
	if(after && ismineralturf(after))
		var/attempts = (crusher_rock_attempts[rock_key] || 0) + 1
		if(attempts >= VAZZ_CRUSHER_ROCK_ATTEMPTS)
			crusher_failed_rocks += rock_key
			crusher_rock_attempts -= rock_key
			if(length(crusher_failed_rocks) > 40)
				crusher_failed_rocks.Cut(1, 11)
		else
			crusher_rock_attempts[rock_key] = attempts
	else
		crusher_rock_attempts -= rock_key
	if(length(crusher_rock_attempts) > 40)
		crusher_rock_attempts.Cut()
	patrol_last_pos = null
	patrol_stuck = 0
	task_busy_until = 0
	vazz_task_pose_clear()

// --------------------------------------------------------------------------
// Крашер: обычная фауна Лаваленда
// --------------------------------------------------------------------------

/// Подходящая добыча: живая обычная фауна Лаваленда (фракция mining, но не boss). Исключены игроки и всё с разумом,
/// другая мегафауна, союзные и прирученные существа (у них фракция другая) и всё, что не стоит на полу.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_valid_prey(mob/living/L)
	if(QDELETED(L) || L == src || L.stat == DEAD || L.client || L.mind)
		return FALSE
	if(istype(L, ismegafauna(L)) || ishuman(L))
		return FALSE
	if(!("mining" in L.faction) || ("boss" in L.faction))
		return FALSE
	return isturf(L.loc)

/// Подходящий труп для питания: мёртвая обычная фауна по тем же правилам, в месте, где Vazz недавно не лечился.
/// Тела игроков не подходят намеренно: они нужны для спасения и воскрешения, а питание ими награждало бы убийство игроков.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_valid_corpse(mob/living/L)
	if(QDELETED(L) || L == src || L.stat != DEAD || L.client || L.mind)
		return FALSE
	if(istype(L, ismegafauna(L)) || ishuman(L))
		return FALSE
	if(!("mining" in L.faction) || ("boss" in L.faction))
		return FALSE
	var/turf/T = get_turf(L)
	if(!T || !isturf(L.loc))
		return FALSE
	var/expires = feed_sites[vazz_feed_site_key(T)]
	return !(expires > world.time)

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_feed_site_key(turf/T)
	return "[T.z]:[round(T.x / VAZZ_FEED_SITE_GRID)]:[round(T.y / VAZZ_FEED_SITE_GRID)]"

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_task_target_valid()
	if(patrol_task == VAZZ_TASK_FEED)
		return vazz_valid_corpse(patrol_task_target)
	return vazz_valid_prey(patrol_task_target)

/// Ближайшая подходящая цель рядом (труп или живая добыча)
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_find_nearest(find_corpse)
	var/mob/living/best
	var/best_dist = VAZZ_TASK_SCAN_RANGE + 1
	for(var/mob/living/L in range(VAZZ_TASK_SCAN_RANGE, src))
		if(find_corpse ? !vazz_valid_corpse(L) : !vazz_valid_prey(L))
			continue
		var/dist = get_dist(src, L)
		if(dist < best_dist)
			best_dist = dist
			best = L
	return best

/// Выбор задачи: сначала питание (если ранен), потом иногда крашер по фауне
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_pick_task()
	if(health <= maxHealth * VAZZ_FEED_HEALTH_THRESHOLD && world.time >= feed_ready_at && feed_total < maxHealth * VAZZ_FEED_TOTAL_CAP_FRACTION)
		var/mob/living/corpse = vazz_find_nearest(TRUE)
		if(corpse)
			patrol_task = VAZZ_TASK_FEED
			patrol_task_target = corpse
			patrol_task_until = world.time + VAZZ_TASK_TIMEOUT
			return
	if(world.time >= crusher_ready_at && prob(VAZZ_CRUSHER_CHANCE))
		var/mob/living/prey = vazz_find_nearest(FALSE)
		if(prey)
			patrol_task = VAZZ_TASK_CRUSH
			patrol_task_target = prey
			patrol_task_until = world.time + VAZZ_TASK_TIMEOUT

/// Тяжёлый удар крашером по фауне. Прерывается, если у Vazz появилась цель или добыча ушла/умерла.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_crush_fauna(mob/living/victim)
	if(!vazz_valid_prey(victim) || get_dist(src, victim) > 1)
		return
	task_busy_until = world.time + VAZZ_CRUSHER_WINDUP + VAZZ_CRUSHER_STRIKE_TIME + 10
	walk(src, 0)
	face_atom(victim)
	visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] поднимает крашер над [victim]."))
	vazz_pose("vazz_crusher", VAZZ_CRUSHER_WINDUP + VAZZ_CRUSHER_STRIKE_TIME)
	SLEEP_CHECK_DEATH(src, VAZZ_CRUSHER_WINDUP)
	if(target || client || !vazz_valid_prey(victim) || get_dist(src, victim) > 2)
		vazz_crusher_abort()
		return
	new /obj/effect/temp_visual/kinetic_blast(get_turf(victim))
	playsound(victim, 'sound/effects/bang.ogg', 70, TRUE)
	victim.adjustBruteLoss(max(VAZZ_CRUSHER_FAUNA_DAMAGE, victim.maxHealth))
	SLEEP_CHECK_DEATH(src, VAZZ_CRUSHER_STRIKE_TIME)
	crusher_ready_at = world.time + VAZZ_CRUSHER_COOLDOWN
	task_busy_until = 0
	vazz_task_pose_clear()

// --------------------------------------------------------------------------
// Питание трупами. Единственный источник самолечения.
// Защита от бесконечного лечения: труп съедается целиком (повторно не используется), между кормлениями кулдаун,
// в одном месте (клетка VAZZ_FEED_SITE_GRID) нельзя лечиться чаще VAZZ_FEED_SITE_COOLDOWN, и есть потолок суммарного
// лечения за жизнь. Прервать кормление можно уроном: оно сбрасывается, труп не тратится.
// --------------------------------------------------------------------------

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_feed(mob/living/corpse)
	if(!vazz_valid_corpse(corpse) || get_dist(src, corpse) > 1)
		return
	task_busy_until = world.time + VAZZ_FEED_TIME + 10
	walk(src, 0)
	face_atom(corpse)
	var/start_health = health
	visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] склоняется над [corpse]."))
	vazz_pose("vazz_feed", VAZZ_FEED_TIME)
	playsound(src, 'sound/weapons/punchmiss.ogg', 40, TRUE, -1) // TODO(звук): поедание
	SLEEP_CHECK_DEATH(src, VAZZ_FEED_TIME)
	if(target || client || health < start_health || !vazz_valid_corpse(corpse) || get_dist(src, corpse) > 1)
		vazz_crusher_abort()
		return
	var/heal = min(round(maxHealth * VAZZ_FEED_HEAL_FRACTION), round(maxHealth * VAZZ_FEED_TOTAL_CAP_FRACTION) - feed_total, maxHealth - health)
	if(heal <= 0)
		vazz_crusher_abort()
		return
	var/turf/corpse_turf = get_turf(corpse)
	feed_sites[vazz_feed_site_key(corpse_turf)] = world.time + VAZZ_FEED_SITE_COOLDOWN
	adjustHealth(-heal)
	feed_total += heal
	feed_ready_at = world.time + VAZZ_FEED_COOLDOWN
	visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] поглощает останки [corpse]."))
	qdel(corpse)
	task_busy_until = 0
	vazz_task_pose_clear()

// --------------------------------------------------------------------------
// Построение фигур. Все клетки и точки считаются ОДИН раз в начале телеграфа.
// figures — ассоциативный список: якорь —> список конечных клеток лучей.
// danger — список клеток, по которым будет нанесён урон.
// --------------------------------------------------------------------------

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_new_anchor(turf/where, lifetime = VAZZ_ANCHOR_LIFETIME, anchor_type = /obj/effect/vazz_beam_anchor)
	var/obj/effect/vazz_beam_anchor/anchor = new anchor_type(where)
	QDEL_IN(anchor, lifetime)
	return anchor

/// Крест из четырёх лучей. diagonal = TRUE даёт "X" вместо "+".
/// Луч останавливается у стены (плотного турфа) и у края карты (get_step вернёт null).
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_add_cross(list/figures, list/danger, turf/center, arm_length, diagonal)
	if(!center)
		return
	var/list/arm_dirs
	if(diagonal)
		arm_dirs = list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	else
		arm_dirs = list(NORTH, SOUTH, EAST, WEST)
	var/list/ends = list()
	danger |= center
	for(var/arm_dir in arm_dirs)
		var/turf/arm_end
		var/turf/step_turf = center
		for(var/i in 1 to arm_length)
			step_turf = get_step(step_turf, arm_dir)
			if(!step_turf || step_turf.density)
				break
			danger |= step_turf
			arm_end = step_turf
		if(arm_end)
			ends += arm_end
	figures[vazz_new_anchor(center)] = ends

/// Клетка на расстоянии range от start под углом beam_angle (как у Legion: 0 — север, по часовой стрелке).
/// clamp не даёт вылезти за карту.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_turf_at_angle(turf/start, beam_angle, range)
	var/dir_x = sin(beam_angle)
	var/dir_y = cos(beam_angle)
	// Нормируем так, чтобы по большей оси длина была ровно range клеток
	var/major = max(abs(dir_x), abs(dir_y))
	return locate(clamp(round(start.x + dir_x / major * range), 1, world.maxx), clamp(round(start.y + dir_y / major * range), 1, world.maxy), start.z)

/// Дальняя точка луча от start в сторону aim. Угол берётся тем же get_angle(), что и у Legion.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_far_turf(turf/start, turf/aim, range)
	return vazz_turf_at_angle(start, get_angle(start, aim), range)

/// Прямой луч от start в сторону aim. Клетки луча — через существующий get_line().
/// Возвращает созданный источник луча или null, если луч упёрся в стену сразу.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_add_lance(list/figures, list/danger, turf/start, turf/aim, range, anchor_type = /obj/effect/vazz_beam_anchor, anchor_lifetime = VAZZ_ANCHOR_LIFETIME)
	if(!start || !aim)
		return
	var/turf/far_turf = vazz_far_turf(start, aim, range)
	if(!far_turf)
		return
	var/turf/lance_end
	for(var/turf/lance_turf as anything in get_line(start, far_turf))
		if(lance_turf == start)
			continue
		if(lance_turf.density)
			break
		danger |= lance_turf
		lance_end = lance_turf
	if(!lance_end)
		return
	var/obj/effect/vazz_beam_anchor/anchor = vazz_new_anchor(start, anchor_lifetime, anchor_type)
	figures[anchor] = list(lance_end)
	return anchor

/// Подбирает клетку вокруг aim_turf на расстоянии min_dist..max_dist. Путь до цели не должен упираться в стену.
/// solid_ground = TRUE: клетка не должна быть лавой, пропастью или занята преградой (для самого Vazz).
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_pick_turf_around(turf/aim_turf, min_dist, max_dist, solid_ground = FALSE)
	for(var/attempt in 1 to 6)
		var/pick_angle = rand(0, 359)
		var/pick_dist = rand(min_dist, max_dist)
		var/turf/candidate = locate(round(aim_turf.x + sin(pick_angle) * pick_dist), round(aim_turf.y + cos(pick_angle) * pick_dist), aim_turf.z)
		if(!candidate || candidate.density)
			continue
		if(solid_ground && (islava(candidate) || ischasm(candidate) || candidate.is_blocked_turf(exclude_mobs = TRUE)))
			continue
		var/blocked = FALSE
		for(var/turf/line_turf as anything in get_line(candidate, aim_turf))
			if(line_turf.density)
				blocked = TRUE
				break
		if(!blocked)
			return candidate
	return null

// --------------------------------------------------------------------------
// Отрисовка, урон, снаряды
// --------------------------------------------------------------------------

/// Рисует лучи для всех фигур. Для телеграфа и для настоящего разряда используются разные beam_type.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_draw(list/figures, beam_time, beam_type)
	for(var/obj/effect/vazz_beam_anchor/anchor in figures)
		for(var/turf/end_turf in figures[anchor])
			anchor.Beam(end_turf, icon_state = "death_laser", time = beam_time, maxdistance = INFINITY, beam_type = beam_type, layer = ON_EDGED_TURF_LAYER)

/// Наносит урон одной цели. Не бьёт себя, других боссов и существ той же фракции, не добивает мёртвых
/// и не бьёт одну и ту же цель дважды за один разряд. Возвращает TRUE, если урон нанесён.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_hit(mob/living/victim, damage, damage_type, list/already_hit, hit_message)
	if(victim == src || victim.stat == DEAD || (victim in already_hit) || length(faction & victim.faction))
		return FALSE
	already_hit += victim
	victim.apply_damage(damage, damage_type)
	to_chat(victim, span_userdanger(hit_message))
	return TRUE

/// Урон по клеткам danger. Каждая цель получает урон один раз за разряд.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_discharge(list/figures, list/danger, damage, atom/sound_source = src)
	playsound(get_turf(sound_source), 'sound/effects/basscannon.ogg', 200, TRUE)
	vazz_draw(figures, VAZZ_FIRE_TIME, /obj/effect/ebeam)
	var/list/already_hit = list()
	for(var/turf/danger_turf in danger)
		for(var/mob/living/victim in danger_turf)
			vazz_hit(victim, damage, BURN, already_hit, "Луч обжигает вас.")

/// Телеграф —> ожидание —> разряд. Возвращает TRUE, если Vazz пережил подготовку.
/// SLEEP_CHECK_DEATH при смерти делает return, и разряд не происходит.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_telegraph_and_fire(list/figures, list/danger, windup, damage)
	vazz_draw(figures, windup, /obj/effect/ebeam/disintegration_telegraph)
	playsound(loc, 'sound/effects/basscannon.ogg', 200, TRUE)
	SLEEP_CHECK_DEATH(src, windup)
	vazz_discharge(figures, danger, damage)
	return TRUE

/// Один снаряд. Источником для расчёта смещения служит тот, из кого он вылетает (Vazz или череп).
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_shoot_projectile(atom/source, turf/aim_turf, angle, damage = VAZZ_BOLT_DAMAGE)
	var/turf/startloc = get_turf(source)
	if(!startloc || !aim_turf || startloc == aim_turf)
		return
	// Не создаём снаряд, если он сразу упрётся в стену или преграду (иначе его "съест" стена)
	var/turf/first_step = vazz_turf_at_angle(startloc, angle, 1)
	if(!first_step || first_step.density || startloc.density || startloc.is_blocked_turf(exclude_mobs = TRUE))
		return
	var/obj/projectile/vazz_bolt/bolt = new(startloc)
	bolt.preparePixelProjectile(aim_turf, source)
	bolt.firer = src
	bolt.damage = vazz_damage(damage)
	bolt.fire(angle)

// --------------------------------------------------------------------------
// Рывок (по мотивам рывка Легионера)
// --------------------------------------------------------------------------

/// Один рывок: телеграф на 6 клеток, ожидание, быстрое движение по зафиксированному направлению.
/// Сбивает, отбрасывает и замедляет всех на пути (каждого один раз). Возвращает TRUE, если Vazz жив.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_charge_once(turf/aim_turf, windup, damage)
	var/turf/origin = get_turf(src)
	var/move_dir = get_dir(origin, aim_turf)
	if(!move_dir)
		move_dir = dir
	var/turf/telegraph_turf = origin
	for(var/i in 1 to VAZZ_CHARGE_LENGTH)
		telegraph_turf = get_step(telegraph_turf, move_dir)
		if(!telegraph_turf)
			break
		new /obj/effect/temp_visual/dragon_swoop/legionnaire/vazz(telegraph_turf)
	setDir(move_dir)
	playsound(src, 'sound/misc/demon_attack1.ogg', 200, TRUE)
	visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] подаётся вперёд, готовясь к рывку!"))
	vazz_pose("vazz_charge_windup", windup)
	SLEEP_CHECK_DEATH(src, windup)
	vazz_pose("vazz_charge", VAZZ_CHARGE_LENGTH * (VAZZ_CHARGE_STEP_TIME + 1))

	var/list/hit_targets = list()
	for(var/i in 1 to VAZZ_CHARGE_LENGTH)
		var/turf/step_turf = get_step(get_turf(src), move_dir)
		if(ismineralturf(step_turf))
			var/turf/simulated/mineral/mineral = step_turf
			mineral.attempt_drill()
			// После бурения клетка могла смениться
			step_turf = get_step(get_turf(src), move_dir)
		if(!step_turf || step_turf.density || ischasm(step_turf) || step_turf.is_blocked_turf(exclude_mobs = TRUE))
			break
		// Не выходим за край карты
		if(step_turf.x > world.maxx - 2 || step_turf.x < 2 || step_turf.y > world.maxy - 2 || step_turf.y < 2)
			break
		forceMove(step_turf)
		playsound(src, 'sound/effects/bang.ogg', 100, TRUE)
		for(var/mob/living/victim in step_turf)
			if(!vazz_hit(victim, damage, BRUTE, hit_targets, "[DECLENT_RU_CAP(src, NOMINATIVE)] сбивает вас с ног!"))
				continue
			victim.throw_at(get_edge_target_turf(src, move_dir), VAZZ_CHARGE_THROW_RANGE, 1.3, src)
			victim.Slowed(3 SECONDS)
			victim.Weaken(0.1 SECONDS)
		SLEEP_CHECK_DEATH(src, VAZZ_CHARGE_STEP_TIME)
	vazz_pose_clear()
	return TRUE

/// Рывок. Ниже 50% здоровья или в enraged — два рывка подряд, второй быстрее и заново нацелен.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_charge_attack(atom/aim_target)
	var/charge_count = (enraged || vazz_is_wounded()) ? 2 : 1
	var/windup = vazz_time(VAZZ_CHARGE_WINDUP)
	var/followup_windup = vazz_time(VAZZ_CHARGE_FOLLOWUP_WINDUP)
	var/total_time = vazz_time(VAZZ_CHARGE_RECOVERY) + windup + VAZZ_CHARGE_LENGTH * VAZZ_CHARGE_STEP_TIME
	if(charge_count > 1)
		total_time += followup_windup + VAZZ_CHARGE_LENGTH * VAZZ_CHARGE_STEP_TIME
	vazz_lock_state(total_time, vazz_time(VAZZ_CHARGE_RECOVERY))
	charge_ready_at = world.time + (phase_two ? VAZZ_PHASE2_CHARGE_COOLDOWN : VAZZ_CHARGE_COOLDOWN)
	for(var/i in 1 to charge_count)
		var/turf/aim_turf = get_turf(aim_target)
		if(!aim_turf || aim_turf.z != z)
			return
		if(!vazz_charge_once(aim_turf, (i == 1) ? windup : followup_windup, vazz_damage(VAZZ_CHARGE_DAMAGE)))
			return

// --------------------------------------------------------------------------
// Крестовой разряд "+"
// --------------------------------------------------------------------------

/// Ниже 50% здоровья или в enraged сразу за ним идёт "X" в новой позиции цели.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_cross_attack(atom/aim_target)
	var/windup = vazz_time(VAZZ_CROSS_WINDUP)
	var/follow_up = enraged || vazz_is_wounded()
	var/followup_windup = vazz_time(VAZZ_FOLLOWUP_WINDUP)
	var/recovery = vazz_time(VAZZ_CROSS_RECOVERY)
	vazz_lock_state(windup + (follow_up ? followup_windup : 0) + recovery, recovery)
	vazz_pose("vazz_cross", windup + (follow_up ? followup_windup : 0))

	var/list/figures = list()
	var/list/danger = list()
	// Центр берётся из текущей позиции цели и больше не меняется — лучи не преследуют игрока
	vazz_add_cross(figures, danger, get_turf(aim_target), VAZZ_CROSS_ARM_LENGTH, FALSE)
	if(!length(figures))
		return
	visible_message(span_warning("Пластины H.E.C.K. Mk II на [declent_ru(PREPOSITIONAL)] тускло светятся. На земле проступают линии."))
	vazz_speak(35)
	if(!vazz_telegraph_and_fire(figures, danger, windup, vazz_damage(VAZZ_CROSS_DAMAGE)))
		return
	if(!follow_up)
		return

	// Вторая фигура: диагональный "X" в новой позиции цели, с собственным телеграфом
	var/turf/second_center = get_turf(aim_target)
	if(!second_center || second_center.z != z)
		return
	var/list/second_figures = list()
	var/list/second_danger = list()
	vazz_add_cross(second_figures, second_danger, second_center, VAZZ_CROSS_ARM_LENGTH, TRUE)
	if(!length(second_figures))
		return
	visible_message(span_warning("Свет в пластинах H.E.C.K. Mk II смещается. Проступает вторая фигура."))
	vazz_telegraph_and_fire(second_figures, second_danger, followup_windup, vazz_damage(VAZZ_CROSS_DAMAGE))

// --------------------------------------------------------------------------
// Выстрел с телепортом (по мотивам выстрела Колосса)
// --------------------------------------------------------------------------

/// Один выстрел: показывает края и центр конуса, ждёт, затем стреляет веером из 6 снарядов в сторону цели.
/// Направление фиксируется в начале подготовки. Возвращает TRUE, если Vazz жив.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_shot_fire(turf/aim_turf, windup)
	var/turf/origin = get_turf(src)
	var/base_angle = get_angle(origin, aim_turf)
	var/list/ends = list()
	for(var/edge_angle in list(base_angle - VAZZ_SHOT_SPREAD, base_angle, base_angle + VAZZ_SHOT_SPREAD))
		var/turf/end_turf = vazz_turf_at_angle(origin, edge_angle, VAZZ_SHOT_RANGE)
		if(end_turf)
			ends += end_turf
	if(!length(ends))
		return TRUE
	var/list/figures = list()
	figures[vazz_new_anchor(origin)] = ends
	face_atom(aim_turf)
	visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] вскидывает руку. Перед ним расходится конус света."))
	vazz_pose("vazz_shot_aim", windup)
	vazz_draw(figures, windup, /obj/effect/ebeam/disintegration_telegraph)
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 2)
	SLEEP_CHECK_DEATH(src, windup)
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 2)
	vazz_pose("vazz_shot_fire", VAZZ_POSE_SHOT_FIRE)
	var/static/list/shot_angles = list(12.5, 7.5, 2.5, -2.5, -7.5, -12.5)
	for(var/angle_offset in shot_angles)
		vazz_shoot_projectile(src, aim_turf, base_angle + angle_offset)
	return TRUE

/// Телепорт на дистанцию 5—7 клеток от цели (во второй фазе — 2—3) и выстрел. Ниже 50% здоровья или в enraged — два
/// выстрела подряд. Заодно служит ответом на игрока, который стоит вплотную.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_shot_attack(atom/aim_target)
	var/shot_count = (enraged || vazz_is_wounded()) ? 2 : 1
	var/windup = vazz_time(VAZZ_SHOT_WINDUP)
	var/recovery = vazz_time(VAZZ_SHOT_RECOVERY)
	var/min_blink = phase_two ? VAZZ_PHASE2_SHOT_BLINK_MIN_DISTANCE : VAZZ_SHOT_BLINK_MIN_DISTANCE
	var/max_blink = phase_two ? VAZZ_PHASE2_SHOT_BLINK_MAX_DISTANCE : VAZZ_SHOT_BLINK_MAX_DISTANCE
	vazz_lock_state(shot_count * windup + recovery, recovery)
	for(var/i in 1 to shot_count)
		var/turf/aim_turf = get_turf(aim_target)
		if(!aim_turf || aim_turf.z != z)
			return
		var/turf/blink_turf = vazz_pick_turf_around(aim_turf, min_blink, max_blink, TRUE)
		if(blink_turf)
			vazz_pose("vazz_shot_hop", VAZZ_POSE_SHOT_HOP)
			vazz_blink(blink_turf)
		if(!vazz_shot_fire(aim_turf, windup))
			return
	vazz_pose("vazz_shot_reload", recovery)

// --------------------------------------------------------------------------
// Бластеры—черепа (в духе Gaster Blaster)
// --------------------------------------------------------------------------

/// Один череп: появляется, поворачивается к цели, показывает линию и по завершении подготовки стреляет лучом.
/// Направление фиксируется в момент появления. Разряд происходит по таймеру и пропускается, если Vazz погиб.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_skull_blast(turf/skull_turf, turf/aim_turf, windup, damage)
	var/list/figures = list()
	var/list/danger = list()
	var/obj/effect/vazz_beam_anchor/skull/skull = vazz_add_lance(figures, danger, skull_turf, aim_turf, VAZZ_BLASTER_RANGE, /obj/effect/vazz_beam_anchor/skull, windup + VAZZ_FIRE_TIME + VAZZ_SKULL_LEAVE_TIME + 1 SECONDS)
	if(!skull)
		return
	skull.appear(get_angle(skull_turf, aim_turf))
	vazz_draw(figures, windup, /obj/effect/ebeam/disintegration_telegraph)
	addtimer(CALLBACK(src, PROC_REF(vazz_skull_discharge), skull, figures, danger, damage), windup)

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_skull_discharge(obj/effect/vazz_beam_anchor/skull/skull, list/figures, list/danger, damage)
	if(QDELETED(src) || stat == DEAD || QDELETED(skull))
		return
	vazz_discharge(figures, danger, damage, skull)
	skull.leave()

/// Атака бластеров: несколько черепов появляются по очереди вокруг цели, каждый целится в цель на момент своего появления.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_blasters_attack(atom/aim_target)
	var/windup = vazz_time(VAZZ_BLASTER_WINDUP)
	var/stagger = vazz_time(VAZZ_BLASTER_STAGGER)
	var/skull_count = VAZZ_BLASTER_COUNT
	if(vazz_is_wounded())
		skull_count++
	if(enraged)
		skull_count++
	var/recovery = vazz_time(VAZZ_BLASTER_RECOVERY)
	vazz_lock_state(windup + stagger * skull_count + recovery, recovery)
	vazz_pose("vazz_blasters", windup + stagger * skull_count)
	visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] сжимает кулак. Из пустоты проступают черепа."))
	for(var/i in 1 to skull_count)
		var/turf/aim_turf = get_turf(aim_target)
		if(!aim_turf || aim_turf.z != z)
			return
		var/turf/skull_turf = vazz_pick_turf_around(aim_turf, VAZZ_BLASTER_MIN_DISTANCE, VAZZ_BLASTER_MAX_DISTANCE)
		if(skull_turf)
			vazz_skull_blast(skull_turf, aim_turf, windup, vazz_damage(VAZZ_BLASTER_DAMAGE))
		SLEEP_CHECK_DEATH(src, stagger)

// --------------------------------------------------------------------------
// Арена (ниже 50% здоровья)
// --------------------------------------------------------------------------

/// Убирает барьеры арены. Безопасно вызывать повторно.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_clear_arena()
	for(var/obj/effect/temp_visual/drakewall/vazz/wall as anything in arena_walls)
		if(!QDELETED(wall))
			qdel(wall)
	arena_walls = list()

/// Живые цели внутри арены (кроме самого Vazz, других боссов и существ его фракции)
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_arena_targets(turf/center)
	var/list/arena_targets = list()
	for(var/turf/arena_turf in RANGE_TURFS(VAZZ_ARENA_RADIUS, center))
		for(var/mob/living/L in arena_turf)
			if(L == src || L.stat == DEAD || length(faction & L.faction))
				continue
			arena_targets += L
	return arena_targets

/// Vazz встаёт перед ареной: на клетку сразу за кольцом барьеров, ближайшую к его нынешнему положению.
/// Если он уже снаружи кольца, остаётся на месте.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_arena_take_post(turf/center)
	if(get_dist(src, center) > VAZZ_ARENA_RADIUS + 1)
		face_atom(center)
		return
	var/post_radius = VAZZ_ARENA_RADIUS + 2
	var/turf/best_turf
	var/best_dist = INFINITY
	for(var/turf/candidate in RANGE_TURFS(post_radius, center) - RANGE_TURFS(post_radius - 1, center))
		if(candidate.density || islava(candidate) || ischasm(candidate) || candidate.is_blocked_turf(exclude_mobs = TRUE))
			continue
		var/candidate_dist = get_dist(src, candidate)
		if(candidate_dist < best_dist)
			best_dist = candidate_dist
			best_turf = candidate
	if(best_turf)
		vazz_blink(best_turf)
	face_atom(center)

/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_skull_shoot(obj/effect/vazz_beam_anchor/skull/skull, turf/aim_turf, list/angles, leave_after = TRUE)
	if(QDELETED(src) || stat == DEAD || QDELETED(skull))
		return
	var/base_angle = get_angle(get_turf(skull), aim_turf)
	for(var/angle_offset in angles)
		vazz_shoot_projectile(skull, aim_turf, base_angle + angle_offset)
	if(leave_after)
		skull.leave()

/// Череп, стреляющий снарядами. Центральная линия показывается заранее, снаряды медленные.
/// angles — смещения углов веера, shots — сколько залпов подряд (с интервалом shot_delay).
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_skull_bolts(turf/skull_turf, turf/aim_turf, charge, list/angles, shots = 1, shot_delay = 0, range = VAZZ_BLASTER_RANGE)
	var/list/figures = list()
	var/list/danger = list()
	var/obj/effect/vazz_beam_anchor/skull/skull = vazz_add_lance(figures, danger, skull_turf, aim_turf, range, /obj/effect/vazz_beam_anchor/skull, charge + shots * shot_delay + VAZZ_SKULL_LEAVE_TIME + 1 SECONDS)
	if(!skull)
		return
	skull.appear(get_angle(skull_turf, aim_turf))
	vazz_draw(figures, charge, /obj/effect/ebeam/disintegration_telegraph)
	for(var/shot in 1 to shots)
		addtimer(CALLBACK(src, PROC_REF(vazz_skull_shoot), skull, aim_turf, angles, shot == shots), charge + (shot - 1) * shot_delay)

/// Волна лучей: черепа на границе арены целятся в находящихся внутри.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_arena_blaster_wave(list/skull_spots, list/arena_targets)
	var/skull_count = VAZZ_ARENA_BLASTERS + (enraged ? 1 : 0)
	var/windup = vazz_time(VAZZ_ARENA_BLASTER_WINDUP)
	for(var/i in 1 to skull_count)
		var/mob/living/victim = pick(arena_targets)
		vazz_skull_blast(pick(skull_spots), get_turf(victim), windup, vazz_damage(VAZZ_ARENA_BLASTER_DAMAGE))

/// Волна снарядов: черепа на границе арены стреляют широкими веерами.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_arena_bolt_wave(list/skull_spots, list/arena_targets)
	var/skull_count = VAZZ_ARENA_BOLT_SKULLS + (enraged ? 1 : 0)
	var/charge = vazz_time(VAZZ_ARENA_BOLT_CHARGE)
	var/list/angles = list(-20, -10, 0, 10, 20)
	if(enraged)
		angles = list(-30, -20, -10, 0, 10, 20, 30)
	for(var/i in 1 to skull_count)
		var/mob/living/victim = pick(arena_targets)
		vazz_skull_bolts(pick(skull_spots), get_turf(victim), charge, angles)

/// Заградительный огонь: на одной стороне арены каждый ряд получает череп, кроме полосы безопасных рядов.
/// Каждый череп показывает линию вдоль своего ряда и выпускает по ней серию снарядов. Нужно стоять в безопасной полосе
/// (там нет линий): снаряды пролетят мимо. Если не успеть, снаряды попадут.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_arena_barrage_wave(turf/center)
	var/vertical = prob(50)
	var/forward = prob(50)
	var/safe_width = enraged ? VAZZ_ARENA_SAFE_WIDTH_ENRAGED : VAZZ_ARENA_SAFE_WIDTH
	var/safe_start = rand(-VAZZ_ARENA_RADIUS, VAZZ_ARENA_RADIUS - safe_width + 1)
	var/charge = vazz_time(VAZZ_ARENA_BARRAGE_CHARGE)
	var/edge = VAZZ_ARENA_RADIUS
	var/side = forward ? -edge : edge
	for(var/offset in -VAZZ_ARENA_RADIUS to VAZZ_ARENA_RADIUS)
		if(offset >= safe_start && offset < safe_start + safe_width)
			continue
		var/turf/from_turf
		var/turf/to_turf
		if(vertical)
			from_turf = locate(center.x + offset, center.y + side, center.z)
			to_turf = locate(center.x + offset, center.y - side, center.z)
		else
			from_turf = locate(center.x + side, center.y + offset, center.z)
			to_turf = locate(center.x - side, center.y + offset, center.z)
		if(!from_turf || !to_turf || from_turf.density || from_turf.is_blocked_turf(exclude_mobs = TRUE))
			continue
		vazz_skull_bolts(from_turf, to_turf, charge, list(0), VAZZ_ARENA_BARRAGE_BURST, VAZZ_ARENA_BARRAGE_DELAY, VAZZ_ARENA_BARRAGE_RANGE)

/// Арена: Vazz встаёт перед кольцом барьеров вокруг цели, на время арены становится неуязвимым (щит) и пускает волны
/// по кругу: лучи черепов —> веера снарядов —> заградительный огонь. Барьеры и щит всегда убираются в конце,
/// при смерти/удалении Vazz, а также по таймеру.
/mob/living/simple_animal/hostile/megafauna/vazz/proc/vazz_arena_attack(atom/aim_target)
	var/turf/center = get_turf(aim_target)
	if(!center || center.z != z)
		return
	// Обычный режим: одна короткая арена — перелом боя. Хардмод: полная арена, повторяется по кулдауну.
	var/waves = enraged ? VAZZ_ARENA_WAVES + 2 : VAZZ_ARENA_WAVES_SHORT
	var/wave_period = vazz_time(VAZZ_ARENA_WAVE_PERIOD)
	var/recovery = vazz_time(VAZZ_ARENA_RECOVERY)
	var/total_time = VAZZ_ARENA_SETUP + waves * wave_period + recovery
	vazz_lock_state(total_time, recovery)
	// После арены начинается вторая фаза (см. vazz_choose_attack)
	var/first_arena = !phase_two
	phase_two = TRUE
	vazz_pose("vazz_arena", total_time - recovery)
	arena_ready_at = world.time + (enraged ? VAZZ_ARENA_COOLDOWN_ENRAGED : VAZZ_ARENA_COOLDOWN)

	// Сначала встаём перед ареной (не внутри), потом строим кольцо
	vazz_arena_take_post(center)
	vazz_shield_on(total_time)

	var/list/ring_turfs = RANGE_TURFS(VAZZ_ARENA_RADIUS + 1, center) - RANGE_TURFS(VAZZ_ARENA_RADIUS, center)
	vazz_clear_arena()
	for(var/turf/ring_turf in ring_turfs)
		if(ring_turf.density || ring_turf == get_turf(src))
			continue
		arena_walls += new /obj/effect/temp_visual/drakewall/vazz(ring_turf)
	// Черепа стоят на внутреннем краю арены (не на барьерах), чтобы снаряды не рождались внутри стены
	var/list/skull_spots = list()
	for(var/turf/edge_turf in RANGE_TURFS(VAZZ_ARENA_RADIUS, center) - RANGE_TURFS(VAZZ_ARENA_RADIUS - 1, center))
		if(edge_turf.density || edge_turf.is_blocked_turf(exclude_mobs = TRUE))
			continue
		skull_spots += edge_turf
	if(!length(skull_spots))
		vazz_clear_arena()
		vazz_shield_off()
		vazz_pose_clear()
		vazz_lock_state(0) // арены не будет — не держим Vazz занятым впустую
		return

	visible_message(span_boldwarning("[DECLENT_RU_CAP(src, NOMINATIVE)] поднимает руку. Свет вокруг смыкается в кольцо, а его самого окутывает щит."))
	vazz_speak(100)
	for(var/mob/M in range(10, center))
		if(M.client)
			shake_camera(M, 4, 3)
	SLEEP_CHECK_DEATH(src, VAZZ_ARENA_SETUP) // время, чтобы понять, что происходит

	for(var/wave in 1 to waves)
		var/list/arena_targets = vazz_arena_targets(center)
		if(!length(arena_targets))
			break // внутри никого не осталось
		switch(wave % 3)
			if(1)
				vazz_arena_blaster_wave(skull_spots, arena_targets)
			if(2)
				vazz_arena_bolt_wave(skull_spots, arena_targets)
			if(0)
				vazz_arena_barrage_wave(center)
		SLEEP_CHECK_DEATH(src, wave_period)

	vazz_clear_arena()
	vazz_shield_off()
	vazz_pose_clear()
	vazz_lock_state(recovery, recovery)
	if(first_arena)
		visible_message(span_boldwarning("[DECLENT_RU_CAP(src, NOMINATIVE)] опускает руку. Щит гаснет. Он больше не собирается отступать."))
		vazz_speak(100)

#undef VAZZ_ATTACK_CHARGE
#undef VAZZ_ATTACK_CROSS
#undef VAZZ_ATTACK_SHOT
#undef VAZZ_ATTACK_BLASTERS
#undef VAZZ_ATTACK_ARENA
#undef VAZZ_MELEE_STREAK_LIMIT
#undef VAZZ_MELEE_WINDOW
#undef VAZZ_MELEE_WINDOW_DISTANCE
#undef VAZZ_CROSS_ARM_LENGTH
#undef VAZZ_CROSS_WINDUP
#undef VAZZ_FOLLOWUP_WINDUP
#undef VAZZ_CROSS_RECOVERY
#undef VAZZ_CROSS_DAMAGE
#undef VAZZ_CHARGE_LENGTH
#undef VAZZ_CHARGE_WINDUP
#undef VAZZ_CHARGE_FOLLOWUP_WINDUP
#undef VAZZ_CHARGE_STEP_TIME
#undef VAZZ_CHARGE_RECOVERY
#undef VAZZ_CHARGE_COOLDOWN
#undef VAZZ_CHARGE_FAR_DISTANCE
#undef VAZZ_CHARGE_DAMAGE
#undef VAZZ_CHARGE_THROW_RANGE
#undef VAZZ_SHOT_RANGE
#undef VAZZ_SHOT_SPREAD
#undef VAZZ_SHOT_WINDUP
#undef VAZZ_SHOT_RECOVERY
#undef VAZZ_SHOT_BLINK_MIN_DISTANCE
#undef VAZZ_SHOT_BLINK_MAX_DISTANCE
#undef VAZZ_BLASTER_COUNT
#undef VAZZ_BLASTER_RANGE
#undef VAZZ_BLASTER_MIN_DISTANCE
#undef VAZZ_BLASTER_MAX_DISTANCE
#undef VAZZ_BLASTER_WINDUP
#undef VAZZ_BLASTER_STAGGER
#undef VAZZ_BLASTER_RECOVERY
#undef VAZZ_BLASTER_DAMAGE
#undef VAZZ_SKULL_LEAVE_TIME
#undef VAZZ_SKULL_SCALE
#undef VAZZ_ARENA_RADIUS
#undef VAZZ_ARENA_WAVES
#undef VAZZ_ARENA_SETUP
#undef VAZZ_ARENA_WAVE_PERIOD
#undef VAZZ_ARENA_RECOVERY
#undef VAZZ_ARENA_COOLDOWN
#undef VAZZ_ARENA_COOLDOWN_ENRAGED
#undef VAZZ_ARENA_BLASTERS
#undef VAZZ_ARENA_BLASTER_WINDUP
#undef VAZZ_ARENA_BLASTER_DAMAGE
#undef VAZZ_ARENA_BOLT_SKULLS
#undef VAZZ_ARENA_BOLT_CHARGE
#undef VAZZ_BOLT_DAMAGE
#undef VAZZ_ARENA_BARRAGE_CHARGE
#undef VAZZ_ARENA_BARRAGE_BURST
#undef VAZZ_ARENA_BARRAGE_DELAY
#undef VAZZ_ARENA_BARRAGE_RANGE
#undef VAZZ_ARENA_SAFE_WIDTH
#undef VAZZ_ARENA_SAFE_WIDTH_ENRAGED
#undef VAZZ_ARENA_WALL_DURATION
#undef VAZZ_FIRE_TIME
#undef VAZZ_ANCHOR_LIFETIME
#undef VAZZ_SWAT_DAMAGE
#undef VAZZ_SWAT_INTERVAL
#undef VAZZ_SWAT_DURING_RECOVERY
#undef VAZZ_PATROL_TICK
#undef VAZZ_PATROL_POINTS
#undef VAZZ_PATROL_RADIUS
#undef VAZZ_PATROL_PAUSE_MIN
#undef VAZZ_PATROL_PAUSE_MAX
#undef VAZZ_PATROL_STUCK_LIMIT
#undef VAZZ_PATROL_GIVEUP_LIMIT
#undef VAZZ_PATROL_ARRIVE_DISTANCE
#undef VAZZ_PATROL_HUNT_CHANCE
#undef VAZZ_PATROL_HUNT_RANGE
#undef VAZZ_TREMOR_RANGE
#undef VAZZ_TREMOR_CAMERA_RANGE
#undef VAZZ_TASK_CRUSH
#undef VAZZ_TASK_FEED
#undef VAZZ_TASK_SCAN_INTERVAL
#undef VAZZ_TASK_SCAN_RANGE
#undef VAZZ_TASK_TIMEOUT
#undef VAZZ_CRUSHER_CHANCE
#undef VAZZ_CRUSHER_COOLDOWN
#undef VAZZ_CRUSHER_WINDUP
#undef VAZZ_CRUSHER_STRIKE_TIME
#undef VAZZ_CRUSHER_FAUNA_DAMAGE
#undef VAZZ_CRUSHER_ROCK_ATTEMPTS
#undef VAZZ_FEED_HEALTH_THRESHOLD
#undef VAZZ_FEED_HEAL_FRACTION
#undef VAZZ_FEED_TOTAL_CAP_FRACTION
#undef VAZZ_FEED_TIME
#undef VAZZ_FEED_COOLDOWN
#undef VAZZ_FEED_SITE_GRID
#undef VAZZ_FEED_SITE_COOLDOWN
#undef VAZZ_PHASE2_MELEE_WINDOW
#undef VAZZ_PHASE2_CHARGE_FAR_DISTANCE
#undef VAZZ_PHASE2_CHARGE_COOLDOWN
#undef VAZZ_PHASE2_SHOT_BLINK_MIN_DISTANCE
#undef VAZZ_PHASE2_SHOT_BLINK_MAX_DISTANCE
#undef VAZZ_POSE_SHOT_HOP
#undef VAZZ_POSE_SHOT_FIRE
#undef VAZZ_ARENA_WAVES_SHORT
