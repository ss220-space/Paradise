#define PHEROMONES_LIFESPAN 15 MINUTES
#define PHEROMONES_MAX 3

/datum/species/kidan
	name = SPECIES_KIDAN
	name_plural = "Kidan"
	icobase = 'icons/mob/human_races/r_kidan.dmi'
	deform = 'icons/mob/human_races/r_def_kidan.dmi'
	language = LANGUAGE_KIDAN
	unarmed_type = /datum/unarmed_attack/claws

	brute_mod = 0.8
	tox_mod = 1.7

	inherent_traits = list(
		TRAIT_HAS_REGENERATION,
	)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_HEAD_ACCESSORY | HAS_HEAD_MARKINGS | HAS_BODY_MARKINGS
	fingers_count = 6
	eyes = "kidan_eyes_s"
	flesh_color = "#ba7814"
	blood_species = "Kidan"
	blood_color = "#FB9800"
	reagent_tag = PROCESS_ORG
	//Default styles for created mobs.
	default_headacc = "Normal Antennae"
	butt_sprite = "kidan"

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/kidan,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/kidan,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/kidan,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/kidan,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/kidan,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/kidan, //Default darksight of 2.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
		INTERNAL_ORGAN_LANTERN = /obj/item/organ/internal/lantern,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/kidan

	has_limbs = list(
		BODY_ZONE_CHEST = list("path" = /obj/item/organ/external/chest/kidan),
		BODY_ZONE_PRECISE_GROIN = list("path" = /obj/item/organ/external/groin/kidan),
		BODY_ZONE_HEAD = list("path" = /obj/item/organ/external/head/kidan),
		BODY_ZONE_L_ARM = list("path" = /obj/item/organ/external/arm),
		BODY_ZONE_R_ARM = list("path" = /obj/item/organ/external/arm/right),
		BODY_ZONE_L_LEG = list("path" = /obj/item/organ/external/leg),
		BODY_ZONE_R_LEG = list("path" = /obj/item/organ/external/leg/right),
		BODY_ZONE_PRECISE_L_HAND = list("path" = /obj/item/organ/external/hand),
		BODY_ZONE_PRECISE_R_HAND = list("path" = /obj/item/organ/external/hand/right),
		BODY_ZONE_PRECISE_L_FOOT = list("path" = /obj/item/organ/external/foot),
		BODY_ZONE_PRECISE_R_FOOT = list("path" = /obj/item/organ/external/foot/right),
	)

	allowed_consumed_mobs = list(/mob/living/simple_animal/diona)

	suicide_messages = list(
		"пытается откусить себе усики!",
		"вонзает когти в свои глазницы!",
		"сворачивает себе шею!",
		"разбивает себе панцирь",
		"протыкает себя челюстями!",
		"задерживает дыхание!")

	speech_sounds = list('sound/voice/kidan/speak1.ogg', 'sound/voice/kidan/speak2.ogg', 'sound/voice/kidan/speak3.ogg' )
	speech_chance = 35
	scream_verb = "визж%(ит,ат)%"
	female_giggle_sound = list('sound/voice/kidan/giggles1.ogg', 'sound/voice/kidan/giggles2.ogg')
	male_giggle_sound = list('sound/voice/kidan/giggles1.ogg', 'sound/voice/kidan/giggles2.ogg')
	male_scream_sound = list('sound/voice/kidan/scream1.ogg', 'sound/voice/kidan/scream2.ogg', 'sound/voice/kidan/scream3.ogg')
	female_scream_sound = list('sound/voice/kidan/scream1.ogg', 'sound/voice/kidan/scream2.ogg', 'sound/voice/kidan/scream3.ogg')
	female_laugh_sound = list('sound/voice/kidan/laugh1.ogg', 'sound/voice/kidan/laugh2.ogg', 'sound/voice/kidan/laugh3.ogg', 'sound/voice/kidan/laugh4.ogg')
	male_laugh_sound = list('sound/voice/kidan/laugh1.ogg', 'sound/voice/kidan/laugh2.ogg', 'sound/voice/kidan/laugh3.ogg', 'sound/voice/kidan/laugh4.ogg')
	death_sounds = list('sound/voice/kidan/deathgasp1.ogg', 'sound/voice/kidan/deathgasp2.ogg')
	male_dying_gasp_sounds = list('sound/voice/kidan/dying_gasp1.ogg', 'sound/voice/kidan/dying_gasp2.ogg', 'sound/voice/kidan/dying_gasp3.ogg')
	female_dying_gasp_sounds = list('sound/voice/kidan/dying_gasp1.ogg', 'sound/voice/kidan/dying_gasp2.ogg', 'sound/voice/kidan/dying_gasp3.ogg')
	male_cough_sounds = list('sound/voice/kidan/cough1.ogg')
	female_cough_sounds = list('sound/voice/kidan/cough1.ogg')
	male_sneeze_sound = list('sound/voice/kidan/sneeze1.ogg', 'sound/voice/kidan/sneeze2.ogg', 'sound/voice/kidan/sneeze3.ogg', 'sound/voice/kidan/sneeze4.ogg')
	female_sneeze_sound = list('sound/voice/kidan/sneeze1.ogg', 'sound/voice/kidan/sneeze2.ogg', 'sound/voice/kidan/sneeze3.ogg', 'sound/voice/kidan/sneeze4.ogg')
	female_cry_sound = list('sound/voice/kidan/cry1.ogg', 'sound/voice/kidan/cry2.ogg')
	male_cry_sound = list('sound/voice/kidan/cry1.ogg', 'sound/voice/kidan/cry2.ogg')
	female_grumble_sound = list('sound/voice/kidan/grumble1.ogg', 'sound/voice/kidan/grumble2.ogg', 'sound/voice/kidan/grumble3.ogg')
	male_grumble_sound = list('sound/voice/kidan/grumble1.ogg', 'sound/voice/kidan/grumble2.ogg', 'sound/voice/kidan/grumble3.ogg')
	male_moan_sound = list('sound/voice/kidan/moan1.ogg')
	female_moan_sound = list('sound/voice/kidan/moan1.ogg')
	female_sigh_sound = list('sound/voice/kidan/sigh1.ogg', 'sound/voice/kidan/sigh2.ogg')
	male_sigh_sound = list('sound/voice/kidan/sigh1.ogg', 'sound/voice/kidan/sigh2.ogg')
	female_choke_sound = list('sound/voice/kidan/dying_gasp1.ogg', 'sound/voice/kidan/dying_gasp2.ogg', 'sound/voice/kidan/dying_gasp3.ogg')
	male_choke_sound = list('sound/voice/kidan/dying_gasp1.ogg', 'sound/voice/kidan/dying_gasp2.ogg', 'sound/voice/kidan/dying_gasp3.ogg')

	disliked_food = FRIED | DAIRY
	liked_food = SUGAR | ALCOHOL | GROSS | FRUIT

/datum/species/kidan/get_species_runechat_color(mob/living/carbon/human/H)
	var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
	return E.eye_colour

/datum/species/kidan/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, list(/mob/living/carbon/human/proc/emote_click,
					/mob/living/carbon/human/proc/emote_clack,
			   		/mob/living/carbon/human/proc/emote_wiggle,
			   		/mob/living/carbon/human/proc/emote_wave_k))
	remove_verb(H, list(
		/mob/living/carbon/human/verb/emote_pale,
		/mob/living/carbon/human/verb/emote_blink,
		/mob/living/carbon/human/verb/emote_blink_r,
		/mob/living/carbon/human/verb/emote_blush,
		/mob/living/carbon/human/verb/emote_wink,
		/mob/living/carbon/human/verb/emote_smile,
		/mob/living/carbon/human/verb/emote_snuffle,
		/mob/living/carbon/human/verb/emote_grin,
		/mob/living/carbon/human/verb/emote_eyebrow,
		/mob/living/carbon/human/verb/emote_frown,
		/mob/living/carbon/human/verb/emote_sniff,
		/mob/living/carbon/human/verb/emote_glare))
	// HUD for detecting pheromones
	var/datum/atom_hud/kidan_hud = GLOB.huds[DATA_HUD_KIDAN_PHEROMONES]
	kidan_hud.add_hud_to(H)

	// Action for creating pheromones
	var/datum/action/innate/produce_pheromones/produce_pheromones = locate() in H.actions
	if(!produce_pheromones)
		produce_pheromones = new
		produce_pheromones.Grant(H)


/datum/species/kidan/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	remove_verb(H, list(
		/mob/living/carbon/human/proc/emote_click,
		/mob/living/carbon/human/proc/emote_clack,
		/mob/living/carbon/human/proc/emote_wiggle,
		/mob/living/carbon/human/proc/emote_wave_k))
	add_verb(H, list(
		/mob/living/carbon/human/verb/emote_pale,
		/mob/living/carbon/human/verb/emote_blink,
		/mob/living/carbon/human/verb/emote_blink_r,
		/mob/living/carbon/human/verb/emote_blush,
		/mob/living/carbon/human/verb/emote_wink,
		/mob/living/carbon/human/verb/emote_smile,
		/mob/living/carbon/human/verb/emote_snuffle,
		/mob/living/carbon/human/verb/emote_grin,
		/mob/living/carbon/human/verb/emote_eyebrow,
		/mob/living/carbon/human/verb/emote_frown,
		/mob/living/carbon/human/verb/emote_sniff,
		/mob/living/carbon/human/verb/emote_glare))

	// Removing the HUD for detecting pheromones
	var/datum/atom_hud/kidan_hud = GLOB.huds[DATA_HUD_KIDAN_PHEROMONES]
	kidan_hud.remove_hud_from(H)

	// Removing the action for creating pheromones
	var/datum/action/innate/produce_pheromones/produce_pheromones = locate() in H.actions
	produce_pheromones?.Remove(H)


/// Pheromones spawnable by kida, only perceivable by other kida
/obj/effect/kidan_pheromones
	name = "kidan pheromones"
	desc = "Special pheromones secreted by a kidan."
	gender = PLURAL
	hud_possible = list(KIDAN_PHEROMONES_HUD)

	// This is to make it visible for observers and mappers at the same time
	invisibility = INVISIBILITY_OBSERVER
	icon_state = "kidan_pheromones"
	alpha = 220

	var/lifespan = PHEROMONES_LIFESPAN

	/// The message added by its creator, visible upon examine
	var/encoded_message

/obj/effect/kidan_pheromones/Initialize(mapload)
	. = ..()

	// Add itself to the kidan hud
	prepare_huds()
	for(var/datum/atom_hud/kidan_pheromones/kidan_hud in GLOB.huds)
		kidan_hud.add_to_hud(src)
	var/image/holder = hud_list[KIDAN_PHEROMONES_HUD]
	holder.icon = icon
	holder.icon_state = icon_state
	holder.alpha = 220

	// Delete itself after some time if it is not permanent variant
	if(lifespan)
		QDEL_IN(src, lifespan)

/obj/effect/kidan_pheromones/examine(mob/user)
	. = ..()
	if(encoded_message)
		. += "It has the following message: \"[encoded_message]\""
	// Failsafe for mappers/adminspawns if they forgot to add a message
	else
		. += "Its meaning is incomprehensible."

// For mappers/adminspawns, this one does not self-delete
/obj/effect/kidan_pheromones/permanent
	lifespan = null

// Innate action for creating pheromones and destroying current ones, owned by all kida
/datum/action/innate/produce_pheromones
	name = "Produce Pheromones"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "kidan_pheromones_static"

	/// How long our message can be (characters)
	var/maximum_message_length = 30

	/// How many active pheromones we can have
	var/active_pheromones_maximum = PHEROMONES_MAX

	/// Which currently existing pheromones belong to us
	var/list/active_pheromones_current

/datum/action/innate/produce_pheromones/Activate()
	var/mob/living/carbon/human/H = owner

	// Do we want to make or destroy them?
	switch(alert(H, "Would you like to produce or destroy nearby pheromones?", "Produce Pheromones", "Produce", "Destroy", "Cancel"))
		// We look for nearby pheromones, if they belong to us, we can destroy them
		if("Destroy")
			var/obj/effect/kidan_pheromones/pheromones_to_destroy = locate(/obj/effect/kidan_pheromones) in range(1, H)
			// No pheromones nearby
			if(!pheromones_to_destroy)
				to_chat(H, "<span class='warning'>You cannot find any pheromones nearby.</span>")
				return
			// These are not ours, do not touch them
			if(!(pheromones_to_destroy in active_pheromones_current))
				to_chat(H, "<span class='warning'>These pheromones were created by someone else, you are unable to dissipate them.</span>")
				return
			// These are ours and we now destroy them
			if(do_after(H, 3 SECONDS, pheromones_to_destroy, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
				// Log the action
				H.create_log(MISC_LOG, "destroyed pheromones that had the message of \"[pheromones_to_destroy.encoded_message]\"")

				// Destroy it; the pheromones remove themselves from our list via signals
				to_chat(H, "<span class='notice'>You dissipate your old pheromones.</span>")
				qdel(pheromones_to_destroy)

		// We decide to produce new ones
		if("Produce")
			// Can we create more pheromones?
			if(length(active_pheromones_current) >= active_pheromones_maximum)
				to_chat(H, "<span class='warning'>You already have [length(active_pheromones_current)] sets of pheromones active and are unable to produce any more.</span>")
				return

			// Encode the message
			var/message_to_encode = input(H, "What message do you wish to encode? (max. [maximum_message_length] characters) Leave it empty to cancel.", "Produce Pheromones")
			if(!message_to_encode)
				to_chat(H, "<span class='notice'>You decide against producing pheromones.</span>")
				return
			if(length(message_to_encode) > maximum_message_length)
				to_chat(H, "<span class='warning'>Your message was too long, the pheromones instantly dissipate.</span>")
				return
			// Strip the message now so it does not mess with the length
			message_to_encode = strip_html(message_to_encode)

			// One batch of pheromones per tile
			if(locate(/obj/effect/kidan_pheromones) in get_turf(H))
				to_chat(H, "<span class='warning'>There are pheromones here already!</span>")
				return

			// Create the pheromones
			if(do_after(H, 3 SECONDS, H, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
				to_chat(H, "<span class='notice'>You produce new pheromones with the message of \"[message_to_encode]\".</span>")
				var/obj/effect/kidan_pheromones/pheromones_to_create = new get_turf(H)
				pheromones_to_create.encoded_message = message_to_encode
				LAZYADD(active_pheromones_current, pheromones_to_create)

				// Add a signal to the new pheromones so it clears its own references when it gets destroyed
				RegisterSignal(pheromones_to_create, COMSIG_QDELETING, PROC_REF(remove_pheromones_from_list))

				// Log the action
				H.create_log(MISC_LOG, "produced pheromones with the message of \"[message_to_encode]\"")
		if("Cancel")
			return

// This handles proper GCing whether we destroyed the pheromones or something else did
/datum/action/innate/produce_pheromones/proc/remove_pheromones_from_list(obj/effect/kidan_pheromones/pheromones)
	SIGNAL_HANDLER

	UnregisterSignal(pheromones, COMSIG_QDELETING)
	LAZYREMOVE(active_pheromones_current, pheromones)

// Clear references if the holder gets destroyed
/datum/action/innate/produce_pheromones/Destroy()
	active_pheromones_current = null
	..()

#undef PHEROMONES_LIFESPAN
#undef PHEROMONES_MAX
