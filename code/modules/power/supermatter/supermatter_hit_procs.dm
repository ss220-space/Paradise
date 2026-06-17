/obj/machinery/power/supermatter_crystal/proc/eat_bullets(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	var/turf/local_turf = loc
	if(!istype(local_turf))
		return NONE

	if(!istype(projectile.firer, /obj/machinery/power/emitter))
		investigate_log("has been hit by [projectile] fired by [key_name(projectile.firer)]", INVESTIGATE_ENGINE)
	if(projectile.flag != BULLET)
		log_activation(who = projectile.firer, how = projectile.firer_source_atom)
	else
		external_damage_immediate += projectile.damage * bullet_energy * 0.01
		// Stop taking damage at emergency point, yell to players at danger point.
		// This isn't clean and we are repeating [/obj/machinery/power/supermatter_crystal/proc/calculate_damage], sorry for this.
		var/damage_to_be = damage + external_damage_immediate * clamp((emergency_point - damage) / emergency_point, 0, 1)
		if(damage_to_be > danger_point)
			visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] сжимается под нагрузкой, сопротивляясь дальнейшим ударам!"))
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	if(istype(projectile, /obj/projectile/beam/emitter/hitscan))
		var/obj/projectile/beam/emitter/hitscan/mahlaser = projectile
		if(mahlaser?.integrity_heal)
			damage = max(0, damage - mahlaser?.integrity_heal)
		if(mahlaser?.energy_reduction)
			internal_energy = max(0, internal_energy - mahlaser?.energy_reduction)
		if(mahlaser?.psi_change)
			psy_coeff = clamp(psy_coeff + mahlaser?.psi_change, 0, 1)
	external_power_immediate += projectile.damage * bullet_energy
	if(istype(projectile, /obj/projectile/beam/emitter/hitscan/magnetic))
		absorption_ratio = clamp(absorption_ratio + 0.05, 0.15, 1)

	qdel(projectile)

/obj/machinery/power/supermatter_crystal/singularity_act()
	var/gain = 100
	investigate_log("was consumed by a singularity.", INVESTIGATE_ENGINE)
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.")
	visible_message(span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] поглощается сингулярностью!"))
	var/turf/sm_turf = get_turf(src)
	for(var/mob/hearing_mob as anything in GLOB.player_list)
		if(!is_valid_z_level(get_turf(hearing_mob), sm_turf))
			continue
		SEND_SOUND(hearing_mob, 'sound/effects/supermatter.ogg') //everyone goan know bout this
		to_chat(hearing_mob, span_bolddanger("Ужасающий скрежет наполняет ваши уши, и волна ужаса захлёстывает вас..."))
	qdel(src)
	return gain

/obj/machinery/power/supermatter_crystal/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("Это была действительно тупая идея."))
	jedi.investigate_log("had [jedi.p_their()] brain dusted by touching [src] with telekinesis.", INVESTIGATE_DEATHS)
	jedi.ghostize()
	var/obj/item/organ/internal/brain/rip_u = jedi.get_int_organ(/obj/item/organ/internal/brain)
	if(rip_u)
		rip_u.remove(jedi)
		qdel(rip_u)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/power/supermatter_crystal/attackby(obj/item/item, mob/user, params)
	if(!istype(item) || (item.flags & ABSTRACT) || !istype(user))
		return ATTACK_CHAIN_BLOCKED

	if(HAS_TRAIT(item, TRAIT_SUPERMATTER_IMMUNE))
		return ATTACK_CHAIN_BLOCKED

	if(istype(item, /obj/item/scalpel/supermatter))
		var/obj/item/scalpel/supermatter/scalpel = item
		to_chat(user, span_notice("Вы осторожно начинаете соскабливать [scalpel.declent_ru(INSTRUMENTAL)] частицу с [declent_ru(GENITIVE)]..."))

		if(!scalpel.use_tool(src, user, 60, volume = 100))
			return ATTACK_CHAIN_BLOCKED

		if(!scalpel.uses_left)
			to_chat(user, span_warning("У вас не получается отделить осколок от [declent_ru(GENITIVE)]! [DECLENT_RU_CAP(scalpel, NOMINATIVE)] больше недостаточно остёр."))
			return ATTACK_CHAIN_BLOCKED

		to_chat(user, span_danger("Вы отделяете осколок от [declent_ru(GENITIVE)]. [DECLENT_RU_CAP(src, NOMINATIVE)] начинает бурно реагировать!"))
		new /obj/item/nuke_core/supermatter_sliver(get_turf(user))
		supermatter_sliver_removed = TRUE
		external_power_trickle += 800
		log_activation(who = user, how = scalpel)

		scalpel.uses_left--
		if(!scalpel.uses_left)
			to_chat(user, span_notice("Крошечный кусочек [scalpel.declent_ru(GENITIVE)] отламывается, делая его бесполезным!"))

		return ATTACK_CHAIN_PROCEED

	if(istype(item, /obj/item/retractor/supermatter))
		to_chat(user, span_warning("Вы тыкаете в [declent_ru(ACCUSATIVE)] наконечниками [item.declent_ru(GENITIVE)] из гипер-ноблия. Ничего не происходит."))
		return ATTACK_CHAIN_BLOCKED

	if(istype(item, /obj/item/destabilizing_crystal))
		var/obj/item/destabilizing_crystal/destabilizing_crystal = item

		if(!is_main_engine)
			to_chat(user, span_warning("Вы не можете применить [destabilizing_crystal.declent_ru(ACCUSATIVE)] к [declent_ru(DATIVE)]."))
			return ATTACK_CHAIN_BLOCKED

		if(get_integrity_percent() < SUPERMATTER_CASCADE_PERCENT)
			to_chat(user, span_warning("[DECLENT_RU_CAP(destabilizing_crystal, NOMINATIVE)] можно применить только к [declent_ru(DATIVE)], целостность которого не ниже [SUPERMATTER_CASCADE_PERCENT]%."))
			return ATTACK_CHAIN_BLOCKED

		to_chat(user, span_warning("Вы начинаете присоединять [destabilizing_crystal.declent_ru(ACCUSATIVE)] к [declent_ru(DATIVE)]..."))
		if(!do_after(user, 3 SECONDS, src))
			return ATTACK_CHAIN_BLOCKED

		message_admins("[ADMIN_LOOKUPFLW(user)] attached [destabilizing_crystal] to the supermatter at [ADMIN_VERBOSEJMP(src)].")
		add_game_logs("attached [destabilizing_crystal] to the supermatter", user)
		user.investigate_log("attached [destabilizing_crystal] to a supermatter crystal.", INVESTIGATE_ENGINE)
		to_chat(user, span_danger("[DECLENT_RU_CAP(destabilizing_crystal, NOMINATIVE)] защёлкивается на [declent_ru(PREPOSITIONAL)]."))

		radio_announce(
			"Обнаружена интеграция неизвестного вещества в гиперструктуру кристалла!",
			src,
			emergency_channel
		)
		set_delam(SM_DELAM_PRIO_IN_GAME, /datum/sm_delam/cascade)
		external_damage_immediate += 10
		external_power_trickle += 500
		log_activation(who = user, how = destabilizing_crystal)
		qdel(destabilizing_crystal)

		return ATTACK_CHAIN_PROCEED

	return ..()

////Do not blow up our internal radio
///obj/machinery/power/supermatter_crystal/contents_explosion(severity, target)
//	return

/obj/machinery/power/supermatter_crystal/proc/wrench_act_callback(mob/user, obj/item/tool)
	if(moveable)
		default_unfasten_wrench(user, tool)

/obj/machinery/power/supermatter_crystal/proc/consume_callback(matter_increase, damage_increase)
	external_power_trickle += matter_increase
	external_damage_immediate += damage_increase

/obj/machinery/power/supermatter_crystal/attack_ai(mob/user)
	return
