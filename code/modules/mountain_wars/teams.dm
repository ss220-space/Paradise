/datum/team/mountain_wars
	var/team_role
	var/team_color
	/// Строка задачи в титрах высадки, см. briefing.dm.
	var/briefing_task
	/// mind -> тип аутфита, который он занимает. По нему считается потолок ролей.
	var/list/role_by_mind = list()

// Заходит сюда дважды на одного бойца, и это не наша ошибка: базовый add_member()
// зовёт get_antag_datum_from_member(), тот создаёт антаг-датум через add_antag_datum(),
// а он в свою очередь снова зовёт add_member() у той же команды. Второй заход приходит
// без outfit_type — то есть переодевает командира в рядового, спавнит его заново и
// выдаёт второй комплект кнопок. Ловим по списку членов, который для этого заполняем
// до ..(), а не после: на момент рекурсии базовый проц до своего members |= ещё не дошёл.
/datum/team/mountain_wars/add_member(datum/mind/new_member, add_objectives = TRUE, outfit_type)
	if(new_member in members)
		return ..(new_member, add_objectives)
	members |= new_member
	deploy_member(new_member, outfit_type)
	return ..(new_member, add_objectives)

/**
 * Ставит бойца в строй: тело, роль, экипировка, точка спавна, кнопки карты.
 *
 * Вынесено из add_member отдельно, потому что админ переназначает роль тому, кто в
 * команде уже числится, — а туда второй раз не пускает защита от рекурсии выше.
 */
/**
 * Записывает за бойцом роль, которую он занял.
 *
 * Отдельно от deploy_member, потому что на старте раунда роль выбирают заранее и
 * параллельно: полтора десятка человек сидят в окне выбора одновременно, и место
 * должно считаться занятым в тот момент, когда его выбрали, а не когда боец уже
 * оделся. Иначе все они разберут одно и то же.
 */
/datum/team/mountain_wars/proc/claim_role(datum/mind/member, outfit_type)
	if(member && outfit_type)
		role_by_mind[member] = outfit_type

/**
 * Сколько бойцов фракции держат эту роль прямо сейчас.
 *
 * Считаются живые, а не все, кто её когда-либо брал. Место выбитого командира обязано
 * освобождаться: иначе к середине боя все три записи заняты покойниками, а отряды
 * остаются без командиров до конца раунда.
 */
/datum/team/mountain_wars/proc/role_holders(outfit_type)
	. = 0
	for(var/datum/mind/mate as anything in role_by_mind)
		if(role_by_mind[mate] != outfit_type)
			continue
		var/mob/body = mate.current
		if(QDELETED(body))
			continue
		// Заявку со старта засчитываем ещё до тела: пока боец не вышел из лобби, его
		// current — /mob/new_player, а у того stat принудительно DEAD. Без этой ветки
		// выбранное на старте место не считалось бы занятым вовсе.
		if(!isnewplayer(body) && body.stat == DEAD)
			continue
		.++

/datum/team/mountain_wars/proc/deploy_member(datum/mind/new_member, outfit_type)
	var/mob/living/character
	if(isnewplayer(new_member.current))
		var/mob/new_player/player = new_member.current
		character = player.create_character()
	else
		character = new_member.current

	SSjobs.AssignRole(character, team_role, TRUE)
	character = SSjobs.AssignRank(character, team_role, TRUE)
	// Аутфит берём по выбранной роли, а не дефолтный из джоба — поэтому
	// экипируем напрямую, минуя SSjobs.EquipRank.
	if(!outfit_type)
		var/datum/job/job = SSjobs.GetJob(team_role)
		outfit_type = job.outfit
	// Роль записываем по факту выдачи, а не только по выбору: сюда приходят и поздний
	// заход, и админское переназначение, а переназначенный обязан отпустить прежнее место.
	claim_role(new_member, outfit_type)
	// Старое снаряжение сносим: outfit.equip кладёт вещи в слоты, а занятый слот
	// новую вещь просто удаляет. Без этого переназначенный админом боец остался бы
	// в прежней форме и с прежним стволом.
	var/mob/living/carbon/human/body = character
	if(istype(body))
		force_human(body)
		body.delete_equipment()

	// Всё, что осталось от прежней роли, снимаем ДО выдачи новой. Иначе разжалованный
	// уходил бы с артиллерией, а назначенный заново получал каждую кнопку по второму
	// разу — но главное, снятие после outfit.equip срезало и то, что тот же equip
	// только что выдал: командирские способности висят как раз на его post_equip.
	// Список спеллов копируем — RemoveSpell чистит его по ходу.
	for(var/datum/action/innate/mw_minimap/stale in character.actions)
		qdel(stale)
	for(var/obj/effect/proc_holder/spell/mw/stale_spell in character.mob_spell_list?.Copy())
		character.RemoveSpell(stale_spell)
	for(var/datum/action/innate/mw_order_note/stale_radio in character.actions)
		qdel(stale_radio)

	var/datum/outfit/job/mountain_wars/outfit = new outfit_type
	outfit.equip(character)

	// Навыки всем одинаковые и базовые. Одной таблицы у должности мало: поверх неё
	// система кладёт свободные очки, вложенные игроком в персонажа до раунда, и тогда
	// два морпеха в одном отряде стреляют с разной меткостью. В бою сторона на стороне
	// это перекос, которого до перехода не было.
	character.mind?.give_basic_skills()

	// Классовые бонусы к скорости работы. Снимаем оба и выдаём заново: переназначенный
	// из санитара в стрелки не должен уносить с собой чужую скорость перевязки.
	REMOVE_TRAIT(character, TRAIT_MW_MEDIC, JOB_TRAIT)
	REMOVE_TRAIT(character, TRAIT_MW_ENGINEER, JOB_TRAIT)
	if(outfit.field_medic)
		ADD_TRAIT(character, TRAIT_MW_MEDIC, JOB_TRAIT)
	if(outfit.combat_engineer)
		ADD_TRAIT(character, TRAIT_MW_ENGINEER, JOB_TRAIT)

	character.forceMove(mountain_wars_spawnpoint(team_role))
	// Карта есть у всех и всегда: на ней держится связка со звеном, а терять её вместе
	// с рюкзаком — потерянный боец. Кнопка привязана к мобу, умрёт вместе с ним.
	if(outfit.squad_leader)
		var/datum/action/innate/mw_order_note/radio = new(character)
		radio.Grant(character)
	var/datum/action/innate/mw_minimap/minimap = new(character)
	minimap.can_draw = outfit.squad_leader
	minimap.Grant(character)
	var/datum/action/innate/mw_minimap/full/tacmap = new(character)
	tacmap.can_draw = outfit.squad_leader
	tacmap.Grant(character)
	RegisterSignal(character, COMSIG_MOB_DEATH, PROC_REF(on_member_death), TRUE)
	// Урон считаем со стороны получателя: только здесь известно, сколько дошло до тела.
	// Кто это сделал, подскажет метка на бойце, см. stats.dm.
	RegisterSignal(character, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_member_damaged), TRUE)
	// Метки мин ходят за игроком, а не за телом: после респавна в другой фракции их
	// надо пересчитать, иначе бывший повстанец продолжит видеть чужое поле.
	mw_refresh_mine_vision(character)
	return character

/**
 * Кому уходит приказ, написанный лидером своими словами.
 *
 * По умолчанию — вся фракция: у повстанцев отрядов нет, там лидер один на всех и делить
 * его приказ не на кого. Морпехи режут список по отделению, см. подтип.
 *
 * Мёртвых и безголовых пропускаем: приказ читают с экрана, а экран есть только у живого
 * с клиентом.
 */
/// Подразделение бойца в титрах высадки. У повстанцев это просто фракция.
/datum/team/mountain_wars/proc/unit_line(datum/mind/member)
	return name

/datum/team/mountain_wars/marine/unit_line(datum/mind/member)
	var/squad = squad_by_mind[member]
	return squad ? "[name] · отделение [squad]" : name

/datum/team/mountain_wars/proc/order_audience(datum/mind/leader)
	. = list()
	for(var/datum/mind/mate as anything in members)
		var/mob/living/body = mate.current
		if(QDELETED(body) || body.stat == DEAD || !body.client)
			continue
		. += body

/datum/team/mountain_wars/marine/order_audience(datum/mind/leader)
	var/squad = squad_by_mind[leader]
	// Лидер без отделения — случай админского назначения. Пусть говорит со всей фракцией,
	// это лучше, чем приказ в пустоту.
	if(!squad)
		return ..()
	. = list()
	for(var/datum/mind/mate as anything in members)
		if(squad_by_mind[mate] != squad)
			continue
		var/mob/living/body = mate.current
		if(QDELETED(body) || body.stat == DEAD || !body.client)
			continue
		. += body

/**
 * Переводит бойца в люди. Ксенорасам в этом бою места нет: снаряжение, униформа и
 * сама завязка режима считаны под людей, а унатх в каске морпеха — не то зрелище.
 *
 * Внешность и имя выдаём заново, а не оставляем прежние: у ксеноса они своей расы,
 * и человек с именем вокса и без волос выглядит хуже, чем случайный незнакомец.
 * scramble_appearance() перекатывает блоки внешности и берёт имя по новой расе.
 *
 * Стоит в deploy_member, потому что через него проходят все входы в бой: старт
 * раунда, поздний заход и админское назначение.
 */
/datum/team/mountain_wars/proc/force_human(mob/living/carbon/human/body)
	if(is_species(body, /datum/species/human))
		return
	body.set_species(/datum/species/human, use_default_color = TRUE)
	body.scramble_appearance()
	body.name = body.real_name
	body.mind?.name = body.real_name
	to_chat(body, span_userdanger("В этой операции участвуют только люди. Вас вписали в списки как [body.real_name]."))

/// Выписывает бойца из команды — админ переводит его в другую фракцию.
/// Список членов чистит базовый remove_member, его дёргает Destroy антаг-датума.
/datum/team/mountain_wars/proc/dismiss_member(datum/mind/member)
	if(!(member in members))
		return
	if(member.current)
		UnregisterSignal(member.current, COMSIG_MOB_DEATH)
	member.remove_antag_datum(antag_datum_type)
	members -= member
	role_by_mind -= member

// ponytail: один билет на жизнь — после первой смерти сигнал снимается,
// оживление дефибом не возвращает билет; пересмотреть в фазе медицины.
/datum/team/mountain_wars/proc/on_member_death(mob/source, gibbed)
	SIGNAL_HANDLER
	GLOB.mw_scoreboard?.log_death(source)
	UnregisterSignal(source, COMSIG_MOB_DEATH)

/datum/team/mountain_wars/proc/on_member_damaged(mob/living/source, damage, damagetype, def_zone, blocked)
	SIGNAL_HANDLER
	GLOB.mw_scoreboard?.log_damage(source, damage, damagetype, blocked)

/datum/team/mountain_wars/marine/on_member_death(mob/source, gibbed)
	. = ..()
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(istype(mode))
		mode.on_marine_death()

/datum/team/mountain_wars/declare_completion()
	var/list/text = list()
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(!istype(mode))
		return text
	// Исход считает режим: у победы морпехов условие своё, по подорванному заводу.
	// Пусто — раунд свернули до развязки, и писать «поражение» обеим сторонам нечестно.
	if(!mode.winner)
		text += span_fontsize3("<br><b>Бой за сектор прерван. Фракция <span style='color:[team_color];'>[name]</span> осталась на позициях.</b>")
		return text
	var/we_won = mode.winner == team_role
	if(we_won)
		text += span_fontsize3("<br><b>Победа фракции <span style='color:[team_color];'>[name]</span>!</b>")
	else
		text += span_fontsize3("<br><b>Поражение фракции <span style='color:[team_color];'>[name]</span>.</b>")
	if(team_role == JOB_TITLE_MW_MARINE)
		text += "<br><b>Осталось билетов подкреплений: [max(mode.marine_tickets, 0)].</b>"
	return text

// MARK: Отделения
// Только у морпехов: у них штатная структура, и в бою надо видеть, где чьё звено.
// Значение — иконстейт из icons/mountain_wars/hud.dmi: тот же квадратик, что
// team2, перекрашенный. Красный не берём — он у повстанцев.
GLOBAL_LIST_INIT(mw_squads, list(
	"Альфа" = "mw_squad_alpha",
	"Браво" = "mw_squad_bravo",
	"Чарли" = "mw_squad_charlie",
))

/// Команда морпехов текущего раунда. Нужна антаг-датуму, у него связи с командой нет.
/proc/mw_marine_team()
	var/datum/game_mode/mountain_wars/mode = SSticker.mode
	if(!istype(mode))
		return null
	return mode.teams[JOB_TITLE_MW_MARINE]

/datum/team/mountain_wars/marine
	name = "Морская пехота США"
	team_color = "#1100ff"
	briefing_task = "занять сектор и выбить противника"
	team_role = JOB_TITLE_MW_MARINE
	antag_datum_type = /datum/antagonist/mountain_wars/marine
	/// mind -> название отделения.
	var/list/squad_by_mind = list()
	/// mind -> TRUE у командиров: их разводим по разным отделениям.
	var/list/leader_minds = list()

// Отделение выдаём после ..(): антаг-датум с его ХУДом создаётся внутри базового
// проца, и до его возврата перекрашивать нечего.
/datum/team/mountain_wars/marine/add_member(datum/mind/new_member, add_objectives = TRUE, outfit_type)
	. = ..()
	if(!new_member?.current)
		return
	if(!squad_by_mind[new_member])
		squad_by_mind[new_member] = pick_squad(leader_minds[new_member])
		to_chat(new_member.current, span_notice("Ваше отделение — <b>[squad_by_mind[new_member]]</b>."))
	apply_squad_hud(new_member)

// Отметка о командире стоит здесь, а не в add_member: админ может переназначить
// роль тому, кто в команде уже есть, и разжалованный командир должен перестать им
// считаться. Зовётся раньше выбора отделения — тот на неё и смотрит.
/datum/team/mountain_wars/marine/deploy_member(datum/mind/new_member, outfit_type)
	. = ..()
	var/datum/outfit/job/mountain_wars/outfit = outfit_type
	if(outfit_type && initial(outfit.squad_leader))
		leader_minds[new_member] = TRUE
	else
		leader_minds -= new_member

/datum/team/mountain_wars/marine/dismiss_member(datum/mind/member)
	. = ..()
	squad_by_mind -= member
	leader_minds -= member

/**
 * Наименее заполненное отделение. Командиров считаем отдельно от рядовых: иначе
 * второй командир попадёт туда, где просто меньше народу, и одно отделение
 * останется без него совсем. Мёртвые не в счёт — выбитое звено должно наполняться.
 */
/datum/team/mountain_wars/marine/proc/pick_squad(leader)
	var/list/tally = list()
	for(var/squad in GLOB.mw_squads)
		tally[squad] = 0
	for(var/datum/mind/mate as anything in squad_by_mind)
		var/mob/living/body = mate.current
		if(QDELETED(body) || body.stat == DEAD)
			continue
		if(leader && !leader_minds[mate])
			continue
		tally[squad_by_mind[mate]] += 1
	var/best
	for(var/squad in tally)
		// При равенстве побеждает первое по списку — так отделения набираются по порядку.
		if(isnull(best) || tally[squad] < tally[best])
			best = squad
	return best

/// body_override — для переноса разума: owner.current там ещё старое тело.
/datum/team/mountain_wars/marine/proc/apply_squad_hud(datum/mind/member, mob/living/body_override)
	var/squad = squad_by_mind[member]
	var/mob/living/body = body_override || member?.current
	if(!squad || QDELETED(body))
		return
	set_antag_hud(body, GLOB.mw_squads[squad])
	// set_antag_hud правит только стейт, а квадратики цвета отделения лежат в своём
	// файле — иначе пришлось бы дописывать стейты в общий icons/mob/hud.dmi.
	var/image/holder = body.hud_list[SPECIALROLE_HUD]
	if(holder)
		holder.icon = 'icons/mountain_wars/hud.dmi'

/datum/team/mountain_wars/insurgent
	name = "Повстанцы"
	team_color = "#ff0000"
	briefing_task = "не дать морпехам закрепиться"
	team_role = JOB_TITLE_MW_INSURGENT
	antag_datum_type = /datum/antagonist/mountain_wars/insurgent

/datum/antagonist/mountain_wars
	show_in_roundend = FALSE
	show_in_orbit = FALSE

/datum/antagonist/mountain_wars/greet()
	var/list/messages = list()
	messages.Add(span_danger("<center>Вы боец фракции [name]!</center>"))
	messages.Add("<center>Ваша задача: удержать сектор и выбить противника.</center>")
	return messages

/datum/antagonist/mountain_wars/marine
	name = "Морская пехота США"
	special_role = JOB_TITLE_MW_MARINE
	antag_menu_name = "Морпехи"
	antag_hud_name = "team2"
	antag_hud_type = ANTAG_HUD_TEAM_2

// Базовый add_antag_hud ставит общий синий квадрат. Перекрываем сразу же, чтобы
// цвет отделения не слетал при переносе разума в новое тело.
/datum/antagonist/mountain_wars/marine/add_antag_hud(mob/living/antag_mob)
	. = ..()
	var/datum/team/mountain_wars/marine/team = mw_marine_team()
	if(team && owner)
		team.apply_squad_hud(owner, antag_mob)

/datum/antagonist/mountain_wars/insurgent
	name = "Повстанцы"
	special_role = JOB_TITLE_MW_INSURGENT
	antag_menu_name = "Повстанцы"
	antag_hud_name = "team3"
	antag_hud_type = ANTAG_HUD_TEAM_3
