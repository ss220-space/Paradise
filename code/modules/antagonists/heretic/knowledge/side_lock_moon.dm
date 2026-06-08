/datum/heretic_knowledge_tree_column/moon_to_lock
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/moon
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/lock

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/spell/mind_gate
	tier2 = list(/datum/heretic_knowledge/unfathomable_curio, /datum/heretic_knowledge/painting)
	tier3 = /datum/heretic_knowledge/codex_morbus

// Sidepaths for knowledge between Knock and Moon.


/datum/heretic_knowledge/spell/mind_gate
	name = "Врата Разума"
	desc = "Даёт вам «Врату Разума» — заклинание, вызывающее у цели галлюцинации, \
			спутанность сознания, удушие и повреждения мозга в течение 10 секунд.\
			Заклинатель получает 20 единиц урона мозгу за каждое применение."
	gain_text = "Мой разум распахивается, как врата, и это, ценой немалых жертв, позволяет мне постичь истину."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "mind_gate"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/mind_gate
	cost = 1


/datum/heretic_knowledge/unfathomable_curio
	name = "Непостижимая Диковинка"
	desc = "Позволяет преобразовать 3 стержня, лёгкие и любой пояс в Непостижимую Диковинку, \
			пояс, в котором можно хранить клинки и предметы для ритуалов. Если этот пояс надет, \
			он позволит выдержать 5 ударов без получения урона. \
			Вне боя эта защита будет перезаряжаться очень медленно."
	gain_text = "В Мансусе хранится множество диковинок, некоторые из которых не предназначены для глаз смертных."

	required_atoms = list(
		/obj/item/organ/internal/lungs = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/belts.dmi'
	research_tree_icon_state = "unfathomable_curio"


/datum/heretic_knowledge/painting
	name = "Непостижимое Искусство"
	desc = "Позволяет преобразовать холст и дополнительный предмет для создания картины. \
			Каждая картина обладает уникальным эффектом и рецептом. Возможные варианты: \
			«Сестра и Плачущий»: Требуется пара Глаз. Очищает и лечит ваш разум и накладывает галлюцинации на нееретиков. \
			«Фестиваль Желаний»: Требуется отрубленная конечность. Обеспечивает вас случайными органами и накладывает \
			жажду плоти на нееретиков. \
			«Мир Без Всех Вас»: Требуется любое растение. При размещении разбрасывает кудзу \
			и снабжает вас маками и колокольчиками. \
			«Леди за Вратами»: Требуется любая пара Перчаток. Очищает ваши мутации, мутирует нееретиков и делает их \
				радиоактивными. \
			«Хозяйка Ржавой Горы»: Требуется кусок Мусора. Накладывает на нееретиков проклятие, вызывая ржавчину \
			на полу, по которому они ходят."
	gain_text = "Ветер вдохновения пронизывал меня. За завесой и за вратами лежат величайшие творения, которые уже были \
				написаны, и те, которые ещё предстоит написать. Они жаждут смертных глаз."

	required_atoms = list(/obj/item/canvas = 1)
	result_atoms = list(/obj/item/canvas)
	cost = 1

	research_tree_icon_path = 'icons/obj/signs.dmi'
	research_tree_icon_state = "eldritch_painting_weeping"


/datum/heretic_knowledge/painting/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(locate(/obj/item/organ/internal/eyes) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/weeping)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/organ/internal/eyes = 1,
		)
		return TRUE

	if(locate(/obj/item/organ/external) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/desire)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/organ/external = 1,
		)
		return TRUE

	if(locate(/obj/item/reagent_containers/food/snacks/grown) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/vines)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/reagent_containers/food/snacks/grown = 1,
		)
		return TRUE

	if(locate(/obj/item/clothing/gloves) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/beauty)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/clothing/gloves = 1,
		)
		return TRUE

	if(locate(/obj/item/trash) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/rust)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/trash = 1,
		)
		return TRUE

	user.balloon_alert(user, "нет второго предмета!")
	return FALSE

/**
 * Codex Morbus, an upgrade to the base codex
 * Functionally an upgraded version of the codex, but it also has the ability to cast curses by right clicking at a rune.
 * Requires you to have the blood of your victim in your off-hand
 */
/datum/heretic_knowledge/codex_morbus
	name = "Кодекс Морбус"
	desc = "Позволяет объединить Кодекс Истезания и труп в Кодекс Морбус. \
			Он немного быстрее создает руны и изучает разломы. \
			Нажмите по руне, чтобы проклясть членов экипажа. \
			Для того, чтобы проклятие подействовало, требуется кровь цели в сосуде в вашей левой руке \
			(лучше всего сочетать с Проклятой Филактерией)."
	gain_text = "Корешок этого тома в кожаном переплёте скрипит от жуткого, мучительного вздоха. \
				Перелистывание страницы требует значительных усилий, и я не смею задерживаться на \
				предложениях книги дольше, чем необходимо. В ней говорится о грядущих бедствиях, \
				о забытых богах ожидающих молитв мёртвых и об уничтожении смертных. \
				В ней говорится об иглах, сдирающих кожу с мира и оставляющих его гноиться. \
				И эта книга обращается ко мне по имени."
	required_atoms = list(
		/obj/item/codex_cicatrix = 1,
		/mob/living/carbon/human = 1,
	)
	result_atoms = list(/obj/item/codex_cicatrix/morbus)
	cost = 1
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "book_morbus"


/datum/heretic_knowledge/codex_morbus/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/mob/living/carbon/human/to_fuck_up = locate() in selected_atoms
	for(var/_limb in to_fuck_up.bodyparts)
		var/obj/item/organ/external/limb = _limb
		limb.fracture()
		limb.internal_bleeding()

	return TRUE
