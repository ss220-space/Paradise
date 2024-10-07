#define SLIMEPERSON_COLOR_SHIFT_TRIGGER 0.1
#define SLIMEPERSON_ICON_UPDATE_PERIOD 200 // 20 seconds
#define SLIMEPERSON_BLOOD_SCALING_FACTOR 5 // Used to adjust how much of an effect the blood has on the rate of color change. Higher is slower.

#define SLIMEPERSON_HUNGERCOST 50
#define SLIMEPERSON_MINHUNGER 250
#define SLIMEPERSON_REGROWTHDELAY 450 // 45 seconds
#define SLIMEPERSON_HAIRGROWTHDELAY 50
#define SLIMEPERSON_HAIRGROWTHCOST 10

/datum/species/slime
	name = SPECIES_SLIMEPERSON
	name_plural = "Slime People"
	language = LANGUAGE_SLIME
	icobase = 'icons/mob/human_races/r_slime.dmi'
	deform = 'icons/mob/human_races/r_slime.dmi'
	remains_type = /obj/effect/decal/remains/slime
	inherent_factions = list("slime")

	// More sensitive to the cold
	cold_level_1 = 280
	cold_level_2 = 240
	cold_level_3 = 200
	coldmod = 3

	brain_mod = 1.5

	male_cough_sounds = list('sound/effects/mob_effects/slime_squish.ogg')
	female_cough_sounds = list('sound/effects/mob_effects/slime_squish.ogg')

	inherent_traits = list(
		TRAIT_EXOTIC_BLOOD,
		TRAIT_HAS_LIPS,
		TRAIT_HAS_REGENERATION,
		TRAIT_NO_SCAN,
		TRAIT_WATERBREATH,
	)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | NO_EYES
	reagent_tag = PROCESS_ORG

	flesh_color = "#5fe8b1"
	blood_color = "#0064C8"
	exotic_blood = "slimejelly"

	butt_sprite = "slime"

	has_organ = list(
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/slime,
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/slime,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/slime,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/slime

	has_limbs = list(
		BODY_ZONE_CHEST = list("path" = /obj/item/organ/external/chest/unbreakable),
		BODY_ZONE_PRECISE_GROIN = list("path" = /obj/item/organ/external/groin/unbreakable),
		BODY_ZONE_HEAD = list("path" = /obj/item/organ/external/head/unbreakable),
		BODY_ZONE_L_ARM = list("path" = /obj/item/organ/external/arm/unbreakable),
		BODY_ZONE_R_ARM = list("path" = /obj/item/organ/external/arm/right/unbreakable),
		BODY_ZONE_L_LEG = list("path" = /obj/item/organ/external/leg/unbreakable),
		BODY_ZONE_R_LEG = list("path" = /obj/item/organ/external/leg/right/unbreakable),
		BODY_ZONE_PRECISE_L_HAND = list("path" = /obj/item/organ/external/hand/unbreakable),
		BODY_ZONE_PRECISE_R_HAND = list("path" = /obj/item/organ/external/hand/right/unbreakable),
		BODY_ZONE_PRECISE_L_FOOT = list("path" = /obj/item/organ/external/foot/unbreakable),
		BODY_ZONE_PRECISE_R_FOOT = list("path" = /obj/item/organ/external/foot/right/unbreakable),
	)

	suicide_messages = list(
		"тает в лужу!",
		"растекается в лужу!",
		"становится растаявшим желе!",
		"вырывает собственное ядро!",
		"становится коричневым, тусклым и растекается в лужу!")

	var/reagent_skin_coloring = FALSE

	disliked_food = SUGAR | FRIED
	liked_food = MEAT | TOXIC | RAW
	/// Special flag used for slimeperson evolved from the slime.
	var/evolved_slime = FALSE

/datum/species/slime/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	var/datum/action/innate/regrow/grow = locate() in H.actions
	if(!grow)
		grow = new
		grow.Grant(H)
	var/datum/action/innate/slimecolor/recolor = locate() in H.actions
	if(!recolor)
		recolor = new
		recolor.Grant(H)
	var/datum/action/innate/slimehair/changehair = locate() in H.actions
	if(!changehair)
		changehair = new
		changehair.Grant(H)
	var/datum/action/innate/slimebeard/changebeard = locate() in H.actions
	if(!changebeard)
		changebeard = new
		changebeard.Grant(H)
	RegisterSignal(H, COMSIG_HUMAN_UPDATE_DNA, PROC_REF(blend))
	blend(H)
	add_verb(H, /mob/living/carbon/human/proc/emote_squish)
	add_verb(H, /mob/living/carbon/human/proc/emote_bubble)
	add_verb(H, /mob/living/carbon/human/proc/emote_pop)


/datum/species/slime/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/action/innate/regrow/grow = locate() in H.actions
	grow?.Remove(H)
	var/datum/action/innate/slimecolor/recolor = locate() in H.actions
	recolor?.Remove(H)
	var/datum/action/innate/slimehair/changehair = locate() in H.actions
	changehair?.Remove(H)
	var/datum/action/innate/slimebeard/changebeard = locate() in H.actions
	changebeard?.Remove(H)
	UnregisterSignal(H, COMSIG_HUMAN_UPDATE_DNA)
	remove_verb(H, /mob/living/carbon/human/proc/emote_squish)
	remove_verb(H, /mob/living/carbon/human/proc/emote_bubble)
	remove_verb(H, /mob/living/carbon/human/proc/emote_pop)


/datum/species/slime/proc/blend(mob/living/carbon/human/H)
	var/new_color = BlendRGB(H.skin_colour, "#acacac", 0.5) // Blends this to make it work better
	if(H.blood_color != new_color) // Put here, so if it's a roundstart, dyed, or CMA'd slime, their blood changes to match skin
		H.blood_color = new_color
		H.dna.species.blood_color = H.blood_color

/datum/species/slime/handle_life(mob/living/carbon/human/H)
	// Slowly shifting to the color of the reagents
	if(reagent_skin_coloring && H.reagents.total_volume > SLIMEPERSON_COLOR_SHIFT_TRIGGER)
		var/blood_amount = H.blood_volume
		var/r_color = mix_color_from_reagents(H.reagents.reagent_list)
		var/new_body_color = BlendRGB(r_color, H.skin_colour, (blood_amount*SLIMEPERSON_BLOOD_SCALING_FACTOR)/((blood_amount*SLIMEPERSON_BLOOD_SCALING_FACTOR)+(H.reagents.total_volume)))
		H.skin_colour = new_body_color
		if(world.time % SLIMEPERSON_ICON_UPDATE_PERIOD > SLIMEPERSON_ICON_UPDATE_PERIOD - 20) // The 20 is because this gets called every 2 seconds, from the mob controller
			for(var/organname in H.bodyparts_by_name)
				var/obj/item/organ/external/E = H.bodyparts_by_name[organname]
				if(istype(E) && E.dna && istype(E.dna.species, /datum/species/slime))
					E.sync_colour_to_human(H)
			H.update_hair()
			H.update_body()
			blend(H)
	..()


/datum/species/slime/can_hear(mob/living/carbon/human/user)
	return !HAS_TRAIT(user, TRAIT_DEAF)


/datum/species/slime/get_vision_organ(mob/living/carbon/human/user)
	return NO_VISION_ORGAN


/datum/action/innate/slimecolor
	name = "Toggle Recolor"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "slime_change"

/datum/action/innate/slimecolor/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/slime/S = H.dna.species
	if(S.reagent_skin_coloring)
		S.reagent_skin_coloring = FALSE
		to_chat(H, "Вы настраиваете свою внутреннюю химию, чтобы отфильтровывать пигменты из употребляемых продуктов.")
	else
		S.reagent_skin_coloring = TRUE
		to_chat(H, "Вы настраиваете свою внутреннюю химию, позволяя окрашивать себя пигментами употребляемых веществ.")

/datum/action/innate/regrow
	name = "Regrow limbs"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "slime_renew"


/datum/action/innate/regrow/Activate()
	var/mob/living/carbon/human/slime = owner
	if(slime.nutrition < SLIMEPERSON_MINHUNGER)
		to_chat(slime, span_warning("Вы слишком голодны для регенерации конечностей!"))
		return

	var/list/missing_limbs = list()
	for(var/limb_zone in slime.bodyparts_by_name)
		var/obj/item/organ/external/bodypart = slime.bodyparts_by_name[limb_zone]
		if(!bodypart)
			var/list/limblist = slime.dna.species.has_limbs[limb_zone]
			var/obj/item/organ/external/limb = limblist["path"]
			var/parent_organ = initial(limb.parent_organ_zone)
			var/obj/item/organ/external/parentLimb = slime.bodyparts_by_name[parent_organ]
			if(!parentLimb)
				continue
			missing_limbs[initial(limb.name)] = limb_zone

	if(!length(missing_limbs))
		to_chat(slime, span_warning("Все Ваши конечности на месте!"))
		return

	var/limb_select = tgui_input_list(slime, "Choose a limb to regrow", "Limb Regrowth", missing_limbs)
	if(!limb_select) // If the user hit cancel on the popup, return
		return
	var/chosen_limb_zone = missing_limbs[limb_select]

	var/chosen_limb_ru
	switch(chosen_limb_zone)
		if(BODY_ZONE_L_LEG)
			chosen_limb_ru = "левой ноги"
		if(BODY_ZONE_R_LEG)
			chosen_limb_ru = "правой ноги"
		if(BODY_ZONE_PRECISE_L_FOOT)
			chosen_limb_ru = "левой ступни"
		if(BODY_ZONE_PRECISE_R_FOOT)
			chosen_limb_ru = "правой ступни"
		if(BODY_ZONE_L_ARM)
			chosen_limb_ru = "левой руки"
		if(BODY_ZONE_R_ARM)
			chosen_limb_ru = "правой руки"
		if(BODY_ZONE_PRECISE_L_HAND)
			chosen_limb_ru = "левой кисти"
		if(BODY_ZONE_PRECISE_R_HAND)
			chosen_limb_ru = "правой кисти"

	slime.visible_message(
		span_notice("[slime] замирает и концентрируется на регенерации своей [chosen_limb_ru]..."),
		span_notice("Вы концентрируетесь на регенерции [chosen_limb_ru]... (Это займет [round(SLIMEPERSON_REGROWTHDELAY/10)] секунд.)"),
	)
	if(!do_after(slime, SLIMEPERSON_REGROWTHDELAY, slime, DA_IGNORE_LYING|DA_IGNORE_HELD_ITEM, extra_checks = CALLBACK(src, PROC_REF(regrowth_checks), chosen_limb_zone)))
		return

	var/list/limb_list = slime.dna.species.has_limbs[chosen_limb_zone]
	var/obj/item/organ/external/limb_path = limb_list["path"]
	var/obj/item/organ/external/new_limb = new limb_path(slime, ORGAN_MANIPULATION_DEFAULT)
	slime.update_body()
	slime.updatehealth()
	slime.UpdateDamageIcon()
	slime.adjust_nutrition(-SLIMEPERSON_HUNGERCOST)

	var/new_limb_ru
	switch(new_limb.limb_zone)
		if(BODY_ZONE_L_LEG)
			chosen_limb_ru = "левую ногу"
		if(BODY_ZONE_R_LEG)
			chosen_limb_ru = "правую ногу"
		if(BODY_ZONE_PRECISE_L_FOOT)
			chosen_limb_ru = "левую ступню"
		if(BODY_ZONE_PRECISE_R_FOOT)
			chosen_limb_ru = "правую ступню"
		if(BODY_ZONE_L_ARM)
			chosen_limb_ru = "левую руку"
		if(BODY_ZONE_R_ARM)
			chosen_limb_ru = "правую руку"
		if(BODY_ZONE_PRECISE_L_HAND)
			chosen_limb_ru = "левую кисть"
		if(BODY_ZONE_PRECISE_R_HAND)
			chosen_limb_ru = "правую кисть"

	slime.visible_message(
		span_notice("[slime] регенерирует свою утраченную [new_limb_ru]!"),
		span_notice("Вы регенерировали [new_limb_ru].")
	)


/datum/action/innate/regrow/proc/regrowth_checks(regrowth_zone)
	var/mob/living/carbon/human/slime = owner
	if(slime.nutrition < SLIMEPERSON_MINHUNGER)
		to_chat(slime, span_warning("Вы слишком голодны чтобы продолжить регенерацию!"))
		return FALSE
	if(slime.get_organ(regrowth_zone))
		to_chat(slime, span_warning("Конечность уже восстановлена!"))
		return FALSE
	var/list/limb_list = slime.dna.species.has_limbs[regrowth_zone]
	var/obj/item/organ/external/limb_path = limb_list["path"]
	var/obj/item/organ/external/potential_parent = slime.get_organ(initial(limb_path.parent_organ_zone))
	if(!potential_parent)
		to_chat(slime, span_danger("Вы потеряли орган, на котором регенерировали новую конечность!"))
		return FALSE
	return TRUE


/datum/action/innate/slimehair
	name = "Change Hairstyle"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "greenglow"

/datum/action/innate/slimehair/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/valid_hairstyles = H.generate_valid_hairstyles()
	var/obj/item/organ/external/head/head_organ = H.get_organ(BODY_ZONE_HEAD)
	var/new_style = input("Please select hair style", "Character Generation", head_organ.h_style) as null|anything in valid_hairstyles
	if(new_style)
		H.visible_message("<span class='notice'>Волосы на голове [H] начинают шевелиться!.</span>", "<span class='notice'>Вы концентрируетесь на своей прическе.</span>")
		if(do_after(H, SLIMEPERSON_HAIRGROWTHDELAY, H))
			H.change_hair(new_style)
			H.adjust_nutrition(-SLIMEPERSON_HAIRGROWTHCOST)
			H.visible_message("<span class='notice'>[H] изменил свою прическу.</span>", "<span class='notice'>Вы изменили свою прическу.</span>")
		else
			to_chat(H, "<span class='warning'>Вы теряете концентрацию.</span>")

/datum/action/innate/slimebeard
	name = "Change Beard"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "greenglow"

/datum/action/innate/slimebeard/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/valid_facial_hairstyles = H.generate_valid_facial_hairstyles()
	var/obj/item/organ/external/head/head_organ = H.get_organ(BODY_ZONE_HEAD)
	if(H.gender == FEMALE)
		to_chat(H, "<span class='warning'> Вы не можете изменить бороду.</span>")
		return
	var/new_style = input("Please select facial style", "Character Generation", head_organ.f_style) as null|anything in valid_facial_hairstyles
	if(new_style)
		H.visible_message("<span class='notice'>Волосы на лице [H] начинают шевелиться!.</span>", "<span class='notice'>Вы концентрируетесь на своей бороде.</span>")
		if(do_after(H, SLIMEPERSON_HAIRGROWTHDELAY, H))
			H.change_facial_hair(new_style)
			H.adjust_nutrition(-SLIMEPERSON_HAIRGROWTHCOST)
			H.visible_message("<span class='notice'>[H] изменил свою бороду.</span>", "<span class='notice'>Вы изменили свою бороду.</span>")
		else
			to_chat(H, "<span class='warning'>Вы теряете концентрацию.</span>")

#undef SLIMEPERSON_COLOR_SHIFT_TRIGGER
#undef SLIMEPERSON_ICON_UPDATE_PERIOD
#undef SLIMEPERSON_BLOOD_SCALING_FACTOR

#undef SLIMEPERSON_HUNGERCOST
#undef SLIMEPERSON_MINHUNGER
#undef SLIMEPERSON_REGROWTHDELAY
#undef SLIMEPERSON_HAIRGROWTHDELAY
#undef SLIMEPERSON_HAIRGROWTHCOST
