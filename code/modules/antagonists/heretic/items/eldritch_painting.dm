/obj/item/wallframe/painting/eldritch
	abstract_type = /obj/item/wallframe/painting/eldritch
	name = "The Blank Canvas: A Study in Default Subtypes"
	desc = "Невозможная картина, созданная невозможной краской. Она не должна существовать в этой реальности."
	icon_state = "eldritch_painting_debug"
	result_path = /obj/structure/sign/painting/eldritch


/obj/structure/sign/painting/eldritch
	abstract_type = /obj/structure/sign/painting/eldritch
	name = "The Blank Canvas: A Study in Default Subtypes"
	desc = "Невозможная картина, созданная невозможной краской. Она не должна существовать в этой реальности."
	icon_state = "eldritch_painting_debug"
	accepted_canvas_types = list()
	buildable_sign = FALSE
	/// The status effect this painting curses onlookers with. null = no passive curse (e.g. the vines).
	var/applied_status_effect = /datum/status_effect/eldritch_painting
	/// The text that shows up when you cross the painting's sightline
	var/text_to_display = "Некоторые вещи не должны быть увиденны."
	/// The range of the painting's effect
	var/range = 7


/obj/structure/sign/painting/eldritch/Initialize(mapload)
	. = ..()
	if(ispath(applied_status_effect))
		var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(apply_painting_effect))
		AddComponent(/datum/component/connect_range, tracked = src, connections = connections, range = range, works_in_containers = FALSE)


/obj/structure/sign/painting/eldritch/proc/apply_painting_effect(datum/source, mob/living/carbon/viewer)
	SIGNAL_HANDLER
	if(!isliving(viewer) || !viewer.can_see(src, range))
		return

	if(isnull(viewer.mind) || viewer.stat != CONSCIOUS || viewer.is_blind())
		return

	if(viewer.has_status_effect(applied_status_effect))
		return

	if(isheretic(viewer))
		return

	if(viewer.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
		return

	if(viewer.reagents?.has_reagent(/datum/reagent/holywater))
		return

	to_chat(viewer, span_notice(text_to_display))
	viewer.apply_status_effect(applied_status_effect)
	INVOKE_ASYNC(viewer, TYPE_PROC_REF(/mob, emote), "scream")
	to_chat(viewer, span_hypnophrase("Ваш разум пылает! Картина оставляет выжженный след в вашем разуме."))


/obj/structure/sign/painting/eldritch/wirecutter_act(mob/living/user, obj/item/I)
	if(!user.can_block_magic(MAGIC_RESISTANCE))
		to_chat(user, span_hypnophrase("Вы чувствуете зуд в голове. Оно смеётся над вами..."))

	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/sign/painting/eldritch/examine(mob/user)
	. = ..()
	if(!iscarbon(user))
		return

	if(HAS_TRAIT(user, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return

	ADD_TRAIT(user, TRAIT_ELDRITCH_PAINTING_EXAMINE, UID())
	addtimer(TRAIT_CALLBACK_REMOVE(user, TRAIT_ELDRITCH_PAINTING_EXAMINE, UID()), 3 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(examine_effects), user), 0.2 SECONDS)


/obj/structure/sign/painting/eldritch/proc/examine_effects(mob/living/carbon/examiner)
	if(isheretic(examiner))
		to_chat(examiner, span_notice("Какая захватывающая картина!"))
		return

	to_chat(examiner, span_notice("Какая странная картина..."))


/obj/item/wallframe/painting/eldritch/weeping
	name = "\improper The Sister and He Who Wept"
	desc = "Прекрасная картина, изображающая прекрасную даму, сидящую рядом с Ним. Он плачет. Вы ещё увидите Его."
	icon_state = "eldritch_painting_weeping"
	result_path = /obj/structure/sign/painting/eldritch/weeping

/obj/item/wallframe/painting/eldritch/weeping/get_ru_names()
	return alist(
		NOMINATIVE = "\"Сестра и Плачущий\"",
		GENITIVE = "\"Сестра и Плачущий\"",
		DATIVE = "\"Сестра и Плачущий\"",
		ACCUSATIVE = "\"Сестра и Плачущий\"",
		INSTRUMENTAL = "\"Сестра и Плачущий\"",
		PREPOSITIONAL = "\"Сестра и Плачущий\"",
	)

/obj/structure/sign/painting/eldritch/weeping
	name = "\improper The Sister and He Who Wept"
	desc = "Прекрасная картина, изображающая прекрасную даму, сидящую рядом с Ним. Он плачет. Вы ещё увидите Его. Можно снять кусачками."
	icon_state = "eldritch_painting_weeping"
	applied_status_effect = /datum/status_effect/eldritch_painting/weeping
	text_to_display = "Так прекрасна! Так печально!"

/obj/structure/sign/painting/eldritch/weeping/get_ru_names()
	return alist(
		NOMINATIVE = "\"Сестра и Плачущий\"",
		GENITIVE = "\"Сестра и Плачущий\"",
		DATIVE = "\"Сестра и Плачущий\"",
		ACCUSATIVE = "\"Сестра и Плачущий\"",
		INSTRUMENTAL = "\"Сестра и Плачущий\"",
		PREPOSITIONAL = "\"Сестра и Плачущий\"",
	)

/obj/structure/sign/painting/eldritch/weeping/examine_effects(mob/living/carbon/examiner)
	if(!isheretic(examiner))
		to_chat(examiner, span_hypnophrase("Отдохните. Пока можете..."))
		return

	to_chat(examiner, span_notice("Просто глядя на [declent_ru(ACCUSATIVE)], вы очищаете свой разум."))
	examiner.SetHallucinate(0)


/obj/item/wallframe/painting/eldritch/desire
	name = "\improper The Feast of Desire"
	desc = "Картина, изображающая изысканное пиршество. Несмотря на то, что еда давно сгнила, она выглядит очень аппетитно."
	icon_state = "eldritch_painting_desire"
	result_path = /obj/structure/sign/painting/eldritch/desire

/obj/item/wallframe/painting/eldritch/desire/get_ru_names()
	return alist(
		NOMINATIVE = "\"Фестиваль Желаний\"",
		GENITIVE = "\"Фестиваль Желаний\"",
		DATIVE = "\"Фестиваль Желаний\"",
		ACCUSATIVE = "\"Фестиваль Желаний\"",
		INSTRUMENTAL = "\"Фестиваль Желаний\"",
		PREPOSITIONAL = "\"Фестиваль Желаний\"",
	)

/obj/structure/sign/painting/eldritch/desire
	name = "\improper The Feast of Desire"
	desc = "Картина, изображающая изысканное пиршество. Несмотря на то, что еда давно сгнила, она выглядит очень аппетитно. Можно снять кусачками."
	icon_state = "eldritch_painting_desire"
	applied_status_effect = /datum/status_effect/eldritch_painting/desire
	text_to_display = "Как же хочется есть..."

/obj/structure/sign/painting/eldritch/desire/get_ru_names()
	return alist(
		NOMINATIVE = "\"Фестиваль Желаний\"",
		GENITIVE = "\"Фестиваль Желаний\"",
		DATIVE = "\"Фестиваль Желаний\"",
		ACCUSATIVE = "\"Фестиваль Желаний\"",
		INSTRUMENTAL = "\"Фестиваль Желаний\"",
		PREPOSITIONAL = "\"Фестиваль Желаний\"",
	)

/obj/structure/sign/painting/eldritch/desire/examine_effects(mob/living/carbon/examiner)
	if(!isheretic(examiner))
		examiner.adjust_nutrition(50)
		to_chat(examiner, span_warning("Вы чувствуете жгучую боль в животе!"))
		examiner.adjustOrganLoss(INTERNAL_ORGAN_STOMACH, 5)
		to_chat(examiner, span_notice("Вы чувствуете что ваш голод отступил."))
		to_chat(examiner, span_warning("Вам следует запастись сырым мясом и органами, прежде чем вы снова проголодаетесь."))
		return

	var/static/list/random_bodypart_or_organ = list(
		/obj/item/organ/internal/brain,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/ears,
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/liver,
		///obj/item/organ/internal/stomach,
		/obj/item/organ/internal/appendix,
		/obj/item/organ/external/arm,
		/obj/item/organ/external/arm/right,
		/obj/item/organ/external/leg,
		/obj/item/organ/external/leg/right
	)
	var/organ_or_bodypart_to_spawn = pick(random_bodypart_or_organ)
	new organ_or_bodypart_to_spawn(drop_location())
	to_chat(examiner, span_notice("Кусок плоти выползает из картины и падает на пол."))
	to_chat(examiner, span_warning("Пустота кричит!"))


/obj/item/wallframe/painting/eldritch/vines
	name = "\improper Great Chaparral Over Rolling Hills"
	desc = "Картина, изображающая густые заросли. Эта картина кипит жизнью, а её содержимое словно рвётся наружу."
	icon_state = "eldritch_painting_vines"
	result_path = /obj/structure/sign/painting/eldritch/vines

/obj/item/wallframe/painting/eldritch/vines/get_ru_names()
	return alist(
		NOMINATIVE = "\"Мир без Всех Вас\"",
		GENITIVE = "\"Мир без Всех Вас\"",
		DATIVE = "\"Мир без Всех Вас\"",
		ACCUSATIVE = "\"Мир без Всех Вас\"",
		INSTRUMENTAL = "\"Мир без Всех Вас\"",
		PREPOSITIONAL = "\"Мир без Всех Вас\"",
	)

/obj/structure/sign/painting/eldritch/vines
	name = "\improper Great Chaparral Over Rolling Hills"
	desc = "Картина, изображающая густые заросли. Эта картина кипит жизнью, а её содержимое словно рвётся наружу. \
			Можно снять кусачками."
	icon_state = "eldritch_painting_vines"
	var/list/mutations = list(
		/datum/spacevine_mutation/aggressive_spread,
		/datum/spacevine_mutation/fire_proof,
		/datum/spacevine_mutation/woodening,
		/datum/spacevine_mutation/thorns,
		/datum/spacevine_mutation/toxicity,
	)
	var/list/items_to_spawn = list(
		/obj/item/reagent_containers/food/snacks/grown/poppy,
		/obj/item/reagent_containers/food/snacks/grown/harebell,
	)
	applied_status_effect = null

/obj/structure/sign/painting/eldritch/vines/get_ru_names()
	return alist(
		NOMINATIVE = "\"Мир без Всех Вас\"",
		GENITIVE = "\"Мир без Всех Вас\"",
		DATIVE = "\"Мир без Всех Вас\"",
		ACCUSATIVE = "\"Мир без Всех Вас\"",
		INSTRUMENTAL = "\"Мир без Всех Вас\"",
		PREPOSITIONAL = "\"Мир без Всех Вас\"",
	)

/obj/structure/sign/painting/eldritch/vines/Initialize(mapload)
	. = ..()
	new /obj/structure/spacevine_controller/event(get_turf(src), mutations, 0, 10)


/obj/structure/sign/painting/eldritch/vines/examine_effects(mob/living/carbon/examiner)
	. = ..()
	if(!isheretic(examiner))
		new /obj/structure/spacevine_controller/event(get_turf(examiner), mutations, 0, 10)
		to_chat(examiner, span_hypnophrase("Вас завораживает изображение виноградной лозы на картине."))
		to_chat(examiner, span_notice("Вы чувствуете, как что-то извивается вокруг вас."))
		return

	var/item_to_spawn = pick(items_to_spawn)
	to_chat(examiner, span_notice("На мгновение вас завораживает хаотичный узор, который создает лоза."))
	to_chat(examiner, span_notice("Вы чувствуете, как жизнь расцветает вокруг."))
	new item_to_spawn(examiner.drop_location())


/obj/item/wallframe/painting/eldritch/beauty
	name = "\improper Lady of the Gate"
	desc = "Картина существа из другого мира. Тонкая кожа цвета фарфора туго натянута на странные кости. Она причудливо красива."
	icon_state = "eldritch_painting_beauty"
	result_path = /obj/structure/sign/painting/eldritch/beauty

/obj/item/wallframe/painting/eldritch/beauty/get_ru_names()
	return alist(
		NOMINATIVE = "\"Владычица Врат\"",
		GENITIVE = "\"Владычица Врат\"",
		DATIVE = "\"Владычица Врат\"",
		ACCUSATIVE = "\"Владычица Врат\"",
		INSTRUMENTAL = "\"Владычица Врат\"",
		PREPOSITIONAL = "\"Владычица Врат\"",
	)

/obj/structure/sign/painting/eldritch/beauty
	name = "\improper Lady of the Gate"
	desc = "Картина существа из другого мира. Тонкая кожа цвета фарфора туго натянута на странные кости. Она причудливо красива. Можно снять кусачками."
	icon_state = "eldritch_painting_beauty"
	applied_status_effect = /datum/status_effect/eldritch_painting/beauty
	text_to_display = "Это маяк чистоты, по сравнению с которым реальный мир кажется таким обыденным и несовершенным..."
	/// List of reagents to add to heretics on examine, set to mutadone by default to remove mutations
	var/list/reagents_to_add = list(/datum/reagent/medicine/mutadone = 5)

/obj/structure/sign/painting/eldritch/beauty/get_ru_names()
	return alist(
		NOMINATIVE = "\"Владычица Врат\"",
		GENITIVE = "\"Владычица Врат\"",
		DATIVE = "\"Владычица Врат\"",
		ACCUSATIVE = "\"Владычица Врат\"",
		INSTRUMENTAL = "\"Владычица Врат\"",
		PREPOSITIONAL = "\"Владычица Врат\"",
	)

/obj/structure/sign/painting/eldritch/beauty/examine_effects(mob/living/carbon/examiner)
	. = ..()
	if(!examiner.dna)
		return

	if(!isheretic(examiner))
		to_chat(examiner, span_hypnophrase("Вы не чисты."))
		randmutb(examiner)
		return

	to_chat(examiner, span_notice("Ваши недостатки исчезнут."))
	examiner.reagents.add_reagent_list(reagents_to_add)


/obj/item/wallframe/painting/eldritch/rust
	name = "\improper Master of the Rusted Mountain"
	desc = "Картина, изображающая странное существо, взбирающееся на гору цвета ржавчины. Стиль картины неестественный и пугающий."
	icon_state = "eldritch_painting_rust"
	result_path = /obj/structure/sign/painting/eldritch/rust

/obj/item/wallframe/painting/eldritch/rust/get_ru_names()
	return alist(
		NOMINATIVE = "\"Хозяйка Ржавой Горы\"",
		GENITIVE = "\"Хозяйка Ржавой Горы\"",
		DATIVE = "\"Хозяйка Ржавой Горы\"",
		ACCUSATIVE = "\"Хозяйка Ржавой Горы\"",
		INSTRUMENTAL = "\"Хозяйка Ржавой Горы\"",
		PREPOSITIONAL = "\"Хозяйка Ржавой Горы\"",
	)

/obj/structure/sign/painting/eldritch/rust
	name = "\improper Master of the Rusted Mountain"
	desc = "Картина, изображающая странное существо, взбирающееся на гору цвета ржавчины. Стиль картины неестественный и пугающий. Можно снять кусачками."
	icon_state = "eldritch_painting_rust"
	applied_status_effect = /datum/status_effect/eldritch_painting/rusting
	text_to_display = "Ржавчина гниёт. Хозяйка поднимается. Она зовёт. Вы отвечаете..."

/obj/structure/sign/painting/eldritch/rust/get_ru_names()
	return alist(
		NOMINATIVE = "\"Хозяйка Ржавой Горы\"",
		GENITIVE = "\"Хозяйка Ржавой Горы\"",
		DATIVE = "\"Хозяйка Ржавой Горы\"",
		ACCUSATIVE = "\"Хозяйка Ржавой Горы\"",
		INSTRUMENTAL = "\"Хозяйка Ржавой Горы\"",
		PREPOSITIONAL = "\"Хозяйка Ржавой Горы\"",
	)

/obj/structure/sign/painting/eldritch/rust/examine_effects(mob/living/carbon/examiner)
	. = ..()

	if(!isheretic(examiner))
		to_chat(examiner, span_hypnophrase("Вы чувствуете ржавчину. Гниль."))
		return

	to_chat(examiner, span_notice("Картина наполняет вас решимостью."))
