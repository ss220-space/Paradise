//OTHER DEBUFFS

/datum/status_effect/cultghost //is a cult ghost and can't use manifest runes
	id = "cult_ghost"
	duration = -1
	alert_type = null

/datum/status_effect/cultghost/tick()
	if(owner.reagents)
		owner.reagents.del_reagent("holywater") //can't be deconverted

/datum/status_effect/crusher_mark
	id = "crusher_mark"
	duration = 300 //if you leave for 30 seconds you lose the mark, deal with it
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/mutable_appearance/marked_underlay
	var/obj/item/twohanded/kinetic_crusher/hammer_synced

/datum/status_effect/crusher_mark/on_creation(mob/living/new_owner, obj/item/twohanded/kinetic_crusher/new_hammer_synced)
	. = ..()
	if(.)
		hammer_synced = new_hammer_synced

/datum/status_effect/crusher_mark/on_apply()
	if(owner.mob_size >= MOB_SIZE_LARGE)
		marked_underlay = mutable_appearance('icons/effects/effects.dmi', "shield2")
		marked_underlay.pixel_x = -owner.pixel_x
		marked_underlay.pixel_y = -owner.pixel_y
		owner.underlays += marked_underlay
		return TRUE
	return FALSE

/datum/status_effect/crusher_mark/Destroy()
	hammer_synced = null
	if(owner)
		owner.underlays -= marked_underlay
	QDEL_NULL(marked_underlay)
	return ..()

/datum/status_effect/crusher_mark/be_replaced()
	owner.underlays -= marked_underlay //if this is being called, we should have an owner at this point.
	..()


/datum/status_effect/pacifism
	id = "pacifism_debuff"
	alert_type = null
	duration = 40 SECONDS


/datum/status_effect/pacifism/on_apply()
	ADD_TRAIT(owner, TRAIT_PACIFISM, id)
	return ..()


/datum/status_effect/pacifism/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, id)


/datum/status_effect/shadow_boxing
	id = "shadow barrage"
	alert_type = null
	duration = 10 SECONDS
	tick_interval = 0.4 SECONDS
	var/damage = 8
	var/source_UID


/datum/status_effect/shadow_boxing/on_creation(mob/living/new_owner, mob/living/source)
	. = ..()
	source_UID = source.UID()


/datum/status_effect/shadow_boxing/tick()
	var/mob/living/attacker = locateUID(source_UID)
	if(attacker in view(owner, 2))
		attacker.do_attack_animation(owner, ATTACK_EFFECT_PUNCH)
		owner.apply_damage(damage, BRUTE)
		shadow_to_animation(get_turf(attacker), get_turf(owner), attacker)


/datum/status_effect/saw_bleed
	id = "saw_bleed"
	duration = -1 //removed under specific conditions
	tick_interval = 6
	alert_type = null
	var/mutable_appearance/bleed_overlay
	var/mutable_appearance/bleed_underlay
	var/bleed_amount = 3
	var/bleed_buildup = 3
	var/delay_before_decay = 5
	var/bleed_damage = 200
	var/needs_to_bleed = FALSE

/datum/status_effect/saw_bleed/Destroy()
	if(owner)
		owner.cut_overlay(bleed_overlay)
		owner.underlays -= bleed_underlay
	QDEL_NULL(bleed_overlay)
	return ..()

/datum/status_effect/saw_bleed/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	bleed_overlay = mutable_appearance('icons/effects/bleed.dmi', "bleed[bleed_amount]")
	bleed_underlay = mutable_appearance('icons/effects/bleed.dmi', "bleed[bleed_amount]")
	var/icon/I = icon(owner.icon, owner.icon_state, owner.dir)
	var/icon_height = I.Height()
	bleed_overlay.pixel_x = -owner.pixel_x
	bleed_overlay.pixel_y = FLOOR(icon_height * 0.25, 1)
	bleed_overlay.transform = matrix() * (icon_height/world.icon_size) //scale the bleed overlay's size based on the target's icon size
	bleed_underlay.pixel_x = -owner.pixel_x
	bleed_underlay.transform = matrix() * (icon_height/world.icon_size) * 3
	bleed_underlay.alpha = 40
	owner.add_overlay(bleed_overlay)
	owner.underlays += bleed_underlay
	return ..()

/datum/status_effect/saw_bleed/tick()
	if(owner.stat == DEAD)
		qdel(src)
	else
		add_bleed(-1)

/datum/status_effect/saw_bleed/proc/add_bleed(amount)
	owner.cut_overlay(bleed_overlay)
	owner.underlays -= bleed_underlay
	bleed_amount += amount
	if(bleed_amount)
		if(bleed_amount >= 10)
			needs_to_bleed = TRUE
			qdel(src)
		else
			if(amount > 0)
				tick_interval += delay_before_decay
			bleed_overlay.icon_state = "bleed[bleed_amount]"
			bleed_underlay.icon_state = "bleed[bleed_amount]"
			owner.add_overlay(bleed_overlay)
			owner.underlays += bleed_underlay
	else
		qdel(src)

/datum/status_effect/saw_bleed/on_remove()
	if(needs_to_bleed)
		var/turf/T = get_turf(owner)
		new /obj/effect/temp_visual/bleed/explode(T)
		for(var/d in GLOB.alldirs)
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(T, d)
		playsound(T, "desceration", 200, 1, -1)
		owner.adjustBruteLoss(bleed_damage)
	else
		new /obj/effect/temp_visual/bleed(get_turf(owner))

/datum/status_effect/stamina_dot
	id = "stamina_dot"
	duration = 130
	alert_type = null

/datum/status_effect/stamina_dot/tick()
	owner.adjustStaminaLoss(10)

/datum/status_effect/bluespace_slowdown
	id = "bluespace_slowdown"
	duration = 150
	alert_type = null

/datum/status_effect/bluespace_slowdown/on_apply()
	owner.next_move_modifier *= 2
	return ..()

/datum/status_effect/bluespace_slowdown/on_remove()
	owner.next_move_modifier /= 2


/**
 * Vampire mark.
 */
/datum/status_effect/mark_prey
	id = "mark_prey"
	duration = 5 SECONDS
	tick_interval = 1 SECONDS
	alert_type = null
	var/mutable_appearance/marked_overlay
	var/datum/antagonist/vampire/vamp
	var/t_eyes
	var/t_hearts
	var/static/list/trash_talk = list("СКАЖИ ПРИВЕТ МОЕМУ МАЛЕНЬКОМУ ДРУГУ!!!",
									"АРРРРРГГГГГХХХ!!!",
									"МОЯ ГОЛОВА!!!",
									"ПОМОГИТЕ! МОИ РУКИ ДВИГАЮТСЯ САМИ ПО СЕБЕ!!!",
									"ЭТО ДЕЛАЕТ [pick("МОЙ БРАТ БЛИЗНЕЦ", "БОРЕР", "СИНДИКАТ", "ВОЛШЕБНИК")]!!!",
									"ОН УКРАЛ МОЙ СЛАДКИЙ РУЛЕТ!!!",
									"Я ПРОСТО ДОЖЕВАЛ ЖВАЧКУ!!!",
									"ПРИШЕЛ ДЕНЬ РАСПЛАТЫ!!!",
									"ЖИВОТНЫЕ НЕ ЧЛЕНЫ ЭКИПАЖА!!!")


/datum/status_effect/mark_prey/on_creation(mob/living/new_owner, datum/antagonist/vampire/antag_datum)
	if(antag_datum)
		vamp = antag_datum
		var/t_kidneys = vamp.get_trophies(INTERNAL_ORGAN_KIDNEYS)
		duration += t_kidneys SECONDS	// 15s. MAX
		t_eyes = vamp.get_trophies(INTERNAL_ORGAN_EYES)
		t_hearts = vamp.get_trophies(INTERNAL_ORGAN_HEART)
	return ..()


/datum/status_effect/mark_prey/Destroy()
	if(owner)
		owner.cut_overlay(marked_overlay)
	QDEL_NULL(marked_overlay)
	vamp = null
	return ..()


/datum/status_effect/mark_prey/on_apply()
	if(owner.stat == DEAD || !vamp)
		return FALSE

	owner.Slowed(duration)
	to_chat(owner, span_danger("You feel the unbearable heaviness of being..."))
	new /obj/effect/temp_visual/cult/sparks(get_turf(owner))

	marked_overlay = mutable_appearance('icons/effects/effects.dmi', "cult_halo1")
	marked_overlay.pixel_y = 3
	owner.add_overlay(marked_overlay)
	return ..()


/datum/status_effect/mark_prey/tick()
	if(owner.stat == DEAD)
		qdel(src)
		return

	if(owner.resting)	// abuses are not allowed
		owner.StopResting()

	if(t_hearts && prob(t_hearts * 10))	// 60% on MAX
		owner.adjustFireLoss(t_hearts)	// 6 MAX

	if(!owner.incapacitated() && prob(30 + t_eyes * 7))	// 100% on MAX
		// lets check our arms first
		var/obj/item/left_hand = owner.l_hand
		var/obj/item/right_hand = owner.r_hand

		// next we will find THE GUN .\_/.
		var/obj/item/gun/found_gun
		if(istype(left_hand, /obj/item/gun))
			found_gun = left_hand

		if(!found_gun && istype(right_hand, /obj/item/gun))
			found_gun = right_hand

		// now we will find the target
		var/new_range = found_gun ? 7 : 1	// we need to check close range only if no guns found
		var/mob/living/target
		for(var/mob/living/check in (view(new_range, owner) - owner))
			if(!check.mind || check.stat == DEAD || isvampire(check) || isvampirethrall(check))
				continue
			target = check
			if(target)
				if(prob(30))
					owner.say(pick(trash_talk))
				break

		// if nothing is found we are the target
		if(!target)
			target = owner

		// if no gun found or target is owner we will attack ourselves in HARM intent
		if(!found_gun || target == owner)
			if(target != owner)
				owner.face_atom(target)

			if(owner.a_intent != INTENT_HARM)
				owner.a_intent_change(INTENT_HARM)

			// empty hands or not a human = unarmed attack
			if((!left_hand && !right_hand) || !ishuman(owner))
				owner.UnarmedAttack(target)
				return

			// otherwise lets find a better weapon
			var/force_left = left_hand ? left_hand.force : 0
			var/force_right = right_hand ? right_hand.force : 0
			if(force_left > force_right)
				if(!owner.hand)
					owner.swap_hand()
				left_hand.attack(target, owner, BODY_ZONE_HEAD)	// yes! right in the neck
			else if(force_right)
				if(owner.hand)
					owner.swap_hand()
				right_hand.attack(target, owner, BODY_ZONE_HEAD)
			return

		// here goes nothing!
		if(found_gun)
			owner.face_atom(target)
			if(owner.a_intent != INTENT_HARM)
				owner.a_intent_change(INTENT_HARM)
			if(owner.hand && owner.l_hand != found_gun)
				owner.swap_hand()
			found_gun.process_fire(target, owner, zone_override = BODY_ZONE_HEAD)	// hell yeah! few headshots for mr. vampire!
			found_gun.attack(owner, owner, BODY_ZONE_HEAD)	// attack ourselves also in case gun has no ammo


// start of `living` level status procs.

/**
 * # Confusion
 *
 * Prevents moving straight, sometimes changing movement direction at random.
 * Decays at a rate of 1 per second.
 */
/datum/status_effect/transient/confusion
	id = "confusion"
	var/image/overlay

/datum/status_effect/transient/confusion/tick()
	. = ..()
	if(!.)
		return
	if(!owner.stat) //add or remove the overlay if they are alive or unconscious/dead
		add_overlay()
	else if(overlay)
		owner.cut_overlay(overlay)
		overlay = null

/datum/status_effect/transient/confusion/proc/add_overlay()
	if(overlay)
		return
	var/matrix/M = matrix()
	M.Scale(0.6)
	overlay = image('icons/effects/effects.dmi', "confusion", pixel_y = 20)
	overlay.transform = M
	owner.add_overlay(overlay)

/datum/status_effect/transient/confusion/on_remove()
	owner.cut_overlay(overlay)
	overlay = null
	return ..()

/**
 * # Disoriented
 *
 * Modification of confusion effect. Makes you crash and take damage if confused
 */
/datum/status_effect/transient/disoriented
	id = "disoriented"

/datum/status_effect/transient/disoriented/on_creation(mob/living/new_owner)
	strength = 1
	. = ..()

/datum/status_effect/transient/disoriented/tick()
	if(QDELETED(src) || QDELETED(owner))
		return FALSE
	. = TRUE
	if(strength <= 0)
		if(owner.get_confusion() <= 0)
			qdel(src)
			return FALSE

/**
 * # Dizziness
 *
 * Slightly offsets the client's screen randomly every tick.
 * Decays at a rate of 1 per second, or 5 when resting.
 */
/datum/status_effect/transient/dizziness
	id = "dizziness"
	var/px_diff = 0
	var/py_diff = 0

/datum/status_effect/transient/dizziness/on_remove()
	if(owner.client)
		// smoothly back to normal
		animate(owner.client, 0.2 SECONDS, pixel_x = -px_diff, pixel_y = -py_diff, flags = ANIMATION_PARALLEL)
	return ..()

/datum/status_effect/transient/dizziness/tick()
	. = ..()
	if(!.)
		return
	var/dir = sin(world.time)
	var/amplitude = min(strength * 0.003, 32)
	px_diff = cos(world.time * 3) * amplitude * dir
	py_diff = sin(world.time * 3) * amplitude * dir
	owner.client?.pixel_x = px_diff
	owner.client?.pixel_y = py_diff

/datum/status_effect/transient/dizziness/calc_decay()
	return (-0.2 + (owner.resting ? -0.8 : 0)) SECONDS

/**
 * # Drowsiness
 *
 * Slows down and causes eye blur, with a 5% chance of falling asleep for a short time.
 * Decays at a rate of 1 per second, or 5 when resting.
 */
/datum/status_effect/transient/drowsiness
	id = "drowsiness"

/datum/status_effect/transient/drowsiness/tick()
	. = ..()
	if(!.)
		return
	owner.EyeBlurry(4 SECONDS)
	if(prob(1))
		owner.AdjustSleeping(2 SECONDS)
		owner.Paralyse(10 SECONDS)

/datum/status_effect/transient/drowsiness/calc_decay()
	return (-0.2 + (owner.resting ? -0.8 : 0)) SECONDS

/**
 * # Drukenness
 *
 * Causes a myriad of status effects and other afflictions the stronger it is.
 * Decays at a rate of 1 per second if no alcohol remains inside.
 */
/datum/status_effect/transient/drunkenness
	id = "drunkenness"
	var/alert_thrown = FALSE

// the number of seconds of the status effect required for each effect to kick in.
#define THRESHOLD_SLUR 60 SECONDS
#define THRESHOLD_BRAWLING 60 SECONDS
#define THRESHOLD_CONFUSION 80 SECONDS
#define THRESHOLD_SPARK 100 SECONDS
#define THRESHOLD_VOMIT 120 SECONDS
#define THRESHOLD_BLUR 150 SECONDS
#define THRESHOLD_COLLAPSE 150 SECONDS
#define THRESHOLD_FAINT 180 SECONDS
#define THRESHOLD_BRAIN_DAMAGE 240 SECONDS
#define DRUNK_BRAWLING /datum/martial_art/drunk_brawling

/datum/status_effect/transient/drunkenness/on_remove()
	if(alert_thrown)
		alert_thrown = FALSE
		owner.clear_alert("drunk")
		owner.sound_environment_override = SOUND_ENVIRONMENT_NONE
	if(owner.mind && istype(owner.mind.martial_art, DRUNK_BRAWLING))
		owner.mind.martial_art.remove(owner)
	return ..()

/datum/status_effect/transient/drunkenness/tick()
	. = ..()
	if(!.)
		return

	// Adjust actual drunkenness based organ presence
	var/actual_strength = strength
	var/datum/mind/M = owner.mind
	var/is_ipc = ismachineperson(owner)

	var/obj/item/organ/internal/liver/L
	if(!is_ipc)
		L = owner.get_int_organ(/obj/item/organ/internal/liver)
		var/liver_multiplier = 5 // no liver? get shitfaced
		if(L)
			liver_multiplier = L.alcohol_intensity
		actual_strength *= liver_multiplier

	// THRESHOLD_SLUR (60 SECONDS)
	if(actual_strength >= THRESHOLD_SLUR)
		owner.Slur(actual_strength)
		if(!alert_thrown)
			alert_thrown = TRUE
			owner.throw_alert("drunk", /obj/screen/alert/drunk)
			owner.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC
	// THRESHOLD_BRAWLING (60 SECONDS)
	if(M)
		if(actual_strength >= THRESHOLD_BRAWLING)
			if(!istype(M.martial_art, DRUNK_BRAWLING))
				var/datum/martial_art/drunk_brawling/MA = new
				MA.teach(owner, TRUE)
		else if(istype(M.martial_art, DRUNK_BRAWLING))
			M.martial_art.remove(owner)
	// THRESHOLD_CONFUSION (80 SECONDS)
	if(actual_strength >= THRESHOLD_CONFUSION && prob(0.66))
		owner.AdjustConfused(6 SECONDS, bound_lower = 2 SECONDS, bound_upper = 1 MINUTES)
	// THRESHOLD_SPARK (100 SECONDS)
	if(is_ipc && actual_strength >= THRESHOLD_SPARK && prob(0.5))
		do_sparks(3, 1, owner)
	// THRESHOLD_VOMIT (120 SECONDS)
	if(!is_ipc && actual_strength >= THRESHOLD_VOMIT && prob(0.2))
		owner.fakevomit()
	// THRESHOLD_BLUR (150 SECONDS)
	if(actual_strength >= THRESHOLD_BLUR)
		owner.EyeBlurry(20 SECONDS)
	// THRESHOLD_COLLAPSE (150 SECONDS)
	if(actual_strength >= THRESHOLD_COLLAPSE && prob(0.2))
		owner.emote("collapse")
		do_sparks(3, 1, src)
	// THRESHOLD_FAINT (180 SECONDS)
	if(actual_strength >= THRESHOLD_FAINT && prob(0.2))
		owner.Paralyse(10 SECONDS)
		owner.Drowsy(60 SECONDS)
		if(L)
			L.receive_damage(1, TRUE)
		if(!is_ipc)
			owner.adjustToxLoss(1)
	// THRESHOLD_BRAIN_DAMAGE (240 SECONDS)
	if(actual_strength >= THRESHOLD_BRAIN_DAMAGE && prob(1))
		owner.adjustBrainLoss(1)

#undef THRESHOLD_SLUR
#undef THRESHOLD_BRAWLING
#undef THRESHOLD_CONFUSION
#undef THRESHOLD_SPARK
#undef THRESHOLD_VOMIT
#undef THRESHOLD_BLUR
#undef THRESHOLD_COLLAPSE
#undef THRESHOLD_FAINT
#undef THRESHOLD_BRAIN_DAMAGE
#undef DRUNK_BRAWLING

/datum/status_effect/transient/drunkenness/calc_decay()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.has_booze())
			return 0
	return -0.2 SECONDS

/datum/status_effect/transient/cult_slurring
	id = "cult_slurring"

/datum/status_effect/transient/clock_cult_slurring
	id = "clock_cult_slurring"

/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/needs_update_stat = FALSE

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		if(ishuman(new_owner))
			var/mob/living/carbon/human/H = new_owner
			set_duration = H.dna.species.spec_stun(H, set_duration)
		duration = set_duration
	if(!duration)
		return FALSE
	. = ..()
	if(. && (needs_update_stat || issilicon(owner)))
		owner.update_stat()
	owner.update_canmove()


/datum/status_effect/incapacitating/on_remove()
	if(needs_update_stat || issilicon(owner)) //silicons need stat updates in addition to normal canmove updates
		owner.update_stat()
	owner.update_canmove()
	return ..()

//STUN - prevents movement and actions, victim stays standing
/datum/status_effect/incapacitating/stun
	id = "stun"

//IMMOBILIZED - prevents movement, victim can still stand and act
/datum/status_effect/incapacitating/immobilized
	id = "immobilized"

//WEAKENED - prevents movement and action, victim falls over
/datum/status_effect/incapacitating/weakened
	id = "weakened"

//PARALYZED - prevents movement and action, victim falls over, victim cannot hear or see.
/datum/status_effect/incapacitating/paralyzed
	id = "paralyzed"
	needs_update_stat = TRUE

//SLEEPING - victim falls over, cannot act, cannot see or hear, heals under certain conditions.
/datum/status_effect/incapacitating/sleeping
	id = "sleeping"
	tick_interval = 2 SECONDS
	needs_update_stat = TRUE

/datum/status_effect/incapacitating/sleeping/tick()
	if(!iscarbon(owner))
		return

	var/mob/living/carbon/dreamer = owner

	if(isvampire(dreamer))
		if(istype(dreamer.loc, /obj/structure/closet/coffin))
			dreamer.adjustBruteLoss(-1, FALSE)
			dreamer.adjustFireLoss(-1, FALSE)
			dreamer.adjustToxLoss(-1)
	dreamer.handle_dreams()
	dreamer.adjustStaminaLoss(-10)
	var/comfort = 1
	if(istype(dreamer.buckled, /obj/structure/bed))
		var/obj/structure/bed/bed = dreamer.buckled
		comfort += bed.comfort
	else if(istype(dreamer.buckled, /obj/structure/chair))
		var/obj/structure/chair/chair = dreamer.buckled
		comfort += chair.comfort
	for(var/obj/item/bedsheet/bedsheet in range(dreamer.loc,0))
		if(bedsheet.loc != dreamer.loc) //bedsheets in your backpack/neck don't give you comfort
			continue
		comfort += bedsheet.comfort
		break //Only count the first bedsheet
	if(dreamer.get_drunkenness() > 0)
		comfort += 1 //Aren't naps SO much better when drunk?
		dreamer.AdjustDrunk(-0.4 SECONDS * comfort) //reduce drunkenness while sleeping.
	if(comfort > 1 && prob(3))//You don't heal if you're just sleeping on the floor without a blanket.
		dreamer.adjustBruteLoss(-1 * comfort, FALSE)
		dreamer.adjustFireLoss(-1 * comfort)
	if(prob(10) && dreamer.health)
		dreamer.emote("snore")


//SLOWED - slows down the victim for a duration and a given slowdown value.
/datum/status_effect/incapacitating/slowed
	id = "slowed"
	var/slowdown_value = 10 // defaults to this value if none is specified

/datum/status_effect/incapacitating/slowed/on_creation(mob/living/new_owner, set_duration, slowdown_value)
	. = ..()
	set_slowdown_value(slowdown_value)

/datum/status_effect/incapacitating/slowed/proc/set_slowdown_value(slowdown_value)
	if(isnum(slowdown_value))
		src.slowdown_value = slowdown_value

/datum/status_effect/transient/silence
	id = "silenced"

/datum/status_effect/transient/silence/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_MUTE, id)

/datum/status_effect/transient/silence/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_MUTE, id)

/datum/status_effect/transient/silence/absolute // this one will mute all emote sounds including gasps
	id = "abssilenced"

/datum/status_effect/transient/jittery
	id = "jittering"

/datum/status_effect/transient/jittery/on_apply()
	. = ..()
	owner.do_jitter_animation(strength / 20, 1)

/datum/status_effect/transient/jittery/tick()
	. = ..()
	if(!.)
		return
	owner.do_jitter_animation(strength / 20, 1)

/datum/status_effect/transient/jittery/calc_decay()
	return (-0.2 + (owner.resting ? -0.8 : 0)) SECONDS

/datum/status_effect/transient/stammering
	id = "stammer"

/datum/status_effect/transient/slurring
	id = "slurring"

/datum/status_effect/transient/lose_breath
	id = "lose_breath"

#define HALLUCINATE_COOLDOWN_MIN 20 SECONDS
#define HALLUCINATE_COOLDOWN_MAX 50 SECONDS
/// This is multiplied with [/mob/var/hallucination] to determine the final cooldown. A higher hallucination value means shorter cooldown.
#define HALLUCINATE_COOLDOWN_FACTOR 0.003
/// Percentage defining the chance at which an hallucination may spawn past the cooldown.
#define HALLUCINATE_CHANCE 20
// Severity weights, should sum up to 100!
#define HALLUCINATE_MINOR_WEIGHT 60
#define HALLUCINATE_MODERATE_WEIGHT 25
#define HALLUCINATE_MAJOR_WEIGHT 15

/datum/status_effect/transient/hallucination
	id = "hallucination"
	var/next_hallucination = 0

/datum/status_effect/transient/hallucination/tick()
	. = ..()
	if(!.)
		return

	if(!iscarbon(owner))
		return

	if(next_hallucination > world.time)
		return

	next_hallucination = world.time + rand(HALLUCINATE_COOLDOWN_MIN, HALLUCINATE_COOLDOWN_MAX) / (strength * HALLUCINATE_COOLDOWN_FACTOR)
	if(!prob(HALLUCINATE_CHANCE))
		return

	// Pick a severity
	var/list/severity = list()
	switch(rand(100))
		if(0 to HALLUCINATE_MINOR_WEIGHT)
			severity = GLOB.minor_hallutinations.Copy()
		if((HALLUCINATE_MINOR_WEIGHT + 1) to (HALLUCINATE_MINOR_WEIGHT + HALLUCINATE_MODERATE_WEIGHT))
			severity = GLOB.medium_hallutinations.Copy()
		if((HALLUCINATE_MINOR_WEIGHT + HALLUCINATE_MODERATE_WEIGHT + 1) to 100)
			severity = GLOB.major_hallutinations.Copy()

	owner.hallucinate_living(pickweight(severity))

#undef HALLUCINATE_COOLDOWN_MIN
#undef HALLUCINATE_COOLDOWN_MAX
#undef HALLUCINATE_COOLDOWN_FACTOR
#undef HALLUCINATE_CHANCE
#undef HALLUCINATE_MINOR_WEIGHT
#undef HALLUCINATE_MODERATE_WEIGHT
#undef HALLUCINATE_MAJOR_WEIGHT


/datum/status_effect/transient/eye_blurry
	id = "eye_blurry"


/datum/status_effect/transient/eye_blurry/on_apply()
	if(!ishuman(owner))
		return FALSE
	// Refresh the blur when a client jumps into the mob, in case we get put on a clientless mob with no hud
	RegisterSignal(owner, COMSIG_MOB_LOGIN, PROC_REF(update_blur))
	// Apply initial blur
	update_blur()
	return TRUE


/datum/status_effect/transient/eye_blurry/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_LOGIN)
	if(!owner.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("eye_blur")


/// Updates the blur of the owner of the status effect.
/// Also a signal proc for [COMSIG_MOB_LOGIN], to trigger then when the mob gets a client.
/datum/status_effect/transient/eye_blurry/proc/update_blur(datum/source)
	SIGNAL_HANDLER

	if(!owner.hud_used)
		return

	var/amount_of_blur = clamp(strength * EYE_BLUR_TO_FILTER_SIZE_MULTIPLIER, 0.6, MAX_EYE_BLURRY_FILTER_SIZE)

	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.add_filter("eye_blur", 1, gauss_blur_filter(amount_of_blur))


// Blur lessens the closer we are to expiring, so we update per tick.
/datum/status_effect/transient/eye_blurry/tick(seconds_per_tick, times_fired)
	. = ..()
	if(.)
		update_blur()


/datum/status_effect/transient/eye_blurry/calc_decay()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/obj/item/organ/vision = H.dna?.species?.get_vision_organ(H)

		if(vision && vision == NO_VISION_ORGAN) //species has no eyes
			return ..()

		if(!vision || vision.is_bruised() || vision.is_traumatized()) // doesn't decay if you have damaged eyesight.
			return 0

		if(istype(H.glasses, /obj/item/clothing/glasses/sunglasses/blindfold)) // decays faster if you rest your eyes with a blindfold.
			return -1 SECONDS
	return ..() //default decay rate


/datum/status_effect/transient/blindness
	id = "blindness"

/datum/status_effect/transient/blindness/on_apply()
	. = ..()
	owner.update_blind_effects()

/datum/status_effect/transient/blindness/on_remove()
	owner.update_blind_effects()

/datum/status_effect/transient/blindness/calc_decay()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if((BLINDNESS in H.mutations))
			return 0

		var/obj/item/organ/vision = H.dna?.species?.get_vision_organ(H)

		if(vision && vision == NO_VISION_ORGAN) // species that have no eyes
			return ..()

		if(!vision || vision.is_traumatized() || vision.is_bruised()) //got no eyes or broken eyes
			return 0

	return ..() //default decay rate

/datum/status_effect/transient/drugged
	id = "drugged"

/datum/status_effect/transient/drugged/on_apply()
	. = ..()
	owner.update_druggy_effects()

/datum/status_effect/transient/drugged/on_remove()
	owner.update_druggy_effects()

/datum/status_effect/transient/disgust
	id = "disgust"
	tick_interval = 2 SECONDS

/datum/status_effect/transient/disgust/tick()
	. = ..()

	if(!.)
		return

	if(!iscarbon(owner))
		return

	var/mob/living/carbon/carbon = owner
	if(strength >= DISGUST_LEVEL_GROSS)
		if(prob(10))
			carbon.AdjustStuttering(4 SECONDS)
			carbon.AdjustConfused(6 SECONDS)
		if(prob(10) && !carbon.stat)
			to_chat(carbon, "<span class='warning'>[pick("You feel nauseous.", "You feel like you're going to throw up!")]</span>")
		carbon.Jitter(9 SECONDS)
	if(strength >= DISGUST_LEVEL_VERYGROSS)
		var/pukeprob = 5 + 0.005 * strength
		if(prob(pukeprob))
			carbon.AdjustConfused(9 SECONDS)
			carbon.AdjustStuttering(3 SECONDS)
			carbon.vomit(15, FALSE, TRUE, 0, FALSE)
		carbon.Dizzy(15 SECONDS)
	if(strength >= DISGUST_LEVEL_DISGUSTED)
		if(prob(25))
			carbon.AdjustEyeBlurry(9 SECONDS)
	carbon.update_disgust_alert()

/datum/status_effect/transient/disgust/on_apply()
	. = ..()
	owner.update_disgust_alert()

/datum/status_effect/transient/disgust/on_remove()
	owner.update_disgust_alert()

/datum/status_effect/transient/disgust/calc_decay()
	return -1 * initial(tick_interval)

/datum/status_effect/transient/deaf
	id = "deafened"

/datum/status_effect/transient/deaf/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)

/datum/status_effect/transient/deaf/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)

// lavaland flowers stuff
/datum/status_effect/taming
	id = "taming"
	duration = -1
	tick_interval = 6
	alert_type = null
	var/tame_amount = 1
	var/tame_buildup = 1
	var/tame_crit = 35
	var/needs_to_tame = FALSE
	var/mob/living/tamer

/datum/status_effect/taming/on_creation(mob/living/owner, mob/living/user)
	. = ..()
	if(!.)
		return
	tamer = user

/datum/status_effect/taming/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/taming/tick()
	if(owner.stat == DEAD)
		qdel(src)

/datum/status_effect/taming/proc/add_tame(amount)
	tame_amount += amount
	if(tame_amount)
		if(tame_amount >= tame_crit)
			needs_to_tame = TRUE
			qdel(src)
	else
		qdel(src)

/datum/status_effect/taming/on_remove()
	var/mob/living/simple_animal/hostile/M = owner
	if(needs_to_tame)
		var/turf/T = get_turf(M)
		new /obj/effect/temp_visual/love_heart(T)
		M.drop_loot()
		M.loot = null
		M.add_atom_colour("#11c42f", FIXED_COLOUR_PRIORITY)
		M.faction = tamer.faction
		to_chat(tamer, span_notice("[M] is now friendly after exposure to the flowers!"))
		. = ..()

/datum/status_effect/bubblegum_curse
	id = "bubblegum curse"
	alert_type = /obj/screen/alert/status_effect/bubblegum_curse
	duration = -1 //Kill it. There is no other option.
	tick_interval = 1 SECONDS
	/// The damage the status effect does per tick.
	var/damage = 0.75
	var/source_UID
	/// Are we starting the process to check if the person has still gotten out of range of bubble / crossed zlvls.
	var/coward_checking = FALSE

/datum/status_effect/bubblegum_curse/on_creation(mob/living/new_owner, mob/living/source)
	. = ..()
	source_UID = source.UID()
	owner.overlay_fullscreen("Bubblegum", /obj/screen/fullscreen/fog, 1)

/datum/status_effect/bubblegum_curse/tick()
	var/mob/living/simple_animal/hostile/megafauna/bubblegum/attacker = locateUID(source_UID)
	if(!attacker || attacker.loc == null)
		qdel(src)
		return
	if(attacker.health <= attacker.maxHealth / 2)
		owner.clear_fullscreen("Bubblegum")
		owner.overlay_fullscreen("Bubblegum", /obj/screen/fullscreen/fog, 2)
	if(!coward_checking)
		if(owner.z != attacker.z)
			addtimer(CALLBACK(src, PROC_REF(onstation_coward_callback)), 12 SECONDS)
			coward_checking = TRUE
		else if(get_dist(attacker, owner) >= 25)
			addtimer(CALLBACK(src, PROC_REF(runaway_coward_callback)), 12 SECONDS)
			coward_checking = TRUE

	owner.apply_damage(damage, BRUTE)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.bleed(0.33)
	if(prob(5))
		to_chat(owner, "<span class='userdanger'>[pick("You feel your sins crawling on your back.", "You felt your sins weighing on your neck.", "You feel your blood pulsing inside you.", "<b>YOU'LL NEVER ESCAPE ME</b>", "<b>YOU'LL DIE FOR INSULTING ME LIKE THIS</b>")]</span>")

/datum/status_effect/bubblegum_curse/on_remove()
	owner.clear_fullscreen("Bubblegum")

/datum/status_effect/bubblegum_curse/proc/onstation_coward_callback()
	coward_checking = FALSE
	var/mob/living/simple_animal/hostile/megafauna/bubblegum/attacker = locateUID(source_UID)
	if(owner.z != attacker.z)
		to_chat(owner, "<span class='colossus'><b>YOU CHALLENGE ME LIKE THIS... AND YOU RUN WITH YOUR FALSE MAGICS?</b></span>")
	else
		return
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>REALLY?</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>SUCH INSOLENCE!</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>SO PATHETIC...</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>...SO FOOLISH!</b></span>")
	get_over_here()

/datum/status_effect/bubblegum_curse/proc/runaway_coward_callback()
	coward_checking = FALSE
	var/mob/living/simple_animal/hostile/megafauna/bubblegum/attacker = locateUID(source_UID)
	if(get_dist(attacker, owner) >= 25)
		to_chat(owner, "<span class='colossus'><b>My my, you can run FAST.</b></span>")
	else
		return
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>I thought you wanted a true fight?</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>Perhaps I was mistaken.</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>You are a coward who does not want a fight...</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>...BUT I WANT YOU DEAD!</b></span>")
	get_over_here()

/datum/status_effect/bubblegum_curse/proc/get_over_here()
	var/mob/living/simple_animal/hostile/megafauna/bubblegum/attacker = locateUID(source_UID)
	if(!attacker)
		return //Let's not nullspace
	if(attacker.loc == null)
		return //Extra emergency safety.
	var/turf/TA = get_turf(owner)
	owner.Immobilize(3 SECONDS)
	new /obj/effect/decal/cleanable/blood/bubblegum(TA)
	new /obj/effect/temp_visual/bubblegum_hands/rightsmack(TA)
	sleep(6)
	var/turf/TB = get_turf(owner)
	to_chat(owner, "<span class='userdanger'>[attacker] rends you!</span>")
	playsound(TB, attacker.attack_sound, 100, TRUE, -1)
	owner.adjustBruteLoss(10)
	new /obj/effect/decal/cleanable/blood/bubblegum(TB)
	new /obj/effect/temp_visual/bubblegum_hands/leftsmack(TB)
	sleep(6)
	var/turf/TC = get_turf(owner)
	to_chat(owner, "<span class='userdanger'>[attacker] rends you!</span>")
	playsound(TC, attacker.attack_sound, 100, TRUE, -1)
	owner.adjustBruteLoss(10)
	new /obj/effect/decal/cleanable/blood/bubblegum(TC)
	new /obj/effect/temp_visual/bubblegum_hands/rightsmack(TC)
	sleep(6)
	var/turf/TD = get_turf(owner)
	to_chat(owner, "<span class='userdanger'>[attacker] rends you!</span>")
	playsound(TD, attacker.attack_sound, 100, TRUE, -1)
	owner.adjustBruteLoss(10)
	new /obj/effect/temp_visual/bubblegum_hands/leftpaw(TD)
	new /obj/effect/temp_visual/bubblegum_hands/leftthumb(TD)
	sleep(8)
	to_chat(owner, "<span class='userdanger'>[attacker] drags you through the blood!</span>")
	playsound(TD, 'sound/misc/enter_blood.ogg', 100, TRUE, -1)
	var/turf/targetturf = get_step(attacker, attacker.dir)
	owner.forceMove(targetturf)
	playsound(targetturf, 'sound/misc/exit_blood.ogg', 100, TRUE, -1)
	addtimer(CALLBACK(attacker, TYPE_PROC_REF(/mob/living/simple_animal/hostile/megafauna/bubblegum, FindTarget), list(owner), 1), 2)

/obj/screen/alert/status_effect/bubblegum_curse
	name = "I SEE YOU"
	desc = "YOUR SOUL WILL BE MINE FOR YOUR INSOLENCE"
	icon_state = "bubblegumjumpscare"

/obj/screen/alert/status_effect/bubblegum_curse/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/screen/alert/status_effect/bubblegum_curse/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/screen/alert/status_effect/bubblegum_curse/process()
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, 40,"#ce3030", 6, 20)
	if(new_filter)
		animate(get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)
