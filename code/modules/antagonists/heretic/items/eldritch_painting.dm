/obj/item/wallframe/painting/eldritch
	name = "Чистый холст"
	desc = "Невозможная картина, созданная невозможной краской. Она не должна существовать в этой реальности."
	// master220's painting compat base points at decals.dmi; the eldritch painting sprites live in signs.dmi.
	icon_state = "eldritch_painting_debug"
	result_path = /obj/structure/sign/painting/eldritch


/obj/structure/sign/painting/eldritch
	name = "Чистый холст"
	desc = "Невозможная картина, созданная невозможной краской. Она не должна существовать в этой реальности."
	icon_state = "eldritch_painting_debug"
	//buildable_sign = FALSE
	accepted_canvas_types = list()
	persistence_id = FALSE
	/// The status effect this painting curses onlookers with. null = no passive curse (e.g. the vines).
	var/applied_status_effect = /datum/status_effect/eldritch_painting
	/// The text that shows up when you cross the painting's sightline
	var/text_to_display = "Некоторые вещи не должны быть увиденны."
	/// The range of the painting's effect
	var/range = 7


/obj/structure/sign/painting/eldritch/Initialize(mapload, dir, building)
	. = ..()
	if(ispath(applied_status_effect))
		var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(apply_painting_effect))
		AddComponent(/datum/component/connect_range, tracked = src, connections = connections, range = range, works_in_containers = FALSE)


/obj/structure/sign/painting/eldritch/proc/apply_painting_effect(datum/source, mob/living/carbon/viewer)
	SIGNAL_HANDLER
	// Must be viewer.can_see(src, range), the master220 atom method - a bare can_see(viewer, src, range)
	// would resolve to /atom/proc/can_see and pass the painting as the `length` arg, silently failing LOS.
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

	// Returns silently for the holy-watered: on_apply would refuse the curse anyway, but we shouldn't fire
	// the scream + "mind burns" feedback for a viewer who is actually immune.
	if(viewer.reagents?.has_reagent(/datum/reagent/holywater))
		return

	to_chat(viewer, span_notice(text_to_display))
	viewer.apply_status_effect(applied_status_effect)
	INVOKE_ASYNC(viewer, TYPE_PROC_REF(/mob, emote), "scream")
	to_chat(viewer, span_hypnophrase("Ваш разум пылает! Картина оставляет след в вашей психике."))


/obj/structure/sign/painting/eldritch/wirecutter_act(mob/living/user, obj/item/I)
	if(!user.can_block_magic(MAGIC_RESISTANCE))
		to_chat(user, span_hypnophrase("У вас зудит в голове. Оно смеётся над вами..."))

	qdel(src)
	return ATTACK_CHAIN_SUCCESS

// On examine eldritch paintings give a trait so their effects can not be spammed
/obj/structure/sign/painting/eldritch/examine(mob/user)
	. = ..()
	if(!iscarbon(user))
		return

	// Per-painting cooldown (keyed by this painting's UID), not a global one - a global trait would block the
	// examine effect of EVERY other painting for 3 min after looking at just one of them.
	if(HAS_TRAIT_FROM(user, TRAIT_ELDRITCH_PAINTING_EXAMINE, UID()))
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
	name = "Сестра и Плачущий"
	desc = "Прекрасная картина, изображающая прекрасную даму, сидящую рядом с Ним. Он плачет. Вы ещё увидите Его."
	icon_state = "eldritch_painting_weeping"
	result_path = /obj/structure/sign/painting/eldritch/weeping


/obj/structure/sign/painting/eldritch/weeping
	name = "Сестра и Плачущий"
	desc = "Прекрасная картина, изображающая прекрасную даму, сидящую рядом с Ним. Он плачет. Вы ещё увидите Его. Можно снять кусачками."
	icon_state = "eldritch_painting_weeping"
	applied_status_effect = /datum/status_effect/eldritch_painting/weeping
	text_to_display = "Так прекрасна! Так печально!"


/obj/structure/sign/painting/eldritch/weeping/examine_effects(mob/living/carbon/examiner)
	if(!isheretic(examiner))
		// The actual "respite" is the TRAIT_ELDRITCH_PAINTING_EXAMINE set in the base examine(), which pauses
		// the weeping curse's hallucination ticks for 3 minutes.
		to_chat(examiner, span_hypnophrase("Отдохните. Пока можете..."))
		return

	to_chat(examiner, span_notice("Просто глядя на [declent_ru(ACCUSATIVE)], вы очищаете свой разум."))
	examiner.SetHallucinate(0)


/obj/item/wallframe/painting/eldritch/desire
	name = "Фестиваль Желаний"
	desc = "Картина, изображающая изысканное пиршество. Несмотря на то, что еда давно сгнила, она выглядит очень аппетитно."
	icon_state = "eldritch_painting_desire"
	result_path = /obj/structure/sign/painting/eldritch/desire


/obj/structure/sign/painting/eldritch/desire
	name = "Фестиваль Желаний"
	desc = "Картина, изображающая изысканное пиршество. Несмотря на то, что еда давно сгнила, она выглядит очень аппетитно. Можно снять кусачками."
	icon_state = "eldritch_painting_desire"
	applied_status_effect = /datum/status_effect/eldritch_painting/desire
	text_to_display = "Как же хочется есть..."


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
	name = "Мир Без Всех Вас"
	desc = "Картина, изображающая густые заросли. Эта картина кипит жизнью, а её содержимое словно рвётся наружу."
	icon_state = "eldritch_painting_vines"
	result_path = /obj/structure/sign/painting/eldritch/vines


/obj/structure/sign/painting/eldritch/vines
	name = "Мир Без Всех Вас"
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
	// No passive sightline curse - just spawns kudzu when hung.
	applied_status_effect = null


/obj/structure/sign/painting/eldritch/vines/Initialize(mapload, dir, building)
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
	name = "Леди за Вратами"
	desc = "Картина существа из другого мира. Тонкая кожа цвета фарфора туго натянута на странные кости. Она обладает странной красотой."
	icon_state = "eldritch_painting_beauty"
	result_path = /obj/structure/sign/painting/eldritch/beauty


/obj/structure/sign/painting/eldritch/beauty
	name = "Леди за Вратами"
	desc = "Картина существа из другого мира. Тонкая кожа цвета фарфора туго натянута на странные кости. Она обладает странной красотой. Можно снять кусачками."
	icon_state = "eldritch_painting_beauty"
	applied_status_effect = /datum/status_effect/eldritch_painting/beauty
	text_to_display = "Это маяк чистоты, по сравнению с которым реальный мир кажется таким обыденным и несовершенным..."
	/// List of reagents to add to heretics on examine, set to mutadone by default to remove mutations
	var/list/reagents_to_add = list(/datum/reagent/medicine/mutadone = 5)


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
	name = "Хозяйка Ржавой Горы"
	desc = "Картина, изображающая странное существо, взбирающееся на гору цвета ржавчины. Стиль картины неестественный и пугающий."
	icon_state = "eldritch_painting_rust"
	result_path = /obj/structure/sign/painting/eldritch/rust


/obj/structure/sign/painting/eldritch/rust
	name = "Хозяйка Ржавой Горы"
	desc = "Картина, изображающая странное существо, взбирающееся на гору цвета ржавчины. Стиль картины неестественный и пугающий. Можно снять кусачками."
	icon_state = "eldritch_painting_rust"
	applied_status_effect = /datum/status_effect/eldritch_painting/rusting
	text_to_display = "Ржавчина гниёт. Хозяйка поднимается. Она зовёт. Вы отвечаете..."


/obj/structure/sign/painting/eldritch/rust/examine_effects(mob/living/carbon/examiner)
	. = ..()

	if(!isheretic(examiner))
		to_chat(examiner, span_hypnophrase("Вы чувствуете ржавчину. Гниль."))
		return

	to_chat(examiner, span_notice("Картина наполняет вас решимостью."))
