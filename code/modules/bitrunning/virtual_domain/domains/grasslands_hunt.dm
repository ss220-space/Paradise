/datum/lazy_template/virtual_domain/grasslands_hunt
	name = "Охота в степи"
	desc = "Мирная охота в дикой местности."
	help_text = "Охотник должен уметь выследить и добыть зверя. Докажите, что вы на это способны."
	is_modular = TRUE
	key = LAZY_TEMPLATE_KEY_BITRUNNING_GRASSLANDS_HUNT
	map_name = "grasslands_hunt"
	mob_modules = list(/datum/modular_mob_segment/deer)
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/datum/lazy_template/virtual_domain/grasslands_hunt/setup_domain(list/created_atoms)
	for(var/turf/tile as anything in created_atoms)
		for(var/obj/effect/landmark/bitrunning/mob_segment/landmark in tile)
			RegisterSignal(landmark, COMSIG_BITRUNNING_MOB_SEGMENT_SPAWNED, PROC_REF(on_spawned))

/datum/lazy_template/virtual_domain/grasslands_hunt/proc/on_spawned(datum/source, list/mobs)
	SIGNAL_HANDLER

	for(var/mob/living/fauna as anything in mobs)
		RegisterSignal(fauna, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/lazy_template/virtual_domain/grasslands_hunt/proc/on_death(datum/source)
	SIGNAL_HANDLER

	add_points(3.5)
