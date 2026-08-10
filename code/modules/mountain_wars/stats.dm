// Статистика боя: кто сколько убил, нанёс урона и вылечил.
//
// Считаем по метке «кто последний попал». Прямой связи «удар — счётчик» в движке нет:
// урон приходит бойцу через apply_damage, а тот про бьющего ничего не знает. Поэтому
// пуля и удар предметом ставят на цели метку с ckey бьющего и временем, а сигнал урона
// эту метку читает. Метка живёт секунды: всё, что прилетело позже, считаем ничьим.
//
// Что в счёт не идёт: взрывы, огонь, падения с уступов и прочий урон без автора —
// метки на него никто не ставит. Артиллерия командира сюда же: снаряд прилетает сам по
// себе, отдавшего приказ на нём не написано.
//
// Доска живёт раунд и создаётся вместе с режимом, см. post_setup.

GLOBAL_DATUM(mw_scoreboard, /datum/mw_scoreboard)

/// Сколько метка «кто попал» годится для записи урона.
#define MW_HIT_MEMORY (5 SECONDS)
/// То же для убийства: раненый умирает не сразу, и стрелявший всё равно виноват.
#define MW_KILL_MEMORY (2 MINUTES)

/datum/mw_score
	var/ckey
	/// Имя на момент последнего обновления строки.
	var/name = "?"
	var/faction
	var/kills = 0
	var/deaths = 0
	/// Нанесено урона, сумма по всем видам, кроме выносливости.
	var/damage = 0
	/// Вылечено урона: brute и burn, снятые с любого бойца, включая себя.
	var/healed = 0

/datum/mw_scoreboard
	/// ckey -> /datum/mw_score.
	var/list/rows = list()
	/// UID жертвы -> list(ckey бьющего, его имя, world.time).
	///
	/// Ключ строкой, а не мобом: живая ссылка в глобальном списке держала бы труп в
	/// памяти до конца раунда и ловила бы hard del на каждом qdel моба.
	var/list/hits = list()

/// Строка бойца. Заводится при первом же событии.
/datum/mw_scoreboard/proc/row(ckey, name)
	if(!ckey)
		return null
	var/datum/mw_score/line = rows[ckey]
	if(!line)
		line = new
		line.ckey = ckey
		rows[ckey] = line
	if(name)
		line.name = name
	return line

/// Метка «по этому бойцу только что попали». Ставится до нанесения урона.
/datum/mw_scoreboard/proc/mark_hit(mob/attacker, mob/living/victim)
	if(!attacker?.ckey || !istype(victim))
		return
	hits[victim.UID()] = list(attacker.ckey, attacker.real_name, world.time)

/// Кто числится за жертвой, если метка ещё свежая.
/datum/mw_scoreboard/proc/marked_author(mob/living/victim, memory)
	var/list/mark = hits[victim.UID()]
	if(!mark || world.time - mark[3] > memory)
		return null
	return row(mark[1], mark[2])

/datum/mw_scoreboard/proc/log_damage(mob/living/victim, damage, damagetype, blocked)
	// Выносливость не урон, а способ уронить на пол: в зачёт не идёт.
	if(damagetype == STAMINA)
		return
	// Сигнал приходит до брони, а в счёт надо то, что дошло до тела.
	var/dealt = damage * (100 - clamp(blocked, 0, 100)) / 100
	if(dealt <= 0)
		return
	var/datum/mw_score/line = marked_author(victim, MW_HIT_MEMORY)
	if(!line)
		return
	line.damage += dealt

/datum/mw_scoreboard/proc/log_heal(mob/healer, amount)
	if(amount <= 0 || !healer?.ckey)
		return
	var/datum/mw_score/line = row(healer.ckey, healer.real_name)
	line.healed += amount

/datum/mw_scoreboard/proc/log_death(mob/living/victim)
	var/datum/mw_score/dead = row(victim?.ckey, victim?.real_name)
	if(dead)
		dead.deaths++
		dead.faction = mountain_wars_faction(victim) || dead.faction
	var/datum/mw_score/killer = marked_author(victim, MW_KILL_MEMORY)
	// Подорвался сам — записываем только смерть.
	if(!killer || killer == dead)
		return
	killer.kills++

/// Сколько на бойце снимаемого урона. По разнице до и после лечения считаем вылеченное.
/datum/mw_scoreboard/proc/hurt(mob/living/target)
	if(!istype(target))
		return null
	return target.getBruteLoss() + target.getFireLoss()

/// Разница «было — стало» после того, как предмет отработал по цели.
/datum/mw_scoreboard/proc/settle_heal(mob/user, mob/living/target, hurt_before)
	if(isnull(hurt_before) || !istype(target))
		return
	log_heal(user, hurt_before - hurt(target))

/datum/mw_scoreboard/proc/render()
	var/list/lines = list()
	for(var/ckey in rows)
		lines += rows[ckey]
	sortTim(lines, GLOBAL_PROC_REF(cmp_mw_score))

	// Без явной кодировки браузерный контрол читает страницу как cp1251 и выдаёт
	// кракозябры: BYOND отдаёт html в UTF-8, но заголовка Content-Type у browse() нет.
	var/list/html = list("<html><head><meta charset='utf-8'><title>Статистика боя</title></head><body>")
	html += "<h2>Mountain Wars — статистика боя</h2>"
	html += "<table border='1' cellpadding='4' cellspacing='0'>"
	html += "<tr><th>Боец</th><th>Ключ</th><th>Фракция</th><th>Убийств</th><th>Смертей</th><th>Урона</th><th>Вылечено</th></tr>"
	for(var/datum/mw_score/line as anything in lines)
		html += "<tr><td>[line.name]</td><td>[line.ckey]</td><td>[line.faction || "—"]</td><td>[line.kills]</td><td>[line.deaths]</td><td>[round(line.damage)]</td><td>[round(line.healed)]</td></tr>"
	html += "</table></body></html>"
	return html.Join()

/// Сверху те, кто больше убил; при равенстве — кто больше вылечил.
/proc/cmp_mw_score(datum/mw_score/a, datum/mw_score/b)
	if(b.kills != a.kills)
		return b.kills - a.kills
	return b.healed - a.healed

/// Раскрывает доску всем на сервере. Раньше итоги существовали только под админской
/// вербой, и раунд заканчивался тем, что игроки не видели ни своих цифр, ни чужих.
/// Рендер один на всех: таблица общая, а окно у каждого своё.
/proc/mw_show_scoreboard()
	var/datum/mw_scoreboard/board = GLOB.mw_scoreboard
	if(!board)
		return
	var/html = board.render()
	for(var/mob/viewer as anything in GLOB.player_list)
		if(!viewer.client)
			continue
		viewer << browse(html, "window=mw_stats;size=700x500")

ADMIN_VERB(mw_stats, R_ADMIN, "MW: Статистика боя", "Кто сколько убил, нанёс урона и вылечил.", ADMIN_CATEGORY_GAME)
	var/datum/mw_scoreboard/board = GLOB.mw_scoreboard
	if(!board)
		to_chat(user, span_warning("Статистики нет: раунд не Mountain Wars."))
		return
	user << browse(board.render(), "window=mw_stats;size=700x500")

#undef MW_HIT_MEMORY
#undef MW_KILL_MEMORY
