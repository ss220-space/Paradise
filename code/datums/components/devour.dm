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
    list/allowed_types,
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
    if(!cancel_attact)
        return
    return COMPONENT_CANCEL_UNARMED_ATTACK

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
    SEND_SIGNAL(parent, COMSIG_COMPONENT_PRE_DEVOUR_TARGET, atom, params)
    if(!silent)
        to_chat(parent, span_warning("Вы начинаете глотать [atom] целиком..."))
    if(devouring_time && !do_after(parent, devouring_time, atom, NONE))
        return
    if(SEND_SIGNAL(parent, COMSIG_COMPONENT_DEVOURING_TARGET, atom, params) & STOP_DEVOURING)
        return
    var/mob/mob = parent
    if(atom?.loc == mob)
        return
    if(!silent)
        playsound(parent, 'sound/misc/demon_attack1.ogg', 100, TRUE)
        mob.visible_message(span_warning("[mob] swallows [atom] whole!"))
    atom.extinguish_light()
    atom.forceMove(mob)
    SEND_SIGNAL(mob, COMSIG_COMPONENT_DEVOURED_TARGET, atom, params)

/datum/component/devour/proc/on_mob_death(gibbed)
    SIGNAL_HANDLER

    if(!drop_contents)
        return
    if(!drop_anyway && !gibbed)
        return
    var/mob/mob = parent
    for(var/atom/movable/atom in mob)
        atom.forceMove(mob.loc)
        if(prob(90))
            step(atom, pick(GLOB.alldirs))

/// Advanced version of devour component which works on special signals.
/datum/component/devour/advanced

/datum/component/devour/advanced/RegisterWithParent()
    RegisterSignal(parent, COMSIG_COMPONENT_DEVOUR_INITIATE, PROC_REF(devour))
    RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_mob_death))

/datum/component/devour/advanced/UnregisterFromParent()
    UnregisterSignal(parent, list(COMSIG_COMPONENT_DEVOUR_INITIATE, COMSIG_MOB_DEATH))

/// Living(target) is devoured by gourmet.
/datum/component/devour/advanced/devour(mob/living/gourmet, mob/living/living)
    SIGNAL_HANDLER

    if(!check_types(living) || !can_devour(gourmet))
        return

    var/target = isturf(living.loc) ? living : gourmet
    gourmet.setDir(get_dir(gourmet, living))

    if(!silent)
        gourmet.visible_message(span_danger("[gourmet.name] пыта[pluralize_ru(gourmet.gender,"ет","ют")]ся поглотить [living.name]!"))

    if(!do_after(gourmet, devouring_time ? devouring_time : get_devour_time(gourmet, living), target, NONE, extra_checks = CALLBACK(src, PROC_REF(can_devour), gourmet, living), max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_notice("Вы прекращаете поглощать [living.name]!")))
        if(!silent)
            gourmet.visible_message(span_notice("[gourmet.name] прекраща[pluralize_ru(gourmet.gender,"ет","ют")] поглощать [living.name]!"))
        return
    
    if(!silent)
        gourmet.visible_message(span_danger("[gourmet.name] поглоща[pluralize_ru(gourmet.gender,"ет","ют")] [living.name]!"))

    if(living.mind)
        add_attack_logs(gourmet, living, "Devoured")

    if(!isvampire(gourmet))
        gourmet.adjust_nutrition(2 * living.health)

    for(var/datum/disease/virus/virus in living.diseases)
        if(virus.spread_flags > NON_CONTAGIOUS)
            virus.Contract(gourmet)
    
    for(var/datum/disease/virus/virus in living.diseases)
        if(virus.spread_flags > NON_CONTAGIOUS)
            virus.Contract(living)

    living.forceMove(gourmet)
    LAZYADD(gourmet.stomach_contents, living)
    return COMSIG_MOB_DEVOURED

/// Does all the checking for the [/proc/devoured()] to see if a mob can eat another with the grab.
/datum/component/devour/advanced/proc/can_devour(mob/living/gourmet, mob/living/target)
	if(isalienadult(gourmet))
		var/mob/living/carbon/alien/humanoid/alien = gourmet
		return alien.can_consume(target)
	return FALSE

/// Returns the time devourer has to wait before they eat a prey.
/datum/component/devour/advanced/proc/get_devour_time(mob/living/gourmet, mob/living/target)
	if(isalienadult(gourmet))
		var/mob/living/carbon/alien/humanoid/alien = gourmet
		return alien.devour_time
	if(isanimal(target))
		return DEVOUR_TIME_ANIMAL
	return DEVOUR_TIME_DEFAULT

