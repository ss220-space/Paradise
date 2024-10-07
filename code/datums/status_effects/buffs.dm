//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Shadow Mend.

/datum/status_effect/shadow_mend
	id = "shadow_mend"
	duration = 30
	alert_type = /atom/movable/screen/alert/status_effect/shadow_mend

/atom/movable/screen/alert/status_effect/shadow_mend
	name = "Shadow Mend"
	desc = "Shadowy energies wrap around your wounds, sealing them at a price. After healing, you will slowly lose health every three seconds for thirty seconds."
	icon_state = "shadow_mend"

/datum/status_effect/shadow_mend/on_apply()
	owner.visible_message("<span class='notice'>Violet light wraps around [owner]'s body!</span>", "<span class='notice'>Violet light wraps around your body!</span>")
	playsound(owner, 'sound/magic/teleport_app.ogg', 50, 1)
	return ..()

/datum/status_effect/shadow_mend/tick(seconds_between_ticks)
	owner.heal_overall_damage(15, 15)

/datum/status_effect/shadow_mend/on_remove()
	owner.visible_message("<span class='warning'>The violet light around [owner] glows black!</span>", "<span class='warning'>The tendrils around you cinch tightly and reap their toll...</span>")
	playsound(owner, 'sound/magic/teleport_diss.ogg', 50, 1)
	owner.apply_status_effect(STATUS_EFFECT_VOID_PRICE)

/datum/status_effect/shadow_empower
	id = "shadow_empower"
	alert_type = /atom/movable/screen/alert/status_effect/shadow_empower

/atom/movable/screen/alert/status_effect/shadow_empower
	name = "Darkness empower"
	desc = "Your body is enhanced with darkness and heals much stronger."
	icon_state = "glare"

/datum/status_effect/shadow_empower/on_apply()
	to_chat(owner, span_revenbignotice("You feel empowered with darkness!"))
	playsound(owner, 'sound/magic/teleport_app.ogg', 50, 1)
	return TRUE

/datum/status_effect/shadow_empower/tick(seconds_between_ticks)
	if(ishuman(owner) && owner.stat != DEAD)
		var/mob/living/carbon/human/human = owner
		human.heal_overall_damage(1,1)
		human.adjustToxLoss(-0.5)
		human.adjustBrainLoss(-1)
		human.adjustCloneLoss(-0.5)
		human.SetKnockdown(0)
		if(prob(15))
			var/obj/item/organ/external/bodypart = safepick(human.check_fractures())
			bodypart?.mend_fracture()
		if(prob(1))
			human.check_and_regenerate_organs()

/datum/status_effect/shadow_empower/on_remove()
	to_chat(owner, span_revenbignotice("You feel exhausted! Darkness no longer supports you!"))
	playsound(owner, 'sound/magic/teleport_diss.ogg', 50, 1)

/datum/status_effect/void_price
	id = "void_price"
	duration = 30 SECONDS
	tick_interval = 3 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/void_price
	/// This is how much hp you lose per tick. Each time the buff is refreshed, it increased by 1. Healing too much in a short period of time will cause your swift demise
	var/price = 3

/atom/movable/screen/alert/status_effect/void_price
	name = "Void Price"
	desc = "Black tendrils cinch tightly against you, digging wicked barbs into your flesh."
	icon_state = "shadow_mend"

/datum/status_effect/void_price/tick(seconds_between_ticks)
	playsound(owner, 'sound/weapons/bite.ogg', 50, TRUE)
	owner.adjustBruteLoss(price)

/datum/status_effect/void_price/refresh(effect, ...)
	price++
	return ..()

/datum/status_effect/blooddrunk
	id = "blooddrunk"
	duration = 10
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/blooddrunk

/atom/movable/screen/alert/status_effect/blooddrunk
	name = "Blood-Drunk"
	desc = "You are drunk on blood! Your pulse thunders in your ears! Nothing can harm you!" //not true, and the item description mentions its actual effect
	icon_state = "blooddrunk"


/datum/status_effect/blooddrunk/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.brute_mod *= 0.1
		human_owner.physiology.burn_mod *= 0.1
		human_owner.physiology.tox_mod *= 0.1
		human_owner.physiology.oxy_mod *= 0.1
		human_owner.physiology.clone_mod *= 0.1
		human_owner.physiology.stamina_mod *= 0.1
	add_attack_logs(owner, owner, "gained blood-drunk stun immunity", ATKLOG_ALL)
	owner.ignore_slowdown(TRAIT_STATUS_EFFECT(id))
	owner.add_status_effect_absorption(source = id, effect_type = list(STUN, WEAKEN, KNOCKDOWN), priority = 4)
	owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, TRUE, use_reverb = FALSE)
	return TRUE


/datum/status_effect/blooddrunk/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.brute_mod *= 10
		human_owner.physiology.burn_mod *= 10
		human_owner.physiology.tox_mod *= 10
		human_owner.physiology.oxy_mod *= 10
		human_owner.physiology.clone_mod *= 10
		human_owner.physiology.stamina_mod *= 10
	add_attack_logs(owner, owner, "lost blood-drunk stun immunity", ATKLOG_ALL)
	owner.unignore_slowdown(TRAIT_STATUS_EFFECT(id))
	owner.remove_status_effect_absorption(source = id, effect_type = list(STUN, WEAKEN, KNOCKDOWN))


/datum/status_effect/exercised
	id = "Exercised"
	duration = 1200
	alert_type = null

/datum/status_effect/exercised/on_creation(mob/living/new_owner, ...)
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)
	START_PROCESSING(SSprocessing, src) //this lasts 20 minutes, so SSfastprocess isn't needed.

/datum/status_effect/exercised/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)


/datum/status_effect/banana_power
	id = "banana_power"
	duration = -1
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/banana_power
	/// Basic heal per tick.
	var/basic_heal_amt = 10
	/// This diminishes the healing from eating bananas the higher it is.
	var/tolerance = 1
	/// Number of heal ticks.
	var/instance_duration = 10
	/// A list of integers, one for each remaining banana effect.
	var/list/active_instances = list()


/datum/status_effect/banana_power/on_apply()
	to_chat(owner, span_boldnotice("Banana juices surge through your veins, you feel invincible!"))
	apply_banana_power()
	return TRUE


/datum/status_effect/banana_power/refresh(effect, ...)
	apply_banana_power()
	..()


/datum/status_effect/banana_power/proc/apply_banana_power()
	tolerance++
	active_instances += instance_duration
	owner.remove_CC()
	if(tolerance > 2)
		to_chat(owner, span_warning("Eating so many bananas will not enhance healing, only prolong it and make weaker!"))


/datum/status_effect/banana_power/tick(seconds_between_ticks)
	var/active_instances_length = length(active_instances)
	if(active_instances_length >= 1)
		var/heal_amount = (active_instances_length / tolerance) * basic_heal_amt
		if(isanimal(owner))
			var/mob/living/simple_animal/s_owner = owner
			s_owner.adjustHealth(-heal_amount)
		else
			var/update = NONE
			update |= owner.heal_overall_damage(heal_amount, heal_amount, updating_health = FALSE)
			update |= owner.heal_damage_type(heal_amount, OXY, FALSE)
			if(update)
				owner.updatehealth("banana_power")
		var/list/expired_instances = list()
		for(var/i in 1 to active_instances_length)
			active_instances[i]--
			if(active_instances[i] <= 0)
				expired_instances += active_instances[i]
		active_instances -= expired_instances
	tolerance = max(tolerance - 0.05, 1)
	if(tolerance <= 1 && !length(active_instances))
		qdel(src)


/atom/movable/screen/alert/status_effect/banana_power
	name = "Banana power"
	desc = "Your body has been infused with banana juices, you will heal damage over time!"
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "banana_power"


//Hippocratic Oath: Applied when the Rod of Asclepius is activated.
/datum/status_effect/hippocraticOath
	id = "Hippocratic Oath"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 25
	examine_text = "<span class='notice'>They seem to have an aura of healing and helpfulness about them.</span>"
	alert_type = null

	var/datum/component/aura_healing/aura_healing
	var/hand
	var/deathTick = 0

/datum/status_effect/hippocraticOath/on_apply()
	var/static/list/organ_healing = list(
		"brain" = 1.4,
	)

	aura_healing = owner.AddComponent( \
		/datum/component/aura_healing, \
		range = 7, \
		brute_heal = 1.4, \
		burn_heal = 1.4, \
		toxin_heal = 1.4, \
		suffocation_heal = 1.4, \
		stamina_heal = 1.4, \
		clone_heal = 0.4, \
		simple_heal = 1.4, \
		mend_fractures_chance = 5, \
		stop_internal_bleeding_chance = 5, \
		organ_healing = organ_healing, \
		healing_color = "#375637", \
	)

	//Makes the user passive, it's in their oath not to harm!
	ADD_TRAIT(owner, TRAIT_PACIFISM, "hippocraticOath")
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(owner)
	return ..()

/datum/status_effect/hippocraticOath/on_remove()
	QDEL_NULL(aura_healing)
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "hippocraticOath")
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.remove_hud_from(owner)

/datum/status_effect/hippocraticOath/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		if(deathTick < 4)
			deathTick += 1
		else
			owner.visible_message("<span class='notice'>[owner]'s soul is absorbed into the rod, relieving the previous snake of its duty.</span>")
			var/mob/living/simple_animal/hostile/retaliate/poison/snake/healSnake = new(owner.loc)
			var/list/chems = list("bicaridine", "perfluorodecalin", "kelotane")
			healSnake.poison_type = pick(chems)
			healSnake.name = "Asclepius's Snake"
			healSnake.real_name = "Asclepius's Snake"
			healSnake.desc = "A mystical snake previously trapped upon the Rod of Asclepius, now freed of its burden. Unlike the average snake, its bites contain chemicals with minor healing properties."
			new /obj/effect/decal/cleanable/ash(owner.loc)
			new /obj/item/rod_of_asclepius(owner.loc)
			qdel(owner)
	else
		if(ishuman(owner))
			var/mob/living/carbon/human/itemUser = owner
			var/obj/item/heldItem = (hand ==  1 ? itemUser.l_hand : itemUser.r_hand)
			if(!heldItem || !istype(heldItem, /obj/item/rod_of_asclepius)) //Checks to make sure the rod is still in their hand
				var/obj/item/rod_of_asclepius/newRod = new(itemUser.loc)
				newRod.activated()
				if(hand)
					itemUser.drop_l_hand(TRUE)
					if(itemUser.put_in_l_hand(newRod, TRUE))
						to_chat(itemUser, "<span class='notice'>The Rod of Asclepius suddenly grows back out of your arm!</span>")
					else
						if(!itemUser.get_organ(BODY_ZONE_L_ARM))
							new /obj/item/organ/external/arm(itemUser)
						new /obj/item/organ/external/hand(itemUser)
						itemUser.update_body()
						itemUser.put_in_l_hand(newRod, TRUE)
						to_chat(itemUser, "<span class='notice'>Your arm suddenly grows back with the Rod of Asclepius still attached!</span>")
				else
					itemUser.drop_r_hand(TRUE)
					if(itemUser.put_in_r_hand(newRod, TRUE))
						to_chat(itemUser, "<span class='notice'>The Rod of Asclepius suddenly grows back out of your arm!</span>")
					else
						if(!itemUser.get_organ(BODY_ZONE_R_ARM))
							new /obj/item/organ/external/arm/right(itemUser)
						new /obj/item/organ/external/hand/right(itemUser)
						itemUser.update_body()
						itemUser.put_in_r_hand(newRod, TRUE)
						to_chat(itemUser, "<span class='notice'>Your arm suddenly grows back with the Rod of Asclepius still attached!</span>")

			//Because a servant of medicines stops at nothing to help others, lets keep them on their toes and give them an additional boost.
			if(itemUser.health < itemUser.maxHealth)
				new /obj/effect/temp_visual/heal(get_turf(itemUser), "#375637")
			var/update = NONE
			update |= itemUser.heal_overall_damage(1.5, 1.5, updating_health = FALSE)
			update |= itemUser.heal_damages(tox = 1.5, oxy = 1.5, clone = 0.5, stamina = 1.5, brain = 1.5, updating_health = FALSE)
			if(update)
				owner.updatehealth("Hippocratic Oath")


/atom/movable/screen/alert/status_effect/regenerative_core
	name = "Reinforcing Tendrils"
	desc = "You can move faster than your broken body could normally handle!"
	icon_state = "regenerative_core"
	name = "Regenerative Core Tendrils"

/datum/status_effect/regenerative_core
	id = "Regenerative Core"
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/regenerative_core


/datum/status_effect/regenerative_core/on_apply()
	owner.ignore_slowdown(TRAIT_STATUS_EFFECT(id))
	owner.heal_overall_damage(25, 25, affect_robotic = TRUE)
	owner.remove_CC()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.set_bodytemperature(H.dna ? H.dna.species.body_temperature : BODYTEMP_NORMAL)
		if(is_mining_level(H.z) || istype(get_area(H), /area/ruin/space/bubblegum_arena))
			for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
				bodypart.stop_internal_bleeding()
				bodypart.mend_fracture()
		else
			to_chat(owner, "<span class='warning'>...But the core was weakened, it is not close enough to the rest of the legions of the necropolis.</span>")
	else
		owner.set_bodytemperature(BODYTEMP_NORMAL)
	return TRUE


/datum/status_effect/regenerative_core/on_remove()
	owner.unignore_slowdown(TRAIT_STATUS_EFFECT(id))


/atom/movable/screen/alert/status_effect/fleshmend
	name = "Fleshmend"
	desc = "Our wounds are rapidly healing"
	icon_state = "fleshmend"

/datum/status_effect/fleshmend
	id = "fleshmend"
	duration = -1
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/fleshmend
	/// This diminishes the healing of fleshmend the higher it is.
	var/tolerance = 1
	/// This diminishes the healing of fleshmend if the user is cold when it is activated
	var/freezing = FALSE
	/// Number of heal ticks.
	var/instance_duration = 10
	/// A list of integers, one for each remaining instance of fleshmend.
	var/list/active_instances = list()
	var/ticks = 0


/datum/status_effect/fleshmend/on_apply()
	apply_new_fleshmend()
	return TRUE


/datum/status_effect/fleshmend/refresh(effect, ...)
	apply_new_fleshmend()
	..()

/datum/status_effect/fleshmend/proc/apply_new_fleshmend()
	tolerance += 1
	freezing = (owner.bodytemperature + 50 <= owner.dna.species.body_temperature)
	if(freezing)
		to_chat(owner, span_warning("Our healing's effectiveness is reduced by our cold body!"))
	active_instances += instance_duration

/datum/status_effect/fleshmend/tick(seconds_between_ticks)
	if(length(active_instances) >= 1)
		var/heal_amount = (length(active_instances) / tolerance) * (freezing ? 2 : 10)
		var/blood_restore = 30 * length(active_instances)
		var/update = NONE
		update |= owner.heal_overall_damage(heal_amount, heal_amount, updating_health = FALSE)
		update |= owner.heal_damage_type(heal_amount, OXY, FALSE)
		if(update)
			owner.updatehealth("fleshmend")
		if(!HAS_TRAIT(owner, TRAIT_NO_BLOOD_RESTORE))
			owner.blood_volume = min(owner.blood_volume + blood_restore, BLOOD_VOLUME_NORMAL)
		var/list/expired_instances = list()
		for(var/i in 1 to length(active_instances))
			active_instances[i]--
			if(active_instances[i] <= 0)
				expired_instances += active_instances[i]
		active_instances -= expired_instances
	tolerance = max(tolerance - 0.05, 1)
	if(tolerance <= 1 && length(active_instances) == 0)
		qdel(src)


/datum/status_effect/speedlegs
	id = "gottagofast"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 4 SECONDS
	alert_type = null
	var/stacks = 0
	/// A reference to the changeling's changeling antag datum.
	var/datum/antagonist/changeling/cling


/datum/status_effect/speedlegs/on_apply()
	cling = owner?.mind?.has_antag_datum(/datum/antagonist/changeling)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/strained_muscles)
	return TRUE


/datum/status_effect/speedlegs/tick(seconds_between_ticks)
	if(owner.body_position == LYING_DOWN)
		to_chat(owner, span_danger("We are unable to use our legs, while lying!"))
		qdel(src)
	else if(owner.stat || owner.staminaloss >= 90 || cling.chem_charges <= (stacks + 1) * 3)
		to_chat(owner, span_danger("Our muscles relax without the energy to strengthen them."))
		owner.Weaken(6 SECONDS)
		qdel(src)
	else
		stacks++
		cling.chem_charges -= stacks * 3 //At first the changeling may regenerate chemicals fast enough to nullify fatigue, but it will stack
		if(stacks == 7) //Warning message that the stacks are getting too high
			to_chat(owner, span_warning("Our legs are really starting to hurt..."))


/datum/status_effect/speedlegs/before_remove()
	if(stacks < 3 && !(owner.stat || owner.staminaloss >= 90 || cling.chem_charges <= (stacks + 1) * 3)) //We don't want people to turn it on and off fast, however, we need it forced off if the 3 later conditions are met.
		to_chat(owner, span_notice("Our muscles just tensed up, they will not relax so fast."))
		return FALSE
	return TRUE


/datum/status_effect/speedlegs/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/strained_muscles)
	if(!owner.IsWeakened())
		to_chat(owner, span_notice("Our muscles relax."))
		if(stacks >= 7)
			to_chat(owner, span_danger("We collapse in exhaustion."))
			owner.Weaken(6 SECONDS)
			owner.emote("gasp")
	cling.genetic_damage += stacks
	cling = null


/datum/status_effect/panacea
	id = "panacea"
	duration = 20 SECONDS
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null


/datum/status_effect/panacea/tick(seconds_between_ticks)
	owner.heal_damages(tox = 5, brain = 5)	//Has the same healing as 20 charcoal, but happens faster
	owner.radiation = max(0, owner.radiation - 70) //Same radiation healing as pentetic
	owner.AdjustDrunk(-12 SECONDS) //50% stronger than antihol
	owner.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 10)
	for(var/datum/reagent/reagent in owner.reagents.reagent_list)
		if(!reagent.harmless)
			owner.reagents.remove_reagent(reagent.id, 2)


/datum/status_effect/terror/regeneration
	id = "terror_regen"
	duration = 250
	alert_type = null

/datum/status_effect/terror/regeneration/tick(seconds_between_ticks)
	owner.adjustBruteLoss(-6)

/datum/status_effect/terror/food_regen
	id = "terror_food_regen"
	duration = 250
	alert_type = null


/datum/status_effect/terror/food_regen/tick(seconds_between_ticks)
	owner.adjustBruteLoss(-(owner.maxHealth/20))


/datum/status_effect/hope
	id = "hope"
	duration = -1
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/hope

/atom/movable/screen/alert/status_effect/hope
	name = "Hope."
	desc = "A ray of hope beyond dispair."
	icon_state = "hope"

/datum/status_effect/hope/tick(seconds_between_ticks)
	if(owner.stat == DEAD || owner.health <= HEALTH_THRESHOLD_DEAD) // No dead healing, or healing in dead crit
		return
	if(owner.health > 50)
		if(prob(0.5))
			hope_message()
		return
	var/heal_multiplier = min(3, ((50 - owner.health) / 50 + 1)) // 1 hp at 50 health, 2 at 0, 3 at -50
	var/update = NONE
	update |= owner.heal_overall_damage(heal_multiplier * 0.5, heal_multiplier * 0.5, updating_health = FALSE)
	update |= owner.heal_damage_type(heal_multiplier, OXY, FALSE)
	if(update)
		owner.updatehealth("hope")
	if(prob(heal_multiplier * 2))
		hope_message()

/datum/status_effect/hope/proc/hope_message()
	var/list/hope_messages = list("You are filled with [pick("hope", "determination", "strength", "peace", "confidence", "robustness")].",
							"Don't give up!",
							"You see your [pick("friends", "family", "coworkers", "self")] [pick("rooting for you", "cheering you on", "worrying about you")].",
							"You can't give up now, keep going!",
							"But you refused to die!",
							"You have been through worse, you can do this!",
							"People need you, do not [pick("give up", "stop", "rest", "pass away", "falter", "lose hope")] yet!",
							"This person is not nearly as robust as you!",
							"You ARE robust, don't let anyone tell you otherwise!",
							"[owner], don't lose hope, the future of the station depends on you!",
							"Do not follow the light yet!")
	var/list/un_hopeful_messages = list("DON'T FUCKING DIE NOW COWARD!",
							"Git Gud, [owner]",
							"I bet a [pick("vox", "vulp", "nian", "tajaran", "baldie")] could do better than you!",
							"You hear people making fun of you for getting robusted.")
	if(prob(99))
		to_chat(owner, "<span class='notice'>[pick(hope_messages)]</span>")
	else
		to_chat(owner, "<span class='cultitalic'>[pick(un_hopeful_messages)]</span>")


/datum/status_effect/thrall_net
	id = "thrall_net"
	tick_interval = 2 SECONDS
	duration = -1
	alert_type = null
	var/blood_cost_per_tick = 5
	var/list/target_UIDs = list()
	var/datum/antagonist/vampire/vamp


/datum/status_effect/thrall_net/on_creation(mob/living/new_owner, datum/antagonist/vampire/V, ...)
	. = ..()
	vamp = V
	START_PROCESSING(SSfastprocess, src)
	target_UIDs += owner.UID()
	var/list/view_cache = view(7, owner)
	for(var/datum/mind/M in owner.mind.som.serv)
		if(!M.has_antag_datum(/datum/antagonist/mindslave/thrall))
			continue

		if(!(M.current in view_cache))
			continue

		if(M.current.stat == DEAD)
			continue

		target_UIDs += M.current.UID()
		M.current.Beam(owner, "sendbeam", time = 2 SECONDS, maxdistance = 7)


/datum/status_effect/thrall_net/tick(seconds_between_ticks)
	var/total_damage = 0
	var/list/view_cache = view(7, owner)
	for(var/uid in target_UIDs)
		var/mob/living/L = locateUID(uid)
		if(!(L in view_cache) || L.stat == DEAD)
			target_UIDs -= uid
			continue
		total_damage += (L.maxHealth - L.health)
		L.Beam(owner, "sendbeam", time = 2 SECONDS, maxdistance = 7)

	var/average_damage = total_damage / length(target_UIDs)

	for(var/uid in target_UIDs)
		var/mob/living/L = locateUID(uid)
		var/current_damage = L.maxHealth - L.health
		if(current_damage == average_damage)
			continue
		if(current_damage > average_damage)
			var/heal_amount = current_damage - average_damage
			L.heal_ordered_damage(heal_amount, list(BRUTE, BURN, TOX, OXY, CLONE))
		else
			var/damage_amount = average_damage - current_damage
			L.adjustFireLoss(damage_amount)

	vamp.bloodusable = max(vamp.bloodusable - blood_cost_per_tick, 0)
	if(!vamp.bloodusable || length(target_UIDs) <= 1) // if there is one left in the list, its only the vampire.
		qdel(src)


/datum/status_effect/thrall_net/on_remove()
	. = ..()
	vamp = null


/datum/status_effect/bloodswell
	id = "bloodswell"
	duration = 30 SECONDS
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/blood_swell
	var/bonus_damage_applied = FALSE


/atom/movable/screen/alert/status_effect/blood_swell
	name = "Blood Swell"
	desc = "Your body has been infused with crimson magics, your resistance to attacks has greatly increased!"
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "blood_swell_status"


/datum/status_effect/bloodswell/on_apply()
	. = ..()
	if(!. || !ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner

	ADD_TRAIT(human_owner, TRAIT_NO_GUNS, VAMPIRE_TRAIT)

	human_owner.physiology.brute_mod *= 0.3
	human_owner.physiology.burn_mod *= 0.6
	human_owner.physiology.stamina_mod *= 0.3
	human_owner.physiology.stun_mod *= 0.3

	var/datum/antagonist/vampire/V = human_owner.mind.has_antag_datum(/datum/antagonist/vampire)
	if(V.get_ability(/datum/vampire_passive/blood_swell_upgrade))
		bonus_damage_applied = TRUE
		human_owner.physiology.punch_damage_low += 14
		human_owner.physiology.punch_damage_high += 14
		human_owner.physiology.punch_stun_threshold += 10	//higher chance to stun but not 100%


/datum/status_effect/bloodswell/on_remove()
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/human_owner = owner

	REMOVE_TRAIT(human_owner, TRAIT_NO_GUNS, VAMPIRE_TRAIT)

	human_owner.physiology.brute_mod /= 0.3
	human_owner.physiology.burn_mod /= 0.6
	human_owner.physiology.stamina_mod /= 0.3
	human_owner.physiology.stun_mod /= 0.3

	if(bonus_damage_applied)
		bonus_damage_applied = FALSE
		human_owner.physiology.punch_damage_low -= 14
		human_owner.physiology.punch_damage_high -= 14
		human_owner.physiology.punch_stun_threshold -= 10


/datum/status_effect/blood_rush
	id = "bloodrush"
	alert_type = /atom/movable/screen/alert/status_effect/blood_rush
	duration = 10 SECONDS


/datum/status_effect/blood_rush/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/blood_rush)
	return TRUE


/datum/status_effect/blood_rush/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/blood_rush)


/atom/movable/screen/alert/status_effect/blood_rush
	name = "Blood Rush"
	desc = "Your body is infused with blood magic, boosting your movement speed."
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "blood_rush_status"

/datum/status_effect/dragon_strength //less powerfull than hope, but works the same way
	id = "dragon strength"
	duration = -1
	tick_interval = 3 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null

/datum/status_effect/dragon_strength/tick(seconds_between_ticks)
	if(owner.stat == DEAD || owner.health <= HEALTH_THRESHOLD_DEAD) // No dead healing, or healing in dead crit
		return
	if(owner.health > 30)
		if(prob(2))
			war_message()
		return
	var/heal_multiplier = min(3, ((40 - owner.health) / 50 + 1)) // 1 hp at 40 health, 2 at -10, 3 at -60
	var/update = NONE
	update |= owner.heal_overall_damage(heal_multiplier * 0.5, heal_multiplier * 0.5, updating_health = FALSE)
	update |= owner.heal_damage_type(heal_multiplier, OXY, FALSE)
	if(update)
		owner.updatehealth("dragon strength")
	if(prob(5))
		hope_message()

/datum/status_effect/dragon_strength/proc/hope_message()
	var/list/hope_messages = list("You are filled with [pick("determination", "strength", "robustness", "power")].",
							"Your most pleasant memories flash through your mind.",
							"You can't give up, keep going!",
							"Pull yourself together!",
							"You are the strongest hunter, you can handle it!",
							"Don't forget how you got this amulet, hunter!",
							"All these persons are not nearly as powerful as you!",
							"You ARE robust, don't you dare die now!",
							"Some stupid scars can't stop you!",
							"You still have monsters to kill, don't die!")
	to_chat(owner, "<span class='notice'>[pick(hope_messages)]</span>")

/datum/status_effect/dragon_strength/proc/war_message()
	var/list/war_messages = list("You feel incredible strength in your heart.",
							"You feel a pleasant smell of human blood.",
							"You feel envious glances.",
							"You want to kill someone.",
							"All your glorious battles flash through your memory.",
							"No one can conquer you.",
							"You can feel fire in your soul.",
							"Don't forget how you got this amulet, hunter.")
	to_chat(owner, "<span class='warning'>[pick(war_messages)]</span>")

/atom/movable/screen/alert/status_effect/dash
	name = "Dash"
	desc = "You have the ability to dash!"
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "genetic_jump"

/datum/status_effect/dash
	id = "dash"
	duration = 5 SECONDS
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/dash


/datum/status_effect/drill_payback
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/drilled_successfully = FALSE
	var/times_warned = 0
	var/obj/structure/safe/drilled

/datum/status_effect/drill_payback/on_creation(mob/living/new_owner, obj/structure/safe/safe)
	drilled = safe
	return ..()

/datum/status_effect/drill_payback/on_apply()
	owner.overlay_fullscreen("payback", /atom/movable/screen/fullscreen/payback, 0)
	addtimer(CALLBACK(src, PROC_REF(payback_phase_2)), 2.7 SECONDS)
	return TRUE

/datum/status_effect/drill_payback/proc/payback_phase_2()
	owner.clear_fullscreen("payback")
	owner.overlay_fullscreen("payback", /atom/movable/screen/fullscreen/payback, 1)

/datum/status_effect/drill_payback/tick(seconds_between_ticks)
	if(!drilled_successfully && (get_dist(owner, drilled) >= 9)) // No privelegies for that who leave his target.
		to_chat(owner, span_userdanger("Get back to the safe, they are going to get the drill!"))
		times_warned++
		if(times_warned >= 6)
			owner.remove_status_effect(STATUS_EFFECT_DRILL_PAYBACK)
			return
	if(owner.stat != DEAD)
		var/update = NONE
		update |= owner.heal_overall_damage(3, 3, updating_health = FALSE)
		update |= owner.heal_damage_type(25, STAMINA, FALSE)
		if(update)
			owner.updatehealth("drill_payback")


/datum/status_effect/drill_payback/on_remove()
	..()
	owner.clear_fullscreen("payback")
