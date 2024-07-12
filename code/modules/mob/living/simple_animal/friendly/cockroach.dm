/mob/living/simple_animal/cockroach
	name = "cockroach"
	desc = "This station is just crawling with bugs."
	icon_state = "cockroach"
	icon_dead = "cockroach"
	health = 1
	maxHealth = 1
	turns_per_move = 5
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	response_help  = "pokes"
	response_disarm = "shoos"
	response_harm   = "splats"
	death_sound = 'sound/creatures/crack_death2.ogg'
	density = FALSE
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	var/squish_chance = 50
	loot = list(/obj/effect/decal/cleanable/insectguts)
	del_on_death = 1
	tts_seed = "Villagerm"


/mob/living/simple_animal/cockroach/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/mob/living/simple_animal/cockroach/can_die()
	// If the nuke is going off, then cockroaches are invincible.
	// Keeps the nuke from killing them, cause cockroaches are immune to nukes.
	return ..() && !SSticker?.mode?.explosion_in_progress


/mob/living/simple_animal/cockroach/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isliving(arrived))
		var/mob/living/arrived_mob = arrived
		if(arrived_mob.mob_size > MOB_SIZE_SMALL)
			if(prob(squish_chance))
				arrived_mob.visible_message(
					span_notice("[arrived_mob] squashed [name]."),
					span_notice("You squashed [name]."),
				)
				death()
			else
				visible_message(span_notice("[name] avoids getting crushed."))

	else if(isstructure(arrived))
		visible_message(span_notice("As [arrived.name] moved over [name], it was crushed."))
		death()


/mob/living/simple_animal/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return

