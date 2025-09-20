/obj/structure/trap
	name = "Ловушка"
	// You can't meet it in game, so no ru_names
	desc = "Давай, наступи на меня!"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "trap"
	anchored = TRUE
	alpha = 30 //initially quite hidden when not "recharging"
	var/flare_message = span_warning("ловушка ярко светится!")
	var/last_trigger = 0
	var/time_between_triggers = 1 MINUTES
	var/charges = INFINITY
	var/antimagic_flags = MAGIC_RESISTANCE

	var/static/list/ignore_typecache
	var/list/mob/immune_minds = list()

	var/sparks = TRUE
	var/datum/effect_system/spark_spread/spark_system

/obj/structure/trap/Initialize(mapload)
	. = ..()
	flare_message = span_warning("[declent_ru(NOMINATIVE)] ярко светится!")
	spark_system = new
	spark_system.set_up(4,1,src)
	spark_system.attach(src)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	if(isnull(ignore_typecache))
		ignore_typecache = typecacheof(list(
			/obj/effect,
			/mob/dead,
		))

/obj/structure/trap/Destroy()
	qdel(spark_system)
	spark_system = null
	. = ..()

/obj/structure/trap/examine(mob/user)
	. = ..()
	if(!isliving(user))
		return
	if(user.mind && (user.mind in immune_minds))
		return
	if(get_dist(user, src) <= 1)
		. += span_notice("You reveal [src]!")
		flare()

/obj/structure/trap/proc/flare()
	// Makes the trap visible, and starts the cooldown until it's
	// able to be triggered again.
	visible_message(flare_message)
	if(sparks)
		spark_system.start()
	alpha = 200
	last_trigger = world.time
	charges--
	if(charges <= 0)
		animate(src, alpha = 0, time = 1 SECONDS)
		QDEL_IN(src, 1 SECONDS)
	else
		animate(src, alpha = initial(alpha), time = time_between_triggers)

/obj/structure/trap/proc/on_entered(datum/source, atom/movable/victim)
	SIGNAL_HANDLER
	if(last_trigger + time_between_triggers > world.time)
		return
	// Don't want the traps triggered by sparks, ghosts or projectiles.
	if(is_type_in_typecache(victim, ignore_typecache))
		return
	if(ismob(victim))
		var/mob/mob_victim = victim
		if(mob_victim.mind in immune_minds)
			return
		if(mob_victim.can_block_magic(antimagic_flags))
			flare()
			return
	if(charges <= 0)
		return
	flare()
	if(isliving(victim))
		trap_effect(victim)

/obj/structure/trap/proc/trap_effect(mob/living/victim)
	return
