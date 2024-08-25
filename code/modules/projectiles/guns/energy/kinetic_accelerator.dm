#define COMPATIBILITY_STANDART	(1<<0)
#define COMPATIBILITY_CYBORG	(1<<1)
#define COMPATIBILITY_MINEBOT	(1<<2)
#define COMPATIBILITY_UNIVERSAL	(~0)


/**
 * ACCELERATORS
 */
/obj/item/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "A self recharging, ranged mining tool that does increased damage in low pressure. Capable of holding up to six slots worth of mod kits."
	icon_state = "kineticgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = /obj/item/stock_parts/cell/emproof
	needs_permit = FALSE
	origin_tech = "combat=3;powerstorage=3;engineering=3"
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 9
	can_bayonet = TRUE
	bayonet_x_offset = 20
	bayonet_y_offset = 12
	/// Lazylist of installed modkits.
	var/list/obj/item/borg/upgrade/modkit/modkits
	/// Bitflags. Used to determine which modkits fit into the KA.
	var/compatibility = COMPATIBILITY_STANDART
	/// Maximum "volume" that the modkits `cost` fills.
	var/max_mod_capacity = 100
	/// Dynamic weapon reload time (may depend on modkits on each shot).
	var/overheat_time = 1.6 SECONDS
	/// KA does discharge or not when it unequipped. Cyborg/minebot can't reload KA by equipping it in "hands", so their KA holds charge.
	var/holds_charge = FALSE
	/// KA reloads slower by each other KA in the inventory or not. Checks all inventory, so better not to use with unique KAs (in cyborg/minebot).
	var/unique_frequency = FALSE
	/// Is KA currently reloading?
	var/overheat = FALSE
	/// Unique uncharged sprite because of unique reload system.
	var/empty_state = "kineticgun_empty"
	/// Saved timer that can be overrided by modkits after hitting target.
	var/recharge_timerid


/obj/item/gun/energy/kinetic_accelerator/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(max_mod_capacity)
			. += span_notice("<b>[get_remaining_mod_capacity()]%</b> mod capacity remaining.")
			for(var/obj/item/borg/upgrade/modkit/MK in get_modkits())
				. += span_notice("There is a [MK.name] mod installed, using <b>[MK.cost]%</b> capacity.")


/obj/item/gun/energy/kinetic_accelerator/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/borg/upgrade/modkit))
		var/obj/item/borg/upgrade/modkit/modkit = I
		if(modkit.install(src, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/gun/energy/kinetic_accelerator/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deattach_modkits(user)


/obj/item/gun/energy/kinetic_accelerator/proc/attach_modkit(obj/item/borg/upgrade/modkit/MK, mob/user)
	return MK.install(src, user)


/obj/item/gun/energy/kinetic_accelerator/proc/deattach_modkits(mob/user)
	var/notification
	if(!LAZYLEN(modkits))
		notification = "модификации отсутствуют!"
	else
		for(var/obj/item/borg/upgrade/modkit/MK in modkits)
			modkit_predeattach(MK, loc)	// God bless anyone who have time for turning modkits back to `/obj/item/modkit`.
			MK.uninstall(src)
		notification = "модификации сняты"

	if(user)
		balloon_alert(user, notification)


/obj/item/gun/energy/kinetic_accelerator/proc/modkit_predeattach(obj/item/borg/upgrade/modkit/MK, atom/location)
	return


/obj/item/gun/energy/kinetic_accelerator/proc/get_remaining_mod_capacity()
	var/current_capacity_used = 0
	for(var/obj/item/borg/upgrade/modkit/MK in get_modkits())
		current_capacity_used += MK.cost
	return max_mod_capacity - current_capacity_used


/obj/item/gun/energy/kinetic_accelerator/proc/get_modkits()
	. = list()
	if(LAZYLEN(modkits))
		. = modkits


/obj/item/gun/energy/kinetic_accelerator/proc/modify_projectile(obj/item/projectile/kinetic/K)
	K.kinetic_gun = src // Do something special on-hit, easy!
	for(var/obj/item/borg/upgrade/modkit/MK in get_modkits())
		MK.modify_projectile(K)


/obj/item/gun/energy/kinetic_accelerator/cyborg
	compatibility = COMPATIBILITY_CYBORG
	holds_charge = TRUE
	unique_frequency = TRUE
	max_mod_capacity = 200


/obj/item/gun/energy/kinetic_accelerator/cyborg/attach_modkit(obj/item/borg/upgrade/modkit/MK, mob/user)
	if(isrobot(loc))
		var/mob/living/silicon/robot/loc_robot = loc
		loc_robot.install_upgrade(MK)
	return MK.install(src, user)


/obj/item/gun/energy/kinetic_accelerator/cyborg/modkit_predeattach(obj/item/borg/upgrade/modkit/MK, mob/living/silicon/robot/owner)
	if(istype(owner))
		owner.upgrades -= MK
		owner.UnregisterSignal(MK, COMSIG_QDELETING)


/obj/item/gun/energy/kinetic_accelerator/minebot
	compatibility = COMPATIBILITY_MINEBOT
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	overheat_time = 2 SECONDS
	holds_charge = TRUE
	unique_frequency = TRUE


/obj/item/gun/energy/kinetic_accelerator/Initialize(mapload)
	. = ..()
	if(!holds_charge)
		empty()


/obj/item/gun/energy/kinetic_accelerator/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	. = ..()
	attempt_reload()


/obj/item/gun/energy/kinetic_accelerator/equipped(mob/user, slot, initial)
	. = ..()
	if(!can_shoot(user))
		attempt_reload()


/obj/item/gun/energy/kinetic_accelerator/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(!QDELING(src) && !holds_charge)
		// Put it on a delay because moving item from slot to hand calls `dropped()`.
		addtimer(CALLBACK(src, PROC_REF(empty_if_not_held)), 0.2 SECONDS)


/obj/item/gun/energy/kinetic_accelerator/proc/empty_if_not_held()
	if(!ismob(loc))
		empty()


/obj/item/gun/energy/kinetic_accelerator/proc/empty()
	cell.use(500)
	update_icon()


/obj/item/gun/energy/kinetic_accelerator/proc/attempt_reload(recharge_time)
	if(overheat)
		return
	if(!recharge_time)
		recharge_time = overheat_time
	overheat = TRUE

	if(!unique_frequency)
		var/carried = 1	// The firing KA is already counted.

		for(var/obj/item/gun/energy/kinetic_accelerator/K in loc.GetAllContents() - src)
			if(!K.unique_frequency)
				carried++
		recharge_time = recharge_time * carried

	deltimer(recharge_timerid)
	recharge_timerid = addtimer(CALLBACK(src, PROC_REF(reload)), recharge_time, TIMER_STOPPABLE)


/obj/item/gun/energy/kinetic_accelerator/emp_act(severity)
	return


/obj/item/gun/energy/kinetic_accelerator/robocharge()
	return


/obj/item/gun/energy/kinetic_accelerator/proc/reload()
	cell.give(500)
	on_recharge()
	if(!suppressed)
		playsound(loc, 'sound/weapons/kenetic_reload.ogg', 60, TRUE)
	else if(isliving(loc))
		balloon_alert(loc, "арбалет заряжен")
	update_icon()
	overheat = FALSE


/obj/item/gun/energy/kinetic_accelerator/update_overlays()
	. = ..()
	if(empty_state && !can_shoot())
		. += empty_state


/obj/item/gun/energy/kinetic_accelerator/experimental
	name = "experimental kinetic accelerator"
	desc = "A modified version of the proto-kinetic accelerator, with more modkit space of the standard version."
	icon_state = "kineticgun_h"
	item_state = "kineticgun_h"
	origin_tech = "combat=5;powerstorage=3;engineering=5"
	max_mod_capacity = 150


/obj/item/gun/energy/kinetic_accelerator/mega
	name = "magmite proto-kinetic accelerator"
	icon_state = "kineticgun_m"
	item_state = "kineticgun_mega"
	empty_state = "kineticgun_m_empty"
	desc = "A self recharging, ranged mining tool that does increased damage in low pressure. This one has been enhanced with plasma magmite."
	origin_tech = "combat=5;powerstorage=3;engineering=5"
	max_mod_capacity = 200
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL


/**
 * CASING
 */
/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/kinetic
	muzzle_flash_color = null
	select_name = "kinetic"
	e_cost = 500
	fire_sound = 'sound/weapons/kenetic_accel.ogg'


/obj/item/ammo_casing/energy/kinetic/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	if(loc && istype(loc, /obj/item/gun/energy/kinetic_accelerator))
		var/obj/item/gun/energy/kinetic_accelerator/KA = loc
		KA.modify_projectile(BB)


/**
 * PROJECTILES
 */
/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 40
	hitsound = "bullet"
	damage_type = BRUTE
	flag = "bomb"
	range = 3
	/// How many `hardness` it takes from mineral turfs.
	var/power = 1
	/// Determines whether the pressure was low at the point of impact of the projectile and saves result here.
	var/pressure_decrease_active = FALSE
	/// The amount of damage we lost when shooting turfs with normal pressure.
	var/pressure_decrease = 0.25
	/// We keep the KA here to use the properties of its modkits when projectile hit the target.
	var/obj/item/gun/energy/kinetic_accelerator/kinetic_gun


/obj/item/projectile/kinetic/mech
	range = 5
	power = 3 // More power for the god of power!


/obj/item/projectile/kinetic/pod
	range = 4


/obj/item/projectile/kinetic/pod/regular
	damage = 50
	pressure_decrease = 0.5


/obj/item/projectile/kinetic/Destroy()
	kinetic_gun = null
	return ..()


/obj/item/projectile/kinetic/prehit(atom/target)
	. = ..()
	if(.)
		if(kinetic_gun)
			for(var/obj/item/borg/upgrade/modkit/M in kinetic_gun.get_modkits())
				M.projectile_prehit(src, target, kinetic_gun)
		if(!lavaland_equipment_pressure_check(get_turf(target)))
			name = "weakened [name]"
			damage = damage * pressure_decrease
			pressure_decrease_active = TRUE


/obj/item/projectile/kinetic/on_range()
	strike_thing()
	..()


/obj/item/projectile/kinetic/on_hit(atom/target)
	strike_thing(target)
	. = ..()


/obj/item/projectile/kinetic/proc/strike_thing(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	if(kinetic_gun) // Hopefully whoever shot this was not very, very unfortunate.
		var/list/obj/item/borg/upgrade/modkit/mods = kinetic_gun.get_modkits()
		for(var/obj/item/borg/upgrade/modkit/M in mods)
			M.projectile_strike_predamage(src, target_turf, target, kinetic_gun)
		for(var/obj/item/borg/upgrade/modkit/M in mods)
			M.projectile_strike(src, target_turf, target, kinetic_gun)
	if(ismineralturf(target_turf))
		if(isancientturf(target_turf))
			visible_message(span_notice("This rock appears to be resistant to all mining tools except pickaxes!"))
		else
			var/turf/simulated/mineral/M = target_turf
			M.attempt_drill(firer, FALSE, power)
	var/obj/effect/temp_visual/kinetic_blast/K = new /obj/effect/temp_visual/kinetic_blast(target_turf)
	K.color = color


/**
 * MODKITS
 */
/obj/item/borg/upgrade/modkit
	name = "kinetic accelerator modification kit"
	desc = "An upgrade for kinetic accelerators."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	origin_tech = "programming=2;materials=2;magnets=4"
	require_module = TRUE
	multiple_use = TRUE
	module_type = /obj/item/robot_module/miner
	usesound = 'sound/items/screwdriver.ogg'
	/// Bitflags. Used to determine which modkits fit into the KA.
	var/compatibility = COMPATIBILITY_UNIVERSAL
	/// Max number of modkits of the type specified in the `denied_type` that can be inserted into the KA.
	var/maximum_of_type = 1
	/// Blocks the installation of a modkit in the KA, if inside KA is already a sufficient number (specified in the `maximum_of_type`) of modkits of the type defined here.
	var/denied_type = null
	/// Modkit's "volume" that fills KA's `max_mod_capacity`.
	var/cost = 30
	/// Just a number for use in any mod kit that has numerical modifiers.
	var/modifier = 1


/obj/item/borg/upgrade/modkit/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += span_notice("Occupies <b>[cost]%</b> of mod capacity.")


/obj/item/borg/upgrade/modkit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/gun/energy/kinetic_accelerator))
		if(install(I, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/borg/upgrade/modkit/action(mob/living/silicon/robot/R)
	if(..())
		for(var/obj/item/gun/energy/kinetic_accelerator/cyborg/KA in R.module.modules)
			return KA.attach_modkit(src, usr)


/obj/item/borg/upgrade/modkit/deactivate(mob/living/silicon/robot/R, user = usr)
	if(..())
		for(var/obj/item/gun/energy/kinetic_accelerator/cyborg/KA in R.module.modules)
			return uninstall(KA, usr)


/obj/item/borg/upgrade/modkit/proc/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	add_fingerprint(user)
	KA.add_fingerprint(user)
	if(!(compatibility & KA.compatibility))
		to_chat(user, span_warning("Похоже, что этот модуль не подходит для таких ускорителей!"))
		return FALSE
	. = TRUE
	if(denied_type)
		var/number_of_denied = 0
		for(var/obj/item/borg/upgrade/modkit/MK in KA.get_modkits())
			if(istype(MK, denied_type))
				number_of_denied++
			if(number_of_denied >= maximum_of_type)
				. = FALSE
				break
	if(KA.get_remaining_mod_capacity() >= cost)
		if(.)
			if(loc == user && !user.drop_transfer_item_to_loc(src, KA))
				return FALSE
			if(loc != KA)
				forceMove(KA)
			balloon_alert(user, "модификация установлена!")
			playsound(loc, usesound, 100, TRUE)
			LAZYADD(KA.modkits, src)
		else
			to_chat(user, span_notice("The modkit you're trying to install would conflict with an already installed modkit. Use a crowbar to remove existing modkits."))
	else
		to_chat(user, span_notice("You don't have room(<b>[KA.get_remaining_mod_capacity()]%</b> remaining, [cost]% needed) to install this modkit. Use a crowbar to remove existing modkits."))
		. = FALSE


/obj/item/borg/upgrade/modkit/proc/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	forceMove(get_turf(KA))
	LAZYREMOVE(KA.modkits, src)


/obj/item/borg/upgrade/modkit/proc/modify_projectile(obj/item/projectile/kinetic/K)


/// Use this one for effects you want to trigger before any damage is done at all and before damage is decreased by pressure.
/obj/item/borg/upgrade/modkit/proc/projectile_prehit(obj/item/projectile/kinetic/K, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
/// Use this one for effects you want to trigger before mods that do damage.
/obj/item/borg/upgrade/modkit/proc/projectile_strike_predamage(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
/// Use this one for things that don't need to trigger before other damage-dealing mods.
/obj/item/borg/upgrade/modkit/proc/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)


// Range
/obj/item/borg/upgrade/modkit/range
	name = "range increase"
	desc = "Increases the range of a kinetic accelerator when installed."
	modifier = 1
	cost = 24 // So you can fit four plus a tracer cosmetic.


/obj/item/borg/upgrade/modkit/range/modify_projectile(obj/item/projectile/kinetic/K)
	K.range += modifier


/obj/item/borg/upgrade/modkit/range/borg
	compatibility = COMPATIBILITY_CYBORG


// Damage
/obj/item/borg/upgrade/modkit/damage
	name = "damage increase"
	desc = "Increases the damage of kinetic accelerator when installed."
	modifier = 10


/obj/item/borg/upgrade/modkit/damage/modify_projectile(obj/item/projectile/kinetic/K)
	K.damage += modifier


/obj/item/borg/upgrade/modkit/damage/borg
	desc = "Increases the damage of kinetic accelerator when installed. Only rated for cyborg use."
	compatibility = COMPATIBILITY_CYBORG


// Cooldown
/obj/item/borg/upgrade/modkit/cooldown
	maximum_of_type = 2
	compatibility = COMPATIBILITY_STANDART|COMPATIBILITY_CYBORG


/obj/item/borg/upgrade/modkit/cooldown/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.overheat_time -= modifier


/obj/item/borg/upgrade/modkit/cooldown/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	KA.overheat_time += modifier
	..()


/obj/item/borg/upgrade/modkit/cooldown/haste
	name = "cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Not rated for minebot use."
	denied_type = /obj/item/borg/upgrade/modkit/cooldown/haste
	modifier = 3.2


/obj/item/borg/upgrade/modkit/cooldown/haste/borg
	desc = "Decreases the cooldown of a kinetic accelerator. Only rated for cyborg use."
	compatibility = COMPATIBILITY_CYBORG


/obj/item/borg/upgrade/modkit/cooldown/haste/minebot
	name = "minebot cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Only rated for minebot use."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	modifier = 10
	cost = 0
	compatibility = COMPATIBILITY_MINEBOT


/obj/item/borg/upgrade/modkit/cooldown/repeater
	name = "rapid repeater"
	desc = "Quarters the kinetic accelerator's cooldown on striking a living target, but greatly increases the base cooldown. Not rated for minebot use."
	denied_type = /obj/item/borg/upgrade/modkit/cooldown/repeater
	modifier = -14 // Makes the cooldown 3 seconds (with no cooldown mods) if you miss. Don't miss.
	cost = 50

/obj/item/borg/upgrade/modkit/cooldown/repeater/borg
	compatibility = COMPATIBILITY_CYBORG

/obj/item/borg/upgrade/modkit/cooldown/repeater/projectile_strike_predamage(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	var/valid_repeat = FALSE
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			valid_repeat = TRUE
	if(ismineralturf(target_turf))
		valid_repeat = TRUE
	if(valid_repeat)
		KA.overheat = FALSE
		KA.attempt_reload(KA.overheat_time * 0.25) // If you hit, the cooldown drops to 0.75 seconds.


// AoE blasts
/obj/item/borg/upgrade/modkit/aoe
	denied_type = /obj/item/borg/upgrade/modkit/aoe
	maximum_of_type = 3
	modifier = 0
	/// Projectile will hit mineral turfs around or not.
	var/turf_aoe = FALSE
	/// It's stats was stolen by other aoe modkit during installation.
	var/stats_stolen = FALSE


/obj/item/borg/upgrade/modkit/aoe/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/item/borg/upgrade/modkit/aoe/AOE in KA.get_modkits()) // Make sure only one of the aoe modules has values if somebody has multiple.
		if(AOE.stats_stolen || AOE == src)
			continue
		modifier += AOE.modifier // Take its modifiers.
		AOE.modifier = 0
		turf_aoe += AOE.turf_aoe
		AOE.turf_aoe = FALSE
		AOE.stats_stolen = TRUE


/obj/item/borg/upgrade/modkit/aoe/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	..()
	modifier = initial(modifier) // Get our modifiers back.
	turf_aoe = initial(turf_aoe)
	stats_stolen = FALSE


/obj/item/borg/upgrade/modkit/aoe/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(stats_stolen)
		return
	new /obj/effect/temp_visual/explosion/fast(target_turf)
	if(turf_aoe)
		for(var/T in RANGE_TURFS(1, target_turf) - target_turf)
			if(ismineralturf(T) && !isancientturf(T))
				var/turf/simulated/mineral/M = T
				M.attempt_drill(K.firer)
	if(modifier)
		for(var/mob/living/L in range(1, target_turf) - K.firer - target)
			var/armor = L.run_armor_check(K.def_zone, K.flag, "", "", K.armour_penetration)
			L.apply_damage(K.damage * modifier, K.damage_type, K.def_zone, armor)
			to_chat(L, span_userdanger("You're struck by a [K.name]!"))


/obj/item/borg/upgrade/modkit/aoe/turfs
	name = "mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock in an AoE."
	turf_aoe = TRUE


/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	name = "offensive mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock and damage mobs in an AoE."
	modifier = 0.25


/obj/item/borg/upgrade/modkit/aoe/mobs
	name = "offensive explosion"
	desc = "Causes the kinetic accelerator to damage mobs in an AoE."
	modifier = 0.2

/obj/item/borg/upgrade/modkit/aoe/turfs/borg
	compatibility = COMPATIBILITY_CYBORG

/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs/borg
	compatibility = COMPATIBILITY_CYBORG

/obj/item/borg/upgrade/modkit/aoe/mobs/borg
	compatibility = COMPATIBILITY_CYBORG

// Minebot passthrough
/obj/item/borg/upgrade/modkit/minebot_passthrough
	name = "minebot passthrough"
	desc = "Causes kinetic accelerator shots to pass through minebots."
	cost = 0


// Hardness
/obj/item/borg/upgrade/modkit/hardness
	name = "hardness increase"
	desc = "Increases the maximum piercing power of a kinetic accelerator when installed."
	denied_type = /obj/item/borg/upgrade/modkit/hardness
	cost = 30


/obj/item/borg/upgrade/modkit/hardness/modify_projectile(obj/item/projectile/kinetic/K)
	K.power += modifier


/obj/item/borg/upgrade/modkit/hardness/borg
	compatibility = COMPATIBILITY_CYBORG


// Resonator Blasts
/obj/item/borg/upgrade/modkit/resonator_blasts
	name = "resonator blast"
	desc = "Causes kinetic accelerator shots to leave and detonate resonator blasts."
	denied_type = /obj/item/borg/upgrade/modkit/resonator_blasts
	cost = 30
	modifier = 0.25 // A bonus 15 damage if you burst the field on a target, 60 if you lure them into it.

/obj/item/borg/upgrade/modkit/resonator_blasts/borg
	compatibility = COMPATIBILITY_CYBORG

/obj/item/borg/upgrade/modkit/resonator_blasts/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(target_turf && !ismineralturf(target_turf)) // Don't make fields on mineral turfs.
		var/obj/effect/temp_visual/resonance/R = locate(/obj/effect/temp_visual/resonance) in target_turf
		if(R)
			R.damage_multiplier = modifier
			R.burst()
			return
		new /obj/effect/temp_visual/resonance(target_turf, K.firer, null, 30)


// Tendril-unique modules
/obj/item/borg/upgrade/modkit/lifesteal
	name = "lifesteal crystal"
	desc = "Causes kinetic accelerator shots to slightly heal the firer on striking a living target. Only rated for humanoid use."
	icon_state = "modkit_crystal"
	modifier = 2.5 //Not a very effective method of healing.
	cost = 20
	compatibility = COMPATIBILITY_STANDART
	/// Healing occurs in the order indicated here, but total healing amount can't be more than modkit `modifier`.
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)


/obj/item/borg/upgrade/modkit/lifesteal/projectile_prehit(obj/item/projectile/kinetic/K, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(isliving(target) && isliving(K.firer))
		var/mob/living/L = target
		if(L.stat == DEAD)
			return
		L = K.firer
		L.heal_ordered_damage(modifier, damage_heal_order)


/obj/item/borg/upgrade/modkit/bounty
	name = "death syphon"
	desc = "Killing or assisting in killing a creature permanently increases your damage against that type of creature."
	denied_type = /obj/item/borg/upgrade/modkit/bounty
	modifier = 1.25
	cost = 30
	/// Max number of "bonus damage" stacks for one type of mob.
	var/maximum_bounty = 25
	/// Associative lazylist of "bonus damage" stacks.
	var/list/bounties_reaped


/obj/item/borg/upgrade/modkit/bounty/projectile_prehit(obj/item/projectile/kinetic/K, mob/living/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(isliving(target))
		for(var/datum/status_effect/syphon_mark/syphon_mark_effect as anything in target.get_all_status_effect_of_id(STATUS_EFFECT_SYPHONMARK))
			// We want to allow multiple people with bounty modkits to use them, but we need to replace our own marks so we don't multi-reward.
			if(syphon_mark_effect.reward_target == src)
				syphon_mark_effect.reward_target = null
				qdel(syphon_mark_effect)
		target.apply_status_effect(STATUS_EFFECT_SYPHONMARK, src)


/obj/item/borg/upgrade/modkit/bounty/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(isliving(target))
		var/mob/living/L = target
		var/target_bounty = LAZYACCESS(bounties_reaped, L.type)
		if(target_bounty)
			var/kill_modifier = 1
			if(K.pressure_decrease_active)
				kill_modifier *= K.pressure_decrease
			var/armor = L.run_armor_check(K.def_zone, K.flag, "", "", K.armour_penetration)
			L.apply_damage(target_bounty * kill_modifier, K.damage_type, K.def_zone, armor)


/obj/item/borg/upgrade/modkit/bounty/proc/get_kill(mob/living/L)
	var/bonus_mod = 1
	if(ismegafauna(L)) // Megafauna reward.
		bonus_mod = 4
	var/target_bounty = LAZYACCESS(bounties_reaped, L.type)
	if(!target_bounty)
		LAZYADDASSOC(bounties_reaped, L.type, min(modifier * bonus_mod, maximum_bounty))
	else
		LAZYADDASSOC(bounties_reaped, L.type, min(target_bounty + (modifier * bonus_mod), maximum_bounty))


// Indoors
/obj/item/borg/upgrade/modkit/indoors
	name = "decrease pressure penalty"
	desc = "A syndicate modification kit that increases the damage a kinetic accelerator does in high pressure environments."
	modifier = 2
	denied_type = /obj/item/borg/upgrade/modkit/indoors
	maximum_of_type = 2
	cost = 35


/obj/item/borg/upgrade/modkit/indoors/modify_projectile(obj/item/projectile/kinetic/K)
	K.pressure_decrease *= modifier


// Trigger Guard
/obj/item/borg/upgrade/modkit/trigger_guard
	name = "modified trigger guard"
	desc = "Allows creatures normally incapable of firing guns to operate the weapon when installed. Only rated for humanoid use."
	cost = 20
	denied_type = /obj/item/borg/upgrade/modkit/trigger_guard
	compatibility = COMPATIBILITY_STANDART


/obj/item/borg/upgrade/modkit/trigger_guard/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(. && KA.trigger_guard != TRIGGER_GUARD_ALLOW_ALL)
		KA.trigger_guard = TRIGGER_GUARD_ALLOW_ALL


/obj/item/borg/upgrade/modkit/trigger_guard/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	KA.trigger_guard = TRIGGER_GUARD_NORMAL
	..()


// Cosmetic
/obj/item/borg/upgrade/modkit/chassis_mod
	name = "super chassis"
	desc = "Makes your KA yellow. All the fun of having a more powerful KA without actually having a more powerful KA."
	cost = 0
	denied_type = /obj/item/borg/upgrade/modkit/chassis_mod
	/// This text replaces KA's `icon_state` after installation.
	var/chassis_icon = "kineticgun_u"
	/// This text replaces KA's `name` after installation.
	var/chassis_name = "super-kinetic accelerator"


/obj/item/borg/upgrade/modkit/chassis_mod/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.icon_state = chassis_icon
		KA.name = chassis_name


/obj/item/borg/upgrade/modkit/chassis_mod/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	KA.icon_state = initial(KA.icon_state)
	KA.name = initial(KA.name)
	..()


/obj/item/borg/upgrade/modkit/chassis_mod/orange
	name = "hyper chassis"
	desc = "Makes your KA orange. All the fun of having explosive blasts without actually having explosive blasts."
	chassis_icon = "kineticgun_h"
	chassis_name = "hyper-kinetic accelerator"


/obj/item/borg/upgrade/modkit/tracer
	name = "white tracer bolts"
	desc = "Causes kinetic accelerator bolts to have a white tracer trail and explosion."
	cost = 0
	denied_type = /obj/item/borg/upgrade/modkit/tracer
	/// This color colors the projectiles after installation.
	var/bolt_color = "#FFFFFF"


/obj/item/borg/upgrade/modkit/tracer/modify_projectile(obj/item/projectile/kinetic/K)
	K.icon_state = "ka_tracer"
	K.color = bolt_color


/obj/item/borg/upgrade/modkit/tracer/adjustable
	name = "adjustable tracer bolts"
	desc = "Causes kinetic accelerator bolts to have an adjustable-colored tracer trail and explosion. Use in-hand to change color."


/obj/item/borg/upgrade/modkit/tracer/adjustable/attack_self(mob/user)
	bolt_color = input(user,"","Choose Color",bolt_color) as color|null


#undef COMPATIBILITY_STANDART
#undef COMPATIBILITY_CYBORG
#undef COMPATIBILITY_MINEBOT
#undef COMPATIBILITY_UNIVERSAL
