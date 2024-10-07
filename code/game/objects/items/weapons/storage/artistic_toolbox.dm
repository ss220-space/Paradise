/obj/item/storage/toolbox/green
	name = "artistic toolbox"
	desc = "A metal container designed to hold various tools. This variety holds art supplies."
	icon_state = "green"
	item_state = "toolbox_green"
	icon = 'icons/goonstation/objects/objects.dmi'
	lefthand_file = 'icons/goonstation/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/items_righthand.dmi'

/obj/item/storage/toolbox/green/memetic
	name = "artistic toolbox"
	desc = "His Grace."
	force = 5
	throwforce = 10
	origin_tech = "combat=4;engineering=4;syndicate=2"
	actions_types = list(/datum/action/item_action/toggle)
	blurry_chance = 8
	var/list/servantlinks = list()
	var/hunger = 0
	var/hunger_level = 0
	var/mob/living/carbon/human/original_owner = null
	var/activated = FALSE

/obj/item/storage/toolbox/green/memetic/ui_action_click(mob/user, datum/action/action, leftclick)
	if(user.HasDisease(/datum/disease/memetic_madness))
		var/obj/item/storage/toolbox/green/memetic/M = user.get_active_hand()
		if(istype(M))
			var/prev_has = HAS_TRAIT_FROM(src, TRAIT_NODROP, HIS_GRACE_TRAIT)
			if(prev_has)
				REMOVE_TRAIT(src, TRAIT_NODROP, HIS_GRACE_TRAIT)
			else
				ADD_TRAIT(src, TRAIT_NODROP, HIS_GRACE_TRAIT)
			to_chat(user, "<span class='warning'>His Grace [prev_has ? "releases from" : "binds to"] your hand!</span>")
	else if(!activated && loc == user)
		if(link_user(user))
			to_chat(user, "<span class='notice'>Call to His Grace again if you wish it bound to your hand!</span>")
	else
		to_chat(user, "<span class='warning'>You can't seem to understand what this does.</span>")


/obj/item/storage/toolbox/green/memetic/attack_hand(mob/living/carbon/user)
	if(!activated && loc == user)
		link_user(user)
		return
	..()

/obj/item/storage/toolbox/green/memetic/proc/link_user(mob/living/carbon/user)
	if(ishuman(user) && !user.HasDisease(/datum/disease/memetic_madness))
		activated = TRUE
		var/datum/disease/memetic_madness/D = new
		D.Contract(user)
		for(var/datum/disease/memetic_madness/DD in user.diseases)
			DD.progenitor = src
			servantlinks.Add(DD)
			break
		force += 4
		throwforce += 4
		SEND_SOUND(user, 'sound/goonstation/effects/screech.ogg')
		shake_camera(user, 20, 1)
		var/acount = 0
		var/amax = rand(10, 15)
		var/up_and_down
		var/asize = 1
		while(acount <= amax)
			up_and_down += "<font size=[asize]>a</font>"
			if(acount > (amax * 0.5))
				asize--
			else
				asize++
			acount++
		to_chat(user, "<span class='warning'>[up_and_down]</span>")
		to_chat(user, "<i><b><font face = Tempus Sans ITC>His Grace accepts thee, spread His will! All who look close to the Enlightened may share His gifts.</font></b></i>")
		original_owner = user
		return TRUE
	return FALSE


/obj/item/storage/toolbox/green/memetic/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/holder))
		add_fingerprint(user)
		var/mob/living/victim = locate() in I.contents
		if(!activated || !victim)
			return ..()
		if(!user.HasDisease(/datum/disease/memetic_madness))
			to_chat(user, span_warning("You can't seem to find the latch to open this."))
			return ATTACK_CHAIN_PROCEED
		if(!victim.stat)
			to_chat(user, span_warning("They're moving too much to feed to His Grace!"))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(span_userdanger("[user] is trying to feed [victim] to [src]!"))
		if(!do_after(user, 3 SECONDS, I, NONE) || !user.HasDisease(/datum/disease/memetic_madness) || !victim.stat || victim.loc != I)
			return ATTACK_CHAIN_PROCEED
		qdel(I)
		user.visible_message(span_userdanger("[user] has fed [victim] to [src]!"))
		to_chat(user, "<i><b><font face = Tempus Sans ITC>You have done well...</font></b></i>")
		consume(victim)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/storage/toolbox/green/memetic/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(!activated || !isliving(grabbed_thing))
		return .
	var/mob/living/victim = grabbed_thing
	if(!grabber.HasDisease(/datum/disease/memetic_madness))
		to_chat(grabber, span_warning("You can't seem to find the latch to open this."))
		return .
	if(!victim.stat && !HAS_TRAIT(victim, TRAIT_RESTRAINED) && !HAS_TRAIT(victim, TRAIT_INCAPACITATED))
		to_chat(grabber, span_warning("They're moving too much to feed to His Grace!"))
		return .
	grabber.visible_message(span_userdanger("[grabber] is trying to feed [victim] to [src]!"))
	if(!do_after(grabber, 3 SECONDS, victim, NONE))
		return .
	if(!grabber.HasDisease(/datum/disease/memetic_madness) || !grabber || !victim || grabber.pulling != victim)
		return .
	if(!victim.stat && !HAS_TRAIT(victim, TRAIT_RESTRAINED) && !HAS_TRAIT(victim, TRAIT_INCAPACITATED))
		return .
	grabber.visible_message(span_userdanger("[grabber] has fed [victim] to [src]!"))
	to_chat(grabber, "<i><b><font face = Tempus Sans ITC>You have done well...</font></b></i>")
	consume(victim)


/obj/item/storage/toolbox/green/memetic/proc/consume(mob/living/L)
	if(!L)
		return
	hunger = 0
	set_hunger_level(new_hunger_level = 0)
	playsound(loc, 'sound/goonstation/misc/burp_alien.ogg', 50, 0)

	if(L != original_owner)
		var/list/equipped_items = L.get_equipped_items(TRUE)
		if(L.l_hand)
			equipped_items += L.l_hand
		if(L.r_hand)
			equipped_items += L.r_hand
		if(equipped_items.len)
			var/obj/item/storage/box/B = new(src)
			B.name = "Box-'[L.real_name]'"
			for(var/obj/item/SI in equipped_items)
				L.drop_transfer_item_to_loc(SI, B, force = TRUE)
			equipped_items.Cut()

	L.forceMove(src)

	L.emote("scream")
	L.death()
	L.ghostize()
	if(L == original_owner)
		L.temporarily_remove_item_from_inventory(src, force = TRUE)
		qdel(L)
		var/obj/item/storage/toolbox/green/fake_toolbox = new(get_turf(src))
		fake_toolbox.desc = "It looks a lot duller than it used to."
		qdel(src)
	else
		force += 5
		throwforce += 5
		qdel(L)


/obj/item/storage/toolbox/green/memetic/Destroy()
	for(var/datum/disease/memetic_madness/D in servantlinks)
		D.cure()

	servantlinks.Cut()
	servantlinks = null
	original_owner = null
	visible_message("<span class='userdanger'>[src] screams!</span>")
	playsound(loc, 'sound/goonstation/effects/screech.ogg', 100, 1)
	return ..()


/obj/item/storage/toolbox/green/memetic/proc/set_hunger_level(new_hunger_level)
	if(hunger_level == new_hunger_level)
		return FALSE

	hunger_level = new_hunger_level
	update_icon(UPDATE_ICON_STATE)
	return TRUE


/datum/disease/memetic_madness
	name = "Memetic Kill Agent"
	max_stages = 4
	stage_prob = 8
	cure_text = "Unknown"
	severity = BIOHAZARD
	curable = FALSE
	can_immunity = FALSE
	virus_heal_resistant = TRUE
	var/obj/item/storage/toolbox/green/memetic/progenitor = null
	var/absorption_applied = FALSE

/datum/disease/memetic_madness/Destroy()
	if(progenitor)
		progenitor.servantlinks.Remove(src)
	progenitor = null
	if(absorption_applied && affected_mob)
		affected_mob.remove_status_effect_absorption(source = name, effect_type = list(STUN, WEAKEN, STAMCRIT, KNOCKDOWN, PARALYZE))
	return ..()

/obj/item/storage/toolbox/green/memetic/update_icon_state()
	icon_state = "green[hunger_level <= 2 ? "" : hunger_level]"

/datum/disease/memetic_madness/stage_act()
	..()
	if(!progenitor) //if someone admin spawns this, cure it right away; this should only ever be given directly from the toolbox itself.
		cure()
		return
	if(progenitor in affected_mob.contents)
		var/update = NONE
		update |= affected_mob.heal_overall_damage(12, 12, updating_health = FALSE, affect_robotic = TRUE)
		update |= affected_mob.heal_damages(tox = 5, oxy = 5, updating_health = FALSE)
		update |= affected_mob.setStaminaLoss(0, FALSE)
		if(update)
			affected_mob.updatehealth()
		affected_mob.AdjustDizzy(-20 SECONDS)
		affected_mob.AdjustDrowsy(-20 SECONDS)
		affected_mob.SetSleeping(0)
		affected_mob.SetSlowed(0)
		affected_mob.SetConfused(0)
		if(!absorption_applied)
			absorption_applied = TRUE
			affected_mob.add_status_effect_absorption(
				source = name,
				effect_type = list(STUN, WEAKEN, STAMCRIT, KNOCKDOWN, PARALYZE),
				priority = 3,
				self_message = span_boldwarning("His Grace protects you!"),
			)
		stage = 1
		switch(progenitor.hunger)
			if(10 to 60)
				if(progenitor.set_hunger_level(new_hunger_level = 1))
					to_chat(affected_mob, "<i><b><font face = Tempus Sans ITC>Feed Me the unclean ones...They will be purified...</font></b></i>")
			if(61 to 120)
				if(progenitor.set_hunger_level(new_hunger_level = 2))
					to_chat(affected_mob, "<i><b><font face = Tempus Sans ITC>I hunger for the flesh of the impure...</font></b></i>")
			if(121 to 210)
				if(progenitor.set_hunger_level(new_hunger_level = 3))
					to_chat(affected_mob, "<i><b><font face = Tempus Sans ITC>The hunger of your Master grows with every passing moment.  Feed Me at once.</font></b></i>")
			if(211 to 399)
				if(progenitor.set_hunger_level(new_hunger_level = 4))
					to_chat(affected_mob, "<i><b><font face = Tempus Sans ITC>His Grace starves in your hands.  Feed Me the unclean or suffer.</font></b></i>")
			if(400 to INFINITY)
				affected_mob.visible_message("<span class='userdanger'>[progenitor] consumes [affected_mob] whole!</span>")
				progenitor.consume(affected_mob)
				return

		progenitor.hunger += min(max((progenitor.force / 10), 1), 10)

	else
		if(absorption_applied)
			absorption_applied = FALSE
			affected_mob.remove_status_effect_absorption(source = name, effect_type = list(STUN, WEAKEN, STAMCRIT, KNOCKDOWN, PARALYZE))

	if(stage == 4)
		if(get_dist(get_turf(progenitor), get_turf(affected_mob)) <= 7)
			stage = 1
			return
		if(prob(4))
			to_chat(affected_mob, "<span class='danger'>You are too far from His Grace...</span>")
			affected_mob.adjustToxLoss(5)
		else if(prob(6))
			to_chat(affected_mob, "<span class='danger'>You feel weak.</span>")
			affected_mob.adjustBruteLoss(5)

		if(ismob(progenitor.loc))
			progenitor.hunger++
