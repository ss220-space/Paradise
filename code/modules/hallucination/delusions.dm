/// A hallucination that makes us and (possibly) other people appear as something else.
/datum/hallucination/delusion
	abstract_hallucination_parent = /datum/hallucination/delusion
	hallucination_tier = HALLUCINATION_TIER_UNCOMMON

	/// The duration of the delusions
	var/duration = 30 SECONDS

	/// If TRUE, this delusion affects us
	var/affects_us = TRUE
	/// If TRUE, this hallucination affects all humans in existence
	var/affects_others = FALSE
	/// If TRUE, people in view of our hallucinator won't be affected (requires affects_others)
	var/skip_nearby = FALSE
	/// If TRUE, we will play the wabbajack sound to the hallucinator
	var/play_wabbajack = FALSE

	/// The file the delusion image is made from
	var/delusion_icon_file
	/// The icon state of the delusion image
	var/delusion_icon_state

	/// The name of the delusion image
	var/delusion_name

	/// An assoc list of affected mobs -> delusions of them we've made
	var/list/delusions

/datum/hallucination/delusion/New(
	mob/living/hallucinator,
	duration,
	affects_us,
	affects_others,
	skip_nearby,
	play_wabbajack,
)

	if(isnum(duration))
		src.duration = duration
	if(!isnull(affects_us))
		src.affects_us = affects_us
	if(!isnull(affects_others))
		src.affects_others = affects_others
	if(!isnull(skip_nearby))
		src.skip_nearby = skip_nearby
	if(!isnull(play_wabbajack))
		src.play_wabbajack = play_wabbajack

	return ..()

/datum/hallucination/delusion/Destroy()
	if(!QDELETED(hallucinator) && LAZYLEN(delusions))
		for(var/image/funny_image in delusions)
			hallucinator.client?.images -= funny_image
		LAZYNULL(delusions)

	return ..()

/datum/hallucination/delusion/start()
	if(!hallucinator.client || hallucinator.incapacitated())
		return FALSE

	feedback_details += "Delusion: [delusion_name]"

	var/list/mob/living/carbon/human/funny_looking_mobs = list()

	// The delusion includes others - all humans
	if(affects_others)
		funny_looking_mobs |= GLOB.human_list.Copy()

	// The delusion includes us - we might be in it already, we might not
	if(affects_us && ishuman(hallucinator))
		funny_looking_mobs |= hallucinator
	// The delusion should not include us
	else
		funny_looking_mobs -= hallucinator

	// The delusion shouldn't include anyone in view of us
	if(skip_nearby)
		for(var/mob/living/carbon/human/nearby_human in view(hallucinator))
			if(nearby_human == hallucinator) // Already handled by affects_us
				continue
			funny_looking_mobs -= nearby_human

	for(var/mob/living/carbon/human/found_human as anything in funny_looking_mobs)
		var/image/funny_image = make_delusion_image(found_human)
		LAZYSET(delusions, found_human, funny_image)
		hallucinator.client.images |= funny_image

	if(play_wabbajack)
		to_chat(hallucinator, span_hear("...wabbajack...wabbajack..."))
		hallucinator.playsound_local(get_turf(hallucinator), 'sound/magic/staff_change.ogg', 50, TRUE)

	if(duration > 0)
		QDEL_IN(src, duration)
	return TRUE

/datum/hallucination/delusion/proc/make_delusion_image(mob/over_who)
	var/image/funny_image = image(delusion_icon_file, over_who, delusion_icon_state)
	funny_image.name = delusion_name
	funny_image.override = TRUE
	SET_PLANE_EXPLICIT(funny_image, ABOVE_GAME_PLANE, over_who)
	return funny_image

/datum/hallucination/delusion/preset
	abstract_hallucination_parent = /datum/hallucination/delusion/preset
	random_hallucination_weight = 2

/datum/hallucination/delusion/preset/clown
	delusion_icon_file = 'icons/mob/simple_human.dmi'
	delusion_icon_state = "clown"
	delusion_name = "clown"

/datum/hallucination/delusion/preset/fleshling
	delusion_icon_file = 'icons/mob/simple_human.dmi'
	delusion_icon_state = "fleshling1"
	delusion_name = "fleshling1"

/datum/hallucination/delusion/preset/carp
	delusion_icon_file = 'icons/mob/livestock.dmi'
	delusion_icon_state = "spesscarp"
	delusion_name = "spesscarp"

/datum/hallucination/delusion/preset/corgi
	delusion_icon_file = 'icons/mob/pets.dmi'
	delusion_icon_state = "corgi"
	delusion_name = "corgi"

/datum/hallucination/delusion/preset/borgi
	delusion_icon_file = 'icons/mob/pets.dmi'
	delusion_icon_state = "borgi"
	delusion_name = "borgi"

/datum/hallucination/delusion/preset/skeleton
	delusion_icon_file = 'icons/mob/simple_human.dmi'
	delusion_icon_state = "skeleton"
	delusion_name = "skeleton"

/datum/hallucination/delusion/preset/zombie
	delusion_icon_file = 'icons/mob/human.dmi'
	delusion_icon_state = "zombie_s"
	delusion_name = "zombie"

/datum/hallucination/delusion/preset/zombie2
	delusion_icon_file = 'icons/mob/human.dmi'
	delusion_icon_state = "zombie2_s"
	delusion_name = "zombie"

/datum/hallucination/delusion/preset/demon
	delusion_icon_file = 'icons/mob/mob.dmi'
	delusion_icon_state = "daemon"
	delusion_name = "demon"

/datum/hallucination/delusion/preset/cyborg
	delusion_icon_file = 'icons/mob/robots.dmi'
	delusion_icon_state = "Robot-RLX"
	delusion_name = "cyborg"
	play_wabbajack = TRUE

/datum/hallucination/delusion/preset/ghost
	delusion_icon_file = 'icons/mob/mob.dmi'
	delusion_icon_state = "ghost"
	delusion_name = "ghost"
	affects_others = TRUE
