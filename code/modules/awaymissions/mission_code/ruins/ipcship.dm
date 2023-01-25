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
	shoes = /obj/item/clothing/shoes/rainbow
	back = /obj/item/storage/backpack/duffel/durathread
	l_ear = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/black

/obj/effect/mob_spawn/human/corpse/ipc/Initialize()
	brute_damage = rand(80, 400)
	burn_damage = rand(80, 400)
	return ..()

// ТРУП ХЕДКРАБА, ПЕРЕНЕСТИ В CORPSE.DM

/obj/effect/mob_spawn/headcrab
	mob_type = /mob/living/simple_animal/hostile/headcrab
	death = TRUE
	name = "Dead headcrab"
	desc = "A small dead parasitic creature that would like to connect with your brain stem."
	icon = 'icons/mob/headcrab.dmi'
	icon_state = "headcrab_dead"

// discharged APC
/obj/machinery/power/apc/discharged
	locked = 0
	start_charge = 0
	operating = 0
	report_power_alarm = FALSE
	req_access = FALSE

/obj/item/mmi/robotic_brain/positronic/decorative
	name = "positronic brain"
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	blank_icon = "posibrain"
	searching_icon = "posibrain-searching"
	occupied_icon = "posibrain-occupied"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	silenced = TRUE
	requires_master = FALSE
	ejected_flavor_text = "metal cube"
	dead_icon = "posibrain"
	searching = FALSE

/obj/machinery/power/supermatter_shard/anchored
	anchored = TRUE

/obj/machinery/power/supermatter_shard/anchored/attackby(obj/item/W as obj, mob/living/user as mob, params)
	if(istype(W,/obj/item/wrench))
		if(!anchored)
			user.visible_message("<span class='danger'>As [user] tries to loose bolts of \the [src] with \a [W] the tool disappears</span>")
		else
			consume_wrench(W)
		user.apply_effect(150, IRRADIATE)
