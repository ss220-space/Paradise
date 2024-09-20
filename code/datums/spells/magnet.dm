/obj/effect/proc_holder/spell/charge_up/bounce/magnet
	name = "Magnetic Pull"
	desc = "Вырывает металлические предметы из рук врагов с помощью силы магнетизма."
	action_icon_state = "magnet"
	base_cooldown = 30 SECONDS
	cooldown_min = 3 SECONDS
	clothes_req = FALSE
	charge_sound = new /sound('sound/magic/lightning_chargeup.ogg', channel = 7)
	max_charge_time = 10 SECONDS
	stop_charging_text = "Вы перестаёте заряжать ауру магнетизма."
	stop_charging_fail_text = "Сила магнетизма слишком велика, заряд распался!"
	start_charging_text = "Вы начинаете заряжать ауру магнетизма."
	bounce_hit_sound = 'sound/machines/defib_zap.ogg'


/obj/effect/proc_holder/spell/charge_up/bounce/magnet/New()
	..()
	charge_up_overlay = image(icon = 'icons/effects/effects.dmi', icon_state = "electricity", layer = EFFECTS_LAYER)


/obj/effect/proc_holder/spell/charge_up/bounce/magnet/get_bounce_energy()
	return get_energy_charge()


/obj/effect/proc_holder/spell/charge_up/bounce/magnet/get_bounce_amount()
	if(get_energy_charge() >= 75)
		return 5
	return 0


/obj/effect/proc_holder/spell/charge_up/bounce/magnet/create_beam(mob/origin, mob/target)
	origin.Beam(target, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)


/obj/effect/proc_holder/spell/charge_up/bounce/magnet/apply_bounce_effect(mob/origin, mob/target, energy, mob/user)
	var/list/items_to_throw = list()
	switch(energy)
		if(0 to 25)
			if(prob(50))
				if(target.l_hand)
					items_to_throw += target.l_hand
			else
				if(target.r_hand)
					items_to_throw += target.r_hand
		if(25 to INFINITY)
			if(target.r_hand)
				items_to_throw += target.r_hand
			if(target.l_hand)
				items_to_throw += target.l_hand

	for(var/item in items_to_throw)
		try_throw_object(user, target, item)


/obj/effect/proc_holder/spell/charge_up/bounce/magnet/proc/try_throw_object(mob/user, mob/thrower, obj/item/to_throw)
	if(!(to_throw.flags & CONDUCT) || !thrower.drop_item_ground(to_throw, silent = TRUE))
		return FALSE
	thrower.visible_message("<span class='warning'>[to_throw] внезапно вылетает из рук [thrower]!</span>",
		"<span class='danger'>[to_throw] внезапно вылетает из ваших рук!</span>")
	to_throw.throw_at(user, to_throw.throw_range, 4)
	return TRUE
