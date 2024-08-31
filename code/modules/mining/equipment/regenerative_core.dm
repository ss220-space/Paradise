/*********************Hivelord stabilizer****************/
/obj/item/hivelordstabilizer
	name = "hivelord stabilizer"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	desc = "Inject a hivelord core with this stabilizer to preserve its healing powers indefinitely."
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=3"

/obj/item/hivelordstabilizer/afterattack(obj/item/organ/internal/M, mob/user, proximity, params)
	. = ..()
	if(!proximity)
		return
	var/obj/item/organ/internal/regenerative_core/C = M
	if(!istype(C, /obj/item/organ/internal/regenerative_core))
		to_chat(user, span_warning("The stabilizer only works on certain types of monster organs, generally regenerative in nature."))
		return ..()

	C.preserved()
	balloon_alert(user, "ядро стабилизировано!") //replace to "organ" when there is more than one kind of regenerative organ
	qdel(src)

/************************Hivelord core*******************/
/obj/item/organ/internal/regenerative_core
	name = "regenerative core"
	desc = "All that remains of a hivelord. It can be used to help keep your body going, but it will rapidly decay into uselessness."
	icon_state = "roro core 2"
	item_flags = NOBLUDGEON
	slot = INTERNAL_ORGAN_HIVECORE
	parent_organ_zone = BODY_ZONE_CHEST
	force = 0
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/inert = 0
	var/preserved = 0

/obj/item/organ/internal/regenerative_core/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(inert_check)), 2400)

/obj/item/organ/internal/regenerative_core/proc/inert_check()
	if(!preserved)
		go_inert()

/obj/item/organ/internal/regenerative_core/proc/preserved(implanted = 0)
	preserved = TRUE
	update_icon()
	desc = "All that remains of a hivelord. It is preserved, allowing you to use it to heal completely without danger of decay."
	if(implanted)
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "implanted"))
	else
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "stabilizer"))

/obj/item/organ/internal/regenerative_core/proc/go_inert()
	inert = TRUE
	name = "decayed regenerative core"
	desc = "All that remains of a hivelord. It has decayed, and is completely useless."
	SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "inert"))
	update_icon()

/obj/item/organ/internal/regenerative_core/ui_action_click(mob/user, datum/action/action, leftclick)
	if(inert)
		to_chat(owner, "<span class='notice'>[src] breaks down as it tries to activate.</span>")
	else
		owner.revive()
	qdel(src)

/obj/item/organ/internal/regenerative_core/on_life()
	..()
	if(owner.health < HEALTH_THRESHOLD_CRIT)
		ui_action_click()

///Handles applying the core, logging and status/mood events.
/obj/item/organ/internal/regenerative_core/proc/applyto(atom/target, mob/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(inert)
			balloon_alert(user, "ядро сгнило!")
			return
		else
			if(H.stat == DEAD)
				balloon_alert(user, "не сработает на трупах!")
				return
			if(H != user)
				H.visible_message("[user] forces [H] to apply [src]... Black tendrils entangle and reinforce [H.p_them()]!")
				SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "other"))
			else
				to_chat(user, span_notice("You start to smear [src] on yourself. Disgusting tendrils hold you together and allow you to keep moving, but for how long?"))
				SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))
			H.apply_status_effect(STATUS_EFFECT_REGENERATIVE_CORE)
			user.temporarily_remove_item_from_inventory(src)
			qdel(src)

/obj/item/organ/internal/regenerative_core/afterattack(atom/target, mob/user, proximity_flag, params)
	. = ..()
	if(proximity_flag)
		applyto(target, user)

/obj/item/organ/internal/regenerative_core/attack_self(mob/user)
	applyto(user, user)

/obj/item/organ/internal/regenerative_core/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(!preserved && !inert)
		preserved(TRUE)
		owner.visible_message("<span class='notice'>[src] stabilizes as it's inserted.</span>")

/obj/item/organ/internal/regenerative_core/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(!inert && !special)
		owner.visible_message("<span class='notice'>[src] rapidly decays as it's removed.</span>")
		go_inert()
	return ..()

/obj/item/organ/internal/regenerative_core/prepare_eat()
	return null

/*************************Legion core********************/
/obj/item/organ/internal/regenerative_core/legion
	desc = "A strange rock that crackles with power. It can be used to heal completely, but it will rapidly decay into uselessness."
	icon_state = "legion_soul"

/obj/item/organ/internal/regenerative_core/legion/Initialize(mapload)
	. = ..()
	update_icon()


/obj/item/organ/internal/regenerative_core/legion/update_icon_state()
	icon_state = inert ? "legion_soul_inert" : "legion_soul"


/obj/item/organ/internal/regenerative_core/legion/update_overlays()
	. = ..()
	if(!inert && !preserved)
		. += "legion_soul_crackle"
	addtimer(CALLBACK(src, PROC_REF(buttons_update)), 0.1 SECONDS)


/obj/item/organ/internal/regenerative_core/legion/proc/buttons_update()
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()


/obj/item/organ/internal/regenerative_core/legion/go_inert()
	..()
	desc = "[src] has become inert. It has decayed, and is completely useless."

/obj/item/organ/internal/regenerative_core/legion/preserved(implanted = 0)
	..()
	desc = "[src] has been stabilized. It is preserved, allowing you to use it to heal completely without danger of decay."

/************************Legion tumor********************/

/obj/item/organ/internal/legion_tumour
	name = "legion tumour"
	desc = "A mass of pulsing flesh and dark tendrils, containing the power to regenerate flesh at a terrible cost."
	icon_state = "legion_remains"
	slot = INTERNAL_ORGAN_PARASITE_EGG
	parent_organ_zone = BODY_ZONE_CHEST
	/// What stage of growth the corruption has reached.
	var/stage = 0
	/// We apply this status effect periodically or when used on someone
	var/applied_status = /datum/status_effect/regenerative_core
	/// How long have we been in this stage?
	var/elapsed_time = 0 SECONDS
	/// How long does it take to advance one stage?
	var/growth_time = 80 SECONDS // Long enough that if you go back to lavaland without realising it you're not totally fucked
	/// What kind of mob will we transform into?
	var/spawn_type = /mob/living/simple_animal/hostile/asteroid/hivelord/legion
	/// Spooky sounds to play as you start to turn
	var/static/list/spooky_sounds = list(
		'sound/voice/lowHiss1.ogg',
		'sound/voice/lowHiss2.ogg',
		'sound/voice/lowHiss3.ogg',
		'sound/voice/lowHiss4.ogg',
	)

/obj/item/organ/internal/legion_tumour/insert(mob/living/carbon/egg_owner, special)
	. = ..()
	ADD_TRAIT(egg_owner, TRAIT_LEGION_TUMOUR, GENERIC_TRAIT)
	egg_owner.med_hud_set_status()

/obj/item/organ/internal/legion_tumour/remove(mob/living/carbon/egg_owner, special)
	stage = 0
	elapsed_time = 0
	if(egg_owner)
		REMOVE_TRAIT(egg_owner, TRAIT_LEGION_TUMOUR, GENERIC_TRAIT)
		egg_owner.med_hud_set_status()
	. = ..()


/obj/item/organ/internal/legion_tumour/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(try_apply(target, user))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/// Smear it on someone like a regen core, why not. Make sure they're alive though.
/obj/item/organ/internal/legion_tumour/proc/try_apply(mob/living/carbon/human/target, mob/user)
	if(!ishuman(target))
		return FALSE
	if(target.stat == DEAD)
		balloon_alert(user, "не сработает на трупах!")
		return FALSE
	. = TRUE
	if(target != user)
		target.visible_message(
			span_warning("[user] forces [target] to apply [src]... Black tendrils entangle and reinforce [target.p_them()]!"),
			span_notice("You have forced [target] to apply [src]... Black tendrils entangle and reinforce [target.p_them()]!"),
		)
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "other"))
	else
		to_chat(user, span_notice("You start to smear [src] on yourself. Disgusting tendrils hold you together and allow you to keep moving, but for how long?"))
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))
	target.apply_status_effect(STATUS_EFFECT_REGENERATIVE_CORE)
	qdel(src)


/obj/item/organ/internal/legion_tumour/on_life()
	. = ..()
	if (QDELETED(src) || QDELETED(owner))
		return

	if(stage >= 2)
		if(prob(stage / 5)) //umhh, it's about ~0.4% every tick on stage 2 0.4% on stage 2, 0.6% on 3, etc.
			to_chat(owner, span_notice("You feel a bit better."))
			owner.apply_status_effect(applied_status) // It's not all bad!
		if(prob(1))
			owner.emote("twitch")
	switch(stage)
		if(2, 3)
			if(prob(1))
				to_chat(owner, span_danger("Your chest spasms!"))
			if(prob(1))
				to_chat(owner, span_danger("You feel weak."))
			if(prob(1))
				SEND_SOUND(owner, sound(pick(spooky_sounds)))
			if(prob(2))
				owner.vomit()
		if(4, 5)
			if(prob(2))
				to_chat(owner, span_danger("Something flexes under your skin."))
			if(prob(2))
				SEND_SOUND(owner, sound(pick(spooky_sounds)))
			if(prob(3))
				owner.vomit(0, 1)
				if(prob(50))
					var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/child = new(owner.loc)
					child.faction = owner.faction.Copy()
			if(prob(3))
				to_chat(owner, span_danger("Your muscles ache."))
				owner.adjustBruteLoss(20)
	if(stage == 5)
		if(prob(10))
			infest()
		return
	elapsed_time += 1 SECONDS
	if(elapsed_time < growth_time)
		return
	stage++
	elapsed_time = 0
	if(stage == 5)
		to_chat(owner, span_danger("Something is moving under your skin!"))

/// Consume our host
/obj/item/organ/internal/legion_tumour/proc/infest()
	if(QDELETED(src) || QDELETED(owner))
		return
	owner.visible_message(span_boldwarning("Black tendrils burst from [owner]'s flesh, covering them in amorphous flesh!"))
	var/mob/living/simple_animal/hostile/asteroid/hivelord/legion/L

	if(HAS_TRAIT(owner, TRAIT_DWARF)) //dwarf legions aren't just fluff!
		L = new /mob/living/simple_animal/hostile/asteroid/hivelord/legion/dwarf(owner.loc)
	else
		L = new(owner.loc)
	owner.death()
	owner.adjustBruteLoss(1000)
	L.stored_mob = owner
	owner.forceMove(L)
	if(prob(75) && owner.get_int_organ(/obj/item/organ/internal/legion_tumour))
		qdel(src) // Congratulations you haven't won a very special prize: second cancer in a row!
	else
		stage = 0
		elapsed_time = 0

/obj/item/organ/internal/legion_tumour/on_find(mob/living/finder)
	. = ..()
	to_chat(finder, span_warning("There's an enormous tumour in [owner]'s chest!"))
	if(stage < 4)
		to_chat(finder, span_notice("Its tendrils seem to twitch towards the light."))
		return
	to_chat(finder, span_notice("Its pulsing tendrils reach all throughout the body."))
	if(prob(stage * 2))
		infest()
