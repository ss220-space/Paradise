#define LIGHT_AMOUNT_HEAL 2
#define LIGHT_AMOUNT_DAMAGE 2
#define TIME_TO_EMPOWER (1 MINUTES)
#define TIME_TO_EXHAUST (5 SECONDS)

/datum/species/shadow
	name = SPECIES_SHADOW_BASIC
	name_plural = "Shadows"

	icobase = 'icons/mob/human_races/r_shadow.dmi'
	deform = 'icons/mob/human_races/r_shadow.dmi'
	dangerous_existence = TRUE
	inherent_factions = list("faithless")

	unarmed_type = /datum/unarmed_attack/claws

	blood_color = "#CCCCCC"
	flesh_color = "#AAAAAA"

	has_organ = list(
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/shadow, //8 darksight.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

	inherent_traits = list(
		TRAIT_NO_BLOOD,
		TRAIT_NO_BREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
	)
	dies_at_threshold = TRUE

	reagent_tag = PROCESS_ORG
	suicide_messages = list(
		"пытается откусить себе язык!",
		"выдавливает большими пальцами себе глазницы!",
		"сворачивает себе шею!",
		"пялится на ближайший источник света!")

	var/grant_vision_toggle = TRUE

	disliked_food = NONE

/datum/action/innate/shadow/darkvision //Darkvision toggle so shadowpeople can actually see where darkness is
	name = "Toggle Darkvision"
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_default"
	button_icon_state = "blind"

/datum/action/innate/shadow/darkvision/Activate()
	var/mob/living/carbon/human/human = owner
	if(!human.vision_type)
		human.set_vision_override(/datum/vision_override/nightvision)
		to_chat(human, "<span class='notice'>Вы изменяете свой взор, чтобы видеть сквозь тьму.</span>")
	else
		human.set_vision_override(null)
		to_chat(human, "<span class='notice'>Вы изменяете свой взор, чтобы вновь различать свет и тени.</span>")

/datum/species/shadow/on_species_gain(mob/living/carbon/human/human)
	. = ..()
	if(grant_vision_toggle)
		var/datum/action/innate/shadow/darkvision/vision_toggle = locate() in human.actions
		if(!vision_toggle)
			vision_toggle = new
			vision_toggle.Grant(human)

/datum/species/shadow/on_species_loss(mob/living/carbon/human/human)
	. = ..()
	var/datum/action/innate/shadow/darkvision/vision_toggle = locate() in human.actions
	if(grant_vision_toggle && vision_toggle)
		human.vision_type = null
		vision_toggle.Remove(human)
	human.clear_alert("lightexposure")
	human.remove_status_effect(STATUS_EFFECT_SHADOW_EMPOWER)

/datum/species/shadow/handle_life(mob/living/carbon/human/human)
	if(!light_check(human)) //if there's enough light, start dying
		human.take_overall_damage(1,1)
		human.throw_alert("lightexposure", /atom/movable/screen/alert/lightexposure)
	else if(light_check(human)) //heal in the dark
		human.heal_overall_damage(1,1)
		human.clear_alert("lightexposure")
	..()

/datum/species/shadow/proc/empower_handler(mob/living/carbon/human/human, empowering = FALSE)
	switch(empowering)
		if(TRUE)
			if(do_after(human, TIME_TO_EMPOWER, human, ALL, progress = FALSE, max_interact_count = 1, extra_checks = CALLBACK(src, PROC_REF(light_check), human)))
				human.apply_status_effect(STATUS_EFFECT_SHADOW_EMPOWER)
		if(FALSE)
			if(do_after(human, TIME_TO_EXHAUST, human, ALL, progress = FALSE, max_interact_count = 1)) // NO extra_checks. Out in the light? Lose empower.
				human.remove_status_effect(STATUS_EFFECT_SHADOW_EMPOWER)

/datum/species/shadow/proc/light_check(mob/living/carbon/human/human)
	var/turf/T = get_turf(human)
	if(T)
		var/light_amount = T.get_lumcount() * 10
		if(light_amount > LIGHT_AMOUNT_DAMAGE)
			if(human.has_status_effect(STATUS_EFFECT_SHADOW_EMPOWER))
				empower_handler(human)
			return FALSE
		else if(light_amount < LIGHT_AMOUNT_HEAL)
			if(!human.has_status_effect(STATUS_EFFECT_SHADOW_EMPOWER))
				empower_handler(human, empowering = TRUE)
	return TRUE // yes, we will heal in nullspace..

/datum/species/shadow/bullet_act(obj/item/projectile/P, mob/living/carbon/human/human)
	if(human.stat == DEAD)
		return TRUE
	if(human.has_status_effect(STATUS_EFFECT_SHADOW_EMPOWER) && prob(50))
		return FALSE
	return TRUE

#undef LIGHT_AMOUNT_HEAL
#undef LIGHT_AMOUNT_DAMAGE
#undef TIME_TO_EMPOWER
#undef TIME_TO_EXHAUST
