/datum/brain_trauma/unit_test
	name = "Unit Test Trauma"
	random_gain = FALSE
	var/gained = 0
	var/lost = 0

/datum/brain_trauma/unit_test/on_gain()
	gained++
	return ..()

/datum/brain_trauma/unit_test/on_lose(silent)
	lost++
	return ..()

/datum/brain_trauma/unit_test/stubborn
	resilience = TRAUMA_RESILIENCE_SURGERY

/datum/unit_test/brain_damage_strings/Run()
	for(var/attempt in 1 to 50)
		var/phrase = pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")
		TEST_ASSERT(phrase, "[BRAIN_DAMAGE_FILE] gave an empty phrase")
		TEST_ASSERT(!findtext(phrase, "@pick("), "[BRAIN_DAMAGE_FILE] left an unresolved substitution in '[phrase]'")

/datum/unit_test/phobia_data/Run()
	var/static/list/innocent_words = list(
		"автоматически", "бригада", "бригадир", "заговорил", "заговорить", "костюм",
		"костяшка", "костёр", "кровать", "кровля", "подставил", "подставка", "провалено",
		"провалился", "тянет", "тянуть", "шутить", "шутка", "шутник",
	)

	for(var/phobia_type in GLOB.phobia_random_types)
		TEST_ASSERT(GLOB.phobia_regexes[phobia_type], "randomly rollable phobia '[phobia_type]' has no word list")

	for(var/phobia_type in GLOB.phobia_types)
		if(phobia_type == "strangers")
			continue
		var/sights = length(GLOB.phobia_mobs[phobia_type]) + length(GLOB.phobia_objs[phobia_type]) + length(GLOB.phobia_turfs[phobia_type]) + length(GLOB.phobia_species[phobia_type])
		TEST_ASSERT(sights, "phobia '[phobia_type]' has nothing to be scared of on sight")

	for(var/phobia_type in GLOB.phobia_regexes)
		TEST_ASSERT(GLOB.phobia_types[phobia_type], "phobia '[phobia_type]' has no player facing name")
		var/regex/trigger = GLOB.phobia_regexes[phobia_type]
		var/list/words = strings(PHOBIA_FILE, phobia_type)

		for(var/word in words)
			TEST_ASSERT(trigger.Find("вот [word]ами и всё"), "phobia '[phobia_type]' does not match its own word '[word]'")
			TEST_ASSERT_EQUAL("[trigger.group[2]][trigger.group[3]]", "[word]ами", "phobia '[phobia_type]' did not capture all of the inflected '[word]'")
			TEST_ASSERT(trigger.Find("ВОТ [uppertext(word)]АМИ И ВСЁ"), "phobia '[phobia_type]' does not match '[word]' in caps")
			for(var/shadowed in words)
				if(shadowed != word)
					TEST_ASSERT(findtext(shadowed, word) != 1, "phobia '[phobia_type]' lists '[shadowed]', which '[word]' already swallows")

		for(var/innocent in innocent_words)
			TEST_ASSERT(!trigger.Find("вот [innocent] и всё"), "phobia '[phobia_type]' fires on the unrelated word '[innocent]'")

/datum/unit_test/room_test/brain_trauma_lifecycle/Run()
	for(var/datum/brain_trauma/trauma_type as anything in subtypesof(/datum/brain_trauma))
		if(trauma_type::abstract_type == trauma_type)
			continue

		var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
		var/datum/brain_trauma/trauma = patient.gain_trauma(trauma_type)
		if(QDELETED(trauma))
			qdel(patient)
			continue

		TEST_ASSERT_EQUAL(trauma.type, trauma_type, "gain_trauma() gave [trauma.type] instead of [trauma_type]")
		for(var/tick in 1 to 20)
			trauma.on_life()
			patient.say("проверка связи это тестовое сообщение")

		qdel(trauma)
		TEST_ASSERT(!patient.has_trauma_type(trauma_type, TRAUMA_RESILIENCE_ABSOLUTE), "[trauma_type] survived being deleted")
		qdel(patient)

/datum/unit_test/room_test/imaginary_friend_appearance/Run()
	var/mob/camera/imaginary_friend/friend = allocate(/mob/camera/imaginary_friend)
	friend.setup_appearance()

	TEST_ASSERT(friend.friend_icon, "the imaginary friend was given no appearance at all")
	TEST_ASSERT_NOTEQUAL(friend.real_name, initial(friend.real_name), "the imaginary friend kept its placeholder name")

	var/icon/appearance = friend.friend_icon
	var/drawn_pixels = 0
	for(var/pixel_x in 1 to appearance.Width())
		for(var/pixel_y in 1 to appearance.Height())
			if(appearance.GetPixel(pixel_x, pixel_y))
				drawn_pixels++
	TEST_ASSERT(drawn_pixels, "the imaginary friend's appearance rendered completely blank")

	var/icon/facing_north = icon(appearance, dir = NORTH)
	var/icon/facing_south = icon(appearance, dir = SOUTH)
	var/directional_pixels = 0
	for(var/pixel_x in 1 to appearance.Width())
		for(var/pixel_y in 1 to appearance.Height())
			if(facing_north.GetPixel(pixel_x, pixel_y) != facing_south.GetPixel(pixel_x, pixel_y))
				directional_pixels++
	TEST_ASSERT(directional_pixels, "the imaginary friend's appearance does not change with direction")

/datum/unit_test/room_test/alter_ego_appearance/Run()
	var/mob/camera/imaginary_friend/alter_ego/tyler = allocate(/mob/camera/imaginary_friend/alter_ego)
	tyler.setup_appearance()

	TEST_ASSERT_EQUAL(tyler.real_name, "Tyler Durden", "the alter ego did not take its fixed name")
	TEST_ASSERT_EQUAL(tyler.gender, MALE, "the alter ego did not take its fixed gender")

	var/icon/appearance = tyler.friend_icon
	TEST_ASSERT_NOTNULL(appearance, "the alter ego was given no appearance at all")

	var/drawn_pixels = 0
	for(var/pixel_x in 1 to appearance.Width())
		for(var/pixel_y in 1 to appearance.Height())
			if(appearance.GetPixel(pixel_x, pixel_y))
				drawn_pixels++
	TEST_ASSERT(drawn_pixels, "the alter ego's appearance rendered completely blank")

/datum/unit_test/room_test/trapped_owner_appearance/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	var/mob/camera/imaginary_friend/trapped/remnant = allocate(/mob/camera/imaginary_friend/trapped)
	remnant.attach_to_owner(body)
	remnant.setup_appearance()

	TEST_ASSERT_EQUAL(remnant.real_name, "[body.real_name]?", "the trapped victim did not take its host's name")
	TEST_ASSERT_NOTNULL(remnant.friend_icon, "the trapped victim was given no appearance at all")
	TEST_ASSERT(remnant in body.imaginary_group, "the trapped victim never joined its host's imaginary group")

/datum/unit_test/room_test/alter_ego_outfit/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	wearer.equipOutfit(/datum/outfit/alter_ego, visualsOnly = TRUE)

	TEST_ASSERT(istype(wearer.wear_mask, /obj/item/clothing/mask/cigarette), "the alter ego outfit left no cigarette in the mask slot")
	var/obj/item/clothing/mask/cigarette/cig = wearer.wear_mask
	TEST_ASSERT(cig.lit, "the alter ego's cigarette was never lit")
	TEST_ASSERT_NOTNULL(wearer.glasses, "the alter ego outfit left the glasses slot empty")
	TEST_ASSERT_NOTNULL(wearer.wear_suit, "the alter ego outfit left the suit slot empty")

/datum/unit_test/room_test/obsessed_antagonist/Run()
	var/mob/living/carbon/human/creep = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/crush = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human)
	for(var/mob/living/carbon/human/participant as anything in list(creep, crush, bystander))
		participant.mind_initialize()
		participant.mind.assigned_role = JOB_TITLE_ENGINEER

	var/datum/antagonist/obsessed/antagonist = new
	antagonist.obsession = crush.mind
	TEST_ASSERT(creep.mind.add_antag_datum(antagonist), "the obsessed antag datum refused to attach")
	TEST_ASSERT_EQUAL(length(antagonist.objectives), antagonist.objectives_to_generate + 1, "the obsessed got the wrong number of objectives")

	for(var/datum/objective/objective as anything in antagonist.objectives)
		TEST_ASSERT(objective.explanation_text, "obsessed objective [objective.type] has no explanation text")
		TEST_ASSERT_NOTEQUAL(objective.explanation_text, "Свободная цель", "obsessed objective [objective.type] failed to find its target")
		objective.check_completion()

	TEST_ASSERT(antagonist.roundend_report(), "the obsessed roundend report came out empty")

/datum/unit_test/room_test/split_personality_backseats/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/datum/brain_trauma/severe/split_personality/trauma = new
	trauma.owner = patient
	trauma.make_backseats()

	TEST_ASSERT(trauma.stranger_backseat, "split personality made no backseat for the stranger")
	TEST_ASSERT(trauma.owner_backseat, "split personality made no backseat for the owner")
	TEST_ASSERT_EQUAL(trauma.stranger_backseat.body, patient, "the stranger backseat is not attached to the body")
	TEST_ASSERT_EQUAL(trauma.stranger_backseat.real_name, patient.real_name, "the stranger backseat did not take the body's name")
	TEST_ASSERT(locate(/datum/action/innate/personality_commune) in trauma.stranger_backseat.actions, "the backseat cannot commune with the host")

	qdel(trauma)

/datum/unit_test/room_test/brain_trauma_resilience/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/datum/brain_trauma/stubborn = patient.gain_trauma(/datum/brain_trauma/unit_test/stubborn)

	TEST_ASSERT(patient.has_trauma_type(/datum/brain_trauma/unit_test/stubborn), "has_trauma_type() with no resilience argument missed a surgery tier trauma")

	patient.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
	TEST_ASSERT(!QDELETED(stubborn), "a surgery tier trauma was cured by basic tier curing")

	patient.cure_trauma_type(resilience = TRAUMA_RESILIENCE_SURGERY)
	TEST_ASSERT(QDELETED(stubborn), "a surgery tier trauma survived surgery tier curing")

/datum/unit_test/room_test/brain_trauma_traits/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/external/left_hand = patient.get_organ(BODY_ZONE_PRECISE_L_HAND)
	var/obj/item/organ/external/right_hand = patient.get_organ(BODY_ZONE_PRECISE_R_HAND)

	TEST_ASSERT(left_hand.is_usable(), "the test dummy started with an unusable left hand")

	ADD_TRAIT(patient, TRAIT_PARALYSIS_L_ARM, TRAUMA_TRAIT)
	TEST_ASSERT(!left_hand.is_usable(), "a paralysed left hand is still usable")
	TEST_ASSERT(right_hand.is_usable(), "paralysing the left arm made the right hand unusable")

	REMOVE_TRAIT(patient, TRAIT_PARALYSIS_L_ARM, TRAUMA_TRAIT)
	TEST_ASSERT(left_hand.is_usable(), "the left hand stayed unusable after the paralysis was cured")

	TEST_ASSERT(patient.is_literate(), "the test dummy started illiterate")
	ADD_TRAIT(patient, TRAIT_ILLITERATE, TRAUMA_TRAIT)
	TEST_ASSERT(!patient.is_literate(), "an illiterate mob can still read")

	TEST_ASSERT(patient.IsAdvancedToolUser(), "the test dummy started unable to use tools")
	patient.apply_status_effect(/datum/status_effect/discoordinated)
	TEST_ASSERT(!patient.IsAdvancedToolUser(), "a discoordinated mob can still use tools")
	patient.remove_status_effect(/datum/status_effect/discoordinated)
	TEST_ASSERT(patient.IsAdvancedToolUser(), "tool use did not come back after discoordination ended")

/datum/unit_test/room_test/brain_damage_scale/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)

	patient.adjustBrainLoss(BRAIN_DAMAGE_DEATH - 20, forced = TRUE)
	TEST_ASSERT_EQUAL(patient.getBrainLoss(), BRAIN_DAMAGE_DEATH - 20, "brain damage did not reach [BRAIN_DAMAGE_DEATH - 20]")
	TEST_ASSERT(patient.stat != DEAD, "the patient died before reaching [BRAIN_DAMAGE_DEATH] brain damage")

	patient.adjustBrainLoss(40, forced = TRUE)
	TEST_ASSERT_EQUAL(patient.getBrainLoss(), BRAIN_DAMAGE_DEATH, "brain damage was not capped at [BRAIN_DAMAGE_DEATH]")
	TEST_ASSERT_EQUAL(patient.stat, DEAD, "the patient survived [BRAIN_DAMAGE_DEATH] brain damage")

/datum/unit_test/room_test/brain_traumas/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/datum/brain_trauma/unit_test/trauma = patient.gain_trauma(/datum/brain_trauma/unit_test)

	TEST_ASSERT_NOTNULL(trauma, "gain_trauma() returned nothing")
	TEST_ASSERT_EQUAL(trauma.gained, 1, "on_gain() was not called exactly once on gaining the trauma")
	TEST_ASSERT(patient.has_trauma_type(/datum/brain_trauma/unit_test), "has_trauma_type() cannot find the gained trauma")
	TEST_ASSERT_NULL(patient.gain_trauma(/datum/brain_trauma/unit_test), "the same trauma type was gained twice")

	var/obj/item/organ/internal/brain/donor_brain = patient.get_int_organ(/obj/item/organ/internal/brain)
	donor_brain.remove(patient)
	TEST_ASSERT_EQUAL(trauma.lost, 1, "on_lose() was not called when the brain was removed")
	TEST_ASSERT_NULL(trauma.owner, "the trauma kept its owner after the brain was removed")
	TEST_ASSERT_EQUAL(trauma.brain, donor_brain, "the trauma did not stay with the removed brain")

	var/mob/living/carbon/human/recipient = allocate(/mob/living/carbon/human)
	qdel(recipient.get_int_organ(/obj/item/organ/internal/brain))
	donor_brain.insert(recipient)
	TEST_ASSERT_EQUAL(trauma.gained, 2, "on_gain() was not called when the brain was transplanted")
	TEST_ASSERT_EQUAL(trauma.owner, recipient, "the trauma did not follow the brain to its new owner")

	recipient.cure_trauma_type(/datum/brain_trauma/unit_test, TRAUMA_RESILIENCE_ABSOLUTE)
	TEST_ASSERT(QDELETED(trauma), "cure_trauma_type() did not delete the trauma")
	TEST_ASSERT(!length(donor_brain.traumas), "the cured trauma was left in the brain's trauma list")

/datum/unit_test/room_test/brain_trauma_sources/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)

	var/datum/event/brain_trauma/event = new(null, TRUE)
	event.traumatize(patient)
	TEST_ASSERT(patient.has_trauma_type(/datum/brain_trauma, TRAUMA_RESILIENCE_ABSOLUTE), "the spontaneous brain trauma event handed out no trauma")
	patient.cure_all_traumas(TRAUMA_RESILIENCE_ABSOLUTE)
	qdel(event)

	patient.reagents.add_reagent("bath_salts", 5)
	TEST_ASSERT(patient.has_trauma_type(/datum/brain_trauma/special/psychotic_brawling/bath_salts, TRAUMA_RESILIENCE_ABSOLUTE), "bath salts did not induce chemical psychosis")
	patient.reagents.del_reagent("bath_salts")
	TEST_ASSERT(!patient.has_trauma_type(/datum/brain_trauma/special/psychotic_brawling/bath_salts, TRAUMA_RESILIENCE_ABSOLUTE), "the chemical psychosis outlived the bath salts")

	patient.reagents.add_reagent("beepskysmash", 5)
	TEST_ASSERT(patient.has_trauma_type(/datum/brain_trauma/special/beepsky, TRAUMA_RESILIENCE_ABSOLUTE), "beepsky smash conjured no securitron")
	patient.reagents.del_reagent("beepskysmash")
	TEST_ASSERT(!patient.has_trauma_type(/datum/brain_trauma/special/beepsky, TRAUMA_RESILIENCE_ABSOLUTE), "the securitron outlived the beepsky smash")

	TEST_ASSERT(GLOB.chemical_reagents_list["neurine"], "neurine is not a registered reagent")

/datum/unit_test/room_test/phobia_sight/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/officer = allocate(/mob/living/carbon/human)
	var/obj/item/bikehorn/horn = allocate(/obj/item/bikehorn)
	officer.equip_to_slot_or_del(new /obj/item/clothing/under/rank/captain, ITEM_SLOT_CLOTH_INNER)

	var/datum/brain_trauma/mild/phobia/coulrophobia = patient.gain_trauma(new /datum/brain_trauma/mild/phobia("clowns"))
	TEST_ASSERT(coulrophobia.is_scary_obj(horn), "a clown phobe is not scared of a bike horn")
	TEST_ASSERT_EQUAL(coulrophobia.find_scary_thing(), horn, "a clown phobe did not spot the bike horn lying in view")

	var/datum/brain_trauma/mild/phobia/authority_phobia = new("authority")
	authority_phobia.owner = patient
	authority_phobia.on_gain()
	TEST_ASSERT(authority_phobia.is_scary_mob(officer), "an authority phobe is not scared of the captain's jumpsuit worn by a colleague")
	qdel(authority_phobia)

	officer.set_species(/datum/species/unathi/ashwalker)
	var/datum/brain_trauma/mild/phobia/herpetophobia = new("lizards")
	herpetophobia.owner = patient
	herpetophobia.on_gain()
	TEST_ASSERT(herpetophobia.is_scary_mob(officer), "a lizard phobe is not scared of an unathi")
	qdel(herpetophobia)

/datum/unit_test/room_test/cosmic_robes_curse/Run()
	var/mob/living/carbon/human/thief = allocate(/mob/living/carbon/human)
	thief.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic, ITEM_SLOT_CLOTH_OUTER)

	var/datum/brain_trauma/magic/stalker/cosmic/curse = thief.has_trauma_type(/datum/brain_trauma/magic/stalker/cosmic, TRAUMA_RESILIENCE_MAGIC)
	TEST_ASSERT(curse, "a non-heretic who put on the starwoven cloak was not cursed")
	TEST_ASSERT_EQUAL(curse.stalker_type, /obj/effect/client_image_holder/stalker_phantom/cosmic, "the cosmic stalker kept the default phantom")

/datum/unit_test/room_test/flesh_desire_palate/Run()
	var/mob/living/carbon/human/glutton = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/food/snacks/gore = allocate(/obj/item/reagent_containers/food/snacks)
	var/obj/item/reagent_containers/food/snacks/second_helping = allocate(/obj/item/reagent_containers/food/snacks)
	var/obj/item/reagent_containers/food/snacks/greens = allocate(/obj/item/reagent_containers/food/snacks)
	gore.foodtype = MEAT | GROSS
	second_helping.foodtype = MEAT | GROSS
	greens.foodtype = VEGETABLES

	gore.check_liked(1, bystander)
	TEST_ASSERT(bystander.AmountDisgust() > 0, "raw meat did not disgust an ordinary human")

	glutton.gain_trauma(/datum/brain_trauma/severe/flesh_desire)
	glutton.SetDisgust(50)
	second_helping.check_liked(1, glutton)
	TEST_ASSERT(glutton.AmountDisgust() < 50, "flesh desire did not make raw meat appetising")

	glutton.SetDisgust(0)
	greens.check_liked(1, glutton)
	TEST_ASSERT(glutton.AmountDisgust() > 0, "flesh desire did not make vegetables repulsive")
