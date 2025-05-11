/datum/ritual/devil
	allowed_special_role = list(ROLE_DEVIL)
	cooldown_after_cast = null
	disaster_prob = 0
	fail_chance = 0

/datum/ritual/devil/imp
	name = "Imp summoning ritual"
	required_things = list(
		/obj/item/wirecutters = 3,
        /obj/item/organ/internal/kidneys = 2,
        /obj/item/organ/internal/heart = 1,
        /obj/effect/decal/cleanable/vomit = 2
	)

/datum/ritual/devil/imp/del_things(list/used_things)
    for(var/obj/obj in used_things) // no type ignore for future.
        qdel(obj)

    return

/datum/ritual/devil/imp/do_ritual(mob/living/carbon/human/invoker, list/invokers, list/used_things)
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за беса?", SPECIAL_ROLE_DEVIL_PAWN, TRUE)

	if(!LAZYLEN(candidates))
		return RITUAL_FAILED_ON_PROCEED 

	var/mob/mob = pick(candidates)
	var/mob/living/simple_animal/imp/imp = new(get_turf(ritual_object))

	imp.key = mob.key
	imp.master_commander = invoker

	improve_imp(imp, invoker)

	return RITUAL_SUCCESSFUL

/datum/ritual/devil/imp/proc/improve_imp(mob/living/simple_animal/imp/imp, mob/living/carbon/human/invoker)
	var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)

	imp.universal_speak = TRUE
	imp.sentience_act()

	imp.mind.store_memory("Я подчиняюсь призывателю [imp.master_commander.name], также известному как [devil.info.truename].")
	imp.mind.add_antag_datum(/datum/antagonist/devil_pawn)

/datum/ritual/devil/sacrifice
	name = "Sacrifice ritual"
	ritual_should_del_things = FALSE
	required_things = list(
		/mob/living/carbon/human = 1
	)

/datum/ritual/devil/sacrifice/check_contents(mob/living/carbon/human/invoker, list/used_things)
    . = ..()

    if(!.)
        return FALSE

    var/mob/living/carbon/human/human = locate() in used_things

    if(!human.mind || !human.mind.hasSoul)
        ritual_object.balloon_alert("цель без души!")
        return FALSE

    var/datum/objective/devil/sacrifice/sacrifice = locate() in invoker.mind?.get_all_objectives()

    if(sacrifice && !LAZYIN(sacrifice.target_minds, human.mind))
        ritual_object.balloon_alert("не имеет ценности!")
        return FALSE

    var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)

    if(LAZYIN(devil.soulsOwned, human.mind))
        return FALSE // Error occured / Admin changed hasSoul.

    return TRUE

/datum/ritual/devil/sacrifice/do_ritual(mob/living/carbon/human/invoker, list/invokers, list/used_things)
	var/mob/living/carbon/human/human = locate() in used_things
	var/datum/antagonist/devil/devil = invoker.mind?.has_antag_datum(/datum/antagonist/devil)
    
	if(!devil || !human || !human.mind)
		return RITUAL_FAILED_ON_PROCEED

	devil.add_soul(human.mind)

	return RITUAL_SUCCESSFUL
