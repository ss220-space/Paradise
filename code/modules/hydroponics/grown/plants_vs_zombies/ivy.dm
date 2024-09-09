/obj/item/seeds/terraformers_plant/ivy
	name = "pack of ivy seeds"
	desc = "Эти семяна выростут в плющ."
	icon_state = "seed-grass"
	species = "grass"
	plantname = "Ivy"
	product = /obj/item/ivy
	lifespan = 40
	endurance = 40
	maturation = 2
	production = 5
	yield = 5
	growthstages = 6
	icon_grow = "grass-grow"
	icon_dead = "grass-dead"
	mutatelist = list(/obj/item/seeds/terraformers_plant/ivy/barbed, /obj/item/seeds/terraformers_plant/ivy/venomous)

/obj/item/seeds/terraformers_plant/ivy/barbed
	name = "pack of barbed ivy seeds"
	plantname = "Barbed ivy"
	product = /obj/item/ivy/barbed

/obj/item/seeds/terraformers_plant/ivy/venomous
	name = "pack of barbed ivy seeds"
	plantname = "Venomous ivy"
	product = /obj/item/ivy/venomous

/obj/item/ivy
	name = "ivy"
	desc = "Постепенно разростающийся плющ. Лечит дион находящихся на нем."
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass1"
	var/spawn_turf = /turf/simulated/floor/ivy
	var/static/list/blacklisted_ivy_turfs = typecacheof(list(
	/turf/simulated/floor/lava,
	/turf/simulated/floor/chasm,
	/turf/simulated/floor/beach/water,
	/turf/simulated/floor/indestructible/beach/water))

/obj/item/ivy/barbed
	name = "barbed ivy"
	desc = "Постепенно разростающийся плющ. Ранит находящихся на нем не Дион."
	plantname = "Barbed ivy"
	spawn_turf = /turf/simulated/floor/ivy/barbed

/obj/item/ivy/venomous
	name = "venomous ivy"
	desc = "Постепенно разростающийся плющ. Отравляет находящихся на нем не Дион."
	plantname = "Venomous ivy"
	spawn_turf = /turf/simulated/floor/ivy/venomous


/obj/item/ivy/proc/plant(turf/loc)
	. = !(loc.type in blacklisted_ivy_turfs) && istype(loc, /turf/simulated/floor)
	if (.)
		loc.ChangeTurf(spawn_turf)

/obj/item/ivy/attack_self(mob/user)
	if (isturf(user.loc) && plant(user.loc))
		user.balloon_alert(user, "плющ посажен")
	else
		user.balloon_alert(user, "неподходящее место")

	qdel(src)

/turf/simulated/floor/ivy
	name = "ivy patch"
	icon_state = "grass1"
	floor_tile = /obj/item/ivy
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	var/generation = 1
	/// If we fail to spread this many times we stop trying to spread
	var/max_failed_spreads = 5
	/// Turfs where the ivy cannot spread to
	var/static/list/blacklisted_ivy_turfs = typecacheof(list(
		/turf/simulated/floor/lava,
		/turf/simulated/floor/chasm,
		/turf/simulated/floor/beach/water,
		/turf/simulated/floor/indestructible/beach/water))

/turf/simulated/floor/ivy/broken_states()
	return list("sand")

/turf/simulated/floor/ivy/update_icon_state()
	icon_state = "grass[pick("1","2","3","4")]"

/turf/simulated/floor/ivy/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/shovel))
		add_fingerprint(user)
		if((locate(/obj/structure/pit) in src))
			to_chat(user, span_notice("Looks like someone dug here a pit!"))
			return .

		if(user.a_intent == INTENT_DISARM)
			I.play_tool_sound(src)
			to_chat(user, span_notice("You start digging..."))
			if(!do_after(user, 4 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL))
				return .
			I.play_tool_sound(src)
			to_chat(user, span_notice("You have dug a pit."))
			new /obj/structure/pit(src)
			return .|ATTACK_CHAIN_SUCCESS

		I.play_tool_sound(src)
		to_chat(user, span_notice("You shovel the ivy."))
		make_plating(FALSE)
		new /obj/item/stack/ore/glass(src, 2) //Make some sand if you shovel ivy
		return .|ATTACK_CHAIN_BLOCKED_ALL

//separate dm since hydro is getting bloated already
/// Time interval between ivy "spreads". Made it as a constant for better control.
#define SPREAD_DELAY 13 SECONDS

/turf/simulated/floor/ivy/examine(mob/user)
	. = ..()
	. += span_notice("This is a [generation]\th generation [name]!")

/turf/simulated/floor/ivy/proc/kill()
	remove_tile(make_tile = FALSE)

/turf/simulated/floor/ivy/Initialize(mapload, mutate_stats, spread)
	. = ..()
	update_icon()
	update_light()
	addtimer(CALLBACK(src, PROC_REF(Spread)), SPREAD_DELAY, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/turf/simulated/floor/ivy/proc/Spread()
	//We could be deleted at any point and the timers might not be cleaned up
	if(QDELETED(src))
		return
	var/ivys_planted = 0
	var/list/possible_locs = list()
	for(var/turf/simulated/floor/earth in RANGE_TURFS(1, src))
		if(is_type_in_typecache(earth, blacklisted_ivy_turfs))
			continue
		if(!CanAtmosPass(earth, vertical = FALSE))
			continue
		possible_locs += earth

	//Lets not even try to spawn again if somehow we have ZERO possible locations
	if(!length(possible_locs))
		return

	for(var/i in 1 to 10)
		// This formula gives you diminishing returns based on generation. 90% with 1st gen, decreasing to 40%, 23.3(3)%, 15, 10, 6...
		var/chance_generation = 100 / generation - 10

		// Whatever is the higher chance we use it (this is really stupid as the diminishing returns are effectively pointless???)
		if(!prob(chance_generation))
			continue

		var/turf/new_loc = pick(possible_locs)


		if (istype(new_loc, /turf/simulated/floor/ivy))
			continue

		//Decay can end us
		if(QDELETED(src) && istype(src, /turf/simulated/floor/ivy))
			return

		var/turf/simulated/floor/ivy/child = new /turf/simulated/floor/ivy(new_loc)
		child.generation = generation + 1
		ivys_planted++

	if(!ivys_planted)
		max_failed_spreads--

	//if we didn't get all possible ivys planted or we haven't failed to spread at least 5 times then try to spread again later
	if((ivys_planted <= 10) && (max_failed_spreads >= 0))
		addtimer(CALLBACK(src, PROC_REF(Spread)), SPREAD_DELAY, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/turf/simulated/floor/ivy/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		kill()

/turf/simulated/floor/ivy/acid_act(acidpwr, acid_volume)
	. = 1
	visible_message(span_danger("[src] melts away!"))
	var/obj/effect/decal/cleanable/molten_object/object = new (get_turf(src))
	object.desc = "Looks like this was \an [src] some time ago."
	kill()


/turf/simulated/floor/ivy/attackby(obj/item/I, mob/living/user)
	. = ATTACK_CHAIN_PROCEED_SUCCESS
	if(!I.force)
		user.visible_message(
			span_warning("[user] gently pokes [src] with [I]."),
			span_warning("You gently poke [src] with [I]."),
		)
		return .
	user.visible_message(
		span_danger("[user] has hit [src] with [I]!"),
		span_danger("You have hit [src] with [I]!"),
	)
	var/obj/item/scythe/scythe = I
	//so folded telescythes won't get damage boosts / insta-clears (they instead will be treated like non-scythes)
	if(istype(I, /obj/item/scythe) && scythe.extend)
		for(var/turf/simulated/floor/ivy/ivy in (view(1, src) - src))
			ivy.kill()

	if(QDELETED(src))
		return ATTACK_CHAIN_BLOCKED_ALL

/turf/simulated/floor/ivy/barbed
	name = "barbed ivy patch"
	floor_tile = /obj/item/ivy/barbed

/turf/simulated/floor/ivy/venomous
	name = "venomous ivy patch"
	floor_tile = /obj/item/ivy/venomous

#undef SPREAD_DELAY
