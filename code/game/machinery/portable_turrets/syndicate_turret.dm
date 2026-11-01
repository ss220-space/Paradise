/obj/machinery/porta_turret/syndicate
	projectile = /obj/projectile/bullet
	eprojectile = /obj/projectile/bullet
	// Syndicate turrets *always* operate in lethal mode.
	// So, nothing, not even emagging them, makes them switch bullet type.
	// So, its best to always have their projectile and eprojectile settings be the same. That way, you know what they will shoot.
	// Otherwise, you end up with situations where one of the two bullet types will never be used.
	shot_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	eshot_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'

	icon_state = "syndieturret0"
	var/icon_state_initial = "syndieturret0"
	var/icon_state_active = "syndieturret1"
	var/icon_state_destroyed = "syndieturret2"

	syndicate = TRUE
	installation = null
	always_up = TRUE
	use_power = NO_POWER_USE
	has_cover = FALSE
	raised = TRUE
	density = TRUE
	scan_range = 9

	faction = "syndicate"
	emp_vulnerable = FALSE

	lethal = TRUE
	lethal_is_configurable = FALSE
	targetting_is_configurable = FALSE
	check_arrest = FALSE
	check_records = FALSE
	check_access = FALSE
	check_synth	= TRUE
	ailock = TRUE
	req_access = list(ACCESS_SYNDICATE)
	var/area/syndicate_depot/core/depotarea

/obj/machinery/porta_turret/syndicate/die()
	. = ..()
	if(istype(depotarea))
		depotarea.turret_died()

	density = FALSE

/obj/machinery/porta_turret/syndicate/shootAt(mob/living/target)
	if(istype(depotarea))
		depotarea.list_add(target, depotarea.hostile_list)
		depotarea.declare_started()
	return ..(target)

/obj/machinery/porta_turret/syndicate/update_icon_state()
	if(stat & BROKEN)
		icon_state = icon_state_destroyed
	else if(enabled)
		icon_state = icon_state_active
	else
		icon_state = icon_state_initial

/obj/machinery/porta_turret/syndicate/setup()
	return

/obj/machinery/porta_turret/syndicate/assess_perp(mob/living/carbon/human/perp)
	return 10 //Syndicate turrets shoot everything not in their faction

/obj/machinery/porta_turret/syndicate/pod
	health = 40
	projectile = /obj/projectile/bullet/weakbullet3
	eprojectile = /obj/projectile/bullet/weakbullet3

/obj/machinery/porta_turret/syndicate/interior
	name = "machine gun turret (.45)"
	desc = "Syndicate interior defense turret chambered for .45 rounds. Designed to down intruders without damaging the hull."
	projectile = /obj/projectile/bullet/midbullet
	eprojectile = /obj/projectile/bullet/midbullet

/obj/machinery/porta_turret/syndicate/exterior
	name = "machine gun turret (7.62)"
	desc = "Syndicate exterior defense turret chambered for 7.62 rounds. Designed to down intruders with heavy calliber bullets."

/obj/machinery/porta_turret/syndicate/grenade
	name = "mounted grenade launcher (40mm)"
	desc = "Syndicate 40mm grenade launcher defense turret. If you've had this much time to look at it, you're probably already dead."
	icon_state = "syndieturret01"
	icon_state_initial = "syndieturret01"
	icon_state_active = "syndieturret01"
	projectile = /obj/projectile/bullet/a40mm
	eprojectile = /obj/projectile/bullet/a40mm

/obj/machinery/porta_turret/syndicate/assault_pod
	name = "machine gun turret (4.6x30mm)"
	desc = "Syndicate exterior defense turret chambered for 4.6x30mm rounds. Designed to be fitted to assault pods, it uses low calliber bullets to save space."
	health = 100
	projectile = /obj/projectile/bullet/weakbullet3
	eprojectile = /obj/projectile/bullet/weakbullet3

/obj/machinery/porta_turret/syndicate/vox
	name = "vox turret"
	projectile = /obj/projectile/beam/disabler
	eprojectile = /obj/projectile/beam/disabler
	faction = "Vox"
