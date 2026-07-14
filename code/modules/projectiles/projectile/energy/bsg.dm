/obj/projectile/energy/bsg
	name = "Сфера чистой БС энергии"
	icon_state = "bluespace"
	impact_effect_type = /obj/effect/temp_visual/bsg_kaboom
	damage = 60
	range = 9
	weaken  = 8 SECONDS //This is going to knock you off your feet
	eyeblur = 20 SECONDS
	speed   = 2
	/// The strength of the core of the fired Б.С.Г.
	var/core_strength = 0

/obj/projectile/energy/bsg/proc/make_chain(obj/projectile/P, mob/user)
	P.chain = P.Beam(user, icon_state = "sm_arc_supercharged", icon = 'icons/effects/beam.dmi', time = 10 SECONDS, maxdistance = 30)

/obj/projectile/energy/bsg/on_hit(atom/target)
	. = ..()
	kaboom()
	qdel(src)

/obj/projectile/energy/bsg/on_range()
	kaboom()
	new /obj/effect/temp_visual/bsg_kaboom(loc)
	..()

/obj/projectile/energy/bsg/proc/kaboom()
	var/effects_mult = core_strength / 170
	playsound(src, 'sound/weapons/bsg_explode.ogg', 75 * effects_mult, TRUE)
	for(var/mob/living/living in hearers(7 * effects_mult, src)) //No stuning people with thermals through a wall.
		var/floored = FALSE
		if(ishuman(living))
			var/mob/living/carbon/human/human = living
			var/obj/item/gun/energy/bsg/bsg = locate() in human
			if(bsg)
				to_chat(human, span_notice("[bsg] развертывает энергетический щит, чтобы защитить вас от взрыва [declent_ru(GENITIVE)]."))
				continue

		var/distance = (1 + get_dist(living, src))
		if(prob(min(400 * effects_mult / distance, 100))) //100% chance to hit with the blast up to 3 tiles, after that chance to hit is 80% at 4 tiles, 66.6% at 5, 57% at 6, and 50% at 7
			if(prob(min(150 * effects_mult / distance, 100)))//100% chance to upgraded to a stun as well at a direct hit, 75% at 1 tile, 50% at 2, 37.5% at 3, 30% at 4, 25% at 5, 21% at 6, and finaly 19% at 7. This is calculated after the first hit however.
				floored = TRUE

			living.apply_damage((rand(15, 30) * (1.1 - distance / 10)) * effects_mult, BURN) //reduced by 10% per tile
			add_attack_logs(src, living, "Hit heavily by [src]")
			if(floored)
				to_chat(living, span_userdanger("Вы видите яркую вспышку синего света, когда [declent_ru(NOMINATIVE)] взрывается, сбивая вас с ног и обжигая!"))
				living.Weaken(8 * effects_mult SECONDS)
			else
				to_chat(living, span_userdanger("Вы видите яркую вспышку синего света, когда [declent_ru(NOMINATIVE)] взрывается, обжигая вас!"))

			if(immolate)
				living.adjust_fire_stacks(immolate)
				living.IgniteMob()
		else
			to_chat(living, span_userdanger("Вы чувствуете жар от взрыва [declent_ru(GENITIVE)], но он почти не задевает вас."))
			add_attack_logs(src, living, "Hit lightly by [src]")
			living.apply_damage(rand(1, 5) * effects_mult, BURN)
