//does aoe brute damage when hitting targets, is immune to explosions
/datum/blobstrain/reagent/explosive_lattice
	name = "Взрывная решетка"
	description = "атакует небольшими взрывами, нанося среднее сочетание урона ожогами и травмами всем, кто находится близко к цели. Споры взрываются при смерти."
	effectdesc = "также имеет повышенную сопротивляемость взрывам, но получает повышенный урон от огня и других источников энергии."
	analyzerdescdamage = "Атакует небольшими взрывами, нанося среднее сочетание урона ожогами и травмами всем, кто находится близко к цели. Споры взрываются при смерти."
	analyzerdesceffect = "Обладает высокой устойчивостью к взрывам, но получает повышенный урон от огня и других источников энергии."
	color = "#8B2500"
	complementary_color = "#00668B"
	blobbernaut_message = "blasts"
	message = "Блоб взрывает тебя"
	reagent = /datum/reagent/blob/explosive_lattice

/datum/blobstrain/reagent/explosive_lattice/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_flag == BOMB)
		return 0
	else if(damage_flag != MELEE && damage_flag != BULLET && damage_flag != LASER)
		return damage * 1.5
	return ..()

/datum/blobstrain/reagent/explosive_lattice/on_sporedeath(mob/living/spore)
	var/obj/effect/temp_visual/explosion/fast/effect = new /obj/effect/temp_visual/explosion/fast(get_turf(spore))
	effect.alpha = 150
	for(var/mob/living/actor in orange(get_turf(spore), 1))
		if(ROLE_BLOB in actor.faction) // No friendly fire
			continue
		actor.take_overall_damage(BLOB_REAGENT_SPORE_VOL, BLOB_REAGENT_SPORE_VOL)

/datum/reagent/blob/explosive_lattice
	name = "Взрывная решетка"
	id = "blob_explosive_lattice"
	taste_description = "бомба"
	color = "#8B2500"

/datum/reagent/blob/explosive_lattice/return_mob_expose_reac_volume(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	if(exposed_mob.stat == DEAD || HAS_TRAIT(exposed_mob, TRAIT_BLOB_ALLY))
		return 0 //the dead, and blob mobs, don't cause reactions
	return reac_volume

/datum/reagent/blob/explosive_lattice/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	var/brute_loss = 0
	var/burn_loss = 0
	var/bomb_armor = 0
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)

	if(reac_volume >= 10) // If it's not coming from a sporecloud, AOE 'explosion' damage
		var/epicenter_turf = get_turf(exposed_mob)
		var/obj/effect/temp_visual/explosion/fast/ex_effect = new /obj/effect/temp_visual/explosion/fast(get_turf(exposed_mob))
		ex_effect.alpha = 150

		// Total damage to epicenter mob of 0.7*reac_volume, like a mid-tier strain
		brute_loss = reac_volume*0.4

		bomb_armor = exposed_mob.getarmor(null, BOMB)
		if(bomb_armor) // Same calculation and proc that ex_act uses on mobs
			brute_loss = brute_loss*(2 - round(bomb_armor*0.01, 0.05))

		burn_loss = brute_loss

		exposed_mob.take_overall_damage(brute_loss, burn_loss)

		for(var/mob/living/nearby_mob in orange(epicenter_turf, 1))
			if(ROLE_BLOB in nearby_mob.faction) // No friendly fire.
				continue
			if(nearby_mob == exposed_mob) // We've already hit the epicenter mob
				continue
			// AoE damage of 0.5*reac_volume to everyone in a 1 tile range
			brute_loss = reac_volume * 0.25
			burn_loss = brute_loss

			bomb_armor = nearby_mob.getarmor(null, BOMB)
			if(bomb_armor) // Same calculation and prod that ex_act uses on mobs
				brute_loss = brute_loss*(2 - round(bomb_armor*0.01, 0.05))
				burn_loss = brute_loss

			nearby_mob.take_overall_damage(brute_loss, burn_loss)

	else
		exposed_mob.apply_damage(0.6*reac_volume, BRUTE, forced = TRUE)
