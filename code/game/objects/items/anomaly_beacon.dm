/obj/item/assembly/anomaly_beacon
	icon = 'icons/obj/weapons/techrelic.dmi'
	icon_state = "beacon"
	item_state = "beacon"
	lefthand_file = 'icons/mob/inhands/relics_production/inhandl.dmi'
	righthand_file = 'icons/mob/inhands/relics_production/inhandr.dmi'
	name = "anomaly beacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	origin_tech = "bluespace=6"

/obj/item/assembly/anomaly_beacon/activate()
	var/obj/effect/anomaly/anomaly_path = pick(subtypesof(/obj/effect/anomaly/))
	var/newAnomaly = new anomaly_path(get_turf(src))
	notify_ghosts("[name] has an object of interest: [newAnomaly]!", title = "Something's Interesting!", source = newAnomaly, action = NOTIFY_FOLLOW)
	qdel(src)

/obj/item/assembly/anomaly_beacon/attack_self(mob/user)
	activate()

/datum/crafting_recipe/anomaly_beacon
	name = "Anomaly beacon"
	result = /obj/item/assembly/anomaly_beacon
	tools = list(TOOL_SCREWDRIVER)
	reqs = list(/obj/item/assembly/signaler/anomaly = 1,
				/obj/item/relict_production/rapid_dupe = 1,
				/obj/item/radio/beacon = 1,
				/obj/item/stack/cable_coil = 5)
	time = 300
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
