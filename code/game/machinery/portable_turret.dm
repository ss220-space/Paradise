/*		Portable Turrets:
		Constructed from metal, a gun of choice, and a prox sensor.
		This code is slightly more documented than normal, as requested by XSI on IRC.
*/
#define TURRET_BUILD_LOOSEN 0
#define TURRET_BUILD_ANCHORED 1
#define TURRET_BUILD_ARMORED 2
#define TURRET_BUILD_ARMOR_SECURED 3
#define TURRET_BUILD_GUN 4
#define TURRET_BUILD_PROX 5
#define TURRET_BUILD_HATCH_CLOSED 6
#define TURRET_BUILD_COATED 7

/obj/machinery/porta_turret
	name = "turret"
	icon = 'icons/obj/machines/turrets.dmi'
	icon_state = "turretCover"
	anchored = TRUE
	density = FALSE
	use_power = IDLE_POWER_USE				//this turret uses and requires power
	idle_power_usage = 50		//when inactive, this turret takes up constant 50 Equipment power
	active_power_usage = 300	//when active, this turret takes up constant 300 Equipment power
	power_channel = EQUIP	//drains power from the EQUIPMENT channel
	can_astar_pass = CANASTARPASS_ALWAYS_PROC
	armor = list(melee = 50, bullet = 30, laser = 30, energy = 30, bomb = 30, bio = 0, rad = 0, fire = 90, acid = 90)

	req_access = list(ACCESS_SECURITY, ACCESS_HEADS)

	var/raised = FALSE			//if the turret cover is "open" and the turret is raised
	var/raising= FALSE			//if the turret is currently opening or closing its cover
	var/health = 80			//the turret's health
	var/locked = TRUE			//if the turret's behaviour control access is locked
	var/controllock = FALSE		//if the turret responds to control panels. TRUE = does NOT respond

	var/installation = /obj/item/gun/energy/gun/turret		//the type of weapon installed
	var/gun_charge = 0		//the charge of the gun inserted
	var/projectile = null	//holder for bullettype
	var/eprojectile = null	//holder for the shot when emagged
	var/reqpower = 500		//holder for power needed
	var/iconholder = null	//holder for the icon_state. 1 for orange sprite, null for blue.
	var/egun = null			//holder to handle certain guns switching bullettypes

	var/last_fired = 0		//1: if the turret is cooling down from a shot, 0: turret is ready to fire
	var/shot_delay = 15		//1.5 seconds between each shot

	var/targetting_is_configurable = TRUE // if false, you cannot change who this turret attacks via its UI
	var/check_arrest = TRUE	//checks if the perp is set to arrest
	var/check_records = TRUE	//checks if a security record exists at all
	var/check_weapons = FALSE	//checks if it can shoot people that have a weapon they aren't authorized to have
	var/check_access = TRUE	//if this is active, the turret shoots everything that does not meet the access requirements
	var/check_anomalies = TRUE	//checks if it can shoot at unidentified lifeforms (ie xenos)
	var/check_synth	 = FALSE 	//if active, will shoot at anything not an AI or cyborg
	var/check_borgs = FALSE //if TRUE, target all cyborgs.
	var/ailock = FALSE 			// if TRUE, AI cannot use this

	var/attacked = FALSE		//if set to 1, the turret gets pissed off and shoots at people nearby (unless they have sec access!)

	var/enabled = TRUE				//determines if the turret is on
	var/lethal = FALSE			//whether in lethal or stun mode
	var/lethal_is_configurable = TRUE // if false, its lethal setting cannot be changed
	var/disabled = FALSE

	var/shot_sound 			//what sound should play when the turret fires
	var/eshot_sound			//what sound should play when the emagged turret fires

	var/datum/effect_system/spark_spread/spark_system	//the spark system, used for generating... sparks?

	var/wrenching = FALSE
	var/last_target //last target fired at, prevents turrets from erratically firing at all valid targets in range

	var/region_min = REGION_GENERAL
	var/region_max = REGION_COMMAND

	var/syndicate = FALSE		//is the turret a syndicate turret?
	var/faction = ""
	var/emp_vulnerable = TRUE // Can be empd
	var/scan_range = 7
	var/always_up = FALSE		//Will stay active
	var/has_cover = TRUE		//Hides the cover

	var/list/turret_marks

	///Targets that are currently processed by turret. Used by process()
	var/list/processing_targets = list()

/obj/machinery/porta_turret/Initialize(mapload)
	. = ..()

	//Sets up a spark system
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	AddComponent(/datum/component/proximity_monitor, scan_range, TRUE)
	setup()

/obj/machinery/porta_turret/HasProximity(atom/movable/AM)
	handleInterloper(AM)

/obj/machinery/porta_turret/proc/handleInterloper(atom/movable/entity)
	//message_admins("[entity] is in target range of [src]")

	if(entity.invisibility > SEE_INVISIBLE_LIVING || entity.alpha == NINJA_ALPHA_INVISIBILITY) //Let's not do typechecks and stuff on invisible things
		return

	var/static/valid_targets = typecacheof(list(/obj/mecha, /obj/spacepod, /obj/vehicle, /mob/living))
	if(!is_type_in_typecache(entity, valid_targets))
		return

	processing_targets[entity] = TRUE //associative for perfomance

/obj/machinery/porta_turret/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/machinery/porta_turret/proc/setup()
	var/obj/item/gun/energy/E = new installation	//All energy-based weapons are applicable
	var/obj/item/ammo_casing/shottype = E.ammo_type[1]

	projectile = shottype.projectile_type
	eprojectile = projectile
	shot_sound = shottype.fire_sound
	eshot_sound = shot_sound

	weapon_setup(installation)

/obj/machinery/porta_turret/proc/weapon_setup(var/guntype)
	switch(guntype)
		if(/obj/item/gun/energy/laser/practice)
			iconholder = 1
			eprojectile = /obj/item/projectile/beam

		if(/obj/item/gun/energy/laser/retro)
			iconholder = 1

		if(/obj/item/gun/energy/laser/captain)
			iconholder = 1

		if(/obj/item/gun/energy/lasercannon)
			iconholder = 1

		if(/obj/item/gun/energy/taser)
			eprojectile = /obj/item/projectile/beam
			eshot_sound = 'sound/weapons/laser.ogg'

		if(/obj/item/gun/energy/gun)
			eprojectile = /obj/item/projectile/beam	//If it has, going to kill mode
			eshot_sound = 'sound/weapons/laser.ogg'
			egun = 1

		if(/obj/item/gun/energy/gun/nuclear)
			eprojectile = /obj/item/projectile/beam	//If it has, going to kill mode
			eshot_sound = 'sound/weapons/laser.ogg'
			egun = 1

		if(/obj/item/gun/energy/gun/turret)
			eprojectile = /obj/item/projectile/beam	//If it has, going to copypaste mode
			eshot_sound = 'sound/weapons/laser.ogg'
			egun = 1

		if(/obj/item/gun/energy/pulse/turret)
			eprojectile = /obj/item/projectile/beam/pulse
			eshot_sound = 'sound/weapons/pulse.ogg'


/obj/machinery/porta_turret/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	return (stat & BROKEN) || !pass_info.is_living


GLOBAL_LIST_EMPTY(turret_icons)

/obj/machinery/porta_turret/update_icon_state()
	if(!GLOB.turret_icons)
		GLOB.turret_icons = list()
		GLOB.turret_icons["open"] = image(icon, "openTurretCover")

	underlays.Cut()
	underlays += GLOB.turret_icons["open"]

	if(stat & BROKEN)
		icon_state = "destroyed_target_prism"
	else if(raised || raising)
		if(powered() && enabled)
			if(iconholder)
				//lasers have a orange icon
				icon_state = "orange_target_prism"
			else
				//almost everything has a blue icon
				icon_state = "target_prism"
		else
			icon_state = "grey_target_prism"
	else
		icon_state = "turretCover"

/obj/machinery/porta_turret/proc/HasController()
	var/area/A = get_area(src)
	return A && A.turret_controls.len > 0

/obj/machinery/porta_turret/proc/access_is_configurable()
	return targetting_is_configurable && !HasController()

/obj/machinery/porta_turret/proc/isLocked(mob/user)
	if(HasController())
		return TRUE
	if(isrobot(user) && !iscogscarab(user) || isAI(user))
		if(ailock)
			to_chat(user, span_notice("There seems to be a firewall preventing you from accessing this device."))
			return TRUE
		else
			return FALSE
	if(isobserver(user))
		if(user.can_admin_interact())
			return FALSE
		else
			return TRUE
	if(locked)
		return TRUE
	return FALSE

/obj/machinery/porta_turret/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/porta_turret/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/porta_turret/attack_hand(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/porta_turret/ui_interact(mob/user, datum/tgui/ui = null)
	if(HasController())
		to_chat(user, span_notice("[src] can only be controlled using the assigned turret controller."))
		return
	if(!anchored)
		to_chat(user, span_notice("[src] has to be secured first!"))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableTurret", name)
		ui.open()

/obj/machinery/porta_turret/ui_data(mob/user)
	var/list/data = list(
		"locked" = isLocked(user), // does the current user have access?
		"on" = enabled,
		"targetting_is_configurable" = targetting_is_configurable, // If false, targetting settings don't show up
		"lethal" = lethal,
		"lethal_is_configurable" = lethal_is_configurable,
		"check_weapons" = check_weapons,
		"neutralize_noaccess" = check_access,
		"one_access" = check_one_access,
		"selectedAccess" = req_access,
		"access_is_configurable" = access_is_configurable(),
		"neutralize_norecord" = check_records,
		"neutralize_criminals" = check_arrest,
		"neutralize_all" = check_synth,
		"neutralize_unidentified" = check_anomalies,
		"neutralize_cyborgs" = check_borgs
	)
	return data

/obj/machinery/porta_turret/ui_static_data(mob/user)
	var/list/data = list()
	data["regions"] = get_accesslist_static_data(region_min, region_max)
	return data

/obj/machinery/porta_turret/ui_act(action, params)
	if (..())
		return
	if(isLocked(usr))
		return
	. = TRUE
	switch(action)
		if("power")
			enabled = !enabled
		if("lethal")
			if(lethal_is_configurable)
				lethal = !lethal
	if(targetting_is_configurable)
		switch(action)
			if("authweapon")
				check_weapons = !check_weapons
			if("authaccess")
				check_access = !check_access
			if("authnorecord")
				check_records = !check_records
			if("autharrest")
				check_arrest = !check_arrest
			if("authxeno")
				check_anomalies = !check_anomalies
			if("authsynth")
				check_synth = !check_synth
			if("authborgs")
				check_borgs = !check_borgs
			if("set")
				var/access = text2num(params["access"])
				if(!(access in req_access))
					LAZYADD(req_access, access)
				else
					LAZYREMOVE(req_access, access)
	if(access_is_configurable())
		switch(action)
			if("grant_region")
				var/region = text2num(params["region"])
				if(isnull(region))
					return
				LAZYOR(req_access, get_region_accesses(region))
			if("deny_region")
				var/region = text2num(params["region"])
				if(isnull(region))
					return
				LAZYREMOVE(req_access, get_region_accesses(region))
			if("clear_all")
				req_access = list()
			if("grant_all")
				req_access = get_all_accesses()
			if("one_access")
				req_access = list()
				check_one_access = !check_one_access


/obj/machinery/porta_turret/power_change(forced = FALSE)
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/porta_turret/crowbar_act(mob/living/user, obj/item/I)
	//If the turret is destroyed, you can remove it with a crowbar to
	//try and salvage its components
	if(!(stat & BROKEN) || syndicate)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || !(stat & BROKEN))
		return .
	if(prob(70))
		to_chat(user, span_notice("You remove the turret and salvage some components."))
		if(installation)
			var/obj/item/gun/energy/Gun = new installation(loc)
			Gun.cell.charge = gun_charge
			Gun.update_icon()
		if(prob(50))
			new /obj/item/stack/sheet/metal(loc, rand(1,4))
		if(prob(50))
			new /obj/item/assembly/prox_sensor(loc)
	else
		to_chat(user, span_notice("You remove the turret but did not manage to salvage anything."))
	qdel(src)


/obj/machinery/porta_turret/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(enabled || raised)
		to_chat(user, span_warning("You cannot unsecure an active turret!"))
		return .
	if(wrenching)
		to_chat(user, span_warning("Someone is already [anchored ? "un" : ""]securing the turret!"))
		return .
	if(!anchored && isinspace())
		to_chat(user, span_warning("Cannot secure turrets in space!"))
		return .
	user.visible_message(
		span_warning("[user] begins [anchored ? "un" : ""]securing the turret."),
		span_notice("You begin [anchored ? "un" : ""]securing the turret."),
	)
	wrenching = TRUE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || enabled || raised || (!anchored && isinspace()))
		wrenching = FALSE
		return .
	wrenching = FALSE
	//This code handles moving the turret around. After all, it's a portable turret!
	set_anchored(!anchored)
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("You [anchored ? "" : "un"]secure the exterior bolts on the turret."))


/obj/machinery/porta_turret/attackby(obj/item/I, mob/user, params)
	if(I.GetID() || is_pda(I))
		add_fingerprint(user)
		if(HasController())
			to_chat(user, span_notice("Turrets regulated by a nearby turret controller are not unlockable."))
			return ATTACK_CHAIN_PROCEED
		if(!allowed(user))
			to_chat(user, span_notice("Access denied."))
			return ATTACK_CHAIN_PROCEED
		locked = !locked
		to_chat(user, span_notice("Controls are now [locked ? "locked" : "unlocked"]."))
		updateUsrDialog()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	var/pissed_check = (I.force * 0.5 > 1)
	. = ..()
	//if the turret was attacked with the intention of harming it
	//and the force of impact dealt at least 1 damage, the turret gets pissed off
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !pissed_check || attacked || emagged)
		return .
	attacked = TRUE
	addtimer(VARSET_CALLBACK(src, attacked, FALSE), 6 SECONDS)


/obj/machinery/porta_turret/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(M.melee_damage_upper == 0 || (M.melee_damage_type != BRUTE && M.melee_damage_type != BURN))
		return
	if(!(stat & BROKEN))
		visible_message(span_danger("[M] [M.attacktext] [src]!"))
		take_damage(M.melee_damage_upper)
	else
		to_chat(M, span_danger("That object is useless to you."))
	return

/obj/machinery/porta_turret/attack_alien(mob/living/carbon/alien/humanoid/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(!(stat & BROKEN))
		playsound(src.loc, 'sound/weapons/slash.ogg', 25, 1, -1)
		visible_message(span_danger("[M] has slashed at [src]!"))
		take_damage(M.attack_damage)
	else
		to_chat(M, span_noticealien("That object is useless to you."))
	return

/obj/machinery/porta_turret/emag_act(mob/user)
	if(!emagged)
		//Emagging the turret makes it go bonkers and stun everyone. It also makes
		//the turret shoot much, much faster.
		if(user)
			to_chat(user, span_warning("You short out [src]'s threat assessment circuits."))
			visible_message("[src] hums oddly...")
		emagged = TRUE
		iconholder = 1
		controllock = TRUE
		enabled = FALSE //turns off the turret temporarily
		sleep(60) //6 seconds for the traitor to gtfo of the area before the turret decides to ruin his shit
		enabled = TRUE //turns it back on. The cover popUp() popDown() are automatically called in process(), no need to define it here

/obj/machinery/porta_turret/take_damage(force)
	if(!raised && !raising)
		force = force / 8
		if(force < 5)
			return

	health -= force
	if(force > 5 && prob(45) && spark_system)
		spark_system.start()
	if(health <= 0)
		die()	//the death process :(

/obj/machinery/porta_turret/bullet_act(obj/item/projectile/Proj)
	if(Proj.damage_type == STAMINA)
		return

	if(enabled)
		if(!attacked && !emagged)
			attacked = TRUE
			spawn(60)
				attacked = FALSE

	..()

	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		take_damage(Proj.damage)

/obj/machinery/porta_turret/emp_act(severity)
	if(enabled && emp_vulnerable)
		//if the turret is on, the EMP no matter how severe disables the turret for a while
		//and scrambles its settings, with a slight chance of having an emag effect
		check_arrest = prob(50)
		check_records = prob(50)
		check_weapons = prob(50)
		check_access = prob(20)	// check_access is a pretty big deal, so it's least likely to get turned on
		check_anomalies = prob(50)
		if(prob(5))
			emagged = TRUE

		enabled=0
		spawn(rand(60, 600))
			if(!enabled)
				enabled = TRUE

	..()

/obj/machinery/porta_turret/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(25))
				qdel(src)
			else
				take_damage(initial(health) * 8) //should instakill most turrets
		if(3)
			take_damage(initial(health) * 8 / 3)

/obj/machinery/porta_turret/proc/die()	//called when the turret dies, ie, health <= 0
	health = 0
	stat |= BROKEN	//enables the BROKEN bit
	if(spark_system)
		spark_system.start()	//creates some sparks because they look cool
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/porta_turret/process()
	//the main machinery process

	if(stat & (NOPOWER|BROKEN))
		if(!always_up)
			//if the turret has no power or is broken, make the turret pop down if it hasn't already
			popDown()
		return

	if(!enabled)
		if(!always_up)
			//if the turret is off, make it pop down
			popDown()
		return

	if(!length(processing_targets))
		return

	//Verify that targeted atoms are in our sight. Otherwise, just remove them from processing.
	for(var/atom/movable/atom as anything in processing_targets)
		if(!can_see(src, atom, scan_range))
			processing_targets -= atom

	var/list/primary_candidates
	var/list/secondary_candidates

	for(var/atom/movable/atom as anything in processing_targets)
		var/assess_type = TURRET_NOT_TARGET
		assess_type = set_assess_type(atom)
		if(assess_type == TURRET_PRIORITY_TARGET)
			LAZYADD(primary_candidates, atom)
			continue

		if(assess_type == TURRET_SECONDARY_TARGET)
			LAZYADD(secondary_candidates, atom)

	if(!primary_candidates && !secondary_candidates)
		if(!always_up)
			popDown()
		return

	if(!tryToShootAt(primary_candidates))
		if(!tryToShootAt(secondary_candidates))
			if(!always_up)
				popDown()

/obj/machinery/porta_turret/proc/set_assess_type(atom/movable/target)
	if(ismecha(target))
		var/obj/mecha/ME = target
		return assess_and_assign(ME.occupant)

	if(isspacepod(target))
		var/obj/spacepod/SP = target
		return assess_and_assign(SP.pilot)

	if(istype(target, /obj/vehicle))
		var/obj/vehicle/T = target
		if(T.has_buckled_mobs())
			for(var/m in T.buckled_mobs)
				var/mob/living/buckled_mob = m
				return assess_and_assign(buckled_mob)

	if(isliving(target))
		var/mob/living/C = target
		return assess_and_assign(C)

/obj/machinery/porta_turret/proc/in_faction(mob/living/target)
	if(!(faction in target.faction))
		return FALSE
	return TRUE

/obj/machinery/porta_turret/proc/assess_and_assign(mob/living/L)
	return assess_living(L)

/obj/machinery/porta_turret/proc/assess_living(mob/living/L)
	if(!L)
		return TURRET_NOT_TARGET

	if(get_turf(L) == get_turf(src))
		return TURRET_NOT_TARGET

	if(!emagged && !syndicate && (issilicon(L) || isbot(L)))
		return (check_borgs && isrobot(L)) ? TURRET_PRIORITY_TARGET : TURRET_NOT_TARGET

	if(L.stat && !emagged)		//if the perp is dead/dying, no need to bother really
		return TURRET_NOT_TARGET	//move onto next potential victim!

	if(get_dist(src, L) > scan_range)	//if it's too far away, why bother?
		return TURRET_NOT_TARGET

	if(emagged)		// If emagged not even the dead get a rest
		return L.stat ? TURRET_SECONDARY_TARGET : TURRET_PRIORITY_TARGET

	if(in_faction(L))
		return TURRET_NOT_TARGET

	if("syndicate" in L.faction && istype(L.get_id_card(), /obj/item/card/id/syndicate))
		return TURRET_NOT_TARGET

	if(lethal && locate(/mob/living/silicon/ai) in get_turf(L))		//don't accidentally kill the AI!
		return TURRET_NOT_TARGET

	if(check_synth)	//If it's set to attack all non-silicons, target them!
		if(L.body_position == LYING_DOWN)
			return lethal ? TURRET_SECONDARY_TARGET : TURRET_NOT_TARGET
		return TURRET_PRIORITY_TARGET

	if(iscuffed(L)) // If the target is handcuffed, leave it alone
		return TURRET_NOT_TARGET

	if(isanimal(L) || is_monkeybasic(L)) // Animals are not so dangerous
		return check_anomalies ? TURRET_SECONDARY_TARGET : TURRET_NOT_TARGET

	if(isalien(L)) // Xenos are dangerous
		return check_anomalies ? TURRET_PRIORITY_TARGET	: TURRET_NOT_TARGET

	if(ishuman(L))	//if the target is a human, analyze threat level
		if(assess_perp(L, check_access, check_weapons, check_records, check_arrest) < 4)
			return TURRET_NOT_TARGET	//if threat level < 4, keep going

	if(L.body_position == LYING_DOWN)		//if the perp is lying down, it's still a target but a less-important target
		return lethal ? TURRET_SECONDARY_TARGET : TURRET_NOT_TARGET

	return TURRET_PRIORITY_TARGET	//if the perp has passed all previous tests, congrats, it is now a "shoot-me!" nominee

/obj/machinery/porta_turret/proc/tryToShootAt(list/mob/living/targets)
	if(!targets)
		return FALSE

	if(targets.len && last_target && (last_target in targets) && target(last_target))
		return TRUE

	while(targets.len)
		var/mob/living/M = pick(targets)
		targets -= M
		if(target(M))
			return TRUE


/obj/machinery/porta_turret/proc/popUp()	//pops the turret up
	if(disabled)
		return
	if(raising || raised)
		return
	if(stat & BROKEN)
		return
	set_raised_raising(raised, TRUE)
	playsound(get_turf(src), 'sound/effects/turret/open.wav', 60, 1)
	update_icon(UPDATE_ICON_STATE)

	var/atom/flick_holder = new /atom/movable/porta_turret_cover(loc)
	flick_holder.layer = layer + 0.1
	flick("popup", flick_holder)
	sleep(10)
	qdel(flick_holder)

	set_raised_raising(TRUE, FALSE)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/porta_turret/proc/popDown()	//pops the turret down
	last_target = null
	if(disabled)
		return
	if(raising || !raised)
		return
	if(stat & BROKEN)
		return
	set_raised_raising(raised, TRUE)
	playsound(get_turf(src), 'sound/effects/turret/open.wav', 60, 1)
	update_icon(UPDATE_ICON_STATE)

	var/atom/flick_holder = new /atom/movable/porta_turret_cover(loc)
	flick_holder.layer = layer + 0.1
	flick("popdown", flick_holder)
	sleep(10)
	qdel(flick_holder)

	set_raised_raising(FALSE, FALSE)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/porta_turret/on_assess_perp(mob/living/carbon/human/perp)
	if((check_access || attacked) && !allowed(perp))
		//if the turret has been attacked or is angry, target all non-authorized personnel, see req_access
		return 10

	return ..()

/obj/machinery/porta_turret/proc/set_raised_raising(var/is_raised, var/is_raising)
	raised = is_raised
	raising = is_raising
	density = is_raised || is_raising

/obj/machinery/porta_turret/proc/target(mob/living/target)
	if(disabled)
		return
	for(var/obj/machinery/door/poddoor/D in get_turf(src))
		if(D.icon_state == "closed")
			return
	if(target)
		last_target = target
		if(has_cover)
			popUp()				//pop the turret up if it's not already up.
		setDir(get_dir(src, target))	//even if you can't shoot, follow the target
		shootAt(target)
		return TRUE

/obj/machinery/porta_turret/proc/shootAt(mob/living/target)
	if(!raised && has_cover) //the turret has to be raised in order to fire - makes sense, right?
		return

	if(!emagged)	//if it hasn't been emagged, cooldown before shooting again
		if((last_fired + shot_delay > world.time) || !raised)
			return
		last_fired = world.time

	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!istype(T) || !istype(U))
		return

	update_icon(UPDATE_ICON_STATE)
	var/obj/item/projectile/A
	if(emagged || lethal)
		if(eprojectile)
			A = new eprojectile(loc)
			playsound(loc, eshot_sound, 75, 1)
	else
		if(projectile)
			A = new projectile(loc)
			playsound(loc, shot_sound, 75, 1)

	// Lethal/emagged turrets use twice the power due to higher energy beams
	// Emagged turrets again use twice as much power due to higher firing rates
	use_power(reqpower * (2 * (emagged || lethal)) * (2 * emagged))

	if(istype(A))
		A.original = target
		A.current = T
		A.yo = U.y - T.y
		A.xo = U.x - T.x
		A.fire()
	else
		A.throw_at(target, scan_range, 1)
	return A

/obj/machinery/porta_turret/centcom
	name = "Centcom Turret"
	enabled = FALSE
	ailock = TRUE
	check_synth	 = FALSE
	check_access = TRUE
	check_arrest = TRUE
	check_records = TRUE
	check_weapons = TRUE
	check_anomalies = TRUE
	region_max = REGION_CENTCOMM // Non-turretcontrolled turrets at CC can have their access customized to check for CC accesses.
	req_access = list(ACCESS_CENT_SPECOPS)

/obj/machinery/porta_turret/centcom/pulse
	name = "Pulse Turret"
	health = 200
	enabled = TRUE
	lethal = TRUE
	lethal_is_configurable = FALSE
	req_access = list(ACCESS_CENT_COMMANDER)
	installation = /obj/item/gun/energy/pulse/turret

/datum/turret_checks
	var/enabled
	var/lethal
	var/check_synth
	var/check_access
	var/check_records
	var/check_arrest
	var/check_weapons
	var/check_anomalies
	var/check_borgs
	var/ailock

/obj/machinery/porta_turret/proc/setState(var/datum/turret_checks/TC)
	if(controllock)
		return
	enabled = TC.enabled
	lethal = TC.lethal
	iconholder = TC.lethal

	check_synth = TC.check_synth
	check_access = TC.check_access
	check_records = TC.check_records
	check_arrest = TC.check_arrest
	check_weapons = TC.check_weapons
	check_anomalies = TC.check_anomalies
	check_borgs = TC.check_borgs
	ailock = TC.ailock

	power_change()

/*
		Portable turret constructions
		Known as "turret frame"s
*/

/obj/machinery/porta_turret_construct
	name = "turret frame"
	icon = 'icons/obj/machines/turrets.dmi'
	icon_state = "turret_frame"
	density = TRUE
	/// The current step in the building process
	var/build_step = TURRET_BUILD_LOOSEN
	var/target_type = /obj/machinery/porta_turret	// The type we intend to build
	var/finish_name="turret"	//the name applied to the product turret
	var/installation = null		//the gun type installed
	var/gun_charge = 0			//the gun charge of the gun type installed


/obj/machinery/porta_turret_construct/update_icon_state()
	icon_state = "turret_frame[build_step >= TURRET_BUILD_ARMORED ? "2" : ""]"


/obj/machinery/porta_turret_construct/wrench_act(mob/living/user, obj/item/I)
	if(build_step != TURRET_BUILD_LOOSEN && build_step != TURRET_BUILD_ANCHORED && build_step != TURRET_BUILD_ARMORED && build_step != TURRET_BUILD_ARMOR_SECURED)
		return FALSE
	. = TRUE
	switch(build_step)
		if(TURRET_BUILD_LOOSEN)
			if(anchored)
				to_chat(user, span_warning("External bolts are already secured."))
				return .
			if(!I.use_tool(src, user, volume = I.tool_volume))
				return .
			to_chat(user, span_notice("You secure the external bolts."))
			set_anchored(TRUE)
			build_step = TURRET_BUILD_ANCHORED
		if(TURRET_BUILD_ANCHORED)
			if(!anchored)
				to_chat(user, span_warning("External bolts are already unfastened."))
				return .
			if(!I.use_tool(src, user, volume = I.tool_volume))
				return .
			to_chat(user, span_notice("You unfasten the external bolts."))
			set_anchored(FALSE)
			build_step = TURRET_BUILD_LOOSEN
		if(TURRET_BUILD_ARMORED)
			if(!I.use_tool(src, user, volume = I.tool_volume))
				return .
			to_chat(user, span_notice("You bolt the metal armor into place."))
			build_step = TURRET_BUILD_ARMOR_SECURED
		if(TURRET_BUILD_ARMOR_SECURED)
			if(!I.use_tool(src, user, volume = I.tool_volume))
				return .
			to_chat(user, span_notice("You remove the turret's metal armor bolts."))
			build_step = TURRET_BUILD_ARMORED


/obj/machinery/porta_turret_construct/crowbar_act(mob/living/user, obj/item/I)
	if(build_step != TURRET_BUILD_LOOSEN)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || build_step != TURRET_BUILD_LOOSEN)
		return .
	to_chat(user, span_notice("You dismantle the turret construction."))
	new /obj/item/stack/sheet/metal(loc, 5)
	qdel(src)


/obj/machinery/porta_turret_construct/screwdriver_act(mob/living/user, obj/item/I)
	if(build_step != TURRET_BUILD_PROX && build_step != TURRET_BUILD_HATCH_CLOSED)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	switch(build_step)
		if(TURRET_BUILD_PROX)
			to_chat(user, span_notice("You close the internal access hatch."))
			build_step = TURRET_BUILD_HATCH_CLOSED
		if(TURRET_BUILD_HATCH_CLOSED)
			to_chat(user, span_notice("You open the internal access hatch."))
			build_step = TURRET_BUILD_PROX


/obj/machinery/porta_turret_construct/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_pen(I))	//you can rename turrets like bots!
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	switch(build_step)
		if(TURRET_BUILD_ANCHORED)
			if(istype(I, /obj/item/stack/sheet/metal))
				add_fingerprint(user)
				var/obj/item/stack/sheet/metal/metal = I
				if(!metal.use(2))
					to_chat(user, span_warning("You need two sheets of metal to continue construction."))
					return ATTACK_CHAIN_PROCEED
				to_chat(user, span_notice("You add some metal armor to the interior frame."))
				build_step = TURRET_BUILD_ARMORED
				update_icon(UPDATE_ICON_STATE)
				return ATTACK_CHAIN_PROCEED_SUCCESS

		if(TURRET_BUILD_ARMOR_SECURED)
			if(istype(I, /obj/item/gun/energy)) //the gun installation part
				if(isrobot(user))
					return ATTACK_CHAIN_PROCEED
				add_fingerprint(user)
				if(!user.drop_transfer_item_to_loc(I, src))
					return ..()
				var/obj/item/gun/energy/new_gun = I
				installation = new_gun.type	//installation becomes new_gun.type
				gun_charge = new_gun.cell.charge	//the gun's charge is stored in gun_charge
				to_chat(user, span_notice("You add [I] to the turret."))

				if(istype(new_gun, /obj/item/gun/energy/laser/tag/blue))
					target_type = /obj/machinery/porta_turret/tag/blue
				else if(istype(new_gun, /obj/item/gun/energy/laser/tag/red))
					target_type = /obj/machinery/porta_turret/tag/red
				else
					target_type = /obj/machinery/porta_turret

				build_step = TURRET_BUILD_GUN
				qdel(I) //delete the gun :( qdel
				return ATTACK_CHAIN_BLOCKED_ALL

		if(TURRET_BUILD_GUN)
			if(isprox(I))
				add_fingerprint(user)
				if(!user.drop_transfer_item_to_loc(I, src))
					return ..()
				build_step = TURRET_BUILD_PROX
				qdel(I)
				to_chat(user, span_notice("You add the prox sensor to the turret."))
				return ATTACK_CHAIN_BLOCKED_ALL

		if(TURRET_BUILD_HATCH_CLOSED)
			if(istype(I, /obj/item/stack/sheet/metal))
				add_fingerprint(user)
				var/obj/item/stack/sheet/metal/metal = I
				if(!metal.use(2))
					to_chat(user, span_warning("You need two sheets of metal to continue construction."))
					return ATTACK_CHAIN_PROCEED
				build_step = TURRET_BUILD_COATED
				to_chat(user, span_notice("You add some metal armor to the exterior frame."))
				return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/porta_turret_construct/welder_act(mob/user, obj/item/I)
	if(build_step != TURRET_BUILD_ARMORED && build_step != TURRET_BUILD_COATED)
		return FALSE
	. = TRUE
	switch(build_step)
		if(TURRET_BUILD_ARMORED)
			if(!I.tool_use_check(user, 0))
				return .
			to_chat(user, span_notice("You start removing the turret's interior metal armor..."))
			if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || build_step != TURRET_BUILD_ARMORED)
				return .
			to_chat(user, span_notice("You remove the turret's interior metal armor."))
			build_step = TURRET_BUILD_ANCHORED
			update_icon(UPDATE_ICON_STATE)
			new /obj/item/stack/sheet/metal(loc, 2)

		if(TURRET_BUILD_COATED)
			if(!I.tool_use_check(user, 5))
				return .
			to_chat(user, span_notice("You start welding the turret's armor down..."))
			if(!I.use_tool(src, user, 5 SECONDS, amount = 5, volume = I.tool_volume) || build_step != TURRET_BUILD_COATED)
				return .
			to_chat(user, span_notice("You weld the turret's armor down."))
			//The final step: create a full turret
			var/obj/machinery/porta_turret/turret = new target_type(loc)
			turret.name = finish_name
			turret.installation = installation
			turret.gun_charge = gun_charge
			turret.enabled = FALSE
			turret.add_fingerprint(user)
			turret.setup()
			qdel(src)


/obj/machinery/porta_turret_construct/attack_hand(mob/user)
	switch(build_step)
		if(TURRET_BUILD_GUN)
			if(!installation)
				return ..()
			add_fingerprint(user)
			build_step = TURRET_BUILD_ARMOR_SECURED
			var/obj/item/gun/energy/removed_gun = new installation(loc)
			removed_gun.cell.charge = gun_charge
			removed_gun.update_icon()
			to_chat(user, span_notice("You remove [removed_gun] from the turret frame."))
			installation = null
			gun_charge = 0
			user.put_in_hands(removed_gun, ignore_anim = FALSE)

		if(TURRET_BUILD_PROX)
			add_fingerprint(user)
			to_chat(user, span_notice("You remove the prox sensor from the turret frame."))
			var/obj/item/assembly/prox_sensor/sensor = new(loc)
			build_step = TURRET_BUILD_GUN
			user.put_in_hands(sensor, ignore_anim = FALSE)

		else
			return ..()


/obj/machinery/porta_turret_construct/attack_ai()
	return

/atom/movable/porta_turret_cover
	icon = 'icons/obj/machines/turrets.dmi'
	anchored = TRUE

// Syndicate turrets
/obj/machinery/porta_turret/syndicate
	projectile = /obj/item/projectile/bullet
	eprojectile = /obj/item/projectile/bullet
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
	scan_range = 9

	faction = "syndicate"
	emp_vulnerable = FALSE

	lethal = TRUE
	lethal_is_configurable = FALSE
	targetting_is_configurable = FALSE
	check_arrest = FALSE
	check_records = FALSE
	check_weapons = FALSE
	check_access = FALSE
	check_anomalies = TRUE
	check_synth	= TRUE
	ailock = TRUE
	req_access = list(ACCESS_SYNDICATE)
	var/area/syndicate_depot/core/depotarea

/obj/machinery/porta_turret/syndicate/die()
	. = ..()
	if(istype(depotarea))
		depotarea.turret_died()

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
	projectile = /obj/item/projectile/bullet/weakbullet3
	eprojectile = /obj/item/projectile/bullet/weakbullet3

/obj/machinery/porta_turret/syndicate/interior
	name = "machine gun turret (.45)"
	desc = "Syndicate interior defense turret chambered for .45 rounds. Designed to down intruders without damaging the hull."
	projectile = /obj/item/projectile/bullet/midbullet
	eprojectile = /obj/item/projectile/bullet/midbullet

/obj/machinery/porta_turret/syndicate/exterior
	name = "machine gun turret (7.62)"
	desc = "Syndicate exterior defense turret chambered for 7.62 rounds. Designed to down intruders with heavy calliber bullets."
	projectile = /obj/item/projectile/bullet
	eprojectile = /obj/item/projectile/bullet

/obj/machinery/porta_turret/syndicate/grenade
	name = "mounted grenade launcher (40mm)"
	desc = "Syndicate 40mm grenade launcher defense turret. If you've had this much time to look at it, you're probably already dead."
	icon_state = "syndieturret01"
	icon_state_initial = "syndieturret01"
	icon_state_active = "syndieturret01"
	icon_state_destroyed = "syndieturret2"
	projectile = /obj/item/projectile/bullet/a40mm
	eprojectile = /obj/item/projectile/bullet/a40mm

/obj/machinery/porta_turret/syndicate/assault_pod
	name = "machine gun turret (4.6x30mm)"
	desc = "Syndicate exterior defense turret chambered for 4.6x30mm rounds. Designed to be fitted to assault pods, it uses low calliber bullets to save space."
	health = 100
	projectile = /obj/item/projectile/bullet/weakbullet3
	eprojectile = /obj/item/projectile/bullet/weakbullet3


#undef TURRET_BUILD_LOOSEN
#undef TURRET_BUILD_ANCHORED
#undef TURRET_BUILD_ARMORED
#undef TURRET_BUILD_ARMOR_SECURED
#undef TURRET_BUILD_GUN
#undef TURRET_BUILD_PROX
#undef TURRET_BUILD_HATCH_CLOSED
#undef TURRET_BUILD_COATED

