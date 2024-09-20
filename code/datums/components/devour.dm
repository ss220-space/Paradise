/datum/component/devour
    /// Which atom types you can devour
    var/list/allowed_types
    /// Blacklisted atom types to devour
    var/list/blacklisted_types
    /// How much time that will take to devour target
    var/devouring_time 
    /// Drops loc contents on dead
    var/drop_contents
    /// Contents can be dropped without gibbing
    var/drop_anyway
    /// Target health threshold, if corpse_only on FALSE you will devour him without dead stat
    var/health_threshold
    /// Can consume only dead target
    var/corpse_only
    /// Silences messages when TRUE
    var/silent
    /// If you still want to do attack without cancel when requirements to devour target met
    var/cancel_attack

/datum/component/devour/Initialize(
    list/allowed_types = list(atom/movable),
    list/blacklisted_types,
    devouring_time,
    health_threshold,
    corpse_only = TRUE,
    drop_contents = TRUE,
    drop_anyway = FALSE,
    silent = FALSE,
    cancel_attack = TRUE
)
    if(!ismob(parent))
        return COMPONENT_INCOMPATIBLE
    src.allowed_types = allowed_types
    src.blacklisted_types = blacklisted_types
    src.health_threshold = health_threshold
    src.corpse_only = corpse_only
    src.drop_contents = drop_contents
    src.drop_anyway = drop_anyway
    src.silent = silent
    src.cancel_attack = cancel_attack

/datum/component/devour/RegisterWithParent()
    RegisterSignal(parent, COMSIG_MOB_PRE_UNARMED_ATTACK, PROC_REF(try_devour))
    RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_mob_death)) // register anyway for flexibility

/datum/component/devour/UnregisterFromParent()
    UnregisterSignal(parent, list(COMSIG_MOB_PRE_UNARMED_ATTACK, COMSIG_MOB_DEATH))

/datum/component/devour/proc/try_devour(datum/source, atom/movable/atom, params)
    SIGNAL_HANDLER

    if(!check_types(atom))
        return
    
    INVOKE_ASYNC(src, PROC_REF(devour), atom, params)
    if(!cancel_attack)
        return
    return COMPONENT_CANCEL_UNARMED_ATTACK

/datum/component/devour/proc/add_to_contents(atom/movable/target)
    var/mob/mob = parent
    target.extinguish_light()
    target.forceMove(mob)
    ADD_TRAIT(target, TRAIT_DEVOURED, UNIQUE_TRAIT_SOURCE(src))
    SEND_SIGNAL(mob, COMSIG_COMPONENT_DEVOURED_TARGET, target)
    return mob

/datum/component/devour/proc/check_types(atom/movable/atom)
    if(allowed_types && !is_type_in_list(atom, allowed_types))
        return FALSE
    if(blacklisted_types && is_type_in_list(atom, blacklisted_types))
        return FALSE
    if(isitem(atom))
        var/obj/item/item = atom
        if(item.anchored)
            return FALSE
    if(isliving(atom))
        var/mob/living/living = atom
        if(corpse_only && living.stat != DEAD)
            return FALSE
        if(health_threshold && living.health > health_threshold)
            return FALSE
    return TRUE

/datum/component/devour/proc/devour(atom/movable/atom, params)
    SEND_SIGNAL(parent, COMSIG_COMPONENT_PRE_DEVOUR_TARGET, atom)
    if(!silent)
        to_chat(parent, span_warning("Вы начинаете глотать [atom] целиком..."))
    if(devouring_time && !do_after(parent, devouring_time, atom, NONE))
        return
    if(SEND_SIGNAL(parent, COMSIG_COMPONENT_DEVOURING_TARGET, atom) & STOP_DEVOURING)
        return
    var/mob/mob = parent
    if(atom?.loc == mob)
        return
    if(!silent)
        playsound(parent, 'sound/misc/demon_attack1.ogg', 100, TRUE)
        mob.visible_message(span_warning("[mob] swallows [atom] whole!"))
    add_to_contents(atom)

/datum/component/devour/proc/on_mob_death(gibbed)
    SIGNAL_HANDLER

    if(!drop_contents)
        return
    if(!drop_anyway && !gibbed)
        return
    var/mob/mob = parent
    for(var/atom/movable/atom in mob)
        atom.forceMove(mob.loc)
        if(HAS_TRAIT(mob, TRAIT_DEVOURED))
            REMOVE_TRAIT(mob, TRAIT_DEVOURED, UNIQUE_TRAIT_SOURCE(src))
        if(prob(90))
            step(atom, pick(GLOB.alldirs))

/// Advanced version of devour component which works on special signals.
/datum/component/devour/advanced

/datum/component/devour/advanced/Initialize(
    list/allowed_types = list(/atom/movable),
    list/blacklisted_types,
    devouring_time,
    health_threshold,
    corpse_only = FALSE,
    drop_contents = TRUE,
    drop_anyway = FALSE,
    silent = FALSE,
    cancel_attack = TRUE
)
    . = ..()
    if(. & COMPONENT_INCOMPATIBLE)
        return COMPONENT_INCOMPATIBLE
    if(!iscarbon(parent))
        return COMPONENT_INCOMPATIBLE

/datum/component/devour/advanced/RegisterWithParent()
    RegisterSignal(parent, COMSIG_LIVING_GRAB_ATTACK, PROC_REF(grab_attack))
    RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(attackedby_item))
    RegisterSignal(parent, COMSIG_LIVING_GRAB_EQUIP, PROC_REF(grab_equip))
    RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_mob_death))

/datum/component/devour/advanced/UnregisterFromParent()
    UnregisterSignal(parent, list(COMSIG_LIVING_GRAB_ATTACK, COMSIG_MOB_DEATH, COMSIG_PARENT_ATTACKBY, COMSIG_LIVING_GRAB_EQUIP))

/datum/component/devour/advanced/proc/attackedby_item(obj/item, mob/living, params)
	SIGNAL_HANDLER

	if(!isholder(item))
		return
	var/mob/living/mob = locate() in item.contents
	if(!mob)
		return

	INVOKE_ASYNC(src, PROC_REF(devouring), living, mob, item)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/devour/advanced/proc/grab_equip(datum/source, atom/movable/grabbed_thing, current_pull_hand)
    SIGNAL_HANDLER

    if(!check_types(grabbed_thing))
        return

    INVOKE_ASYNC(src, PROC_REF(devouring), source, grabbed_thing)
    return GRAB_EQUIP_SUCCESS

/datum/component/devour/advanced/proc/grab_attack(datum/source, mob/living/grabber, atom/movable/grabbed_thing)
    SIGNAL_HANDLER

    if(!check_types(grabbed_thing))
        return
    if(grabber.a_intent != INTENT_GRAB)
        return
    if(grabber != source)
        return
    
    INVOKE_ASYNC(src, PROC_REF(devouring), grabber, grabbed_thing)
    return

/datum/component/devour/advanced/check_types(atom/movable/atom)
    . = ..()
    if(!.)
        return FALSE
    if(!isliving(atom))
        return FALSE
    return TRUE

/datum/component/devour/advanced/proc/devouring(mob/living/carbon/source, mob/living/living, obj/item)
    SEND_SIGNAL(parent, COMSIG_COMPONENT_PRE_DEVOUR_TARGET, living)
    var/target = isturf(living.loc) ? living : source
    source.setDir(get_dir(source, living))

    if(!silent)
        source.visible_message(span_danger("[source.name] пыта[pluralize_ru(source.gender,"ет","ют")]ся поглотить [living.name]!"))

    if(!do_after(source, devouring_time ? devouring_time : get_devour_time(source, living), target, NONE, extra_checks = CALLBACK(src, PROC_REF(can_devour), source, living), max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_notice("Вы прекращаете поглощать [living.name]!")))
        if(!silent)
            source.visible_message(span_notice("[source.name] прекраща[pluralize_ru(source.gender,"ет","ют")] поглощать [living.name]!"))
        return

     if(SEND_SIGNAL(parent, COMSIG_COMPONENT_DEVOURING_TARGET, living) & STOP_DEVOURING)
        return

    if(!silent)
        source.visible_message(span_danger("[source.name] поглоща[pluralize_ru(source.gender,"ет","ют")] [living.name]!"))

    if(living.mind)
        add_attack_logs(source, living, "Devoured")

    if(!isvampire(source))
        source.adjust_nutrition(2 * living.health)

    for(var/datum/disease/virus/virus in living.diseases)
        if(virus.spread_flags > NON_CONTAGIOUS)
            virus.Contract(source)
    
    for(var/datum/disease/virus/virus in living.diseases)
        if(virus.spread_flags > NON_CONTAGIOUS)
            virus.Contract(living)
    
    add_to_contents(living)
    if(isholder(item))
        qdel(item)

/datum/component/devour/advanced/add_to_contents(atom/movable/target)
    . = ..()
    var/mob/living/carbon/carbon = .
    LAZYADD(carbon.stomach_contents, target)

/datum/component/devour/advanced/proc/can_devour(mob/living/carbon/source, mob/living/target)
	if(isalienadult(source))
		var/mob/living/carbon/alien/humanoid/alien = source
		return alien.can_consume(target)
	return TRUE

/datum/component/devour/advanced/proc/get_devour_time(mob/living/source, mob/living/target)
	if(isanimal(target))
		return DEVOUR_TIME_ANIMAL
	return DEVOUR_TIME_DEFAULT

