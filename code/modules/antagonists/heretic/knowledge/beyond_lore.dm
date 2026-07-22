
/datum/heretic_knowledge_tree_column/main/beyond

	route = PATH_BEYOND
	ui_bgr = "node_glitch"
	disabled_reason = "Путь отправлен на переработку и временно недоступен для выбора."
	complexity = "Сложный"
	complexity_color = "#c93b3b"
	path_description = list(
		"Путь Beyond строится вокруг перестановки противников, отмены их действий и накопления Runtime Error.",
		"Берите этот путь, если готовы выигрывать бой заранее, а не в момент удара.",
	)
	path_pros = list(
		"Меняйте местами кого угодно и что угодно в поле зрения.",
		"Отменяйте выстрелы, удары и заклинания до того, как они случатся.",
		"Запирайте узкие коридоры областями задержки.",
		"Две Runtime Error крашат цель: паралич, немота и сорванное действие.",
	)
	path_cons = list(
		"Низкий прямой урон, пока вы не изучите Нулевую Ссылку.",
		"Чтобы уронить цель, нужно последовательно сложить несколько эффектов.",
		"Почти всё, что вы делаете, останавливается магической защитой.",
		"Бесплатного прохода сквозь стены путь не даёт.",
	)
	path_tips = list(
		"\"Хватка Обители\" выделяет цель на 15 секунд: вы видите её сквозь стены и знаете, \
		сколько у неё здоровья. Удар любым вашим клинком по выделенной цели активирует метку.",
		"Активированная метка вешает Rubberband: четыре секунды жертва не может отойти дальше \
		одной плитки от места, где стояла. Стрелять и бить она при этом может.",
		"Враждебная телепортация рвёт Rubberband, но оставляет ещё одну ошибку — телепортом можно доломать цель.",
		"\"Потеря Пакета\" съедает следующее осознанное действие. Умная жертва потратит его на что-то безобидное, \
		так что накладывайте эффект тогда, когда ей нельзя терять ход.",
		"Первое попадание каждой жертвы в конкретную область задержки даёт ошибку. Загоняйте людей \
		в поле \"Подменой Ссылок\" — это ещё одна ошибка сверху.",
		"Копии из \"Дублирования Кадров\" — законные цели \"Подмены Ссылок\". Меняйтесь с копией местами, \
		чтобы мгновенно уйти из окружения.",
		"\"Просмотр Переменных\" даёт добить цель через stat = UNCONSCIOUS, но только если на ней уже висит ошибка.",
	)
	passive_name = "Ошибка Состояния"
	passive_descriptions = list(
		"Вас невозможно уронить скользкой поверхностью: вода, лёд, мыло, кровь и кожура вас не касаются.",
		"Ползание больше не замедляет вас — лёжа вы двигаетесь со скоростью шага.",
		"Полный иммунитет к оглушению, параличу, обездвиживанию и сбиванию с ног.",
	)
	start = /datum/heretic_knowledge/limited_amount/starting/base_beyond
	knowledge_tier1 = /datum/heretic_knowledge/spell/reference_swap
	knowledge_tier2 = /datum/heretic_knowledge/spell/packet_loss
	robes = /datum/heretic_knowledge/armor/beyond
	knowledge_tier3 = /datum/heretic_knowledge/spell/lag_spike
	blade = /datum/heretic_knowledge/blade_upgrade/beyond
	knowledge_tier4 = /datum/heretic_knowledge/spell/view_variables
	ascension = /datum/heretic_knowledge/ultimate/beyond_final
	guaranteed_side_tier1 = /datum/heretic_knowledge/eldritch_coin
	guaranteed_side_tier2 = /datum/heretic_knowledge/spell/burglar_finesse
	guaranteed_side_tier3 = /datum/heretic_knowledge/essence


/datum/heretic_knowledge/limited_amount/starting/base_beyond
	name = "Dream Maker"
	desc = "Открывает вам Путь Beyond. \
			Позволяет преобразовать кухонный нож, мультитул и два сканирующих модуля в Невозможный Клинок. \
			Вы можете создать только два клинка одновременно. \
			Ваша \"Хватка Обители\" начинает выделять цели."
	gain_text = "Я увидел мир без света, имён и формы. Комнаты назывались областями, \
				люди — мобами, а моя душа хранилась в переменной. Затем Наблюдатель указал на меня курсором."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/multitool = 1,
		/obj/item/stock_parts/scanning_module = 2,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/beyond)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "beyond_blade"
	mark_type = /datum/status_effect/eldritch/beyond
	passive_type = /datum/status_effect/heretic_passive/beyond


/datum/heretic_knowledge/limited_amount/starting/base_beyond/create_mark(mob/living/source, mob/living/target)
	if(target.stat == DEAD)
		return
	return target.apply_status_effect(mark_type, source)


/datum/heretic_knowledge/limited_amount/starting/base_beyond/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()
	give_runtime_error(target, source)


/datum/heretic_knowledge/spell/reference_swap
	drafting_tier = 5
	name = "Подмена Ссылок"
	desc = "Даёт вам \"Подмену Ссылок\", заклинание, меняющее местами два объекта или существа. \
			Обе цели должны быть в пределах девяти плиток от вас и девяти плиток друг от друга. \
			Каждая перемещённая жертва получает Runtime Error."
	gain_text = "Наблюдатель не двигал фигуры. Он лишь исправлял координаты, \
				в которых они всегда должны были находиться."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "reference_swap"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/reference_swap
	cost = 2


/datum/heretic_knowledge/spell/packet_loss
	name = "Потеря Пакета"
	desc = "Даёт вам \"Потерю Пакета\", заклинание, повреждающее соединение цели на восемь секунд. \
			Следующее её осознанное действие не дойдёт до мира и оставит Runtime Error. \
			Движение, речь и смена руки не блокируются."
	gain_text = "Его рука пришла в движение, но мир так и не получил сведения об ударе."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "packet_loss"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/packet_loss
	cost = 2


/datum/heretic_knowledge/armor/beyond
	name = "Некомпилируемая Оболочка"
	desc = "Позволяет преобразовать стол (или верхнюю одежду), маску, мультитул и три микроманипулятора \
			в Некомпилируемую Оболочку. Она хорошо защищает, ничем вас не замедляет и даёт способность \
			\"Дублирование Кадров\". Действует как источник фокуса, пока надет капюшон. \
			Тот, кто наденет её не будучи еретиком, начнёт сыпать собственными повреждёнными копиями."
	gain_text = "Моё тело не успевало за движением. Позади шли его прошлые версии, \
				всё ещё уверенные, что именно они настоящие."
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/multitool = 1,
		/obj/item/stock_parts/manipulator = 3,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/beyond)
	research_tree_icon_state = "glitch_armor"
	research_tree_icon_frame = 1


/datum/heretic_knowledge/spell/lag_spike
	name = "Скачок Задержки"
	desc = "Даёт вам \"Скачок Задержки\", заклинание, разворачивающее область 5x5 на восемь секунд. \
			Внутри неё чужаки двигаются и действуют медленнее и периодически застывают, а снаряды вязнут. \
			Первое попадание каждой жертвы в конкретное поле оставляет Runtime Error."
	gain_text = "Мир остановился не полностью. Некоторые вещи продолжали двигаться, \
				ожидая подтверждения от места, которого не существовало."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "lag_spike"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/lag_spike
	cost = 2


/datum/heretic_knowledge/blade_upgrade/beyond
	name = "Нулевая Ссылка"
	desc = "Ваш клинок начинает повреждать связь вещей с миром. Успешный удар по живой цели накладывает \
			Runtime Error, но не чаще раза в две с половиной секунды на одну и ту же жертву. \
			Краш, вызванный вашим ударом, дополнительно наносит 10 урона, выбивает предмет из руки \
			и не даёт поднять его три секунды. \
			Кроме того, клинок в руке позволяет обнулить ссылку на предмет в чужих руках."
	gain_text = "Лезвие не рассекало плоть. Оно рассекало связь между вещью и миром, \
				который пытался её запомнить."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_beyond"
	var/error_cooldown = 2.5 SECONDS


/datum/heretic_knowledge/blade_upgrade/beyond/on_gain(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	for(var/obj/item/melee/sickly_blade/beyond/blade in user.get_all_contents_type(/obj/item/melee/sickly_blade/beyond))
		blade.update_appearance(UPDATE_ICON)
	user.update_held_items()


/datum/heretic_knowledge/blade_upgrade/beyond/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	if(!TIMER_COOLDOWN_FINISHED(target, COOLDOWN_BEYOND_BLADE_ERROR))
		return

	TIMER_COOLDOWN_START(target, COOLDOWN_BEYOND_BLADE_ERROR, error_cooldown)
	give_runtime_error(target, source)


/datum/heretic_knowledge/spell/view_variables
	name = "Просмотр Переменных"
	desc = "Даёт вам \"Просмотр Переменных\", заклинание, позволяющее временно переписать одно свойство цели: \
			приколотить её к полу, вычеркнуть из физического мира или обнулить её видимость. \
			Если на цели уже висит ошибка, вместо этого можно выключить ей сознание."
	gain_text = "Я увидел не лицо человека, а список свойств. Одно из них было истинным. \
				Остальные просто ещё не изменили."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "view_variables"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/view_variables
	cost = 2
	is_final_knowledge = TRUE


/datum/heretic_knowledge/ultimate/beyond_final
	name = "Права Хоста"
	desc = "Ритуал вознесения Пути Beyond. \
			Поднесите 3 трупа, 3 мультитула и блюспейс-кристалл к руне трансмутации, чтобы завершить ритуал. \
			После вознесения вы получаете полный иммунитет к станам и три новые способности: \
			Pause(), останавливающую всё вокруг; Reboot Area(), откатывающую область на пять секунд назад; \
			и qdel(), стирающую добитое существо из мира. \
			Мир перестаёт помнить, как вас зовут, а позади вас тянутся ваши прошлые кадры."
	gain_text = "Наблюдатель никогда не был богом. Он был пользователем. Мансус никогда не был миром. \
				Он был процессом. Теперь системное сообщение произносит моё имя: Host connected."

	announcement_text = "%SPOOKY% Host connected. Реальность больше не отвечает на запросы. \
						Сущность %NAME% получила права на изменение мира. %SPOOKY%"
	announcement_sound = 'sound/machines/terminal_alert.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "beyondascend"
	required_atoms = list(
		/mob/living/carbon/human = 3,
		/obj/item/multitool = 3,
		/obj/item/stack/ore/bluespace_crystal = 1,
	)


/datum/heretic_knowledge/ultimate/beyond_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()

	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/host_pause())
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/reboot_area())
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/pointed/host_qdel())

	user.apply_status_effect(/datum/status_effect/host_identity)
	user.AddElement(/datum/element/effect_trail/beyond_afterimage, /obj/effect/temp_visual/beyond_afterimage)
