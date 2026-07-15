
/datum/heretic_knowledge_tree_column/main/ash

	route = PATH_ASH
	ui_bgr = "node_ash"
	complexity = "Лёгкий"
	complexity_color = "#20b142"
	path_description = list(
		"Путь Пепла строится вокруг огня, мобильности и жёсткого контроля одиночных противников.",
		"Берите этот путь, если вы новичок в Еретике или любите тактику \"ударил и убежал\".",
	)
	path_pros = list(
		"Очень силён уже с самого начала пути.",
		"Лёгкий доступ к мобильности и расширенному зрению.",
		"Очень мощный эффект метки.",
	)
	path_cons = list(
		"Слабее большинства еретиков за пределами стартовых способностей.",
		"Не хватает живучести в затяжных конфликтах.",
		"Зависит от того, сумеете ли вы ударить быстро и сильно до того, как враг подготовит контрмеры.",
	)
	path_tips = list(
		"Ваша \"Хватка Обители\" накладывает короткую слепоту и метку, которая при срабатывании от клинка вгоняет жертву в стамина-крит. Метка может перекидываться на ближайших врагов.",
		"Выбор этого пути даёт иммунитет к урону от высокой температуры. Но помните: ваша одежда всё ещё может гореть! Если хотите защититься от собственного огня — носите Опалённую Мантию.",
		"Опалённая Мантия будет поддерживать на вас пламя, защищая от его вредных эффектов. Пользуйтесь этим: врывайтесь в толпы врагов и разносите огонь повсюду.",
		"\"Извержение Вулкана\" быстро расправится с врагами, если те имели глупость сбиться в кучу.",
		"Не пренебрегайте \"Маской Безумия\" — она медленно выкачивает выносливость врагов и вызывает галлюцинации.",
		"Поджигайте как можно больше врагов! \"Возрождение Ночного Дозорного\" лечит вас и снижает откат за каждого поражённого.",
		"Вознесение даёт полный иммунитет к опасностям окружения, включая бомбы! Но обычное оружие всё ещё опасно, не теряйте бдительности.",
	)
	passive_name = "Клятва Разрушения"
	passive_descriptions = list(
		"Иммунитет к жару и пепельным бурям.",
		"Иммунитет к лаве.",
		"Сопротивление высокому и низкому давлению.",
	)
	start = /datum/heretic_knowledge/limited_amount/starting/base_ash
	knowledge_tier1 = /datum/heretic_knowledge/spell/ash_passage
	knowledge_tier2 = /datum/heretic_knowledge/spell/fire_blast
	robes = /datum/heretic_knowledge/armor/ash
	knowledge_tier3 = /datum/heretic_knowledge/nightwatchers_lantern
	blade = /datum/heretic_knowledge/blade_upgrade/ash
	knowledge_tier4 = /datum/heretic_knowledge/spell/flame_birth
	ascension = /datum/heretic_knowledge/ultimate/ash_final
	guaranteed_side_tier1 = /datum/heretic_knowledge/medallion
	guaranteed_side_tier2 = /datum/heretic_knowledge/rifle
	guaranteed_side_tier3 = /datum/heretic_knowledge/limited_amount/summon/ashy


/datum/heretic_knowledge/limited_amount/starting/base_ash
	name = "Секрет Ночного Дозорного"
	desc = "Открывает вам Путь Пепла. \
			Позволяет превратить спичку и нож в Пепельный Клинок. \
			Вы можете создать только два клинка одновременно."
	gain_text = "Городская стража стоит на своем посту. Если вы подойдете к ним ночью, возможно, узнаете историю о потухшем фонаре."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/match = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "ash_blade"
	mark_type = /datum/status_effect/eldritch/ash
	passive_type = /datum/status_effect/heretic_passive/ash


/// Mansus Grasp also burns the victim's eyes, blurring their vision (was the "Хватка Пепла" node).
/datum/heretic_knowledge/limited_amount/starting/base_ash/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()
	if(target.is_blind())
		return

	if(!target.get_organ_slot(INTERNAL_ORGAN_EYES))
		return

	to_chat(target, span_danger("Яркий зеленый свет ужасно жжёт ваши глаза!"))
	target.adjustOrganLoss(INTERNAL_ORGAN_EYES, 15)
	target.EyeBlurry(20 SECONDS)
	addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, adjustOrganLoss), INTERNAL_ORGAN_EYES, -15), 20 SECONDS)


/// Triggering the Ash mark also refunds 75% of the Mansus Grasp cooldown (was the "Метка Пепла" node).
/datum/heretic_knowledge/limited_amount/starting/base_ash/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return

	var/obj/effect/proc_holder/spell/touch/mansus_grasp/grasp = locate() in source.mind.spell_list
	if(!grasp)
		return

	grasp.cooldown_handler.recharge_time -= round(grasp.base_cooldown * 0.75)
	grasp.action?.UpdateButtonIcon()


/datum/heretic_knowledge/spell/ash_passage
	name = "Врата Пепла"
	desc = "Дает вам \"Врата Пепла\", заклинание, позволяющее вам выходить из реальности и перемещаться на небольшие расстояния, проходя сквозь любые стены."
	gain_text = "Он умел ходить между мирами."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "ash_shift"
	spell_to_add = /obj/effect/proc_holder/spell/ethereal_jaunt/ash
	cost = 2
	drafting_tier = 5


/datum/heretic_knowledge/spell/fire_blast
	name = "Извержение Вулкана"
	desc = "Дарует вам \"Извержение Вулкана\", заклинание, после короткой подготовки выпускающее луч энергии \
			в ближайшего врага, поджигая его. Если противник не погаснет сам, \
			луч продолжит движение к другой цели."
	gain_text = "Никакой огонь не был достаточно жарким, чтобы разжечь фонарь вновь. Никакой огонь не был достаточно ярким, чтобы спасти их. Никакой огонь не вечен."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "flames"
	spell_to_add = /obj/effect/proc_holder/spell/charged/beam/fire_blast
	cost = 2
	research_tree_icon_frame = 7


/datum/heretic_knowledge/armor/ash
	name = "Опалённая Мантия"
	desc = "Позволяет создать Опалённую Мантию.<br>\
			Она обеспечивает полную защиту от огня и способна пассивно создавать пламя. \
			Действует в качестве источника фокуса, пока надет капюшон."
	transmute_text = "Преобразуйте стол (или верхнюю одежду), маску и спичку."
	gain_text = "Дозор остаётся там, где пал, рассыпаясь в прах. И всё же ветра, веющие сквозь город, \
				зовут их обратно на службу, поднимая пыль в воздух — дрейфующий силуэт павших."
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/match = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash)
	research_tree_icon_state = "ash_armor"
	research_tree_icon_frame = 1


/datum/heretic_knowledge/nightwatchers_lantern
	name = "Фонарь Ночного Дозорного"
	desc = "Позволяет создать пылающий фонарь.<br>\
			Пылающий фонарь — источник яркого света, который повреждает глаза и со временем \
			дезориентирует тех, кто слишком долго на него смотрит. Эффект слабее для тех, \
			кто носит защиту глаз, и сильнее, если пылающий фонарь — единственный источник света поблизости."
	transmute_text = "Преобразуйте лампу, фонарь или фонарик охраны, пару глаз, вспышку и четыре зажжённые свечи."
	gain_text = "Ночной Дозорный не выходил во тьму. Это было бы глупостью — даже Дозор понимал это. \
				Его фонарь горел светом, способным сжечь само солнце."
	result_atoms = list(/obj/item/flashlight/lantern/heretic)
	required_atoms = list(
		list(/obj/item/flashlight/lamp, /obj/item/flashlight/lantern, /obj/item/flashlight/seclite) = 1,
		/obj/item/organ/internal/eyes = 1,
		/obj/item/flash = 1,
		/obj/item/candle = 4,
	)
	research_tree_icon_path = 'icons/obj/lighting.dmi'
	research_tree_icon_state = "lantern"


/datum/heretic_knowledge/nightwatchers_lantern/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/candle/candle in atoms)
		if(!candle.lit)
			atoms -= candle


/datum/heretic_knowledge/blade_upgrade/ash
	name = "Огненный Клинок"
	desc = "Теперь ваш клинок поджигает врагов при атаке."
	gain_text = "Он вернулся с клинком в руке, он размахивал им, пока пепел падал с небес. \
				Его город, люди, за которыми он поклялся следить... и он следил, пока они все не сгорели дотла."

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_ash"


/datum/heretic_knowledge/blade_upgrade/ash/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.adjust_fire_stacks(1)
	target.IgniteMob()


/datum/heretic_knowledge/spell/flame_birth
	name = "Возрождение Ночного Дозорного"
	desc = "Дарует вам \"Возрождение Ночного Дозорного\", заклинание, которое тушит вас и \
			ранит всех находящихся поблизости горящих язычников, исцеляя вас за каждую пораженную жертву. \
			Если жертвы находятся в критическом состоянии, они также мгновенно умирают."
	gain_text = "Огонь был неизбежен, и всё же жизнь теплилась в его обугленном теле. \
				Ночной Дозорный был особенным человеком, всегда наблюдавшим."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "smoke"
	spell_to_add = /obj/effect/proc_holder/spell/aoe/fiery_rebirth
	cost = 2
	research_tree_icon_frame = 5
	is_final_knowledge = TRUE


/datum/heretic_knowledge/ultimate/ash_final
	name = "Обряд Повелителя Пепла"
	desc = "Ритуал вознесения Пути Пепла. \
			Положите 3 горящих трупа на руну трансмутации, чтобы завершить ритуал. \
			После завершения ритуала вы становитесь предвестником пламени и получаете две способности. \
			Каскад, создающий вокруг вас огромное растущее огненное кольцо, \
			и Клятва Пламени, позволяющая вам пассивно создавать огненное кольцо при ходьбе. \
			Вы также приобретете иммунитет к огню и давлению."
	gain_text = "Дозор уничтожен, Ночной Дозорный сгорел вместе с ним. Но его огонь горит вечно, \
				ибо Ночной Дозорный принёс себя в жертву человечеству! Его взгляд продолжает смотреть, \
				ибо теперь он един с пламенем, СТАНЬТЕ СВИДЕТЕЛЕМ МОЕГО ВОЗНЕСЕНИЯ, ПЕПЕЛЬНЫЙ ФОНАРЬ СНОВА ЗАГОРИТСЯ!"

	announcement_text = "%SPOOKY% Реальность потрескивает, как тлеющие в костре угли! Бойтесь пламени, ибо Повелитель Пепла, %NAME% вознесся! Пламя поглотит ВСЁ! %SPOOKY%"
	announcement_sound = 'sound/music/heretic/ascend_ash.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "ashascend"
	/// A static list of all traits we apply on ascension.
	var/static/list/traits_to_apply = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_NO_BREATH,
		TRAIT_NO_FIRE,
		TRAIT_RESIST_COLD,
		TRAIT_RESIST_HEAT,
	)


/datum/heretic_knowledge/ultimate/ash_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return

	if(sacrifice.on_fire)
		return TRUE

	if(HAS_TRAIT_FROM(sacrifice, TRAIT_HUSK, BURN))
		return TRUE

	return FALSE


/datum/heretic_knowledge/ultimate/ash_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/fire_sworn())
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/fire_cascade/big())
	var/obj/effect/proc_holder/spell/charged/beam/fire_blast/existing_beam_spell = locate() in user.mind.spell_list
	if(existing_beam_spell)
		existing_beam_spell.max_beam_bounces *= 2 // Double beams
		existing_beam_spell.beam_duration *= 0.66 // Faster beams
		existing_beam_spell.base_cooldown *= 0.66 // Lower cooldown
		existing_beam_spell.cooldown_handler?.recharge_duration = existing_beam_spell.base_cooldown

	var/obj/effect/proc_holder/spell/aoe/fiery_rebirth/fiery_rebirth = locate() in user.mind.spell_list
	if(fiery_rebirth)
		fiery_rebirth.base_cooldown *= 0.16
		fiery_rebirth.cooldown_handler?.recharge_duration = fiery_rebirth.base_cooldown

	user.add_traits(traits_to_apply, type)
