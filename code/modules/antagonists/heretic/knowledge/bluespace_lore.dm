
/datum/heretic_knowledge_tree_column/main/bluespace

	route = PATH_BLUESPACE
	ui_bgr = "node_bluespace"
	complexity = "Сложный"
	complexity_color = "#c93b3b"
	path_description = list(
		"Путь Блюспейса строится вокруг перестановки противников, срыва их действий и накопления Разломов.",
		"Берите этот путь, если готовы выигрывать бой заранее, а не в момент удара.",
	)
	path_pros = list(
		"Меняйте местами кого угодно и что угодно в поле зрения.",
		"Обрывайте выстрелы, удары и заклинания до того, как они случатся.",
		"Запирайте узкие коридоры полями искажения.",
		"Два Разлома схлопывают цель: паралич, немота и сорванное действие.",
	)
	path_cons = list(
		"Низкий прямой урон, пока вы не изучите Смещающий Клинок.",
		"Чтобы уронить цель, нужно последовательно сложить несколько эффектов.",
		"Почти всё, что вы делаете, останавливается магической защитой.",
		"Бесплатного прохода сквозь стены путь не даёт.",
	)
	path_tips = list(
		"\"Хватка Обители\" выделяет цель на 15 секунд: вы видите её сквозь стены и знаете, \
		сколько у неё здоровья. Удар любым вашим клинком по выделенной цели активирует метку.",
		"Активированная метка вешает Привязку: четыре секунды жертва не может отойти дальше \
		одной плитки от места, где стояла. Стрелять и бить она при этом может.",
		"Враждебная телепортация рвёт Привязку, но оставляет ещё один Разлом — телепортом можно доломать цель.",
		"\"Смещение\" съедает следующее осознанное действие. Умная жертва потратит его на что-то безобидное, \
		так что накладывайте эффект тогда, когда ей нельзя терять ход.",
		"Первое попадание каждой жертвы в конкретное поле искажения даёт Разлом. Загоняйте людей \
		в поле \"Пространственной Рокировкой\" — это ещё один Разлом сверху.",
		"Двойники из \"Блюспейс-Двойников\" — законные цели \"Пространственной Рокировки\". \
		Меняйтесь с двойником местами, чтобы мгновенно уйти из окружения.",
		"\"Расплетение Формы\" даёт добить цель беспамятством, но только если на ней уже висит Разлом.",
	)
	passive_name = "Расфазированное Тело"
	passive_descriptions = list(
		"Вас невозможно уронить скользкой поверхностью: вода, лёд, мыло, кровь и кожура вас не касаются.",
		"Ползание больше не замедляет вас — лёжа вы двигаетесь со скоростью шага.",
		"Полный иммунитет к оглушению, параличу, обездвиживанию и сбиванию с ног.",
	)
	start = /datum/heretic_knowledge/limited_amount/starting/base_bluespace
	knowledge_tier1 = /datum/heretic_knowledge/spell/spatial_swap
	knowledge_tier2 = /datum/heretic_knowledge/spell/displacement
	robes = /datum/heretic_knowledge/armor/bluespace
	knowledge_tier3 = /datum/heretic_knowledge/spell/distortion_field
	blade = /datum/heretic_knowledge/blade_upgrade/bluespace
	knowledge_tier4 = /datum/heretic_knowledge/spell/unravel
	ascension = /datum/heretic_knowledge/ultimate/bluespace_final
	guaranteed_side_tier1 = /datum/heretic_knowledge/eldritch_coin
	guaranteed_side_tier2 = /datum/heretic_knowledge/spell/opening_blast
	guaranteed_side_tier3 = /datum/heretic_knowledge/essence


/datum/heretic_knowledge/limited_amount/starting/base_bluespace
	name = "Трещина в Пространстве"
	desc = "Открывает вам Путь Блюспейса. \
			Позволяет преобразовать нож и маяк в блюспейс-клинок. \
			Вы можете создать только два клинка одновременно. \
			Ваша \"Хватка Обители\" начинает выделять цели."
	gain_text = "Обитель показала мне изнанку пространства — место, где расстояний не существует, \
				а всякая вещь помнит все точки, в которых когда-либо была. Оттуда меня и заметили."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/beacon = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/bluespace)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "bluespace_blade"
	mark_type = /datum/status_effect/eldritch/bluespace
	passive_type = /datum/status_effect/heretic_passive/bluespace


/datum/heretic_knowledge/limited_amount/starting/base_bluespace/create_mark(mob/living/source, mob/living/target)
	if(target.stat == DEAD)
		return
	return target.apply_status_effect(mark_type, source)


/datum/heretic_knowledge/limited_amount/starting/base_bluespace/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()
	give_spatial_instability(target, source)


/datum/heretic_knowledge/spell/spatial_swap
	name = "Пространственная Рокировка"
	desc = "Даёт вам \"Пространственную Рокировку\", заклинание, меняющее местами два объекта или существа. \
			Обе цели должны быть в пределах девяти плиток от вас и девяти плиток друг от друга. \
			Каждая перемещённая жертва получает Разлом."
	gain_text = "Изнанка не двигала фигуры. Она лишь напоминала им, в каких точках они \
				всегда должны были находиться."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "spatial_swap"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/spatial_swap
	cost = 2


/datum/heretic_knowledge/spell/displacement
	name = "Смещение"
	desc = "Даёт вам \"Смещение\", заклинание, вырывающее цель из пространства на восемь секунд. \
			Следующее её осознанное действие уйдёт в изнанку и оставит Разлом. \
			Движение, речь и смена руки не блокируются."
	gain_text = "Его рука пришла в движение, но удар случился где-то в стороне от мира."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "displacement"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/displacement
	cost = 2


/datum/heretic_knowledge/armor/bluespace
	name = "Мантия Разлома"
	desc = "Позволяет преобразовать стол (или верхнюю одежду), маску и маяк \
			в Мантию Разлома. Она хорошо защищает, ничем вас не замедляет и даёт способность \
			\"Блюспейс-Двойники\". Действует как источник фокуса, пока надет капюшон. \
			Тот, кто наденет её не будучи еретиком, начнёт сыпать собственными смещёнными отражениями."
	gain_text = "Моё тело не успевало за движением. Позади шли те, кем я был мгновение назад, \
				всё ещё уверенные, что именно они настоящие."
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/beacon = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/bluespace)
	research_tree_icon_state = "bluespace_armor"
	research_tree_icon_frame = 1


/datum/heretic_knowledge/spell/distortion_field
	name = "Поле Искажения"
	desc = "Даёт вам \"Поле Искажения\", заклинание, растягивающее область 5x5 на восемь секунд. \
			Внутри неё чужаки двигаются и действуют медленнее и периодически застревают, а снаряды вязнут. \
			Первое попадание каждой жертвы в конкретное поле оставляет Разлом."
	gain_text = "Мир не остановился. Он просто стал длиннее, чем был, \
				и каждый шаг внутри занимал больше пути, чем снаружи."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "distortion_field"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/distortion_field
	cost = 2


/datum/heretic_knowledge/blade_upgrade/bluespace
	name = "Смещающий Клинок"
	desc = "Ваш клинок начинает рвать связь вещей с их местом. Успешный удар по живой цели оставляет \
			Разлом, но не чаще раза в две с половиной секунды на одну и ту же жертву. \
			Схлопывание, вызванное вашим ударом, дополнительно наносит 10 урона, выбивает предмет из руки \
			и не даёт поднять его три секунды. \
			Кроме того, клинок в руке позволяет сместить предмет в чужих руках."
	gain_text = "Лезвие не рассекало плоть. Оно рассекало нить между вещью и точкой, \
				в которой мир держал её всё это время."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_bluespace"
	var/tear_cooldown = 2.5 SECONDS


/datum/heretic_knowledge/blade_upgrade/bluespace/on_gain(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	. = ..()
	for(var/obj/item/melee/sickly_blade/bluespace/blade in user.get_all_contents_type(/obj/item/melee/sickly_blade/bluespace))
		blade.update_appearance(UPDATE_ICON)
	user.update_held_items()


/datum/heretic_knowledge/blade_upgrade/bluespace/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	if(!TIMER_COOLDOWN_FINISHED(target, COOLDOWN_BLUESPACE_BLADE_TEAR))
		return

	TIMER_COOLDOWN_START(target, COOLDOWN_BLUESPACE_BLADE_TEAR, tear_cooldown)
	give_spatial_instability(target, source)


/datum/heretic_knowledge/spell/unravel
	name = "Расплетение Формы"
	desc = "Даёт вам \"Расплетение Формы\", заклинание, позволяющее временно расплести одно свойство цели: \
			приковать её к точке, вывести из фазы с миром или преломить вокруг неё свет. \
			Если на цели уже висит Разлом, вместо этого можно уронить её в беспамятство."
	gain_text = "Я увидел не человека, а горсть нитей, которыми он привязан к миру. \
				Одну из них можно было развязать."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "unravel"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/unravel
	cost = 2
	is_final_knowledge = TRUE


/datum/heretic_knowledge/ultimate/bluespace_final
	name = "Хозяин Разлома"
	desc = "Ритуал вознесения Пути Блюспейса. \
			Поднесите 3 трупа и блюспейс-кристалл к руне трансмутации, чтобы завершить ритуал. \
			После вознесения вы получаете полный иммунитет к станам и три новые способности: \
			Стазис, замораживающий всё вокруг; Откат Пространства, возвращающий область на пять секунд назад; \
			и Изгнание в Блюспейс, стирающее добитое существо из мира. \
			Мир перестаёт помнить, как вас зовут, а позади вас тянутся ваши отголоски."
	gain_text = "Обитель никогда не была миром. Она была изнанкой, на которой держатся все расстояния. \
				Теперь эта изнанка носит моё имя."

	announcement_text = "%SPOOKY% Пространство станции разорвано. Сущность %NAME% \
						больше не привязана ни к одной точке этого мира. %SPOOKY%"
	announcement_sound = 'sound/magic/lightning_chargeup.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "bluespaceascend"
	required_atoms = list(
		/mob/living/carbon/human = 3,
		/obj/item/stack/ore/bluespace_crystal = 1,
	)


/datum/heretic_knowledge/ultimate/bluespace_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()

	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/bluespace_stasis())
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/spatial_rewind())
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/pointed/bluespace_banish())

	user.apply_status_effect(/datum/status_effect/unmoored_name)
	user.AddElement(/datum/element/effect_trail/bluespace_echo, /obj/effect/temp_visual/bluespace_echo)
