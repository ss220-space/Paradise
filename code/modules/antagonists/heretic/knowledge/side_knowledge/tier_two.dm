/datum/heretic_knowledge/ether
	drafting_tier = 2
	name = "Душа Нерождённого Младенца"
	desc = "Превращает лужу рвоты и осколок в одноразовое зелье. Выпив его, \
			вы избавитесь от любых отклонений в вашем теле, включая болезни, травмы и имплантаты. \
			Кроме того, вы полностью восстановите здоровье, но потеряете сознание на целую минуту."
	gain_text = "Видения и мысли затуманиваются, когда пары этого вещества поднимаются мне навстречу. \
				Сквозь дымку я обнаруживаю, что смотрю на самого себя. Вернее, на что-то, отдалённо \
				напоминающее моё лицо. Именно эта жалкая личность будет следовать моей судьбе. Чью-то \
				чужую судьбу я поглотил вместе с этой дымкой. Как же я глуп."
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/effect/decal/cleanable/vomit = 1,
	)
	result_atoms = list(/obj/item/ether)
	cost = 1
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "poison_flask"


/datum/heretic_knowledge/spell/opening_blast
	drafting_tier = 2
	name = "Волна Отчаяния"
	desc = "Дарует вам \"Волну отчаяния\", заклинание, которое можно применить только будучи скованным. \
			Оно снимает с вас оковы, отталкивает и сбивает с ног окружающих, а также накладывает \"Хватку \
			Обители\" на всё вокруг."
	gain_text = "Мои оковы были разорваны в тёмной ярости, их слабые путы рушатся под давлением моей силы."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "uncuff"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/wave_of_desperation
	cost = 1


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


/datum/heretic_knowledge/rune_carver
	drafting_tier = 2
	name = "Рунный Резак"
	desc = "Позволяет преобразовать нож, осколок стекла и лист бумаги в рунный резак. \
			Рунный резак позволяет создавать руны-ловушки, срабатывающие при \
			наступании на них. \
			Также служит неплохим метательным оружием."
	gain_text = "Высеченный, вырезанный... ныне вечный. Во всём скрыта сила. Я могу раскрыть её! \
				Я могу высечь монолит, чтобы сбросить цепи!"

	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	cost = 1


	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "rune_carver"


/datum/heretic_knowledge/greaves_of_the_prophet
	drafting_tier = 2
	name = "Поножи Пророка"
	desc = "Позволяет объединить пару берцев и 2 листа титана в пару \
			бронированных, не скользящих поножей."
	gain_text = "Хрящи с хрустом проворачиваются в суставах — резкий омерзительный щелчок, и безумец \
		вырывает почерневшую ступню из пасти другого. Веками ведя свою игру, это изувеченное сплетение конечностей \
		корчится и бьётся; вцепившись в оскалённые десны, они пытаются разорвать на части тяжесть своих приросших \
		друг к другу собратьев. Отягощённая истерзанными ногами, эта крона из зловонных идиотов вечно стремится \
		разорвать узы, сковывающие их воедино. Меня страшит мысль о том, чтобы идти по их следам, \
		но я все же обязан двигаться дальше. Их ритмы, не ведающие преград и границ, разжигают вражду \
		с новой силой, вовлекая всё новых и новых участников в этот безумный вальс."
	cost = 1
	required_atoms = list(
		/obj/item/clothing/shoes/jackboots = 1,
		/obj/item/stack/sheet/mineral/titanium = 2,
	)
	result_atoms = list(/obj/item/clothing/shoes/greaves_of_the_prophet)
	research_tree_icon_path = 'icons/obj/clothing/shoes.dmi'
	research_tree_icon_state = "hereticgreaves"


/datum/heretic_knowledge/rifle
	drafting_tier = 2
	name = "Винтовка Охотника на Львов"
	desc = "Позволяет преобразовать кусок дерева, шкуру \
			любого животного и фотоаппарат, в винтовку Охотника на Львов. \
			Винтовка Охотника на львов — это дальнобойное баллистическое оружие, вмещающее три патрона. \
			Попадание по жертве оставляет вашу метку на ней."
	gain_text = "В антикварной лавке я встретил старика, владеющего очень необычным оружием. \
				Тогда я не смог его купить, но старик рассказал, как оно было создано."

	required_atoms = list(
		/obj/item/stack/sheet/wood = 1,
		/obj/item/stack/sheet/animalhide = 1,
		/obj/item/camera = 1,
	)
	result_atoms = list(/obj/item/gun/projectile/shotgun/boltaction/lionhunter)
	cost = 2


	research_tree_icon_path = 'icons/obj/weapons/projectile.dmi'
	research_tree_icon_state = "goldrevolver"


/datum/heretic_knowledge/rifle_ammo
	name = "Боеприпасы для винтовки Охотника на Львов"
	desc = "Позволяет преобразовать 3 гильзы баллистических патронов любого калибра, \
			включая патроны для дробовика, в дополнительный магазин для винтовки Охотника на Львов."
	gain_text = "К оружию прилагались три грубых железных шарика — патрона. \
				Вскоре они закончились. Никакие другие боеприпасы не работали. \
				Тот старик был очень странным."
	required_atoms = list(
		/obj/item/ammo_casing = 3,
	)
	result_atoms = list(/obj/item/ammo_box/speedloader/lionhunter)
	research_tree_icon_path = 'icons/obj/weapons/ammo.dmi'
	research_tree_icon_state = "310_strip"


/datum/heretic_knowledge/rifle_ammo/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return TRUE


/datum/heretic_knowledge/reroll_targets
	drafting_tier = 2
	name = "Неустанное Сердцебиение"
	desc = "Позволяет использовать колокольчик (цветок), книгу и комбинезон, на руне \
			чтобы изменить цели жертвоприношения."
	gain_text = "Отдайте своё сердце принципам. Только тогда они могут называться нерушимыми."
	required_atoms = list(
		/obj/item/reagent_containers/food/snacks/grown/harebell = 1,
		/obj/item/book = 1,
		/obj/item/clothing/under = 1,
	)
	cost = 1
	research_tree_icon_path = 'icons/mob/actions/actions_animal.dmi'
	research_tree_icon_state = "gaze"


/datum/heretic_knowledge/reroll_targets/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)

	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(heretic_datum.has_living_heart() != HERETIC_HAS_LIVING_HEART)
		loc.balloon_alert(user, "нет живого сердца!")
		return FALSE

	return TRUE


/datum/heretic_knowledge/reroll_targets/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	for(var/mob/living/carbon/human/target as anything in heretic_datum.sac_targets)
		heretic_datum.remove_sacrifice_target(target)

	var/datum/heretic_knowledge/hunt_and_sacrifice/target_finder = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!target_finder)
		CRASH("Heretic datum didn't have a hunt_and_sacrifice knowledge learned, what?")

	if(!target_finder.obtain_targets(user, heretic_datum = heretic_datum))
		loc.balloon_alert(user, "нет подходящих целей!")
		return FALSE

	return TRUE


/datum/heretic_knowledge/hypnosis_ritual
	drafting_tier = 2
	name = "Раскрытие Разума"
	desc = "Обнажает разум язычника перед ужасами Обители, гипнотизируя его."
	transmute_text = "Преобразуйте скальпель, осколок стекла, лист бумаги и живого язычника."
	notice = "Язычник будет загипнотизирован тем, что написано на предоставленной бумаге.\
		<br>Если у язычника стоит имплант защиты разума, тот будет уничтожен — но итоговый гипноз может оказаться не таким, как вы ожидали.\
		<br>На других еретиков этот ритуал не действует."
	gain_text = "Моё восхождение было одиноким, но я понял, что так быть не должно. \
		Я могу показать им истину. Их слабые смертные умы могут не выдержать откровения, но из пепла восстанет феникс — свободный и истинный."
	required_atoms = list(
		/obj/item/scalpel = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
		/mob/living/carbon/human = 1,
	)
	cost = 2
	research_tree_icon_path = 'icons/mob/screen_alert.dmi'
	research_tree_icon_state = "hypnosis"


/datum/heretic_knowledge/hypnosis_ritual/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/mob/living/carbon/human/victim in atoms)
		if(victim.stat == DEAD || IS_HERETIC(victim) || victim.has_trauma_type(/datum/brain_trauma/hypnosis))
			atoms -= victim

	var/has_paper = FALSE
	var/has_written_text = FALSE
	for(var/obj/item/paper/paper in atoms)
		has_paper = TRUE
		if(paper.info)
			has_written_text = TRUE

	if(!has_written_text && has_paper)
		loc.balloon_alert(user, "напишите гипноз на бумаге!")
		return FALSE

	return ..()


/datum/heretic_knowledge/hypnosis_ritual/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/hypnosis_text = ""
	for(var/obj/item/paper/paper in selected_atoms)
		hypnosis_text += "[STRIP_HTML_FULL(paper.info, MAX_MESSAGE_LEN)] "

	hypnosis_text = trim(hypnosis_text, MAX_MESSAGE_LEN)
	for(var/mob/living/carbon/human/victim in selected_atoms)
		var/specific_hypnosis_text = (ismindshielded(victim) || !hypnosis_text) ? pick_list(HERETIC_INFLUENCE_FILE, "hypnosis") : hypnosis_text
		for(var/obj/item/implant/mindshield/shield in victim)
			shield.removed(victim)
			qdel(shield)

		selected_atoms -= victim
		var/datum/brain_trauma/hypnosis/trauma = new(specific_hypnosis_text)
		victim.gain_trauma(trauma, TRAUMA_RESILIENCE_LOBOTOMY)

	return TRUE
