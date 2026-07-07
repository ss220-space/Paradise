/datum/action/cooldown/spell/charged/beam/magnet
	name = "Magnetic Pull"
	desc = "Pulls metalic objects from enemies hands with the power of MAGNETS."
	button_icon_state = "magnet"
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	charge_sound ='sound/magic/lightning_chargeup.ogg'
	channel_message = "You start gathering magnetism around you."
	sound = 'sound/machines/defib_zap.ogg'
	charge_overlay_icon = 'icons/effects/effects.dmi'
	charge_overlay_state = "electricity"

/datum/action/cooldown/spell/charged/beam/magnet/send_beam(atom/origin, atom/to_beam, bounces)
	origin.Beam(to_beam, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
	apply_bounce_effect(origin, to_beam, owner)

/datum/action/cooldown/spell/charged/beam/magnet/proc/apply_bounce_effect(mob/origin, mob/target, mob/user)
	var/list/items_to_throw = list()
	if(target.r_hand)
		items_to_throw += target.r_hand
	if(target.l_hand)
		items_to_throw += target.l_hand

	for(var/item in items_to_throw)
		try_throw_object(user, target, item)

/datum/action/cooldown/spell/charged/beam/magnet/proc/try_throw_object(mob/user, mob/thrower, obj/item/to_throw)
	if(!(to_throw.flags & CONDUCT) || !thrower.drop_item_ground(to_throw, silent = TRUE))
		return FALSE
	thrower.visible_message(span_warning("[to_throw] gets thrown out of [thrower] [thrower.p_their()] hands!"),
		span_danger("[to_throw] suddenly gets thrown out of your hands!"))
	to_throw.throw_at(user, to_throw.throw_range, 4)
	return TRUE

/datum/action/cooldown/spell/charged/beam/magnet/get_target(atom/center)
	var/list/possibles = list()
	for(var/mob/living/carbon/to_check in view(target_radius, center))
		if(to_check == center || to_check == owner)
			continue
		if(!length(get_path_to(center, to_check, max_distance = target_radius, simulated_only = FALSE)))
			continue

		possibles += to_check

	if(!length(possibles))
		return null

	return pick(possibles)
