#define HAS_COMBOS LAZYLEN(combos)
#define COMBO_ALIVE_TIME 5 SECONDS // How long the combo stays alive when no new attack is done

/datum/martial_art
	var/name = "Martial Art"
	var/streak = ""
	// var/max_streak_length = 6
	var/temporary = FALSE
	var/owner_UID
	/// The permanent style.
	var/datum/martial_art/base = null
	/// Chance to deflect projectiles while on throw mode.
	var/deflection_chance = 0
	/// Can it reflect projectiles in a random direction?
	var/reroute_deflection = FALSE
	///Chance to block melee attacks using items while on throw mode.
	var/block_chance = 0
	//Chance to reflect projectiles but NINJA!
	var/reflection_chance = 0
	var/help_verb = null
	/// Set to TRUE to prevent users of this style from using guns (sleeping carp, highlander). They can still pick them up, but not fire them.
	var/no_guns = FALSE
	/// Message to tell the style user if they try and use a gun while no_guns = TRUE (DISHONORABRU!)
	var/no_guns_message = ""

	/// If the martial art has it's own explaination verb.
	var/has_explaination_verb = FALSE

	/// If the martial art gives dirslash
	var/has_dirslash = TRUE

	/// What combos can the user do? List of combo types.
	var/list/combos = list()
	/// What combos are currently (possibly) being performed.
	var/list/datum/martial_art/current_combos = list()
	/// When the last hit happened.
	// var/last_hit = 0
	/// Stores the timer_id for the combo timeout timer
	var/combo_timer
	/// If the user is preparing a martial arts stance.
	var/in_stance = FALSE
	/// The priority of which martial art is picked from all the ones someone knows, the higher the number, the higher the priority.
	var/weight = 0

/datum/martial_art/New()
	. = ..()
	reset_combos()

/datum/martial_art/proc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_DISARM, A, D)

/datum/martial_art/proc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_HARM, A, D)

/datum/martial_art/proc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_GRAB, A, D)

/datum/martial_art/proc/help_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_HELP, A, D)

/datum/martial_art/proc/can_use(mob/living/carbon/human/H)
	return !HAS_TRAIT(H, TRAIT_PACIFISM)

/datum/martial_art/proc/act(step, mob/living/carbon/human/user, mob/living/carbon/human/target, could_start_new_combo = TRUE)
	if(!can_use(user))
		return MARTIAL_ARTS_CANNOT_USE
/*
	if(last_hit + COMBO_ALIVE_TIME < world.time)
		reset_combos()
	last_hit = world.time
*/
	if(HAS_COMBOS)
		if(combo_timer)
			deltimer(combo_timer)
		combo_timer = addtimer(CALLBACK(src, PROC_REF(reset_combos)), COMBO_ALIVE_TIME, TIMER_UNIQUE | TIMER_STOPPABLE)
		streak += intent_to_streak(step)
		var/mob/living/carbon/human/owner = locateUID(owner_UID)
		if(istype(owner) && !QDELETED(owner))
			owner.hud_used.combo_display.update_icon(ALL, streak)
			return check_combos(step, user, target, could_start_new_combo)
	return FALSE

/datum/martial_art/proc/reset_combos()
	current_combos.Cut()
	streak = ""
	var/mob/living/carbon/human/owner = locateUID(owner_UID)
	if(istype(owner) && !QDELETED(owner))
		owner.hud_used.combo_display.update_icon(ALL, streak)
	for(var/combo_type in combos)
		current_combos.Add(new combo_type())

/datum/martial_art/proc/check_combos(step, mob/living/carbon/human/user, mob/living/carbon/human/target, could_start_new_combo = TRUE)
	. = FALSE
	for(var/thing in current_combos)
		var/datum/martial_combo/MC = thing
		if(!MC.check_combo(step, target))
			current_combos -= MC	// It failed so remove it
		else
			switch(MC.progress_combo(user, target, src))
				if(MARTIAL_COMBO_FAIL)
					current_combos -= MC
				if(MARTIAL_COMBO_DONE_NO_CLEAR)
					. = TRUE
					current_combos -= MC
				if(MARTIAL_COMBO_DONE)
					reset_combos()
					return TRUE
				if(MARTIAL_COMBO_DONE_BASIC_HIT)
					basic_hit(user, target)
					reset_combos()
					return TRUE
				if(MARTIAL_COMBO_DONE_CLEAR_COMBOS)
					combos.Cut()
					reset_combos()
					return TRUE
	if(!LAZYLEN(current_combos))
		reset_combos()
		if(HAS_COMBOS && could_start_new_combo)
			act(step, user, target, could_start_new_combo = FALSE)

/datum/martial_art/proc/basic_hit(mob/living/carbon/human/A, mob/living/carbon/human/D)

	var/damage = rand(A.dna.species.punchdamagelow, A.dna.species.punchdamagehigh)
	var/datum/unarmed_attack/attack = A.dna.species.unarmed

	var/atk_verb = "[pick(attack.attack_verb)]"
	if(D.lying)
		atk_verb = "kick"

	switch(atk_verb)
		if("kick")
			A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		else
			A.do_attack_animation(D, attack.animation_type)

	if(!damage)
		playsound(D.loc, attack.miss_sound, 25, 1, -1)
		D.visible_message("<span class='warning'>[A] has attempted to [atk_verb] [D]!</span>")
		return FALSE

	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, attack.attack_sound, 25, 1, -1)
	D.visible_message("<span class='danger'>[A] has [atk_verb] [D]!</span>", \
								"<span class='userdanger'>[A] has [atk_verb] [D]!</span>")

	D.apply_damage(damage, BRUTE, affecting, armor_block)
	objective_damage(A, D, damage, BRUTE)

	add_attack_logs(A, D, "Melee attacked with martial-art [src]", (damage > 0) ? null : ATKLOG_ALL)

	if((D.stat != DEAD) && damage >= A.dna.species.punchstunthreshold)
		D.visible_message("<span class='danger'>[A] has weakened [D]!!</span>", \
								"<span class='userdanger'>[A] has weakened [D]!</span>")
		D.apply_effect(4 SECONDS, WEAKEN, armor_block)
		D.forcesay(GLOB.hit_appends)
	else if(D.lying)
		D.forcesay(GLOB.hit_appends)
	return TRUE

/datum/martial_art/proc/attack_reaction(mob/living/carbon/human/defender, mob/living/carbon/human/attacker, obj/item/I, visible_message, self_message)
	if(can_use(defender) && defender.in_throw_mode && !defender.incapacitated(FALSE, TRUE))
		if(prob(block_chance))
			if(visible_message || self_message)
				defender.visible_message(visible_message, self_message)
			else
				defender.visible_message("<span class='warning'>[defender] blocks [I]!</span>")
			return TRUE

/datum/martial_art/proc/user_hit_by(atom/movable/AM, mob/living/carbon/human/H)
	return FALSE

/datum/martial_art/proc/objective_damage(mob/living/user, mob/living/target, damage, damage_type)
	var/all_objectives = user?.mind?.get_all_objectives()
	if(target.mind && all_objectives)
		for(var/datum/objective/pain_hunter/objective in all_objectives)
			if(target.mind == objective.target)
				objective.take_damage(damage, damage_type)

/datum/martial_art/proc/teach(mob/living/carbon/human/H, make_temporary = FALSE)
	if(!H.mind)
		return FALSE
	for(var/datum/martial_art/MA in H.mind.known_martial_arts)
		if(istype(MA, src))
			return FALSE
	if(has_explaination_verb)
		H.verbs |= /mob/living/carbon/human/proc/martial_arts_help
	if(has_dirslash)
		H.verbs |= /mob/living/carbon/human/proc/dirslash_enabling
		H.dirslash_enabled = TRUE
	temporary = make_temporary
	H.mind.known_martial_arts.Add(src)
	H.mind.martial_art = get_highest_weight(H)
	owner_UID = H.UID()
	return TRUE

/datum/martial_art/proc/remove(mob/living/carbon/human/H)
	var/datum/martial_art/MA = src
	if(!H.mind)
		return FALSE
	deltimer(combo_timer)
	H.mind.known_martial_arts.Remove(MA)
	H.mind.martial_art = get_highest_weight(H)
	H.verbs -= /mob/living/carbon/human/proc/martial_arts_help
	H.verbs -= /mob/living/carbon/human/proc/dirslash_enabling
	H.dirslash_enabled = initial(H.dirslash_enabled)
	return TRUE

///	Returns the martial art with the highest weight from all the ones someone knows.
/datum/martial_art/proc/get_highest_weight(mob/living/carbon/human/H)
	var/datum/martial_art/highest_weight = null
	for(var/datum/martial_art/MA in H.mind.known_martial_arts)
		if(!highest_weight || MA.weight > highest_weight.weight)
			highest_weight = MA
	return highest_weight

/mob/living/carbon/human/proc/martial_arts_help()
	set name = "Show Info"
	set desc = "Gives information about the martial arts you know."
	set category = "Martial Arts"
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		to_chat(usr, "<span class='warning'>You shouldn't have access to this verb. Report this as a bug to the github please.</span>")
		return
	H.mind.martial_art.give_explaination(H)

/mob/living/carbon/human/proc/dirslash_enabling()
	set name = "Enable/Disable direction slash"
	set desc = "If direction slash is enabled, you can attack mobs, by clicking behind their backs"
	set category = "Martial Arts"
	dirslash_enabled = !dirslash_enabled
	to_chat(src, span_notice("Directrion slash is [dirslash_enabled? "enabled" : "disabled"] now."))


/datum/martial_art/proc/give_explaination(user = usr)
	explaination_header(user)
	explaination_combos(user)
	explaination_footer(user)
	explaination_notice(user)

// Put after the header and before the footer in the explaination text
/datum/martial_art/proc/explaination_combos(user)
	if(HAS_COMBOS)
		for(var/combo_type in combos)
			var/datum/martial_combo/MC = new combo_type()
			MC.give_explaination(user)

// Put on top of the explaination text
/datum/martial_art/proc/explaination_header(user)
	return

// Put below the combos in the explaination text
/datum/martial_art/proc/explaination_footer(user)
	return

/datum/martial_art/proc/explaination_notice(user)
	return to_chat(user, "<b><i>Combo steps can be provided only with empty hand!</b></i>")

/datum/martial_art/proc/try_deflect(mob/user)
	return prob(deflection_chance)

/datum/martial_art/proc/intent_to_streak(intent)
	switch(intent)
		if(MARTIAL_COMBO_STEP_HARM)
			return "E" // these hands are rated E for everyone
		if(MARTIAL_COMBO_STEP_DISARM)
			return "D"
		if(MARTIAL_COMBO_STEP_GRAB)
			return "G"
		if(MARTIAL_COMBO_STEP_HELP)
			return "H"

//ITEMS

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot, initial)
	. = ..()

	if(!ishuman(user))
		return
	if(slot == slot_gloves)
		var/mob/living/carbon/human/H = user
		style.teach(H, TRUE)

/obj/item/clothing/gloves/boxing/dropped(mob/user, silent = FALSE)
	. = ..()

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_gloves) == src)
		style.remove(H)

/obj/item/storage/belt/champion/wrestling
	name = "Wrestling Belt"
	var/datum/martial_art/wrestling/style = new

/obj/item/storage/belt/champion/wrestling/true
	name = "Пояс Истинного Чемпиона"
	desc = "Вы - лучший! и Вы это знаете!"

/obj/item/storage/belt/champion/wrestling/equipped(mob/user, slot, initial)
	. = ..()

	if(!ishuman(user))
		return
	if(slot == slot_belt)
		var/mob/living/carbon/human/H = user
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='warning'>In spite of the grandiosity of the belt, you don't feel like getting into any fights.</span>")
			return
		style.teach(H, TRUE)
		to_chat(user, "<span class='sciradio'>You have an urge to flex your muscles and get into a fight. You have the knowledge of a thousand wrestlers before you. You can remember more by using the show info verb in the martial arts tab.</span>")

/obj/item/storage/belt/champion/wrestling/dropped(mob/user, silent = FALSE)
	. = ..()

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_belt) == src)
		style.remove(H)
		to_chat(user, "<span class='sciradio'>You no longer have an urge to flex your muscles.</span>")

/obj/item/plasma_fist_scroll
	name = "frayed scroll"
	desc = "An aged and frayed scrap of paper written in shifting runes. There are hand-drawn illustrations of pugilism."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	var/used = FALSE


/obj/item/plasma_fist_scroll/update_icon_state()
	icon_state = used ? "blankscroll" : initial(icon_state)


/obj/item/plasma_fist_scroll/update_name(updates = ALL)
	. = ..()
	name = used ? "empty scroll" : initial(name)


/obj/item/plasma_fist_scroll/update_desc(updates = ALL)
	. = ..()
	desc = used ? "It's completely blank." : initial(desc)


/obj/item/plasma_fist_scroll/attack_self(mob/user as mob)
	if(!ishuman(user))
		return

	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/plasma_fist/F = new/datum/martial_art/plasma_fist(null)
		F.teach(H)
		to_chat(H, "<span class='boldannounce'>You have learned the ancient martial art of Plasma Fist.</span>")
		used = TRUE
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)


/obj/item/sleeping_carp_scroll
	name = "mysterious scroll"
	desc = "A scroll filled with strange markings. It seems to be drawings of some sort of martial art."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"

/obj/item/sleeping_carp_scroll/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	if(user.mind && (ischangeling(user) || isvampire(user))) //Prevents changelings and vampires from being able to learn it
		if(ischangeling(user)) //Changelings
			to_chat(user, "<span class ='warning'>We try multiple times, but we are not able to comprehend the contents of the scroll!</span>")
			return
		else //Vampires
			to_chat(user, "<span class ='warning'>Your blood lust distracts you too much to be able to concentrate on the contents of the scroll!</span>")
			return

	if(istype(user.mind.martial_art, /datum/martial_art/the_sleeping_carp))
		to_chat(user, span_warning("You realise, that you have learned everything from Carp Teachings and decided to not read the scroll."))
		return

	var/datum/martial_art/the_sleeping_carp/theSleepingCarp = new(null)
	theSleepingCarp.teach(user)
	user.temporarily_remove_item_from_inventory(src)
	visible_message("<span class='warning'>[src] lights up in fire and quickly burns to ash.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/CQC_manual
	name = "old manual"
	desc = "A small, black manual. There are drawn instructions of tactical hand-to-hand combat."
	icon = 'icons/obj/library.dmi'
	icon_state = "cqcmanual"

/obj/item/CQC_manual/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return

	if(user.mind) //Prevents changelings and vampires from being able to learn it
		if(ischangeling(user))
			to_chat(user, "<span class='warning'>We try multiple times, but we simply cannot grasp the basics of CQC!</span>")
			return
		else if(isvampire(user)) //Vampires
			to_chat(user, "<span class='warning'>Your blood lust distracts you from the basics of CQC!</span>")
			return
		else if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='warning'>The mere thought of combat, let alone CQC, makes your head spin!</span>")
			return

	to_chat(user, "<span class='boldannounce'>You remember the basics of CQC.</span>")

	var/datum/martial_art/cqc/CQC = new(null)
	CQC.teach(user)
	user.temporarily_remove_item_from_inventory(src)
	visible_message("<span class='warning'>[src] beeps ominously, and a moment later it bursts up in flames.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/CQC_manual/chef
	name = "CQC Upgrade implant"
	desc = "Gives you to remember what you always forget"
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter1"
	item_state = "syringe_0"

/obj/item/CQC_manual/chef/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.mind && user.mind.assigned_role == "Chef")
		to_chat(user, "<span class='boldannounce'>You completely memorise the basics of CQC.</span>")
		var/datum/martial_art/cqc/CQC = new(null)
		CQC.teach(user)
		user.temporarily_remove_item_from_inventory(src)
		visible_message("<span class='warning'>[src] beeps ominously, and a moment later it blow up.</span>")
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)
	else
		to_chat(user, "<span class='notice'>You implant yourself, but nanobots can't find their target. You feel sharp pain in head!</span>")
		if(isliving(user))
			var/mob/living/L = user
			L.adjustBrainLoss(20)
			L.adjustFireLoss(20)
		user.temporarily_remove_item_from_inventory(src)
		visible_message("<span class='warning'>[src] beeps ominously, and a moment later it blow up!</span>")
		playsound(get_turf(src),'sound/effects/explosion2.ogg', 100, 1)
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)

/obj/item/mr_chang_technique
	name = "«Aggressive Marketing Technique»"
	desc = "Even a sneak peek on a cover of this magazine just made you 23 credit of clear profit! Wow!"
	icon = 'icons/obj/library.dmi'
	icon_state = "mr_cheng_manual"

/obj/item/mr_chang_technique/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	to_chat(user, "<span class='boldannounce'>You remember the basics of Aggressive Marketing Technique.</span>")

	var/datum/martial_art/mr_chang/mr_chang = new(null)
	mr_chang.teach(user)
	user.temporarily_remove_item_from_inventory(src)
	visible_message("<span class='warning'>[src] beeps ominously, and a moment later it bursts up in flames.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/throwing_manual
	name = "Commandos knife techniques manual"
	desc = "This is a thin black book. On the front there is a picture of a man with knives. \nContains a guide for learning the commandos knife technique with a visual representation of the application of the techniques."
	icon = 'icons/obj/library.dmi'
	icon_state = "throwingknives"

/obj/item/throwing_manual/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	to_chat(user, "<span class='boldannounce'>You remember the basics of knife throwing.</span>")

	var/datum/martial_art/throwing/MA = new
	MA.teach(user)
	user.temporarily_remove_item_from_inventory(src)
	visible_message("<span class='warning'>[src] beeps ominously, and a moment later it bursts up in flames.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/twohanded/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 24
	throwforce = 20
	throw_speed = 2
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon_state = "bostaff0"
	block_chance = 50


/obj/item/twohanded/bostaff/update_icon_state()
	icon_state = "bostaff[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/bostaff/attack(mob/target, mob/living/user)
	add_fingerprint(user)
	if((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class ='warning'>You club yourself over the head with [src].</span>")
		user.Weaken(6 SECONDS)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_organ_damage(2*force)
		return
	if(isrobot(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, "<span class='warning'>It would be dishonorable to attack a foe while [C.p_they()] cannot retaliate.</span>")
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You feel violence is not the answer.</span>")
		return
	switch(user.a_intent)
		if(INTENT_DISARM)
			if(!HAS_TRAIT(src, TRAIT_WIELDED))
				return ..()
			if(!ishuman(target))
				return ..()
			var/mob/living/carbon/human/H = target
			var/list/fluffmessages = list("[user] clubs [H] with [src]!", \
										  "[user] smacks [H] with the butt of [src]!", \
										  "[user] broadsides [H] with [src]!", \
										  "[user] smashes [H]'s head with [src]!", \
										  "[user] beats [H] with front of [src]!", \
										  "[user] twirls and slams [H] with [src]!")
			H.visible_message("<span class='warning'>[pick(fluffmessages)]</span>", \
								   "<span class='userdanger'>[pick(fluffmessages)]</span>")
			playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, 1, -1)
			H.adjustStaminaLoss(rand(13,20))
			if(prob(10))
				H.visible_message("<span class='warning'>[H] collapses!</span>", \
									   "<span class='userdanger'>Your legs give out!</span>")
				H.Weaken(8 SECONDS)
			if(H.staminaloss && !H.IsSleeping())
				var/total_health = (H.health - H.staminaloss)
				if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
					H.visible_message("<span class='warning'>[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!</span>", \
										   "<span class='userdanger'>[user] knocks you unconscious!</span>")
					H.SetSleeping(60 SECONDS)
					H.adjustBrainLoss(25)
			return
		else
			return ..()

/obj/item/twohanded/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()
	return FALSE

/obj/screen/combo
	icon_state = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = ui_combo
	layer = ABOVE_HUD_LAYER
	var/streak


/obj/screen/combo/proc/clear_streak()
	cut_overlays()
	streak = ""
	icon_state = ""


/obj/screen/combo/update_icon(updates, _streak)
	streak = _streak
	return ..()


/obj/screen/combo/update_overlays()
	. = list()
	for(var/i in 1 to length(streak))
		var/intent_text = copytext(streak, i, i + 1)
		var/image/intent_icon = image(icon, src, "combo_[intent_text]")
		intent_icon.pixel_x = 16 * (i - 1) - 8 * length(streak)
		. += intent_icon


/obj/screen/combo/update_icon_state()
	icon_state = ""
	if(!streak)
		return
	icon_state = "combo"


#undef HAS_COMBOS
#undef COMBO_ALIVE_TIME
