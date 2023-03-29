// Soul vessel (Posi Brain)
/obj/item/mmi/robotic_brain/clockwork
	name = "soul vessel"
	desc = "A heavy brass cube, three inches to a side, with a single protruding cogwheel."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "soul_vessel"
	blank_icon = "soul_vessel"
	searching_icon = "soul_vessel_search"
	occupied_icon = "soul_vessel_occupied"
	requires_master = FALSE
	ejected_flavor_text = "brass cube"
	dead_icon = "soul_vessel"
	clock = TRUE
	var/obj/item/victim_brain = null

/obj/item/mmi/robotic_brain/clockwork/proc/get_ghost(mob/living/M, mob/user)
	var/mob/dead/observer/chosen_ghost
	if(M.ghost_can_reenter())
		for(var/mob/dead/observer/ghost in GLOB.player_list)
			if(ghost.mind && ghost.mind.current == M && ghost.client)
				chosen_ghost = ghost
				break
	if(!chosen_ghost)
		icon_state = searching_icon
		searching = TRUE
		to_chat(user, "<span class='clocklarge'><b>Capture failed!</b></span> The soul has already fled its mortal frame. You attempt to bring it back...")
		var/list/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Servant of Ratvar?", ROLE_CLOCKER, FALSE, poll_time = 10 SECONDS, source = /obj/item/mmi/robotic_brain/clockwork)
		if(length(candidates))
			chosen_ghost = pick(candidates)
		reset_search()
	if(!M)
		return FALSE
	if(!chosen_ghost)
		to_chat(user, "<span class='danger'>There were no spirits willing to become a Servant of Ratvar.</span>")
		return FALSE
	if(brainmob.key)
		return FALSE
	M.ckey = chosen_ghost.ckey
	transfer_personality(M)
	return TRUE

/obj/item/mmi/robotic_brain/clockwork/proc/try_to_transfer(mob/living/target, mob/user)
	if(ishuman(target))
		for(var/obj/item/I in target)
			target.unEquip(I)
	var/mob/living/living = target
	if(victim_brain)
		if(istype(victim_brain, /obj/item/mmi/robotic_brain))
			var/obj/item/mmi/robotic_brain/rbrain = victim_brain
			living = rbrain.brainmob
		if(istype(victim_brain, /obj/item/mmi/robotic_brain))
			var/obj/item/organ/internal/brain/obrain = victim_brain
			living = obrain.brainmob
	if(!victim_brain && living.stat == CONSCIOUS)
		to_chat(user, "<span class='warning'>[living] must be dead or unconscious for you to claim [living.p_their()] mind!</span>")
		return
	if(living.client == null)
		living.dust()
		get_ghost(living, user)
	else
		if(brainmob.key)
			to_chat(user, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
			return
		living.dust()
		transfer_personality(living)
		to_chat(living, "<span class='clocklarge'><b>\"You belong to me now.\"</b></span>")
	if(victim_brain)
		QDEL_NULL(victim_brain)

/obj/item/mmi/robotic_brain/clockwork/transfer_personality(mob/candidate)
	searching = FALSE
	brainmob.key = candidate.key
	brainmob.name = "[pick(list("Nycun", "Oenib", "Havsbez", "Ubgry", "Fvreen"))]-[rand(10, 99)]"
	brainmob.real_name = brainmob.name
	name = "[src] ([brainmob.name])"
	brainmob.mind.assigned_role = "Soul Vessel Cube"
	visible_message("<span class='notice'>[src] chimes quietly.</span>")
	become_occupied(occupied_icon)
	if(SSticker.mode.add_clocker(brainmob.mind))
		brainmob.create_log(CONVERSION_LOG, "[brainmob.mind] been converted by [src.name]")

/obj/item/mmi/robotic_brain/clockwork/attack_self(mob/living/user)
	if(!isclocker(user))
		to_chat(user, "<span class='warning'>You fiddle around with [src], to no avail.</span>")
		return
	if(brainmob.key)
		to_chat(user, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
		do_sparks(5, TRUE, user)
	else
		to_chat(user, "<span class='warning'>You have to find a dead body to fill a vessel.</span>")

/obj/item/mmi/robotic_brain/attackby(obj/item/O, mob/user)
	// capturing robotic brains
	if(istype(O, /obj/item/mmi/robotic_brain/clockwork))
		if(istype(src, /obj/item/mmi/robotic_brain/clockwork))
			return
		if(!isclocker(user))
			user.Weaken(5)
			user.emote("scream")
			to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
			to_chat(user, "<span class='clocklarge'>\"Don't even try.\"</span>")
			return
		if(isdrone(user))
			to_chat(user, "<span class='warning'>You are not dexterous enough to do this!</span>")
			return

		var/mob/living/carbon/brain/b_mob
		var/obj/item/mmi/robotic_brain/brain = src
		var/obj/item/mmi/robotic_brain/clockwork/vessel = O
		b_mob = brain.brainmob

		if(vessel.brainmob.key)
			to_chat(user, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
			return
		if(!length(brain.client_mobs_in_contents))
			to_chat(user, "<span class='clock'>\"This brain has no soul to catch.\"</span>")
			return
		if(jobban_isbanned(b_mob, ROLE_CLOCKER) || jobban_isbanned(b_mob, ROLE_SYNDICATE))
			to_chat(user, "<span class='warning'>A mysterious force prevents you from claiming [b_mob]'s mind.</span>")
			return
		if(vessel.searching)
			to_chat(user, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
			return

		playsound(brain, 'sound/hallucinations/veryfar_noise.ogg', 40, TRUE)
		user.visible_message("<span class='warning'>[user] starts pressing [vessel] to [b_mob]'s brain, ripping through the cables and components</span>", \
		"<span class='clock'>You start extracting [b_mob]'s consciousness from [b_mob.p_their()] brain.</span>")
		do_sparks(5, TRUE, brain)

		if(do_after(user, 40, target = brain))
			if(vessel.searching)
				to_chat(user, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
				return
			user.visible_message("<span class='warning'>[user] pressed [vessel] through [b_mob]'s brain and extracted something!", \
			"<span class='clock'>You extracted [b_mob]'s consciousness, trapping it in the soul vessel.")
			vessel.victim_brain = brain
			vessel.try_to_transfer(b_mob, user)
			return TRUE
		return FALSE

	// chaplain purifying
	if(istype(O, /obj/item/storage/bible) && istype(src, /obj/item/mmi/robotic_brain/clockwork) && !isclocker(user) && user.mind.isholy)
		to_chat(user, "<span class='notice'>You begin to exorcise [src].</span>")
		playsound(src, 'sound/hallucinations/veryfar_noise.ogg', 40, TRUE)
		if(do_after(user, 40, target = src))
			var/obj/item/mmi/robotic_brain/positronic/purified = new(get_turf(src))
			if(brainmob.key)
				SSticker.mode.remove_clocker(brainmob.mind)
				purified.transfer_identity(brainmob)
			qdel(src)
			return TRUE
		return FALSE
	. = ..()

/obj/item/organ/internal/brain/attackby(obj/item/O, mob/user)
	// capturing organic brains
	if(!istype(O, /obj/item/mmi/robotic_brain/clockwork))
		return ..()
	if(!isclocker(user))
		user.Weaken(5)
		user.emote("scream")
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		to_chat(user, "<span class='clocklarge'>\"Don't even try.\"</span>")
		return
	if(isdrone(user))
		to_chat(user, "<span class='warning'>You are not dexterous enough to do this!</span>")
		return

	var/mob/living/carbon/brain/b_mob
	var/obj/item/organ/internal/brain/brain = src
	var/obj/item/mmi/robotic_brain/clockwork/vessel = O
	b_mob = brain.brainmob

	if(vessel.brainmob.key)
		to_chat(user, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
		return
	if(!length(brain.client_mobs_in_contents))
		to_chat(user, "<span class='clock'>\"This brain has no soul to catch.\"</span>")
		return
	if(jobban_isbanned(b_mob, ROLE_CLOCKER) || jobban_isbanned(b_mob, ROLE_SYNDICATE))
		to_chat(user, "<span class='warning'>A mysterious force prevents you from claiming [b_mob]'s mind.</span>")
		return
	if(vessel.searching)
		to_chat(user, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
		return

	playsound(brain, 'sound/hallucinations/veryfar_noise.ogg', 40, TRUE)
	user.visible_message("<span class='warning'>[user] starts pressing [vessel] to [b_mob]'s brain, ripping through its tissue</span>", \
	"<span class='clock'>You start extracting [b_mob]'s consciousness from [b_mob.p_their()] brain.</span>")
	do_sparks(5, TRUE, brain)

	if(do_after(user, 40, target = brain))
		if(vessel.searching)
			to_chat(user, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
			return
		user.visible_message("<span class='warning'>[user] pressed [vessel] through [b_mob]'s brain and extracted something!", \
		"<span class='clock'>You extracted [b_mob]'s consciousness, trapping it in the soul vessel.")
		vessel.victim_brain = brain
		vessel.try_to_transfer(b_mob, user)
		return TRUE
	return FALSE

/obj/item/mmi/robotic_brain/clockwork/attack(mob/living/M, mob/living/user, def_zone)
	// catching souls of dead/unconscious carbons and robots
	if(!isclocker(user))
		user.Weaken(5)
		user.emote("scream")
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		to_chat(user, "<span class='clocklarge'>\"Don't even try.\"</span>")
		return
	if(isanimal(M) || isAI(M) || ispAI(M))
		return ..()

	if(M == user)
		return
	if(isdrone(user))
		to_chat(user, "<span class='warning'>You are not dexterous enough to do this!</span>")
		return
	if(brainmob.key)
		to_chat(user, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
		return
	if(!length(M.client_mobs_in_contents))
		to_chat(user, "<span class='clock'>\"This body has no soul to catch.\"</span>")
		return
	if(jobban_isbanned(M, ROLE_CLOCKER) || jobban_isbanned(M, ROLE_SYNDICATE))
		to_chat(user, "<span class='warning'>A mysterious force prevents you from claiming [M]'s mind.</span>")
		return
	if(M.stat == CONSCIOUS)
		to_chat(user, "<span class='warning'>[M] must be dead or unconscious for you to claim [M.p_their()] mind!</span>")
		return
	if(iscarbon(M) && M.has_brain_worms())
		to_chat(user, "<span class='warning'>[M] is corrupted by an alien intelligence and cannot claim [M.p_their()] mind!</span>")
		return
	if(isrobot(M) && !(locate(/obj/item/mmi/robotic_brain) in M))
		to_chat(user, "<span class='warning'>[M] has no brain, and thus no mind to claim!</span>")
		return
	if(searching)
		to_chat(user, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
		return

	user.visible_message("<span class='warning'>[user] starts pressing [src] to [M]'s body, ripping through the surface</span>", \
	"<span class='clock'>You start extracting [M]'s consciousness from [M.p_their()] body.</span>")
	do_sparks(5, TRUE, M)

	if(do_after(user, 90, target = M))
		user.visible_message("<span class='warning'>[user] pressed [src] through [M]'s body and extracted the brain!", \
		"<span class='clock'>You extracted [M]'s consciousness, trapping it in the soul vessel.")
		if(searching)
			to_chat(user, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
			return
		try_to_transfer(M, user)
		return TRUE
	return FALSE
