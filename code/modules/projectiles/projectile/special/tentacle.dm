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
	if(QDELETED(thrown_item) || QDELETED(user))
		return

	if(thrown_item in user.contents)
		return

	if(user.get_active_hand())
		return

	if(thrown_item.GetComponent(/datum/component/two_handed) && user.get_inactive_hand())
		return

	reset_throw(user)
	user.put_in_active_hand(thrown_item)

/obj/projectile/tentacle/proc/tentacle_grab(mob/living/target, mob/living/carbon/user)
	if(QDELETED(target) || QDELETED(user))
		return

	if(target.grabbedby(user, supress_message = TRUE))
		target.grippedby(user) //instant aggro grab
		target.Weaken(1 SECONDS)

/obj/projectile/tentacle/proc/tentacle_harm(mob/living/target, mob/living/carbon/human/user)
	if(QDELETED(target) || QDELETED(user))
		return

	var/obj/item/offarm_item = user.get_inactive_hand()

	if(!offarm_item)
		return

	offarm_item.attack(target, user)

	target.visible_message(
		span_danger("[user] impales [target] with [offarm_item]!"), \
		span_danger("[user] impales you with [offarm_item]!")
	)
	add_attack_logs(user, target, "[user] pulled [target] with a tentacle, attacking them with [offarm_item]") //Attack log is here so we can fetch the item they're stabbing with.

/obj/projectile/tentacle/on_hit(atom/target, blocked = 0)
	if(blocked >= 100 || isturf(target))
		return FALSE

	var/mob/living/carbon/human/user = firer

	if(isitem(target))
		var/obj/item/item = target
		if(item.anchored)
			return FALSE

		to_chat(user, span_notice("You pull [item] towards yourself."))
		add_attack_logs(src, item, "[src] pulled [item] towards them with a tentacle")
		user.throw_mode_on()
		item.throw_at(user, 10, 2, callback = CALLBACK(src, PROC_REF(tentacle_disarm), item, user))
		qdel(source.gun)
		return TRUE

	else if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		switch(intent)
			if(INTENT_HELP)
				carbon_target.visible_message(
					span_danger("[carbon_target] is pulled by [user]'s tentacle!"), \
					span_userdanger("A tentacle grabs you and pulls you towards [user]!")
				)
				add_attack_logs(user, carbon_target, "[user] pulled [carbon_target] towards them with a tentacle")
				carbon_target.throw_at(get_step_towards(user, carbon_target), 8, 2)
				qdel(source.gun)
				return TRUE

			if(INTENT_DISARM)
				var/obj/item/active_hand = carbon_target.get_active_hand()
				var/obj/item/inactive_hand = carbon_target.get_inactive_hand()
				var/obj/item/hand_item = active_hand
				if(!istype(hand_item, /obj/item/shield))  //shield is priotity target
					hand_item = inactive_hand
					if(!istype(hand_item, /obj/item/shield))
						hand_item = active_hand
						if(!hand_item)
							hand_item = inactive_hand

				if(!hand_item)
					to_chat(user, span_danger("[carbon_target] has nothing in hand to disarm!"))
					return FALSE

				if(!carbon_target.drop_item_ground(hand_item))
					to_chat(user, span_danger("You can't seem to pry [hand_item] out of [carbon_target]'s hands!"))
					add_attack_logs(src, carbon_target, "[src] tried to grab [hand_item] out of [carbon_target]'s hand with a tentacle, but failed")
					return FALSE

				carbon_target.visible_message(
					span_danger("[hand_item] is yanked out of [carbon_target]'s hand by [src]!"), \
					span_userdanger("A tentacle pulls [hand_item] away from you!")
				)
				add_attack_logs(src, carbon_target, "[src] has grabbed [hand_item] out of [carbon_target]'s hand with a tentacle")
				on_hit(hand_item) //grab the item as if you had hit it directly with the tentacle
				return TRUE

			if(INTENT_GRAB)
				carbon_target.visible_message(
					span_danger("[carbon_target] is grabbed by [user]'s tentacle!"), \
					span_userdanger("A tentacle grabs you and pulls you towards [user]!")
				)
				add_attack_logs(user, carbon_target, "[user] grabbed [carbon_target] with a changeling tentacle")
				carbon_target.throw_at(get_step_towards(user, carbon_target), 8, 2, callback = CALLBACK(src, PROC_REF(tentacle_grab), carbon_target, user))
				qdel(source.gun)
				return TRUE

			if(INTENT_HARM)
				carbon_target.visible_message(
					span_danger("[carbon_target] is thrown towards [user] by a tentacle!"), \
					span_userdanger("A tentacle grabs you and throws you towards [user]!")
				)
				carbon_target.throw_at(get_step_towards(user, carbon_target), 8, 2, callback = CALLBACK(src, PROC_REF(tentacle_harm), carbon_target, user))
				qdel(source.gun)
				return TRUE

	else if(isliving(target))
		var/mob/living/living_target = target
		if(intent == INTENT_HARM)
			living_target.visible_message(
				span_danger("[living_target] is thrown towards [user] by a tentacle!"), \
				span_userdanger("A tentacle grabs you and throws you towards [user]!")
			)
			living_target.throw_at(get_step_towards(user, living_target), 8, 2, callback = CALLBACK(src, PROC_REF(tentacle_harm), living_target, user))
			qdel(source.gun)
			return TRUE
		else
			living_target.visible_message(
				span_danger("[living_target] is pulled by [user]'s tentacle!"), \
				span_userdanger("A tentacle grabs you and pulls you towards [user]!")
			)
			living_target.throw_at(get_step_towards(user, living_target), 8, 2)
			qdel(source.gun)
			return TRUE

/obj/projectile/tentacle/Destroy()
	qdel(chain)
	source = null
	return ..()
