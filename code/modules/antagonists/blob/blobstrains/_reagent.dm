/datum/blobstrain/reagent // Blobs that mess with reagents, all "legacy" ones // what do you mean "legacy" you never added an alternative
	var/datum/reagent/reagent

/datum/blobstrain/reagent/New(mob/camera/blob/new_overmind)
	. = ..()
	reagent = new reagent()


/datum/blobstrain/reagent/attack_living(mob/living/L)
	var/mob_protection = L.getarmor(null, BIO) * 0.01
	reagent.reaction_mob(L, REAGENT_TOUCH, BLOB_REAGENT_ATK_VOL, TRUE, mob_protection, overmind)
	send_message(L)

/datum/blobstrain/reagent/blobbernaut_attack(atom/attacking, mob/living/simple_animal/hostile/blobbernaut)
	if(!isliving(attacking))
		return

	var/mob/living/living_attacking = attacking
	var/mob_protection = living_attacking.getarmor(null, BIO) * 0.01
	reagent.reaction_mob(living_attacking, REAGENT_TOUCH, BLOBMOB_BLOBBERNAUT_REAGENT_ATK_VOL + blobbernaut_reagentatk_bonus, FALSE, mob_protection, overmind)//this will do between 10 and 20 damage(reduced by mob protection), depending on chemical, plus 4 from base brute damage.

/datum/blobstrain/reagent/on_sporedeath(mob/living/simple_animal/hostile/blob_minion/spore/spore)
	var/burst_range = (istype(spore)) ? spore.death_cloud_size : 1
	do_blob_chem_smoke(range = burst_range, holder = spore, reagent_volume = BLOB_REAGENT_SPORE_VOL, location = get_turf(spore), reagent_type = reagent.type)


/proc/do_blob_chem_smoke(range = 0, amount = DIAMOND_AREA(range), atom/holder = null, location = null, reagent_type = /datum/reagent/water, reagent_volume = 10, log = FALSE)
	var/smoke_type = /datum/effect_system/fluid_spread/smoke/chem/quick
	var/lifetime = /obj/effect/particle_effect/fluid/smoke/chem/quick::lifetime
	var/volume = reagent_volume * (lifetime /(1 SECONDS))
	do_chem_smoke(range, amount, holder, location, reagent_type, smoke_type, reagent_volume = volume, log = log)


// These can only be applied by blobs. They are what (reagent) blobs are made out of.
/datum/reagent/blob
	name = "Неизвестно"
	description = "Это не должно существовать, вам следует немедленно обратиться за помощью в adminhelp и написать баг-репорт в Discord'е."
	color = COLOR_WHITE
	taste_description = "ошибок в коде"
	penetrates_skin = TRUE
	clothing_penetration = 1
	metabolization_rate = BLOB_REAGENTS_METABOLISM

/// Used by blob reagents to calculate the reaction volume they should use when exposing mobs.
/datum/reagent/blob/proc/return_mob_expose_reac_volume(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	if(exposed_mob.stat == DEAD || HAS_TRAIT(exposed_mob, TRAIT_BLOB_ALLY))
		return FALSE //the dead, and blob mobs, don't cause reactions
	return round(reac_volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/// Exists to earmark the new overmind arg used by blob reagents.
/datum/reagent/blob/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	return ..()
