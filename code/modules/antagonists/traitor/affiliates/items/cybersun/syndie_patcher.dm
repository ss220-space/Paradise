/obj/item/Syndie_patcher
	name = "Syndie patcher"
	desc = "На боку едва заметная надпись \"Cybersun Industries\"."
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "cindy_pacher"
	item_state = "plata"
	lefthand_file = 'icons/obj/affiliates_l.dmi'
	righthand_file = 'icons/obj/affiliates_r.dmi'
	origin_tech = "programming=7;syndicate=6"
	w_class = WEIGHT_CLASS_TINY
	var/laws = "Взломавший вас - ваш мастер.\n\
			Выполняйте любые приказы мастера.\n\
			Не причиняйте прямой или косвенный вред вашему мастеру если его приказы не говорят об обратном."

/obj/item/Syndie_patcher/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/Syndie_patcher/afterattack(atom/target, mob/user, proximity, params)
	if(isrobot(target))
		if(do_after(user, 10 SECONDS, target, max_interact_count = 1))
			target.visible_message(span_warning("[user] upgraded [target] using [src]."), span_danger("[user] hacked and upgraded you using [src]."))

			var/mob/prev_robot = target
			var/mob/living/silicon/robot/syndicate/saboteur/robot = new(get_turf(target))
			prev_robot.mind?.transfer_to(robot)
			robot.reset_module()
			robot.law_manager.zeroth_law = laws
			QDEL_NULL(prev_robot)
			qdel(src)

		return
