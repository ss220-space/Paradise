/obj/item/grenade/frag
	name = "frag grenade"
	desc = "Взрывчатое устройство, предназначенное для ручного подрыва. При детонации создаёт \
			взрывную волну и выпускает множественные осколки."
	icon_state = "frag"
	origin_tech = "materials=3;magnets=4"
	det_time = 3 SECONDS
	var/range = 5
	var/max_shrapnel = 4
	/// Reduced by armor
	var/embed_prob = 100
	var/embedded_type = /obj/item/embedded/shrapnel

/obj/item/grenade/frag/get_ru_names()
	return list(
		NOMINATIVE = "осколочная граната",
		GENITIVE = "осколочной гранаты",
		DATIVE = "осколочной гранате",
		ACCUSATIVE = "осколочную гранату",
		INSTRUMENTAL = "осколочной гранатой",
		PREPOSITIONAL = "осколочной гранате"
	)

/obj/item/grenade/frag/prime()
	. = ..()
	update_mob()
	var/turf/epicenter = get_turf(src)
	for(var/mob/living/carbon/human/H in epicenter)
		if(H.body_position == LYING_DOWN) //grenade is jumped on but get real fucked up
			embed_shrapnel(H, max_shrapnel)
			range = 1
	explosion(loc, devastation_range = 0, heavy_impact_range = 1, light_impact_range = range, breach = FALSE, cause = src)
	for(var/turf/T in view(range, loc))
		for(var/mob/living/carbon/human/H in T)
			var/shrapnel_amount = max_shrapnel - T.Distance(epicenter)
			if(shrapnel_amount > 0)
				embed_shrapnel(H, shrapnel_amount)
	qdel(src)

/obj/item/grenade/frag/proc/embed_shrapnel(mob/living/carbon/human/H, amount)
	for(var/i = 0, i < amount, i++)
		if(prob(embed_prob - H.getarmor(attack_flag = BOMB)))
			var/obj/item/embedded/S = new embedded_type(src)
			H.hitby(S, skipcatch = 1)
			S.throwforce = 1
			S.throw_speed = 1
			S.sharp = FALSE
		else
			to_chat(H, span_warning("Шрапнель отскакивает от вашей брони!"))
