/obj/item/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	belt_icon = "flashbang"
	origin_tech = "materials=2;combat=3"
	light_power = 10

	var/light_time = 0.2 SECONDS // The duration the area is illuminated
	var/range = 7 // The range in tiles of the flashbang

/obj/item/grenade/flashbang/prime(power = 1)
	. = ..()
	update_mob()
	var/turf/T = get_turf(src)
	if(T)
		// VFX and SFX
		do_sparks(rand(5, 9), FALSE, src)
		playsound(T, 'sound/effects/bang.ogg', 100, TRUE)
		new /obj/effect/dummy/lighting_obj(T, range + 2, light_power, light_color, light_time)
		// Blob damage
		for(var/obj/structure/blob/B in get_hear(range + 1, T))
			var/damage = round(30 / (get_dist(B, T) + 1))
			B.take_damage(damage * power, BURN, MELEE, FALSE)

		// Stunning & damaging mechanic
		bang(T, src, range)
	qdel(src)

/**
 * Creates a flashing effect that blinds and deafens mobs within range
 *
 * Arguments:
 * * T - The turf to flash
 * * A - The flashing atom
 * * range - The range in tiles of the flash
 * * flash - Whether to flash (blind)
 * * bang - Whether to bang (deafen)
 */
/proc/bang(turf/target, atom/source, range = 7, flash = TRUE, bang = TRUE, direct_bang = TRUE)
	// Flashing mechanic
	var/turf/source_turf = get_turf(source)
	for(var/mob/living/M in hearers(range, target))
		if(M.stat == DEAD)
			continue
		M.show_message(span_warning("BANG"), 2)
		var/mobturf = get_turf(M)

		var/distance = max(1, get_dist(source_turf, mobturf))
		var/status_duration = max(10 SECONDS / distance, 4 SECONDS)

		// Flash
		if(flash)
			if(M.weakeyes)
				M.visible_message(span_disarm("<b>[M]</b> screams and collapses!"))
				to_chat(M, span_userdanger(span_fontsize3("AAAAGH!")))
				M.Weaken(status_duration * 3) //hella stunned
				if(ishuman(M))
					M.emote("scream")
					var/mob/living/carbon/human/H = M
					var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
					if(E)
						E.internal_receive_damage(8, silent = TRUE)
			if(M.flash_eyes())
				M.AdjustConfused(status_duration * 2)

			if(issilicon(M))
				M.Weaken(status_duration * 2)

		// Bang
		if(!bang)
			continue

		var/ear_safety = M.check_ear_prot()

		//Atmosphere affects sound
		var/pressure_factor = 1
		var/datum/gas_mixture/hearer_env = source_turf.get_readonly_air()
		var/datum/gas_mixture/source_env = target.get_readonly_air()

		if(hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
			if(pressure < ONE_ATMOSPHERE - 10) //-10 KPA as a nice soft zone before we start losing power
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE) / (ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else //space
			pressure_factor = 0

		if(distance <= 1)
			pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

		if(direct_bang && source_turf == mobturf) // Holding on person or being exactly where lies is significantly more dangerous and voids protection
			M.Weaken(10 SECONDS)

		if(ear_safety)
			return

		M.apply_damage(15, STAMINA)
		M.Weaken(status_duration * pressure_factor)
		M.Deaf(30 SECONDS * pressure_factor)

		if(!iscarbon(M))
			return

		var/mob/living/carbon/C = M
		var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)

		if(!istype(ears))
			return

		if(HAS_TRAIT(M, TRAIT_WEAK_EARS))
			ears.internal_receive_damage(10)

		ears.internal_receive_damage(5 * pressure_factor)
		if(ears.damage >= 15)
			to_chat(M, span_warning("Your ears start to ring badly!"))
			if(prob(ears.damage - 5))
				to_chat(M, span_warning("You can't hear anything!"))
			return

		if(ears.damage >= 5)
			to_chat(M, span_warning("Your ears start to ring!"))
