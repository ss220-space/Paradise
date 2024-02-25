
// Drill, Diamond drill, Mining scanner

#define DRILL_BASIC 1
#define DRILL_HARDENED 2

/obj/item/mecha_parts/mecha_equipment/drill
	name = "exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is the drill that'll pierce the heavens!"
	icon_state = "mecha_drill"
	equip_cooldown = 1.5 SECONDS
	energy_drain = 10
	force = 15
	harmful = TRUE
	sharp = TRUE
	var/drill_delay = 7
	var/drill_level = DRILL_BASIC

/obj/item/mecha_parts/mecha_equipment/drill/action(atom/target)
	if(!action_checks(target))
		return FALSE
	if(isspaceturf(target))
		return FALSE
	if(isobj(target))
		var/obj/target_obj = target
		if(target_obj.resistance_flags & UNACIDABLE)
			return FALSE
	if(isancientturf(target))
		visible_message(span_notice("This rock appears to be resistant to all mining tools except pickaxes!"))
		return FALSE
	target.visible_message(span_warning("[chassis] starts to drill [target]."),
						span_userdanger("[chassis] starts to drill [target]..."),
						span_italics("You hear drilling."))
	if(do_after_cooldown(target))
		log_message("Started drilling [target]")
		set_ready_state(FALSE)
		if(isturf(target))
			var/turf/T = target
			T.drill_act(src)
			set_ready_state(TRUE)
			return TRUE
		while(do_after_mecha(target, drill_delay))
			if(isliving(target))
				drill_mob(target, chassis.occupant)
				playsound(src, 'sound/weapons/drill.ogg', 40, TRUE)
			else if(isobj(target))
				var/obj/O = target
				O.take_damage(15, BRUTE, 0, FALSE, get_dir(chassis, target))
				playsound(src, 'sound/weapons/drill.ogg', 40, TRUE)
			else
				set_ready_state(TRUE)
				return TRUE
		set_ready_state(TRUE)

/turf/proc/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	return

/turf/simulated/wall/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	if(drill.do_after_mecha(src, 60 / drill.drill_level))
		drill.log_message("Drilled through [src]")
		dismantle_wall(TRUE, FALSE)

/turf/simulated/wall/r_wall/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	if(drill.drill_level >= DRILL_HARDENED)
		if(drill.do_after_mecha(src, 120 / drill.drill_level))
			drill.log_message("Drilled through [src]")
			dismantle_wall(TRUE, FALSE)
	else
		drill.occupant_message(span_danger("[src] is too durable to drill through."))

/turf/simulated/mineral/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	for(var/turf/simulated/mineral/M in range(drill.chassis, 1))
		if(get_dir(drill.chassis, M) & drill.chassis.dir)
			M.attempt_drill()
	drill.log_message("Drilled through [src]")
	drill.move_ores()

/turf/simulated/floor/plating/asteroid/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	for(var/turf/simulated/floor/plating/asteroid/M in range(1, drill.chassis))
		if((get_dir(drill.chassis, M) & drill.chassis.dir) && !M.dug)
			M.getDug()
	drill.log_message("Drilled through [src]")
	drill.move_ores()

/obj/item/mecha_parts/mecha_equipment/drill/proc/move_ores()
	if((locate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp) in chassis.equipment) && istype(chassis, /obj/mecha/working))
		var/obj/mecha/working/R = chassis //we could assume that it's a ripley because it has a clamp, but that's ~unsafe~ and ~bad practice~
		R.collect_ore()

/obj/item/mecha_parts/mecha_equipment/drill/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/drill/proc/drill_mob(mob/living/target, mob/user)
	target.visible_message(span_danger("[chassis] is drilling [target] with [src]!"),
						span_userdanger("[chassis] is drilling you with [src]!"))
	add_attack_logs(user, target, "DRILLED with [src] ([uppertext(user.a_intent)]) ([uppertext(damtype)])")
	if(target.stat == DEAD && target.getBruteLoss() >= 200)
		add_attack_logs(user, target, "gibbed")
		if(LAZYLEN(target.butcher_results) || issmall(target))
			target.harvest(chassis) // Butcher the mob with our drill.
		else
			target.gib()
	else
		var/splatter_dir = get_dir(chassis, target)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/obj/item/organ/external/target_part = H.get_organ(ran_zone(BODY_ZONE_CHEST))
			H.apply_damage(10, BRUTE, BODY_ZONE_CHEST, H.run_armor_check(target_part, MELEE))

			//blood splatters
			blood_color = H.dna.species.blood_color

			new /obj/effect/temp_visual/dir_setting/bloodsplatter(H.drop_location(), splatter_dir, blood_color)

					//organs go everywhere
			if(target_part && prob(10 * drill_level))
				target_part.droplimb()
		else
			target.adjustBruteLoss(10)
			if(isalien(target))
				new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter(target.drop_location(), splatter_dir)

/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	name = "diamond-tipped exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is an upgraded version of the drill that'll pierce the heavens!"
	icon_state = "mecha_diamond_drill"
	origin_tech = "materials=4;engineering=4"
	equip_cooldown = 1 SECONDS
	drill_delay = 4
	drill_level = DRILL_HARDENED

/obj/item/mecha_parts/mecha_equipment/drill/giga
	name = "Old giant steel drill"
	desc = "Time-tested giant diamond-coated steel drill. This giant will drill anything!"
	icon_state = "mech_gigadrill"
	equip_cooldown = 0.5 SECONDS
	drill_delay = 2
	drill_level = DRILL_HARDENED
	integrated = TRUE

/obj/item/mecha_parts/mecha_equipment/mining_scanner
	name = "exosuit mining scanner"
	desc = "Equipment for engineering and combat exosuits. It will automatically check surrounding rock for useful minerals."
	icon_state = "mecha_analyzer"
	equip_cooldown = 1.5 SECONDS

/obj/item/mecha_parts/mecha_equipment/mining_scanner/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/mining_scanner/attach_act(obj/mecha/M)
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/mining_scanner/detach_act(obj/mecha/M)
	STOP_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/mining_scanner/process()
	if(!chassis)
		STOP_PROCESSING(SSobj, src)
		return TRUE
	if(!action_checks(src))
		return FALSE
	if(istype(loc, /obj/mecha/working))
		var/obj/mecha/working/mecha = loc
		if(!mecha.occupant)
			return FALSE
		mineral_scan_pulse(get_turf(src))
		start_cooldown()
		return TRUE

/obj/item/mecha_parts/mecha_equipment/mining_scanner/action(atom/target)
	melee_attack_chain(chassis.occupant, target)
	return TRUE

#undef DRILL_BASIC
#undef DRILL_HARDENED
