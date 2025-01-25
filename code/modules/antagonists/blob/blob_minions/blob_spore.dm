/**
 * A floating fungus which turns people into zombies and explodes into reagent clouds upon death.
 */
/mob/living/simple_animal/hostile/blob_minion/spore
	name = "blob spore"
	desc = "Плавающая хрупкая спора."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blobpod"
	icon_living = "blobpod"
	health_doll_icon = "blobpod"
	health = BLOBMOB_SPORE_HEALTH
	maxHealth = BLOBMOB_SPORE_HEALTH
	verb_say = list("psychically pulses", "pulses")
	verb_ask = "psychically probes"
	verb_exclaim = "psychically yells"
	verb_yell = "psychically screams"
	melee_damage_lower = BLOBMOB_SPORE_DMG_LOWER
	melee_damage_upper = BLOBMOB_SPORE_DMG_UPPER
	obj_damage = BLOBMOB_SPORE_OBJ_DMG
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attacktext = "ударяет"
	attack_sound = 'sound/weapons/genhit1.ogg'
	deathmessage = "взрывается облаком газа!"
	gold_core_spawnable = HOSTILE_SPAWN
	del_on_death = TRUE
	speed = BLOBMOB_SPORE_SPEED_MOD
	/// Size of cloud produced from a dying spore
	var/death_cloud_size = 2
	/// Type of mob to create
	var/mob/living/zombie_type = /mob/living/simple_animal/hostile/blob_minion/zombie


/mob/living/simple_animal/hostile/blob_minion/spore/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)

/mob/living/simple_animal/hostile/blob_minion/spore/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/simple_flying)

/mob/living/simple_animal/hostile/blob_minion/spore/death(gibbed)
	. = ..()
	death_burst()

/mob/living/simple_animal/hostile/blob_minion/spore/on_factory_destroyed()
	death()

/// Create an explosion of spores on death
/mob/living/simple_animal/hostile/blob_minion/spore/proc/death_burst()
	do_blob_chem_smoke(range = death_cloud_size, reagent_volume = BLOB_REAGENT_SPORE_VOL, holder = src, location = get_turf(src), reagent_type = /datum/reagent/toxin/spore)

/mob/living/simple_animal/hostile/blob_minion/spore/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/structure/blob))
		return TRUE

/mob/living/simple_animal/hostile/blob_minion/spore/CanAttack(atom/the_target)
	if(ishuman(the_target))
		stat_attack = DEAD
	. = ..()
	stat_attack = initial(stat_attack)

/mob/living/simple_animal/hostile/blob_minion/spore/pull_constraint(atom/movable/pulled_atom, state, supress_message = FALSE) //Prevents spore from pulling things
	if(istype(pulled_atom, /mob/living))
		return TRUE // Get dem
	if(!supress_message)
		to_chat(src, span_warning("Вы не можете таскать ничего кроме других существ и их тел."))
	return FALSE

/mob/living/simple_animal/hostile/blob_minion/spore/AttackingTarget()
	. = ..()
	var/mob/living/carbon/human/human_target = target
	if(!target || !istype(human_target) || human_target.stat != DEAD)
		return .

	if(HAS_TRAIT(human_target, TRAIT_BLOB_ZOMBIFIED))
		return .
	zombify(human_target)

/// Become a zombie
/mob/living/simple_animal/hostile/blob_minion/spore/proc/zombify(mob/living/carbon/human/target)
	if(HAS_TRAIT(target, TRAIT_NO_TRANSFORM) || target.has_status_effect(/datum/status_effect/hippocraticOath))
		return

	visible_message(span_warning("Тело [target.name] внезапно поднимается!"))
	var/mob/living/simple_animal/hostile/blob_minion/zombie/blombie = change_mob_type(zombie_type, loc, new_name = initial(zombie_type.name))
	blombie.set_name()
	if(istype(blombie)) // In case of badmin
		blombie.consume_corpse(target)
	SEND_SIGNAL(src, COMSIG_BLOB_ZOMBIFIED, blombie)
	qdel(src)

/// Variant of the blob spore which is actually spawned by blob factories
/mob/living/simple_animal/hostile/blob_minion/spore/minion
	gold_core_spawnable = NO_SPAWN
	zombie_type = /mob/living/simple_animal/hostile/blob_minion/zombie/controlled
	/// We die if we leave the same turf as this z level
	var/turf/z_turf

/mob/living/simple_animal/hostile/blob_minion/spore/minion/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_changed))

/// When we z-move check that we're on the same z level as our factory was
/mob/living/simple_animal/hostile/blob_minion/spore/minion/proc/on_z_changed()
	SIGNAL_HANDLER
	if(isnull(z_turf))
		return
	if(!is_valid_z_level(get_turf(src), z_turf))
		death()

/// Mark the turf we need to track from our factory
/mob/living/simple_animal/hostile/blob_minion/spore/minion/link_to_factory(obj/structure/blob/special/factory/factory)
	. = ..()
	z_turf = get_turf(factory)

/// If the blob changes to distributed neurons then you can control the spores
/mob/living/simple_animal/hostile/blob_minion/spore/minion/on_strain_updated(mob/camera/blob/overmind, datum/blobstrain/new_strain)
	if(istype(new_strain, /datum/blobstrain/reagent/distributed_neurons))
		AddComponent(\
			/datum/component/ghost_direct_control,\
			ban_type = ROLE_BLOB,\
			poll_candidates = FALSE,\
		)
	else
		qdel(GetComponent(/datum/component/ghost_direct_control))

/mob/living/simple_animal/hostile/blob_minion/spore/minion/death_burst()
	return // This behaviour is superceded by the overmind's intervention


/// Weakened spore spawned by distributed neurons, can't zombify people and makes a teeny explosion
/mob/living/simple_animal/hostile/blob_minion/spore/minion/weak
	name = "fragile blob spore"
	health = 15
	maxHealth = 15
	melee_damage_lower = 1
	melee_damage_upper = 2
	death_cloud_size = 1

/mob/living/simple_animal/hostile/blob_minion/spore/minion/weak/zombify()
	return

/mob/living/simple_animal/hostile/blob_minion/spore/minion/weak/on_strain_updated()
	return
