/obj/effect/vaultspawner
	var/maxX = 6
	var/maxY = 6
	var/minX = 2
	var/minY = 2

/obj/effect/vaultspawner/Initialize(mapload, lX = minX, uX = maxX, lY = minY, uY = maxY, vault_type)
	. = ..()
	if(!vault_type)
		vault_type = pick("sandstone", "rock", "alien")

	var/turf/location = get_turf(src)
	var/lowBoundX = location.x
	var/lowBoundY = location.y
	var/hiBoundX = location.x + rand(lX, uX)
	var/hiBoundY = location.y + rand(lY, uY)
	var/z = location.z

	for(var/i in (lowBoundX) to (hiBoundX))
		for(var/j in (lowBoundY) to (hiBoundY))
			if(i == lowBoundX || i == hiBoundX || j == lowBoundY || j == hiBoundY)
				new /turf/simulated/wall/vault(locate(i, j, z), vault_type)
			else
				var/turf/T = new /turf/simulated/floor/vault(locate(i, j, z))
				T.icon_state = "[vault_type]vault"

	return INITIALIZE_HINT_QDEL
