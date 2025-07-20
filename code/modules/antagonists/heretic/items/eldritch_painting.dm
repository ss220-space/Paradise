// The basic eldritch painting
/obj/item/wallframe/painting/eldritch
	name = "The Blank Canvas: A Study in Default Subtypes"
	desc = "An impossible painting made of impossible paint. It should not exist in this reality."
	icon = 'icons/obj/signs.dmi'
	resistance_flags = FLAMMABLE
	icon_state = "eldritch_painting_debug"
	result_path = /obj/structure/sign/painting/eldritch
	pixel_shift = 30


/obj/structure/sign/painting/eldritch
	name = "The Blank Canvas: A Study in Default Subtypes"
	desc = "An impossible painting made of impossible paint. It should not exist in this reality."
	icon = 'icons/obj/signs.dmi'
	icon_state = "eldritch_painting_debug"
	resistance_flags = FLAMMABLE
	//buildable_sign = FALSE
	// The list of canvas types accepted by this frame, set to zero here
	accepted_canvas_types = list()
	// Set to false since we don't want this to persist
	persistence_id = FALSE
	/// The text that shows up when you cross the paintings path
	var/text_to_display = "Some things should not be seen by mortal eyes..."
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
	to_chat(viewer, span_hypnophrase("Your mind is overcome! The painting leaves a mark on your psyche."))

/obj/structure/sign/painting/eldritch/wirecutter_act(mob/living/user, obj/item/I)
	if(!user.can_block_magic(MAGIC_RESISTANCE))
		to_chat(user, span_hypnophrase("There's an itch in your brain. It's laughing at you..."))

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
		to_chat(examiner, span_notice("What an engrossing painting!"))
	else
		to_chat(examiner, span_notice("What a strange painting..."))


// The Sister and He Who Wept eldritch painting
/obj/item/wallframe/painting/eldritch/weeping
	name = "\improper The Sister and He Who Wept"
	desc = "A beautiful painting depicting a fair lady sitting beside Him. He weeps. You will see him again."
	icon_state = "eldritch_painting_weeping"
	result_path = /obj/structure/sign/painting/eldritch/weeping


/obj/structure/sign/painting/eldritch/weeping
	name = "Сестра и Плачущий"
	desc = "Прекрасная картина, изображающая прекрасную даму, сидящую рядом с Ним. Он плачет. Вы ещё увидите Его. Можно снять кусачками."
	icon_state = "eldritch_painting_weeping"
	text_to_display = "Such beauty! Such sorrow!"


/obj/structure/sign/painting/eldritch/weeping/apply_choosen_trauma(mob/living/carbon/human/viewer)
	viewer.force_gene_block(GLOB.hallucinationblock, TRUE, TRUE)
	viewer.Hallucinate(3 MINUTES)


/obj/structure/sign/painting/eldritch/weeping/examine_effects(mob/living/carbon/examiner)
	if(!isheretic(examiner))
		to_chat(examiner, span_hypnophrase("Respite, for now...."))
		return

	to_chat(examiner, span_notice("Just gazing upon it clears your mind."))
	examiner.SetHallucinate(0)


// The First Desire painting, using a lot of the painting/eldritch framework
/obj/item/wallframe/painting/eldritch/desire
	name = "\improper The Feast of Desire"
	desc = "A painting of an elaborate feast. Despite being made entirely of rotting meat and decaying organs, the food looks very appetising."
	icon_state = "eldritch_painting_desire"
	result_path = /obj/structure/sign/painting/eldritch/desire


/obj/structure/sign/painting/eldritch/desire
	name = "Пир Чревоугодия"
	desc = "Картина, изображающая изысканное пиршество. Несмотря на то, что еда давно сгнила, она выглядит очень аппетитно. Можно снять кусачками."
	icon_state = "eldritch_painting_desire"
	text_to_display = "Just looking at this painting makes me hungry..."


/obj/structure/sign/painting/eldritch/desire/apply_choosen_trauma(mob/living/carbon/human/viewer)
	viewer.gain_trauma(/datum/brain_trauma/severe/flesh_desire, TRAUMA_RESILIENCE_MAGIC)


// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/desire/examine_effects(mob/living/carbon/examiner)
	if(!isheretic(examiner))
		// Gives them some nutrition
		examiner.adjust_nutrition(50)
		to_chat(examiner, span_warning("You feel a searing pain in your stomach!"))
		examiner.adjustOrganLoss(INTERNAL_ORGAN_STOMACH, 5)
		to_chat(examiner, span_notice("You feel less hungry."))
		to_chat(examiner, span_warning("You should stockpile raw meat and organs, before you get hungry again."))
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
	to_chat(examiner, span_notice("A piece of flesh crawls out of the painting and flops onto the floor."))
	to_chat(examiner, span_warning("The void screams!"))


// Great chaparral over rolling hills, this one doesn't have the sensor type
/obj/item/wallframe/painting/eldritch/vines
	name = "\improper Great Chaparral Over Rolling Hills"
	desc = "A painting depicting a massive thicket. This painting teems with life, and seems to strain against its frame."
	icon_state = "eldritch_painting_vines"
	result_path = /obj/structure/sign/painting/eldritch/vines


/obj/structure/sign/painting/eldritch/vines
	name = "\improper Great Chaparral Over Rolling Hills"
	desc = "A painting depicting a massive thicket. This painting teems with life, and seems to strain against its frame. Removable with wirecutters."
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
		to_chat(examiner, span_hypnophrase("You are transfixed for a moment by the vines on the painting."))
		to_chat(examiner, span_notice("You feel something writhing around you."))
		return

	var/item_to_spawn = pick(items_to_spawn)
	to_chat(examiner, span_notice("You are transfixed for a moment by the chaotic patterns the vines make."))
	to_chat(examiner, span_notice("You feel life coalesce and bloom beneath you."))
	new item_to_spawn(examiner.drop_location())


// Lady out of gates, gives a brain trauma causing the person to scratch themselves
/obj/item/wallframe/painting/eldritch/beauty
	name = "\improper Lady of the Gate"
	desc = "A painting of an otherworldly being. Its thin, porcelain-coloured skin is stretched tight over its strange bone structure. It has an odd beauty."
	icon_state = "eldritch_painting_beauty"
	result_path = /obj/structure/sign/painting/eldritch/beauty


/obj/structure/sign/painting/eldritch/beauty
	name = "Леди за Вратами"
	desc = "Картина существа из другого мира. Тонкая кожа цвета фарфора туго натянута на странные кости. Она обладает странной красотой. Можно снять кусачками."
	icon_state = "eldritch_painting_beauty"
	text_to_display = "A beacon of purity, the real world seems so mundane and imperfect in comparison..."
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
		to_chat(examiner, span_hypnophrase("You are not yet pure."))
		randmutb(examiner)
		return

	to_chat(examiner, span_notice("Your imperfections are shed."))
	examiner.reagents.add_reagent_list(reagents_to_add)


// Climb over the rusted mountain, gives a brain trauma causing the person to randomly rust tiles beneath them
/obj/item/wallframe/painting/eldritch/rust
	name = "\improper Master of the Rusted Mountain"
	desc = "A painting of a strange being climbing a rust-coloured mountain. The brushwork is unnatural and unnerving."
	icon_state = "eldritch_painting_rust"
	result_path = /obj/structure/sign/painting/eldritch/rust


/obj/structure/sign/painting/eldritch/rust
	name = "Хозяйка Ржавой Горы" // I think its like ike "Хозяйка Медной горы" from "Малахитовая шкатулка".
	desc = "Картина, изображающая странное существо, взбирающееся на гору цвета ржавчины. Стиль картины неестественный и пугающий. Можно снять кусачками."
	icon_state = "eldritch_painting_rust"
	text_to_display = "The rust decays. The master climbs. It calls. You answer..."


/obj/structure/sign/painting/eldritch/rust/apply_choosen_trauma(mob/living/carbon/human/viewer)
	var/obj/item/organ/organ = pick(list(pick(viewer.internal_organs), pick(viewer.bodyparts)))
	organ.handle_germs()


// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/rust/examine_effects(mob/living/carbon/examiner)
	. = ..()

	if(!isheretic(examiner))
		to_chat(examiner, span_hypnophrase("You feel the rust. The rot."))
		return

	to_chat(examiner, span_notice("The painting fills you with resolve."))
