
/datum/heretic_knowledge_tree_column/main/lock
	neighbour_type_left = /datum/heretic_knowledge_tree_column/moon_to_lock
	neighbour_type_right = /datum/heretic_knowledge_tree_column/lock_to_flesh

	route = PATH_LOCK
	ui_bgr = "node_lock"
	complexity = "Средняя"
	complexity_color = "#d6a531"
	// TG gives Lock a flat -1 to every Knowledge Shop tier (the path's whole identity is gadget-shopping).
	// This is the "shop is cheaper" half of the lock passive's level-1 line; the passive itself only grants
	// the shock immunity so the discount is not double-applied (see /datum/status_effect/heretic_passive/lock).
	shop_cost_discount = 1
	path_description = list(
		"Путь Замка строится вокруг доступа, перекрытия зон, воровства и хитрых приспособлений.",
		"Берите этот путь, если хотите менее прямой стиль игры и предпочитаете быть скользкой крысой.",
	)
	path_pros = list(
		"Ваше «Прикосновение Мансуса» открывает любой замок, разблокирует любой терминал и обходит любое ограничение доступа.",
		"Еретики Замка получают скидку в магазине знаний — идеальный путь, если хотите поэкспериментировать со всеми безделушками магазина.",
	)
	path_cons = list(
		"Слабейший путь еретика в прямом бою, без вариантов.",
		"Крайне ограниченная боевая польза.",
		"Никаких защитных бонусов или иммунитетов.",
		"Никакой мобильности и дополнительной телепортации.",
		"Сильно зависит от чужой силы — других отделов, игроков и игрового мира.",
	)
	path_tips = list(
		"«Прикосновение Мансуса» открывает вам всё: шлюзы, консоли и даже мехов, но на игроков оно прямого эффекта не оказывает. Зато оно оставляет метку, при срабатывании которой жертва не сможет покинуть помещение, где вы находитесь.",
		"Ваш клинок работает и как лом! Его можно хранить в поясах для инструментов и, в крайнем случае, вскрыть им шлюз.",
		"Ваша ID карта Еретика создаёт портал между двумя шлюзами. Полезно, если хотите устроить тайную базу.",
		"Используйте справочник по лабиринту, чтобы оторваться от преследователей — он создаёт стены, непроходимые ни для кого, кроме вас.",
	)
	// "Open Invitation" passive ("Открытое Приглашение"), ported 1:1 from tg.
	passive_name = "Открытое Приглашение"
	passive_descriptions = list(
		"Изоляция от тока; все знания из магазина знаний дешевле.",
		"Рентген-зрение: вы видите сквозь стены и предметы.",
		"Захват больше не уходит на откат, когда им открывают дверь или шкаф.",
	)

	// TG-format column (1:1 with tgstation Lock). Main line:
	// base_lock -> Key Keeper's Burden -> Concierge's Rite -> Shifting Guise(robes) ->
	// Burglar's Finesse -> Opening Blade -> Caretaker's Last Refuge -> ascension.
	// The grasp (secondary door/mech/console unlock), the lock mark and the on-pick passive are all folded
	// into base_knock (matching TG, no separate grasp/mark nodes).
	start = /datum/heretic_knowledge/limited_amount/starting/base_knock
	knowledge_tier1 = /datum/heretic_knowledge/key_ring
	knowledge_tier2 = /datum/heretic_knowledge/limited_amount/concierge_rite
	robes = /datum/heretic_knowledge/armor/lock
	knowledge_tier3 = /datum/heretic_knowledge/spell/burglar_finesse
	blade = /datum/heretic_knowledge/blade_upgrade/flesh/lock
	knowledge_tier4 = /datum/heretic_knowledge/spell/caretaker_refuge
	ascension = /datum/heretic_knowledge/ultimate/lock_final
	// Side knowledges guaranteed to be offered in this path's drafts (TG).
	guaranteed_side_tier1 = /datum/heretic_knowledge/painting
	guaranteed_side_tier2 = /datum/heretic_knowledge/spell/opening_blast
	guaranteed_side_tier3 = /datum/heretic_knowledge/limited_amount/summon/fire_shark


/datum/heretic_knowledge/limited_amount/starting/base_knock
	name = "Ходячий Замок" // Howl's Moving Castle
	desc = "Открывает вам Путь Замка. \
			Позволяет преобразовать нож и лом в ключ-лезвие. \
			Вы можете создать только два лезвия одновременно, и они работают как быстрые ломы. \
			Кроме того, их можно поместить в пояс для инструментов."
	gain_text = "Запертый Лабиринт ведёт к свободе. Но только запертые в нём Стюарды знают правильный путь."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/crowbar = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/lock)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "key_blade"
	// TG folds the lock mark and the on-pick passive into the starting knowledge.
	mark_type = /datum/status_effect/eldritch/lock
	passive_type = /datum/status_effect/heretic_passive/lock


/datum/heretic_knowledge/limited_amount/starting/base_knock/on_gain(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	// Secondary grasp (RMB on a door/mech/console/closet) unlocks it - the base starting knowledge only
	// wires the primary grasp, so register the secondary here. Folded from the old "Прикосновение Замка".
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp), override = TRUE)
	// TG makes the lock grasp silent and invocation-less, to fit the path's sneaky-rat playstyle.
	var/obj/effect/proc_holder/spell/touch/mansus_grasp/grasp = locate() in user.mob_spell_list
	if(grasp)
		grasp.invocation_type = INVOCATION_NONE
		grasp.sound = null


/datum/heretic_knowledge/limited_amount/starting/base_knock/on_lose(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)


// TG also rolls down the victim's jumpsuit on a primary grasp (pure flavor). master220's under-clothing
// adjust API differs and it has no mechanical effect, so - like the original Paradise port - we skip it and
// let the parent's create_mark() apply the lock mark on a primary grasp.

/// Secondary grasp: unlock whatever we grab - airlocks, mechs, consoles and lockers all pop open.
/datum/heretic_knowledge/limited_amount/starting/base_knock/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(ismecha(target))
		var/obj/mecha/mecha = target
		mecha.dna_lock = null
		if(mecha.occupant)
			var/mob/living/occupant = mecha.occupant
			if(!isAI(occupant))
				occupant.Paralyse(5 SECONDS)
				INVOKE_ASYNC(mecha, TYPE_PROC_REF(/obj/mecha, force_eject_occupant), occupant)

	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/door = target
		door.locked = FALSE
		INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open), TRUE)

	// NB: tg also force-authenticates /obj/machinery/computer here, but master220's base computer has no
	// unified `authenticated` flag (only a handful of subtypes do), so there's no clean 1:1 - consoles are
	// left out rather than special-casing each type. Airlocks/mechs/lockers cover the path's core utility.

	else if(istype(target, /obj/structure/closet))
		var/obj/structure/closet/closet = target
		closet.open(TRUE)

	// master220 has no atoms that listen for COMSIG_ATOM_MAGICALLY_UNLOCKED, so the explicit branches above
	// cover everything; tg's blanket turf signal is left out as it would be inert here.
	//var/turf/target_turf = get_turf(target)
	//SEND_SIGNAL(target_turf, COMSIG_ATOM_MAGICALLY_UNLOCKED, src, source)
	playsound(target, 'sound/magic/hereticknock.ogg', 100, TRUE, -1)

	// Level-3 passive ("Открытое Приглашение"): opening a lock no longer consumes the grasp, so it never
	// goes on cooldown. We do this by NOT returning COMPONENT_USE_HAND, leaving the grasp charge intact.
	if(HAS_TRAIT(source, TRAIT_LOCK_GRASP_UPGRADED))
		return

	return COMPONENT_USE_HAND


/datum/heretic_knowledge/key_ring
	name = "Бремя хранителя ключей"
	desc = "Позволяет преобразовать кошелек, железный прут и ID карту в карту Еретика. \
			Ударьте ею по паре шлюзов, чтобы создать два портала, которые телепортируют вас между ними, а \
			не-еретиков случайным образом. \
			Каждая карта может поддерживать только одну пару порталов одновременно. \
			Она функционирует и выглядит так же, как обычная ID карта. \
			Нажатие картой Еретика по обычной поглощает её копируя все доступы. Вы можете использовать эту карту в руке, чтобы \
			изменить её внешний вид на поглощенную карту."
	gain_text = "Хранитель презрительно усмехнулся: «Эти пластиковые прямоугольники — \
				насмешка над ключами, и я проклинаю каждую дверь, которая принимает их»."
	required_atoms = list(
		/obj/item/storage/wallet = 1,
		/obj/item/stack/rods = 1,
		/obj/item/card/id = 1,
	)
	result_atoms = list(/obj/item/card/id/advanced/heretic)
	cost = 2 // TG: key_ring costs 2
	research_tree_icon_path = 'icons/obj/card.dmi'
	research_tree_icon_state = "card_gold"


/datum/heretic_knowledge/key_ring/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/obj/item/card/id = locate(/obj/item/card/id) in selected_atoms
	if(isnull(id))
		return FALSE

	var/obj/item/card/id/advanced/heretic/result_item = new(loc)
	if(!istype(result_item))
		return FALSE

	selected_atoms -= id
	result_item.eat_card(id)
	result_item.shapeshift(id)
	return TRUE


/datum/heretic_knowledge/limited_amount/concierge_rite // item that creates heretic-only barriers at range
	drafting_tier = 5 // TG: this is researchable but starts deep in the shop
	name = "Обряд консьержа"
	desc = "Позволяет преобразовать мелок, деревянную доску и мультитул в «Справочник по лабиринту». \
			Он может материализовать баррикаду на расстоянии, через которую сможете пройти только вы и люди, \
			устойчивые к магии. 5 использований, которые восстанавливаются со временем."
	gain_text = "Консьерж записал мое имя в справочнике. «Добро пожаловать в ваш новый дом, товарищ Стюард»."
	required_atoms = list(
		/obj/item/toy/crayon = 1,
		/obj/item/stack/sheet/wood = 1,
		/obj/item/multitool = 1,
	)
	result_atoms = list(/obj/item/heretic_labyrinth_handbook)
	cost = 2 // TG: concierge_rite costs 2
	research_tree_icon_path = 'icons/obj/library.dmi'
	research_tree_icon_state = "heretichandbook"


/datum/heretic_knowledge/armor/lock
	name = "Изменчивая Личина" // Shifting Guise
	desc = "Позволяет преобразовать стол (или верхнюю одежду), маску и лом в изменчивую личину. \
			Она даёт камуфляж от камер, скрывает вашу личность, голос и приглушает шаги. \
			Действует как амулет, пока надет капюшон."
	gain_text = "Хотя Стюарды известны Консьержу, между собой и с чужаками они общаются под тенью капюшонов. \
				Узнавание — это предательство, даже самого себя."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock)
	research_tree_icon_state = "lock_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/crowbar = 1,
	)


/datum/heretic_knowledge/spell/burglar_finesse
	name = "Хитрость взломщика"
	desc = "Даёт вам «Хитрость взломщика» — заклинание, действующее на одну цель, \
			которое кладёт вам в руку случайный предмет из рюкзака жертвы."
	gain_text = "Общение с духами-взломщиками не приветствуется, но управляющий \
				всегда захочет узнать больше о новых дверях."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "burglarsfinesse"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/burglar_finesse
	cost = 2 // TG: burglar_finesse costs 2


/datum/heretic_knowledge/blade_upgrade/flesh/lock
	name = "Клинок Открытия"
	desc = "Ваш клинок при атаке имеет шанс вызвать у врагов обильное кровотечение."
	gain_text = "«Пилигрим-хирург» не был стюардом. Тем не менее, его лезвия и нити оказались не хуже ключей."
	research_tree_icon_state = "blade_upgrade_lock"
	// TG applies a *critical* weeping avulsion; the flesh parent applies a *severe* one. master220 has no
	// wound system, so the flesh parent already adapts that to sustained external bleeding - the lock blade
	// is simply a chance-gated version of it, exactly mirroring TG's "if(prob(chance)) return ..()".
	var/chance = 35


/datum/heretic_knowledge/blade_upgrade/flesh/lock/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(prob(chance))
		return ..()


/datum/heretic_knowledge/spell/caretaker_refuge
	name = "Последнее пристанище смотрителя"
	desc = "Даёт вам заклинание, делающее вас прозрачным и неосязаемым. Нельзя использовать рядом с живыми разумными существами. \
			В этом состоянии вы не можете использовать руки или заклинания, а также невосприимчивы к замедлению. \
			Вы неуязвимы, но не можете причинить вред кому-либо. Отменяется ударом антимагического предмета."
	gain_text = "Завистливо преследовали меня Страж и Гончая. Но я скрыл свой облик став неосязаемым туманом."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "caretaker"
	spell_to_add = /obj/effect/proc_holder/spell/caretaker
	cost = 2 // TG: caretaker_refuge costs 2
	is_final_knowledge = TRUE


/datum/heretic_knowledge/ultimate/lock_final
	name = "Открытие Лабиринта"
	desc = "Ритуал вознесения Пути Замка. \
			Положите 3 трупа без органов в торсе на руну трансмутации, чтобы завершить ритуал. \
			После завершения ритуала вы обретёте способность превращаться в могущественных потусторонних существ, \
			а ваши ключи-клинки станут ещё смертоноснее. \
			Кроме того, вы создадите разрыв в сердце Лабиринта, \
			расположенный на месте проведения ритуала. \
			Через этот разлом потусторонние существа смогут попасть в наш мир. \
			Они будут обязаны подчиняться вашим указаниям."
	gain_text = "Наместники вели меня, а я вел их. \
				Мои враги были Замками, а мои клинки — Ключом! \
				Лабиринт больше не будет заперт, и мы обретём свободу! СТАНЬТЕ СВИДЕТЕЛЯМИ НАШЕГО ОСВОБОЖДЕНИЯ!"
	required_atoms = list(/mob/living/carbon/human = 3)
	//ascension_achievement = /datum/award/achievement/misc/lock_ascension
	announcement_text = "Обнаружена пространственная аномалия класса «Дельта» %SPOOKY% Реальность пала. Врата открыты, двери открыты, %NAME% вознёсся! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_knock.ogg'


/datum/heretic_knowledge/ultimate/lock_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue

		if(LAZYLEN(body.get_organs_zone(BODY_ZONE_CHEST)))
			to_chat(user, span_hierophant_warning("[body.declent_ru(NOMINATIVE)] всё ещё содержит органы."))
			continue

		selected_atoms += body


	if(!LAZYLEN(selected_atoms))
		loc.balloon_alert(user, "мало подходящих тел!")
		return FALSE

	return TRUE


/datum/heretic_knowledge/ultimate/lock_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	// buffs
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shapeshift/eldritch/ascension)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/blade_upgrade/flesh/lock/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/flesh/lock)
	blade_upgrade.chance += 30
	new /obj/structure/lock_tear(loc, user.mind)
