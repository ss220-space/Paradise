/atom/proc/add_gravity(id, gravity_delta)
	if(id in gravity_sources)
		gravity_sources[id] = 0

	gravity_sources[id] += gravity_delta

	if(!gravity_sources[id])
		gravity_sources.Remove(id)

	if(isliving(src))
		var/mob/living/M = src
		M.refresh_gravity()

/atom/proc/remove_gravity_source(id)
	gravity_sources.Remove(id)
	if(isliving(src))
		var/mob/living/M = src
		M.refresh_gravity()

/atom/proc/add_ignored_gravity_source(id)
	if(!(id in ignored_gravity_sources))
		ignored_gravity_sources[id] = 1
	else
		ignored_gravity_sources[id]++

/atom/proc/remove_ignored_gravity_source(id)
	ignored_gravity_sources[id]--
	if(!ignored_gravity_sources[id])
		ignored_gravity_sources.Remove(id)
