/**
 * Paint splatting component
 *
 * When applied to mob it will make paint splatters when moving
 *
 */
/datum/component/paint_splatter
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS // Only one of the component can exist on an item
	/// Paint splat color
	var/paint_color
	/// Component live duration
	var/live_duration
	/// Timer when component will be removed
	var/remove_timer = null
	var/splat_chance
	var/paint_amount

/**
 * Paint splatting component
 */
/datum/component/paint_splatter/Initialize(color = "#d87417", amount = 10, chance = 100, duration = 30 SECONDS)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	paint_color = color
	live_duration = duration
	splat_chance = chance
	paint_amount = amount
	// start remove timer
	remove_timer = addtimer(CALLBACK(src, PROC_REF(on_finish_live_time)), live_duration, TIMER_UNIQUE | TIMER_STOPPABLE)

// Inherit the new values passed to the component
/datum/component/paint_splatter/InheritComponent(datum/component/paint_splatter/new_comp, original, color = "#d87417", amount = 10, chance = 50, duration = 30 SECONDS)
	if(!original)
		return
	paint_color = color
	live_duration = duration
	splat_chance = chance
	paint_amount = amount
	// start remove timer
	if(remove_timer)
		deltimer(remove_timer)
	remove_timer = addtimer(CALLBACK(src, PROC_REF(on_finish_live_time)), live_duration, TIMER_UNIQUE | TIMER_STOPPABLE)

/datum/component/paint_splatter/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_MOVED, PROC_REF(on_move))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

/datum/component/paint_splatter/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLIENT_MOVED, COMSIG_COMPONENT_CLEAN_ACT))

/datum/component/paint_splatter/proc/on_finish_live_time()
	qdel(src)



// MARK: Signals processors
/datum/component/paint_splatter/proc/on_move(datum/source)
	SIGNAL_HANDLER
	var/turf/parent_turf = get_turf(source)
	if(!parent_turf)
		return
	if(!prob(splat_chance + paint_amount))
		return
	create_paint_splatter(parent_turf)

/datum/component/paint_splatter/proc/on_clean(datum/source, strength)
	SIGNAL_HANDLER
	paint_amount -= strength
	if(paint_amount > 0)
		var/mob/living/carbon/human/human = source
		if(istype(human))
			human.add_blood(human.get_blood_dna_list(), color = paint_color)
		return
	if(remove_timer)
		deltimer(remove_timer)
	qdel(src)



// MARK: Logic procs
/datum/component/paint_splatter/proc/create_paint_splatter(turf/location)
	var/obj/effect/decal/cleanable/blood/drip/paint/paint = new(location)
	paint.basecolor = paint_color
	paint.update_icon()

/datum/component/paint_splatter/proc/restart_live_timer(amount = 10)
	if(remove_timer)
		deltimer(remove_timer)
	paint_amount += amount
	remove_timer = addtimer(CALLBACK(src, PROC_REF(on_finish_live_time)), live_duration, TIMER_UNIQUE | TIMER_STOPPABLE)
