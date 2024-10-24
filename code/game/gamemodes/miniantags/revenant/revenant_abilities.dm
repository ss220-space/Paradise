///Harvest
/mob/living/simple_animal/revenant/ClickOn(atom/A, params) //Copypaste from ghost code - revenants can't interact with the world directly.

	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return

	if(modifiers["shift"])
		ShiftClickOn(A)
		return

	if(modifiers["alt"])
		SEND_SIGNAL(A, COMSIG_CLICK_ALT, src)
		AltClickOn(A)
		return

	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(world.time <= next_move)
		return

	A.attack_ghost(src)
	if(ishuman(A) && in_range(src, A))
		if(isLivingSSD(A) && client.send_ssd_warning(A)) //Do NOT Harvest SSD people unless you accept the warning
			return

		Harvest(A)


/mob/living/simple_animal/revenant/proc/Harvest(mob/living/carbon/human/target)
	if(!castcheck(0))
		return

	if(draining)
		to_chat(src, span_revenwarning("You are already siphoning the essence of a soul!"))
		return

	var/mob_UID = target.UID()
	if(mob_UID in drained_mobs)
		to_chat(src, span_revenwarning("[target]'s soul is dead and empty."))
		return

	if(!target.stat)
		to_chat(src, span_revennotice("This being's soul is too strong to harvest."))
		if(prob(10))
			to_chat(target, "You feel as if you are being watched.")
		return

	draining = TRUE
	essence_drained = rand(15, 20)
	to_chat(src, span_revennotice("You search for the soul of [target]."))

	if(do_after(src, 1 SECONDS, target, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM)) //did they get deleted in that second?
		if(target.ckey)
			to_chat(src, span_revennotice("Their soul burns with intelligence."))
			essence_drained += rand(20, 30)

		if(target.stat != DEAD)
			to_chat(src, span_revennotice("Their soul blazes with life!"))
			essence_drained += rand(40, 50)
		else
			to_chat(src, span_revennotice("Their soul is weak and faltering."))

		if(do_after(src, 2 SECONDS, target, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM)) //did they get deleted NOW?
			switch(essence_drained)
				if(1 to 30)
					to_chat(src, span_revennotice("[target] will not yield much essence. Still, every bit counts."))
				if(30 to 70)
					to_chat(src, span_revennotice("[target] will yield an average amount of essence."))
				if(70 to 90)
					to_chat(src, span_revenboldnotice("Such a feast! [target] will yield much essence to you."))
				if(90 to INFINITY)
					to_chat(src, span_revenbignotice("Ah, the perfect soul. [target] will yield massive amounts of essence to you."))
			if(do_after(src, 2 SECONDS, target, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM)) //how about now
				if(!target.stat)
					to_chat(src, span_revenwarning("They are now powerful enough to fight off your draining."))
					to_chat(target, span_boldannounceic("You feel something tugging across your body before subsiding."))
					draining = FALSE
					return //hey, wait a minute...

				to_chat(src, span_revenminor("You begin siphoning essence from [target]'s soul."))
				if(target.stat != DEAD)
					to_chat(target, span_warning("You feel a horribly unpleasant draining sensation as your grip on life weakens..."))

				reveal(27)
				stun(27)
				target.visible_message(span_warning("[target] suddenly rises slightly into the air, [target.p_their()] skin turning an ashy gray."))
				target.Beam(src,icon_state="drain_life",icon='icons/effects/effects.dmi',time=26)

				if(do_after(src, 3 SECONDS, target, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM)) //As one cannot prove the existance of ghosts, ghosts cannot prove the existance of the target they were draining.
					change_essence_amount(essence_drained, 0, target)
					if(essence_drained > 90)
						essence_regen_cap += 25
						perfectsouls += 1
						to_chat(src, span_revenboldnotice("The perfection of [target]'s soul has increased your maximum essence level. Your new maximum essence is [essence_regen_cap]."))
					to_chat(src, span_revennotice("[target]'s soul has been considerably weakened and will yield no more essence for the time being."))
					target.visible_message(span_warning("[target] slumps onto the ground."), \
										span_revenwarning("Violets lights, dancing in your vision, getting clo--"))
					drained_mobs.Add(mob_UID)
					add_attack_logs(src, target, "revenant harvested soul")
					target.death()
				else
					to_chat(src, span_revenwarning("[target ? "[target] has":"They have"] been drawn out of your grasp. The link has been broken."))
					draining = 0
					essence_drained = 0
					if(target) //Wait, target is WHERE NOW?
						target.visible_message(span_warning("[target] slumps onto the ground."), \
											span_revenwarning("Violets lights, dancing in your vision, receding--"))
					return
			else
				to_chat(src, span_revenwarning("You are not close enough to siphon [target ? "[target]'s":"their"] soul. The link has been broken."))
				draining = FALSE
				essence_drained = 0
				return

	draining = FALSE
	essence_drained = 0


/**
 * Toggle night vision: lets the revenant toggle its night vision
 */
/obj/effect/proc_holder/spell/night_vision/revenant
	base_cooldown = 0
	message = span_revennotice("You toggle your night vision.")
	action_icon_state = "r_nightvision"
	action_background_icon_state = "bg_revenant"


//Transmit: the revemant's only direct way to communicate. Sends a single message silently to a single mob
/obj/effect/proc_holder/spell/revenant_transmit
	name = "Transmit"
	desc = "Telepathically transmits a message to the target."
	base_cooldown = 0
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_revenant"


/obj/effect/proc_holder/spell/revenant_transmit/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living
	return T


/obj/effect/proc_holder/spell/revenant_transmit/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	for(var/mob/living/M in targets)
		spawn(0)
			var/msg = tgui_input_text(usr, "What do you wish to tell [M]?", null, "")

			if(!msg)
				cooldown_handler.revert_cast()
				return

			log_say("(REVENANT to [key_name(M)]) [msg]", user)
			to_chat(user, "[span_revenboldnotice("You transmit to [M]:")] [span_revennotice(msg)]")
			to_chat(M, "[span_revenboldnotice("An alien voice resonates from all around...")] [span_italics(msg)]")


/obj/effect/proc_holder/spell/aoe/revenant
	name = "Spell"
	clothes_req = FALSE
	human_req = FALSE
	action_background_icon_state = "bg_revenant"
	/// How long it reveals the revenant in deciseconds
	var/reveal = 8 SECONDS
	/// How long it stuns the revenant in deciseconds
	var/stun = 2 SECONDS
	/// If it's locked and needs to be unlocked before use
	var/locked = TRUE
	/// How much essence it costs to unlock
	var/unlock_amount = 100
	/// How much essence it costs to use
	var/cast_amount = 50


/obj/effect/proc_holder/spell/aoe/revenant/New()
	..()
	if(locked)
		name = "[initial(name)] ([unlock_amount]E)"
	else
		name = "[initial(name)] ([cast_amount]E)"


/obj/effect/proc_holder/spell/aoe/revenant/revert_cast(mob/user)
	. = ..()
	to_chat(user, span_revennotice("Your ability wavers and fails!"))
	var/mob/living/simple_animal/revenant/R = user
	R?.essence += cast_amount //refund the spell and reset


/obj/effect/proc_holder/spell/aoe/revenant/can_cast(mob/living/simple_animal/revenant/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.inhibited)
		return FALSE

	if(cooldown_handler.is_on_cooldown())
		return FALSE

	if(locked)
		if(user.essence <= unlock_amount)
			return FALSE

	if(user.essence <= cast_amount)
		return FALSE

	return TRUE


/obj/effect/proc_holder/spell/aoe/revenant/proc/attempt_cast(mob/living/simple_animal/revenant/user = usr)
	if(locked)
		if(!user.castcheck(-unlock_amount))
			cooldown_handler.revert_cast()
			return FALSE

		name = "[initial(name)] ([cast_amount]E)"
		to_chat(user, span_revenwarning("You have unlocked <B>[initial(name)]</B>!"))

		locked = FALSE
		cooldown_handler.revert_cast()

		return FALSE

	if(!user.castcheck(-cast_amount))
		cooldown_handler.revert_cast()
		return FALSE

	name = "[initial(name)] ([cast_amount]E)"
	user.reveal(reveal)
	user.stun(stun)

	if(action)
		action.UpdateButtonIcon()

	return TRUE


//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/obj/effect/proc_holder/spell/aoe/revenant/overload
	name = "Overload Lights"
	desc = "Directs a large amount of essence into nearby electrical lights, causing lights to shock those nearby."
	base_cooldown = 20 SECONDS
	stun = 3 SECONDS
	cast_amount = 45
	var/shock_range = 2
	var/shock_damage = 20
	action_icon_state = "r_overload_lights"
	aoe_range = 5


/obj/effect/proc_holder/spell/aoe/revenant/overload/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	T.allowed_type = /obj/machinery/light
	return T


/obj/effect/proc_holder/spell/aoe/revenant/overload/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/obj/machinery/light/L as anything in targets)
			INVOKE_ASYNC(src, PROC_REF(shock_lights), L, user)


/obj/effect/proc_holder/spell/aoe/revenant/overload/proc/shock_lights(obj/machinery/light/L, mob/living/simple_animal/revenant/user)
	if(!L.on)
		return

	L.visible_message(span_boldwarning("\The [L] suddenly flares brightly and begins to spark!"))
	do_sparks(4, 0, L)
	new /obj/effect/temp_visual/revenant(L.loc)
	sleep(2 SECONDS)
	if(!L.on) //wait, wait, don't shock me
		return

	flick("[L.base_icon_state]2", L)
	for(var/mob/living/M in view(shock_range, L))
		if(M == user)
			continue

		M.Beam(L, icon_state = "purple_lightning", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
		M.electrocute_act(shock_damage, "настенной лампы", flags = SHOCK_NOGLOVES)

		do_sparks(4, 0, M)
		playsound(M, 'sound/machines/defib_zap.ogg', 50, TRUE, -1)


//Defile: Corrupts nearby stuff, unblesses floor tiles.
/obj/effect/proc_holder/spell/aoe/revenant/defile
	name = "Defile"
	desc = "Twists and corrupts the nearby area as well as dispelling holy auras on floors."
	base_cooldown = 15 SECONDS
	stun = 1 SECONDS
	reveal = 4 SECONDS
	unlock_amount = 75
	cast_amount = 30
	action_icon_state = "r_defile"
	aoe_range = 4


/obj/effect/proc_holder/spell/aoe/revenant/defile/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	return T

/obj/effect/proc_holder/spell/aoe/revenant/defile/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!attempt_cast(user))
		return

	for(var/turf/T in targets)
		T.defile()

		for(var/atom/A in T.contents)
			A.defile()


//Malfunction: Makes bad stuff happen to robots and machines.
/obj/effect/proc_holder/spell/aoe/revenant/malfunction
	name = "Malfunction"
	desc = "Corrupts and damages nearby machines and mechanical objects."
	base_cooldown = 20 SECONDS
	cast_amount = 45
	unlock_amount = 150
	action_icon_state = "r_malfunction"
	aoe_range = 2


/obj/effect/proc_holder/spell/aoe/revenant/malfunction/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	return T


//A note to future coders: do not replace this with an EMP because it will wreck malf AIs and gang dominators and everyone will hate you.
/obj/effect/proc_holder/spell/aoe/revenant/malfunction/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			INVOKE_ASYNC(src, PROC_REF(effect), user, T)


/obj/effect/proc_holder/spell/aoe/revenant/malfunction/proc/effect(mob/living/simple_animal/revenant/user, turf/T)
	T.rev_malfunction(TRUE)

	for(var/atom/A in T.contents)
		A.rev_malfunction(TRUE)


/**
 * Makes objects be haunted and then throws them at conscious people to do damage, spooky!
 */
/obj/effect/proc_holder/spell/aoe/revenant/haunt_object
	name = "Haunt Objects"
	desc = "Empower nearby objects to you with ghostly energy, causing them to attack nearby mortals. \
		Items closer to you are more likely to be haunted."
	action_icon_state = "r_haunt"
	base_cooldown = 60 SECONDS
	unlock_amount = 150
	cast_amount = 50
	stun = 3 SECONDS
	reveal = 10 SECONDS
	aoe_range = 7
	/// The maximum number of objects to haunt
	var/max_targets = 7
	/// Self explanatory
	var/haunt_time = 20 SECONDS
	/// A list of all attack timers started by this spell being cast
	var/list/attack_timers = list()


/obj/effect/proc_holder/spell/aoe/revenant/haunt_object/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	T.allowed_type = /obj/item
	return T


/obj/effect/proc_holder/spell/aoe/revenant/haunt_object/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!attempt_cast(user))
		return

	var/successes = 0
	for(var/obj/item/nearby_item as anything in targets)
		if(successes >= max_targets) // End loop if we've already got 7 spooky items
			break

		// Don't throw around anchored things or dense things
		// (Or things not on a turf but I am not sure if range can catch that)
		if(nearby_item.anchored || nearby_item.density || nearby_item.move_resist == INFINITY || !isturf(nearby_item.loc))
			continue
		// Don't throw abstract things
		if(nearby_item.item_flags & ABSTRACT)
			continue
		// Don't throw things we can't see
		if(nearby_item.invisibility > user.see_invisible)
			continue

		var/distance_from_user = max(get_dist(get_turf(nearby_item), get_turf(user)), 1) // get_dist() for same tile dists return -1, we do not want that
		var/chance_of_haunting = 150 / distance_from_user // The further away things are, the less likely they are to be picked
		if(!prob(chance_of_haunting))
			continue

		make_spooky(nearby_item, user)
		successes++

	if(!successes) //no items to throw
		revert_cast()
		return

	// Stop the looping attacks after 20 SECONDS, roughly 4-5 attack cycles depending on lag
	addtimer(CALLBACK(src, PROC_REF(stop_timers)), haunt_time, TIMER_UNIQUE)


/**
 * Handles making an object haunted and setting it up to attack.
 */
/obj/effect/proc_holder/spell/aoe/revenant/haunt_object/proc/make_spooky(obj/item/item_to_possess, mob/living/simple_animal/revenant/user)
	new /obj/effect/temp_visual/revenant(get_turf(item_to_possess)) // Thematic spooky visuals
	var/mob/living/simple_animal/possessed_object/possessed_object = new(item_to_possess) // Begin haunting object
	item_to_possess.throwforce = min(item_to_possess.throwforce + 5, 15) // Damage it should do? throwforce+5 or 15, whichever is lower
	set_outline(possessed_object)
	possessed_object.maxHealth = 100 // Double the regular HP of possessed objects
	possessed_object.health = 100
	possessed_object.escape_chance = 100 // We cannot be contained

	addtimer(CALLBACK(src, PROC_REF(attack), possessed_object, user), 1 SECONDS, TIMER_UNIQUE) // Short warm-up for floaty ambience
	attack_timers.Add(addtimer(CALLBACK(src, PROC_REF(attack), possessed_object, user), 4 SECONDS, TIMER_UNIQUE|TIMER_LOOP|TIMER_STOPPABLE)) // 5 second looping attacks
	addtimer(CALLBACK(possessed_object, TYPE_PROC_REF(/mob/living/simple_animal/possessed_object, death)), haunt_time + 4 SECONDS, TIMER_UNIQUE) // De-haunt the object


/**
 * Handles finding a valid target and throwing us at it.
 */
/obj/effect/proc_holder/spell/aoe/revenant/haunt_object/proc/attack(mob/living/simple_animal/possessed_object/possessed_object, mob/living/simple_animal/revenant/user)
	var/list/potential_victims = list()

	for(var/mob/living/carbon/potential_victim in range(aoe_range, get_turf(possessed_object)))
		if(!can_see(possessed_object, potential_victim, aoe_range)) // You can't see me
			continue

		if(potential_victim.stat != CONSCIOUS) // Don't kill our precious essence-filled sleepy mobs
			continue

		potential_victims.Add(potential_victim)

	if(!length(potential_victims))
		possessed_object.possessed_item.throwforce = min(possessed_object.possessed_item.throwforce + 5, 15) // If an item is stood still for a while it can gather power
		set_outline(possessed_object)
		return

	var/mob/living/carbon/victim = pick(potential_victims)
	possessed_object.throw_at(victim, aoe_range, 2, user)


/**
 * Sets the glow on the haunted object, scales up based on throwforce.
 */
/obj/effect/proc_holder/spell/aoe/revenant/haunt_object/proc/set_outline(mob/living/simple_animal/possessed_object/possessed_object)
	possessed_object.remove_filter("haunt_glow")
	var/outline_size = min((possessed_object.possessed_item.throwforce / 15) * 3, 3)
	possessed_object.add_filter("haunt_glow", 2, list("type" = "outline", "color" = "#7A4FA9", "size" = outline_size)) // Give it spooky purple outline


/**
 * Stop all attack timers cast by the previous spell use.
 */
/obj/effect/proc_holder/spell/aoe/revenant/haunt_object/proc/stop_timers()
	for(var/I in attack_timers)
		deltimer(I)


/**
 * Gives everyone in a 7 tile radius 2 minutes of hallucinations
 */
/obj/effect/proc_holder/spell/aoe/revenant/hallucinations
	name = "Hallucination Aura"
	desc = "Toy with the living nearby, giving them glimpses of things that could be or once were."
	action_icon_state = "r_hallucinations"
	base_cooldown = 15 SECONDS
	unlock_amount = 50
	cast_amount = 25
	stun = 1 SECONDS
	reveal = 3 SECONDS


/obj/effect/proc_holder/spell/aoe/revenant/hallucinations/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	T.allowed_type = /mob/living/carbon
	return T


/obj/effect/proc_holder/spell/aoe/revenant/hallucinations/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!attempt_cast(user))
		return

	for(var/mob/living/carbon/M as anything in targets)
		M.AdjustHallucinate(60 SECONDS, bound_upper = 300 SECONDS) //Lets not let them get more than 5 minutes of hallucinations
		new /obj/effect/temp_visual/revenant(get_turf(M))

/**
 * Infects targets with a ectoplasmic disease
 */
/obj/effect/proc_holder/spell/aoe/revenant/blight
	name = "Blight"
	desc = "Infects people nearby with a disease that slowly debilitates them."
	action_icon_state = "blight"
	base_cooldown = 60 SECONDS
	unlock_amount = 200
	cast_amount = 40
	stun = 3 SECONDS
	reveal = 7 SECONDS
	aoe_range = 4

/obj/effect/proc_holder/spell/aoe/revenant/blight/create_new_targeting()
	var/datum/spell_targeting/aoe/target = new()
	target.range = aoe_range
	target.allowed_type = /mob/living/carbon/human
	return target

/obj/effect/proc_holder/spell/aoe/revenant/blight/valid_target(mob/living/carbon/human/target, mob/living/simple_animal/revenant/user = usr)
	if(!target.mind)
		return FALSE

	if(target.mind in SSticker.mode.sintouched)
		return FALSE

	if(locate(/datum/disease/ectoplasmic) in target.diseases)
		return FALSE

	return TRUE

/obj/effect/proc_holder/spell/aoe/revenant/blight/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!attempt_cast(user))
		return

	for(var/mob/living/carbon/human/human as anything in targets)
		var/datum/disease/ectoplasmic/disease = new
		disease.Contract(human)
		new /obj/effect/temp_visual/revenant(get_turf(human))

/**
 * Defiling atoms.
 */

/turf/defile()
	if(flags & NOJAUNT)
		flags &= ~NOJAUNT
		new /obj/effect/temp_visual/revenant(loc)

/turf/simulated/floor/defile()
	..()
	if(prob(15))
		broken = FALSE
		burnt = FALSE
		make_plating(intact)

/turf/simulated/floor/plating/defile()
	if(flags & NOJAUNT)
		flags &= ~NOJAUNT
		new /obj/effect/temp_visual/revenant(loc)

/turf/simulated/floor/engine/cult/defile()
	if(flags & NOJAUNT)
		flags &= ~NOJAUNT
		new /obj/effect/temp_visual/revenant(loc)

/turf/simulated/wall/defile()
	..()
	if(prob(15))
		new/obj/effect/temp_visual/revenant(loc)
		ChangeTurf(/turf/simulated/wall/rust)

/turf/simulated/wall/r_wall/defile()
	..()
	if(prob(15))
		new/obj/effect/temp_visual/revenant(loc)
		ChangeTurf(/turf/simulated/wall/r_wall/rust)

/obj/structure/window/defile()
	take_damage(rand(30,80))
	if(fulltile)
		new /obj/effect/temp_visual/revenant/cracks(loc)

/obj/machinery/light/defile()
	flicker(30)

/obj/structure/closet/defile()
	open()

/mob/living/carbon/human/defile()
	to_chat(src, span_warning("You suddenly feel [pick("sick and tired", "tired and confused", "nauseated", "dizzy")]."))
	apply_damages(tox = 5, stamina = 60)
	AdjustConfused(40 SECONDS, bound_lower = 0, bound_upper = 60 SECONDS)
	new /obj/effect/temp_visual/revenant(loc)

/atom/proc/defile()
	return

/turf/simulated/wall/r_wall/rust/defile()
	return

/turf/simulated/wall/shuttle/defile()
	return

/turf/simulated/wall/rust/defile()
	return

/turf/simulated/wall/r_wall/defile()
	return

/turf/simulated/wall/indestructible/defile()
	return

/turf/simulated/floor/shuttle/defile()
	return

/turf/simulated/floor/plating/defile()
	return


/**
 * Malfunctioning atoms.
 */

/mob/living/carbon/human/rev_malfunction(cause_emp = TRUE)
	to_chat(src, span_warning("You feel [pick("your sense of direction flicker out", "a stabbing pain in your head", "your mind fill with static")]."))
	new /obj/effect/temp_visual/revenant(loc)
	if(cause_emp)
		emp_act(1)

/mob/living/simple_animal/bot/rev_malfunction(cause_emp = TRUE)
	if(!emagged)
		new /obj/effect/temp_visual/revenant(loc)
		locked = FALSE
		open = TRUE
		emag_act(null)

/mob/living/silicon/robot/rev_malfunction(cause_emp = TRUE)
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
	new /obj/effect/temp_visual/revenant(loc)
	spark_system.start()
	if(cause_emp)
		emp_act(1)

/obj/rev_malfunction(cause_emp = TRUE)
	if(prob(20))
		if(prob(50))
			new /obj/effect/temp_visual/revenant(loc)
		emag_act(null)
	else if(cause_emp)
		emp_act(1)

/obj/machinery/clonepod/rev_malfunction(cause_emp = TRUE)
	..(cause_emp = FALSE)

/atom/proc/rev_malfunction(cause_emp = TRUE)
	return

/obj/machinery/power/apc/rev_malfunction(cause_emp = TRUE)
	return

/obj/machinery/power/smes/rev_malfunction(cause_emp = TRUE)
	return

