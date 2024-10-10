/obj/item/grenade/bloodgrenade
	name = "Bloody Grenade"
	desc = "Красная граната с гравировкой \"Hematogenic Industries\"."
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "bloody"
	item_state = "flashbang"
	w_class = WEIGHT_CLASS_SMALL
	force = 2.0
	var/radius = 4
	var/max_beams = 10
	var/process_time = 6 SECONDS
	var/blood = 0

/obj/item/grenade/bloodgrenade/prime()
	..()

	START_PROCESSING(SSprocessing, src)
	sleep(process_time)
	STOP_PROCESSING(SSprocessing, src)
	do_sparks(10, TRUE, src)

	for(var/turf/T in view(min(10, sqrt(blood / 10)), src))
		var/D = get_dist(src, T)
		if(prob(D * D / 2))
			continue

		new/obj/effect/decal/cleanable/blood(T)
		for(var/mob/living/M in T)
			M.adjustFireLoss(blood / 25)

	qdel(src)
	return

/obj/item/grenade/bloodgrenade/process()
	var/beam_number = 0
	for(var/mob/living/carbon/human/H in view(radius, src))
		if(HAS_TRAIT(H, TRAIT_NO_BLOOD))
			continue

		if(H.stat)
			continue

		var/drain_amount = rand(50, 100)
		blood += drain_amount
		beam_number++
		H.bleed(drain_amount)
		H.Beam(src, icon_state = "drainbeam", time = 2 SECONDS)
		H.adjustBruteLoss(15)
		if(drain_amount >= 90)
			to_chat(H, span_warning("<b>Вы чувствуете, как ваша жизненная сила уходит!</b>"))

		if(beam_number >= max_beams)
			break
