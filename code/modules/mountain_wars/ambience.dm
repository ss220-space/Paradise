// Эхо боя.
//
// Штатный playsound рассылает выстрел на SOUND_RANGE, то есть на пятнадцать клеток,
// и на этом всё. На карте 255x255 это значит, что бой в соседнем квадрате идёт в
// полной тишине: между двумя перестрелками игрок слышит только ветер. Достраиваем
// второй слой — тем, кто дальше пятнадцати клеток, вместо самого выстрела уходит
// глухая очередь вдали.
//
// Это фон, а не отчёт о каждом нажатии на спуск. Поэтому эхо не привязано к
// конкретной пуле: один ствол добавляет его не чаще раза в несколько секунд и не
// каждый раз. Иначе на сотне игроков дальний слой превратится в кашу, а клиент
// упрётся в лимит одновременных звуков.
//
// Источники сэмплов — freesound.org: 855244 (qubodup), 417690 (superphat) и 101962
// (cgeffex). Лицензии — в раздел атрибуции PR вместе с ассетами TGMC.
//
// Стрелковка и турели звучат разными наборами: очередь крупного калибра за полкарты
// слышна не трескотнёй, а глухими ударами. Записи cgeffex сделаны вблизи, поэтому
// «даль» им приделана фильтром при сборке — срез выше 1100 Гц.

/// Ближе этой границы слышен сам выстрел — эхо там не нужно.
#define MW_DISTANT_MIN (SOUND_RANGE + 1)
/// Дальше не слышно ничего. Четверть карты по диагонали.
#define MW_DISTANT_MAX 45
/// Как часто один ствол может добавить эхо.
#define MW_DISTANT_COOLDOWN 6 SECONDS
/// И с какой вероятностью, когда может.
#define MW_DISTANT_CHANCE 60
/// Турель громче и реже: пропускать её выстрелы жальче, чем чужую очередь.
#define MW_DISTANT_TURRET_COOLDOWN 5 SECONDS
#define MW_DISTANT_TURRET_CHANCE 75

GLOBAL_LIST_INIT(mw_distant_fire, list(
	'sound/mountain_wars/distant_fire_1.ogg',
	'sound/mountain_wars/distant_fire_2.ogg',
	'sound/mountain_wars/distant_fire_3.ogg',
	'sound/mountain_wars/distant_fire_4.ogg',
))

GLOBAL_LIST_INIT(mw_distant_turret, list(
	'sound/mountain_wars/distant_turret_1.ogg',
	'sound/mountain_wars/distant_turret_2.ogg',
	'sound/mountain_wars/distant_turret_3.ogg',
))

/**
 * Эхо ручного оружия. Зовётся из /obj/item/gun/shoot_live_shot() — единственная
 * правка вне модуля. В обычном раунде выходит первой строкой.
 *
 * Аргументы:
 * * source — стрелявший ствол, на нём же висит откат.
 * * where — откуда стреляли, обычно сам стрелок.
 */
/proc/mw_distant_shot(obj/item/gun/source, atom/where)
	if(!istype(SSticker?.mode, /datum/game_mode/mountain_wars))
		return
	if(!COOLDOWN_FINISHED(source, mw_distant_cooldown))
		return
	// Откат ставим до броска кубика: иначе неудачный бросок оставляет ствол
	// открытым и следующий же выстрел пробует снова.
	COOLDOWN_START(source, mw_distant_cooldown, MW_DISTANT_COOLDOWN)
	if(!prob(MW_DISTANT_CHANCE))
		return
	mw_distant_echo(where, GLOB.mw_distant_fire)

/**
 * То же для турелей техники. Отдельный проц, а не общий с откатом на любом датуме:
 * макросы COOLDOWN обращаются к вару по имени и требуют точного типа, а вешать
 * этот вар на /atom/movable ради трёх машин — плата со всех атомов раунда.
 */
/proc/mw_distant_turret_shot(obj/vehicle/mw/source, atom/where)
	if(!istype(SSticker?.mode, /datum/game_mode/mountain_wars))
		return
	if(!COOLDOWN_FINISHED(source, mw_distant_cooldown))
		return
	COOLDOWN_START(source, mw_distant_cooldown, MW_DISTANT_TURRET_COOLDOWN)
	if(!prob(MW_DISTANT_TURRET_CHANCE))
		return
	mw_distant_echo(where, GLOB.mw_distant_turret)

/// Сама рассылка: кому и как громко. Ничего не решает.
/proc/mw_distant_echo(atom/where, list/samples)
	var/turf/from = get_turf(where)
	if(!from || !length(samples))
		return
	// Один датум звука на всех слушателей — так же, как это делает сам playsound:
	// playsound_local переписывает у него громкость и позицию перед каждой отправкой.
	var/sound/echo = sound(pick(samples))
	for(var/mob/listener as anything in SSmobs.clients_by_zlevel[from.z])
		var/turf/ear = get_turf(listener)
		if(!ear || ear.z != from.z)
			continue
		var/distance = get_dist(ear, from)
		if(distance < MW_DISTANT_MIN || distance > MW_DISTANT_MAX)
			continue
		listener.playsound_local(
			from,
			null,
			45,
			vary = FALSE,
			// Пологое затухание вместо штатного крутого: на этих дистанциях звук и так
			// на грани слышимости, а с экспонентой 2.5 он пропадает сразу за границей.
			falloff_exponent = 1,
			sound_to_use = echo,
			max_distance = MW_DISTANT_MAX,
			min_volume = 4,
		)

#undef MW_DISTANT_MIN
#undef MW_DISTANT_MAX
#undef MW_DISTANT_COOLDOWN
#undef MW_DISTANT_CHANCE
#undef MW_DISTANT_TURRET_COOLDOWN
#undef MW_DISTANT_TURRET_CHANCE
