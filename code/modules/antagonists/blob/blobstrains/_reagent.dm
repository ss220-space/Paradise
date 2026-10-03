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
