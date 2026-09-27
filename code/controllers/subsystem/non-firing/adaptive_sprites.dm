SUBSYSTEM_DEF(adaptive_sprites)
	name = "Adaptive Sprites"
	ss_flags = SS_NO_FIRE

	var/list/profiles = list()

/datum/controller/subsystem/adaptive_sprites/Initialize()
	for(var/species_name in GLOB.all_species)
		var/datum/species/species = GLOB.all_species[species_name]
		var/datum/species_fit/species_fit = get_species_fit(species.fit_profile)
		if(!species_fit || (species_fit in profiles))
			continue
		species_fit.build()
		species_fit.load_disk_cache()
		profiles += species_fit
	purge_stale_caches()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/adaptive_sprites/Shutdown()
	for(var/datum/species_fit/species_fit in profiles)
		species_fit.flush_disk_cache()

/datum/controller/subsystem/adaptive_sprites/proc/purge_stale_caches()
	var/list/live_keys = list()
	for(var/datum/species_fit/species_fit in profiles)
		live_keys[species_fit.cache_key] = TRUE
	for(var/entry in flist("[FIT_CACHE_DIRECTORY]/"))
		if(live_keys[replacetext(entry, "/", "")])
			continue
		fdel("[FIT_CACHE_DIRECTORY]/[entry]")
