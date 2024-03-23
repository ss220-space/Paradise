/turf/simulated/floor/chasm
	name = "chasm"
	desc = "Watch your step."
	baseturf = /turf/simulated/floor/chasm
	smooth = SMOOTH_TRUE | SMOOTH_BORDER | SMOOTH_MORE
	icon = 'icons/turf/floors/Chasms.dmi'
	icon_state = "smooth"
	canSmoothWith = list(/turf/simulated/floor/chasm)
	density = TRUE //This will prevent hostile mobs from pathing into chasms, while the canpass override will still let it function like an open turf
	layer = 1.7
	intact = 0
	var/static/list/falling_atoms = list() //Atoms currently falling into the chasm
	var/static/list/forbidden_types = typecacheof(list(
		/obj/singularity,
		/obj/docking_port,
		/obj/structure/lattice,
		/obj/structure/stone_tile,
		/obj/item/projectile,
		/obj/effect/portal,
		/obj/effect/hotspot,
		/obj/effect/landmark,
		/obj/effect/temp_visual,
		/obj/effect/light_emitter/tendril,
		/obj/effect/collapse,
		/obj/effect/particle_effect/ion_trails,
		/obj/effect/abstract,
		/obj/effect/ebeam,
		/obj/effect/spawner,
		/obj/structure/railing,
		/obj/machinery/atmospherics/pipe/simple,
		/mob/living/simple_animal/hostile/megafauna //failsafe
		))
	var/drop_x = 1
	var/drop_y = 1
	var/drop_z = 1

	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null

/turf/simulated/floor/chasm/Entered(atom/movable/AM)
	..()
	START_PROCESSING(SSprocessing, src)
	drop_stuff(AM)

/turf/simulated/floor/chasm/CanPathfindPass(obj/item/card/id/ID, to_dir, caller, no_id = FALSE)
	if(!isliving(caller))
		return TRUE
	var/mob/living/L = caller
	return (L.flying || ismegafauna(caller))

/turf/simulated/floor/chasm/process()
	if(!drop_stuff())
		STOP_PROCESSING(SSprocessing, src)

/turf/simulated/floor/chasm/Initialize()
	. = ..()
	drop_z = level_name_to_num(MAIN_STATION)

/turf/simulated/floor/chasm/ex_act()
	return

/turf/simulated/floor/chasm/acid_act(acidpwr, acid_volume)
	return

/turf/simulated/floor/chasm/singularity_act()
	return

/turf/simulated/floor/chasm/singularity_pull(S, current_size)
	return

/turf/simulated/floor/chasm/crowbar_act()
	return

/turf/simulated/floor/chasm/make_plating()
	return

/turf/simulated/floor/chasm/remove_plating()
	return

/turf/simulated/floor/chasm/rcd_act()
	return RCD_NO_ACT

/turf/simulated/floor/chasm/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/simulated/floor/chasm/attackby(obj/item/C, mob/user, params, area/area_restriction)
	..()
	if(istype(C, /obj/item/stack/fireproof_rods))
		var/obj/item/stack/fireproof_rods/R = C
		var/obj/structure/lattice/fireproof/L = locate(/obj/structure/lattice, src)
		var/obj/structure/lattice/catwalk/fireproof/W = locate(/obj/structure/lattice/catwalk/fireproof, src)
		if(W)
			to_chat(user, span_warning("Здесь уже есть мостик!"))
			return
		if(!L)
			if(R.use(1))
				to_chat(user, span_notice("Вы установили прочную решётку."))
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				new /obj/structure/lattice/fireproof(src)
			else
				to_chat(user, span_warning("Вам нужен один огнеупорный стержень для постройки решётки."))
			return
		if(L)
			if(R.use(2))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, span_notice("Вы установили мостик."))
				new /obj/structure/lattice/catwalk/fireproof(src)
	if(istype(C, /obj/item/twohanded/fishingrod))
		var/obj/item/twohanded/fishingrod/rod = C
		if(!rod.wielded)
			to_chat(user, span_warning("You need to wield the rod in both hands before you can fish in the chasm!"))
			return
		user.visible_message(span_warning("[user] throws a fishing rod into the chasm and tries to catch something!"),
							 span_notice("You started to fishing."),
							 span_notice("You hear the sound of a fishing rod."))
		playsound(rod, 'sound/effects/fishing_rod_throw.ogg', 30)
		if(do_after(user, 6 SECONDS, target = src))
			if(!rod.wielded)
				return
			var/atom/parent = src
			var/list/fishing_contents = parent.GetAllContents()
			if(!length(fishing_contents))
				to_chat(user, span_warning("There's nothing here!"))
				return
			var/found = FALSE
			for(var/mob/M in fishing_contents)
				M.forceMove(get_turf(user))
				UnregisterSignal(M, COMSIG_LIVING_REVIVE)
				found = TRUE
			if(found)
				to_chat(user, span_warning("You reel in something!"))
				playsound(rod, 'sound/effects/fishing_rod_catch.ogg', 30)
			else
				to_chat(user, span_warning("There's nothing here!"))
		return

/turf/simulated/floor/chasm/is_safe()
	if(find_safeties() && ..())
		return TRUE
	return FALSE

/turf/simulated/floor/chasm/proc/drop_stuff(AM)
	. = 0
	if(find_safeties())
		return FALSE
	var/thing_to_check = src
	if(AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(droppable(thing))
			. = 1
			INVOKE_ASYNC(src, PROC_REF(drop), thing)

/turf/simulated/floor/chasm/proc/droppable(atom/movable/AM)
	if(falling_atoms[AM])
		return FALSE
	if(!isliving(AM) && !isobj(AM))
		return FALSE
	if(!AM.simulated || is_type_in_typecache(AM, forbidden_types) || AM.throwing)
		return FALSE
	//Flies right over the chasm
	if(isliving(AM))
		var/mob/living/M = AM
		if(M.flying || M.floating || M.incorporeal_move)
			return FALSE
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(istype(H.belt, /obj/item/wormhole_jaunter))
			var/obj/item/wormhole_jaunter/J = H.belt
			//To freak out any bystanders
			visible_message(span_boldwarning("[H] falls into [src]!"))
			J.chasm_react(H)
			return FALSE
	return TRUE

/turf/simulated/floor/chasm/proc/drop(atom/movable/AM)
	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return
	falling_atoms[AM] = TRUE
	var/turf/T = locate(drop_x, drop_y, drop_z)
	if(T)
		AM.visible_message(span_boldwarning("[AM] falls into [src]!"), span_userdanger("GAH! Ah... where are you?"))
		T.visible_message(span_boldwarning("[AM] falls from above!"))
		AM.forceMove(T)
		if(isliving(AM))
			var/mob/living/L = AM
			L.Weaken(10 SECONDS)
			L.adjustBruteLoss(30)
	falling_atoms -= AM

/turf/simulated/floor/chasm/straight_down
	var/obj/effect/abstract/chasm_storage/storage

/turf/simulated/floor/chasm/straight_down/Initialize()
	..()
	var/found_storage = FALSE
	for(var/obj/effect/abstract/chasm_storage/C in contents)
		storage = C
		found_storage = TRUE
		break
	if(!found_storage)
		storage = new /obj/effect/abstract/chasm_storage(src)
	drop_x = x
	drop_y = y
	drop_z = z - 1
	var/turf/T = locate(drop_x, drop_y, drop_z)
	if(T)
		T.visible_message(span_boldwarning("The ceiling gives way!"))
		playsound(T, 'sound/effects/break_stone.ogg', 50, 1)

/turf/simulated/floor/chasm/straight_down/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE
	baseturf = /turf/simulated/floor/chasm/straight_down/lava_land_surface //Chasms should not turn into lava
	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA //let's just say you're falling into lava, that makes sense right

/turf/simulated/floor/chasm/straight_down/lava_land_surface/drop(atom/movable/AM)
	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM) || AM.anchored)
		return
	falling_atoms[AM] = TRUE
	AM.visible_message(span_boldwarning("[AM] falls into [src]!"), span_userdanger("You stumble and stare into an abyss before you. It stares back, and you fall \
	into the enveloping dark."))
	if(isliving(AM))
		var/mob/living/L = AM
		L.notransform = TRUE
		L.Stun(400 SECONDS)
		L.resting = TRUE
	var/oldtransform = AM.transform
	var/oldcolor = AM.color
	var/oldalpha = AM.alpha
	animate(AM, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 10)
	if(iscarbon(AM) && prob(25))
		playsound(AM.loc, 'sound/effects/wilhelm_scream.ogg', 150)
	for(var/i in 1 to 5)
		//Make sure the item is still there after our sleep
		if(!AM || QDELETED(AM))
			return
		AM.pixel_y--
		sleep(2)

	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return

	if(isrobot(AM))
		var/mob/living/silicon/robot/S = AM
		qdel(S.mmi)
		qdel(AM)
		return

	falling_atoms -= AM

	if(istype(AM, /obj/item/grenade/jaunter_grenade))
		AM.forceMove(storage)
		return

	if(isliving(AM))
		if(!storage)
			storage = new(get_turf(src))

		if(storage.contains(AM))
			return

		AM.alpha = oldalpha
		AM.color = oldcolor
		AM.transform = oldtransform

		if(!AM.forceMove(storage))
			visible_message(span_boldwarning("[src] spits out [AM]!"))
			AM.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1, 10), rand(1, 10))


		var/mob/living/fallen_mob = AM
		if(fallen_mob.stat != DEAD)
			fallen_mob.death(TRUE)
			fallen_mob.notransform = FALSE
			fallen_mob.apply_damage(1000)

	else
		qdel(AM)


	if(!isliving(AM) && AM && !QDELETED(AM))	//It's indestructible and not human
		visible_message(span_boldwarning("[src] spits out the [AM]!"))
		AM.alpha = oldalpha
		AM.color = oldcolor
		AM.transform = oldtransform
		AM.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1, 10),rand(1, 10))

/obj/effect/abstract/chasm_storage
	name = "chasm depths"
	desc = "The bottom of a hole. You shouldn't be able to interact with this."
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/abstract/chasm_storage/Entered(atom/movable/arrived)
	. = ..()
	if(isliving(arrived))
		RegisterSignal(arrived, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))

/obj/effect/abstract/chasm_storage/Exited(atom/movable/gone)
	. = ..()
	if(isliving(gone))
		UnregisterSignal(gone, COMSIG_LIVING_REVIVE)

#define CHASM_TRAIT "chasm trait"
/**
 * Called if something comes back to life inside the pit. Expected sources are badmins and changelings.
 * Ethereals should take enough damage to be smashed and not revive.
 * Arguments
 * escapee - Lucky guy who just came back to life at the bottom of a hole.
 */

/obj/effect/abstract/chasm_storage/proc/on_revive(mob/living/escapee)
	SIGNAL_HANDLER
	var/turf/ourturf = get_turf(src)
	if(istype(ourturf, /turf/simulated/floor/chasm/straight_down/lava_land_surface))
		ourturf.visible_message(span_boldwarning("After a long climb, [escapee] leaps out of [ourturf]!"))
	else
		playsound(ourturf, 'sound/effects/bang.ogg', 50, TRUE)
		ourturf.visible_message(span_boldwarning("[escapee] busts through [ourturf], leaping out of the chasm below!"))
		ourturf.ChangeTurf(ourturf.baseturf)
	escapee.flying = TRUE
	escapee.forceMove(ourturf)
	escapee.throw_at(get_edge_target_turf(ourturf, pick(GLOB.alldirs)), rand(2, 10), rand(2, 10))
	escapee.flying = FALSE
	escapee.Sleeping(20 SECONDS)
	UnregisterSignal(escapee, COMSIG_LIVING_REVIVE)

#undef CHASM_TRAIT

/turf/simulated/floor/chasm/straight_down/lava_land_surface/normal_air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C


/// Lets people walk into chasms.
/turf/simulated/floor/chasm/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	return TRUE

