#define LIGHT_AMOUNT_HEAL 2
#define LIGHT_AMOUNT_DAMAGE 2
#define TIME_TO_EMPOWER 600
#define TIME_TO_EXHAUST 50

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

	species_traits = list(NO_BREATHE, NO_BLOOD, RADIMMUNE, VIRUSIMMUNE)
	dies_at_threshold = TRUE

	reagent_tag = PROCESS_ORG
	suicide_messages = list(
		"пытается откусить себе язык!",
		"выдавливает большими пальцами себе глазницы!",
		"сворачивает себе шею!",
		"пялится на ближайший источник света!")

	var/grant_vision_toggle = TRUE
	var/empowered = FALSE
	var/processing_state = FALSE // to avoid multiple do_after
	disliked_food = NONE

/datum/action/innate/shadow/darkvision //Darkvision toggle so shadowpeople can actually see where darkness is
	name = "Toggle Darkvision"
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_default"
	button_icon_state = "blind"

/datum/action/innate/shadow/darkvision/Activate()
	var/mob/living/carbon/human/H = owner
	if(!H.vision_type)
		H.set_vision_override(/datum/vision_override/nightvision)
		to_chat(H, "<span class='notice'>Вы изменяете свой взор, чтобы видеть сквозь тьму.</span>")
	else
		H.set_vision_override(null)
		to_chat(H, "<span class='notice'>Вы изменяете свой взор, чтобы вновь различать свет и тени.</span>")

/datum/species/shadow/on_species_gain(mob/living/carbon/human/H)
	..()
	if(grant_vision_toggle)
		var/datum/action/innate/shadow/darkvision/vision_toggle = locate() in H.actions
		if(!vision_toggle)
			vision_toggle = new
			vision_toggle.Grant(H)

/datum/species/shadow/on_species_loss(mob/living/carbon/human/H)
	..()
	var/datum/action/innate/shadow/darkvision/vision_toggle = locate() in H.actions
	if(grant_vision_toggle && vision_toggle)
		H.vision_type = null
		vision_toggle.Remove(H)
	H.clear_alert("lightexposure")

/datum/species/shadow/handle_life(mob/living/carbon/human/H)
	if(!light_check(H)) //if there's enough light, start dying
		if(empowered)
			timer(H)
		H.take_overall_damage(1,1)
		H.throw_alert("lightexposure", /atom/movable/screen/alert/lightexposure)
	else if(light_check(H)) //heal in the dark
		if(!empowered)
			timer(H, empowering = TRUE)
		else
			shadowmend(H)
		H.heal_overall_damage(1,1)
		H.clear_alert("lightexposure")
	..()

/datum/species/shadow/proc/shadowmend(mob/living/carbon/human/H)
	H.heal_overall_damage(1,1)
	H.adjustToxLoss(-0.5)
	H.adjustBrainLoss(-1)
	H.adjustCloneLoss(-0.5)
	H.SetWeakened(0)
	if(prob(15))
		var/list/fractured_organs = H.check_fractures()
		shuffle(fractured_organs)
		for(var/obj/item/organ/external/bodypart as anything in fractured_organs)
			if(bodypart.mend_fracture())
				break
	if(prob(1))
		H.check_and_regenerate_organs()

/datum/species/shadow/proc/timer(mob/living/carbon/human/H, empowering = FALSE)
	if(processing_state)
		return FALSE
	processing_state = TRUE
	if(empowering && do_after(H, TIME_TO_EMPOWER, H, ALL, progress = FALSE))
		to_chat(H, span_revenbignotice("You feel empowered with darkness!"))
		empowered = TRUE
		processing_state = FALSE
		return TRUE
	else if(do_after(H, TIME_TO_EXHAUST, H, ALL, progress = FALSE))
		to_chat(H, span_revenbignotice("You feel exhausted! Darkness no longer supports you!"))
		empowered = FALSE
		processing_state = FALSE
		return TRUE
	processing_state = FALSE
	return FALSE

/datum/species/shadow/proc/light_check(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	if(T)
		var/light_amount = T.get_lumcount() * 10
		if(light_amount > LIGHT_AMOUNT_DAMAGE)
			return FALSE
		else if(light_amount < LIGHT_AMOUNT_HEAL)
			return TRUE
	return TRUE // yes, we will heal in nullspace..

/datum/species/shadow/bullet_act(obj/item/projectile/P)
	var/mob/living/carbon/human/H = src
	if(H.stat == DEAD)
		..()
	var/turf/T = get_turf(H)
	if(T)
		var/light_amount = T.get_lumcount() * 10
		if(light_amount < LIGHT_AMOUNT_HEAL && empowered && prob(50))
			return
	..()


#undef LIGHT_AMOUNT_HEAL
#undef LIGHT_AMOUNT_DAMAGE
#undef TIME_TO_EMPOWER
#undef TIME_TO_EXHAUST