/// A shambling mob made out of a crew member
/mob/living/simple_animal/hostile/blob_minion/zombie
	name = "blob zombie"
	desc = "Шаркающий труп, оживленный блобом."
	icon_state = "zombie"
	icon_living = "zombie"
	health_doll_icon = "blobpod"
	health = BLOBMOB_ZOMBIE_HEALTH
	maxHealth = BLOBMOB_ZOMBIE_HEALTH
	verb_say = list("gurgles", "groans")
	verb_ask = "demands"
	verb_exclaim = "roars"
	verb_yell = "bellows"
	melee_damage_lower = BLOBMOB_ZOMBIE_DMG_LOWER
	melee_damage_upper = BLOBMOB_ZOMBIE_DMG_UPPER
	obj_damage = BLOBMOB_ZOMBIE_OBJ_DMG
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attacktext = "ударяет"
	attack_sound = 'sound/weapons/genhit1.ogg'
	deathmessage = 	"падает на землю!"
	gold_core_spawnable = NO_SPAWN
	del_on_death = TRUE
	speed = BLOBMOB_ZOMBIE_SPEED_MOD
	/// The dead body we have inside
	var/mob/living/carbon/human/corpse


/mob/living/simple_animal/hostile/blob_minion/zombie/death(gibbed)
	if(corpse)
		REMOVE_TRAIT(corpse, TRAIT_BLOB_ZOMBIFIED, BLOB_ZOMBIE_TRAIT)
		UnregisterSignal(corpse, list(COMSIG_HUMAN_DESTROYED, COMSIG_LIVING_REVIVE))
		corpse.forceMove(loc)
	death_burst()
	return ..()

/mob/living/simple_animal/hostile/blob_minion/zombie/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != corpse)
		return
	corpse = null
	death()

/mob/living/simple_animal/hostile/blob_minion/zombie/pull_constraint(atom/movable/pulled_atom, state, supress_message = FALSE) //Prevents spore from pulling things
	if(istype(pulled_atom, /mob/living))
		return TRUE // Get dem
	if(!supress_message)
		to_chat(src, span_warning("Вы не можете таскать ничего кроме других существ и их тел."))
	return FALSE

/mob/living/simple_animal/hostile/blob_minion/zombie/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/structure/blob))
		return TRUE


/mob/living/simple_animal/hostile/blob_minion/zombie/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)

/mob/living/simple_animal/hostile/blob_minion/zombie/Destroy()
	QDEL_NULL(corpse)
	return ..()

/mob/living/simple_animal/hostile/blob_minion/zombie/on_factory_destroyed()
	. = ..()
	death()

/mob/living/simple_animal/hostile/blob_minion/zombie/update_overlays()
	. = ..()
	. |= corpse?.overlays?.Copy()
	var/mutable_appearance/blob_head_overlay = mutable_appearance('icons/mob/blob.dmi', "blob_head")
	blob_head_overlay.color = LAZYACCESS(atom_colours, FIXED_COLOUR_PRIORITY) || COLOR_WHITE
	color = initial(color) // reversing what our component did lol, but we needed the value for the overlay
	. |= blob_head_overlay
	if(blocks_emissive)
		. |= get_emissive_block()


/// Create an explosion of spores on death
/mob/living/simple_animal/hostile/blob_minion/zombie/proc/death_burst()
	do_blob_chem_smoke(range = 1, holder = src, reagent_volume = BLOB_REAGENT_SPORE_VOL, location = get_turf(src), reagent_type = /datum/reagent/toxin/spore)

/// Store a body so that we can drop it on death
/mob/living/simple_animal/hostile/blob_minion/zombie/proc/consume_corpse(mob/living/carbon/human/new_corpse)
	ADD_TRAIT(new_corpse, TRAIT_BLOB_ZOMBIFIED, BLOB_ZOMBIE_TRAIT)
	if(new_corpse.wear_suit)
		maxHealth += new_corpse.getarmor(attack_flag = MELEE)
		health = maxHealth
	new_corpse.change_facial_hair("Shaved")
	new_corpse.change_hair("Bald")
	new_corpse.forceMove(src)
	corpse = new_corpse
	update_icon()
	RegisterSignal(corpse, COMSIG_LIVING_REVIVE, PROC_REF(on_corpse_revived))
	RegisterSignal(corpse, COMSIG_HUMAN_DESTROYED, PROC_REF(on_corpse_destroyed))

/// Dynamic changeling reentry
/mob/living/simple_animal/hostile/blob_minion/zombie/proc/on_corpse_revived()
	SIGNAL_HANDLER
	visible_message(span_boldwarning("[src] разрывается изнутри!"))
	death()

/mob/living/simple_animal/hostile/blob_minion/zombie/proc/on_corpse_destroyed()
	SIGNAL_HANDLER
	visible_message(span_boldwarning("C носитель уничтожено. [src] разрушается изнутри!"))
	death()

/// Blob-created zombies will ping for player control when they make a zombie
/mob/living/simple_animal/hostile/blob_minion/zombie/controlled

/mob/living/simple_animal/hostile/blob_minion/zombie/controlled/consume_corpse(mob/living/carbon/human/new_corpse)
	. = ..()
	if(!isnull(client) || SSticker.current_state == GAME_STATE_FINISHED)
		return
	AddComponent(\
		/datum/component/ghost_direct_control,\
		ban_type = ROLE_BLOB,\
		ban_syndicate = TRUE,\
		poll_candidates = TRUE,\
	)

/mob/living/simple_animal/hostile/blob_minion/zombie/controlled/death_burst()
	return
