/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
/obj/item/borg
	icon = 'icons/mob/robot_items.dmi'

/obj/item/borg/stun
	name = "electrically-charged arm"
	icon_state = "elecarm"
	var/charge_cost = 30


/obj/item/borg/stun/attack(mob/living/carbon/human/target, mob/living/silicon/robot/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(ishuman(target) && target.check_shields(src, 0, "[target]'s [name]", MELEE_ATTACK))
		playsound(target, 'sound/weapons/genhit.ogg', 50, TRUE)
		return .

	if(isrobot(user) && !user.cell.use(charge_cost))
		return .

	. |= ATTACK_CHAIN_SUCCESS
	user.do_attack_animation(target)
	target.Weaken(2 SECONDS)
	target.apply_effect(STUTTER, 10 SECONDS)
	target.apply_damage(20, STAMINA)

	target.visible_message(
		span_danger("[user] has prodded [target] with [src]!"),
		span_userdanger("[user] has prodded you with [src]!"),
	)

	playsound(loc, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	add_attack_logs(user, target, "Stunned with [src] ([uppertext(user.a_intent)])")


/obj/item/gun/energy/emittercannon
	name = "Emitter Cannon"
	desc = "Looks clean and very powerful."
	ammo_type = list(/obj/item/ammo_casing/energy/emittergunborg)
	icon_state = "emittercannon"
	var/charge_cost = 750

/obj/item/gun/energy/emittercannon/emp_act(severity)
	return

/obj/item/borg/overdrive
	name = "Overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
