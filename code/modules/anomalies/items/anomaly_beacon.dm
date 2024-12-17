/obj/item/assembly/anomaly_beacon
	icon = 'icons/obj/weapons/techrelic.dmi'
	icon_state = "beacon"
	item_state = "beacon"
	lefthand_file = 'icons/mob/inhands/relics_production/inhandl.dmi'
	righthand_file = 'icons/mob/inhands/relics_production/inhandr.dmi'
	name = "anomaly beacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	origin_tech = "bluespace=6"
	/// Inserted core of anomaly.
	var/obj/item/assembly/signaler/core/core = null

/obj/item/assembly/anomaly_beacon/activate()
	if(!core)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return

	var/datum/anomaly_gen_datum/gen_datum = GLOB.anomaly_types["[core.tier - 1]"][pick(GLOB.anomaly_types["[core.tier - 1]"])]
	var/obj/effect/anomaly/anomaly_path = gen_datum.anomaly
	var/newAnomaly = new anomaly_path(get_turf(src))
	notify_ghosts("[name] has an object of interest: [newAnomaly]!", title = "Аномалия!", source = newAnomaly, action = NOTIFY_FOLLOW)
	qdel(src)

/obj/item/assembly/anomaly_beacon/attack_self(mob/user)
	activate()

/obj/item/assembly/anomaly_beacon/attackby(obj/item/I, mob/user, params)
	if(!(iscore(I) && !iscoreempty(I) && !iscoret1(I)))
		return ..()

	if(!user.drop_transfer_item_to_loc(I, src))
		balloon_alert(user, "отпустить невозможно!")
		return ATTACK_CHAIN_PROCEED

	var/msg = "ядро вставлено"
	if(core)
		msg = "ядро заменено"
		user.put_in_hands(core)

	core = I
	user.balloon_alert(user, msg)
	return ATTACK_CHAIN_BLOCKED

/obj/item/assembly/anomaly_beacon/AltClick(mob/user)
	if(!core)
		user.balloon_alert(user, "нет ядра")
		return

	user.put_in_hands(core)
	core = null
	user.balloon_alert(user, "ядро извлечено")

/datum/crafting_recipe/anomaly_beacon
	name = "Anomaly beacon"
	result = /obj/item/assembly/anomaly_beacon
	tools = list(TOOL_SCREWDRIVER)
	reqs = list(/obj/item/relict_production/rapid_dupe = 1,
				/obj/item/radio/beacon = 1,
				/obj/item/stack/cable_coil = 5)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
