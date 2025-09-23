#define SLIMEPERSON_COLOR_SHIFT_TRIGGER 0.1
#define SLIMEPERSON_ICON_UPDATE_PERIOD (20 SECONDS)
#define SLIMEPERSON_BLOOD_SCALING_FACTOR 5 // Used to adjust how much of an effect the blood has on the rate of color change. Higher is slower.

#define SLIMEPERSON_MINHUNGER 250
#define SLIMEPERSON_HUNGERCOST 50
#define SLIMEPERSON_CHANGEGENDERCOST 25
#define SLIMEPERSON_HAIRGROWTHCOST 10
#define SLIMEPERSON_HAIRGROWTHDELAY (5 SECONDS)
#define SLIMEPERSON_CHANGEGENDERDELAY (15 SECONDS)
#define SLIMEPERSON_REGROWTHDELAY (45 SECONDS)

GLOBAL_LIST_EMPTY(slime_actions)

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
		TRAIT_NO_DNA,
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


	disliked_food = SUGAR | FRIED
	liked_food = MEAT | TOXIC | RAW
	/// Special flag used for slimeperson evolved from the slime.
	var/evolved_slime = FALSE

	age_sheet = list(
		SPECIES_AGE_MIN = 17,
		SPECIES_AGE_MAX = 140,
		JOB_MIN_AGE_HIGH_ED = 30,
		JOB_MIN_AGE_COMMAND = 30,
	)

/datum/species/slime/on_species_gain(mob/living/carbon/human/slime)
	. = ..()
	var/datum/action/innate/slime_people_action/actions = locate() in slime.actions
	if(!actions)
		actions = new
		actions.Grant(slime)
	RegisterSignal(slime, COMSIG_HUMAN_UPDATE_DNA, PROC_REF(blend))
	blend(slime)
	add_verb(slime, /mob/living/carbon/human/proc/emote_squish)
	add_verb(slime, /mob/living/carbon/human/proc/emote_bubble)
	add_verb(slime, /mob/living/carbon/human/proc/emote_pop)


/datum/species/slime/on_species_loss(mob/living/carbon/human/slime)
	. = ..()
	var/datum/action/innate/slime_people_action/actions = locate() in slime.actions
	actions?.Remove(slime)

	UnregisterSignal(slime, COMSIG_HUMAN_UPDATE_DNA)
	remove_verb(slime, /mob/living/carbon/human/proc/emote_squish)
	remove_verb(slime, /mob/living/carbon/human/proc/emote_bubble)
	remove_verb(slime, /mob/living/carbon/human/proc/emote_pop)


/datum/species/slime/proc/blend(mob/living/carbon/human/slime)
	SIGNAL_HANDLER
	var/new_color = BlendRGB(slime.skin_colour, "#acacac", 0.5) // Blends this to make it work better
	if(slime.blood_color == new_color)  // Put here, so if it's a roundstart, dyed, or CMA'd slime, their blood changes to match skin
		return
	slime.blood_color = new_color
	slime.dna.species.blood_color = slime.blood_color

/datum/species/slime/handle_life(mob/living/carbon/human/slime)
	// Slowly shifting to the color of the reagents
	if(slime.reagents.total_volume > SLIMEPERSON_COLOR_SHIFT_TRIGGER)
		var/blood_amount = slime.blood_volume
		var/r_color = mix_color_from_reagents(slime.reagents.reagent_list)
		var/new_body_color = BlendRGB(r_color, slime.skin_colour, (blood_amount * SLIMEPERSON_BLOOD_SCALING_FACTOR) / ((blood_amount * SLIMEPERSON_BLOOD_SCALING_FACTOR) + slime.reagents.total_volume))
		slime.skin_colour = new_body_color
		if(world.time % SLIMEPERSON_ICON_UPDATE_PERIOD > SLIMEPERSON_ICON_UPDATE_PERIOD - 20) // The 20 is because this gets called every 2 seconds, from the mob controller
			for(var/organname in slime.bodyparts_by_name)
				var/obj/item/organ/external/external_organ = slime.bodyparts_by_name[organname]
				if(istype(external_organ) && external_organ.dna && istype(external_organ.dna.species, /datum/species/slime))
					external_organ.sync_colour_to_human(slime)
			slime.update_hair()
			slime.update_body()
			blend(slime)
	..()


/datum/species/slime/can_hear(mob/living/carbon/human/user)
	return !HAS_TRAIT(user, TRAIT_DEAF)


/datum/species/slime/get_vision_organ(mob/living/carbon/human/user)
	return NO_VISION_ORGAN

/datum/action/innate/slime_people_action
	name = "Манипуляция над собой"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slime_change"

/datum/action/innate/slime_people_action/Activate()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/slime = owner
	var/list/action_images = list()

	for(var/action_name in GLOB.slime_actions)
		var/datum/slime_action/action = GLOB.slime_actions[action_name]
		action_images[action_name] = image(icon = action.icon, icon_state = action.icon_state)

	var/choice = show_radial_menu(slime, slime, action_images, src, radius = 40)
	if(!choice)
		return FALSE

	var/datum/slime_action/select_action = GLOB.slime_actions[choice]
	select_action.activate(slime)

// SLIMEPERSON ACTIONS

/datum/slime_action
	var/name
	var/icon = 'icons/mob/actions/actions.dmi'
	var/icon_state

/datum/slime_action/proc/activate(mob/living/carbon/human/slime)
	return

/datum/slime_action/regrow
	name = "Восстановить конечность"
	icon_state = "slime_renew"

/datum/slime_action/regrow/activate(mob/living/carbon/human/slime)
	if(slime.nutrition < SLIMEPERSON_MINHUNGER)
		to_chat(slime, span_warning("Вы слишком голодны для регенерации конечностей!"))
		slime.balloon_alert(slime, "нужно поесть")
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
		to_chat(slime, span_warning("Все ваши конечности на месте!"))
		slime.balloon_alert(slime, "нечего отращивать")
		return

	var/limb_select = tgui_input_list(slime, "Выберите конечность для отращивания", "Отрастить конечность", missing_limbs)
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
	if(!do_after(slime, SLIMEPERSON_REGROWTHDELAY, slime, DA_IGNORE_LYING|DA_IGNORE_HELD_ITEM, extra_checks = CALLBACK(src, PROC_REF(regrowth_checks), chosen_limb_zone, slime)))
		return FALSE

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
	slime.balloon_alert(slime, "конечность регенерировала")
	playsound(slime, 'sound/effects/mob_effects/slime_bubble.ogg', 50, TRUE)

/datum/slime_action/regrow/proc/regrowth_checks(regrowth_zone, mob/living/carbon/human/slime)
	if(slime.nutrition < SLIMEPERSON_MINHUNGER)
		to_chat(slime, span_warning("Вы слишком голодны чтобы продолжить регенерацию!"))
		slime.balloon_alert(slime, "нужно поесть")
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

/datum/slime_action/set_color
	name = "Изменить цвет геля"
	icon_state = "slime_change"

/datum/slime_action/set_color/activate(mob/living/carbon/human/slime)
	if(!(slime.dna.species.bodyflags & HAS_SKIN_COLOR))
		return

	var/new_color = tgui_input_color(slime, "Выберите новый цвет геля.", "Цвет геля.", slime.skin_colour)

	if(!new_color)
		slime.balloon_alert(slime, "цвет не выбран")
		return

	slime.change_skin_color(new_color)
	if(slime.blood_color == new_color)
		slime.update_body()
		return

	slime.balloon_alert(slime, "цвет изменён")
	slime.blood_color = new_color
	slime.dna.species.blood_color = slime.blood_color
	slime.update_body()

/datum/slime_action/set_hair
	name = "Изменить причёску"
	icon_state = "slime_hair"

/datum/slime_action/set_hair/activate(mob/living/carbon/human/slime)
	var/list/valid_hairstyles = slime.generate_valid_hairstyles()
	var/obj/item/organ/external/head/head_organ = slime.get_organ(BODY_ZONE_HEAD)

	var/new_style = tgui_input_list(slime, "Пожалуйста, выберите стиль прически", "Изменить стиль", valid_hairstyles, head_organ.h_style)
	if(!new_style)
		return FALSE

	slime.visible_message(span_notice("Волосы на голове [slime] начинают шевелиться!"), span_notice("Вы концентрируетесь на своей прическе."))
	if(!do_after(slime, SLIMEPERSON_HAIRGROWTHDELAY, slime))
		slime.balloon_alert(slime, "концентрация потеряна")
		to_chat(slime, span_warning("Вы теряете концентрацию."))
		return FALSE

	slime.change_hair(new_style)
	slime.adjust_nutrition(-SLIMEPERSON_HAIRGROWTHCOST)
	slime.balloon_alert(slime, "прическа изменена")
	slime.visible_message(span_notice("[slime] изменил свою прическу."), span_notice("Вы изменили свою прическу."))
	playsound(slime, 'sound/effects/mob_effects/slime_bubble.ogg', 50, TRUE)

/datum/slime_action/set_beard
	name = "Изменить бороду"
	icon_state = "slime_beard"

/datum/slime_action/set_beard/activate(mob/living/carbon/human/slime)
	var/list/valid_facial_hairstyles = slime.generate_valid_facial_hairstyles()
	var/obj/item/organ/external/head/head_organ = slime.get_organ(BODY_ZONE_HEAD)

	if(slime.gender == FEMALE)
		to_chat(slime, span_warning("Вы не можете изменить бороду."))
		slime.balloon_alert(slime, "пол не подходит")
		return

	var/new_style = tgui_input_list(slime, "Выберите стиль бороны", "Изменить стиль", valid_facial_hairstyles, head_organ.f_style)
	if(!new_style)
		return FALSE

	slime.visible_message(span_notice("Волосы на лице [slime] начинают шевелиться!"), span_notice("Вы концентрируетесь на своей бороде."))
	if(!do_after(slime, SLIMEPERSON_HAIRGROWTHDELAY, slime))
		slime.balloon_alert(slime, "концентрация потеряна")
		to_chat(slime, span_warning("Вы теряете концентрацию."))
		return FALSE

	slime.change_facial_hair(new_style)
	slime.adjust_nutrition(-SLIMEPERSON_HAIRGROWTHCOST)
	slime.balloon_alert(slime, "борода изменена")
	slime.visible_message(span_notice("[slime] изменил свою бороду."), span_notice("Вы изменили свою бороду."))
	playsound(slime, 'sound/effects/mob_effects/slime_bubble.ogg', 50, TRUE)

/datum/slime_action/set_gender
	name = "Изменить пол"
	icon_state = "slime_gender_change"

/datum/slime_action/set_gender/activate(mob/living/carbon/human/slime)
	var/static/list/genders = list(FEMALE, MALE)
	var/new_gender = tgui_input_list(slime, "Выберите пол", "Изменить пол", genders, slime.gender)

	if(!new_gender)
		return FALSE

	if(new_gender == slime.gender)
		to_chat(slime, span_warning("Для изменения нужно выбрать пол, отличный от текущего."))
		return FALSE

	slime.visible_message(span_notice("Слизь и желе [slime] начинают слегка вибрировать!"), span_notice("Вы концентрируетесь на своей форме тела."))
	if(!do_after(slime, SLIMEPERSON_CHANGEGENDERDELAY, slime))
		slime.balloon_alert(slime, "концентрация потеряна")
		to_chat(slime, span_warning("Вы теряете концентрацию или передумали изменяться."))
		return FALSE

	slime.change_gender(new_gender)
	slime.adjust_nutrition(-SLIMEPERSON_CHANGEGENDERCOST)
	slime.balloon_alert(slime, "пол изменён")
	slime.visible_message(span_notice("[slime] изменяет свой пол!"), span_notice("Вы изменили свой пол."))
	playsound(slime, 'sound/effects/mob_effects/slime_bubble.ogg', 50, TRUE)

#undef SLIMEPERSON_COLOR_SHIFT_TRIGGER
#undef SLIMEPERSON_ICON_UPDATE_PERIOD
#undef SLIMEPERSON_BLOOD_SCALING_FACTOR

#undef SLIMEPERSON_HUNGERCOST
#undef SLIMEPERSON_MINHUNGER
#undef SLIMEPERSON_REGROWTHDELAY
#undef SLIMEPERSON_HAIRGROWTHDELAY
#undef SLIMEPERSON_HAIRGROWTHCOST
#undef SLIMEPERSON_CHANGEGENDERCOST
#undef SLIMEPERSON_CHANGEGENDERDELAY

