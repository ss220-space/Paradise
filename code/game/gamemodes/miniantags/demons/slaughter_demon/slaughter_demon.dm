/mob/living/simple_animal/demon/slaughter
	name = "slaughter demon"
	real_name = "slaughter demon"
	desc = "A large, menacing creature covered in armored black scales. You should run."
	speak = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri", "orkan", "allaq")
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	deathmessage = "screams in anger as it collapses into a puddle of viscera!"
	loot = list(/obj/effect/decal/cleanable/blood/innards, /obj/effect/decal/cleanable/blood, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic, /obj/item/organ/internal/heart/demon/slaughter)
	var/feast_sound = 'sound/misc/demon_consume.ogg'
	var/boost = 0
	var/devoured = 0

	var/list/consumed_mobs = list()
	var/list/nearby_mortals = list()

	var/cooldown = 0
	var/gorecooldown = 0

	playstyle_string = "<B>You are the Slaughter Demon, a terrible creature from another existence. You have a single desire: to kill.  \
						You may use the blood crawl icon when on blood pools to travel through them, appearing and dissapearing from the station at will. \
						Pulling a dead or critical mob while you enter a pool will pull them in with you, allowing you to feast. \
						You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. </B>"


/mob/living/simple_animal/demon/slaughter/Initialize(mapload)
	. = ..()
	remove_from_all_data_huds()
	ADD_TRAIT(src, TRAIT_BLOODCRAWL_EAT, TRAIT_BLOODCRAWL_EAT)
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/slaughter))
		bloodspell.phased = TRUE


/mob/living/simple_animal/demon/slaughter/Destroy()
	// Only execute the below if we successfully died
	for(var/mob/living/M in consumed_mobs)
		release_consumed(M)
	. = ..()


/mob/living/simple_animal/demon/slaughter/Life(seconds, times_fired)
	..()
	if(boost < world.time)
		speed = 1
	else
		speed = 0


/mob/living/simple_animal/demon/slaughter/attempt_objectives()
	if(!..())
		return

	var/list/messages = list()
	messages.Add(playstyle_string)
	messages.Add("<b><span class ='notice'>You are not currently in the same plane of existence as the station. Use the blood crawl action at a blood pool to manifest.</span></b>")
	src << 'sound/misc/demon_dies.ogg'
	if(vialspawned)
		return

	var/datum/objective/slaughter/objective = new
	var/datum/objective/demonFluff/fluffObjective = new
	objective.owner = mind
	fluffObjective.owner = mind
	//Paradise Port:I added the objective for one spawned like this
	mind.objectives += objective
	mind.objectives += fluffObjective
	messages.Add(mind.prepare_announce_objectives(FALSE))
	messages.Add("<span class='motd'>С полной информацией вы можете ознакомиться на вики: <a href=\"https://wiki.ss220.space/index.php/Slaughter_Demon\">Демон резни</a></span>")
	to_chat(src, chat_box_red(messages.Join("<br>")))



/obj/effect/decal/cleanable/blood/innards
	icon = 'icons/obj/surgery.dmi'
	icon_state = "innards"
	name = "pile of viscera"
	desc = "A repulsive pile of guts and gore."


/mob/living/simple_animal/demon/slaughter/proc/release_consumed(mob/living/M)
	M.forceMove(get_turf(src))


// Cult slaughter demon
/mob/living/simple_animal/demon/slaughter/cult //Summoned as part of the cult objective "Bring the Slaughter"
	name = "harbinger of the slaughter"
	real_name = "harbinger of the Slaughter"
	desc = "An awful creature from beyond the realms of madness."
	maxHealth = 500
	health = 500
	melee_damage_upper = 60
	melee_damage_lower = 60
	environment_smash = ENVIRONMENT_SMASH_RWALLS //Smashes through EVERYTHING - r-walls included
	faction = list("cult")
	playstyle_string = "<b><span class='userdanger'>You are a Harbinger of the Slaughter.</span> Brought forth by the servants of Nar'Sie, you have a single purpose: slaughter the heretics \
	who do not worship your master. You may use the ability 'Blood Crawl' near a pool of blood to enter it and become incorporeal. Using the ability again near a blood pool will allow you \
	to emerge from it. You are fast, powerful, and almost invincible. By dragging a dead or unconscious body into a blood pool with you, you will consume it after a time and fully regain \
	your health. You may use the ability 'Sense Victims' in your Cultist tab to locate a random, living heretic.</span></b>"


/mob/living/simple_animal/demon/slaughter/cult/attempt_objectives()
	return


/obj/effect/proc_holder/spell/sense_victims
	name = "Sense Victims"
	desc = "Sense the location of heretics"
	base_cooldown = 0
	clothes_req = FALSE
	human_req = FALSE
	cooldown_min = 0
	overlay = null
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_cult"
	panel = "Demon"


/obj/effect/proc_holder/spell/sense_victims/create_new_targeting()
	return new /datum/spell_targeting/alive_mob_list


/obj/effect/proc_holder/spell/sense_victims/valid_target(mob/living/target, user)
	return target.stat == CONSCIOUS && target.key && !iscultist(target) // Only conscious, non cultist players


/obj/effect/proc_holder/spell/sense_victims/cast(list/targets, mob/user)
	var/mob/living/victim = targets[1]
	to_chat(victim, span_userdanger("You feel an awful sense of being watched..."))
	victim.Stun(6 SECONDS) //HUE
	var/area/A = get_area(victim)
	if(!A)
		to_chat(user, span_warning("You could not locate any sapient heretics for the Slaughter."))
		return
	to_chat(user, span_danger("You sense a terrified soul at [A]. <b>Show [A.p_them()] the error of [A.p_their()] ways.</b>"))


/mob/living/simple_animal/demon/slaughter/cult/Initialize(mapload)
	. = ..()
	spawn(0.5 SECONDS)
		var/list/demon_candidates = SSghost_spawns.poll_candidates("Do you want to play as a slaughter demon?", ROLE_DEMON, TRUE, 10 SECONDS, source = /mob/living/simple_animal/demon/slaughter/cult)
		if(!demon_candidates.len)
			log_game("[src] has failed to spawn, because no one enrolled.")
			visible_message(span_warning("[src] disappears in a flash of red light!"))
			qdel(src)
			return
		var/mob/M = pick(demon_candidates)
		var/mob/living/simple_animal/demon/slaughter/cult/S = src
		if(!M || !M.client)
			log_game("[src] has failed to spawn, because enrolled player is missing.")
			visible_message(span_warning("[src] disappears in a flash of red light!"))
			qdel(src)
			return
		var/client/C = M.client

		S.key = C.key
		S.mind.assigned_role = "Harbinger of the Slaughter"
		S.mind.special_role = "Harbinger of the Slaughter"
		to_chat(S, playstyle_string)
		SSticker.mode.add_cultist(S.mind)
		var/obj/effect/proc_holder/spell/sense_victims/SV = new
		AddSpell(SV)
		var/datum/objective/new_objective = new /datum/objective
		new_objective.owner = S.mind
		new_objective.explanation_text = "Bring forth the Slaughter to the nonbelievers."
		S.mind.objectives += new_objective
		var/list/messages = list(S.mind.prepare_announce_objectives(FALSE))
		to_chat(S, chat_box_red(messages.Join("<br>")))
		log_game("[S.key] has become Slaughter demon.")


/**
 * The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl.
 */
/obj/item/organ/internal/heart/demon/slaughter/attack_self(mob/living/user)
	..()

	// Eating the heart for the first time. Gives basic bloodcrawling. This is the only time we need to insert the heart.
	if(!HAS_TRAIT(user, TRAIT_BLOODCRAWL))
		user.visible_message(span_warning("[user]'s eyes flare a deep crimson!"), \
						 span_userdanger("You feel a strange power seep into your body... you have absorbed the demon's blood-travelling powers!"))
		ADD_TRAIT(user, TRAIT_BLOODCRAWL, "bloodcrawl")
		user.drop_from_active_hand()
		insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E.
		return TRUE

	// Eating a 2nd heart. Gives the ability to drag people into blood and eat them.
	if(HAS_TRAIT(user, TRAIT_BLOODCRAWL))
		to_chat(user, "You feel differ-[span_warning(" CONSUME THEM! ")]")
		ADD_TRAIT(user, TRAIT_BLOODCRAWL_EAT, TRAIT_BLOODCRAWL_EAT)
		qdel(src) // Replacing their demon heart with another demon heart is pointless, just delete this one and return.
		return TRUE

	// Eating any more than 2 demon hearts does nothing.
	to_chat(user, span_warning("...and you don't feel any different."))
	qdel(src)


/obj/item/organ/internal/heart/demon/slaughter/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	M?.mind?.AddSpell(new /obj/effect/proc_holder/spell/bloodcrawl(null))


/obj/item/organ/internal/heart/demon/slaughter/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(M.mind)
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL, TRAIT_BLOODCRAWL)
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL_EAT, TRAIT_BLOODCRAWL_EAT)
		M.mind.RemoveSpell(/obj/effect/proc_holder/spell/bloodcrawl)
	. = ..()


/**
 * LAUGHTER DEMON
 */
/mob/living/simple_animal/demon/slaughter/laughter
	// The laughter demon! It's everyone's best friend! It just wants to hug
	// them so much, it wants to hug everyone at once!
	name = "laughter demon"
	real_name = "laughter demon"
	desc = "A large, adorable creature covered in armor with pink bows."
	speak_emote = list("giggles", "titters", "chuckles")
	emote_hear = list("gaffaws", "laughs")
	response_help  = "hugs"
	attacktext = "неистово щекочет"
	maxHealth = 175
	health = 175
	melee_damage_lower = 25
	melee_damage_upper = 25

	attack_sound = 'sound/items/bikehorn.ogg'
	feast_sound = 'sound/spookoween/scary_horn2.ogg'
	death_sound = 'sound/misc/sadtrombone.ogg'

	icon_state = "bowmon"
	icon_living = "bowmon"
	deathmessage = "fades out, as all of its friends are released from its prison of hugs."
	loot = list(/mob/living/simple_animal/pet/cat/kitten{name = "Laughter"})


/mob/living/simple_animal/demon/slaughter/laughter/release_consumed(mob/living/M)
	if(M.revive())
		M.grab_ghost(force = TRUE)
		playsound(get_turf(src), feast_sound, 50, 1, -1)
		to_chat(M, span_clown("You leave [src]'s warm embrace, and feel ready to take on the world."))
	..(M)


//Objectives and helpers.

//Objective info, Based on Reverent mini Atang
/datum/objective/slaughter
	needs_target = FALSE
	var/targetKill = 10


/datum/objective/slaughter/New()
	targetKill = rand(10,20)
	explanation_text = "Devour [targetKill] mortals."
	..()


/datum/objective/slaughter/check_completion()
	var/kill_count = 0
	for(var/datum/mind/player in get_owners())
		if(!isslaughterdemon(player.current) || QDELETED(player.current))
			continue

		var/mob/living/simple_animal/demon/slaughter/demon = player.current
		kill_count += demon.devoured

	if(kill_count >= targetKill)
		return TRUE

	return FALSE


/datum/objective/demonFluff
	needs_target = FALSE


/datum/objective/demonFluff/New()
	find_target()
	var/targetname = "someone"
	if(target?.current)
		targetname = target.current.real_name
	var/list/explanation_texts = list("Spread blood all over the bridge.", \
									 "Spread blood all over the brig.", \
									 "Spread blood all over the chapel.", \
									 "Kill or Destroy all Janitors or Sanitation bots.", \
									 "Spare a few after striking them... make them bleed before the harvest.", \
									 "Hunt those that try to hunt you first.", \
									 "Hunt those that run away from you in fear", \
									 "Show [targetname] the power of blood.", \
									 "Drive [targetname] insane with demonic whispering."
									 )

	// As this is a fluff objective, we don't need a target, so we want to null it out.
	// We don't want the demon getting a "Time for Plan B" message if the target cryos.
	target = null
	explanation_text = pick(explanation_texts)
	..()


/datum/objective/demonFluff/check_completion()
	return TRUE
