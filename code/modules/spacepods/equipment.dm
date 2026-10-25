/obj/item/spacepod_equipment/weaponry/proc/fire_weapons(mob/user, target_x, target_y)
	var/obj/spacepod/craft = my_atom
	if(!user || QDELETED(craft) || user != craft.pilot || user.incapacitated())
		return
	if((HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt) && harmful)
		to_chat(user, span_warning("Вы не хотите причинять вред живым существам."))
		return
	if(craft.next_firetime > world.time)
		return
	if(!craft.equipment_system || craft.equipment_system.weapon_system != src)
		return
	if(craft.overmap_vessel?.overmap_pod?.is_in_own_pocket())
		if(!craft.overmap_vessel.in_free_flight() || !craft.overmap_vessel.sector)
			to_chat(user, span_warning("Орудия недоступны во время перехода."))
			return
	if(isnum(target_x) && isnum(target_y))
		var/datum/component/ship_weapon/weapon = GetComponent(/datum/component/ship_weapon)
		var/obj/overmap/entity/vessel = weapon.host()
		if(!vessel || !weapon.can_aim(vessel, target_x, target_y))
			return FALSE
	if(!craft.battery?.use(shot_cost))
		to_chat(user, span_warning("Недостаточно энергии для выстрела."))
		return
	craft.next_firetime = world.time + fire_delay
	INVOKE_ASYNC(src, PROC_REF(fire_burst), user, target_x, target_y)
	return TRUE

/obj/item/spacepod_equipment/weaponry/proc/fire_burst(mob/user, target_x, target_y)
	var/obj/spacepod/craft = my_atom
	for(var/i in 1 to shots_per)
		if(QDELETED(craft) || QDELETED(src) || craft.pilot != user)
			break
		if(craft.overmap_vessel?.overmap_pod?.is_in_own_pocket() && !craft.overmap_vessel.in_free_flight())
			break
		var/datum/component/ship_weapon/weapon = GetComponent(/datum/component/ship_weapon)
		if(isnum(target_x) && isnum(target_y) && !weapon.can_aim(weapon.host(), target_x, target_y))
			break
		for(var/side in list(-1, 1))
			var/obj/projectile/projectile = new projectile_type(null)
			projectile.overmap_radar_visible |= overmap_radar_visible
			if(penetration_chance)
				projectile.ship_penetrations = 1
				projectile.ship_penetration_chance = penetration_chance
				projectile.ship_penetration_decay = 0.5
			projectile.firer = user
			projectile.firer_source_atom = craft
			projectile.def_zone = BODY_ZONE_CHEST
			if(craft.overmap_vessel?.in_free_flight())
				craft.overmap_vessel.fire_pod_projectile(projectile, side, target_x, target_y)
			else
				var/turf/muzzle = get_turf(craft)
				switch(craft.dir)
					if(NORTH)
						muzzle = get_step(muzzle, NORTH)
						if(side > 0)
							muzzle = get_step(muzzle, EAST)
					if(SOUTH)
						if(side > 0)
							muzzle = get_step(muzzle, EAST)
					if(EAST)
						muzzle = get_step(muzzle, EAST)
						if(side > 0)
							muzzle = get_step(muzzle, NORTH)
					if(WEST)
						if(side > 0)
							muzzle = get_step(muzzle, NORTH)
				projectile.forceMove(muzzle)
				projectile.starting = get_turf(craft)
				if(isnum(target_x) && isnum(target_y))
					var/list/point = weapon.world_position(weapon.host())
					var/obj/overmap/entity/owner = SSovermap.frame_owner(muzzle)
					projectile.set_angle(delta_to_angle(target_x - point[1], target_y - point[2]) - (istype(owner) ? owner.get_facing() : 0))
					projectile.fire()
				else
					projectile.dumbfire(craft.dir)
		if(fire_sound)
			craft.play_sound_to_riders(fire_sound)
		sleep(2)

/datum/spacepod/equipment

	var/obj/spacepod/my_atom
	var/list/obj/item/spacepod_equipment/installed_modules = list() // holds an easy to access list of installed modules
	var/obj/item/spacepod_equipment/weaponry/weapon_system // weapons system
	var/obj/item/spacepod_equipment/misc/misc_system // misc system
	var/obj/item/spacepod_equipment/cargo/cargo_system // cargo system
	var/obj/item/spacepod_equipment/sec_cargo/sec_cargo_system // secondary cargo system
	var/obj/item/spacepod_equipment/lock/lock_system // lock system
	var/obj/item/spacepod_equipment/locators/locator_system //locator_system

/datum/spacepod/equipment/Destroy(force)
	my_atom = null
	QDEL_LIST(installed_modules)
	weapon_system = null
	misc_system = null
	cargo_system = null
	sec_cargo_system = null
	lock_system = null
	locator_system = null
	. = ..()

/datum/spacepod/equipment/New(obj/spacepod/SP)
	..()
	if(istype(SP))
		my_atom = SP

/obj/item/spacepod_equipment
	name = "equipment"
	icon = 'icons/obj/spacepod.dmi'
	var/obj/spacepod/my_atom
	var/occupant_mod = 0	// so any module can modify occupancy
	var/list/storage_mod = list("slots" = 0, "w_class" = 0)		// so any module can modify storage slots

/obj/item/spacepod_equipment/Destroy()
	my_atom?.equipment_system?.installed_modules -= src
	my_atom = null
	. = ..()

/obj/item/spacepod_equipment/proc/removed(mob/user) // So that you can unload cargo when you remove the module
	return

/*
///////////////////////////////////////
/////////Weapon System///////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/weaponry
	name = "pod weapon"
	desc = "You shouldn't be seeing this"
	icon_state = null
	var/obj/projectile/projectile_type
	var/penetration_chance = 0
	var/overmap_radar_visible = FALSE
	var/shot_cost = 0
	var/shots_per = 1
	var/fire_sound
	var/fire_delay = 15
	var/harmful = TRUE

/obj/item/spacepod_equipment/weaponry/Initialize(mapload)
	. = ..()
	var/datum/component/ship_weapon/weapon = AddComponent(/datum/component/ship_weapon)
	weapon.arc = 20
	weapon.automatic = FALSE
	weapon.mount_dir = NORTH

/obj/item/spacepod_equipment/weaponry/Destroy()
	if(my_atom?.equipment_system?.weapon_system == src)
		my_atom.equipment_system.weapon_system = null
	. = ..()

/obj/item/spacepod_equipment/weaponry/taser
	name = "disabler system"
	desc = "A weak disabler system for space pods, fires disabler beams."
	icon_state = "weapon_taser"
	projectile_type = /obj/projectile/beam/disabler
	shot_cost = 800
	shots_per = 2
	fire_sound = 'sound/weapons/taser.ogg'
	harmful = FALSE

/obj/item/spacepod_equipment/weaponry/burst_taser
	name = "burst disabler system"
	desc = "A weak disabler system for space pods, this one fires 3 round burst at a time."
	icon_state = "weapon_burst_taser"
	projectile_type = /obj/projectile/beam/disabler
	shot_cost = 1200
	shots_per = 3
	fire_sound = 'sound/weapons/taser.ogg'
	fire_delay = 30
	harmful = FALSE

/obj/item/spacepod_equipment/weaponry/laser
	name = "laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy."
	icon_state = "weapon_laser"
	projectile_type = /obj/projectile/beam
	shot_cost = 1200
	shots_per = 2
	fire_sound = 'sound/weapons/laser.ogg'

/obj/item/spacepod_equipment/weaponry/solaris
	penetration_chance = 50
	overmap_radar_visible = TRUE
	name = "solaris system"
	desc = "A stronger vesion of laser systems for pods. Fires high concetrated bursts of energy"
	icon_state = "weapon_laser"
	projectile_type = /obj/projectile/beam/laser/heavylaser
	shot_cost = 1800
	shots_per = 2
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/spacepod_equipment/weaponry/ion
	name = "ion system"
	desc = "A paired ion projector for spacepods."
	icon_state = "weapon_taser"
	projectile_type = /obj/projectile/ion/pod
	shot_cost = 800
	shots_per = 1
	fire_sound = 'sound/weapons/ionrifle.ogg'

// MINING LASERS
/obj/item/spacepod_equipment/weaponry/mining_laser_basic
	name = "kinetic accelerator system"
	desc = "A kinetic accelerator system for space pods, fires bursts of kinetic force that cut through rock."
	icon = 'icons/goonstation/pods/ship.dmi'
	icon_state = "pod_taser"
	projectile_type = /obj/projectile/kinetic/pod
	shot_cost = 300
	fire_delay = 14
	fire_sound = 'sound/weapons/kenetic_accel.ogg'

/obj/item/spacepod_equipment/weaponry/mining_laser
	name = "industrial kinetic accelerator system"
	desc = "A industrial kinetic accelerator system for space pods, fires heavy bursts of kinetic force that cut through rock."
	icon = 'icons/goonstation/pods/ship.dmi'
	icon_state = "pod_m_laser"
	projectile_type = /obj/projectile/kinetic/pod/regular
	shot_cost = 250
	fire_delay = 10
	fire_sound = 'sound/weapons/kenetic_accel.ogg'

/*
///////////////////////////////////////
/////////Misc. System///////////////////
///////////////////////////////////////
*/

GLOBAL_LIST_EMPTY(pod_trackers)

/obj/item/spacepod_equipment/misc
	name = "pod misc"
	desc = "You shouldn't be seeing this"
	icon = 'icons/goonstation/pods/ship.dmi'
	icon_state = null

/obj/item/spacepod_equipment/misc/tracker
	name = "spacepod tracking system"
	desc = "A tracking device for spacepods."
	icon_state = "pod_locator"

/obj/item/spacepod_equipment/misc/tracker/Initialize(mapload)
	GLOB.pod_trackers |= src
	return ..()

/obj/item/spacepod_equipment/misc/tracker/Destroy()
	GLOB.pod_trackers -= src
	if(my_atom?.equipment_system?.misc_system == src)
		my_atom.equipment_system.misc_system = null
	return ..()

/*
///////////////////////////////////////
/////////Cargo System//////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/cargo
	name = "pod cargo"
	desc = "You shouldn't be seeing this"
	icon_state = "cargo_blank"
	var/obj/storage = null

/obj/item/spacepod_equipment/cargo/Destroy()
	if(my_atom?.equipment_system?.cargo_system == src)
		my_atom.equipment_system.cargo_system = null
	QDEL_NULL(storage)
	. = ..()

/obj/item/spacepod_equipment/cargo/proc/passover(obj/item/I)
	return

/obj/item/spacepod_equipment/cargo/proc/unload() // called by unload verb
	if(storage)
		storage.forceMove(get_turf(my_atom))
		storage = null

/obj/item/spacepod_equipment/cargo/removed(mob/user) // called when system removed
	. = ..()
	unload()

// Ore System
/obj/item/spacepod_equipment/cargo/ore
	name = "spacepod ore storage system"
	desc = "An ore storage system for spacepods. Scoops up any ore you drive over."
	icon_state = "cargo_ore"

/obj/item/spacepod_equipment/cargo/ore/passover(obj/item/I)
	if(storage && istype(I,/obj/item/stack/ore))
		I.forceMove(storage)

// Crate System
/obj/item/spacepod_equipment/cargo/crate
	name = "spacepod crate storage system"
	desc = "A heavy duty storage system for spacepods. Holds one crate."
	icon_state = "cargo_crate"

/*
///////////////////////////////////////
/////////Secondary Cargo System////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/sec_cargo
	name = "secondary cargo"
	desc = "you shouldn't be seeing this"
	icon_state = null

/obj/item/spacepod_equipment/sec_cargo/Destroy()
	if(my_atom?.equipment_system?.sec_cargo_system == src)
		my_atom.equipment_system.sec_cargo_system = null
	. = ..()

// Passenger Seat
/obj/item/spacepod_equipment/sec_cargo/chair
	name = "passenger seat"
	desc = "A passenger seat for a spacepod."
	icon_state = "sec_cargo_chair"
	occupant_mod = 1

// Loot Box
/obj/item/spacepod_equipment/sec_cargo/loot_box
	name = "loot box"
	desc = "A small compartment to store valuables."
	icon_state = "sec_cargo_loot"
	storage_mod = list("slots" = 7, "w_class" = 14)

/*
///////////////////////////////////////
/////////Lock System///////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/lock
	name = "pod lock"
	desc = "You shouldn't be seeing this"
	icon_state = null
	var/mode = 0
	var/id = null

/obj/item/spacepod_equipment/lock/Destroy()
	if(my_atom?.equipment_system?.lock_system == src)
		my_atom.equipment_system.lock_system = null
	. = ..()

// Key and Tumbler System
/obj/item/spacepod_equipment/lock/keyed
	name = "spacepod tumbler lock"
	desc = "A locking system to stop podjacking. This version uses a standalone key."
	icon_state = "lock_tumbler"
	var/static/id_source = 0

/obj/item/spacepod_equipment/lock/keyed/Initialize(mapload)
	. = ..()
	id = ++id_source

// The key
/obj/item/spacepod_equipment/key
	name = "spacepod key"
	desc = "A key for a spacepod lock."
	icon_state = "podkey"
	w_class = WEIGHT_CLASS_TINY
	var/id = 0

// Key - Lock Interactions
/obj/item/spacepod_equipment/lock/keyed/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/spacepod_equipment/key))
		add_fingerprint(user)
		var/obj/item/spacepod_equipment/key/key = I
		if(key.id)
			to_chat(user, span_warning("This key is already ground."))
			return ATTACK_CHAIN_PROCEED
		key.id = id
		to_chat(user, span_notice("You have ground the blank key to fit the lock."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

// Locator System
/obj/item/spacepod_equipment/locators
	name = "Locator system"
	desc = "You shouldn't be seeing this"
	icon = 'icons/spacepods_paradise/locator.dmi'
	icon_state = null
	var/can_ignore_z = FALSE
	var/can_found_all = FALSE

/obj/item/spacepod_equipment/locators/Destroy()
	if(my_atom?.equipment_system?.locator_system == src)
		my_atom.equipment_system.locator_system = null
	. = ..()

/obj/item/spacepod_equipment/locators/proc/scan(mob/user)
	var/message_user = ""

	for(var/obj/effect/landmark/ruin/space_ruin in GLOB.ruin_landmarks)
		if((user.loc.z == space_ruin.z || can_ignore_z) && (space_ruin.ruin_template.can_found || can_found_all))
			message_user += "\nX:[space_ruin.x] Y:[space_ruin.y] Z:[space_ruin.z] Размер: [object_size(space_ruin.ruin_template.width*space_ruin.ruin_template.height)]"

	if(!message_user)
		atom_say("Объектов в секторе не обнаружено")
		return
	atom_say("Результаты поиска:[message_user]")

/obj/item/spacepod_equipment/locators/proc/object_size(square)
	if(square <= 500)
		return "Малый"
	else if(square <= 900)
		return "Средний"
	else if(square <= 3000)
		return "Большой"
	return "Огромный"

/obj/item/spacepod_equipment/locators/basic_pod_locator
	name = "Модуль поиска астероидов"
	desc = "Сканирующее устройство позволяющее определять координаты астероидов в секторе."
	icon_state = "pod_locator"
	origin_tech = "engineering=5;magnets=4"

/obj/item/spacepod_equipment/locators/advanced_pod_locator
	name = "Улучшеный модуль поиска астероидов"
	desc = "Улучшеный модуль поиска способный обнаружить любой объект в секторе"
	icon_state = "pod_locator"
	can_found_all = TRUE
