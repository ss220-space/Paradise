/obj/effect/landmark/spawner/vox_raider
	name = "Vox Raider"
	icon_state = "vox_raider"

/obj/effect/landmark/spawner/vox_raider/Initialize(mapload)
	spawner_list = GLOB.raider_spawn
	return ..()
