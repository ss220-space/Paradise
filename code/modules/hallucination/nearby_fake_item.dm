/// A hallucination that creates the illusion that someone nearby has pulled out a weapon or object.
/datum/hallucination/nearby_fake_item
	abstract_hallucination_parent = /datum/hallucination/nearby_fake_item
	random_hallucination_weight = 4
	hallucination_tier = HALLUCINATION_TIER_COMMON

	/// The icon file to draw from for left hand icons
	var/left_hand_file
	/// The icon file to draw from for right hand icons
	var/right_hand_file
	/// The icon state of the files to make the image from
	var/image_icon_state
	/// The image we actually generate
	var/image/generated_image

/datum/hallucination/nearby_fake_item/Destroy()
	if(generated_image)
		hallucinator.client?.images -= generated_image
		generated_image = null
	return ..()

/datum/hallucination/nearby_fake_item/start()
	// This hallucination is purely visual, so we don't need to bother for clientless mobs
	if(!hallucinator.client || hallucinator.stat != CONSCIOUS)
		return FALSE

	var/list/mob_pool = list()
	for(var/mob/living/carbon/human/nearby_mob in view(7, hallucinator))
		if(nearby_mob == hallucinator)
			continue
		mob_pool += nearby_mob

	if(!length(mob_pool))
		return FALSE

	var/mob/living/carbon/human/who_has_the_item = pick(mob_pool)
	feedback_details += "Mob: [who_has_the_item.real_name]"

	if(!who_has_the_item.l_hand)
		generated_image = generate_fake_image(who_has_the_item, file = left_hand_file)

	else if(!who_has_the_item.r_hand)
		generated_image = generate_fake_image(who_has_the_item, file = right_hand_file)

	if(generated_image)
		hallucinator.client?.images += generated_image
		addtimer(CALLBACK(src, PROC_REF(remove_image), who_has_the_item), rand(15 SECONDS, 25 SECONDS))
		return TRUE

	return FALSE

/// Generates the image with the given file on the passed mob.
/datum/hallucination/nearby_fake_item/proc/generate_fake_image(mob/living/carbon/human/holder, file)
	var/image/fake = image(file, holder, image_icon_state, layer = ABOVE_MOB_LAYER)
	SET_PLANE_EXPLICIT(fake, ABOVE_GAME_PLANE, holder)
	return fake

/// Remove the image when all's said and done.
/datum/hallucination/nearby_fake_item/proc/remove_image(mob/living/carbon/human/holder)
	if(QDELETED(src) || QDELETED(hallucinator) || !generated_image)
		return

	hallucinator.client?.images -= generated_image
	generated_image = null
	qdel(src)

/datum/hallucination/nearby_fake_item/e_sword
	left_hand_file = 'icons/mob/inhands/melee_lefthand.dmi'
	right_hand_file = 'icons/mob/inhands/melee_righthand.dmi'
	image_icon_state = "swordred"

/datum/hallucination/nearby_fake_item/e_sword/generate_fake_image(mob/living/carbon/human/holder, file)
	hallucinator.playsound_local(get_turf(holder), 'sound/weapons/saberon.ogg', 35, TRUE)
	return ..()

/datum/hallucination/nearby_fake_item/e_sword/remove_image(mob/living/carbon/human/holder)
	if(!QDELETED(holder))
		hallucinator.playsound_local(get_turf(holder), 'sound/weapons/saberoff.ogg', 35, TRUE)
	return ..()

/datum/hallucination/nearby_fake_item/arm_blade
	left_hand_file = 'icons/mob/inhands/melee_lefthand.dmi'
	right_hand_file = 'icons/mob/inhands/melee_righthand.dmi'
	image_icon_state = "arm_blade"

/datum/hallucination/nearby_fake_item/arm_blade/generate_fake_image(mob/living/carbon/human/holder, file)
	hallucinator.playsound_local(get_turf(holder), pick('sound/effects/bone_break_1.ogg', 'sound/effects/bone_break_2.ogg'), 35, TRUE)
	return ..()

/datum/hallucination/nearby_fake_item/arm_blade/remove_image(mob/living/carbon/human/holder)
	if(!QDELETED(holder))
		hallucinator.playsound_local(get_turf(holder), pick('sound/effects/bone_break_1.ogg', 'sound/effects/bone_break_2.ogg'), 35, TRUE)
	return ..()

/datum/hallucination/nearby_fake_item/arm_blade/flesh_maul
	image_icon_state = "flesh_maul"

/datum/hallucination/nearby_fake_item/taser
	left_hand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	right_hand_file = 'icons/mob/inhands/guns_righthand.dmi'
	image_icon_state = "advtaserstun3"

/datum/hallucination/nearby_fake_item/taser/ebow
	image_icon_state = "crossbow"

/datum/hallucination/nearby_fake_item/contractor_baton
	left_hand_file = 'icons/mob/inhands/melee_lefthand.dmi'
	right_hand_file = 'icons/mob/inhands/melee_righthand.dmi'
	image_icon_state = "contractor_baton_extended"

/datum/hallucination/nearby_fake_item/contractor_baton/generate_fake_image(mob/living/carbon/human/holder, file)
	hallucinator.playsound_local(get_turf(holder), 'sound/weapons/contractorbatonextend.ogg', 75, TRUE)
	return ..()

/datum/hallucination/nearby_fake_item/ttv
	left_hand_file = 'icons/mob/inhands/items_lefthand.dmi'
	right_hand_file = 'icons/mob/inhands/items_righthand.dmi'
	image_icon_state = "ttv"
