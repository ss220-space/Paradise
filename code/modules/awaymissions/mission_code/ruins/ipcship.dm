// AREAS
/area/ruin/space/ipcship/engine
	name = "Engine zone"
	icon_state = "ipc_ship3"
	requires_power = TRUE
	report_alerts = FALSE

/area/ruin/space/ipcship/shard
	name = "Shard zone"
	icon_state = "ipc_ship4"
	requires_power = TRUE
	report_alerts = FALSE

/area/ruin/space/ipcship/middle
	name = "Middle zone"
	icon_state = "ipc_ship2"
	requires_power = TRUE

/area/ruin/space/ipcship/asteroid
	name = "IPC asteroid zone"
	icon_state = "ipc_ship"
	requires_power = FALSE

/area/ruin/space/ipcship/aft
	name = "IPC aft zone"
	icon_state = "ipc_ship1"
	requires_power = TRUE

// HEADCRAB SPAWNERS
/obj/structure/spawner/headcrab/smaller_amount
	max_mobs = 7

// IPC corpse
/obj/effect/mob_spawn/human/corpse/ipc
	mob_type = /mob/living/carbon/human/machine
	name = "Machine corpse"
	icon = 'icons/mob/human_races/r_golem.dmi'
	icon_state = "overlay_husk"
	mob_name = "Unknown IPC"
	random = TRUE
	death = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/ipc_corpse

/datum/outfit/ipc_corpse
	name = "IPC corpse"
	uniform = /obj/item/clothing/under/misc/durathread
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack
	l_ear = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/black

/obj/effect/mob_spawn/human/corpse/ipc/Initialize()
	brute_damage = rand(0, 400)
	burn_damage = rand(0, 400)
	return ..()

// ТРУП ХЕДКРАБА, ПЕРЕНЕСТИ В CORPSE.DM

/obj/effect/mob_spawn/headcrab
	mob_type = /mob/living/simple_animal/hostile/headcrab
	death = TRUE
	name = "Dead headcrab"
	icon = 'icons/mob/headcrab.dmi'
	icon_state = "headcrab_dead"
