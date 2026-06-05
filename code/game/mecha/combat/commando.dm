#define COMMANDO_CLOAK_DRAIN_PER_SECOND 100
#define COMMANDO_PHASE_EMP_LOCKOUT 10 SECONDS

#define RASCAL_MODE_QUIETUS 1
#define RASCAL_MODE_BURST 2

/obj/mecha/combat/commando
	desc = "An exosuit developed by Syndicate mad scientists and, apparently, a mime. Combines Phazon and Reticence systems with the field versatility of a locker mech."
	name = "Commando"
	icon = 'icons/obj/mecha/lockermech.dmi'
	icon_state = "contractormech"
	initial_icon = "contractormech"
	step_in = 2
	step_energy_drain = 3
	normal_step_energy_drain = 3
	max_integrity = 300
	deflect_chance = 30
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, BIO = 100, FIRE = 100, ACID = 100)
	rad_insulation = RAD_FULL_INSULATION
	infra_luminosity = 3
	operation_req_access = list(ACCESS_SYNDICATE)
	id_lock_on = FALSE
	maint_access = TRUE
	wreckage = /obj/structure/mecha_wreckage/phazon
	internal_damage_threshold = 25
	force = 20
	max_equip = 4
	phase_state = "contractormech"
	mech_type = MECH_TYPE_COMMANDO
	starting_voice = /obj/item/mecha_modkit/voice/syndicate
	ui_theme = "syndicate"

	var/cloak_active = FALSE
	var/cloak_name
	var/cloak_desc
	var/cloak_icon_state
	var/cloak_last_drain = 0
	var/phase_blocked_until = 0
	var/obj/item/installed_uplink
	var/datum/action/innate/mecha/commando_cloak/cloak_action = new
	var/datum/action/innate/mecha/commando_uplink/uplink_action = new

/obj/mecha/combat/commando/Destroy()
	QDEL_NULL(installed_uplink)
	return ..()

/obj/mecha/combat/commando/GrantActions(mob/living/user, human_occupant = 0)
	..()
	phasing_action.Grant(user, src)
	thrusters_action.Grant(user, src)
	cloak_action.Grant(user, src)
	if(installed_uplink)
		uplink_action.Grant(user, src)

/obj/mecha/combat/commando/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	phasing_action.Remove(user)
	thrusters_action.Remove(user)
	cloak_action.Remove(user)
	uplink_action.Remove(user)

/obj/mecha/combat/commando/Initialize(mapload)
	. = ..()
	cloak_name = name
	cloak_desc = desc
	cloak_icon_state = initial_icon

/obj/mecha/combat/commando/process()
	..()
	process_cloak_power()

/obj/mecha/combat/commando/proc/process_cloak_power()
	if(!cloak_active)
		return
	if(!cloak_last_drain)
		cloak_last_drain = world.time
		return
	var/elapsed = world.time - cloak_last_drain
	if(elapsed < 1 SECONDS)
		return
	var/power_to_drain = round(COMMANDO_CLOAK_DRAIN_PER_SECOND * elapsed / (1 SECONDS))
	cloak_last_drain = world.time
	if(!has_charge(power_to_drain))
		disable_cloak(span_warning("Cloaking field collapses as the power feed runs dry."))
		return
	use_power(power_to_drain)

/obj/mecha/combat/commando/proc/toggle_cloak(mob/living/user)
	if(cloak_active)
		disable_cloak(span_notice("Experimental cloaking disabled."))
		return
	var/list/cloak_options = build_cloak_options()
	var/choice = tgui_input_list(user, "Choose exosuit signature.", "Experimental Cloaking", cloak_options)
	if(!choice || !cloak_options[choice] || occupant != user)
		return
	var/list/cloak_data = cloak_options[choice]
	cloak_name = name
	cloak_desc = desc
	cloak_icon_state = initial_icon
	name = cloak_data["name"]
	desc = cloak_data["desc"]
	initial_icon = cloak_data["icon_state"]
	cloak_active = TRUE
	cloak_last_drain = world.time
	update_icon(UPDATE_ICON_STATE)
	occupant_message(span_notice("Experimental cloaking enabled."))

/obj/mecha/combat/commando/proc/build_cloak_options()
	var/list/cloak_options = list()
	for(var/obj/mecha/mech_type as anything in subtypesof(/obj/mecha))
		if(mech_type == type || ispath(mech_type, /obj/mecha/combat/commando))
			continue
		var/icon_state_to_use = initial(mech_type.initial_icon) || initial(mech_type.icon_state)
		if(!icon_state_to_use)
			continue
		var/name_to_use = initial(mech_type.name)
		cloak_options["[name_to_use]"] = list(
			"name" = name_to_use,
			"desc" = initial(mech_type.desc),
			"icon_state" = icon_state_to_use,
		)
	for(var/obj/item/paintkit/paintkit_type as anything in subtypesof(/obj/item/paintkit))
		var/name_to_use = initial(paintkit_type.new_name)
		var/icon_state_to_use = initial(paintkit_type.new_icon)
		if(!name_to_use || !icon_state_to_use)
			continue
		cloak_options["[name_to_use]"] = list(
			"name" = name_to_use,
			"desc" = initial(paintkit_type.new_desc),
			"icon_state" = icon_state_to_use,
		)
	return cloak_options

/obj/mecha/combat/commando/proc/disable_cloak(message)
	if(!cloak_active)
		return
	cloak_active = FALSE
	name = cloak_name
	desc = cloak_desc
	initial_icon = cloak_icon_state
	cloak_last_drain = 0
	update_icon(UPDATE_ICON_STATE)
	if(message)
		occupant_message(message)

/obj/mecha/combat/commando/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. > 0)
		disable_cloak(span_warning("Incoming damage disrupts the cloaking field!"))

/obj/mecha/combat/commando/emp_act(severity)
	disable_cloak(span_warning("EMP interference shreds the cloaking field!"))
	phase_blocked_until = world.time + COMMANDO_PHASE_EMP_LOCKOUT
	if(phasing)
		phasing = FALSE
		if(phasing_action.owner)
			phasing_action.button_icon_state = "mech_phasing_off"
			phasing_action.UpdateButtonIcon()
	..()

/obj/mecha/combat/commando/can_phase()
	if(world.time >= phase_blocked_until)
		return TRUE
	occupant_message(span_warning("EMP interference is still suppressing the phase core."))
	return FALSE

/obj/mecha/combat/commando/prevents_weapon_fire(obj/item/mecha_parts/mecha_equipment/weapon/weapon)
	if(!cloak_active)
		return FALSE
	occupant_message(span_warning("The cloaking field blocks weapon discharge."))
	return TRUE

/obj/mecha/combat/commando/attackby(obj/item/I, mob/user, params)
	if(is_commando_uplink(I))
		add_fingerprint(user)
		if(installed_uplink)
			to_chat(user, span_warning("There is already an uplink installed in [src]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		installed_uplink = I
		if(occupant)
			uplink_action.Grant(occupant, src)
		to_chat(user, span_notice("You install [I] into [src]'s encrypted uplink slot."))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/mecha/combat/commando/proc/is_commando_uplink(obj/item/I)
	return istype(I, /obj/item/uplink) || istype(I, /obj/item/radio/uplink) || istype(I, /obj/item/contractor_uplink)

/obj/mecha/combat/commando/proc/open_installed_uplink(mob/user)
	if(!installed_uplink)
		occupant_message(span_warning("No uplink installed."))
		return
	installed_uplink.attack_self(user)

/obj/mecha/combat/commando/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/rascal
	ME.attach(src, MECH_HAND_LEFT)
	ME = new /obj/item/mecha_parts/mecha_equipment/cage/abductor
	ME.attach(src, MECH_HAND_RIGHT)
	ME = new /obj/item/mecha_parts/mecha_equipment/mimercd(src)
	ME.attach(src, MECH_HAND_LEFT)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy(src)
	ME.attach(src, MECH_HAND_RIGHT)

/datum/action/innate/mecha/commando_cloak
	name = "Experimental cloak"
	button_icon_state = "mech_zoom_off"

/datum/action/innate/mecha/commando_cloak/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/obj/mecha/combat/commando/commando = chassis
	if(!istype(commando))
		return
	commando.toggle_cloak(owner)

/datum/action/innate/mecha/commando_uplink
	name = "Installed uplink"
	button_icon_state = "syndicate"

/datum/action/innate/mecha/commando_uplink/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/obj/mecha/combat/commando/commando = chassis
	if(!istype(commando))
		return
	commando.open_installed_uplink(owner)

/obj/projectile/bullet/commando_burst
	name = "suppression round"
	icon_state = "cbbolt"
	damage = 0
	stun = 0.5 SECONDS
	weaken = 0.5 SECONDS
	stamina = 0
	slur = 0
	stutter = 0
	knockdown = 3 SECONDS

/obj/projectile/bullet/commando_burst/on_hit(atom/target, blocked = 0)
	..(target, blocked)
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.Silence(10 SECONDS)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/rascal
	name = "S.H.H. \"Rascal\" carbine"
	desc = "An upgraded Quietus-pattern carbine with a suppressive burst mode."
	fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
	icon_state = "mecha_mime"
	equip_cooldown = 1.5 SECONDS
	projectile = /obj/projectile/bullet/mime
	projectiles = 30
	projectile_energy_cost = 50
	harmful = FALSE
	var/fire_mode = RASCAL_MODE_QUIETUS

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/rascal/can_attach(obj/mecha/combat/M)
	if(..())
		if(istype(M, /obj/mecha/combat/commando))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/rascal/get_shot_amount()
	if(fire_mode == RASCAL_MODE_BURST)
		return 3
	return 1

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/rascal/action(target, list/modifiers)
	if(fire_mode == RASCAL_MODE_BURST)
		projectile = /obj/projectile/bullet/commando_burst
		equip_cooldown = 0.8 SECONDS
		projectile_delay = 2
		variance = 6
	else
		projectile = /obj/projectile/bullet/mime
		equip_cooldown = 1.5 SECONDS
		projectile_delay = 0
		variance = 0
	return ..()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/rascal/get_snowflake_data()
	var/list/data = ..()
	data["snowflake_id"] = MECHA_SNOWFLAKE_ID_MODE
	data["mode"] = fire_mode == RASCAL_MODE_QUIETUS ? "Quietus" : "Burst"
	data["mode_label"] = "Rascal"
	return data

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/rascal/handle_ui_act(action, list/params)
	if(action == "change_mode")
		fire_mode = fire_mode == RASCAL_MODE_QUIETUS ? RASCAL_MODE_BURST : RASCAL_MODE_QUIETUS
		return TRUE
	return ..()

/obj/item/mecha_parts/mecha_equipment/cage/abductor
	name = "CSC 4 \"Abductor\" capture module"
	desc = "An upgraded contractor capture module that suppresses prisoners and can load valid targets into extraction pods."
	equip_cooldown = 2 SECONDS
	energy_drain = 500

/obj/item/mecha_parts/mecha_equipment/cage/abductor/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/combat/commando))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/cage/abductor/action(mob/living/carbon/target, list/modifiers)
	if(!action_checks(target))
		return FALSE
	if(!istype(target))
		return FALSE
	var/obj/structure/closet/supplypod/extractionpod/pod = locate() in get_turf(target)
	if(pod && insert_into_extraction_pod(target, pod))
		return TRUE
	return ..()

/obj/item/mecha_parts/mecha_equipment/cage/abductor/proc/insert_into_extraction_pod(mob/living/carbon/target, obj/structure/closet/supplypod/extractionpod/pod)
	if(prisoner != target && holding != target)
		return FALSE
	if(!pod.opened)
		return FALSE
	occupant_message(span_notice("You begin loading [target] into [pod]..."))
	chassis.visible_message(span_warning("[DECLENT_RU_CAP(chassis, NOMINATIVE)] begins loading [target] into [pod]."))
	if(!do_after_cooldown(pod))
		return FALSE
	if(prisoner == target)
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
		REMOVE_TRAIT(target, TRAIT_COMMANDO_ABDUCTOR_SPEECH, src)
		prisoner = null
		change_state("mecha_cage")
	if(holding == target)
		stop_supressing(target)
	target.forceMove(pod)
	occupant_message(span_notice("[target] has been loaded into [pod]."))
	return TRUE

/obj/item/mecha_parts/mecha_equipment/cage/abductor/insert_action(mob/living/carbon/target)
	. = ..()
	if(prisoner == target)
		ADD_TRAIT(target, TRAIT_COMMANDO_ABDUCTOR_SPEECH, src)

/obj/item/mecha_parts/mecha_equipment/cage/abductor/eject(force)
	var/mob/living/carbon/old_prisoner = prisoner
	. = ..()
	if(old_prisoner && old_prisoner != prisoner)
		REMOVE_TRAIT(old_prisoner, TRAIT_COMMANDO_ABDUCTOR_SPEECH, src)

/obj/item/mecha_parts/mecha_equipment/cage/abductor/on_escape(mob/living/carbon/target)
	REMOVE_TRAIT(target, TRAIT_COMMANDO_ABDUCTOR_SPEECH, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/cage/abductor/Destroy()
	if(prisoner)
		REMOVE_TRAIT(prisoner, TRAIT_COMMANDO_ABDUCTOR_SPEECH, src)
	return ..()

#undef COMMANDO_CLOAK_DRAIN_PER_SECOND
#undef COMMANDO_PHASE_EMP_LOCKOUT

#undef RASCAL_MODE_QUIETUS
#undef RASCAL_MODE_BURST
