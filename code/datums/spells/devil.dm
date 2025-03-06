/obj/effect/proc_holder/spell/conjure_item/pitchfork
	name = "Summon Pitchfork"
	desc = "A devil's weapon of choice.  Use this to summon/unsummon your pitchfork."

	item_type = /obj/item/twohanded/pitchfork/demonic

	action_icon_state = "pitchfork"
	action_background_icon_state = "bg_demon"

	human_req = FALSE

/obj/effect/proc_holder/spell/conjure_item/pitchfork/greater
	item_type = /obj/item/twohanded/pitchfork/demonic/greater


/obj/effect/proc_holder/spell/conjure_item/pitchfork/ascended
	item_type = /obj/item/twohanded/pitchfork/demonic/ascended


/obj/effect/proc_holder/spell/conjure_item/violin
	name = "Summon golden violin"
	desc = "A devil's instrument of choice.  Use this to summon/unsummon your golden violin."

	item_type = /obj/item/instrument/violin/golden

	invocation_type = "whisper"
	invocation = "I ain't have this much fun since Georgia."

	action_icon_state = "golden_violin"
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/summon_contract
	name = "Summon infernal contract"
	desc = "Skip making a contract by hand, just do it by magic."

	invocation_type = "whisper"
	invocation = "Just sign on the dotted line."

	selection_activated_message = span_notice("You prepare a detailed contract. Click on a target to summon the contract in his hands.")
	selection_deactivated_message = span_notice("You archive the contract for later use.")

	clothes_req = FALSE
	human_req = FALSE

	school = "conjuration"
	base_cooldown = 15 SECONDS
	cooldown_min = 1 SECONDS

	action_icon_state = "spell_default"
	action_background_icon_state = "bg_demon"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/summon_contract/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.try_auto_target = FALSE
	T.range = 5
	T.click_radius = -1
	T.allowed_type = /mob/living/carbon
	return T


/obj/effect/proc_holder/spell/summon_contract/valid_target(mob/living/carbon/target, mob/user)
	return target.mind


/obj/effect/proc_holder/spell/summon_contract/cast(list/targets, mob/user = usr)
	for(var/target in targets)
		var/mob/living/carbon/C = target
		if(!C.mind || !user.mind)
			to_chat(user, span_notice("[C] seems to not be sentient. You are unable to summon a contract for them."))
			continue

		if(C.stat == DEAD)
			if(!user.drop_from_active_hand())
				continue

			var/obj/item/paper/contract/infernal/revive/contract = new(user.loc, C.mind, user.mind)
			user.put_in_hands(contract)
		else
			var/obj/item/paper/contract/infernal/contract
			var/contractTypeName = input(user, "What type of contract?") in list (CONTRACT_POWER, CONTRACT_WEALTH, CONTRACT_PRESTIGE, CONTRACT_MAGIC, CONTRACT_KNOWLEDGE, CONTRACT_FRIENDSHIP)  // no todo: contracts are deprecated and soon will be deleted

			switch(contractTypeName)
				if(CONTRACT_POWER)
					contract = new /obj/item/paper/contract/infernal/power(C.loc, C.mind, user.mind)
				if(CONTRACT_WEALTH)
					contract = new /obj/item/paper/contract/infernal/wealth(C.loc, C.mind, user.mind)
				if(CONTRACT_PRESTIGE)
					contract = new /obj/item/paper/contract/infernal/prestige(C.loc, C.mind, user.mind)
				if(CONTRACT_MAGIC)
					contract = new /obj/item/paper/contract/infernal/magic(C.loc, C.mind, user.mind)
				if(CONTRACT_KNOWLEDGE)
					contract = new /obj/item/paper/contract/infernal/knowledge(C.loc, C.mind, user.mind)
				if(CONTRACT_FRIENDSHIP)
					contract = new /obj/item/paper/contract/infernal/friendship(C.loc, C.mind, user.mind)

			C.put_in_hands(contract)


/obj/effect/proc_holder/spell/fireball/hellish
	name = "Hellfire"
	desc = "This spell launches hellfire at the target."

	school = "evocation"
	base_cooldown = 8 SECONDS

	clothes_req = FALSE
	human_req = FALSE

	invocation = "Your very soul will catch fire!"
	invocation_type = "shout"

	fireball_type = /obj/projectile/magic/fireball/infernal
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/infernal_jaunt
	name = "Infernal Jaunt"
	desc = "Use hellfire to phase out of existence."

	base_cooldown = 20 SECONDS
	cooldown_min = 0

	overlay = null

	action_icon_state = "jaunt"
	action_background_icon_state = "bg_demon"

	phase_allowed = TRUE

	clothes_req = FALSE
	human_req = FALSE

/obj/effect/proc_holder/spell/infernal_jaunt/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/infernal_jaunt/can_cast(mob/living/user, charge_check, show_message)
	. = ..()
	if(!.)
		return FALSE

	if(!istype(user))
		return FALSE

/obj/effect/proc_holder/spell/infernal_jaunt/cast(list/targets, mob/living/user = usr)
	if(istype(user.loc, /obj/effect/dummy/slaughter))
		var/continuing = 0
		if(istype(get_area(user), /area/shuttle)) // Can always phase in in a shuttle.
			continuing = TRUE
		else
			for(var/mob/living/C in orange(2, get_turf(user.loc))) //Can also phase in when nearby a potential buyer.
				if (C.mind && C.mind.soulOwner == C.mind)
					continuing = TRUE
					break
		if(continuing)
			to_chat(user, span_warning("You are now phasing in."))
			if(do_after(user, 15 SECONDS, user, NONE))
				user.infernalphasein(src)
		else
			to_chat(user, span_warning("You can only re-appear near a potential signer or on a shuttle."))
			revert_cast()
			return ..()

	else
		user.fakefire()
		to_chat(user, span_warning("You begin to phase back into sinful flames."))
		if(do_after(user, 15 SECONDS, user, NONE))
			ADD_TRAIT(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
			user.infernalphaseout(src)
		else
			to_chat(user, span_warning("You must remain still while exiting."))
			user.ExtinguishMob()

	cooldown_handler.start_recharge()
	return

/mob/living/proc/infernalphaseout(obj/effect/proc_holder/spell/infernal_jaunt/spell)
	dust_animation()

	visible_message(span_warning("[src] disappears in a flashfire!"))
	playsound(get_turf(src), 'sound/misc/enter_blood.ogg', 100, 1, -1)

	var/obj/effect/dummy/slaughter/s_holder = new(loc)

	ExtinguishMob()
	forceMove(s_holder)

	holder = s_holder

	REMOVE_TRAIT(src, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(spell))
	fakefireextinguish()


/mob/living/proc/infernalphasein(obj/effect/proc_holder/spell/infernal_jaunt/spell)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		to_chat(src, span_warning("You're too busy to jaunt in."))
		return FALSE

	fakefire()
	forceMove(get_turf(src))

	visible_message(span_warning("<B>[src] appears in a firey blaze!</B>"))
	playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, 1, -1)

	addtimer(CALLBACK(src, PROC_REF(fakefireextinguish), TRUE), 1.5 SECONDS)


/obj/effect/proc_holder/spell/sintouch
	name = "Sin Touch"
	desc = "Subtly encourage someone to sin."

	base_cooldown = 180 SECONDS
	cooldown_min = 0

	clothes_req = FALSE
	human_req = FALSE
	overlay = null

	action_icon_state = "sintouch"
	action_background_icon_state = "bg_demon"

	invocation = "TASTE SIN AND INDULGE!!"
	invocation_type = "shout"

	var/max_targets = 3


/obj/effect/proc_holder/spell/sintouch/ascended
	name = "Greater sin touch"
	base_cooldown = 10 SECONDS
	max_targets = 10


/obj/effect/proc_holder/spell/sintouch/create_new_targeting()
	var/datum/spell_targeting/targeted/targeting = new()

	targeting.selection_type = SPELL_SELECTION_RANGE
	targeting.random_target = TRUE
	targeting.target_priority = SPELL_TARGET_RANDOM
	targeting.use_turf_of_user = TRUE

	targeting.range = 2
	targeting.max_targets = 3

	return targeting


/obj/effect/proc_holder/spell/sintouch/sintouch/cast(list/targets, mob/living/user = usr)
	for(var/mob/living/carbon/human/human in targets)
		if(!human.mind)
			continue

		if(human.mind.has_antag_datum(/datum/antagonist/sintouched))
			continue

		human.mind.add_antag_datum(/datum/antagonist/sintouched)
		human.Weaken(4 SECONDS)

/obj/effect/proc_holder/spell/summon_dancefloor
	name = "Summon Dancefloor"
	desc = "When what a Devil really needs is funk."
	clothes_req = FALSE
	human_req = FALSE
	school = "conjuration"
	base_cooldown = 1 SECONDS
	cooldown_min = 5 SECONDS // 5 seconds, so the smoke can't be spammed
	action_icon_state = "funk"
	action_background_icon_state = "bg_demon"

	var/list/dancefloor_turfs
	var/list/dancefloor_turfs_types
	var/dancefloor_exists = FALSE

/obj/effect/proc_holder/spell/summon_dancefloor/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/summon_dancefloor/cast(list/targets, mob/user = usr)
	LAZYINITLIST(dancefloor_turfs)
	LAZYINITLIST(dancefloor_turfs_types)

	if(dancefloor_exists)
		dancefloor_exists = FALSE
		for(var/i in 1 to dancefloor_turfs.len)
			var/turf/T = dancefloor_turfs[i]
			T.ChangeTurf(dancefloor_turfs_types[i])
	else
		var/list/funky_turfs = RANGE_TURFS(1, user)
		for(var/turf/T in funky_turfs)
			if(T.density)
				to_chat(user, span_warning("You're too close to a wall."))
				return

		dancefloor_exists = TRUE
		var/i = 1

		dancefloor_turfs.len = funky_turfs.len
		dancefloor_turfs_types.len = funky_turfs.len

		for(var/t in funky_turfs)
			var/turf/T = t
			dancefloor_turfs[i] = T
			dancefloor_turfs_types[i] = T.type
			T.ChangeTurf((i % 2 == 0) ? /turf/simulated/floor/light/colour_cycle/dancefloor_a : /turf/simulated/floor/light/colour_cycle/dancefloor_b)
			i++

/obj/effect/proc_holder/spell/aoe/devil_fire
	name = "Devil fire"
	desc = "Призывает огненные волны в радиусе заклинания."
	action_icon_state = "explosion_old"

	base_cooldown = 60 SECONDS
	aoe_range = 10

	clothes_req = FALSE
	human_req = FALSE

	var/fire_prob = 50
	var/slow_time = 5 SECONDS

/obj/effect/proc_holder/spell/aoe/devil_fire/create_new_targeting()
	var/datum/spell_targeting/aoe/targeting = new()

	targeting.range = aoe_range
	targeting.allowed_type = /atom

	return targeting

/obj/effect/proc_holder/spell/aoe/devil_fire/cast(list/targets, mob/user = usr)
	for(var/mob/living/living in targets)
		living.Slowed(slow_time)

	for(var/turf/turf in targets)
		if(turf == get_turf(user))
			continue

		if(!prob(fire_prob))
			continue

		new /obj/effect/hotspot(turf)
		turf.hotspot_expose(2000, 50, 1)

	playsound(get_turf(user), 'sound/magic/blind.ogg', 50, TRUE)

/obj/effect/proc_holder/spell/dark_conversion
	name = "Dark conversion"
	desc = "Превращает гуманоида в тенечеловека и искажает его восприятие реальности."

	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "horror"

	base_cooldown = 300 SECONDS
	var/cast_time = 5 SECONDS

	clothes_req = FALSE
	human_req = FALSE

/obj/effect/proc_holder/spell/dark_conversion/create_new_targeting()
	var/datum/spell_targeting/aoe/targeting = new()

	targeting.range = 5
	targeting.allowed_type = /mob/living/carbon/human

	return targeting

/obj/effect/proc_holder/spell/dark_conversion/create_new_handler()
	var/datum/spell_handler/devil/devil = new
	return devil

/obj/effect/proc_holder/spell/dark_conversion/valid_target(mob/living/carbon/human/target, mob/user)
	return target.mind && !isshadowperson(target)

/obj/effect/proc_holder/spell/dark_conversion/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/human = targets[1]
	var/mob/living/carbon/carbon = user
	var/datum/antagonist/devil/devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)

	carbon.say("INF' [devil.info.truename] NO")
	playsound(get_turf(carbon), 'sound/magic/narsie_attack.ogg', 100, TRUE)

	human.Knockdown(0.1 SECONDS)

	if(!do_after(user, cast_time, user, NONE))
		revert_cast(user)
		return

	make_shadow(human)

/obj/effect/proc_holder/spell/dark_conversion/proc/make_shadow(mob/living/carbon/human/human)
	human.set_species(/datum/species/shadow)
	human.store_memory("Вы - создание тьмы. Старайтесь сохранить свою истинную форму и выполнить свои задания.", TRUE)

	var/datum/objective/assassinate/kill = new
	kill.owner = human.mind
	kill.find_target()

	LAZYADD(human.mind.objectives, kill)
	LAZYADD(human.faction, "hell")

	human.mind.prepare_announce_objectives()
	playsound(human, 'sound/magic/mutate.ogg', 100, TRUE)

/obj/effect/proc_holder/spell/sacrifice_circle
	name = "Create sacrifice circle"
	desc = "Создает руну для жертвоприношений."

	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "sintouch"

	base_cooldown = 900 SECONDS
	var/cast_time = 5 SECONDS

	clothes_req = FALSE
	human_req = FALSE

/obj/effect/proc_holder/spell/sacrifice_circle/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/sacrifice_circle/create_new_handler()
	var/datum/spell_handler/devil/devil = new
	return devil

/obj/effect/proc_holder/spell/sacrifice_circle/cast(list/targets, mob/user = usr)
	playsound(get_turf(user), 'sound/magic/cult_spell.ogg', 100, TRUE)

	if(!do_after(user, cast_time, user, NONE))
		revert_cast(user)
		return

	create_rune(user)

/obj/effect/proc_holder/spell/sacrifice_circle/proc/create_rune(mob/user)
	var/mob/living/carbon/carbon = user
	var/datum/antagonist/devil/devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)

	if(!devil)
		return

	var/obj/effect/decal/cleanable/devil/devil_rune = new(get_turf(carbon))
	playsound(get_turf(carbon), 'sound/magic/invoke_general.ogg', 100, TRUE)

	devil_rune.AddComponent( \
		/datum/component/ritual_object, \
		allowed_categories = /datum/ritual/devil, \
		allowed_special_role = list(ROLE_DEVIL), \
	)

	devil_rune.devil = devil
	devil_rune.update_appearance(UPDATE_DESC)

	return
