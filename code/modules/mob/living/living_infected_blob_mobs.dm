/mob/living
	var/can_be_blob = FALSE
	var/was_bursted = FALSE
	var/dusted = FALSE

/mob/living/proc/burst_blob_on_die()
	burst_blob_mob()

/mob/living/proc/burst_blob_in_mob()
	if(!ismob(loc))
		return
	burst_blob_mob()

/mob/living/proc/burst_blob_mob()
	if(dusted)
		return
	if(!(mind && SSticker && SSticker.mode && can_be_blob))
		return
	if(mind.special_role == SPECIAL_ROLE_BLOB &&!was_bursted)
		var/datum/antagonist/blob_infected/blob = mind.has_antag_datum(/datum/antagonist/blob_infected)
		blob?.burst_blob(TRUE)

/mob/living/simple_animal
	can_be_blob = TRUE

/mob/living/carbon/human
	can_be_blob = TRUE


/datum/species
	var/can_be_blob = TRUE

/datum/species/machine
	can_be_blob = FALSE

/datum/species/skeleton
	can_be_blob = FALSE

/mob/living/simple_animal/imp
	can_be_blob = FALSE

/mob/living/simple_animal/borer
	can_be_blob = FALSE

/mob/living/simple_animal/demon
	can_be_blob = FALSE

/mob/living/simple_animal/revenant
	can_be_blob = FALSE

/mob/living/simple_animal/bot
	can_be_blob = FALSE

/mob/living/simple_animal/spiderbot
	can_be_blob = FALSE

/mob/living/simple_animal/ascendant_shadowling
	can_be_blob = FALSE

/mob/living/simple_animal/mouse/clockwork
	can_be_blob = FALSE

/mob/living/simple_animal/mouse/blobinfected/proc/get_mind()
	if(mind || !SSticker || !SSticker.mode)
		return
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за мышь, зараженную Блобом?", ROLE_BLOB, TRUE, source = /mob/living/simple_animal/mouse/blobinfected)
	if(!length(candidates))
		log_and_message_admins("There were no players willing to play as a mouse infected with a blob.")
		return
	var/mob/M = pick(candidates)
	key = M.key
	var/datum/antagonist/blob_infected/blob_datum = new
	blob_datum.time_to_burst_h = TIME_TO_BURST_MOUSE_H
	blob_datum.time_to_burst_l = TIME_TO_BURST_MOUSE_H
	mind.add_antag_datum(blob_datum)
	to_chat(src, "<span class='userdanger'>Теперь вы мышь, заражённая спорами Блоба. Найдите какое-нибудь укромное место до того, как вы взорветесь и станете Блобом! Вы можете перемещаться по вентиляции, нажав Alt+ЛКМ на вентиляционном отверстии.</span>")
	log_game("[key] has become blob infested mouse.")
	notify_ghosts("Заражённая мышь появилась в [get_area(src)].", source = src, action = NOTIFY_FOLLOW)


/mob/living/simple_animal/mouse/fluff/clockwork
	can_be_blob = FALSE

/mob/living/simple_animal/pet/dog/corgi/borgi
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/swarmer
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/guardian
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/morph
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/construct
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/clockwork
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/alien
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/asteroid
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/malf_drone
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/statue
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/retaliate/syndirat
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/skeleton/retaliate
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/poison/terror_spider
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/megafauna/ancient_robot
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/megafauna/legion
	can_be_blob = FALSE

/mob/living/simple_animal/hostile/megafauna/swarmer_swarm_beacon
	can_be_blob = FALSE
