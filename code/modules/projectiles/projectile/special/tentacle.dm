/obj/projectile/tentacle
	name = "tentacle"
	icon_state = "tentacle_end"
	damage = 0
	range = 8
	hitsound = 'sound/weapons/thudswoosh.ogg'
	reflectability = REFLECTABILITY_NEVER //Let us not reflect this ever. It's not quite a bullet, and a cling should never wrap its tentacle around itself, it controls its body well
	var/intent = INTENT_HELP
	var/obj/item/ammo_casing/magic/tentacle/source //the item that shot it

/obj/projectile/tentacle/Initialize(mapload)
	source = loc
	. = ..()

/obj/projectile/tentacle/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "tentacle", time = INFINITY, maxdistance = INFINITY)
		intent = firer.a_intent
		if(intent == INTENT_DISARM)
			armour_penetration = 100   //ignore block_chance
	..()

/obj/projectile/tentacle/proc/reset_throw(mob/living/carbon/human/user)
	if(QDELETED(user))
		return
	if(user.in_throw_mode)
		user.throw_mode_off() //Don't annoy the changeling if he doesn't catch the item

/obj/projectile/tentacle/proc/tentacle_disarm(obj/item/thrown_item, mob/living/carbon/user)
	reset_throw(user)

	if(QDELETED(thrown_item) || QDELETED(user))
		return

	if(thrown_item in user.contents)
		return

	if(user.get_active_hand())
		return

	if(thrown_item.GetComponent(/datum/component/two_handed) && user.get_inactive_hand())
		return

	user.put_in_active_hand(thrown_item)

/obj/projectile/tentacle/proc/tentacle_grab(mob/living/carbon/target, mob/living/carbon/user)
	if(QDELETED(target) || QDELETED(user))
		return

	if(!user.Adjacent(target))
		return

	if(target.grabbedby(user, supress_message = TRUE))
		target.grippedby(user) //instant aggro grab
		target.Weaken(4 SECONDS)

/obj/projectile/tentacle/proc/tentacle_stab(mob/living/carbon/target, mob/living/carbon/user)
	if(QDELETED(target) || QDELETED(user))
		return

	if(!user.Adjacent(target))
		return

	var/obj/item/offarm_item = user.get_active_hand()
	if(!offarm_item.sharp)
		offarm_item = user.get_inactive_hand()

	if(!offarm_item.sharp)
		return

	target.visible_message(span_danger("[user] impales [target] with [offarm_item]!"), \
							span_danger("[user] impales you with [offarm_item]!"))
	add_attack_logs(user, target, "[user] pulled [target] with a tentacle, attacking them with [offarm_item]") //Attack log is here so we can fetch the item they're stabbing with.

	target.apply_damage(offarm_item.force, BRUTE, BODY_ZONE_CHEST)
	user.do_attack_animation(target, used_item = offarm_item)
	offarm_item.add_mob_blood(target)
	playsound(get_turf(user), offarm_item.hitsound, 75, TRUE)

/obj/projectile/tentacle/on_hit(atom/target, blocked = 0)
	qdel(source.gun) //one tentacle only unless you miss
	if(blocked >= 100)
		return FALSE

	var/mob/living/carbon/human/user = firer
	if(isitem(target))
		var/obj/item/item = target
		if(!item.anchored)
			to_chat(firer, span_notice("You pull [item] towards yourself."))
			add_attack_logs(src, item, "[src] pulled [item] towards them with a tentacle")
			user.throw_mode_on()
			item.throw_at(user, 10, 2, callback = CALLBACK(src, PROC_REF(tentacle_disarm), item, user))
			. = TRUE

	else if(isliving(target))
		var/mob/living/l_target = target
		if(!l_target.anchored && !l_target.throwing)//avoid double hits
			if(iscarbon(l_target))
				var/mob/living/carbon/c_target = l_target
				switch(intent)
					if(INTENT_HELP)
						c_target.visible_message(span_danger("[c_target] is pulled by [user]'s tentacle!"), \
												span_userdanger("A tentacle grabs you and pulls you towards [user]!"))

						add_attack_logs(user, c_target, "[user] pulled [c_target] towards them with a tentacle")
						c_target.client?.move_delay = world.time + 1 SECONDS
						c_target.throw_at(get_step_towards(user, c_target), 8, 2)
						return TRUE

					if(INTENT_DISARM)
						var/obj/item/active_hand = c_target.get_active_hand()
						var/obj/item/inactive_hand = c_target.get_inactive_hand()
						var/obj/item/hand_item = active_hand
						if(!istype(hand_item, /obj/item/shield))  //shield is priotity target
							hand_item = inactive_hand
							if(!istype(hand_item, /obj/item/shield))
								hand_item = active_hand
								if(!hand_item)
									hand_item = inactive_hand

						if(hand_item)
							if(c_target.drop_item_ground(hand_item))
								c_target.visible_message(span_danger("[hand_item] is yanked out of [c_target]'s hand by [src]!"), \
														span_userdanger("A tentacle pulls [hand_item] away from you!"))
								add_attack_logs(src, c_target, "[src] has grabbed [hand_item] out of [c_target]'s hand with a tentacle")
								on_hit(hand_item) //grab the item as if you had hit it directly with the tentacle
								return TRUE

							else
								to_chat(firer, span_danger("You can't seem to pry [hand_item] out of [c_target]'s hands!"))
								add_attack_logs(src, c_target, "[src] tried to grab [hand_item] out of [c_target]'s hand with a tentacle, but failed")
								return FALSE

						else
							to_chat(firer, span_danger("[c_target] has nothing in hand to disarm!"))
							return FALSE

					if(INTENT_GRAB)
						c_target.visible_message(span_danger("[c_target] is grabbed by [user]'s tentacle!"), \
												span_userdanger("A tentacle grabs you and pulls you towards [user]!"))
						add_attack_logs(user, c_target, "[user] grabbed [c_target] with a changeling tentacle")
						c_target.client?.move_delay = world.time + 1 SECONDS
						c_target.throw_at(get_step_towards(user, c_target), 8, 2, callback = CALLBACK(src, PROC_REF(tentacle_grab), c_target, user))
						return TRUE

					if(INTENT_HARM)
						c_target.visible_message(span_danger("[c_target] is thrown towards [user] by a tentacle!"), \
												span_userdanger("A tentacle grabs you and throws you towards [user]!"))
						c_target.client?.move_delay = world.time + 1 SECONDS
						c_target.throw_at(get_step_towards(user, c_target), 8, 2, callback = CALLBACK(src, PROC_REF(tentacle_stab), c_target, user))
						return TRUE

			else
				l_target.visible_message(span_danger("[l_target] is pulled by [user]'s tentacle!"), \
										span_userdanger("A tentacle grabs you and pulls you towards [user]!"))
				l_target.throw_at(get_step_towards(user, l_target), 8, 2)
				. = TRUE

/obj/projectile/tentacle/Destroy()
	qdel(chain)
	source = null
	return ..()
