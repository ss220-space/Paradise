
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


/// The base heretic knowledge. Grants the Хватка Обители spell.
/datum/heretic_knowledge/spell/basic
	name = "Рассвет"
	desc = "Начинает ваше путешествие по Обители. \
			Даёт вам \"Хватку Обители\", мощное и улучшаемое \
			заклинание, которое можно применить без фокуса."
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "static"
	spell_to_add = /obj/effect/proc_holder/spell/touch/mansus_grasp
	is_starting_knowledge = TRUE

/*
/datum/heretic_knowledge/spell/basic/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	..()
	RegisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST, PROC_REF(on_grasp_cast))


/datum/heretic_knowledge/spell/basic/proc/on_grasp_cast(mob/living/carbon/cast_on, obj/effect/proc_holder/spell/touch/touch_spell)
	SIGNAL_HANDLER

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
/// Gives the heretic a living heart, and a ritual to turn their heart into one if lost.
/datum/heretic_knowledge/living_heart
	name = "Живое Сердце"
	desc = "Даёт вам \"Живое Сердце\", позволяющее отслеживать цели жертвоприношения. \
			Если вы потеряете сердце, вы можете использовать мак и лужу крови, \
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
	if(!is_valid_heart(where_to_put_our_heart))
		where_to_put_our_heart = null

	if(!where_to_put_our_heart)
		var/static/list/backup_organs = list(
			INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs,
			INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver,
		)

		for(var/backup_slot in backup_organs)
			var/obj/item/organ/look_for_backup = user.get_organ_slot(backup_slot)
			if(!is_valid_heart(look_for_backup))
				continue

			where_to_put_our_heart = look_for_backup
			our_heretic.living_heart_organ_slot = backup_slot
			to_chat(user, span_boldnotice("Поскольку у вашего вида нет сердца, ваше Живое Сердце находится в ваш[GEND_EM_EI_EM_IH(look_for_backup)] [look_for_backup.declent_ru(PREPOSITIONAL)]."))
			break

	if(!where_to_put_our_heart)
		for(var/fallback_slot in list(INTERNAL_ORGAN_HEART, INTERNAL_ORGAN_BRAIN))
			var/obj/item/organ/fallback_organ = user.get_organ_slot(fallback_slot)
			if(!fallback_organ)
				continue
			where_to_put_our_heart = fallback_organ
			our_heretic.living_heart_organ_slot = fallback_slot
			to_chat(user, span_boldnotice("Поскольку ваше тело синтетическое, ваше Живое Сердце пробуждается в ваш[GEND_EM_EI_EM_IH(fallback_organ)] [fallback_organ.declent_ru(PREPOSITIONAL)]."))
			break

	if(!where_to_put_our_heart)
		to_chat(user, span_boldnotice("У вас нет сердца, да и вообще каких-либо органов в грудной клетке. Из-за этого вы не получили Живое Сердце."))
		return

	where_to_put_our_heart.AddComponent(/datum/component/living_heart)
	desc = "Даёт вам Живое Сердце, привязанное к ваш[GEND_HIM_HER(where_to_put_our_heart)] [where_to_put_our_heart.declent_ru(DATIVE)], позволяющее отслеживать цели жертвоприношений. \
			Если вы потеряете своё [where_to_put_our_heart.declent_ru(ACCUSATIVE)], вы можете преобразовать мак и лужу крови, \
			чтобы пробудить силы Живого Сердца в ваш[GEND_EM_EI_EM_IH(where_to_put_our_heart)] [where_to_put_our_heart.declent_ru(DATIVE)]. \
			Кибернетическ[UNLINT(genderize_ru(where_to_put_our_heart.gender, "ий", "ая", "ое", "ие"))] [where_to_put_our_heart.declent_ru(NOMINATIVE)] не позвол[PLUR_IT_YAT(where_to_put_our_heart)] провести ритуал!"


/datum/heretic_knowledge/living_heart/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	var/obj/item/organ/our_living_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	if(!our_living_heart)
		return

	qdel(our_living_heart.GetComponent(/datum/component/living_heart))


/datum/heretic_knowledge/living_heart/can_be_invoked(datum/antagonist/heretic/invoker)
	return invoker.has_living_heart() != HERETIC_HAS_LIVING_HEART


/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/obj/item/organ/our_living_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	if(QDELETED(our_living_heart))
		loc.balloon_alert(user, "провал, нет сердца!")
		return FALSE

	if(HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		loc.balloon_alert(user, "провал, способность занята!")
		return FALSE

	if(is_valid_heart(our_living_heart))
		return TRUE

	loc.balloon_alert(user, "орган не подходит!") // "heart can't be awakened!"
	return FALSE


/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/obj/item/organ/our_new_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	selected_atoms -= our_new_heart
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


/// Allows the heretic to craft a spell focus, required to cast advanced spells.
/datum/heretic_knowledge/amber_focus
	name = "Янтарный Амулет"
	desc = "Позволяет преобразовать лист стекла и пару глаз в Янтарный Амулет. \
			Предоставляет носителю фокус, необходимый для использования более сложных заклинаний."
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
	desc = "Даёт вам заклинание \"Плащ Тьмы\". Это заклинание полностью скроет вашу личность в фиолетовом дыму \
			на три минуты, помогая вам сохранять скрытность."
	notice = "Можно применить, только пока у вас есть Живое Сердце."
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "curse"
	spell_to_add = /obj/effect/proc_holder/spell/shadow_cloak
	cost = 1
	drafting_tier = 1
	is_shop_only = TRUE

/// Кодекс Истязания: lets heretics rush influences stealthily, or build a codex to take what's left
/// for more points - a tradeoff between speed/stealth and power, with strip searches as the downside.
/datum/heretic_knowledge/codex_cicatrix
	drafting_tier = 1
	is_shop_only = TRUE
	name = "Кодекс Истязания"
	desc = "Позволяет трансмутировать книгу, любую уникальную ручку (не обычную) и любой предмет на ваш выбор из туши (животного или человека), кожи или шкуры, чтобы создать Кодекс Истязания. \
			Кодекс Истязания можно использовать для получения дополнительных знаний при поглощении раскола реальности. \
			Кроме этого его можно использовать для более удобного рисования и удаления рун трансмутации, а также в качестве источника фокуса при сотворении заклинаний."
	gain_text = "Потусторонние силы оставляют фрагменты знаний и силы повсюду. Кодекс Истязания — одно из доказательств. \
				На кожанных страницах находятся знания, открывающие путь к Обители."
	required_atoms = list(
		/obj/item/book = 1,
		/obj/item/pen = 1,
		list(/mob/living, /obj/item/stack/sheet/leather, /obj/item/stack/sheet/animalhide) = 1,
	)
	banned_atom_types = list(/obj/item/pen)
	result_atoms = list(/obj/item/codex_cicatrix)
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 4 // Low ritual priority, as it's an optional boon.
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

	user.balloon_alert(user, "нет трупа!")
	return FALSE


/datum/heretic_knowledge/codex_cicatrix/cleanup_atoms(list/selected_atoms)
	var/mob/living/body = locate() in selected_atoms
	if(!body)
		return ..()

	var/atom/movable/ripped_thing = body

	if(iscarbon(body))
		var/mob/living/carbon/human/human_body = body
		var/obj/item/organ/external/bodypart = pick(human_body.bodyparts)
		ripped_thing = bodypart

		human_body.apply_damage(25, BRUTE, bodypart, sharp = TRUE)
	else
		body.apply_damage(25, BRUTE, sharp = TRUE)

	var/obj/item/book/le_book = locate() in selected_atoms
	if(!le_book)
		stack_trace("Somehow, no book in Codex Cicatrix selected atoms! [english_list(selected_atoms)]")

	playsound(body, 'sound/items/poster_ripped.ogg', 100, TRUE)
	body.do_jitter_animation()
	body.visible_message(span_danger("Раздается ужасный звук, когда кожа отделяется от [ripped_thing.declent_ru(GENITIVE)] и обретает жутковатый синий оттенок, становясь обложкой [le_book.declent_ru(GENITIVE)]!"))
	return ..()


/datum/heretic_knowledge/miraculous_mirror
	drafting_tier = 1
	is_shop_only = TRUE
	name = "Чудотворное Зеркало"
	desc = "Позволяет создать Чудотворное Зеркало.<br>\
			Чудотворное Зеркало позволяет вам свободно менять любые черты своей внешности. \
			Через него можно даже сменить расу, но при этом зеркало разобьётся. \
			Язычник, заглянувший в зеркало, впадёт в транс, и отражение изменит его по своей прихоти."
	transmute_text = "Преобразуйте пять слитков серебра и пару органических глаз."
	gain_text = "Я был несовершенен, слаб. Как я мог достичь столь великих свершений в столь жалком состоянии? \
				В каждом окне, мимо которого я проходил, я видел своё отражение — и всякий раз чувствовал жгучее желание измениться, стать лучше, начать заново."
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/stack/sheet/mineral/silver = 5,
	)
	result_atoms = list(/obj/item/mounted/mirror/heretic)
	cost = 1
	research_tree_icon_path = 'icons/obj/watercloset.dmi'
	research_tree_icon_state = "magic_mirror"


/datum/heretic_knowledge/miraculous_mirror/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/organ/internal/eyes/eye in atoms)
		if(eye.is_robotic())
			atoms -= eye


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
	var/alert = tgui_alert(user, "Вы действительно хотите отказаться от своего вознесения? Это действие необратимо.", "Фестиваль Сов", list("Да", "Нет"), 30 SECONDS)
	if(alert != "Да" || QDELETED(user) || QDELETED(src) || get_dist(user, loc) > 2)
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

/// Warren King's Welcome: lets heretics gain maintenance/external airlock access without relying on
/// a HoP or having to off some poor assistant, and brand nearby airlocks as their own.
/datum/heretic_knowledge/bookworm
	drafting_tier = 1
	name = "Приветствие короля Уоррена"
	desc = "Ставит клеймо на все принесённые ID-карты и ближайшие шлюзы.<br>\
			Заклеймённые ID-карты получают доступ к тех тоннелям, внешним шлюзам, а также к заклеймённым шлюзам.<br>\
			Заклеймённые шлюзы открываются только заклеймённой ID-картой."
	transmute_text = "Преобразуйте 10 кусков кабеля, лист бумаги и мультитул."
	gain_text = "Въевшись в кости пальцев, существо направляет мой гудящий, затуманенный разум к массивной двери. \
				Медленно свет танцует среди наползающей тьмы, покрывая зловонный променад бесконечными бликами. \
				Но король скоро получит свой фунт плоти. Даже здесь сборщик налогов получает свою долю. Ибо нужно кормить тысячи ртов."
	required_atoms = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/paper = 1,
		/obj/item/multitool = 1,
	)
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 3
	research_tree_icon_path = 'icons/obj/card.dmi'
	research_tree_icon_state = "eldritch"


/datum/heretic_knowledge/bookworm/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/card/id/used_id in atoms)
		selected_atoms += used_id
	var/obj/item/card/id/user_card = user.get_id_card()
	if(istype(user_card))
		selected_atoms |= user_card


/datum/heretic_knowledge/bookworm/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/card/id/improved_id in selected_atoms)
		improved_id.access |= list(ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_HERETIC)
		selected_atoms -= improved_id
	for(var/obj/machinery/door/airlock/door in view(7, loc))
		door.req_access = list(ACCESS_HERETIC)
		door.wires?.cut(WIRE_AI_CONTROL)
		do_sparks(3, FALSE, door.loc)
		var/obj/effect/light_emitter/brand_light = new(door.loc)
		brand_light.set_light(1.75, 1.5, "#a95c68")
		QDEL_IN(brand_light, 1 SECONDS)
		playsound(door, 'sound/magic/castsummon.ogg', 20, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)
		playsound(door, SFX_SPARKS, 33, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)

	return TRUE
