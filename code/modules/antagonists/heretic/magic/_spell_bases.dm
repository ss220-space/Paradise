
/obj/effect/proc_holder/spell/proc/get_things_to_cast_on(mob/user)
	return targeting.choose_targets(user, src)

/obj/effect/proc_holder/spell/aoe/get_things_to_cast_on(atom/center, radius_override)
	return targeting.choose_targets(action.owner, src, null, center, radius_override)

/obj/effect/proc_holder/spell/proc/on_spell_loss(mob/user = usr)
	return

/obj/effect/proc_holder/spell/proc/can_add(mob/granted)
	return TRUE

/// Registered against movement / status signals so the button re-evaluates can_cast()
/// (e.g. lighting up green the moment the caster steps into space).
/obj/effect/proc_holder/spell/proc/update_status_on_signal(datum/source, ...)
	SIGNAL_HANDLER
	action?.build_all_button_icons(UPDATE_BUTTON_STATUS)

/obj/effect/proc_holder/spell/pointed
	/// Message shown to the spell owner upon activating the pointed spell.
	var/active_msg
	/// Message shown to the spell owner upon deactivating the pointed spell.
	var/deactive_msg
	/// The casting range of our spell.
	var/cast_range = 7
	/// If aim assist is used. Disable to disable.
	var/aim_assist = TRUE


/obj/effect/proc_holder/spell/pointed/Initialize(mapload)
	. = ..()
	if(!active_msg)
		active_msg = "Вы готовитесь использовать [declent_ru(ACCUSATIVE)] на цели..."
	if(!deactive_msg)
		deactive_msg = "Вы отменяете [declent_ru(ACCUSATIVE)]."


/obj/effect/proc_holder/spell/pointed/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/spell_targeting = new()
	spell_targeting.range = cast_range
	return spell_targeting


/obj/effect/proc_holder/spell/pointed/add_mousepointer(client/on_who)
	. = ..()
	on_activation(on_who.eye)


/obj/effect/proc_holder/spell/pointed/remove_mousepointer(client/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!on_who)
		return
	on_deactivation(on_who.eye, refund_cooldown = refund_cooldown)


/obj/effect/proc_holder/spell/pointed/before_cast(list/targets, mob/user = usr)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		on_deactivation(action.owner, refund_cooldown = FALSE)
		return
	var/atom/cast_on = length(targets) ? targets[1] : null
	if(!action?.owner || !cast_on || get_dist(get_turf(action.owner), get_turf(cast_on)) <= cast_range)
		return
	cast_on.balloon_alert(action.owner, "слишком далеко!")
	return . | SPELL_CANCEL_CAST


/obj/effect/proc_holder/spell/pointed/proc/on_activation(mob/on_who)
	SHOULD_CALL_PARENT(TRUE)
	to_chat(on_who, span_notice("[active_msg] <b>Нажмите ЛКМ чтобы применить умение на цели!</b>"))
	action?.UpdateButtonIcon()
	return TRUE


/obj/effect/proc_holder/spell/pointed/proc/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(refund_cooldown)
		to_chat(on_who, span_notice("[deactive_msg]"))
	action?.UpdateButtonIcon()
	return TRUE


/obj/effect/proc_holder/spell/pointed/InterceptClickOn(mob/living/clicker, params, atom/target)
	var/atom/aim_assist_target
	if(aim_assist)
		aim_assist_target = aim_assist(clicker, target)
	var/atom/final_target = aim_assist_target || target
	if(get_dist(get_turf(clicker), get_turf(final_target)) > cast_range)
		final_target.balloon_alert(clicker, "слишком далеко!")
		return TRUE
	if(!valid_target(final_target, clicker))
		final_target.balloon_alert(clicker, "неподходящая цель!")
		return TRUE
	return ..(clicker, params, final_target)


/obj/effect/proc_holder/spell/pointed/proc/aim_assist(mob/living/clicker, atom/target)
	if(!isturf(target))
		return
	return (locate(/mob/living/carbon/human) in target) || (locate(/mob/living) in target)


/obj/effect/proc_holder/spell/pointed/projectile
	should_recharge_after_cast = FALSE
	/// What projectile we create when we shoot our spell.
	var/obj/projectile/projectile_type = /obj/projectile/magic/teleport
	/// How many projectiles we can fire per cast (like charges).
	var/projectile_amount = 1
	/// How many projectiles we have yet to fire, based on projectile_amount.
	var/current_amount = 0
	/// How many projectiles we fire every fire_projectile() call.
	var/projectiles_per_fire = 1


/obj/effect/proc_holder/spell/pointed/projectile/should_remove_click_intercept(mob/user)
	return !current_amount


/obj/effect/proc_holder/spell/pointed/projectile/valid_target(atom/cast_on)
	return TRUE


/obj/effect/proc_holder/spell/pointed/projectile/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return
	current_amount = projectile_amount


/obj/effect/proc_holder/spell/pointed/projectile/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(projectile_amount < 1 || projectile_amount == current_amount)
		return
	cooldown_handler.start_recharge(base_cooldown * ((projectile_amount - current_amount) / projectile_amount))
	current_amount = 0


/obj/effect/proc_holder/spell/pointed/projectile/cast(list/targets, mob/user = usr)
	. = ..()
	if(!isturf(action.owner.loc))
		return FALSE
	var/atom/cast_on = targets[1]
	var/turf/caster_turf = get_turf(action.owner)
	var/turf/caster_front_turf = get_step(action.owner, action.owner.dir)
	fire_projectile(cast_on)
	action.owner.newtonian_move(get_angle(caster_front_turf, caster_turf))
	if(current_amount <= 0)
		remove_mousepointer(action.owner.client, refund_cooldown = FALSE)
	return TRUE


/obj/effect/proc_holder/spell/pointed/projectile/after_cast(atom/cast_on)
	. = ..()
	if(current_amount != 0)
		return
	cooldown_handler.start_recharge()
	remove_mousepointer(action.owner.client)


/obj/effect/proc_holder/spell/pointed/projectile/proc/fire_projectile(atom/target)
	current_amount--
	for(var/i in 1 to projectiles_per_fire)
		var/obj/projectile/to_fire = new projectile_type(get_turf(action.owner))
		ready_projectile(to_fire, target, action.owner, i)
		to_fire.fire()
	return TRUE


/obj/effect/proc_holder/spell/pointed/projectile/proc/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	to_fire.original = target
	to_fire.firer = user
	var/list/click_params = targeting.click_params
	if(istext(click_params))
		click_params = params2list(click_params)
	to_fire.preparePixelProjectile(target, user, click_params)
