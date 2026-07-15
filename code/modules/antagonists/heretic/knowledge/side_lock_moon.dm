/datum/heretic_knowledge/unfathomable_curio
	drafting_tier = 4
	name = "Непостижимая Диковинка"
	desc = "Позволяет преобразовать 3 стержня, лёгкие и любой пояс в Непостижимую Диковинку, \
			пояс, в котором можно хранить клинки и предметы для ритуалов. Если этот пояс надет, \
			он позволит выдержать 5 ударов без получения урона. \
			Вне боя эта защита будет перезаряжаться очень медленно."
	gain_text = "В Обители хранится множество диковинок, большинство из которых не предназначены для глаз смертных."

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
	drafting_tier = 2
	name = "Непостижимое Искусство"
	desc = "Позволяет преобразовать холст и дополнительный предмет для создания картины. \
			Каждая картина обладает уникальным эффектом и рецептом. Возможные варианты: \
			\"Сестра и Плачущий\": Требуется пара глаз. Очищает и лечит ваш разум и накладывает галлюцинации на язычников. \
			\"Фестиваль Желаний\": Требуется отрубленная конечность. Обеспечивает вас случайными органами и накладывает \
			жажду плоти на язычников. \
			\"Мир без Всех Вас\": Требуется любое растение. При размещении разбрасывает кудзу \
			и снабжает вас маками и колокольчиками. \
			\"Леди за Вратами\": Требуется любая пара перчаток. Очищает ваши мутации, мутирует язычников и заставляет их \
				яростно расцарапывать себя. \
			\"Хозяйка Ржавой Горы\": Требуется кусок мусора. Накладывает на язычников проклятие, распространяющее ржавчину \
			на полу, по которому они ходят."
	gain_text = "Ветер вдохновения пронизывал меня. За завесой и за Вратами лежат величайшие творения, которые уже были \
				написаны, и те, которые ещё предстоит написать. Они жаждут смертных глаз."

	required_atoms = list(/obj/item/canvas = 1)
	result_atoms = list(/obj/item/canvas)
	cost = 2

	research_tree_icon_path = 'icons/obj/decals.dmi'
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

/// Upgraded codex that can also cast curses by right-clicking a rune. Requires the victim's blood in your off-hand.
/datum/heretic_knowledge/codex_morbus
	drafting_tier = 2
	name = "Кодекс Хвори"
	desc = "Позволяет объединить Кодекс Истязания и труп в Кодекс Хвори. \
			Он немного быстрее создает руны и изучает разломы. \
			Нажмите по руне, чтобы проклясть членов экипажа. \
			Для того, чтобы проклятие подействовало, требуется кровь цели в сосуде в вашей левой руке \
			(лучше всего сочетать с Проклятой Филактерией)."
	gain_text = "Корешок этого тома в кожаном переплёте скрипит от жуткого, мучительного вздоха. \
				Перелистывание страницы требует значительных усилий, и я не смею задерживаться на \
				предложениях книги дольше, чем необходимо. В ней говорится о грядущих бедствиях, \
				о забытых Богах, ожидающих молитв мёртвых, и об уничтожении смертных. \
				В ней говорится об иглах, сдирающих кожу с мира и оставляющих его гноиться... \
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
