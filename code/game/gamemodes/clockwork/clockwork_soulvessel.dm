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

/obj/item/mmi/robotic_brain/clockwork/proc/try_to_transfer(mob/living/target)
	for(var/obj/item/I in target)
		target.unEquip(I)
	if(target.client && target.ghost_can_reenter())
		transfer_personality(target)
		to_chat(target, "<span class='clocklarge'><b>\"You belong to me now.\"</b></span>")
		target.dust()
	else
		target.dust()
		icon_state = searching_icon
		searching = TRUE
		var/list/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Servant of Ratvar?", ROLE_CLOCKER, FALSE, poll_time = 10 SECONDS, source = /obj/item/mmi/robotic_brain/clockwork)
		if(candidates.len)
			transfer_personality(pick(candidates))
		reset_search()

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

		var/mob/living/carbon/brain/b_mob
		var/obj/item/mmi/robotic_brain/brain = src
		var/obj/item/mmi/robotic_brain/clockwork/vessel = O
		b_mob = brain.brainmob

		if(vessel.brainmob.key)
			to_chat(user, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
			return
		if(!(b_mob && b_mob.key))
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

		if(do_after(user, 40, target = brain))
			if(vessel.searching)
				to_chat(user, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
				return
			user.visible_message("<span class='warning'>[user] pressed [vessel] through [b_mob]'s brain and extracted something!", \
			"<span class='clock'>You extracted [b_mob]'s consciousness, trapping it in the soul vessel.")
			vessel.try_to_transfer(b_mob)
			vessel.searching = TRUE
			qdel(brain)
			return TRUE
		return

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
		return
	..()

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

	var/mob/living/carbon/brain/b_mob
	var/obj/item/organ/internal/brain/brain = src
	var/obj/item/mmi/robotic_brain/clockwork/vessel = O
	b_mob = brain.brainmob

	if(vessel.brainmob.key)
		to_chat(user, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
		return
	if(!(b_mob && b_mob.key))
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

	if(do_after(user, 40, target = brain))
		if(vessel.searching)
			to_chat(user, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
			return
		user.visible_message("<span class='warning'>[user] pressed [vessel] through [b_mob]'s brain and extracted something!", \
		"<span class='clock'>You extracted [b_mob]'s consciousness, trapping it in the soul vessel.")
		vessel.try_to_transfer(b_mob)
		vessel.searching = TRUE
		qdel(brain)
		return TRUE
	return

/obj/item/mmi/robotic_brain/clockwork/attack(mob/living/M, mob/living/user, def_zone)
	if(!ishuman(M))
		return ..()
	if(!isclocker(user))
		user.Weaken(5)
		user.emote("scream")
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		to_chat(user, "<span class='clocklarge'>\"Don't even try.\"</span>")
		return

	if(M == user)
		return
	if(brainmob.key)
		to_chat(user, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
		return
	var/mob/living/carbon/human/H = M
	if(!(H.client && H.ghost_can_reenter()))
		to_chat(user, "<span class='clock'>\"This body has no soul to catch.\"</span>")
		return
	if(jobban_isbanned(M, ROLE_CLOCKER) || jobban_isbanned(M, ROLE_SYNDICATE))
		to_chat(user, "<span class='warning'>A mysterious force prevents you from claiming [M]'s mind.</span>")
		return
	if(H.stat == CONSCIOUS)
		to_chat(user, "<span class='warning'>[H] must be dead or unconscious for you to claim [H.p_their()] mind!</span>")
		return
	if(H.has_brain_worms())
		to_chat(user, "<span class='warning'>[H] is corrupted by an alien intelligence and cannot claim [H.p_their()] mind!</span>")
		return
	if(!H.get_int_organ(/obj/item/organ/internal/brain))
		if(!H.get_int_organ(/obj/item/mmi/robotic_brain))
			to_chat(user, "<span class='warning'>[H] has no brain, and thus no mind to claim!</span>")
			return
	if(searching)
		to_chat(user, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
		return

	user.visible_message("<span class='warning'>[user] starts pressing [src] to [H]'s body, ripping through the flesh</span>", \
	"<span class='clock'>You start extracting [H]'s consciousness from [H.p_their()] body.</span>")

	if(do_after(user, 40, target = H))
		user.visible_message("<span class='warning'>[user] pressed [src] through [H]'s body and extracted the brain!", \
		"<span class='clock'>You extracted [H]'s consciousness, trapping it in the soul vessel.")
		if(searching)
			to_chat(user, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
			return
		searching = TRUE
		try_to_transfer(H)
	return
