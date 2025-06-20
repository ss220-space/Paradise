///Blood walk, a component that causes you to make blood wherever you walk.
/datum/component/blood_walk
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	///How many blood pools can we create?
	///If we reach 0, we will stop leaving blood and self delete
	var/blood_remaining = 0
	///The sound that plays when we spread blood.
	var/sound_played
	///How loud will the sound be, if there is one.
	var/sound_volume
	///The chance of spawning blood whenever walking
	var/blood_spawn_chance
	///Should the decal face the direction of the parent
	var/target_dir_change


/datum/component/blood_walk/Initialize(
	sound_played,
	sound_volume = 80,
	blood_spawn_chance = 100,
	target_dir_change = FALSE,
	max_blood = INFINITY,
)

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.sound_played = sound_played
	src.sound_volume = sound_volume
	src.blood_spawn_chance = blood_spawn_chance
	src.target_dir_change = target_dir_change

	blood_remaining = max_blood


/datum/component/blood_walk/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(spread_blood))


/datum/component/blood_walk/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)


/datum/component/blood_walk/InheritComponent(
	/*datum/component/pricetag/new_comp,*/
	i_am_original,
	sound_played,
	sound_volume = 80,
	blood_spawn_chance = 100,
	target_dir_change = FALSE,
	max_blood = INFINITY,
)

	if(!i_am_original)
		return

	if(max_blood >= INFINITY || blood_remaining >= INFINITY)
		return

	// Applying a new version of the blood walk component will add the new version's step count to our's.
	// We will completely disregard any other arguments passed, because we already have arguments set.
	blood_remaining += max_blood


///Spawns blood (if possible) under the source, and plays a sound effect (if any)
/datum/component/blood_walk/proc/spread_blood(atom/movable/source)
	SIGNAL_HANDLER

	var/turf/current_turf = source.loc
	if(!isturf(current_turf) || iswallturf(current_turf) || isgroundlessturf(current_turf))
		return

	if(!prob(blood_spawn_chance))
		return

	var/obj/effect/decal/cleanable/blood/blood = new /obj/effect/decal/cleanable/blood(current_turf)

	if(QDELETED(blood)) // Our blood was placed on somewhere it shouldn't be and qdeleted in init.
		return

	if(target_dir_change)
		blood.setDir(source.dir)

	if(!isnull(sound_played))
		playsound(source, sound_played, sound_volume, TRUE, 2, TRUE)

	blood_remaining = max(blood_remaining - 1, 0)
	if(blood_remaining > 0)
		return

	qdel(src)
