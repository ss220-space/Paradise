// Heretic starting knowledge.

/// Global list of all heretic knowledge that have is_starting_knowledge = TRUE. List of PATHS.
GLOBAL_LIST_INIT(heretic_start_knowledge, initialize_starting_knowledge())

/**
 * Returns a list of all heretic knowledge TYPEPATHS
 * that have route set to PATH_START.
 */
/proc/initialize_starting_knowledge()
	. = list()
	for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
		if(initial(knowledge.is_starting_knowledge) != TRUE)
			continue

		. += knowledge


/*
 * The base heretic knowledge. Grants the Прикосновение Мансуса spell.
 */
/datum/heretic_knowledge/spell/basic
	name = "Рассвет"
	desc = "Начинает ваше путешествие в Мансус. \
			Даёт вам Прикосновение Мансуса — мощное и улучшаемое \
			заклинание, которое можно применить без Амулета."
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "static"
	spell_to_add = /obj/effect/proc_holder/spell/touch/mansus_grasp
	is_starting_knowledge = TRUE

/*
// Heretics can enhance their fishing rods to fish better - fishing content.
// Lasts until successfully fishing something up.
/datum/heretic_knowledge/spell/basic/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	..()
	RegisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST, PROC_REF(on_grasp_cast))


/datum/heretic_knowledge/spell/basic/proc/on_grasp_cast(mob/living/carbon/cast_on, obj/effect/proc_holder/spell/touch/touch_spell)
	SIGNAL_HANDLER

	// Not a grasp, we dont want this to activate with say star or mending touch.
	if(!istype(touch_spell, spell_to_add))
		return NONE

	var/obj/item/twohanded/fishing_rod/held_rod = cast_on.get_active_hand()
	if(!istype(held_rod, /obj/item/twohanded/fishing_rod) || HAS_TRAIT(held_rod, TRAIT_ROD_MANSUS_INFUSED))
		return NONE

	INVOKE_ASYNC(cast_on, TYPE_PROC_REF(/atom/movable, say), message = "R'CH T'H F'SH!", forced = "fishing rod infusion invocation")
	playsound(cast_on, /obj/effect/proc_holder/spell/touch/mansus_grasp::sound, 15)
	cast_on.visible_message(span_notice("[cast_on] snaps [cast_on.p_their()] fingers next to [held_rod], covering it in a burst of purple flames!"))

	ADD_TRAIT(held_rod, TRAIT_ROD_MANSUS_INFUSED, held_rod.UID())
	held_rod.difficulty_modifier -= 20
	RegisterSignal(held_rod, COMSIG_FISHING_ROD_CAUGHT_FISH, PROC_REF(unfuse))
	held_rod.add_filter("mansus_infusion", 2, list("type" = "outline", "color" = COLOR_VOID_PURPLE, "size" = 1))
	return COMPONENT_CAST_HANDLESS


/datum/heretic_knowledge/spell/basic/proc/unfuse(obj/item/fishing_rod/item, reward, mob/user)
	if(reward != FISHING_INFLUENCE && !prob(35))
		return

	item.remove_filter("mansus_infusion")
	REMOVE_TRAIT(item, TRAIT_ROD_MANSUS_INFUSED, item.UID())
	item.difficulty_modifier += 20
*/
/**
 * The Living Heart heretic knowledge.
 *
 * Gives the heretic a living heart.
 * Also includes a ritual to turn their heart into a living heart.
 */
/datum/heretic_knowledge/living_heart
	name = "Живое Сердце"
	desc = "Даёт вам Живое Сердце, позволяющее отслеживать цели жертвоприношения. \
			Если вы потеряете сердце, вы можете преобразовать мак и лужу крови \
			чтобы переобразовать своё сердце в Живое Сердце. Если ваше сердце кибернетическое, \
			вы не сможете переобразовать его."
	required_atoms = list(
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
	)
	priority = MAX_KNOWLEDGE_PRIORITY - 1 // Knowing how to remake your heart is important
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "living_heart"


/datum/heretic_knowledge/living_heart/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()

	var/obj/item/organ/where_to_put_our_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	// Our heart slot is not valid to put a heart
	if(!is_valid_heart(where_to_put_our_heart))
		where_to_put_our_heart = null

	// If a heretic is made from a species without a heart, we need to find a backup.
	if(!where_to_put_our_heart)
		var/static/list/backup_organs = list(
			INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs,
			INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver,
			//INTERNAL_ORGAN_STOMACH = /obj/item/organ/internal/stomach,
		)

		for(var/backup_slot in backup_organs)
			var/obj/item/organ/look_for_backup = user.get_organ_slot(backup_slot)
			// This backup slot is not a valid slot to put a heart
			if(!is_valid_heart(look_for_backup))
				continue

			// We found a replacement place to put our heart
			where_to_put_our_heart = look_for_backup
			our_heretic.living_heart_organ_slot = backup_slot
			to_chat(user, span_boldnotice("Поскольку у вашего вида нет сердца, ваше Живое Сердце находится в вашем [look_for_backup.declent_ru(PREPOSITIONAL)]."))
			break

	if(!where_to_put_our_heart)
		to_chat(user, span_boldnotice("У вас нет сердца, да и вообще каких-либо органов в грудной клетке. Из-за этого вы не получили живое сердце."))
		return

	where_to_put_our_heart.AddComponent(/datum/component/living_heart)
	desc = "Даёт вам Живое Сердце, привязанное к ваш[genderize_ru(where_to_put_our_heart.gender, "ему", "ей", "ему", "им")] [where_to_put_our_heart.declent_ru(DATIVE)], позволяющее отслеживать цели жертвоприношений. \
			Если вы потеряете своё [where_to_put_our_heart.declent_ru(ACCUSATIVE)], вы можете преобразовать мак и лужу крови, \
			чтобы пробудить силы Живого Сердца в ваш[genderize_ru(where_to_put_our_heart.gender, "ем", "ей", "ем", "их")] [where_to_put_our_heart.declent_ru(DATIVE)]. \
			Кибернетическ[genderize_ru(where_to_put_our_heart.gender, "ий", "ая", "ое", "ие")] [where_to_put_our_heart.declent_ru(NOMINATIVE)] не позвол[pluralize_ru(where_to_put_our_heart.gender, "ит", "ят")] провести ритуал!"


/datum/heretic_knowledge/living_heart/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	var/obj/item/organ/our_living_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	if(!our_living_heart)
		return

	qdel(our_living_heart.GetComponent(/datum/component/living_heart))


// Don't bother letting them invoke this ritual if they have a Living Heart already in their chest
/datum/heretic_knowledge/living_heart/can_be_invoked(datum/antagonist/heretic/invoker)
	return invoker.has_living_heart() != HERETIC_HAS_LIVING_HEART


/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/obj/item/organ/our_living_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	// No heart, nothing to give living heart to
	if(QDELETED(our_living_heart))
		loc.balloon_alert(user, "провал, нет сердца!")
		return FALSE

	// For sanity's sake, check if they've got a living heart -
	// even though it's not invokable if you already have one,
	// they may have gained one unexpectantly in between now and then
	if(HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		loc.balloon_alert(user, "провал, способность занята!")
		return FALSE

	// By this point they are making a new heart
	// If their current heart is organic / not synthetic, we can continue the ritual as normal
	if(is_valid_heart(our_living_heart))
		return TRUE

	loc.balloon_alert(user, "орган не подходит!") // "heart can't be awakened!"
	return FALSE


/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/obj/item/organ/our_new_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	// Don't delete our shiny new heart
	selected_atoms -= our_new_heart
	// Make it the living heart
	our_new_heart.AddComponent(/datum/component/living_heart)
	to_chat(user, span_warning("Вы чувствуете как [our_new_heart.declent_ru(NOMINATIVE)] начинает яростно биться!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	return TRUE


/// Checks if the passed heart is a valid heart to become a living heart
/datum/heretic_knowledge/living_heart/proc/is_valid_heart(obj/item/organ/new_heart)
	if(QDELETED(new_heart))
		return FALSE

	if(new_heart.is_dead())
		return FALSE

	if(HASBIT(new_heart.status, ORGAN_ROBOT))
		return FALSE

	return TRUE


/**
 * Allows the heretic to craft a spell focus.
 * They require a focus to cast advanced spells.
 */
/datum/heretic_knowledge/amber_focus
	name = "Янтарный Амулет"
	desc = "Позволяет преобразовать лист стекла и пару глаз в Янтарный Амулет.\
			Для использования более сложных заклинаний необходимо надеть Амулет."
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus)
	priority = MAX_KNOWLEDGE_PRIORITY - 2 // Not as important as making a heart or sacrificing, but important enough.
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'icons/obj/clothing/neck.dmi'
	research_tree_icon_state = "eldritch_necklace"


/datum/heretic_knowledge/spell/heretic_menu
	name = "Меню Еретика"
	desc = "Открывает меню, в котором можно изучать новые знания."
	research_tree_icon_path = 'icons/mob/actions/actions.dmi'
	research_tree_icon_state = "spell_default"
	spell_to_add = /obj/effect/proc_holder/spell/heretic_menu
	is_starting_knowledge = TRUE


/datum/heretic_knowledge/spell/cloak_of_shadows
	name = "Плащ Тьмы"
	desc = "Даёт вам заклинание «Плащ тьмы». Это заклинание полностью скроет вашу личность в фиолетовом дыму \
			на три минуты, помогая вам сохранять скрытность. Для применения требуется концентрация."
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "curse"
	spell_to_add = /obj/effect/proc_holder/spell/shadow_cloak
	is_starting_knowledge = TRUE

/**
 * Кодекс Истезания is available at the start:
 * This allows heretics to choose if they want to rush all the influences and take them stealthily, or
 * Construct a codex and take what's left with more points.
 * Another downside to having the book is strip searches, which means that it's not just a free nab, at least until you get exposed - and when you do, you'll probably need the faster drawing speed.
 * Overall, it's a tradeoff between speed and stealth or power.
 */
/datum/heretic_knowledge/codex_cicatrix
	name = "Кодекс Истезания"
	desc = "Позволяет трансмутировать книгу, любую уникальную ручку (не обычную) и любой предмет на ваш выбор из туши (животного или человека), кожи или шкуры, чтобы создать Кодекс Истезания. \
			Кодекс Истезания можно использовать чтобы поглотить раскол реальности для получения дополнительных знаний, но он это сопряжено с повышеннием риска быть замеченным. \
			Его также можно использовать для более удобного рисования и удаления рун трансмутации, а также вместо Янтарного Амулета."
	gain_text = "Потусторонние силы оставляют фрагменты знаний и силы повсюду. Кодекс Истезания — одно из доказательств. \
				На кожанных страницах находятся знания открывающие путь к Мансусу."
	required_atoms = list(
		list(/obj/item/book) = 1,
		/obj/item/pen = 1,
		list(/mob/living, /obj/item/stack/sheet/leather, /obj/item/stack/sheet/animalhide) = 1,
	)
	banned_atom_types = list(/obj/item/pen)
	result_atoms = list(/obj/item/codex_cicatrix)
	cost = 1
	is_starting_knowledge = TRUE
	priority = MAX_KNOWLEDGE_PRIORITY - 4 // Least priority out of the starting knowledges, as it's an optional boon.
	var/static/list/non_mob_bindings = typecacheof(list(/obj/item/stack/sheet/leather, /obj/item/stack/sheet/animalhide, /mob/living/simple_animal/mouse))
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "book"


/datum/heretic_knowledge/codex_cicatrix/parse_required_item(atom/item_path, number_of_things)
	if(item_path == /obj/item/pen)
		return "особый вид ручки"

	return ..()


/datum/heretic_knowledge/codex_cicatrix/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/thingy in atoms)
		if(is_type_in_typecache(thingy, non_mob_bindings))
			selected_atoms += thingy
			return TRUE

		else if(!isliving(thingy))
			continue

		var/mob/living/body = thingy
		if(body.stat != DEAD)
			continue

		selected_atoms += body
		return TRUE

	user.balloon_alert(user, "нет трупа")
	return FALSE


/datum/heretic_knowledge/codex_cicatrix/cleanup_atoms(list/selected_atoms)
	var/mob/living/body = locate() in selected_atoms
	if(!body)
		return ..()

	// A golem or an android doesn't have skin!
	//var/exterior_text = "skin"
	// If carbon, it's the limb. If not, it's the body.
	var/atom/movable/ripped_thing = body

	// We will check if it's a carbon's body.
	// If it is, we will damage a random bodypart, and check that bodypart for its body type, to select between 'skin' or 'exterior'.
	if(iscarbon(body))
		var/mob/living/carbon/human/human_body = body
		var/obj/item/organ/external/bodypart = pick(human_body.bodyparts)
		ripped_thing = bodypart

		human_body.apply_damage(25, BRUTE, bodypart, sharp = TRUE)
		//if(!(bodypart.bodytype & BODYTYPE_ORGANIC))
		//	exterior_text = "exterior"
	else
		body.apply_damage(25, BRUTE, sharp = TRUE)
		// If it is not a carbon mob, we will just check biotypes and damage it directly.
		//if(body.mob_biotypes & (MOB_MINERAL|MOB_ROBOTIC))
		//	exterior_text = "exterior"

	// Procure book for flavor text. This is why we call parent at the end.
	var/obj/item/book/le_book = locate() in selected_atoms
	if(!le_book)
		stack_trace("Somehow, no book in Кодекс Истезания selected atoms! [english_list(selected_atoms)]")

	playsound(body, 'sound/items/poster_ripped.ogg', 100, TRUE)
	body.do_jitter_animation()
	body.visible_message(span_danger("Раздается ужасный звук, когда кожа отделяется от [ripped_thing.declent_ru(GENITIVE)] и обретает жутковатый синий оттенок становясь обложкой [le_book.declent_ru(GENITIVE)]!"))
	return ..()


/datum/heretic_knowledge/feast_of_owls
	name = "Фестиваль Сов"
	desc = "Позволяет пройти ритуал, дающий 5 очков знаний, но блокирующий возможность вознесения. Это можно сделать только один раз."
	gain_text = "Под мягким сиянием безумия в ночи крадётся зверь. Я смирюсь со своей судьбой и позволю ему найти меня. Он насытится моими амбициями и оставит после себя знание."
	is_starting_knowledge = TRUE
	required_atoms = list()
	research_tree_icon_path = 'icons/mob/actions/actions_animal.dmi'
	research_tree_icon_state = "god_transmit"
	/// amount of research points granted
	var/reward = 5


/datum/heretic_knowledge/feast_of_owls/can_be_invoked(datum/antagonist/heretic/invoker)
	return !invoker.feast_of_owls


/datum/heretic_knowledge/feast_of_owls/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/alert = tgui_alert(user, "Вы действительно хотите отказаться от своего вознесения? Это действие необратимо.", "Фестиваль Сов", list("Да, я уверен", "Нет"), 30 SECONDS)
	if(alert == "Нет" || QDELETED(user) || QDELETED(src) || get_dist(user, loc) > 2)
		return FALSE

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(QDELETED(heretic_datum) || heretic_datum.feast_of_owls)
		return FALSE

	. = TRUE

	heretic_datum.feast_of_owls = TRUE
	user.EyeBlind(reward * 1 SECONDS)
	user.AdjustParalysis(reward * 1 SECONDS)
	user.playsound_local(get_turf(user), 'sound/music/heretic/heretic_gain_intense.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	for(var/i in 1 to reward)
		user.emote("scream")
		playsound(loc, 'sound/items/eatfood.ogg', 100, TRUE)
		heretic_datum.knowledge_points++
		to_chat(user, span_danger("Вы чувствуете, как что-то невидимое разрывает самую вашу суть!"))
		user.do_jitter_animation()
		sleep(1 SECONDS)
		if(QDELETED(user) || QDELETED(heretic_datum))
			return FALSE

	to_chat(user, span_danger(span_big("Ваши амбиции разрушены, но что-то могущественное осталось после них...")))
	var/drain_message = pick_list(HERETIC_INFLUENCE_FILE, "drain_message")
	to_chat(user, span_purple(span_big("[drain_message]")))
	return .

/*
/**
 * Warren King's Welcome
 * Ritual available at the start. So that heretics can easily gain access to maintenance airlocks without having to rely on a HoP or having to off some poor assistant.
 * Gives access to solars since those doors are especially useful to get in or out of space.
 */
/datum/heretic_knowledge/bookworm
	name = "Приветствие короля Уоррена"
	desc = "Позволяет преобразовать 5 кусков кабеля и лист бумаги в любую ID карту с доступом к тех тоннелям и внешним шлюзам."
	gain_text = "Въевшись в кости пальцев, существо направляет мой гудящий, затуманенный разум к массивной двери. \
				Медленно свет танцует среди наползающей тьмы, покрывая зловонный променад бесконечными бликами. \
				Но король скоро получит свой фунт плоти. Даже здесь сборщик налогов получает свою долю. Ибо нужно кормить тысячи ртов."
	required_atoms = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/paper = 1,
	)
	cost = 1
	is_starting_knowledge = TRUE
	priority = MAX_KNOWLEDGE_PRIORITY - 3
	research_tree_icon_path = 'icons/obj/card.dmi'
	research_tree_icon_state = "eldritch"


/datum/heretic_knowledge/bookworm/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/card/id/used_id in atoms)
		if((ACCESS_MAINT_TUNNELS in used_id.access) && (ACCESS_EXTERNAL_AIRLOCKS in used_id.access)) // If we can't give any access we aren't elligible
			continue

		selected_atoms += used_id
		return TRUE

	user.balloon_alert(user, "провал, нет доступа!")
	return FALSE


/datum/heretic_knowledge/bookworm/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/obj/item/card/id/improved_id = locate() in selected_atoms
	improved_id.access |= list(ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS)
	selected_atoms -= improved_id
	return TRUE
*/
