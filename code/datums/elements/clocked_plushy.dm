/// Used by hidden clockwork slab hidden inside a plushie. Checks for a clocker and asks for to be revealed.
/datum/element/clocked_plushy
	/// The clockwork slab itself hidden inside /datum/target
	var/obj/item/clockwork/clockslab/clockslab
	/// Our plushie
	var/obj/item/item

/datum/element/clocked_plushy/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	item = target
	RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, PROC_REF(try_reveal))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(clock_examine))

/datum/element/clocked_plushy/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)

/datum/element/clocked_plushy/proc/try_reveal(mob/user)
	if(!isclocker(user))
		return

	if(alert(user, "Do you want to reveal [clockslab]?","Revealing!","Yes","No") != "Yes")
		return
	qdel(item)
	if(user.put_in_active_hand(clockslab))
		clockslab.forceMove(get_turf(user))
	return

/datum/element/clocked_plushy/proc/clock_examine(datum/source, mob/user, list/examine_list)
	if(isclocker(user))
		examine_list += span_clockitalic("It's a hidden [clockslab]!")
