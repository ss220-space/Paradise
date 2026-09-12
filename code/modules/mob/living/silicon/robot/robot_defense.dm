/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(M.a_intent == INTENT_DISARM)
		if(body_position != LYING_DOWN)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			var/obj/item/I = get_active_hand()

			if(I)
				uneq_active()
				balloon_alert_to_viewers("обезоружен!")
				add_attack_logs(M, src, "alien disarmed")

			else
				Stun(4 SECONDS)
				step(src, get_dir(M,src))
				add_attack_logs(M, src, "Alien pushed over")
				balloon_alert_to_viewers("оглушён!")

			playsound(loc, 'sound/weapons/pierce.ogg', 50, TRUE, -1)

	else
		..()

	return

/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M)
	. = ..()

	if(!.) //successful slime shock
		return

	flash_eyes(3, affect_silicon = TRUE)
	var/stunprob = M.powerlevel * 7 + 10

	if(prob(stunprob) && M.powerlevel >= 8)
		adjustBruteLoss(M.powerlevel * rand(6,10))

	var/damage = rand(1, 3)

	if(M.age_state.age != SLIME_BABY)
		damage = rand(20 + M.age_state.damage, 40 + M.age_state.damage)

	else
		damage = rand(5, 35)

	damage = round(damage / 2) // borgs receive half damage
	adjustBruteLoss(damage)

	return .

/mob/living/silicon/robot/attack_hand(mob/living/carbon/human/user)
	add_fingerprint(user)

	if(opened && !wiresexposed && !issilicon(user))
		if(cell)
			cell.update_icon()
			cell.add_fingerprint(user)
			cell.forceMove_turf()
			user.put_in_active_hand(cell, ignore_anim = FALSE)
			balloon_alert(user, "аккумулятор извлечен")
			var/datum/robot_component/C = components["power cell"]
			C.uninstall()
			module?.update_cells(unlink_cell = TRUE)
			diag_hud_set_borgcell()

	if(!opened)
		if(..()) // hulk attack
			spark_system.start()
			step_away(src, user, 15)
			sleep(3)
			step_away(src, user, 15)

/mob/living/silicon/robot/bullet_act(obj/projectile/projectile)
	if(module_active && iscyborgmobilitymodule(module_active))
		return ..(projectile)
	if(!reflection_type || !reflectable)
		return ..(projectile)
	if((!istype(projectile) || !projectile.is_reflectable(reflection_type) || !projectile.starting))
		return ..(projectile)
	balloon_alert_to_viewers("снаряд отражен")
	projectile.reflect_back(src)
	return -1
