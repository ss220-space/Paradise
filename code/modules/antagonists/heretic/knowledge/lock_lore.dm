
/datum/heretic_knowledge_tree_column/main/lock
	neighbour_type_left = /datum/heretic_knowledge_tree_column/moon_to_lock
	neighbour_type_right = /datum/heretic_knowledge_tree_column/lock_to_flesh

	route = PATH_LOCK
	ui_bgr = "node_lock"

	start = /datum/heretic_knowledge/limited_amount/starting/base_knock
	grasp = /datum/heretic_knowledge/lock_grasp
	tier1 = /datum/heretic_knowledge/key_ring
	mark = /datum/heretic_knowledge/mark/lock_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/lock
	unique_ability = /datum/heretic_knowledge/limited_amount/concierge_rite
	tier2 = /datum/heretic_knowledge/spell/burglar_finesse
	blade = /datum/heretic_knowledge/blade_upgrade/flesh/lock
	tier3 =	/datum/heretic_knowledge/spell/caretaker_refuge
	ascension = /datum/heretic_knowledge/ultimate/lock_final


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


/datum/heretic_knowledge/lock_grasp
	name = "Прикосновение Замка"
	desc = "Ваше Прикосновение Мансуса позволяет вам получить доступ ко всему! \
			Активируйте Прикосновение в руке и нажмите по шлюзу или шкафчику, чтобы открыть его. \
			ДНК-замки с мехов будут сняты, а любой пилот будет выкинут. Работает на консолях. \
			Издаёт характерный стук при использовании."
	gain_text = "Любой откроется мне."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_lock"


/datum/heretic_knowledge/lock_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))
	//RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))


/datum/heretic_knowledge/lock_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)
	//UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/*
/datum/heretic_knowledge/lock_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER
	var/obj/item/clothing/under/suit = target.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	if(istype(suit) && suit.adjusted == NORMAL_STYLE)
		suit.toggle_jumpsuit_adjust()
		suit.update_appearance()
*/

/datum/heretic_knowledge/lock_grasp/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(ismecha(target))
		var/obj/mecha/mecha = target
		mecha.dna_lock = null
		//mecha.mecha_flags &= ~ID_LOCK_ON
		if(mecha.occupant)
			var/mob/living/occupant = mecha.occupant
			if(!isAI(occupant))
				occupant.Paralyse(5 SECONDS)
				INVOKE_ASYNC(mecha, TYPE_PROC_REF(/obj/mecha, force_eject_occupant))

	else if(istype(target,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/door = target
		door.locked = FALSE
		INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open), TRUE)

	else if(istype(target, /obj/structure/closet))
		var/obj/structure/closet/closet = target
		closet.open(TRUE)

	//var/turf/target_turf = get_turf(target)
	//SEND_SIGNAL(target_turf, COMSIG_ATOM_MAGICALLY_UNLOCKED, src, source)
	playsound(target, 'sound/magic/hereticknock.ogg', 100, TRUE, -1)

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
	cost = 1
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


/datum/heretic_knowledge/mark/lock_mark
	name = "Метка Замка"
	desc = "Ваше Прикосновение Мансуса теперь накладывает Метку Замка. \
			Атакуйте отмеченного человека, чтобы он не мог проходить через шлюзы во время действия метки."
	gain_text = "Привратница была плохим человеком. Она мешала \
				своим товарищам ради собственного извращённого развлечения."
	mark_type = /datum/status_effect/eldritch/lock


/datum/heretic_knowledge/knowledge_ritual/lock


/datum/heretic_knowledge/limited_amount/concierge_rite // item that creates 3 max at a time heretic only barriers, probably should limit to 1 only, holy people can also pass
	name = "Обряд консьержа"
	desc = "Позволяет преобразовать мелок, деревянную доску и мультитул в «Справочник по лабиринту». \
			Он может материализовать баррикаду на расстоянии, через которую сможете пройти только вы и люди, \
			устойчивые к магии. 3 использования."
	gain_text = "Консьерж записал мое имя в справочнике. «Добро пожаловать в ваш новый дом, товарищ Стюард»."
	required_atoms = list(
		/obj/item/toy/crayon = 1,
		/obj/item/stack/sheet/wood = 1,
		/obj/item/multitool = 1,
	)
	result_atoms = list(/obj/item/heretic_labyrinth_handbook)
	cost = 1
	research_tree_icon_path = 'icons/obj/library.dmi'
	research_tree_icon_state = "heretichandbook"


/datum/heretic_knowledge/spell/burglar_finesse
	name = "Хитрость взломщика"
	desc = "Даёт вам «Хитрость взломщика» — заклинание, действующее на одну цель, \
			которое кладёт вам в руку случайный предмет из рюкзака жертвы."
	gain_text = "Общение с духами-взломщиками не приветствуется, но управляющий \
				всегда захочет узнать больше о новых дверях."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "burglarsfinesse"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/burglar_finesse
	cost = 1


/datum/heretic_knowledge/blade_upgrade/flesh/lock //basically a chance-based weeping avulsion version of the former
	name = "Клинок Открытия"
	desc = "Ваш клинок имеет шанс наложить запутанность при атаке."
	gain_text = "«Пилигрим-хирург» не был стюардом. Тем не менее, его лезвия и нити оказались не хуже ключей."
	research_tree_icon_state = "blade_upgrade_lock"
	var/chance = 35


/datum/heretic_knowledge/blade_upgrade/flesh/lock/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!prob(chance) || !istype(target))
		return

	target.Confused(25 SECONDS)


/datum/heretic_knowledge/spell/caretaker_refuge
	name = "Последнее пристанище смотрителя"
	desc = "Даёт вам заклинание, делающее вас прозрачным и неосязаемым. Нельзя использовать рядом с живыми разумными существами. \
			В этом состоянии вы не можете использовать руки или заклинания, а также невосприимчивы к замедлению. \
			Вы неуязвимы, но не можете причинить вред кому-либо. Отменяется ударом антимагического предмета."
	gain_text = "Завистливо преследовали меня Страж и Гончая. Но я скрыл свой облик став неосязаемым туманом."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "caretaker"
	spell_to_add = /obj/effect/proc_holder/spell/caretaker
	cost = 1


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
