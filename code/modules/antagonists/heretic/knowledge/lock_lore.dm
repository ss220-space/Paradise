
/datum/heretic_knowledge_tree_column/main/lock

	route = PATH_LOCK
	ui_bgr = "node_lock"
	complexity_color = "#d6a531"
	shop_cost_discount = 1
	path_description = list(
		"Путь Замка́ строится вокруг доступа, перекрытия зон, воровства и хитрых приспособлений.",
		"Берите этот путь, если хотите менее прямой стиль игры и предпочитаете быть скользкой крысой.",
	)
	path_pros = list(
		"Ваша \"Хватка Обители\" открывает любой замок, разблокирует любой терминал и обходит любое ограничение доступа.",
		"Еретики Замка́ получают скидку в магазине знаний — идеальный путь, если хотите поэкспериментировать со всеми безделушками магазина.",
	)
	path_cons = list(
		"Слабейший путь еретика в прямом бою, без вариантов.",
		"Крайне ограниченная боевая польза.",
		"Никаких защитных бонусов или иммунитетов.",
		"Никакой мобильности и дополнительной телепортации.",
		"Сильно зависит от чужой силы — других отделов, игроков и игрового мира.",
	)
	path_tips = list(
		"\"Хватка Обители\" открывает вам всё: шлюзы, консоли и даже мехов, но на гуманоидов оно прямого эффекта не оказывает. Зато оно оставляет метку, при срабатывании которой жертва не сможет покинуть помещение, где вы находитесь.",
		"Ваш клинок работает и как лом! Его можно хранить в поясах для инструментов и, в крайнем случае, вскрыть им шлюз.",
		"Ваша ID карта Еретика создаёт портал между двумя шлюзами. Полезно, если хотите устроить тайную базу.",
		"Используйте справочник по лабиринту, чтобы оторваться от преследователей — он создаёт стены, непроходимые ни для кого, кроме вас.",
	)
	passive_name = "Открытое Приглашение"
	passive_descriptions = list(
		"Изоляция от тока; все знания из магазина знаний дешевле.",
		"Рентген-зрение: вы видите сквозь стены и предметы.",
		"Захват больше не уходит на откат, когда им открывают дверь или шкаф.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_knock
	knowledge_tier1 = /datum/heretic_knowledge/key_ring
	knowledge_tier2 = /datum/heretic_knowledge/limited_amount/concierge_rite
	robes = /datum/heretic_knowledge/armor/lock
	knowledge_tier3 = /datum/heretic_knowledge/spell/burglar_finesse
	blade = /datum/heretic_knowledge/blade_upgrade/flesh/lock
	knowledge_tier4 = /datum/heretic_knowledge/spell/caretaker_refuge
	ascension = /datum/heretic_knowledge/ultimate/lock_final
	guaranteed_side_tier1 = /datum/heretic_knowledge/painting
	guaranteed_side_tier2 = /datum/heretic_knowledge/spell/opening_blast
	guaranteed_side_tier3 = /datum/heretic_knowledge/limited_amount/summon/fire_shark


/datum/heretic_knowledge/limited_amount/starting/base_knock
	name = "Ходячий Замок" // Howl's Moving Castle
	desc = "Открывает вам Путь Замка́. \
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
	mark_type = /datum/status_effect/eldritch/lock
	passive_type = /datum/status_effect/heretic_passive/lock


/datum/heretic_knowledge/limited_amount/starting/base_knock/on_gain(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp), override = TRUE)
	var/obj/effect/proc_holder/spell/touch/mansus_grasp/grasp = locate() in user.mob_spell_list
	if(grasp)
		grasp.invocation_type = INVOCATION_NONE
		grasp.sound = null


/datum/heretic_knowledge/limited_amount/starting/base_knock/on_lose(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)


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

	else if(is_airlock(target))
		var/obj/machinery/door/airlock/door = target
		door.locked = FALSE
		INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open), TRUE)


	else if(iscloset(target))
		var/obj/structure/closet/closet = target
		closet.open(TRUE)

	playsound(target, 'sound/magic/hereticknock.ogg', 100, TRUE, -1)

	if(HAS_TRAIT(source, TRAIT_LOCK_GRASP_UPGRADED))
		return

	return COMPONENT_USE_HAND


/datum/heretic_knowledge/key_ring
	name = "Бремя Хранителя Ключей"
	desc = "Позволяет преобразовать кошелёк, железный прут и ID карту в карту Еретика. \
			Ударьте ею по паре шлюзов, чтобы создать два портала, которые телепортируют вас между ними, а \
			язычников случайным образом. \
			Каждая карта может поддерживать только одну пару порталов одновременно. \
			Она функционирует и выглядит так же, как обычная ID карта. \
			Нажатие картой Еретика по обычной поглощает её копируя все доступы. Вы можете использовать эту карту в руке, чтобы \
			изменить её внешний вид на поглощенную карту."
	gain_text = "Хранитель презрительно усмехнулся: \"Эти пластиковые прямоугольники — \
				насмешка над ключами, и я проклинаю каждую дверь, которая принимает их\"."
	required_atoms = list(
		/obj/item/storage/wallet = 1,
		/obj/item/stack/rods = 1,
		/obj/item/card/id = 1,
	)
	result_atoms = list(/obj/item/card/id/advanced/heretic)
	cost = 2
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
	drafting_tier = 5 // researchable but starts deep in the shop
	name = "Обряд Консьержа"
	desc = "Позволяет преобразовать мелок, деревянную доску и мультитул в \"Справочник по лабиринту\". \
			Он может материализовать баррикаду на расстоянии, через которую сможете пройти только вы и люди, \
			устойчивые к магии. 5 использований, которые восстанавливаются со временем."
	gain_text = "Консьерж записал мое имя в справочнике. \"Добро пожаловать в ваш новый дом, товарищ Стюард\"."
	required_atoms = list(
		/obj/item/toy/crayon = 1,
		/obj/item/stack/sheet/wood = 1,
		/obj/item/multitool = 1,
	)
	result_atoms = list(/obj/item/heretic_labyrinth_handbook)
	cost = 2
	research_tree_icon_path = 'icons/obj/library.dmi'
	research_tree_icon_state = "heretichandbook"


/datum/heretic_knowledge/armor/lock
	name = "Изменчивая Личина" // Shifting Guise
	desc = "Позволяет преобразовать стол (или верхнюю одежду), маску и лом в изменчивую личину. \
			Она даёт камуфляж от камер, скрывает вашу личность, голос и приглушает шаги. \
			Действует в качестве источника фокуса, пока надет капюшон."
	gain_text = "Хотя Стюарды известны Консьержу, между собой и с чужаками они общаются под тенью капюшонов. \
				Узнавание — это предательство, даже самого себя."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock)
	research_tree_icon_state = "lock_armor"
	research_tree_icon_frame = 1
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/crowbar = 1,
	)


/datum/heretic_knowledge/spell/burglar_finesse
	name = "Хитрость взломщика"
	desc = "Даёт вам \"Хитрость взломщика\", заклинание, действующее на одну цель, \
			которое кладёт вам в руку случайный предмет из рюкзака жертвы."
	gain_text = "Общение с духами-взломщиками не приветствуется, но управляющий \
				всегда захочет узнать больше о новых дверях."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "burglarsfinesse"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/burglar_finesse
	cost = 2


/datum/heretic_knowledge/blade_upgrade/flesh/lock
	name = "Клинок Открытия"
	desc = "Ваш клинок при атаке имеет шанс вызвать у врага артериальное кровотечение."
	gain_text = "\"Пилигрим-хирург\" не был стюардом. Тем не менее, его лезвия и нити оказались не хуже ключей."
	research_tree_icon_state = "blade_upgrade_lock"
	var/chance = 35


/datum/heretic_knowledge/blade_upgrade/flesh/lock/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!prob(chance))
		return
	if(!ishuman(target) || source == target)
		return

	var/mob/living/carbon/human/human_target = target
	if(HAS_TRAIT(human_target, TRAIT_NO_BLOOD))
		return

	var/list/valid_limbs = list()
	for(var/obj/item/organ/external/bodypart as anything in human_target.bodyparts)
		if(!bodypart.is_robotic() && !bodypart.has_arterial_bleeding() && !bodypart.cannot_arterial_bleed)
			valid_limbs += bodypart
	if(!length(valid_limbs))
		return

	var/obj/item/organ/external/limb = pick(valid_limbs)
	limb.arterial_bleeding()


/datum/heretic_knowledge/spell/caretaker_refuge
	name = "Последнее Пристанище Смотрителя"
	desc = "Даёт вам заклинание, скрывающее вас в Убежище Смотрителя — прозрачным и неосязаемым. \
			Войти в него можно, только пока вас никто не видит, и выйти — лишь там, где вас никто не видит. \
			В убежище вы неуязвимы, но не можете действовать."
	gain_text = "Завистливо преследовали меня Страж и Гончая. Но я скрыл свой облик, став неосязаемым туманом."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "caretaker"
	spell_to_add = /obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker
	cost = 2
	is_final_knowledge = TRUE


/datum/heretic_knowledge/ultimate/lock_final
	name = "Открытие Лабиринта"
	desc = "Ритуал вознесения Пути Замка́. \
			Положите 3 трупа без органов в торсе на руну трансмутации, чтобы завершить ритуал. \
			После завершения ритуала вы обретёте способность превращаться в могущественных потусторонних существ, \
			а ваши ключи-клинки станут ещё смертоноснее. \
			Кроме того, вы создадите разрыв в сердце Лабиринта, \
			расположенный на месте проведения ритуала. \
			Через этот разлом потусторонние существа смогут попасть в наш мир. \
			Они будут обязаны подчиняться вашим указаниям."
	gain_text = "Наместники вели меня, а я вел их. \
				Мои враги были Замка́ми, а мои клинки — Ключом! \
				Лабиринт больше не будет заперт, и мы обретём свободу! СТАНЬТЕ СВИДЕТЕЛЯМИ НАШЕГО ОСВОБОЖДЕНИЯ!"
	required_atoms = list(/mob/living/carbon/human = 3)
	announcement_text = "%SPOOKY% Реальность пала. Ключ проворачивается в замке. Врата открыты, двери распахнуты, %NAME% вознёсся! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_knock.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "lockascend"


/datum/heretic_knowledge/ultimate/lock_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue

		if(LAZYLEN(body.get_organs_zone(BODY_ZONE_CHEST)))
			to_chat(user, span_hierophant_warning("[DECLENT_RU_CAP(body, NOMINATIVE)] всё ещё содержит органы."))
			continue

		selected_atoms += body


	if(!LAZYLEN(selected_atoms))
		loc.balloon_alert(user, "мало подходящих тел!")
		return FALSE

	return TRUE


/datum/heretic_knowledge/ultimate/lock_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shapeshift/eldritch/ascension)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/blade_upgrade/flesh/lock/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/flesh/lock)
	blade_upgrade.chance += 30
	new /obj/structure/lock_tear(loc, user.mind)
