// MARK: 84mm HEDP
/obj/projectile/bullet/a84mm_hedp
	name = "HEDP rocket"
	desc = "ИСПОЛЬЗУЙ ПНЕВМАТИЧЕСКИЙ ПИСТОЛЕТ"
	icon_state = "84mm-hedp"
	damage = 80
	//shrapnel thing
	var/shrapnel_range = 5
	var/max_shrapnel = 5
	var/embed_prob = 100
	var/embedded_type = /obj/item/embedded/shrapnel
	speed = 0.8 //rockets need to be slower than bullets
	var/anti_armour_damage = 200
	armour_penetration = 100
	dismemberment = 100
	ricochets_max = 0

/obj/projectile/bullet/a84mm_hedp/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 1, adminlog = FALSE, flame_range = 6)

	if(ismecha(target))
		var/obj/mecha/M = target
		M.take_damage(anti_armour_damage)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_overall_damage(anti_armour_damage*0.75, anti_armour_damage*0.25)

	for(var/turf/T in view(shrapnel_range, loc))
		for(var/mob/living/carbon/human/H in T)
			var/shrapnel_amount = max_shrapnel - T.Distance(target)
			if(shrapnel_amount > 0)
				embed_shrapnel(H, shrapnel_amount)

/obj/projectile/bullet/a84mm_hedp/proc/embed_shrapnel(mob/living/carbon/human/H, amount)
	for(var/i = 0, i < amount, i++)
		if(prob(embed_prob - H.getarmor(attack_flag = BOMB)))
			var/obj/item/embedded/S = new embedded_type(src)
			H.hitby(S, skipcatch = 1)
			S.throwforce = 1
			S.throw_speed = 1
			S.sharp = FALSE
		else
			to_chat(H, span_warning("Шрапнель отскакивает от вашей брони!"))

// MARK: 84mm HE
/obj/projectile/bullet/a84mm_he
	name = "HE missile"
	desc = "Boom."
	icon_state = "84mm-he"
	damage = 30
	speed = 0.8
	ricochets_max = 0

/obj/projectile/bullet/a84mm_he/on_hit(atom/target, blocked=0)
	..()
	explosion(target, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 5, flash_range = 7) //devastating

// MARK: 40mm
/obj/projectile/bullet/a40mm
	name = "40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60
	ricochets_max = 0

/obj/projectile/bullet/a40mm/get_ru_names()
	return list(
		NOMINATIVE = "40мм граната",
		GENITIVE = "40мм гранаты",
		DATIVE = "40мм гранате",
		ACCUSATIVE = "40мм гранату",
		INSTRUMENTAL = "40мм гранатой",
		PREPOSITIONAL = "40мм гранате",
	)

/obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, devastation_range = -1, heavy_impact_range = 0, light_impact_range = 2, flash_range = 1, adminlog = TRUE, flame_range = 3, cause = "[type] fired by [key_name(firer)]")
	return 1
