// The basic eldritch painting
/obj/item/wallframe/painting/eldritch
	name = "Чистый холст"
	desc = "Невозможная картина, созданная невозможной краской. Она не должна существовать в этой реальности."
	resistance_flags = FLAMMABLE
	icon_state = "eldritch_painting_debug"
	result_path = /obj/structure/sign/painting/eldritch


/obj/structure/sign/painting/eldritch
	name = "Чистый холст"
	desc = "Невозможная картина, созданная невозможной краской. Она не должна существовать в этой реальности."
	icon_state = "eldritch_painting_debug"
	//buildable_sign = FALSE
	// The list of canvas types accepted by this frame, set to zero here
	accepted_canvas_types = list()
	// Set to false since we don't want this to persist
	persistence_id = FALSE
	/// The text that shows up when you cross the paintings path
	var/text_to_display = "Некоторые вещи не должны быть увиденны."
	/// The range of the paintings effect
	var/range = 7


/obj/structure/sign/painting/eldritch/Initialize(mapload, dir, building)
	. = ..()
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(apply_trauma))
	AddComponent(/datum/component/connect_range, tracked = src, connections = connections, range = range, works_in_containers = FALSE)


/obj/structure/sign/painting/eldritch/proc/apply_choosen_trauma(mob/living/carbon/human/viewer)
	ADD_TRAIT(viewer, TRAIT_PACIFISM, HERETIC_TRAIT)


/obj/structure/sign/painting/eldritch/proc/apply_trauma(datum/source, mob/living/carbon/viewer)
	SIGNAL_HANDLER
	if(!isliving(viewer) || !can_see(viewer, src, range))
		return

	if(isnull(viewer.mind) || viewer.stat != CONSCIOUS || viewer.is_blind())
		return

	if(isheretic(viewer))
		return

	if(viewer.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
		return

	to_chat(viewer, span_notice(text_to_display))
	apply_choosen_trauma(viewer)
	INVOKE_ASYNC(viewer, TYPE_PROC_REF(/mob, emote), "scream")
	to_chat(viewer, span_purple("Ваш разум пылает! Картина оставляет след в вашей психике."))


/obj/structure/sign/painting/eldritch/wirecutter_act(mob/living/user, obj/item/I)
	if(!user.can_block_magic(MAGIC_RESISTANCE))
		to_chat(user, span_purple("У вас зудит в голове. Оно смеётся над вами..."))

	qdel(src)
	return ATTACK_CHAIN_SUCCESS

// On examine eldritch paintings give a trait so their effects can not be spammed
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


// The Sister and He Who Wept eldritch painting
/obj/item/wallframe/painting/eldritch/weeping
	name = "Сестра и Плачущий"
	desc = "Прекрасная картина, изображающая прекрасную даму, сидящую рядом с Ним. Он плачет. Вы ещё увидите Его."
	icon_state = "eldritch_painting_weeping"
	result_path = /obj/structure/sign/painting/eldritch/weeping


/obj/structure/sign/painting/eldritch/weeping
	name = "Сестра и Плачущий"
	desc = "Прекрасная картина, изображающая прекрасную даму, сидящую рядом с Ним. Он плачет. Вы ещё увидите Его. Можно снять кусачками."
	icon_state = "eldritch_painting_weeping"
	text_to_display = "Так прекрасна! Так печально!"


/obj/structure/sign/painting/eldritch/weeping/apply_choosen_trauma(mob/living/carbon/human/viewer)
	viewer.force_gene_block(GLOB.hallucinationblock, TRUE, TRUE)
	viewer.Hallucinate(3 MINUTES)


/obj/structure/sign/painting/eldritch/weeping/examine_effects(mob/living/carbon/examiner)
	if(!isheretic(examiner))
		to_chat(examiner, span_purple("Отдохните. Пока можете..."))
		return

	to_chat(examiner, span_notice("Просто глядя на [declent_ru(ACCUSATIVE)], вы очищаете свой разум."))
	examiner.SetHallucinate(0)
	examiner.adjustBrainLoss(-30)


// The First Desire painting, using a lot of the painting/eldritch framework
/obj/item/wallframe/painting/eldritch/desire
	name = "Фестиваль Желаний"
	desc = "Картина, изображающая изысканное пиршество. Несмотря на то, что еда давно сгнила, она выглядит очень аппетитно."
	icon_state = "eldritch_painting_desire"
	result_path = /obj/structure/sign/painting/eldritch/desire


/obj/structure/sign/painting/eldritch/desire
	name = "Фестиваль Желаний"
	desc = "Картина, изображающая изысканное пиршество. Несмотря на то, что еда давно сгнила, она выглядит очень аппетитно. Можно снять кусачками."
	icon_state = "eldritch_painting_desire"
	text_to_display = "Как же хочется есть..."


/obj/structure/sign/painting/eldritch/desire/apply_choosen_trauma(mob/living/carbon/human/viewer)
	viewer.gain_trauma(/datum/brain_trauma/severe/flesh_desire, TRAUMA_RESILIENCE_MAGIC)


// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/desire/examine_effects(mob/living/carbon/examiner)
	if(!isheretic(examiner))
		// Gives them some nutrition
		examiner.adjust_nutrition(50)
		to_chat(examiner, span_warning("Вы чувствуете жгучую боль в животе!"))
		examiner.adjustOrganLoss(INTERNAL_ORGAN_STOMACH, 5)
		to_chat(examiner, span_notice("Вы чувствуете что ваш голод отступил."))
		to_chat(examiner, span_warning("Вам следует запастись сырым мясом и органами, прежде чем вы снова проголодаетесь."))
		return

	// A list made of the organs and bodyparts the heretic can get
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


// Great chaparral over rolling hills, this one doesn't have the sensor type
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
	// A static list of 5 pretty strong mutations, simple to expand for any admins
	var/list/mutations = list(
		/datum/spacevine_mutation/aggressive_spread,
		/datum/spacevine_mutation/fire_proof,
		/datum/spacevine_mutation/woodening,
		/datum/spacevine_mutation/thorns,
		/datum/spacevine_mutation/toxicity,
	)
	// Poppy and harebell are used in heretic rituals
	var/list/items_to_spawn = list(
		/obj/item/reagent_containers/food/snacks/grown/poppy,
		/obj/item/reagent_containers/food/snacks/grown/harebell,
	)


/obj/structure/sign/painting/eldritch/vines/apply_choosen_trauma(mob/living/carbon/human/viewer)
	return


/obj/structure/sign/painting/eldritch/vines/Initialize(mapload, dir, building)
	. = ..()
	new /obj/structure/spacevine_controller/event(get_turf(src), mutations, 0, 10)


/obj/structure/sign/painting/eldritch/vines/examine_effects(mob/living/carbon/examiner)
	. = ..()
	if(!isheretic(examiner))
		new /obj/structure/spacevine_controller/event(get_turf(examiner), mutations, 0, 10)
		to_chat(examiner, span_purple("Вас завораживает изображение виноградной лозы на картине."))
		to_chat(examiner, span_notice("Вы чувствуете, как что-то извивается вокруг вас."))
		return

	var/item_to_spawn = pick(items_to_spawn)
	to_chat(examiner, span_notice("На мгновение вас завораживает хаотичный узор, который создает лоза."))
	to_chat(examiner, span_notice("Вы чувствуете, как жизнь расцветает вокруг."))
	new item_to_spawn(examiner.drop_location())


// Lady out of gates, gives a brain trauma causing the person to scratch themselves
/obj/item/wallframe/painting/eldritch/beauty
	name = "Леди за Вратами"
	desc = "Картина существа из другого мира. Тонкая кожа цвета фарфора туго натянута на странные кости. Она обладает странной красотой."
	icon_state = "eldritch_painting_beauty"
	result_path = /obj/structure/sign/painting/eldritch/beauty


/obj/structure/sign/painting/eldritch/beauty
	name = "Леди за Вратами"
	desc = "Картина существа из другого мира. Тонкая кожа цвета фарфора туго натянута на странные кости. Она обладает странной красотой. Можно снять кусачками."
	icon_state = "eldritch_painting_beauty"
	text_to_display = "Это маяк чистоты, по сравнению с которым реальный мир кажется таким обыденным и несовершенным..."
	/// List of reagents to add to heretics on examine, set to mutadone by default to remove mutations
	var/list/reagents_to_add = list(/datum/reagent/medicine/mutadone = 5)


/obj/structure/sign/painting/eldritch/beauty/apply_choosen_trauma(mob/living/carbon/human/viewer)
	viewer.force_gene_block(GLOB.radblock, TRUE, TRUE)
	viewer.apply_effect(30, IRRADIATE, 0)


// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/beauty/examine_effects(mob/living/carbon/examiner)
	. = ..()
	if(!examiner.dna)
		return

	if(!isheretic(examiner))
		to_chat(examiner, span_purple("Вы не чисты."))
		randmutb(examiner)
		return

	to_chat(examiner, span_notice("Ваши недостатки исчезнут."))
	examiner.reagents.add_reagent_list(reagents_to_add)


// Climb over the rusted mountain, gives a brain trauma causing the person to randomly rust tiles beneath them
/obj/item/wallframe/painting/eldritch/rust
	name = "Хозяйка Ржавой Горы"
	desc = "Картина, изображающая странное существо, взбирающееся на гору цвета ржавчины. Стиль картины неестественный и пугающий."
	icon_state = "eldritch_painting_rust"
	result_path = /obj/structure/sign/painting/eldritch/rust


/obj/structure/sign/painting/eldritch/rust
	name = "Хозяйка Ржавой Горы"
	desc = "Картина, изображающая странное существо, взбирающееся на гору цвета ржавчины. Стиль картины неестественный и пугающий. Можно снять кусачками."
	icon_state = "eldritch_painting_rust"
	text_to_display = "Ржавчина гниёт. Хозяйка поднимается. Она зовёт. Вы отвечаете..."


/obj/structure/sign/painting/eldritch/rust/apply_choosen_trauma(mob/living/carbon/human/viewer)
	//var/obj/item/organ/organ = pick(list(pick(viewer.internal_organs), pick(viewer.bodyparts)))
	//organ.handle_germs()
	viewer.gain_trauma(/datum/brain_trauma/severe/rusting, TRAUMA_RESILIENCE_MAGIC)


// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/rust/examine_effects(mob/living/carbon/examiner)
	. = ..()

	if(!isheretic(examiner))
		to_chat(examiner, span_purple("Вы чувствуете ржавчину. Гниль."))
		return

	to_chat(examiner, span_notice("Картина наполняет вас решимостью."))


// This one is for "Climb over the rusted mountain" or /obj/structure/sign/painting/eldritch/rust
/datum/brain_trauma/severe/rusting
	name = "Синдром Ржавой Горы"
	scan_desc = "опасная пси-волновая активность"
	gain_text = span_warning("Поднимись по ржавчине. Овладей энтропией.")
	lose_text = span_notice("У вас такое чувство, будто вы только что проснулись от дурного сна.")
	random_gain = FALSE

/datum/brain_trauma/severe/rusting/on_life(seconds_per_tick, times_fired)
	var/atom/tile = get_turf(owner)
	// Examining a painting should stop this effect to give counterplay
	if(HAS_TRAIT(owner, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return

	if(!SPT_PROB(50, seconds_per_tick))
		return

	to_chat(owner, span_notice("Вы чувствуете разложение..."))
	tile.rust_heretic_act()
