/obj/item/tuned_anomalous_teleporter
	name = "tuned anomalous teleporter"
	desc = "A portable item using blue-space technology."
	icon = 'icons/obj/weapons/techrelic.dmi'
	icon_state = "teleport"
	lefthand_file = 'icons/mob/inhands/relics_production/inhandl.dmi'
	righthand_file = 'icons/mob/inhands/relics_production/inhandr.dmi'
	item_state = "teleport"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10000)
	origin_tech = "magnets=3;bluespace=4"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Variable contains next time hand tele can be used to make it not EMP proof
	var/emp_timer = 0
	COOLDOWN_DECLARE(tuned_anomalous_teleporter_cooldown) // declare cooldown for teleportations
	COOLDOWN_DECLARE(emp_cooldown) // declare cooldown for EMP
	var/base_cooldown = 20 SECONDS // cooldown  for teleportations
	var/emp_cooldown_min = 10 SECONDS // min cooldown for emp
	var/emp_cooldown_max = 15 SECONDS // max cooldown for emp
	var/tp_range = 5 // range of teleportations
	origin_tech = "bluespace=5"

/obj/item/tuned_anomalous_teleporter/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, emp_cooldown))
		do_sparks(5, FALSE, loc)
		to_chat(user, span_warning("[src] attempts to teleport you, but abruptly shuts off."))
		return FALSE
	if(!COOLDOWN_FINISHED(src, tuned_anomalous_teleporter_cooldown))
		to_chat(user, span_warning("[src] is still recharging."))
		return FALSE

	COOLDOWN_START(src, tuned_anomalous_teleporter_cooldown, base_cooldown)

	var/datum/teleport/TP = new /datum/teleport()
	var/crossdir = angle2dir((dir2angle(user.dir)) % 360)
	var/turf/T1 = get_turf(user)
	for(var/i in 1 to tp_range)
		T1 = get_step(T1, crossdir)
	var/datum/effect_system/smoke_spread/s1 = new
	var/datum/effect_system/smoke_spread/s2 = new
	s1.set_up(5, FALSE, user)
	s2.set_up(5, FALSE, user)
	TP.start(user, T1, FALSE, TRUE, s1, s2, 'sound/effects/phasein.ogg', )
	TP.doTeleport()

/obj/item/tuned_anomalous_teleporter/emp_act(severity)
	make_inactive(severity)
	return ..()

/obj/item/tuned_anomalous_teleporter/proc/make_inactive(severity)
	var/time = rand(emp_cooldown_min, emp_cooldown_max) * (severity == EMP_HEAVY ? 2 : 1)
	COOLDOWN_START(src, emp_cooldown, time)

/obj/item/tuned_anomalous_teleporter/examine(mob/user)
	. = ..()
	if(emp_timer > world.time)
		. += span_warning("It looks inactive.")

/datum/crafting_recipe/tuned_anomalous_teleporter
	name = "Tuned anomalous teleporter"
	result = /obj/item/tuned_anomalous_teleporter
	tools = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	reqs = list(/obj/item/relict_production/strange_teleporter = 1,
				/obj/item/assembly/signaler/anomaly/bluespace = 1,
				/obj/item/gps = 1,
				/obj/item/stack/ore/bluespace_crystal,
				/obj/item/stack/sheet/metal = 2,
				/obj/item/stack/cable_coil = 5)
	time = 300
	category = CAT_MISC
