/datum/antagonist/space_dragon
	name = "\improper Space Dragon"
	roundend_category = "space dragons"
	job_rank = ROLE_SPACE_DRAGON
	special_role = SPECIAL_ROLE_SPACE_DRAGON
	/// All space carps created by this antagonist space dragon
	var/list/datum/mind/carp = list()
	/// The innate ability to summon rifts
	var/datum/action/innate/summon_rift/rift_ability
	/// Current time since the the last rift was activated.  If set to -1, does not increment.
	var/riftTimer = 0
	/// Maximum amount of time which can pass without a rift before Space Dragon despawns.
	var/maxRiftTimer = 300
	/// A list of all of the rifts created by Space Dragon.  Used for setting them all to infinite carp spawn when Space Dragon wins, and removing them when Space Dragon dies.
	var/list/obj/structure/carp_rift/rift_list = list()
	/// How many rifts have been successfully charged
	var/rifts_charged = 0
	/// Whether or not Space Dragon has completed their objective, and thus triggered the ending sequence.
	var/objective_complete = FALSE
	/// What mob to spawn from ghosts using this dragon's rifts
	var/minion_to_spawn = /mob/living/simple_animal/hostile/carp/rift_carp
	/// What AI mobs to spawn from this dragon's rifts
	var/ai_to_spawn = /mob/living/simple_animal/hostile/carp/rift_carp
	/// Our dragon
	var/mob/living/simple_animal/hostile/space_dragon/dragon


/datum/antagonist/space_dragon/on_gain()
	. = ..()
	if(!.)
		return

	dragon = owner.current


/datum/antagonist/space_dragon/Destroy()
	rift_list = null
	carp = null
	dragon = null
	QDEL_NULL(rift_ability)
	return ..()


/datum/antagonist/space_dragon/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!.)
		return FALSE

	var/datum/mind/tested = new_owner || owner
	if(!tested || !istype(tested.current, /mob/living/simple_animal/hostile/space_dragon))
		log_admin("Failed to make Space Dragon antagonist, owner is not a space dragon!")
		return FALSE

	return TRUE


/datum/antagonist/space_dragon/greet()
	var/list/messages = list()
	messages.Add(span_userdanger("Вы космический дракон!"))
	messages.Add("<b>Мы движемся сквозь время и пространство, не смотря на их величину. Мы не помним, откуда мы явились; мы не знаем, куда мы пойдем. Весь космос принадлежит нам.\n\
					Мы являемся высшими хищниками в бездонной пустоте, и мало кто может осмелиться занять этот титул.\n\
					Но сейчас, мы лицезреем нарушителей, что борются против наших клыков с помощью немыслимой магии; их логова мелькают в глубине космоса, как маленькие огоньки.\n\
					Сегодня, мы потушим один из этих огоньков.</b>")
	messages.Add(span_boldwarning("У вас имеется пять минут, чтобы найти безопасное место для открытия первого разрыва. Если не успеете, вас вернет в бездну, из которой вы пришли."))
	SEND_SOUND(owner.current, sound('sound/misc/demon_attack1.ogg'))
	return messages


/datum/antagonist/space_dragon/give_objectives()
	add_objective(/datum/objective/summon_carp)


/datum/antagonist/space_dragon/apply_innate_effects(mob/living/mob_override)
	var/mob/living/antag = ..()
	if(!antag)
		return

	RegisterSignal(antag, COMSIG_LIVING_LIFE, PROC_REF(rift_checks))
	RegisterSignal(antag, COMSIG_LIVING_DEATH, PROC_REF(destroy_rifts))
	antag.faction |= "carp"
	// Give the ability over if we have one
	if(!rift_ability)
		rift_ability = new()
	rift_ability.Grant(antag)


/datum/antagonist/space_dragon/remove_innate_effects(mob/living/mob_override)
	var/mob/living/antag = ..()
	if(!antag)
		return

	UnregisterSignal(antag, COMSIG_LIVING_LIFE)
	UnregisterSignal(antag, COMSIG_LIVING_DEATH)
	antag.faction -= "carp"
	rift_ability?.Remove(antag)


/**
 * Checks to see if we need to do anything with the current state of the dragon's rifts.
 *
 * A simple update check which sees if we need to do anything based on the current state of the dragon's rifts.
 *
 */
/datum/antagonist/space_dragon/proc/rift_checks()
	if((rifts_charged == 3 || (SSshuttle.emergency.mode == SHUTTLE_DOCKED && rifts_charged > 0)) && !objective_complete)
		victory()
		return
	if(riftTimer == -1)
		return
	riftTimer = min(riftTimer + 1, maxRiftTimer + 1)
	if(riftTimer == (maxRiftTimer - 60))
		to_chat(owner.current, span_boldwarning("У вас осталась минута, чтобы открыть разрыв! Скорее!"))
		return
	if(riftTimer >= maxRiftTimer)
		to_chat(owner.current, span_boldwarning("Вы не успели огкрыть разрыв! Бездна затягивает вас обратно!"))
		destroy_rifts()
		SEND_SOUND(owner.current, sound('sound/misc/demon_dies.ogg'))
		owner.current.death(TRUE)
		QDEL_NULL(owner.current)


/**
 * Destroys all of Space Dragon's current rifts.
 *
 * QDeletes all the current rifts after removing their references to other objects.
 * Currently, the only reference they have is to the Dragon which created them, so we clear that before deleting them.
 * Currently used when Space Dragon dies or one of his rifts is destroyed.
 */
/datum/antagonist/space_dragon/proc/destroy_rifts()
	if(objective_complete)
		return
	rifts_charged = 0
	owner.current.add_movespeed_modifier(/datum/movespeed_modifier/dragon_depression)
	riftTimer = -1
	SEND_SOUND(owner.current, sound('sound/vehicles/rocketlaunch.ogg'))
	for(var/obj/structure/carp_rift/rift as anything in rift_list)
		rift.dragon = null
		rift_list -= rift
		if(!QDELETED(rift))
			QDEL_NULL(rift)


/**
 * Sets up Space Dragon's victory for completing the objectives.
 *
 * Triggers when Space Dragon completes his objective.
 * Calls the shuttle with a coefficient of 3, making it impossible to recall.
 * Sets all of his rifts to allow for infinite sentient carp spawns
 * Also plays appropiate sounds and CENTCOM messages.
 */
/datum/antagonist/space_dragon/proc/victory()
	objective_complete = TRUE
	permanant_empower()
	var/datum/objective/summon_carp/main_objective = locate() in objectives
	if(main_objective)
		main_objective.completed = TRUE
	GLOB.command_announcement.Announce("Огромное число форм жизни направляется к [station_name()] с высокой скоростью. \
	Оставшемуся экипажу рекомендуется эвакуироваться как можно скорее...", "Отдел Изучения Дикой Природы")
	sound_to_playing_players('sound/creatures/space_dragon_roar.ogg')
	for(var/obj/structure/carp_rift/rift as anything in rift_list)
		rift.carp_stored = 999999
		rift.time_charged = rift.max_charge
	SSshuttle.emergency.canRecall = FALSE
	SSshuttle.emergencyNoEscape = FALSE
	if(SSshuttle.emergency.mode >= SHUTTLE_DOCKED)
		return
	SSshuttle.emergency.request(coefficient = 0.5)


/**
 * Gives Space Dragon their the rift speed buff permanantly and fully heals the user.
 *
 * Gives Space Dragon the enraged speed buff from charging rifts permanantly.
 * Only happens in circumstances where Space Dragon completes their objective.
 * Also gives them a full heal.
 */
/datum/antagonist/space_dragon/proc/permanant_empower()
	owner.current.rejuvenate()
	owner.current.add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 5))
	owner.current.add_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)


/**
 * Handles Space Dragon's temporary empowerment after boosting a rift.
 *
 * Empowers and depowers Space Dragon after a successful rift charge.
 * Empowered, Space Dragon regains all his health and becomes temporarily faster for 30 seconds, along with being tinted red.
 */
/datum/antagonist/space_dragon/proc/rift_empower()
	owner.current.rejuvenate()
	owner.current.add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 5))
	owner.current.add_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)
	addtimer(CALLBACK(src, PROC_REF(rift_depower)), 30 SECONDS)


/**
 * Removes Space Dragon's rift speed buff.
 *
 * Removes Space Dragon's speed buff from charging a rift.  This is only called
 * in rift_empower, which uses a timer to call this after 30 seconds.  Also
 * removes the red glow from Space Dragon which is synonymous with the speed buff.
 */
/datum/antagonist/space_dragon/proc/rift_depower()
	owner.current.remove_filter("anger_glow")
	owner.current.remove_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)


/datum/objective/summon_carp
	needs_target = FALSE
	explanation_text = "Открывайте и защищайте разрывы, чтобы наводнить станцию карпами."


/datum/antagonist/space_dragon/roundend_report()
	var/list/parts = list()
	var/datum/objective/summon_carp/S = locate() in objectives
	if(S.check_completion())
		parts += "<span class='redtext big'>[name] - успех! Космические карпы вернули контроль над территорией расположения станции!</span>"
	parts += printplayer(owner)
	var/objectives_complete = TRUE
	if(objectives.len)
		parts += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break
	if(objectives_complete)
		parts += "<span class='greentext big'>[name] преуспел!</span>"
	else
		parts += "<span class='redtext big'>[name] провалился!</span>"
	if(carp.len)
		parts += "<span class='header'>Помощниками [name] были:</span>"
		for(var/datum/mind/M in carp)
			parts += "[printplayer(M)]"
	return parts.Join("<br>")

/proc/isspacedragon(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/space_dragon)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/space_dragon)
