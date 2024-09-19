/*
	Station Airlocks Regular
*/

/obj/machinery/door/airlock/command
	icon = 'icons/obj/doors/airlocks/station/command.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_com
	normal_integrity = 450

/obj/machinery/door/airlock/security
	icon = 'icons/obj/doors/airlocks/station/security.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_sec
	normal_integrity = 450

/obj/machinery/door/airlock/engineering
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_eng

/obj/machinery/door/airlock/medical
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_med

/obj/machinery/door/airlock/maintenance
	name = "maintenance access"
	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_mai
	normal_integrity = 250

/obj/machinery/door/airlock/maintenance/external
	name = "external airlock access"
	icon = 'icons/obj/doors/airlocks/station/maintenanceexternal.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_extmai

/obj/machinery/door/airlock/mining
	name = "mining airlock"
	icon = 'icons/obj/doors/airlocks/station/mining.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_min

/obj/machinery/door/airlock/atmos
	name = "atmospherics airlock"
	icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_atmo

/obj/machinery/door/airlock/research
	icon = 'icons/obj/doors/airlocks/station/research.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_research

/obj/machinery/door/airlock/freezer
	name = "freezer airlock"
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_fre

/obj/machinery/door/airlock/science
	icon = 'icons/obj/doors/airlocks/station/science.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_science

//////////////////////////////////
/*
	Station Airlocks Glass
*/

/obj/machinery/door/airlock/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/command/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/engineering/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/security/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/medical/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/research/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/mining/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/atmos/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/science/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/maintenance/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/maintenance/external/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 200

//////////////////////////////////
/*
	Station Airlocks Mineral
*/

/obj/machinery/door/airlock/gold
	name = "gold airlock"
	icon = 'icons/obj/doors/airlocks/station/gold.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_gold
	paintable = FALSE

/obj/machinery/door/airlock/gold/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/silver
	name = "silver airlock"
	icon = 'icons/obj/doors/airlocks/station/silver.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_silver
	paintable = FALSE

/obj/machinery/door/airlock/silver/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/diamond
	name = "diamond airlock"
	icon = 'icons/obj/doors/airlocks/station/diamond.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_diamond
	normal_integrity = 1000
	explosion_block = 2
	paintable = FALSE

/obj/machinery/door/airlock/diamond/glass
	normal_integrity = 950
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/uranium
	name = "uranium airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/airlocks/station/uranium.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_uranium
	paintable = FALSE
	var/event_step = 20

/obj/machinery/door/airlock/uranium/Initialize()
	. = ..()
	AddComponent(/datum/component/radioactivity, \
				rad_per_cycle = 15, \
				rad_cycle_chance = 50, \
				rad_cycle = 2 SECONDS, \
				rad_cycle_radius = 3 \
	)

/obj/machinery/door/airlock/uranium/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/plasma
	name = "plasma airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/airlocks/station/plasma.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_plasma
	paintable = FALSE

/obj/machinery/door/airlock/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 500)
	var/obj/structure/door_assembly/DA
	DA = new /obj/structure/door_assembly(loc)
	if(glass)
		DA.glass = TRUE
	if(heat_proof)
		DA.heat_proof_finished = TRUE
	DA.update_icon()
	DA.update_name()
	qdel(src)


/obj/machinery/door/airlock/plasma/attackby(obj/item/I, mob/user, params)
	var/heat_temp = is_hot(I)
	if(heat_temp > 300)
		add_fingerprint(user)
		add_attack_logs(user, src, "ignited using [I]", ATKLOG_FEW)
		investigate_log("was <font color='red'><b>ignited</b></font> by [key_name_log(user)]", INVESTIGATE_ATMOS)
		ignite(heat_temp)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/door/airlock/plasma/BlockSuperconductivity() //we don't stop the heat~
	return 0

/obj/machinery/door/airlock/plasma/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/bananium
	name = "bananium airlock"
	desc = "Honkhonkhonk"
	icon = 'icons/obj/doors/airlocks/station/bananium.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_bananium
	doorOpen = 'sound/items/bikehorn.ogg'
	doorClose = 'sound/items/bikehorn.ogg'
	paintable = FALSE

/obj/machinery/door/airlock/bananium/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/tranquillite
	name = "tranquillite airlock"
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
	doorOpen = null // it's silent!
	doorClose = null
	doorDeni = null
	boltUp = null
	boltDown = null
	paintable = FALSE

/obj/machinery/door/airlock/sandstone
	name = "sandstone airlock"
	icon = 'icons/obj/doors/airlocks/station/sandstone.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_sandstone
	paintable = FALSE

/obj/machinery/door/airlock/sandstone/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/wood
	name = "wooden airlock"
	icon = 'icons/obj/doors/airlocks/station/wood.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_wood
	paintable = FALSE

/obj/machinery/door/airlock/wood/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/titanium
	name = "shuttle airlock"
	assemblytype = /obj/structure/door_assembly/door_assembly_titanium
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	normal_integrity = 400
	paintable = FALSE

/obj/machinery/door/airlock/titanium/glass
	normal_integrity = 350
	opacity = FALSE
	glass = TRUE

//////////////////////////////////
/*
	Station2 Airlocks
*/

/obj/machinery/door/airlock/public
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_public

/obj/machinery/door/airlock/public/glass
	opacity = FALSE
	glass = TRUE

//////////////////////////////////
/*
	External Airlocks
*/

/obj/machinery/door/airlock/external
	name = "external airlock"
	icon = 'icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_ext
	doorOpen = 'sound/machines/airlock_ext_open.ogg'
	doorClose = 'sound/machines/airlock_ext_close.ogg'

/obj/machinery/door/airlock/external/glass
	opacity = FALSE
	glass = TRUE

//////////////////////////////////
/*
	CentCom Airlocks
*/

/obj/machinery/door/airlock/centcom
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'
	opacity = FALSE
	explosion_block = 2
	assemblytype = /obj/structure/door_assembly/door_assembly_centcom
	normal_integrity = 1000
	security_level = 6
	hackable = FALSE

/obj/machinery/door/airlock/centcom/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(user.a_intent == INTENT_HARM && ishuman(user) && (user.dna.species.obj_damage + user.physiology.punch_obj_damage > 0))
		return

/////////////////////////////////
/*
	Vault Airlocks
*/

/obj/machinery/door/airlock/vault
	name = "vault door"
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_vault
	explosion_block = 2
	normal_integrity = 400 // reverse engieneerd: 400 * 1.5 (sec lvl 6) = 600 = original
	security_level = 6
	paintable = FALSE

/obj/machinery/door/airlock/vault/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	if(!our_rcd.canRwall)
		return RCD_NO_ACT
	. = ..()


//////////////////////////////////
/*
	Hatch Airlocks
*/

/obj/machinery/door/airlock/hatch
	name = "airtight hatch"
	icon = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_hatch
	paintable = FALSE

/obj/machinery/door/airlock/hatch/syndicate
	name = "syndicate hatch"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/door/airlock/hatch/syndicate/command
	name = "Command Center"
	req_access = list(ACCESS_SYNDICATE_COMMAND)
	explosion_block = 2
	normal_integrity = 1000
	security_level = 6
	hackable = FALSE

/obj/machinery/door/airlock/hatch/syndicate/vault
	name = "syndicate vault hatch"
	req_access = list(ACCESS_SYNDICATE_LEADER)
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_vault
	security_level = 6
	hackProof = TRUE
	aiControlDisabled = AICONTROLDISABLED_ON

/obj/machinery/door/airlock/hatch/gamma
	name = "gamma level hatch"
	id_tag = "gamma_home"
	hackProof = TRUE
	aiControlDisabled = AICONTROLDISABLED_ON
	resistance_flags = FIRE_PROOF | ACID_PROOF
	is_special = TRUE


/obj/machinery/door/airlock/hatch/gamma/attackby(obj/item/I, mob/user, params)
	if(!issilicon(user) && isElectrified() && shock(user, 75))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/detective_scanner))
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/grenade/plastic/c4))
		add_fingerprint(user)
		to_chat(user, span_warning("The hatch is coated with a product that prevents the shaped charge from sticking!"))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/mecha_parts/mecha_equipment/rcd) || istype(I, /obj/item/rcd))
		add_fingerprint(user)
		to_chat(user, span_warning("The hatch is made of an advanced compound that cannot be deconstructed using an RCD."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/door/airlock/hatch/gamma/welder_act(mob/user, obj/item/I)
	if(shock_user(user, 75))
		return
	if(operating || !density)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, amount = 0, volume = I.tool_volume))
		return
	welded = !welded
	visible_message(span_notice("[user] [welded ? null : "un"]welds [src]!"),\
					span_notice("You [welded ? null : "un"]weld [src]!"),\
					span_italics("You hear welding."))
	update_icon()

/obj/machinery/door/airlock/maintenance_hatch
	name = "maintenance hatch"
	icon = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_mhatch
	paintable = FALSE

//////////////////////////////////
/*
	High Security Airlocks
*/

/obj/machinery/door/airlock/highsecurity
	name = "high tech security airlock"
	icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
	overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_highsecurity
	explosion_block = 2
	normal_integrity = 500
	security_level = 1
	damage_deflection = 30
	paintable = FALSE

/obj/machinery/door/airlock/highsecurity/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	if(!our_rcd.canRwall)
		return RCD_NO_ACT
	. = ..()

/obj/machinery/door/airlock/highsecurity/red
	name = "secure armory airlock"
	hackProof = TRUE
	aiControlDisabled = AICONTROLDISABLED_ON


/obj/machinery/door/airlock/highsecurity/red/attackby(obj/item/I, mob/user, params)
	if(!issilicon(user) && isElectrified() && shock(user, 75))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/detective_scanner))
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/machinery/door/airlock/highsecurity/red/welder_act(mob/user, obj/item/I)
	if(shock_user(user, 75))
		return
	if(operating || !density)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	welded = !welded
	visible_message(span_notice("[user] [welded ? null : "un"]welds [src]!"),\
					span_notice("You [welded ? null : "un"]weld [src]!"),\
					span_italics("You hear welding."))
	update_icon()


//////////////////////////////////
/*
	Shuttle Airlocks
*/

/obj/machinery/door/airlock/shuttle
	name = "shuttle airlock"
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_shuttle
	paintable = FALSE
	smoothing_groups = SMOOTH_GROUP_AIRLOCK

/obj/machinery/door/airlock/shuttle/glass
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/abductor
	name = "alien airlock"
	desc = "With humanity's current technological level, it could take years to hack this advanced airlock... or maybe we should give a screwdriver a try?"
	icon = 'icons/obj/doors/airlocks/abductor/abductor_airlock.dmi'
	overlays_file = 'icons/obj/doors/airlocks/abductor/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_abductor
	damage_deflection = 30
	explosion_block = 3
	hackProof = TRUE
	aiControlDisabled = AICONTROLDISABLED_ON
	normal_integrity = 700
	security_level = 1
	paintable = FALSE

//////////////////////////////////
/*
	Cult Airlocks
*/

/obj/machinery/door/airlock/cult
	name = "cult airlock"
	icon = 'icons/obj/doors/airlocks/cult/runed/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/runed/cult-overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult
	damage_deflection = 10
	hackProof = TRUE
	aiControlDisabled = AICONTROLDISABLED_ON
	paintable = FALSE
	/// Spawns an effect when opening
	var/openingoverlaytype = /obj/effect/temp_visual/cult/door
	/// Will the door let anyone through
	var/friendly = FALSE
	/// Is this door currently concealed
	var/stealthy = FALSE
	/// Door sprite when concealed
	var/stealth_icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	/// Door overlays when concealed (Bolt lights, maintenance panel, etc.)
	var/stealth_overlays = 'icons/obj/doors/airlocks/station/overlays.dmi'
	/// Is the concealed airlock glass
	var/stealth_glass = FALSE
	/// Opacity when concealed (For glass doors)
	var/stealth_opacity = TRUE
	/// Inner airlock material (Glass, plasteel)
	var/stealth_airlock_material = null

/obj/machinery/door/airlock/cult_fake
	name = "cult airlock"
	icon = 'icons/obj/doors/airlocks/cult/runed/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/runed/cult-overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult_fake

/obj/machinery/door/airlock/cult_fake/Initialize()
	. = ..()
	icon = SSticker.cultdat?.airlock_runed_icon_file
	overlays_file = SSticker.cultdat?.airlock_runed_overlays_file
	update_icon()

/obj/machinery/door/airlock/cult/Initialize()
	. = ..()
	icon = SSticker.cultdat?.airlock_runed_icon_file
	overlays_file = SSticker.cultdat?.airlock_runed_overlays_file
	update_icon()
	new openingoverlaytype(loc)

/obj/machinery/door/airlock/cult/canAIControl(mob/user)
	return (iscultist(user) && !isAllPowerLoss())

/obj/machinery/door/airlock/cult/allowed(mob/living/L)
	if(!density)
		return TRUE
	if(friendly || iscultist(L) || isshade(L)|| isconstruct(L))
		if(!stealthy)
			new openingoverlaytype(loc)
		return TRUE
	else
		if(!stealthy)
			new /obj/effect/temp_visual/cult/sac(loc)
			var/atom/throwtarget
			throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
			SEND_SOUND(L, pick(sound('sound/hallucinations/turn_around1.ogg', 0, 1, 50), sound('sound/hallucinations/turn_around2.ogg', 0, 1, 50)))
			L.Weaken(4 SECONDS)
			L.throw_at(throwtarget, 5, 1,src)
		return FALSE

/obj/machinery/door/airlock/cult/cult_conceal()
	icon = stealth_icon
	overlays_file = stealth_overlays
	set_opacity(stealth_opacity)
	glass = stealth_glass
	airlock_material = stealth_airlock_material
	name = "airlock"
	desc = "It opens and closes."
	stealthy = TRUE
	update_icon()

/obj/machinery/door/airlock/cult/cult_reveal()
	icon = SSticker.cultdat?.airlock_runed_icon_file
	overlays_file = SSticker.cultdat?.airlock_runed_overlays_file
	set_opacity(initial(opacity))
	glass = initial(glass)
	airlock_material = initial(airlock_material)
	name = initial(name)
	desc = initial(desc)
	stealthy = initial(stealthy)
	update_icon()

/obj/machinery/door/airlock/cult/narsie_act()
	return

/obj/machinery/door/airlock/cult/ratvar_act()
	new /obj/machinery/door/airlock/clockwork(get_turf(src))
	qdel(src)

/obj/machinery/door/airlock/cult/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/glass
	glass = TRUE
	opacity = FALSE

/obj/machinery/door/airlock/cult_fake/glass
	glass = TRUE
	opacity = FALSE

/obj/machinery/door/airlock/cult/glass/Initialize()
	. = ..()
	update_icon()

/obj/machinery/door/airlock/cult/glass/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/unruned
	icon = 'icons/obj/doors/airlocks/cult/unruned/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/unruned/cult-overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_cult/unruned
	openingoverlaytype = /obj/effect/temp_visual/cult/door/unruned

/obj/machinery/door/airlock/cult/unruned/Initialize()
	. = ..()
	icon = SSticker.cultdat?.airlock_unruned_icon_file
	overlays_file = SSticker.cultdat?.airlock_unruned_overlays_file
	update_icon()

/obj/machinery/door/airlock/cult/unruned/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/unruned/glass
	glass = TRUE
	opacity = FALSE

/obj/machinery/door/airlock/cult/unruned/glass/Initialize()
	. = ..()
	update_icon()

/obj/machinery/door/airlock/cult/unruned/glass/friendly
	friendly = TRUE

/obj/machinery/door/airlock/cult/weak
	name = "brittle cult airlock"
	desc = "An airlock hastily corrupted by blood magic, it is unusually brittle in this state."
	normal_integrity = 150
	damage_deflection = 5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

//////////////////////////////////
/*
	Clockwork Airlocks
*/

/obj/machinery/door/airlock/clockwork
	name = "clockwork airlock"
	icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi'
	overlays_file = 'icons/obj/doors/airlocks/clockwork/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_clock
	damage_deflection = 10
	hackProof = TRUE
	aiControlDisabled = AICONTROLDISABLED_ON
	paintable = FALSE
	/// Will the door let anyone through
	var/friendly = FALSE

/obj/machinery/door/airlock/clockwork/Initialize()
	. = ..()
	new /obj/effect/temp_visual/ratvar/door(get_turf(src))

/obj/machinery/door/airlock/clockwork/canAIControl(mob/user)
	return (isclocker(user) && !isAllPowerLoss())

/obj/machinery/door/airlock/clockwork/allowed(mob/living/L)
	if(!density)
		return TRUE
	if(friendly || isclocker(L))
		return TRUE
	else
		new /obj/effect/temp_visual/ratvar/door(loc)
		var/atom/throwtarget
		throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
		SEND_SOUND(L, pick(sound('sound/hallucinations/turn_around1.ogg', 0, 1, 50), sound('sound/hallucinations/turn_around2.ogg', 0, 1, 50)))
		L.Weaken(4 SECONDS)
		L.throw_at(throwtarget, 5, 1,src)
		return FALSE

/obj/machinery/door/airlock/clockwork/narsie_act()
	new /obj/machinery/door/airlock/cult(get_turf(src))
	qdel(src)

/obj/machinery/door/airlock/clockwork/ratvar_act()
	return

/obj/machinery/door/airlock/clockwork/friendly
	friendly = TRUE

/obj/machinery/door/airlock/clockwork/glass
	glass = TRUE
	opacity = FALSE

/obj/machinery/door/airlock/clockwork/glass/friendly
	friendly = TRUE

/obj/machinery/door/airlock/clockwork/weak
	name = "brittle clockwork airlock"
	desc = "An airlock made from pure-hands into some brass moving structure."
	normal_integrity = 150
	damage_deflection = 5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

//////////////////////////////////
/*
	Syndie airlocks by Furukai
*/

/obj/machinery/door/airlock/syndicate
	name = "evil looking airlock"
	desc = "Why does it have those blowers?"
	overlays_file = 'icons/obj/doors/airlocks/syndicate/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/syndicate/overlays.dmi'
	paintable = FALSE

/obj/machinery/door/airlock/syndicate/build_access_electronics()
	access_electronics = new /obj/item/access_control/syndicate(src)
	access_electronics.selected_accesses = length(req_access) ? req_access : list()
	access_electronics.one_access = check_one_access

/obj/machinery/door/airlock/syndicate/security
	name = "evil looking security airlock"
	icon = 'icons/obj/doors/airlocks/syndicate/security.dmi'
	assemblytype = /obj/structure/door_assembly/syndicate/door_assembly_syndie_sec
	normal_integrity = 500

/obj/machinery/door/airlock/syndicate/security/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 450

/obj/machinery/door/airlock/syndicate/public
	name = "evil looking public airlock"
	icon = 'icons/obj/doors/airlocks/syndicate/public.dmi'
	assemblytype = /obj/structure/door_assembly/syndicate/door_assembly_syndie_public
	normal_integrity = 350

/obj/machinery/door/airlock/syndicate/public/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 300

/obj/machinery/door/airlock/syndicate/atmos
	name = "evil looking atmos airlock"
	icon = 'icons/obj/doors/airlocks/syndicate/atmos.dmi'
	assemblytype = /obj/structure/door_assembly/syndicate/door_assembly_syndie_atmos
	normal_integrity = 400
/obj/machinery/door/airlock/syndicate/atmos/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 350

/obj/machinery/door/airlock/syndicate/maintenance
	name = "evil looking maintenance airlock"
	icon = 'icons/obj/doors/airlocks/syndicate/maintenance.dmi'
	assemblytype = /obj/structure/door_assembly/syndicate/door_assembly_syndie_maint
	normal_integrity = 300

/obj/machinery/door/airlock/syndicate/maintenance/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 250

/obj/machinery/door/airlock/syndicate/medical
	name = "evil looking medbay airlock"
	icon = 'icons/obj/doors/airlocks/syndicate/medical.dmi'
	assemblytype = /obj/structure/door_assembly/syndicate/door_assembly_syndie_med
	normal_integrity = 400


/obj/machinery/door/airlock/syndicate/medical/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 350

/obj/machinery/door/airlock/syndicate/cargo
	name = "evil looking cargo airlock"
	icon = 'icons/obj/doors/airlocks/syndicate/cargo.dmi'
	assemblytype = /obj/structure/door_assembly/syndicate/door_assembly_syndie_cargo
	normal_integrity = 400

/obj/machinery/door/airlock/syndicate/cargo/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 350

/obj/machinery/door/airlock/syndicate/research
	name = "evil looking research airlock"
	icon = 'icons/obj/doors/airlocks/syndicate/research.dmi'
	assemblytype = /obj/structure/door_assembly/syndicate/door_assembly_syndie_research
	normal_integrity = 400

/obj/machinery/door/airlock/syndicate/research/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 350

/obj/machinery/door/airlock/syndicate/engineering
	name = "evil looking engineering airlock"
	icon = 'icons/obj/doors/airlocks/syndicate/engineering.dmi'
	assemblytype = /obj/structure/door_assembly/syndicate/door_assembly_syndie_engi
	normal_integrity = 450

/obj/machinery/door/airlock/syndicate/engineering/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 400

/obj/machinery/door/airlock/syndicate/command
	name = "evil looking command airlock"
	icon = 'icons/obj/doors/airlocks/syndicate/command.dmi'
	assemblytype = /obj/structure/door_assembly/syndicate/door_assembly_syndie_com
	normal_integrity = 500

/obj/machinery/door/airlock/syndicate/command/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 450

/obj/machinery/door/airlock/syndicate/freezer
	name = "evil looking freezer airlock"
	desc = "It's not even cold inside..."
	icon = 'icons/obj/doors/airlocks/syndicate/freezer.dmi'
	assemblytype = /obj/structure/door_assembly/syndicate/door_assembly_syndie_freezer
	normal_integrity = 350

/obj/machinery/door/airlock/syndicate/freezer/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 300

/obj/machinery/door/airlock/syndicate/extmai
	name = "evil looking external maintenance airlock"
	icon = 'icons/obj/doors/airlocks/syndicate/maintenanceexternal.dmi'
	assemblytype = /obj/structure/door_assembly/syndicate/door_assembly_syndie_extmai
	normal_integrity = 350

/obj/machinery/door/airlock/syndicate/extmai/glass
	opacity = FALSE
	glass = TRUE
	normal_integrity = 300

/obj/machinery/door/airlock/syndicate/extmai/glass/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(user.a_intent == INTENT_HARM && ishuman(user) && (user.dna.species.obj_damage + user.physiology.punch_obj_damage > 0))
		return

/*
	Misc Airlocks
*/

//Terribly sorry for the code doubling, but things go derpy otherwise.
/obj/machinery/door/airlock/multi_tile
	name = "large airlock"
	dir = EAST
	width = 2
	icon = 'icons/obj/doors/airlocks/glass_large/glass_large.dmi'
	overlays_file = 'icons/obj/doors/airlocks/glass_large/overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/glass_large/overlays.dmi'
	assemblytype = /obj/structure/door_assembly/multi_tile
	paintable = FALSE


/obj/machinery/door/airlock/multi_tile/narsie_act()
	return

/obj/machinery/door/airlock/multi_tile/ratvar_act()
	return

/obj/machinery/door/airlock/multi_tile/glass
	opacity = FALSE
	glass = TRUE
